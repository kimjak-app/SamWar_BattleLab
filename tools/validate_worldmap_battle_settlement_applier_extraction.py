"""Static M-5 boundary validator; runtime behavior is covered by the Godot test."""

from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MAIN_PATH = "scripts/worldmap/worldmap_main.gd"
APPLIER_PATH = ROOT / "scripts/worldmap/battle/battle_settlement_applier.gd"
MAIN = (ROOT / MAIN_PATH).read_text(encoding="utf-8")
APPLIER = APPLIER_PATH.read_text(encoding="utf-8")
M4 = subprocess.check_output(
    ["git", "show", f"2ee28db:{MAIN_PATH}"], cwd=ROOT, text=True, encoding="utf-8"
)


def functions(source: str) -> dict[str, str]:
    matches = list(re.finditer(r"(?m)^func\s+([A-Za-z0-9_]+)\([^\n]*", source))
    return {
        match.group(1): source[match.start() : matches[index + 1].start() if index + 1 < len(matches) else len(source)].rstrip()
        for index, match in enumerate(matches)
    }


assert "extends RefCounted" in APPLIER
for forbidden in ["NodePath", "get_node(", "connect(", "Camera", "change_scene", "HUD", "popup", "save_worldmap", "raw_result"]:
    assert forbidden not in APPLIER, f"forbidden applier dependency: {forbidden}"
for forbidden_recalculation in ["_calculate_invasion", "_normalize_battle", "_resolve_occupation", "winner_side"]:
    assert forbidden_recalculation not in APPLIER, f"applier recalculates result data: {forbidden_recalculation}"
for report_key in ["ok", "battle_kind", "target_city_id", "troop_changes", "ownership_changed", "hero_changes", "supply_changes", "cargo_changes", "indexes_rebuilt", "warnings"]:
    assert f'"{report_key}"' in APPLIER, f"missing report key: {report_key}"

main_functions = functions(MAIN)
returned = main_functions["_apply_returned_battle_result_mvp"]
assert returned.index("build_settlement_plan(result)") < returned.index("_ensure_battle_settlement_applier().apply(settlement_plan)")
for wrapper in [
    "_set_hero_faction_after_conquest_mvp", "_move_hero_to_city_t02",
    "_set_hero_runtime_status_placeholder", "_apply_t02_defender_supply_result",
    "_add_t02_attacker_cargo_to_city",
]:
    assert "_ensure_battle_settlement_applier()" in main_functions[wrapper], f"non-delegating wrapper: {wrapper}"

m4_functions = functions(M4)
for protected in [
    "_build_t03_battle_report", "_queue_t03_automatic_battle_report",
    "_try_present_next_t03_battle_report", "_show_t03_battle_report_card",
]:
    assert protected in main_functions, f"T03 presentation compatibility wrapper missing: {protected}"

for extracted in [
    "_prepare_t03_battle_transaction", "_pay_t03_expedition_cargo",
    "_rollback_t03_battle_transaction", "_resolve_t03_automatic_invasion",
    "_apply_t03_strategic_battle_result",
]:
    assert "_ensure_t03_transaction_service()" in main_functions[extracted], f"M-6 T03 wrapper does not delegate: {extracted}"

print("PASS: M-5 settlement applier boundary, coordinator route, report contract, wrappers, and T03 protection")
