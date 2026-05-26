# ARMY DEPLOYMENT RULES

## Role
- Defines future army, corps, fleet, and deployment rules.
- Bridges worldmap hero placement to battle roster preparation.
- Keeps deployment authority outside the battle engine.

## Core Direction
- Heroes are placed in regions, cities, armies, fleets, or reserve pools.
- Heroes are assigned to regions before they become local battle candidates.
- Armies and fleets move on the worldmap.
- A hero may belong to an `army_id`.
- Encounters are generated from army / fleet position, route, ownership, and conflict rules.
- When an encounter occurs, heroes from the relevant army, fleet, city, or region become battle roster candidates.
- Battle rosters are selected before battle launch and passed through `BattleContext`.

## ArmyData Example
```js
ArmyData = {
  army_id,
  force_id,
  region_id,
  hero_ids,
  supply,
  movement_points
}
```

## Extended ArmyData Fields
- `commander_hero_id`
- `origin_city_id`
- `current_city_id`
- `route_id`
- `movement_mode`
- `troop_pool`
- `supply_state`

## Deployment Intent Example
```js
DeploymentIntent = {
  side,
  army_id,
  main_hero_ids,
  reinforcement_hero_ids,
  reserve_hero_ids,
  preferred_slots,
  entry_rule
}
```

## Movement Modes
- `land`
- `naval`
- `coastal`
- `siege_approach`

## Deployment Sources
- `city_garrison`: heroes stationed in a city or fortress.
- `roaming_army`: mobile land army moving across regions and cities.
- `naval_fleet`: mobile sea force moving through routes, ports, and coastal regions.
- `regional_reserve`: heroes available from the local region but not currently deployed.

## Battle Roster Rules
- Main units and reinforcements are selected before battle startup.
- Roster entries should distinguish `deployed`, `reinforcement`, and `reserve` roles.
- Reinforcement possibility belongs to army / encounter / BattleContext preparation before battle startup.
- Reinforcement timing may be included as explicit `entry_rule` data.
- Battle engine may apply current internal round timing while the contract is MVP, but should not decide which heroes are reinforcements.
- Current `3 main + 2 reinforce` per side remains the stable MVP battle shape until a larger roster contract is implemented.

## Deployment Authority
- Worldmap / army systems decide which heroes are present.
- Worldmap / army systems decide attacker and defender side data.
- Battle engine only validates and consumes the prepared roster.

## Future Expansion Hooks
- army split / merge
- multi-army reinforcement
- naval fleet assignment
- siege attacker / defender posture
- supply impact on starting troops
- fatigue and morale
- retreat path and capture risk
- AI-controlled countries should use the same army, region, fleet, and roster candidate structure as the player.

## Regression Guard
- Do not replace current deployment marker behavior during docs-only contract work.
- Do not make scene slots decide army composition.
- Do not let battle runtime changes mutate worldmap army state directly; use a future battle result contract.
