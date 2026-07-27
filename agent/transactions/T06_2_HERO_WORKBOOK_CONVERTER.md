# T06-2 Hero Workbook Schema & Validator/Converter

Status: `COMPLETE / RUNTIME NOT CONNECTED`

## Purpose

Convert the approved 39-hero design workbook into deterministic JSON design data while validating the T06-1 contract. This transaction does not change Godot runtime behavior.

## Implementation

- Added `tools/convert_hero_workbook.py`.
- The converter uses only the Python standard library and reads `.xlsx` as an OOXML ZIP package.
- No `openpyxl` or other new project dependency is required.
- Generated files:
  - `data/heroes/generated/hero_base_stats.json`
  - `data/heroes/generated/hero_battle_profiles.json`
  - `data/heroes/generated/hero_unique_skills.json`
  - `data/heroes/generated/unit_type_rules.json`
  - `data/heroes/generated/battle_role_rules.json`

## Validation Contract

The converter fails before writing files when any of the following is found:

- hero count is not exactly 39
- unique-skill count is not exactly 39
- hero IDs are duplicated or differ in order between sheets
- unit type is not one of the approved six internal values
- primary or secondary role is not one of the approved eight internal values
- workbook unit/role values differ between the hero and skill sheets
- unique-skill ID is not `<hero_id>_unique`
- momentum cost is not 3
- action cost is not 1
- HP condition is not `none`
- target mode is unsupported
- range is outside 0–5
- radius is outside 0–3
- removed text remains: `대백제`, `대백제 진군`, or `영락대전`

## Verification Evidence

The approved workbook was processed with the converter.

Result:

```text
VALIDATION PASS: 39 heroes, 39 unique skills, 6 unit types, 8 roles
```

All five generated JSON files were parsed successfully as JSON.

During validation, one stale explanatory phrase was found for 계백: the concept still referred to low HP even though HP activation conditions were removed. The corrected workbook changes the concept to `황산벌의 결사항전으로 주변 아군의 방어와 반격을 강화`. No HP trigger is restored.

## Protected Boundaries

- `scripts/worldmap/hero_definition_registry.gd` remains the authoritative runtime source during T06-2.
- The generated JSON is design/import output only and is not loaded by Godot yet.
- No WorldMap, Battle, save/load, BattleContext, AI, scene, or asset behavior changed.
- Existing `UNIQUE_SKILL_REGISTRY` behavior remains protected.
- Effect sounds remain deferred to the final polish stage.

## Reproduction

```bash
python tools/convert_hero_workbook.py <approved-workbook.xlsx> \
  --output-dir data/heroes/generated
```

Validation without writing files:

```bash
python tools/convert_hero_workbook.py <approved-workbook.xlsx> --validate-only
```

## Next Transaction

T06-3 must audit the generated JSON against `hero_definition_registry.gd` and the existing battle/unique-skill registries, then add a non-destructive loader or parity layer. Runtime source replacement is not authorized until parity and Godot QA pass.
