#!/usr/bin/env node
// Pull a city's subway lines and stations from OpenStreetMap (Overpass API)
// into HopNest's `lines` format. Run once per city (and yearly / on network
// changes, per the curation spec §3), review, then paste into
// site/data/<city>.json. The app never calls OpenStreetMap itself.
//
//   node scripts/osm-lines.js "<south>,<west>,<north>,<east>" [--types subway,light_rail] [--out file.json]
//   e.g. node scripts/osm-lines.js "48.80,2.22,48.92,2.47" --out paris-lines.json
//
// Data © OpenStreetMap contributors, ODbL. Needs Node 18+ (built-in fetch).
const fs = require('fs');
const { formatJson } = require('./format-json');

const args = process.argv.slice(2);
const bbox = args[0];
if (!bbox || !/^-?[\d.]+,-?[\d.]+,-?[\d.]+,-?[\d.]+$/.test(bbox)) {
  console.error('Usage: node scripts/osm-lines.js "<south>,<west>,<north>,<east>" [--types subway,light_rail] [--out file.json]');
  process.exit(1);
}
const opt = name => { const i = args.indexOf(name); return i > 0 ? args[i + 1] : null; };
const types = (opt('--types') || 'subway').split(',');
const outFile = opt('--out');
const ENDPOINT = process.env.OVERPASS_URL || 'https://overpass-api.de/api/interpreter';

const query = `[out:json][timeout:120];
(${types.map(t => `relation["type"="route"]["route"="${t}"](${bbox});`).join('')})->.routes;
.routes out body;
node(r.routes);
out body;
rel(br.routes)["type"="route_master"];
out body;`;

const STOP_ROLES = new Set(['stop', 'stop_entry_only', 'stop_exit_only', 'platform', 'platform_entry_only', 'platform_exit_only']);
const slug = s => s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
const round = n => Math.round(n * 1e4) / 1e4; // ~11 m, same precision as existing data

(async () => {
  // Overpass is a free shared service: retry busy/timeout answers, then
  // try a second public instance.
  const endpoints = [ENDPOINT, 'https://overpass.private.coffee/api/interpreter'];
  let res, lastErr;
  for (let attempt = 0; attempt < 6 && !res; attempt++) {
    const url = endpoints[attempt % endpoints.length];
    try {
      const r = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'User-Agent': 'HopNest data script (github.com/daewoogao/HopNest)' },
        body: 'data=' + encodeURIComponent(query),
      });
      if (r.ok) { res = r; break; }
      lastErr = `${url} answered ${r.status}: ${(await r.text()).slice(0, 200)}`;
    } catch (e) { lastErr = `${url}: ${e.message}`; }
    console.error(`  attempt ${attempt + 1} failed (${lastErr}), retrying`);
    await new Promise(ok => setTimeout(ok, 5000 * (attempt + 1)));
  }
  if (!res) throw new Error('Overpass unavailable: ' + lastErr);
  const { elements } = await res.json();
  const nodes = new Map(elements.filter(e => e.type === 'node').map(e => [e.id, e]));
  const routes = elements.filter(e => e.type === 'relation' && e.tags.type === 'route');
  const masters = elements.filter(e => e.type === 'relation' && e.tags.type === 'route_master');
  const masterOf = new Map();
  masters.forEach(m => m.members.forEach(mem => masterOf.set(mem.ref, m)));

  // One HopNest line per route_master (or per ref when there is none); keep
  // the variant with the most stops and report the rest for a manual look,
  // since branches (e.g. a Y-shaped line) need hand-splitting.
  const groups = new Map();
  for (const r of routes) {
    const m = masterOf.get(r.id);
    const key = m ? 'm' + m.id : 'r' + (r.tags.ref || r.tags.name || r.id);
    const stations = [];
    for (const mem of r.members) {
      if (mem.type !== 'node' || !STOP_ROLES.has(mem.role)) continue;
      const n = nodes.get(mem.ref);
      if (!n || !n.tags) continue;
      const name = n.tags['name:en'] || n.tags.name;
      if (!name) continue;
      // stop position and platform of the same station often both appear
      if (stations.length && stations[stations.length - 1][0] === name) continue;
      stations.push([name, round(n.lat), round(n.lon)]);
    }
    const g = groups.get(key) || { master: m, variants: [] };
    g.variants.push({ r, stations });
    groups.set(key, g);
  }

  const lines = [], notes = [];
  for (const { master, variants } of groups.values()) {
    variants.sort((a, b) => b.stations.length - a.stations.length);
    const best = variants[0];
    const t = { ...best.r.tags, ...(master ? master.tags : {}) };
    const ref = t.ref || '';
    if (best.stations.length < 2) { notes.push(`${t.name || ref}: fewer than 2 named stops (under construction?), skipped; OSM relation r${best.r.id}`); continue; }
    // names often carry the termini ("Ligne 1 : A ↔ B"); keep the part
    // before the colon, from the route_master if there is one, else "Line <ref>"
    const mName = master && (master.tags['name:en'] || master.tags.name || '').split(/\s*:\s*/)[0];
    const name = mName || (ref ? `Line ${ref}` : (t['name:en'] || t.name || 'Line'));
    const color = (t.colour || t.color || '').toUpperCase();
    lines.push({
      id: 'l' + (slug(ref || name) || lines.length),
      name,
      ...(master && master.tags.name && master.tags['name:en'] && master.tags.name !== master.tags['name:en'] ? { jp: master.tags.name.split(/\s*:\s*/)[0] } : {}),
      color: /^#[0-9A-F]{6}$/.test(color) ? color : '#888888',
      code: ref,
      stations: best.stations,
    });
    if (!/^#[0-9A-F]{6}$/.test(color)) notes.push(`${name}: no colour tag in OSM, set the official color by hand`);
    const longer = variants.slice(1).filter(v => v.stations.some(s => !best.stations.some(b => b[0] === s[0])));
    if (longer.length) notes.push(`${name}: ${longer.length} other variant(s) with stations not on the main one (branch?), check by hand`);
  }
  lines.sort((a, b) => a.code.localeCompare(b.code, undefined, { numeric: true }));

  const out = formatJson(lines);
  if (outFile) fs.writeFileSync(outFile, out + '\n'); else console.log(out);
  console.error(`${lines.length} lines, ${lines.reduce((a, l) => a + l.stations.length, 0)} stations`);
  notes.forEach(n => console.error('  check: ' + n));
})().catch(e => { console.error(e.message); process.exit(1); });
