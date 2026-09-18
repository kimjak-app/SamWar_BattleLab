# B-1E | Action Lock State Boundary Audit

Date: 2026-09-18  
Branch: `refactor/engine-core-20260918`  
Baseline HEAD: `edfc67e25972b99031943c6575ccdf4b587c9d69`  
Verified workflow: `35340079442` — success

## 1. Current baseline

Current `scripts/battle_web_import_test.gd` at the audited HEAD:

- 661,683 bytes
- 15,806 lines
- 859 functions

B-1B owns movement queries.  
B-1C owns combat queries.  
B-1D owns pre-wounded damage formula calculation.

The next coherent responsibility is acted-unit bookkeeping used by turn alternation and battle resume.

## 2. Current action-lock state

Controller-owned registries:

- `acted_ally_unit_ids: Dictionary`
- `acted_enemy_unit_ids: Dictionary`

Compatibility/query functions:

- `_mark_ally_unit_acted`
- `_has_ally_unit_acted`
- `_reset_ally_action_locks_for_new_round`
- `_mark_enemy_unit_acted`
- `_has_enemy_unit_acted`
- `_reset_enemy_action_locks_for_new_round`
- `_are_all_alive_enemies_acted`
- `_are_all_alive_allies_acted`
- `_get_next_available_enemy_ai_actor`
- `_get_first_available_ally_unit`
- `_get_remaining_unacted_enemy_count`

The registries are also part of battle-resume persistence:

- snapshot keys `acted_ally_unit_ids`
- snapshot keys `acted_enemy_unit_ids`

They are restored after `BattleRuntimeSnapshot.restore()`, which already restores each unit's `has_acted` / `has_moved` flags.

Dead-unit cleanup erases the unit id from both acted registries.

## 3. B-1E extraction decision

Create:

`scripts/battle/services/battle_action_lock_state_service.gd`

Recommended:

```gdscript
class_name BattleActionLockStateService
extends RefCounted
```

The service owns **acted-id registry state and acted queries only**.

It should own:

- ally acted-id registry;
- enemy acted-id registry;
- side-aware acted lookup;
- first-time acted registration;
- side registry clear;
- dead-unit id erase;
- side snapshot export;
- side snapshot restore;
- unacted count / first-unacted / all-acted queries over supplied unit arrays.

The service must not own phase, turn sequencing, AI policy, status ticking, UI, logs, resume storage I/O, or WorldMap.

## 4. Important ownership boundary

B-1E must **not** move all action completion side effects into the service.

Keep these controller-side:

### Ally mark wrapper

Current behavior to preserve:

1. reject null;
2. reject non-ally;
3. reject empty `unit_id`;
4. determine whether already acted;
5. register acted id;
6. set `unit_state.has_acted = true`;
7. set `unit_state.has_moved = true`;
8. when actor is active unit, set controller mirror `ally_has_moved = true`;
9. only on first completion, consume strategy status.

The service may perform steps 4–5.  
Steps 6–9 remain controller-owned in B-1E.

### Enemy mark wrapper

Current behavior to preserve:

1. reject null;
2. reject non-enemy;
3. reject empty `unit_id`;
4. determine whether already acted;
5. register acted id;
6. set `unit_state.has_acted = true`;
7. set `unit_state.has_moved = true`;
8. only on first completion, consume strategy status;
9. only on first completion, print the existing `[ENEMY_TURN]` log with remaining count.

The service may perform steps 4–5.  
Steps 6–9 remain controller-owned in B-1E.

This keeps status consumption and logging out of the state service.

## 5. Exact query semantics lock

Preserve current `_has_ally_unit_acted` semantics:

- null -> `true`
- side != `ally` -> `false`
- empty `unit_id` -> `unit_state.has_acted`
- otherwise registry value with `unit_state.has_acted` fallback

Preserve current `_has_enemy_unit_acted` semantics:

- null -> `true`
- side != `enemy` -> `false`
- empty `unit_id` -> `unit_state.has_acted`
- otherwise registry value with `unit_state.has_acted` fallback

Do not normalize these asymmetries away.

## 6. Round-reset boundary

Keep controller wrappers:

- `_reset_ally_action_locks_for_new_round`
- `_reset_enemy_action_locks_for_new_round`

Service responsibility:

- clear the corresponding acted-id registry.

Controller responsibility remains:

- iterate supplied current alive units and call `unit_state.reset_action_flags()`;
- ally wrapper sets `ally_has_moved = false`;
- enemy wrapper calls `_clear_enemy_ai_turn_reservations()`.

Do not move `BattleUnitState.reset_action_flags()` ownership in B-1E. It resets more than acted state:

- `has_acted`
- `has_moved`
- `is_defending`
- `attacked_this_turn`
- post-attack movement flags
- `last_action`

That broader action lifecycle is outside this extraction.

## 7. Aggregate-query semantics

Preserve current empty-list behavior:

- `_are_all_alive_enemies_acted()`: empty enemy list -> `true`
- `_are_all_alive_allies_acted()`: empty ally list -> `false`

Do not replace both wrappers with one generic mathematical empty-set rule unless the wrapper explicitly preserves these results.

Stable actor ordering remains controller-owned:

- enemy actor candidates continue in existing slot order;
- ally candidate list continues to come from existing alive-unit ordering.

The service may choose first unacted from a supplied ordered list, but it must not construct or reorder candidate lists.

## 8. Resume-snapshot compatibility lock

Snapshot field names are external runtime compatibility:

- `acted_ally_unit_ids`
- `acted_enemy_unit_ids`

Do not rename them.

Controller remains owner of:

- `BattleRuntimeSnapshot.capture()`;
- `GameSession.save_battle_resume_snapshot()`;
- `GameSession.load_battle_resume_snapshot()`;
- `BattleRuntimeSnapshot.restore()`.

B-1E changes only how acted registries are exported/imported.

Required relationship:

```text
controller snapshot capture
  -> action_lock_state_service.export_acted_ids("ally" / "enemy")
  -> same existing extra_state keys

BattleRuntimeSnapshot.restore()
  -> restores unit has_acted / has_moved
controller extra_state restore
  -> action_lock_state_service.restore_acted_ids(...)
```

Restoring registry dictionaries must not independently mutate unit flags.

Use deep duplicates to preserve current snapshot isolation.

## 9. Dead-unit cleanup lock

Current cleanup erases a dead unit id from both acted registries.

Replace that direct dictionary ownership with a service API such as:

`erase_unit_id(unit_id)`

Do not move any other dead-unit cleanup, logs, visual hiding, targeting cleanup, result handling, or selection cleanup into B-1E.

## 10. Reset-demo lock

`reset_demo_state()` currently performs an early enemy acted-registry clear and later calls both action-lock reset wrappers.

Do not opportunistically remove the early clear as "redundant" in this task.

Route it through the service while preserving execution order.

No unrelated dead-code cleanup during B-1E.

## 11. Suggested service API

Exact names may vary, but the responsibility should remain equivalent:

```gdscript
func has_unit_acted(unit_state: BattleUnitState, expected_side: String) -> bool
func register_unit_acted(unit_state: BattleUnitState, expected_side: String) -> Dictionary
func clear_side(expected_side: String) -> void
func erase_unit_id(unit_id: String) -> void
func export_acted_ids(expected_side: String) -> Dictionary
func restore_acted_ids(expected_side: String, value: Variant) -> void
func count_unacted(unit_states: Array[BattleUnitState], expected_side: String) -> int
func first_unacted(unit_states: Array[BattleUnitState], expected_side: String) -> BattleUnitState
func are_all_acted(unit_states: Array[BattleUnitState], expected_side: String) -> bool
```

Recommended `register_unit_acted` result:

```gdscript
{
  "accepted": bool,
  "was_already_acted": bool
}
```

It must not mutate `BattleUnitState` in B-1E.

## 12. Compatibility wrapper strategy

Do not mass-rewrite existing callers.

Keep the controller functions named above and delegate bookkeeping/query work into the service.

This preserves:

- manual battle callers;
- auto battle callers;
- enemy AI callers;
- turn-order validators;
- ready-frame checks;
- move-target checks;
- resume flow;
- future scenario subclasses.

## 13. Focused regression requirements

Add:

`tests/scripts/test_battle_action_lock_state_service.gd`

Minimum cases:

1. null acted query -> true;
2. wrong-side query -> false;
3. empty unit id falls back to `unit_state.has_acted`;
4. first ally register accepted / not previously acted;
5. second ally register reports already acted;
6. equivalent enemy behavior;
7. ally/enemy registries remain isolated;
8. clear ally does not clear enemy;
9. clear enemy does not clear ally;
10. dead-id erase clears both sides;
11. export returns deep copy;
12. restore accepts Dictionary and deep-copies;
13. restore non-Dictionary -> empty registry;
14. first-unacted preserves supplied array order;
15. count-unacted parity;
16. all-acted true when all supplied units acted;
17. representative controller wrapper parity;
18. round-reset wrapper preserves `reset_action_flags()`;
19. ally reset preserves `ally_has_moved = false`;
20. enemy reset still clears AI reservations;
21. resume snapshot retains exact acted key names and round-trip values.

Do not write a test that can print PASS after a script compile/load failure. Reuse the established `Battle_Main.tscn` fixture approach.

## 14. Static validation requirements

Recommended:

`tools/validate_b1e_battle_action_lock_state_service.py`

At minimum assert:

- service and tracked `.gd.uid` exist;
- controller preloads/owns service;
- legacy acted Dictionary member ownership is removed from controller;
- compatibility wrappers remain;
- mark wrappers still mutate unit `has_acted` / `has_moved` controller-side;
- strategy-status consumption stays controller-side;
- enemy log stays controller-side;
- ally mirror stays controller-side;
- enemy AI reservation reset stays controller-side;
- snapshot keys unchanged;
- snapshot save/load remains controller-side;
- dead-unit cleanup delegates only acted-id erase;
- WorldMap entry remains `res://Battle_Land.tscn`;
- service contains no GameSession, BattleRuntimeSnapshot, phase/UI/AI/log/status ticking/WorldMap/result responsibilities.

Turn-order validator may be updated only where it locates ownership, not to weaken the behavioral assertions.

## 15. Explicitly out of scope

Do not change in B-1E:

- initiative order;
- ally/enemy alternation;
- `_get_next_side_after_enemy_action`;
- `_return_to_ally_turn`;
- `_start_new_round` sequencing;
- battle-round increment;
- supply settlement;
- reinforcement timing;
- AI target/action policy;
- movement/combat/damage services;
- status ticking/burn;
- unique-skill cooldowns;
- momentum;
- dead-unit behavior except acted-id erase delegation;
- resume schema/version;
- WorldMap/BattleContext/BattleResult;
- scene routing.

## 16. Decision

B-1E implementation task:

**Extract acted-id registry and acted-state queries into BattleActionLockStateService while keeping all action side effects and turn orchestration in the controller.**

Because this crosses many live callers plus resume/dead-cleanup boundaries, implementation should be delegated to Codex after this audit is locked.
