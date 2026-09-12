"""Phase-two guard for the production spy routing extraction."""

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "ba52b9fdf523cbf5450397e8d2948ce817f3509e"
PHASE_2B_BASE = "6b3bf867544cf6cbdd48ba7eed8be7f3e3ef3ded"
MAIN = "scripts/worldmap/worldmap_main.gd"


def original(path):
    return subprocess.check_output(
        ["git", "show", f"{BASE}:{path}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n")


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def at_commit(commit, path):
    return subprocess.check_output(
        ["git", "show", f"{commit}:{path}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n")


def functions(source):
    result = {}
    for match in re.finditer(r"(?ms)^func (\w+)(\(.*?)(?=^func |\Z)", source):
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
        "_apply_spy_action", "_on_spy_action_pressed",
        "_execute_external_manual_trade_order",
        "_on_manual_trade_execution_button_pressed",
        "_get_diplomacy_action_definition",
        "_validate_diplomacy_action",
        "_build_diplomacy_action_failure_result",
        "_normalize_diplomacy_resource_package",
        "_apply_alliance_diplomacy_action",
        "_propose_alliance",
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
    assert after["_apply_spy_action_legacy"] == before["_apply_spy_action"], "legacy spy implementation changed"
    assert 'validation.get("payment", {})' in after["_apply_alliance_diplomacy_action"], "diplomacy 2B alliance payment adapter missing"
    assert "prepaid_payment: Dictionary = {}" in after["_propose_alliance"], "diplomacy 2B alliance payment handoff missing"
    assert len(current(MAIN).splitlines()) >= len(at_commit(PHASE_2B_BASE, MAIN).splitlines()) - 250, "host shortened beyond approved 2C-1 extraction budget"

    for file in ["spy_action_service.gd", "worldmap_action_coordinator.gd"]:
        path = "scripts/worldmap/actions/" + file
        assert current(path) == original(path), f"existing service/coordinator changed: {file}"
    presentation = "scripts/worldmap/ui/worldmap_action_presentation_controller.gd"
    assert current(presentation) == original(presentation), "presentation contract changed"

    ui = "scripts/worldmap/ui/worldmap_city_action_test_controller.gd"
    old_ui, new_ui = functions(original(ui)), functions(current(ui))
    for name in old_ui:
        if name != "_on_contextual_action_pressed":
            assert old_ui[name] == new_ui[name], f"unrelated UI changed: {name}"
    ui_entry = new_ui["_on_contextual_action_pressed"]
    assert all(action in ui_entry for action in ['"diplomacy"', '"spy"', '"trade"'])
    assert '\telse:\n\t\taction_video_test_requested.emit(action_type, target_city_id)' in ui_entry

    assert '.begin("diplomacy", target_city_id)' in after["open_contextual_worldmap_action"]
    assert '.begin("spy", target_city_id)' in after["open_contextual_worldmap_action"]
    assert '.execute_now("diplomacy", action_id, target_city_id)' in after["_apply_diplomacy_action"]
    assert '.execute_now("spy", action_id, target_city_id)' in after["_apply_spy_action"]
    assert 'if action_type == "spy":' in after["complete_contextual_worldmap_action"]
    assert '_pending_spy_action_id' in after["complete_contextual_worldmap_action"]

    coordinator = current("scripts/worldmap/actions/worldmap_action_coordinator.gd")
    assert '"spy":\n\t\t\treturn _spy_service.execute(host, action_id, target_city_id, source_city_id)' in coordinator
    spy_service = current("scripts/worldmap/actions/spy_action_service.gd")
    for helper in ["_validate_spy_action", "_store_failed_spy_action_result", "_gather_spy_info", "_disrupt_city_public_support", "_disrupt_city_loyalty", "_instigate_revolt", "_apply_spy_wedge_action"]:
        assert f'"{helper}"' in spy_service, f"service helper missing: {helper}"

    print(f"PASS: spy routing static guard; {len(before)} prior functions retained, legacy body identical, spy/coordinator unchanged; diplomacy 2C-1 bridges allowed")


if __name__ == "__main__":
    main()
