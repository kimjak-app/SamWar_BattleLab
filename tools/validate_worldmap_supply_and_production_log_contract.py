#!/usr/bin/env python3
"""Protect actual WorldMap supply visibility and live Production battle-log binding."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
BATTLE = (ROOT / "scripts/battle_web_import_test.gd").read_text(encoding="utf-8")
PREVIEW = (ROOT / "tests/scripts/battle_ui_production_test_bottom_hud.gd").read_text(encoding="utf-8")
SCENE = (ROOT / "tests/scenes/Battle_UI_Production_Test.tscn").read_text(encoding="utf-8")
LAND = (ROOT / "Battle_Land.tscn").read_text(encoding="utf-8")
errors: list[str] = []
PREVIEW_CODE = "\n".join(line.split("#", 1)[0] for line in PREVIEW.splitlines())

def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)

for token in (
    "func _should_show_runtime_battle_supply() -> bool:",
    "return _has_worldmap_battle_context() and battle_supply_runtime != null",
    "func _refresh_battle_supply_visibility() -> void:",
    "battle_supply_panel.visible = _should_show_runtime_battle_supply()",
    "_refresh_battle_supply_visibility()",
    "if not _should_show_runtime_battle_supply() or battle_supply_panel == null:",
    "BattleSupplyRuntimeScript.new()",
    "battle_supply_runtime.configure(context)",
    "_refresh_battle_supply_side(\"Ally\"",
    "_refresh_battle_supply_side(\"Enemy\"",
):
    require(token in BATTLE, f"missing runtime supply contract: {token}")
for token in ("TurnLabel", "FoodValue", "SaltValue", "ConsumptionValue", "SustainValue", "WarningLabel"):
    require(token in BATTLE, f"runtime supply label is not refreshed: {token}")
require('[node name="T02BattleSupplyPanel"' in LAND and "visible = false" in LAND, "Battle_Land supply panel missing/default hidden contract")
require('[node name="BattleSupplyPreviewPanel"' in SCENE, "Production supply preview missing")
require("BattleSupplyRuntime" not in PREVIEW_CODE and "worldmap_battle_context" not in PREVIEW_CODE, "Production preview leaked runtime supply")

require('"아군 준비"' not in PREVIEW and '"권율 방어"' not in PREVIEW and '"최근 행동 대기"' not in PREVIEW, "Production preview still overwrites live logs")
require("battle_log_lines.clear()" in BATTLE, "test reset still inserts fixed battle-log samples")
require("func _append_battle_log(line: String) -> void:" in BATTLE, "missing battle log source of truth")
require("_refresh_production_battle_hud(\"log\")" in BATTLE, "live log append does not refresh Production HUD")
require('"BattleLogHud/RecentLogLabel", "\\n".join(log_lines)' in BATTLE, "Production log does not render common battle_log_lines")
for token in ("이동 완료", "공격", "방어 태세", "고유특기", "적군 턴", "BATTLE %d 시작"):
    require(token in BATTLE, f"missing live battle-log event: {token}")

if errors:
    print("WORLDMAP SUPPLY / PRODUCTION LOG VALIDATION FAILED", file=sys.stderr)
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print("WORLDMAP SUPPLY / PRODUCTION LOG PASS: actual runtime supply visibility and live battle_log_lines binding; preview remains isolated")
