# WorldMap M-2 enemy warfare audit and move table

Baseline checkpoint: `5b3e6fd` (`refactor(worldmap): extract military administration controller`).

## Boundary

M-2 owns enemy personality/goal interpretation, pressure-plan candidate generation and target selection, reinforcement target scoring, and invasion-pair eligibility/ranking. It does not own turn mutation, RNG/event creation, UI formatting, deployment, battle context, camera, scene transition, battle result, occupation, diplomacy, trade, spy, or military administration.

The service receives personality/goal seeds and invasion configuration once. Runtime facts are queried through a narrow adapter on `worldmap_main.gd`; it has no NodePath, cached scene node, signal, or UI dependency.

## Exact move table

| Current function(s) | Target | Inputs/dependencies | Main wrapper | Callers | Risk |
|---|---|---|---|---|---|
| `_get_enemy_faction_personality_seed`, `_get_enemy_faction_personality_profile_id`, `_get_enemy_faction_personality_label`, `_get_enemy_faction_behavior_weight`, `_get_enemy_faction_personality_metadata` | `enemy_warfare_service.gd` | injected personality seeds, player faction | yes | pressure/reinforcement scoring and result presentation | low: default merge parity |
| `_get_enemy_faction_strategic_goal_seed`, `_get_enemy_faction_goal_id`, `_get_enemy_faction_goal_label`, `_get_enemy_faction_goal_pressure`, `_get_enemy_faction_goal_weight`, `_get_enemy_goal_target_city_ids`, `_is_city_preferred_by_enemy_goal`, `_is_city_adjacent_to_enemy_goal_target`, `_get_enemy_faction_goal_metadata` | same | injected goal seeds; city existence/neighbors | yes | pressure/reinforcement scoring and summaries | medium: invalid target filtering |
| `_normalize_enemy_pressure_type_mvp`, `_should_skip_enemy_pressure_plan_mvp`, `_build_enemy_pressure_plan_candidates_mvp`, `_build_enemy_pressure_plan_candidate_for_faction_mvp`, `_get_enemy_pressure_plan_target_city_ids_for_source_mvp`, `_score_enemy_pressure_plan_candidate_mvp`, `_sort_enemy_pressure_plan_candidates_mvp`, `_pick_enemy_pressure_plan_mvp`, `_normalize_enemy_pressure_plan_result_mvp`, `_get_enemy_pressure_plan_for_scoring_mvp`, `_is_enemy_pressure_plan_target_city_mvp`, `_get_enemy_pressure_plan_score_bonus_mvp` | same | turn/pending state, faction/city facts, labels | yes | enemy-turn coordinator, reinforcement/invasion/diplomacy/spy scoring consumers | high: deterministic ordering and persisted payload compatibility |
| `_is_enemy_frontline_city_for_faction`, `_find_enemy_frontline_city_for_faction`, `_pick_enemy_city_for_turn_action`, `_score_enemy_reinforcement_city_for_personality` | same | owner, neighbors, troops, pressure plan | yes | `_process_enemy_faction_turn_mvp`, reinforcement mutation | high: selected reinforcement target parity |
| `_get_enemy_invasion_pairs_mvp`, `_is_city_owner_consistent_for_enemy_invasion_mvp`, `_is_enemy_invasion_pair_eligible_mvp`, `_score_enemy_invasion_pair_mvp`, `_sort_enemy_invasion_pairs_mvp`, `_get_city_troops_for_enemy_invasion_mvp`, `_is_player_frontline_city_for_enemy_invasion_mvp` | same | Korea city ids, ownership, adjacency, troop/hero/command/supply facts | yes | `_roll_enemy_invasion_event_mvp`, UI/status helpers | high: invasion availability and deterministic pair order |

## Retained coordinator/adapters

- `_roll_enemy_invasion_event_mvp`: turn guards, one-roll state, RNG, pending-event creation, cooldown, auto-resolution.
- `_process_enemy_faction_turn_mvp`: phase orchestration, state persistence, reinforcement mutation, diplomacy/spy follow-up, summary.
- `_apply_enemy_city_reinforcement_mvp`: city troop mutation; consumes service target decision.
- `_get_safe_enemy_owner_faction_id_for_turn_mvp`, `_get_worldmap_city_ids_for_enemy_turn_mvp`, `_get_enemy_faction_ids_for_turn_mvp`, `_get_enemy_owned_city_ids_for_faction`: runtime-state adapters/enumeration retained to avoid moving scene registries.
- `_get_enemy_pressure_plan_display_label_mvp`, `_get_enemy_pressure_plan_compact_label_mvp`, `_format_enemy_pressure_plan_hint_mvp` and other `_format_enemy_*` helpers: presentation only.
- `_enemy_warfare_query`: narrow dependency adapter; no strategy/selection policy.

## M-3 handoff exclusion

Battle-context candidates are deliberately excluded: `_validate_pending_invasion_event_for_battle_context`, `_build_battle_context_from_pending_invasion`, `_build_player_attack_battle_context`, `_build_player_attack_selected_roster_for_battle_context`, `_build_selected_side_roster_for_battle_context`, `_build_even_troop_allocation_for_heroes`, `_build_command_limit_troop_allocation_for_heroes`, `_apply_troop_allocation_to_roster`, `_sum_troop_allocation`, `_build_invasion_side_roster_for_battle_context`, `_append_invasion_roster_hero_id`, `_build_invasion_roster_result`, `_get_reinforcement_candidate_city_ids_for_battle_context`, `_are_factions_reinforcement_compatible`, `_get_hero_city_id_for_battle_context`, `_get_city_stationed_hero_ids_for_battle_context`, `_get_city_battle_heroes_for_battle_context`, `_apply_domestic_battle_tech_modifier_to_hero_data_mvp`, `_get_hero_battle_data_for_battle_context`, `_get_city_governor_id_for_battle_context`, `_normalize_command_rank_mvp`, `_get_hero_command_rank_for_city_mvp`, `_get_hero_command_limit_for_city_mvp`, `_get_hero_command_summary_for_city_mvp`, `_set_pending_battle_context_mvp`, `_get_pending_battle_context_mvp`, and `_clear_pending_battle_context_mvp`.

## Verification

- Godot 4.6.2 editor/headless parse: pass; only the two pre-existing duplicate Battle scene UID warnings remain.
- Enemy warfare extraction: 20 checks, 0 failures. Covers singleton construction, pressure normalization, personality/goal resolution, reinforcement target selection/scoring, pressure candidates, and invasion eligibility.
- Military administration: 17 checks, 0 failures.
- Diplomacy: 526 checks, 0 failures.
- Trade: 141 checks, 0 failures.
- Spy: 120 checks, 0 failures; pre-existing shutdown-only resource warnings remain.
- WorldMap-to-Battle lifecycle: pass.
- `git diff --check`: pass.
