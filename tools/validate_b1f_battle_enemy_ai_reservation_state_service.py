#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SERVICE_PATH = ROOT / "scripts/battle/services/battle_enemy_ai_reservation_state_service.gd"
UID_PATH = SERVICE_PATH.with_suffix(".gd.uid")
TEST_PATH = ROOT / "tests/scripts/test_battle_enemy_ai_reservation_state_service.gd"
CONTROLLER_PATH = ROOT / "scripts/battle_web_import_test.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"

assert SERVICE_PATH.exists(), "missing production BattleEnemyAiReservationStateService"
assert UID_PATH.exists(), "missing BattleEnemyAiReservationStateService .gd.uid"
assert TEST_PATH.exists(), "missing focused BattleEnemyAiReservationStateService test"

tracked = subprocess.run(
    ["git", "ls-files", "--error-unmatch", UID_PATH.relative_to(ROOT).as_posix()],
    cwd=ROOT,
    capture_output=True,
    text=True,
)
assert tracked.returncode == 0, "BattleEnemyAiReservationStateService .gd.uid is not tracked"
assert UID_PATH.read_text(encoding="utf-8").strip().startswith("uid://"), "invalid reservation service UID"

service = SERVICE_PATH.read_text(encoding="utf-8")
controller = CONTROLLER_PATH.read_text(encoding="utf-8")
worldmap = WORLDMAP_PATH.read_text(encoding="utf-8")


def function_body(source: str, name: str) -> str:
    match = re.search(rf"^func {re.escape(name)}\b.*?(?=\n\nfunc |\Z)", source, re.M | re.S)
    assert match, f"missing function: {name}"
    return match.group(0)


assert "class_name BattleEnemyAiReservationStateService" in service
assert "extends RefCounted" in service
for api in (
    "clear_turn_reservations",
    "is_destination_reserved_for_other_actor",
    "is_engagement_reserved_for_other_actor",
    "reserve_decision_plan",
):
    assert re.search(rf"^func {api}\b", service, re.M), f"service API missing: {api}"

resource = "res://scripts/battle/services/battle_enemy_ai_reservation_state_service.gd"
assert resource in controller, "battle controller does not preload reservation state service"
assert "enemy_ai_reservation_state_service := BattleEnemyAiReservationStateServiceScript.new()" in controller
assert not re.search(r"^var enemy_ai_reserved_(destination|engagement)_cells\b", controller, re.M), "legacy reservation dictionary still owned by controller"

clear_wrapper = function_body(controller, "_clear_enemy_ai_turn_reservations")
destination_wrapper = function_body(controller, "_is_enemy_ai_destination_cell_reserved_for_other_actor")
engagement_wrapper = function_body(controller, "_is_enemy_ai_engagement_cell_reserved_for_other_actor")
reserve_wrapper = function_body(controller, "_reserve_enemy_ai_decision_plan_for_actor")
can_use_wrapper = function_body(controller, "_can_enemy_ai_use_destination_cell")
enemy_reset = function_body(controller, "_reset_enemy_action_locks_for_new_round")

assert "enemy_ai_reservation_state_service.clear_turn_reservations()" in clear_wrapper

assert "if enemy_actor_state == null:" in destination_wrapper
assert "return false" in destination_wrapper
assert "_get_capacity_slot_id_for_unit_state(enemy_actor_state)" in destination_wrapper
assert "enemy_ai_reservation_state_service.is_destination_reserved_for_other_actor(cell, enemy_actor_state.grid_cell, actor_slot_id)" in destination_wrapper

assert "if enemy_actor_state == null:" in engagement_wrapper
assert "return false" in engagement_wrapper
assert "_get_capacity_slot_id_for_unit_state(enemy_actor_state)" in engagement_wrapper
assert "enemy_ai_reservation_state_service.is_engagement_reserved_for_other_actor(cell, enemy_actor_state.grid_cell, actor_slot_id)" in engagement_wrapper

assert "if enemy_actor_state == null or decision_plan.is_empty():" in reserve_wrapper
assert "_get_capacity_slot_id_for_unit_state(enemy_actor_state)" in reserve_wrapper
assert "enemy_ai_reservation_state_service.reserve_decision_plan(enemy_actor_state.grid_cell, actor_slot_id, decision_plan)" in reserve_wrapper

assert "_is_valid_destination_for_unit(cell, enemy_actor_state)" in can_use_wrapper
assert "_is_enemy_ai_destination_cell_reserved_for_other_actor(cell, enemy_actor_state)" in can_use_wrapper

assert 'action_lock_state_service.clear_side("enemy")' in enemy_reset
assert "_clear_enemy_ai_turn_reservations()" in enemy_reset
assert "unit_state.reset_action_flags()" in enemy_reset
assert enemy_reset.index("_clear_enemy_ai_turn_reservations()") < enemy_reset.index("unit_state.reset_action_flags()")

for legacy in (
    "enemy_ai_reserved_destination_cells",
    "enemy_ai_reserved_engagement_cells",
):
    assert legacy not in controller, f"legacy controller reservation ownership remains: {legacy}"

for forbidden in (
    "BattleUnitState",
    "_is_valid_destination_for_unit",
    "_find_",
    "score",
    "target",
    "current_phase",
    "battle_round",
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
    assert forbidden not in service, f"forbidden responsibility leaked into reservation service: {forbidden}"

assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert "res://scenes/battle/Battle_Main.tscn" not in worldmap

print("B-1F BattleEnemyAiReservationStateService static validation: PASS")
