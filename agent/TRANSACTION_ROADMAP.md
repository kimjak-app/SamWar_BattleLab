# TRANSACTION ROADMAP

## Active

### T06-4 Battle-side Hero Stat/Profile Adapter

Status: `IMPLEMENTED / GODOT QA PENDING`.

Implemented scope:

- `scripts/battle/hero_battle_design_adapter.gd`
- `agent/transactions/T06_4_BATTLE_HERO_DESIGN_ADAPTER.md`
- namespaced, defensive-copy composition of legacy hero data with T06 design data
- fail-closed `design_adapter_error` handling

Protected scope:

- `HeroDefinitionRegistry.HERO_DATA` remains WorldMap authority
- existing BattleContext shape remains unchanged
- legacy battle fields and formulas remain active
- no six-unit runtime behavior
- no role-passive, momentum, unique-skill, AI, cutin, VFX, or sound activation

Exit gate:

- Godot parse/F5 PASS
- representative hero contracts build with valid design namespaces
- invalid/missing hero IDs fail safely
- WorldMap, battle entry/return, and save/load remain unchanged
- no new parse error or warning

## Complete

### T06-3 Hero Design JSON Parity & Non-Destructive Loader

Status: `COMPLETE`. Static parity and user Godot smoke passed. The read-only loader exposes 39 base records, 39 profiles, 39 skills, six unit types, and eight roles without replacing the legacy WorldMap registry or changing save/BattleContext/runtime behavior.

### T06-2 Hero Workbook Schema & Validator/Converter

Status: `IMPLEMENTED`. The standard-library workbook converter, generated JSON, and validation contract are present on main. Generated data contains 39 heroes, 39 battle profiles, 39 unique skills, six unit types, and eight roles. Runtime authority was not switched.

### T06-1 Hero Data Contract

Status: `DESIGN COMPLETE` at commit `8d0dfac28a49213459968a1c8343f1ed5573d71e`. The canonical roster is 39 heroes. Core stat names, six unit types, eight roles, stable unique-skill IDs, momentum/action/HP conditions, positional range/radius rules, obsolete-name rejection, naval/land fallback, externalization pipeline, validator failures, and the final-sound-stage rule are locked. No runtime code changed.

### T06-0 Hero Definition Registry Extraction

Status: `COMPLETE`. `HERO_DATA` was moved without transformation into `scripts/worldmap/hero_definition_registry.gd` at implementation commit `a12ea4ce28948ef4ca7cbe9ad49c02704b1d4867`; the protected UID follow-up is `5958b593a3c635e722a3bca7152a19dcd6d27868`.

All 39 heroes, ID order, 51-field set, and complete Dictionary values matched. WorldMap reads use the registry with no save/load, BattleContext, runtime hero-state, unique-skill, Battle, scene, or asset behavior change. Godot QA passed.

### T04–T05 Korea MVP Turn Loop & Unification Completion

Status: `COMPLETE` on the v0.76 baseline. Godot integrated F5 QA passed for four starts, repeated turn progression, duplicate guards, enemy-phase save/load resume, research/recovery, victory/defeat, terminal restore, title-screen continue detection, and clean Output.

### T02 Player Invasion Logistics, Battle Supply & Occupation

Status: `COMPLETE` at `ff642424e28f98d6b390c457d6913d8b4c2f6c71`.

### T01 Korea MVP New Game Four-Faction Selection

Status: `COMPLETE`.

### T00 Documentation & MVP Architecture Foundation

Status: `COMPLETE`.

## Next

- T06-5 may call the adapter at the Battle roster-registration boundary only after T06-4 QA PASS.
- T06-5 must expose namespaced design data without switching legacy combat formulas.
- Later bounded transactions activate six unit types, primary-role passives, momentum, representative unique skills, all 39 skills, AI, cutins, cooperative attacks, and VFX.
- Sound effects remain the final polish step.
- T07 starts only after T06 completion and its own discussion-first gate.

## Later

- Tech-tree effect integration expansion
- General definition/runtime-state separation
- Talent discovery and recruitment
- China scenario
- Japan scenario
- Naval expansion

## Blocked

None confirmed.

## Use

This is the active roadmap. Keep completed detail in Git history and transaction documents. Update the active transaction only after its exit evidence is recorded.
