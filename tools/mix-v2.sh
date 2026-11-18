#!/usr/bin/env bash
# Teaser v2d mix (Neon v2c 7/10 fixes applied) -> assets/sfx/mix_v2.wav (55 s, 48k stereo, -14 LUFS). Narration is INCLUDED.
# Narration lines 7-9 are shifted +0.8 s so there is ~2.8 s hard silence after line 6.
# Final VO line starts (video time): 0.6 5.06 8.68 16.12 25.2 30.3 | 37.81 41.01 47.75. Line 6 ends 35.05.
set -euo pipefail
cd "$(dirname "$0")/.."
P=assets/sfx/pixabay; N=$P/new; D=55; TMP=${TMPDIR:-/tmp}/mixv2.wav
ffmpeg -nostdin -v error -y \
  -i assets/voice/v2/narration_v2.wav \
  -i assets/music/v2/score_a.mp3 \
  -i $N/foghorn_long_distant_40915.mp3 \
  -i $N/sea_at_night_17353.mp3 \
  -i $N/engine_room_hum_584775.mp3 \
  -i $P/alexis_gaming_cam-cinematic-bass-boom-free-370400.mp3 \
  -i $N/morse_code_131798.mp3 \
  -i $N/camera_shutter_187326.mp3 \
  -i $P/chrysalyn-immersive-ocean-storm-ambience-with-roaring-waves-and-wind-562429.mp3 \
  -i $P/liecio-howling-wind-109590.mp3 \
  -i $P/dragon-studio-groaning-metal-511322.mp3 \
  -i $P/dragon-studio-cinematic-boom-01-414572.mp3 \
  -i $P/universfield-thunder-strike-124463.mp3 \
  -filter_complex "
  [0]aformat=sample_rates=48000:channel_layouts=stereo,asplit=2[va][vb];
  [va]atrim=0:36[v1]; [vb]atrim=36,asetpts=N/SR/TB,adelay=36800:all=1[v2];
  [v1][v2]amix=inputs=2:normalize=0,apad=whole_dur=$D,atrim=0:$D,asplit=3[vo][sc1][sc2];
  [1]aformat=sample_rates=48000:channel_layouts=stereo,asplit=3[m1][m2][m3];
  [m1]atrim=0:30.4,afade=t=in:d=2,afade=t=out:st=29.4:d=1.0,highpass=f=85:poles=2,equalizer=f=260:t=o:w=1.2:g=-4,volume='0.55*if(between(t,16.0,16.8),0.55,1)*if(between(t,23.3,24.9),0.45,1)':eval=frame[sA];
  [m3]atrim=1:6.2,asetpts=N/SR/TB,lowpass=f=900,afade=t=in:d=0.6,afade=t=out:st=4.9:d=0.8:curve=exp,adelay=29900:all=1,volume=0.38[drone6];
  [m2]atrim=40:57.5,asetpts=N/SR/TB,afade=t=in:d=2.5,afade=t=out:st=13.2:d=4,adelay=37800:all=1,volume='0.55*if(between(t,38.8,43.6)*not(between(t,40.2,40.9)),0.62,1)*if(lt(t,47.2),0.67,if(lt(t,51.1),0.42,1.6))':eval=frame[sB];
  [2]atrim=0.5,asetpts=N/SR/TB,afade=t=out:st=6.5:d=1.3,equalizer=f=200:t=o:w=1:g=-2.5,volume=1.6[horn];
  [3]atrim=2:18,asetpts=N/SR/TB,lowpass=f=3000,afade=t=in:d=1.0,afade=t=out:st=12:d=4,volume=1.7[sea];
  [4]atrim=2:11,asetpts=N/SR/TB,lowpass=f=1200,equalizer=f=250:t=o:w=1.5:g=3,afade=t=in:d=0.8,afade=t=out:st=5.5:d=3,adelay=4800:all=1,volume=1.5[eng];
  [5]atrim=0:6,afade=t=out:st=4:d=2,adelay=8550:all=1,volume=0.85[drop];
  [6]highpass=f=500,lowpass=f=1600,acrusher=bits=10:mix=0.2,aecho=0.6:0.4:40:0.2,adelay=23900:all=1,volume=1.3[morse];
  [7]atrim=0:0.15,highpass=f=300,highshelf=f=5000:g=-3,aecho=0.8:0.5:60|110:0.25|0.15,asplit=2[k1][k2];[k1]adelay=29560:all=1,volume=0.45[sh1];[k2]adelay=29980:all=1,volume=0.38[sh2];
  [8]atrim=0:16,afade=t=in:d=0.3,afade=t=out:st=6.5:d=4,adelay=37750:all=1,volume='0.31*if(between(t,38.8,39.6),0.7,1)*if(between(t,38.8,43.6)*not(between(t,40.2,40.9)),0.67,1)*if(between(t,43.6,45.4),0.4,1)':eval=frame[storm];
  [9]atrim=3:18,asetpts=N/SR/TB,afade=t=in:d=1.0,afade=t=out:st=5:d=5,adelay=37900:all=1,volume=0.17[wind];
  [10]atrim=0:2.4,afade=t=out:st=1.6:d=0.8,adelay=39950:all=1,volume=1.0[met1];
  anoisesrc=d=3.6:c=brown:a=0.004:r=48000,lowpass=f=400,afade=t=in:d=0.4,afade=t=out:st=3.0:d=0.6,adelay=34700:all=1[room];
  [11]adelay=37750:all=1,volume=0.90[boom];
  [12]atrim=0:7,afade=t=out:st=4:d=3,adelay=38200:all=1,volume=0.55[thun];
  [storm][wind][sB]amix=inputs=3:normalize=0,equalizer=f=2600:t=o:w=1.5:g=-7[stormbus0];
  [stormbus0][sc1]sidechaincompress=threshold=0.02:ratio=8:attack=15:release=300:makeup=1[stormbus];
  [sA][drone6][horn][sea][eng][drop][morse][sh1][sh2][met1][boom][thun][room]amix=inputs=13:normalize=0,equalizer=f=3200:t=o:w=1.4:g=-5[restbus0];
  [restbus0][sc2]sidechaincompress=threshold=0.05:ratio=3:attack=20:release=350:makeup=1[restbus];
  [stormbus][restbus][vo]amix=inputs=3:normalize=0,apad=whole_dur=$D,atrim=0:$D,afade=t=out:st=53.5:d=1.5[out]" \
  -map "[out]" -c:a pcm_s16le "$TMP"
ffmpeg -nostdin -v error -y -i "$TMP" -af "loudnorm=I=-14:TP=-1.5:LRA=14,aresample=48000" -ar 48000 -c:a pcm_s16le assets/sfx/mix_v2.wav
ffmpeg -nostdin -hide_banner -i assets/sfx/mix_v2.wav -af ebur128=peak=true -f null - 2>&1 | grep -A12 Summary | grep -E "I:|Peak:"
