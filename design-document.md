# HopNest — Design Document
*Subway + Hotel + Sightseeing trip planner*

This is a living document. Every time meaningful work is done on the app,
a dated entry gets added to the Changelog at the bottom. Everything above
the changelog reflects the *current* state of the app, not history — if
something changes, the relevant section gets edited in place rather than
left stale.

---

## How HopNest actually helps someone plan a trip

Normally, "where should I stay" means juggling four separate tools — a
subway map, a hotel booking site, a sightseeing guide, and eyeballing
distances on a generic map to guess whether anything actually connects.
HopNest puts all of that on one screen, so the question becomes
answerable at a glance instead of a research project.

**The actual flow, start to finish:**

1. **Pick a city** — real subway colors, real geography, not placeholders.
2. **See trustworthy hotels immediately, no research needed.** The
   default view isn't "every hotel" — it's a pre-vetted shortlist per
   busy area: real brand names, ≥4.0 rating with enough reviews to
   actually trust it, spread across budget to luxury. Shortlist over
   directory is the whole point — booking sites already give you 200
   options; HopNest gives you the ones worth considering.
3. **Click any station, airport, or rail hub → see exactly what's
   walkable from there**, with a live-adjustable radius. This is the
   single biggest thing a booking site can't do well — "is this hotel
   actually convenient" answered visually, not by squinting at a tiny
   map thumbnail.
4. **Filter by star class** to match budget without wading through
   irrelevant tiers.
5. **See real, TripAdvisor-vetted sightseeing** layered on the same map
   — hotels and what's worth visiting nearby in one glance, not two
   separate apps cross-referenced by hand.
6. **Real first/last train times** for the connections that actually
   matter — airport and rail links — genuinely useful for a late flight
   or an early Eurostar, not decorative info.
7. **Search anything by name**, and if it's not in the curated list,
   **live-search the real web for it** (off for launch; the public site
   offers a Booking.com search instead) — so someone who already booked a
   random hotel can still check "is this actually walkable" instead of
   being stuck with only the pre-picked options.
8. **Pin favorites** while comparing, so browsing doesn't mean losing
   track of what was liked.

**The honest summary of the value:** HopNest isn't trying to be Google
Maps or a booking site — it's trying to answer one specific, recurring
travel-planning question really well: *"given where I want to be, what's
actually nearby and trustworthy?"* — with real data behind every answer,
not guesses.

---

## 1. What this is

A single-page interactive map that solves one specific problem: existing
map apps don't let you see subway routes, hotel walkability, and
sightseeing together. HopNest overlays all three, lets you toggle subway
lines on/off, and highlights which hotels are actually walkable from a
station/airport/railway stop you tap.

## 2. Architecture

- **One HTML file for the app** (`site/index.html`) plus **one JSON file
  per city** in `site/data/` (since 2026-10-15). No build step and no
  backend, but the page fetches its data files, so it must be served over
  HTTP (GitHub Pages, or `python3 -m http.server --directory site`
  locally); opening `index.html` straight from disk no longer loads cities.
- **Map engine:** Leaflet.js (via CDN) + OpenStreetMap tiles.
- **Data model:** `site/data/cities.json` lists every city (`name`,
  `country`, `flag`, `comingSoon?`), and each ready city has
  `site/data/<cityId>.json`. On startup `loadAllCities()` fetches them all
  into the in-page `CITIES` object, so the rest of the code is unchanged.
  All cities load up front (~15 KB each), not on first open, because pins
  and share links can point at any city. Hotel/sight IDs (`<city>_h<n>`,
  `<city>_s<n>`) are assigned at load from their position in the file, so
  **never reorder or delete hotels or sights in a city file**; append new
  ones at the end, or saved pins and old share links will point at the
  wrong place. Each city file has this shape:
  ```
  cityId: {
    name, country, flag, center:[lat,lng], zoom,
    lines:    [{ id, name, jp?, color, code, stations:[[name,lat,lng],...] }],
    hotels:   [{ name, lat, lng, area, rating, ratingCount?, stars,
                 priceTier(1-4), phone?, curated, brandAnchor? }],
    sights:   [{ name, lat, lng, note, hours?, rating?, phone? }],
    railStations: [{ name, lat, lng, note }],
    airports: [{ name, code, lat, lng, transitNote }]
  }
  ```
  Adding a city = one JSON file in this shape plus one line in
  `cities.json` (see §4 "Adding a city"). No rendering code needs to
  change.
- **No backend, no database.** Everything is static data baked into the
  file at the time I edit it. The only saved state is per-browser
  `localStorage`: pinned hotels/sights and the last-viewed city survive a
  reload (live-search pins are saved as full snapshots so they don't need
  re-fetching). Nothing syncs across devices.
- **Installable (PWA)**: `manifest.json` + `icon-192.png`, `icon-512.png`
  and `apple-touch-icon.png`, plus iOS-specific meta tags, so "Add to Home
  Screen" opens HopNest full-screen with its own icon. No service worker,
  so no offline support.

## 3. Features (current state)

- **Subway lines**: real official colors, toggleable per line, station
  dots clickable.
- **Transfers** (2026-10-16, restyled 2026-10-17): like LA Metro's
  Expo/Crenshaw mark: a white circle at each line's platform joined by a
  white bar, drawn as one smooth shape with only a thin, soft grey-blue
  outline on the outer edge (no line where circles meet the bar). It marks a station where you change lines inside
  (one label per interchange); a dashed grey line
  joins two separate stations a short walk apart. The station popup says
  which lines you can change to, or how far the walk is. Worked out in
  the browser from the line data (no extra data): same station name on
  lines of different colours within 500 m = one station; different names
  within 200 m, or the same name 500–800 m apart = walk. A legend sits
  under the line list.
- **Cities**: Tokyo, Shanghai, New York City, London, Barcelona, plus
  the scale-up (2026-10-15/16): Paris, Seoul, Osaka, Hong Kong,
  Singapore, Taipei, Bangkok, Beijing, Madrid, Rome, Berlin, Amsterdam,
  Vienna, Prague, Istanbul, Lisbon, Milan, Washington DC, Chicago,
  Mexico City, and batch 5 (2026-10-16): Shenzhen, Guangzhou, Xi'an,
  Busan, Kuala Lumpur, Dubai, Delhi, Munich, Budapest, Copenhagen,
  Stockholm, Athens, Brussels, San Francisco, Los Angeles, Boston,
  Toronto, Montreal, São Paulo, Buenos Aires, and batch 6 (2026-10-17):
  Kyoto, Macau, Chengdu, Ho Chi Minh City, Hanoi, Mumbai, Jakarta,
  Riyadh, Doha, Jerusalem, Cairo, Dublin, Edinburgh, Florence, Miami,
  Las Vegas, Vancouver, Rio de Janeiro, Sydney, Melbourne. Batch 7 (US, 2026-10-18):
  Seattle, Philadelphia, San Diego, New Orleans, Atlanta. Batch 8 (US, 2026-10-18):
  Portland, Honolulu, Denver, Dallas, Baltimore, Minneapolis–Saint Paul, Salt Lake City, Houston, Phoenix, St. Louis, Pittsburgh, Charlotte. Batch 9 (US, 2026-10-18):
  Detroit, Buffalo, Cincinnati, Milwaukee, Cleveland, Norfolk, Sacramento, Tucson, Kansas City, San Jose, Austin, Tampa (94 cities).
  City-list groups: Asia, Europe, Americas, Africa, Oceania.
- **City picker** (search redesigned 2026-10-16): a search box that
  matches city name, country, other names (`aliases` in `cities.json`:
  local script, nicknames like NYC) and airport codes (CDG, KIX), with
  one-typo tolerance; results are ranked and Enter opens the best one.
  With no search, recently opened cities come first, then cities grouped
  by `region` (Asia, Europe, Americas), alphabetized; the list scrolls.
  Each continent heading opens/closes its group (shows the city count);
  only the current city's continent starts open, and the open/closed
  choice is remembered in the browser. Searching ignores it and lists
  every match.
  Kept separate from the in-city place search.
  Cities without data yet show as "coming soon"; a text box lets the user
  request a new one (session-only placeholder).
- **Place search**: typeahead search bar for curated hotels, sights,
  subway/rail stations and airports in the current city (accent-
  insensitive). It only searches saved data, never the web. Shows every
  match in a scrollable list (no cap). Order: sights first, then
  stations/rail/airports, then hotels; within each group, name matches
  before area/description matches. (Before 2026-10-15 hotels came first
  and the list capped at 8, so typing "Shibuya" showed only hotels.)
- **Live hotel name search**: if a searched hotel isn't curated, it can
  be looked up on the web by name and dropped on the map (same
  live-search mechanism and caveats as below). Off for launch: with no
  match, the dropdown shows "Search hotels for "<query>" on Booking.com"
  (query + city, new tab) instead of the web-search button.
- **Hotel walkability**: slider (5–20 min, presets at 5/10/15) sizes the
  walk-radius circle drawn when you tap a station/airport/rail icon.
  Precise walkability is read from the circle (dark green = confirmed
  within radius of that specific point) rather than a separate filter
  toggle — a redundant "only show walkable" checkbox was removed on
  2026-07-12 once we confirmed the circle already answers that question
  more precisely.
- **Click-to-reveal circles**: tapping a subway station, airport, or
  railway icon draws its walk-radius circle. Tapping elsewhere on the map
  clears all open circles. Tapping the same icon again also clears just
  that one.
- **Revealed hotels stay (decided 2026-10-17)**: a click-to-reveal hotel
  that any circle has shown stays on the map and in the hotel list (light
  green) after the circle closes, until the page reloads. The star filter
  still applies to it.
- **Color logic**: default/curated hotels = light green diamond always.
  Hotels revealed by a **subway** station's circle = dark green (spotlight).
  Hotels revealed by an **airport/rail** circle = light green (treated as
  "more default coverage," not a special highlight).
- **Live search fallback**: if a clicked spot has no curated data, the
  page calls Claude's API (web search enabled) to fetch real hotels on
  the fly. Only works while viewing this as a live Claude artifact — it
  cannot authenticate from a downloaded standalone file. See §5.
  **Turned off for launch** (`LIVE_SEARCH_ENABLED = false`). Re-enable
  once a backend proxy holds the API key.
- **Nearest-hotels fallback (replaces the "not curated yet" banner for
  station/airport/rail clicks, decided 2026-10-10)**: when no stored hotel
  (curated or click-to-reveal) is within the walk radius of the clicked
  point and live search is off, a card lists the **3 nearest always-
  visible curated hotels** (stars, area, walk time up to 2 km, otherwise
  km; picks respect the star filter) — the map flies to fit the station
  and those 3 hotels above the card, so they're visible on the map, not
  just listed; tapping one flies to it and opens its popup — plus a **"Search
  all hotels near <station>"** button linking to a Booking.com search for
  that station and city (new tab). $0, no backend; the link is where an
  affiliate ID goes later. Closes with ×, a map tap, or the next
  message. Coverage counts *any* stored hotel within radius, so a
  station whose only nearby hotels are click-to-reveal ones no longer
  shows the fallback while those hotels are on the map.
- **Pinning**: any hotel or sight can be pinned (📌); pinned items always
  show regardless of filters/circles. Pins persist across reloads in the
  same browser (`localStorage`).
- **Trip sharing (no backend)**: "🔗 Share my pinned picks" encodes every
  pin (across all cities) into one URL and copies it in a single tap; the
  link field and Copy button only appear if auto-copy fails. Curated pins
  are encoded as IDs, live-search pins as full snapshots. Opening a shared
  link loads its city and merges its pins into the recipient's saved pins.
- **Fares**: real fare structure per city in the sidebar, plus airport
  supplements shown on the relevant airport (e.g. JFK AirTrain,
  Barcelona L9 Sud).
- **First/last train times** on airport and intercity rail connectors.
- **Sight details**: TripAdvisor-vetted sights with hours, rating,
  official ticket link and a "books up" flag where relevant; thumbnails
  in Barcelona (pilot).
- **Star class vs. guest rating**: `stars` (1–5, official/brand tier) is
  tracked separately from `rating` (Google guest review average) — these
  can and do diverge (see curation spec).
- **Airports & railway stations**: their own marker layer/toggle, both
  clickable like subway stations, both get curated default hotels.
- **Custom sightseeing pins**: user can drop their own labeled pin
  anywhere on the map.

- **Star-tier filter**: multi-select ★ chips (1–5) in the sidebar let
  users narrow hotels by official star class, independent of guest
  rating. Empty selection = show all (default, no-op until touched).
  Pinned hotels always bypass this filter, same as other filters.

## 4. Data curation strategy

Full logic lives in `hotel-curation-pipeline-spec.md` in the same repo.
Summary: Tier 1 (airports + major rail hubs) always curated first; brand
anchor (Hilton/Hyatt/IHG/etc.) weighted *above* raw rating for at least
one hotel per area, since brand recognition reduces booking anxiety for
Western travelers; ≥100-review volume floor; price-tier spread required;
capped at 3–5 hotels per area.

Two more rules (Audrey, 2026-10-18):
- **Red flags drop a hotel.** Before a hotel is picked, skim its recent
  reviews. Repeated complaints (3 or more) about a wrong map location,
  discrimination, mould or hygiene, or closure rule it out, whatever
  its rating.
- **Monthly refresh.** Every city's picks are re-checked once a month:
  current rating and review count, recent red flags, permanent
  closures. A hotel that falls below the floor, closes, or shows red
  flags is taken off the map (marked hidden, not deleted, so hotel
  numbers and shared pins stay stable), and the area's gap is recorded.

### Sightseeing selection

Sights have no separate spec file; these are the rules, gathered from the
changelog entries where each was decided.

1. **Source: the real TripAdvisor ranking.** `web_fetch` the city's
   actual TripAdvisor attractions page and work from its numbered list.
   Generic web search is not used, because it returns snippets *about*
   rankings and missed real top-10 entries in London (2026-07-13 cont'd, 4).
2. **Core list: roughly the ranked top 12–15.** Every entry should be
   traceable to the ranking (2026-07-13 cont'd, 5).
3. **A few deliberate local-flavor additions** beyond the ranked list
   (a food market, a free viewpoint, a park, a nightlife alley) for
   variety a pure top-N list misses. Prefer swapping in a real ranked
   entry over keeping a weak unranked one (2026-07-13 cont'd, 6).
4. **Exclusions, always noted in the changelog, never silent:**
   attractions far outside the city (e.g. Disneylands), entries that
   aren't attractions (shops, hotels), very new low-review entries, and
   judgment calls for a general-audience planner (e.g. Barcelona's
   adult-themed museum) (2026-07-13 cont'd, 6 and 16).
5. **Details from Google Places**: hours, rating, phone. Names and
   rankings come from TripAdvisor; descriptions are rewritten, never
   copied (2026-07-12 cont'd).
6. **Ticket links: official domains only**, never resellers
   (Klook/Viator/GetYourGuide/Tiqets). If no clean official site can be
   confirmed, leave the link empty rather than guess. Ticketed sights get
   the qualitative `bookAhead` flag, not a made-up day count
   (2026-07-13 cont'd, 35).
7. **Closures override the ranking**: a closed or renovating sight gets
   its note and hours updated to say so rather than sending people
   there (2026-07-13 cont'd, 35).
8. **Refresh**: hours and ratings monthly (curation spec §3).
9. **Verify by evaluating the data**, e.g.
   `CITIES.london.sights.map(s=>s.name)`, not just a parse check
   (2026-07-13 cont'd, 4).

### Adding a city (decided 2026-10-15)

Scaling from 5 to 25 cities. Audrey chose **Claude curates** hotels and
sights by hand, following the curation spec and the sightseeing rules
above ($0, about one thread run per city), over a paid Google Places
pipeline. The JSON format is the same either way, so a Places pipeline
can take over later.

Steps per city:
1. **Subway lines from OpenStreetMap.** Run the GitHub Action "Fetch
   subway lines from OpenStreetMap" (Actions tab → Run workflow, with the
   city id and a bounding box). It runs `scripts/osm-lines.js` on
   GitHub's servers and saves `osm/<city>-lines.json` plus a notes file
   on a side branch `osm/<city>`; it never touches `main`. The script
   keeps the longest variant of each line and lists branches, missing
   colors and empty lines in the notes to fix by hand. Lines come from
   OSM's `colour` tags (Paris test: 16 lines, all with official colors).
   The live app never calls OpenStreetMap. Re-run yearly or when a line
   opens (curation spec §3). OSM data is ODbL: keep the "© OpenStreetMap
   contributors" credit.
2. **Airports and intercity rail hubs**, then **hotels** per the curation
   spec (Tier 1 hubs first, then the top 3–5 interchanges/districts),
   **sights** per the rules above, **fares** and **first/last trains**.
3. **Validate**: `node scripts/validate-cities.js <city>` checks the
   format, coordinates, the §7 coverage audit (every airport and rail
   station has hotels) and that ticket links aren't resellers. Fix every
   error; fix or document every warning in the changelog.
4. **Ship in batches of 5 cities, one PR per batch**, previewed before
   merge (merging to `main` = live). Batches 2–4 shipped together in one
   PR (2026-10-16) to finish all 20 the same day.

Batches (proposed 2026-10-15, Audrey can swap any):
1. Paris, Seoul, Osaka, Hong Kong, Singapore
2. Taipei, Bangkok, Beijing, Madrid, Rome
3. Berlin, Amsterdam, Vienna, Prague, Istanbul
4. Lisbon, Milan, Washington DC, Chicago, Mexico City

Open before scaling: stored Google/TripAdvisor ratings break those
services' terms (§8 "Check terms"), and 20 more cities multiply that.
Recommendation: use ratings to *choose* hotels, but stop storing them in
the data. Not decided yet.

## 5. Known limitations (honest, not hidden)

- Subway line paths are simplified/hand-placed, not schedule-grade or
  pulled from a live transit feed (ODPT/GTFS would be the real fix).
- Hotel price tiers are static estimates, not live bookable rates.
- Live search only works inside Claude's artifact viewer, not a
  downloaded file — it depends on that environment's authenticated fetch
  to Claude's API. No API key is embedded, so it can't work standalone.
- Pins persist only in the same browser (`localStorage`), not across
  devices; clearing site data or a private window loses them. Inside the
  Claude artifact preview, `localStorage` may be unavailable, so pins can
  still reset there.
- No offline support (no service worker).
- Not every city/station has curated data yet — coverage grows city by
  city, area by area (see Changelog for what's covered so far).

## 6. Roadmap (not yet built)

- **Later: line-colour audit (Audrey, 2026-10-19).** Line colours come
  from each line's OpenStreetMap colour tag (grey #888888 if missing, then
  set by hand). A spot-check found them right at a glance but not always
  the exact official shade: London and Seoul exact; New York exact except
  A/C/E (#2850AD vs MTA #0039A6); Tokyo exact except Chiyoda (#00A650 vs
  #00BB85); Paris Line 1 #FFBE00 vs RATP #FFCD00; Beijing Line 1 #A12830
  vs #C23A30. To do: check every line in all cities against the
  operator's official colour and fix off shades, one city at a time.
- Real backend (Node/Python) + Google Places API, replacing "live search
  on click" with cheap, reliable, always-available curated data.
  **Cost estimate, corrected and scaled to 150 cities** (superseding the
  earlier $35–75/mo figure, which under-scoped both city count and field
  richness):
  - Assumptions: 10 curated areas/city, ~40 curated hotels/city, ~400
    Places API calls/city/month at full monthly refresh (area discovery
    + per-hotel detail lookups, including vetting candidates that don't
    make the cut). 150 × 400 = **60,000 calls/month**.
  - Rating/review/phone/hours together push each call into Google's
    **Enterprise tier (~$35–40/1,000 calls)**, not the free/basic tier —
    this was the error in the original estimate.
  - **At full monthly refresh, every city, every hotel: ~$2,100–2,400/mo.**
  - **Recommended mitigation — tiered refresh frequency, not flat
    monthly for everything:**
    - Top 10–20 highest-traffic cities: refresh monthly (ratings/hours
      genuinely shift; users are actually there to notice)
    - Long-tail cities: refresh quarterly instead — hotel ratings don't
      meaningfully move week to week, and quarterly for the little-used
      majority cuts total call volume 2–3x with minimal real accuracy
      loss
    - Cheap fields (address/coordinates) can refresh independently and
      more often than expensive fields (rating/reviews), since only the
      latter triggers Enterprise pricing
    - **Realistic tiered estimate: roughly $700–1,200/mo** instead of
      the full $2,100–2,400/mo flat-monthly figure, at the same 150-city
      scale.
  - Only city-provider-agnostic figures here — no hidden dependency; the
    provider (Google Places vs. an alternative) is a separate decision
    from the tiering strategy itself.
- **Live search cost — this is separate from the batch-refresh cost
  above, and adds to it, not replaces it.** Right now live search only
  works inside Claude's own artifact preview (auto-authenticated, no
  key needed, effectively free to the user). Once a real backend exists
  with its own Anthropic API key, **every live search call costs real
  money, billed directly to the site owner** — current rate (Anthropic's
  own docs): $10 per 1,000 searches + token cost, roughly 1–2 cents per
  lookup. Two triggers feed the *same* underlying cost, not separate
  systems:
  1. Clicking a station/airport/rail circle with no curated hotels
     (existing behavior, live since the first build)
  2. Searching a hotel name not in the curated list (built — see
     Changelog 2026-07-13 cont'd, 24)
  This scales with **actual user traffic**, not city count — unlike the
  batch-refresh cost above, which scales with how many cities/hotels
  exist regardless of whether anyone visits them. At modest early
  traffic (a few hundred fallback lookups/month across both triggers):
  a few dollars/month. At real scale (tens of thousands of monthly
  active users hitting uncurated spots regularly), this could become
  the larger of the two cost lines, not the smaller — worth watching
  via the event-logging item below once there's real traffic to measure.
  **Combined realistic monthly total at 150-city scale, tiered refresh +
  modest live-search traffic: roughly $750–1,300/mo.**
- **Minimal, privacy-respecting event logging — build this in from day one
  once the backend exists, not as an afterthought.** Rationale: right now
  the app is a static file with zero telemetry, so questions like "how
  often does a star filter return zero results" are genuinely
  unanswerable — we're flying blind on real usage. The moment a backend
  exists, add lightweight logging for exactly these edge cases (e.g.
  "star filter set to [1,2], zero results shown, area: X, city: Y") so
  future decisions (like whether the 1–2★ live-search-fallback button
  discussed on 2026-07-13 is worth building) can be traced back to actual
  user behavior instead of guessing.
  - **China caveat, don't default past this:** Shanghai is one of the
    five cities in the app, and most Western analytics tools (Google Analytics
    included) are blocked by the Great Firewall without a VPN — a naive
    default would silently lose data from exactly the market with the
    most curation investment. Prefer self-hosted, privacy-respecting
    tools (Plausible/Umami on our own domain) over a blocked third-party
    SDK, specifically because it stands a real chance of working for
    mainland China visitors too.
- Cross-device pin sync (would need the backend + a database, e.g.
  Supabase). Same-browser persistence is already built via
  `localStorage`.
- More cities: 20 more in 4 batches, Paris first (§4 "Adding a city").
- Offline support via a service worker (PWA install itself is built).

## 7. Repo / hosting

- Public GitHub repo: `daewoogao/HopNest`, branch `main` (made public
  2026-10-09; the top-level docs are readable on GitHub but never served).
- `site/` holds everything the website serves: `index.html`,
  `data/` (`cities.json` + one `<city>.json` per city), `_redirects` (Cloudflare/Netlify only; GitHub Pages ignores it),
  `manifest.json`, `icon-192.png`, `icon-512.png`, `apple-touch-icon.png`.
  **When deploying, publish only `site/`** — everything the browser
  downloads is readable by visitors, so internal docs must never be
  served.
- Top level (internal, never deployed): `README.md`,
  `hotel-curation-pipeline-spec.md`, `launch-cost-plan.md`, this design
  doc, and `.gitignore` (excludes `.DS_Store`).
- `scripts/` (never deployed): `osm-lines.js` (subway lines from
  OpenStreetMap), `validate-cities.js` (format + coverage audit),
  `format-json.js` (keeps one station/hotel/sight per line in the data
  files so diffs stay readable).
- `.github/workflows/osm-lines.yml`: manual-run Action that runs
  `osm-lines.js` and saves its output to an `osm/<city>` branch.
- **Live at https://daewoogao.github.io/HopNest/** on GitHub Pages
  (free), chosen 2026-10-09 in place of the earlier Cloudflare Pages
  plan. `.github/workflows/pages.yml` uploads only `site/` and deploys on
  every push to `main`. Pages source is set to "GitHub Actions". A custom
  domain can be added later in repo Settings → Pages.

## 8. Launch checklist

Everything that has to change between "works in Claude's preview" and
"public website anyone in the world can use." Check items off here as
they're done.

**Already done**
- [x] Pins and last-viewed city persist across reloads (Changelog cont'd, 40)
- [x] Installable as a home-screen app / PWA (Changelog cont'd, 43)
- [x] Website files isolated in `site/` so internal docs can't be deployed
  (Changelog 2026-09-29)

**Must fix before launch**
- [x] **Decide live search.** Chose (a) on 2026-10-07: disabled behind
  `LIVE_SEARCH_ENABLED`, error text no longer mentions the artifact
  viewer. Original note: It only works inside Claude's preview; on a
  real site it fails, and the error banner mentions "the artifact viewer,"
  which means nothing to a real user. Either:
  - (a) disable it for launch and show a plain "not covered yet"
    message — $0, simplest; or
  - (b) build a small backend that holds the Anthropic API key and
    proxies the call — ~1–2¢ per lookup (see `launch-cost-plan.md` §4).
    The key must never be put in `index.html`.
- [ ] **Switch map tiles off OpenStreetMap's public tile server.** Its
  usage policy isn't meant for production sites with real traffic and it
  can block us. Move to a tile provider with a free tier (MapTiler,
  Stadia Maps, Thunderforest — compare at decision time). Keep the
  OpenStreetMap attribution. **Not decided yet.** Recommendation
  (2026-10-07): OpenFreeMap, which is free, needs no account or key, and
  allows commercial use. It serves vector tiles, so it needs MapLibre GL
  plus the maplibre-gl-leaflet plugin. MapTiler and Stadia free tiers are
  non-commercial only, which conflicts with affiliate links.
- [x] **Hosting**: GitHub Pages (free), public repo, deploys `site/`
  on push to `main` via `.github/workflows/pages.yml` (2026-10-09).
  Replaced the Cloudflare Pages plan. Domain optional (~$10/yr).
- [x] **Rename `hopnest.html` → `index.html`** so the bare domain loads
  the app; `manifest.json` `start_url` is now `./` (2026-10-07).
- [ ] **Re-verify the curated data.** Everything was curated in July
  2026: re-check hotel price tiers, sight hours, fares, first/last train
  times, and drop anything that has closed.
- [ ] **Real-device testing**: iPhone Safari, Android Chrome, slow mobile
  data. Cover Add to Home Screen, share links, city picker, pins.

**Should do at launch**
- [ ] **Analytics**: Plausible or Umami (not Google Analytics — blocked in
  mainland China). See Roadmap §6.
- [ ] **Error tracking** (e.g. Sentry) so browser errors reach us instead
  of relying on user reports.
- [ ] **About / Privacy page**: what's stored (pins in the browser only),
  where the data comes from, and "verify details before booking."
- [ ] **Check terms for displaying ratings.** We show TripAdvisor/Google
  ratings; confirm what their terms allow on a public site.
- [ ] **More cities**: target 25 (decided 2026-10-15). Plan and batches
  in §4 "Adding a city".

**After launch (not blocking)**
- Backend + Google Places automated data refresh (§6)
- Trust circles / shared trips (Supabase)
- Cross-device pin sync
- Offline support (service worker)
- App Store / Play Store versions

---

## Changelog

### 2026-10-19 — Picks at empty airports and stations (outside China)
- 37 hubs in 28 cities had no picks. Filling them one city at a time with
  the usual TripAdvisor rules (4.0+ with 100+ reviews). Airports: on-grounds
  or terminal-connected first, else hotels with a FREE shuttle within ~3 km.
- Dublin Airport 0→2 (Crowne Plaza, Carlton; free shuttles). The two
  on-grounds hotels score under 4.0.
- LAX 0→5 (Century Blvd / El Segundo, all free 24-hour shuttles). LA Union
  Station: nothing within 800 m reaches 4.0, so no pick.
- Brussels Airport 0→1 (Crowne Plaza, free shuttle); the rest score under
  4.0, have too few reviews, or charge for the shuttle.
- Rio Central do Brasil 0→1 (Gamboa Rio Hotel, 490 m); nothing else
  within 800 m reaches 4.0 with 100+ reviews.
- Hanoi Noi Bai 0→1 (Viet Village Hotel, free airport transfer, 3 km).
- No pick passes yet: Rome Fiumicino and Ciampino, Vienna airport (the
  terminal hotels score 3.5–3.9). Asked Audrey about an airport exception.
- No hotel at all, or none that passes, within 800 m: Seoul Suseo,
  Singapore Woodlands checkpoint, Bangkok Krung Thep Aphiwat, Vancouver
  Pacific Central, Cairo Ramses, Buenos Aires Constitución, Atlanta
  Peachtree (Amtrak; nearest hotel 805 m), Charlotte Amtrak (industrial
  area, nearest hotel 1.8 km), Jakarta Halim station and airport, Detroit
  Amtrak (only hotel nearby rated 2.9), Cincinnati Union Terminal, both Riyadh
  stations and King Khalid airport, Norfolk Amtrak, Busan Gimhae airport,
  Edinburgh airport (on-grounds hotels score 3.0–3.9), Ben Gurion airport
  (no airport hotels), Honolulu airport (free-shuttle hotels score 3.5–3.7),
  Florence airport (good hotels 1.9–2.7 km away but no free shuttle; T2
  tram). The card's 15/20 min walk buttons cover
  these.

### 2026-10-19 — Line colours: audit noted for later
- Spot-checked line colours against official ones; most match, a few are
  an older or slightly different shade. Full audit added to §6 Roadmap.

### 2026-10-19 — Removed the "add a city" box
- Audrey asked to remove the "Don't see it? Type a city…" box and its Add
  button under the city list. It only added a placeholder for the current
  visit, never a real city. New cities are still added by us.

### 2026-10-19 — Shenzhen picks via Trip.com; station pins fixed
- Same Trip.com method. Shenzhen goes from 13 to 18 picks: North Station
  1→3, Shenzhen Station (Luohu) 1→4.
- Found while doing it: some train-station pins in China were stored in
  China's offset map coordinates (GCJ-02), ~400–700 m from the real spot.
  Fixed: Shenzhen North, Shenzhen Station, Futian, all three Guangzhou
  stations, and Beijing West. Also moved the Pullman Shenzhen North pin.
  Xi'an, Shanghai, Chengdu and the other Beijing stations checked fine.
- Rule for China data: every coordinate from a Chinese map source is
  converted with cur/gcj2wgs.py and checked against OpenStreetMap.

### 2026-10-19 — Guangzhou: station and airport picks via Trip.com
- Same Trip.com method. Guangzhou goes from 9 to 20 picks: South Station
  0→3, Guangzhou Station 0→3, East Station 2→4, Baiyun Airport 2→4
  (airport business area, free terminal shuttles), Shamian 2→3.
- Gap: Tianhe/Zhujiang New Town has only upscale picks.

### 2026-10-19 — Chengdu: station and airport picks via Trip.com
- Same Trip.com method. Chengdu goes from 10 to 24 picks: East Station
  0→3, South Station 0→3, Chengdu Station 0→1, Tianfu Airport 0→2 (on the
  airport grounds), Shuangliu Airport 1→3, Kuanzhai Alley 1→4.
- Gaps: Chengdu Station and Tianfu Airport are under 3 (other qualifying
  hotels had no trustworthy pin; one was ruled out for mould reviews).

### 2026-10-19 — Shanghai: station and airport picks via Trip.com
- Same Trip.com method as Xi'an and Beijing. Shanghai goes from 24 to 33
  picks: South Station 1→4, Shanghai Station 2→4, Pudong Airport 2→3,
  Hongqiao Airport 0→3 (all three inside Terminal 2, terminal-connected).
- Fixed the Holiday Inn Shanghai Pudong Airport pin: it was ~450 m off
  (an unconverted GCJ-02 coordinate). Moved, not re-added, so its ID holds.
- Gaps: no budget pick at either airport (the near-terminal budget hotels
  score under 4.5 or have no trustworthy pin).

### 2026-10-19 — Beijing: station and airport picks via Trip.com
- Same Trip.com method as Xi'an (floor 4.5/5 with 200+ reviews, foreign
  passports accepted, no red flags), applied to Beijing's hubs. Trip.com
  scores out of 10 are halved. Pins come from OpenStreetMap or from
  Skyscanner's map pin converted from GCJ-02; no trustworthy pin, no pick.
- Beijing goes from 16 to 30 picks: West Station 0→4, Beijing Station 1→4,
  Daxing Airport 1→5 (airport hotel cluster, free shuttles), Capital
  Airport 2→4. Every new pick links to its exact Trip.com page.
- Gap: Beijing South Station has only 1 (Golden Oasis, 600 m). The
  station's own HanTing/JI hotels qualify but have no trustworthy pin yet.
- Other China cities follow one at a time: Shanghai, Chengdu, Guangzhou,
  Shenzhen.

### 2026-10-19 — Hotel card can be dragged
- The hotel card that opens after clicking a station or sight can be moved
  by dragging its title bar (mouse or finger). It stays where it was
  dropped for later stations; double-clicking the title bar puts it back
  in the top-right corner. It is kept inside the map.

### 2026-10-19 — Xi'an: more picks via Trip.com
- Audrey noticed Xi'an North station had no hotels. Cause: OpenStreetMap
  and TripAdvisor both cover China thinly, so few hotels qualified.
- Trial for China: ratings from Trip.com (score out of 5, floor 4.5 with
  200+ reviews; only hotels that accept foreign passports). Pins still
  come from OpenStreetMap; no hotel without a trustworthy pin. The popup
  says "★ 4.8 / 5 on Trip.com" for these, and hotels with a known Trip.com
  page link there instead of Booking.com.
- Same day: every pick in a China city now books on Trip.com (its exact
  page when known, otherwise a Trip.com search for the hotel), so the
  booking site matches the rating site. Elsewhere it stays Booking.com.
- Xi'an goes from 5 to 12 picks: North Station 2 (Fairfield by Marriott,
  Atour; ~1.4-1.6 km south, beside Beiyuan station, one Line 2 stop away,
  since nothing nearer qualifies), airport 2, Railway Station 2, Bell Tower
  4, Giant Wild Goose Pagoda 2 (+ Westin).

### 2026-10-18 — booking link on our picks; two more curation rules
- Every hand-picked (sunflower) hotel's popup now has a "Check prices on
  Booking.com" button: a Booking.com search for the hotel's name and
  city, the same kind of link the map-data hotels already had. No price
  is shown, since we have no live rates. An affiliate ID can be added to
  this one link later.
- Audrey added two curation rules to §4: red-flag reviews rule a hotel
  out, and every city's picks are re-checked monthly.

### 2026-10-18 — batch 9: more US cities (94 total)
- Audrey asked for more US cities with rail or streetcars.
- Detroit: QLINE streetcar and People Mover loop (both free). Gaps:
  Amtrak station 0 hotels; Cultural Center 1; Midtown 2; most DTW hotels
  are shuttle hotels 3-4 km out.
- Buffalo: NFTA Metro Rail. Gaps: Exchange Street station 2; Downtown 2;
  airport hotels are shuttle hotels about 1 km out; Niagara Falls listed
  as a far sight (car or bus).
- Cincinnati: Connector streetcar (free). Gaps: Union Terminal 0 hotels;
  Over-the-Rhine 1; CVG hotels are shuttle hotels about 3 km out; The
  Banks has no budget pick.
- Milwaukee: The Hop M-Line and L-Line streetcars (free). Gaps: Third
  Ward 2; Yankee Hill has no brand pick; airport hotels are shuttle
  hotels 0.9-2 km out.
- Cleveland: RTA Red Line (airport) and Blue/Green light rail. Gaps:
  airport 1 shuttle hotel; Lakefront Station 2; University Circle 2;
  Playhouse Square is a theatre-district area about 1 km from rail;
  Waterfront stops only run on Browns game days.
- Norfolk: The Tide light rail. Gaps: Amtrak station 0 hotels; Freemason
  & Ghent 1; airport hotels 1.9-2.7 km out; Downtown has no budget pick;
  Virginia Beach listed as a far sight.
- Sacramento: SacRT Blue/Gold/Green light rail. Gaps: airport 0 picks
  (the nearest shuttle hotels are ~7 km out, too far to list); Midtown
  1; Valley Station has no budget pick; new Dos Rios station missing
  from OSM.
- Tucson: Sun Link streetcar (fare-free). Gaps: Amtrak station 2;
  University 2; airport hotels are shuttle hotels 1.2-2.4 km out; many
  top sights (Saguaro, Desert Museum, Mt. Lemmon) need a car.
- Kansas City: KC Streetcar (free, Riverfront to UMKC). Gaps: airport 0
  hotels (only on-site hotel rated 3.5); Country Club Plaza has no
  budget pick.
- San Jose: VTA Blue/Green/Orange light rail. Gaps: only 8 picks pass
  the 4.0 floor: Diridon 0, Levi's Stadium 1, Downtown 3 (no budget);
  airport hotels 0.8-1.2 km out.
- Austin: CapMetro Rail Red Line (no Sunday service); South Congress and
  UT/Capitol are off-rail areas. Gaps: airport 1 (Hyatt Place); Amtrak
  station has no budget pick; East Austin and South Congress have no
  brand pick.
- Tampa: TECO Line Streetcar (free). Gaps: Union Station 2; Water Street
  has no budget pick; Busch Gardens is ~12 km out with no rail link.

### 2026-10-18 — batch 8: more US cities overnight (82 total)
- Audrey asked for as many more US cities as possible overnight. Added so
  far: Portland (MAX Blue/Red/Green/Yellow/Orange, Streetcar NS/A/B).
- Gaps: Portland airport hotels are shuttle or Cascade Station hotels
  1.6-2.8 km out; Union Station 4 picks; Nob Hill 3; MAX Green Line's
  downtown segment and Blue Line's Gateway-Ruby Junction segment are
  missing from OSM.
- Honolulu: Skyline (East Kapolei to Middle Street; airport served, not
  yet Downtown or Waikiki), with Waikiki as an off-rail area. Gaps:
  airport 0 hotels (none rated 4.0+); Downtown 1; Ala Moana 4.
- Denver: RTD A Line (airport), B/G/N commuter lines and D/E/H/L/R/W
  light rail; Amtrak lines left off. Gaps: airport 1 hotel (Westin);
  RiNo 2; Downtown no budget pick.
- Dallas: DART Red/Blue/Green/Orange light rail, M-Line trolley, Dallas
  Streetcar; the Silver Line commuter rail (opened 2025) is not drawn
  yet. Gaps: DFW 2 hotels and Love Field 2 shuttle hotels; Union Station
  3; Uptown picks all luxury; no budget picks at Union Station or the
  Arts District.
- Baltimore: Metro SubwayLink and Light RailLink (BWI and Glen Burnie
  branches). Gaps: Penn Station 1 hotel (no light-rail stop drawn
  there); BWI hotels are shuttle hotels 2.3-2.8 km out; Inner Harbor 3.
- Minneapolis–Saint Paul: METRO Blue and Green light rail (Twin Cities).
  Gaps: airport hotels are 3 shuttle hotels about 2-3 km out; Saint Paul
  Union Depot 1; University 2.
- Salt Lake City: TRAX Blue/Red/Green and S-Line streetcar. Gaps: Salt
  Lake Central 1 hotel; airport hotels are 3 shuttle hotels 2.2-2.9 km
  out; The Gateway has no budget pick.
- Houston: METRORail Red/Green/Purple (no airport rail). Gaps: Amtrak
  station 0 hotels; IAH 1 (terminal Marriott); Museum District 1; Space
  Center Houston is 40 km out, car needed.
- Phoenix: Valley Metro A/B light rail, Tempe Streetcar, PHX Sky Train.
  Gaps: airport hotels are around the 44th St Sky Train interchange
  (none on airport grounds); Midtown 3.
- St. Louis: MetroLink Red (airport) and Blue. Gaps: Gateway Station 2;
  Central West End 1; Delmar Loop 1; Downtown has no budget pick.
- Pittsburgh: The T Red/Blue/Silver light rail (airport by 28X bus, not
  drawn). Gaps: airport hotels are 3 shuttle hotels 2-3 km out; North
  Shore has no tier-4 pick; only 2 neighbourhood areas on the T.
- Charlotte: LYNX Blue light rail and CityLYNX Gold streetcar (airport
  by bus, not drawn). Gaps: Amtrak station 0 hotels; airport hotels are
  4 shuttle hotels 2.7-3.2 km out; University City 2.

### 2026-10-18 — station clicks always pull in nearby hotels
- Audrey: in Seattle, a station with any curated pick in walking distance
  showed no map-data hotels. Now every station click (like sight clicks)
  lists all hotels in walking distance: our picks first (sunflower, rated),
  then OpenStreetMap hotels, regardless of whether picks are nearby.

### 2026-10-18 — batch 7: five more US cities (70 total)
- Audrey asked for more US cities. Added the most-visited US cities with
  real city rail that weren't on the site: Seattle (Link 1/2, Monorail,
  two streetcars), Philadelphia (SEPTA L, B, T1-T5 trolleys, PATCO;
  suburban D/M lines and NJ River Line left off), San Diego (Trolley
  Blue/Orange/Green/Copper), New Orleans (St. Charles, Canal x2,
  Riverfront streetcars; Rampart line missing in OSM), Atlanta (MARTA
  Red/Gold/Blue/Green, Atlanta Streetcar). Each has curated hotels and
  sights plus the OpenStreetMap hotel layer. Orlando skipped (no city rail).
- Gaps: Atlanta Peachtree Station 0 hotels; Seattle airport 2; Philadelphia
  30th Street 2 (no brand/budget) and PHL 2 shuttle hotels ~2.5 km out;
  San Diego airport hotels 1.7-2.2 km out (free shuttles) and Mission
  Valley 3; New Orleans airport 1 shuttle hotel, Union Passenger Terminal 2.
  Philadelphia and New Orleans show every street stop on trolley lines.

### 2026-10-18 — second station click hides its hotels
- Audrey: clicking the same station again should hide the hotels it
  showed, like a toggle. Turning a station's walk circle off now also
  removes its map-data hotels, the hotel card and any dashed lines (only
  when that station was the last lookup). Clicking again brings them back.
- Same for sights (Audrey): a second click on a sight closes its popup and
  hides its hotels, card and dashed walk circle.
- Station dots were hard to hit (Audrey): each clickable station now has an
  invisible 16px ring around its dot that takes the same click. Dots
  went from 5px to 6px radius (Audrey). The ring stays invisible when
  lines are toggled.
- Clicking a station no longer opens its popup (Audrey); it only shows the
  walk circle and the hotel card. Airports and rail stations keep theirs.
  Clicking empty map (which already turned station circles off) now also
  hides the station's hotels and card.

### 2026-10-18 — kawaii hotel icon
- Audrey asked for a Japanese cartoon-style hotel logo that reads
  instantly as "hotel". Six options drawn (A smiling hotel, B sleepy bed,
  C little inn, D desk bell, E room key, F ryokan). Map-data hotels now
  show B3, the sleepy bed: a kitty-eared sleeper tucked under a blanket
  with "zz", head redrawn per Audrey (pink
  blanket = hotel, mint = hostel), anchored at its base. Replaces the bed
  badge; the card legend shows the same icon.
- Curated picks: Audrey asked for an oil-paint style; nine options drawn
  (Monet M1-M3, Van Gogh V1-V3, Sisley S1-S3). Chosen: V3, a Van Gogh
  sunflower with an "H" on swirling blue, in a gold ring. Replaces the
  green diamond; 28px normally, 34px inside a walk circle, pin badge kept.
  Served as one data-URI image so many markers stay light.
- Sights: Audrey asked for a more fun Van Gogh-style icon; nine pin options
  drawn (Van Gogh P1-P3, Sisley Q1-Q3, Renoir R1-R3). Chosen: P2, a map pin
  with a painted yellow camera on Starry Night swirls and a gold rim
  (warm red version for traveller-added sights). Replaces the plain
  blue/red pins.

### 2026-10-17 — hotel card out of the way; hotels near sights
- Audrey: the hotel list covered the map after a station click. The card
  now docks top-right on desktop (bottom on phones, max ~38% height),
  shows 3 rows with "Show all", and has a fold button (–) that shrinks it
  to its title. The map frames the hotels beside the card, not under it.
- Audrey: clicking a sight should show hotels around it too. Opening a
  sight now draws a dashed walk circle around it and lists hotels within
  the walk time: our picks first (★, rated), then OpenStreetMap hotels
  (unrated). Free, same saved data.
- Changing the walk time (slider or preset) re-runs the hotel lookup for
  the last clicked station or sight, so a station with nothing at 10 min
  can find hotels at 15 min; the dashed nearest-pick lines are removed.
- No hotels at all (picks or map data) within the walk time: no more
  dashed lines to far-away picks (Audrey). The card says "No hotels within
  N min walk" and offers longer-walk buttons (15/20 min, up to the slider
  max) that re-run the lookup, plus the Booking.com search link.
- Map-data hotels show as a small rounded "bed" badge (lavender for
  hotels, peach for hostels) instead of grey dots, per Audrey.

### 2026-10-17 — every station shows hotels in walking distance (free)
- Audrey expected a station click to find real hotels within walking
  distance, not the far-away nearest picks. Live search stays off (no
  backend to hide a paid API key). Audrey chose "saved map data": every
  OpenStreetMap hotel/hostel across each city's whole rail area is saved
  in site/data/osm/<city>.json ([lat, lng, name, stars or 0, hostel 0/1];
  65 files, ~1.8 MB total, loaded only on first station click). Hotels we
  already picked are left out.
- Station click with no picks in walking distance: grey dots for every
  saved hotel in the walk circle, a card listing the nearest 5 with walk
  times ("not yet rated by us"), each popup links to Booking.com for
  prices and reviews; the map frames them clear of the card. Dots stay
  until the city changes. If even OSM has none, the old card with the 3
  nearest picks shows.
- Rebuild: curation/queries <city>-osmall.overpassql (station extent +
  ~1.3 km), then build_osm step (§4).

### 2026-10-17 — revealed and suggested hotels stay on the map
- Audrey: hotels that only appear when you click a station should stay
  on the map; the 3 nearest picks in the "no hotels nearby" card should
  show on the map too. Free: stored data only, no live lookup.
- Click-to-reveal hotels now stay on the map and in the list after their
  station circle closes (until reload).
- Nearest-hotels card: the map flies to fit the station plus the 3 picks,
  kept clear of the card; each pick gets a name tag and a dashed blue
  line from the station. Tags stay for every station clicked until you
  switch city (lines only for the latest). Picks follow the star filter.

### 2026-10-17 — batch 6: 20 more cities (65 total)
- Audrey: next 20, picked by visitor numbers, not 5 per continent. Taken
  from the top of the international-arrivals rankings, skipping places
  with no city rail (Antalya, Cancún, Phuket, Pattaya, Venice, Bali,
  Mecca). New city-list groups: Africa (Cairo) and Oceania (Sydney,
  Melbourne).
- Tram/monorail cities (Dublin Luas, Edinburgh, Florence, Melbourne, Las
  Vegas monorail, Jerusalem light rail) draw those as their lines. Kyoto
  adds JR Nara/Sagano, Hankyu, Kintetsu, Randen and Eizan Kurama to the
  two subway lines; Sydney draws Sydney Trains T1–T9, Metro and light
  rail (intercity/tour trains left off); Doha draws metro only.
- Same §4 process and hotel floor (TripAdvisor ≥4.0 and ≥100 reviews,
  within 800 m); never lowered to fill a gap. Validator: 0 errors.
  Hotel/sight counts and gaps:
  - Kyoto: 23 hotels/18 sights. Itami 1 hotel, KIX 2 (no brand); Gion no brand in 800 m. Keihan Main Line missing from lines (no usable OSM relation).
  - Macau: 13 hotels/17 sights. Airport 0 hotels (none meet 4.0+100 reviews); Taipa Village 3, no budget.
  - Chengdu: 10 hotels/16 sights. All 3 rail stations + Tianfu airport 0 hotels (nothing meeting floor in 800 m); Shuangliu 1.
  - Ho Chi Minh City: 17 hotels/18 sights. Railway station 1 hotel; airport 2.
  - Vancouver: 18/17. Pacific Central Station 0 hotels.
  - Rio de Janeiro: 21/18. Central do Brasil and Galeão 0 hotels; Santos Dumont 2.
  - Sydney: 27/18. All areas filled.
  - Melbourne: 23/18. Airport 1 hotel; St Kilda 3. Fares note Victoria's half-price fares to 1 Jan 2027.
  - Doha: 16/16. Airport 1 hotel; metro lines only (Red, Gold, Green).
  - Jerusalem: 18/18. Ben Gurion 0 hotels (45 km away); Navon station 3.
  - Cairo: 12/17. Ramses Station 0 hotels; airport 2; Giza 2.
  - Dublin: 23/17. Airport 0 hotels (on-site ones under 4.0).
  - Edinburgh: 22/18. Airport 0 hotels (on-site ones under 4.0).
  - Florence: 19/17. Peretola airport 0 hotels.
  - Miami: 20/15. Airport 0; MiamiCentral 1.
  - Las Vegas: 18/15. Airport 0; Downtown/Fremont has no hotel meeting the floor, so no area.
  - Hanoi: 19/18. Noi Bai airport 0 hotels.
  - Mumbai: 22/18. CSMT 1, Mumbai Central 2. Metro Lines 2B, 4, 9 left off (opening unconfirmed); monorail suspended.
  - Jakarta: 14/14 (most ranked attractions are malls). Gambir 2, Pasar Senen 1, Kota Tua 1, Halim station/airport 0, Soekarno–Hatta 2.
  - Riyadh: 8/14. Both rail stations and the airport 0 hotels; Al Faisaliah 2.

### 2026-10-17 — softer, seamless transfer marks
- Audrey found the transfer mark's black outline too strong and the
  inner lines (where each circle met the bar) ugly; asked for it to look
  exactly like LA's Expo/Crenshaw mark. Now every outline piece is drawn
  first and the white pieces on top, so only the outer edge has a line;
  outline is 1.6 px #3b4652 instead of 3 px near-black. Then, per Audrey,
  rounder: circles radius 8 px, joined by a narrow 5 px bar. Co-located
  platforms still show a single circle (Audrey confirmed that's fine).

### 2026-10-16 — hide/show the side panel
- Audrey asked how to close the left panel; there was no way. Now a ◀
  button in the panel's top-right corner hides it, and a "☰ Show panel"
  pill at the top-left of the map brings it back. On desktop the choice
  is remembered (`hopnest_panel_hidden_v1`).
- Also fixes phones: under 760 px the panel was off-screen with no way to
  open it. It now starts closed and slides over the map from the same
  button.

### 2026-10-16 — transfer stations marked on the map
- Audrey asked: at Lisbon's São Sebastião (Blue and Red lines), can you
  change inside the station or do you walk? Now every city shows it: a
  white ring = change inside the station; a dashed line = separate
  stations, walk; the popup lists the lines or gives the walk distance.
- Computed from the line data (`computeTransfers()` in `site/index.html`),
  so new cities get it for free. Lines in the same colour count as one
  line (branches, shared trunks like New York's A/C/E). Station-name
  spelling variants across lines are matched ("Reuilly - Diderot" /
  "Reuilly — Diderot", "Inderlok (Red Line)" / "Inderlok").
- Limits: it's a heuristic. A few "inside" changes are long corridors
  (Paris Montparnasse), and a few walk pairs are joined underground
  (Buenos Aires Perú–Catedral–Bolívar); the walk popup says to follow
  the signs. 45 cities: ~960 interchange rings, ~45 walk links.
- Same day, restyled after Audrey shared an LA Metro map she finds clear:
  one white circle per line at the station, joined by a white bar with a
  dark outline (instead of one ring), and the station name shown once.

### 2026-10-16 — batch 5: 20 more cities (45 total)
- Audrey asked for the next 20 in the same PR as the continent toggle.
  Claude picked them (Audrey can swap any): Shenzhen, Guangzhou, Xi'an,
  Busan, Kuala Lumpur, Dubai, Delhi, Munich, Budapest, Copenhagen,
  Stockholm, Athens, Brussels, San Francisco, Los Angeles, Boston,
  Toronto, Montreal, São Paulo, Buenos Aires.
- Same §4 process as batches 1–4, run cheaper: one GitHub run for all the
  OpenStreetMap downloads, and curation helpers on a smaller model. Some
  hotels that qualify on TripAdvisor were dropped because no trustworthy
  map pin exists (OSM gaps), so Xi'an, Busan, Guangzhou and Shenzhen are
  thin. Hours, fares and some sight pins are approximate ("~").
- Airport-lines not on the metro map (KLIA Ekspres, Munich/Arlanda S-Bahn
  and express trains, UP Express, Ezeiza buses) are explained in the
  airport popups instead.
- Validator: 0 errors. Hotel gaps per city:
  - Xi'an (thin: 5 hotels): Railway Station 1, Bell Tower 3, Giant Wild Goose Pagoda 1; North Station and Xianyang Airport 0 (nothing ≥4.0/100 within reach; three qualifying hotels have no map pin). Terracotta Army and Huaqing Palace kept with "far" notes.
  - Busan (thin: 8): Busan Station 1, Seomyeon 4, Nampo 2, Gwangalli 1, Gimhae Airport 0. Several qualifying hotels (Asti, Stanford Inn, Noah) have no OSM pin.
  - Kuala Lumpur: KL Sentral and KLCC have no budget option ≥4.0; KLIA hotels are the terminal-complex ones (Sama-Sama, Tune). KLIA Ekspres not drawn.
  - Dubai: no intercity rail; airport 3 (no budget with a pin); no Dubai Marina area (no trustworthy hotel pins); Business Bay no budget.
  - Delhi: New Delhi Station 3, no brand anchor; IGI Airport 0 on grounds (Aerocity hotels listed as their own area, one Airport Express stop); Karol Bagh 1, Khan Market 2 (luxury only). RapidX, Aqua Line (Noida) left off.
  - Athens: Airport 1 (Sofitel); Acropoli no brand anchor; station names translated from Greek.
  - Munich: Airport 2 (Hilton, Novotel); Schwabing 2, no brand anchor; S-Bahn to the airport not drawn.
  - Budapest: Airport 2 (TRIBE, ibis Styles, ~900 m); Keleti no brand anchor.
  - Copenhagen: Airport 1 (Clarion); Christianshavn 2; Nyhavn no brand anchor.
  - Stockholm: Östermalm no budget; Södermalm 3. Line colours set by hand (OSM had none). Arlanda Express not drawn.
  - Brussels: Airport 0 (Sheraton 3.8; Park Inn ~3 km); Nord and EU Quarter no budget.
  - Montreal: Trudeau Airport 1 (Marriott in-terminal); Central Station no budget; Latin Quarter no upper tier.
  - San Francisco: SFO 1 (Grand Hyatt); Caltrain station 3, no budget; Civic Center no brand anchor.
  - Los Angeles (12): Downtown 5, Hollywood 5, Koreatown 2; LAX 0 (Hyatt Regency LAX is 1.3 km, off grounds) and Union Station counted under Downtown.
  - Boston: Logan 1 (Hyatt Regency Harbor, water shuttle); South Station no budget; Harvard Square 3, no budget.
  - Toronto: Pearson 4 (Sheraton Gateway on grounds, 3 shuttle hotels); Yorkville and Entertainment District no budget. UP Express not drawn. Lines 5 and 6 included as OSM has them; re-check they're open.
  - São Paulo: Luz 1, Congonhas 0, Guarulhos 3 (shuttle cluster 1.3–2.4 km); Jardins and Faria Lima 2. Line 6 left off (opening unconfirmed).
  - Buenos Aires: Constitución 0, Ezeiza 0, Aeroparque 0; Retiro, Recoleta, San Telmo no brand anchor (Park Tower has no pin).
  - Shenzhen (13): North Station 1 (Pullman), Futian 4, Shenzhen Station 1 (Shangri-La), Bao'an Airport 3 (Hyatt trio, indoor walk), Huaqiang North 4 (no brand anchor); Shekou and Houhai have no pinned hotels. Hong Kong MTR lines caught in the map box removed.
  - Guangzhou (9): South Station 0, Guangzhou Station 0 (China Hotel, Dongfang ~900 m), East Station 2, Baiyun Airport 2, Zhujiang New Town 3 (luxury only), Shamian 2, Beijing Road 0. Foshan Metro lines left off.

### 2026-10-16 — continent groups open and close
- Audrey asked for an expand/collapse on each continent in the city list,
  since each will hold many cities. Each heading (Asia, Europe, Americas,
  plus Other/Requested) is now a button with ▾ and a city count.
- First visit: only the current city's continent is open. After that the
  open/closed set is saved in the browser (`hopnest_open_regions_v1`).
  The Recent group always shows; search results ignore collapsing.

### 2026-10-16 — batches 2–4: 15 more cities (25 total)
- Taipei, Bangkok, Beijing, Madrid, Rome, Berlin, Amsterdam, Vienna,
  Prague, Istanbul, Lisbon, Milan, Washington DC, Chicago and Mexico City,
  made by the §4 "Adding a city" steps, same as batch 1: lines from
  OpenStreetMap (run on GitHub's servers), hotels and sights curated by
  Claude, TripAdvisor ratings and `ratingCount` (storing them is still
  Audrey's open call). Shipped as one PR instead of three.
- Sight hours, fares and closures come from Claude's knowledge plus a
  limited number of web checks; some are approximate ("~") and the first
  monthly refresh should re-check them.
- **Airport radius exception:** where no hotel on airport grounds reaches
  4.0/100, free-shuttle hotels farther out are listed and say so: DCA,
  IAD, O'Hare (Rosemont), Midway, Madrid Barajas.
- **Line fixes:** non-Latin station names translated (Beijing, Taipei,
  Bangkok); local line names kept as the second label (Línea, Linea,
  Linka, Metro Hattı); airport lines carry first/last train notes. Bangkok
  BTS Silom Line rebuilt from OSM station nodes (its route relation lists
  6 of 14 stations); Airport Rail Link added. Beijing's Batong and Daxing
  stubs folded into lines 1 and 4. Taipei's Airport MRT drawn once
  (express stops are a subset). Istanbul adds Marmaray and the T1 and T5 trams
  (Sultanahmet has no metro). Not drawn: suburban/airport trains that
  aren't metro (Vienna CAT/S-Bahn, Rome Leonardo Express, Milan Malpensa
  Express, Metra, MARC); airport popups explain them. Rome Metro C's
  unopened stretch skipped.
- Validator: 0 errors. Every warning is a hotel gap listed below.
- **Hotel gaps and sights excluded, per city:**
  - Berlin: BER has 2 (Steigenberger, IntercityHotel at T1; no brand anchor or budget; Holiday Inn/B&B 3.8, Moxy 3.5). Friedrichshain chosen over Kreuzberg (no brand, thin inventory). Sights: Pergamonmuseum and German Historical Museum excluded (closed/renovating), Reichstag dome closed 19–30 Oct 2026 noted; KaDeWe (shop), Neues Museum (part of Museum Island), Alexanderplatz (3.9, hotel area), others cap.
  - Amsterdam: Schiphol 3 (Hilton, Sheraton, citizenM; on grounds; no budget—YOTELAIR 3.9); Zuidas 3, no budget or luxury (Element 851 m). Sights: Red Light District (adult/district), Centraal Station (rail hub), Molen van Sloten (outskirts), adult museums excluded.
  - Washington DC: Union Station has no budget at 4.0+ (YOTEL 3.6, hostel 3.8); no hostel anywhere reaches 4.0/100. Reagan National: no hotel on airport grounds — 5 Crystal City/National Landing hotels 1.2–1.4 km out with free shuttles and one Metro stop. Dulles: on-grounds Marriott 3.7 — 5 shuttle hotels 1.8–4 km out (geocoded addresses). Sights: White House (tours by congressional request only), Georgetown (neighbourhood), Smithsonian umbrella listing, others cap. Air and Space partly renovating.
  - Lisbon: Airport has 2 (Meliá Aeroporto, Star Inn; no brand anchor; ibis Styles 66 reviews, Holiday Inn Express 3.5, Radisson Blu 3.7); Santa Apolónia no brand anchor; Cais do Sodré 4, no luxury. Sights: Chiado (hotel area), Centro Colombo (mall), Parque das Nações (district), Arco do Triunfo (part of Praça do Comércio). Torre de Belém reopened 27 May 2026 (timed slots); Gulbenkian reopened 18 Jul 2026. Tram 28 kept at 3.9.
  - Taipei: Taoyuan Airport has 1 (Hyatt Regency, on airport grounds); Songshan Airport 0 (Fullerton North 897 m, Mandarin Oriental 966 m); Ximending no brand anchor; Xinyi no budget; East District 4. Hotel Resonance 806 m excluded. Sights: Taipei 101 Observatory, Beitou Thermal Valley, Maokong merged into parent entries.
  - Prague: Airport has 1 (Courtyard by Marriott; Holiday Inn Airport 3.8). Sights: Lesser Town (district), Museum of Senses and Illusion Art Museum (gimmicks), Sex Machines Museum (adult), Klementinum (3.7), Palladium (mall), others cap. Petřín funicular reopened 22 Sep 2026.
  - Bangkok: Krung Thep Aphiwat 0 (nearest 878 m); Hua Lamphong 4, no brand anchor (kept as a hub: Eastern Line and ordinary trains); Suvarnabhumi 1 (Hyatt Regency, tunnel; Boxtel 3.9); Don Mueang 1 (Amari, footbridge; no brand/budget); Riverside 4, no budget; Chinatown no brand anchor. Khao San not an area (no metro). Sights: Siam Paragon, MBK, Terminal 21, ICONSIAM, CentralWorld, Platinum, Pratunam, Asiatique (shopping), Emerald Buddha (in Grand Palace), Sukhumvit (district), Playmondo (kids' play), Safari World and Train Night Market (far), Soi Cowboy (3.6), Chao Phraya River (not one place). Khaosan Road kept at 3.8. BTS Silom Line rebuilt from station nodes (OSM route incomplete).
  - Vienna: Airport 0 (NH Airport 3.9, Moxy 3.8 on grounds; no floor exception used); Leopoldstadt no luxury; Landstraße 4. S7 ends at St. Marx until ~Oct 2027 (REX7 to Hauptbahnhof). Sights: Historic Center (district), Stephansplatz/Rathausplatz (duplicates), Schönbrunn Gardens and Sisi Museum (merged), Musikverein (concert venue), MuseumsQuartier (overlaps Leopold), Graben (shopping), others cap. Sisi Museum closed until 19 Nov 2026; KHM timed tickets.
  - Chicago: O'Hare's only on-grounds hotel (Hilton O'Hare) is 3.6, so 4 Rosemont free-shuttle hotels 2.8–3.7 km out (one Blue Line stop) are listed instead; Midway 2 (Marriott, Holiday Inn Express, ~1.5 km on Cicero Ave, free shuttle; DoubleTree Midway not in OSM); West Loop 3, no brand anchor or budget (Hotel Chicago West Loop 3.9). Sights: Magnificent Mile (shopping/hotel area), Cloud Gate (in Millennium Park), Medieval Torture Museum (judgment), Route 66 sign, United Center (arena), Chicago River (dup of Riverwalk), Union Station (hub), Skyline (not a place), Macy's (shop), others cap.
  - Milan: Malpensa 1 (Moxy at T2; Sheraton 3.9, others <4.0); Linate 1 (Moxy ~660 m; NH 3.8, Novotel 3.7); Porta Garibaldi no budget (3.9s); Brera 3, no brand anchor or budget; Navigli no brand anchor or budget (Mercure 3.9, nhow 816 m). Airport pins are terminal estimates (±300 m). Sights: Brera District (hotel area), Arco della Pace (in Parco Sempione), Milano Centrale (station), Museum of Senses (gimmick), Duomo Museum (dup), Mercato Centrale (closed by health authority Mar 2026). Piazza del Duomo, Terrazze and Santa Maria delle Grazie merged.
  - Istanbul: Söğütlüçeşme 1 (Holiday Inn Kadıköy); Istanbul Airport 1 (YOTEL landside; Hilton Airport opened Aug 2026, too few reviews/no pin); Sabiha Gökçen 1 (Kepler Club, airside, international departures only; ISG Airport Hotel had no pin). Halkalı not included. Sights: Sultanahmet District (hotel area), Bosphorus (water), Historic Areas (umbrella), Vialand (theme park), İstinye Park and Cevahir (malls), Sultanahmet Square (dup), Çamlıca Mosque (low reviews), Taksim Square (3.7), Emirgan Park and Rumeli Fortress (cap). Spice Bazaar not in TA top 60.
  - Rome: Fiumicino 0 (Hilton Rome Airport 3.5, Hilton Garden Inn 3.8); Ciampino 0 (Casa Lollobrigida, 4.7, not in OSM; nothing else ≥4.0 within 2.5 km); Tiburtina 2, no brand anchor or upper (BW Blu 980 m, 3.7); Spanish Steps no budget; Prati no luxury. Trastevere not an area (no metro). Sights: St. Peter's added (TripAdvisor files it under Vatican City); Centro Storico (district) and an unclear "Welcome To Rome" entry skipped; Trevi €2 basin ticket since Feb 2026.
  - Madrid: Chamartín 2 (Barceló Imagine, Eurostars Madrid Tower; no brand or budget); Barajas: nothing on grounds qualifies, so Hilton Madrid Airport (2.1 km) and Marriott Auditorium (2.4 km), both with free airport shuttles; Salamanca no budget. Malasaña's ibis Styles passes on the new-brand rule (31 reviews). Sights: Museo Sorolla house closed for works (extension open); Barrio de Salamanca and La Latina (districts), Palacio de Cristal (in Retiro), Palacio de Cibeles (in Plaza de Cibeles), Primark (shop), Atocha (hub), Mementorium (show), others cap.
  - Mexico City: Airport 2 (Courtyard, NH Collection T2; no budget; Hilton 3.8, Camino Real 3.6); Polanco 4, all luxury (Habita 3.5; Pug Seal, Royal Colonial not in OSM); Condesa 2 (Villa Condesa, María Condesa; Andaz and Mondrian missing from OSM; anchored on Parque México, no central metro). No rail hub (El Insurgente is a Toluca commuter link); Felipe Ángeles airport left out. Sights: Ballet Folklórico (in Bellas Artes), Polanco/Historic Center/La Condesa (hotel areas), Chapultepec Forest (overlaps castle and museum), Bazaar Sábado (shopping), Gran Hotel (hotel), others cap. Xochimilco not in the ranking.
  - Beijing (thinnest city: OpenStreetMap lacks many Beijing hotels): Beijing South 0 and Beijing West 0 (nothing in 800 m reaches 4.0/100; Magnolia not mapped); Beijing Railway Station 1 (Pudi); Capital Airport 2 (Cordis, Hilton; no budget); Daxing Airport 1 (Mumian, covered walkway); Nanluoguxiang 3, no brand; Sanlitun 4. Qianmen dropped as an area (Mandarin Oriental Qianmen, The Emperor, 365 Inn unmapped). Chaoyang station left out. Sights: Wangfujing Street, Hongqiao Market, Qianmen Street, Taikoo Li (shopping), Gubei Water Town (120 km), Happy Valley and Universal Beijing (theme parks), Juyong Pass/Simatai/Huanghuacheng (other Great Wall sections), Tian'anmen gate and Long Corridor (duplicates), Water Cube and Bird's Nest (merged into Olympic Park). Mutianyu and Badaling kept with transport notes.

### 2026-10-16 — smarter city search
- Audrey asked for a smart way to find a city as the list grows to 25.
  Decided (Claude's default, open to change): search matches name,
  country, aliases and airport codes, ranked, with one-typo tolerance and
  Enter-to-open; empty search shows Recent (last 4 opened, stored in
  `hopnest_recent_cities_v1`) then region groups. `cities.json` entries
  gain `region` and `aliases`; every new city must set both.

### 2026-10-15 — batch 1 cities: Paris, Seoul, Osaka, Hong Kong, Singapore
- Five new city files in `site/data/`, made by the §4 "Adding a city"
  steps. Subway lines from OpenStreetMap (run on GitHub's servers, since
  Overpass is blocked from Claude's machines), cleaned by hand. Hotels and
  sights curated by Claude per the curation spec and §4 rules.
- **Rating source for new cities is TripAdvisor** (bubble rating, plus a
  new `ratingCount` field with the review count used for the ≥100 floor).
  Google Places is unreachable from Claude's machines. Hotel coordinates
  come from OpenStreetMap where the hotel is mapped. The open question in
  §4 about storing ratings still stands; Claude is keeping them for now
  (Audrey's call pending).
- Hotel stars for Japan, Hong Kong and Singapore are class estimates (no
  official star scheme). Sight hours are from Claude's knowledge, not a
  live lookup; first monthly refresh should re-check them.
- Validator: 0 errors. Warnings documented here: Seoul's Suseo (SRT) and
  Singapore's Woodlands Train Checkpoint have **no hotel within 800 m**
  (nearest qualifying ones are 1.3 km+ away; radius not stretched).
- **Line fixes:** Paris line 15 skipped (not open); line 10's Auteuil
  loop westbound stations not drawn (OSM pairs them within 400 m of the
  eastbound ones). Seoul Line 1's Korail branch stops at Pyeongtaek
  (it runs 80+ km out); Korean-only station names translated from OSM's
  English tags; AREX added from a separate pull. Singapore's Jurong Region
  Line left off (in OSM, opens 2027+); Circle Line Stage 6 (opened
  12 Jul 2026) included. Osaka's airports aren't on the metro; their
  popups explain the train links.
- **Hotel gaps (left open, not filled with sub-floor options):**
  - Paris: CDG has only citizenM (others under 4.0); Orly only Novotel
    Coeur d'Orly; Gare de l'Est has no brand anchor at 4.0+ (NH 3.7);
    Saint-Germain and Le Marais have no brand anchor; Opéra has no budget
    option.
  - Seoul: Gimpo has 1 (Lotte City Hotel; no global brand, no budget);
    Gangnam has 2 (no brand anchor or budget; Novotel Gangnam is 812 m
    out). The three Yongsan Accor hotels share one Dragon City pin.
    Millennium Hilton (closed 2022) excluded.
  - Osaka: Kansai Airport has 2 (Hotel Nikko, First Cabin; no brand
    anchor; Rinku Town across the bridge excluded); Itami has 1 (Osaka
    Airterminal Hotel); Shin-Osaka has no luxury option.
  - Hong Kong: Airport has 3, no budget (Tung Chung town, ~3 km, excluded);
    West Kowloon and Hung Hom have no budget option at 4.0+; Central has
    no brand anchor within 800 m (Island Shangri-La ~830 m). Hung Hom is a
    hotel area, not an intercity hub (through-trains ended 2020).
  - Singapore: Changi has 1 (Crowne Plaza, landside; transit hotels are
    under 4.0); Marina Bay has 2 luxury only (Pan Pacific, PARKROYAL,
    Mandarin Oriental are 830–900 m out).
- **Sights excluded from the TripAdvisor rankings:**
  - Paris: Montmartre, Le Marais, Saint-Germain, Latin Quarter (districts;
    Sacré-Cœur covers Montmartre), Galeries Lafayette (shop), The Seine and
    Champs-Élysées (not single places), Parc des Princes (stadium),
    Marmottan Monet, Père-Lachaise, Panthéon and below (cap). Marché des
    Enfants Rouges added for local flavor.
  - Seoul: Lotte World (theme park), COEX Mall and Lotte Department Store
    (shopping), Namsan Park (same hill as N Seoul Tower), Hongdae street
    (hotel area); Jogyesa, NANTA, Folk Museum, Leeum, Sea Life, Seoul
    Forest, Trickeye cut for the cap.
  - Osaka: Shinsaibashi-suji, Namba Parks, Osaka Station City, Universal
    CityWalk, Denden Town (shopping); Osaka Castle Park (same as the
    castle); Minami (district); Namba Grand Kagetsu (Japanese-language
    comedy); Cool Japan Park (few reviews); Mint Museum, Bunraku Theater
    (cap). USJ kept (#1; on JR, not the metro).
  - Hong Kong: Skyline (not a place), Victoria Harbour (same as Star Ferry
    and the Promenade), Lantau Island (whole island), Mong Kok and Tsim Sha
    Tsui (districts), Ladies Market, Stanley Market, Harbour City
    (shopping); Ten Thousand Buddhas, Hong Kong Park, Tai O, Lamma, Repulse
    Bay cut for the cap. Disneyland and Ocean Park kept (both on the MTR).
  - Singapore: Orchard Road, Shoppes at MBS (shopping), Chinatown
    (district), Night Safari and Little India (3.8), Adventure Cove (water
    park), Hell's Museum (niche), SensoryScape (walkway), Lau Pa Sat
    (listing muddled). Cloud Forest, Flower Dome and the Orchid Garden are
    folded into their parent gardens.


### 2026-10-15 — city data split into JSON files; tools for adding cities
- Audrey asked how to go from 5 cities to 25. Plan decided: §4 "Adding a
  city". Audrey chose Claude curating hotels and sights over a paid
  Google Places pipeline.
- City data moved out of `site/index.html` into `site/data/cities.json`
  plus one file per city (tokyo, shanghai, newyork, london, barcelona;
  Paris stays "coming soon"). Data is byte-for-byte the same (checked by
  round-trip), and the app was tested side by side with the old version:
  same markers, lines and sidebar for every city. `index.html` went from
  143 KB to 79 KB.
- The page now needs to be served over HTTP; opening the file from disk
  no longer loads cities (§2, README).
- Fixed: pins in cities you hadn't opened yet in this visit were
  silently dropped the next time pins were saved (IDs were only assigned
  when a city was opened). IDs are now assigned for all cities at load.
- Fixed: switching city while zoomed in or out (or into/out of
  Barcelona, zoom 13) threw an error mid-switch, because the zoom change
  redrew the map before the new city's lines existed. Likely the cause
  of the "bare map" reports; the redraw now skips lines not built yet.
- Added `scripts/osm-lines.js`, the "Fetch subway lines from
  OpenStreetMap" Action, and `scripts/validate-cities.js` (§7). The
  validator passes on all 5 cities with 2 warnings: Shanghai Hongqiao
  Airport's hotel is labeled under the shared rail hub (allowed by curation
  spec §7), and NYC's simplified A-train jump to Howard Beach-JFK.

### 2026-10-15 — search bar fixes
- Audrey asked what the top search bar does: it searches saved data
  only, not the web.
- Fixed: typing "Shibuya" showed only hotels. Hotels were listed first
  and the dropdown caps at 8, so Shibuya's 8 hotel matches hid the
  station and Shibuya Crossing. Per Audrey: results are now ordered
  sights, then stations/rail/airports, then hotels, and every match is
  shown in a scrollable list with no cap (§3 "Place search").
- With no match, the dropdown's "Search the web" button (dead while live
  search is off) is replaced by a Booking.com search link for the query
  in the current city. The web-search button returns automatically if
  `LIVE_SEARCH_ENABLED` is turned back on.
- Removed a duplicate Tokyo hotel entry (The Millennials Shibuya was
  listed twice with different price tiers; kept the first, tier 2).

### 2026-10-10 — nearest-hotels fallback for uncurated stations
- Audrey asked how to handle the live site's "We haven't curated hotels
  near X" banner. Options weighed: better fallback ($0), curate more
  areas (ongoing, never complete), live-search backend (~1–2¢ per click
  plus an API key). Audrey chose the fallback.
- Built it (§3 "Nearest-hotels fallback"): 3 nearest curated hotels with
  walk time or distance, tap to open, plus a Booking.com search link for
  the station.
- Fixed: the coverage check only counted always-visible hotels, so a
  station with only click-to-reveal (`curated:false`) hotels nearby showed
  "not curated" while those hotels were on the map. It now counts any
  stored hotel within the radius.
- Curating more Tier 3 areas continues as the long-term fix; a live
  search backend waits until traffic justifies its cost.

### 2026-10-09 — live on GitHub Pages
- Hosting switched from the planned Cloudflare Pages to GitHub Pages
  (Audrey's call): repo `daewoogao/HopNest` made public, site live at
  https://daewoogao.github.io/HopNest/ (§7, §8).
- Added `.github/workflows/pages.yml`: publishes only `site/` on each
  push to `main`, so internal docs are still never served.
- Scanned the repo and full git history for API keys and secrets before
  going public; none found.
- Still open before a wider launch: OpenStreetMap public tiles aren't
  allowed for production traffic, and stored Google/TripAdvisor ratings
  conflict with their terms (§8).

### 2026-10-07 — launch prep for free hosting
- Picked Cloudflare Pages free tier as the host (§7): free with a private
  repo, no bandwidth cap. Replaces the earlier Netlify/Vercel default.
- Renamed `site/hopnest.html` → `site/index.html` (Audrey's call) so the
  bare domain loads the app; `manifest.json` `start_url` now `./`.
  `site/_redirects` sends old `/hopnest.html` links to `/`.
- Live search turned off for launch (checklist option (a), $0) via
  `LIVE_SEARCH_ENABLED = false`. Uncurated stations and hotel names now
  show a plain "not curated yet" banner, and error text no longer
  mentions the artifact viewer.
- Map tiles: OpenFreeMap recommended in §8, awaiting Audrey's decision.
- Fixed the stale disclaimer that said pins reset when the tab closes;
  they persist since cont'd 40.

### 2026-10-07 — sightseeing selection rules written into §4
- The hotel rules had a full spec, but the sightseeing rules only existed
  scattered across changelog entries. Collected them into a new
  "Sightseeing selection" subsection of §4 (TripAdvisor ranking as the
  source, local-flavor additions, noted exclusions, Places details,
  official-only ticket links, closures, refresh, verification). No rule
  was changed; each one cites the entry where it was decided.

### 2026-09-29 — launch checklist added (§8)
- Wrote down the full gap between the current app and a public launch
  as §8, grouped into must-fix / should-do / after-launch. New items not
  previously tracked anywhere: map tiles must move off OpenStreetMap's
  public server, the live-search error message is written for the
  Claude preview rather than real users, `index.html` rename, re-verifying
  July 2026 data, and checking terms for displaying ratings.
- Added map tiles to `launch-cost-plan.md` (new §2b and summary row).

### 2026-09-29 — website files moved into `site/`
- Moved `hopnest.html`, `manifest.json` and the three icons into `site/`
  so the host can publish just that folder. Deploying the whole repo
  would have made `launch-cost-plan.md`, the curation spec and this doc
  readable at public URLs. Relative paths inside the site are unchanged
  (all files moved together), so nothing in the app needed editing.

### 2026-09-28 — repo set up, README added, design doc brought up to date
- Put the project under git and pushed it to the existing private
  GitHub repo `daewoogao/HopNest`, merging with the older copies
  already there (local versions kept; GitHub's `README.md` kept).
  Added `.gitignore` for `.DS_Store`.
- Wrote a full `README.md` (features, cities, how to run, structure,
  curation summary, limitations, roadmap).
- Updated sections 2, 3, 5, 6 and 7 of this doc, which had fallen behind
  the changelog: pins/last city now persist (cont'd, 40), PWA install is
  built (cont'd, 43), live hotel name search is built (cont'd, 24), and
  added the city picker search, place search, trip sharing, fares,
  train times and sight details to the feature list. The app currently
  has 5 cities, not 2.

### 2026-07-13 (cont'd, 43) — PWA manifest added (item 2 of the launch checklist)
- Second item from the launch checklist: makes "Add to Home Screen" turn
  HopNest into something that looks and opens like a real installed app
  (full-screen, own icon, own name) instead of a generic bookmark that
  opens inside the browser chrome. Doesn't provide offline capability on
  its own (that needs a separate service worker, not built here) — scope
  was deliberately just the "feels like an app" piece.
- **New files**: `manifest.json` (name, icons, `display:standalone`,
  theme color, start URL), `icon-192.png`, `icon-512.png` (general PWA/
  Android icons), `apple-touch-icon.png` (180×180, iOS-specific — iOS
  Safari doesn't fully honor the web manifest's icon field, needs its
  own dedicated tag).
- **Generated the icon programmatically** (via PIL) rather than using a
  placeholder — a location-pin mark in the exact gold accent color
  (`#e0c34c`) already used throughout the app for pinned items, on the
  same navy gradient background already established for hover tooltips
  — so the install icon is visually consistent with the app's existing
  identity rather than an arbitrary new design.
- **Added the iOS-specific meta tags** required for standalone-mode
  behavior on Safari specifically (`apple-mobile-web-app-capable`,
  `apple-mobile-web-app-status-bar-style`, `apple-mobile-web-app-title`)
  — Android/Chrome mostly infer this from the manifest alone, iOS needs
  these declared explicitly.
- **Caught and fixed a real, unrelated inconsistency while in the head
  section anyway**: the `<title>` tag still said the old pre-rename
  "Transit Trip Planner" name — never updated when the project was
  renamed to HopNest. Fixed alongside this work since it was directly
  adjacent and easy to miss otherwise.
- Verified via the full-script execution test, direct inspection of the
  resulting `<head>` tags, and validated `manifest.json` actually
  parses as valid JSON before shipping.

### 2026-07-13 (cont'd, 42) — Copy button hidden unless actually needed, plus a real edge case found while testing it
- User pushed back further: even after merging Share+Copy into one
  action last entry, the Copy button was still always visible — which
  is exactly the redundant-button confusion originally flagged, just
  not fully fixed. Fair catch.
- **Fix**: Copy button now hidden by default, only revealed when
  auto-copy genuinely fails (both the Clipboard API and the older
  `execCommand` fallback). Verified via three explicit simulated
  scenarios (clipboard works / clipboard missing but execCommand works
  / both fail) — confirmed the button stays hidden in the first two and
  only appears in the third.
- **While building the test for this, found a real, separate bug**:
  `navigator.clipboard?.writeText(...).then().catch()` — when
  `navigator.clipboard` is entirely absent (not just present-but-
  rejecting), JS optional chaining short-circuits the *whole* chain,
  silently skipping `.then()` AND `.catch()` both. That meant in this
  specific case the person would get zero feedback at all — no success
  banner, no failure banner, and the Copy button would never appear,
  leaving them stuck with no way to know what happened. Confirmed this
  wasn't a mock artifact via a plain isolated Node test of the exact
  optional-chaining behavior before treating it as real.
- **Fixed properly**: added an explicit `if(!navigator.clipboard)`
  branch that goes straight to the `execCommand` fallback, rather than
  relying on optional chaining to handle a case it structurally can't
  handle. This is a genuinely different failure mode than "clipboard
  API exists but permission denied" and needed its own path.
- Notable given this session's pattern: found by testing the *fix* for
  a UX complaint, not by a user report — a case where writing the
  verification test surfaced a bug the original code review missed.

### 2026-07-13 (cont'd, 41) — fixed sight-pin visual feedback, share button, and confusing 2-button flow
- User reported three connected issues in one message.
- **1. Sight pinning appeared completely broken.** Real root cause found:
  `_togglePin()`'s popup-refresh logic only searched `hotelMarkers` to
  find which marker to re-open after pinning — never `sightMarkers`.
  Sights actually pinned correctly underneath (added to `pinnedIds`,
  persisted to storage) but the popup never visually refreshed to show
  "📌 Pinned," so it looked entirely non-functional even though it
  wasn't. Fixed by checking both marker arrays.
- **2. "Share button doesn't work."** Tested the actual share logic in
  isolation first — it worked correctly with no errors. Best diagnosis:
  a likely downstream consequence of bug #1 — if pinning attempts looked
  like they failed, there may have been nothing to actually share, and
  clicking Share with zero pins shows only a small, easy-to-miss banner
  rather than an obvious error state.
- **3. "What is Copy for, is it a duplicate of Share?"** This exposed a
  real UX problem worth fixing directly rather than just explaining:
  yes, requiring two separate clicks (Share to generate, then a second
  Copy click) was clunky. **Merged into one action** — Share now
  generates the link AND immediately attempts to copy it in a single
  tap. The visible link field remains as a fallback specifically for
  when clipboard access fails (some browser contexts restrict it), not
  as a mandatory first step every time.
- **Verified with a genuine end-to-end simulation**, not separate
  isolated checks: pinned a sight through the real `_togglePin` code
  path, then called the real `generateShareLink`, and confirmed the
  clipboard mock actually received the correct encoded URL — proving
  the full real user flow works, not just each piece individually.
- Also re-verified byte-level escaping correctness on the edited
  strings (the recurring class of bug from earlier in this session) —
  confirmed clean this time via direct numeric byte inspection before
  and after the edit, not just visual inspection.

### 2026-07-13 (cont'd, 40) — persistence added (item 1 of the launch checklist)
- First item from the "finish the launch checklist before adding more
  cities" decision. Pins and last-viewed city now survive a reload —
  previously reset every time, which was specifically a *Claude-preview*
  sandbox limitation (localStorage works fine on a real deployed site,
  this constraint doesn't carry over to launch).
- **Deliberately reused the exact same encoding logic already built and
  tested for share links** rather than writing new persistence logic
  from scratch — extracted the shared part into `collectPinItems()`,
  used by both `generateShareLink()` and the new `savePinsToStorage()`.
  Same curated-vs-live-search distinction applies: curated pins save as
  just an ID, live-search pins save their full snapshot so they survive
  without needing to be re-fetched.
- **Shared links and local persistence now compose correctly**: opening
  a shared link still takes priority for which city loads, but those
  shared pins also get adopted into this browser's own saved state
  afterward — so a shared trip doesn't just show once and vanish, it
  becomes part of what's remembered going forward.
- All localStorage access wrapped defensively (try/catch, silent
  failure) — same category of thing as clipboard/other browser APIs
  that can be restricted in some contexts; failing to persist should
  never crash the app.
- **Lost and rebuilt the test harness file twice during this session**
  (environment resets wiped `/home/claude/run_full_script.js` between
  turns) — rebuilt it from scratch each time with all previously
  accumulated mock fixes (setRadius, setPopupContent, location,
  btoa/atob, URLSearchParams, and now localStorage), rather than losing
  the accumulated verification rigor each time the file disappeared.
- Verified via the full-script execution test (confirmed `saveLastCity`
  fires correctly on init) plus a direct round-trip test: saved a
  realistic pin payload, simulated a completely fresh page load against
  a separate copy of the data, confirmed the pins restore correctly.

### 2026-07-13 (cont'd, 39) — searchable, alphabetized city picker
- Forward-looking fix for scale: discussed how a scrolling grid of city
  cards (fine at 5 cities) would become genuinely bad at hundreds — no
  way to jump straight to a city without scrolling through an unsorted
  list.
- **Deliberately kept this as a separate search box from the existing
  place-search bar**, not merged into it — they answer different
  questions (which city to look at, vs. what to find inside the current
  city) and merging them would make typing a city name while already
  inside a different city ambiguous.
- **Reused the exact same proven mechanism** rather than designing a new
  one: the same `normalizeSearchText()` accent-insensitive matching
  already built and tested for the in-city search bar, applied here to
  filter city cards instead of places.
- **Also alphabetized the city list as a free improvement** — previously
  cities just appeared in whatever order they were built in code, which
  was invisible at 5 cities but would be genuinely unhelpful at scale.
  Verified real order: Barcelona, London, New York City, Paris,
  Shanghai, Tokyo.
- Implementation deliberately avoids rebuilding the DOM on every
  keystroke — toggles `display:none` on existing, stable card elements
  (same lesson already learned from the city-switching bug fixed
  earlier: destroying/rebuilding elements during interaction is a real
  risk, not just wasteful).
- Verified via the full-script execution test (recreated after an
  environment reset wiped the test harness file — rebuilt it with all
  previously-accumulated mock fixes rather than starting the mock over)
  plus a direct data-level test of the sort and filter logic against
  real city data.

### 2026-07-13 (cont'd, 38) — new file: launch-cost-plan.md
- Consolidated every cost discussed across the entire project into one
  standalone financial planning document, requested to support a real
  launch decision rather than leaving cost info scattered across many
  separate conversation turns.
- Covers: one-time costs (domain, Apple/Google developer fees), hosting
  (GitHub Pages vs Netlify/Vercel), the data-refresh pipeline (corrected
  150-city figure + tiered strategy + a rough proportional 5-city
  estimate, explicitly flagged as not independently re-derived), live
  search (per-lookup cost, scales with traffic not city count), Supabase
  trust-circle costs (free tier sufficient to start, $25/mo Pro trigger),
  and analytics (not yet built, China/GA caveat carried over).
- Central framing: almost every real cost is gated behind one decision —
  building the backend — which simultaneously unlocks the data pipeline,
  live search, trust circles, and analytics at once, rather than being
  four separate cost decisions.
- Every figure carries its own research date and an explicit note to
  re-verify before committing money, since several of these prices (esp.
  Supabase, Google Places tiers) have shifted more than once this year
  per the sources checked during research.

### 2026-07-13 (cont'd, 37) — trip-plan sharing, Version A (no backend)
- Built the "Version A" share design scoped several sessions back:
  no accounts, no server, one link encodes everything currently pinned.
- **New "🔗 Share my pinned picks" button** in the sidebar. Gathers every
  currently pinned hotel and sight (across the whole session — pins can
  span multiple cities at once, not just the currently loaded one),
  encodes them into a compact base64 URL parameter, and shows the link
  in a copyable field (clipboard API first, `execCommand('copy')`
  fallback, manual-select as the last resort — no single clipboard path
  is reliable across every browser context).
- **Correctly distinguishes curated vs. live-search pins** when
  building the link — this was the trickiest real design decision.
  Curated hotels/sights just reference their ID (recipient's static
  data already has them). But live-search-found hotels don't persist
  anywhere — so for those specifically, the *entire hotel snapshot*
  (name/coordinates/rating/stars/price/phone) is embedded directly in
  the link, letting the recipient's browser reconstruct the marker
  without ever needing to re-run a search. Solves the "ephemeral live
  search" limitation for exactly the items someone actually cared enough
  about to pin — without needing a real backend.
- **Opening a shared link**: parses the URL on page load, restores every
  pin into `pinnedIds`, injects any embedded live-search snapshots into
  the right city's hotel list, and loads whichever city the first pin
  belongs to — with a banner confirming "📌 Showing a shared trip plan!"
  so it's clear what just happened.
- Fixed a real init-ordering bug while building this: `renderCityPicker()`
  needs to run *after* the correct city is loaded (not before), or a
  shared link pointing at a non-default city would show the wrong city
  highlighted as "active" in the picker despite the map being correct.
- **Verified with a full round-trip test against real data** (not just
  each half in isolation): generated a share payload from a realistic
  mixed set of pins — one curated Tokyo hotel, one Tokyo sight, one
  cross-city Shanghai hotel, and one simulated live-search hotel — then
  parsed it exactly as a fresh page load would, on a completely separate
  fresh copy of the data. Confirmed every pin restored correctly,
  including the live-search hotel's full snapshot reconstructing without
  any re-fetch.
- Also caught and fixed a real gap in the automated test harness itself
  while verifying this: the mock had no `location`, `btoa`/`atob`, or
  `URLSearchParams` globals (things every real browser provides
  automatically) — added them so future features touching URL state can
  be verified the same rigorous way.

### 2026-07-13 (cont'd, 36) — resolved the 2 remaining Tokyo gaps
- User asked me to actually double back and confirm rather than leave
  Tokyo National Museum and Shinjuku Gyoen as an open gap. Did the
  targeted searches — both resolved cleanly:
  - **Tokyo National Museum**: official site (tnm.jp, confirmed via
    Wikipedia infobox) itself links out to `tnm-museum.world/en/pay/` as
    its advance-ticket portal — confirmed genuinely official, not a
    reseller, since it's referenced directly from tnm.jp. Added with
    `bookAhead:true` (recommended for smoother entry, not strictly
    required — matches what multiple independent sources described).
  - **Shinjuku Gyoen**: official is the Ministry of Environment's own
    page, with advance booking at `shinjukugyoen.hp.peraichi.com/en`.
    **Deliberately did NOT apply the generic `bookAhead` flag** — the
    real requirement is far more specific than "books up in peak
    season": reservations are only mandatory on a handful of named
    weekend dates during cherry blossom season (10 AM–4 PM slots),
    walk-up entry works fine every other day of the year. Applying the
    generic flag would have overstated a real, well-documented nuance.
    Instead wrote the precise seasonal detail directly into the sight's
    own note field — a case where the flat boolean genuinely wasn't
    honest enough on its own, exactly the kind of over-simplification
    risk discussed when the flag was first designed.
- **All 24 Tokyo/London/NYC/Barcelona sights with ticket needs are now
  resolved** — no remaining unconfirmed gaps outside Shanghai (still
  deliberately skipped per earlier direction).
- Verified via the full-script execution test plus direct inspection
  confirming Shinjuku Gyoen correctly has `bookAhead: undefined` (not
  `true`), proving the deliberate omission landed as intended.

### 2026-07-13 (cont'd, 35) — official ticket links + "books up" flag, 22 sights
- Implemented both pieces discussed: real official ticket URLs, and a
  qualitative "books up in advance" flag instead of a fake specific
  day-count (rejected the precise-number idea since availability is
  genuinely seasonal and we have no live-availability data source — a
  wrong specific number would be worse than no number at all).
- **22 sights got real, individually-verified official ticket links**:
  Tokyo (3: Skytree, Tower, teamLab Planets), London (all 7), NYC (all
  6), Barcelona (6: Sagrada Família, Casa Batlló, Park Güell, Palace of
  Catalan Music, La Pedrera, Casa Vicens). Every single link was
  confirmed as the genuine official domain, not a reseller — this
  mattered in practice: nearly every search for these iconic sights was
  dominated by Klook/Viator/GetYourGuide/Tiqets-style resale sites, and
  several required a second, more targeted search specifically for the
  known official domain to cut through the SEO noise.
- **Shanghai deliberately skipped, at user's direction** mid-task, after
  finding that Chinese attractions (Shanghai Tower, Oriental Pearl
  Tower) don't have a clean single official English ticketing domain
  the way Western/Japanese ones do — results were dominated by tour-
  guide aggregator content, not a canonical official site. Left without
  ticket links rather than guess.
- **Real, unplanned finding along the way: Shanghai World Financial
  Center's observation decks have been closed since 2023 for
  renovation.** This wasn't a ticket-link question anymore — updated
  the sight's note and hours field to reflect the closure directly,
  since sending someone there for a closed observation deck would be
  actively wrong, not just an incomplete feature.
- Tokyo National Museum and Shinjuku Gyoen intentionally left without
  ticket links — couldn't get a clean official-domain confirmation for
  either in the time spent, and chose to leave an honest gap rather
  than guess.
- Added `bookAhead` boolean, displayed as "⚠️ Books up — reserve ahead,
  especially in peak season" — applied uniformly to all 22 ticketed
  sights rather than trying to rank which ones sell out faster (a
  distinction not confidently verifiable without live data anyway).
- Paced this as a multi-stage task with explicit check-ins rather than
  silently grinding through ~29 sights in one continuous push — checked
  in twice on scope/pace, and the user explicitly chose to skip further
  Shanghai digging partway through rather than have that decision made
  silently.
- Verified via the full-script execution test, plus direct confirmation
  that all 22 ticketUrl fields and the SWFC closure note landed
  correctly with clean apostrophe encoding.

### 2026-07-13 (cont'd, 34) — sightseeing pinning added (step 1 of trip-sharing)
- First concrete step toward the trip-sharing feature discussed
  earlier: pinning previously only existed for hotels — sights had no
  pin capability at all, which would have made "share your favorite
  hotels and sightseeing" only half-true.
- Assigned each sight a stable `_id` (`cityId_s{idx}`), same pattern
  hotels already use (`cityId_h{idx}`) — no collision risk between the
  two ID namespaces, confirmed by checking every use of `pinnedIds`
  before sharing the Set between them (it's only ever checked via
  `.has(id)`, never iterated with hotel-only assumptions, so this was
  safe).
- **Deliberately used the same robust `popupopen` pattern already
  established for hotels** (bind the popup once, rebuild its content
  dynamically via Leaflet's native event) rather than the old static-
  content approach sights previously used — avoids reintroducing the
  exact "second click does nothing" class of bug already fixed once
  today for hotels.
- Added `buildSightPopupHTML(s)` as a pure content function (mirroring
  `buildHotelPopupHTML`), including a pin button styled identically to
  the hotel one.
- **Also wired up ticket-link support now** (`s.ticketUrl`, shown only
  when present, same conditional pattern as `phone`) — no sight data has
  this field populated yet, but the code is ready for it. Decided ticket
  links are worth adding: several sights (Sagrada Família, teamLab,
  Tokyo Skytree, Statue of Liberty) require timed-entry booking and can
  sell out — a direct official link avoids someone googling their way to
  a markup-charging resale site instead. Scoped as a separate follow-up
  data-population task, not bundled into this pinning change.
- Verified via the full-script execution test plus a direct test of
  `buildSightPopupHTML` against realistic data, confirming correct
  output including the pin button.

### 2026-07-13 (cont'd, 33) — fixed city switch sometimes showing a bare map on the first click
- User reported: switching cities sometimes showed just the map tiles
  with no subway lines/hotels on the first click, only appearing after
  a second click.
- **Diagnosis**: `map.setView()` was called without disabling animation,
  so switching cities triggered an animated pan/zoom — and in the same
  synchronous step immediately after, dozens of new layers (subway
  polylines, station dots, hotel markers) were added to the map *while
  that animation was still in flight*. This is a known category of
  Leaflet issue: layers added mid-transition can have their screen
  positions calculated against the map's old, not-yet-settled state,
  so they don't visually paint correctly until something else forces a
  fresh layout pass — like a second click or interaction.
- **Fix**: `map.setView(data.center, data.zoom, {animate:false})` —
  disables the animation for this specific transition, the standard
  approach for this exact class of bug. Also added `map.invalidateSize()`
  right before, as a cheap standard companion fix to ensure Leaflet's
  internal size cache is correct in case any layout shift happened
  between switches (e.g. the search bar's topbar-shifting behavior).
- **Honest verification caveat**: the mock Leaflet used for the full-
  script execution test doesn't simulate real animation timing, so this
  couldn't be behaviorally confirmed through automated testing the way
  the other fixes today were. Confidence here comes from `{animate:
  false}` + `invalidateSize()` being a well-established, standard fix
  pattern for this exact symptom, not from a passing test — flagging
  this distinction honestly rather than implying the same level of
  certainty as the fixes that were directly verified.

### 2026-07-13 (cont'd, 32) — fixed Barcelona's airport line being disconnected from the rest of the network
- User noticed L9 Sud (the airport line) didn't visually connect to any
  other line. Verified: confirmed true — L9S shared zero station names
  with L1–L5, making it a disconnected island on the map despite Metro
  L9S genuinely being a one-seat ride discovery we'd highlighted earlier
  as a differentiator.
- **Root cause**: L9S's station list already correctly named its real
  transfer points (Torrassa, Collblanc, Zona Universitària), but I never
  added matching entries to the *other* lines those stations actually
  connect to — so the names existed on one side of each transfer but
  not the other, and nothing overlapped.
- **Verified the real transfers via search before fixing** (per TMB's
  own site): Torrassa↔L1, Collblanc↔L5, Zona Universitària↔L3 — all
  three confirmed directly from Barcelona's transit authority.
- Added the three transfer stations to their real corresponding lines,
  reusing L9S's exact existing coordinates for each so the name-based
  interchange dedup (fixed a few entries ago) treats them as proper
  single connection points rather than near-but-not-quite matches.
- Verified via the full-script execution test plus a direct connectivity
  check confirming all three stations now appear on both their local
  line and L9 Sud.

### 2026-07-13 (cont'd, 31) — fixed click bug at multi-line interchange stations
- User caught a real bug: clicking a station served by multiple lines
  (an interchange) didn't show the walk circle, but hotel highlighting
  still worked — meaning the underlying data logic ran, but the visible
  circle didn't clearly appear.
- **Root cause**: each line independently created its own fully-clickable
  dot for every station, including shared ones. A station on 3 lines got
  3 separate interactive circleMarkers stacked at nearly the same spot.
  A single tap — especially on touch, where the tap target is larger
  than the 5px dot — could land on more than one overlapping dot at
  once, firing `toggleStationCircle` multiple times for one physical
  tap. Multiple circles/popups got created and interfered with each
  other (later popups auto-closing earlier ones), which produced exactly
  the reported symptom.
- **First fix attempt used exact-coordinate matching and was
  insufficient** — verified this directly against real data before
  shipping it: NYC's Times Sq-42 St has 3 *slightly different*
  coordinates across its lines (up to ~250m apart, representing
  different platform entrances), so an exact-match dedup missed it
  entirely. Caught this by actually testing against real station data
  rather than assuming the first fix worked.
- **Correct fix: deduplicate by station name, not coordinates.** Subway
  station names are effectively unique identifiers within a system by
  strong real-world convention (precisely so people don't confuse two
  different places) — confirmed this holds for all of our data before
  relying on it. Only the first line's dot for a given station name is
  now interactive; every other line's dot at that station becomes
  visual-only (`interactive:false`), so a tap there can only ever fire
  once, regardless of how many lines pass through.
- **Also made subway line polylines non-interactive** — they had no
  click behavior at all (confirmed via search before changing), but
  were capturing clicks by Leaflet's default, and multiple lines'
  5px-wide polylines also converge at the same interchange points,
  giving them the same potential to intercept a tap meant for a dot.
  Purely additive robustness fix, zero behavior lost.
- Verified with the full-script execution test, plus a direct test of
  the dedup logic against real NYC data — confirmed Union Square-14 St,
  Grand Central-42 St, and Times Sq-42 St each now have exactly one
  interactive dot instead of 2–3 competing ones (5 dots fixed in NYC
  alone; likely more across Tokyo/London's own interchange stations,
  not individually re-verified per city but the fix is general).

### 2026-07-13 (cont'd, 30) — real fare information added, all 5 cities
- First feature pursued from the "what should we build next" discussion,
  chosen deliberately over the trip-sharing feature as the smaller,
  standalone piece to ship first.
- **Real fare structures researched and verified per city** — each
  system genuinely works differently, worth knowing honestly rather than
  assuming one model fits all:
  - Tokyo: distance-based, ¥180–¥330 (Metro) / up to ¥430 (Toei)
  - Shanghai: distance-based, ¥3 base (≤6km) + ~¥1 per additional 10km
  - London: zone-based, £3.00 off-peak/£3.10 peak Zone 1, £8.90 daily cap
  - New York: flat $3.00 regardless of distance, $35 weekly cap
    (confirmed via official mta.info — some third-party sources still
    quoted the pre-January-2026 $2.90 rate, used the current one)
  - Barcelona: zone-based, €2.90 single / €13.00 for 10 trips
- **Specific "gotcha" fares surfaced right where they matter**, not just
  buried in a general note — added directly to the relevant airport's
  info: Tokyo Monorail ¥519, Keisei Skyliner ¥2,465, NYC's JFK AirTrain
  supplement ($8.50 on top of the $3 subway fare), and Barcelona's L9
  Sud airport supplement (€5.90 — standard tickets/T-Casual explicitly
  do NOT cover this line, confirmed as a common visitor trap across
  multiple sources).
- New `fareInfo` field per city, displayed in the sidebar right below
  the operating-hours note, same UI pattern for consistency.
- Verified via the full-script execution test plus direct spot-checks of
  the exact fare text landing correctly on Haneda and El Prat.

### 2026-07-13 (cont'd, 29) — fixed two real bugs: hotel popup not reopening, city switch needing 2 clicks
- **Bug 1: clicking a hotel a second time showed nothing.** Root cause:
  `openHotelPopup()` called `marker.bindPopup(...).openPopup()` on
  *every* click. Leaflet's `bindPopup()` silently (re-)registers its own
  internal click-to-toggle listener each time it's called — combined
  with our separate custom click listener, this created two competing
  click handlers on the same marker. On the second click: our handler
  fired first and reopened the popup, then Leaflet's own toggle listener
  fired immediately after (registered during the first click's bindPopup
  call) and saw the popup as already-open, so it closed what our handler
  had just opened — net effect looked like nothing happened.
  **Fix**: refactored to bind the popup exactly once per marker (at
  creation), with a `buildHotelPopupHTML()` pure content function and a
  `wireHotelPopup()` helper that hooks Leaflet's native `popupopen` event
  to refresh content dynamically. Leaflet's own toggle is now the only
  thing controlling open/close — no more competing handlers. Applied at
  all 3 marker-creation call sites (curated hotels, live-search results,
  name-search results).
- **Bug 2: switching cities needed two taps.** Root cause: the city-card
  click handler called `renderCityPicker()`, which destroyed and rebuilt
  *all* city cards — including the very card that was mid-click — via
  `innerHTML=''`. Replacing an element during its own click event is a
  known category of mobile bug that can make the very next tap at that
  screen position silently misfire. It was also just wasteful: 6 DOM
  elements + 6 listeners rebuilt on every single city switch, when only
  one CSS class actually needed to change.
  **Fix**: added `updateActiveCityCard()`, which toggles the `.active`
  class on the existing, stable card elements instead of rebuilding
  anything. `renderCityPicker()` now only runs once, at page load.
- Verified both fixes via the full-script execution test (not just
  parse-checking), plus confirmed zero leftover references to the old
  buggy `openHotelPopup` function — all 3 call sites were caught and
  migrated, none left stale.

### 2026-07-13 (cont'd, 28) — full audit: airport/railway hotel coverage
- User asked directly whether airports/railway stations were treated as
  Tier 1 critical areas, having seen 0 hotels around some. Ran a full
  exact-match audit across all 5 cities' airports and rail stations —
  found the picture was more nuanced than "missing," two distinct
  problems stacked together:
  1. **Real bug (not a content gap): naming mismatches.** Several areas
     *did* have curated hotels, just tagged with a shorthand area label
     that didn't exactly match the airport/station's official name
     string (e.g. hotels tagged `'JFK Airport'` vs. the real name `'John
     F. Kennedy International Airport'`). This wasn't just an audit
     inconvenience — it broke the app's own live-search-skip check
     (exact string match), meaning clicking these airports would have
     incorrectly triggered unnecessary live searches despite curated
     hotels already existing right there. **Fixed**: renamed every
     mismatched hotel `area` field to the exact official name (Shanghai
     Pudong, Shanghai Hongqiao Railway Station, JFK, Grand Central
     Terminal, El Prat — 15 hotels relabeled across 4 cities).
  2. **Made the live-search-skip check spatial, not just name-based.**
     Shanghai's Hongqiao airport and railway station physically share
     one hub — hotels there are labeled with the station's name, so
     exact-string matching would never recognize them as covering the
     airport too. Rather than force a data hack, fixed the actual check
     in `maybeFetchLiveHotels()`: now also considers a curated hotel
     "already covering" a clicked point if it's within the current walk
     radius, regardless of which exact area label it carries. This
     generalizes to any future shared-hub case, not just Hongqiao.
  3. **Real remaining gaps, filled with genuine researched hotels**:
     Shanghai South Railway Station (Pullman Shanghai South — the only
     nearby hotel that cleared both the rating and 100-review floor even
     after a broader search; Radisson Blu and JOYA looked appealing but
     had 14 and 29 reviews, too thin to trust), Newark Airport (Hilton
     Newark Airport + Holiday Inn Express Newark Airport, both real
     brand anchors at exactly 4.0), and Gatwick Airport (Sofitel London
     Gatwick — literally walkway-connected to the terminal — + Holiday
     Inn + Crowne Plaza, all real IHG/Accor brand anchors).
- **Final state, verified**: every airport and railway station across
  all 5 cities now has real curated coverage — either directly, or (for
  Hongqiao specifically) correctly recognized via the new spatial check
  even though the exact-string audit still shows 0 for that one case.
- Verified via the full-script execution test plus a complete re-run of
  the audit query before and after each fix, not just spot-checked.

### 2026-07-13 (cont'd, 27) — fixed stale popup text (wrong color name + frozen minute value)
- User quoted the exact stale text: "Showing 15-min walk radius. Hotels
  inside are highlighted gold in the list." Two separate real bugs in
  one sentence:
  1. **Wrong color name** — hotels highlight dark green, not gold (gold
     was accurate at an earlier point in the build, before the color
     scheme changed; the popup text was never updated to match). Fixed.
  2. **Frozen minute value** — same root cause as the circle-radius bug
     fixed earlier: the popup's text was a static string baked in at
     the moment the popup was first opened, so it kept showing whatever
     the slider said *then*, not the current value.
- **Fix**: extracted `buildStationPopupHTML(name, line, mins)` so the
  popup content can be regenerated on demand, not just built once.
  `setWalkMinutes()` now calls `markerKey.setPopupContent(...)` to
  rebuild any currently-open station popup's text live, in addition to
  resizing the circle — so dragging the slider while a popup is open
  now updates both the circle size AND the displayed minute value in
  real time, not just one of them.
- Stored the full `line` object (not just its name string) on
  `circle.meta.lineObj` specifically to make this regeneration possible
  — the original code only kept `line.name`, which wasn't enough to
  rebuild the full popup (needed `line.firstLast` too).
- Verified via the full-script execution test with `setPopupContent`
  added to the test's Leaflet mock, plus confirmed via direct string
  search that "highlighted gold" no longer appears anywhere in the file.

### 2026-07-13 (cont'd, 26) — fixed walk-distance slider not affecting open circles
- User caught a real bug: changing the walk-distance slider while a
  circle was already open showed identical hotels no matter how far the
  slider moved. Root cause confirmed via code review: circle radius was
  baked in at the moment of creation (`walkMinutes*WALK_SPEED_M_PER_MIN`
  captured once into `circle.meta.radius`), and the slider's `input`
  handler only updated the global `walkMinutes` variable — it never
  touched any already-open circle's actual size or its stored radius
  used for the hotel-in-circle calculation.
- **Fix**: `setWalkMinutes()` now calls `circle.setRadius()` on every
  currently-open circle (resizing the visible shape on the map) and
  updates `circle.meta.radius` to match (so hotel highlighting
  recalculates correctly), before triggering `render()`. Dragging the
  slider with a circle open now visibly grows/shrinks it and live-
  updates which hotels are highlighted, instead of doing nothing.
- Verified via the full-script execution test (not just parse-checking)
  with `setRadius` added to the test's Leaflet mock — confirmed the
  script still initializes cleanly end to end with this change in place.

### 2026-07-13 (cont'd, 25) — Lujiazui added as its own curated hotel area
- User caught a real geographic error: Lujiazui had been implicitly
  treated as covered by "The Bund" area's hotels, but they're on
  **opposite sides of the Huangpu River with no walking bridge** — not
  actually walkable between them, contrary to what the grouping implied.
  Lujiazui previously existed only as a sightseeing landmark, with zero
  hotels tagged to it.
- Added Lujiazui as its own sixth curated hotel area: Novotel Shanghai
  Atlantis (4.5★, 4★ class), Grand Hyatt Shanghai (4.3★, 5★, inside Jin
  Mao Tower), Grand Kempinski Hotel Shanghai (4.5★, 5★), Pudong
  Shangri-La (4.4★, 5★, 1,396 reviews).
- **Honest gap, not forced**: Lujiazui's real hotel inventory skews
  heavily luxury — searched specifically for a budget/mid option and
  found only very low-volume candidates (Binjia Youth Hostel: 8 reviews;
  iFamily Apart Hotel: 1 review; CitiGo: 3; JI Hotel: 2) — all far below
  the 100-review floor. None forced in. This matches Lujiazui's actual
  character as a financial/business skyline district rather than being
  an oversight in the curation pass.
- Also fixed the underlying assumption in the pipeline spec that
  physically adjacent-looking areas are automatically walkable to each
  other — river/highway/rail separations can break this even when two
  places look close on a map. See spec update below.

### 2026-07-13 (cont'd, 24) — live hotel name search
- Built the feature scoped a few messages back: when a search returns 0
  curated matches, the dropdown now offers **"Search the web for
  '[query]'"** instead of just a dead-end "no matches" message.
- Deliberately reuses existing infrastructure rather than adding a new
  paid API integration: same `api.anthropic.com` + web-search-tool call
  pattern as the existing station-triggered live search, same dedup
  pattern (`liveFetchedKeys`/`liveFetchInFlight`), same hotel object
  shape (`curated:false, live:true`), and — notably — **walk-distance-
  to-nearest-station comes for free**, since `openHotelPopup()` already
  computes and displays that for any hotel regardless of how it entered
  `data.hotels`. No new walkability code was needed at all.
- New `fetchHotelByName(query, key)`: asks Claude to find one specific
  named hotel (not a list) via web search, returns `{found, name, lat,
  lng, rating, stars, priceTier, phone, area}`. On success: adds the
  hotel, pans the map to it, opens its popup (which shows the real walk
  distance to the nearest station, or "no active subway line nearby" if
  none is toggled on) — directly answering the original request: type a
  hotel that isn't curated, see if it's actually walkable.
- Same honest caveats as existing live search: best-effort, only works
  inside Claude's own preview (no backend yet), costs real money once a
  backend exists (~1–2¢/lookup, per the cost estimate already in this
  doc).
- **Hit and fixed the recurring backslash-escaping bug again** (this
  time genuinely real — confirmed via raw byte values, not a repr
  misread) in the system prompt string's `hotel's`. Fixed with a
  byte-level Python script rather than string-literal replacement,
  after two failed attempts where Python's own string-literal escaping
  kept adding a layer of confusion on top of the original bug — the
  numeric byte-value check (`list(bytes)`) was what finally gave an
  unambiguous answer, and is now the most reliable verification method
  found so far for this specific class of bug.
- Thumbnails (Tokyo/Shanghai/London/NYC) intentionally deferred per
  explicit user direction — this feature was prioritized first.

### 2026-07-13 (cont'd, 23) — search deployed to all cities
- Pilot succeeded (Shanghai-only). Removed the city-gating condition —
  search now shows for every city, and since the underlying logic reads
  `CITIES[currentCityId]` dynamically rather than hardcoding city names
  anywhere, it automatically covers future cities (Rome, Paris, whatever
  comes next) with zero additional code required.
- Verified real item counts per city before shipping: Tokyo 171,
  Shanghai 72, London 82, New York 71, Barcelona 64 searchable items.
- Sightseeing thumbnails remain Barcelona-only for now — much larger
  lift (14 individually-verified images just for one city) — being
  worked through city by city separately, not a quick toggle like search
  was.

### 2026-07-13 (cont'd, 22) — corrected the 150-city cost estimate
- User pressure-tested the earlier $35–75/mo figure by scaling it to 150
  cities and asked directly whether that meant $2,000+/mo. Correct
  answer: yes, roughly — and my prior "$35–75/mo at global scale" number
  was wrong, reused from an earlier estimate without re-deriving it
  properly.
- **Real math**: 150 cities × 10 areas × 40 hotels ≈ 400 Places API
  calls/city/month (area discovery + per-hotel detail lookups,
  including candidates vetted but not kept) = 60,000 calls/month.
  Rating+review+phone+hours together push each call into Google's
  Enterprise tier (~$35–40/1,000), not the free/basic tier — this field-
  mask detail was the specific error in the original estimate.
  **Corrected flat-monthly figure: ~$2,100–2,400/mo.**
- **Fix implemented, per user request: tiered refresh frequency**
  instead of flat monthly for every city — top 10–20 cities monthly,
  long tail quarterly, since hotel ratings don't meaningfully shift
  week to week for most cities. Cuts the estimate to **~$700–1,200/mo**
  at the same 150-city scale.
- **Also per user request: combined live-search cost into the same
  estimate**, since it's a real, separate, additive cost once a backend
  exists — not folded into the batch-refresh number, and scales with
  *user traffic* rather than city count, which is a structurally
  different growth curve worth watching separately via the event-logging
  item once real usage exists to measure.
- **Combined realistic total at 150-city scale: ~$750–1,300/mo**,
  documented in §6 with the reasoning shown, not just the number, so a
  future re-derivation (when real usage data exists) can check it
  against actual assumptions rather than trusting a bare figure.

### 2026-07-13 (cont'd, 21) — fixed search returning 0 for category terms like "art museum"
- User tried searching "art museum" in Shanghai and got zero results,
  despite Shanghai Museum obviously existing. Root cause was two stacked
  bugs, not one:
  1. Search only indexed name + subtitle, never the description text —
     so "art" was invisible to search even though Shanghai Museum's own
     description literally says "major collection of Chinese art &
     artifacts."
  2. Even with descriptions included, the old matching required the
     whole query as one contiguous substring — "art" living in the
     description and "museum" living in the name are two different
     fields, so a phrase match would still have failed.
- **Fix**: added each item's description/note text to the search index
  (`extra` field — sight notes, rail station notes, airport transit
  notes), and switched matching from single-phrase to per-word AND logic
  (every word in the query must appear somewhere in name+sub+extra
  combined, but the words no longer need to be adjacent or in the same
  field).
- This fix generalizes well beyond the one reported case — verified
  "museum", "temple", and "garden" all now correctly surface Shanghai
  Museum, Jade Buddha Temple, and Yu Garden respectively, none of which
  contain those exact words in their proper names alone.

### 2026-07-13 (cont'd, 20) — fixed search bar overlapping the zoom-hint pill
- User screenshot caught a real layout bug: the new search bar and the
  existing "zoom in for labels" pill were both absolutely positioned at
  nearly the same spot (top:10px vs top:14px), so they collided visually
  on Shanghai specifically (the only city where the search bar shows).
- **Fix**: added a `.search-active` class on `#topbar` that pushes it
  down (top:74px) to clear the search bar, toggled in sync with the
  search bar's own Shanghai-only visibility in `loadCity()` — so other
  cities are completely unaffected, only Shanghai's layout changed.
- Also bumped the search bar's z-index above the topbar's, so if the
  results dropdown ever extends down far enough to reach where the pill
  now sits, the dropdown correctly layers on top rather than the two
  fighting for the same visual space.

### 2026-07-13 (cont'd, 19) — place search, Shanghai pilot
- Added a floating search bar over the map (Google Maps-style), pinned
  at the top regardless of sidebar/sheet state. **Scoped to Shanghai
  only for this pilot** — hidden for every other city — per the user's
  explicit request to test on a city they know well before deciding
  whether to roll it out everywhere.
- Searches across everything in the current city: hotels, sights,
  subway stations (deduplicated by name across lines), railway stations,
  and airports — 72 searchable items for Shanghai currently.
- Live-filters as you type (typeahead, not submit-and-search), up to 8
  results shown with a type icon + subtitle (area for hotels, line name
  for stations, etc).
- **Accent-insensitive matching** built in from the start — normalizes
  via Unicode NFD decomposition before comparing, so typing without
  diacritics still matches. (Barcelona will need this even more once/if
  the feature extends there — Güell, Milà, Família all have accents.)
- Selecting a result pans/zooms the map to it and opens its popup.
  **Handles the click-to-reveal hotel case correctly**: if the selected
  hotel isn't currently visible (not curated, no circle active), it's
  force-added to the map directly rather than just scrolling to an
  invisible point — search always shows you what you searched for.
- Verified the index-building logic against real Shanghai data before
  shipping (not just eyeballed) — confirmed correct type counts and
  tested a real accent-relevant case (Lujiazui correctly returns both
  its sight and station entries).
- Scoping mechanism: `#place-search-wrap` visibility is toggled in
  `loadCity()` based on `cityId === 'shanghai'` — trivial to extend to
  all cities later by removing that one condition, once the pilot
  proves out.

### 2026-07-13 (cont'd, 18) — sightseeing thumbnails added, Barcelona only (pilot)
- User feedback: some Barcelona sight names are genuinely hard to
  distinguish by text alone (Casa Batlló / Casa Milà / Casa Vicens are
  all "Casa + name + Gaudí building"). Proposed adding a small photo to
  each sight's popup — piloted on Barcelona only, per explicit request,
  before deciding whether to extend to other cities.
- **Source: Wikimedia Commons exclusively**, not generic image search —
  chosen specifically for reliability (URLs don't hotlink-break the way
  random web images do) and unambiguous licensing (everything on Commons
  is confirmed freely reusable). Used `Special:FilePath`, Commons' own
  stable-linking mechanism built for exactly this kind of external
  embedding.
- Manually verified all 14 images individually — confirmed each file
  actually exists on Commons and is genuinely the right subject (not
  just a plausible-sounding filename) before using it. This took
  considerably longer than expected; a mid-task infrastructure outage
  (tool failures, unrelated to the work itself) added further delay but
  didn't affect the data — work resumed cleanly once tools recovered.
- Implementation: added an `img` field to each Barcelona sight, a
  `.sight-thumb` CSS class (rounded, cropped to a consistent 110px
  height), and updated the popup builder to show the image at the top
  when present. Scoped deliberately to the **popup only, not hover** —
  hover was already trimmed down to short text/schedule info in an
  earlier change, and this isn't reversing that.
- Explicitly a pilot, per the user's own framing ("let's see how it
  goes") — not yet extended to Tokyo/Shanghai/London/NYC. Revisit after
  feedback on how Barcelona's version actually feels in use.

### 2026-07-13 (cont'd, 17) — hover simplified to name + schedule only
- User feedback (on desktop, testing this preview via mouse): hover and
  click showed identical content, which read as duplicated/weird.
  Discussed whether hover should be removed entirely, and whether
  device-adaptive behavior (different UI for mouse vs. touch) made
  sense.
- **Decision: keep hover, but give it a distinct, narrower job instead
  of removing it.** Reasoning: hover has no side effects (doesn't draw a
  circle or trigger highlighting), so it's genuinely useful for
  comparing multiple icons before committing to a click — removing it
  would force every quick glance into a stateful map action.
- **Rejected device-adaptive (mouse vs. touch) behavior on principle**:
  this app is phone-first per repeated earlier direction; building a
  separate desktop-only interaction path optimizes the secondary
  platform at the cost of doubling future maintenance. A single
  universal behavior that happens to degrade gracefully on touch
  (hover mostly doesn't fire there anyway) was preferred over branching
  logic by input type.
- **Implementation**: hover now shows name + schedule only, dropping the
  transit note. Click keeps full detail (name + note + schedule) plus
  the walk-circle action, unchanged. For airports/stations with no real
  schedule data (Gatwick, LaGuardia, Newark), hover falls back to a
  short version of the transit note instead of showing nothing.
- Clarified and confirmed the underlying data model in the process: the
  "schedule" shown for an airport is always the *connecting subway
  line's* first/last train (e.g. Haneda's hours come from the Tokyo
  Monorail), never the airport's own hours — airports don't have a
  fixed daily operating window the way trains do.
- Verified all three render cases (connected airport, unconnected
  airport, rail station) via direct evaluation before shipping.

### 2026-07-13 (cont'd, 16) — Barcelona added
- Built Barcelona as the fifth full city, same rigor throughout: real
  fetched TripAdvisor ranking, confirmed real Metro colors, targeted
  budget-tier searches, full data-evaluation verification before
  shipping.
- **6 Metro lines**, real TMB colors confirmed via search (not just
  assumed): L1 (red), L2 (purple), L3 (green), L4 (yellow), L5 (blue),
  L9 Sud (orange, airport). ~30 stations covering Gothic Quarter,
  Eixample, Barceloneta, Sants, and the airport corridor.
- **Genuine first for this project: El Prat Airport has a true one-seat
  metro ride** (L9S, direct to both terminals) — every other city so far
  has needed a transfer (JFK/AirTrain) or has no connection at all
  (LaGuardia). Called this out explicitly in the airport's transit note
  since it's a real differentiator worth knowing.
- **20 curated hotels** across 5 areas (Gothic Quarter, Eixample,
  Barceloneta, Barcelona Sants, El Prat Airport), all ≥4.0, full pipeline
  applied — brand anchors (Radisson Blu, NH, Hilton, W, Eurostars, Hyatt
  Regency, Meliá, Sheraton) and genuine budget options found via targeted
  hostel searches (Ítaca Hostel 4.6★, Sun & Moon hostel 4.2★).
- **14 sights**, cross-checked against the real fetched TripAdvisor
  ranking. One deliberate exclusion: #10 on the real list is an
  adult-themed museum, skipped as a judgment call for a general-purpose
  trip planner — noted explicitly rather than silently dropped, same
  transparency standard as every other decision in this project.
- **1 railway station** (Barcelona Sants — AVE high-speed rail to Madrid
  and France).
- **Confirmed genuinely unique operating hours**: Barcelona's Metro runs
  24 hours continuously from Saturday morning through Sunday night —
  more generous than any other city on the map, verified via search
  rather than assumed.
- Verified the full build via direct data evaluation (not just parse-
  checking) before shipping — confirmed all apostrophes render correctly
  and Tokyo/Shanghai/London/NYC were untouched by the insertion.
- City picker required no extra wiring — confirmed it dynamically
  iterates `Object.entries(CITIES)`, so Barcelona appeared automatically.

### 2026-07-13 (cont'd, 15) — smart popup auto-close
- Follow-up to the hover/click discussion. Real annoyance identified:
  not "doesn't close automatically" (Leaflet already closes on map-click
  by default) but that the popup **lingers and blocks the view of the
  exact hotels you just asked to see** by clicking.
- **Smart rule implemented**: clicking a station/airport/rail icon opens
  its info popup as before, but it now auto-closes itself after 4
  seconds — enough time to read, then it gets out of the way. The
  circle and highlighted hotels stay exactly as they were; only the
  popup box closes, nothing else changes.
- **Immediate close on toggle-off**: clicking the same icon again to
  clear its circle now also closes the popup immediately (previously it
  showed a separate "walk radius cleared" confirmation popup that itself
  needed dismissing — removed as unnecessary noise, consistent with the
  "click = action, not a wall of text" philosophy from this discussion).
- Scoped deliberately to station/airport/rail popups only, not hotel
  popups (which have an interactive pin button and should stay open
  until the user is done with them, not auto-dismiss mid-decision).
- Implementation: a small `scheduleAutoClose(marker, delay)` helper,
  timer stored per-marker and cleared/reset on every open so repeated
  clicks don't stack stale timers.

### 2026-07-13 (cont'd, 14) — unified hover and click content, white card style
- User feedback: hover and click showed different, overlapping info,
  and the navy tooltip clashed with the rest of the app's light UI.
  Clarified mental model: **click = toggle the walk circle + hotel
  highlighting** (unchanged); **both hover and click should show the
  same general + schedule info**, just via different UI (tooltip vs
  popup).
- Replaced the navy gradient tooltip with a **white card matching the
  existing popup's visual language** exactly (same border-radius, same
  text colors as `.popup-title`/`.popup-sub`) — so hover and click now
  look like the same design system, not two different ones. Added a
  thin colored left-accent stripe per marker type (airport blue, rail
  brown) for a touch of visual distinction without a jarring dark box.
- Replaced `formatHoverTooltip()` (which only ever showed the schedule
  snippet) with `buildInfoHTML()`, which renders the exact same
  title+note+hours structure as the click popup. Hover and click are
  now genuinely the same information, not two different subsets of it.
- Rail station tooltips now always show (previously only bound if
  `r.hours` existed) since every station has at least a `note` — every
  rail/airport marker now reliably shows something useful on hover.
- Verified via direct evaluation of `buildInfoHTML()` against real data
  before shipping.

### 2026-07-13 (cont'd, 13) — tooltip visual redesign
- User feedback: previous fix was technically correct but ugly — narrow,
  flat black box, poor reading experience. Full redesign, not just a
  tweak:
  - Background: flat black → soft navy-to-charcoal diagonal gradient
    (`#234e70 → #1b3a56 → #142a40`), reads as a "night sky/journey" feel
    that fits a transit app better than a stark black tooltip.
  - Width: 240px → 290px max, with a 180px minimum so short messages
    don't look cramped either.
  - Rounded corners bumped to 14px, softer/deeper drop shadow for a
    genuine floating-label feel instead of a flat rectangle.
  - Content now splits into a bold gold headline (e.g. "🕐 Departing
    Hongqiao") + a lighter body line below, via a new `formatHoverTooltip()`
    helper that splits the text at its first ": " if one exists early in
    the string. Falls back gracefully to a single styled line for
    railway-station texts that don't have a clean head/body split (none
    of them use a colon in the current data).
- Verified the formatting helper against real data directly (not just
  eyeballed) before shipping — confirmed both the split and no-split
  cases render correctly.

### 2026-07-13 (cont'd, 12) — fixed tooltip text not wrapping
- Different bug from the previous fix — that one was about *which* text
  showed, this one was about *how* it rendered. User's screenshot showed
  the hover tooltip as one long unbroken line, mostly spilling out past
  the dark background box as plain unstyled white text.
- **Root cause**: Leaflet's default `.leaflet-tooltip` CSS forces
  `white-space: nowrap`, which silently overrode my `max-width` setting
  — the text refused to wrap, so it just overflowed past the visible box
  instead of staying contained.
- **Fix**: added `white-space: normal !important` plus `word-wrap:
  break-word` to the tooltip CSS class, forcing proper wrapping
  regardless of Leaflet's own stylesheet. Also added border-radius and a
  drop shadow so the box reads as a clean floating label rather than a
  flat rectangle, and aligned both tooltip max-widths (rail + airport)
  to the same 240px so text wraps consistently across both.

### 2026-07-13 (cont'd, 11) — fixed confusing bidirectional airport tooltip
- User caught a real bug via screenshot: hovering PVG (Pudong) showed
  the *entire* Line 2 description, including "Toward Hongqiao end: last
  train ~11:47 PM..." — irrelevant noise about the opposite end of the
  line while looking at Pudong specifically. Root cause: airport tooltips
  were dynamically pulling the connector line's single bidirectional
  `firstLast` string (written to describe both ends of the line at
  once) and dumping the whole thing onto whichever airport was hovered.
- **Fix**: removed the `connectorLineId` line-lookup approach entirely.
  Each airport now has its own self-contained `hours` field, phrased
  from "departing this specific airport" — no other-endpoint information
  bleeds in. E.g. PVG now reads "Departing Pudong Airport: first ~6:00
  AM, last ~10:30 PM toward the city on Line 2" — nothing about Hongqiao.
- Double-checked railway station hover tooltips for the same bug class —
  confirmed clean. Those were always written per-station individually,
  never derived from a shared line description, so no fix was needed
  there. Mentioned this explicitly since the user's report named both
  features.
- Verified via full data evaluation that every connected airport (NRT,
  HND, PVG, SHA, LHR, JFK) now shows correctly-scoped text, and that the
  genuinely unconnected ones (Gatwick, LaGuardia, Newark) still fall back
  to their transit note as intended.

### 2026-07-13 (cont'd, 10)
- **Airports now treated identically to railway stations**: hover shows
  info with no click needed (subway first/last time if the airport
  connects to a mapped line, otherwise the transit note), click still
  toggles the walk circle + hotel highlighting as before. Added
  `connectorLineId` to each airport entry, pointing at the specific line
  whose `firstLast` data should surface:
  - Tokyo: NRT→skyliner, HND→monorail
  - Shanghai: both PVG and SHA→sh2 (explicit user request to confirm SHA
    wasn't missed — it wasn't, both were already wired, now upgraded to
    the hover treatment together)
  - London: LHR→piccadilly. Gatwick deliberately left without a
    connector — it has no Underground connection, so showing fabricated
    subway hours would be dishonest; its tooltip falls back to the
    National Rail transit note instead.
  - NYC: JFK→blueace (A/C/E). LaGuardia and Newark deliberately left
    without a connector for the same reason — neither has a direct
    subway line, so their tooltips show the transit note (bus/AirTrain
    info) rather than implying a train first/last time that doesn't
    apply to them.
- **Considered switching sightseeing pins to hover, decided against it.**
  Two reasons: (1) hover doesn't work reliably on touch screens — the
  first tap often just triggers the hover state, causing accidental
  double-taps, and this is a phone-first app; sightseeing pins also
  cluster much more tightly than rail/airport icons (e.g. Ueno Park's
  museums), making hover collision worse exactly where it'd be used
  most. (2) The existing zoom-level label system (labels appear ≥ zoom
  13) already solves the "quick glance without clicking" need that
  hover would address, while click-to-popup still does real work for
  sightseeing specifically (hours/rating/phone — richer than a rail
  station's hover text). Kept sightseeing on click; noted as an option
  to revisit only if the zoom-label threshold itself feels too high.

### 2026-07-13 (cont'd, 9) — exact schedule accuracy for airport/rail connectors
- **Airport circles now also turn hotels dark green**, matching the rail
  fix from earlier today. Simplified `hotelCircleStatus` — every circle
  kind (subway/rail/airport) now behaves identically. The subway-vs-
  airport light/dark distinction from the original design was removed at
  the user's request; one consistent rule now, less code too.
- **Real first/last train times added for the specific lines connecting
  to airports and railway stations** — user explicitly prioritized
  accuracy here over the general city-wide hours added yesterday.
  Researched and confirmed per line (sources vary slightly by day —
  presented as researched-but-verify, consistent with existing "not
  schedule-grade" disclaimers elsewhere in the app):
  - Tokyo Monorail (Haneda): first ~5:09 AM, last ~11:45 PM, same both
    directions
  - Keisei Skyliner (Narita): first ~6:00 AM (Ueno-bound) / ~7:25 AM
    (Narita-bound), last ~9:20 PM / ~10:30 PM — only 1 train per 20–40
    min, flagged as easy to miss
  - Shanghai Line 2: Pudong Airport end first ~6:00 AM/last ~10:30 PM;
    Hongqiao end last train ~11:47 PM Sun–Thu, ~12:57 AM Fri–Sat (later
    weekends — genuinely different by day, confirming the user's
    original question that yes, different routes/directions do vary)
  - London Piccadilly (Heathrow): first ~5:00 AM, last ~11:30 PM–12:30 AM
    Mon–Thu/Sun; genuine Night Tube Fri/Sat between Heathrow T2&3/T5 and
    Cockfosters (no T4 overnight)
  - NYC A/C/E (JFK) and N/Q/R/W (LaGuardia-adjacent via Astoria-Ditmars):
    honestly noted as having **no first/last train at all** — 24/7 system,
    just reduced frequency overnight
- Displayed in two places: a subtitle under the line's name in the
  sidebar (only for lines that have this data, so it doesn't clutter the
  ~85% of lines without it), and in that line's station popup on click.
- **Railway station hover tooltip added** (mouseover, not click) showing
  operating-hours info — explicitly scoped to railStations only, not
  airports, per the user's own read that airports don't need this.
  Mainline/HSR terminals (Shanghai's 3, London's King's Cross/Paddington,
  NYC's Penn/Grand Central) don't have a single "last train" the way
  metro lines do — represented honestly as station concourse hours +
  "trains depart all day on individual timetables" rather than
  fabricating one system-wide number that doesn't reflect how mainline
  rail actually works.
- Verified all new data with the full-evaluation method (actually running
  CITIES and checking real values) before shipping.

### 2026-07-13 (cont'd, 8)
- **Railway station circles now behave like subway circles**: hotels
  inside a railway station's walk circle turn dark green (previously
  only subway station circles did this; airport circles still stay light
  green, unchanged, since that distinction wasn't asked to change).
- **Added real subway/metro operating hours** per city, shown in the
  sidebar above the line toggles. Verified current before adding, since
  transit schedules do shift:
  - Tokyo: ~5:00 AM–12:00/1:00 AM, no overnight service
  - Shanghai: ~5:30/6:00 AM–10:30/11:00 PM, no overnight service
  - London: ~5:00 AM–12:00 AM Mon–Sat, but genuine Night Tube (all-night)
    Fri/Sat on Central, Jubilee, Northern & Piccadilly — all four are on
    our map, so this is a real usable fact, not trivia
  - New York: confirmed 24/7, every day — the only one of the four with
    no overnight closure at all

### 2026-07-13 (cont'd, 7) — New York City added
- Built New York as the fourth full city.
- **6 subway lines**, real official MTA colors: 4/5/6 (green), N/Q/R/W
  (yellow), A/C/E (blue), 1/2/3 (red), L (grey), 7 (purple). ~30 stations
  covering Manhattan core, Williamsburg (L), Queens/Flushing (7).
- **23 curated hotels** across 8 areas (Times Square, Penn Station, Grand
  Central, Financial District, Chelsea, Upper West Side, JFK, LaGuardia),
  all ≥4.0 applying the full pipeline. Real brand anchors throughout
  (Marriott Marquis, Hyatt, Westin, Hilton, Hotel Indigo). Genuine
  Hostelling International find again: HI New York City Hostel (4.4★,
  4,666 reviews) — same pattern as Shanghai's Blue Mountain Bund.
- **15 sights — first city where the real TripAdvisor top-15 needed zero
  local-flavor additions**, unlike Tokyo/Shanghai/London. All 15 ranked
  entries fit cleanly: Central Park, Met Museum, 9/11 Memorial, Empire
  State, Top of the Rock, High Line, Times Square, Statue of Liberty,
  Grand Central, Brooklyn Bridge, AMNH, NY Public Library, Chelsea
  Market, Staten Island Ferry, Rockefeller Center.
- **2 railway stations**: Penn Station (Amtrak/NJ Transit/LIRR) and Grand
  Central (Metro-North) — Grand Central deliberately appears as both a
  sight AND a rail station, same dual-role pattern as London's King's
  Cross.
- **3 airports, handled with real honesty about NYC's messy airport
  transit**: JFK connects via AirTrain transfer (not a one-seat ride —
  noted explicitly). **LaGuardia has zero rail connection** — confirmed
  via research that the AirTrain project was officially cancelled in
  2023; it's the only major East Coast airport without rail access.
  Represented this accurately: extended the N/W line to its real
  terminus (Astoria-Ditmars Blvd) as the closest subway approach, with
  the airport's transitNote explaining the bus transfer required, rather
  than pretending a subway line reaches the airport. Newark included
  too, clearly marked as requiring AirTrain + NJ Transit, not on the
  subway map shown.
- Caught and fixed a duplicate-closing-brace bug from my own edit mid-
  build (the insertion anchor was positioned before London/Shanghai in
  the file, so appending a full closing `};` after New York orphaned the
  rest of the CITIES object) — verified via full data evaluation before
  shipping, confirming London/Shanghai/Tokyo were untouched.

### 2026-07-13 (cont'd, 6) — swapped unranked entries for real ranked ones
- Full audit (previous entry) found ~6 unranked-but-real Tokyo entries and
  2 in Shanghai. User chose to swap for genuinely higher-ranked
  alternatives where a good swap existed, rather than just relabeling.
- **Tokyo**: removed Godzilla Head and Tokyo Night & Light (weakest
  justification — a novelty photo-op and a seasonal-only event). Added
  **Akihabara** (real #9) and **Ginza** (real #11) — both genuine
  TripAdvisor top-12 entries that were missing. Net: still 15 sights.
  Kept Imperial Palace East Gardens, Tokyo Metropolitan Government
  Building Observation Deck, Tsukiji Outer Market, and Omoide Yokocho —
  all real Places-verified locations, just not in the main numbered
  ranking; kept deliberately for variety (nature, free viewpoint, food
  market, nightlife alley) a pure top-12 list wouldn't cover.
- **Shanghai**: no swap made. Checked what would need to replace Jade
  Buddha Temple (#19) or Shanghai Tower (real, dedicated heavily-reviewed
  page, just not in the top-30 numbered list — likely filed under its own
  "Observation Decks & Towers" subcategory) — the actual top-15 gaps are
  a tailor shop (#2), Shanghai Disneyland 11mi outside the city (#8, same
  reason Tokyo Disneyland was excluded), a hotel (#9, not an attraction),
  and a 187-review new installation (#12). None improve on what's there,
  so nothing was changed. Documented explicitly so this isn't mistaken
  for an oversight later.

### 2026-07-13 (cont'd, 5) — Tokyo & Shanghai audited against real TripAdvisor rankings
- User asked directly whether Tokyo/Shanghai got the same TripAdvisor fix
  as London. Honest answer at the time was no — audited both properly.
- **Tokyo**: real ranking fetched directly. Found one meaningful error —
  had added "teamLab Borderless" (Azabudai Hills) when TripAdvisor's
  actual #3-ranked attraction is **teamLab Planets TOKYO** (Toyosu), a
  different exhibit entirely. Swapped to the correct one. Also added
  **Tokyo National Museum** (#12, missed originally). Tokyo now at 15
  sights, all traceable to the real ranking or otherwise well-justified
  (Omoide Yokocho, Godzilla Head, Tsukiji, Tokyo Night & Light are
  deliberate local-flavor additions beyond the top-12, not miscounted as
  ranked entries).
- **Shanghai**: real ranking fetched directly. Added 4 confirmed misses:
  Zhujiajiao Ancient Town (#5), Former French Concession (#7, anchored at
  Wukang Road), Tianzifang (#10), Shanghai World Financial Center (#13).
  Shanghai now at 13 sights.
- Both edits verified using the upgraded evaluation method (actually
  running the CITIES object and inspecting real field values), not just
  the parse-only syntax check — confirmed apostrophes and data intact
  before shipping.

### 2026-07-13 (cont'd, 4)
- **Process fix, prompted by user catching a real gap:** sightseeing was
  being picked via generic web search, which returns scattered snippets
  *about* TripAdvisor pages rather than the actual ranked list — this is
  why London's original 10 sights missed 3 genuine TripAdvisor top-10
  entries (Sky Garden #4, Natural History Museum #8, V&A #9) and why
  British Museum shipped with a clearly-wrong 3.5/79-review Places rating
  instead of its real 4.6/75,030. **Fix: directly `web_fetch` the actual
  TripAdvisor city attractions URL going forward**, which returns the
  real numbered ranking — confirmed working, now the standard method for
  every future city's sightseeing list.
- Added Sky Garden, Natural History Museum, V&A to London (13 sights
  total now); corrected British Museum's rating to the real 4.6.
- **Verification method upgraded.** While fixing this, chased what looked
  like a recurring double-backslash apostrophe bug — turned out to be a
  false alarm caused by misreading Python's byte-repr output (it always
  displays one literal backslash as two characters on screen, which I
  mistook for an actual double-backslash in the file). Real lesson from
  the detour: the `new Function(code)` syntax check used throughout this
  project only confirms code *parses* — it doesn't catch semantic bugs
  where broken syntax happens to still be valid JS (e.g. "Walkie-Talkie"
  silently parsing as a subtraction expression between two undefined
  variables). **New standard for verifying data edits going forward:
  actually evaluate the CITIES object and inspect real field values**
  (e.g. `CITIES.london.sights.map(s=>s.name)`), not just parse-check.

### 2026-07-13 (cont'd, 3) — London added
- Built London as the third full city, same rigor as Tokyo/Shanghai.
- **6 Underground lines**, real official TfL colors: Central (red),
  Piccadilly (dark blue — direct to Heathrow), Circle (yellow), District
  (green), Jubilee (grey), Northern (black). ~65 stations covering West
  End, South Kensington, King's Cross, Paddington corridor, Canary Wharf,
  Camden.
- **16 curated hotels** across 5 areas (Covent Garden, South Kensington,
  King's Cross St Pancras, Paddington, Heathrow Airport — 4 hotels
  covering different terminals given Heathrow's size), all ≥4.0 rating
  applying the full pipeline: brand anchors included (Hilton, Marriott/
  Curio Collection, Radisson, Premier Inn, Holiday Inn Express), budget
  tier present (The Z Hotel, hub by Premier Inn), price-tier spread
  intact. Star range 2★–5★.
- **10 sights**, cross-referenced against TripAdvisor's consensus list:
  Tower of London, British Museum, Westminster Abbey, Tower Bridge,
  London Eye, St Paul's Cathedral, Buckingham Palace, Houses of
  Parliament & Big Ben, Camden Market, Borough Market.
- **2 railway stations**: King's Cross St Pancras (Eurostar to Paris/
  Brussels/Amsterdam + East Coast Main Line) and Paddington (Elizabeth
  Line/Heathrow Express + Great Western main line) — London's two
  highest-value rail hubs given the Eurostar connection specifically.
- **2 airports**: Heathrow (direct via Piccadilly Line, shown on map) and
  Gatwick (honestly noted as National Rail only, not reachable via the
  Underground map shown).
- **Honest gaps**: no ≥4.0 budget (1–2★) option found near King's Cross
  or South Kensington in this pass — Premier Inn (3★) partially covers
  the King's Cross budget need, South Kensington has a real gap. Also:
  British Museum's Places rating came back as a clear data anomaly
  (3.5/79 reviews — implausible for one of the world's most-visited
  museums, likely matched a wrong sub-entity) — rating field left blank
  rather than publish a number known to be wrong.
- Caught and fixed the same apostrophe-escaping bug that hit Shanghai
  (double-backslash instead of single before apostrophes in station/
  hotel names) before it reached the user this time — now a known
  failure mode to check for on every new-city edit.

### 2026-07-13 (cont'd, 2)
- Checked for Hostelling International (HI/YHA) — the largest global
  nonprofit hostel network (2,500+ hostels, 60+ countries) — since named
  global brands weren't part of yesterday's generic "hostel"/"capsule
  hotel" search pass.
  - Tokyo (HI Tokyo Central YH, Iidabashi): 3.9 rating on 324 reviews —
    narrowly misses the 4.0 floor. Not added; the floor stays real.
  - Shanghai (Blue Mountain Bund Youth Hostel, HI-affiliated): 4.2 on 499
    reviews — clears the bar. Added to The Bund area (1★, tier 1).
- Process note for future curation passes: search named global budget
  brands (Hostelling International, Generator, A&O, Wombat's, St
  Christopher's Inns) explicitly in addition to generic category terms —
  generic searches surface local independent operators first and can
  miss recognizable international brands entirely.

### 2026-07-13 (cont'd)
- Executed the budget-tier curation discussed earlier: searched
  explicitly for hostels/capsule hotels/budget chains per area, held to
  the same 4.0+ rating / ≥100-review bar as everything else. Added 12 new
  real hotels: Sotetsu Fresa Inn Higashi-Shinjuku Ekimae (Shinjuku),
  Hostel Wasabi Asakusa, Wise Owl Hostels Shibuya + The Millennials
  Shibuya, Grids Tokyo Ueno Hotel & Hostel, VIA INN Higashi Ginza, Anshin
  Oyado Tokyo Akihabara Denkigaiten, House Ikebukuro + Sakura Hotel
  Ikebukuro, Apa Hotel & Resort Roppongi-Eki-Higashi, KEIKYU EX INN
  Haneda, Shanghai Fish Inn Bund.
- Star distribution is now real and usable: 4× 1★, 12× 2★, 31× 3★, 23×
  4★, 7× 5★ (77 hotels total) — the star filter chips added yesterday now
  have genuine budget options behind them, not an empty result.
- **Honest gaps, left as gaps rather than forced:** no 1–2★ hotel cleared
  the rating/volume floor in Hibiya, Shanghai People's Square, Shanghai
  Railway Station, Hongqiao Hub, or Pudong Airport, despite explicit
  searches. This is the `floorException` scenario the spec anticipated —
  logged here rather than silently lowering the bar to fill a slot.
- Updated `hotel-curation-pipeline-spec.md` Step 5 to explicitly require
  *searching* for budget-tier options (hostel/capsule/budget-chain search
  terms) rather than hoping they surface in a generic area search, which
  in practice skews toward brand-anchor and mid/upper hotels.

### 2026-07-13
- Discussed the 1–2★ filter gap: curated hotels currently skew 3–5★
  because curation passes have focused on brand anchors and well-reviewed
  mid/upper options, not because budget hotels can't meet the 4.0 rating
  floor (they can — Toyoko Inn Narita already proves it at 4.1/2★).
- Decision: proactively curate real budget-tier (1–2★) hotels for
  existing areas, same 4.0+/100-review bar as everything else. No
  fallback/live-search button for the zero-result edge case — considered
  and deliberately rejected as likely over-engineering for a rare
  intersection (rare filter choice × uncurated area). Plain text empty
  state stays, matching the pattern used everywhere else in the app.
  Budget-tier curation itself is still pending (not yet executed).
- Identified a real blind spot: the app has zero telemetry today, so
  "how often would that fallback button actually get used" is
  unanswerable from data — this is now logged as a concrete backend
  requirement in §6 (event logging, with an explicit China/Great Firewall
  caveat about analytics tool choice) so the decision can be revisited
  with real evidence once a backend exists, instead of staying a guess.

### 2026-07-12 (cont'd, 4)
- Removed the "Only show walkable hotels" toggle. Reasoning: it was a
  coarse, un-visualized duplicate of what the station/airport/rail
  circles already show precisely (dark green = confirmed within walk
  radius of that exact point). Kept the walk-time slider, since it still
  sizes the circles — only the redundant checkbox and its filtering
  logic were removed. One fewer control, no loss of real capability.

### 2026-07-12 (cont'd, 3)
- Added a multi-select star-tier filter (★1–★5 chips in the sidebar).
  Users can pick, e.g., "4★ and 5★ only" to match their budget. Defaults
  to no filter applied (all stars shown) so it's a pure opt-in, doesn't
  change default behavior for anyone who ignores it. Pinned hotels always
  bypass the filter, consistent with how pinning overrides other filters
  elsewhere in the app.

### 2026-07-12 (cont'd, 2)
- Raised the hotel rating floor from 3.7 to **4.0** guest rating (still
  requires ≥100 reviews). Re-audited all 69 hotels; 10 fell below the new
  floor. Found real ≥4.0 replacements for every single one — no exceptions
  needed anywhere:
  - Ebisu: swapped Prince Smart Inn (3.9) → TOKYU STAY Shibuya Ebisu (4.9)
  - Shanghai Railway Station: swapped Park Inn by Radisson (3.8, also
    flagged earlier for a rude-staff review pattern) → Courtyard by
    Marriott Shanghai Puxi (4.3) — also adds a brand anchor to this area
  - Pudong Airport: swapped Ramada (3.8) → Holiday Inn Express Shanghai
    Pudong Airport (4.0)
  - Ueno: swapped 4 sub-4.0 hotels for 3 real ≥4.5 alternatives (MIMARU
    Tokyo Ueno Okachimachi 4.9, MONday Apart Premium Ueno 4.6, hotel
    MONday Premium Ueno Okachimachi 4.5)
  - Ikebukuro/Shibuya/Shinjuku: simple removals (Centurion Hotel
    Ikebukuro, APA Hotel Shibuya Dogenzakaue, Shinjuku Washington Hotel)
    — each area already had 4+ solid ≥4.0 options.
  - Net: 69 → 65 hotels (some areas lost a redundant low performer
    without needing a replacement).
- Updated `hotel-curation-pipeline-spec.md`: rating floor raised to 4.0,
  added an explicit `floorException` exception clause for the rare case
  where no ≥4.0 option exists in an area (must be flagged in data, not
  silently included).

### 2026-07-12 (cont'd)
- Cross-referenced sightseeing lists against TripAdvisor's editorial "top
  things to do" consensus (names/rankings only — descriptions rewritten,
  no copyrighted text reproduced; each new entry backed by real Google
  Places data for hours/rating/phone).
- Added to Tokyo: teamLab Borderless (correctly placed at its current
  Azabudai Hills location, not the old Odaiba site), Shibuya Crossing,
  Tokyo Metropolitan Government Building Observation Deck (free, often
  missed), Tsukiji Outer Market, Ueno Park.
- Added to Shanghai: Nanjing Road Pedestrian Street, Xintiandi, Jade
  Buddha Temple.
- Tokyo now has 14 sightseeing entries, Shanghai has 9.

### 2026-07-12
- Renamed project from "tokyo-transit-planner" to **HopNest**.
- Set up private GitHub repo; uploaded `hopnest.html` +
  `hotel-curation-pipeline-spec.md`.
- Created this design document.
- Audited existing curated hotels against the new curation pipeline spec:
  - Removed Lavande Hotel (Shanghai Railway Station) — 4.0 rating on only
    4 reviews, failed new volume floor.
  - Added brand anchors: Hilton Tokyo (Shinjuku), Hyatt Centric Ginza,
    Hyatt House Tokyo Shibuya, Hilton Tokyo Narita Airport.
- Added curated (always-visible) hotels around Narita and Haneda airports
  — previously these relied on live search only.
- Fixed: airport/rail icon clicks now behave like subway stations (draw
  walk circle, trigger live search if uncurated); clicking elsewhere on
  the map clears open circles; clicking the same icon again clears just
  that circle.
- Added Shanghai coverage: 5 metro lines (1, 2, 4, 8, 10) with real
  official colors, Lujiazui as a named sightseeing landmark, 3 major
  railway stations (Shanghai Railway Station, Shanghai South, Hongqiao)
  as their own marker layer, curated hotels around both Shanghai airports
  and all three rail hubs.
- Extended Shanghai Line 2 to its real full route (Hongqiao Airport →
  Hongqiao Railway Station → central Shanghai → Pudong Airport); extended
  Line 1 to Shanghai South Railway Station.
- Added Tokyo Monorail (Haneda access) and Keisei Skyliner (Narita
  access) as real airport-connecting subway-style lines.
- Added official star classification (`stars`, 1–5) to all 42 existing
  Tokyo hotels + 10 Shanghai hotels, kept explicitly separate from Google
  guest rating.
- Wrote `hotel-curation-pipeline-spec.md`: the full hotel-selection logic
  (area tiers, brand-anchor weighting, review volume floor, disqualifier
  patterns, price-tier spread, refresh cadence) for a future automated
  monthly-refresh pipeline.

### Earlier work (pre-dating this document, reconstructed from conversation)
- Built initial Tokyo prototype: Yamanote/Ginza/Marunouchi/Hibiya/Ōedo/
  Chiyoda lines, 25 curated hotels across 5 neighborhoods, 9 sightseeing
  spots, Narita/Haneda airport markers, city-picker architecture.
- Added pinning, price tiers, click-to-toggle walk circles, live-search
  fallback for uncurated stations, multi-city data schema.
