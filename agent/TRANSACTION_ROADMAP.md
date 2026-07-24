# TRANSACTION ROADMAP

## Active

### T06-0 Hero Definition Data Extraction

Status: `AUDIT / IMPLEMENTATION`. Extract the authoritative WorldMap hero definition data from `scripts/worldmap/worldmap_main.gd` into a dedicated read-only registry without changing roster membership, field names, values, save data, UI behavior, battle handoff, combat formulas, or unique skills.

Next gate: complete the source/reference audit, perform the no-behavior-change extraction, run static parity checks, then run focused Godot F5 regression QA before marking the extraction complete.

## Complete

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

- T06-1 hero stat-field contract audit and design decision after T06-0 extraction is complete.
- Later T06 sub-transactions cover definition/runtime unification, external data loading, balance, cutins, unique skills, and cooperative attacks only after their own discussion and acceptance gates.
- T07 planning follows the same discussion-first rule after T06. Existing T07 material is reference only.

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
