# P-1B-3 | Production WorldMap Interaction & Presentation Promotion

Date: 2026-09-19
Branch: `refactor/production-runtime-unification-20260919`
Plan revision: `PRU-20260919-1`

## Goal

Promote the player-facing interaction layer that was previously visible only through `WorldMap_16x9_Test.tscn`.

## Promoted to `WorldMap.tscn`

- `WorldMapTopNav.tscn` on a production CanvasLayer;
- production `WorldMapCityActionController`;
- production turn-compass installer using `WorldMapTurnCompass`;
- `WorldMapActionPresentation.tscn` for diplomacy/trade/spy video and result scroll.

## Production wiring

### Top navigation

The existing accepted top navigation scene is instanced directly and receives:

```text
production_world_map_path = ../..
```

The production tech-tree opener and system/audio popup remain the actual actions.

### Contextual city actions

The former test controller was promoted to `WorldMapCityActionController`.

It now:

- uses the production WorldMap root directly;
- opens contextual spy/diplomacy/trade actions through `open_contextual_worldmap_action()`;
- preserves battle button parity by delegating to the existing attack button state/callback;
- has no test video signal or `ProductionWorldMap` wrapper dependency.

### Action video/result presentation

The existing self-contained action presentation scene is instanced directly under the production WorldMap and explicitly points to:

```text
production_world_map_path = ..
city_action_controller_path = ../WorldMapCityActionController
```

It continues to listen to:

- `contextual_worldmap_action_presentation_requested`;
- `contextual_worldmap_action_resolved`;

and completes real actions through `complete_contextual_worldmap_action()`.

### Turn-end compass

`WorldMapTurnCompassInstaller` creates/binds the accepted compass against the production `WorldMapUI` and existing hidden legacy turn-end button contract.

### Legacy cleanup

The production HUD now hides:

- `DomesticTechTreeButtonMVP` after late creation;
- `CameraDebugLabel`.

This removes the small legacy "테크트리" label and camera debug text that remained visible after P-1B-2.

## Still deferred

P-1B-3 does not yet promote:

- territory overlay (P-1B-4);
- turn-summary structured production binding;
- character-speech structured production binding;
- Battle_Main routing.

The current WorldMap battle entry remains `res://Battle_Land.tscn`.
