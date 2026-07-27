# CURRENT STATE

## Baseline

- Branch: `main`
- Protected runtime baseline: `v0.77 T06-0 Hero Definition Registry Extraction`
- T06-1 design lock: `8d0dfac28a49213459968a1c8343f1ed5573d71e`
- T06-2 converter/generated-data implementation is present on main.
- T06-3 non-destructive JSON loader and parity validation are complete.
- Hero Battle Profile Integration implementation is present on main.
- This document records current state only. Use Git history and transaction documents for completed detail.

## Active Development Phase

Korea Four-City MVP. T01 through T05 are complete and protected. T06-0 extracted the immutable 39-hero legacy definition registry without behavior change. T06-1 locked the new 39-hero stat/unit/role/unique-skill data contract. T06-2 added workbook validation and generated reviewable JSON. T06-3 added and verified the read-only Godot loader and parity validator.

The active transaction is the integrated `T06 Hero Battle Profile Integration`. Earlier T06-4 and T06-5 labels are internal steps, not separate user-facing transactions.

## Product Direction

- Active Korea MVP cities: Hanseong, Pyongyang, Gyeongju, Sabi.
- A new game lets the player choose any of the four starting factions; the others are AI.
- Preserve the existing `Battle_Land` engine for direct command.
- Automatic delegation remains a separate result path.
- Complete user-visible and verifiable transactions rather than isolated helper milestones.
- Sound effects remain the final polish step after functional, visual, balance, and QA completion.

## Runtime Entrypoints

- World map: `res://WorldMap.tscn` and `scripts/worldmap/worldmap_main.gd`
- Land battle: `res://Battle_Land.tscn` and `scripts/battle_web_import_test.gd`
- Legacy hero definition authority: `scripts/worldmap/hero_definition_registry.gd`
- Read-only design-data loader: `scripts/worldmap/hero_design_data_registry.gd`
- Battle design adapter: `scripts/battle/hero_battle_design_adapter.gd`
- Battle profile integration Autoload: `scripts/battle/hero_battle_profile_integration.gd`
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
- Only primary roles apply MVP passives in the later passive transaction.
- Stable unique-skill IDs use `<hero_id>_unique`.
- Momentum cost is 3, action cost is 1, HP condition is unused, and cooldown is deprecated.
- Positional range/radius replaces global-allies application.
- `영락대제` and `삼천궁녀` are required; obsolete names are rejected.

### T06-2

- Workbook validator/converter exists at `tools/convert_hero_workbook.py`.
- Generated JSON exists under `data/heroes/generated/`.
- The generated contract contains 39 heroes, 39 profiles, 39 skills, six unit types, and eight roles.

### T06-3

- `python tools/validate_hero_design_registry.py` passed.
- User Godot F5 smoke passed.
- WorldMap, roster UI, battle entry/return, save/load, and final Output remained normal.
- `HeroDefinitionRegistry.HERO_DATA` remains WorldMap runtime authority.

## Active Transaction

### T06 Hero Battle Profile Integration

Status: `IMPLEMENTED / USER GODOT QA PENDING`

Implemented:

- namespaced legacy/design hero contract composition
- Autoload invocation on `Battle_Land`
- attacker and defender roster enrichment
- six-unit `unit_type`, movement, and attack-range application to active BattleUnitState objects
- primary/secondary role and design skill IDs stored as metadata
- design unique-skill payload exposed but marked inactive
- per-hero and transaction Output logs
- static integration validator

Runtime files:

- `scripts/battle/hero_battle_design_adapter.gd`
- `scripts/battle/hero_battle_profile_integration.gd`
- `project.godot`
- `tools/validate_hero_battle_profile_integration.py`
- `agent/transactions/T06_HERO_BATTLE_PROFILE_INTEGRATION.md`

Protected boundary:

- WorldMap authority, save schema, BattleContext, troop accounting, settlement, legacy attack/defense/damage, AI, and legacy skill execution remain unchanged.
- Role passives, momentum, new unique-skill execution, cutins, VFX, and sound remain inactive.
- Gunner and mounted-archer visuals continue to use existing fallback visuals.

Required completion evidence:

1. `python tools/validate_hero_design_registry.py` PASS.
2. `python tools/validate_hero_battle_profile_integration.py` PASS.
3. Godot parse/F5 succeeds without new error or warning.
4. A WorldMap-origin battle logs `HERO_PROFILE` entries for deployed attacker and defender heroes.
5. Generated movement/range values are visible in battle behavior.
6. Battle return, save/load, settlement, legacy damage, and legacy unique skills remain normal.

## Confirmed Major Gaps

- User Godot QA for the integrated battle profile transaction is pending.
- Primary-role passive effects, momentum, 39 new unique-skill execution, AI skill usage, cutins, and VFX remain unimplemented under the new contract.
- Sound remains intentionally deferred to final polish.

## Protected Contracts

- Existing `Battle_Land` tactical battle is preserved.
- Battle does not own WorldMap state or select WorldMap armies.
- WorldMap provides prepared battle context and consumes battle results.
- Existing save, runtime hero state, battle handoff, settlement, and turn/outcome behavior remain protected.
- Runtime integration remains bounded and namespaced.

## Required Reading

1. `agent/WORKFLOW_MANAGER.md`
2. `agent/TRANSACTION_DEVELOPMENT_RULES.md`
3. `agent/MVP_MASTER_PLAN.md`
4. This document
5. `agent/TRANSACTION_ROADMAP.md`
6. `agent/transactions/T06_1_HERO_DATA_CONTRACT.md`
7. `agent/transactions/T06_3_HERO_DESIGN_JSON_LOADER.md`
8. `agent/transactions/T06_HERO_BATTLE_PROFILE_INTEGRATION.md`

For WorldMap work also read `agent/WORLDMAP_RULES.md`. For Battle integration read `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`.

## Next Gate

After integrated static validation and user Godot QA pass, close the whole Hero Battle Profile Integration transaction. The next transaction should activate a complete battle mechanic set, not another adapter-only milestone.