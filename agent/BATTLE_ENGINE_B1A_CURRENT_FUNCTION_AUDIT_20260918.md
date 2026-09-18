# B-1A | Current Battle Function Audit + First Extraction Boundary

Date: 2026-09-18  
Branch: `refactor/engine-core-20260918`  
Audited HEAD: `1a9b8fb05323f825ca9ef5f8adbe3d61f64872c3`  
Verified workflow: `35290623012` — success

## 1. Why this audit exists

The older `agent/BATTLE_ENGINE_REFACTOR_FUNCTION_MAP.md` is useful as historical risk classification, but its line/function counts are stale and its line numbers must not be used as an execution map for B-1.

Current `scripts/battle_web_import_test.gd` metrics at the audited HEAD:

- file size: 669,000 bytes
- line count: 16,046
- function count: 859
- const count: 326
- `@onready var` count: 230
- preload count: 14

Older map baseline was 14,810 lines / 791 functions. B-1 implementation must use the current source, not the old line map.

## 2. B-1 first extraction decision

First extraction family:

**Grid / Path Query**

Why this is first:

- calculation-heavy and synchronous;
- no signal ownership;
- no `await` / timer sequencing;
- no Tween / animation lifecycle;
- no scene transition or WorldMap contract ownership;
- ally and enemy movement already share nearly identical BFS structure;
- public callers can remain untouched behind compatibility wrappers;
- path/range rules can be locked with direct deterministic tests.

This is safer than beginning with turn orchestration, AI decision execution, skill execution, battle result, camera, or HUD ownership.

## 3. Exact current functions in scope

Current source positions are recorded only as audit hints; Codex must re-read the current HEAD before editing.

| Function | Current line | B-1B treatment |
|---|---:|---|
| `_get_effective_move_range` | 14624 | keep wrapper; delegate calculation |
| `_get_occupied_cells_except` | 14663 | keep wrapper; delegate using current alive-unit snapshot |
| `_is_cell_occupied_except` | 14674 | keep wrapper; delegate |
| `_is_valid_destination_for_unit` | 14689 | keep wrapper and existing log behavior; delegate boolean query |
| `_is_path_clear_for_unit` | 14706 | keep wrapper and existing log behavior; delegate boolean query |
| `_is_cell_walkable_for_ally` | 14726 | keep compatibility wrapper; no external API change |
| `_find_ally_move_path` | 14738 | keep wrapper; delegate BFS |
| `_is_cell_walkable_for_enemy_actor` | 14807 | keep compatibility wrapper |
| `_find_enemy_move_path_for_actor` | 14823 | keep wrapper |
| `_find_enemy_path_to_destination_for_actor` | 14830 | keep wrapper; delegate BFS with override |
| `_get_enemy_reachable_paths_for_actor` | 14896 | keep wrapper; delegate reachable-path query |
| `get_unit_grid_distance` | 15087 | keep public wrapper; delegate Manhattan distance |

The zero-caller compatibility helpers (`_get_occupied_cells_for_move`, `_is_cell_occupied_for_move`, `_get_occupied_cells_for_enemy_move`, `_is_cell_walkable_for_enemy`, `_find_enemy_move_path`, `_get_enemy_reachable_paths`) are **not deleted in B-1B**. Removal requires a later dead-code task.

## 4. New production owner

Create:

`scripts/battle/services/battle_movement_query_service.gd`

Recommended owner:

`class_name BattleMovementQueryService`  
`extends RefCounted`

This service owns pure/synchronous movement queries only.

Recommended API responsibilities:

- effective movement range from `BattleUnitState` statuses;
- occupied-cell collection from a supplied alive-unit list;
- occupied-cell membership;
- destination validity against `BattleGridController`;
- path-clear query;
- deterministic four-neighbor BFS pathfinding;
- deterministic reachable-path map;
- Manhattan unit-to-unit grid distance.

The service must receive runtime data as arguments. It must not read scene nodes, active selection state, WorldMap meta, UI controls, animations, timers, or global battle phase directly.

## 5. Compatibility rule

B-1B must preserve the controller's existing wrapper names and caller surface.

Target relationship:

```text
existing battle callers
        ↓
battle_web_import_test.gd compatibility wrappers
        ↓
BattleMovementQueryService
```

Do not mass-rewrite all 20+ call sites in the first extraction.

The wrapper layer keeps:

- null checks tied to controller state;
- existing diagnostic `print()` behavior;
- active-unit / current-enemy actor selection;
- `ALLOW_BREAKTHROUGH_MOVE` ownership;
- current method names used by tests and scenario subclasses.

## 6. Exact behavior locks

The extraction must preserve:

- logical orthogonal grid authority;
- Manhattan distance;
- four-neighbor traversal only;
- BFS neighbor order exactly:
  1. `Vector2i(1, 0)`
  2. `Vector2i(-1, 0)`
  3. `Vector2i(0, 1)`
  4. `Vector2i(0, -1)`
- destination occupancy rules;
- mover excluded from occupied-cell blocking;
- `ALLOW_BREAKTHROUGH_MOVE` behavior;
- mobility-up +1;
- movement-down -1;
- minimum effective movement 0;
- ally path max-step behavior;
- enemy max-step override behavior;
- reachable-path dictionary behavior;
- no change to attack eligibility, unit type rules, AI ranking, or movement execution.

## 7. Explicitly out of scope

Do **not** extract or redesign in B-1B:

- `play_basic_move_demo` / move animation;
- click handling / target selection;
- `is_valid_move_target` action-eligibility checks;
- `is_unit_in_attack_range` / attack contract;
- enemy AI target ranking or destination scoring;
- surround-pressure decision logic;
- facing visual updates;
- range overlay rendering;
- ISO projection modules;
- turn/phase transitions;
- signals, timers, awaits, tweens;
- battle result / retreat / victory;
- WorldMap context/result handoff.

## 8. Required new direct regression test

Add a focused headless GDScript test for `BattleMovementQueryService`.

Minimum cases:

1. empty-grid deterministic path;
2. occupied-cell deterministic detour;
3. occupied destination rejected;
4. max-step limit rejected;
5. breakthrough mode ignores occupied blockers;
6. reachable paths never exceed max steps;
7. reachable paths exclude blocked destinations;
8. mobility-up increases effective range by 1;
9. movement-down decreases effective range by 1;
10. effective range clamps at 0;
11. Manhattan unit distance parity;
12. ally/enemy wrapper parity for representative fixtures.

For deterministic path tests, assert exact cell order, not only path length.

## 9. Validation gate

B-1B is not complete unless:

- new focused service test passes;
- existing five-unit-type action eligibility validation passes;
- existing turn-order tests pass;
- Godot 4.6 import/class-cache succeeds;
- project parse succeeds;
- `Battle_Main.tscn` loads;
- Imjin ISO scenario loads;
- full existing repository workflow succeeds;
- generated `.gd.uid` state is clean/understood;
- `git diff --check` passes;
- WorldMap still points to `res://Battle_Land.tscn`.

## 10. B-1A decision

B-1A is an audit/design task only. No battle behavior is changed here.

Next implementation task:

**B-1B | Extract BattleMovementQueryService with compatibility wrappers**

This implementation is a good Codex task because it requires coordinated edits across the 669 KB controller, a new service, focused tests, validator wiring, and repository-wide verification.
