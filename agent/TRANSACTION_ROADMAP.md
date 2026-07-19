# TRANSACTION ROADMAP

## Active

### T02 Player Invasion Logistics, Battle Supply & Occupation

Status: Implementation Complete / Manual QA Pending. Formation cargo, both-side Battle_Land supply, 30-turn limit, occupation/defeat settlement, wounded recovery, duplicate protection, four-faction handling, and save/reload automated smoke are implemented. Hotfix 2 makes the bottom-right HUD compact two-column, locks defender supply to target CityState persistence through result settlement/save-load smoke, and makes invasion titles data-driven. Do not promote T03 until integrated manual QA passes.

### T01 Korea MVP New Game Four-Faction Selection

Status: Implementation Complete / Manual QA Pending. Four selections, role-separated session state, WorldMap initialization, and save schema are implemented. Do not promote T02 until F6 QA passes.

### T00 Documentation & MVP Architecture Foundation

Status: complete with this documentation transaction. It establishes the Korea MVP direction, transaction rules, source-of-truth targets, scenario boundaries, document inventory, and archive policy. Runtime implementation is not part of T00.

Exit evidence: the default read order identifies current product direction, protected contracts, active T01 specification, and archive candidates without carrying old version history forward.

## Next

3. **T03 Enemy Invasion & Player Defense Completion** — present and resolve player defense without breaking the existing Battle/WorldMap handoff.
4. **T04 Turn Resolution Transaction** — resolve player/end-turn state, AI actions, research, UI, and persistence as one flow.
5. **T05 Korea Unification Victory Transaction** — evaluate four-city victory and zero-city defeat, present outcome, and persist it.

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
