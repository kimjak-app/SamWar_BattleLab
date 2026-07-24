# TRANSACTION ROADMAP

## Active

### T04–T05 Korea MVP Turn Loop & Unification Completion

Status: `IMPLEMENTED / STATIC QA PASS / GODOT RUNTIME + F5 QA PENDING`. End turn, AI baseline city production/actions/invasion, player city-stock production, domestic/research resolution, month-boundary recovery, next-turn entry, persisted duplicate guards, four-city victory, zero-city defeat, and terminal save/load presentation are connected as one v0.76 transaction candidate.

Next gate: run `scripts/t04_t05/t04_t05_smoke_test.gd` under Godot 4.6, then integrated F5 QA for all four starts, repeated turn end, enemy-phase save/load resume, research/recovery, fourth-city victory, last-city defeat, terminal restore, title-screen continue, and final Editor Output.

## Complete

### T02 Player Invasion Logistics, Battle Supply & Occupation

Status: `COMPLETE` at `ff642424e28f98d6b390c457d6913d8b4c2f6c71`. Formation cargo, both-side Battle_Land supply, 30-turn limit, occupation settlement, deterministic defender alignment/adjacent retreat, wounded recovery, duplicate protection, ownership-derived city registry, defeated-faction state, city-stock national aggregation, scoped research payment, save/reload smoke, integrated F5 QA, and final Editor Output confirmation passed.

### T01 Korea MVP New Game Four-Faction Selection

Status: `COMPLETE`. Four selections, role-separated session state, WorldMap initialization, save schema, and integrated F5 QA passed on the current baseline.

### T00 Documentation & MVP Architecture Foundation

Status: complete with this documentation transaction. It establishes the Korea MVP direction, transaction rules, source-of-truth targets, scenario boundaries, document inventory, and archive policy. Runtime implementation is not part of T00.

Exit evidence: the default read order identifies current product direction, protected contracts, active T01 specification, and archive candidates without carrying old version history forward.

## Next

- T06 planning discussion after T04–T05 completion. Existing T06 material is reference only; design is not locked.
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
