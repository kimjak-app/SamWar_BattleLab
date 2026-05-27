# WORLDMAP RULES

## Role
- Defines the future SamWar worldmap system contract.
- Owns region, city, route, connection, encounter, and battle launch context decisions.
- Produces `BattleContext` for the battle engine.

## Current Canvas Foundation
- `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control` makes scene-authored Tile node positions the source of truth for worldmap tile layout.
- Runtime must not overwrite the four Tile node positions during `_ready()`.
- Runtime camera clamp should read the union of the current tile Sprite2D world rects, not a hardcoded 2x2 layout.
- Kimjak can manually adjust `Tile_A1_TopLeft`, `Tile_A2_TopRight`, `Tile_B1_BottomLeft`, and `Tile_B2_BottomRight` in the Godot 2D editor and save the scene.
- `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix` updates the scene-authored four-tile layout so the Godot 2D editor shows one contiguous map for manual city placement.
- The current editor-visible tile positions are A1 `(0, 0)`, A2 `(512, 0)`, B1 `(0, 512)`, and B2 `(512, 512)`, with `Sprite2D.centered = false`.
- Runtime tile configuration must match the scene-authored layout result and must not hide a broken editor layout.
- `v0.68b-1 WorldMap Four-Tile Canvas Foundation` adds `WorldMap_Test.tscn` as the current visual worldmap canvas foundation.
- The four prepared tiles under `assets/worldmap/tiles/` are arranged as NW, NE, SW, and SE Sprite2D nodes with `centered = false`.
- `scripts/worldmap_test.gd` uses the A1 tile texture size to place A2 at `(tile_width, 0)`, B1 at `(0, tile_height)`, and B2 at `(tile_width, tile_height)`.
- `WorldMapCamera` is the scene-authored Camera2D foundation for large-map pan and zoom, clamped to the combined 2x2 world rect.
- `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` are prepared as empty Node2D layers only.
- City click, city data, route graph, army movement, battle entry, and `BattleContext` creation remain forbidden until their dedicated tasks.

## Current City Marker Foundation
- `v0.68b-2-hotfix5 WorldMap City Marker Label Reparent Fix` standardizes each city as one scene-authored marker bundle under `CityLayer`.
- Each `CityMarker_*` root owns local `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D` children.
- Moving a `CityMarker_*` root in the Godot 2D editor should move the icon/dot, label, and click area together.
- Runtime code may refresh local label text and marker color from metadata, but must not place `NameLabel` with independent world coordinates.
- Runtime may update label text/color from marker metadata and process click signals, but it must not detach label/click geometry from the marker root.
- City marker positions remain scene-authored `CityMarker_*`.`position`; tile manual layout control does not make web `x` / `y` authoritative.
- After `v0.68b-2-hotfix2`, corrected `CityMarker_*` seed positions use the 1024x1024 four-tile combined rect so markers sit on the map image in the Godot 2D editor.
- `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix` aligns the city marker layer with the four-tile worldmap coordinate space.
- `WorldMapRoot`, `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` use the same zero-offset parent coordinate basis.
- Scene-authored tile positions are A1 `(0, 0)`, A2 `(tile_width, 0)`, B1 `(0, tile_height)`, and B2 `(tile_width, tile_height)` with `Sprite2D.centered = false`.
- Corrected `CityMarker_*` positions are a one-time seed fix against the 4-tile combined rect; future edits should move the marker nodes directly in the Godot 2D editor.
- `v0.68b-2 WorldMap City Marker Layer MVP` adds the first 13 city markers under `WorldMap_Test.tscn > WorldMapRoot > CityLayer`.
- City marker metadata is based on `SamWar_web/data/cities.js`: `id`, `name`, `regionKey`, `ownerFactionId`, `neighbors`, and `routeTypes`.
- Web `x` / `y` values are only seed/fallback placement data. They are recorded as `web_seed_position` but must not become the final Godot source of truth.
- Final city placement source of truth is each scene-authored `CityMarker_*` node's `position` in `WorldMap_Test.tscn`.
- Kimjak may move `CityMarker_*` nodes directly in the Godot 2D editor and save the scene; runtime must preserve those edited positions.
- `scripts/worldmap_city_marker.gd` stores marker metadata and lightweight visual label/color behavior only. It must not override the marker root position from web data at runtime.
- City click, selection UI, route drawing, army movement, battle entry, and `BattleContext` creation remain forbidden until their dedicated tasks.

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
