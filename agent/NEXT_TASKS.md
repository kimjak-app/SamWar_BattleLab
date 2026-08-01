# NEXT TASKS

## Completed QA locks

- T06-10H occupation portrait QA: PASS.
- T06-10I unique-skill Korean display QA: PASS.
- T06-11A enemy multi-actor turn orchestration QA: PASS.
- T06-11B engagement reservation and surround-pressure QA: PASS.
- T07 five-unit-type automated validation: PASS.
- T07 dedicated gunner and mounted-archer visual metadata: PASS.

## Current status

T07 is `IMPLEMENTED / AUTOMATED VALIDATION PASS / DEDICATED VISUALS BOUND / USER F5 QA PENDING`.

Preserve:

- T06 turn, momentum, unique-skill, cutin, Korean display, portrait, result, and save/load contracts.
- T07 five-unit-type IDs, action eligibility, gunner/mounted-archer behavior, manual/auto damage parity, and visual resources.
- Korea production roster assignments.
- T07 functional values until T11 balance work.

## Official roadmap

Authoritative document:

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`

Current order:

1. T07 — Five Unit-Type Battle Completion
2. T08 — Battle UI/UX Renewal
3. T09 — Battlefield Terrain & Tactical Map System
4. T10 — Cooperative Attack & Common Tactics
5. T11 — Korea MVP Full Balance & Final Battle QA

The former terrain-first order is superseded. Battle UI/UX is now completed before terrain and tactics.

## Next implementation

### T08-1 Battle UI/UX Current-State Audit & Production Information Architecture Design

Audit before changing production layout:

- `Battle_Land.tscn` battle UI node hierarchy
- current top bars, force overviews, selected-unit information, portraits, HP/troop/status presentation
- floating command panel and command enable/disable behavior
- movement, attack, unique-skill, facing, and strategy selection instructions
- momentum display and spend feedback
- battle log and important event messaging
- range/target overlays
- cutin enter/exit and post-cutin state restoration
- reinforcement/formation guidance
- 1920×1080 overlap, clipping, scaling, and tactical-grid obstruction
- runtime bindings and duplicated formatting logic

Deliverables:

- current-state audit
- production information hierarchy
- interaction/phase contract
- node/layout migration strategy
- implementation transaction split
- automated validator plan
- user F5 QA gates

Do not implement terrain or cooperative tactics during T08-1.
