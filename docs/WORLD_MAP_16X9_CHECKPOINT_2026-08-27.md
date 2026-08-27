# World Map 16:9 Checkpoint — 2026-08-27

## Purpose
This file is the recovery checkpoint for the current world-map presentation work. Use it to resume the exact same test scene and avoid accidentally editing the production world map directly.

## Current working branch
- `feature/worldmap-background-refresh`
- Layout checkpoint commit: `7ed9bd53732e635a68c544287c002b4020a619ef`
- Commit message: `W3-0F-fix: apply approved city positions in 16x9 test host`

## Authoritative F6 scene
- `res://WorldMap_16x9_Test.tscn`
- This is the scene to run with F6 for current visual verification.
- Do not switch to `WorldMap_UI_Test.tscn` for this work.

## Authoritative layout host
- `res://scripts/worldmap/worldmap_16x9_test_host.gd`
- City placement overrides belong in `CITY_POSITIONS` here.
- The host already reapplies city labels and refreshes route geometry after moving markers.

## Design-2 background path
- Test controller: `res://scripts/worldmap/ui/worldmap_v2_background_test_controller.gd`
- Texture: `res://assets/source/worldmap/worldmap_bg_v2_test.png`
- Design-2 background is intentionally test-only and must not overwrite the production background setup.

## Production boundary — important
- `res://WorldMap.tscn` is the production world map instance used inside the 16:9 test host.
- Do **not** directly edit production city positions for Design-2 presentation alignment.
- During the 2026-08-27 session, city positions were mistakenly applied to `WorldMap.tscn` once; that change was fully restored.
- After correction, the diff from the pre-error baseline contains only the intended `worldmap_16x9_test_host.gd` city-position change.

## Approved 13-city marker centers
Coordinates are sampled from the approved 2048×1152 red-square marker guide and applied 1:1 in the 16:9 test world coordinate space.

```gdscript
const CITY_POSITIONS := {
    "karakorum": Vector2(1029.5, 272.5),
    "yecheng": Vector2(842.5, 499.0),
    "pyeongyang": Vector2(1178.0, 342.0),
    "hanseong": Vector2(1235.0, 424.5),
    "luoyang": Vector2(765.0, 586.5),
    "gyeongju": Vector2(1303.0, 488.5),
    "sabi": Vector2(1236.0, 523.5),
    "edo": Vector2(1602.5, 414.5),
    "jianye": Vector2(955.0, 670.0),
    "kyoto": Vector2(1543.5, 492.5),
    "osaka": Vector2(1513.5, 567.0),
    "chengdu": Vector2(408.5, 730.5),
    "kyushu": Vector2(1397.5, 628.5),
}
```

City ID mapping:
- `karakorum` = 카라코룸
- `pyeongyang` = 평양
- `hanseong` = 한성
- `gyeongju` = 경주
- `sabi` = 사비
- `yecheng` = 업성
- `luoyang` = 낙양
- `jianye` = 건업
- `chengdu` = 성도
- `kyushu` = 규슈
- `osaka` = 오사카
- `kyoto` = 교토
- `edo` = 에도

## Elements locked during city-position pass
Do not move or restyle these when adjusting city positions:
- Design-2 background
- left nation/status panel
- right city-info panel
- turn-end compass
- top title plaque
- existing compact HUD treatment

## Route and label behavior
The test host performs the following after city coordinates are applied:
1. `_apply_city_positions(world_root)`
2. `_apply_city_label_offsets(world_root)`
3. `_refresh_routes(world_root)`

Therefore marker movement should propagate to city-name placement and route endpoints. Manual production route edits should not be the first response to a city-position adjustment.

## 2026-08-27 visual verification
User F6 verification passed on `WorldMap_16x9_Test.tscn` after the corrected patch:
- Design-2 map background visible
- 13 cities aligned to the approved guide
- labels follow city markers
- route lines refresh to moved cities
- left/right HUD panels preserved
- turn-end compass preserved
- top title preserved

## Resume checklist for the next session
1. Confirm branch is `feature/worldmap-background-refresh`.
2. Confirm latest branch HEAD before editing.
3. Open/run `WorldMap_16x9_Test.tscn`.
4. For city placement, edit only `CITY_POSITIONS` in `worldmap_16x9_test_host.gd` unless the task explicitly changes architecture.
5. Keep `WorldMap.tscn` production layout untouched for presentation-only adjustments.
6. F6 the 16:9 test scene and visually verify background, city markers, labels, routes, HUD panels, compass, and title together.
