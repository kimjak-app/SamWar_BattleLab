# T06-11B Existing Engagement Reservation & Surround Behavior Activation

## Status

`IMPLEMENTED / ENEMY ENGAGEMENT RESERVATION PASS / SURROUND PRESSURE USER F5 QA PENDING`

## T06-11A gate

- T06-11A user F5 QA passed: a single Yi Sun-sin unit invading Sabi was approached and actioned by all three enemy units in the same enemy phase.
- The former first-enemy-only failure is therefore closed. This transaction audits only the existing multi-actor engagement path, without changing the T06-11A actor/round contract.

## Live reservation and engagement flow

```text
alive shared target candidates
→ _get_enemy_ai_decision_plan_for_actor()
→ _build_enemy_ai_target_action_plan_for_actor()
→ _get_enemy_engagement_step_plan_for_actor()
→ _get_enemy_engagement_candidate_cells()
→ _reserve_enemy_ai_decision_plan_for_actor()
→ move completion updates BattleUnitState.grid_cell
→ next enemy plans against actual occupancy plus retained reservations
```

- `enemy_ai_reserved_destination_cells: Dictionary` stores `destination cell → actor capacity-slot ID`.
- `enemy_ai_reserved_engagement_cells: Dictionary` stores `final engagement cell → actor capacity-slot ID`.
- `_get_target_candidates_for_actor_from_adapter()` returns all living deployed opponents, with no target reservation or target-exclusion rule. Multiple enemies may therefore select the same living ally.
- `_get_enemy_engagement_candidate_cells()` rejects out-of-bounds, occupied, and other-actor reserved engagement cells. `_get_enemy_engagement_step_plan_for_actor()` rejects other-actor reserved destination steps. Existing occupied-cell/path checks use the current `BattleUnitState.grid_cell`, so an earlier moved actor is seen by later planners.
- Reservations remain while the T06-11A continuation advances actors. They clear only once the enemy side finishes through `_advance_enemy_turn_or_return_to_ally()` or at the existing new-round reset.

## Surround helper decision

- `_should_enemy_use_surround_pressure_mode()` returns true for an enemy numerical advantage against one or two living allies, but it has no call site.
- It remains unconnected. The live decision path already invokes reservation-aware engagement candidates and passed the multi-direction planning validator. Connecting the dead helper would change selection behavior without a reproduced failure and is outside this minimal transaction.

## Directional/cooperative contract

- The current battle implementation has no distinct support/assist/cooperative damage resolver to activate.
- Its existing cooperative result is spatial: attackers formed at different target-relative cells can produce the existing side/back angle classifications, logs, and damage multipliers.
- No values changed. Validator parity confirms side `1.15` and back `1.30` multipliers.

## Automated verification

- `tools/validate_enemy_engagement_reservation_and_surround.gd`: `[ENEMY_SURROUND_TEST] PASS scenarios=8`.
  - Same target shared.
  - Destination and engagement-cell uniqueness.
  - At least two directional pressure sectors in sequential 1v4 planning.
  - Reservation retention and reset.
  - Blocked actor chooses an alternate destination.
  - Target movement replans against the new target cell.
  - Existing side/back eligibility and multiplier parity.
- No production AI source change was required; the validator and documentation lock the already-live behavior.

## User F5 QA

1. Invade Sabi with one Yi Sun-sin unit against three-to-four defenders.
2. End Yi Sun-sin's action and watch each enemy phase.
3. Confirm enemies do not select the same destination cell, and available routes form at least two meaningful approach directions rather than a forced single-file stop.
4. Confirm a blocked enemy chooses an alternate valid route when one exists; constrained terrain may legitimately create sequential approach.
5. Confirm existing `측면 공격!` / `후방 공격!` logs when the established directional conditions occur. No new cooperative damage rule is expected.

## Next

- Only pursue a further AI behavior transaction if this F5 gate identifies a concrete reservation, occupancy, or candidate-selection defect.
