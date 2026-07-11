# Scene Entrypoint Map

## Current MVP Entrypoint

Source: `project.godot`

```ini
run/main_scene="res://WorldMap_Test.tscn"
```

- `res://WorldMap_Test.tscn` is the current MVP run entrypoint.
- During the v0.71 refactor route, this root scene is the main worldmap baseline scene.
- The filename still carries the legacy `Test` suffix, but the scene is treated as the MVP worldmap entrypoint until a dedicated rename task is approved later.
- `res://scenes/WorldMap_Test.tscn` is not the active entrypoint and is absent from this repo.
- Active script: `res://scripts/worldmap/worldmap_main.gd`.
- Legacy script path `res://scripts/worldmap_test.gd` was retired in v0.71-13.
- `WorldMap_Test.tscn` keeps a path-based script ExtResource for the active script path.

## Known Scene Roles

| Scene Path | Current Role | Rename Now? | Notes |
| ---------- | ------------ | ----------- | ----- |
| `res://WorldMap_Test.tscn` | Current MVP worldmap entrypoint and v0.71 refactor baseline scene. | No | Root scene; uses `scripts/worldmap/worldmap_main.gd`; legacy scene `Test` suffix is retained for now. |
| `res://Battle_Fullscreen_Test.tscn` | Current stable fullscreen battle scene and worldmap battle handoff target. | No | Referenced by `WORLDMAP_BATTLE_SCENE_PATH`; keep available for battle regression. |
| `res://Battle_Singijeon_Test.tscn` | Legacy standalone Singijeon battle test scene. | No | Preserved as a test scene; no longer the run main scene. |
| `res://Battle_WebImport_Test.tscn` | Web-import battle sample/test scene. | No | Preserved for battle import/sample validation. |
| `res://scenes/dev/video_theora_test.tscn` | Dev video/Theora playback test scene. | No | Dev-only validation scene. |

## Naming Policy During v0.71

- v0.71-02 does not rename `.tscn` files.
- `WorldMap_Test.tscn` is the MVP main scene during v0.71 despite the legacy `Test` suffix.
- `Battle_*_Test.tscn` scenes remain test/validation scenes.
- Physical scene rename or move work should be considered only after script split risk is reduced and should be handled by a dedicated future task.
- Path cleanup in v0.71-02 is limited to removing or correcting nonexistent active references, especially confusion around `res://scenes/WorldMap_Test.tscn`.

## Next Cleanup Boundary

- v0.71-03 should move to `Scripts Folder Structure Split`.
- Scene rename is not part of v0.71-03.
- If scene rename becomes necessary, split it into a separate task after v0.71 or after the script folder structure is stable.
