#!/usr/bin/env python3
"""Validate T08-3B1-hotfix1 status placement and legacy formatter parity."""
from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
BASELINE = "b10ac31055251b2d4c8188dc2d634fdf097f3a25"
SCENE = "tests/scenes/Battle_UI_Production_Test.tscn"
BRIDGE = "tests/scripts/battle_ui_production_test_roster.gd"
SIDES = ("Ally", "Enemy")
SLOTS = ("Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02")
PROTECTED = ("Battle_Land.tscn", "scripts/battle/ui/battle_hud_state_adapter.gd")
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
        name, kind, parent = match.groups()
        parent = parent or ""
        path = f"{parent}/{name}" if parent not in ("", ".") else name
        end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        nodes[path] = (source.count("\n", 0, match.start()) + 1, parent, kind, source[match.end():end])
    return nodes


def offset(body: str, name: str) -> float:
    match = re.search(rf"^{name} = (-?\d+(?:\.\d+)?)$", body, re.M)
    return float(match.group(1)) if match else float("nan")


scene = (ROOT / SCENE).read_text(encoding="utf-8")
baseline_scene = git("show", f"{BASELINE}:{SCENE}")
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
require(scene[scene.index(top_start):scene.index(roster_start)] == baseline_scene[baseline_scene.index(top_start):baseline_scene.index(roster_start)],
        "T08-3A top HUD slice changed")

for side in SIDES:
    root = f"BattleUI/ProductionHudRoot/{side}RosterHud"
    for slot in SLOTS:
        card = f"{root}/{slot}"
        status = f"{card}/StatusLabel"
        hp = f"{card}/HpLabel"
        troop_type = f"{card}/TroopTypeLabel"
        icon = f"{card}/TroopIconRect"
        require(all(path in nodes for path in (card, status, hp, troop_type, icon)), f"missing roster node in {card}")
        if not all(path in nodes for path in (card, status, hp, troop_type, icon)):
            continue
        body = nodes[status][3]
        left, top, right, bottom = (offset(body, key) for key in ("offset_left", "offset_top", "offset_right", "offset_bottom"))
        hp_bottom = offset(nodes[hp][3], "offset_bottom")
        type_left = offset(nodes[troop_type][3], "offset_left")
        card_right = offset(nodes[card][3], "offset_right")
        card_bottom = offset(nodes[card][3], "offset_bottom") - offset(nodes[card][3], "offset_top")
        require("visible = false" in body, f"StatusLabel is not default hidden: {status}")
        require(left == 80.0 and top == 66.0 and right == 188.0 and bottom == 88.0, f"unexpected status geometry: {status}")
        require(top >= hp_bottom, f"StatusLabel is not below HpLabel: {status}")
        require(right <= type_left, f"StatusLabel overlaps TroopTypeLabel horizontally: {status}")
        require(0.0 <= left < right <= card_right and 0.0 <= top < bottom <= card_bottom, f"StatusLabel exceeds card bounds: {status}")
        for locked in (card, troop_type, icon):
            for key in ("offset_left", "offset_top", "offset_right", "offset_bottom"):
                require(offset(nodes[locked][3], key) == offset(baseline_nodes[locked][3], key), f"locked geometry changed: {locked} {key}")

bridge = (ROOT / BRIDGE).read_text(encoding="utf-8")
require('controller.call("_get_formation_status_summary_text", unit)' in bridge, "bridge does not use the legacy status formatter")
require('status_label.visible = status_text != ""' in bridge, "bridge status visibility contract missing")
require('status_entries' not in bridge, "bridge retains non-legacy local status formatting")
for forbidden in ("current_troops =", "max_troops =", "is_defending =", "has_moved ="):
    require(forbidden not in bridge, f"bridge contains forbidden state mutation: {forbidden}")

if errors:
    print("T08-3B1-HOTFIX1 STATUS PLACEMENT VALIDATION FAILED", file=sys.stderr)
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
print("T08-3B1-HOTFIX1 STATUS PLACEMENT PASS: legacy formatter, non-overlap geometry, locked roster/runtime/top HUD")
