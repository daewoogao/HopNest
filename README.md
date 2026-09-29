# HopNest

**Subway + hotels + sightseeing on one map, city by city.**

Planning where to stay usually means juggling a subway map, a booking site, a
sightseeing guide, and a generic map to guess whether any of it connects.
HopNest puts all of it on one screen to answer one question well:

> *Given where I want to be, what's actually nearby and trustworthy?*

## Cities

| City | Status |
|---|---|
| 🇯🇵 Tokyo | Available |
| 🇨🇳 Shanghai | Available |
| 🇺🇸 New York City | Available |
| 🇬🇧 London | Available |
| 🇪🇸 Barcelona | Available |
| 🇫🇷 Paris | Coming soon |

## Features

- **Real subway maps.** Official line colors, and each line can be toggled on or off.
- **Walkability at a tap.** Tap any subway station, airport or rail hub to draw
  a walking-radius circle (5–20 min, adjustable). Hotels inside the circle
  are highlighted.
- **Curated hotel shortlists, not directories.** 3–5 hand-vetted hotels per
  busy area. Each has a rating of 4.0 or higher backed by enough reviews to
  trust, and each area covers budget through luxury with at least one
  recognizable brand.
- **Star-class filter.** Narrow hotels by official star tier, separately from
  the guest rating.
- **TripAdvisor-vetted sightseeing.** Shown on the same map, with opening hours,
  ratings, official ticket links, and a flag for places that book up.
- **First and last train times** for airport and intercity rail links.
- **Real fare information** for all five cities.
- **Search by name.** If a place isn't in the curated list, HopNest can
  live-search the web for it (see [Limitations](#known-limitations)).
- **Pins and shareable trip links.** Pin hotels and sights while you compare.
  Pins survive a reload, and the **🔗 Share my pinned picks** button turns
  everything you've pinned into one link. No account needed.
- **Installable.** "Add to Home Screen" on iOS or Android opens HopNest
  full-screen with its own icon.

## Running it

HopNest is a single HTML file with no build step and no server.

```bash
open hopnest.html
```

To test **Add to Home Screen**, the files need to be served over HTTP rather
than opened as a local file:

```bash
python3 -m http.server 8000
# then visit http://localhost:8000/hopnest.html
```

## Project structure

| File | What it is |
|---|---|
| `hopnest.html` | The whole app: map, data, UI and logic |
| `manifest.json` | PWA manifest (app name, icons, theme color) |
| `icon-192.png`, `icon-512.png` | Android and Chrome install icons |
| `apple-touch-icon.png` | iOS home-screen icon (180×180) |
| `design-document.md` | Living design doc: architecture, features, roadmap and a dated changelog |
| `hotel-curation-pipeline-spec.md` | The rules for choosing which hotels appear, written for a future automated refresh script |

## How it's built

- **Map:** [Leaflet](https://leafletjs.com/) 1.9.4 with OpenStreetMap tiles,
  loaded from a CDN.
- **Data:** a single `CITIES` object in `hopnest.html`. Each city holds its
  subway lines, hotels, sights, rail stations and airports. Adding a city
  means adding one entry of the same shape; no rendering code changes:

  ```js
  cityId: {
    name, country, flag, center: [lat, lng], zoom,
    lines:        [{ id, name, color, code, stations: [[name, lat, lng], ...] }],
    hotels:       [{ name, lat, lng, area, rating, stars, priceTier, curated, ... }],
    sights:       [{ name, lat, lng, note, hours, rating, ticketUrl, ... }],
    railStations: [{ name, lat, lng, note }],
    airports:     [{ name, code, lat, lng, transitNote }]
  }
  ```

- **Storage:** pins and the last-viewed city are saved in the browser's
  `localStorage`. There's no backend or database.

## Hotel curation

The shortlist logic is spelled out in
[`hotel-curation-pipeline-spec.md`](hotel-curation-pipeline-spec.md). In short:

1. **Areas are curated in priority order.** Airports and major rail hubs
   always come first, then major interchange stations and well-known
   districts.
2. **Hotels must be within about 800 m (roughly a 10-minute walk)** of the
   anchor point. Real barriers like rivers and highways count, not just
   straight-line distance.
3. **At least one recognizable brand** (Hilton, Hyatt, IHG, and so on) per
   area, weighted above raw rating.
4. **A review-volume floor of 100+ reviews**, a spread of price tiers, and a
   cap of 3–5 hotels per area.

## Known limitations

- **Subway paths are simplified.** They're hand-placed, not taken from a live
  transit feed (GTFS/ODPT).
- **Hotel prices are estimates.** Price tiers are static, not live bookable
  rates.
- **Live web search only works inside Claude's artifact viewer.** It relies on
  that environment's authenticated API access. A standalone copy has no API
  key, so live search won't work there.
- **Coverage is still growing.** Not every station has curated hotels yet.

## Roadmap

See `design-document.md` §6. Highlights:

- A real backend using the Google Places API for reliable, regularly refreshed
  hotel data.
- Privacy-respecting usage analytics (self-hosted, so it also works in
  mainland China).
- Offline support through a service worker.
- More cities, starting with Paris.
