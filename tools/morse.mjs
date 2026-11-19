// Real Morse timing for the lamp exchange (night scene + click track).
// node tools/morse.mjs json   -> keying windows  |  node tools/morse.mjs html -> panel markup
const CODE = { A: ".-", H: "....", I: "..", P: ".--.", R: ".-.", S: "...", T: "-", W: ".--" };
export const MSGS = [
  { id: "r1", label: "Clan MacIntyre", text: "WHAT SHIP", start: 25.25, unit: 0.05, lamp: false },
  { id: "r2", label: "Waratah · reply", text: "WARATAH", start: 29.25, unit: 0.062, lamp: true },
];
export function key(m) {
  const out = []; let t = m.start; // [on, off, letterIndex]
  [...m.text].forEach((ch, li) => {
    if (ch === " ") { t += 4 * m.unit; return; }
    [...CODE[ch]].forEach((s, si) => {
      const d = (s === "." ? 1 : 3) * m.unit;
      out.push([+t.toFixed(3), +(t + d).toFixed(3), li]); t += d + m.unit;
    });
    t += 2 * m.unit;
  });
  return out;
}
const mode = process.argv[2];
if (mode === "json") console.log(JSON.stringify(MSGS.map(m => ({ id: m.id, lamp: m.lamp, k: key(m) }))));
if (mode === "clicks") MSGS.forEach(m => key(m).forEach(([a, b]) => console.log(m.lamp ? "near" : "far", a, b)));
if (mode === "html") MSGS.forEach(m => {
  const letters = [...m.text].map((ch, li) => ch === " " ? '<span class="gap"></span>' :
    `<span class="L" id="${m.id}l${li}"><b>${ch}</b><i>${CODE[ch].replace(/\./g, "·").replace(/-/g, "—")}</i></span>`).join("");
  console.log(`      <p class="row" id="nm-${m.id}"><span class="lbl">${m.label}</span>${letters}</p>`);
});
