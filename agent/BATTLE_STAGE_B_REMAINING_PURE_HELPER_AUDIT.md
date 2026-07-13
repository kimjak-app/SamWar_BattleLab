# Battle Stage B Remaining Pure Helper Audit

## 1. Baseline

- Version: `v0.72-16 Battle Stage B Remaining Pure Helper Audit`
- Baseline commit: `bf4db99028e7c54f64a42237303f6d6054a6a950`
- Scope: remaining `Stage B` functions in `scripts/battle_web_import_test.gd`, after completed/locked helper domains were excluded.

## 2. Completed / Locked Domains

- UI text formatting, skill metadata, formation/facing values, reinforcement slot mapping, unit-visual portrait offsets, and helper dependency dedup are locked.
- This audit does not re-extract or redesign those helpers.

## 3. Existing Helper Inventory

| Helper | Class | Public static responsibility | Helper dependency | Reuse / duplicate finding |
|---|---|---|---|---|
| `battle_debug_format_helper.gd` | `BattleDebugFormatHelper` | Cell debug formatting | none | Owns `format_cell` only |
| `battle_ui_text_format_helper.gd` | `BattleUITextFormatHelper` | Status/side text and debug object class text | none | Owns selected UI formatter responsibilities |
| `battle_skill_metadata_helper.gd` | `BattleSkillMetadataHelper` | Specialty cutin config lookup | none | Owns cutin metadata lookup |
| `battle_formation_facing_helper.gd` | `BattleFormationFacingHelper` | Facing normalization, axis predicates, arrow text | none | Shared facing value owner |
| `battle_reinforcement_helper.gd` | `BattleReinforcementHelper` | Legacy/capacity slot mapping | none | Owns bidirectional slot ID mapping |
| `battle_unit_visual_helper.gd` | `BattleUnitVisualHelper` | Pure portrait offset calculations | `BattleFormationFacingHelper` (one-way preload) | Reuses public facing normalization; no duplicate remains |

No helper dependency cycle was found. The only helper-to-helper preload is `BattleUnitVisualHelper -> BattleFormationFacingHelper`.

## 4. Search Method

- Enumerated all 145 function-map `Stage B` rows, then excluded functions already extracted/locked or explicitly outside the pure boundary.
- Searched the requested normalization, resolve, key/id/type/side/slot, label/text/name/color/icon/metadata, range/distance/offset/duration/cost/limit/capacity/index/order/priority, predicate, format/build/collect/map/convert/clamp/sanitize patterns in the battle script and all helper files.
- For candidate classes, inspected direct callers and checked member/Node/`BattleUnitState`/registry/resource/Tween/collection mutation/formula/AI/WorldMap coupling, fallbacks, and existing-helper overlap.

## 5. Remaining Stage B Candidate Table

| Candidate / group | Domain | Current line(s) | Direct callers | Inputs -> return | Boundary findings | Existing helper / reuse | Decision |
|---|---|---:|---|---|---|---|---|
| `_allows_sample_roster_crash_guard` | UI | 1690 | startup context | runtime values -> `bool` | startup/runtime guard | UI helper not applicable | Rejected — runtime guard |
| `_get_existing_resource_path` | Path | 1796 | WorldMap context build | path -> `String` | `ResourceLoader.exists` | none | Rejected — resource access |
| selection/preview/cancel/auto unique-skill Stage B rows | Skill | 3214–4084 | skill flow | states/data -> flow values | target, timer, phase, state | skill helper intentionally metadata-only | Rejected — execution/target/phase |
| status display color/text wrappers | UI / status | 3607–3648 | UI display | status/state -> `Color`/`String` | some pure, but share locked UI formatter/status chain | `BattleUITextFormatHelper` potential extension | Deferred — locked domain; no re-design in audit |
| unique-skill range/target/value/cooldown/buff rows | Skill | 3801–4961 | combat/AI/turn | states/data -> mixed | range, targeting, formula, runtime maps | skill helper metadata-only | Rejected — combat/runtime boundary |
| specialty cutin/video/camera/texture rows | Skill visual | 4224–4683 | cutin flow | mixed | Node/resource/video/camera/Tween | skill metadata helper owns only config | Rejected — visual/resource execution |
| `_get_direction_from_positions`, `_get_opposite_facing` | Formation | 4810–4835 | attack-angle calculation | cells/facing -> `String` | pure but direct combat-angle dependency | `BattleFormationFacingHelper` could be extended | Deferred — locked formation helper and formula-adjacent |
| `_get_attack_angle_type` | Formation/combat | 4838 | directional damage | states -> `String` | `BattleUnitState` and formula | none | Rejected — combat formula |
| tactical mode/input/panel Stage B rows | Interaction | 5242–5717 | UI flow | members -> bool/void | Node/input/runtime flags | none | Rejected — runtime/UI mutation |
| formation guide, cooldown guide, icon texture rows | Formation/UI | 6060–6409 | guide refresh | states/Nodes -> mixed | Node, state, texture paths | locked formation/UI helpers | Rejected — Node/state/resource |
| `_get_unit_action_status_text`, hero context exclusion text | UI | 6765–7626 | UI/context | state/Dictionary -> String | state/WorldMap context | UI helper potential extension | Deferred — locked UI/contract boundary |
| `_get_capacity_slot_formation_index` | Formation | 7716 | slot metadata build | slot -> `int` | input-only but slot-schema parsing | formation helper potential extension | Deferred — locked formation domain; one-line extraction value low |
| capacity metadata/active/deployed/state availability/arrival rows | Reinforcement | 7729–8266 | roster/deploy/visual | members/states -> mixed | runtime registry, spawn, turn, Node | reinforcement helper owns only ID mapping | Rejected — runtime roster/deploy boundary |
| visual-slot dictionaries and reinforce visual updates | Visual | 8306–8450, 14223–14288 | visual refresh | Nodes/states -> mixed | visual registry and Node mutation | unit visual helper intentionally value-only | Rejected — Node/runtime visual boundary |
| toast/banner/texture/shader/debug rows | UI | 9178–9461 | UI presentation | Node/Texture -> mixed | Node/Texture/shader/resource | UI helper potential extension | Rejected — presentation/resource boundary |
| `_get_arrow_curve_midpoint` | Movement effect | 9641 | arrow volley | vectors -> `Vector2` | pure-looking but effect trajectory owner | no existing value helper | Deferred — effect-specific one-off, extraction value low |
| `_apply_group_offset`, group base positions | Movement/visual | 10108, 11467–11546 | movement/visual | state/Node -> mixed | position mutation, state/Node | none | Rejected — application/layout |
| grid cell/snap/validity rows | Movement/grid | 11555–11581, 13623 | movement selection | controller/members -> cells | grid controller/runtime selection | debug helper only formats cells | Rejected — grid/runtime dependency |
| auto-facing/action availability rows | Formation/AI | 12550–12809 | auto battle | state -> mixed | AI/turn/state | formation helper value-only | Rejected — AI/runtime |
| facing normalize/axis/arrow, portrait-offset rows | Formation/visual | 14399–14568 | wrappers/visual | value inputs -> mixed | already extracted and locked | formation/unit visual helpers | Existing Helper Reuse — excluded |
| token flip / default texture / unit facing / indicator rows | Visual/facing | 14529–14616 | token/indicator apply | values/state -> mixed | texture, state, Node | formation/unit visual helpers | Deferred/Rejected — locked or visual application |
| toast-facing suppression | Skill/UI | 14696 | cutin/toast | runtime -> void | member state/UI | none | Rejected — runtime mutation |

All other Stage B rows fall into the same audited categories: skill execution/targeting, state/roster/deploy, Node/visual/resource presentation, grid/movement, combat formula/AI, or already locked helper ownership. No additional input-only cohesive 1–4 function group remains outside those boundaries.

## 6. Duplicate Responsibility Findings

- The prior duplicate facing normalization is resolved: `BattleUnitVisualHelper` reuses `BattleFormationFacingHelper.normalize_facing()`.
- Existing UI text, skill metadata, reinforcement mapping, and portrait offset responsibilities remain owned by their corresponding helpers; no new duplicate implementation was found.
- Candidate extensions to locked helpers (`_get_status_display_color`, direction values, capacity formation index) were deliberately not made during this audit.

## 7. Existing Helper Reuse Findings

- `BattleFormationFacingHelper`: potential future home for direction/opposite-facing and capacity-index value reviews, but current callers are formula-adjacent or the functions are low-value one-offs.
- `BattleUITextFormatHelper`: potential future home for status/context text values, but the remaining callers are state/context coupled.
- No safe consumer needed a new one-way helper dependency in this audit.

## 8. Rejected Candidates

- Resource/texture loaders, Node/visual application, Tween/video/camera/effects, state/registry/roster helpers, selection/phase/turn functions, grid/controller functions, AI, combat formulas, WorldMap contracts, and result/transition paths.

## 9. Deferred Candidates

- Status display color/text: locked UI responsibility.
- Direction/opposite-facing and slot formation index: existing Formation/Facing responsibility but formula-adjacent or too small to justify changing the locked helper boundary.
- Arrow curve midpoint: effect-specific isolated calculation.

## 10. Selected Decision

`v0.72-16 Battle Stage B Remaining Pure Helper Audit — Review Only`

- No code or helper file changed.
- The audit found no strong remaining pure group that is both outside the completed locks and worth a new helper/dependency boundary.

## 11. Changed Files

- Added this audit record.
- Updated `agent/NEXT_TASKS.md`.

## 12. Validation

- Baseline HEAD and clean worktree verified before documentation changes.
- Review Only: runtime code, helpers, scenes, and project settings have no diff.
- Existing helper inventory and dependency graph were checked; no cycle was found.

## 13. Rollback

- Revert this audit record and the prepended NEXT_TASKS entry. No runtime file is involved.

## 14. Manual QA Requirement

- Not required: this is Review Only with no runtime/helper change.

## 15. Next Recommended Task

`v0.72-17 Battle Stage B Audit Complete Lock`

## 16. Complete Lock Reference

- v0.72-16 `Review Only` is a normal completed audit: no runtime/helper change was made, and manual QA is not required.
- The final Stage B completion and lock record is `agent/BATTLE_STAGE_B_COMPLETE_LOCK.md`.
- Remaining candidate classifications, deferred boundaries, and the existing-helper reuse findings in this audit are locked by that final record unless a documented reopen condition is met.
