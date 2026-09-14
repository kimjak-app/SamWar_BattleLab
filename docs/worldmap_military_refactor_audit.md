# WorldMap M-0 audit and M-1 military move specification

Date: 2026-09-14
Repository: `C:/dev/SamWar_BattleLab`
Branch: `recovery/worldmap-iso-sfx-services-20260912`
Baseline HEAD: `277bb846decb47f9977e72b58e36c0e1ff3ff765`
Origin: `origin/recovery/worldmap-iso-sfx-services-20260912`, fetched and `0 ahead / 0 behind`
Initial working tree: clean

## M-0 declaration inventory

`scripts/worldmap/worldmap_main.gd` was audited in full. At the M-1 verification point it contains 1,070 functions, 266 top-level constants, 148 top-level state variables, 81 `@onready` node references, and two signals. The signals are the generic action-hub signals `contextual_worldmap_action_presentation_requested` and `contextual_worldmap_action_resolved`; neither is owned by military rules. The added `_play_worldmap_sfx` coordinator removes compile-time autoload ordering from the WorldMap preload path while preserving the three existing SFX routes.

Major state groups are world camera/layout, city/hero runtime registries, player/turn/save state, contextual action routing, diplomacy/trade/spy controller and presenter references, domestic-tech UI state, invasion/battle handoff state, and battle/outcome presentation state. The node references are presentation nodes. The M-1 controller therefore receives the host and uses explicit method/state bridges; it does not cache scene nodes.

## Existing extraction regression audit

Diplomacy, trade, and spy are already constructed by `_ensure_diplomacy_controller`, `_ensure_trade_controller`, and `_ensure_spy_controller`, then routed through `WorldMapActionCoordinator`. Their main-file APIs are compatibility wrappers (for example `_validate_diplomacy_action`, `_apply_diplomacy_action`, `_get_spy_action_definition`, `_validate_spy_action`, `_apply_spy_action`, `_get_trade_efficiency_for_cities`, `_calculate_trade_import_cost`, `_calculate_trade_export_gain`, `_validate_internal_trade_transfer`). UI event handlers remain in the hub. No extracted implementation was moved back or rewritten in M-1.

The remaining `_request_military_support` flow is a diplomacy action that mutates relations and support counters. It remains with the existing diplomacy boundary in this change; moving it as warfare would split a single diplomacy transaction across owners.

## Military dependency profiles

The profiles below make the function inventory compact without omitting dependency fields.

| Profile | Variables/constants | Node references | Signals/UI | Other systems |
|---|---|---|---|---|
| MA — military administration | `_player_state`, `_city_markers_by_id`, `_enemy_turn_mvp_pending`; troop/garrison, battle-meta and turn-phase constants | no cached node; reads marker `neighbors` through host | no signals; no direct UI | city runtime, loyalty/security, domestic tech, resource payment, pending battle state |
| MU — military UI/coordinator | selected city/action state and presentation state | `city_info_panel`, deployment panel, invasion/result controls | connects city-info attack/recruit signals and button callbacks | calls MA and battle routing |
| AI — enemy warfare | player/city state, personality/goal seeds, invasion thresholds/cooldowns | city markers for ownership/adjacency | result/hint formatting only | turn engine, diplomacy/spy follow-up, auto battle |
| BC — battle context/handoff | pending invasion/context, city/hero runtime, supply/cargo, command-rank and battle constants | deployment panel, camera, viewport | deployment callbacks and input skip; scene transition | GameSession, Engine metadata, Battle scene |
| BR — battle result | city/hero runtime, wounded queues, casualty/occupation constants | post-battle and wounded controls | result UI callbacks | persistence, economy supply, ownership indexes |
| MT — military technology | domestic-tech completion/unlock state and military/naval/siege constants | tech-tree UI only in formatter functions | no domain signals | domestic-tech system and battle-context modifiers |
| TP — T03 presentation/turn routing | queued reports, turn state, pending invasion | T03 video/result nodes, T05 outcome nodes | video/confirm callbacks | auto-battle resolver, save/outcome, world turn |

## Function-level military inventory

Each function below is individually identified. “Calls / called from” records the stable boundary rather than every incidental formatting helper.

### MA — moved in M-1

| Current function | Role | Calls | Called from | State/node/signal/UI/system dependency |
|---|---|---|---|---|
| `_is_supply_path_between` | owned-city supply-path BFS | ownership query, marker neighbors | troop validation/default target, supply state | MA; no node/signal/UI |
| `_get_city_min_garrison` | minimum retained garrison | city security requirement | move preview/validation/rebalance | MA; security/city runtime |
| `_is_peacetime_for_troop_move` | military mutation gate | pending invasion/context, Engine meta, turn phase | move/recruit/conscription validation | MA; battle and turn state |
| `_can_move_troops` | troop move validation | supply path, garrison, troop count | UI preview, rebalance, move command | MA; no direct UI |
| `_move_troops` | apply movement and loyalty attrition | validation, troop state setters, total count | rebalance and city-detail action | MA; city runtime mutation |
| `_calculate_troop_move_arrived_amount` | loyalty attrition arithmetic | none | movement and preview | MA; pure rule |
| `_get_conscription_capacity_by_loyalty` | population/loyalty cap | city and loyalty query | availability and turn application | MA |
| `_get_city_conscription_available` | remaining conscription capacity | cap and troop count | summary and turn application | MA |
| `_get_conscription_turn_add_multiplier` | national-tech multiplier | national tech completion | summary and turn application | MA; domestic tech |
| `_apply_city_conscription_for_world_turn` | per-turn conscription mutation | peace gate, cap, barracks, troop setter | `_apply_domestic_turn_mvp` | MA; turn/domestic tech |
| `_get_recruitment_limit_by_loyalty` | manual recruitment cap | loyalty query | summary/validation/result | MA |
| `_calculate_recruitment_cost` | recruitment cost rule | none | summary/validation/result | MA; pure rule |
| `_can_recruit_troops` | manual recruitment validation | ownership, peace gate, limits, payment check | city-info event and recruit command | MA; economy payment boundary |
| `_recruit_troops` | charge resources and add troops | validation, payment commit, troop setter | city-info event | MA; economy/city runtime |

### MU — retained coordinator/presentation functions

| Function | Role | Calls / called from | Why it remains |
|---|---|---|---|
| `_connect_city_info_panel_actions` | connect attack/recruit UI signals once | `_ready`; panel signals | hub owns scene nodes and signal lifecycle |
| `_on_city_info_attack_requested` | route button to attack start | city panel signal → `_start_player_attack_battle` | thin UI route |
| `_on_city_info_recruitment_requested` | coordinate validation/result refresh | city panel signal → MA wrappers and refresh methods | scene UI coordination |
| `_show_city_info_recruitment_result` | display message | recruitment handler | direct panel access |
| `_format_recruitment_failure_hint` | UI reason text | recruitment handler/summary | presentation helper candidate |
| `_format_city_recruitment_conscription_display` | compose city card text | city-detail refresh → recruitment summary | presentation only |
| `_get_troop_move_preview_for_city` | compose current UI command | unified panel → MA wrappers | selected-city presentation query |
| `_get_troop_move_default_amount` | UI default amount | preview | presentation policy candidate |
| `_get_default_troop_move_target_city` | choose UI default target | preview → MA wrappers | presentation selection candidate |
| `_format_troop_move_preview_display` | compose preview text | unified panel | presentation only |
| `_format_troop_move_button_text` | compatibility formatter | unified panel → `DefenseBattleHelpers` | thin wrapper |
| `_format_troop_move_reason` | compatibility formatter | preview → `DefenseBattleHelpers` | thin wrapper |
| `_setup_pending_invasion_choice_ui` | connect defense buttons | `_ready` | node/signal owner |
| `_setup_post_battle_result_ui` | connect result controls | `_ready` | node/signal owner |
| `_ensure_player_attack_deployment_panel` | instantiate/connect panel | `_ready`, attack/defense flows | node/signal owner |
| `_refresh_city_info_attack_action_state` | update attack button | city selection/state refresh | direct UI access |
| `_refresh_pending_invasion_choice_ui` | update defense choice | turn/result flows | direct UI access |
| `_show_post_battle_result_summary`, `_clear_post_battle_result_summary`, `_refresh_post_battle_result_panel`, `_refresh_wounded_treatment_controls` | result presentation | battle result/wounded callbacks | direct UI access |

### AI — enemy warfare functions retained for the next extraction

The following are domain implementation, not coordinator code: `_roll_enemy_invasion_event_mvp`, `_process_enemy_faction_turn_mvp`, `_get_enemy_owned_city_ids_for_faction`, `_get_enemy_faction_personality_seed`, `_get_enemy_faction_personality_profile_id`, `_get_enemy_faction_personality_label`, `_get_enemy_faction_behavior_weight`, `_get_enemy_faction_personality_metadata`, `_get_enemy_faction_strategic_goal_seed`, `_get_enemy_faction_goal_id`, `_get_enemy_faction_goal_label`, `_get_enemy_faction_goal_pressure`, `_get_enemy_faction_goal_weight`, `_get_enemy_goal_target_city_ids`, `_is_city_preferred_by_enemy_goal`, `_is_city_adjacent_to_enemy_goal_target`, `_get_enemy_faction_goal_metadata`, `_normalize_enemy_pressure_type_mvp`, `_should_skip_enemy_pressure_plan_mvp`, `_build_enemy_pressure_plan_candidates_mvp`, `_build_enemy_pressure_plan_candidate_for_faction_mvp`, `_get_enemy_pressure_plan_target_city_ids_for_source_mvp`, `_score_enemy_pressure_plan_candidate_mvp`, `_sort_enemy_pressure_plan_candidates_mvp`, `_pick_enemy_pressure_plan_mvp`, `_normalize_enemy_pressure_plan_result_mvp`, `_get_enemy_pressure_plan_for_scoring_mvp`, `_is_enemy_pressure_plan_target_city_mvp`, `_get_enemy_pressure_plan_score_bonus_mvp`, `_get_safe_enemy_owner_faction_id_for_turn_mvp`, `_is_enemy_frontline_city_for_faction`, `_find_enemy_frontline_city_for_faction`, `_pick_enemy_city_for_turn_action`, `_score_enemy_reinforcement_city_for_personality`, `_apply_enemy_city_reinforcement_mvp`, `_get_enemy_invasion_pairs_mvp`, `_is_city_owner_consistent_for_enemy_invasion_mvp`, `_is_enemy_invasion_pair_eligible_mvp`, `_score_enemy_invasion_pair_mvp`, `_sort_enemy_invasion_pairs_mvp`, `_get_city_troops_for_enemy_invasion_mvp`, and `_is_player_frontline_city_for_enemy_invasion_mvp`.

All use profile AI. Their internal call chain is candidate construction → scoring/sorting → selection → reinforcement/invasion mutation; callers are `_run_enemy_turn_mvp`, `_process_enemy_faction_turn_mvp`, and turn-summary routing. They use no signals directly; adjacency functions read city markers, while display-only `_format_enemy_*` functions are presentation candidates. The diplomacy/spy follow-up functions in the same source region are explicitly excluded from military movement because those systems are already separated.

### BC — attack, deployment, context, and handoff functions retained for the next extraction

Domain/rule functions: `_get_city_neighbors_mvp`, `_get_city_route_type_between_mvp`, `_is_naval_attack_route_mvp`, `_is_siege_attack_target_mvp`, `_get_player_naval_siege_attack_unlock_block_reason_mvp`, `_get_player_attack_block_reason`, `_can_player_attack_city`, `_find_player_attack_source_city`, `_find_nearest_player_owned_neighbor_city_mvp`, `_get_available_player_attack_main_hero_ids`, `_build_player_attack_deployment_payload`, `_get_deployable_player_heroes_for_city`, `_validate_player_attack_deployment`, `_calculate_player_attack_supply_cost`, `_can_pay_player_attack_supply_cost`, `_pay_player_attack_supply_cost`, `_move_generals_for_pending_expedition`, `_select_city_battle_supply`, `_ensure_city_supply_resource_defaults`, `_get_city_supply_resource_amount`, `_create_pending_invasion_event_mvp`, `_get_pending_invasion_event_mvp`, `_has_pending_invasion_event_mvp`, `_build_defense_deployment_payload`, `_validate_defense_deployment`, `_validate_pending_invasion_event_for_battle_context`, `_build_battle_context_from_pending_invasion`, `_build_player_attack_battle_context`, `_build_player_attack_selected_roster_for_battle_context`, `_build_selected_side_roster_for_battle_context`, `_build_even_troop_allocation_for_heroes`, `_build_command_limit_troop_allocation_for_heroes`, `_apply_troop_allocation_to_roster`, `_sum_troop_allocation`, `_build_invasion_side_roster_for_battle_context`, `_append_invasion_roster_hero_id`, `_build_invasion_roster_result`, `_get_reinforcement_candidate_city_ids_for_battle_context`, `_are_factions_reinforcement_compatible`, `_get_hero_city_id_for_battle_context`, `_has_city_for_battle_context`, `_get_city_owner_id_for_battle_context`, `_get_city_troops_for_battle_context`, `_get_city_stationed_hero_ids_for_battle_context`, `_get_city_battle_heroes_for_battle_context`, `_get_hero_battle_data_for_battle_context`, `_get_city_governor_id_for_battle_context`, `_normalize_command_rank_mvp`, `_get_hero_command_rank_for_city_mvp`, `_get_hero_command_limit_for_city_mvp`, `_get_hero_command_summary_for_city_mvp`, `_set_pending_battle_context_mvp`, `_get_pending_battle_context_mvp`, `_clear_pending_battle_context_mvp`, and `_clear_pending_invasion_event_mvp`.

Coordinator/UI functions: `_start_player_attack_battle`, `_open_player_attack_deployment`, `_confirm_player_attack_deployment`, `_on_player_attack_deployment_confirmed`, `_on_player_attack_deployment_cancelled`, `_on_manual_defense_pressed`, `_on_auto_defense_pressed`, `_open_defense_deployment_panel_from_pending_invasion`, `_confirm_defense_deployment`, `_handoff_battle_context_to_battle_scene`, `_change_scene_to_battle_with_context`, `_rollback_player_attack_handoff`, `_get_worldmap_city_visual_position`, `_build_worldmap_battle_entry_focus`, `_start_worldmap_battle_entry_camera_handoff`, `_complete_worldmap_battle_entry_camera_handoff`, `_skip_worldmap_battle_entry_camera_handoff`, `_is_worldmap_battle_entry_handoff_skip_event`, and `_get_clamped_worldmap_camera_position_for_zoom`.

All use profile BC. Rule functions call city/hero/supply/tech queries and are called by deployment/context builders. Coordinator functions are called by panel signals or `_input`, and access deployment panel/camera/viewport; these must remain hub wrappers after their rule bodies move to a future `battle_context_service`.

### BR — result settlement and wounded functions retained for the next extraction

`_consume_worldmap_battle_result_if_any`, `_apply_returned_battle_result_mvp`, `_is_player_attack_battle_result`, `_apply_player_attack_battle_result`, `_apply_t02_player_attack_result`, `_settle_defender_generals_after_occupation`, `_set_hero_faction_after_conquest_mvp`, `_rebuild_occupation_runtime_indexes_mvp`, `_move_hero_to_city_t02`, `_normalize_battle_result_hero_ids`, `_on_fast_wounded_treatment_pressed`, `_apply_t02_defender_supply_result`, `_add_t02_attacker_cargo_to_city`, `_apply_invasion_battle_result`, `_format_battle_result_status`, `_is_enemy_invasion_battle_result`, `_normalize_invasion_battle_result_kind`, `_normalize_player_attack_battle_result_kind`, `_get_invasion_result_city_id`, `_build_invasion_result_summary`, `_format_invasion_result_status_from_summary`, `_normalize_battle_hero_outcomes`, `_apply_explicit_battle_hero_outcomes`, `_apply_invasion_hero_state_placeholder`, `_is_hero_eligible_for_placeholder_state`, `_get_existing_hero_runtime_state`, `_set_hero_runtime_status_placeholder`, `_append_hero_state_result_lines`, `_format_hero_name_list`, `_get_hero_state_badge_text`, `_get_hero_display_name_with_state`, `_is_hero_captured_for_battle`, `_get_hero_battle_exclusion_reason`, `_apply_defender_win_invasion_result`, `_apply_attacker_win_invasion_result`, `_apply_player_attack_win_result`, `_apply_player_attack_loss_result`, `_get_player_troop_outcome_from_result`, `_get_enemy_troop_outcome_from_result`, `_calculate_player_attack_troop_outcome_fallback`, `_calculate_invasion_casualty_result`, `_resolve_invasion_remaining_troops`, `_resolve_occupation_troops`, `_clamp_invasion_troops`, `_get_result_troop_value`, `_set_city_runtime_troops`, `_get_city_wounded_queue_mvp`, `_add_wounded_to_city_mvp`, `_clear_city_wounded_queue_mvp`, `_apply_wounded_recovery_for_world_turn_mvp`, and `_advance_wounded_hero_recovery_turns` use profile BR. They are called from battle-result consumption, world-turn recovery, and result UI callbacks; they call city/hero persistence, ownership/index rebuild, resource cargo, and UI refresh. Only callback/refresh functions have direct node/UI dependency; none emit the generic action signals.

### MT and TP — cross-system military functions retained

MT rule functions are `_get_empty_domestic_tech_city_military_defense_bonus_mvp`, `_get_empty_domestic_battle_modifier_mvp`, `_get_domestic_tech_city_military_defense_bonus_mvp`, `_merge_domestic_battle_source_techs_mvp`, `_add_domestic_battle_modifier_values_mvp`, `_get_player_national_battle_modifier_mvp`, `_get_player_city_battle_modifier_mvp`, `_get_player_battle_tech_modifier_mvp`, `_get_domestic_tech_city_naval_siege_bonus_mvp`, `_get_player_naval_unlock_modifier_mvp`, `_get_player_siege_unlock_modifier_mvp`, `_is_player_ship_unlocked_by_domestic_tech_mvp`, `_is_player_siege_unlocked_by_domestic_tech_mvp`, `_has_domestic_tech_city_military_defense_bonus_mvp`, `_has_domestic_defense_modifier_data_mvp`, `_has_domestic_battle_modifier_data_mvp`, `_has_domestic_tech_city_naval_siege_bonus_mvp`, `_has_domestic_tech_city_naval_siege_bonus_data_mvp`, `_get_domestic_tech_city_defense_display_value_mvp`, `_format_city_defense_battle_modifier_summary_mvp`, `_format_domestic_tech_city_military_defense_bonus_lines_mvp`, and `_format_domestic_tech_city_naval_siege_bonus_lines_mvp`. They are called by tech UI and BC hero/context construction. They remain under domestic-tech ownership; military consumes their output rather than owning research state.

TP functions are `_make_t03_transaction_id`, `_build_t03_expedition_cargo_plan`, `_filter_t03_context_heroes`, `_prepare_t03_battle_transaction`, `_select_t03_food_type`, `_sum_t03_food_stock`, `_pay_t03_expedition_cargo`, `_rollback_t03_battle_transaction`, `_resolve_t03_automatic_invasion`, `_apply_t03_strategic_battle_result`, `_apply_t03_defender_supply_result`, `_add_t03_attacker_cargo_to_city`, `_build_t03_battle_report`, `_queue_t03_automatic_battle_report`, `_setup_t03_battle_presentation`, `_try_present_next_t03_battle_report`, `_on_t03_battle_video_skipped`, `_on_t03_battle_video_finished`, `_show_t03_battle_report_card`, `_on_t03_battle_report_confirmed`, `_format_pending_invasion_detail`, and `_format_invasion_status_text`. They form transaction → auto resolution → report queue/presentation. The transaction/rule subset is a future service; presentation callbacks remain hub-owned.

## M-1 finalized move table

| Current function(s) | Target | Move with | Main wrapper | Signal change | Node delivery | External call sites | Regression risk |
|---|---|---|---|---|---|---|---|
| supply path/min-garrison/peace gate (first three MA rows) | `military_controller.gd` | `TROOP_MOVE_MIN_GARRISON_RATIO`, battle-meta/turn-phase identifiers | yes, same names/signatures | none | host bridge; no cache | supply calculation, UI preview, rebalance | medium: graph and pending-state parity |
| move validation/application/arrival (next three MA rows) | same | movement result payload/log format | yes | none | none | unified city action, AI rebalance helpers | high: troop conservation and compatibility payload |
| conscription capacity/availability/multiplier/application (next four MA rows) | same | loyalty ratio and +100/1.10 rules | yes | none | none | domestic turn and city summary | high: per-turn mutation/order |
| recruitment limit/cost/validation/application (last four MA rows) | same | loyalty bands, 100-unit rule, result payload/log format | yes | none | none | city panel callback and summaries | high: payment atomicity and UI contract |

Controller construction is lazy through `_ensure_military_controller`. Existing external call sites keep calling the old private names, so no scene or test caller changes are required. The only new call site is each wrapper’s delegation to the controller. State and cross-system dependencies are passed through explicit host calls/getters; scene nodes are not passed.

## Boundary decision

`main.gd` remains the coordinator for scene lifecycle, node ownership, input, UI signal connection, presentation refresh, scene transition, persistence checkpoints, and cross-system sequencing. Military administration rules and mutations have moved. Enemy strategy, battle-context construction, result settlement, and T03 transaction rules remain identified domain coupling and are the next extraction candidates; their UI callbacks should remain wrappers in the hub.

## Verification record

- Godot 4.6.2 editor/headless parse: pass. Two pre-existing duplicate Battle scene UID warnings remain.
- Military controller extraction: 17 checks, 0 failures, including real recruitment payment/troop mutation and connected-city troop movement conservation.
- WorldMap-to-Battle input lifecycle: pass, including one-shot handoff, context consumption, battle supply runtime, and supply panel visibility.
- Diplomacy suites: routing 172, controller 131, mutation 67, validation 54, state 50, alliance 52 checks; 0 failures.
- Trade suites: routing 73, controller 32, automation 15, internal transfer 21 checks; 0 failures.
- Spy suites: routing 71 and controller 49 checks; 0 failures. Their existing shutdown-only ObjectDB/resource warnings remain.
- `git diff --check`: pass.
- `military_controller.gd` contains no signal connection and no direct node-path lookup. Lazy construction plus its test confirms a single controller instance.
