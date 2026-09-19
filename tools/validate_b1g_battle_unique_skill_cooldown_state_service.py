#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SERVICE_PATH = ROOT / "scripts/battle/services/battle_unique_skill_cooldown_state_service.gd"
UID_PATH = SERVICE_PATH.with_suffix(".gd.uid")
TEST_PATH = ROOT / "tests/scripts/test_battle_unique_skill_cooldown_state_service.gd"
CONTROLLER_PATH = ROOT / "scripts/battle_web_import_test.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"

assert SERVICE_PATH.exists(), "missing BattleUniqueSkillCooldownStateService"
assert UID_PATH.exists(), "missing BattleUniqueSkillCooldownStateService .gd.uid"
assert TEST_PATH.exists(), "missing focused cooldown state service test"

tracked = subprocess.run(
    ["git", "ls-files", "--error-unmatch", UID_PATH.relative_to(ROOT).as_posix()],
    cwd=ROOT,
    capture_output=True,
    text=True,
)
assert tracked.returncode == 0, "cooldown service .gd.uid is not tracked"
assert UID_PATH.read_text(encoding="utf-8").strip().startswith("uid://"), "invalid cooldown service UID"

service = SERVICE_PATH.read_text(encoding="utf-8")
controller = CONTROLLER_PATH.read_text(encoding="utf-8")
worldmap = WORLDMAP_PATH.read_text(encoding="utf-8")


def function_body(source: str, name: str) -> str:
    match = re.search(rf"^func {re.escape(name)}\b.*?(?=\n\nfunc |\Z)", source, re.M | re.S)
    assert match, f"missing function: {name}"
    return match.group(0)


assert "class_name BattleUniqueSkillCooldownStateService" in service
assert "extends RefCounted" in service
for api in ("clear", "set_remaining", "get_remaining", "tick_keys", "export_state", "restore_state"):
    assert re.search(rf"^func {api}\b", service, re.M), f"service API missing: {api}"

resource = "res://scripts/battle/services/battle_unique_skill_cooldown_state_service.gd"
assert resource in controller
assert "unique_skill_cooldown_state_service := BattleUniqueSkillCooldownStateServiceScript.new()" in controller
assert not re.search(r"^var unique_skill_cooldowns_by_hero_id\b", controller, re.M), "legacy cooldown dictionary still controller-owned"
assert "unique_skill_cooldowns_by_hero_id" not in controller, "legacy cooldown dictionary references remain"

set_wrapper = function_body(controller, "_set_unique_skill_cooldown")
tick_wrapper = function_body(controller, "_tick_unique_skill_cooldowns_for_side")
get_wrapper = function_body(controller, "_get_unique_skill_remaining_cooldown_turns")
reset_demo = function_body(controller, "reset_demo_state")
capture = function_body(controller, "_persist_battle_resume_snapshot")
restore = function_body(controller, "_try_restore_battle_resume_snapshot")

assert "_get_unique_skill_cooldown_key(unit_state)" in set_wrapper
assert "unique_skill_cooldown_state_service.set_remaining(cooldown_key, cooldown_turns)" in set_wrapper
assert "_get_alive_deployed_unit_states_for_side(side)" in tick_wrapper
assert "unique_skill_cooldown_state_service.tick_keys(cooldown_keys)" in tick_wrapper
assert "_tick_unique_skill_attack_buffs_for_side(side)" in tick_wrapper
assert tick_wrapper.index("unique_skill_cooldown_state_service.tick_keys(cooldown_keys)") < tick_wrapper.index("_tick_unique_skill_attack_buffs_for_side(side)")
assert "unique_skill_cooldown_state_service.get_remaining(cooldown_key)" in get_wrapper
assert "unique_skill_cooldown_state_service.clear()" in reset_demo
assert '"cooldowns": unique_skill_cooldown_state_service.export_state()' in capture
assert 'unique_skill_cooldown_state_service.restore_state(extra.get("cooldowns", {}))' in restore
assert "GameSession.save_battle_resume_snapshot" in capture
assert "GameSession.load_battle_resume_snapshot" in restore

for forbidden in (
    "BattleUnitState",
    "skill_data",
    "current_phase",
    "battle_round",
    "buff",
    "attack",
    "defense",
    "GameSession",
    "BattleRuntimeSnapshot",
    "WorldMap",
    "BattleResult",
    "BattleContext",
    "print(",
    "push_warning(",
    "signal ",
    "emit_signal",
    "await ",
    "Tween",
    "Audio",
):
    assert forbidden not in service, f"forbidden responsibility leaked into cooldown service: {forbidden}"

assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert "res://scenes/battle/Battle_Main.tscn" not in worldmap

print("B-1G BattleUniqueSkillCooldownStateService static validation: PASS")
