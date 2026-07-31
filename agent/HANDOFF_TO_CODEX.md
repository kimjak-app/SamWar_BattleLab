# HANDOFF TO CODEX

## Current locked baseline

- T01–T05 Korea Four-City MVP world-turn, invasion, occupation, logistics, recovery, and unification contracts are protected.
- T06 hero authority, five-stat data, battle profiles, 39 unique skills, shared momentum, resolver integration, battle result parity, cutins, Korean effect display, and post-battle garrison portraits are implemented.
- T06-11A user F5 PASS: one Yi Sun-sin unit invading Sabi saw all living defenders act in the same enemy phase.
- T06-11B user F5 PASS: multiple enemies surrounded Yi Sun-sin, used momentum/unique skills, and attacked without the old single-actor stall.
- Current battle momentum test policy remains start 3 / max 10 until an explicit later balance transaction changes it.

## Protected T06 contracts

- `HeroDesignDataRegistry -> HeroRuntimeFactory -> BattleUnitState -> BattleSkillResolver` remains the single-authority path.
- Authoritative hero IDs must remain canonical through WorldMap, formation, battle, result settlement, and save/load.
- Player and AI unique skills share the same committed resolver path.
- Korea MVP cutins require exact canonical `hero_id` + `skill_id` registry parity.
- User-visible unique-skill effect/status/failure strings must pass through the shared Korean display layer.
- Post-battle garrison portraits resolve from canonical hero identity and production atlas metadata.
- Every living enemy actor may act at most once per enemy phase; unacted enemies prevent premature ally return or round reset.
- Multiple enemies may share a target, while destination and engagement cells remain exclusive.
- Existing side/back attack multipliers remain `1.15` / `1.30` until explicitly rebalanced.

## New authoritative roadmap

Read before planning any post-T06 work:

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`

The major sequence is now:

1. T07 — Six Unit-Type Battle Completion
2. T08 — Battlefield Terrain & Tactical Map System
3. T09 — Cooperative Attack & Common Tactics
4. T10 — Battle UI/UX Renewal
5. T11 — Korea MVP Full Balance & Final Battle QA

T07–T10 are battle-engine feature-completion stages. Full Korea MVP campaign and numerical balance is intentionally deferred to T11.

## Next transaction

### T07-1 Six Unit-Type Current-State Audit & Canonical Contract Design

Do not implement firearm infantry or mounted archers before completing this audit.

Audit the current unit-type contract across:

- generated hero battle profiles and authoritative unit-type fields
- registries, aliases, and display names
- HeroRuntimeFactory
- BattleUnitState
- movement, range, target, counterattack, and facing rules
- AI planning and distance behavior
- battle resolver and auto-battle
- formation/WorldMap handoff
- result payload and settlement
- save/load migration
- battle UI, logs, tooltips, and validation

The audit must identify the actual current unit types and then propose the canonical final six-unit-type contract, including firearm infantry and mounted archers.

Constraints:

- Do not force firearm infantry or mounted archers into the Korea production roster.
- Do not finalize numerical balance during T07-1.
- Do not patch by hero name or scene-specific fallback.
- Preserve T01–T06 protected contracts.
- Split later implementation into auditable transactions with automated validators and user F5 gates.

## Later stages

## Current handoff

T07 five-unit-type battle parity is implemented and locally committed. Start T08 terrain/tactical-map work from the current `main`; do not change T07 validation numbers outside T11.

- T08 adds terrain data, passability, movement cost, terrain modifiers, bridges, rivers, cliffs, high ground, and tactical-map AI awareness.
- T09 adds a true cooperative-attack contract and common tactics such as fire attack and disruption, while keeping them distinct from hero unique skills and passive terrain effects.
- T10 replaces the test-oriented battle UI with a production-quality 1920×1080 information and command layout covering six unit types, terrain, tactics, statuses, momentum, and cutins.
- T11 performs the final Korea MVP economy, war, AI, battle, pacing, and unification balance lock.
