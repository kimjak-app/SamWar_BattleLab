# B-1E | Codex Execution Brief — BattleActionLockStateService

Repository: `kimjak-app/SamWar_BattleLab`  
Branch: `refactor/engine-core-20260918`

Read first:

- `.agents/skills/samwar-dev/SKILL.md`
- `.agents/skills/samwar-dev/references/refactor.md`
- `.agents/skills/samwar-dev/references/regression.md`
- `.agents/skills/samwar-dev/references/closeout.md`
- `BATTLE_RUNTIME_REFACTOR_PLAN.md`
- `agent/BATTLE_ENGINE_B1E_ACTION_LOCK_STATE_AUDIT_20260918.md`
- `agent/BATTLE_ENGINE_RULES.md`

## Goal

Extract controller-owned acted-id registry state/query responsibility into:

`scripts/battle/services/battle_action_lock_state_service.gd`

Recommended:

```gdscript
class_name BattleActionLockStateService
extends RefCounted
```

Preserve battle behavior, initiative order, action completion side effects, and resume compatibility exactly.

## Mandatory preflight

Before editing:

1. confirm branch `refactor/engine-core-20260918`;
2. fetch and record local HEAD / origin HEAD / upstream;
3. inspect `git status --short`;
4. protect unrelated user changes; no reset/restore/stash/delete;
5. re-read current functions and all direct acted-registry accesses;
6. confirm B-1D final exact-head CI green;
7. confirm WorldMap still enters `res://Battle_Land.tscn`;
8. do not use historical line numbers as edit coordinates.

## Service ownership

Move the two acted-id registries out of the controller and into the service.

Service owns:

- side-specific acted-id dictionaries;
- has-acted query semantics;
- register-first-action bookkeeping;
- clear side;
- erase unit id from both sides;
- export/restore acted dictionaries;
- aggregate queries over supplied ordered unit arrays.

Service must not mutate `BattleUnitState` in B-1E.

## Controller wrappers must remain

Keep these public/internal surfaces:

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

Do not mass-rewrite their callers.

## Mark-wrapper behavior lock

For ally and enemy wrappers, preserve current validation, then use the service for prior-state query + registry mark.

After the service call, controller must still set:

```gdscript
unit_state.has_acted = true
unit_state.has_moved = true
```

Ally wrapper additionally keeps:

- `ally_has_moved = true` when the marked unit is the active unit;
- first-action-only `_consume_strategy_status_after_unit_action(unit_state)`.

Enemy wrapper additionally keeps:

- first-action-only status consumption;
- exact existing `[ENEMY_TURN]` logging;
- current remaining-unacted count behavior.

Do not move any of those side effects into service.

## Exact has-acted semantics

For each side preserve:

- null -> true;
- wrong side -> false;
- empty unit_id -> unit.has_acted fallback;
- otherwise registry lookup with unit.has_acted fallback.

No "cleanup" or unification that changes these results.

## Round reset

Service only clears acted registry.

Controller wrappers still:

- call `reset_action_flags()` on current alive side units;
- ally: set `ally_has_moved = false`;
- enemy: call `_clear_enemy_ai_turn_reservations()`.

Do not move `reset_action_flags()` into the service.

## Aggregate queries

Service may implement count/first/all over supplied ordered arrays.

Preserve wrappers' special empty behavior:

- no enemies -> all enemies acted = true;
- no allies -> all allies acted = false.

Do not let the service reorder units.

## Resume persistence

Preserve exact snapshot keys:

- `acted_ally_unit_ids`
- `acted_enemy_unit_ids`

Capture must export deep-copied dictionaries from the service.

Restore order remains:

1. `BattleRuntimeSnapshot.restore()` restores unit runtime flags;
2. controller reads `extra_state`;
3. controller restores acted registries into service.

Do not mutate unit flags when restoring acted registries.

Do not change snapshot schema version.

Do not move `GameSession` calls into the service.

## Dead cleanup

Replace direct:

- `acted_ally_unit_ids.erase(unit_id)`
- `acted_enemy_unit_ids.erase(unit_id)`

with one service operation that erases the id from both registries.

Nothing else in dead cleanup moves.

## reset_demo_state

Preserve the current early enemy registry clear even though later reset wrappers clear both sides.

Route it through the service; do not remove it as redundant.

## Suggested service API

Equivalent API is acceptable:

```gdscript
has_unit_acted(unit_state, expected_side)
register_unit_acted(unit_state, expected_side)
clear_side(expected_side)
erase_unit_id(unit_id)
export_acted_ids(expected_side)
restore_acted_ids(expected_side, value)
count_unacted(unit_states, expected_side)
first_unacted(unit_states, expected_side)
are_all_acted(unit_states, expected_side)
```

`register_unit_acted` should return enough data for controller to distinguish rejected vs first vs repeated completion without causing controller-side logic changes.

## Forbidden service responsibilities

No:

- `unit_state.has_acted =`
- `unit_state.has_moved =`
- `reset_action_flags()`
- status tick/consume;
- battle log or print;
- phase or round sequencing;
- AI reservation/policy;
- GameSession;
- BattleRuntimeSnapshot;
- UI/FX/audio;
- movement/combat/damage formula;
- WorldMap/BattleResult/BattleContext;
- signals/await/tween.

## Focused test

Add:

`tests/scripts/test_battle_action_lock_state_service.gd`

Cover every minimum case from the audit, including snapshot export/restore isolation and representative controller wrapper parity.

Use `Battle_Main.tscn` fixture for controller parity; do not directly preload controller in a way that bypasses autoload/class setup.

If fixture audio starts, use established fixture-audio teardown.

Test must exit nonzero on compile/load/parity failure.

## Static validator

Add:

`tools/validate_b1e_battle_action_lock_state_service.py`

Wire validator and focused test into `.github/workflows/verify-c-track.yml`.

Existing validators may be updated only to follow ownership relocation; do not weaken behavioral checks.

## Validation gate

Required:

- focused action-lock state test;
- B-1E static validator;
- B-1B movement 30/0;
- B-1C combat query 29/0;
- B-1D damage formula 33/0;
- alternating action-order validator/runtime test;
- one-side-exhaustion turn-order regression;
- five-unit-type validators;
- Godot 4.6 import/class cache;
- project parse;
- Battle_Main load;
- Imjin ISO load;
- WorldMap load;
- full established workflow;
- `git diff --check`;
- generated `.gd.uid` understood/clean;
- WorldMap remains on `res://Battle_Land.tscn`.

Scan final logs for hidden:

- `SCRIPT ERROR`
- `Compile Error`
- `Failed to load script`
- `Invalid call`

Do not call Full Green if any new occurrence is caused by B-1E.

## Closeout

Report:

- final branch + exact HEAD;
- changed files;
- service API;
- wrapper behavior;
- resume snapshot compatibility;
- dead cleanup delegation;
- focused check count/failures;
- static validator;
- turn-order regressions;
- hidden-error scan;
- full CI run id/status/head;
- worktree clean;
- local/origin ahead/behind;
- remaining pre-existing warnings.

Do not begin B-1F.
