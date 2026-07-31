# T06-11A Enemy Multi-Actor Turn Orchestration Recovery

## Status

`IMPLEMENTED / ENEMY MULTI-ACTOR TURN ORCHESTRATION PASS / USER 1V4 F5 QA PENDING`

## User reproduction and root cause

- In a one-allied-unit versus three-to-four-enemy battle, only the first enemy actor moved or attacked. The other living enemies never received a turn.
- Individual enemy terminal paths in `scripts/battle_web_import_test.gd` marked the current actor acted and called `_return_to_ally_turn()` directly.
- `_return_to_ally_turn()` then treated “no remaining ally actor” as sufficient reason to call `_start_new_round()`. With one allied actor, that reset every enemy acted flag before the other enemies could act, so the fixed enemy selector chose the first actor again next round.

## Orchestration contract

- `_advance_enemy_turn_or_return_to_ally()` is the sole normal continuation after an enemy basic attack, move completion/wait/failure, no target/path, confusion, and unique-skill completion or commit failure.
- It checks battle end, cleans dead actors, selects the next living unacted enemy, and uses `call_deferred("_play_enemy_ai_for_actor", next_enemy_actor)` to avoid recursive Tween/signal re-entry.
- It clears enemy planning reservations only after no living unacted enemy remains, then returns to the ally-side transition.
- `_return_to_ally_turn()` defensively continues the enemy phase if an unacted living enemy remains.
- `_start_new_round(force_round_start := false)` now blocks ordinary flow unless both `_are_all_alive_allies_acted()` and `_are_all_alive_enemies_acted()` are true. Its explicit force argument is reserved for the existing T02 headless round-limit smoke; the regular battle flow never supplies it.
- Each living enemy is marked once at the end of its consumed action. Dead actors are excluded. Existing destination and engagement reservation selection is unchanged; reservations live through the enemy side and reset at existing side/round boundaries.

## Direct ally-return audit and final handling

| Previous direct completion location | Final handling |
| --- | --- |
| `_handle_unique_skill_commit_failure` | Mark enemy, then common advance helper |
| `_finalize_unique_skill_action` | Mark consumed action, then common advance helper |
| `_play_enemy_ai_turn` / invalid actor | Common advance helper |
| `_play_enemy_ai_for_actor` confusion, no target, wait, no path | Mark actor, then common advance helper |
| `_play_enemy_actor_basic_attack_from_current_cell` invalid actor/target | Mark when applicable, then common advance helper |
| `_play_enemy_actor_path_move_then_act` invalid actor/grid, blocked path, missing marker | Mark when applicable, then common advance helper |
| `_finish_enemy_actor_basic_move` / post-move wait | Common advance helper after consumed action |
| `_finish_enemy_actor_basic_attack` | Mark actor, then common advance helper |

The only remaining normal `_return_to_ally_turn()` invocation is inside the common helper after enemy-side completion; the other textual occurrence is its function declaration.

## Automated verification

- `tools/validate_enemy_multi_actor_turn_orchestration.gd`: `[ENEMY_TURN_TEST] PASS scenarios=8`.
  - 1v4 fixed actor ordering and no duplicate action.
  - 1v1 return boundary.
  - dead actor exclusion.
  - path failure/wait consumes only that actor and continues.
  - completed AI unique skill advances to the next actor.
  - battle end stops remaining actors.
  - new-round reset requires both sides complete.
- Headless project parse and `Battle_Land.tscn` load pass.
- Runtime logs are limited to `[ENEMY_TURN]` per newly acted actor/completion and `[ROUND_FLOW]` for defensive deferred/blocked transitions.

## User F5 QA

1. Start a battle with one deployed allied unit facing four living enemy units.
2. Consume the allied action.
3. Confirm all four living enemies move, attack, or wait once in the same enemy phase before ally control returns.
4. Confirm an enemy with no path does not end the phase, and an AI unique skill is followed by the next enemy actor.
5. Confirm battle end stops later actors and the next round grants each surviving enemy at most one action.

## Next

- T06-11B Existing Engagement Reservation & Surround Behavior Activation, only after the T06-11A user 1v4 gate passes.
