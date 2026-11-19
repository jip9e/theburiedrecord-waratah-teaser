# Build assets/sfx/lamp_clicks.wav: one shutter click at every lamp on/off from tools/morse.mjs.
# "far" = Clan MacIntyre's lamp (distant, dull, very quiet); "near" = Waratah's shutter (quiet, roomy).
import subprocess, numpy as np, wave
SR = 48000; D = 63
raw = subprocess.check_output(["ffmpeg", "-nostdin", "-v", "error", "-i", "assets/sfx/pixabay/new/clack_85854.mp3",
  "-af", "atrim=0.075:0.25,afade=t=out:st=0.14:d=0.035", "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"])
click = np.frombuffer(raw, np.float32); click = click / np.abs(click).max()
ev = [l.split() for l in subprocess.check_output(["node", "tools/morse.mjs", "clicks"]).decode().split("\n") if l]
out = {"far": np.zeros(SR * D, np.float32), "near": np.zeros(SR * D, np.float32)}
for kind, a, b in ev:
    for t, g in ((float(a), 1.0), (float(b), 0.7)):  # shutter open is louder than release
        i = int(t * SR); out[kind][i:i + len(click)] += g * click[: SR * D - i]
for k, v in out.items():
    with wave.open(f"{__import__('os').environ.get('T','/tmp')}/clk_{k}.wav", "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((np.clip(v, -1, 1) * 32000).astype(np.int16).tobytes())
print(len(ev), "lamp elements")
