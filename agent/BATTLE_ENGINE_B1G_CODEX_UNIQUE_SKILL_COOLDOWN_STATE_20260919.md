# B-1G | Execution Brief — BattleUniqueSkillCooldownStateService

Repository: `kimjak-app/SamWar_BattleLab`  
Target branch: `refactor/engine-core-20260918`

## Goal

Move only `unique_skill_cooldowns_by_hero_id` ownership into a focused RefCounted state service while preserving all existing unique-skill, round, buff, and resume behavior.

## Required service

`scripts/battle/services/battle_unique_skill_cooldown_state_service.gd`

Recommended API:

```gdscript
clear()
set_remaining(cooldown_key, turns)
get_remaining(cooldown_key)
tick_keys(cooldown_keys)
export_state()
restore_state(value)
```

## Compatibility locks

Controller wrappers remain and resolve hero IDs/controller state.

`_tick_unique_skill_cooldowns_for_side(side)` must:

1. gather current alive/deployed unit cooldown keys;
2. delegate cooldown decrement to the service;
3. still call `_tick_unique_skill_attack_buffs_for_side(side)` afterward.

Resume key remains exactly `cooldowns`.

`reset_demo_state()` clears the service instead of the legacy dictionary.

## Forbidden service ownership

No BattleUnitState, skill metadata, side/phase/round, buffs, AI policy, GameSession, BattleRuntimeSnapshot, UI, logs, WorldMap, BattleContext, BattleResult, signals, await, tween, or audio.

## Validation

Add focused GDScript test and static validator, register them in the established verification workflow, and preserve B-1E/B-1F tests.
