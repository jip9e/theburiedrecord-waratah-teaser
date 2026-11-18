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
 [m3]atrim=1:6.2,asetpts=N/SR/TB,lowpass=f=900,afade=t=in:d=0.6,afade=t=out:st=4.2:d=0.9,adelay=29900:all=1,volume=0.7[dr];
 [m2]atrim=40:57.5,asetpts=N/SR/TB,afade=t=in:d=2.0,afade=t=out:st=13.2:d=4,adelay=37800:all=1[B];
 [A][dr][B]amix=inputs=3:normalize=0,apad=whole_dur=$D,atrim=0:$D,
 highpass=f=90:poles=2,equalizer=f=250:t=o:w=1.2:g=-4,equalizer=f=2500:t=o:w=1.5:g=-5,
 acompressor=threshold=0.05:ratio=6:attack=80:release=900:makeup=2,
 loudnorm=I=$MUS_I:TP=-6:LRA=5,volume='1-0.3*clip((t-38.5)/0.5,0,1)*clip((47.7-t)/0.5,0,1)-0.3*clip((t-47.5)/0.4,0,1)*clip((51.2-t)/0.4,0,1)':eval=frame,aresample=48000[o]" -map "[o]" -c:a pcm_s16le "$T/music.wav"

# 3) SFX stem: one effect per story beat.
ffmpeg -nostdin -v error -y \
 -i $N/foghorn_long_distant_40915.mp3 -i $N/sea_at_night_17353.mp3 -i $N/engine_room_hum_584775.mp3 \
 -i $P/alexis_gaming_cam-cinematic-bass-boom-free-370400.mp3 -i $N/morse_code_131798.mp3 -i $N/camera_shutter_187326.mp3 \
 -i $P/chrysalyn-immersive-ocean-storm-ambience-with-roaring-waves-and-wind-562429.mp3 \
 -i $P/dragon-studio-groaning-metal-511322.mp3 -i $P/dragon-studio-cinematic-boom-01-414572.mp3 -i $P/universfield-thunder-strike-124463.mp3 \
 -filter_complex "
 [0]atrim=0.5,asetpts=N/SR/TB,afade=t=out:st=6.5:d=1.3,equalizer=f=200:t=o:w=1:g=-2.5,volume=1.4[horn];
 [1]atrim=2:18,asetpts=N/SR/TB,lowpass=f=3000,afade=t=in:d=1.0,afade=t=out:st=12:d=4,volume=2.0[sea];
 [2]atrim=2:11,asetpts=N/SR/TB,lowpass=f=1200,afade=t=in:d=0.8,afade=t=out:st=5.5:d=3,adelay=4800:all=1,volume=1.3[eng];
 [3]atrim=0:6,afade=t=out:st=4:d=2,adelay=8550:all=1,volume=0.7[drop];
 [4]highpass=f=500,lowpass=f=1600,aecho=0.6:0.4:40:0.2,adelay=23900:all=1,volume=2.0[morse];
 [5]atrim=0:0.15,highpass=f=300,highshelf=f=5000:g=-3,aecho=0.8:0.6:60|110|180:0.35|0.25|0.15,asplit=2[k1][k2];
 [k1]adelay=29560:all=1,volume=0.22[s1];[k2]adelay=29980:all=1,volume=0.19[s2];
 [6]atrim=0:16,afade=t=in:d=0.3,afade=t=out:st=5.5:d=4.2,adelay=37750:all=1,lowpass=f=4500,volume=0.17[storm];
 [7]atrim=0:1.4,afade=t=out:st=0.9:d=0.5,adelay=40250:all=1,volume=0.7[metal];
 [8]adelay=37750:all=1,volume=0.5[boom];
 [9]atrim=0:7,afade=t=out:st=4:d=3,adelay=38200:all=1,volume=0.3[thun];
 [horn][sea][eng][drop][morse][s1][s2][storm][metal][boom][thun]amix=inputs=11:normalize=0,
 apad=whole_dur=$D,atrim=0:$D,equalizer=f=3000:t=o:w=1.4:g=-4,
 loudnorm=I=$SFX_I:TP=-3:LRA=15,aresample=48000[o]" -map "[o]" -c:a pcm_s16le "$T/sfx.wav"

# 4) Sum: music and SFX gently duck (about 3 dB) only while the voice speaks, so the bed still feels steady.
ffmpeg -nostdin -v error -y -i "$T/vo.wav" -i "$T/music.wav" -i "$T/sfx.wav" -filter_complex "
 [0]asplit=3[vo][k1][k2];
 [1][k1]sidechaincompress=threshold=0.03:ratio=1.5:attack=120:release=1400:knee=8[mus];
 [2][k2]sidechaincompress=threshold=0.03:ratio=3:attack=20:release=400[fx];
 [vo][mus][fx]amix=inputs=3:normalize=0,afade=t=out:st=53.5:d=1.5[o]" -map "[o]" -c:a pcm_s16le "$T/sum.wav"
ffmpeg -nostdin -v error -y -i "$T/sum.wav" -af "loudnorm=I=-14:TP=-1.5:LRA=14,aresample=48000" -ar 48000 -c:a pcm_s16le assets/sfx/mix_v2.wav
for s in vo music sfx; do printf "%-6s" $s; ffmpeg -nostdin -hide_banner -i "$T/$s.wav" -af ebur128 -f null - 2>&1 | grep -A3 Summary | grep "I:"; done
printf "final "; ffmpeg -nostdin -hide_banner -i assets/sfx/mix_v2.wav -af ebur128=peak=true -f null - 2>&1 | grep -A12 Summary | grep -E "I:|Peak:" | tr '\n' ' '; echo
