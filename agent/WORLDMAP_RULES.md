# WORLDMAP RULES

## Role
- Defines the future SamWar worldmap system contract.
- Owns region, city, route, connection, encounter, and battle launch context decisions.
- Produces `BattleContext` for the battle engine.

## Canonical Direction
- The battle engine does not choose heroes directly.
- The battle engine does not read worldmap state directly.
- The worldmap / army system creates an encounter and converts it into `BattleContext`.
- The battle engine consumes `BattleContext.roster`, map metadata, and battle rules as prepared input.

## World Scope
- The worldmap is based on China, the Korean peninsula, and the Japanese archipelago.
- Worldmap data should support land regions, coastal regions, sea routes, ports, cities, and strategic connections.

## Core Concepts
- `city`: controllable settlement, base, port, capital, fortress, or supply node.
- `region`: larger geographic grouping used for terrain, map selection, ownership, and encounter rules.
- `route`: sea movement path between ports, coasts, islands, or naval regions.
- `connection`: land or sea adjacency used for movement, invasion, reinforcement, and supply.
- `encounter`: resolved worldmap event that requests a battle.

## Movement Types
- Land movement occurs through land connections between cities or regions.
- Sea movement occurs through sea routes and port/coastal connections.
- Mixed coastal movement may connect land armies, fleets, ports, and coastal battle rules.

## Battle Type Selection
- Worldmap rules decide `battle_type`.
- Supported future battle types:
  - `land`
  - `naval`
  - `coastal`
  - `siege`
  - `mountain`
- Region, route, city, terrain, attacker approach, defender position, and encounter type may all affect battle type.

## Map Variant Selection
- `map_variant_id` is chosen by worldmap / region rules, not by the battle engine.
- The battle engine should receive a resolved `map_variant_id` in `BattleContext`.
- Map variant selection may use:
  - `region_id`
  - `city_id`
  - `route_id`
  - `battle_type`
  - `terrain_tags`
  - attacker / defender approach direction

## Battle Context Responsibility
- Worldmap owns encounter creation.
- Worldmap resolves attacker and defender armies.
- Worldmap resolves battle type, terrain, region, map variant, and initial scenario metadata.
- Worldmap produces `BattleContext`.
- Battle engine consumes `BattleContext` and reports battle result back through a future result contract.

## Future Expansion Hooks
- `weather`
- `season`
- `fog`
- `river_crossing`
- `supply`
- naval wind/current conditions
- siege equipment and wall state
- road quality and movement fatigue

## Forbidden Coupling
- Do not make battle scripts query worldmap ownership directly.
- Do not make battle scripts select armies directly from city or region state.
- Do not encode region-specific map selection inside the battle engine.
- Do not treat scene node placement as worldmap deployment data.
