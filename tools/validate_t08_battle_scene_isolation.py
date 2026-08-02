#!/usr/bin/env python3
"""Validate the runtime legacy battle scene and the isolated T08 production HUD scene."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
GAME_SCENE_PATH = ROOT / "Battle_Land.tscn"
TEST_SCENE_PATH = ROOT / "tests/scenes/Battle_UI_Production_Test.tscn"
BATTLE_SCRIPT_PATH = ROOT / "scripts/battle_web_import_test.gd"
MOMENTUM_PATH = ROOT / "scripts/battle/battle_momentum_state.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"
PROJECT_PATH = ROOT / "project.godot"
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def nodes(source: str) -> dict[str, tuple[int, str, str]]:
    records: dict[str, tuple[int, str, str]] = {}
    pattern = re.compile(r'^\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?[^\]]*\]$', re.M)
    for match in pattern.finditer(source):
        name, node_type, parent = match.groups()
        parent = parent or ""
        path = f"{parent}/{name}" if parent not in ("", ".") else name
        line = source.count("\n", 0, match.start()) + 1
        records[path] = (line, parent, node_type)
    return records


def validate_scene_source(label: str, path: Path, source: str) -> dict[str, tuple[int, str, str]]:
    records = nodes(source)
    require(bool(records), f"{label}: no scene nodes parsed")
    for line_number, line in enumerate(source.splitlines(), 1):
        stripped = line.strip()
        require(not (stripped in {"+", "-"} or stripped.startswith(("@@", "<<<<<<<", "=======", ">>>>>>>"))),
                f"{label}: malformed patch/conflict marker at line {line_number}")
    for node_path, (line, parent, _node_type) in records.items():
        if parent and parent != ".":
            require(parent in records, f"{label}: missing parent {parent} for {node_path}")
            if parent in records:
                require(records[parent][0] < line, f"{label}: parent declared after child {node_path}")
    for resource_path in re.findall(r'path="res://([^"]+)"', source):
        require((ROOT / resource_path).exists(), f"{label}: missing ext_resource res://{resource_path}")
    return records


require(GAME_SCENE_PATH.exists(), "missing runtime Battle_Land.tscn")
require(TEST_SCENE_PATH.exists(), "missing production HUD test scene")
game = GAME_SCENE_PATH.read_text(encoding="utf-8")
test = TEST_SCENE_PATH.read_text(encoding="utf-8")
battle = BATTLE_SCRIPT_PATH.read_text(encoding="utf-8")
momentum = MOMENTUM_PATH.read_text(encoding="utf-8")
worldmap = WORLDMAP_PATH.read_text(encoding="utf-8")
project = PROJECT_PATH.read_text(encoding="utf-8")
game_nodes = validate_scene_source("runtime", GAME_SCENE_PATH, game)
test_nodes = validate_scene_source("test", TEST_SCENE_PATH, test)

require('script = ExtResource("1_script")' in game, "runtime root script connection missing")
require('script = ExtResource("1_script")' in test, "test root script connection missing")
require("ProductionHudRoot" not in game, "runtime scene still exposes ProductionHudRoot")
require("BattleUI/ProductionHudRoot" in test_nodes, "test scene missing ProductionHudRoot")
for path in ("BattleUI/TopBar", "BattleUI/TopBar/TurnBanner", "BattleUI/CommandBar",
             "BattleUI/BattleMiniLogPanel", "BattleUI/FormationSlotGuideLayer", "Slots",
             "AllySide", "EnemySide", "BattleUI/SkillCutinLayer", "ResultOverlay",
             "EnemyRetreatToastLayer"):
    require(path in game_nodes, f"runtime legacy/latest node missing: {path}")
for side in ("Ally", "Enemy"):
    row = f"BattleUI/ProductionHudRoot/TopHudRoot/{side}MomentumHud/SlotRow"
    require(sum(path.startswith(row + "/Slot") for path in test_nodes) == 10,
            f"test {side} momentum must have 10 slots")
require("BattleUI/ProductionHudRoot/TopHudRoot/TurnHud" in test_nodes, "test TurnHud missing")
require("get_node_or_null(\"BattleUI/ProductionHudRoot\")" in battle,
        "Production HUD NodePath is not optional")
require("func _refresh_production_battle_hud" in battle and "if production_hud_root == null:" in battle,
        "Production HUD refresh is not null-safe")
require("const STARTING_MOMENTUM := 3" in momentum, "STARTING_MOMENTUM must remain 3")
require("const MAX_MOMENTUM := 10" in momentum, "MAX_MOMENTUM must remain 10")
require("BATTLE_MAX_TURNS := 30" in (ROOT / "scripts/t02/expedition_supply_calculator.gd").read_text(encoding="utf-8"),
        "MAX_TURN must remain 30")
require('WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap,
        "WorldMap battle entry no longer targets Battle_Land.tscn")
require("Battle_UI_Production_Test.tscn" not in worldmap and "Battle_UI_Production_Test.tscn" not in project,
        "test scene leaked into runtime entry path")

if errors:
    print("T08 BATTLE SCENE ISOLATION VALIDATION FAILED", file=sys.stderr)
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
print("T08 BATTLE SCENE ISOLATION PASS: legacy runtime scene, isolated production HUD scene, paths, resources, contracts")
