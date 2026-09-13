"""Final 2D guard for complete diplomacy rule ownership separation."""

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "9bd3a356d94d04a57b4d20533ca0603f017fc6ac"
MAIN = "scripts/worldmap/worldmap_main.gd"
SERVICE = "scripts/worldmap/actions/diplomacy_action_service.gd"


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def at_base(path):
    return subprocess.check_output(
        ["git", "show", f"{BASE}:{path}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n")


def functions(source):
    result = {}
    for match in re.finditer(r"(?ms)^(?:static )?func (\w+)(\(.*?)(?=^(?:static )?func |\Z)", source):
        result[match[1]] = "\n".join(
            line for line in match[2].splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        )
    return result


def main():
    main_source = current(MAIN)
    service_source = current(SERVICE)
    main_functions = functions(main_source)
    service_functions = functions(service_source)

    deleted = {
        "_get_player_relation_target_faction_from_key",
        "_sync_alliance_mirror_state_from_relations",
        "_set_diplomacy_action_cooldown",
        "_build_diplomacy_action_failure_result",
        "_apply_diplomacy_action_legacy",
        "_apply_alliance_diplomacy_action",
        "_normalize_diplomacy_resource_package",
        "_propose_alliance",
        "_get_trade_agreement_cost",
        "_propose_trade_agreement",
        "_get_tribute_cost",
        "_can_send_tribute",
        "_calculate_tribute_relation_gain",
        "_send_tribute",
    }
    gd_sources = "\n".join(
        path.read_text(encoding="utf-8")
        for root_name in ["scripts", "tests"]
        for path in (ROOT / root_name).rglob("*.gd")
    )
    for name in deleted:
        assert name not in main_functions, f"deleted legacy function still defined: {name}"
        assert name not in gd_sources, f"deleted legacy function still has a GDScript caller/reference: {name}"

    assert '.execute_now("diplomacy", action_id, target_city_id)' in main_functions["_apply_diplomacy_action"]
    coordinator = current("scripts/worldmap/actions/worldmap_action_coordinator.gd")
    assert '"diplomacy":\n\t\t\treturn _diplomacy_service.execute(host, action_id, target_city_id, source_city_id)' in coordinator
    execute = service_functions["execute"]
    assert 'host.call("_build_diplomacy_action_validation_context", action_id, target_city_id)' in execute
    assert "apply_diplomacy_resource_cost(host, cost)" in execute
    assert "apply_diplomacy_relation_delta(" in execute
    assert "apply_alliance_action(host, prepaid_validation)" in execute
    for forbidden in ["_apply_diplomacy_action_legacy", "_apply_alliance_diplomacy_action", "_apply_generic_resource_cost", "_adjust_faction_relation_score"]:
        assert forbidden not in execute, f"production execute uses legacy host logic: {forbidden}"

    required_service_owners = {
        "get_action_definition", "validate_action", "build_failure_result",
        "normalize_resource_package", "normalize_diplomacy_relation_entry",
        "apply_diplomacy_resource_cost", "apply_diplomacy_relation_delta",
        "get_diplomacy_action_cooldown", "set_diplomacy_action_cooldown",
        "advance_diplomacy_state_entry", "apply_trade_agreement_state",
        "propose_trade_agreement", "sync_diplomacy_mirror_state",
        "restore_diplomacy_state_from_mirrors", "calculate_alliance_acceptance_chance",
        "propose_alliance", "apply_alliance_action", "advance_alliance_state_entry",
        "sync_alliance_mirror_state", "restore_alliance_state_from_mirror",
        "get_active_alliance_turns",
    }
    assert required_service_owners.issubset(service_functions), "service owner function set incomplete"
    assert 'entry["tribute_cooldown"] = after_tribute_cooldown' in service_functions["advance_diplomacy_state_entry"]
    assert 'entry["diplomacy_action_cooldown"] = after_action_cooldown' in service_functions["advance_diplomacy_state_entry"]
    assert 'entry["trade_agreement_active"] = false' in service_functions["advance_diplomacy_state_entry"]
    assert 'entry["status"] = RELATION_STATUS_NEUTRAL' in service_functions["advance_alliance_state_entry"]
    assert 'player_state["alliances"] = alliances' in service_functions["sync_alliance_mirror_state"]

    thin_wrappers = {
        "_apply_diplomacy_action": "execute_now",
        "_get_diplomacy_action_definition": "get_action_definition",
        "_validate_diplomacy_action": "validate_action",
        "_get_diplomacy_action_cooldown": "get_diplomacy_action_cooldown",
        "_get_trade_agreement_bonus_multiplier": "get_trade_agreement_bonus_multiplier",
        "_get_active_trade_agreement_turns": "get_active_trade_agreement_turns",
        "_calculate_alliance_acceptance_chance": "calculate_alliance_acceptance_chance",
        "_get_active_alliance_turns": "get_active_alliance_turns",
    }
    for name, target in thin_wrappers.items():
        body = main_functions[name]
        assert target in body, f"compatibility wrapper target missing: {name}"
        assert len(body.splitlines()) <= 2, f"compatibility wrapper is not thin: {name}"

    sync_body = main_functions["_sync_diplomacy_action_mirror_state_from_relations"]
    assert "sync_diplomacy_mirror_state" in sync_body and "sync_alliance_mirror_state" in sync_body
    normalize_body = main_functions["_normalize_diplomacy_action_state_from_player_state"]
    assert "restore_diplomacy_state_from_mirrors" in normalize_body and "restore_alliance_state_from_mirror" in normalize_body
    ensure_body = main_functions["_ensure_faction_relation_entry"]
    assert "normalize_diplomacy_relation_entry" in ensure_body
    for forbidden in ["alliance_created_turn", "alliance_resource_package", "trade_agreement_active", "trade_agreement_bonus"]:
        assert forbidden not in ensure_body, f"main relation adapter still implements diplomacy normalization: {forbidden}"
    advance_body = main_functions["_advance_diplomacy_cooldowns_for_world_turn"]
    assert "advance_diplomacy_state_entry" in advance_body and "advance_alliance_state_entry" in advance_body
    for forbidden in ["before_tribute_cooldown", "before_action_cooldown", "before_agreement_turns", "before_alliance_turns"]:
        assert forbidden not in advance_body, f"main turn entry still calculates diplomacy state: {forbidden}"

    for forbidden_constant in [
        "const TRIBUTE_COOLDOWN_TURNS", "const TRIBUTE_RELATION_GAIN_MIN",
        "const TRIBUTE_RELATION_GAIN_MAX", "const TRIBUTE_BASE_COST",
        "const TRADE_AGREEMENT_SCORE_REQUIREMENT", "const TRADE_AGREEMENT_TURNS",
        "const TRADE_AGREEMENT_MULTIPLIER_BONUS", "const TRADE_AGREEMENT_COST",
        "const DIPLOMACY_ACTION_TRADE_AGREEMENT_TURNS", "const DIPLOMACY_ACTION_ALLIANCE_TURNS",
        "const DIPLOMACY_ACTION_ALLIANCE_COST", "const ALLIANCE_ACCEPTANCE_THRESHOLD := 70",
    ]:
        assert forbidden_constant not in main_source, f"diplomacy rule constant duplicated in main: {forbidden_constant}"

    old_main_functions = functions(at_base(MAIN))
    for protected in ["_calculate_military_support_acceptance_chance", "_request_military_support", "_break_spy_wedge_alliance_if_needed"]:
        assert main_functions[protected] == old_main_functions[protected], f"cross-domain boundary changed: {protected}"
    for path in [
        "scripts/worldmap/actions/spy_action_service.gd",
        "scripts/worldmap/actions/trade_action_service.gd",
        "scripts/worldmap/actions/worldmap_action_coordinator.gd",
    ]:
        assert current(path) == at_base(path), f"out-of-scope production file changed: {path}"

    print("PASS: diplomacy 2D service separation; legacy callers 0, production service-only, main wrappers/adapters thin, military/spy/trade boundaries preserved")


if __name__ == "__main__":
    main()
