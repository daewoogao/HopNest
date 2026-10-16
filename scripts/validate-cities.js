#!/usr/bin/env node
// Checks every city in site/data/ before it ships:
//   - format: required fields, types, coordinates near the city center
//   - coverage audit (curation spec §7): every airport and rail station has
//     hotels labeled with its exact name, or at least one within walk radius
//   - sight ticket links point at official sites, not resellers (design doc §4)
// Errors fail (exit 1); warnings are things to look at or document.
//   node scripts/validate-cities.js            all cities
//   node scripts/validate-cities.js paris      one city
const fs = require('fs');
const path = require('path');

const DATA = path.join(__dirname, '..', 'site', 'data');
const WALK_RADIUS_M = 800; // curation spec §2 step 1
const MAX_FROM_CENTER_KM = 80; // airports can sit far out (e.g. Narita ~60 km)
const RESELLERS = /klook|viator|getyourguide|tiqets|tripadvisor|musement|headout|civitatis/i;

const haversineM = (a, b, c, d) => {
  const r = x => x * Math.PI / 180, R = 6371000;
  const h = Math.sin(r(c - a) / 2) ** 2 + Math.cos(r(a)) * Math.cos(r(c)) * Math.sin(r(d - b) / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
};
const isNum = v => typeof v === 'number' && Number.isFinite(v);
const isStr = v => typeof v === 'string' && v.trim() !== '';

const index = JSON.parse(fs.readFileSync(path.join(DATA, 'cities.json'), 'utf8'));
const only = process.argv[2];
let errors = 0, warnings = 0;

for (const [id, meta] of Object.entries(index)) {
  if (only && id !== only) continue;
  if (!isStr(meta.name) || !isStr(meta.country) || !isStr(meta.flag)) report('error', id, 'cities.json entry needs name, country and flag');
  if (meta.comingSoon) continue;
  const file = path.join(DATA, id + '.json');
  if (!fs.existsSync(file)) { report('error', id, `missing site/data/${id}.json`); continue; }
  let c;
  try { c = JSON.parse(fs.readFileSync(file, 'utf8')); } catch (e) { report('error', id, 'not valid JSON: ' + e.message); continue; }
  checkCity(id, c, meta);
}
if (only && !index[only]) report('error', only, 'not listed in site/data/cities.json');
console.log(`\n${errors} error(s), ${warnings} warning(s)`);
process.exit(errors ? 1 : 0);

function report(level, city, msg) {
  if (level === 'error') errors++; else warnings++;
  console.log(`${level === 'error' ? 'ERROR' : 'warn '} [${city}] ${msg}`);
}

function checkCity(id, c, meta) {
  const err = m => report('error', id, m), warn = m => report('warn', id, m);
  if (c.name !== meta.name) warn(`name "${c.name}" differs from cities.json "${meta.name}"`);
  if (!Array.isArray(c.center) || c.center.length !== 2 || !c.center.every(isNum)) return err('center must be [lat,lng]');
  if (!isNum(c.zoom)) err('zoom must be a number');
  const near = (lat, lng, what) => {
    if (!isNum(lat) || !isNum(lng)) return err(`${what}: lat/lng must be numbers`), false;
    const km = haversineM(c.center[0], c.center[1], lat, lng) / 1000;
    if (km > MAX_FROM_CENTER_KM) err(`${what}: ${km.toFixed(0)} km from the city center (swapped lat/lng?)`);
    return true;
  };

  // lines
  if (!Array.isArray(c.lines) || !c.lines.length) err('needs at least one line');
  const lineIds = new Set();
  for (const l of c.lines || []) {
    const w = `line ${l.id || l.name}`;
    if (!isStr(l.id) || !isStr(l.name)) err(`${w}: needs id and name`);
    if (lineIds.has(l.id)) err(`${w}: duplicate line id`);
    lineIds.add(l.id);
    if (!/^#[0-9A-Fa-f]{6}$/.test(l.color || '')) err(`${w}: color must be #RRGGBB`);
    if (l.color && l.color.toUpperCase() === '#888888') warn(`${w}: placeholder grey color, set the official one`);
    if (!Array.isArray(l.stations) || l.stations.length < 2) { err(`${w}: needs 2+ stations`); continue; }
    l.stations.forEach((s, i) => {
      if (!Array.isArray(s) || s.length !== 3 || !isStr(s[0])) return err(`${w}: station ${i} must be [name,lat,lng]`);
      near(s[1], s[2], `${w} / ${s[0]}`);
    });
    // a jump this big between consecutive stations is usually a misplaced
    // point, except on simplified airport links (stops skipped on purpose)
    const atAirport = s => (c.airports || []).some(a => haversineM(a.lat, a.lng, s[1], s[2]) < 3000);
    for (let i = 1; i < l.stations.length; i++) {
      const [a, b] = [l.stations[i - 1], l.stations[i]];
      const km = haversineM(a[1], a[2], b[1], b[2]) / 1000;
      if (km > 15 && !l.stations.some(atAirport)) warn(`${w}: ${a[0]} → ${b[0]} is ${km.toFixed(1)} km apart, check order/coordinates`);
    }
  }

  // hotels
  const hotels = c.hotels || [];
  if (!hotels.length) err('needs hotels');
  hotels.forEach(h => {
    const w = `hotel ${h.name}`;
    if (!isStr(h.name) || !isStr(h.area)) err(`${w}: needs name and area`);
    near(h.lat, h.lng, w);
    if (!Number.isInteger(h.priceTier) || h.priceTier < 1 || h.priceTier > 4) err(`${w}: priceTier must be 1–4`);
    if (!Number.isInteger(h.stars) || h.stars < 1 || h.stars > 5) err(`${w}: stars must be 1–5`);
    if (h.rating != null && (!isNum(h.rating) || h.rating < 0 || h.rating > 5)) err(`${w}: rating must be 0–5`);
  });
  const dupes = hotels.map(h => h.name).filter((n, i, a) => a.indexOf(n) !== i);
  if (dupes.length) warn(`duplicate hotel names: ${[...new Set(dupes)].join(', ')}`);

  // coverage audit, curation spec §7
  const hubs = [...(c.airports || []).map(a => ({ ...a, kind: 'airport' })), ...(c.railStations || []).map(r => ({ ...r, kind: 'rail station' }))];
  for (const hub of hubs) {
    if (!isStr(hub.name)) { err(`${hub.kind} needs a name`); continue; }
    near(hub.lat, hub.lng, `${hub.kind} ${hub.name}`);
    if (hub.kind === 'airport' && !isStr(hub.code)) warn(`airport ${hub.name}: no code`);
    const labeled = hotels.filter(h => h.area === hub.name).length;
    const nearby = hotels.filter(h => haversineM(hub.lat, hub.lng, h.lat, h.lng) <= WALK_RADIUS_M).length;
    if (!labeled && !nearby) warn(`${hub.kind} "${hub.name}": 0 hotels (gap to fill or document, or an area label that doesn't match exactly)`);
    else if (!labeled) warn(`${hub.kind} "${hub.name}": ${nearby} hotel(s) within ${WALK_RADIUS_M} m but none labeled with this exact name (fine for a shared hub)`);
  }
  // areas that look like a hub's name but don't match exactly (the 2026-07-13 bug)
  const hubNames = new Set(hubs.map(h => h.name));
  for (const area of new Set(hotels.map(h => h.area))) {
    if (hubNames.has(area)) continue;
    const close = hubs.find(h => h.name && (h.name.toLowerCase().includes(area.toLowerCase()) || area.toLowerCase().includes(h.name.toLowerCase())));
    if (close) warn(`hotel area "${area}" looks like ${close.kind} "${close.name}" but doesn't match exactly`);
  }

  // sights, design doc §4
  const sights = c.sights || [];
  if (sights.length < 10) warn(`only ${sights.length} sights (target ~12–15 ranked + a few local picks)`);
  sights.forEach(s => {
    const w = `sight ${s.name}`;
    if (!isStr(s.name) || !isStr(s.note)) err(`${w}: needs name and note`);
    near(s.lat, s.lng, w);
    if (s.ticketUrl) {
      if (!/^https:\/\//.test(s.ticketUrl)) err(`${w}: ticketUrl must be https`);
      if (RESELLERS.test(s.ticketUrl)) err(`${w}: ticketUrl is a reseller, use the official site or leave it empty`);
    }
    if (s.rating != null && (!isNum(s.rating) || s.rating < 0 || s.rating > 5)) err(`${w}: rating must be 0–5`);
  });
}
