# T08 Roadmap Reorder — Battle UI/UX First

Status: `DECISION LOCKED / ROADMAP UPDATED / IMPLEMENTATION NOT STARTED`

## Decision

The post-T07 battle-engine order is officially changed to:

1. T08 — Battle UI/UX Renewal
2. T09 — Battlefield Terrain & Tactical Map System
3. T10 — Cooperative Attack & Common Tactics
4. T11 — Korea MVP Full Balance & Final Battle QA

This supersedes the former order in which terrain preceded the battle UI renewal.

## Rationale

The current battle screen remains test-oriented even though T06 and T07 have added:

- multi-unit player and enemy turns
- momentum and unique skills
- cutins
- Korean status/effect presentation
- five canonical unit types
- expanded action eligibility and battle states

Terrain and common tactics will add more information:

- hovered/selected cell properties
- movement costs and blocked reasons
- terrain modifiers
- cooperative participants and action consumption
- tactic targets, success/failure, and status outcomes

Adding these systems before locking the production information hierarchy would increase layout duplication and force later UI restructuring. T08 therefore establishes the production battle interface first, while leaving documented extension points for T09 and T10.

## T08 Scope

T08 renews the existing battle UI/UX for 1920×1080 without implementing terrain or common tactics.

Required areas:

- force overview
- round, active side, active unit, and phase state
- selected hero information
- HP, troops, unit type, action state, and statuses
- momentum
- current commands and disabled-state reasons
- selection instructions and cancel behavior
- battle logs and important messages
- range and target overlays
- cutin transitions
- reinforcement and formation information
- overlap, clipping, scaling, and tactical-grid obstruction

## Protected Contracts

- T01–T05 campaign behavior remains unchanged.
- T06 momentum, unique skills, cutins, Korean display, portraits, AI multi-actor flow, result settlement, and save/load remain unchanged.
- T07 five-unit-type behavior, functional values, canonical IDs, and visual resources remain unchanged.
- Korea production roster remains unchanged.
- Terrain and cooperative/common-tactic runtime behavior are explicitly out of scope for T08-1.

## Immediate Next Transaction

`T08-1 Battle UI/UX Current-State Audit & Production Information Architecture Design`

T08-1 is documentation and architecture work. It must audit the current scene and interaction flow before production layout implementation begins.

## Updated Files

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`
- `agent/NEXT_TASKS.md`
- `agent/HANDOFF_TO_CODEX.md`
- `agent/CURRENT_STATE.md`
- `agent/transactions/T08_ROADMAP_REORDER_BATTLE_UI_UX_FIRST.md`
