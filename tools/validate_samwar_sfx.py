"""Offline asset/integration validation; does NOT replace a Godot runtime check."""
from pathlib import Path
import array, hashlib, re, runpy, wave
ROOT = Path(__file__).resolve().parents[1]
manager = (ROOT/"scripts/audio/game_audio.gd").read_text()
paths = re.findall(r'preload\("res://([^"]+\.wav)"\)', manager)
assert len(paths) == 21 and len(set(paths)) == 21
before = {}
for rel in paths:
    p = ROOT/rel
    before[rel] = hashlib.sha256(p.read_bytes()).hexdigest()
    with wave.open(str(p)) as f:
        assert (f.getnchannels(), f.getsampwidth(), f.getframerate()) == (1,2,44100), rel
        data = array.array("h", f.readframes(f.getnframes()))
    assert 0 < len(data)/44100 < 2.0, rel
    assert 1000 < max(abs(v) for v in data) < 30000, rel
    assert abs(data[0]) < 10 and abs(data[-1]) < 100, rel
runpy.run_path(str(ROOT/"tools/generate_samwar_sfx.py"), run_name="__main__")
assert all(hashlib.sha256((ROOT/r).read_bytes()).hexdigest()==h for r,h in before.items())
ids={Path(r).stem for r in paths}
for p in (ROOT/"scripts").rglob("*.gd"):
    for event in re.findall(r'GameAudio.play_sfx\("([a-z_]+)"',p.read_text()):
        assert event in ids,(p,event)
assert 'GameAudio="*res://scripts/audio/game_audio.gd"' in (ROOT/"project.godot").read_text()
assert 'node.bus = VIDEO_BUS' in manager
assert 'set_bus_mute(video_index, not _video_enabled or _video_volume <= 0.0)' in manager
assert 'RandomNumberGenerator.new()' in manager
print("PASS: 21 valid, reproducible WAVs; registered call IDs; autoload and video mute wiring")
print("NOT RUN: Godot parser, import, scene execution and listening QA")
