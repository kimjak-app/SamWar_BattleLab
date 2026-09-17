"""Static M-9 boundary validator; runtime behavior is covered by two Godot tests."""

from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MAIN_PATH = "scripts/worldmap/worldmap_main.gd"
DEPLOYMENT_PATH = "scripts/worldmap/military/player_attack_deployment_service.gd"
REBALANCE_PATH = "scripts/worldmap/military/troop_rebalance_service.gd"
MAIN = (ROOT / MAIN_PATH).read_text(encoding="utf-8")
DEPLOYMENT = (ROOT / DEPLOYMENT_PATH).read_text(encoding="utf-8")
REBALANCE = (ROOT / REBALANCE_PATH).read_text(encoding="utf-8")
M8_MAIN = subprocess.check_output(["git", "show", f"531123f:{MAIN_PATH}"], cwd=ROOT, text=True, encoding="utf-8")
M4_MAIN = subprocess.check_output(["git", "show", f"be25225:{MAIN_PATH}"], cwd=ROOT, text=True, encoding="utf-8")
BATTLE_SETTLEMENT_PATH = "scripts/worldmap/battle/battle_settlement_applier.gd"
OLD_STANDARD_WOUNDED_SIGNATURE = b"func _apply_standard_wounded(plan: Dictionary, report: Dictionary) -> void:"
NEW_STANDARD_WOUNDED_SIGNATURE = b"func _apply_standard_wounded(plan: Dictionary, _report: Dictionary) -> void:"


def functions(source: str) -> dict[str, str]:
    matches = list(re.finditer(r"(?m)^func\s+([A-Za-z0-9_]+)\([^\n]*", source))
    return {
        match.group(1): source[match.start() : matches[index + 1].start() if index + 1 < len(matches) else len(source)].rstrip()
        for index, match in enumerate(matches)
    }


def assert_af1_standard_wounded_rename(current_bytes: bytes, baseline_bytes: bytes) -> None:
    assert baseline_bytes.count(OLD_STANDARD_WOUNDED_SIGNATURE) == 1, "M-8 baseline AF-1 signature contract changed"
    assert current_bytes.count(NEW_STANDARD_WOUNDED_SIGNATURE) == 1, "current AF-1 signature missing or duplicated"
    assert current_bytes.count(OLD_STANDARD_WOUNDED_SIGNATURE) == 0, "current file retains pre-AF-1 signature"
    expected_bytes = baseline_bytes.replace(OLD_STANDARD_WOUNDED_SIGNATURE, NEW_STANDARD_WOUNDED_SIGNATURE, 1)
    assert current_bytes == expected_bytes, "battle settlement changed beyond the exact AF-1 parameter rename"


current = functions(MAIN)
baseline = functions(M8_MAIN)
m4_baseline = functions(M4_MAIN)

assert "class_name PlayerAttackDeploymentService" in DEPLOYMENT and "extends RefCounted" in DEPLOYMENT
assert "class_name TroopRebalanceService" in REBALANCE and "extends RefCounted" in REBALANCE
for source in [DEPLOYMENT, REBALANCE]:
    for forbidden in ["configure(host", "NodePath", "get_node(", ".connect(", "Control", "Button", "Camera", "popup", "change_scene", "save_worldmap", "_player_state", "_city_runtime_states", "_hero_runtime_states"]:
        assert forbidden not in source, f"service crossed UI/host boundary: {forbidden}"
for forbidden in ["BattleResultService", "BattleSettlementApplier", "StrategicBattleTransactionService", "WoundedRecoveryService", "T03BattlePresentationController", "AutoBattleResolver"]:
    assert forbidden not in DEPLOYMENT and forbidden not in REBALANCE, f"M-9 duplicated protected service: {forbidden}"
for method in ["build_payload", "get_deployable_heroes", "validate", "calculate_supply_cost", "check_affordability", "can_pay_supply", "pay_supply", "select_city_battle_supply", "apply_context_side_pre_decrement", "move_generals_for_expedition", "apply_departure", "rollback_departure"]:
    assert f"func {method}(" in DEPLOYMENT, f"missing deployment method: {method}"
for key in ["ok", "error_code", "selected_hero_ids", "attacker_troop_allocation", "total_troops", "supply_cost", "resource_changes", "duplicate", "rolled_back"]:
    assert f'"{key}"' in DEPLOYMENT, f"missing structured deployment result: {key}"
assert "ExpeditionSupplyCalculatorScript.minimum_food" in DEPLOYMENT
assert "ExpeditionSupplyCalculatorScript.minimum_gold" in DEPLOYMENT
assert 'context.get(deployed_key, false)' in DEPLOYMENT
assert "_paid_transaction_ids" in DEPLOYMENT and "_applied_transaction_ids" in DEPLOYMENT and "_rolled_back_transaction_ids" in DEPLOYMENT
assert "func calculate_suggestions(" in REBALANCE and "func apply_suggestion(" in REBALANCE
assert '"can_move_troops"' in REBALANCE and '"move_troops"' in REBALANCE
assert "set_last_suggestions" not in REBALANCE, "rebalance calculation must stay pure"

for wrapper, delegate in {
    "_build_player_attack_deployment_payload": "build_payload",
    "_get_deployable_player_heroes_for_city": "get_deployable_heroes",
    "_validate_player_attack_deployment": ".validate(",
    "_calculate_player_attack_supply_cost": "calculate_supply_cost",
    "_can_pay_player_attack_supply_cost": "can_pay_supply",
    "_pay_player_attack_supply_cost": "pay_supply",
    "_move_generals_for_pending_expedition": "move_generals_for_expedition",
    "_select_city_battle_supply": "select_city_battle_supply",
    "_apply_context_side_troop_pre_decrement_mvp": "apply_context_side_pre_decrement",
    "_calculate_troop_rebalance_suggestions": "calculate_suggestions",
    "_apply_troop_rebalance_suggestion": "apply_suggestion",
}.items():
    assert delegate in current[wrapper], f"non-delegating M-9 wrapper: {wrapper}"

confirm = current["_confirm_player_attack_deployment"]
assert confirm.index("_build_player_attack_battle_context") < confirm.index("apply_departure")
assert "_set_pending_battle_context_mvp" in confirm and "_serialize_worldmap_state" in confirm and "_handoff_battle_context_to_battle_scene" in confirm
for direct_mutation in ["_set_city_runtime_troops", "_pay_player_attack_supply_cost", "_move_generals_for_pending_expedition", "_apply_context_side_troop_pre_decrement_mvp"]:
    assert direct_mutation not in confirm, f"confirm retains deployment mutation: {direct_mutation}"
rollback = current["_rollback_player_attack_handoff"]
assert "_rollback_t03_battle_transaction" in rollback and "rollback_departure" in rollback

for protected in [
    "_transfer_stationed_hero_between_player_cities", "_apply_battle_settlement_move_hero",
    "_apply_battle_settlement_hero_faction", "_rebuild_occupation_runtime_indexes_mvp",
    "_sync_worldmap_hero_locations_from_city_runtime_states", "_is_hero_captured_for_battle",
    "_get_hero_battle_exclusion_reason", "_build_player_attack_battle_context",
]:
    assert current[protected] == baseline[protected], f"M-9 changed protected C-tail/coordinator: {protected}"
for protected in ["_handoff_battle_context_to_battle_scene", "_change_scene_to_battle_with_context"]:
    assert current[protected] == m4_baseline[protected], f"post-M-4 changed protected battle handoff: {protected}"

for unchanged_path in [
    "scripts/worldmap/battle/battle_result_service.gd",
    BATTLE_SETTLEMENT_PATH,
    "scripts/worldmap/t03/strategic_battle_transaction_service.gd",
    "scripts/worldmap/military/wounded_recovery_service.gd",
    "scripts/worldmap/t03/t03_battle_presentation_controller.gd",
    "scripts/worldmap/t03/auto_battle_resolver.gd",
]:
    current_bytes = (ROOT / unchanged_path).read_bytes()
    baseline_bytes = subprocess.check_output(["git", "show", f"531123f:{unchanged_path}"], cwd=ROOT)
    if unchanged_path == BATTLE_SETTLEMENT_PATH:
        assert_af1_standard_wounded_rename(current_bytes, baseline_bytes)
    else:
        assert current_bytes == baseline_bytes, f"M-9 changed protected module: {unchanged_path}"

print("PASS: M-9 deployment/supply transaction, pre-decrement guard, pure rebalance, thin wrappers, and protected boundaries")
