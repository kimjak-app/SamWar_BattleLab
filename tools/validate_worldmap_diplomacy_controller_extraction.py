"""2F guard: one diplomacy owner, unchanged shared coordinator contracts."""

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "114cb33283ef08e4282dff4f79b130127039d4ac"
COORDINATOR = "scripts/worldmap/actions/worldmap_action_coordinator.gd"
CONTROLLER = "scripts/worldmap/actions/diplomacy_controller.gd"


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def baseline(path):
    return subprocess.check_output(["git", "show", f"{BASE}:{path}"], cwd=ROOT).decode("utf-8").replace("\r\n", "\n")


def check_coordinator():
    source = current(COORDINATOR)
    assert "DiplomacyActionServiceScript" not in source
    assert "var _diplomacy_controller: RefCounted" in source
    assert "func configure_diplomacy(controller: RefCounted)" in source
    assert "return _diplomacy_controller.execute(action_id, target_city_id, source_city_id)" in source
    for contract in ["func begin(", "func cancel(", "func request_presentation(", "func complete(", "func execute_now(", "signal action_resolved", "signal presentation_requested"]:
        assert contract in source, f"Coordinator contract missing: {contract}"




CONTROLLER_FUNCTIONS = {
    "_make_faction_relation_key",
    "_normalize_faction_relation_status",
    "_get_faction_relation_band",
    "_ensure_faction_relation_entry",
    "_get_faction_relation_entry",
    "_get_faction_relation_score",
    "_get_faction_relation_status",
    "_normalize_diplomacy_action_state_from_player_state",
    "_sync_diplomacy_action_mirror_state_from_relations",
    "_get_selected_diplomacy_target",
    "_get_diplomacy_action_definition",
    "_get_diplomacy_action_cooldown",
    "_build_diplomacy_action_validation_context",
    "_validate_diplomacy_action",
    "_calculate_alliance_acceptance_chance",
    "_get_trade_agreement_bonus_multiplier",
    "_get_active_trade_agreement_turns",
    "_get_active_alliance_turns",
    "_advance_diplomacy_cooldowns_for_world_turn",
    "_get_known_faction_ids_for_diplomacy",
    "_normalize_faction_relations_for_world_state",
    "_get_enemy_diplomacy_baseline_mvp",
    "_get_empty_domestic_diplomacy_modifier_mvp",
    "_get_player_diplomacy_tech_modifier_mvp",
    "_has_domestic_diplomacy_modifier_data_mvp",
    "_get_modified_diplomacy_relation_delta_mvp",
    "_get_modified_diplomacy_success_chance_mvp",
}


PRESENTER = "scripts/worldmap/actions/diplomacy_presentation_helper.gd"
PRESENTER_FUNCTIONS = {
    "_format_diplomacy_owner_display",
    "_format_diplomacy_relation_summary_for_ui",
    "_format_diplomacy_relation_status_for_ui",
    "_format_diplomacy_trade_status_for_ui",
    "_format_diplomacy_action_candidates_for_ui",
    "_format_diplomacy_policy_display_for_ui",
    "_format_diplomacy_action_hint",
    "_format_last_diplomacy_action_result_for_ui",
    "_format_player_diplomacy_tech_modifier_summary_mvp",
    "_format_diplomacy_normalize_summary",
    "_format_diplomacy_cooldown_summary",
    "_format_last_tribute_summary",
}
KEPT_BRIDGES = {
    "_make_faction_relation_key",
    "_normalize_faction_relation_status",
    "_get_faction_relation_band",
    "_ensure_faction_relation_entry",
    "_get_faction_relation_score",
    "_get_faction_relation_status",
    "_sync_diplomacy_action_mirror_state_from_relations",
    "_validate_diplomacy_action",
    "_get_trade_agreement_bonus_multiplier",
    "_get_known_faction_ids_for_diplomacy",
    "_get_modified_diplomacy_success_chance_mvp",
}
MAIN_REMOVED = (CONTROLLER_FUNCTIONS - KEPT_BRIDGES) | PRESENTER_FUNCTIONS | {
    "_get_selected_city_relation_label", "_get_selected_city_relation_description",
}
MAIN_REWIRED = {
    "_show_unified_diplomacy_spy_content", "_format_domestic_apply_summary",
    "_ensure_worldmap_runtime_state_defaults", "_apply_domestic_turn_mvp",
    "_on_diplomacy_action_pressed", "_refresh_diplomacy_action_card",
    "_refresh_diplomacy_action_button", "_ensure_diplomacy_action_coordinator",
}


def functions(source):
    result = {}
    for match in re.finditer(r"(?ms)^func (\w+)(\(.*?)(?=^func |\Z)", source):
        result[match[1]] = "\n".join(line for line in match[2].splitlines() if line.strip() and not line.lstrip().startswith("#"))
    return result


def check_controller_moves():
    old = functions(baseline("scripts/worldmap/worldmap_main.gd"))
    host = functions(current("scripts/worldmap/worldmap_main.gd"))
    controller = functions(current(CONTROLLER))
    for name in CONTROLLER_FUNCTIONS:
        expected = old[name].replace("DiplomacyActionServiceScript.new()", "_service").replace("var payment_check := _can_pay_generic_resource_cost(cost)", "var payment_check := _service.can_pay_diplomacy_resource_cost(self, cost)")
        assert controller[name] == expected, f"Moved controller implementation changed: {name}"
        if name in MAIN_REMOVED:
            assert name not in host, f"Unnecessary main wrapper retained: {name}"
            continue
        signature = old[name].splitlines()[0]
        args = re.findall(r"(?:\(|, )(\w+):", signature)
        statement = "" if signature.endswith("-> void:") else "return "
        expected_wrapper = signature + "\n\t" + statement + f"_ensure_diplomacy_controller().{name}({', '.join(args)})"
        assert host[name] == expected_wrapper, f"Main diplomacy adapter is not a thin bridge: {name}"



def check_presentation_moves():
    old = functions(baseline("scripts/worldmap/worldmap_main.gd"))
    presenter = functions(current(PRESENTER))
    for name in PRESENTER_FUNCTIONS:
        expected = old[name]
        for dependency in CONTROLLER_FUNCTIONS | {"_get_city_owner_faction_id_for_trade_display", "_get_current_player_faction_id"}:
            expected = expected.replace(dependency + "(", "_controller." + dependency + "(")
        assert presenter[name] == expected, f"Presentation behavior changed: {name}"
    assert "Button.new" not in current(PRESENTER)
    assert "Label.new" not in current(PRESENTER)


def check_main_boundaries():
    old = functions(baseline("scripts/worldmap/worldmap_main.gd"))
    host = functions(current("scripts/worldmap/worldmap_main.gd"))
    source = current("scripts/worldmap/worldmap_main.gd")
    assert "DiplomacyActionServiceScript" not in source
    assert "configure_diplomacy(_ensure_diplomacy_controller())" in source
    frozen_controller = functions(subprocess.check_output(
        ["git", "show", f"b51f95f868aa7bda891895ac29eb0730d0b15428:{CONTROLLER}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n"))
    current_controller = functions(current(CONTROLLER))
    for name, body in frozen_controller.items():
        assert current_controller.get(name) == body, f"Diplomacy Controller baseline function changed: {name}"
    assert set(current_controller) - set(frozen_controller) == {"apply_spy_relation_delta", "break_alliance_for_spy_wedge"}, "Unexpected Diplomacy Controller expansion"
    assert current(PRESENTER) == subprocess.check_output(
        ["git", "show", f"b51f95f868aa7bda891895ac29eb0730d0b15428:{PRESENTER}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n"), "Diplomacy Presenter changed during Trade extraction"
    controller = current(CONTROLLER)
    calls = set(re.findall(r'_host.call\("([^"]+)"', controller))
    allowed = {
        "_get_city_owner_faction_id_for_trade_display", "_get_current_player_faction_id",
        "_get_city_owner_faction_id", "_get_enemy_owned_city_count_mvp",
        "_format_enemy_city_baseline_grade_label_mvp",
        "_get_domestic_tech_diplomacy_spy_bonus_mvp",
        "_get_unique_domestic_tech_source_ids_mvp",
        "_has_completed_national_domestic_tech_mvp",
        "_append_domestic_modifier_source_if_completed_mvp",
        "_get_total_recruitment_food_stock",
    }
    assert calls == allowed, f"Unexpected main dependencies: {calls ^ allowed}"
    assert not (calls & CONTROLLER_FUNCTIONS), "Controller calls diplomacy-specific main implementation"
    for name in ["_calculate_military_support_acceptance_chance", "_request_military_support"]:
        assert host[name] == old[name], f"Cross-domain boundary changed: {name}"
    assert "func apply_spy_relation_delta(" in controller
    assert "func break_alliance_for_spy_wedge(" in controller


def check_regression_migration():
    # Only the host/owner access changes; every prior check and scenario survives.
    for suffix in ["routing", "validation_extraction", "mutation_extraction", "state_extraction", "alliance_extraction"]:
        path = f"tests/scripts/test_worldmap_diplomacy_{suffix}.gd"
        expected = baseline(path)
        for name in CONTROLLER_FUNCTIONS - KEPT_BRIDGES:
            expected = expected.replace(
                f'_worldmap.call("{name}"',
                f'_worldmap.call("_ensure_diplomacy_controller").call("{name}"'
            )
        expected = re.sub(
            r'(_service\.call\("[^"]+", )_worldmap(?=[,)])',
            r'\1_worldmap.call("_ensure_diplomacy_controller")',
            expected,
        )
        assert current(path) == expected, f"Legacy regression changed beyond owner migration: {suffix}"


def main():
    check_regression_migration()
    check_controller_moves()
    check_presentation_moves()
    check_main_boundaries()
    check_coordinator()
    controller = current(CONTROLLER)
    main_source = current("scripts/worldmap/worldmap_main.gd")
    assert controller.count("DiplomacyActionServiceScript.new()") == 1
    assert "DiplomacyActionServiceScript.new()" not in main_source
    assert "_service.execute(self, action_id, target_city_id, source_city_id)" in controller
    assert "configure_diplomacy(_ensure_diplomacy_controller())" in main_source
    for name in ["diplomacy_action_service.gd"]:
        path = "scripts/worldmap/actions/" + name
        assert current(path) == baseline(path), f"Service changed: {name}"
    print("PASS: diplomacy 2F Controller/Presenter ownership, exact moved bodies, thin main, explicit Spy boundary, unchanged Trade/Military")


if __name__ == "__main__":
    main()
