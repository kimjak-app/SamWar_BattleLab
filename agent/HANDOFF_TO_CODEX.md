# HANDOFF TO CODEX

## Current locked baseline

- T01–T05 Korea Four-City MVP world-turn, invasion, occupation, logistics, recovery, and unification contracts are protected.
- T06 hero authority, five-stat data, 39 unique skills, shared momentum, resolver integration, battle result parity, cutins, Korean display, portraits, and enemy multi-actor flow are implemented.
- T07 five-unit-type battle parity is implemented with dedicated gunner and mounted-archer visuals.
- T07 status: `IMPLEMENTED / AUTOMATED VALIDATION PASS / DEDICATED VISUALS BOUND / USER F5 QA PENDING`.

## Protected contracts

- `HeroDesignDataRegistry -> HeroRuntimeFactory -> BattleUnitState -> BattleSkillResolver` remains the single-authority hero path.
- Player and AI consume shared unit-type action eligibility and damage metadata.
- Gunner and mounted archer remain canonical unit types and are not forced into the Korea production roster.
- T06 cutin, momentum, unique-skill, Korean display, portrait, result-settlement, and save/load contracts remain protected.
- Existing side/back multipliers remain protected until T11 unless explicitly rebalanced.

## Authoritative roadmap

Read before planning work:

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`

Official order:

1. T07 — Five Unit-Type Battle Completion
2. T08 — Battle UI/UX Renewal
3. T09 — Battlefield Terrain & Tactical Map System
4. T10 — Cooperative Attack & Common Tactics
5. T11 — Korea MVP Full Balance & Final Battle QA

The previous terrain-first sequence is obsolete. UI/UX is now completed first so terrain and tactics can integrate into a stable production information layout.

## Next transaction

### T08-1 Battle UI/UX Current-State Audit & Production Information Architecture Design

Audit only. Do not begin visual restructuring or terrain implementation before the audit is documented.

Inspect:

- `Battle_Land.tscn` UI node hierarchy and runtime bindings
- force overview, turn/round state, selected-unit information, HP/troops/statuses
- floating command panel and disabled-state reasons
- movement/attack/unique-skill/facing/strategy interaction phases
- momentum presentation
- battle log and important event feedback
- overlays and target instructions
- cutin transition and state restoration
- reinforcement/formation UI
- 1920×1080 overlap, clipping, scaling, and grid obstruction
- duplicated text formatting and stale UI risks

T08-1 deliverables:

- current-state audit
- locked information hierarchy
- interaction and phase-state contract
- proposed node/layout migration
- implementation transaction sequence
- automated validator plan
- user F5 QA gates

Do not add terrain data, terrain modifiers, cooperative attacks, or new common tactics as part of T08-1.
