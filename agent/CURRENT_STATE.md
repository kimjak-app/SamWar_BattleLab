# CURRENT STATE

## Baseline

- Branch: `main`
- Protected runtime baseline: `v0.77 T06-0 Hero Definition Registry Extraction`
- T06-1 design lock: `8d0dfac28a49213459968a1c8343f1ed5573d71e`
- T06-2 converter/generated-data implementation is present on main.
- T06-3 non-destructive JSON loader and parity validation are complete.
- T06-4 Battle-side hero design adapter implementation is present on main.
- This document records current state only. Use Git history and transaction documents for completed detail.

## Active Development Phase

Korea Four-City MVP. T01 through T05 are complete and protected. T06-0 extracted the immutable 39-hero legacy definition registry without behavior change. T06-1 locked the new 39-hero stat/unit/role/unique-skill data contract. T06-2 added workbook validation and generated reviewable JSON. T06-3 added and verified an opt-in, read-only Godot loader and parity validator without switching runtime authority.

The active transaction is T06-4 Battle-side Hero Stat/Profile Adapter, implemented with Godot QA pending.

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
- Battle-side design adapter: `scripts/battle/hero_battle_design_adapter.gd`
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

### T06-3

- `python tools/validate_hero_design_registry.py` passed.
- User Godot F5 smoke passed.
- WorldMap, roster UI, battle entry/return, save/load, and final Output remained normal.
- `HeroDefinitionRegistry.HERO_DATA` remains WorldMap runtime authority.

## Active Transaction

### T06-4 Battle-side Hero Stat/Profile Adapter

Status: `IMPLEMENTED / GODOT QA PENDING`

Implemented:

- `scripts/battle/hero_battle_design_adapter.gd`
- `agent/transactions/T06_4_BATTLE_HERO_DESIGN_ADAPTER.md`
- legacy hero Dictionaries are deep-copied and enriched only with namespaced design fields
- invalid/missing design links fail closed with `design_adapter_error`

Protected boundary:

- legacy `attack`, `defense`, `war`, `command`, troops, city, faction, save, BattleContext, and `unique_skill_id` fields are not overwritten
- the adapter is not yet called by Battle roster registration
- existing battle formulas remain unchanged
- six-unit behavior, primary-role passives, momentum, and new unique-skill execution remain inactive

Required completion evidence:

1. Godot parse/F5 succeeds.
2. Representative hero contracts expose all design namespaces.
3. Missing/invalid IDs fail safely without crash.
4. WorldMap, battle entry/return, and save/load remain unchanged.
5. No new parse error or warning appears.

## Confirmed Major Gaps

- T06-4 adapter QA has not yet been recorded as passed.
- The adapter is not yet invoked at the Battle roster-registration boundary.
- Six-unit behavior, role passives, momentum, 39 unique-skill execution, AI usage, cutins, and VFX remain unimplemented under the new contract.
- Sound remains intentionally deferred to final polish.

## Protected Contracts

- Existing `Battle_Land` tactical battle is preserved.
- Battle does not own WorldMap state or select WorldMap armies.
- WorldMap provides prepared battle context and consumes battle results.
- Existing save, runtime hero state, battle handoff, settlement, and turn/outcome behavior remain unchanged during T06-4.
- New fields must not be mapped onto legacy fields merely because their names appear similar.
- Runtime adaptation remains bounded, adapter-first, and separately QA-locked.

## Required Reading

1. `agent/WORKFLOW_MANAGER.md`
2. `agent/TRANSACTION_DEVELOPMENT_RULES.md`
3. `agent/MVP_MASTER_PLAN.md`
4. This document
5. `agent/TRANSACTION_ROADMAP.md`
6. `agent/transactions/T06_1_HERO_DATA_CONTRACT.md`
7. `agent/transactions/T06_3_HERO_DESIGN_JSON_LOADER.md`
8. `agent/transactions/T06_4_BATTLE_HERO_DESIGN_ADAPTER.md`

For WorldMap work also read `agent/WORLDMAP_RULES.md`. For Battle integration read `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`.

## Next Gate

After T06-4 Godot QA PASS, T06-5 may invoke the adapter at the Battle roster-registration boundary while preserving all legacy combat formulas.
