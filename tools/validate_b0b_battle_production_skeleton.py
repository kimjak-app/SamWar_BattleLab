#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

controller_path = ROOT / "scripts/battle/battle_controller.gd"
uid_path = ROOT / "scripts/battle/battle_controller.gd.uid"
scene_path = ROOT / "scenes/battle/Battle_Main.tscn"
worldmap_path = ROOT / "scripts/worldmap/worldmap_main.gd"
audit_path = ROOT / "agent/BATTLE_RUNTIME_OWNERSHIP_AUDIT_20260918.md"

for path in [controller_path, uid_path, scene_path, worldmap_path, audit_path]:
    assert path.exists(), f"missing required path: {path.relative_to(ROOT)}"

controller = controller_path.read_text(encoding="utf-8")
assert 'extends "res://scripts/battle_web_import_test.gd"' in controller
assert "class_name BattleController" in controller
assert "\nfunc " not in controller, "B-0B controller must remain an override-free bridge"

uid = uid_path.read_text(encoding="utf-8").strip()
assert uid == "uid://d9b0ctlprod26", f"unexpected controller UID: {uid}"

scene = scene_path.read_text(encoding="utf-8")
assert 'path="res://Battle_Land.tscn"' in scene
assert 'path="res://scripts/battle/battle_controller.gd"' in scene
assert 'uid="uid://d9b0ctlprod26"' in scene
assert '[node name="Battle_Fullscreen_Test" instance=ExtResource("1_base")]' in scene
assert 'script = ExtResource("2_controller")' in scene

worldmap = worldmap_path.read_text(encoding="utf-8")
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"' not in worldmap

print("B-0B canonical battle production skeleton static validation: PASS")
