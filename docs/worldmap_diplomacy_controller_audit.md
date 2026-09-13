# Diplomacy controller extraction audit (2F)

Baseline: `114cb33283ef08e4282dff4f79b130127039d4ac` on `recovery/worldmap-iso-sfx-services-20260912`.

Local/origin match; initial tree clean; integrity and four routing/separation validators pass. Runtime baseline: 172/54/67/50/52/71/73 checks pass.

This inventory uses function bodies and caller references (including Service host.call, tests, turn defaults and UI), not names alone.

## Ownership decisions

### Controller

| Function | Main callers before extraction |
| --- | --- |
| `_make_faction_relation_key` | `_ensure_faction_relation_entry`, `_adjust_faction_relation_score`, `_request_military_support`, `_break_spy_wedge_alliance_if_needed`, `_normalize_faction_relations_for_world_state` |
| `_normalize_faction_relation_status` | `_get_enemy_diplomacy_follow_up_candidates_mvp`, `_normalize_enemy_strategic_action_for_display`, `_ensure_faction_relation_entry`, `_get_faction_relation_status`, `_build_diplomacy_action_validation_context`, `_request_military_support`, `_get_spy_wedge_counterpart_faction_id`, `_can_wedge_faction_relation`, `_break_spy_wedge_alliance_if_needed` |
| `_get_faction_relation_band` | `_format_city_trade_route_display`, `_adjust_faction_relation_score`, `_calculate_trade_route_value` |
| `_ensure_faction_relation_entry` | `_get_enemy_diplomacy_follow_up_candidates_mvp`, `_get_faction_relation_entry`, `_adjust_faction_relation_score`, `_build_diplomacy_action_validation_context`, `_calculate_military_support_acceptance_chance`, `_request_military_support`, `_get_spy_wedge_counterpart_faction_id`, `_can_wedge_faction_relation`, `_break_spy_wedge_alliance_if_needed`, `_normalize_faction_relations_for_world_state` |
| `_get_faction_relation_entry` | `_get_faction_relation_score`, `_get_faction_relation_status` |
| `_get_faction_relation_score` | `_format_diplomacy_relation_summary_for_ui`, `_refresh_diplomacy_action_card`, `_get_enemy_diplomacy_baseline_mvp`, `_apply_enemy_diplomacy_follow_up_mvp`, `_gather_spy_info`, `_disrupt_city_public_support`, `_disrupt_city_loyalty`, `_instigate_revolt`, `_apply_spy_wedge_action`, `_calculate_trade_route_value` |
| `_get_faction_relation_status` | `_refresh_manual_trade_order_relation`, `_format_diplomacy_relation_summary_for_ui`, `_format_diplomacy_action_candidates_for_ui`, `_refresh_diplomacy_action_card`, `_format_external_trade_relation_summary`, `_get_trade_relation_multiplier_for_ui`, `_get_spy_wedge_success_chance`, `_can_drive_wedge`, `_can_trade_between_factions`, `_calculate_trade_route_value` |
| `_normalize_diplomacy_action_state_from_player_state` | `_ensure_worldmap_runtime_state_defaults` |
| `_sync_diplomacy_action_mirror_state_from_relations` | `_normalize_diplomacy_action_state_from_player_state`, `_advance_diplomacy_cooldowns_for_world_turn`, `_break_spy_wedge_alliance_if_needed` |
| `_get_selected_diplomacy_target` | `_build_diplomacy_action_validation_context`, `_on_diplomacy_action_pressed` |
| `_get_diplomacy_action_definition` | `_format_diplomacy_action_hint`, `_build_diplomacy_action_validation_context` |
| `_get_diplomacy_action_cooldown` | `_refresh_diplomacy_action_card`, `_build_diplomacy_action_validation_context` |
| `_build_diplomacy_action_validation_context` | `_validate_diplomacy_action` |
| `_validate_diplomacy_action` | `_refresh_diplomacy_action_card`, `_get_domestic_tech_gameplay_effect_integration_map_summary_mvp`, `_on_diplomacy_action_pressed` |
| `_calculate_alliance_acceptance_chance` | `_get_domestic_tech_gameplay_effect_integration_map_summary_mvp`, `_build_diplomacy_action_validation_context` |
| `_get_trade_agreement_bonus_multiplier` | `_get_trade_relation_multiplier_for_ui`, `_calculate_trade_route_value` |
| `_get_active_trade_agreement_turns` | `_refresh_diplomacy_action_card`, `_get_enemy_diplomacy_baseline_mvp` |
| `_get_active_alliance_turns` | `_refresh_diplomacy_action_card`, `_get_enemy_diplomacy_baseline_mvp` |
| `_advance_diplomacy_cooldowns_for_world_turn` | `_apply_domestic_turn_mvp` |
| `_get_known_faction_ids_for_diplomacy` | `_get_spy_wedge_candidate_faction_ids`, `_normalize_faction_relations_for_world_state` |
| `_normalize_faction_relations_for_world_state` | `_apply_domestic_turn_mvp` |
| `_get_enemy_diplomacy_baseline_mvp` | `_get_modified_diplomacy_relation_delta_mvp`, `_get_modified_diplomacy_success_chance_mvp`, `_format_player_diplomacy_tech_modifier_summary_mvp` |
| `_get_empty_domestic_diplomacy_modifier_mvp` | `_get_player_diplomacy_tech_modifier_mvp` |
| `_get_player_diplomacy_tech_modifier_mvp` | `_get_modified_diplomacy_relation_delta_mvp`, `_get_modified_diplomacy_success_chance_mvp`, `_format_player_diplomacy_tech_modifier_summary_mvp` |
| `_has_domestic_diplomacy_modifier_data_mvp` | `_format_player_diplomacy_tech_modifier_summary_mvp` |
| `_get_modified_diplomacy_relation_delta_mvp` | `_build_diplomacy_action_validation_context` |
| `_get_modified_diplomacy_success_chance_mvp` | `_calculate_military_support_acceptance_chance` |

### Presentation helper

| Function | Main callers before extraction |
| --- | --- |
| `_format_diplomacy_owner_display` | `_show_unified_diplomacy_spy_content` |
| `_format_diplomacy_relation_summary_for_ui` | `_show_unified_diplomacy_spy_content` |
| `_format_diplomacy_relation_status_for_ui` | `_format_diplomacy_relation_summary_for_ui`, `_refresh_diplomacy_action_card` |
| `_format_diplomacy_trade_status_for_ui` | `_show_unified_diplomacy_spy_content` |
| `_format_diplomacy_action_candidates_for_ui` | `_show_unified_diplomacy_spy_content` |
| `_format_diplomacy_policy_display_for_ui` | `_show_unified_diplomacy_spy_content` |
| `_format_diplomacy_action_hint` | `_refresh_diplomacy_action_card` |
| `_format_last_diplomacy_action_result_for_ui` | `_format_diplomacy_policy_display_for_ui` |
| `_format_player_diplomacy_tech_modifier_summary_mvp` | `_format_diplomacy_policy_display_for_ui` |
| `_format_diplomacy_normalize_summary` | `_format_domestic_apply_summary` |
| `_format_diplomacy_cooldown_summary` | `_format_domestic_apply_summary` |
| `_format_last_tribute_summary` | `_format_domestic_apply_summary` |

## Retained boundaries

- Main owns Controller and injects it into Coordinator. Generic action begin/request/complete/cancel and pending IDs retain their existing contracts.
- UI card/button node creation and signal wiring remain in main. Card models, hints, tooltips, result and turn-summary text move to the helper.
- Military support acceptance/request and Spy wedge implementation remain byte-for-byte unchanged. Their relation/key/status/sync/modified-chance calls retain thin main adapters.
- AI follow-up scoring/action selection, trade route value/payment, and shared domestic research data remain in their domains. Relation APIs delegate to Controller.
- Main retains generic player state, city/hero/technology storage and status label storage. Controller adapts these explicitly, without a new repository.
- Shared generic relation adjustment remains the existing Spy/AI/Military boundary; production diplomacy mutation stays in the unmodified Service.
- Save/load and turn entries remain generic; diplomacy implementations delegate to Controller.
- `_format_diplomacy_spy_target_city_display` and `_get_diplomacy_spy_tab_label` remain shared Spy/UI presentation.
- `_get_selected_city_relation_label` and `_get_selected_city_relation_description` have no callers in scripts/tests; remove as dead helpers in 2F-3.

## Checkpoints

2F-1: inject Controller and consolidate Service instances; explicit adapters may forward to main until 2F-2.

2F-2: move audited context/state/query/lifecycle implementations; migrate internal-only callers and tests, preserving external boundaries.

2F-3: move presentation models/text and remove dead wrappers. Re-run all seven runtime suites between stages.

## Completed verification

All three internal checkpoints passed the seven runtime suites: diplomacy routing 172/172, validation 54/54, mutation 67/67, cooldown/agreement 50/50, alliance 52/52, Spy 71/71, Trade 73/73. No checkpoint commits were created.

Final 2F regression: 131/131 checks. It exercises a minimal host with no diplomacy implementation, Coordinator immediate/presentation completion parity for all five actions and invalid actions across player/silla, cancellation/context-change, validation, full result/state dictionaries, state replacement, save serialization/restore, cooldown/agreement/alliance expiry and presentation strings. The five existing diplomacy tests changed only their owner/host access; the new validator enforces this exact migration.

Static checks passed: worldmap integrity, diplomacy routing, 2D separation, 2F extraction, Spy routing, Trade routing, battle input lifecycle, supply/production log contract and git diff --check. Old whole-Coordinator and 2D deletion-budget checks are replaced by exact diplomacy-only Coordinator transformation checks, exact moved implementation comparisons, and untouched-main function comparisons.

Godot 4.6.2 executable: C:/Users/seong/Desktop/godot/Godot_v4.6.2-stable_win64_console.exe. Editor scan/parse, project headless and WorldMap_16x9_Test.tscn headless exited 0. Existing duplicate Battle scene UID warnings (2) remain; these scene files were not changed. No interactive visual/manual gameplay QA is claimed.

Main: 24,261 -> 23,633 lines; 1,181 -> 1,153 functions; +53/-681 (net -628). Controller owns 27 moved functions. Presenter owns 12 moved formatting functions and two extracted card/button models. Removed 16 unnecessary Controller wrappers, 12 presentation functions and two unused legacy display functions from main. Added only two main setup methods.

## Final main compatibility APIs and reasons

| Main API | Reason retained |
| --- | --- |
| `_make_faction_relation_key` | Shared Spy/Military relation identity |
| `_normalize_faction_relation_status` | Spy/Military/AI status boundary |
| `_get_faction_relation_band` | Generic trade display and shared relation adjustment |
| `_ensure_faction_relation_entry` | Spy/Military/AI shared relation boundary |
| `_get_faction_relation_score` | Spy/AI/Trade read boundary |
| `_get_faction_relation_status` | Spy/Trade read boundary |
| `_sync_diplomacy_action_mirror_state_from_relations` | Unchanged Spy wedge sync call |
| `_validate_diplomacy_action` | UI validation entry and integrity sentinel |
| `_get_trade_agreement_bonus_multiplier` | Existing Trade efficiency contract |
| `_get_known_faction_ids_for_diplomacy` | Unchanged Spy wedge candidate enumeration |
| `_get_modified_diplomacy_success_chance_mvp` | Unchanged Military acceptance modifier call |

Every API above is a single delegation statement. Generic turn/defaults call Controller directly. Main also retains Controller/Presenter creation, Coordinator injection, action/video signals and pending state, action press/execute UI bridge, diplomacy card/button node wiring, shared diplomacy/Spy tab wiring and placeholder label wiring. AI follow-up selection/scoring, military execution, Spy wedge execution and shared relation adjustment are unchanged.

Service production host is exclusively Controller. Service source is unchanged; it does not receive main. Controller reads/writes the live generic player dictionary and status storage and explicitly bridges player identity, selected city, city ownership, city-count baseline, generic technology data/source lookups and food totals. Presenter uses Controller queries plus generic faction/resource labels, resource cost formatting, percent formatting and Trade availability. No new state repository, Spy/Trade phase-two extraction or military extraction was performed.
