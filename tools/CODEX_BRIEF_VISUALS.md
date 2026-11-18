# Brief: rebuild the teaser visuals (HyperFrames, 1920x1080, 30 fps, 55 s)

You are working in this folder (a HyperFrames project). Read CLAUDE.md, CARBON_CRITIQUE.md and SCRIPT_V2.md first.
The audio is FINISHED and must not change: index.html already plays one track, `<audio id="mix" src="assets/sfx/mix_v2.wav">`, 0 to 55 s.
The root duration is already 55 s. Your job: rebuild every visual scene so it fixes every visual point in CARBON_CRITIQUE.md and lands on the new audio times.

## Voice line start times in video time (seconds)
L1 0.6 "Two hundred and eleven people." / L2 5.06 "A brand-new steamship." / L3 8.68 "And not one trace of them has ever been found." /
L4 16.12 "July, 1909. The Waratah leaves Durban, bound for Cape Town." / L5 25.2 "Next morning, a passing ship signals her by lamp." /
L6 30.3 "Her reply is the last anyone will ever hear from her." (ends 35.05) / HARD SILENCE 35.06 to 37.76 /
L7 37.81 "That night, the storm came." / L8 41.01 "Warships searched for weeks. The families paid for a search of their own." /
L9 47.75 "The sea gave back nothing." (voice ends about 50.7). Music fades out from 53.5 s.
Get each line's exact end with: `ffmpeg -i assets/voice/v2/narration_v2.wav -af silencedetect=n=-40dB:d=0.35 -f null -` (that file is in narration time; lines 7 to 9 are shifted +0.8 s in the video).

## Sound hits that the picture must match
- 0.5 foghorn (fog over dark water) / 4.8 engine thrum begins / 8.55 sub drop (hard cut to the title THE WARATAH, small and restrained)
- 23.9 to about 29 Morse telegraph / 29.56 and 29.98 two lamp shutter clicks / 30.3 to 35 a low drone only / 35.06 to 37.76 TRUE BLACK
- 37.75 storm impact plus thunder (cut on it) / 39.95 and 43.45 metal groans / 47.75 onwards calm, end card

## Shot plan (rewrite the compositions; you may rename, add or delete scene files)
1. 0 to 5.0: near-black, slow fog over dark water (assets/flow/ocean.mp4, graded dark through media-treatment). "211" in the one serif, small, light ink on dark (it must read; no beige on beige).
2. 5.0 to 8.55: ship photo (best real Waratah photo in assets/archive, e.g. port_adelaide.jpg or postcard.jpg), held for the whole line with a slow push-in and a subtle 2.5D parallax (split foreground/background by masking or a second scaled layer). Grain and grade via media-treatment.
3. 8.55 to 16.0: cut to black on the sub drop, then the title card THE WARATAH (one serif, period spacing), slow fade. Give L3 room; no gimmicks.
4. 16.0 to 25.0: a period chart. Download a public-domain 19th or early-20th-century chart of the South African coast (Durban to Cape Town) from Wikimedia Commons (check the licence is PD; record its URL and licence in assets/archive/urls.tsv). Plot the route as a dotted ink line drawing itself along the sea lane offshore (NOT hugging the coast, never over land), Durban to Cape Town. A small handwritten-style label "26 July 1909" is fine. Remove all GIS or modern satellite imagery (s1-map and bake-basemap are the old version; drop them).
5. 25.0 to 30.3: night sea and the dark horizon; a SMALL point of light flashing real Morse in sync with the Morse audio (23.9 to 29), and two quick blinks exactly on 29.56 and 29.98. No full-frame strobe.
6. 30.3 to 35.05: barely visible, very dark ship silhouette or the sea, slowly fading to black by 35.0.
7. 35.06 to 37.76: pure black #000, nothing on screen.
8. 37.76 to 41.0: hard cut on the impact to the storm painting (assets/archive/at_sea.jpg), wide, with camera shake easing out and slight push-in; flicker of lightning at 38.2 (brightness change done on an overlay layer, not a filter).
9. 41.0 to 47.6: 2 to 3 shots: a tighter push into the painting, then a 1909 newspaper clipping. Prefer a real PD scan (Trove, Papers Past or Wikimedia: search "Waratah missing 1909"). If none is reachable, build a credible clipping in HTML: one period serif, aged paper texture, headline "THE WARATAH. STILL NO NEWS." Do not invent quotes beyond a headline plus one plain factual line.
10. 47.6 to 55.0: calm dark sea, then the end card: the logo assets/brand/logo.png plus "The Buried Record". The logo is RGB with a dark (16,13,12) background, which caused the grey box. Make assets/brand/logo_alpha.png with real transparency (remove the dark background, keep the soft edges) and use it, OR put it on an exactly matching background. Fade to black by 54.8.

## Rules (hard)
- Delete burned-in subtitles: remove compositions/captions.html and its host from index.html.
- One serif only (Cormorant). Drop Cinzel and Inter use. Text sparingly.
- No bevelled rectangles, no whip-pans into the same photo, no fake sun flares, no grey strobes, nothing over 0.3 s of empty grey.
- Grades, grain and vignettes go through `npx hyperframes media-treatment` (read the media-use skill: ~/.claude/skills/media-use/references/media-treatments.md), never CSS filters.
- Follow the HyperFrames contract: class="clip", data-start, data-duration, one paused timeline per composition registered on window.__timelines, deterministic only, no network at render time (download assets into assets/ now).
- Do not touch assets/sfx, assets/voice or the <audio id="mix"> element.
- Do not render video on this laptop (it is weak). Only `npm run check` and `npx hyperframes snapshot --at ...` (at most about 12 frames).

## Done means
`npm run check` passes with no errors, snapshots at 2, 6, 12, 20, 27.5, 29.6, 33, 36, 38.3, 44, 50, 53 look right, and you write a short report (what changed, asset sources and licences, any problem left) to tools/CODEX_REPORT_VISUALS.md.
