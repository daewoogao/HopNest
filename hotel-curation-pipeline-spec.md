# Hotel Curation Pipeline Spec
### Transit Trip Planner — monthly data refresh

This document defines how the automated pipeline selects which hotels appear
in the app, encoding the manual curation logic so a script can apply it
consistently across every city. Written to be handed to whoever implements
the batch-refresh script (Node/Python + Google Places API).

---

## 1. Where to curate (area selection)

Priority tiers — the pipeline processes areas in this order:

| Tier | Areas | Rule |
|---|---|---|
| 1 | Every airport; every major intercity rail hub (HSR/Shinkansen/national rail) | ALWAYS curated. Non-negotiable. Arrival friction, not tourism appeal. |
| 2 | Interchange stations where 3+ metro lines meet; the 1–2 guidebook-consensus districts | Curate top 3–5 hubs per city. |
| 3 | Secondary tourist/business districts | Curate only on demand. |
| 4 | Everything else | Not pre-curated. Covered by on-demand lookup (or left empty). |

## 2. How to pick hotels within an area (selection filters, in order)

Applied as a sequential funnel per area:

### Step 1 — Distance (hard filter)
- Within walk radius of the anchor point: **800 m** (≈10 min at 80 m/min).
- Airports: prefer "terminal-connected" or "free shuttle" over raw distance.
  If Places data shows the hotel inside airport grounds, it passes regardless
  of straight-line distance quirks.
- **Straight-line distance can lie — check for physical barriers.**
  Two anchor points that look close on a map can still be unwalkable if a
  river, highway, or rail yard sits between them with no pedestrian
  crossing nearby (real example: Shanghai's Lujiazui and The Bund look
  adjacent but sit on opposite banks of the Huangpu River with no
  walking bridge — grouping them as one area was a real error caught
  during curation, not a hypothetical). When in doubt, treat them as
  separate areas rather than assuming walkability from proximity alone.

### Step 2 — Brand anchor (HIGH priority — apply before rating sort)
- Each curated area MUST include at least one internationally recognized
  Western/global brand where one exists in radius: Hilton, Hyatt, Marriott,
  IHG (Holiday Inn/Indigo/InterContinental), Accor (Mercure/Sofitel/Novotel/ibis),
  Radisson, Wyndham, Best Western, Langham, Shangri-La, Kempinski.
- Rationale: brand recognition materially reduces booking anxiety for
  Western travelers — weight this ABOVE marginal rating differences.
  A 4.1 Hilton beats a 4.4 unknown local property for the anchor slot.
- If NO qualifying brand exists in radius (e.g. Asakusa, Tokyo): note the gap
  in the data (`brandAnchor: false` on the area) — do not stretch the radius
  to force one.

### Step 3 — Rating floor with volume check
- Guest rating ≥ **4.0** **AND** review count ≥ 100.
- Review count under 100 → EXCLUDE regardless of score (a 4.9 with 4 reviews
  is statistically meaningless). Exception: newly opened properties of
  qualifying brands (Step 2) may pass with ≥ 25 reviews.
- Prefer higher review volume when scores are within 0.2 of each other.
- **Exception clause:** if an area genuinely has no hotel ≥ 4.0 within the
  walk radius (checked by searching, not assumed), the highest-rated
  available option may be used instead — but must be explicitly flagged
  as an exception in the data (`floorException: true`) rather than
  silently included. In practice this should be rare: broader searches
  (chains, extended-stay brands, apartment-hotels) almost always surface
  a ≥4.0 option once the search isn't limited to the first handful of
  results.

### Step 4 — Review-content disqualifiers (scan recent reviews)
Exclude if recent reviews show repeated patterns of:
- Location pin wrong / "not where the map says" (fatal for a map app)
- Discriminatory staff behavior reported by multiple reviewers
- Mold / hygiene failures mentioned in 3+ recent reviews
- "Permanently closed" or renovation-shutdown signals
Single bad reviews do NOT disqualify; look for patterns (3+ mentions).

### Step 5 — Price-tier spread (composition rule)
Final set per area must include, where inventory allows:
- ≥ 1 budget (tier 1–2 / 1–2★) — hostels, capsule hotels, budget chains.
  Explicitly search for these (terms like "hostel", "capsule hotel",
  "budget hotel") rather than relying on them surfacing in a generic
  search, which tends to skew toward brand-anchor and mid/upper options.
- ≥ 2 mid-range (tier 2–3)
- ≥ 1 upper (tier 3–4)
Never ship an all-luxury or all-budget list.
If NO 1–2★ option in radius clears the Step 3 rating/volume floor after a
genuine search: leave the gap rather than lowering the bar, and note it
(see §7 in the design doc's gap tracking).

### Step 6 — Cap
- 3–5 hotels per area. The product is a trustworthy shortlist, not a directory.
- If more than 5 pass all filters: keep the brand anchor + highest
  review-volume representatives of each price tier.

## 3. Refresh cadence

| Data | Cadence |
|---|---|
| Subway lines/stations/colors | Yearly, or on announced network change |
| Hotels (list, rating, price tier) | Monthly |
| Sightseeing (hours, ratings) | Monthly |
| Airports / rail hubs | Yearly |

## 4. Freshness guard (recommended addition)
- Flag any hotel whose trailing-90-day average rating is ≥ 0.5 below its
  lifetime average → hold for manual review before republishing.
- Auto-drop any hotel Places marks CLOSED_PERMANENTLY.

## 5. Output format
Pipeline writes one JSON file per city matching the app's CITIES schema:
```
{ name, country, flag, center, zoom,
  lines:   [{ id, name, jp?, color, code, stations: [[name,lat,lng],...] }],
  hotels:  [{ name, lat, lng, area, rating, ratingCount, stars, priceTier,
              phone?, curated, brandAnchor? }],
  sights:  [{ name, lat, lng, note, hours?, rating?, phone? }],
  railStations: [{ name, lat, lng, note }],
  airports:[{ name, code, lat, lng, transitNote }] }
```
Notes:
- `stars` = official/typical property class (1–5), distinct from `rating`
  (guest review average). Populate from brand tier / booking-site class,
  never from the guest rating.
- `ratingCount` should be stored going forward (added to schema) so the
  volume filter is auditable.
- `curated: false` marks click-to-reveal areas (Tier 3).

## 6. Cost guardrails
- One Nearby Search + details per anchor point per refresh, cached.
- Never call Places per user click in production; serve from the JSON.
- Estimated volume at monthly cadence, ~150 cities × ~30 anchors ≈ 6k
  requests/month (within or near Places free threshold as of mid-2026 —
  re-verify pricing before launch, Google has changed it twice recently).

## 7. Data consistency rules (added after a real bug, 2026-07-13)
A user audit found several airports/stations showing "0 curated hotels"
that actually had real hotels — mislabeled with a shorthand `area` name
that didn't exactly match the official station/airport name string. This
silently broke the app's own live-search-skip check too (exact string
match), causing wasted live-search calls on already-covered spots.
**Rules to prevent recurrence:**
- **`area` must be the exact, official name string** of the
  `railStations`/`airports` entry it represents — copy it verbatim, never
  a shorthand (`'JFK Airport'` is wrong if the airport object's `name` is
  `'John F. Kennedy International Airport'`; use the real one).
- **Shared-hub exception**: when an airport and a railway station
  physically share one hub (e.g. Shanghai Hongqiao), hotels only need to
  be labeled under ONE of the two exact names — the app's matching logic
  is spatial as a fallback (any curated hotel within the walk radius of
  a clicked point counts as coverage, regardless of its exact `area`
  string), so this does not need duplicate-tagging. Confirmed via the
  `maybeFetchLiveHotels()` fix in the main app — this is an app-logic
  guarantee, not just a data-entry convention, so it holds even if a
  future curator forgets this rule.
- **Pre-ship checklist for every new city**: before considering a city
  "done," run a coverage audit — for every entry in `airports` and
  `railStations`, count hotels where `h.area === (that entry's exact
  name)`. Any zero count is either a real gap (research and fill it, or
  document explicitly why nothing qualifies) or a naming mismatch (fix
  the label). Never ship a city without running this check at least
  once — it takes one script, and it already caught 5 real mislabels
  and 3 real gaps across cities that had each individually seemed
  "done" beforehand.
