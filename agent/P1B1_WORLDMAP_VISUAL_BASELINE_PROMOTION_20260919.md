# P-1B-1 | WorldMap Visual Baseline Promotion

Date: 2026-09-19
Branch: `refactor/production-runtime-unification-20260919`
Plan revision: `PRU-20260919-1`

## Goal

Promote only the accepted 16:9 world geometry into Production WorldMap ownership.

## Implemented

- Production background refresh owner now uses the accepted Design-2 4096×2304 source.
- Production world geometry is 2048×1152.
- Bottom atlas tiles move to Y=576.
- All 13 approved city positions are persisted in `WorldMap.tscn`.
- City-marker production seed positions match the approved 16:9 coordinates.
- All 13 city labels use Y=16.
- Production camera center/bounds are persisted as 2048×1152.
- Runtime initial camera cover keeps viewport-derived zoom and now applies 16:9 bounds.
- Existing route controller remains responsible for endpoint/interior route refresh after city positions resolve.
- WorldMap battle entry intentionally remains `res://Battle_Land.tscn`.

## Explicitly unchanged

- compact HUD composition;
- top navigation;
- turn-end compass ownership;
- contextual city action menu;
- turn-summary/speech/help wiring;
- territory overlay promotion;
- Battle_Main/ISO battle switch.

## Scoped verification

Repository-state checks confirmed:

- 13/13 production city positions match the approved baseline;
- 13/13 city labels use the approved offset;
- four production tile positions match 2048×1152 geometry;
- Design-2 background source is production-owned;
- camera bounds are 0,0 → 2048,1152;
- route refresh hook remains active;
- WorldMap battle path is unchanged.

Runtime/editor visual parity must be checked in Godot by opening/running `WorldMap.tscn` directly, not `WorldMap_16x9_Test.tscn`.


## Visual-QA hotfix note

The first P-1B-1 pass promoted runtime ownership but left the old four tile PNGs serialized in `WorldMap.tscn`. That caused the Godot 2D editor and initial scene state to continue presenting the legacy map.

Hotfixes now:

- remove all four legacy tile texture references from `WorldMap.tscn`;
- persist `worldmap_bg_v2_test.png` as the canonical scene texture;
- persist four AtlasTexture regions directly in the scene;
- persist the 17 route Curve2D guide-point baselines against the approved city coordinates;
- fix the A1 tile block serialization;
- extend the P-1B-1 validator to reject legacy tile references or escaped-newline corruption.

After pulling the latest branch, close/reopen `WorldMap.tscn` (or reload the Godot project) so the editor discards its cached open-scene state.
