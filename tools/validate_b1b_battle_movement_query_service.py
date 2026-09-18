#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SERVICE_PATH = ROOT / "scripts/battle/services/battle_movement_query_service.gd"
UID_PATH = SERVICE_PATH.with_suffix(".gd.uid")
CONTROLLER_PATH = ROOT / "scripts/battle_web_import_test.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"

assert SERVICE_PATH.exists(), "missing production BattleMovementQueryService"
assert UID_PATH.exists(), "missing BattleMovementQueryService .gd.uid"
tracked = subprocess.run(
    ["git", "ls-files", "--error-unmatch", UID_PATH.relative_to(ROOT).as_posix()],
    cwd=ROOT,
    capture_output=True,
    text=True,
)
assert tracked.returncode == 0, "BattleMovementQueryService .gd.uid is not tracked"
assert UID_PATH.read_text(encoding="utf-8").strip().startswith("uid://"), "invalid service UID"

service = SERVICE_PATH.read_text(encoding="utf-8")
controller = CONTROLLER_PATH.read_text(encoding="utf-8")
worldmap = WORLDMAP_PATH.read_text(encoding="utf-8")

assert "class_name BattleMovementQueryService" in service
assert "extends RefCounted" in service
for marker in (
    "get_effective_move_range",
    "get_occupied_cells_except",
    "is_cell_occupied_except",
    "is_valid_destination_for_unit",
    "is_path_clear_for_unit",
    "is_cell_walkable",
    "find_move_path",
    "get_reachable_paths",
    "get_unit_grid_distance",
):
    assert re.search(rf"^func {marker}\b", service, re.M), f"service API missing: {marker}"

direction_markers = (
    "Vector2i(1, 0)",
    "Vector2i(-1, 0)",
    "Vector2i(0, 1)",
    "Vector2i(0, -1)",
)
positions = [service.index(marker) for marker in direction_markers]
assert positions == sorted(positions), "BFS direction order changed"

service_resource = "res://scripts/battle/services/battle_movement_query_service.gd"
assert service_resource in controller, "battle controller does not preload movement query service"
assert "movement_query_service := BattleMovementQueryServiceScript.new()" in controller, "battle controller does not own movement query service"

wrappers = (
    "_get_effective_move_range",
    "_get_occupied_cells_except",
    "_is_cell_occupied_except",
    "_is_valid_destination_for_unit",
    "_is_path_clear_for_unit",
    "_is_cell_walkable_for_ally",
    "_find_ally_move_path",
    "_is_cell_walkable_for_enemy_actor",
    "_find_enemy_move_path_for_actor",
    "_find_enemy_path_to_destination_for_actor",
    "_get_enemy_reachable_paths_for_actor",
    "get_unit_grid_distance",
)
for wrapper in wrappers:
    assert re.search(rf"^func {re.escape(wrapper)}\b", controller, re.M), f"compatibility wrapper missing: {wrapper}"

assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert 'res://scenes/battle/Battle_Main.tscn' not in worldmap
for forbidden in ("WorldMap", "worldmap", "BattleResult", "battle_result", "BattleContext", "battle_context"):
    assert forbidden not in service, f"forbidden responsibility leaked into movement service: {forbidden}"

print("B-1B BattleMovementQueryService static validation: PASS")
