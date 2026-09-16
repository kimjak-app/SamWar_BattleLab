# T-2 | Domestic Tech Research Lifecycle Service Extraction

## Baseline

- Branch: `recovery/worldmap-iso-sfx-services-20260912`
- T-1 baseline: `87bd41ee705094081649eb34a7d9f3d858164ad0`
- T-1 was already present on origin at T-2 start (`ahead 0 / behind 0`).
- Start working tree: clean
- T-1 `worldmap_main.gd`: 19,063 lines

## Boundary

`scripts/worldmap/domestic_tech/domestic_tech_research_service.gd` is a `RefCounted` lifecycle service. It receives the T-1 Catalog and Rules instances plus narrow query/mutation Callables. It does not receive the world-map host and does not access scene/UI/save state directly.

Queries currently used:

- `player_value`
- `city_state`
- `city_ids`
- `city_exists`
- `is_city_owned`
- `current_turn`
- `city_storage`
- `is_city_coastal`

Mutations currently used:

- `set_player_value`
- `set_city_state`
- `set_city_storage`

## Preserved state schema

National canonical state:

- `_player_state["national_domestic_tech_completed"]`
- `_player_state["national_domestic_tech_unlocked"]`
- `_player_state["national_tech_research"]["active"]`

City canonical/mirror state:

- `_player_state["city_domestic_tech_completed"][city_id]`
- `_player_state["city_domestic_tech_unlocked"][city_id]`
- `_city_runtime_states[city_id]["city_tech"]["research"]["active"]`
- `_city_runtime_states[city_id]["city_tech"]["completed"]` compatibility mirror

No key was renamed, added to the save schema or removed.

## Active payload

The active payload remains exactly:

- `tech_id`
- `started_turn`
- `remaining_turns`
- `duration_turns`

Malformed/old values are normalized to this shape. A zero remaining value completes the valid research during state normalization, matching the pre-extraction behavior.

## Charge contract

- Timing remains `on_research_start_once`.
- No per-turn or completion charge exists.
- National gold uses player `resource_stock`.
- City gold uses city storage.
- Food group is `rice -> barley -> seafood` for implemented scopes.
- Definition costs such as wood/iron/silk/salt remain Catalog/display metadata; the pre-T-2 actual research charge contract implements only planned gold and food-group costs.
- Labor/policy remain explicitly unsupported/skipped.
- All costs are validated before one atomic scope-level stock mutation.
- Repeated start is rejected by active/completed/conflict checks before payment.

## Start flow

ResearchService performs definition/scope lookup through Catalog, eligibility through Rules, completed/active conflict checks, Rules cost/duration lookup, complete affordability validation, one-time payment and active-payload creation. Main adapts reason codes to the existing Korean messages, sets status text and refreshes the inspector/overlay.

## Progress and completion flow

ResearchService normalizes state, advances national then player-city research, decrements `remaining_turns`, completes at zero and returns structured events. Main stores `last_domestic_tech_progress_result`, adds presentation-only completion messages, queues completion presentation and refreshes HUD/overlay surfaces.

National completion clears active state and records the canonical national completed map. Duplicate completion clears active but returns `already_completed` without a second completion.

City completion clears active state, records the canonical per-city completed map and synchronizes the existing `city_tech.completed` mirror. Multiple player cities progress independently.

## Moved functions

State/normalization/query implementations moved behind the service:

- `_normalize_domestic_tech_state_mvp`
- `_normalize_city_domestic_tech_state_map_mvp`
- `_normalize_national_domestic_tech_state_map_mvp`
- `_normalize_national_domestic_tech_research_state_mvp`
- `_normalize_city_domestic_tech_research_state_mvp`
- `_normalize_domestic_tech_research_container_mvp`
- `_normalize_domestic_tech_research_turn_value_mvp`
- `_normalize_domestic_tech_research_duration_value_mvp`
- `_parse_positive_domestic_tech_research_turn_value_mvp`
- `_mark_domestic_tech_completed_from_normalize_mvp`
- `_sync_city_domestic_tech_completed_mirror_mvp`
- `_get_national_domestic_tech_active_research_mvp`
- `_get_city_domestic_tech_active_research_mvp`
- `_is_domestic_tech_researching_mvp`
- `_is_city_domestic_tech_completed_mvp`
- `_is_national_domestic_tech_completed_mvp`

Lifecycle/charge implementations moved behind the service:

- `_build_domestic_tech_actual_charge_plan_mvp`
- `_has_domestic_tech_national_food_group_scope_mvp`
- `_validate_domestic_tech_actual_charge_mvp`
- `_apply_domestic_tech_actual_charge_mvp`
- `_can_start_domestic_tech_research_mvp` domain portion
- `_start_domestic_tech_research_mvp` domain/mutation portion
- `_advance_domestic_tech_research_for_world_turn_mvp` domain portion
- `_advance_national_tech_research_for_world_turn_mvp`
- `_advance_city_tech_research_for_world_turn_mvp`
- `_complete_national_tech_research_mvp`
- `_complete_city_tech_research_mvp`
- `_get_player_city_ids_for_domestic_tech_research_mvp`

The original main signatures remain as thin compatibility wrappers or presentation adapters.

## Retained in main

- button callback and action-slot UI
- Korean validation/status/completion strings
- Tech Tree inspector/overlay refresh
- completion queue/video/card/SFX
- HUD refresh and last-result storage
- save/load orchestration
- all completed-tech effect calculation and safe sets

## Legacy coexistence

Legacy `_advance_national_tech_progress_for_world_turn()` and `_advance_city_tech_progress_for_world_turn()` are unchanged. `_apply_domestic_turn_mvp` still calls, exactly once and in order:

1. national legacy progression
2. city legacy progression
3. Domestic Tech lifecycle service wrapper

The legacy progression schema was not merged with Domestic Tech. Only the existing city completed compatibility mirror is maintained.

## Tests and structural verification

- T-2 ResearchService: 35 checks, 0 failures
- T-1 Catalog: 19 checks, 0 failures
- T-1 Rules: 17 checks, 0 failures
- Existing world-map runtime regression scripts: 22 pass (diplomacy routing passed on isolated rerun after one batch timeout)
- Applicable static validators: 13 pass
- Godot project and `WorldMap_16x9_Test.tscn` headless parse/load: pass
- ResearchService forbidden dependency scan: 0 matches
- `git diff --check`: pass

Historical fixed-baseline guards remain unmodified and non-applicable: diplomacy routing rejects the intentional T-1 catalog wrapper change; deployment and T03 presentation compare `battle_settlement_applier.gd` to pre-AF-1 baselines.

## Main reduction

- T-1 baseline: 19,063 lines
- T-2 result: 18,574 lines
- T-2 net reduction: 489 lines
- T-0 baseline: 19,275 lines
- T-0 through T-2 cumulative net reduction: 701 lines

## T-3 Effect Provider candidates

- `_get_domestic_tech_city_economy_bonus_mvp`
- `_get_player_city_domestic_economy_modifier_mvp`
- `_get_domestic_tech_city_military_defense_bonus_mvp`
- `_get_domestic_tech_city_naval_siege_bonus_mvp`
- `_get_domestic_tech_national_policy_bonus_mvp`
- `_get_domestic_tech_diplomacy_spy_bonus_mvp`
- `_get_domestic_tech_city_spy_intel_bonus_mvp`
- `_get_domestic_tech_economy_turn_summary_mvp`
- `_get_domestic_tech_effect_phase1_summary_mvp`
- `_get_domestic_tech_national_policy_effect_summary_mvp`
- `_get_domestic_tech_numeric_effect_phase1_summary_mvp`
- `_get_domestic_tech_military_defense_effect_summary_mvp`
- `_get_domestic_tech_naval_siege_effect_summary_mvp`
- `_get_domestic_tech_diplomacy_spy_effect_summary_mvp`
- `_get_domestic_tech_full_effect_integration_summary_mvp`
- `_get_domestic_tech_gameplay_effect_integration_map_summary_mvp`
