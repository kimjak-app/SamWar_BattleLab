# T06-1 Hero Data Contract

Status: `DESIGN COMPLETE / IMPLEMENTATION NOT STARTED`

## Purpose

Lock the approved 39-hero data contract before any runtime migration, external JSON loading, balance application, role passive implementation, momentum implementation, or unique-skill implementation.

This document supersedes stale planning references to 41 heroes. The protected runtime registry and the approved design workbook both contain 39 heroes.

## Approved Sources

- Runtime audit source: `scripts/worldmap/hero_definition_registry.gd`
- Approved design workbook: `삼국WAR_장수39명_고유기_최종확정본.xlsx`
- Prior discussion reference: `T06_HERO_STAT_SKILL_DESIGN_DECISIONS.md`

The workbook is a human-facing design master. Runtime data will be generated as reviewable text data in a later transaction; Godot will not read XLSX directly.

## Roster Contract

- Canonical roster count: 39
- Canonical hero key: `hero_id`
- Hero order must remain stable during migration.
- No hero may be added, removed, renamed, or merged during the data-pipeline transaction.
- Stale 41-hero references are not implementation authority.

## Core Stat Contract

- `leadership`: canonical command stat.
- `command`: duplicate legacy field; remove only through an audited compatibility migration.
- `attack`: canonical martial stat.
- `intelligence`: canonical strategy stat.
- `politics`: canonical administration/diplomacy stat.
- `war`: reserved legacy field; do not reinterpret or delete in the first migration.
- `troops`: canonical troop-count field name going forward.
- `troop_count`: compatibility read only until later cleanup.

Approved display labels:

- leadership: 지휘력
- attack: 무력
- intelligence: 지력
- politics: 정치

## Battlefield Multiplier Contract

- `land_multiplier`: approved per-hero land-battle multiplier.
- `naval_multiplier`: preserved per approved workbook values; naval-system behavior remains deferred.
- Multipliers are data, not permission to redesign Battle formulas in the import transaction.

## Unit Type Contract

Allowed values:

- `infantry`
- `cavalry`
- `archer`
- `gunner`
- `mounted_archer`
- `support`

The approved workbook assignment is authoritative for the 39-hero design set. Adding `gunner`, `mounted_archer`, or `support` runtime behavior is a later bounded implementation transaction.

## Battlefield Role Contract

Allowed primary and secondary values:

- `assault`
- `vanguard`
- `defender`
- `commander`
- `mobile`
- `ranged`
- `tactician`
- `support`

Only the primary role applies a combat passive in MVP. The secondary role is descriptive and reserved for later extension.

## Role Passive Direction

- assault: melee damage +10%
- vanguard: first attack +12%
- defender: damage taken -8%; defense stance additional -5%
- commander: allies within radius 2 attack +5% and damage taken -5%; self excluded; no stacking
- mobile: flank/rear damage +8%
- ranged: range 2 or greater damage +8%
- tactician: status success +10%; debuff magnitude +8%
- support: buff/heal/momentum recovery +12%

Exact runtime insertion points and stacking caps require separate implementation audit.

## Unit Base Rule Direction

- infantry: move 3, range 1; damage taken -5%; defense stance additional -10%
- cavalry: move 4, range 1; after moving at least 2 tiles damage +12%; flank/rear +8%
- archer: move 3, range 3; stationary shot +8%; adjacent enemy increases damage taken +10%
- gunner: move 2, range 3; defense ignore 20%; loaded shot +15%; attack next turn -40%
- mounted_archer: move 4, range 2; may move before/after attack; flank +6%; base attack -8%; damage taken +8%
- support: move 3, range 1; buff/heal/momentum effects +15%; attack -20%

These values are approved design data. They are not implemented by this document.

## Unique Skill Identity Contract

- One unique skill per hero in MVP.
- Stable skill ID format: `<hero_id>_unique`
- Display name is separate from skill ID.
- Renaming a display name must not change saved or runtime references.

Required corrections:

- 광개토대왕: `영락대제`
- 의자왕: `삼천궁녀`
- `대백제` and `대백제 진군` are deleted concepts and must fail validation.

## Unique Skill Trigger Contract

- `momentum_cost`: 3 for all 39 skills
- `action_cost`: 1 for all 39 skills
- `min_battle_turn`: 0
- `hp_condition`: null / unused in MVP
- `cooldown_turns`: deprecated; do not populate in generated canonical data

## Momentum Contract

One independent pool per side:

- starting value: 3
- per completed battle round: +1
- successful attack by side: +1
- hit taken by side: -1
- additional cooperative-attack hit penalty: -1
- additional unique-skill hit penalty: -1
- cap: 10
- unique skill consumption: 3
- cooperative attack consumption: 2

Hero stats do not modify momentum gain or cap in MVP.

## Unique Skill Range and Radius Contract

Definitions:

- range: maximum distance from acting hero to selected target point or unit
- radius: affected area around the selected center
- radius 0: single target or line resolution
- radius 1: small close-area effect
- radius 2: normal multi-unit buff/debuff
- radius 3: exceptional battlefield-scale command/formation effect

Approved exceptional radius-3 skills include:

- 학익진
- 영락대제
- 청해진
- 위무의령
- 왕좌책략
- 팔진도
- 인의지덕
- 태합호령
- 에도의 인내
- 초원의 정복자

Specific approved examples:

- 개혁령: self-centered, range 0, radius 2
- 영락대제: self-centered, range 0, radius 3
- 나당연합: allied area, range 3, radius 2
- 삼천궁녀: enemy area, range 3, radius 2
- 학익진: enemy area, range 4, naval radius 3, land radius 2
- 팔진도: area, range 4, radius 3
- 인의지덕: self-centered, range 0, radius 3

Global `all_allies` application is rejected. Multi-unit effects must use positional areas.

## Control and Momentum Safety Rules

- Guaranteed full action denial is rejected for MVP.
- Prefer movement reduction, increased momentum cost, reduced attack/accuracy, or low-probability delay.
- Area momentum recovery is limited to side-pool +1.
- Same-turn momentum-recovery stacking must be prevented.
- `에도의 인내` must not grant recurring per-turn momentum.

## Naval/Land Compatibility

Naval-specialized heroes must retain a reduced land effect until naval battle exists.

- 학익진: naval radius 3; land radius 2 with reduced effect.
- 청해진: naval radius 3; land radius 2 with reduced ranged/support effect.

## Data Externalization Contract

Planned pipeline:

`approved workbook -> validator/converter -> generated JSON + validation report -> Godot compatibility loader -> registry facade`

Rules:

- XLSX is not loaded at runtime.
- Generated JSON and validation output are the reviewable Git artifacts.
- The first loader must preserve the current WorldMap, save/load, BattleContext, battle return, and hero runtime-state contracts.
- Registry replacement must be adapter-first; no mass rewrite.
- The binary workbook may be retained as a design attachment, but generated text data is the code-review authority.

## Required Validator Failures

The converter must fail with an actionable report when any of these occurs:

- hero count is not 39
- duplicate or missing `hero_id`
- hero order differs from approved order
- invalid unit type or role
- missing or duplicate skill ID
- skill ID is not `<hero_id>_unique`
- momentum cost is not 3
- action cost is not 1
- HP condition is populated
- deprecated cooldown is populated
- radius is outside 0–3
- obsolete `대백제`, `대백제 진군`, or `영락대전` appears
- required `영락대제` or `삼천궁녀` entry is missing

## Explicit Non-Goals

- Runtime code modification
- Save-schema modification
- Battle formula redesign
- Troop formula activation
- Casualty split tuning
- Momentum implementation
- Six-unit implementation
- Role passive implementation
- Unique-skill execution implementation
- AI unique-skill decision logic
- Cutin or VFX implementation
- Sound effects; sound is reserved for the final polish stage

## Next Transaction

`T06-2 Hero Workbook Schema & Validator/Converter`

The next transaction may add schema documentation, conversion tooling, generated JSON, and a validation report only. It must not add the Godot loader or change runtime behavior.