"""Diplomacy 2D guard: preserve recovery boundaries and enforce service ownership.

Compare with the verified recovery HEAD, not a moving branch name. Runtime
behavior is covered separately by test_worldmap_diplomacy_routing.gd.
"""

import re
import subprocess
from pathlib import Path
from validate_worldmap_diplomacy_controller_extraction import check_coordinator, check_controller_moves, check_main_boundaries, check_presentation_moves, CONTROLLER_FUNCTIONS, CONTROLLER, MAIN_REMOVED, MAIN_REWIRED
from validate_worldmap_spy_controller_extraction import SPY_MAIN_REMOVED

ROOT = Path(__file__).resolve().parents[1]
BASE = "e066b59a28226de1e5f4680ae11b651926903361"
PHASE_2B_BASE = "6b3bf867544cf6cbdd48ba7eed8be7f3e3ef3ded"
PHASE_2C1_BASE = "b54dadcf7a586968c84ef185f9527231ef4646a4"
PHASE_2C2_BASE = "9bd3a356d94d04a57b4d20533ca0603f017fc6ac"
SERVICE_EXTRACTION_CHECKPOINT = "2ee28db607cc5b6f2060a3a3c2087b53b89188be"
MAIN = "scripts/worldmap/worldmap_main.gd"
SFX_REWIRED = {
    "_on_city_marker_selected": (
        'GameAudio.play_sfx("city_select")',
        '_play_worldmap_sfx("city_select")',
    ),
    "_on_ally_turn_end_pressed": (
        'GameAudio.play_sfx("turn_end")',
        '_play_worldmap_sfx("turn_end")',
    ),
    "_show_domestic_tech_completion_card_mvp": (
        'GameAudio.play_sfx("research")',
        '_play_worldmap_sfx("research")',
    ),
}
SERVICE_REWIRED = set("""
_get_enemy_faction_personality_seed
_get_enemy_faction_personality_profile_id
_get_enemy_faction_personality_label
_get_enemy_faction_behavior_weight
_get_enemy_faction_personality_metadata
_get_enemy_faction_strategic_goal_seed
_get_enemy_faction_goal_id
_get_enemy_faction_goal_label
_get_enemy_faction_goal_pressure
_get_enemy_faction_goal_weight
_get_enemy_goal_target_city_ids
_is_city_preferred_by_enemy_goal
_is_city_adjacent_to_enemy_goal_target
_get_enemy_faction_goal_metadata
_normalize_enemy_pressure_type_mvp
_should_skip_enemy_pressure_plan_mvp
_build_enemy_pressure_plan_candidates_mvp
_build_enemy_pressure_plan_candidate_for_faction_mvp
_get_enemy_pressure_plan_target_city_ids_for_source_mvp
_score_enemy_pressure_plan_candidate_mvp
_sort_enemy_pressure_plan_candidates_mvp
_pick_enemy_pressure_plan_mvp
_normalize_enemy_pressure_plan_result_mvp
_get_enemy_pressure_plan_for_scoring_mvp
_is_enemy_pressure_plan_target_city_mvp
_get_enemy_pressure_plan_score_bonus_mvp
_is_enemy_frontline_city_for_faction
_find_enemy_frontline_city_for_faction
_pick_enemy_city_for_turn_action
_score_enemy_reinforcement_city_for_personality
_get_enemy_invasion_pairs_mvp
_is_city_owner_consistent_for_enemy_invasion_mvp
_is_enemy_invasion_pair_eligible_mvp
_score_enemy_invasion_pair_mvp
_sort_enemy_invasion_pairs_mvp
_get_city_troops_for_enemy_invasion_mvp
_is_player_frontline_city_for_enemy_invasion_mvp
_apply_returned_battle_result_mvp
_is_player_attack_battle_result
_normalize_battle_result_hero_ids
_is_enemy_invasion_battle_result
_normalize_invasion_battle_result_kind
_normalize_player_attack_battle_result_kind
_get_invasion_result_city_id
_build_invasion_result_summary
_normalize_battle_hero_outcomes
_get_player_troop_outcome_from_result
_get_enemy_troop_outcome_from_result
_calculate_player_attack_troop_outcome_fallback
_calculate_invasion_casualty_result
_resolve_invasion_remaining_troops
_resolve_occupation_troops
_clamp_invasion_troops
_get_result_troop_value
_is_supply_path_between
_get_city_min_garrison
_is_peacetime_for_troop_move
_can_move_troops
_move_troops
_calculate_troop_move_arrived_amount
_get_conscription_capacity_by_loyalty
_get_city_conscription_available
_get_conscription_turn_add_multiplier
_apply_city_conscription_for_world_turn
_get_recruitment_limit_by_loyalty
_calculate_recruitment_cost
_can_recruit_troops
_recruit_troops
_validate_pending_invasion_event_for_battle_context
_build_battle_context_from_pending_invasion
_build_player_attack_battle_context
_build_player_attack_selected_roster_for_battle_context
_build_selected_side_roster_for_battle_context
_build_even_troop_allocation_for_heroes
_build_command_limit_troop_allocation_for_heroes
_apply_troop_allocation_to_roster
_sum_troop_allocation
_build_invasion_side_roster_for_battle_context
_append_invasion_roster_hero_id
_build_invasion_roster_result
_get_reinforcement_candidate_city_ids_for_battle_context
_are_factions_reinforcement_compatible
_get_hero_city_id_for_battle_context
_get_city_troops_for_battle_context
_get_city_stationed_hero_ids_for_battle_context
_get_city_battle_heroes_for_battle_context
_apply_domestic_battle_tech_modifier_to_hero_data_mvp
_get_hero_battle_data_for_battle_context
_get_city_governor_id_for_battle_context
_normalize_command_rank_mvp
_get_hero_command_rank_for_city_mvp
_get_hero_command_limit_for_city_mvp
_get_hero_command_summary_for_city_mvp
""".split())
M5_SETTLEMENT_REWIRED = {
    "_apply_returned_battle_result_mvp",
    "_apply_t02_player_attack_result",
    "_apply_defender_win_invasion_result",
    "_apply_attacker_win_invasion_result",
    "_apply_player_attack_win_result",
    "_apply_player_attack_loss_result",
    "_settle_defender_generals_after_occupation",
    "_set_hero_faction_after_conquest_mvp",
    "_move_hero_to_city_t02",
    "_apply_explicit_battle_hero_outcomes",
    "_apply_invasion_hero_state_placeholder",
    "_set_hero_runtime_status_placeholder",
    "_apply_t02_defender_supply_result",
    "_add_t02_attacker_cargo_to_city",
    "_rebuild_occupation_runtime_indexes_mvp",
}
M6_T03_TRANSACTION_REWIRED = set("""
_get_t03_city_food_stock
_get_t03_city_food_total
_make_t03_transaction_id
_build_t03_expedition_cargo_plan
_filter_t03_context_heroes
_prepare_t03_battle_transaction
_select_t03_food_type
_sum_t03_food_stock
_pay_t03_expedition_cargo
_rollback_t03_battle_transaction
_resolve_t03_automatic_invasion
_apply_t03_strategic_battle_result
_apply_t03_defender_supply_result
_add_t03_attacker_cargo_to_city
""".split())
SERVICE_REMOVED = {
    "_log_invasion_reinforcement_rule_summary",
    "_get_hero_contract_nation_key",
    "_get_hero_contract_portrait_path",
    "_get_hero_contract_cutin_path",
    "_format_hero_contract_skill_name",
    "_format_hero_contract_skill_desc",
}


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
    check_coordinator()
    check_controller_moves()
    check_main_boundaries()
    check_presentation_moves()
    before, after = functions(original(MAIN)), functions(current(MAIN))
    service_checkpoint = functions(at_commit(SERVICE_EXTRACTION_CHECKPOINT, MAIN))
    trade_removed = {
        "_get_trade_control_mode_label", "_get_trade_control_hint",
        "_format_manual_trade_preview_summary", "_execute_external_manual_trade_order_legacy",
        "_validate_external_manual_trade_execution", "_build_external_manual_trade_execution_preview",
        "_build_empty_external_trade_delta", "_calculate_external_trade_delta",
        "_get_default_trade_control_modes", "_normalize_manual_trade_order_payload",
        "_normalize_manual_trade_order_items", "_normalize_trade_delta_payload",
        "_normalize_chancellor_auto_trade_section_payload", "_format_external_trade_manual_order_summary",
        "_format_external_manual_trade_execution_result_summary",
        "_format_manual_trade_nonzero_preview_summary", "_format_trade_market_prices_for_external_trade_ui",
        # Trade Phase 2 implementation moved from main to Trade-owned services.
        "_record_chancellor_auto_trade_result", "_get_player_owned_city_ids_for_chancellor_auto_trade",
        "_get_chancellor_auto_trade_resource_priority", "_get_chancellor_auto_trade_resource_cap",
        "_has_chancellor_auto_trade_cap_aptitude", "_get_chancellor_auto_trade_target_min",
        "_get_chancellor_auto_trade_surplus_buffer", "_apply_chancellor_internal_auto_trade",
        "_get_chancellor_internal_auto_trade_target_demands", "_select_chancellor_internal_auto_trade_source",
        "_apply_chancellor_external_auto_trade", "_get_chancellor_external_tradeable_candidate_city_ids",
        "_build_empty_chancellor_external_delta", "_is_chancellor_external_delta_empty",
        "_apply_chancellor_external_export", "_apply_chancellor_external_import",
    }
    trade_rewired = {
        "_ensure_diplomacy_action_coordinator", "_apply_city_detail_tab_content",
        "_refresh_trade_control_ui", "_refresh_manual_trade_order_relation",
        "_refresh_manual_trade_order_preview", "_build_manual_trade_order_preview",
        "_on_manual_trade_order_confirm_pressed", "_on_manual_trade_execution_button_pressed",
        "_get_trade_efficiency_for_cities", "_calculate_trade_import_cost",
        "_calculate_trade_export_gain", "_normalize_trade_control_modes",
        "_normalize_manual_trade_orders", "_normalize_trade_result_payload",
        "_normalize_chancellor_auto_trade_result_payload", "_sync_trade_persistence_to_player_state",
        "_restore_trade_persistence_from_player_state", "_format_chancellor_external_auto_trade_result_summary",
        # Trade Phase 2 extracts automatic/internal rules behind thin main bridges.
        "_apply_chancellor_auto_trade_for_world_turn",
        "_validate_internal_trade_transfer", "_apply_internal_trade_transfer",
    }
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
    bridges = {
        "_ensure_diplomacy_action_coordinator",
        "open_contextual_worldmap_action", "cancel_contextual_worldmap_action",
        "complete_contextual_worldmap_action",
        "_request_contextual_worldmap_action_presentation",
        "_apply_diplomacy_action", "_on_diplomacy_action_pressed",
        # Later domain phases may extend the shared bridge without changing
        # the phase-one diplomacy implementation checked below.
        "_apply_spy_action", "_on_spy_action_pressed",
        "_execute_external_manual_trade_order",
        "_on_manual_trade_execution_button_pressed",
        "_apply_chancellor_auto_trade_for_world_turn",
        "_validate_internal_trade_transfer", "_apply_internal_trade_transfer",
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
        # Phase 2D delegates remaining relation normalization and removes
        # duplicated UI fallback rule constants from main.
        "_ensure_faction_relation_entry",
        "_build_diplomacy_action_validation_context",
        "_refresh_diplomacy_action_button",
        "_format_diplomacy_action_hint",
        "_format_last_diplomacy_action_result_for_ui",
    }
    for name, body in before.items():
        # Spy Controller extraction has its own strict ownership validator.
        spy_owned = name in SPY_MAIN_REMOVED or "spy" in name or "intel" in name or "revolt_instigation" in name or name in {"_normalize_city_intel_registry"}
        if spy_owned and name not in after:
            continue
        if name in deleted | MAIN_REMOVED | trade_removed | SERVICE_REMOVED:
            assert name not in after, f"dead diplomacy function retained: {name}"
            continue
        assert name in after, f"removed function: {name}"
        if not spy_owned and name not in bridges | CONTROLLER_FUNCTIONS | MAIN_REWIRED | trade_rewired:
            if name in SFX_REWIRED:
                old_call, new_call = SFX_REWIRED[name]
                assert body.count(old_call) == 1, f"baseline SFX call contract changed: {name}"
                expected_body = body.replace(old_call, new_call)
                assert after[name] == expected_body, f"out-of-scope function changed beyond SFX routing: {name}"
            elif name in M5_SETTLEMENT_REWIRED:
                continue
            elif name in M6_T03_TRANSACTION_REWIRED:
                continue
            elif name in SERVICE_REWIRED:
                assert name in service_checkpoint, f"service checkpoint function missing: {name}"
                assert after[name] == service_checkpoint[name], f"service extraction wrapper changed: {name}"
            else:
                assert after[name] == body, f"out-of-scope function changed: {name}"

    worldmap_source = current(MAIN)
    assert 'BattleResultService.build_settlement_plan' not in worldmap_source
    returned_result = after["_apply_returned_battle_result_mvp"]
    assert "build_settlement_plan(result)" in returned_result, "M-5 coordinator lost settlement planning"
    assert "_ensure_battle_settlement_applier().apply(settlement_plan)" in returned_result, "M-5 coordinator lost settlement application"
    for name in [
        "_set_hero_faction_after_conquest_mvp", "_move_hero_to_city_t02",
        "_set_hero_runtime_status_placeholder", "_apply_t02_defender_supply_result",
        "_add_t02_attacker_cargo_to_city",
    ]:
        assert "_ensure_battle_settlement_applier()" in after[name], f"M-5 compatibility wrapper does not delegate: {name}"
    sfx_helper = after.get("_play_worldmap_sfx", "")
    assert 'get_node_or_null("/root/GameAudio")' in sfx_helper, "worldmap SFX helper lost runtime autoload lookup"
    assert "if game_audio != null:" in sfx_helper, "worldmap SFX helper lost null guard"
    assert 'game_audio.call("play_sfx", sfx_id)' in sfx_helper, "worldmap SFX helper lost guarded play_sfx dispatch"
    assert not re.search(r"\bGameAudio\s*\.", worldmap_source), "compile-time GameAudio reference added to worldmap main"
    phase_2c1 = functions(at_commit(PHASE_2C1_BASE, MAIN))
    for name in ["_calculate_military_support_acceptance_chance", "_request_military_support"]:
        assert after[name] == phase_2c1[name], f"2C-2 changed protected military function: {name}"
    for name in [
        "_adjust_faction_relation_score", "_request_military_support",
        "_apply_generic_resource_cost",
    ]:
        assert after[name] == before[name], f"diplomacy mutation function changed: {name}"
    # Exact moved-body checks replace the old 2D line-deletion budget.
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
    # Domain ownership follows Controller; untouched-main comparisons above remain strict.
    after.update(functions(current(CONTROLLER)))
    assert "DiplomacyActionServiceScript.get_action_definition(action_id)" in after["_get_diplomacy_action_definition"]
    assert "DiplomacyActionServiceScript.validate_action" in after["_validate_diplomacy_action"]
    for name in ["_get_diplomacy_action_definition", "_validate_diplomacy_action"]:
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
    assert "_service.get_diplomacy_action_cooldown" in after["_get_diplomacy_action_cooldown"]
    assert "_service.sync_diplomacy_mirror_state" in after["_sync_diplomacy_action_mirror_state_from_relations"]
    assert "_service.sync_alliance_mirror_state" in after["_sync_diplomacy_action_mirror_state_from_relations"]
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
        "_calculate_alliance_acceptance_chance": "calculate_alliance_acceptance_chance",
        "_get_active_alliance_turns": "get_active_alliance_turns",
    }
    for name, target in wrapper_targets.items():
        assert f"_service.{target}" in after[name], f"alliance wrapper does not delegate: {name}"
        assert len(after[name].splitlines()) <= 2, f"alliance compatibility API is not thin: {name}"
    assert "restore_alliance_state_from_mirror" in after["_normalize_diplomacy_action_state_from_player_state"]
    assert "advance_alliance_state_entry" in after["_advance_diplomacy_cooldowns_for_world_turn"]
    assert "normalize_diplomacy_relation_entry" in after["_ensure_faction_relation_entry"]
    assert "before_tribute_cooldown" in service_functions["advance_diplomacy_state_entry"]
    for forbidden in ["before_alliance_turns", "before_tribute_cooldown", 'entry["alliance_turns_remaining"] =', 'entry.erase("alliance_created_turn")']:
        assert forbidden not in after["_advance_diplomacy_cooldowns_for_world_turn"], f"main still owns alliance expiry mutation: {forbidden}"
    assert "_apply_diplomacy_action_legacy" not in current(MAIN)
    print(f"PASS: diplomacy routing/static 2D guard; service owns rules/state, dead legacy removed, production coordinator route retained, military/spy boundaries protected")


if __name__ == "__main__":
    main()
