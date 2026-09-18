# B-1F | Codex Execution Brief — BattleEnemyAiReservationStateService

Repository: `kimjak-app/SamWar_BattleLab`  
Target branch: `refactor/engine-core-20260918`

Read first:

- `.agents/skills/samwar-dev/SKILL.md`
- `.agents/skills/samwar-dev/references/refactor.md`
- `.agents/skills/samwar-dev/references/regression.md`
- `.agents/skills/samwar-dev/references/closeout.md`
- `BATTLE_RUNTIME_REFACTOR_PLAN.md`
- `agent/BATTLE_ENGINE_B1F_ENEMY_AI_RESERVATION_STATE_AUDIT_20260919.md`
- `agent/BATTLE_ENGINE_RULES.md`

## Goal

Extract only enemy-AI per-turn destination/engagement reservation bookkeeping into:

`scripts/battle/services/battle_enemy_ai_reservation_state_service.gd`

Preserve battle behavior and AI policy exactly.

## Mandatory preflight

1. confirm target branch and exact HEAD;
2. protect unrelated changes;
3. re-read all direct `enemy_ai_reserved_*_cells` accesses;
4. confirm WorldMap still enters `res://Battle_Land.tscn`;
5. do not use historical line numbers as edit coordinates.

## Service ownership

Service owns:

- destination reservation dictionary;
- engagement reservation dictionary;
- clear both dictionaries;
- same-actor vs other-actor reservation lookup;
- reserve decision-plan destination/final cell.

Service does not receive or inspect scene nodes.

## Controller wrappers remain

Keep:

- `_clear_enemy_ai_turn_reservations`
- `_is_enemy_ai_destination_cell_reserved_for_other_actor`
- `_is_enemy_ai_engagement_cell_reserved_for_other_actor`
- `_reserve_enemy_ai_decision_plan_for_actor`
- `_can_enemy_ai_use_destination_cell`

Controller continues resolving `actor_slot_id` through `_get_capacity_slot_id_for_unit_state()`.

## Exact behavior lock

Do not change:

- actor current cell exemption;
- absent reservation behavior;
- own reservation behavior;
- other-actor reservation behavior;
- decision plan `destination` default;
- `final_cell` default to destination;
- destination/final-cell storage conditions;
- empty slot-id semantics.

## Round reset

Keep `_reset_enemy_action_locks_for_new_round()` ordering.

It must still call `_clear_enemy_ai_turn_reservations()` before resetting current alive enemy action flags.

## Existing B-1E test

Update the B-1E controller-parity test only where it directly reaches into the legacy reservation dictionaries. Replace that white-box dependency with wrapper-level reservation/clear assertions. Do not weaken its action-lock checks.

## Focused test

Add `tests/scripts/test_battle_enemy_ai_reservation_state_service.gd`.

Use direct state-service tests plus a `Battle_Main.tscn` controller wrapper parity fixture.

## Static validator

Add `tools/validate_b1f_battle_enemy_ai_reservation_state_service.py`.

Wire validator + focused test into `.github/workflows/verify-c-track.yml`.

## Validation gate

Required on the final target HEAD:

- B-1F focused service test;
- B-1F static validator;
- B-1E focused test still green;
- B-1B/B-1C/B-1D focused tests;
- alternating and single-side-exhaustion turn-order regressions;
- Godot import/class cache;
- project parse;
- Battle_Main load;
- Imjin ISO load;
- WorldMap load;
- full established workflow;
- clean generated `.gd.uid` state;
- `git diff --check`;
- WorldMap still on `res://Battle_Land.tscn`.

Do not call Full Green until exact-head CI succeeds.

## Forbidden service responsibilities

No:

- BattleUnitState mutation;
- pathfinding/movement query;
- AI target/action scoring;
- turn/phase sequencing;
- status/cooldown;
- logs;
- GameSession/snapshot;
- UI/FX/audio;
- WorldMap/BattleContext/BattleResult;
- signals/await/tween.

## Closeout

Report exact branch/HEAD, changed files, service API, wrapper parity, focused check count, regression status, CI run, upstream state, and remaining pre-existing warnings.

Do not begin B-1G.
