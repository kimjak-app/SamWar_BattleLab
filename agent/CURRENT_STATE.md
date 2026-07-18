# CURRENT STATE

## Baseline

- Branch: `main`
- Baseline commit: `a8b65d573dd4f5d064245beb114367189d5bb85a`
- Current implementation: `v0.74-02-hotfix1 Battle Supply HUD Relocation & Readability` (this document's Git commit)
- This state document is current-state only. Use Git history and archive candidates for completed version detail.

## Active Development Phase

Korea Four-City MVP. T01 and T02 implementations are complete; integrated manual UI/gameplay QA remains.

The active context deliberately contains only current direction, protected boundaries, and the next executable transaction. Completed version-by-version evidence remains in Git history and retained archive candidates.

## Product Direction

- Active Korea MVP cities: Hanseong, Pyongyang, Gyeongju, Sabi.
- A new game lets the player choose any of the four starting factions; the others are AI.
- Player role and nation ID are separate; Hanseong is not permanently the player faction.
- Preserve the existing `Battle_Land` engine for direct command. Auto delegation is a separate result path.
- Use national and city research as real gameplay systems, not decorative UI.
- Complete user-visible transactions rather than isolated helper/refactor milestones.

The intended core loop is preparation, research-aware choice, invasion or defense, battle/delegation resolution, result application, turn progression, and Korea-wide outcome evaluation.

Direct command and automatic delegation are complementary player choices. Automatic delegation must calculate a separate result; it must not silently replace tactical battle with a reduced battle loop.

## Runtime Entrypoints

- World map: `res://WorldMap.tscn` and `scripts/worldmap/worldmap_main.gd`
- Land battle: `res://Battle_Land.tscn` and `scripts/battle_web_import_test.gd`
- Existing WorldMap-to-Battle and result-return contract: `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`

## Strong Existing Assets

- Existing `Battle_Land` tactical engine and WorldMap battle handoff baseline.
- Stage B land-battle refactoring is complete as a historical implementation milestone.
- National/city technology data, UI icons, progress, and cost systems exist.
- Existing WorldMap city and general registry data is authoritative for runtime audits.
- Existing city research and national research systems must be audited for current effect coverage before their MVP activation is narrowed.
- Existing China, Japan, and naval content remains preserved while the Korea scenario is active.

These are implementation assets, not a claim that every connected gameplay effect has already been verified. Active T01–T05 work must audit and reuse them as needed.

## Confirmed Major Gaps

- Four-faction new-game choice and player-nation session setup: implemented through `GameSession` and `NewGameFactionSelect.tscn`; Manual QA pending.
- Korea MVP starting general/resource/technology values: `Needs Data Audit` / `Needs Runtime Audit`.
- Player occupation, enemy defense, turn resolution, and Korea victory need transaction completion and integrated QA.
- City-research behavior on occupation: `Needs Runtime Audit`.
- The authoritative starting roster count, city assignment, resources, and initial technology states require a runtime/data audit before T01 locks them.

No confirmed runtime blocker currently prevents T01 planning. A missing design value is an audit requirement, not permission to fabricate it in code or documentation.

## Active Documentation Transaction

T00 established `MVP_MASTER_PLAN`, transaction rules, roadmap, scenario, source-of-truth target, tech contract, inventory, and archive policy. No runtime code changed.

T00 is a documentation transaction, not an implementation claim. The new documents distinguish `Proposed`, `Not Yet Implemented`, `Needs Data Audit`, and `Needs Runtime Audit` where current evidence is incomplete.

## Current Runtime Transaction

T02 is Implementation Complete / Manual QA Pending. Player invasion now carries transaction-scoped gold/one food type/salt through Battle_Land, consumes both sides' supply once per round, enforces the absolute 30-turn limit, settles occupation/defeat/wounded recovery, prevents duplicate result application, and checkpoints the result. Hotfix 1 relocates the obscured supply HUD to the anchored bottom-right panel above battle commands; live resolution/layout QA remains. T03 remains inactive until T02 manual QA passes.

## Protected Contracts

- Existing `Battle_Land` direct tactical battle is preserved.
- Battle does not own WorldMap state or choose WorldMap armies.
- WorldMap provides prepared battle context and consumes results through the established handoff.
- City/general registry and city placement authority remain subject to current domain rules.
- Technology values/effects are not altered without implementation evidence and an active transaction.
- National research belongs to the nation; city research occupation handling remains explicit until audited.
- State responsibility is targeted by `SYSTEM_SOURCE_OF_TRUTH`; it does not authorize a mass refactor.

When an active transaction discovers a contract mismatch, record the concrete evidence and change only the necessary boundary. Do not use the contract as a blanket migration mandate.

## Required Reading

1. `agent/WORKFLOW_MANAGER.md`
2. `agent/TRANSACTION_DEVELOPMENT_RULES.md`
3. `agent/MVP_MASTER_PLAN.md`
4. This document
5. `agent/TRANSACTION_ROADMAP.md`
6. Active transaction specification

Read conditional contracts only for their domain.

For WorldMap work also read `WORLDMAP_RULES`. For Battle integration read `BATTLE_WORLDMAP_HANDOFF_CONTRACT`. For technology, scenario, or state changes read the matching contract/scenario document before editing runtime files.

## Archive Candidates

Historical v0.70–v0.72 plans, audits, QA records, helper extraction documents, and complete locks are candidates for a future documentation-cleanup transaction. They are retained now; see `agent/DOCUMENT_INVENTORY.md` and `agent/archive/README.md`.

The next cleanup may move only documents whose unique contract value has been reviewed. No history is deleted by this state transition.

Archive review is separate from runtime implementation. Its result must preserve discoverability through Git history and the archive index.

Historical detail is retained, but it is no longer a default-session dependency.
