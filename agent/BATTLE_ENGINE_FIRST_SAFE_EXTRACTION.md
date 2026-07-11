# Battle Engine First Safe Extraction

## 1. Baseline

- Baseline version: `v0.72-04 Battle Engine Function Map & Refactor Plan`
- Baseline commit: `51a415f82e6d15594315a0ec02307b7173da3a29`
- Target file: `scripts/battle_web_import_test.gd`
- Pre-change line count: 14,810
- Pre-change function count: 791

## 2. Candidate Review

| Function | Original location | Call locations | Inputs | Return | Member variables | Node access | State / collection mutation | Gameplay formula | Handoff contract | Decision |
|---|---:|---|---|---|---|---|---|---|---|---|
| `_format_cell` | `battle_web_import_test.gd:14226` | `:2308`, `:5528`, `:12731` | `cell: Vector2i` | `String` formatted as `(%d,%d)` | None | None | None | No | No | Selected |
| `_get_toast_texture_debug_name` | `battle_web_import_test.gd:9453` | `:9201`, `:9276` | `texture: Texture2D` | `String` resource name/path | None | None | None | No | No | Rejected: reads a resource object's `resource_path` and has an object-string fallback; retain it pending a dedicated resource-formatting review. |
| `_format_troop_label` | `battle_web_import_test.gd:10460` | No in-file caller found | `value: int` | `String` | None | None | None | No | No | Rejected: pure, but no caller is present. Moving an unused function would not validate a live extraction path. |

`_format_cell` was rechecked against the required safety criteria: it uses only its typed input; reads or writes no battle member; accesses no node, `Engine`, `SceneTree`, or `ResourceLoader`; mutates no state, Dictionary, or Array; uses no random, time, delta, or frame data; and always returns the same string for the same `Vector2i` input.

## 3. Selected Extraction

- Selected function: `_format_cell(cell: Vector2i) -> String`
- Reason: limited, traceable use in debug/log string construction only; exact pure formatting behavior with no gameplay or runtime dependencies.
- New helper: `scripts/battle/helpers/battle_debug_format_helper.gd`
- Helper API: `BattleDebugFormatHelper.format_cell(cell: Vector2i) -> String`
- Wrapper: the existing `_format_cell` name, parameter, and `String` return type remain in `battle_web_import_test.gd`; its body delegates directly to the static helper.
- Contract preservation: all existing callers remain unchanged, and the returned format is exactly `"(%d,%d)" % [cell.x, cell.y]`.

## 4. Rejected Candidates

- `_get_toast_texture_debug_name`: resource-object inspection and `str(texture)` fallback are safe-looking but less constrained than a typed value formatter. It is intentionally deferred.
- `_format_troop_label`: no current call site was found, so it does not provide a live wrapper-path validation target.
- All WorldMap handoff, result, transition, AI, formula, turn/phase, movement/range, selection, state mutation, UI, animation, camera, effect, HP bar, portrait/resource loading, and skill execution functions remain excluded by scope.

## 5. Change Summary

- Added: `scripts/battle/helpers/battle_debug_format_helper.gd`
- Added: this investigation record.
- Modified: `scripts/battle_web_import_test.gd`
- Extracted functions: 1
- Gameplay change: none.
- Schema change: none.
- Formula change: none.
- Scene change: none.
- WorldMap handoff change: none.

## 6. Validation

- Baseline verified before modification: `main`, local HEAD, and `origin/main` all matched `51a415f82e6d15594315a0ec02307b7173da3a29`; worktree was clean.
- Static call review: all three existing `_format_cell` call sites were retained without edits.
- Return review: wrapper signature remains `func _format_cell(cell: Vector2i) -> String`; helper retains the exact prior format expression.
- Godot headless editor/project-load verification: passed with Godot `4.6.2`; the scan registered `BattleDebugFormatHelper` and exited `0` with no parser errors.
- Godot headless battle-scene load: `Battle_Land.tscn` exited `0`; the sample battle initialized and reported its normal identity, grid, roster, adapter, and toast diagnostics.
- Automated tests: no dedicated automated test command was found in the project search; the available project-load and battle-scene headless checks were run instead.
- Required diff review: passed after validation; only the helper, preserved wrapper, and this record changed.
- Human gameplay QA: PASS.
- Human QA confirmed:
  - `WorldMap.tscn` startup 정상
  - WorldMap -> `Battle_Land.tscn` 진입 정상
  - 전투 화면 및 기본 동작 정상
  - Battle -> `WorldMap.tscn` 복귀 정상
  - parser/helper/old-path 관련 오류 없음
  - 기존 cell debug formatting 이상 없음

## 7. Rollback

If a problem is found, revert only these files:

- `scripts/battle/helpers/battle_debug_format_helper.gd` (remove the added helper)
- `scripts/battle_web_import_test.gd` (restore the original one-line `_format_cell` body)
- `agent/BATTLE_ENGINE_FIRST_SAFE_EXTRACTION.md` (remove this record)

No scene, project, gameplay schema, payload, formula, or WorldMap handoff file is part of this extraction.

## 8. Complete Lock

- Human QA: PASS
- Extraction helper: `scripts/battle/helpers/battle_debug_format_helper.gd`
- Godot UID companion: `scripts/battle/helpers/battle_debug_format_helper.gd.uid`
- Extracted function: `_format_cell(cell: Vector2i) -> String`
- Existing wrapper and all three call sites preserved.
- WorldMap handoff unchanged.
- Battle result contract unchanged.
- Scene transition unchanged.
- Gameplay schema unchanged.
- Formula unchanged.
- v0.72-05 implementation commit: `db3ecc2e4233c17a5efb701026cc8621b92369c7`
