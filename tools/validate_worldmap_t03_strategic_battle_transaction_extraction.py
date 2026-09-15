"""Static M-6 boundary validator; runtime behavior is covered by the Godot test."""

from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "scripts/worldmap/worldmap_main.gd").read_text(encoding="utf-8")
SERVICE = (ROOT / "scripts/worldmap/t03/strategic_battle_transaction_service.gd").read_text(encoding="utf-8")
RESOLVER = (ROOT / "scripts/worldmap/t03/auto_battle_resolver.gd").read_text(encoding="utf-8")
M5_MAIN = subprocess.check_output(
    ["git", "show", "cbfcaa1:scripts/worldmap/worldmap_main.gd"], cwd=ROOT, text=True, encoding="utf-8"
)


def functions(source: str) -> dict[str, str]:
    matches = list(re.finditer(r"(?m)^func\s+([A-Za-z0-9_]+)\([^\n]*", source))
    return {
        match.group(1): source[match.start() : matches[index + 1].start() if index + 1 < len(matches) else len(source)].rstrip()
        for index, match in enumerate(matches)
    }


assert "class_name StrategicBattleTransactionService" in SERVICE
assert "extends RefCounted" in SERVICE
for forbidden in ["NodePath", "get_node(", ".connect(", "Camera", "popup", "change_scene", "save_worldmap", "HUD"]:
    assert forbidden not in SERVICE, f"forbidden service dependency: {forbidden}"
for contract_key in [
    "ok", "transaction_id", "cargo_plan", "cargo_paid", "cargo_rolled_back",
    "battle_result", "settlement", "ownership_changed", "troop_changes",
    "supply_changes", "hero_changes", "error_code", "warnings",
]:
    assert f'"{contract_key}"' in SERVICE, f"missing structured result key: {contract_key}"
for flow_call in ["prepare(event, base_context", "_resolver.call(context)", "apply_result(battle_result", "rollback(context)"]:
    assert flow_call in SERVICE, f"missing transaction flow: {flow_call}"

main_functions = functions(MAIN)
m5_functions = functions(M5_MAIN)
for wrapper, delegated in {
    "_make_t03_transaction_id": "make_transaction_id",
    "_build_t03_expedition_cargo_plan": "build_expedition_cargo_plan",
    "_filter_t03_context_heroes": "filter_context_heroes",
    "_prepare_t03_battle_transaction": ".prepare(",
    "_select_t03_food_type": "select_food_type",
    "_sum_t03_food_stock": "sum_food_stock",
    "_pay_t03_expedition_cargo": "pay_expedition_cargo",
    "_rollback_t03_battle_transaction": ".rollback(",
    "_apply_t03_strategic_battle_result": ".apply_result(",
    "_apply_t03_defender_supply_result": "apply_defender_supply",
    "_add_t03_attacker_cargo_to_city": "add_attacker_cargo",
}.items():
    assert delegated in main_functions[wrapper], f"non-delegating M-6 wrapper: {wrapper}"

automatic = main_functions["_resolve_t03_automatic_invasion"]
assert ".execute(event, context)" in automatic
assert "T03AutoBattleResolverScript.resolve" not in automatic

for protected in [
    "_build_t03_battle_report", "_queue_t03_automatic_battle_report",
    "_setup_t03_battle_presentation", "_try_present_next_t03_battle_report",
    "_on_t03_battle_video_skipped", "_on_t03_battle_video_finished",
    "_show_t03_battle_report_card", "_on_t03_battle_report_confirmed",
]:
    assert protected in main_functions, f"presentation escaped main: {protected}"
    assert f"func {protected}" not in SERVICE, f"presentation moved into service: {protected}"
    assert main_functions[protected] == m5_functions[protected], f"M-6 changed protected presentation: {protected}"

for lifecycle in ["_save_worldmap_state", "_consume_worldmap_battle_result_if_any"]:
    assert main_functions[lifecycle] == m5_functions[lifecycle], f"M-6 changed protected lifecycle: {lifecycle}"

assert "static func resolve(context: Dictionary)" in RESOLVER
assert "StrategicBattleTransactionService" not in RESOLVER
for existing_service in ["BattleContextService", "BattleResultService", "BattleSettlementApplier", "MilitaryController", "EnemyWarfareService"]:
    assert f"class_name {existing_service}" not in SERVICE, f"existing service duplicated: {existing_service}"

print("PASS: M-6 T03 transaction service boundary, structured result, thin wrappers, resolver reuse, and presentation protection")
