#!/usr/bin/env bash
# Teaser v3 mix: three organized stems (VOICE / MUSIC / SFX), each levelled on its own, then summed.
#  - MUSIC: one steady compressed bed, ~15 LU under the voice the whole way (no dips, no swells).
#  - SFX: a few clear spot effects, each on its moment, ducked under the voice.
# Output: assets/sfx/mix_v2.wav (name kept so index.html needs no change), 55 s, 48k stereo, -14 LUFS.
set -euo pipefail
cd "$(dirname "$0")/.."
P=assets/sfx/pixabay; N=$P/new; D=55
T=${TMPDIR:-/tmp}/mixv3; mkdir -p "$T"
VO_I=-16; MUS_I=-34; SFX_I=-27

# 1) VOICE stem (lines 7-9 shifted +0.8 s for the hard silence)
ffmpeg -nostdin -v error -y -i assets/voice/v2/narration_v2.wav -filter_complex "
 [0]aformat=sample_rates=48000:channel_layouts=stereo,asplit=2[a][b];
 [a]atrim=0:36[v1];[b]atrim=36,asetpts=N/SR/TB,adelay=36800:all=1[v2];
 [v1][v2]amix=inputs=2:normalize=0,apad=whole_dur=$D,atrim=0:$D,loudnorm=I=$VO_I:TP=-2:LRA=11,aresample=48000[o]" -map "[o]" -c:a pcm_s16le "$T/vo.wav"

# 2) MUSIC stem: part A 0-30.4 s, a soft drone through line 6, silence 35.1-37.8, part B 37.8-55.
#    Compressed so it never jumps, EQ'd out of the voice's range.
ffmpeg -nostdin -v error -y -i assets/music/v2/score_a.mp3 -filter_complex "
 [0]aformat=sample_rates=48000:channel_layouts=stereo,asplit=3[m1][m2][m3];
 [m1]atrim=0:30.4,afade=t=in:d=2,afade=t=out:st=29.4:d=1.0[A];
 [m3]atrim=1:6.2,asetpts=N/SR/TB,lowpass=f=900,afade=t=in:d=0.6,afade=t=out:st=4.95:d=0.15,apad=pad_dur=3,aecho=0.8:0.7:300|650|1100:0.35|0.22|0.12,adelay=29900:all=1,volume=1.1[dr];
 [m2]atrim=40:57.5,asetpts=N/SR/TB,afade=t=in:d=2.0,afade=t=out:st=13.2:d=4,adelay=37800:all=1[B];
 [A][dr][B]amix=inputs=3:normalize=0,apad=whole_dur=$D,atrim=0:$D,
 highpass=f=85:poles=2,equalizer=f=260:t=o:w=1.2:g=-5.5,equalizer=f=150:t=o:w=1:g=-2,equalizer=f=2500:t=o:w=1.5:g=-5,
 acompressor=threshold=0.05:ratio=6:attack=80:release=900:makeup=2,
 loudnorm=I=$MUS_I:TP=-6:LRA=5,volume='(1-0.6*clip((t-38.6)/0.4,0,1)*clip((47.4-t)/0.4,0,1)-0.55*clip((t-47.4)/0.4,0,1)*clip((51.1-t)/0.4,0,1))*(1+0.6*clip((t-51.1)/0.8,0,1))':eval=frame,equalizer=f=650:t=o:w=1.6:g=-4:enable='between(t,38.4,51.2)',aresample=48000[o]" -map "[o]" -c:a pcm_s16le "$T/music.wav"

# 3) SFX stem: one effect per story beat.
T="$T" python3 tools/lamp-clicks.py
ffmpeg -nostdin -v error -y \
 -i $N/foghorn_long_distant_40915.mp3 -i $N/sea_at_night_17353.mp3 -i $N/engine_room_hum_584775.mp3 \
 -i $P/alexis_gaming_cam-cinematic-bass-boom-free-370400.mp3 -i "$T/clk_far.wav" -i "$T/clk_near.wav" \
 -i $P/chrysalyn-immersive-ocean-storm-ambience-with-roaring-waves-and-wind-562429.mp3 \
 -i $P/dragon-studio-groaning-metal-511322.mp3 -i $P/dragon-studio-cinematic-boom-01-414572.mp3 -i $P/universfield-thunder-strike-124463.mp3 -i $N/steam_engine_loop_43171.mp3 \
 -filter_complex "
 [0]atrim=0.5,asetpts=N/SR/TB,afade=t=out:st=6.5:d=1.3,equalizer=f=200:t=o:w=1:g=-2.5,volume=1.4[horn];
 [1]atrim=2:18,asetpts=N/SR/TB,lowpass=f=3000,afade=t=in:d=0.6,afade=t=out:st=12:d=4,volume=2.8[sea];
 [2]atrim=2:11,asetpts=N/SR/TB,lowpass=f=1200,afade=t=in:d=0.8,afade=t=out:st=5.5:d=3,adelay=4800:all=1,volume=1.3[eng];
 [d0]atrim=0:6,afade=t=out:st=4:d=2,adelay=8550:all=1,volume=0.7[drop];
 [4]aformat=channel_layouts=stereo,highpass=f=400,lowpass=f=1800,aecho=0.8:0.6:90|180:0.4|0.25,volume='0.10*(1-0.6*clip((t-29.6)/0.3,0,1))':eval=frame,lowpass=f=1400:enable='gte(t,29.6)'[morse];
 [5]aformat=channel_layouts=stereo,highpass=f=250,lowpass=f=6000,highshelf=f=4500:g=-6,aecho=0.8:0.7:60|120|200:0.4|0.28|0.16,volume=0.16[s1];
 [3]asplit=4[d0][d1][d2][d3];
 [d3]atrim=0:0.6,lowpass=f=260,afade=t=out:st=0.08:d=0.45,adelay=41950:all=1,volume=1.1[stamp];
 [d1]atrim=0:4,lowpass=f=140,afade=t=in:d=0.05,afade=t=out:st=0.4:d=2.0,adelay=34950:all=1,volume=0.45[tail];
 [d2]atrim=0:4,lowpass=f=200,afade=t=out:st=1.2:d=2.0,adelay=37720:all=1,volume=0.9[sub];
 [6]atrim=0:16,afade=t=in:d=0.3,afade=t=out:st=8.0:d=2.2,adelay=37750:all=1,lowpass=f=4500,volume='0.17*(1+0.9*clip((38.9-t)/0.6,0,1))*(1-0.45*clip((t-40.5)/0.9,0,1))':eval=frame[storm];
 [7]atrim=0:1.4,afade=t=out:st=0.9:d=0.5,adelay=40250:all=1,volume=0.7[metal];
 [8]adelay=37750:all=1,volume=0.85[boom];
 [9]atrim=0:5,afade=t=out:st=2.5:d=2.5,adelay=38050:all=1,volume=0.42[thun];
 [10]atrim=0:4,asetpts=N/SR/TB,highpass=f=100,lowpass=f=2500,equalizer=f=250:t=o:w=1:g=3,afade=t=in:d=0.4,afade=t=out:st=2.4:d=1.0,adelay=4900:all=1,volume=1.2[chug];
 [horn][sea][eng][drop][morse][s1][tail][sub][storm][metal][boom][thun][chug][stamp]amix=inputs=14:normalize=0,
 apad=whole_dur=$D,atrim=0:$D,equalizer=f=3000:t=o:w=1.4:g=-4,
 loudnorm=I=$SFX_I:TP=-3:LRA=15,volume='(1-0.5*clip((t-38.8)/0.3,0,1)*clip((47.2-t)/0.3,0,1))*(1-0.55*clip((t-43.8)/0.1,0,1)*clip((45.0-t)/0.2,0,1))':eval=frame,aresample=48000[o]" -map "[o]" -c:a pcm_s16le "$T/sfx.wav"

# 4) Sum: music and SFX gently duck (about 3 dB) only while the voice speaks, so the bed still feels steady.
ffmpeg -nostdin -v error -y -i "$T/vo.wav" -i "$T/music.wav" -i "$T/sfx.wav" -filter_complex "
 [0]asplit=3[vo][k1][k2];
 [1][k1]sidechaincompress=threshold=0.03:ratio=1.5:attack=120:release=1400:knee=8[mus];
 [2][k2]sidechaincompress=threshold=0.03:ratio=3:attack=20:release=400[fx];
 [vo][mus][fx]amix=inputs=3:normalize=0,afade=t=out:st=53.5:d=1.5[o]" -map "[o]" -c:a pcm_s16le "$T/sum.wav"
ffmpeg -nostdin -v error -y -i "$T/sum.wav" -af "loudnorm=I=-14:TP=-1.5:LRA=14,aresample=48000" -ar 48000 -c:a pcm_s16le assets/sfx/mix_v2.wav
for s in vo music sfx; do printf "%-6s" $s; ffmpeg -nostdin -hide_banner -i "$T/$s.wav" -af ebur128 -f null - 2>&1 | grep -A3 Summary | grep "I:"; done
printf "final "; ffmpeg -nostdin -hide_banner -i assets/sfx/mix_v2.wav -af ebur128=peak=true -f null - 2>&1 | grep -A12 Summary | grep -E "I:|Peak:" | tr '\n' ' '; echo
