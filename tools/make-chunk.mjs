// Rewrite index.html so it holds only one scene, starting at 0 (for parallel CI renders).
// Usage: node tools/make-chunk.mjs <sceneId>   |   node tools/make-chunk.mjs --list
import { readFileSync, writeFileSync } from "node:fs";
const html = readFileSync("index.html", "utf8");
const hostRe = /<div id="([\w-]+)" class="clip"[^>]*?data-start="([\d.]+)" data-duration="([\d.]+)"[^>]*><\/div>/gs;
const scenes = [...html.matchAll(hostRe)].map(m => ({ id: m[1], start: +m[2], dur: +m[3], tag: m[0] }));
const arg = process.argv[2];
if (arg === "--list") { console.log(JSON.stringify(scenes.map(({ id, start, dur }) => ({ id, start, dur })))); process.exit(0); }
const s = scenes.find(x => x.id === arg);
if (!s) { console.error("unknown scene " + arg); process.exit(1); }
const open = html.indexOf('<div id="main"'), close = html.indexOf("<script>", open);
const body = `<div id="main" data-composition-id="main" data-start="0" data-duration="${s.dur}" data-width="1920" data-height="1080">\n  ` +
  s.tag.replace(/data-start="[\d.]+"/, 'data-start="0"') + "\n</div>\n";
let out = html.slice(0, open) + body + html.slice(close);
out = out.replace(/main\.set\(\{\}, \{\}, [\d.]+\)/, `main.set({}, {}, ${s.dur})`);
writeFileSync("index.html", out);
console.log(`chunk ${s.id}: ${s.dur}s`);
