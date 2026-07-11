# Battle UI Text / Formatter Helper Extraction

## 1. Baseline

- Version: `v0.72-05 Battle Engine First Safe Extraction Complete Lock`
- Commit: `80f8f35f05b416865cda96a4f73e9a1607dcaa4e`
- Branch: `main`
- Target file: `scripts/battle_web_import_test.gd`
- Pre-change line count: `12,979`
- Pre-change function count: `791`
- Previous helper extraction state: `scripts/battle/helpers/battle_debug_format_helper.gd` already existed and owned `_format_cell(cell: Vector2i) -> String`.

## 2. Candidate Search Method

- Function-map scope checked: `UI / HUD / Text Formatter` and nearby Stage B entries in `agent/BATTLE_ENGINE_REFACTOR_FUNCTION_MAP.md`.
- Search patterns used: `_format_`, `_build_*text`, `_build_*label`, `_get_*label`, `_get_*name`, `_describe_`, `_make_*text`, `_resolve_*name`, plus the named reviews `_format_troop_label` and `_get_toast_texture_debug_name`.
- Live call site check: `rg -n` against `scripts/battle_web_import_test.gd` for each candidate name, then direct source inspection around the reported lines.
- Safety checks used: verified member-variable access, node access, `Engine`/`SceneTree`/`ResourceLoader` access, collection mutation, state mutation, formula coupling, and WorldMap handoff coupling by reading the implementation and its callers.

## 3. Candidate Review

| Function | Original line | Estimated end line | Call sites | Inputs | Return | Member access | Node access | Resource access | Dict/Array mutation | State mutation | Formula / handoff | Example output | Decision |
|---|---:|---:|---|---|---|---|---|---|---|---|---|---|---|
| `_get_strategy_status_display_name` | 3518 | 3526 | `3497` | `status_id: String` | `String` | No | No | No | No | No | No | `confusion -> 혼란`, `shake -> 동요`, fallback -> `상태` | Selected |
| `_get_side_display_name` | 4811 | 4814 | `4736` | `side: String` | `String` | No | No | No | No | No | No | `enemy -> 적군`, otherwise `아군` | Selected |
| `_get_debug_object_class_name` | 4380 | 4383 | `2433`, `4281`, `4293`, `4301`, `4321`, `4353`, `4360`, `4426` | `value: Object` | `String` | No | No | No | No | No | No | `null -> "null"`, otherwise `value.get_class()` | Selected |
| `_get_facing_arrow_text` | 14598 | 14609 | `13139` | `facing: String` | `String` | No | No | No | No | No | No | Returns arrows, but depends on `_normalize_facing`, so extracting it alone would drag in a second helper boundary. | Rejected |
| `_get_strategy_status_icon_text` | 3631 | 3632 | `6038` | `unit_state: BattleUnitState` | `String` | No battle-main member access, but it is a pass-through to `_get_unit_status_badge_text` | No | No | No | Depends on battle-state formatter chain | No | Badge text is produced elsewhere | Rejected |
| `_get_strategy_status_summary_text` | 3635 | 3636 | None found | `unit_state: BattleUnitState` | `String` | No battle-main member access, but it is a pass-through to `_get_unit_status_summary_text` | No | No | No | Depends on unit-status summary chain | No | Summary text is produced elsewhere | Rejected |
| `_format_troop_label` | 10460 | 10461 | None found | `value: int` | `String` | No | No | No | No | No | No | `"%d / %d" % [value, value]` | Rejected |
| `_get_toast_texture_debug_name` | 9453 | 9459 | `9201`, `9276` | `texture: Texture2D` | `String` | No | No | Reads `resource_path`; fallback uses `str(texture)` | No | No | No | `null -> "null"`, resource path file name, or object string fallback | Rejected |
| `_get_selected_ally_display_name` | 11582 | 11585 | `2962`, `3110`, `5478`, `13265` | none beyond implicit state | `String` | Yes, reads `active_unit_state` | No | No | No | Reads battle-main member state | No | Returns `active_unit_state.display_name` or `""` | Rejected |

## 4. Selected Extraction

- Selected functions:
  - `_get_strategy_status_display_name(status_id: String) -> String`
  - `_get_side_display_name(side: String) -> String`
  - `_get_debug_object_class_name(value: Object) -> String`
- Helper API:
  - `BattleUITextFormatHelper.format_strategy_status_display_name(status_id: String) -> String`
  - `BattleUITextFormatHelper.format_side_display_name(side: String) -> String`
  - `BattleUITextFormatHelper.get_debug_object_class_name(value: Object) -> String`
- New helper path: `scripts/battle/helpers/battle_ui_text_format_helper.gd`
- Wrapper maintenance: each existing function name, argument list, and return type remained unchanged in `scripts/battle_web_import_test.gd`; only the body now delegates to the new helper.
- Call sites unchanged: all existing live call sites remain exactly where they were.
- Output equality: each wrapper returns the same string as before, with no format-string changes.

## 5. Rejected Candidates

- `_get_facing_arrow_text`: safe-looking formatter, but it depends on `_normalize_facing`. Moving it cleanly would require a second extraction boundary, which is beyond this step.
- `_get_strategy_status_icon_text`: pass-through wrapper to battle-state badge logic, not an independent formatter boundary.
- `_get_strategy_status_summary_text`: pass-through wrapper to battle-state summary logic, not an independent formatter boundary.
- `_format_troop_label`: pure, but there is no live call site, so it does not validate the wrapper path.
- `_get_toast_texture_debug_name`: texture/resource fallback makes it more coupled than the selected pure string lookups.
- `_get_selected_ally_display_name`: reads `active_unit_state`, so it is not input-only.

## 6. Changed Files

- Added:
  - `scripts/battle/helpers/battle_ui_text_format_helper.gd`
  - `scripts/battle/helpers/battle_ui_text_format_helper.gd.uid`
  - `agent/BATTLE_UI_TEXT_FORMATTER_EXTRACTION.md`
- Modified:
  - `scripts/battle_web_import_test.gd`
- UID companion: retained as a normal Godot resource companion file.
- Extracted function count: 3
- Wrapper count: 3

## 7. Validation

- Godot parse: passed.
- Helper registration: `BattleUITextFormatHelper` registered during `--editor --quit`.
- Battle scene headless load: passed for `Battle_Land.tscn`.
- Call site count: verified by `rg -n`; existing live callers were unchanged.
- Signature comparison: passed; all three wrappers kept the original signature and return type.
- Output-expression comparison: passed by source review; the wrappers now delegate to helpers that preserve the exact prior outputs.
- Forbidden diff check: passed; no diff was introduced in `scripts/worldmap/worldmap_main.gd`, `WorldMap.tscn`, `Battle_Land.tscn`, or `project.godot`.
- Manual QA required: yes. Human gameplay QA has not been performed in this turn.

## 8. Rollback

- Remove `scripts/battle/helpers/battle_ui_text_format_helper.gd`.
- Remove `scripts/battle/helpers/battle_ui_text_format_helper.gd.uid` if Godot generated it.
- Restore the original wrapper bodies in `scripts/battle_web_import_test.gd`.
- Remove the `BattleUITextFormatHelper` preload constant from `scripts/battle_web_import_test.gd`.
- Remove this document if the extraction is reverted.
- No WorldMap handoff, battle result, scene transition, formula, or schema file is affected by this rollback.
