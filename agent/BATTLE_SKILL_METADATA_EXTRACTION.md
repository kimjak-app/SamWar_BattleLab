# Battle Skill Metadata / Description Helper Extraction

## 1. Baseline

- Version: `v0.72-07 Battle Skill Metadata / Description Helper Extraction`
- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Requested baseline commit: `bd09d27bff9159917efb4556a1775a873c1e9e8b`
- Target script: `scripts/battle_web_import_test.gd`
- Function-map review scope: `Unique / Specialty Skill`, `Stage B`.

## 2. Candidate Search Method

- Reviewed the `Unique / Specialty Skill` Stage B rows in `agent/BATTLE_ENGINE_REFACTOR_FUNCTION_MAP.md`.
- Searched the battle script for `_get_*skill*name`, `_get_*skill*description`, `_build_*skill*description`, `_get_*skill*label`, `_get_*skill*type`, `_get_*skill*metadata`, `_resolve_*skill*name`, `_resolve_*skill*description`, `_describe_*skill`, `_format_*skill`, `_get_*target_mode`, `_get_*range_type`, `_get_*icon_key`, and `_get_*visual_key`.
- Inspected every relevant nearby skill metadata/description/display candidate and each in-file call site with `rg -n` and direct source review.
- For each candidate, checked battle-main member reads, Node/Engine/SceneTree/ResourceLoader access, Dictionary/Array and `BattleUnitState` mutation, formula/result coupling, and WorldMap handoff coupling.

## 3. Candidate Review Table

| Function | Original line | Call locations / count | Inputs / return | Main member access | Node / Engine / SceneTree / ResourceLoader | Dictionary / Array or `BattleUnitState` mutation | Formula / result / handoff coupling | Example output | Decision |
|---|---:|---|---|---|---|---|---|---|---|
| `_resolve_worldmap_context_skill_name` | 1784 | `1756` / 1 | `hero_data`, `sample_skill_entry` -> `String` | No | No | No | WorldMap context construction | `"이순신 전법"` or registry name | Rejected — WorldMap handoff scope |
| `_get_default_visual_key_for_worldmap_hero` | 1829 | no in-file call / 0 | `hero_data` -> `String` | No | No | No | WorldMap hero visual preparation | `"korea_archer"` | Rejected — WorldMap scope and not a battle skill metadata boundary |
| `_get_target_mode_for_worldmap_skill_effect` | 1850 | `1767` / 1 | `effect_type` -> `String` | No | No | No | WorldMap context skill entry | `cannon_aoe -> enemy_auto_aoe` | Rejected — WorldMap handoff scope |
| `_get_unique_skill_for_unit` | 3154 | `3184`, `3209`, `6250` / 3 | `BattleUnitState` -> `Dictionary` | Yes: WorldMap registry and skill registry | No | No | WorldMap registry fallback | skill entry Dictionary | Rejected — WorldMap handoff registry coupling |
| `_should_unique_skill_resolve_without_manual_target` | 3251 | `3246` / 1 | `skill_data` -> `bool` | No | No | No | Controls target-selection resolution | `ally_attack_buff -> true` | Rejected — target-selection behavior |
| `_get_unique_skill_range` | 3796 | `3828`, `3843` / 2 | `caster_state`, `skill_data` -> `int` | Yes: range constants | No | No | Range limitation used by target selection | `cannon_aoe -> min(range, 3)` | Rejected — range/target judgment |
| `_get_specialty_skill_video_cutin_hero_id` | 4224 | `4110` / 1 | `caster_state`, `skill_data` -> `String` | Yes: cutin config registry and hero-id resolver | No | No | Specialty video cutin path | `yi_sunsin` or `""` | Rejected — `BattleUnitState` and cutin flow coupling |
| `_get_specialty_skill_cutin_config` | 4233 | `4118`, `8880` / 2 | `hero_id` -> `Dictionary` | Yes: read-only cutin config constants | No | No | Display configuration only; no gameplay/result/handoff | Yi Sun-sin cutin config Dictionary | Selected |
| `_get_specialty_skill_cutin_config_float` | 4237 | `8895`–`8900`, `8912`–`8915` / 10 | `config`, `key`, `fallback` -> `float` | No | No | No; read-only `Dictionary.get` | Display configuration only; no gameplay/result/handoff | `hero_width_ratio -> 0.86` | Selected |
| `_get_specialty_skill_cutin_video_load_failure_guess` | 4322 | `4278`, `4318` / 2 | path/load-state values -> `String` | No | No direct access; caller performs resource access | No | Video loading diagnostics | `file_missing` | Rejected — video/resource loading diagnostic boundary |
| `_get_unique_skill_cutin_slide_direction` | 4600 | `4533` / 1 | `caster_state` -> `float` | No | No | No | Cutin animation positioning | enemy -> `-1.0` | Rejected — animation/cutin positioning and `BattleUnitState` input |
| `_get_unique_skill_name_position` | 4646 | `4537` / 1 | `cutin_rect` -> `Vector2` | Yes: cutin layout constants | No | No | Cutin UI layout | label anchor `Vector2` | Rejected — UI/cutin layout, not metadata or description lookup |

## 4. Selected Extraction

- New helper: `scripts/battle/helpers/battle_skill_metadata_helper.gd` with `class_name BattleSkillMetadataHelper` and static functions.
- Extracted pure lookup implementations:
  - `_get_specialty_skill_cutin_config(hero_id: String) -> Dictionary`
  - `_get_specialty_skill_cutin_config_float(config: Dictionary, key: String, fallback: float) -> float`
- Existing wrappers keep their original function names, arguments, and return types. Existing caller lines were not edited.
- The config wrapper passes the existing read-only registry and fallback hero ID into the helper, preserving the original nested `Dictionary.get` behavior and returned Dictionary identity.

## 5. Rejected Candidates

- WorldMap-context name, target mode, visual-key, and unit-skill registry functions remain in the battle script because they participate in the WorldMap handoff contract.
- Skill range and automatic-resolution functions remain because they determine targeting/range behavior.
- Hero-id, video failure, slide-direction, and name-position helpers remain because they are coupled to `BattleUnitState`, video/resource diagnostics, or cutin/UI animation layout.
- No skill execution, damage/heal/hit/probability/status/AP/MP/HP logic was selected.

## 6. Changed Files

- Added `scripts/battle/helpers/battle_skill_metadata_helper.gd`.
- Modified `scripts/battle_web_import_test.gd` only to add the helper preload and delegate the two preserved wrappers.
- Added this review record.
- Modified `agent/NEXT_TASKS.md` by prepending the required v0.72-07, v0.72-06, and v0.72-05 status entries.

## 7. Validation

- Godot project parse: passed.
- Helper class registration/preload: passed.
- `Battle_Land.tscn` headless load: passed.
- Wrapper signatures and existing call locations: verified unchanged by source and `rg` review.
- Output equality: verified from the preserved nested `Dictionary.get` and `float(Dictionary.get(...))` expressions.
- Diff review: no skill execution, damage/heal/probability/status/AP/MP/HP formula, WorldMap handoff, battle result/retreat/scene transition change.
- Protected-file review: no changes in `scripts/worldmap/worldmap_main.gd`, `WorldMap.tscn`, `Battle_Land.tscn`, or `project.godot`.

## 8. Rollback

- Remove `scripts/battle/helpers/battle_skill_metadata_helper.gd` and its generated `.uid` companion, if present.
- Remove the `BattleSkillMetadataHelper` preload and restore the two original wrapper bodies in `scripts/battle_web_import_test.gd`.
- Revert this review record and the prepended `NEXT_TASKS.md` entry.
- No scene, schema, formula, WorldMap handoff, battle result, retreat, or transition file needs rollback.

## 9. Manual QA Required

- In `Battle_Land.tscn`, trigger the Yi Sun-sin specialty cutin and verify the portrait/title display positions and scale remain unchanged.
- Confirm the normal fallback cutin configuration still appears when a hero-specific configuration is absent.
- Run a normal unique skill action and confirm that targeting, effect application, cooldown, battle result, and Battle-to-WorldMap return remain unchanged.

## 10. Next Recommended Task

`v0.72-08 Battle Formation / Facing Pure Helper Review`
