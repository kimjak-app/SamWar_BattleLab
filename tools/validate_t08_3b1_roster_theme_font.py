#!/usr/bin/env python3
"""Validate the T08-3B1 roster visual pass stays isolated to the Production scene."""
from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
BASELINE = "d53b45ea8988917e3568cb9f7252767a2b77e6d7"
SCENE = "tests/scenes/Battle_UI_Production_Test.tscn"
THEME = "assets/ui/battle_ui_theme.tres"
BRIDGE = "tests/scripts/battle_ui_production_test_roster.gd"
PROTECTED = (
    "Battle_Land.tscn",
    "scripts/battle_web_import_test.gd",
    "scripts/battle/ui/battle_hud_state_adapter.gd",
)
SIDES = ("Ally", "Enemy")
SLOTS = ("Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02")
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
        end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        nodes[path] = (source.count("\n", 0, match.start()) + 1, parent, node_type, source[match.end():end])
    return nodes


def property_value(body: str, name: str) -> str:
    match = re.search(rf"^{re.escape(name)} = (.+)$", body, re.M)
    return match.group(1) if match else ""


scene = (ROOT / SCENE).read_text(encoding="utf-8")
theme = (ROOT / THEME).read_text(encoding="utf-8")
baseline_scene = git("show", f"{BASELINE}:{SCENE}")
baseline_theme = git("show", f"{BASELINE}:{THEME}")
nodes = parse_nodes(scene)
baseline_nodes = parse_nodes(baseline_scene)

for line_number, line in enumerate(scene.splitlines(), 1):
    marker = line.strip()
    require(not (marker in {"+", "-"} or marker.startswith(("@@", "<<<<<<<", "=======", ">>>>>>>"))),
            f"malformed patch/conflict marker at scene line {line_number}")
for path, (line, parent, _kind, _body) in nodes.items():
    if parent and parent != ".":
        require(parent in nodes, f"missing parent {parent} for {path}")
        if parent in nodes:
            require(nodes[parent][0] < line, f"parent declared after child {path}")

for path in PROTECTED:
    require(not git("diff", BASELINE, "--", path).strip(), f"protected file changed from baseline: {path}")

top_start = '[node name="TopHudRoot"'
roster_start = '[node name="AllyRosterHud"'
require(top_start in scene and roster_start in scene and top_start in baseline_scene and roster_start in baseline_scene,
        "unable to locate Production top-HUD slice")
require(scene[scene.index(top_start):scene.index(roster_start)] == baseline_scene[baseline_scene.index(top_start):baseline_scene.index(roster_start)],
        "T08-3A top HUD geometry/theme slice changed")

for required in (
    "ProductionRosterPanelAlly", "ProductionRosterPanelEnemy", "ProductionRosterCardAlly", "ProductionRosterCardEnemy",
    "ProductionRosterHeroName", "ProductionRosterTroops", "ProductionRosterUnitType", "ProductionRosterStatus",
):
    require(f"{required}/base_type" in theme, f"missing roster Theme variation: {required}")
for font_name in ("NotoSerifKR-Bold.otf", "NotoSerifKR-Medium.otf"):
    require(f"res://assets/font/noto_serif_kr/{font_name}" in theme, f"missing NotoSerifKR reference: {font_name}")
require('ProductionRosterHeroName/fonts/font = ExtResource("1_bold")' in theme, "hero-name Bold hierarchy missing")
require('ProductionRosterHeroName/font_sizes/font_size = 19' in theme, "hero-name size must be 19")
require('ProductionRosterTroops/fonts/font = ExtResource("2_medium")' in theme, "troop Medium hierarchy missing")
require('ProductionRosterTroops/font_sizes/font_size = 15' in theme, "troop size must be 15")
require('ProductionRosterUnitType/fonts/font = ExtResource("2_medium")' in theme, "unit-type Medium hierarchy missing")
require('ProductionRosterUnitType/font_sizes/font_size = 14' in theme, "unit-type size must be 14")
for existing in ("AllyMomentumPanel", "TurnHudPanel", "EnemyMomentumPanel", "BattleHudTitle", "BattleHudValue", "BattleHudSecondary"):
    pattern = re.compile(rf"^{re.escape(existing)}/.+$", re.M)
    require(pattern.findall(theme) == pattern.findall(baseline_theme), f"existing top-HUD variation changed: {existing}")

for side in SIDES:
    root = f"BattleUI/ProductionHudRoot/{side}RosterHud"
    panel_variation = f"ProductionRosterPanel{side}"
    card_variation = f"ProductionRosterCard{side}"
    require(root in nodes, f"missing roster root: {root}")
    if root in nodes:
        body = nodes[root][3]
        require('theme = ExtResource("38_battle_ui_theme")' in body, f"{root} does not use the Battle Theme")
        require(f'theme_type_variation = &"{panel_variation}"' in body, f"{root} lacks {panel_variation}")
    for slot in SLOTS:
        card = f"{root}/{slot}"
        require(card in nodes and card in baseline_nodes, f"missing card: {card}")
        if card not in nodes or card not in baseline_nodes:
            continue
        require(f'theme_type_variation = &"{card_variation}"' in nodes[card][3], f"{card} lacks {card_variation}")
        for child, variation in (
            ("NameLabel", "ProductionRosterHeroName"), ("HpLabel", "ProductionRosterTroops"),
            ("TroopTypeLabel", "ProductionRosterUnitType"), ("StatusLabel", "ProductionRosterStatus"),
        ):
            path = f"{card}/{child}"
            require(path in nodes, f"missing card information node: {path}")
            if path in nodes:
                require(f'theme_type_variation = &"{variation}"' in nodes[path][3], f"{path} lacks {variation}")
        for child in ("Portrait", "NameLabel", "HpLabel", "TroopIconRect", "TroopTypeLabel"):
            path = f"{card}/{child}"
            require(path in baseline_nodes and path in nodes, f"missing baseline content node: {path}")
            if path in baseline_nodes and path in nodes:
                for coordinate in ("offset_left", "offset_top", "offset_right", "offset_bottom"):
                    require(property_value(nodes[path][3], coordinate) == property_value(baseline_nodes[path][3], coordinate),
                            f"geometry changed for {path}: {coordinate}")
        for hidden in ("TroopBar", "ActionStateLabel", "UniqueSkillReadyLabel", "StatusLabel", "UniqueSkillReadyIcon"):
            path = f"{card}/{hidden}"
            require(path in nodes and "visible = false" in nodes[path][3], f"hidden contract broken: {path}")

require("ProductionRosterCardAllySelected/base_type" not in theme and "ProductionRosterCardEnemySelected/base_type" not in theme,
        "selection variations must remain deferred without a test-only selection signal")
bridge = (ROOT / BRIDGE).read_text(encoding="utf-8")
require('_get_formation_status_summary_text' in bridge, "test bridge must use the legacy status formatter")
require("current_troops =" not in bridge and "max_troops =" not in bridge, "test bridge must not mutate battle state")
project = (ROOT / "project.godot").read_text(encoding="utf-8")
worldmap = (ROOT / "scripts/worldmap/worldmap_main.gd").read_text(encoding="utf-8")
require("Battle_UI_Production_Test.tscn" not in project and "Battle_UI_Production_Test.tscn" not in worldmap,
        "test scene leaked into runtime entry")
require('WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap, "WorldMap battle route changed")

if errors:
    print("T08-3B1 ROSTER THEME/FONT VALIDATION FAILED", file=sys.stderr)
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
print("T08-3B1 ROSTER THEME/FONT PASS: isolated variations, font hierarchy, geometry, hidden contracts, top-HUD lock")
