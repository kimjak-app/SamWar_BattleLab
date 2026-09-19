# P-1B-2 | Production WorldMap HUD Promotion

Date: 2026-09-19
Branch: `refactor/production-runtime-unification-20260919`
Plan revision: `PRU-20260919-1`

## Goal

Promote the accepted compact 16:9 left/right HUD from the QA host into `WorldMap.tscn` without shipping the mirror/lock/late-guard scaffolding.

## Production controllers added

- `WorldMapHudPresentationController` attached as the canonical `HudPositionOwner`;
- `WorldMapWarehouseTabsController`;
- `WorldMapGarrisonCompactController`;
- `WorldMapReadabilityController`;
- `WorldMapPanelRefinementController`;
- `WorldMapTechBadgeSummaryController`.

## Behavior promoted

- 320px left compact nation HUD;
- 308px right compact city HUD;
- 16:9 side/top HUD positioning;
- user drag position preservation;
- legacy save/logistics/trade clutter hidden from the compact nation panel;
- stable two-tab nation warehouse presentation;
- three-column compact garrison presentation over the runtime-created `GarrisonCard`;
- readability typography/profile refinement;
- loyalty/tax presentation refinement and compact domestic metrics;
- national/city tech summary sections backed by actual completed-tech snapshots.

## Deliberately not promoted

- hard-coded sample tech badges;
- `StableHudMirrorController`;
- `LeftPanelLockGuard`;
- `TurnTransitionLateGuard`;
- test-host parent path assumptions.

## Existing runtime contract reused

`worldmap_shared_ui_controller.gd` already routes panel position changes through a child named `HudPositionOwner`. The production compact HUD controller now fills that contract and resolves legacy 10px-top requests to the approved 16:9 default layout while keeping explicit user drag positions.

`WorldMapCityInfoPanelBase` already creates `GarrisonCard` and `GarrisonList` during runtime setup. The promoted compact-garrison controller attaches after that creation instead of duplicating city data ownership.

## Scope lock

P-1B-2 does not yet promote:

- TopNav;
- contextual city action menu;
- turn summary;
- character speech;
- action presentation;
- territory overlay;
- Battle_Main routing.

WorldMap battle entry remains `res://Battle_Land.tscn`.

## Runtime QA

After pulling this HEAD, run `WorldMap.tscn` directly and compare the left/right HUD with the accepted `WorldMap_16x9_Test` presentation.
