# Battle Helper Dependency Dedup Review

## 1. Baseline

- Version: `v0.72-14 Battle Helper Dependency Dedup Review`
- Baseline commit: `b50e90745aeba58a8f95a7090fd3b090103a6691`
- Target helpers: `BattleFormationFacingHelper`, `BattleUnitVisualHelper`.

## 2. Duplicate Responsibility

- `BattleFormationFacingHelper.normalize_facing(facing: String) -> String` owns public facing normalization for `left`, `right`, `up`, and `down`, with invalid input falling back to `right`.
- `BattleUnitVisualHelper` previously repeated that same value normalization privately, using wrapper-supplied facing values.
- Main wrappers supply the established standard values, so both implementations produced the same values in the live path. The duplicate nevertheless carried future drift risk.

## 3. Current Dependency Graph

Before:

```text
battle_web_import_test.gd
├─ BattleFormationFacingHelper
└─ BattleUnitVisualHelper
   └─ private _normalize_facing (duplicate)
```

After:

```text
battle_web_import_test.gd
├─ BattleFormationFacingHelper
└─ BattleUnitVisualHelper
   └─ BattleFormationFacingHelper.normalize_facing
```

`BattleFormationFacingHelper` does not preload or reference `BattleUnitVisualHelper`; the dependency is one-way and has no preload cycle.

## 4. Option A Review

- **Decision: selected.** `BattleFormationFacingHelper.normalize_facing` is public, static, and has the required `String -> String` contract.
- `BattleUnitVisualHelper` now preloads it directly and replaces four private-normalizer calls.
- The helper dependency is responsibility-aligned: portrait-offset calculation consumes a normalized facing value owned by the Formation/Facing helper.
- No main wrapper or existing caller changed.

## 5. Option B Review

- Rejected. Normalizing in every main wrapper would duplicate responsibility, enlarge wrappers, and make the visual helper's public contract less clear while retaining repeated work.

## 6. Option C Review

- Rejected. A third shared value helper for one existing public static normalizer would add a file and dependency layer without additional reuse evidence.

## 7. Option D Review

- Rejected. The direct one-way dependency is safe and smaller than retaining duplicate normalization logic.

## 8. Selected Decision

- Applied Option A.
- Removed `BattleUnitVisualHelper._normalize_facing(...)`.
- Preserved all four public visual-helper function signatures, main wrappers, and calls.
- The existing standard-facing wrapper inputs ensure equivalent valid values and invalid fallback: `left -> left`, `right -> right`, `up -> up`, `down -> down`, invalid -> `right`.
- `Vector2(8, 3)` still yields `Vector2(-8, 3)` for left, `Vector2(8, 3)` for right, and preserves the existing up/down fallback behavior.

## 9. Changed Files

- Modified `scripts/battle/helpers/battle_unit_visual_helper.gd` only to preload the Formation/Facing helper, use its public normalizer, and remove the duplicate private implementation.
- Added this review record.
- Updated `agent/NEXT_TASKS.md`.

## 10. Validation

- Baseline HEAD and clean worktree verified before modification.
- Godot project parse passed.
- `Battle_Land.tscn` headless load passed.
- `BattleFormationFacingHelper` and `BattleUnitVisualHelper` registered successfully.
- `rg` confirmed the private `_normalize_facing` is gone from the visual helper and only the Formation/Facing helper owns the implementation.
- Source review confirmed public helper signatures, main wrappers, callers, Dictionary lookup order, ally/enemy vertical fallback, and `Vector2` expressions are unchanged.
- No Node/resource/Tween/runtime state, WorldMap/result/transition, or protected-file diff was introduced.

## 11. Rollback

- Remove the Formation/Facing preload from `BattleUnitVisualHelper`.
- Restore the private `_normalize_facing` body and its four call sites in that helper.
- Revert this review record and NEXT_TASKS entry.

## 12. Manual QA Requirement

- Required / Not Performed: ally/enemy portrait positions, left/right offsets, up/down fallback, movement/attack/skill portraits, enemy reinforcement portrait, and Battle → WorldMap return.

## 13. Next Recommended Task

`v0.72-15 Battle Helper Dependency Dedup Manual QA Complete Lock`
