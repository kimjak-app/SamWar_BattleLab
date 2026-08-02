#!/usr/bin/env python3
"""Validate the isolated T08-3C Production bottom HUD preview."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BASELINE = "9d94a97a7c80d8e6937d89652a5193e89ff5083f"
SCENE = "tests/scenes/Battle_UI_Production_Test.tscn"
THEME = "assets/ui/battle_ui_theme.tres"
PREVIEW = "tests/scripts/battle_ui_production_test_bottom_hud.gd"
PROTECTED = (
    "Battle_Land.tscn",
    "scripts/battle/ui/battle_hud_state_adapter.gd", "tests/scripts/battle_ui_production_test_roster.gd",
)
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, text=True, encoding="utf-8", errors="replace", capture_output=True).stdout


def nodes(source: str) -> dict[str, tuple[int, str, str]]:
    result: dict[str, tuple[int, str, str]] = {}
    pattern = re.compile(r'^\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?[^\]]*\]$', re.M)
    matches = list(pattern.finditer(source))
    for i, match in enumerate(matches):
        name, kind, parent = match.groups()
        parent = parent or ""
        path = f"{parent}/{name}" if parent not in ("", ".") else name
        end = matches[i + 1].start() if i + 1 < len(matches) else len(source)
        result[path] = (source.count("\n", 0, match.start()) + 1, kind, source[match.end():end])
    return result


def prop(body: str, name: str) -> float:
    match = re.search(rf"^{re.escape(name)} = (-?[0-9.]+)", body, re.M)
    return float(match.group(1)) if match else 0.0


def rectangle(item: tuple[int, str, str]) -> tuple[float, float, float, float]:
    body = item[2]
    return (prop(body, "offset_left"), prop(body, "offset_top"), prop(body, "offset_right"), prop(body, "offset_bottom"))


def overlaps(a: tuple[float, float, float, float], b: tuple[float, float, float, float]) -> bool:
    return max(a[0], b[0]) < min(a[2], b[2]) and max(a[1], b[1]) < min(a[3], b[3])


scene = (ROOT / SCENE).read_text(encoding="utf-8")
theme = (ROOT / THEME).read_text(encoding="utf-8")
preview = (ROOT / PREVIEW).read_text(encoding="utf-8")
preview_code = "\n".join(line.split("#", 1)[0] for line in preview.splitlines())
parsed = nodes(scene)
baseline = git("show", f"{BASELINE}:{SCENE}")
baseline_nodes = nodes(baseline)

for line_no, line in enumerate(scene.splitlines(), 1):
    marker = line.strip()
    require(not (marker in {"+", "-"} or marker.startswith(("@@", "<<<<<<<", "=======", ">>>>>>>"))), f"marker at scene line {line_no}")
for path, (line, _kind, _body) in parsed.items():
    parent = path.rsplit("/", 1)[0] if "/" in path else ""
    if parent:
        require(parent in parsed and parsed[parent][0] < line, f"invalid scene parent for {path}")
for path in PROTECTED:
    require(not git("diff", BASELINE, "--", path).strip(), f"protected file changed: {path}")

top_start = '[node name="TopHudRoot"'
roster_start = '[node name="AllyRosterHud"'
require(scene[scene.index(top_start):scene.index(roster_start)] == baseline[baseline.index(top_start):baseline.index(roster_start)], "top HUD slice changed")
for side in ("Ally", "Enemy"):
    root = f"BattleUI/ProductionHudRoot/{side}RosterHud"
    require(root in parsed and root in baseline_nodes and parsed[root][2] == baseline_nodes[root][2], f"roster root changed: {side}")

required = (
    "BattleUI/ProductionHudRoot/BattleLogHud",
    "BattleUI/ProductionHudRoot/ActorComparisonHud",
    "BattleUI/ProductionHudRoot/InteractionGuideHud",
    "BattleUI/ProductionHudRoot/BottomHudRoot/BattleSupplyPreviewPanel",
)
for path in required:
    require(path in parsed, f"missing HUD area: {path}")
supply_root = "BattleUI/ProductionHudRoot/BottomHudRoot/BattleSupplyPreviewPanel/Margin/Content"
for side in ("AllyColumn", "EnemyColumn"):
    for name in ("FoodValue", "SaltValue", "ConsumptionValue", "SustainValue", "WarningLabel"):
        require(f"{supply_root}/Columns/{side}/{name}" in parsed, f"missing {side}/{name}")
require(f"{supply_root}/Header/TurnLabel" in parsed, "missing supply TurnLabel")
require('script = ExtResource("40_production_bottom_hud")' in scene, "preview bridge not attached")
require("BattleSupplyRuntime" not in preview_code and "worldmap_battle_context" not in preview_code, "preview uses runtime/context")
require("SHOW_WARNING_SAMPLE := false" in preview and "소금 고갈 · 식량 소비 +10%" in preview, "warning sample toggle missing")
for variation in (
    "ProductionBattleLogPanel", "ProductionBattleLogTitle", "ProductionBattleLogBody", "ProductionCurrentActionTitle",
    "ProductionCurrentActionHero", "ProductionCurrentActionDetail", "ProductionInteractionPhase", "ProductionInteractionInstruction",
    "ProductionInteractionDisabled", "ProductionSupplyPanel", "ProductionSupplyTitle", "ProductionSupplyTurn",
    "ProductionSupplyAllyTitle", "ProductionSupplyEnemyTitle", "ProductionSupplyValue", "ProductionSupplyWarning",
):
    require(f"{variation}/base_type" in theme, f"missing Theme variation: {variation}")
require("NotoSerifKR-Bold.otf" in theme and "NotoSerifKR-Medium.otf" in theme and "NotoSerifKR-Regular.otf" in theme, "NotoSerifKR hierarchy missing")

rects = {path: rectangle(parsed[path]) for path in required if path in parsed}
for path, rect in rects.items():
    require(0 <= rect[0] < rect[2] <= 1920 and 0 <= rect[1] < rect[3] <= 1080, f"out of 1920x1080 bounds: {path}")
for first, second in ((required[0], required[1]), (required[0], required[2]), (required[0], required[3]), (required[1], required[3]), (required[2], required[3])):
    if first in rects and second in rects:
        require(not overlaps(rects[first], rects[second]), f"bottom HUD overlap: {first} / {second}")
command = (1254.0, 948.0, 1830.0, 1037.0)
if required[3] in rects:
    require(not overlaps(rects[required[3]], command), "supply preview overlaps CommandBar/AutoBattle area")

if errors:
    print("T08-3C BOTTOM HUD VALIDATION FAILED", file=sys.stderr)
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print("T08-3C BOTTOM HUD PASS: isolated sample preview, Theme hierarchy, protected runtime/top/roster, bounds and overlap checks")
