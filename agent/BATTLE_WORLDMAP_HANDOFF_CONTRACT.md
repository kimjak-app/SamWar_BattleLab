# Battle <-> WorldMap Handoff Contract

## Baseline
- WorldMap script: `scripts/worldmap/worldmap_main.gd`
- Battle script: `scripts/battle_web_import_test.gd`
- Main scene: `res://WorldMap.tscn`
- Battle scene: `res://Battle_Land.tscn`
- Analysis baseline: `62db80afecaa22b47be6a7fb05b4360fe4376c51` (`v0.72-03 Scene Entrypoint Rename Complete Lock`)

## Contract Summary
- WorldMap -> Battle entry: WorldMap builds a battle context dictionary, stores it in `Engine` meta under `samwar_worldmap_battle_context`, then changes scene to `res://Battle_Land.tscn`.
- Battle receives: `scripts/battle_web_import_test.gd` reads and removes the context meta during startup, duplicates the dictionary, applies rosters/hero contracts, and configures the battle UI for a worldmap-origin battle.
- Battle runtime mutates: local battle actor/unit state, hero contract registries, roster summary, visuals, and result return UI while preserving the input context shape for result construction.
- Battle -> WorldMap return: Battle builds a result dictionary, stores it in `Engine` meta under `samwar_worldmap_battle_result`, and changes scene to `res://WorldMap.tscn`.
- WorldMap applies result: WorldMap consumes and removes `samwar_worldmap_battle_result`; T02 player-attack results restore the transaction snapshot, validate transaction/result IDs, atomically settle city/general/troop/resource/wounded state, refresh UI, and checkpoint. Legacy enemy-invasion results retain the pre-T02 handler for T03.

## Scene Paths
- `WORLDMAP_BATTLE_SCENE_PATH`: `res://Battle_Land.tscn`
- `WORLDMAP_SCENE_PATH`: `res://WorldMap.tscn`
- WorldMap -> Battle meta key: `samwar_worldmap_battle_context`
- Battle -> WorldMap meta key: `samwar_worldmap_battle_result`

## Data Fields

### T02 Required Player-Attack Extension

BattleContext adds `transaction_id`, `scenario_id`, `player_faction_id`, attacker/defender faction and source/target city IDs, general IDs, initial healthy troops and compositions, attacker carried gold/food type/food/salt, defender selected city food type/amount/salt, `battle_max_turns=30`, current turn, supply/tech snapshots, return destination, and a transient strategic-state snapshot. Production contexts use registry-backed city generals only.

BattleResult adds `transaction_id`, `result_id`, `winner_side`, `result_reason`, `completed_turn`, each side's healthy/wounded/dead/deserter counts, remaining supply, surviving general IDs, and the transient strategic snapshot. All numeric result fields are non-negative. `turn_limit` always means defender victory.

`BattleSupplyRuntime` settles attacker and defender once per numbered round. UI and runtime both use `ExpeditionSupplyCalculator`. WorldMap rejects a mismatched pending transaction ID and ignores an already-applied result ID. Battle never mutates persistent WorldMap state directly.

### WorldMap -> Battle Context Fields
| Field | Source Function | Battle Consumer | Required? | Notes |
|---|---|---|---:|---|
| `source` | `_build_battle_context_from_pending_invasion`, `_build_player_attack_battle_context` | `_build_worldmap_battle_result_payload` | REVIEW | Preserved into result payload when present. |
| `type` | `_build_battle_context_from_pending_invasion`, `_build_player_attack_battle_context` | `_apply_worldmap_battle_context_handoff`, `_build_worldmap_battle_result_payload` | YES | Invasion/player attack discriminator. |
| `mode` | `_build_battle_context_from_pending_invasion`, `_build_player_attack_battle_context` | `_apply_worldmap_battle_context_handoff`, `_build_worldmap_battle_result_payload` | YES | Manual/auto battle mode marker. |
| `attacker_city_id` | WorldMap battle context builders | `_apply_worldmap_context_side_roster`, `_build_worldmap_battle_result_payload` | YES | Attacker city identity. |
| `defender_city_id` | WorldMap battle context builders | `_apply_worldmap_context_side_roster`, `_build_worldmap_battle_result_payload` | YES | Defender city identity. |
| `attacker_city_name` | WorldMap battle context builders | `_apply_worldmap_battle_context_handoff`, `_apply_worldmap_context_side_roster`, result payload builder | REVIEW | Used for diagnostics and display. |
| `defender_city_name` | WorldMap battle context builders | `_apply_worldmap_battle_context_handoff`, `_apply_worldmap_context_side_roster`, result payload builder | REVIEW | Used for diagnostics and display. |
| `attacker_owner` | WorldMap battle context builders | `_apply_worldmap_context_side_roster`, result payload builder | REVIEW | Side owner/faction label. |
| `defender_owner` | WorldMap battle context builders | `_apply_worldmap_context_side_roster`, result payload builder | REVIEW | Side owner/faction label. |
| `attacker_troops` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Original attacker troop count. |
| `defender_troops` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Original defender troop count. |
| `attacker_total_allocated_troops` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Used to build return troop outcome. |
| `defender_total_allocated_troops` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Used to build return troop outcome. |
| `attacker_troop_allocation` | WorldMap battle context builders | `_apply_worldmap_context_side_roster`, result payload builder | REVIEW | Per-hero allocation payload. |
| `defender_troop_allocation` | WorldMap battle context builders | `_apply_worldmap_context_side_roster`, result payload builder | REVIEW | Per-hero allocation payload. |
| `attacker_source_city_id` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Source city for player attack troop accounting. |
| `defender_source_city_id` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Source city for defender troop accounting when present. |
| `attacker_source_city_troops_before` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Preserved accounting field. |
| `attacker_source_city_troops_after` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Preserved accounting field. |
| `defender_source_city_troops_before` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Preserved accounting field. |
| `defender_source_city_troops_after` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Preserved accounting field. |
| `troop_deployed_from_city` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Legacy/summary deployment field. |
| `attacker_troop_deployed_from_city` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Attacker deployment accounting. |
| `defender_troop_deployed_from_city` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Defender deployment accounting. |
| `turn_number` | WorldMap battle context builders | `_build_worldmap_battle_result_payload` | REVIEW | Preserved turn marker. |
| `attacker_governor_id` | WorldMap battle context builders | `_get_context_hero_ids_for_side` | REVIEW | Fallback actor id for attacker side. |
| `defender_governor_id` | WorldMap battle context builders | `_get_context_hero_ids_for_side` | REVIEW | Fallback actor id for defender side. |
| `attacker_heroes` | WorldMap battle context builders | `_register_worldmap_context_hero_contracts`, `_get_context_hero_ids_for_side` | REVIEW | Hero contract list/dictionary. |
| `defender_heroes` | WorldMap battle context builders | `_register_worldmap_context_hero_contracts`, `_get_context_hero_ids_for_side` | REVIEW | Hero contract list/dictionary. |
| `attacker_hero_ids` | WorldMap battle context builders | `_get_context_hero_ids_for_side` | REVIEW | Explicit attacker roster id list. |
| `defender_hero_ids` | WorldMap battle context builders | `_get_context_hero_ids_for_side` | REVIEW | Explicit defender roster id list. |
| `selected_attacker_hero_ids` | `_build_player_attack_battle_context` | `_get_context_hero_ids_for_side` | REVIEW | Selected player attack roster. |
| `selected_defender_hero_ids` | `_build_battle_context_from_pending_invasion` | `_get_context_hero_ids_for_side` | REVIEW | Selected defense roster. |
| `supply_cost` | `_build_player_attack_battle_context` | UNKNOWN / needs source inspection | REVIEW | Mentioned in builder signature; consumer should be verified before contract edits. |

### Battle -> WorldMap Result Fields
| Field | Battle Producer | WorldMap Consumer | Required? | Notes |
|---|---|---|---:|---|
| `source` | `_build_worldmap_battle_result_payload` | `_apply_returned_battle_result_mvp` and downstream result handlers | REVIEW | Preserved from context when present. |
| `type` | `_build_worldmap_battle_result_payload` | `_is_enemy_invasion_battle_result`, `_is_player_attack_battle_result` | YES | Result type discriminator. |
| `mode` | `_build_worldmap_battle_result_payload` | `_apply_returned_battle_result_mvp` | REVIEW | Preserved battle mode. |
| `result` | `_build_worldmap_battle_result_payload` | `_apply_returned_battle_result_mvp`, invasion/player result handlers | YES | Battle outcome kind. |
| `winner` | `_build_worldmap_battle_result_payload` | `_apply_returned_battle_result_mvp`, result formatters | YES | Winner side marker. |
| `attacker_city_id` | `_build_worldmap_battle_result_payload` | `_apply_player_attack_battle_result`, invasion result helpers | YES | City result identity. |
| `defender_city_id` | `_build_worldmap_battle_result_payload` | `_apply_player_attack_battle_result`, invasion result helpers | YES | City result identity. |
| `attacker_city_name` | `_build_worldmap_battle_result_payload` | result summary/status helpers | REVIEW | Display/status field. |
| `defender_city_name` | `_build_worldmap_battle_result_payload` | result summary/status helpers | REVIEW | Display/status field. |
| `attacker_owner` | `_build_worldmap_battle_result_payload` | result handlers/status | REVIEW | Owner/faction marker. |
| `defender_owner` | `_build_worldmap_battle_result_payload` | result handlers/status | REVIEW | Owner/faction marker. |
| `attacker_troops` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Original troop count. |
| `defender_troops` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Original troop count. |
| `attacker_surviving_troops` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Runtime survivor count. |
| `defender_surviving_troops` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Runtime survivor count. |
| `attacker_total_allocated_troops` | `_build_worldmap_battle_result_payload` | player/invasion result handlers | REVIEW | Allocation accounting. |
| `defender_total_allocated_troops` | `_build_worldmap_battle_result_payload` | player/invasion result handlers | REVIEW | Allocation accounting. |
| `attacker_troop_allocation` | `_build_worldmap_battle_result_payload` | player/invasion result handlers | REVIEW | Per-hero allocation. |
| `defender_troop_allocation` | `_build_worldmap_battle_result_payload` | player/invasion result handlers | REVIEW | Per-hero allocation. |
| `attacker_source_city_id` | `_build_worldmap_battle_result_payload` | player attack result handlers | REVIEW | Player source city accounting. |
| `defender_source_city_id` | `_build_worldmap_battle_result_payload` | invasion result handlers | REVIEW | Defender source accounting. |
| `attacker_source_city_troops_before` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Accounting field. |
| `attacker_source_city_troops_after` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Accounting field. |
| `defender_source_city_troops_before` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Accounting field. |
| `defender_source_city_troops_after` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Accounting field. |
| `troop_deployed_from_city` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Legacy/summary deployment field. |
| `attacker_troop_deployed_from_city` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Attacker deployment accounting. |
| `defender_troop_deployed_from_city` | `_build_worldmap_battle_result_payload` | troop result handlers | REVIEW | Defender deployment accounting. |
| `turn_number` | `_build_worldmap_battle_result_payload` | result handlers/status | REVIEW | Turn marker. |
| `player_troop_outcome` | `_calculate_player_attack_troop_outcome_from_units` | player attack result handlers | REVIEW | Nested outcome dictionary. |
| `enemy_troop_outcome` | `_calculate_player_attack_troop_outcome_from_units` / mirrored side logic | result handlers | REVIEW | Nested outcome dictionary when present. |
| `source_city_id` | `_calculate_player_attack_troop_outcome_from_units` | player attack troop accounting | REVIEW | Nested troop outcome field. |
| `allocated` | `_calculate_player_attack_troop_outcome_from_units` | player attack troop accounting | REVIEW | Nested troop outcome field. |
| `survivors` | `_calculate_player_attack_troop_outcome_from_units` | player attack troop accounting | REVIEW | Nested troop outcome field. |
| `losses` | `_calculate_player_attack_troop_outcome_from_units` | player attack troop accounting | REVIEW | Nested troop outcome field. |
| `wounded` | `_calculate_player_attack_troop_outcome_from_units` | player attack troop accounting | REVIEW | Nested troop outcome field. |
| `dead` | `_calculate_player_attack_troop_outcome_from_units` | player attack troop accounting | REVIEW | Nested troop outcome field. |
| `allocations` | `_calculate_player_attack_troop_outcome_from_units` | player attack troop accounting | REVIEW | Nested per-unit allocation field. |
| `survivor_allocations` | `_calculate_player_attack_troop_outcome_from_units` | player attack troop accounting | REVIEW | Nested per-unit survivor field. |

## Locked Contract Functions

### WorldMap Side
| Function | Reason |
|---|---|
| `_confirm_defense_deployment` | Prepares defense deployment and pending battle context. |
| `_handoff_battle_context_to_battle_scene` | Validates and initiates battle scene handoff. |
| `_change_scene_to_battle_with_context` | Owns `Engine` meta write and scene transition to `Battle_Land.tscn`. |
| `_consume_worldmap_battle_result_if_any` | Owns result meta read/remove on WorldMap startup. |
| `_apply_returned_battle_result_mvp` | Dispatches returned result into worldmap mutation handlers. |
| `_is_player_attack_battle_result` | Classifies player attack result payload. |
| `_apply_player_attack_battle_result` | Applies player attack battle result to worldmap state. |
| `_apply_invasion_battle_result` | Applies invasion battle result to worldmap state. |
| `_format_battle_result_status` | User-facing result status tied to payload shape. |
| `_is_enemy_invasion_battle_result` | Classifies enemy invasion result payload. |
| `_normalize_invasion_battle_result_kind` | Normalizes contract result values. |
| `_normalize_player_attack_battle_result_kind` | Normalizes contract result values. |
| `_get_invasion_result_city_id` | Resolves city identity from result payload. |
| `_build_invasion_result_summary` | Converts result payload into apply/status summary. |
| `_format_invasion_result_status_from_summary` | User-facing summary tied to result summary shape. |
| `_apply_invasion_hero_state_placeholder` | Applies hero placeholder state from battle outcome. |
| `_apply_defender_win_invasion_result` | Mutates city/invasion state for defender win. |
| `_apply_attacker_win_invasion_result` | Mutates city/invasion state for attacker win. |
| `_calculate_invasion_casualty_result` | Result formula/accounting; do not move without formula review. |
| `_resolve_invasion_remaining_troops` | Result troop accounting. |
| `_clamp_invasion_troops` | Result troop accounting. |
| `_validate_pending_invasion_event_for_battle_context` | Validates source pending invasion payload. |
| `_build_battle_context_from_pending_invasion` | Builds WorldMap -> Battle context dictionary. |
| `_build_player_attack_battle_context` | Builds player attack WorldMap -> Battle context dictionary. |
| `_build_player_attack_selected_roster_for_battle_context` | Builds selected player roster contract. |
| `_build_selected_side_roster_for_battle_context` | Builds side roster contract. |
| `_build_invasion_side_roster_for_battle_context` | Builds invasion side roster contract. |
| `_append_invasion_roster_hero_id` | Roster payload construction helper. |
| `_build_invasion_roster_result` | Roster payload construction helper. |
| `_get_reinforcement_candidate_city_ids_for_battle_context` | Context construction for reinforcement candidates. |
| `_are_factions_reinforcement_compatible` | Context construction rule; review before extraction. |
| `_get_hero_city_id_for_battle_context` | Context construction helper. |
| `_set_pending_battle_context_mvp` | Pending BattleContext ownership. |
| `_get_pending_battle_context_mvp` | Pending BattleContext ownership. |
| `_clear_pending_battle_context_mvp` | Pending BattleContext ownership. |

### Battle Side
| Function | Reason |
|---|---|
| `_read_worldmap_battle_context_handoff` | Owns `Engine` meta read/remove for battle context. |
| `_apply_worldmap_battle_context_handoff` | Applies context into battle runtime state. |
| `_setup_worldmap_context_battle_roster` | Converts context rosters into active battle unit state. |
| `_apply_worldmap_context_side_roster` | Applies side-specific context roster and allocation data. |
| `_get_context_hero_ids_for_side` | Reads side roster/governor fields from context. |
| `_register_worldmap_context_hero_contracts` | Registers hero and skill contracts from context. |
| `_build_worldmap_context_hero_registry_entry` | Defines battle-side hero contract shape. |
| `_build_worldmap_context_unique_skill_entry` | Defines battle-side unique skill contract shape. |
| `_configure_worldmap_result_return_button` | Creates return UI and binds result return action. |
| `_refresh_worldmap_result_return_button` | Updates return UI state based on worldmap context. |
| `_has_worldmap_battle_context` | Gates result return availability. |
| `_on_worldmap_result_return_pressed` | Battle return action entrypoint. |
| `_return_to_worldmap_with_result` | Owns result meta write and scene transition to `WorldMap.tscn`. |
| `_build_worldmap_battle_result_payload` | Defines Battle -> WorldMap result dictionary shape. |
| `_sum_alive_deployed_troops_for_side` | Result troop accounting; formula-sensitive. |
| `_calculate_unit_surviving_allocated_troops` | Result troop accounting; formula-sensitive. |
| `_calculate_player_attack_troop_outcome_from_units` | Defines nested troop outcome payload and casualty accounting. |

## Do Not Change Without Dedicated Contract Task
- Field names.
- Required/optional field meaning.
- Scene transition path semantics.
- Defeat/retreat result shape.
- Pending invasion ownership.
- BattleContext ownership.
