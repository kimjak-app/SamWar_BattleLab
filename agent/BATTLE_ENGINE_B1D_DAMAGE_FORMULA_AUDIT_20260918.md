# B-1D | Damage Formula Boundary Audit

Date: 2026-09-18  
Branch: `refactor/engine-core-20260918`  
Baseline HEAD: `e226ff02606182f3d97af25eddf35cf833b295e6`  
Verified workflow: `35338064619` — success

## 1. Current baseline

Current `scripts/battle_web_import_test.gd` at the audited HEAD:

- 665,425 bytes
- 15,859 lines
- 859 functions
- `_get_directional_attack_damage`: 7 callers
- `_get_attack_angle_damage_multiplier`: 1 caller

B-1C already owns combat queries through `BattleCombatQueryService`. B-1D must not reopen that boundary.

## 2. B-1D extraction decision

Extract only the synchronous, read-only **pre-wounded damage formula**.

New production owner:

`scripts/battle/services/battle_damage_formula_service.gd`

Recommended:

```gdscript
class_name BattleDamageFormulaService
extends RefCounted
```

The service may:

- read attacker/defender `BattleUnitState` fields and status effects;
- use the attack-angle type supplied by the controller/BattleCombatQueryService;
- call `UnitTypeContract.get_damage_context()`;
- call `UnitTypeContract.get_number()`;
- calculate the pre-wounded integer damage result.

The service must not mutate any battle state.

## 3. Controller compatibility boundary

Keep both existing controller functions:

- `_get_attack_angle_damage_multiplier`
- `_get_directional_attack_damage`

Target relationship:

```text
existing callers
      ↓
battle_web_import_test.gd compatibility wrapper
      ↓
BattleCombatQueryService      -> angle type
BattleDamageFormulaService    -> pre-wounded damage
      ↓
controller wounded adjustment/logging
```

All seven existing `_get_directional_attack_damage` callers remain unchanged in B-1D.

## 4. Wounded-state ownership lock

Do **not** move these responsibilities into the damage service:

- `_is_unit_hero_wounded`
- `_get_wounded_penalty_multiplier`
- `_apply_wounded_amount_multiplier`
- `_apply_wounded_incoming_damage_penalty`
- `_log_wounded_penalty`
- hero registry lookup
- WorldMap hero status

The controller wrapper must preserve the current tail exactly:

1. calculate pre-wounded directional damage;
2. when `apply_attacker_wounded_penalty` is true, call the existing attacker wounded adjustment;
3. always call the existing defender incoming-wounded adjustment;
4. preserve `should_log_wounded_penalty` behavior and log strings.

This keeps strategic hero status outside the pure combat formula service.

## 5. Formula order lock

The current order is behavior and must remain exact.

Starting multiplier:

1. front / side / back angle multiplier;
2. `UnitTypeContract.get_damage_context()`:
   - `base_damage_modifier`;
   - `matchup_modifier`;
   - `side_or_rear_modifier`;
   - `received_damage_modifier`;
3. gunner prepared-fire bonus when not moved;
4. gunner `post_fire_penalty`;
5. attacker `shake`;
6. defender `shake`;
7. defender `is_defending`;
8. attacker:
   - `attack_defense_up`;
   - `attack_defense_down`;
   - `counter_up`;
   - `flank_damage_up` when non-front;
9. defender:
   - `defense_up` / `attack_defense_up`;
   - `defense_down` / `attack_defense_down`;
   - `damage_reduction`;
   - `formation_break`;
   - `flank_damage_taken_up` when non-front;
   - `incoming_damage_down`.

Then preserve the current two-stage rounding behavior:

1. `maxi(1, round(base_damage * damage_multiplier))`;
2. for gunner, apply armor-ignore adjustment using defender defense and round again;
3. return the pre-wounded integer result.

Do not combine the two round operations.

## 6. Existing numeric locks

Current controller values are the behavior baseline:

- front: 1.00
- side: 1.15
- back: 1.30
- attacker shake: 0.90
- defender shake incoming damage: 1.10
- defend multiplier: 0.62
- status default magnitudes exactly as currently used
- gunner prepared-fire and armor-ignore values remain sourced from `UnitTypeContract`

Do not rebalance values in this task.

## 7. Call-site lock

The seven current callers cover:

- manual ally basic attack;
- unique-skill target projection;
- resolver/skill damage application;
- unique-skill single-damage flows;
- enemy basic attack;
- auto damage projection.

Do not rewrite those callers. The compatibility wrapper remains their single entry point.

In particular, preserve calls where `apply_attacker_wounded_penalty` is false for skill damage. Skill wounded handling is already performed by `_get_unique_skill_effect_amount` and must not be doubled.

## 8. Explicitly out of scope

Do not change or extract in B-1D:

- `BattleCombatQueryService`;
- attack range eligibility;
- `apply_damage()`;
- `_commit_basic_attack_unit_contract`;
- momentum gain;
- target selection;
- AI scoring or ranking;
- counterattack sequencing;
- unique-skill amount calculation;
- wound detection or wound logs;
- burn/status ticking;
- animations, FX, audio, UI;
- turn/phase state;
- BattleContext/BattleResult;
- WorldMap battle entry.

## 9. Focused regression requirements

Add a direct headless regression for the new service.

Recommended:

`tests/scripts/test_battle_damage_formula_service.gd`

Minimum coverage:

1. front neutral damage;
2. side neutral damage;
3. back neutral damage;
4. minimum damage clamp;
5. attacker shake;
6. defender shake;
7. defending multiplier;
8. attack-defense up/down;
9. defense up/down;
10. damage reduction;
11. formation break;
12. counter-up;
13. attacker flank bonus only on side/back;
14. defender flank-damage-taken bonus only on side/back;
15. incoming-damage-down;
16. gunner prepared fire;
17. gunner moved state;
18. gunner post-fire penalty;
19. gunner armor-ignore second-round behavior;
20. representative wrapper parity;
21. `apply_attacker_wounded_penalty=false` remains compatible for skill-style callers.

Prefer exact integer expected values for deterministic formula cases, not only relative comparisons.

## 10. Static validation requirements

Recommended:

`tools/validate_b1d_battle_damage_formula_service.py`

At minimum assert:

- service and tracked `.gd.uid` exist;
- controller preloads/owns the service;
- both compatibility wrappers remain;
- seven caller surface is not mass-rewritten;
- `_get_directional_attack_damage` still performs wounded adjustments in controller;
- service contains no `apply_damage`, logging, WorldMap/BattleResult/BattleContext, UI, signal, await, tween, AI scoring, or mutation responsibilities;
- WorldMap still points to `res://Battle_Land.tscn`.

## 11. Decision

B-1D implementation task:

**Extract BattleDamageFormulaService while leaving wounded strategic-state handling and all attack execution in the controller.**

This is a Codex-sized task because the formula has many locked modifiers, seven live caller contexts, exact rounding semantics, and needs broad regression verification.
