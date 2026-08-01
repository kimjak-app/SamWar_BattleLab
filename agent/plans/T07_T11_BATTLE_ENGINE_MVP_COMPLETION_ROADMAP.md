# T07–T11 Battle Engine MVP Completion Roadmap

## Purpose

This document is the authoritative post-T06 battle-engine roadmap for the Korea MVP and later China, Japan, and Mongolia expansion.

T07–T10 complete battle-engine features. T11 performs final Korea MVP campaign and numerical balance only after the feature set is stable.

## Current Locked Baseline

- T01–T05 Korea Four-City MVP world-turn, invasion, occupation, logistics, recovery, and unification contracts are protected.
- T06 hero authority, five-stat data, 39 unique skills, shared momentum, battle calculation, result parity, cutins, Korean display, and multi-actor enemy flow are implemented.
- T07 five-unit-type runtime, AI, manual/auto damage parity, persistence, Korean labels, and dedicated gunner/mounted-archer visuals are implemented.
- T07 remains `IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F5 QA PENDING`.
- Korea production roster assignments remain unchanged.
- Full numerical balance remains deferred to T11.

## Official Roadmap Order

1. T07 — Five Unit-Type Battle Completion
2. T08 — Battle UI/UX Renewal
3. T09 — Battlefield Terrain & Tactical Map System
4. T10 — Cooperative Attack & Common Tactics
5. T11 — Korea MVP Full Balance & Final Battle QA

This order supersedes the previous terrain-first sequence. The battle screen is renewed before terrain and tactics so later systems can target a stable production-quality information and command layout.

---

# T07 — Five Unit-Type Battle Completion

## Status

`IMPLEMENTED / AUTOMATED VALIDATION PASS / DEDICATED VISUALS BOUND / USER F5 QA PENDING`

## Locked Result

- Canonical unit types: infantry, cavalry, archer, gunner, mounted_archer.
- Player and AI share movement, range, counterattack, and action-eligibility contracts.
- Gunner prepared fire, armor penetration, post-fire penalty, and AI behavior are implemented.
- Mounted-archer mobile ranged behavior and battle snapshot state are implemented.
- Manual and auto battle consume shared unit-type damage metadata.
- Dedicated gunner and mounted-archer token resources are bound without changing canonical unit IDs.
- T07 functional values remain unchanged until T11 unless a reproducible defect requires a hotfix.

---

# T08 — Battle UI/UX Renewal

## Goal

Replace the current test-oriented battle screen with a production-quality 1920×1080 interface suitable for normal play, demonstrations, crowdfunding, and investment presentations.

T08 precedes terrain and common tactics. The renewed UI must preserve extension points for terrain information, cooperative attacks, and tactics without prematurely implementing those systems.

## Required Information Architecture

- Ally and enemy force overview.
- Round, active side, active unit, and current interaction phase.
- Shared momentum and spend/availability feedback.
- Selected hero portrait, name, unit type, HP, troops, action state, and status effects.
- Move, normal attack, unique skill, defend/wait, and currently implemented commands.
- Clear target-selection instructions and cancel/back behavior.
- Disabled command reasons shown in Korean.
- Battle log and important event messages separated by importance.
- Cutin playback that returns cleanly to readable battle state.
- Formation/reinforcement status where currently relevant.

## UX Principles

- The player must immediately understand whose turn it is, which unit is selected, what can be done, and why an action is unavailable.
- Internal IDs must never appear in user-visible text.
- Important information must not require reading debug output.
- The interface must preserve T06 cutin, portrait, momentum, unique-skill, status, and result contracts.
- The interface must preserve T07 five-unit-type labels and command eligibility.
- Layout is authored for 1920×1080 first and then checked for supported scaling.
- Critical UI must not overlap, clip, obscure the tactical grid, or remain stale after turn/phase changes.

## Process

1. Audit the current battle scene, control nodes, runtime bindings, and user flow.
2. Lock a production information architecture and interaction contract.
3. Separate state formatting from layout where practical.
4. Rebuild or reorganize nodes rather than merely decorating the current test UI.
5. Add deterministic UI-state validators and user F5 gates.

## Completion Gate

- Full existing battle flow is playable without debug knowledge.
- No overlapping or clipped critical UI at 1920×1080.
- Player/AI action presentation stays synchronized with battle state.
- Existing T06–T07 behavior and automated validators remain green.
- Terrain/tactics placeholders, if present, are non-interactive and do not simulate unimplemented systems.

---

# T09 — Battlefield Terrain & Tactical Map System

## Goal

Make battlefield position and terrain materially affect movement and combat after the renewed UI can clearly present cell and terrain information.

## Planned Terrain Set

- Plain
- Forest
- Hill or high ground
- Mountain or rough ground
- Cliff or impassable area
- River or shallow water
- Bridge
- Marsh or difficult ground where appropriate
- Wall, gate, or fortified cell where appropriate
- Narrow passage

The final MVP terrain list may be reduced during T09 design, but the data model must support later regional maps.

## Required Contracts

- Terrain ID and visual representation are separate.
- Traversable, conditionally traversable, and impassable cells are explicit.
- Movement cost and pathfinding consume the same authoritative terrain rules.
- Combat modifiers are explicit, deterministic, and testable.
- Unit-type/terrain interactions use shared data or helpers.
- Player and AI obey the same terrain and movement-cost rules.
- Bridges and narrow paths create choke points without overlap.
- Terrain information is visible through the T08 UI contract.
- Relevant deterministic battle setup and snapshot state survive save/load.

## Completion Gate

- At least one production-ready tactical map demonstrates normal, costly, impassable, and choke-point terrain.
- Player and AI movement obey identical terrain rules.
- Terrain effects are visible in UI/logs and covered by deterministic validation.

---

# T10 — Cooperative Attack & Common Tactics

## Goal

Expand combat beyond individual normal attacks and hero-exclusive unique skills through shared battlefield cooperation and common tactical commands.

## Cooperative Attack Scope

- Authoritative eligibility and resolution path.
- Initiator/supporter action consumption.
- Target, range, adjacency, facing, and participation rules.
- Duplicate resolver and duplicate momentum prevention.
- Clear logs, UI feedback, AI evaluation, and persistence behavior.
- Existing side/back multipliers remain protected until T11 unless explicitly changed.

## Common Tactics Scope

Candidate tactics include fire attack, disruption, confusion, provocation, morale pressure, movement restriction, retreat-route pressure, and terrain-supported ambush or concealment.

The exact MVP set must be designed before implementation.

## Layer Separation

- Hero unique skill: named hero-specific ability.
- Common tactic: shared battlefield command unlocked by explicit rules.
- Terrain effect: passive or cell-driven battlefield rule.

These layers require an explicit stacking and precedence contract.

## Completion Gate

- Cooperative attacks use one validated eligibility and resolution path.
- Common tactics have validation, execution, failure, Korean display, UI, AI, and snapshot contracts.
- Terrain interactions consume only the documented T09 terrain contract.

---

# T11 — Korea MVP Full Balance & Final Battle QA

## Goal

Balance and lock the complete Korea Four-City MVP after T07–T10 feature completion.

## Balance Scope

- Starting resources, troops, cities, and hero distribution.
- Production, research, recovery, and invasion logistics.
- AI invasion frequency, target selection, defense retention, and repeated-war restraint.
- Unit-type matchup values.
- Terrain modifiers.
- Cooperative attack and tactic values.
- Unique-skill and momentum frequency.
- Side/back multipliers if evidence requires revision.
- Early, middle, and unification pacing.
- Expected turn count and session length.

## Validation Scope

- Deterministic and repeated simulations.
- 1v1 through multi-unit battle samples.
- Player F5 campaign runs.
- Victory, defeat, injury, death, retreat, occupation, save/load, and WorldMap return regression.
- Performance and warning cleanup.

## Completion Gate

- No faction has an unintended deterministic collapse or runaway advantage.
- Players can influence outcomes through economy, formation, heroes, unit types, UI clarity, terrain, tactics, and battle execution.
- Korea MVP reaches unification within an acceptable difficulty and play-time range.
- Final regression suite passes and the MVP baseline is locked.

---

# Protected Planning Rules

- Do not begin T09 terrain implementation before T08 UI/UX audit and production layout contract are locked.
- Do not begin T10 tactics before their relationship with terrain and hero unique skills is specified.
- Do not move full numerical balance ahead of T11 unless a value blocks functional testing.
- Do not force gunner or mounted archer into the Korea production roster.
- Preserve T01–T07 completed contracts.
- Each stage must be split into auditable transactions with automated validation and user F5 gates.

# Immediate Next Transaction

`T08-1 Battle UI/UX Current-State Audit & Production Information Architecture Design`

This transaction must inspect the current `Battle_Land` scene, battle HUD nodes, floating command panel, selected-unit information, momentum/status displays, overlays, logs, cutin transitions, disabled-state feedback, scaling behavior, and runtime bindings before production layout implementation begins.
