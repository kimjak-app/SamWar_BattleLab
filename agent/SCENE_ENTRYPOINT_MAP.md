# Scene Entrypoint Map

## v0.72-00 Scene Entrypoint Rename Plan

This document separates runtime production scenes from dev/test-only scenes before the v0.72 physical rename.

### Current Runtime Production Scenes

| Scene | Current Path | Current Role | v0.72-01 Proposed Path |
|---|---|---|---|
| WorldMap | `res://WorldMap_Test.tscn` | Project main scene and MVP worldmap runtime entrypoint. | `res://WorldMap.tscn` |
| Battle Fullscreen | `res://Battle_Fullscreen_Test.tscn` | Runtime land battle scene used by WorldMap battle handoff. | `res://Battle_Land.tscn` |

### Dev/Test-Only Scenes

| Scene | Path | Rename in v0.72-01? | Notes |
|---|---|---:|---|
| Singijeon Battle Test | `res://Battle_Singijeon_Test.tscn` | NO | Dev battle experiment scene. |
| Web Import Battle Test | `res://Battle_WebImport_Test.tscn` | NO | Dev/sample battle import scene. |
| Video Theora Test | `res://scenes/dev/video_theora_test.tscn` | NO | Dev video playback test scene. |

### Confirmed Runtime Path References

| Symbol / Reference | File | Current Value | v0.72-01 Value | Reference Type |
|---|---|---|---|---|
| `run/main_scene` | `project.godot` | `res://WorldMap_Test.tscn` | `res://WorldMap.tscn` | Runtime production config |
| `WORLDMAP_BATTLE_SCENE_PATH` | `scripts/worldmap/worldmap_main.gd` | `res://Battle_Fullscreen_Test.tscn` | `res://Battle_Land.tscn` | Runtime production constant |
| `WORLDMAP_SCENE_PATH` | `scripts/battle_web_import_test.gd` | `res://WorldMap_Test.tscn` | `res://WorldMap.tscn` | Runtime/dev return constant |

Documentation-only references include current-state notes, QA records, changelog/session history, and archive history. Historical references should not be rewritten during v0.72-01 unless the task explicitly asks for documentation cleanup.

### Recommended Scope

v0.72-01 should rename exactly:

- `res://WorldMap_Test.tscn` -> `res://WorldMap.tscn`
- `res://Battle_Fullscreen_Test.tscn` -> `res://Battle_Land.tscn`

Do not rename dev/test-only scenes in v0.72-01.

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
- v0.71-14 locks this runtime entrypoint state. Scene filename cleanup is deferred to v0.72.

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

- Scene filename cleanup is deferred to v0.72.
- `WorldMap_Test.tscn` remains the MVP main scene despite the legacy `Test` suffix.
- Recommended next task: `v0.72-00 Scene Entrypoint Rename Plan`.
