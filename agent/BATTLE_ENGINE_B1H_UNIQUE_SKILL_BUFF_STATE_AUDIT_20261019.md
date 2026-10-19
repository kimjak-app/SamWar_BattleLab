# B-1H | Unique Skill Buff State Boundary Audit

Date: 2026-10-19  
Branch base: `integration/p1-engine-core-20261019`  
Plan revision: `BRP-20260919-1`  
Auditor: 클코치 (independent of the builder)

## Decision

The next extraction is the unique-skill **buff bookkeeping** only: the three controller dictionaries that track attack-buff turns/bonus and defense-buff bonus per unit id.

Current controller-owned state (`scripts/battle_web_import_test.gd`):

- `unique_skill_attack_buff_turns_by_unit_id: Dictionary` (line ~959)
- `unique_skill_attack_buff_bonus_by_unit_id: Dictionary` (line ~960)
- `unique_skill_defense_buff_bonus_by_unit_id: Dictionary` (line ~961)

Direct users: `reset_demo_state()` (~3064-3066 clear), status-icon entries (~3893, ~3900), AI target/candidate selection (~4246, ~4321), skill execution (~5403-5423), and the helper block (~5567-5636).

## New owner

`scripts/battle/services/battle_unique_skill_buff_state_service.gd` (`extends RefCounted`, pure bookkeeping)

Suggested API:

```gdscript
clear()
has_active_attack_buff(key) -> bool
get_attack_buff_bonus(key) -> int
set_attack_buff(key, bonus, turns)
get_defense_buff_bonus(key) -> int
set_defense_buff(key, bonus)
tick_attack_buff(key) -> Dictionary   # {"expired": bool, "restore_bonus": int}
```

`tick_attack_buff` returns what the controller must do; the service never touches `BattleUnitState`.

## Controller boundary (stays in the controller)

- unit -> key resolution (`_get_unique_skill_attack_buff_key`, `_get_unique_skill_defense_buff_key`);
- `unit_state.attack += / -=` and `caster_state.defense +=` mutation;
- which units are alive/deployed for a side and the side/round sequencing;
- call order: cooldown tick first, then attack-buff tick (inside `_tick_unique_skill_cooldowns_for_side`);
- `_refresh_formation_slot_guides()` and `_refresh_strategy_status_icon_labels()` calls after the tick loop;
- skill target/effect policy, AI policy, FX, logs;
- all thin wrapper functions (names and signatures unchanged).

## Asymmetries that MUST be preserved (do not "fix")

1. **Defense buff never expires.** No tick, no revert of `defense`. `_set_unique_skill_defense_buff_state` max-merges (`maxi(current, bonus)`) and never lowers.
2. **Attack buff getter returns 0 when turns <= 0**, even if a bonus entry exists. `has_active` is `turns > 0`.
3. **Attack setter overwrites** bonus (no max-merge) and clamps turns with `maxi(turns, 0)`.
4. **Defense key rejects empty `unit_id`; attack key rejects only null** (the attack key helper returns `unit_state.unit_id`, so an empty id yields `""` and is rejected by the `buff_key == ""` checks downstream). Both end up ignoring empty keys; keep each wrapper's own guard.
5. **Tick:** skip when remaining <= 0; decrement; on reaching 0 restore `attack - bonus` **only when bonus > 0**, floored at 0 (`maxi(0, ...)`), then erase both turns and bonus entries; otherwise write back remaining.
6. The attack buff is applied only to units without an active attack buff (`_has_active_unique_skill_attack_buff` gate in both apply and AI selection).

## Out of scope

Cooldown service (B-1G, already extracted), `BattleUnitState` fields, skill metadata, momentum cost, round/phase orchestration, resume snapshot schema, WorldMap/BattleContext/BattleResult, scene routing.

## Separate finding (NOT part of B-1H — behavior decision for 김작)

Buff dictionaries are **not saved in the resume snapshot** (only `cooldowns` is, at ~6593 / ~6627). If the unit's already-buffed `attack` value is restored but the buff turns are lost, the attack bonus can become permanent after resume. B-1H must keep this behavior byte-for-byte (no `export_state`/`restore_state` wiring, no schema change). Whether to persist buffs is a gameplay decision handled in its own task after B-1H.

## Validation level

Level 2 scoped regression (state extraction, no snapshot schema change, no routing change):

- focused service test with the asymmetries above pinned one by one;
- static validator (service purity, controller wrappers delegate, three dictionaries gone from the controller, call order cooldown-then-buff kept, snapshot keys unchanged);
- neighbor tests: B-1E/B-1F/B-1G state services, movement/combat query services;
- Godot parse / `Battle_Main` load when the environment allows.

Do not call Full Green without a Level 3 checkpoint.
