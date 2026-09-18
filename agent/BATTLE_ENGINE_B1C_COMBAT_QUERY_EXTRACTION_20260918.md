# B-1C | BattleCombatQueryService Extraction

Date: 2026-09-18  
Branch: `refactor/engine-core-20260918`  
Baseline HEAD: `e601750b42bd05618cb5bfc7aaa6737d2dc22698`

## Goal

Extract synchronous combat-query responsibility without changing damage resolution, attack execution, AI scoring, presentation, turn flow, or WorldMap contracts.

## Production owner

`scripts/battle/services/battle_combat_query_service.gd`

Owned queries:

- direction from grid positions;
- opposite facing;
- front / side / back attack-angle classification;
- unit attack-range eligibility from a supplied grid distance.

## Compatibility wrappers retained

- `_get_direction_from_positions`
- `_get_opposite_facing`
- `_get_attack_angle_type`
- `is_unit_in_attack_range`

Callers continue using the controller surface.

## Boundary decisions

- Manhattan distance remains owned by `BattleMovementQueryService` through the existing controller wrapper.
- Facing normalization remains owned by the already-locked `BattleFormationFacingHelper`.
- `UnitTypeContract.can_unit_attack()` remains the authority for unit-type attack eligibility.
- Actual damage calculation remains in `scripts/battle_web_import_test.gd`.

## Explicitly not moved

- `_get_attack_angle_damage_multiplier`
- `_get_directional_attack_damage`
- damage modifiers/status effects;
- attack execution/commit;
- AI target scoring;
- target-selection state;
- counterattack;
- skill execution;
- animation/logging/UI;
- WorldMap/BattleResult/BattleContext.

## Behavior locks

- axis ties remain horizontal-first;
- zero delta remains right;
- invalid facing normalizes to right and therefore opposite resolves left;
- null attack-angle inputs return front;
- front/back/side semantics remain identical;
- dead targets cannot be attacked;
- moved/acted restrictions remain delegated to `UnitTypeContract.can_unit_attack()`.

## Validation

Focused headless test:

`tests/scripts/test_battle_combat_query_service.gd`

Static validator:

`tools/validate_b1c_battle_combat_query_service.py`

The repository verification workflow runs both before B-1C can be considered complete.
