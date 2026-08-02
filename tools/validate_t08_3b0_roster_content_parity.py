#!/usr/bin/env python3
"""Validate T08-3B0 roster-content parity remains test-scene isolated."""
from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
BASELINE = "21a7ae4eba03c1cfe0fda80ca0616ff41faa91a3"
SCENE = "tests/scenes/Battle_UI_Production_Test.tscn"
SCRIPT = "tests/scripts/battle_ui_production_test_roster.gd"
PROTECTED = (
    "Battle_Land.tscn",
    "scripts/battle_web_import_test.gd",
    "scripts/battle/ui/battle_hud_state_adapter.gd",
)
SLOTS = ("Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02")
SIDES = ("Ally", "Enemy")
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def git(*args: str) -> str:
    return subprocess.run(
        ["git", *args], cwd=ROOT, text=True, encoding="utf-8", errors="replace", capture_output=True, check=False
    ).stdout


def parse_nodes(source: str) -> dict[str, tuple[int, str, str, str]]:
    nodes: dict[str, tuple[int, str, str, str]] = {}
    pattern = re.compile(r'^\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?[^\]]*\]$', re.M)
    matches = list(pattern.finditer(source))
    for index, match in enumerate(matches):
        name, node_type, parent = match.groups()
        parent = parent or ""
        path = f"{parent}/{name}" if parent not in ("", ".") else name
        body_end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        nodes[path] = (source.count("\n", 0, match.start()) + 1, parent, node_type, source[match.end():body_end])
    return nodes


scene_path = ROOT / SCENE
scene = scene_path.read_text(encoding="utf-8")
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

require((ROOT / SCRIPT).exists(), "missing test-scene-only roster content bridge")
require('path="res://tests/scripts/battle_ui_production_test_roster.gd"' in scene, "test bridge is not attached to scene")
require("ProductionRosterContentParityBridge" in nodes, "missing test bridge node")

for protected in PROTECTED:
    require(not git("diff", BASELINE, "--", protected).strip(), f"protected file changed from baseline: {protected}")

baseline_scene = git("show", f"{BASELINE}:{SCENE}")
top_start = '[node name="TopHudRoot"'
roster_start = '[node name="AllyRosterHud"'
require(top_start in baseline_scene and roster_start in baseline_scene, "unable to load baseline top HUD slice")
require(
    scene[scene.index(top_start):scene.index(roster_start)] == baseline_scene[baseline_scene.index(top_start):baseline_scene.index(roster_start)],
    "T08-3A top HUD geometry/theme slice changed",
)

for side in SIDES:
    roster_root = f"BattleUI/ProductionHudRoot/{side}RosterHud"
    require(roster_root in nodes, f"missing roster root {roster_root}")
    cards = [f"{roster_root}/{slot}" for slot in SLOTS]
    require(all(card in nodes for card in cards), f"{side} roster slot order/count changed")
    for card in cards:
        for child, node_type in (
            ("Portrait", "TextureRect"), ("NameLabel", "Label"), ("HpLabel", "Label"),
            ("TroopIconRect", "TextureRect"), ("TroopTypeLabel", "Label"),
            ("StatusLabel", "Label"), ("UniqueSkillReadyIcon", "TextureRect"),
        ):
            path = f"{card}/{child}"
            require(path in nodes, f"missing {child} at {card}")
            if path in nodes:
                require(nodes[path][2] == node_type, f"{path} expected {node_type}")
        for hidden_child in ("TroopBar", "ActionStateLabel", "UniqueSkillReadyLabel", "StatusLabel", "UniqueSkillReadyIcon"):
            path = f"{card}/{hidden_child}"
            require(path in nodes and "visible = false" in nodes[path][3], f"{path} is not default hidden")
        require(f'{card}/UnitTypeLabel' in nodes and f'{card}/TroopsLabel' in nodes, f"legacy test NodePath lost at {card}")

bridge = (ROOT / SCRIPT).read_text(encoding="utf-8")
for required in ("_get_closeup_portrait_texture_for_unit", "_get_troop_icon_texture_for_visual_key", "_is_unique_skill_ready_for_formation_guide"):
    require(required in bridge, f"test bridge does not read existing runtime visual source: {required}")
for forbidden in ("battle_web_import_test.gd", "battle_hud_state_adapter.gd", "save", "current_hp =", "current_troops ="):
    require(forbidden not in bridge, f"test bridge contains forbidden mutation/reference: {forbidden}")

project = (ROOT / "project.godot").read_text(encoding="utf-8")
worldmap = (ROOT / "scripts/worldmap/worldmap_main.gd").read_text(encoding="utf-8")
require("Battle_UI_Production_Test.tscn" not in project and "Battle_UI_Production_Test.tscn" not in worldmap,
        "test scene leaked into main game route")
require('WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap, "WorldMap battle route changed")

if errors:
    print("T08-3B0 ROSTER CONTENT PARITY VALIDATION FAILED", file=sys.stderr)
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
print("T08-3B0 ROSTER CONTENT PARITY PASS: legacy content contract, test-only bridge, protected runtime isolation")
