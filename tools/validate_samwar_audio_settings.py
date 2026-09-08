"""Static settings integration guard. Runtime persistence/listening require Godot."""
from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[1]
manager = (ROOT / "scripts/audio/game_audio.gd").read_text()
panel = (ROOT / "WorldMapAudioSettings.tscn").read_text()
controller = (ROOT / "scripts/worldmap/ui/worldmap_audio_settings.gd").read_text()
nav = (ROOT / "scripts/worldmap/ui/worldmap_top_nav.gd").read_text()
nav_scene = (ROOT / "WorldMapTopNav.tscn").read_text()
assert 'elif menu_id == &"system":' in nav and '$AudioSettingsPopup.popup_centered()' in nav
assert 'path="res://WorldMapAudioSettings.tscn"' in nav_scene
assert '[node name="AudioSettingsPopup" parent="." instance=' in nav_scene
nodes = set()
for name, parent in re.findall(r'\[node name="([^"]+)"[^\n]*parent="([^"]+)"', panel):
    nodes.add(name if parent == "." else parent + "/" + name)
for path in re.findall(r'\$([A-Za-z0-9_/]+)', controller):
    assert path in nodes, path
methods = set(re.findall(r'^func (\w+)\(', manager, re.M))
for method in re.findall(r'GameAudio\.(\w+)', controller):
    assert method in methods, method
for section, key in [("sfx", "enabled"),("sfx","volume"),("sfx","duplicate_limit"),("video","enabled"),("video","volume")]:
    assert f'config.get_value("{section}", "{key}",' in manager, (section,key,"load")
    assert f'config.set_value("{section}", "{key}",' in manager, (section,key,"save")
assert 'var _video_enabled := false' in manager
assert 'if _duplicate_limit_enabled and now -' in manager
assert 'set_bus_mute(video_index, not _video_enabled or _video_volume <= 0.0)' in manager
for rel in ['scripts/audio/game_audio.gd','scripts/ui/cutin/hero_cutin_presentation.gd','scripts/worldmap/ui/worldmap_action_presentation_controller.gd']:
    assert not re.search(r'volume_db\s*=.*-80', (ROOT/rel).read_text()), rel
assert 'set_pressed_no_signal' in controller and 'set_value_no_signal' in controller
print("PASS: system menu -> scene -> controls -> audio methods; five persisted settings; no forced video mute")
print("NOT RUN: Godot UI/scene parsing, settings roundtrip, playback and listening")
