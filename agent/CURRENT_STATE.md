# CURRENT STATE

## Baseline

- Branch: `main`
- Protected runtime baseline: `v0.77 T06-0 Hero Definition Registry Extraction`
- T06-1 design lock: `8d0dfac28a49213459968a1c8343f1ed5573d71e`
- T06-2 converter/generated-data implementation is present on main.
- T06-3 non-destructive JSON loader implementation is present at `4eb520f6ce6faec9a5418b3ff02831232dc05382`.
- This document records current state only. Use Git history and transaction documents for completed detail.

## Active Development Phase

Korea Four-City MVP. T01 through T05 are complete and protected. T06-0 extracted the immutable 39-hero legacy definition registry without behavior change. T06-1 locked the new 39-hero stat/unit/role/unique-skill data contract. T06-2 added workbook validation and generated reviewable JSON. T06-3 added an opt-in, read-only Godot loader and parity validator without switching runtime authority.

The active gate is T06-3 static parity and user Godot smoke confirmation. T06-4 runtime adaptation is not yet authorized.

## Product Direction

- Active Korea MVP cities: Hanseong, Pyongyang, Gyeongju, Sabi.
- A new game lets the player choose any of the four starting factions; the others are AI.
- Preserve the existing `Battle_Land` engine for direct command.
- Automatic delegation remains a separate result path.
- Complete user-visible transactions rather than isolated refactor milestones.
- Sound effects remain the final polish step after functional, visual, balance, and QA completion.

## Runtime Entrypoints

- World map: `res://WorldMap.tscn` and `scripts/worldmap/worldmap_main.gd`
- Land battle: `res://Battle_Land.tscn` and `scripts/battle_web_import_test.gd`
- Legacy hero definition authority: `scripts/worldmap/hero_definition_registry.gd`
- New read-only design-data loader: `scripts/worldmap/hero_design_data_registry.gd`
- WorldMap/Battle handoff: `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`

## Protected Completed Baselines

### T01–T05

- Four-faction new-game selection, invasion/defense, battle logistics, settlement, persistence, turn progression, and Korea victory/defeat are complete.
- Save/load, BattleContext, battle return, city resources, recovery, technology continuity, and outcome handling remain protected.

### T06-0

- The immutable 39-hero legacy registry extraction is complete.
- All IDs, order, fields, and values were preserved.

### T06-1

- Canonical roster count is 39.
- Core fields are `leadership`, `martial`, `intelligence`, and `politics`.
- Six unit types and eight battlefield roles are locked.
- Only primary roles apply MVP passives.
- Stable unique-skill IDs use `<hero_id>_unique`.
- Momentum cost is 3, action cost is 1, HP condition is unused, and cooldown is deprecated.
- Positional range/radius replaces global-allies application.
- `영락대제` and `삼천궁녀` are required; obsolete names are rejected.

### T06-2

- Workbook validator/converter exists at `tools/convert_hero_workbook.py`.
- Generated JSON exists under `data/heroes/generated/`.
- The generated contract contains 39 heroes, 39 profiles, 39 skills, six unit types, and eight roles.
- The Godot runtime source was not switched in T06-2.

## Active Transaction

### T06-3 Hero Design JSON Parity & Non-Destructive Loader

Status: `IMPLEMENTED / STATIC QA AND USER GODOT SMOKE PENDING`

Implemented:

- `scripts/worldmap/hero_design_data_registry.gd`
- `tools/validate_hero_design_registry.py`
- `agent/transactions/T06_3_HERO_DESIGN_JSON_LOADER.md`

Protected boundary:

- `HeroDefinitionRegistry.HERO_DATA` remains authoritative for WorldMap runtime behavior.
- The new loader is read-only, opt-in, and does not overwrite legacy `war`, `command`, `attack`, troop, save, city, or BattleContext values.
- Six-unit behavior, role passives, momentum, and new unique-skill effects remain inactive.

Required completion evidence:

1. Run `python tools/validate_hero_design_registry.py` and confirm the 39/39/39, six-unit, eight-role parity PASS.
2. Run Godot 4.6 parse/F5 smoke.
3. Confirm WorldMap, roster UI, battle entry/return, and save/load remain unchanged.
4. Confirm no new parse error or warning.

## Confirmed Major Gaps

- T06-3 QA has not yet been recorded as passed.
- New design stats/profiles are not yet adapted into Battle runtime.
- Six-unit behavior, role passives, momentum, 39 unique-skill execution, AI usage, cutins, and VFX remain unimplemented under the new contract.
- Sound remains intentionally deferred to final polish.

## Protected Contracts

- Existing `Battle_Land` tactical battle is preserved.
- Battle does not own WorldMap state or select WorldMap armies.
- WorldMap provides prepared battle context and consumes battle results.
- Existing save, runtime hero state, battle handoff, settlement, and turn/outcome behavior remain unchanged during T06-3.
- New fields must not be mapped onto legacy fields merely because their names appear similar.
- Runtime adaptation must be bounded, adapter-first, and separately QA-locked.

## Required Reading

1. `agent/WORKFLOW_MANAGER.md`
2. `agent/TRANSACTION_DEVELOPMENT_RULES.md`
3. `agent/MVP_MASTER_PLAN.md`
4. This document
5. `agent/TRANSACTION_ROADMAP.md`
6. `agent/transactions/T06_1_HERO_DATA_CONTRACT.md`
7. `agent/transactions/T06_3_HERO_DESIGN_JSON_LOADER.md`

For WorldMap work also read `agent/WORLDMAP_RULES.md`. For Battle integration read `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`.

## Next Gate

Only after T06-3 parity and Godot smoke PASS may T06-4 connect new base-stat/profile data through a bounded Battle-side adapter. T06-4 may not switch WorldMap source of truth or activate all unique skills at once.
