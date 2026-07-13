# Battle Reinforcement Pure Helper Review

## 1. Baseline

- Version: `v0.72-10 Battle Reinforcement Pure Helper Review`
- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Baseline commit: `e74149d24d85af8c63d36affd15e8ea3cee52851`
- Target: `scripts/battle_web_import_test.gd`
- Function-map scope: `Reinforcement`, `Stage B`.

## 2. Search Method

- Reviewed every `Reinforcement` / `Stage B` row in `agent/BATTLE_ENGINE_REFACTOR_FUNCTION_MAP.md`.
- Ran the requested reinforcement, reserve, wave, spawn, slot, capacity, roster, arrival, label, name, index, and side patterns against the battle script.
- Read each candidate implementation and all direct in-file callers, checking constants/members, Node and `BattleUnitState` access, collection read/mutation, spawn/roster/grid/turn/wave, WorldMap/schema, and AI/formula coupling.

## 3. Reinforcement Candidate Table

| Function | Current line | Direct call locations / count | Inputs -> return | Const / member / collection access | Node / `BattleUnitState` / mutation | Spawn / roster / grid / turn / wave | WorldMap / schema / AI / formula | Example | Group | Decision |
|---|---:|---|---|---|---|---|---|---|---|---|
| `_get_hero_id_for_unit_state` | 7491 | `2699`, `3157`, `4229`, and runtime callers / 12 | `BattleUnitState` -> `String` | metadata registry, test roster | state access | roster identity | WorldMap hero registry path | hero ID | Roster/runtime | Rejected — state and hero-contract coupling |
| `_get_capacity_slot_id_for_legacy_slot_id` | 7722 | `7854`, `8496` / 2 | `String` -> `String` | read-only const Dictionary | none | none | none | `ally_main -> ally_main_01` | Pure metadata | Selected |
| `_get_legacy_slot_id_for_capacity_slot_id` | 7726 | `7440`, `8264` / 2 | `String` -> `String` | read-only const Dictionary | none | none | none | `ally_main_01 -> ally_main` | Pure metadata | Selected |
| `_get_capacity_slot_metadata` | 7730 | metadata/guide/deploy callers / 11 | `String` -> `Dictionary` | runtime metadata registry | returns live runtime Dictionary | roster/deploy data | payload contract | slot metadata | Roster/runtime | Rejected — runtime member registry and mutable returned Dictionary |
| `_is_capacity_slot_active` | 7746 | adapter/visual callers / 4 | `String` -> `bool` | runtime metadata registry | none | deployed/actor eligibility | none | active flag | Roster/runtime | Rejected — runtime eligibility state |
| `_is_capacity_slot_deployed` | 7752 | adapter/visual callers / 5 | `String` -> `bool` | runtime metadata registry | none | deployment/occupancy eligibility | none | deployed flag | Roster/runtime | Rejected — runtime deployment state |
| `_get_active_capacity_slots_for_side` | 7758 | roster diagnostics / 1 | `String` -> `Array[String]` | slot constant and runtime registry | creates array, no input mutation | active roster | none | active slot list | Roster/runtime | Rejected — reads runtime roster state |
| `_get_deployed_capacity_slots_for_side` | 7767 | roster diagnostics / 1 | `String` -> `Array[String]` | slot constant and runtime registry | creates array, no input mutation | deployed roster/occupancy | none | deployed slot list | Roster/runtime | Rejected — reads runtime deployment state |
| `_get_unit_state_for_capacity_slot_id` | 7839 | battle/guide callers / 5 | `String` -> `BattleUnitState` | runtime map | `BattleUnitState` return | roster | none | state/null | Roster/runtime | Rejected — runtime state object |
| `_get_capacity_slot_id_for_unit_state` | 7846 | AI/visual/runtime callers / 20+ | `BattleUnitState` -> `String` | slot constants and state | state access | roster identity | AI consumers | capacity slot | Roster/runtime | Rejected — `BattleUnitState` coupling |
| `_is_unit_state_deployed_by_capacity_slot` | 7960 | actor/visual/deploy callers / 8 | `BattleUnitState` -> `bool` | runtime metadata | state access | occupancy/deployment | AI consumers | deployed eligibility | Roster/runtime | Rejected — state/grid eligibility |
| `_is_unit_state_active_by_capacity_slot` | 7969 | actor/AI callers / 5 | `BattleUnitState` -> `bool` | runtime metadata | state access | active roster | AI consumers | active eligibility | Roster/runtime | Rejected — state/AI eligibility |
| `_is_unit_state_available_for_battle_slot` | 7978 | combat/AI/visual callers / 14+ | `BattleUnitState` -> `bool` | runtime metadata | state `is_alive` read | actor/target/occupied paths | AI/combat consumers | available bool | Roster/runtime | Rejected — battle eligibility and target/grid coupling |
| `_set_unit_deployed` | 7993 | city reinforcement deploy / 1 | state, bool -> `void` | metadata registry | metadata mutation | deployment/arrival | none | writes deployed flag | Spawn/placement | Rejected — mutation |
| `_get_city_reinforcement_arrival_round` | 8006 | deploy log / 1 | `String` -> `int` | runtime metadata | none | arrival-turn data | none | `3` | Turn/wave/arrival | Deferred — runtime arrival metadata; retain beside readiness/deploy flow |
| `_is_city_reinforcement_ready_to_arrive` | 8010 | deploy/arrival flow / 3 | `String` -> `bool` | runtime metadata and `battle_round` | none | arrival/turn flow | none | ready bool | Turn/wave/arrival | Rejected — reads current battle round and controls arrival |
| `_deploy_city_reinforcement_unit` and arrival/wave helpers | 8024 onward | turn flow | states -> `bool`/`void` | runtime members | state/metadata mutation | spawn, placement, countdown/wave | result guard | deploys unit | Spawn/placement | Rejected — spawn/runtime/turn flow |
| `_get_unit_visual_slot_for_capacity_slot_id` | 8261 | `8496` / 1 | `String` -> `UnitVisualSlot` | visual-slot member registry | visual object/resource path | placement visual | none | visual slot/null | Spawn/placement | Rejected — visual/runtime object access |
| `_update_*_reinforce_*_visuals_from_state` | 14275–14288 | visual refresh | none -> `void` | unit state members | Node/UI mutation | post-arrival visual refresh | none | visual update | Spawn/placement | Rejected — Node/visual mutation |

## 4. Dependency Groups

- **Pure Metadata / Lookup Group:** the two legacy/capacity slot ID mapping functions. They read only wrapper-supplied immutable mapping values and return a `String` fallback of `""`.
- **Spawn / Placement Group:** deploy city reinforcement, unit visual slot lookup, and reinforce visual updates. Locked because they create/apply runtime or visual placement.
- **Roster / Runtime State Group:** hero/state/metadata resolution, active/deployed predicates, and state availability. Locked because they read or mutate live registries and `BattleUnitState`.
- **Turn / Wave / Arrival Group:** arrival-round and readiness functions plus city reinforcement deployment flow. Locked/deferred because they are tied to live round/countdown and deployment behavior.
- **WorldMap Contract Group:** hero registry and metadata paths used by the battle context. No Stage D contract function was selected or moved.

## 5. Selected Extraction

- Added `scripts/battle/helpers/battle_reinforcement_helper.gd` with `class_name BattleReinforcementHelper` and static functions.
- Extracted only:
  - `_get_capacity_slot_id_for_legacy_slot_id(legacy_slot_id: String) -> String`
  - `_get_legacy_slot_id_for_capacity_slot_id(capacity_slot_id: String) -> String`
- Existing wrappers retain their names, arguments, and return types. Existing callers were not edited.
- The wrappers pass the existing mapping constants into the helper; the helper does not duplicate battle-main mapping data.
- Exact fallback remains `""`; mapping values, Dictionary shape, and lookup order are unchanged.

## 6. Rejected Candidates

- Hero/state/metadata, active/deployed, availability, set-deployed, deploy/spawn, visual-slot, and reinforce visual functions are rejected because they access or mutate runtime state, `BattleUnitState`, placement, grid/occupancy, Node, or visual resources.

## 7. Deferred Candidates

- `_get_city_reinforcement_arrival_round` is read-only but remains with the arrival/readiness/deployment flow because it reads live metadata and represents turn/wave behavior.

## 8. Changed Files

- Added `scripts/battle/helpers/battle_reinforcement_helper.gd` and its generated `.uid` companion.
- Modified `scripts/battle_web_import_test.gd` only for the helper preload and two preserved wrapper delegations.
- Added this review record and updated `agent/NEXT_TASKS.md`.

## 9. Validation

- Baseline HEAD and clean worktree verified before modification.
- Godot editor/project parse passed.
- `Battle_Land.tscn` headless load passed.
- `BattleReinforcementHelper` class/preload registration passed.
- Wrapper signatures, direct callers, exact mapping lookups, and `""` fallback were preserved by source review.
- No spawn/despawn, roster mutation, `BattleUnitState`, grid/occupancy, turn/phase/wave/countdown, AI/formula, WorldMap, result/retreat/transition, or save/load schema diff was introduced.
- No changes in `scripts/worldmap/worldmap_main.gd`, `WorldMap.tscn`, `Battle_Land.tscn`, or `project.godot`.

## 10. Rollback

- Remove the new helper and generated `.uid` companion.
- Remove its preload and restore the two original wrapper bodies in `scripts/battle_web_import_test.gd`.
- Revert this review record and the prepended `NEXT_TASKS.md` entry.

## 11. Manual QA Required

- Required / Not Performed: ally/enemy reinforcement entry, arrival turn, slot ordering, reserve roster, spawn positions, grid non-overlap, post-reinforcement turn/AI, result handling, and Battle → WorldMap return.

## 12. Next Recommended Task

`v0.72-11 Battle Unit Visual / Animation Pure Helper Review`
