# Battle Stage B Audit Complete Lock

## 1. Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Baseline commit: `d6574637f1e83ccd17da10de4b9bf910eda17d82`
- Main battle script: `scripts/battle_web_import_test.gd`
- Main battle scene: `Battle_Land.tscn`
- Function map: `agent/BATTLE_ENGINE_REFACTOR_FUNCTION_MAP.md`

This document is the final documentation lock for the Battle Stage B pure-helper work completed from v0.72-07 through v0.72-16. It records existing locked work and makes no runtime or helper-code change.

## 2. Completed Work Summary

| Version | Completed scope | Lock / QA status |
|---|---|---|
| v0.72-07 | Extracted specialty-skill cutin configuration read-only lookups while preserving wrappers and callers. | Human gameplay QA `PASS`; locked in v0.72-09. |
| v0.72-08 | Extracted facing normalization, axis predicates, and facing arrow text value helpers. | Human gameplay QA `PASS`; locked in v0.72-09. |
| v0.72-10 | Extracted legacy/capacity reinforcement slot-ID bidirectional mapping with the `""` fallback preserved. | Enemy reinforcement QA `PASS`; ally reinforcement is `NOT APPLICABLE`; locked in v0.72-11. |
| v0.72-12 | Extracted four input-only portrait-offset calculations and preserved Node/resource/Tween/runtime visual boundaries. | Human gameplay QA `PASS`; locked in v0.72-13. |
| v0.72-14 | Removed the duplicate Unit Visual private facing normalizer and reused the Formation/Facing public normalizer through a one-way dependency. | Human gameplay QA `PASS`; locked in v0.72-15. |
| v0.72-16 | Audited all remaining Stage B rows after completed domains were excluded. | `Review Only`; no runtime change and no manual QA required. |

Supporting locked Stage B provenance also includes `BattleDebugFormatHelper` (v0.72-05) and `BattleUITextFormatHelper` (v0.72-06). Both preserve their wrappers and have recorded Human gameplay QA `PASS`.

## 3. Final Helper Inventory

| Helper | Responsibility and public static API | Dependency | Complete Lock / Manual QA | Technical debt and future review condition |
|---|---|---|---|---|
| `BattleDebugFormatHelper` | Debug cell formatting: `format_cell(cell)`. | None. | v0.72-05 locked; Human gameplay QA `PASS`. | None open. Reopen only for a debug-format contract regression. |
| `BattleUITextFormatHelper` | UI strings: `get_strategy_status_display_name`, `get_side_display_name`, `get_debug_object_class_name`. | None. | v0.72-06 locked; Human gameplay QA `PASS`. | None open. Reopen only for a concrete UI-text contract or caller-boundary change. |
| `BattleSkillMetadataHelper` | Specialty cutin metadata: `get_cutin_config_value`, `get_cutin_config_float`. | None. | v0.72-07 locked in v0.72-09; Human gameplay QA `PASS`. | None open. Reopen only for a skill metadata/fallback contract change. |
| `BattleFormationFacingHelper` | Facing values: `normalize_facing`, `is_vertical_facing`, `is_horizontal_facing`, `get_facing_arrow_text`. | None. | v0.72-08 locked in v0.72-09; Human gameplay QA `PASS`. | Shared facing-value owner. Reopen only for a real facing contract, fallback, or dependency-drift issue. |
| `BattleReinforcementHelper` | Slot-ID mappings: `get_capacity_slot_id_from_legacy_slot_id`, `get_legacy_slot_id_from_capacity_slot_id`. | None. | v0.72-10 locked in v0.72-11; Human gameplay QA `PASS` (ally entry `NOT APPLICABLE`). | None open. Reopen only for a roster/slot-schema contract regression. |
| `BattleUnitVisualHelper` | Portrait offset values: `get_portrait_template_offset`, `get_ally_portrait_offset_for_facing`, `get_enemy_portrait_offset_for_facing`, `get_facing_aware_portrait_offset`. | One-way preload of `BattleFormationFacingHelper`. | v0.72-12 locked in v0.72-13; dependency dedup locked in v0.72-15; Human gameplay QA `PASS`. | Former private-facing-normalizer duplicate is resolved. Reopen only for portrait value/fallback regression or helper dependency drift. |

## 4. QA Summary

- Skill metadata and Formation/Facing gameplay flows were confirmed `PASS` in the v0.72-09 Human gameplay QA, including cutin/fallback/unique-skill behavior, facing/arrow/movement/attack/AI/formation behavior, and Battle → WorldMap return.
- Reinforcement was confirmed `PASS` in v0.72-11: enemy reinforcement arrival and subsequent turn/AI/battle/result/WorldMap flow worked. Ally reinforcement is `NOT APPLICABLE — 현재 전투 구조에서 미지원`.
- Unit Visual portrait-offset behavior was confirmed `PASS` in v0.72-13, including ally/enemy portraits, horizontal offsets, vertical fallbacks, movement/attack/skill behavior, enemy reinforcement portraits, and Battle → WorldMap return.
- The helper dependency dedup was confirmed `PASS` in v0.72-15 with the same portrait and Battle → WorldMap coverage.
- v0.72-16 is Review Only. It changed no runtime/helper behavior, so no Human gameplay QA was required.

These are summaries of the existing task records; this lock does not infer any new QA result.

## 5. Dependency Graph

```text
battle_web_import_test.gd
├─ BattleDebugFormatHelper
├─ BattleUITextFormatHelper
├─ BattleSkillMetadataHelper
├─ BattleFormationFacingHelper
├─ BattleReinforcementHelper
└─ BattleUnitVisualHelper
   └─ BattleFormationFacingHelper
```

`BattleUnitVisualHelper -> BattleFormationFacingHelper` is the only helper-to-helper dependency. It is one-way: `BattleFormationFacingHelper` does not refer back to `BattleUnitVisualHelper`, so there is no circular dependency.

## 6. Remaining Stage B Classification

`Battle Stage B pure-helper extraction and audit is COMPLETE and LOCKED.`

- Strong pure metadata/value/lookup candidates were extracted or explicitly reviewed.
- Remaining Stage B rows belong to locked helper ownership or to Node, resource, runtime state, registry, roster/deploy, grid/movement, combat formula, AI, WorldMap, result, or transition boundaries.
- Formula-adjacent direction values and low-value one-off calculations remain deferred rather than being extracted speculatively.
- Stage B is not a standing queue for further helper extraction. A one-line move, line-count reduction, or style cleanup is not sufficient reason to reopen it.

## 7. Review Only Findings

v0.72-16 completed normally as `Battle Stage B Remaining Pure Helper Audit — Review Only`.

- No new duplicate responsibility was found.
- No safe cohesive input-only group of one to four functions remained outside locked responsibilities.
- Candidate extensions to UI, Formation/Facing, and Reinforcement helpers were rejected or deferred because they were locked, formula-adjacent, runtime-coupled, or too low-value to justify a new boundary.
- Runtime code, helper files, scenes, and project settings were not changed.

## 8. Resolved Technical Debt

- Technical debt: `BattleUnitVisualHelper` previously contained a private facing-normalization implementation duplicating `BattleFormationFacingHelper.normalize_facing()`.
- Resolution: v0.72-14 removed the private implementation and made `BattleUnitVisualHelper` reuse `BattleFormationFacingHelper.normalize_facing()` through the one-way dependency shown above.
- Verification: parse/headless `PASS`; Human gameplay QA `PASS` in v0.72-15.
- Status: `RESOLVED`.

## 9. Lock Rules

`기존 helper 재사용 우선, 동일 책임의 중복 구현 금지`

- Reuse the established helper that owns a value responsibility before creating a new helper or private duplicate.
- Allow only one-way helper dependencies; inspect both directions before adding a preload or class reference.
- Preserve public helper signatures, battle-script wrappers, callers, fallback values, and return shapes.
- Do not reopen Stage B for speculative cleanup, naming/style alignment, file splitting, line-count reduction, or an isolated one-line extraction without demonstrated reuse value.

## 10. Reopen Conditions

Stage B may be reopened only when there is a concrete reason:

- an actual bug or test failure;
- an explicit functional requirement;
- a newly discovered duplicate responsibility;
- helper dependency drift or a circular-dependency risk;
- a fallback/contract mismatch; or
- a genuinely new call boundary that changes the prior safety assessment.

## 11. Protected Files

The Stage B lock covers these runtime/helper boundaries:

- `scripts/battle_web_import_test.gd` helper-wrapper regions;
- `scripts/battle/helpers/battle_ui_text_format_helper.gd`;
- `scripts/battle/helpers/battle_skill_metadata_helper.gd`;
- `scripts/battle/helpers/battle_formation_facing_helper.gd`;
- `scripts/battle/helpers/battle_reinforcement_helper.gd`;
- `scripts/battle/helpers/battle_unit_visual_helper.gd`.

The following files remain protected from this documentation lock: `scripts/worldmap/worldmap_main.gd`, `Battle_Land.tscn`, `WorldMap.tscn`, and `project.godot`.

## 12. Validation

- Baseline HEAD and a clean worktree were confirmed before this documentation-only work.
- Godot project parse: `PASS` (`--headless --editor --path . --quit`).
- `Battle_Land.tscn` headless load: `PASS`.
- Helper inventory and dependency direction were reviewed; no helper cycle exists.
- Final diff review must contain documentation changes only: no runtime/helper, scene, or project-settings diff.
- Existing Stage B documents show no pending manual QA for their locked extractions; v0.72-16 remains correctly marked as manual QA not required.

## 13. Next Recommended Task

`v0.72-18 Battle Stage C Boundary Review`

The next work is a review, not a pre-authorized extraction. It should inventory Stage C candidates, map Node/runtime controller and state-ownership boundaries, and select at most one small safe domain or conclude Review Only. Initial review candidates are visual controller, UI controller, movement/grid controller, skill execution orchestration, and reinforcement runtime controller boundaries.
