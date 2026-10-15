// Shared JSON formatter for site/data/*.json: anything that fits on one
// line (a station, a hotel, a sight) stays on one line, so diffs show one
// changed place per line instead of a wall of brackets.
function formatJson(value, indent = '', width = 200) {
  const flat = JSON.stringify(value);
  if (value === null || typeof value !== 'object' || flat.length + indent.length <= width) return flat;
  const next = indent + '  ';
  if (Array.isArray(value)) {
    return '[\n' + value.map(v => next + formatJson(v, next, width)).join(',\n') + '\n' + indent + ']';
  }
  return '{\n' + Object.entries(value)
    .map(([k, v]) => next + JSON.stringify(k) + ': ' + formatJson(v, next, width))
    .join(',\n') + '\n' + indent + '}';
}
module.exports = { formatJson };
