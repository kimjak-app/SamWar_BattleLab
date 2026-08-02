#!/usr/bin/env python3
"""Validate the T08-3B roster HUD pass without touching the locked top HUD."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SCENE_PATH = ROOT / "tests/scenes/Battle_UI_Production_Test.tscn"
THEME_PATH = ROOT / "assets/ui/battle_ui_theme.tres"
GAME_SCENE_PATH = ROOT / "Battle_Land.tscn"
SCRIPT_PATH = ROOT / "scripts/battle_web_import_test.gd"
ADAPTER_PATH = ROOT / "scripts/battle/ui/battle_hud_state_adapter.gd"
WORLDMAP_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"
PROJECT_PATH = ROOT / "project.godot"
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def parse_nodes(source: str) -> dict[str, tuple[int, str, str, str]]:
    result: dict[str, tuple[int, str, str, str]] = {}
    pattern = re.compile(r'^\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?[^\]]*\]$', re.M)
    matches = list(pattern.finditer(source))
    for index, match in enumerate(matches):
        name, node_type, parent = match.groups()
        parent = parent or ""
        path = f"{parent}/{name}" if parent not in ("", ".") else name
        line = source.count("\n", 0, match.start()) + 1
        end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        result[path] = (line, parent, node_type, source[match.end():end])
    return result


def git_output(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True, check=False).stdout


scene = SCENE_PATH.read_text(encoding="utf-8")
theme = THEME_PATH.read_text(encoding="utf-8")
game = GAME_SCENE_PATH.read_text(encoding="utf-8")
script = SCRIPT_PATH.read_text(encoding="utf-8")
adapter = ADAPTER_PATH.read_text(encoding="utf-8")
nodes = parse_nodes(scene)
top_root = "BattleUI/ProductionHudRoot/TopHudRoot"

for line_number, line in enumerate(scene.splitlines(), 1):
    stripped = line.strip()
    require(not (stripped in {"+", "-"} or stripped.startswith(("@@", "<<<<<<<", "=======", ">>>>>>>"))),
            f"malformed patch/conflict marker at scene line {line_number}")
for path, (line, parent, _node_type, _body) in nodes.items():
    if parent and parent != ".":
        require(parent in nodes, f"missing parent {parent} for {path}")
        if parent in nodes:
            require(nodes[parent][0] < line, f"parent declared after child {path}")

for variation in ("BattleRosterPanel", "AllyRosterPanel", "EnemyRosterPanel", "BattleRosterHeader",
                  "AllyRosterHeader", "EnemyRosterHeader", "BattleHeroCard", "AllyHeroCard", "EnemyHeroCard",
                  "AllyHeroCardSelected", "EnemyHeroCardSelected", "HeroCardDisabled", "HeroCardEmpty",
                  "HeroNameLabel", "HeroTroopLabel", "HeroUnitTypeLabel", "HeroStatusLabel", "HeroEffectLabel", "HeroTroopBar"):
    require(f"{variation}/base_type" in theme, f"missing Theme variation {variation}")
require("NotoSerifKR-Bold.otf" in theme and "NotoSerifKR-Medium.otf" in theme and "NotoSerifKR-Regular.otf" in theme,
        "Theme no longer references required NotoSerifKR hierarchy")

slots = ("Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02")
label_variations = {"NameLabel": "HeroNameLabel", "TroopsLabel": "HeroTroopLabel", "UnitTypeLabel": "HeroUnitTypeLabel",
                    "ActionStateLabel": "HeroStatusLabel", "StatusLabel": "HeroStatusLabel", "UniqueSkillReadyLabel": "HeroEffectLabel",
                    "TroopBar": "HeroTroopBar"}
for side in ("Ally", "Enemy"):
    root = f"BattleUI/ProductionHudRoot/{side}RosterHud"
    require(root in nodes, f"missing {side} roster root")
    if root in nodes:
        body = nodes[root][3]
        require('theme = ExtResource("38_battle_ui_theme")' in body, f"{side} roster does not use shared Theme")
        require(f'theme_type_variation = &"{side}RosterPanel"' in body, f"{side} roster variation missing")
    require(sum(path.startswith(root + "/") and path.count("/") == root.count("/") + 1 for path in nodes) == 5,
            f"{side} roster slot count changed")
    for slot in slots:
        card = f"{root}/{slot}"
        require(card in nodes and f'theme_type_variation = &"{side}HeroCard"' in nodes[card][3], f"missing card variation {card}")
        require(f"{card}/Portrait" in nodes, f"portrait NodePath missing {card}")
        for child, variation in label_variations.items():
            path = f"{card}/{child}"
            require(path in nodes and f'theme_type_variation = &"{variation}"' in nodes[path][3], f"missing {variation} on {path}")

# Locked T08-3A top-HUD geometry, alignment, and panel alpha remain exact.
for panel, expected in (("AllyMomentumHud", ("offset_right = 260.0", "offset_bottom = 88.0", 'theme_type_variation = &"AllyMomentumPanel"')),
                        ("TurnHud", ("offset_left = 310.0", "offset_right = 610.0", "offset_bottom = 88.0", 'theme_type_variation = &"TurnHudPanel"')),
                        ("EnemyMomentumHud", ("offset_left = 660.0", "offset_right = 920.0", "offset_bottom = 88.0", 'theme_type_variation = &"EnemyMomentumPanel"'))):
    body = nodes[f"{top_root}/{panel}"][3]
    for value in expected:
        require(value in body, f"locked top HUD changed: {panel} lacks {value}")
for value in ("StyleBoxFlat_ally_panel", "bg_color = Color(0.045, 0.09, 0.13, 0.84)",
              "StyleBoxFlat_turn_panel", "bg_color = Color(0.095, 0.08, 0.06, 0.84)",
              "StyleBoxFlat_enemy_panel", "bg_color = Color(0.13, 0.05, 0.055, 0.84)"):
    require(value in theme, f"locked top HUD Theme value changed: {value}")
for side in ("Ally", "Enemy"):
    row = f"{top_root}/{side}MomentumHud/SlotRow"
    require(sum(path.startswith(row + "/Slot") for path in nodes) == 10, f"{side} top momentum slot count changed")
require('text = "3 / 10"' in nodes[f"{top_root}/AllyMomentumHud/ValueLabel"][3], "ally momentum default changed")
require('text = "1 / 30"' in nodes[f"{top_root}/TurnHud/TurnLabel"][3], "turn default changed")
require('text = "3 / 10"' in nodes[f"{top_root}/EnemyMomentumHud/ValueLabel"][3], "enemy momentum default changed")

require("_mark_roster_selection(allies, active_unit)" in adapter and "_mark_roster_selection(enemies, selected_target)" in adapter,
        "existing selection state is not forwarded to roster presentation")
require('slot.theme_type_variation = "%sHeroCard%s"' in script, "roster card selection variation is not refreshed")
require('slot.visible = should_show_slot' in script, "empty-slot visibility contract changed")
require("ProductionHudRoot" not in game, "runtime Battle_Land contains Production HUD")
require(not git_output("diff", "--", "Battle_Land.tscn").strip(), "Battle_Land.tscn has uncommitted changes")
require('WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in WORLDMAP_PATH.read_text(encoding="utf-8"), "WorldMap battle route changed")
require("Battle_UI_Production_Test.tscn" not in PROJECT_PATH.read_text(encoding="utf-8"), "test scene leaked into main scene")

if errors:
    print("T08-3B ROSTER HUD VALIDATION FAILED", file=sys.stderr)
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
print("T08-3B ROSTER HUD PASS: roster Theme hierarchy, cards, selection presentation, locked top HUD, runtime isolation")
