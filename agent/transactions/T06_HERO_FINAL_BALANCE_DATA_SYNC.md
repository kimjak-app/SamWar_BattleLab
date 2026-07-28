# T06 Hero Final Balance Data Sync

## Status

`IMPLEMENTED / STATIC DATA QA PASS / GODOT QA NOT REQUIRED`

## Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Starting commit: `ceaa683e7b88893f209f08e916275fd93601c09e`

## Official workbook

- `삼국WAR_장수39명_기세비용_1-4_5병종_최종확정본.xlsx`

The workbook is the final design authority for this correction transaction.

## Final momentum-cost contract

- Unique-skill momentum cost range: `1..4`
- Cost 1: 1 hero
- Cost 2: 9 heroes
- Cost 3: 18 heroes
- Cost 4: 11 heroes
- Action cost remains `1`
- HP condition remains unused (`null`)
- Momentum remains a side-shared battle resource; costs belong to each hero skill definition.

## Final unit-type contract

Allowed unit types:

- `infantry`
- `cavalry`
- `archer`
- `gunner`
- `mounted_archer`

Final distribution:

- infantry: 11
- cavalry: 10
- archer: 11
- gunner: 4
- mounted_archer: 3

Final reassignment corrections:

- `kim_chun_chu`: archer -> infantry
- `uija_wang`: archer -> infantry
- `toyotomi_hideyoshi`: archer -> infantry

`support` remains a valid primary or secondary role but is forbidden as `unit_type`.

## Modified generated data

- `data/heroes/generated/hero_unique_skills.json`
- `data/heroes/generated/hero_battle_profiles.json`

## Validator lock

`tools/validate_hero_design_registry.py` now rejects:

- momentum costs outside integer `1..4`
- a momentum-cost distribution different from `1/9/18/11`
- `support` as a unit type
- a unit distribution different from `11/10/11/4/3`
- invalid role values
- action cost other than `1`
- non-null HP activation conditions
- duplicate or incorrectly linked unique-skill IDs

## Protected scope

This transaction changes design data and validation only. It does not activate runtime momentum, unique-skill execution, AI skill use, cutins, VFX, cooperative attacks, or sound.

## Next transaction

Use this locked final data as the single source for the complete playable unique-skill and shared-momentum implementation transaction. Do not reintroduce a flat momentum cost or a support unit type.
