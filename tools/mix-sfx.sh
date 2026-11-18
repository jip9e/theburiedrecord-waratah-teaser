#!/usr/bin/env bash
# Builds assets/sfx/bed.wav (27.5 s, 48 kHz stereo) from ready-made Pixabay SFX.
# Scene cuts: 5.5, 9.5, 13.4, 18.4. Narration sits on its own track in index.html.
set -euo pipefail
cd "$(dirname "$0")/.."
P=assets/sfx/pixabay
ffmpeg -nostdin -v error -y \
  -i "$P/chrysalyn-immersive-ocean-storm-ambience-with-roaring-waves-and-wind-562429.mp3" \
  -i "$P/liecio-howling-wind-109590.mp3" \
  -i "$P/kuzu420-inside-the-old-creaking-ship-inside-544810.mp3" \
  -i "$P/freesound_community-shipcreaks2-107801.mp3" \
  -i "$P/dragon-studio-groaning-metal-511322.mp3" \
  -i "$P/dragon-studio-cinematic-boom-01-414572.mp3" \
  -i "$P/dragon-studio-whoosh-cinematic-376875.mp3" \
  -i "$P/alexis_gaming_cam-cinematic-bass-boom-free-370400.mp3" \
  -i "$P/universfield-thunder-strike-124463.mp3" \
  -i "$P/soundreality-atlantic-drone-589644.mp3" \
  -i "$P/pwlpl-underwater-rumble-sound-effect-521068.mp3" \
  -filter_complex "
  [0]atrim=0:27.5,afade=t=in:d=1.5,afade=t=out:st=24:d=3.5,volume=0.55[storm];
  [1]atrim=2:29.5,asetpts=N/SR/TB,afade=t=in:d=3,afade=t=out:st=23:d=4,volume=0.30[wind];
  [2]atrim=5:32.5,asetpts=N/SR/TB,afade=t=in:d=2,afade=t=out:st=20:d=4,volume=0.40[hull];
  [3]adelay=5300|5300,volume=0.70[creak];
  [4]afade=t=out:st=4:d=2,adelay=13200|13200,volume=0.55[metal];
  [5]asplit=2[b1][b2];
  [b1]adelay=5450|5450,volume=0.75[boom1];
  [b2]adelay=13350|13350,volume=0.75[boom2];
  [6]adelay=9050|9050,volume=0.60[whoosh];
  [7]atrim=0:6,afade=t=out:st=4:d=2,adelay=18350|18350,volume=0.80[bass];
  [8]atrim=0:8,afade=t=out:st=5:d=3,adelay=18100|18100,volume=0.65[thunder];
  [9]atrim=0:9,afade=t=in:d=3,afade=t=out:st=6.5:d=2.5,adelay=18400|18400,volume=0.45[drone];
  [10]afade=t=out:st=3:d=2,adelay=22300|22300,volume=0.60[rumble];
  [storm][wind][hull][creak][metal][boom1][boom2][whoosh][bass][thunder][drone][rumble]
    amix=inputs=12:duration=longest:normalize=0,aformat=sample_rates=48000:channel_layouts=stereo,
    atrim=0:27.5,alimiter=limit=0.89[out]" \
  -map "[out]" -ar 48000 -ac 2 -c:a pcm_s16le assets/sfx/bed.wav
ffprobe -v error -show_entries format=duration -of csv=p=0 assets/sfx/bed.wav
