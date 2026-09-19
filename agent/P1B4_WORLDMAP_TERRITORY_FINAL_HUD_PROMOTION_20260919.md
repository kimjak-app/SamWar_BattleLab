# P-1B-4 | Territory Overlay + Final Compact HUD Promotion

Date: 2026-09-19
Branch: `refactor/production-runtime-unification-20260919`
Plan revision: `PRU-20260919-1`

## Goal

Finish the major visual gap still visible after P-1B-3:

1. promote the accepted territory ownership overlay into the canonical production WorldMap;
2. stop legacy left/right information blocks from reappearing after turn/city/intel refreshes.

## P-1B-4A | Territory overlay

Promoted:

`scripts/worldmap/ui/worldmap_territory_controller.gd`

The production controller now owns:

- 2048×1152 territory ColorRect;
- 4096×2304 land/sea mask;
- territory shader;
- faction colors from the city-marker owner palette;
- city-position/color shader arrays;
- layer placement above map tiles and below routes/cities.

`WorldMap.tscn` directly owns `WorldMapTerritoryController`.

Runtime ownership changes and restored ownership state call:

`_refresh_territory_overlay_if_present()`

so the overlay follows actual city ownership rather than being a static QA image.

## P-1B-4B | Final compact HUD authority

The remaining "old UI" was not a scene-layout problem. Production refresh code was re-enabling legacy labels after the compact controllers ran.

### Left nation HUD

`WorldMapHudController` now has an explicit compact-presentation mode.

When enabled it keeps hidden across later refreshes:

- player/faction eyebrow;
- old turn/calendar/nation header;
- old resource bonus text;
- logistics/trade summary text;
- save-management title/status;
- old separator/save row.

The accepted compact warehouse and tech sections remain the visible data surface.

### Right city HUD

`WorldMapCityInfoPanel` now has an explicit compact-presentation mode.

It keeps hidden across own-city, enemy-city, empty-city, intel, and recruitment refreshes:

- military detail text;
- legacy domestic text source;
- intel hint wall;
- old attack/button row;
- old recruitment block;
- hero-transfer/military auxiliary panels.

The visible production surface remains:

- city name / faction / type;
- compact domestic metrics;
- stability;
- governor;
- compact garrison;
- city tech summary.

Contextual `첩보 / 외교 / 무역 / 전투` actions remain handled by the separate production city-action menu promoted in P-1B-3.

## Architecture result

This pass deliberately does **not** import:

- LeftPanelLockGuard;
- StableHudMirrorController;
- TurnTransitionLateGuard;
- TerritoryTestController.

The actual data/presentation owners now enforce the accepted state.

## Still deferred

- structured production turn-summary promotion;
- structured character-speech promotion;
- ISO battle production promotion;
- final WorldMap → Battle_Main switch.

Battle entry remains `res://Battle_Land.tscn`.
