#!/usr/bin/env python3
"""Structural and safe-default validator for the T08-2 production battle HUD."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SCENE_PATH = ROOT / "tests/scenes/Battle_UI_Production_Test.tscn"
SCENE = SCENE_PATH.read_text(encoding="utf-8")
BATTLE = (ROOT / "scripts/battle_web_import_test.gd").read_text(encoding="utf-8")
ADAPTER = (ROOT / "scripts/battle/ui/battle_hud_state_adapter.gd").read_text(encoding="utf-8")
errors: list[str] = []

def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)

def node_records(source: str) -> list[tuple[int, str, str, str]]:
    records = []
    pattern = re.compile(r'^\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?[^\]]*\]$', re.M)
    for match in pattern.finditer(source):
        name, node_type, parent = match.groups()
        parent = parent or ""
        path = f"{parent}/{name}" if parent not in ("", ".") else name
        records.append((source[:match.start()].count("\n") + 1, path, parent, node_type))
    return records

def node_block(path: str) -> str:
    escaped = re.escape(path.rsplit("/", 1)[-1])
    parent = re.escape(path.rsplit("/", 1)[0]) if "/" in path else ""
    pattern = re.compile(rf'^\[node name="{escaped}" type="[^"]+" parent="{parent}"[^\]]*\]\n(?P<body>.*?)(?=^\[node |\Z)', re.M | re.S)
    match = pattern.search(SCENE)
    return match.group("body") if match else ""

# Reject patch residue before interpreting the scene graph.
for line_number, line in enumerate(SCENE.splitlines(), 1):
    stripped = line.strip()
    require(stripped not in {"+", "-"} and not stripped.startswith("@@") and not stripped.startswith("<<<<<<<") and not stripped.startswith("=======") and not stripped.startswith(">>>>>>>"),
            f"malformed patch/conflict marker at scene line {line_number}")

records = node_records(SCENE)
paths = {path: (line, parent, node_type) for line, path, parent, node_type in records}
require(bool(records), "scene node declarations could not be parsed")
for line, path, parent, _node_type in records:
    if parent and parent != ".":
        require(parent in paths, f"parent missing for {path}: {parent}")
        if parent in paths:
            require(paths[parent][0] < line, f"parent declared after child for {path}")

production_root = "BattleUI/ProductionHudRoot"
require(production_root in paths, "missing scene-authored ProductionHudRoot")
if production_root in paths:
    require(paths[production_root][1] == "BattleUI", "ProductionHudRoot parent must be BattleUI")

required_roots = ("TopHudRoot", "AllyRosterHud", "EnemyRosterHud", "InteractionGuideHud",
                  "ActorComparisonHud", "GlobalCommandHud", "BattleLogHud", "TooltipHud", "FacingSelectionHud")
for name in required_roots:
    require(f"{production_root}/{name}" in paths, f"missing production root {name}")

for side in ("Ally", "Enemy"):
    momentum_root = f"{production_root}/TopHudRoot/{side}MomentumHud"
    row = f"{momentum_root}/SlotRow"
    require(momentum_root in paths and row in paths, f"missing {side} momentum root/row")
    slots = [path for path in paths if path.startswith(row + "/Slot")]
    require(len(slots) == 10, f"{side} momentum slot count is {len(slots)}, expected 10")
    require(f"{momentum_root}/ValueLabel" in paths, f"missing {side} momentum value label")

for side in ("Ally", "Enemy"):
    roster = f"{production_root}/{side}RosterHud"
    for slot in ("Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"):
        require(f"{roster}/{slot}" in paths, f"missing {side} roster {slot}")

for name in ("TurnLabel", "ActiveSideLabel", "BattleTitleLabel", "LeftActorPanel",
             "CenterContextPanel", "RightSubjectPanel", "InstructionLabel", "DisabledReasonLabel"):
    require(any(path.endswith("/" + name) for path in paths), f"missing {name}")

for path, limit in ((f"{production_root}/TopHudRoot", 120), (f"{production_root}/ActorComparisonHud", 180)):
    block = node_block(path)
    bottom = re.search(r"offset_bottom = ([0-9.]+)", block)
    top = re.search(r"offset_top = ([0-9.]+)", block)
    if bottom and top:
        require(float(bottom.group(1)) - float(top.group(1)) <= limit, f"{path} exceeds height limit")
for path in (f"{production_root}/TopHudRoot", f"{production_root}/AllyRosterHud",
             f"{production_root}/EnemyRosterHud", f"{production_root}/ActorComparisonHud",
             f"{production_root}/BattleLogHud"):
    block = node_block(path)
    values = {key: float(value) for key, value in re.findall(r"(offset_(?:left|top|right|bottom)) = ([0-9.]+)", block)}
    if len(values) == 4:
        require(0 <= values["offset_left"] <= values["offset_right"] <= 1920 and 0 <= values["offset_top"] <= values["offset_bottom"] <= 1080,
                f"{path} rect is outside 1920x1080")

for path in (f"{production_root}/TooltipHud", f"{production_root}/FacingSelectionHud",
             f"{production_root}/ActorComparisonHud/CenterContextPanel/TerrainPlaceholderLabel"):
    require("visible = false" in node_block(path), f"{path} must be hidden by default")
require("_sync_production_hud_legacy_visibility" in BATTLE, "legacy visibility parity helper missing")
for legacy in ("top_bar.visible = false", "formation_slot_guide_layer.visible = false",
               "battle_mini_log_panel.visible = false", "unit_closeup_panel.visible = false"):
    require(legacy in BATTLE, f"legacy visibility parity missing: {legacy}")
require(not re.search(r"\b(?:var|func)\s+visible\b", BATTLE), "CanvasItem.visible shadowing declaration remains")
require(not re.search(r"\b(?:var|func)\s+visible\b", ADAPTER), "adapter visible shadowing declaration remains")
require("func _refresh_production_battle_hud" in BATTLE, "production refresh entry missing")
require("BattleHudStateAdapterScript.build(self)" in BATTLE, "refresh does not consume normalized adapter state")
for field in ("turn", "max_turn", "active_side", "phase", "battle_title", "ally_momentum", "enemy_momentum",
              "ally_roster", "enemy_roster", "left_actor", "right_subject", "right_subject_role", "center_context",
              "instruction", "disabled_reason", "command_states", "recent_log", "battle_complete"):
    require(f'"{field}"' in ADAPTER, f"adapter field missing: {field}")
floating = re.search(r'\[node name="FloatingMoveButton".*?(?=\n\[node |\Z)', SCENE, re.S)
require(floating is not None and 'text = "방어"' in floating.group(0), "visible 이동->defend mismatch remains")
if errors:
    print("T08-2 HOTFIX1 HUD VALIDATION FAILED", file=sys.stderr)
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
print("T08-2 HOTFIX1 HUD VALIDATION PASS: scene graph/order, safe defaults, layout, legacy parity, adapter")
