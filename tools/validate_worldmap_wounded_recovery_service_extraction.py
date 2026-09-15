"""Static M-7 boundary validator; runtime rules are covered by the Godot test."""

from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MAIN_PATH = "scripts/worldmap/worldmap_main.gd"
SERVICE_PATH = "scripts/worldmap/military/wounded_recovery_service.gd"
MAIN = (ROOT / MAIN_PATH).read_text(encoding="utf-8")
SERVICE = (ROOT / SERVICE_PATH).read_text(encoding="utf-8")
M6_MAIN = subprocess.check_output(
    ["git", "show", f"d2d9686:{MAIN_PATH}"], cwd=ROOT, text=True, encoding="utf-8"
)


def functions(source: str) -> dict[str, str]:
    matches = list(re.finditer(r"(?m)^func\s+([A-Za-z0-9_]+)\([^\n]*", source))
    return {
        match.group(1): source[match.start() : matches[index + 1].start() if index + 1 < len(matches) else len(source)].rstrip()
        for index, match in enumerate(matches)
    }


current = functions(MAIN)
baseline = functions(M6_MAIN)

assert "class_name WorldMapWoundedRecoveryService" in SERVICE
assert "extends RefCounted" in SERVICE
for forbidden in ["extends Node", "NodePath", "get_node(", ".connect(", "Camera", "popup", "change_scene", "save_worldmap", "HUD", "configure(host"]:
    assert forbidden not in SERVICE, f"forbidden service dependency: {forbidden}"
for method in [
    "get_city_wounded_queue", "add_wounded_to_city", "clear_city_wounded_queue",
    "apply_battle_hero_status", "world_month_serial", "advance_recovery_month",
    "evaluate_fast_treatment", "apply_fast_treatment",
]:
    assert f"func {method}(" in SERVICE, f"missing domain method: {method}"
for key in [
    "ok", "action", "city_id", "hero_id", "turns_before", "turns_after",
    "resource_changes", "queue_changed", "recovered_hero_ids", "error_code", "warnings",
]:
    assert f'"{key}"' in SERVICE, f"missing structured result key: {key}"
for dependency in ["_query.call(query_id, args)", "_mutation.call(mutation_id, args)"]:
    assert dependency in SERVICE, f"missing narrow dependency: {dependency}"
assert "WoundedRecoveryRulesScript.advance_month(queue)" in SERVICE, "existing T02 recovery rule must be reused"
assert "ExpeditionSupplyCalculatorScript.fast_recovery_salt(wounded)" in SERVICE, "existing salt rule must be reused"

for wrapper, delegate in {
    "_apply_battle_settlement_hero_status": "apply_battle_hero_status",
    "_get_city_wounded_queue_mvp": "get_city_wounded_queue",
    "_add_wounded_to_city_mvp": "add_wounded_to_city",
    "_clear_city_wounded_queue_mvp": "clear_city_wounded_queue",
    "_apply_wounded_recovery_for_world_turn_mvp": "advance_recovery_month",
    "_get_world_month_serial": "world_month_serial",
    "_advance_wounded_hero_recovery_turns": "advance_recovery_month",
}.items():
    assert delegate in current[wrapper], f"non-delegating compatibility wrapper: {wrapper}"

fast = current["_on_fast_wounded_treatment_pressed"]
assert "apply_fast_treatment" in fast
assert "_refresh_wounded_treatment_controls" in fast and "_save_worldmap_state" in fast
for direct_state in ["_city_runtime_states", "_hero_runtime_states", "woundedQueue", "wounded_turns_remaining", "resource_stock"]:
    assert direct_state not in fast, f"fast-treatment callback retains domain mutation: {direct_state}"
controls = current["_refresh_wounded_treatment_controls"]
assert "evaluate_fast_treatment" in controls and "_wounded_fast_treatment_button" in controls
advance = current["_advance_world_turn_mvp"]
assert "advance_recovery_month(next_month_serial)" in advance
assert "_advance_wounded_hero_recovery_turns()" not in advance
serialization = current["_serialize_worldmap_hero_runtime_state"]
normalization = current["_normalize_hero_runtime_state"]
for persisted in ["last_battle_current_troops", "last_battle_max_troops", "last_battle_transaction_id"]:
    assert persisted in serialization and persisted in normalization, f"missing hero recovery linkage persistence: {persisted}"
assert '"last_wounded_recovery_month_serial": -1' in MAIN

settlement = current["_battle_settlement_mutation"]
assert '"set_hero_status"' in settlement and "_apply_battle_settlement_hero_status" in settlement
assert "BattleResultService" not in SERVICE and "BattleSettlementApplier" not in SERVICE

for protected in [
    "_is_hero_captured_for_battle", "_get_hero_battle_exclusion_reason",
    "_sync_worldmap_hero_locations_from_city_runtime_states",
    "_rebuild_occupation_runtime_indexes_mvp",
]:
    assert current[protected] == baseline[protected], f"M-7 changed protected function: {protected}"

print("PASS: M-7 wounded/recovery domain, thin wrappers, lifecycle guard, UI boundary, and settlement adapter")
