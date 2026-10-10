# HopNest — Launch Cost & Financial Plan
*Written 2026-07-13. All figures sourced during real conversations with Claude,
each with its own research date noted — re-verify anything time-sensitive
before actually committing money, since pricing pages change.*

This document exists to answer one question when you're ready to launch:
**what actually costs money, how much, and — critically — *when* does each
cost actually start?** Most of what follows is $0 until you deliberately
flip a specific switch. Nothing here is a recurring cost today.

---

## 1. The one-time / fixed costs

| Item | Cost | Notes |
|---|---|---|
| Domain name (.com or .app) | ~$10–20/year | Typical registrar pricing (Namecheap/Cloudflare/GoDaddy) — check exact price at purchase, short catchy names sometimes get squatted/marked up |
| Apple Developer Program (if App Store) | $99/year | Required to submit to the iOS App Store, recurring annually |
| Google Play Developer registration (if Android) | ~$25 one-time | Long-standing flat fee, verify current amount before paying |

**None of these are needed yet.** Domain only matters once you're hosting for
real (Stage 1 of the launch plan). App store fees only matter for Stage 3
(App Store submission) — which we deliberately agreed to defer until after
real usage validates the idea via Stages 1–2.

---

## 2. Hosting (getting the site actually live)

| Option | Cost | Catch |
|---|---|---|
| GitHub Pages | Free | Requires a **public** repo — anyone can browse your commit history |
| Netlify or Vercel | Free tier | Can deploy from a **private** repo — keeps history hidden, same free live URL |

**Decided 2026-10-09: GitHub Pages** (repo made public; live at
https://daewoogao.github.io/HopNest/, see design doc §7). This replaced
the 2026-10-07 Cloudflare Pages plan. Earlier note:
Netlify/Vercel if repo privacy
matters to you; GitHub Pages if you're fine going public (repo privacy
doesn't protect the *live site's* code either way — that's inherent to how
browsers work, not a GitHub-specific tradeoff).

**Cost today: $0, either way.**

---

## 2b. Map tiles (the map images themselves)
*Added 2026-09-29 — missing from the original plan.*

The app currently loads map images from OpenStreetMap's own public tile
server. That's fine for a prototype, but its usage policy isn't meant for
a real public website with steady traffic, and it can block sites that
lean on it. **Before launch, switch to a tile provider.**

| Option | Cost | Notes |
|---|---|---|
| MapTiler / Stadia Maps / Thunderforest | Free tier to start | Each has a free tier sized for small sites, then paid plans by traffic. Exact limits and prices not researched here — compare at decision time. |

The switch itself is a one-line change in `site/index.html` (the tile
URL) plus an API key. Unlike the Anthropic key, tile keys are designed to
sit in browser code, and are locked to your domain in the provider's
dashboard.

**Cost today: $0.** Likely $0 at launch on a free tier; grows with traffic,
like live search.

---

## 3. Hotel/sightseeing data — what's free vs. what costs money

**Everything curated so far (all 5 cities, ~150 hotels, ~70 sights) was
effectively free** — it came from Claude's own Places-search tool during our
conversations, covered by your existing Claude subscription, not a separate
Google bill.

**Where real cost begins: keeping that data fresh automatically, forever,**
once there's no one manually re-curating it in chat. This requires an actual
backend calling Google's Places API on a schedule.

**Researched cost (2026-07-13), at full 150-city scale:**
- Flat monthly refresh, every city, full field richness: **~$2,100–2,400/mo**
  (this was a *corrected* figure — an earlier, wrong estimate said $35–75/mo,
  which under-scoped both city count and how expensive the rating/review
  fields specifically are at Google's pricing tiers)
- **Tiered refresh (recommended)** — top 10–20 highest-traffic cities
  monthly, the long tail quarterly instead: **~$700–1,200/mo**

**At your actual current scale (5 cities, not 150):** proportionally far
lower — rough scaling suggests **~$25–40/month** for a tiered refresh of
just Tokyo/Shanghai/London/NYC/Barcelona, though this hasn't been
independently re-derived at 5-city scale specifically and should be
recalculated properly once you're ready to build the backend, not assumed
from linear scaling of the 150-city number.

**Cost today: $0.** This entire section only activates once the automated
refresh backend actually exists — which doesn't exist yet.

---

## 4. Live search (the "search any hotel/station not in our curated list" feature)

**Right now: $0, but also only works inside Claude's own preview** —
authenticated automatically by that environment, not something you're
billed for, but also not something that survives once this is a real
launched site.

**Once a real backend exists with its own Anthropic API key, this becomes a
real per-use cost:**
- ~$10 per 1,000 web searches + normal token cost ≈ **1–2¢ per lookup**
- Two triggers feed this same cost: clicking an uncurated station/airport
  circle, and searching a hotel name not in the curated list
- Scales with **actual user traffic**, not city count — a structurally
  different growth curve than the data-refresh cost above. At real scale
  (thousands of monthly active users), this could become the *larger* of
  the two costs, not the smaller one — worth watching once there's real
  traffic to measure (see the analytics section below).

**Realistic early estimate:** a few hundred fallback lookups/month across a
small friends-and-family user base ≈ **a few dollars/month.**

**Cost today: $0.** Also gated behind the backend existing.

---

## 5. Trust circles / shared trip collaboration (Supabase)

Researched 2026-07-13, current published rates:

| Tier | Cost | What it covers |
|---|---|---|
| Free | $0/month | Real Postgres DB (500 MB), 50,000 monthly active users, 200 real-time connections, 1 GB file storage |
| Pro | $25/month | 8 GB DB, 100K MAU, backups, higher real-time connection limit |

**The free tier is genuinely enough to start with** — a shared trip (pinned
hotels/sights, a circle code, who's in which circle) is tiny data, nowhere
near the 500 MB free limit even with real usage.

**One real catch on Free:** projects auto-pause after 7 days of zero
activity — fine for a friends-and-family tool, just means the first visit
after a quiet stretch takes a few extra seconds to spin back up.

**When to upgrade to Pro ($25/mo):** once real, frequent usage exists —
not before. Turn on the "Spend Cap" (on by default) to avoid surprise
overage billing.

**Cost today: $0**, and likely $0 for a good while into real usage.

---

## 6. Usage/event logging (analytics)

Not yet built, flagged earlier as a real gap (the app currently has zero
telemetry — impossible to answer "how often does X happen" without it).

- **Avoid Google Analytics specifically** — blocked in mainland China
  without a VPN, which would silently lose data from Shanghai visitors,
  exactly the market with the most curation investment.
- **Self-hosted alternatives (Plausible/Umami)**: free if self-hosted on
  infrastructure you already have (e.g., alongside the backend once it
  exists); their hosted cloud versions typically run a modest monthly fee
  (verify current pricing at decision time — not independently re-checked
  as part of this document).

**Cost today: $0.** Not yet built; bundle this in whenever the backend gets
built, since it's cheap to add at that point and expensive to bolt on later
without losing historical data.

---

## 7. Summary — what triggers each cost

| Cost | Today | Trigger that turns it on |
|---|---|---|
| Domain | $0 | Deciding to actually launch (Stage 1) |
| Hosting | $0 forever | N/A — free tier is sufficient indefinitely at this scale |
| Map tiles | $0 | Required switch before launch; free tier likely covers early traffic, paid tiers scale with traffic |
| Data refresh pipeline | $0 | Building the backend + choosing to automate refresh |
| Live search | $0 | Building the backend (same one, reused) |
| Trust circles | $0 | Building the backend (same one, reused) — likely stays $0 on Supabase Free even after |
| Analytics | $0 | Building the backend (same one, reused) |
| Apple Developer | $0 | Deciding to submit to the App Store (Stage 3, deliberately deferred) |

**The honest bottom line:** almost every real cost in this app is gated
behind **one decision — building the backend.** Everything before that
point (where you are right now) costs nothing beyond your existing Claude
subscription. Once you do build it, the backend itself unlocks the data
refresh, live search, trust circles, *and* analytics simultaneously — it's
one investment that pays for four features, not four separate projects.
