#!/usr/bin/env python3
from pathlib import Path
import re

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
# P-1C/P-1D superseded the B-0B skeleton wiring: Battle_Main now instances the
# production battle scene, and the BattleController bridge is inherited through
# BattleProductionController (asserted below and in validate_p1c_*).
assert 'path="res://scenes/battle/Battle_Production.tscn"' in scene
assert 'path="res://Battle_Land.tscn"' not in scene
assert 'type="Script"' not in scene
assert re.search(r'\[node name="Battle_Main"(?: unique_id=\d+)? instance=ExtResource\("1_base"\)\]', scene)
production_controller = (ROOT / "scripts/battle/battle_production_controller.gd").read_text(encoding="utf-8")
assert 'extends "res://scripts/battle/battle_controller.gd"' in production_controller

worldmap = worldmap_path.read_text(encoding="utf-8")
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"' in worldmap
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' not in worldmap

print("B-0B canonical battle production skeleton static validation: PASS")
