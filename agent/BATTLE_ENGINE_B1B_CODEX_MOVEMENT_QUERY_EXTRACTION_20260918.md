# B-1B | Codex Execution Brief — BattleMovementQueryService

Use the repository skill automatically:

- `.agents/skills/samwar-dev/SKILL.md`
- `.agents/skills/samwar-dev/references/refactor.md`
- `.agents/skills/samwar-dev/references/regression.md`
- `.agents/skills/samwar-dev/references/closeout.md`

Read first:

- `BATTLE_RUNTIME_REFACTOR_PLAN.md`
- `agent/BATTLE_ENGINE_B1A_CURRENT_FUNCTION_AUDIT_20260918.md`
- `agent/BATTLE_ENGINE_RULES.md`

## Goal

Extract generic synchronous Grid/Path query logic from `scripts/battle_web_import_test.gd` into:

`scripts/battle/services/battle_movement_query_service.gd`

Preserve observable behavior exactly.

## Preflight

Before edits:

1. confirm branch is `refactor/engine-core-20260918`;
2. record current HEAD and upstream;
3. inspect worktree and protect unrelated changes;
4. re-read the current controller functions instead of trusting historical line numbers;
5. confirm `scripts/worldmap/worldmap_main.gd` still uses `res://Battle_Land.tscn`;
6. use the repository's existing CI/test commands; do not invent replacements.

## Implementation contract

Create `BattleMovementQueryService` as a focused `RefCounted` production service.

Move/delegate only the calculation responsibility described in the B-1A audit.

Keep the existing controller wrapper method names intact. Existing external callers should not need a broad rewrite.

Controller wrappers must continue to own:

- controller-state null guards where applicable;
- current active/enemy actor selection;
- existing diagnostic log strings;
- `ALLOW_BREAKTHROUGH_MOVE` value;
- scene/runtime orchestration.

The service must not own:

- UI nodes;
- animation/tweens;
- input;
- signals/await/timers;
- phase transitions;
- AI target/destination scoring;
- WorldMap handoff;
- battle result mutation.

## Pathfinding parity

Preserve BFS semantics exactly.

Neighbor order is locked:

```gdscript
Vector2i(1, 0)
Vector2i(-1, 0)
Vector2i(0, 1)
Vector2i(0, -1)
```

Do not replace BFS with A*, navigation APIs, sorting, diagonal movement, or a different traversal order.

Do not optimize behavior while extracting it.

## Controller wrappers to preserve

At minimum preserve these names and return shapes:

- `_get_effective_move_range`
- `_get_occupied_cells_except`
- `_is_cell_occupied_except`
- `_is_valid_destination_for_unit`
- `_is_path_clear_for_unit`
- `_is_cell_walkable_for_ally`
- `_find_ally_move_path`
- `_is_cell_walkable_for_enemy_actor`
- `_find_enemy_move_path_for_actor`
- `_find_enemy_path_to_destination_for_actor`
- `_get_enemy_reachable_paths_for_actor`
- `get_unit_grid_distance`

Do not delete zero-caller compatibility wrappers in this task.

## Tests to add

Add a focused headless test, recommended path:

`tests/scripts/test_battle_movement_query_service.gd`

Cover:

- deterministic empty-grid path;
- deterministic occupied detour;
- occupied destination;
- max-step rejection;
- breakthrough behavior;
- reachable-path max range and blockers;
- mobility-up/down/clamp;
- Manhattan distance;
- representative wrapper parity.

Add a static validator, recommended path:

`tools/validate_b1b_battle_movement_query_service.py`

It should at least assert:

- production service exists;
- tracked `.gd.uid` exists;
- controller preloads/owns the service;
- wrapper method names still exist;
- WorldMap battle scene path is unchanged;
- no forbidden WorldMap or result-contract ownership moved into the service.

Register the focused test/validator in the existing verification workflow for this refactor branch.

## Forbidden changes

Do not change:

- combat formulas or unit-type data;
- attack-range behavior;
- AI decision ranking;
- move animation timing;
- signals / awaits / timers;
- facing rules or visuals;
- ISO projection;
- HUD geometry;
- BattleContext/BattleResult shape;
- WorldMap battle entry;
- `Battle_Land.tscn` production path;
- existing scenario identity/rosters.

## Validation

Run targeted validation first, then the repository's full established regression workflow.

Do not claim Full Green unless the final commit SHA is the same SHA verified by CI.

## Closeout report

Report:

- branch + exact HEAD;
- new service path;
- controller wrappers changed;
- tests/validators added;
- targeted results;
- full CI run ID/status;
- worktree state;
- any remaining risk.

Do not begin a second responsibility extraction in the same task.
