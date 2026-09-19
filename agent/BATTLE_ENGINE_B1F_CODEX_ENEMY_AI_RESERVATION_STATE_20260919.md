# B-1F | Codex Execution Brief — BattleEnemyAiReservationStateService

Repository: `kimjak-app/SamWar_BattleLab`  
Target branch: `refactor/engine-core-20260918`  
Plan revision: `BRP-20260919-1`  
Recommended validation: **Level 2 — Scoped regression**

Generic permission, preflight, validation, CI, reading, and closeout rules come from:
- `agent/WORKFLOW_MANAGER.md`
- `.agents/skills/samwar-dev/SKILL.md`

Do not expand this brief into a repository-wide checklist.

## Goal

Extract only enemy-AI per-turn destination/engagement reservation bookkeeping into:

`scripts/battle/services/battle_enemy_ai_reservation_state_service.gd`

Preserve battle behavior and AI policy exactly.

## Task-specific context

Use:
- `agent/BATTLE_ENGINE_B1F_ENEMY_AI_RESERVATION_STATE_AUDIT_20260919.md`
- current B-1 status / next action in Sections 11–13 of `BATTLE_RUNTIME_REFACTOR_PLAN.md`
- only the relevant invariants in `agent/BATTLE_ENGINE_RULES.md`

Because the plan revision is declared above, do not reread the entire plan if `BRP-20260919-1` is already loaded for the current track.

## Service ownership

Service owns:
- destination reservation dictionary
- engagement reservation dictionary
- clear both dictionaries
- same-actor vs other-actor reservation lookup
- reserve decision-plan destination/final cell

Service does not receive or inspect scene nodes.

## Controller wrappers remain

Keep:
- `_clear_enemy_ai_turn_reservations`
- `_is_enemy_ai_destination_cell_reserved_for_other_actor`
- `_is_enemy_ai_engagement_cell_reserved_for_other_actor`
- `_reserve_enemy_ai_decision_plan_for_actor`
- `_can_enemy_ai_use_destination_cell`

Controller continues resolving `actor_slot_id` through `_get_capacity_slot_id_for_unit_state()`.

## Exact behavior locks

Do not change:
- actor current-cell exemption
- absent reservation behavior
- own-vs-other reservation semantics
- decision-plan `destination` default
- `final_cell` default to destination
- destination/final-cell storage conditions
- empty slot-id semantics
- `_reset_enemy_action_locks_for_new_round()` ordering

The round reset must still clear enemy-AI reservations before resetting alive enemy action flags.

## Existing B-1E test

Update the B-1E controller-parity test only where it directly reaches into legacy reservation dictionaries. Replace that white-box dependency with wrapper-level reservation/clear assertions. Do not weaken action-lock coverage.

## Focused implementation checks

Add:
- `tests/scripts/test_battle_enemy_ai_reservation_state_service.gd`
- `tools/validate_b1f_battle_enemy_ai_reservation_state_service.py`

Wire the new focused test/validator into `.github/workflows/verify-c-track.yml`.

For this **Level 2** task, the required scoped evidence is:
- B-1F focused service test
- B-1F static validator
- B-1E focused test because B-1F changes its white-box dependency
- relevant project parse / `Battle_Main.tscn` load needed to prove the changed controller/service path compiles and loads
- scoped diff / generated `.gd.uid` review

Do **not** automatically rerun B-1B/B-1C/B-1D, full WorldMap/Imjin suites, full established workflow, or exact-head CI solely for B-1F. Escalate to Level 3 only if the implementation crosses the declared boundary or a checkpoint/full-green request is made.

## Forbidden service responsibilities

No:
- BattleUnitState mutation
- pathfinding/movement query
- AI target/action scoring or policy
- turn/phase sequencing
- status/cooldown
- logs
- GameSession/snapshot
- UI/FX/audio
- WorldMap/BattleContext/BattleResult
- signals/await/tween

## Finish condition

Report only the scoped Level 2 evidence and changed ownership. Do not require CI/upstream/full-project proof unless the task escalated to Level 3.

Do not begin B-1G.
