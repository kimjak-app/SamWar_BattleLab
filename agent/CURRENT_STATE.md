# CURRENT STATE

## Latest implemented stage

### T07 Five Unit-Type Battle Completion

Status: `IMPLEMENTED / AUTOMATED VALIDATION PASS / DEDICATED VISUALS BOUND / USER F5 QA PENDING`

- Canonical unit types are infantry, cavalry, archer, gunner, and mounted_archer.
- Shared movement/range/action eligibility, gunner runtime, mounted-archer runtime, manual/auto damage parity, persistence, and Korean labels are implemented.
- Dedicated gunner and mounted-archer token resources are connected through canonical visual metadata.
- Korea production roster assignments remain unchanged.

## Latest completed design transaction

### T08-1 Battle UI/UX Current-State Audit & Production Information Architecture Design

Status: `AUDIT COMPLETE / PRODUCTION IA LOCKED / IMPLEMENTATION NOT STARTED`

Completed:

- Audited `Battle_Land.tscn` and `scripts/battle_web_import_test.gd` presentation structure.
- Confirmed current test-oriented coupling, mixed 1920×1080 and legacy 1152×648 assumptions, absolute layout, duplicated information surfaces, runtime-created momentum HUD risk, command label/handler mismatch risk, log duplication, cutin restoration requirements, and battlefield safe-zone requirements.
- Locked 1920×1080 production UI information architecture.
- Locked top HUD contract:
  - ally momentum `current / 10`;
  - battle turn `current / 30`;
  - enemy momentum `current / 10`.
- Confirmed authoritative momentum start `3` and maximum `10`.
- Locked current actor / next AI / selected target / counterattack HUD behavior.
- Locked Hanseong as the single production master template before Sabi, Gyeongju, and Pyongyang.
- Locked defender city/fortress and attacker temporary-camp role mapping independent of player/AI identity.
- Locked T08 art/presentation and T09 terrain-mechanics separation.

Authoritative documents:

- `agent/transactions/T08_1_BATTLE_UI_UX_CURRENT_STATE_AUDIT_AND_PRODUCTION_INFORMATION_ARCHITECTURE_DESIGN.md`
- `agent/plans/T08_BATTLE_UI_UX_PRODUCTION_PLAN.md`
- `agent/plans/KOREA_MVP_BATTLEFIELD_ART_MASTER_PLAN.md`
- `agent/plans/T09_BATTLEFIELD_TERRAIN_HANDOFF_PLAN.md`

## Current roadmap decision

The official post-T07 order remains:

1. T08 — Battle UI/UX Renewal
2. T09 — Battlefield Terrain & Tactical Map System
3. T10 — Cooperative Attack & Common Tactics
4. T11 — Korea MVP Full Balance & Final Battle QA

The production template is completed and approved on Hanseong first. Remaining Korea MVP battlefields inherit the locked UI/camera/framing contract.

## Immediate next transaction

### T08-2 Scene-Authored Production HUD Skeleton & UI State Adapter

Status: `PLANNED / NOT STARTED`

Required work:

- Add the production scene hierarchy in `Battle_Land.tscn` without changing battle rules.
- Make the major momentum, turn, roster, actor-comparison, guidance, log, global-command, tooltip, toast, cutin, and result roots scene-authored.
- Introduce normalized presentation-state mapping over existing runtime phases.
- Preserve all current T06–T07 actions, cutins, results, save/load, AI, and validators.
- Keep decorative art provisional until the skeleton and state adapter are validated.
- Do not implement terrain behavior.

## Protected baseline

- T01–T05 Korea Four-City MVP campaign contracts remain protected.
- T06 hero authority, unique skills, momentum, cutins, Korean display, portraits, result settlement, save/load, and enemy multi-actor flow remain protected.
- T07 five-unit-type behavior and validation values remain protected until T11 unless a reproducible defect requires correction.
- Momentum starts at `3` and is capped at `10`.
- Maximum battle turn remains `30`.
- Generated hero data remains authoritative.
- Player and AI must continue to share canonical action and calculation paths.
- T08 must not add T09 terrain rules or T10 tactics.

## Authoritative roadmap document

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`