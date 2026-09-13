"""Spy Controller extraction guard: ownership, routing, domain boundaries, and frozen systems."""

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "90cfe4343977cd70ed9e512ec3a3b35c2f41bd71"
MAIN = "scripts/worldmap/worldmap_main.gd"
COORDINATOR = "scripts/worldmap/actions/worldmap_action_coordinator.gd"
CONTROLLER = "scripts/worldmap/actions/spy_controller.gd"
SERVICE = "scripts/worldmap/actions/spy_action_service.gd"
PRESENTER = "scripts/worldmap/actions/spy_presentation_helper.gd"
SPY_MAIN_REMOVED = {
    "_get_selected_spy_target", "_get_spy_result_key_for_action", "_apply_spy_detection_relation_penalty",
    "_store_failed_spy_action_result", "_apply_spy_action_legacy", "_get_spy_info_success_chance",
    "_get_city_security_score_for_spy", "_calculate_spy_detection_chance", "_get_spy_info_visibility_level",
    "_can_gather_spy_info", "_roll_spy_info_result", "_build_spy_info_payload", "_gather_spy_info",
    "_can_disrupt_city_public_support", "_roll_spy_public_support_disrupt_result", "_disrupt_city_public_support",
    "_can_disrupt_city_loyalty", "_roll_spy_loyalty_disrupt_result", "_disrupt_city_loyalty",
    "_can_instigate_revolt", "_roll_spy_revolt_instigation_result", "_instigate_revolt",
    "_get_spy_wedge_candidate_faction_ids", "_get_spy_wedge_counterpart_faction_id",
    "_get_spy_wedge_success_chance", "_can_wedge_faction_relation", "_can_drive_wedge",
    "_roll_spy_wedge_result", "_drive_wedge", "_roll_spy_wedge_city_result",
    "_break_spy_wedge_alliance_if_needed", "_apply_spy_wedge_action",
    "_get_modified_spy_success_chance_mvp", "_get_modified_spy_detection_chance_mvp",
    "_get_modified_spy_visibility_level_mvp", "_record_city_intel_from_spy_result",
}


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def at_base(path):
    return subprocess.check_output(["git", "show", f"{BASE}:{path}"], cwd=ROOT).decode("utf-8").replace("\r\n", "\n")


def functions(source):
    return {
        m[1]: "\n".join(line for line in m[2].splitlines() if line.strip() and not line.lstrip().startswith("#"))
        for m in re.finditer(r"(?ms)^func (\w+)(\(.*?)(?=^func |\Z)", source)
    }


def main():
    host = current(MAIN)
    coordinator = current(COORDINATOR)
    controller = current(CONTROLLER)
    service = current(SERVICE)
    presenter = current(PRESENTER)

    assert "SpyActionServiceScript" not in coordinator
    assert "var _spy_controller: RefCounted" in coordinator
    assert "func configure_spy(controller: RefCounted)" in coordinator
    assert "return _spy_controller.execute(action_id, target_city_id, source_city_id)" in coordinator
    assert "configure_spy(_ensure_spy_controller())" in host
    assert controller.count("SpyActionServiceScript.new()") == 1
    assert "SpyActionServiceScript.new()" not in host + coordinator
    assert "_service.execute(self, action_id, target_city_id, source_city_id)" in controller

    service_functions = functions(service)
    required_rules = {
        "_validate_spy_action", "_gather_spy_info", "_disrupt_city_public_support",
        "_disrupt_city_loyalty", "_instigate_revolt", "_apply_spy_wedge_action",
        "_roll_spy_info_result", "_roll_spy_public_support_disrupt_result",
        "_roll_spy_loyalty_disrupt_result", "_roll_spy_revolt_instigation_result",
        "_roll_spy_wedge_city_result", "_get_spy_wedge_success_chance",
        "_advance_revolt_instigation_for_world_turn", "_advance_spy_cooldown_for_world_turn",
    }
    assert required_rules.issubset(service_functions), "Spy Service owner function set incomplete"
    for legacy_host_call in [
        '_adapter.call("_validate_spy_action"', '_adapter.call("_gather_spy_info"',
        '_adapter.call("_disrupt_city_public_support"', '_adapter.call("_disrupt_city_loyalty"',
        '_adapter.call("_instigate_revolt"', '_adapter.call("_apply_spy_wedge_action"',
    ]:
        assert legacy_host_call not in service, f"Service still dispatches Spy implementation to main: {legacy_host_call}"

    for name in SPY_MAIN_REMOVED:
        assert f"func {name}(" not in host, f"Spy implementation remains in main: {name}"

    host_functions = functions(host)
    for bridge, target in {
        "_apply_spy_action": "execute_now", "_validate_spy_action": "validate_spy_action",
        "_advance_spy_cooldown_for_world_turn": "advance_spy_cooldown_for_world_turn",
        "_advance_revolt_instigation_for_world_turn": "advance_revolt_instigation_for_world_turn",
        "_normalize_city_intel_registry": "normalize_city_intel_registry",
    }.items():
        assert target in host_functions[bridge] and len(host_functions[bridge].splitlines()) <= 2, f"Main Spy bridge not thin: {bridge}"

    for method in ["format_visibility_summary", "format_known_info_summary", "format_action_candidates", "format_recent_result", "format_action_policy", "format_action_hint", "format_player_tech_modifier_summary", "format_cooldown_summary", "format_last_summary"]:
        assert f"func {method}(" in presenter, f"Spy presentation formatter missing: {method}"
    assert "Button.new" not in presenter and "Label.new" not in presenter

    assert '_diplomacy().call("apply_spy_relation_delta"' in controller
    assert '_diplomacy().call("break_alliance_for_spy_wedge"' in controller
    assert "faction_relations" not in service and "alliances" not in service
    diplomacy_controller = current("scripts/worldmap/actions/diplomacy_controller.gd")
    assert "func apply_spy_relation_delta(" in diplomacy_controller
    assert "func break_alliance_for_spy_wedge(" in diplomacy_controller

    # Existing Diplomacy/Trade Services and Military/Battle production remain frozen.
    for path in [
        "scripts/worldmap/actions/diplomacy_action_service.gd",
        "scripts/worldmap/actions/trade_action_service.gd",
        "scripts/worldmap/actions/trade_controller.gd",
        "scripts/worldmap/actions/trade_presentation_helper.gd",
        "scripts/worldmap/ui/worldmap_action_presentation_controller.gd",
    ]:
        assert current(path) == at_base(path), f"Frozen production file changed: {path}"
    old_main, new_main = functions(at_base(MAIN)), host_functions
    for name in ["_calculate_military_support_acceptance_chance", "_request_military_support", "_handoff_to_battle"]:
        if name in old_main:
            assert new_main[name] == old_main[name], f"Military/Battle boundary changed: {name}"

    subprocess.run(["python", "tools/validate_worldmap_main_integrity.py"], cwd=ROOT, check=True, capture_output=True)
    print("PASS: Spy Controller/Service/Presenter ownership; Diplomacy boundary explicit; Trade/Military/Battle frozen")


if __name__ == "__main__":
    main()
