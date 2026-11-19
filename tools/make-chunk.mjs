// Rewrite index.html so it holds only one scene, starting at 0 (for parallel CI renders).
// Usage: node tools/make-chunk.mjs <sceneId>   |   node tools/make-chunk.mjs --list
import { readFileSync, writeFileSync } from "node:fs";
const html = readFileSync("index.html", "utf8");
const hostRe = /<div id="([\w-]+)" class="clip"[^>]*?data-start="([\d.]+)" data-duration="([\d.]+)"[^>]*><\/div>/gs;
const all = [...html.matchAll(hostRe)].map(m => ({ id: m[1], start: +m[2], dur: +m[3], tag: m[0] }));
const cardsHost = all.find(x => x.id === "cards");
const scenes = all.filter(x => x.id !== "cards").sort((a, b) => a.start - b.start);
// Every scene but the last renders TAIL extra seconds past its cut, so the stitch can crossfade into the next one.
const TAIL = 1.2;
scenes.forEach((x, i) => { x.tail = i < scenes.length - 1 ? TAIL : 0; });
const arg = process.argv[2];
if (arg === "--list") { console.log(JSON.stringify(scenes.map(({ id, start, dur, tail }) => ({ id, start, dur, tail })))); process.exit(0); }
const s0 = scenes.find(x => x.id === arg);
if (!s0) { console.error("unknown scene " + arg); process.exit(1); }
const s = { ...s0, dur: +(s0.dur + s0.tail).toFixed(3), tag: s0.tag.replace(/data-duration="[\d.]+"/, `data-duration="${+(s0.dur + s0.tail).toFixed(3)}"`) };
const open = html.indexOf('<div id="main"'), close = html.indexOf("<script>", open);
const body = `<div id="main" data-composition-id="main" data-start="0" data-duration="${s.dur}" data-width="1920" data-height="1080">\n  ` +
  s.tag.replace(/data-start="[\d.]+"/, 'data-start="0"') + "\n  " +
  (cardsHost ? cardsHost.tag.replace(/data-duration="[\d.]+"/, `data-duration="${s.dur}"`) : "") + "\n</div>\n";
// Shift the cards overlay into this chunk's time window and drop cards outside it.
if (cardsHost) {
  let c = readFileSync("compositions/cards.html", "utf8");
  c = c.replace(/<div id="(c\d+)" class="clip card" data-start="([\d.]+)" data-duration="([\d.]+)">([\s\S]*?)<\/div><\/div>(<\/div>)?/g,
    (m, id, st, du) => {
      const a = +st - s.start, b = a + +du;
      if (b <= 0 || a >= s.dur) return "";
      return m.replace(/data-start="[\d.]+"/, `data-start="${Math.max(0, a).toFixed(3)}"`)
              .replace(/data-duration="[\d.]+"/, `data-duration="${(Math.min(b, s.dur) - Math.max(0, a)).toFixed(3)}"`);
    });
  writeFileSync("compositions/cards.html", c);
}
let out = html.slice(0, open) + body + html.slice(close);
out = out.replace(/main\.set\(\{\}, \{\}, [\d.]+\)/, `main.set({}, {}, ${s.dur})`);
// Camera carry-through: every scene drifts in from a slight zoom and pushes on into the next cut,
// so the stitch crossfades between two moving frames (a zoom-through dissolve, not a slide change).
const idx = scenes.findIndex(x => x.id === s.id), isComp = /data-composition-src/.test(s.tag);
let cam = "";
if (isComp && idx > 0) cam += `main.fromTo("#${s.id}",{scale:1.07,x:24,transformOrigin:"50% 50%"},{scale:1,x:0,duration:1.8,ease:"power2.out"},0);`;
if (isComp && s0.tail > 0) cam += `main.to("#${s.id}",{scale:1.09,x:-26,transformOrigin:"50% 50%",duration:${(1.3 + s0.tail).toFixed(2)},ease:"power1.in"},${(s0.dur - 1.3).toFixed(2)});`;
out = out.replace(/(main\.set\(\{\}, \{\}, [\d.]+\);)/, `$1 ${cam}`);
writeFileSync("index.html", out);
console.log(`chunk ${s.id}: ${s.dur}s`);
