# B-1G | Unique Skill Cooldown State Boundary Audit

Date: 2026-09-19  
Branch: `refactor/engine-core-20260918`  
Baseline HEAD: `84d04814b54c3e418b0edbf3944ab022a830d62c`

## Decision

The next extraction is the unique-skill cooldown registry only.

Current controller-owned state:

- `unique_skill_cooldowns_by_hero_id: Dictionary`

Current direct responsibilities:

- clear during `reset_demo_state()`;
- set cooldown after a unique skill completes;
- decrement cooldowns once per round for alive deployed units of each side;
- query remaining cooldown for UI/action availability;
- persist under the exact resume key `cooldowns`;
- restore from the exact resume key `cooldowns`.

## New owner

Create:

`scripts/battle/services/battle_unique_skill_cooldown_state_service.gd`

The service owns only cooldown dictionary bookkeeping:

- clear;
- set remaining turns;
- get remaining turns;
- tick supplied hero-id keys once each;
- deep-copy export;
- deep-copy restore.

## Controller boundary

Keep controller ownership of:

- unit -> hero-id resolution via `_get_unique_skill_cooldown_key()`;
- which units are alive/deployed for a side;
- side/round sequencing;
- the existing call order where cooldown tick is followed by attack-buff tick;
- unique skill metadata lookup and readiness policy;
- unique skill execution;
- all buff dictionaries and buff mutation;
- resume capture/load I/O via BattleRuntimeSnapshot/GameSession.

Compatibility wrappers remain:

- `_get_unique_skill_cooldown_key`
- `_set_unique_skill_cooldown`
- `_tick_unique_skill_cooldowns_for_side`
- `_get_unique_skill_remaining_cooldown_turns`

## Exact behavior locks

- empty cooldown key -> ignored on set, 0 on query;
- set clamps turns to >= 0;
- ticking decrements only values > 0;
- duplicate hero ids tick only once per call;
- zero entries are not opportunistically erased;
- `_tick_unique_skill_cooldowns_for_side()` still ticks unique-skill attack buffs after cooldown bookkeeping;
- snapshot key remains exactly `cooldowns`;
- restore does not change unit state, skill metadata, phase, or round;
- no snapshot schema/version change.

## Out of scope

Do not move or change:

- attack/defense buff dictionaries;
- `BattleUnitState.attack` mutation;
- skill target/effect execution;
- momentum cost;
- AI unique-skill policy;
- round/phase orchestration;
- WorldMap/BattleContext/BattleResult;
- scene routing.

## Validation level

This is a narrow state extraction with snapshot participation but no schema change. Under the current SamWar protocol use Level 2 scoped regression:

- focused B-1G service test;
- B-1G static validator;
- B-1E/B-1F neighboring state-service tests;
- existing unique-skill/turn-order checks where available;
- Godot parse/Battle_Main load when execution environment is available.

Do not call Full Green without a Level 3 checkpoint.
