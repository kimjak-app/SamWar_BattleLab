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

T08-1 is `AUDIT COMPLETE / PRODUCTION IA LOCKED`.

T08-2 is `SPEC LOCKED / LOCAL IMPLEMENTATION PENDING / FINAL ART DEFERRED`.

Preserve:

- T06 turn, momentum, unique-skill, cutin, Korean display, portrait, result, and save/load contracts.
- T07 five-unit-type IDs, action eligibility, gunner/mounted-archer behavior, manual/auto damage parity, and visual resources.
- Korea production roster assignments.
- Momentum start `3`, maximum `10`.
- Battle maximum turn `30`.
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

## T08 authoritative design package

Read before implementation:

- `agent/transactions/T08_1_BATTLE_UI_UX_CURRENT_STATE_AUDIT_AND_PRODUCTION_INFORMATION_ARCHITECTURE_DESIGN.md`
- `agent/transactions/T08_2_SCENE_AUTHORED_PRODUCTION_HUD_SKELETON_AND_UI_STATE_ADAPTER.md`
- `agent/plans/T08_BATTLE_UI_UX_PRODUCTION_PLAN.md`
- `agent/plans/KOREA_MVP_BATTLEFIELD_ART_MASTER_PLAN.md`
- `agent/plans/T09_BATTLEFIELD_TERRAIN_HANDOFF_PLAN.md`

Locked direction:

- 1920×1080 production UI.
- Top-center ally momentum `x/10`, turn `x/30`, enemy momentum `x/10`.
- Left ally roster and right enemy roster.
- Bottom current actor / next AI or selected target comparison HUD.
- Scene-authored major HUD roots; runtime updates values and state only.
- Hanseong is the single UI/battlefield master template.
- Defender side uses the city/fortress; attacker side uses the temporary camp regardless of player/AI identity.
- 4K battlefield masters with 1080p runtime derivatives.
- T08 prepares visual terrain language only; T09 implements passability and terrain rules.

## Next implementation

### T08-2 Scene-Authored Production HUD Skeleton & UI State Adapter

Authoritative scope:

- `agent/transactions/T08_2_SCENE_AUTHORED_PRODUCTION_HUD_SKELETON_AND_UI_STATE_ADAPTER.md`

Required scope:

- Add a scene-authored `ProductionHudRoot` hierarchy to `Battle_Land.tscn`.
- Add separate scene-authored ally/enemy ten-slot momentum displays and turn `current / 30` display.
- Add ally/enemy five-slot roster HUDs.
- Add current actor / next AI / selected target / counterattack comparison HUD behavior.
- Add one visible interaction guidance and disabled-reason surface.
- Introduce one normalized production HUD state boundary and one identifiable refresh entry.
- Correct the visible command label/handler mismatch without changing battle semantics.
- Route the visible production log from one canonical recent-event source.
- Restore the production HUD from current authoritative battle state after cutins/toasts/results.
- Keep working battle behavior intact.
- Keep final decorative textures provisional.
- Preserve player and AI flow, WorldMap context, cutins, results, supply, save/resume, and all T06–T07 validators.

Deliverables:

- production scene skeleton;
- normalized UI phase/state mapping;
- one coherent refresh adapter;
- compatibility binding to existing battle runtime;
- focused node/binding validator;
- Godot parse/load validation;
- user F5 QA checklist and result field.

Do not:

- implement terrain IDs, passability, movement cost, or modifiers;
- generate or integrate the final Hanseong 4K battlefield yet;
- add cooperative attacks or new common tactics;
- rebalance momentum or units;
- delete working legacy UI before parity is proven.