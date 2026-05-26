# BATTLE CONTEXT CONTRACT

## Role
- Defines the handoff object between worldmap / army systems and the battle engine.
- Makes the battle engine a consumer of prepared battle data.
- Prepares for worldmap-driven land, naval, coastal, siege, and mountain battles.

## Core Direction
- `BattleContext` is created before battle scene startup.
- `BattleContext` is produced by worldmap / army encounter logic.
- The battle engine consumes `BattleContext.roster`.
- The battle engine does not choose participating heroes directly.
- The battle engine does not read worldmap state directly.
- `BattleContext` is the only worldmap-to-battle input the battle engine should consume.

## BattleContext Example
```js
BattleContext = {
  battle_id,
  battle_type,
  region_id,
  map_variant_id,

  attacker: {
    force_id,
    army_id,
    heroes
  },

  defender: {
    force_id,
    army_id,
    heroes
  },

  terrain_tags,
  weather,
  rewards
}
```

## Extended BattleContext Fields
- `encounter_id`
- `city_id`
- `route_id`
- `deployment`
- `rules`
- `environment`
- `reinforcement_source`

## Side Context Example
```js
BattleSideContext = {
  side,
  force_id,
  army_id,
  commander_hero_id,
  objective,
  retreat_route_id
}
```

## Roster Entry Example
```js
BattleRosterEntry = {
  side,
  hero_id,
  army_id,
  capacity_slot_id,
  role,
  entry_round,
  starting_troops,
  max_troops,
  unit_type_override,
  initial_statuses,
  deployment_hint
}
```

## Required BattleContext Fields
- `battle_id`: stable runtime battle ID.
- `battle_type`: `land`, `naval`, `coastal`, `siege`, or `mountain`.
- `region_id`: worldmap region that owns battle map selection.
- `map_variant_id`: resolved map variant selected before battle load.
- `attacker`: attacker side context.
- `defender`: defender side context.
- `attacker.heroes` / `defender.heroes`: side rosters selected by worldmap / army systems.

## Optional BattleContext Fields
- `city_id`
- `route_id`
- `terrain_tags`
- `deployment`
- `rules`
- `environment`
- `weather`
- `season`
- `fog`
- `river_crossing`
- `supply_modifiers`
- `rewards`
- `reinforcement_source`

## Current MVP Compatibility
- Current stable battle shape is `5v5`.
- Current internal flow is:
  - `ROUND 1 = 3v3`
  - `ROUND 2 = 4v4`
  - `ROUND 3 = 5v5`
- The first contract MVP may map roster entries to existing `capacity_slot_id` values.
- The current demo registry path may remain until a real `BattleContext` adapter replaces it.
- Naval, coastal, siege, land, and mountain battles should use the same `BattleContext` boundary, with battle-type-specific fields added only as contract data.

## Validation Rules
- Every roster entry must have `side`, `hero_id`, `capacity_slot_id`, `role`, and troop values.
- `hero_id` must resolve to `HeroData`.
- `unique_skill_ids` must resolve through skill metadata.
- No duplicate active `capacity_slot_id` may exist within one battle side.
- Battle type and map variant must be known before scene load.
- Reinforcement source and timing should be resolved in `BattleContext`, even if the current battle engine still applies MVP round timing.

## Forbidden Coupling
- Do not make battle startup inspect city or region ownership to choose rosters.
- Do not make battle startup choose `map_variant_id` from raw worldmap state.
- Do not treat scene-authored slot names as army data.
- Do not write battle results directly into worldmap state without a future result contract.
