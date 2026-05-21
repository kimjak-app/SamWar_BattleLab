# Scalable Battle Slot Capacity Plan

## Scope
- Step: `v0.67a Scalable Battle Slot Capacity Plan`
- This step is documentation only.
- No scene change.
- No script change.
- No slot creation.

## 1. Final Capacity Goal

Final target per side:
- Main deployed units: up to `7`
- Reinforcement units: up to `3`
- Total per side: up to `10`
- Total battle capacity across both sides: up to `20`

MVP target per side:
- Main deployed units: `3`
- Reinforcement units: `2`
- Total per side: `5`
- Total battle capacity across both sides: `10`

Current `v0.66i` baseline:
- Stable `2v2`
- `ally_main`
- `ally_support`
- `enemy_main`
- `enemy_support`
- This remains the minimum stable test case for the scalable slot system.

## 2. Slot Naming Policy

Recommended final `slot_id` set:

```text
ally_main_01
ally_main_02
ally_main_03
ally_main_04
ally_main_05
ally_main_06
ally_main_07

ally_reinforce_01
ally_reinforce_02
ally_reinforce_03

enemy_main_01
enemy_main_02
enemy_main_03
enemy_main_04
enemy_main_05
enemy_main_06
enemy_main_07

enemy_reinforce_01
enemy_reinforce_02
enemy_reinforce_03
```

Legacy `2v2` mapping review:
- `ally_main` -> `ally_main_01`
- `enemy_main` -> `enemy_main_01`
- `ally_support` should be reviewed as:
  - `ally_main_02`
  - not `ally_reinforce_01` by default
- `enemy_support` should be reviewed as:
  - `enemy_main_02`
  - not `enemy_reinforce_01` by default

Recommended long-term interpretation:
- Current `support` units are present at battle start.
- Because they are present from turn 1, they fit `main_02` better than `reinforce_01`.
- `reinforce` slots should stay reserved for delayed or triggered entry units.

## 3. Slot Metadata Design

Each slot should be able to carry metadata such as:
- `slot_id`
- `side`
- `slot_role`
- `formation_index`
- `is_active`
- `is_deployed`
- `entry_rule`
- `source_city_id`
- `assigned_unit_id`
- `unit_state`
- `visual_slot`
- `deployment_cell`
- `entry_turn`
- `trigger_condition`

Recommended semantic meanings:
- `side`: `ally` or `enemy`
- `slot_role`: `main` or `reinforce`
- `formation_index`: stable ordering index within that side and role
- `is_active`: slot exists and is part of the current battle configuration
- `is_deployed`: unit is actually on the field now
- `entry_rule`: `initial`, `delayed`, `triggered`, `city_reinforcement`

## 4. Main Slot vs Reinforcement Slot

Main slot:
- Deployed at battle start
- Chosen from the city or fort garrison selected for battle participation
- MVP should prioritize `main_01` through `main_03`

Reinforcement slot:
- Used by external or delayed support units
- May enter on a later turn
- May enter after a trigger condition
- May represent support dispatched from another city
- MVP should prioritize `reinforce_01` and `reinforce_02`

Practical rule:
- Presence at battle start should normally classify a unit as `main`
- Delayed arrival should normally classify a unit as `reinforce`

## 5. Link to the Current C-Style Slot Tree

Current scene-level slot tree:

```text
Slots
  AllyMainSlot
  AllySupportSlot
  EnemyMainSlot
  EnemySupportSlot
```

Future capacity-oriented direction:

```text
Slots
  AllyMain01Slot
  AllyMain02Slot
  AllyMain03Slot
  AllyMain04Slot
  AllyMain05Slot
  AllyMain06Slot
  AllyMain07Slot
  AllyReinforce01Slot
  AllyReinforce02Slot
  AllyReinforce03Slot
  EnemyMain01Slot
  EnemyMain02Slot
  EnemyMain03Slot
  EnemyMain04Slot
  EnemyMain05Slot
  EnemyMain06Slot
  EnemyMain07Slot
  EnemyReinforce01Slot
  EnemyReinforce02Slot
  EnemyReinforce03Slot
```

Naming migration caution:
- Scene-tree names do not need to change immediately.
- A readable scene name and an extensible script-side `slot_id` registry can coexist during transition.
- Scene tree renaming should be treated as a separate migration step because it carries node-path risk.

## 6. Need for BattleUnitState Arrays

Current fixed variables:
- `ally_unit_state`
- `ally_support_unit_state`
- `enemy_unit_state`
- `enemy_support_unit_state`

Target scalable containers:
- `ally_unit_states: Array[BattleUnitState]`
- `enemy_unit_states: Array[BattleUnitState]`
- `all_unit_states: Array[BattleUnitState]`
- `unit_state_by_slot_id: Dictionary`
- `unit_visual_slot_by_slot_id: Dictionary`

Design conclusion:
- Fixed variables are acceptable for the stable `2v2` baseline.
- Fixed variables do not scale to `10` slots per side without structural duplication.
- Transition should happen through adapters and fallback, not instant deletion.
- The current `2v2` should remain representable as the first two entries of the future arrays.

## 7. Auto Battle Expansion Considerations

Current state:
- Auto battle is stabilized for `2v2`

Future requirements:
- Actor choice should be based on an actionable unit list
- Target choice should be based on a valid target list
- `main` and `reinforce` slots should both be supported
- Non-deployed reinforcements must be excluded from actor selection
- Non-deployed reinforcements must be excluded from target selection
- Basic eligibility should include:
  - `is_alive`
  - `is_deployed`
  - `has_acted`

Scaling note:
- Current step limits and iteration assumptions should be reviewed later for `10` units per side.
- Priority should stay on correctness and clean filtering before tuning performance.

## 8. City/Fort Deployment Pipeline

Recommended pipeline:

```text
City garrison data
-> battle participant resolver
-> main / reinforce slot assignment
-> BattleUnitState creation
-> UnitVisualSlot attachment
-> battle start or reinforcement arrival
```

Example:
- 한성 주둔 이순신 -> `ally_main_01`
- 한성 주둔 정도전 -> `ally_main_02`
- 개성 파견 지원군 -> `ally_reinforce_01`
- 평양 파견 지원군 -> `ally_reinforce_02`

Design rule:
- Slot assignment should be resolved before combat runtime begins.
- Runtime battle logic should consume resolved slot metadata rather than inventing slot placement ad hoc.

## 9. Formation and Layout Direction

For `7` main units:
- A front / mid / rear concept will likely be required
- Infantry, cavalry, archers, gunners, siege, and naval cases may need different authored positions
- Scene-authored layout should remain the controlling principle
- Code should not hard-force final battlefield coordinates when authored scene placement is the better source of truth

For MVP `3 + 2`:
- `main_01` through `main_03` begin deployed
- `reinforce_01` and `reinforce_02` are designed as later-entry positions
- Reinforcement entry positions should remain editable in the Godot 2D editor

## 10. Implementation Roadmap

### v0.67a Scalable Battle Slot Capacity Plan
- Current step
- Documentation only

### v0.67b Slot Registry Array Scaffold
- Add slot-id lists and slot metadata constants
- Register the current `4` stable slots in an array/registry form
- Keep existing battle behavior unchanged

### v0.67c BattleUnitState List Adapter
- Wrap the current fixed state variables in ally/enemy arrays
- Keep direct fixed-variable fallback during transition

### v0.67d 2v2 on Scalable Slot Framework
- Run the current `2v2` battle on the scalable slot registry structure
- Preserve the current stable result exactly

### v0.68 MVP 3 Main + 2 Reinforce Layout Plan
- Define authored battlefield layout for `3 + 2` per side

### v0.69 MVP 5-Slot Battle Prototype
- Build an MVP prototype for:
  - ally `3 + 2`
  - enemy `3 + 2`

### v0.70 Final 7+3 Capacity Preparation
- Prepare the architecture for `10` slots per side

## 11. Risks

Key risks:
- Fixed variables and array registry coexisting can create duplicate references
- Dead-unit cleanup may miss newly added slots
- Non-deployed reinforcements may accidentally become clickable
- Non-deployed reinforcements may accidentally become valid auto-battle actors
- READY / Facing / overlay tracking may fail to scale with more slots
- Code-driven formation logic may override scene-authored layout and break tuning
- `10` visible units can create readability problems
- HP bars, labels, and portraits may overlap heavily
- Structural confusion is a larger near-term risk than raw performance

## 12. Capacity Expansion QA Checklist

Future QA targets:
- Existing `2v2` remains stable
- `3` main slots can be active per side
- `2` reinforcement slots can remain inactive and undeployed at battle start
- Reinforcements can appear later without breaking click targeting
- Reinforcements can appear later without breaking AI targeting
- Dead main-unit cleanup remains correct
- Dead reinforcement-unit cleanup remains correct
- Auto battle ON/OFF remains stable
- Auto stop remains stable
- READY / Facing overlays remain correct
- UnitCloseupPanel remains correct
- Battle dust remains readable
- Error log remains clean

## Recommendation

Recommended next implementation step:
- `v0.67b Slot Registry Array Scaffold`

Reason:
- It creates the minimum scalable registry layer without forcing battle-behavior changes.
- It preserves the current stable `2v2` as the compatibility baseline while opening the path toward `3 + 2` MVP and `7 + 3` final capacity.
