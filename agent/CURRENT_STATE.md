# CURRENT STATE

## Latest implemented stage

### T07 Five Unit-Type Battle Completion

Status: `IMPLEMENTED / AUTOMATED VALIDATION PASS / DEDICATED VISUALS BOUND / USER F5 QA PENDING`

- Canonical unit types are infantry, cavalry, archer, gunner, and mounted_archer.
- Shared movement/range/action eligibility, gunner runtime, mounted-archer runtime, manual/auto damage parity, persistence, and Korean labels are implemented.
- Dedicated gunner and mounted-archer token resources are connected through canonical visual metadata.
- Korea production roster assignments remain unchanged.

## Current roadmap decision

The official post-T07 order is now:

1. T08 — Battle UI/UX Renewal
2. T09 — Battlefield Terrain & Tactical Map System
3. T10 — Cooperative Attack & Common Tactics
4. T11 — Korea MVP Full Balance & Final Battle QA

This supersedes the earlier terrain-first sequence.

Reason:

- The current battle screen is still test-oriented.
- Terrain and common tactics will introduce additional cell, command, status, and disabled-state information.
- A stable production information hierarchy and interaction layout must exist before those systems are connected.

## Immediate next transaction

### T08-1 Battle UI/UX Current-State Audit & Production Information Architecture Design

Status: `PLANNED / NOT STARTED`

Required audit areas:

- `Battle_Land.tscn` UI node hierarchy and runtime bindings
- ally/enemy force overview
- round, active side, selected unit, and interaction phase presentation
- hero portrait, unit type, HP, troops, action state, and statuses
- floating command panel and disabled-state feedback
- movement, attack, unique skill, facing, and strategy selection guidance
- momentum presentation
- battle log and important messages
- range/target overlays
- cutin transition and state restoration
- reinforcement and formation guidance
- 1920×1080 overlap, clipping, scaling, and grid obstruction
- duplicated formatting and stale-state risks

T08-1 changes no terrain, cooperative-attack, common-tactic, or numerical balance behavior.

## Protected baseline

- T01–T05 Korea Four-City MVP campaign contracts remain protected.
- T06 hero authority, unique skills, momentum, cutins, Korean display, portraits, result settlement, save/load, and enemy multi-actor flow remain protected.
- T07 five-unit-type behavior and validation values remain protected until T11 unless a reproducible defect requires correction.
- Generated hero data remains authoritative.
- Player and AI must continue to share canonical action and calculation paths.

## Authoritative roadmap document

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`
