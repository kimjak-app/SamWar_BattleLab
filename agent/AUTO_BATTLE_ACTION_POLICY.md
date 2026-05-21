# AUTO BATTLE ACTION POLICY

## Scope
- Baseline: `v0.65i-3 READY/Facing UI Slot Registry Cleanup Stable`
- This step is design and documentation only.
- No scene change.
- No script change.
- No auto battle button implementation yet.

## 1. Basic Purpose

Auto battle should decide actions without manual clicks, using `BattleUnitState` data and existing grid/combat rules.

Primary goals:
- Choose the next actionable unit for the current side.
- Build the list of living enemies.
- Judge whether an attack is possible from the current cell.
- Choose the best attack target by policy.
- If no attack is possible, choose the best movement target.
- After movement, re-check attack possibility.
- If attack is still impossible, wait.
- Mark action completion and move to the next actor or next turn.

Important direction:
- This is not a click overlap policy.
- Auto battle should use:
  - `BattleUnitState`
  - `grid_cell`
  - `attack_range`
  - `hp`
  - `side`
  - `has_acted`
- `ClickArea` should not be part of auto battle decision logic.

## 2. Auto Action Core Flow

Expected high-level flow:

1. Find actionable units for the current side.
2. Select the next acting unit.
3. Build the list of living enemy units.
4. Search enemies already attackable from the current cell.
5. If attackable targets exist, choose one by target priority policy and attack.
6. If no attackable target exists, search movement candidates.
7. Choose the best movement destination.
8. Move there if a valid destination exists.
9. Re-check attackable targets after movement.
10. If attackable targets now exist, choose one by the same target priority policy and attack.
11. If no valid attack is available, wait.
12. Mark the actor as completed.
13. Continue with the next actor for the same side, or hand over turn flow to the next side.

## 3. Shared Data Model Direction

Auto battle should be designed as a side-agnostic policy layer on top of current battle data.

Recommended policy inputs:
- `actor_state: BattleUnitState`
- `actor_side: String`
- `living_allies: Array[BattleUnitState]`
- `living_enemies: Array[BattleUnitState]`
- `reachable_cells: Array[Vector2i]` or `Dictionary[cell -> path]`
- `current_phase`
- action flags such as:
  - `has_acted`
  - `has_moved`

Recommended policy outputs:
- `action_type`
  - `attack_now`
  - `move_then_attack`
  - `move_then_wait`
  - `wait`
- `target_unit`
- `move_target_cell`
- optional debug fields:
  - chosen score
  - rejected reason
  - candidate list summary

## 4. Target Priority Policy Draft

This step does not change balance. It only defines the intended priority order.

Recommended target priority:

1. Killable target first
- Prefer targets that can be finished this action if the current combat system says the hit is valid.
- In current code, exact kill prediction may need a later helper if damage preview is not exposed as a reusable function yet.
- Until then, this can remain a planned priority layer.

2. Currently attackable target
- If a target is already in range, prefer immediate attack over movement.

3. Lower HP target
- Prefer targets with lower current HP among otherwise valid candidates.

4. Closer target
- Prefer lower `get_unit_grid_distance()`.

5. Main slot priority
- Prefer major slot targets when earlier conditions tie.
- Expected slot preference:
  - `enemy_main` over `enemy_support`
  - `ally_main` over `ally_support`
- This should remain a policy layer, not a hardcoded click rule.

6. Stable array order fallback
- If every earlier score is tied, preserve existing array order.
- This keeps deterministic behavior and reduces hidden randomness.

### Suggested target scoring shape

The future implementation can normalize these into a tuple-like score:

- `can_kill`
- `is_attackable_now`
- `target_hp_low`
- `distance`
- `slot_priority`
- `original_index`

Sorting should be deterministic and stable.

## 5. Movement Destination Priority Draft

Movement should only be evaluated when no current-cell attack is available.

Recommended movement priority:

1. Cell that enables attack after move
- Highest priority is a destination where the actor can attack at least one valid enemy after moving.

2. Cell that reduces distance to the best target
- If no attack-enabling cell exists, prefer cells that reduce distance toward the best target.

3. Occupied cell avoidance
- Do not move into occupied cells.
- Respect current occupancy rules and alive-unit blocking.

4. Path clear requirement
- Only consider destinations with a valid clear path.

5. Higher follow-up attack potential
- If multiple cells are equivalent, prefer the cell that gives better next-step attack chances.
- Example interpretation:
  - more enemies in future range
  - stronger target access
  - shorter remaining distance next turn

6. Wait if no useful move exists
- If no valid move improves the tactical state, the actor should wait.

### Movement evaluation notes

- Auto battle should not invent a second movement rule set.
- It should reuse the same destination validity and path rules already used by manual control and current enemy AI.
- A move should be selected only if it is legal under the existing grid and path constraints.

## 6. Side-Agnostic Actor Selection Policy

Recommended selection policy for the next actor:

1. Collect living units of the current side.
2. Exclude units with `has_acted == true` or equivalent acted-lock state.
3. Preserve deterministic slot order if no stronger rule is needed.

Current expected stable order:
- Ally side:
  - `ally_main`
  - `ally_support`
- Enemy side:
  - `enemy_main`
  - `enemy_support`

This matches the current battle loop style and keeps auto battle predictable.

## 7. Proposed One-Action Decision Sequence

For one acting unit:

1. Validate actor:
- alive
- correct side
- not already acted

2. Immediate attack check:
- gather living enemies
- filter with `is_unit_in_attack_range(actor, target)`
- if any exist, choose best target and attack

3. Movement planning:
- gather legal reachable destinations
- score destinations
- choose the best destination

4. Post-move attack check:
- re-run target selection from the new cell context
- if attackable target exists, attack
- otherwise wait

5. Completion:
- set action completion flags using existing acted-state flow

## 8. Reusable Existing Function Candidates

The following current functions appear reusable for auto battle implementation.

### Strong reusable candidates
- `_get_alive_enemy_targets()`
  - current ally-facing living enemy list helper
- `_get_alive_ally_units()`
  - living ally list helper
- `_get_alive_enemy_units()`
  - living enemy list helper
- `is_unit_in_attack_range(attacker, target)`
  - direct attack-range check
- `get_unit_grid_distance(attacker, target)`
  - deterministic Manhattan distance
- `_is_valid_destination_for_unit(target_cell, mover_state, should_log = false)`
  - destination legality check
- `_is_path_clear_for_unit(path, mover_state, should_log = false)`
  - path blocking check
- `_find_ally_move_path(start_cell, target_cell)`
  - current ally path search
- `_find_enemy_move_path_for_actor(enemy_actor_state, start_cell, target_cell)`
  - current enemy actor path search
- `_choose_enemy_basic_ai_destination_for_actor(enemy_actor_state, target_state)`
  - current enemy destination heuristic that can inform shared policy design
- `_get_next_available_enemy_ai_actor()`
  - existing enemy acted-order helper
- `_has_ally_unit_acted(unit_state)`
  - ally acted-state helper
- `_has_enemy_unit_acted(unit_state)`
  - enemy acted-state helper

### Useful related current helpers
- `_get_enemy_ai_target_state_for_actor(enemy_actor_state)`
  - current enemy target heuristic reference
- `_find_best_attack_target_for_active_ally()`
  - current ally immediate target selection reference
- `_get_enemy_reachable_paths_for_actor(enemy_actor_state, start_cell)`
  - current enemy reachable-cell scan reference
- `_get_first_available_ally_unit()`
  - current ally order helper
- `is_cell_occupied(cell)`
  - occupancy query

### Notes on reuse quality
- Ally and enemy path helpers are currently asymmetric.
- Existing enemy AI helpers are useful references, but auto battle should move toward side-agnostic shared helpers where practical.
- `_get_alive_enemy_targets()` is ally-oriented by name and current scope; future shared auto battle helpers may need side-neutral wrappers.

## 9. Recommended Future Helper Layer

Before full auto battle, introduce neutral helpers that do not depend on click flow or one-side naming.

Recommended helper concepts:
- `_get_alive_units_for_side(side: String)`
- `_get_opposing_alive_units_for_side(side: String)`
- `_has_unit_acted_for_side(unit_state: BattleUnitState)`
- `_get_next_available_actor_for_side(side: String)`
- `_get_attackable_targets_for_actor(actor_state: BattleUnitState, targets: Array[BattleUnitState])`
- `_score_auto_battle_target(actor_state: BattleUnitState, target_state: BattleUnitState)`
- `_get_reachable_cells_for_actor(actor_state: BattleUnitState)`
- `_score_auto_battle_destination(actor_state: BattleUnitState, cell: Vector2i, preferred_target: BattleUnitState)`
- `_plan_auto_battle_action_for_actor(actor_state: BattleUnitState)`

These should remain wrappers around existing battle rules rather than new battle rules.

## 10. Risks And Guardrails

### Main risks
- Accidentally creating a second rule set that diverges from manual battle behavior
- Reusing enemy AI logic too literally and making ally auto battle behave unevenly
- Hidden nondeterminism when several targets or cells tie
- Coupling auto battle to UI or click-area state

### Guardrails
- Use `BattleUnitState` and grid rules only.
- Do not use `ClickArea` or mouse hit tests.
- Reuse current movement and range checks wherever possible.
- Keep tie-break rules explicit and deterministic.
- Keep auto battle as one-action planning first, full loop second.

## 11. Final Recommendation

1. Build auto battle on existing `BattleUnitState` and grid legality helpers, not on UI state.
2. Keep target selection deterministic with explicit priority order.
3. Prefer immediate valid attacks over speculative movement.
4. Reuse current path and occupancy rules exactly.
5. Add side-agnostic helper wrappers before connecting UI or full-loop automation.
6. Implement ally one-action MVP before adding a full auto battle button or loop.

## 12. Proposed Next Steps

- `v0.65j-2 Auto Battle Helper Functions Scaffold`
- `v0.65j-3 Ally Auto Battle One-Action MVP`
- `v0.65j-4 Auto Battle Button Hook`
- `v0.65j-5 Full Auto Battle Loop Prototype`
