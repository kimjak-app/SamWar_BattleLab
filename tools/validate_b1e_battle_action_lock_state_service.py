#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SERVICE_PATH = ROOT / "scripts/battle/services/battle_action_lock_state_service.gd"
UID_PATH = SERVICE_PATH.with_suffix(".gd.uid")
TEST_PATH = ROOT / "tests/scripts/test_battle_action_lock_state_service.gd"
CONTROLLER_PATH = ROOT / "scripts/battle_web_import_test.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"

assert SERVICE_PATH.exists(), "missing production BattleActionLockStateService"
assert UID_PATH.exists(), "missing BattleActionLockStateService .gd.uid"
assert TEST_PATH.exists(), "missing focused BattleActionLockStateService test"
tracked = subprocess.run(
    ["git", "ls-files", "--error-unmatch", UID_PATH.relative_to(ROOT).as_posix()],
    cwd=ROOT,
    capture_output=True,
    text=True,
)
assert tracked.returncode == 0, "BattleActionLockStateService .gd.uid is not tracked"
assert UID_PATH.read_text(encoding="utf-8").strip().startswith("uid://"), "invalid action-lock service UID"

service = SERVICE_PATH.read_text(encoding="utf-8")
controller = CONTROLLER_PATH.read_text(encoding="utf-8")
worldmap = WORLDMAP_PATH.read_text(encoding="utf-8")


def function_body(source: str, name: str) -> str:
    match = re.search(rf"^func {re.escape(name)}\b.*?(?=\n\nfunc |\Z)", source, re.M | re.S)
    assert match, f"missing function: {name}"
    return match.group(0)


assert "class_name BattleActionLockStateService" in service
assert "extends RefCounted" in service
for api in (
    "has_unit_acted",
    "register_unit_acted",
    "clear_side",
    "erase_unit_id",
    "export_acted_ids",
    "restore_acted_ids",
    "count_unacted",
    "first_unacted",
    "are_all_acted",
):
    assert re.search(rf"^func {api}\b", service, re.M), f"service API missing: {api}"

resource = "res://scripts/battle/services/battle_action_lock_state_service.gd"
assert resource in controller, "battle controller does not preload action-lock state service"
assert "action_lock_state_service := BattleActionLockStateServiceScript.new()" in controller
assert not re.search(r"^var acted_(ally|enemy)_unit_ids\b", controller, re.M), "legacy acted registry still owned by controller"

wrappers = (
    "_mark_ally_unit_acted",
    "_has_ally_unit_acted",
    "_reset_ally_action_locks_for_new_round",
    "_mark_enemy_unit_acted",
    "_has_enemy_unit_acted",
    "_reset_enemy_action_locks_for_new_round",
    "_are_all_alive_enemies_acted",
    "_are_all_alive_allies_acted",
    "_get_next_available_enemy_ai_actor",
    "_get_first_available_ally_unit",
    "_get_remaining_unacted_enemy_count",
)
for wrapper in wrappers:
    assert re.search(rf"^func {re.escape(wrapper)}\b", controller, re.M), f"compatibility wrapper missing: {wrapper}"

ally_mark = function_body(controller, "_mark_ally_unit_acted")
enemy_mark = function_body(controller, "_mark_enemy_unit_acted")
for body, side in ((ally_mark, "ally"), (enemy_mark, "enemy")):
    assert f'action_lock_state_service.register_unit_acted(unit_state, "{side}")' in body
    assert "unit_state.has_acted = true" in body
    assert "unit_state.has_moved = true" in body
    assert "_consume_strategy_status_after_unit_action(unit_state)" in body
assert "ally_has_moved = true" in ally_mark
assert "[ENEMY_TURN]" in enemy_mark
assert "_get_remaining_unacted_enemy_count()" in enemy_mark

ally_reset = function_body(controller, "_reset_ally_action_locks_for_new_round")
enemy_reset = function_body(controller, "_reset_enemy_action_locks_for_new_round")
assert 'action_lock_state_service.clear_side("ally")' in ally_reset
assert "unit_state.reset_action_flags()" in ally_reset
assert "ally_has_moved = false" in ally_reset
assert 'action_lock_state_service.clear_side("enemy")' in enemy_reset
assert "_clear_enemy_ai_turn_reservations()" in enemy_reset
assert "unit_state.reset_action_flags()" in enemy_reset

enemy_all = function_body(controller, "_are_all_alive_enemies_acted")
ally_all = function_body(controller, "_are_all_alive_allies_acted")
assert "if alive_enemies.is_empty():\n\t\treturn true" in enemy_all
assert "if alive_allies.is_empty():\n\t\treturn false" in ally_all
assert 'action_lock_state_service.are_all_acted(alive_enemies, "enemy")' in enemy_all
assert 'action_lock_state_service.are_all_acted(alive_allies, "ally")' in ally_all

enemy_actor = function_body(controller, "_get_next_available_enemy_ai_actor")
assert enemy_actor.index("enemy_unit_state") < enemy_actor.index("enemy_support_unit_state")
assert enemy_actor.index("enemy_support_unit_state") < enemy_actor.index("enemy_main_03_unit_state")
assert enemy_actor.index("enemy_main_03_unit_state") < enemy_actor.index("enemy_reinforce_01_unit_state")
assert enemy_actor.index("enemy_reinforce_01_unit_state") < enemy_actor.index("enemy_reinforce_02_unit_state")
assert 'action_lock_state_service.first_unacted(available_candidates, "enemy")' in enemy_actor

capture = function_body(controller, "_persist_battle_resume_snapshot")
restore = function_body(controller, "_try_restore_battle_resume_snapshot")
assert '"acted_ally_unit_ids": action_lock_state_service.export_acted_ids("ally")' in capture
assert '"acted_enemy_unit_ids": action_lock_state_service.export_acted_ids("enemy")' in capture
assert 'action_lock_state_service.restore_acted_ids("ally", extra.get("acted_ally_unit_ids", {}))' in restore
assert 'action_lock_state_service.restore_acted_ids("enemy", extra.get("acted_enemy_unit_ids", {}))' in restore
assert restore.index("BattleRuntimeSnapshotScript.restore(") < restore.index("action_lock_state_service.restore_acted_ids")
assert "GameSession.save_battle_resume_snapshot" in capture
assert "GameSession.load_battle_resume_snapshot" in restore

cleanup = function_body(controller, "_cleanup_dead_units")
assert "action_lock_state_service.erase_unit_id(unit_state.unit_id)" in cleanup
assert "acted_ally_unit_ids.erase" not in cleanup and "acted_enemy_unit_ids.erase" not in cleanup
reset_demo = function_body(controller, "reset_demo_state")
assert 'action_lock_state_service.clear_side("enemy")' in reset_demo
assert reset_demo.index('action_lock_state_service.clear_side("enemy")') < reset_demo.index("_clear_enemy_ai_turn_reservations()")

for forbidden in (
    "unit_state.has_acted =",
    "unit_state.has_moved =",
    "reset_action_flags(",
    "status_effect",
    "battle_log",
    "print(",
    "push_warning(",
    "GameSession",
    "BattleRuntimeSnapshot",
    "current_phase",
    "battle_round",
    "enemy_ai",
    "WorldMap",
    "BattleResult",
    "BattleContext",
    "signal ",
    "emit_signal",
    "await ",
    "Tween",
    "Audio",
):
    assert forbidden not in service, f"forbidden responsibility leaked into action-lock service: {forbidden}"

assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert "res://scenes/battle/Battle_Main.tscn" not in worldmap

print("B-1E BattleActionLockStateService static validation: PASS")
