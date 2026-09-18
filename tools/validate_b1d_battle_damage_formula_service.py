#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SERVICE_PATH = ROOT / "scripts/battle/services/battle_damage_formula_service.gd"
UID_PATH = SERVICE_PATH.with_suffix(".gd.uid")
TEST_PATH = ROOT / "tests/scripts/test_battle_damage_formula_service.gd"
CONTROLLER_PATH = ROOT / "scripts/battle_web_import_test.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"

assert SERVICE_PATH.exists(), "missing production BattleDamageFormulaService"
assert UID_PATH.exists(), "missing BattleDamageFormulaService .gd.uid"
assert TEST_PATH.exists(), "missing focused BattleDamageFormulaService test"
tracked = subprocess.run(
    ["git", "ls-files", "--error-unmatch", UID_PATH.relative_to(ROOT).as_posix()],
    cwd=ROOT,
    capture_output=True,
    text=True,
)
assert tracked.returncode == 0, "BattleDamageFormulaService .gd.uid is not tracked"
assert UID_PATH.read_text(encoding="utf-8").strip().startswith("uid://"), "invalid damage formula service UID"

service = SERVICE_PATH.read_text(encoding="utf-8")
controller = CONTROLLER_PATH.read_text(encoding="utf-8")
worldmap = WORLDMAP_PATH.read_text(encoding="utf-8")

assert "class_name BattleDamageFormulaService" in service
assert "extends RefCounted" in service
for api in ("get_attack_angle_damage_multiplier", "calculate_pre_wounded_damage"):
    assert re.search(rf"^func {api}\b", service, re.M), f"service API missing: {api}"

resource = "res://scripts/battle/services/battle_damage_formula_service.gd"
assert resource in controller, "battle controller does not preload damage formula service"
assert "damage_formula_service := BattleDamageFormulaServiceScript.new()" in controller, "battle controller does not own damage formula service"

def function_body(source: str, name: str) -> str:
    match = re.search(rf"^func {re.escape(name)}\b.*?(?=\n\nfunc |\Z)", source, re.M | re.S)
    assert match, f"missing function: {name}"
    return match.group(0)

angle_wrapper = function_body(controller, "_get_attack_angle_damage_multiplier")
damage_wrapper = function_body(controller, "_get_directional_attack_damage")
assert "damage_formula_service.get_attack_angle_damage_multiplier(angle_type)" in angle_wrapper
assert "damage_formula_service.calculate_pre_wounded_damage" in damage_wrapper
assert "UnitTypeContractScript.get_damage_context" not in controller, "formula core remains duplicated in controller"
for moved_constant in (
    "FRONT_ATTACK_DAMAGE_MULTIPLIER",
    "SIDE_ATTACK_DAMAGE_MULTIPLIER",
    "BACK_ATTACK_DAMAGE_MULTIPLIER",
    "STRATEGY_SHAKE_ATTACK_MULTIPLIER",
    "STRATEGY_SHAKE_DEFENSE_DAMAGE_MULTIPLIER",
    "DEFEND_DAMAGE_MULTIPLIER",
):
    assert moved_constant not in controller, f"formula constant remains duplicated in controller: {moved_constant}"

caller_count = len(re.findall(r"_get_directional_attack_damage\(", controller)) - 1
assert caller_count == 7, f"expected seven compatibility-wrapper callers, found {caller_count}"
assert len(re.findall(r"_get_directional_attack_damage\([^\n]*, false, false\)", controller)) == 2, "skill projection/resolver wounded flags changed"
assert len(re.findall(r"_get_directional_attack_damage\([^\n]*, false, true\)", controller)) == 2, "skill damage wounded flags changed"

service_call = damage_wrapper.index("damage_formula_service.calculate_pre_wounded_damage")
attacker_wounded = damage_wrapper.index("if apply_attacker_wounded_penalty:")
attacker_adjustment = damage_wrapper.index("_apply_wounded_amount_multiplier")
defender_adjustment = damage_wrapper.index("_apply_wounded_incoming_damage_penalty")
assert service_call < attacker_wounded < attacker_adjustment < defender_adjustment, "controller wounded tail order changed"
assert "should_log_wounded_penalty" in damage_wrapper

ordered_formula_markers = (
    "get_attack_angle_damage_multiplier(angle_type)",
    "get_damage_context",
    'unit_context.get("base_damage_modifier"',
    'unit_context.get("matchup_modifier"',
    'unit_context.get("side_or_rear_modifier"',
    'unit_context.get("received_damage_modifier"',
    'get_number(UNIT_TYPE_GUNNER, "prepared_fire_bonus")',
    'has_status_effect("post_fire_penalty")',
    "STRATEGY_SHAKE_ATTACK_MULTIPLIER",
    "STRATEGY_SHAKE_DEFENSE_DAMAGE_MULTIPLIER",
    "is_defending",
    'has_status_effect("attack_defense_up")',
    'has_status_effect("counter_up")',
    'has_status_effect("defense_up")',
    'has_status_effect("damage_reduction")',
    'has_status_effect("formation_break")',
    'has_status_effect("incoming_damage_down")',
    "var damage := maxi(1, int(round(",
    'unit_context.get("armor_ignore_ratio"',
    "damage = maxi(1, int(round(",
)
formula_body = function_body(service, "calculate_pre_wounded_damage")
positions = [formula_body.index(marker) for marker in ordered_formula_markers]
assert positions == sorted(positions), "damage formula modifier or rounding order changed"
assert formula_body.count("round(") == 2, "damage formula must preserve exactly two rounding stages"

for forbidden in (
    "_is_unit_hero_wounded",
    "_get_wounded_penalty_multiplier",
    "_apply_wounded_amount_multiplier",
    "_apply_wounded_incoming_damage_penalty",
    "_log_wounded_penalty",
    "HeroDesignDataRegistry",
    "apply_damage",
    "BattleResult",
    "BattleContext",
    "WorldMap",
    "enemy_ai",
    "target_selection",
    "signal ",
    "emit_signal",
    "await ",
    "Tween",
    "Audio",
):
    assert forbidden not in service, f"forbidden responsibility leaked into damage formula service: {forbidden}"

assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert 'res://scenes/battle/Battle_Main.tscn' not in worldmap

print("B-1D BattleDamageFormulaService static validation: PASS")
