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
- T08-1 current-state audit and production information architecture are complete.

## Official Roadmap Order

1. T07 — Five Unit-Type Battle Completion
2. T08 — Battle UI/UX Renewal
3. T09 — Battlefield Terrain & Tactical Map System
4. T10 — Cooperative Attack & Common Tactics
5. T11 — Korea MVP Full Balance & Final Battle QA

This order supersedes the previous terrain-first sequence. The battle screen is renewed before terrain and tactics so later systems can target a stable production-quality information and command layout.

## Authoritative T08/T09 Design Package

- `agent/transactions/T08_1_BATTLE_UI_UX_CURRENT_STATE_AUDIT_AND_PRODUCTION_INFORMATION_ARCHITECTURE_DESIGN.md`
- `agent/plans/T08_BATTLE_UI_UX_PRODUCTION_PLAN.md`
- `agent/plans/KOREA_MVP_BATTLEFIELD_ART_MASTER_PLAN.md`
- `agent/plans/T09_BATTLEFIELD_TERRAIN_HANDOFF_PLAN.md`

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

## Status

`T08-1 AUDIT COMPLETE / PRODUCTION IA LOCKED / T08-2 PLANNED`

## Goal

Replace the current test-oriented battle screen with a production-quality 1920×1080 interface suitable for normal play, demonstrations, crowdfunding, and investment presentations.

T08 precedes terrain and common tactics. The renewed UI must preserve extension points for terrain information, cooperative attacks, and tactics without prematurely implementing those systems.

## Locked Presentation Contract

- Production baseline: 1920×1080, 16:9.
- Ally momentum: starting `3`, maximum `10`, shown as `current / 10` plus a readable ten-stage gauge.
- Battle turn: shown as `current / 30`.
- Enemy momentum: starting `3`, maximum `10`, shown as `current / 10` plus a readable ten-stage gauge.
- Left ally roster and right enemy roster support the Korea MVP five-slot contract.
- Bottom comparison HUD shows current actor on the left and next AI actor, selected target, or counterattack target on the right according to interaction state.
- Major HUD roots are scene-authored; runtime code updates values and state.
- Hanseong is the only production template until user F5 approval.
- Defender role maps to city/fortress; attacker role maps to temporary camp independent of player/AI identity.

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

1. Audit the current battle scene, control nodes, runtime bindings, and user flow. `COMPLETE`
2. Lock a production information architecture and interaction contract. `COMPLETE`
3. Build a scene-authored production HUD skeleton and normalized UI-state adapter. `NEXT`
4. Produce and bind reusable text-free production UI assets.
5. Produce and integrate the Hanseong 4K master and 1080p derivative without terrain mechanics.
6. Complete interaction-state, cutin restoration, and user-facing disabled reasons.
7. Lock the reusable production template through automated and user F5 QA.

## Completion Gate

- Full existing battle flow is playable without debug knowledge.
- No overlapping or clipped critical UI at 1920×1080.
- Player/AI action presentation stays synchronized with battle state.
- Existing T06–T07 behavior and automated validators remain green.
- Terrain/tactics placeholders, if present, are non-interactive and do not simulate unimplemented systems.
- Hanseong passes both player-attacker and player-defender role tests.
- The same UI/camera/framing contract can be reused for Sabi, Gyeongju, and Pyongyang.

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
- Battlefield PNG pixels are never the authoritative terrain rule source.

## Hanseong Demonstration Gate

Hanseong is the first production terrain map and must demonstrate:

- normal traversable ground;
- costly or conditional terrain;
- impassable terrain;
- one major choke point;
- one alternate route;
- attacker camp deployment;
- defender city/fortress deployment;
- player/AI role parity.

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

- Do not begin T09 terrain implementation before the T08 production layout and Hanseong visual template are sufficiently stable for terrain presentation.
- Do not begin T10 tactics before their relationship with terrain and hero unique skills is specified.
- Do not move full numerical balance ahead of T11 unless a value blocks functional testing.
- Do not force gunner or mounted archer into the Korea production roster.
- Preserve T01–T07 completed contracts.
- Each stage must be split into auditable transactions with automated validation and user F5 gates.
- Do not hardcode ally/enemy identity to attacker/defender battlefield landmarks.

# Immediate Next Transaction

`T08-2 Scene-Authored Production HUD Skeleton & UI State Adapter`

This transaction creates the production HUD hierarchy and presentation-state adapter without final decorative assets, final Hanseong art, terrain behavior, cooperative attacks, or balance changes.