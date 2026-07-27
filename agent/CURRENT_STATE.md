# CURRENT STATE

## Baseline

- Branch: `main`
- Protected runtime baseline: `v0.77 T06-0 Hero Definition Registry Extraction`
- T06-1 design lock commit: `8d0dfac28a49213459968a1c8343f1ed5573d71e`
- Current documentation HEAD includes the T06-2 roadmap transition.
- This state document is current-state only. Use Git history and transaction documents for completed detail.

## Active Development Phase

Korea Four-City MVP. T01 through T05 are complete and protected. T06-0 extracted the immutable 39-hero definition registry without behavior change. T06-1 has now locked the approved hero/stat/unit/role/unique-skill data contract without runtime changes.

The active transaction is T06-2 Hero Workbook Schema & Validator/Converter.

## Product Direction

- Active Korea MVP cities: Hanseong, Pyongyang, Gyeongju, Sabi.
- A new game lets the player choose any of the four starting factions; the others are AI.
- Preserve the existing `Battle_Land` engine for direct command.
- Automatic delegation remains a separate result path.
- Complete user-visible transactions rather than isolated helper/refactor milestones.
- Sound effects are reserved for the final polish stage after functional, visual, balance, and QA completion.

## Runtime Entrypoints

- World map: `res://WorldMap.tscn` and `scripts/worldmap/worldmap_main.gd`
- Land battle: `res://Battle_Land.tscn` and `scripts/battle_web_import_test.gd`
- Hero definition registry: `scripts/worldmap/hero_definition_registry.gd`
- WorldMap/Battle handoff: `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`

## Protected Completed Baselines

### T01–T05

- Four-faction new-game selection, player/AI identity, invasion/defense, battle logistics, settlement, persistence, turn progression, and Korea victory/defeat are complete.
- Godot integrated QA passed with no new errors or warnings.
- Save/load, BattleContext, battle return, city resources, recovery, technology continuity, and outcome handling remain protected during T06.

### T06-0

- Hero Definition Registry Extraction is complete.
- Authoritative immutable definition data is `scripts/worldmap/hero_definition_registry.gd`.
- All 39 hero IDs, order, 51-field set, and Dictionary values were preserved.
- No save/load, runtime hero state, BattleContext, unique-skill behavior, battle code, scene, or asset behavior changed.

### T06-1

- Hero Data Contract design is complete in `agent/transactions/T06_1_HERO_DATA_CONTRACT.md`.
- Canonical roster count is 39. Stale 41-hero references are not implementation authority.
- `leadership`, `attack`, `intelligence`, and `politics` are the approved core fields.
- Six unit types and eight battlefield roles are locked.
- Only primary roles apply MVP passives.
- Stable unique-skill IDs use `<hero_id>_unique`.
- Unique-skill momentum cost is 3; action cost is 1; HP condition is unused; cooldown is deprecated.
- Positional range/radius replaces global all-allies effects.
- `영락대제` and `삼천궁녀` are required; `대백제`, `대백제 진군`, and `영락대전` are rejected.
- XLSX is a human-facing design master; runtime will consume generated reviewable text data.

## Active Transaction

### T06-2 Hero Workbook Schema & Validator/Converter

Status: `AUDIT / IMPLEMENTATION READY`

Allowed:

- workbook/schema contract documentation
- validator/converter tooling
- generated JSON
- generated validation report
- automated valid/invalid input tests

Forbidden:

- Godot loader or registry source switch
- runtime behavior changes
- save/BattleContext changes
- troop/casualty formula activation
- momentum implementation
- six-unit runtime implementation
- role-passive runtime implementation
- unique-skill execution/AI/cutin/VFX/sound work

Required completion evidence:

- exactly 39 heroes
- stable hero order
- allowed unit/role enums only
- unique skill ID parity
- momentum/action/HP/cooldown validation
- obsolete-name rejection
- generated JSON suitable for Git review
- actionable invalid-input report

## Confirmed Major Gaps

- External JSON is not yet loaded by Godot.
- Current runtime registry remains authoritative until a later adapter transaction passes parity and regression QA.
- Six-unit behavior, role passives, momentum, 39 unique skills, AI usage, cutins, and VFX are not yet implemented under the new contract.
- Sound remains intentionally deferred to the final polish stage.
- Leadership-based troop and casualty formulas require later bounded balance transactions.

## Protected Contracts

- Existing `Battle_Land` tactical battle is preserved.
- Battle does not own WorldMap state or select WorldMap armies.
- WorldMap provides prepared battle context and consumes battle results.
- Existing save, runtime hero state, battle handoff, settlement, and turn/outcome behavior remain unchanged during T06-2.
- A missing or conflicting data value must fail validation; it is not permission to fabricate a runtime value.
- Externalization must be adapter-first rather than a mass refactor.

## Required Reading

1. `agent/WORKFLOW_MANAGER.md`
2. `agent/TRANSACTION_DEVELOPMENT_RULES.md`
3. `agent/MVP_MASTER_PLAN.md`
4. This document
5. `agent/TRANSACTION_ROADMAP.md`
6. `agent/transactions/T06_1_HERO_DATA_CONTRACT.md`
7. The T06-2 transaction specification once created

For WorldMap work also read `agent/WORLDMAP_RULES.md`. For Battle integration read `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`.

## Next Gate

Complete T06-2 schema, converter, generated JSON, validation report, and invalid-input tests. Only then may T06-3 add a Godot compatibility loader. Runtime source-of-truth switching requires its own later QA lock.