#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SERVICE_PATH = ROOT / "scripts/battle/services/battle_combat_query_service.gd"
UID_PATH = SERVICE_PATH.with_suffix(".gd.uid")
CONTROLLER_PATH = ROOT / "scripts/battle_web_import_test.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"

assert SERVICE_PATH.exists(), "missing production BattleCombatQueryService"
assert UID_PATH.exists(), "missing BattleCombatQueryService .gd.uid"
tracked = subprocess.run(
    ["git", "ls-files", "--error-unmatch", UID_PATH.relative_to(ROOT).as_posix()],
    cwd=ROOT,
    capture_output=True,
    text=True,
)
assert tracked.returncode == 0, "BattleCombatQueryService .gd.uid is not tracked"
assert UID_PATH.read_text(encoding="utf-8").strip().startswith("uid://"), "invalid combat service UID"

service = SERVICE_PATH.read_text(encoding="utf-8")
controller = CONTROLLER_PATH.read_text(encoding="utf-8")
worldmap = WORLDMAP_PATH.read_text(encoding="utf-8")

assert "class_name BattleCombatQueryService" in service
assert "extends RefCounted" in service
for marker in (
    "get_direction_from_positions",
    "get_opposite_facing",
    "get_attack_angle_type",
    "is_unit_in_attack_range",
):
    assert re.search(rf"^func {marker}\b", service, re.M), f"service API missing: {marker}"

resource = "res://scripts/battle/services/battle_combat_query_service.gd"
assert resource in controller, "battle controller does not preload combat query service"
assert "combat_query_service := BattleCombatQueryServiceScript.new()" in controller, "battle controller does not own combat query service"

wrappers = (
    "_get_direction_from_positions",
    "_get_opposite_facing",
    "_get_attack_angle_type",
    "is_unit_in_attack_range",
)
for wrapper in wrappers:
    assert re.search(rf"^func {re.escape(wrapper)}\b", controller, re.M), f"compatibility wrapper missing: {wrapper}"

assert "combat_query_service.get_direction_from_positions" in controller
assert "combat_query_service.get_opposite_facing" in controller
assert "combat_query_service.get_attack_angle_type" in controller
assert "combat_query_service.is_unit_in_attack_range" in controller

# Damage resolution stays in the controller in B-1C.
assert re.search(r"^func _get_attack_angle_damage_multiplier\b", controller, re.M)
assert re.search(r"^func _get_directional_attack_damage\b", controller, re.M)
assert "UnitTypeContractScript.get_damage_context" in controller
for forbidden in (
    "get_damage_context",
    "apply_damage",
    "damage_multiplier",
    "WorldMap",
    "worldmap",
    "BattleResult",
    "battle_result",
    "BattleContext",
    "battle_context",
    "Tween",
    "await ",
    "enemy_ai",
):
    assert forbidden not in service, f"forbidden responsibility leaked into combat query service: {forbidden}"

assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert 'res://scenes/battle/Battle_Main.tscn' not in worldmap

print("B-1C BattleCombatQueryService static validation: PASS")
