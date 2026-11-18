# Waratah teaser visual rebuild

The 55-second composition opens on moving fog and water with a readable “211,” then holds the Port Adelaide photograph for 3.55 seconds with a slow push and a separately moving quay. The 8.55-second title cut, offshore chart route, distant signal and its two shutter blinks lead into the black hold. The storm starts at 37.76, with lightning at 38.20 and a camera jolt on the first metal groan. The closer view cuts to the newspaper at the brief’s second groan cue, 43.45. The closing sea carries a single Cormorant lockup with a transparent logo, fully faded by 54.8. The satellite sequence, its build script, and the burned-in captions were removed.

## Archive sources

- The route uses a scan of the 1827 Admiralty Chart No. 596 from Royal Museums Greenwich. The dots describe the intended Durban–Cape Town passage. Commons marks the scan as public domain under PD-Art / PD-old-100-expired. [Chart and licence](https://commons.wikimedia.org/wiki/File:Admiralty_Chart_No_596_Africa,_sheet_IV_from_Hollams_Island_to_Cape_Correntes_including_the_Cape_of_Good_Hope_-_from_1822_to_1826_RMG_F0115,_Published_1827.tiff)
- The newspaper uses the authentic Waratah headline from page 2 of the *Victoria Daily Times*, 6 August 1909, digitized by the University of Victoria. The crop keeps the headline and excludes neighboring coverage. Commons identifies the issue as PD-Canada. The 1909 issue is also public domain in the United States. [Scan and licence](https://commons.wikimedia.org/wiki/File:Victoria_Daily_Times_(1909-08-06)_(IA_victoriadailytimes19090806).pdf)
- The 1909 Port Adelaide photograph and 1908–09 postcard are marked PD-Australia. The postcard contains the storm painting. The similarly named `at_sea.jpg` contains a photograph. The sea crops use the project’s existing Flow clips and the logo derives from the supplied brand asset. [Port Adelaide photograph](https://commons.wikimedia.org/wiki/File:SS_%27Waratah%27_at_Port_Adelaide%2C_1909.jpeg) · [Waratah postcard](https://commons.wikimedia.org/wiki/File:SS_Waratah_colour_postcard.jpg)

The download URLs and derived crops are recorded in [`assets/archive/urls.tsv`](../assets/archive/urls.tsv). Exposure, colour, grain and vignette were applied with HyperFrames media-treatment. GSAP is loaded from the local vendored copy.

## Timing and verification

FFmpeg detected narration line ends in video time at 3.824, 7.712, 13.849, 24.365, 29.511, 35.046, 39.949, 46.815 and 50.696 seconds. The last three include the 0.8-second shift. The locked Morse effect starts at 23.9 over the chart and its keyed tones finish at about 25.93. The 25-second cut carries the remaining pulses onto the sea. The shutter blinks start at 29.56 and 29.98.

The audio wasn’t edited as part of this rebuild. The WAV changed separately during the work and measured 52.64 seconds when checked, ending before the stated music fade at 53.5. The newer mix script also adds room tone during the hold (about −60 dBFS RMS across 35.06–37.75 seconds) and omits the second groan. The picture follows the brief’s original cut times, including true black from 35.06 to 37.76 seconds.

The 12 requested timestamps were inspected as PNGs. The affected sea frames were recaptured after correcting their crop. The retake command logged a Chrome shutdown error after saving all six replacement PNGs, which were opened and inspected. The sampled image at 36 seconds was RGB (0, 0, 0) across the entire frame. The review frames and contact sheet are in [`out/visuals-review`](../out/visuals-review/contact-sheet.jpg).

The full `npm run check -- --timeout 45s` passed with zero errors and no layout, motion or craft findings. The only warnings were software WebGL readback stalls and the 52.64-second source WAV in its 55-second slot. All text contrast samples passed, including the chart and newspaper in the targeted check. Verification used still frames and the HyperFrames check.
