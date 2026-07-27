# TRANSACTION ROADMAP

## Active

### T06-2 Hero Workbook Schema & Validator/Converter

Status: `AUDIT / IMPLEMENTATION READY`. Build the approved 39-hero workbook schema, validator/converter, generated JSON, and validation report without changing Godot runtime behavior.

Allowed scope:

- schema documentation
- conversion/validation tooling
- generated reviewable JSON
- generated validation report
- automated invalid-input checks

Forbidden scope:

- Godot external-data loader
- registry source-of-truth switch
- save/BattleContext changes
- troop/casualty formula activation
- momentum, unit-type, role-passive, unique-skill, AI, cutin, VFX, or sound implementation

Entry contract: `agent/transactions/T06_1_HERO_DATA_CONTRACT.md`.

## Complete

### T06-1 Hero Data Contract

Status: `DESIGN COMPLETE` at commit `8d0dfac28a49213459968a1c8343f1ed5573d71e`. The canonical roster is 39 heroes. Core stat names, six unit types, eight roles, role/unit directions, stable unique-skill IDs, momentum/action/HP conditions, positional range/radius rules, obsolete-name rejection, naval/land fallback, externalization pipeline, validator failures, and the final-sound-stage rule are locked. No runtime code changed.

### T06-0 Hero Definition Registry Extraction

Status: `COMPLETE`. `HERO_DATA` was moved without transformation into `scripts/worldmap/hero_definition_registry.gd` at implementation commit `a12ea4ce28948ef4ca7cbe9ad49c02704b1d4867`; protected current HEAD, including only the generated UID follow-up, is `5958b593a3c635e722a3bca7152a19dcd6d27868`.

All 39 heroes, ID order, 51-field set, and complete Dictionary values matched. The four WorldMap reads now use the registry, with no save/load, BattleContext, `_hero_runtime_states`, `UNIQUE_SKILL_REGISTRY`, Battle, scene, or asset change. `git diff --check`, Godot 4.6.2 headless parse, and user F5 QA passed.

### T04–T05 Korea MVP Turn Loop & Unification Completion

Status: `COMPLETE` on the v0.76 baseline. Godot 4.6 integrated F5 QA passed for all four starts, repeated turn progression, duplicate guards, enemy-phase save/load resume, research/recovery, fourth-city victory, last-city defeat, terminal restore, title-screen continue detection, and final Output with no new errors or warnings.

### T02 Player Invasion Logistics, Battle Supply & Occupation

Status: `COMPLETE` at `ff642424e28f98d6b390c457d6913d8b4c2f6c71`. Formation cargo, both-side Battle_Land supply, 30-turn limit, occupation settlement, deterministic defender alignment/adjacent retreat, wounded recovery, duplicate protection, ownership-derived city registry, defeated-faction state, city-stock national aggregation, scoped research payment, save/reload smoke, integrated F5 QA, and final Editor Output confirmation passed.

### T01 Korea MVP New Game Four-Faction Selection

Status: `COMPLETE`. Four selections, role-separated session state, WorldMap initialization, save schema, and integrated F5 QA passed on the current baseline.

### T00 Documentation & MVP Architecture Foundation

Status: complete with this documentation transaction. It establishes the Korea MVP direction, transaction rules, source-of-truth targets, scenario boundaries, document inventory, and archive policy. Runtime implementation is not part of T00.

Exit evidence: the default read order identifies current product direction, protected contracts, active transaction specification, and archive candidates without carrying old version history forward.

## Next

- T06-3 external JSON compatibility loader only after T06-2 generated-data parity and invalid-input tests pass.
- Later T06 sub-transactions cover registry source switch, balance/formulas, momentum, six unit types, role passives, unique skills, AI, cutins, and cooperative attacks only after their own acceptance gates.
- VFX follows functional skill verification; sound effects remain the final polish step.
- T07 planning follows the same discussion-first rule after T06. Existing T07 material is reference only and has not started.

### T01 Entry Conditions

- Audit the actual WorldMap registry and city assignments before committing starting generals.
- Audit current starting resources and technology state before committing their values.
- Preserve the existing Battle/WorldMap handoff and direct `Battle_Land` engine.

### T02–T05 Shared Rules

- Treat each item as one playable, persisted user flow.
- Record related technology states/effects, AI application, UI indication, and save impact.
- Keep results in the transaction specification; do not restore version-history accumulation here.

## Later

- Tech-tree effect integration expansion
- General definition/runtime-state separation
- Talent discovery and recruitment
- China scenario
- Japan scenario
- Naval expansion

Later work activates only after its own transaction has a bounded acceptance specification. Inactive regional content remains data-preserved rather than removed for the Korea MVP.

## Blocked

None confirmed.

Record only a reproducible external or codebase constraint here. Missing audits are planned work, not a confirmed blocker.

## Use

This is the active roadmap. Do not append completed version history here; use Git history and archived transaction evidence for historical detail.

When an item completes, update its active transaction document and change the next item; archive movement is handled separately by a documentation-cleanup transaction.