# T07–T11 Battle Engine MVP Completion Roadmap

## Purpose

This document locks the post-T06 battle-engine plan for the Korea MVP and future China, Japan, and Mongolia expansion.

T07–T10 are feature-completion stages for the land-battle engine. Full Korea MVP economy, war, and campaign balance is intentionally deferred until T11, after the battle feature set is stable.

## Current Locked Baseline

- T01–T05 Korea Four-City MVP world-turn, invasion, occupation, logistics, recovery, and unification flow are protected.
- T06 hero stats, loyalty, battle profiles, 39 unique skills, shared momentum, battle calculations, cross-scene hero authority, cutins, Korean effect display, and post-battle portrait parity are implemented.
- T06-11A enemy multi-actor turn orchestration passed automated validation and user F5 QA.
- T06-11B existing destination/engagement reservation and multi-direction surround pressure passed automated validation and user F5 QA.
- User F5 confirmed one Yi Sun-sin unit invading Sabi was surrounded and attacked by multiple enemies using momentum and unique skills.
- Current battle momentum test policy remains start 3 / max 10 until a later balance transaction explicitly changes it.
- Full campaign balance is not the immediate next task.

## Roadmap Order

1. T07 — Six Unit-Type Battle Completion
2. T08 — Battlefield Terrain & Tactical Map System
3. T09 — Cooperative Attack & Common Tactics
4. T10 — Battle UI/UX Renewal
5. T11 — Korea MVP Full Balance & Final Battle QA

The order may be adjusted when implementation dependencies or user visual design work require it, but each stage must preserve the contracts of completed earlier stages.

---

# T07 — Six Unit-Type Battle Completion

## Goal

Complete the runtime, AI, calculation, UI metadata, persistence, and round-trip contracts for all six planned land unit types, including firearm infantry and mounted archers.

The Korea MVP roster does not need to use firearm infantry or mounted archers. They are completed in advance for later Japan, China, and Mongolia content.

## Required Scope

- Audit the currently implemented and configured unit types.
- Lock the canonical six-unit-type identifiers and display names.
- Complete movement, attack range, valid target, counterattack, and facing contracts.
- Complete unit matchup metadata without final numerical balance lock.
- Complete AI movement and attack behavior for each type.
- Complete formation → battle → result → WorldMap/save round-trip parity.
- Complete auto-battle calculation parity.
- Complete combat log, tooltip, and status presentation.
- Ensure future roster data can assign the two expansion unit types without scene-specific patches.

## Firearm Infantry Direction

- High ranged impact and clear battlefield identity.
- Close-range or mobility weakness must be represented by an explicit contract rather than ad-hoc hero logic.
- Reload, firing cadence, minimum range, or post-move firing restrictions must be designed before implementation.
- Exact values are deferred to T11 unless a functional default is required for testing.

## Mounted Archer Direction

- High mobility and ranged pressure.
- Movement-after-attack, attack-after-move, disengagement, and distance-keeping behavior must be explicitly designed.
- It must not be implemented as a cavalry stat clone with a bow icon.
- Exact values are deferred to T11 unless a functional default is required for testing.

## Completion Gate

- Six canonical unit types validate through authoritative data, runtime factory, battle unit state, AI, calculation, UI, save/load, and battle-result round trip.
- Firearm infantry and mounted archers work in test/demo rosters without being added to the Korea production roster.
- Existing Korea roster unit assignments do not change unintentionally.

---

# T08 — Battlefield Terrain & Tactical Map System

## Goal

Make battlefield position and terrain materially affect movement and combat so that battle strategy is not determined only by hero and unit strength.

## Planned Terrain Set

- Plain
- Forest
- Hill or high ground
- Mountain
- Cliff
- River or shallow water
- Bridge
- Marsh or difficult ground where appropriate
- Wall, gate, or fortified cell where appropriate
- Impassable area
- Narrow passage

The final MVP terrain list may be reduced or expanded during T08 design, but the terrain data model must support later regional maps.

## Required Contracts

- Terrain ID and visual representation are separate.
- Traversable, conditionally traversable, and impassable cells are explicit.
- Movement cost and pathfinding consume the same authoritative terrain rules.
- Attack, defense, accuracy, range, line-of-sight, or status modifiers are explicit and testable.
- Unit-type/terrain interactions use shared data or helpers rather than scattered scene conditions.
- AI evaluates terrain cost and tactical value.
- Bridges and narrow paths naturally create choke points without cell overlap.
- Terrain effects survive save/load and deterministic battle setup where relevant.

## Example Design Directions

- Mountain or rough ground may reduce cavalry mobility and support infantry defense.
- Forest may affect ranged accuracy, concealment, ambush, or fire tactics.
- River crossing may increase movement cost or temporary vulnerability.
- Bridge cells may be traversable choke points.
- Cliff and blocked cells are impassable.
- High ground may support ranged or visibility bonuses.

These examples are not final balance values.

## Completion Gate

- At least one production-ready tactical map demonstrates passable terrain, costly terrain, impassable terrain, and a choke point.
- Player and AI movement obey the same terrain rules.
- Terrain modifiers are visible in UI/logs and covered by deterministic validation.

---

# T09 — Cooperative Attack & Common Tactics

## Goal

Expand combat beyond individual normal attacks and hero-exclusive unique skills through shared battlefield cooperation and common tactical commands.

## Cooperative Attack Scope

- Define when multiple allied units may participate in one coordinated action.
- Define action consumption for initiator and supporters.
- Define target, range, adjacency, facing, and eligibility rules.
- Prevent duplicate resolver application and duplicate momentum gain/spend.
- Preserve existing side/back directional multipliers unless a later explicit balance transaction changes them.
- Add clear combat logs and visual feedback.

The current side/back pressure contract is not automatically treated as a complete cooperative-attack system.

## Common Tactics Scope

Candidate tactics include:

- Fire attack
- Disruption
- Confusion
- Provocation
- Morale pressure
- Movement restriction
- Retreat-route pressure
- Ambush or concealment where terrain supports it

The exact MVP tactic set must be designed before implementation.

## Role Separation

- Hero unique skill: named hero-specific signature ability.
- Common tactic: battlefield command available through defined stats, unit types, items, formations, or commander roles.
- Terrain effect: passive battlefield rule.

These three layers must not duplicate or overwrite each other without an explicit stacking contract.

## Completion Gate

- Cooperative attack has one authoritative eligibility and resolution path.
- Common tactics have validation, execution, failure, log, UI, AI, and save/snapshot contracts.
- Fire and disruption-type tactics interact with terrain only through documented rules.

---

# T10 — Battle UI/UX Renewal

## Goal

Replace the current test-oriented battle screen with a production-quality 1920×1080 battle interface suitable for player use, demonstrations, crowdfunding, and investment presentations.

## Information Architecture

- Ally and enemy force overview
- Round and active-side state
- Shared momentum
- Selected hero portrait and core battle information
- HP, troops, action state, and status effects
- Move, normal attack, unique skill, cooperative attack, tactic, and wait commands as applicable
- Target-selection instructions
- Terrain information for hovered or selected cells
- Battle log and important event messages
- Cutin integration without obscuring critical state after playback
- Clear disabled-state reasons and validation failures

## UX Principles

- The player must understand whose turn it is, which unit is selected, what can be done, and why an action is unavailable.
- Internal IDs must never appear in user-visible labels.
- Important combat information should not require reading the debug log.
- The UI must support the full six-unit-type, terrain, cooperative-attack, tactic, status, and momentum feature set.
- Layout must be authored for 1920×1080 first, then validated for supported scaling behavior.

## Process

- First lock a visual and interaction design.
- Then rebuild the node/layout structure rather than merely decorating the current test UI.
- Temporary developer UI may be used during T07–T09, but final visual polish belongs here.

## Completion Gate

- Full battle flow is playable without debug knowledge.
- No overlapping or clipped critical UI at the target resolution.
- Player and AI action presentations remain synchronized with the underlying battle state.
- Existing cutin, portrait, Korean display, and result-settlement contracts remain intact.

---

# T11 — Korea MVP Full Balance & Final Battle QA

## Goal

Balance and lock the complete Korea Four-City MVP only after T07–T10 battle features are stable.

## Balance Scope

- Four-faction starting resources, troops, cities, and hero distribution
- City production and recovery
- Research cost and duration
- Invasion gold, food, salt, and logistics pressure
- Reinforcement and wounded recovery
- AI invasion frequency, target selection, defense retention, and repeated-war restraint
- Unit-type matchup values
- Terrain modifier values
- Cooperative attack and tactic values
- Unique-skill and momentum frequency in full battles
- Side/back multipliers if evidence requires revision
- Early, middle, and final-unification pacing
- Expected turn count and player session length

## Validation Scope

- Deterministic and repeated simulations
- 1v1 through multi-unit battle samples
- Player F5 campaign runs
- Victory, defeat, injury, death, retreat, occupation, save/load, and WorldMap return regression
- Performance and warning cleanup
- Final Korea MVP lock documentation

## Completion Gate

- No faction has a deterministic unavoidable early collapse or guaranteed runaway advantage without intentional design.
- The player can understand and influence campaign outcomes through economy, formation, heroes, unit types, terrain, tactics, and battle execution.
- Korea MVP reaches unification with an acceptable difficulty and play-time range.
- Final regression suite passes and the MVP battle/campaign baseline is locked.

---

# Protected Planning Rules

- Do not move full numerical balance work ahead of T11 unless a value blocks functional testing.
- Do not force firearm infantry or mounted archers into the Korea production roster.
- Do not implement tactics before their relationship with terrain and unique skills is specified.
- Do not perform the final UI renewal before the information requirements of T07–T09 are known.
- Fix reproducible defects when discovered, but do not use a hotfix to silently expand the next major stage.
- Each major stage must be split into auditable transactions with automated validation and user F5 gates.

# Immediate Next Transaction

T07-1 Six Unit-Type Current-State Audit & Canonical Contract Design

This transaction must inspect the current unit-type registry, generated hero battle profiles, runtime factory, battle state, resolver, AI, UI, auto-battle, result payload, and save/load paths before any firearm-infantry or mounted-archer production implementation begins.
