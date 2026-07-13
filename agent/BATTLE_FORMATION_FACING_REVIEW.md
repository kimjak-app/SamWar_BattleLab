# Battle Formation / Facing Pure Helper Review

## 1. Baseline

- Version: `v0.72-08 Battle Formation / Facing Pure Helper Review`
- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Baseline commit: `45639984dc88d1275d680d997f7542d25c3744cb`
- Main script: `scripts/battle_web_import_test.gd`
- Function-map scope: `Formation / Facing`, `Stage B`.

## 2. Search Method

- Reviewed every `Formation / Facing` / `Stage B` row in `agent/BATTLE_ENGINE_REFACTOR_FUNCTION_MAP.md`.
- Searched the specified facing, direction, opposing-side, offset, formation, and arrow-text patterns in the battle script.
- Read each candidate implementation and every direct in-file call site. Checked main constants/member reads, Node and `BattleUnitState` access, collection mutation, grid/path/occupancy, AI/formula/target, visual/animation, and WorldMap coupling.

## 3. Formation / Facing Candidate Table

| Function | Current line | Call locations / count | Inputs -> return | Constants / members | Node / `BattleUnitState` / mutation | Grid / AI / formula / target | Visual / WorldMap | Example | Standalone / group | Decision |
|---|---:|---|---|---|---|---|---|---|---|---|
| `_enter_attack_select_mode` | 2991 | UI action callers | none -> `void` | phase/member state | state and overlay mutation | attack target selection | UI | enters selection | none | Rejected — selection/UI |
| `_reset_unit_group_positions` | 3122 | battle flow callers | none -> `void` | runtime visual state | Node position mutation | movement state | visual | resets groups | none | Rejected — visual mutation |
| `_get_unit_status_summary_color` | 3628 | status UI | `BattleUnitState` -> `Color` | status constants | state reads | status logic | UI | status color | none | Rejected — not formation/facing pure boundary |
| `_get_formation_status_summary_text` | 3642 | status UI | `BattleUnitState` -> `String` | status values | state reads | status logic | UI | formation summary | none | Rejected — `BattleUnitState` dependency |
| `_consume_strategy_status_after_unit_action` | 3650 | action flow | `BattleUnitState` -> `void` | runtime state | state mutation | action logic | UI refresh | consumes status | none | Rejected — mutation |
| `_get_opposing_side` | 4800 | `3432`, `3841`, `3924`, `4770` / 4 | `String` -> `String` | none | none | used by skill targeting | none | `ally -> enemy` | standalone | Deferred — pure, but its live boundary is skill-target selection, not facing |
| `_get_direction_from_positions` | 4810 | `4841` / 1 | `Vector2i`, `Vector2i` -> `String` | facing constants | none | used by attack-angle formula | none | `(0,0)->(1,0) = right` | standalone | Deferred — pure but direct formula dependency |
| `_get_opposite_facing` | 4824 | `4845` / 1 | `String` -> `String` | facing constants | none | used by attack-angle formula | none | `left -> right` | with normalization | Deferred — direct formula dependency |
| `_get_attack_angle_type` | 4838 | directional damage | states -> `String` | angle constants | `BattleUnitState` reads | damage formula | none | back / side / front | none | Rejected — combat formula |
| `_try_direct_move_to_cell` | 5533 | movement UI | `Vector2i` -> `bool` | runtime members | grid/state mutation | path/reachability | visual | movement attempt | none | Rejected — movement/grid |
| `_clear_auto_action_flags` | 5706 | battle flow | none -> `void` | runtime members | state mutation | auto battle | none | clears flags | none | Rejected — mutation |
| `_refresh_formation_slot_guides` | 6053 | UI refresh callers | none -> `void` | guide members | Node access | roster state | UI | guide refresh | none | Rejected — Node/UI |
| `_get_formation_guide_unit_state_for_capacity_slot_id` | 6226 | guide UI | `String` -> `BattleUnitState` | registry members | state access | slot lookup | UI | state/null | none | Rejected — runtime state |
| `_get_formation_guide_unit_type` | 6295 | guide UI | slot/state/hero Dictionary -> `String` | helper/registry reads | `BattleUnitState` reads | visual selection | UI | `infantry` | none | Rejected — state/guide coupling |
| `_get_troop_icon_texture_for_visual_key` | 6331 | formation guide | visual key/state -> `Texture2D` | texture paths/cache | `BattleUnitState`/resource access | none | visual/resource | icon texture | none | Rejected — resource/visual |
| `_clear_pending_move_snapshot` | 6888 | flow callers | none -> `void` | pending state | state mutation | movement | none | clear snapshot | none | Rejected — mutation |
| `_get_capacity_slot_formation_index` | 7716 | `7440` / 1 | `String` -> `int` | none | none | slot setup | none | `ally_main_02 -> 2` | standalone | Deferred — pure but slot-schema parsing outside facing core |
| `_get_ally_*_visual_slots`, `_get_enemy_*_visual_slots` | 8305–8472 | visual initialization | none -> `Dictionary` | Node members | Node references | none | visual | node slot Dictionary | grouped only | Rejected — Node access |
| `_capture_portrait_template_offsets` | 10977 | initialization | `Node2D`, vectors -> `Dictionary` | facing constants | Node access | none | visual | offset map | with portrait group | Rejected — Node access |
| `_get_portrait_template_offset` | 11006 | `8783`, `8799`, `11017`, `11024` / 4 | Dictionary, `Vector2`, `String` -> `Vector2` | normalization | read-only Dictionary | none | portrait layout | left offset | with portrait group | Deferred — pure but requires a separate portrait-layout boundary |
| `_get_ally_portrait_offset_for_facing` | 11013 | group positioning | Dictionary, vector, facing -> `Vector2` | normalization | read-only Dictionary | none | portrait layout | vertical fallback | with portrait group | Deferred — portrait layout group |
| `_get_enemy_portrait_offset_for_facing` | 11020 | group positioning | Dictionary, vector, facing -> `Vector2` | normalization | read-only Dictionary | none | portrait layout | vertical fallback | with portrait group | Deferred — portrait layout group |
| `_get_best_auto_facing_toward_nearest_enemy` | 12543 | auto action | `BattleUnitState` -> `String` | runtime unit list | state reads | enemy AI target decision | none | `right` | none | Rejected — AI |
| `_get_facing_indicator_for_unit` | 13019 | indicator update | `BattleUnitState` -> `Label` | visual registry | Node and state access | none | UI | Label/null | none | Rejected — Node/UI |
| `_update_all_unit_visuals_from_state` | 14223 | state refresh | none -> `void` | unit registry | Node/state mutation | none | visual | updates sprites | none | Rejected — visual mutation |
| `_normalize_facing` | 14406 | 14 direct callers / wrapper calls unchanged | `String` -> `String` | facing string constants only | none | none | none | `invalid -> right` | with axis/arrow group | Selected |
| `_is_vertical_facing` | 14410 | `14525`, `14539` / 2 | `String` -> `bool` | normalization only | none | none | none | `up -> true` | with normalization | Selected |
| `_is_horizontal_facing` | 14414 | `14440`, `14531` / 2 | `String` -> `bool` | normalization only | none | none | none | `left -> true` | with normalization | Selected |
| `_set_unit_facing` | 14418 | movement/facing flow | state, facing -> `void` | none | `BattleUnitState` mutation | movement/AI | visual refresh downstream | writes facing | none | Rejected — state mutation |
| `_get_horizontal_facing_from_step` | 14424 | `14437` / 1 | cells, fallback -> `String` | normalization | none | movement-facing decision | none | x+ -> right | with movement group | Deferred — retain beside movement application |
| `_apply_unit_movement_facing` / `_face_unit_toward_cell` | 14432 / 14445 | movement/AI callers | states/cells -> `void` | runtime | `BattleUnitState` mutation | movement/AI | visual | applies facing | none | Rejected — mutation/AI/visual |
| `_is_token_flip_h_for_facing` | 14528 | `14532` / 1 | facing, side -> `bool` | normalization | none | none | token visual | `right -> true` | token visual group | Deferred — visual-only caller |
| `_get_default_token_texture_for_facing` | 14547 | token visuals | facing, side -> `Texture2D` | texture members | resource/member access | none | visual | texture | none | Rejected — texture/member access |
| `_get_facing_aware_portrait_offset` | 14564 | portrait template/group calls | `Vector2`, facing -> `Vector2` | normalization | none | none | portrait layout | `(8,0), left -> (-8,0)` | portrait group | Deferred — portrait layout boundary |
| `_get_unit_facing` | 14575 | visual/guide callers | `BattleUnitState` -> `String` | facing default | state read | none | visual | null -> right | none | Rejected — `BattleUnitState` input |
| `_get_facing_arrow_text` | 14581 | `13132` / 1 | `String` -> `String` | normalization only | none | none | output consumed by UI | `up -> ↑` | with normalization | Selected |
| `_update_facing_indicators` and position/visibility helpers | 14585 onward | facing UI refresh | state -> `void` | Node members | Node mutation | none | UI/animation | updates arrows | grouped only | Rejected — Node/UI |

## 4. Dependency Groups

- Selected pure facing-value group: `_normalize_facing` -> `_is_vertical_facing`, `_is_horizontal_facing`, `_get_facing_arrow_text`. It uses only the four established facing strings and has no runtime object or collection access.
- Formula-adjacent group: `_get_direction_from_positions` -> `_get_opposite_facing` -> `_get_attack_angle_type` -> directional damage. The first two are pure but were deferred to avoid expanding into a combat-formula boundary.
- Movement/state group: horizontal step, facing setters, face-toward-cell, movement facing, initial/AI refresh. Locked because it changes state, grid behavior, or AI behavior.
- Portrait/token visual group: portrait offsets, token flip/texture, and facing indicators. Locked or deferred because Node/resource/visual layout ownership is outside this helper.

## 5. Selected Extraction

- Added `scripts/battle/helpers/battle_formation_facing_helper.gd` with `class_name BattleFormationFacingHelper` and static functions.
- Extracted: `_normalize_facing`, `_is_vertical_facing`, `_is_horizontal_facing`, and `_get_facing_arrow_text`.
- Each existing main-script function remains a wrapper with the same name, parameters, and return type. Call sites were not edited.
- The helper preserves `left`, `right`, `up`, `down`, the `right` fallback, and all four arrow characters exactly.

## 6. Rejected / Deferred Candidates

- Rejected candidates mutate `BattleUnitState`, grid/runtime state, Nodes, visuals, textures, or participate in movement, target selection, AI, or combat formulas.
- Deferred candidates are independently pure but belong to a different boundary: skill targeting, attack-angle formula, slot-schema parsing, portrait layout, movement application, or token visual behavior.

## 7. Changed Files

- Added `scripts/battle/helpers/battle_formation_facing_helper.gd` and generated `.uid` companion.
- Modified `scripts/battle_web_import_test.gd` only for one preload and four preserved wrapper delegations.
- Added this review document.
- Updated v0.72-06/v0.72-07 QA documentation and `agent/NEXT_TASKS.md` for status consistency.

## 8. Validation

- Godot project parse/editor registration: passed; `BattleFormationFacingHelper` registered.
- `Battle_Land.tscn` headless load: passed.
- Source/diff review: wrapper signatures and all existing caller locations are preserved; no caller was edited.
- Output equivalence examples: invalid facing -> `right`, `up` -> vertical, `left` -> horizontal, `down` -> `↓`.
- No facing mutation, unit/grid/occupancy/pathfinding, AI/target/formula, visual/overlay/animation, WorldMap handoff, result/retreat/scene transition, or protected-file diff was introduced.
- v0.72-09 pre-lock automatic validation: baseline HEAD and clean worktree confirmed; Godot editor/project parse and `Battle_Land.tscn` headless load passed; `BattleFormationFacingHelper` preload/class registration confirmed; protected files remained unchanged.

## 9. Rollback

- Remove the new helper and generated `.uid` companion.
- Remove its preload and restore the four wrapper bodies in `scripts/battle_web_import_test.gd`.
- Revert this review record and the documentation status updates.

## 10. Manual QA

- QA basis: Human gameplay QA performed in the Godot editor against `dd3c292170aa9707ba158de6dae184422f4f84b3`.
- Human gameplay QA: `PASS`.
- Up arrow: `PASS`.
- Down arrow: `PASS`.
- Left arrow: `PASS`.
- Right arrow: `PASS`.
- Fallback facing: `PASS`.
- Invalid/blank display: `PASS` (no blank or invalid arrow observed).
- Move right: `PASS`.
- Move left: `PASS`.
- Move up: `PASS`.
- Move down: `PASS`.
- Arrow/visual consistency: `PASS`.
- Facing persistence: `PASS`.
- Pre-attack facing: `PASS`.
- Post-attack facing: `PASS`.
- Side/back attack behavior: `PASS`.
- Damage/formula regression: `PASS` (no regression observed).
- AI movement facing: `PASS`.
- AI attack facing: `PASS`.
- AI facing persistence: `PASS`.
- AI turn errors: `PASS` (none observed).
- Initial formation: `PASS`.
- Slot placement: `PASS`.
- Portrait/token layout: `PASS`.
- UI layout regression: `PASS` (none observed).
- Facing after skill: `PASS`.
- Arrow after cutin: `PASS`.
- Next action flow: `PASS`.
- Battle → WorldMap return: `PASS`.
- Minor future detail work was noted by QA, but it is not an extraction-caused regression or blocker and is intentionally outside this lock task.

## 11. Next Recommended Task

`v0.72-10 Battle Reinforcement Pure Helper Review`

## Complete Lock

- `v0.72-08 Battle Formation / Facing Pure Helper Extraction` passed parse/headless validation and Human gameplay QA.
- Facing strings and fallback, up/down/left/right classification, and arrow output are preserved.
- Movement/state/grid/occupancy/pathfinding, AI, formula, visual, WorldMap handoff, battle result, and scene transition logic remain unchanged.
- `v0.72-08` is final and locked.
