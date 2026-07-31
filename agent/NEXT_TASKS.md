# NEXT TASKS

## Completed QA locks

- T06-10H occupation portrait QA: PASS. Post-battle Sabi garrison portraits no longer show `?` for registered Korea MVP heroes.
- T06-10I unique-skill Korean display QA: PASS. User confirmed the previously exposed English effect IDs no longer appear.
- T06-11A enemy multi-actor turn orchestration QA: PASS. One Yi Sun-sin unit invading Sabi saw all living defenders act in the same enemy phase.
- T06-11B engagement reservation and surround-pressure QA: PASS. User confirmed multiple enemies surrounded Yi Sun-sin, used momentum/unique skills, and attacked without the old single-actor stall.

## Immediate maintenance

- Preserve T06-11A/T06-11B turn, reservation, side/back, momentum, cutin, Korean display, portrait, result-settlement, and save/load contracts.
- Clean or commit any remaining generated validator `.gd.uid` files after confirming they are normal Godot-generated companions.
- Do not begin full Korea MVP balance work yet.

## Next implementation

### T07-1 Six Unit-Type Current-State Audit & Canonical Contract Design

Before implementing new unit behavior, audit the current unit-type architecture across:

- authoritative generated hero battle profiles
- unit-type registries and aliases
- HeroRuntimeFactory
- BattleUnitState
- player and AI movement/attack rules
- counterattack and facing
- battle calculation and auto-battle
- formation and WorldMap handoff
- battle result settlement
- save/load migration
- battle UI and logs

The audit must identify the current implemented/configured unit types, then design the final six-unit-type contract, including firearm infantry and mounted archers.

Firearm infantry and mounted archers are for future Japan, China, and Mongolia expansion. They must not be forced into the Korea production roster.

## Locked roadmap

Authoritative planning document:

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`

Major stages:

1. T07 — Six Unit-Type Battle Completion
2. T08 — Battlefield Terrain & Tactical Map System
3. T09 — Cooperative Attack & Common Tactics
4. T10 — Battle UI/UX Renewal
5. T11 — Korea MVP Full Balance & Final Battle QA

T07–T10 complete the battle-engine feature set. Full campaign and numerical balance is intentionally deferred to T11.
