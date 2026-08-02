#!/usr/bin/env python3
"""Validate the T08-3A Theme/Font first pass is isolated to the production HUD test scene."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SCENE_PATH = ROOT / "tests/scenes/Battle_UI_Production_Test.tscn"
THEME_PATH = ROOT / "assets/ui/battle_ui_theme.tres"
GAME_SCENE_PATH = ROOT / "Battle_Land.tscn"
MOMENTUM_PATH = ROOT / "scripts/battle/battle_momentum_state.gd"
TURN_PATH = ROOT / "scripts/t02/expedition_supply_calculator.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"
PROJECT_PATH = ROOT / "project.godot"
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def parse_nodes(source: str) -> dict[str, tuple[int, str, str, str]]:
    records: dict[str, tuple[int, str, str, str]] = {}
    pattern = re.compile(r'^\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?[^\]]*\]$', re.M)
    matches = list(pattern.finditer(source))
    for index, match in enumerate(matches):
        name, node_type, parent = match.groups()
        parent = parent or ""
        path = f"{parent}/{name}" if parent not in ("", ".") else name
        line = source.count("\n", 0, match.start()) + 1
        body_end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        records[path] = (line, parent, node_type, source[match.end():body_end])
    return records


def git_output(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True, check=False).stdout


scene = SCENE_PATH.read_text(encoding="utf-8")
theme = THEME_PATH.read_text(encoding="utf-8")
game_scene = GAME_SCENE_PATH.read_text(encoding="utf-8")
momentum = MOMENTUM_PATH.read_text(encoding="utf-8")
turns = TURN_PATH.read_text(encoding="utf-8")
worldmap = WORLDMAP_PATH.read_text(encoding="utf-8")
project = PROJECT_PATH.read_text(encoding="utf-8")
nodes = parse_nodes(scene)

for line_number, line in enumerate(scene.splitlines(), 1):
    stripped = line.strip()
    require(not (stripped in {"+", "-"} or stripped.startswith(("@@", "<<<<<<<", "=======", ">>>>>>>"))),
            f"malformed patch/conflict marker at scene line {line_number}")
for path, (line, parent, _node_type, _body) in nodes.items():
    if parent and parent != ".":
        require(parent in nodes, f"missing parent {parent} for {path}")
        if parent in nodes:
            require(nodes[parent][0] < line, f"parent declared after child {path}")

require(THEME_PATH.exists(), "missing battle_ui_theme.tres")
for font_name in ("NotoSerifKR-Bold.otf", "NotoSerifKR-Medium.otf", "NotoSerifKR-Regular.otf"):
    font_path = ROOT / "assets/font/noto_serif_kr" / font_name
    require(font_path.exists(), f"missing required NotoSerifKR font {font_name}")
    require(f"res://assets/font/noto_serif_kr/{font_name}" in theme, f"theme does not reference {font_name}")
for variation in ("BattleHudPanel", "AllyMomentumPanel", "TurnHudPanel", "EnemyMomentumPanel",
                  "BattleHudTitle", "BattleHudValue", "BattleHudSecondary", "BattleHudSlotRow",
                  "MomentumSlotAllyFilled", "MomentumSlotAllyEmpty", "MomentumSlotEnemyFilled", "MomentumSlotEnemyEmpty"):
    require(f"{variation}/base_type" in theme, f"theme variation missing: {variation}")

top_root = "BattleUI/ProductionHudRoot/TopHudRoot"
for panel, variation in (("AllyMomentumHud", "AllyMomentumPanel"), ("TurnHud", "TurnHudPanel"), ("EnemyMomentumHud", "EnemyMomentumPanel")):
    path = f"{top_root}/{panel}"
    require(path in nodes, f"missing top HUD panel {path}")
    if path in nodes:
        body = nodes[path][3]
        require('theme = ExtResource("38_battle_ui_theme")' in body, f"{panel} does not use battle UI Theme")
        require(f'theme_type_variation = &"{variation}"' in body, f"{panel} variation missing")

for label, variation in (("AllyMomentumHud/Frame", "BattleHudTitle"), ("AllyMomentumHud/ValueLabel", "BattleHudValue"),
                         ("TurnHud/Frame", "BattleHudTitle"), ("TurnHud/TurnLabel", "BattleHudValue"),
                         ("TurnHud/ActiveSideLabel", "BattleHudSecondary"), ("TurnHud/BattleTitleLabel", "BattleHudTitle"),
                         ("EnemyMomentumHud/Frame", "BattleHudTitle"), ("EnemyMomentumHud/ValueLabel", "BattleHudValue")):
    path = f"{top_root}/{label}"
    require(path in nodes and f'theme_type_variation = &"{variation}"' in nodes[path][3], f"missing {variation} on {path}")

for label in ("AllyMomentumHud/Frame", "AllyMomentumHud/ValueLabel", "TurnHud/Frame", "TurnHud/TurnLabel",
              "TurnHud/ActiveSideLabel", "TurnHud/BattleTitleLabel", "EnemyMomentumHud/Frame", "EnemyMomentumHud/ValueLabel"):
    path = f"{top_root}/{label}"
    require("horizontal_alignment = 1" in nodes[path][3], f"{path} is not center aligned")

for side in ("Ally", "Enemy"):
    row = f"{top_root}/{side}MomentumHud/SlotRow"
    require(row in nodes and 'theme_type_variation = &"BattleHudSlotRow"' in nodes[row][3], f"{side} slot-row theme variation missing")
    slots = [path for path in nodes if path.startswith(row + "/Slot")]
    require("offset_left = 33.0" in nodes[row][3] and "offset_right = 227.0" in nodes[row][3],
            f"{side} slot row is not centered in its panel")
    require(len(slots) == 10, f"{side} slot count is {len(slots)}, expected 10")
    expected = f'MomentumSlot{side}Empty'
    for slot in slots:
        require(f'theme_type_variation = &"{expected}"' in nodes[slot][3], f"{slot} lacks initial {expected} variation")

top_paths = [path for path in nodes if path.startswith(top_root + "/")]
for path in top_paths:
    require("theme_override_" not in nodes[path][3], f"static theme_override remains in top HUD: {path}")
theme_paths = {path for path, (_line, _parent, _node_type, body) in nodes.items()
               if 'theme = ExtResource("38_battle_ui_theme")' in body}
allowed_theme_paths = {f"{top_root}/AllyMomentumHud", f"{top_root}/TurnHud", f"{top_root}/EnemyMomentumHud",
                       "BattleUI/ProductionHudRoot/AllyRosterHud", "BattleUI/ProductionHudRoot/EnemyRosterHud"}
require(theme_paths == allowed_theme_paths, "Theme applied outside approved top HUD / roster roots")
require("offset_right = 610.0" in nodes[f"{top_root}/TurnHud"][3] and "offset_bottom = 88.0" in nodes[f"{top_root}/TurnHud"][3],
        "Turn HUD compact dimensions missing")
require('text = "3 / 10"' in nodes[f"{top_root}/AllyMomentumHud/ValueLabel"][3], "ally default momentum text changed")
require('text = "1 / 30"' in nodes[f"{top_root}/TurnHud/TurnLabel"][3], "default turn text changed")
require('text = "3 / 10"' in nodes[f"{top_root}/EnemyMomentumHud/ValueLabel"][3], "enemy default momentum text changed")
require("const STARTING_MOMENTUM := 3" in momentum, "STARTING_MOMENTUM changed")
require("const MAX_MOMENTUM := 10" in momentum, "MAX_MOMENTUM changed")
require("BATTLE_MAX_TURNS := 30" in turns, "MAX_TURN changed")
require('WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap, "WorldMap battle route changed")
require("Battle_UI_Production_Test.tscn" not in project and "Battle_UI_Production_Test.tscn" not in worldmap, "test scene leaked into runtime entry")
require("ProductionHudRoot" not in game_scene, "runtime scene unexpectedly contains Production HUD")
require(not git_output("diff", "--", "Battle_Land.tscn").strip(), "Battle_Land.tscn has uncommitted changes")

changed_paths = git_output("diff", "--name-only", "origin/main..HEAD").splitlines()
for changed_path in changed_paths:
    require(not changed_path.lower().endswith((".png", ".jpg", ".jpeg", ".webp", ".otf", ".ttf")), f"new image/font asset in T08-3A range: {changed_path}")

if errors:
    print("T08-3A BATTLE UI THEME VALIDATION FAILED", file=sys.stderr)
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
print("T08-3A BATTLE UI THEME PASS: isolated Theme/font hierarchy, top HUD variations, slots, contracts")
