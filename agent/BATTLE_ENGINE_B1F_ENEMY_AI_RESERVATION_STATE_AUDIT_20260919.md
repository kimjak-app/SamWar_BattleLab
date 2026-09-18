# B-1F | Enemy AI Reservation State Boundary Audit

Date: 2026-09-19  
Branch: `refactor/engine-core-20260918`  
Baseline HEAD: `287326f2fa9935e7d218f385a1a155305b15896d`

## 1. Current baseline

Current `scripts/battle_web_import_test.gd` at the audited baseline:

- 15,781 lines
- 859 functions
- B-1B owns movement queries.
- B-1C owns combat queries.
- B-1D owns pre-wounded damage formula calculation.
- B-1E owns acted-id action-lock bookkeeping/query state.

The next smallest coherent mutable-state responsibility is enemy-AI per-turn cell reservation bookkeeping.

## 2. Current reservation state

Controller-owned dictionaries:

- `enemy_ai_reserved_destination_cells: Dictionary`
- `enemy_ai_reserved_engagement_cells: Dictionary`

Direct ownership is limited to the reservation wrapper family:

- `_clear_enemy_ai_turn_reservations`
- `_is_enemy_ai_destination_cell_reserved_for_other_actor`
- `_is_enemy_ai_engagement_cell_reserved_for_other_actor`
- `_reserve_enemy_ai_decision_plan_for_actor`

`_can_enemy_ai_use_destination_cell` remains an orchestration/policy wrapper because it combines destination validity with reservation state.

Current controller direct accesses are intentionally narrow: declaration, clear, lookup, and plan reservation only.

## 3. B-1F extraction decision

Create:

`scripts/battle/services/battle_enemy_ai_reservation_state_service.gd`

Recommended:

```gdscript
class_name BattleEnemyAiReservationStateService
extends RefCounted
```

The service owns only:

- destination-cell reservation dictionary;
- engagement-cell reservation dictionary;
- per-turn clear;
- own-vs-other actor reservation query;
- decision-plan destination/final-cell reservation.

The service receives primitive/runtime values as arguments. It does not choose actors, targets, paths, destinations, or actions.

## 4. Compatibility wrapper boundary

Keep all existing controller wrapper names and callers.

Target relationship:

```text
existing enemy AI callers
        ↓
battle_web_import_test.gd compatibility wrappers
        ↓
BattleEnemyAiReservationStateService
```

Controller remains responsible for:

- null actor checks;
- `_get_capacity_slot_id_for_unit_state()`;
- destination/path validity;
- AI decision-plan construction and scoring;
- actor/target policy;
- logging;
- turn sequencing.

## 5. Exact semantics lock

Preserve destination and engagement query semantics:

- null actor in wrapper -> `false`;
- queried cell equal to actor current cell -> `false`;
- unreserved cell -> `false`;
- reserved by same actor slot -> `false`;
- reserved by a different actor slot -> `true`.

Preserve decision-plan reservation semantics:

- null actor or empty decision plan -> no-op in wrapper;
- `destination` defaults to actor current cell;
- `final_cell` defaults to destination;
- actor current cell is never inserted as a reservation;
- destination and final cell may both be reserved;
- slot-id string is preserved exactly, including an empty string if the existing slot resolver returns one.

Do not add occupancy/path checks inside the state service.

## 6. Lifecycle lock

Enemy reservation state is per-turn ephemeral state.

Current reset path stays:

`_reset_enemy_action_locks_for_new_round()`
-> `_clear_enemy_ai_turn_reservations()`
-> service clear

Do not move round reset, `BattleUnitState.reset_action_flags()`, or action-lock state into B-1F.

No resume-snapshot schema change is introduced. Reservations remain intentionally non-persistent.

## 7. Focused regression requirements

Add:

`tests/scripts/test_battle_enemy_ai_reservation_state_service.gd`

Cover at minimum:

1. empty state is unreserved;
2. own current cell is never treated as reserved-for-other;
3. reserve destination for actor A;
4. actor A may reuse its own destination reservation;
5. actor B sees actor A destination as reserved;
6. engagement reservation has equivalent semantics;
7. current-cell destination is not stored;
8. current-cell final cell is not stored;
9. final-cell default follows destination;
10. clear removes both reservation families;
11. controller wrappers preserve null behavior;
12. controller reserve wrapper delegates slot identity;
13. enemy action-lock reset still clears reservation state.

## 8. Static validation requirements

Add:

`tools/validate_b1f_battle_enemy_ai_reservation_state_service.py`

Assert:

- service and tracked `.gd.uid` exist;
- controller preloads and instantiates service;
- legacy reservation dictionaries are no longer controller-owned;
- compatibility wrappers remain;
- wrappers delegate to service;
- slot resolution remains controller-side;
- `_can_enemy_ai_use_destination_cell` still combines destination validity and reservation check controller-side;
- enemy round reset still calls `_clear_enemy_ai_turn_reservations()`;
- B-1E action-lock service remains separate;
- WorldMap entry remains `res://Battle_Land.tscn`;
- service contains no movement/path query, target scoring, action execution, phase/round, UI, animation, WorldMap, GameSession, BattleContext, or BattleResult ownership.

## 9. Explicitly out of scope

Do not change in B-1F:

- enemy AI target ordering;
- decision scoring;
- destination scoring;
- surround-pressure policy;
- pathfinding;
- movement execution;
- attack execution;
- turn/phase sequencing;
- action-lock semantics;
- status ticking;
- unique skills;
- reinforcement;
- snapshot schema;
- WorldMap/BattleContext/BattleResult;
- scene routing.

## 10. Decision

B-1F implementation task:

**Extract enemy-AI destination/engagement reservation dictionaries into a dedicated state service while preserving all AI policy and turn sequencing in the controller.**
