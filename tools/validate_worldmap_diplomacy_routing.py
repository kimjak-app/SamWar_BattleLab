"""Diplomacy 2C-2 guard: preserve recovery functions and own alliance state.

Compare with the verified recovery HEAD, not a moving branch name. Runtime
behavior is covered separately by test_worldmap_diplomacy_routing.gd.
"""

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "e066b59a28226de1e5f4680ae11b651926903361"
PHASE_2B_BASE = "6b3bf867544cf6cbdd48ba7eed8be7f3e3ef3ded"
PHASE_2C1_BASE = "b54dadcf7a586968c84ef185f9527231ef4646a4"
MAIN = "scripts/worldmap/worldmap_main.gd"


def original(path):
    return subprocess.check_output(
        ["git", "show", f"{BASE}:{path}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n")


def at_commit(commit, path):
    return subprocess.check_output(
        ["git", "show", f"{commit}:{path}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n")


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def functions(source):
    # Ignore comments/blank lines when comparing function bodies. Keep every
    # executable line, including indentation and signal connections.
    result = {}
    for match in re.finditer(r"(?ms)^(?:static )?func (\w+)(\(.*?)(?=^(?:static )?func |\Z)", source):
        result[match[1]] = "\n".join(
            line for line in match[2].splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        )
    return result


def main():
    before, after = functions(original(MAIN)), functions(current(MAIN))
    bridges = {
        "open_contextual_worldmap_action", "cancel_contextual_worldmap_action",
        "complete_contextual_worldmap_action",
        "_request_contextual_worldmap_action_presentation",
        "_apply_diplomacy_action", "_on_diplomacy_action_pressed",
        # Later domain phases may extend the shared bridge without changing
        # the phase-one diplomacy implementation checked below.
        "_apply_spy_action", "_on_spy_action_pressed",
        "_execute_external_manual_trade_order",
        "_on_manual_trade_execution_button_pressed",
        # Phase 2A moves diplomacy validation/pure calculations.
        "_get_diplomacy_action_definition",
        "_validate_diplomacy_action",
        "_build_diplomacy_action_failure_result",
        "_normalize_diplomacy_resource_package",
        # Phase 2C-2 retains compatibility APIs while moving alliance logic.
        "_apply_alliance_diplomacy_action",
        "_propose_alliance",
        "_calculate_alliance_acceptance_chance",
        "_sync_alliance_mirror_state_from_relations",
        "_get_active_alliance_turns",
        # Phase 2C-1 moves cooldown/trade-agreement state and their mirror
        # implementation while retaining main compatibility/turn entries.
        "_normalize_diplomacy_action_state_from_player_state",
        "_sync_diplomacy_action_mirror_state_from_relations",
        "_get_diplomacy_action_cooldown",
        "_set_diplomacy_action_cooldown",
        "_propose_trade_agreement",
        "_get_trade_agreement_bonus_multiplier",
        "_get_active_trade_agreement_turns",
        "_advance_diplomacy_cooldowns_for_world_turn",
    }
    for name, body in before.items():
        assert name in after, f"removed function: {name}"
        if name not in bridges:
            assert after[name] == body, f"out-of-scope function changed: {name}"
    assert after["_apply_diplomacy_action_legacy"] == before["_apply_diplomacy_action_legacy"], "legacy implementation changed"
    phase_2c1 = functions(at_commit(PHASE_2C1_BASE, MAIN))
    for name in ["_calculate_military_support_acceptance_chance", "_request_military_support", "_break_spy_wedge_alliance_if_needed"]:
        assert after[name] == phase_2c1[name], f"2C-2 changed protected military/spy function: {name}"
    for name in [
        "_adjust_faction_relation_score", "_request_military_support",
        "_send_tribute", "_apply_generic_resource_cost",
    ]:
        assert after[name] == before[name], f"diplomacy mutation function changed: {name}"
    assert len(current(MAIN).splitlines()) >= len(at_commit(PHASE_2C1_BASE, MAIN).splitlines()) - 250, "host shortened beyond the 2C-2 extraction budget"
    for file in ["spy_action_service.gd", "worldmap_action_coordinator.gd"]:
        path = "scripts/worldmap/actions/" + file
        assert current(path) == original(path), f"shared routing/service changed: {file}"
    presentation = "scripts/worldmap/ui/worldmap_action_presentation_controller.gd"
    assert current(presentation) == original(presentation), "presentation contract changed"
    ui = "scripts/worldmap/ui/worldmap_city_action_test_controller.gd"
    old_ui, new_ui = functions(original(ui)), functions(current(ui))
    for name in old_ui:
        if name != "_on_contextual_action_pressed":
            assert old_ui[name] == new_ui[name], f"unrelated UI changed: {name}"
    assert '\telse:\n\t\taction_video_test_requested.emit(action_type, target_city_id)' in new_ui["_on_contextual_action_pressed"]
    assert '.execute_now("diplomacy", action_id, target_city_id)' in after["_apply_diplomacy_action"]
    assert '.complete(action_type, action_id, target_city_id)' in after["complete_contextual_worldmap_action"]
    assert '.begin("diplomacy", target_city_id)' in after["open_contextual_worldmap_action"]
    service = current("scripts/worldmap/actions/diplomacy_action_service.gd")
    assert 'host.call("_get_current_player_faction_id")' in service
    assert "PLAYER_FACTION_ID" not in service
    service_functions = functions(service)
    for name in ["get_action_definition", "validate_action", "build_failure_result", "normalize_resource_package"]:
        assert name in service_functions, f"extracted service function missing: {name}"
    for name in ["get_action_definition", "validate_action", "build_failure_result", "normalize_resource_package"]:
        pure_body = service_functions[name]
        for forbidden in ["host.", "_player_state", "_apply_generic_resource_cost", "_adjust_faction_relation_score", "_set_diplomacy_action_cooldown"]:
            assert forbidden not in pure_body, f"{name} owns forbidden side effect/dependency: {forbidden}"
    assert "DiplomacyActionServiceScript.get_action_definition(action_id)" in after["_get_diplomacy_action_definition"]
    assert "DiplomacyActionServiceScript.validate_action" in after["_validate_diplomacy_action"]
    assert "DiplomacyActionServiceScript.build_failure_result" in after["_build_diplomacy_action_failure_result"]
    assert "DiplomacyActionServiceScript.normalize_resource_package" in after["_normalize_diplomacy_resource_package"]
    for name in ["_get_diplomacy_action_definition", "_validate_diplomacy_action", "_build_diplomacy_action_failure_result", "_normalize_diplomacy_resource_package"]:
        assert len(after[name].splitlines()) <= 2, f"host compatibility API is not a thin wrapper: {name}"
    assert 'host.call("_build_diplomacy_action_validation_context", action_id, target_city_id)' in service_functions["execute"]
    for name in ["apply_diplomacy_resource_cost", "apply_diplomacy_relation_delta"]:
        assert name in service_functions, f"2B mutation function missing: {name}"
        body = service_functions[name]
        assert 'host.set("_player_state", player_state)' in body, f"{name} does not commit state"
        assert '_apply_generic_resource_cost' not in body, f"{name} delegates resource mutation to host"
        assert '_adjust_faction_relation_score' not in body, f"{name} delegates relation mutation to host"
    assert 'resource_stock[resource_id] = before_amount - paid_amount' in service_functions["apply_diplomacy_resource_cost"], "resource subtraction implementation missing"
    assert 'entry["score"] = after_score' in service_functions["apply_diplomacy_relation_delta"], "relation score mutation implementation missing"
    assert 'player_state["last_diplomacy_relation_result"] = result' in service_functions["apply_diplomacy_relation_delta"], "relation result state contract missing"
    execute = service_functions["execute"]
    assert "apply_diplomacy_resource_cost(host, cost)" in execute, "execute does not own diplomacy cost application"
    assert "apply_diplomacy_relation_delta(" in execute, "execute does not own diplomacy relation application"
    assert '_apply_generic_resource_cost' not in execute, "execute still routes diplomacy cost through shared host helper"
    assert '_adjust_faction_relation_score' not in execute, "execute still routes diplomacy relation through shared host helper"
    assert "prepaid_payment: Dictionary = {}" in after["_propose_alliance"], "alliance compatibility API lost prepaid payment"
    for name in [
        "get_diplomacy_action_cooldown", "set_diplomacy_action_cooldown",
        "apply_trade_agreement_state", "advance_diplomacy_state_entry",
        "sync_diplomacy_mirror_state", "restore_diplomacy_state_from_mirrors",
        "get_trade_agreement_bonus_multiplier", "get_active_trade_agreement_turns",
        "propose_trade_agreement",
    ]:
        assert name in service_functions, f"2C-1 service function missing: {name}"
    assert 'relation_entry["diplomacy_action_cooldown"] = maxi(0, turns)' in service_functions["set_diplomacy_action_cooldown"], "cooldown set mutation not owned by service"
    assert 'entry["diplomacy_action_cooldown"] = after_action_cooldown' in service_functions["advance_diplomacy_state_entry"], "cooldown advance not owned by service"
    assert 'entry["trade_agreement_active"] = false' in service_functions["advance_diplomacy_state_entry"], "agreement expiry not owned by service"
    assert 'relation_entry["trade_agreement_active"] = true' in service_functions["apply_trade_agreement_state"], "agreement creation not owned by service"
    assert 'player_state["diplomacy_action_cooldowns"] = cooldowns' in service_functions["sync_diplomacy_mirror_state"], "cooldown mirror not owned by service"
    assert 'player_state["trade_agreements"] = agreements' in service_functions["sync_diplomacy_mirror_state"], "agreement mirror not owned by service"
    assert "DiplomacyActionServiceScript.new().get_diplomacy_action_cooldown" in after["_get_diplomacy_action_cooldown"]
    assert "DiplomacyActionServiceScript.new().set_diplomacy_action_cooldown" in after["_set_diplomacy_action_cooldown"]
    assert "DiplomacyActionServiceScript.new().propose_trade_agreement" in after["_propose_trade_agreement"]
    assert "DiplomacyActionServiceScript.new().sync_diplomacy_mirror_state" in after["_sync_diplomacy_action_mirror_state_from_relations"]
    assert "_sync_alliance_mirror_state_from_relations()" in after["_sync_diplomacy_action_mirror_state_from_relations"]
    assert "before_tribute_cooldown" in after["_advance_diplomacy_cooldowns_for_world_turn"], "tribute cooldown left main unexpectedly"
    for forbidden in ["before_action_cooldown", "before_agreement_turns", 'entry["trade_agreement_active"] = false']:
        assert forbidden not in after["_advance_diplomacy_cooldowns_for_world_turn"], f"main still owns 2C-1 advance mutation: {forbidden}"
    for name in [
        "calculate_alliance_acceptance_chance", "propose_alliance", "apply_alliance_action",
        "advance_alliance_state_entry", "sync_alliance_mirror_state",
        "restore_alliance_state_from_mirror", "get_active_alliance_turns",
    ]:
        assert name in service_functions, f"2C-2 alliance service function missing: {name}"
    assert 'updated_relation["status"] = RELATION_STATUS_ALLIED' in service_functions["propose_alliance"], "alliance creation not owned by service"
    assert 'updated_relation["alliance_turns_remaining"] = duration_turns' in service_functions["propose_alliance"], "alliance duration not owned by service"
    assert 'player_state["last_alliance_proposal_result"] = {' in service_functions["propose_alliance"], "alliance result not owned by service"
    assert 'payment_result := prepaid_payment if not prepaid_payment.is_empty() else apply_diplomacy_resource_cost' in service_functions["propose_alliance"], "alliance prepaid/single-payment path missing"
    assert 'entry["status"] = RELATION_STATUS_NEUTRAL' in service_functions["advance_alliance_state_entry"], "alliance expiry not owned by service"
    assert 'player_state["alliances"] = alliances' in service_functions["sync_alliance_mirror_state"], "alliance mirror not owned by service"
    assert 'relation_entry["status"] = RELATION_STATUS_ALLIED' in service_functions["restore_alliance_state_from_mirror"], "alliance restore not owned by service"
    execute = service_functions["execute"]
    assert "apply_alliance_action(host, prepaid_validation)" in execute, "production alliance execution does not stay in service"
    assert '"_apply_alliance_diplomacy_action"' not in execute, "production alliance execution still calls host implementation"
    wrapper_targets = {
        "_apply_alliance_diplomacy_action": "apply_alliance_action",
        "_propose_alliance": "propose_alliance",
        "_calculate_alliance_acceptance_chance": "calculate_alliance_acceptance_chance",
        "_sync_alliance_mirror_state_from_relations": "sync_alliance_mirror_state",
        "_get_active_alliance_turns": "get_active_alliance_turns",
    }
    for name, target in wrapper_targets.items():
        assert f"DiplomacyActionServiceScript.new().{target}" in after[name], f"alliance wrapper does not delegate: {name}"
        assert len(after[name].splitlines()) <= 2, f"alliance compatibility API is not thin: {name}"
    assert "restore_alliance_state_from_mirror" in after["_normalize_diplomacy_action_state_from_player_state"]
    assert "advance_alliance_state_entry" in after["_advance_diplomacy_cooldowns_for_world_turn"]
    for forbidden in ["before_alliance_turns", 'entry["alliance_turns_remaining"] =', 'entry.erase("alliance_created_turn")']:
        assert forbidden not in after["_advance_diplomacy_cooldowns_for_world_turn"], f"main still owns alliance expiry mutation: {forbidden}"
    print(f"PASS: diplomacy routing/static 2C-2 guard; {len(before)} original functions retained, 2A/2B/2C-1 preserved, alliance acceptance/state/expiry/mirror owned by service, military/spy protected")


if __name__ == "__main__":
    main()
