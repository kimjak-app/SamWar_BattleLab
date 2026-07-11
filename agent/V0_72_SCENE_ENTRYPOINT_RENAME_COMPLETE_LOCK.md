# v0.72 Scene Entrypoint Rename Complete Lock

## Baseline
- Commit: `99172748f3a8a621d9be54aa2b3b1ada0c4aa5b4` (`v0.72-02 Scene Rename F6 Roundtrip QA`).
- Task start HEAD: `d3d04b8a3b4b9e1b48e80952a562931eaacd88a2` (`리팩토링과정`), on top of `9917274` and matching `origin/main`.
- Date: 2026-07-11.
- Main scene: `res://WorldMap.tscn`.
- Land battle scene: `res://Battle_Land.tscn`.
- Active worldmap script: `res://scripts/worldmap/worldmap_main.gd`.

## Final Result
- Overall lock result: PASS.
- Proceed to next development task: YES.
- Blockers: 0.
- Major issues: 0.
- Minor notes: `Battle_Land.tscn` prints existing diagnostic logs during direct headless startup.

## Runtime Entrypoints
- Main scene: `res://WorldMap.tscn`.
- Active worldmap script: `res://scripts/worldmap/worldmap_main.gd`.
- Land battle scene: `res://Battle_Land.tscn`.
- Dev/test scenes:
  - `res://Battle_Singijeon_Test.tscn`.
  - `res://Battle_WebImport_Test.tscn`.
  - `res://scenes/dev/video_theora_test.tscn`.

## Retired Production Paths
- `res://WorldMap_Test.tscn`.
- `res://Battle_Fullscreen_Test.tscn`.

## Rename Summary

| Old | New | Status |
|---|---|---|
| `res://WorldMap_Test.tscn` | `res://WorldMap.tscn` | Complete |
| `res://Battle_Fullscreen_Test.tscn` | `res://Battle_Land.tscn` | Complete |

## Runtime Path Constants
- `project.godot` main scene:
  - `res://WorldMap.tscn`.
- `WORLDMAP_BATTLE_SCENE_PATH`:
  - `res://Battle_Land.tscn`.
- `WORLDMAP_SCENE_PATH`:
  - `res://WorldMap.tscn`.

## Headless Verification

| Check | Result | Notes |
|---|---|---|
| Godot project headless load | PASS | Exit code 0. |
| `WorldMap.tscn` headless load | PASS | Exit code 0. |
| `Battle_Land.tscn` headless load | PASS | Exit code 0; existing diagnostic logs only. |

New warning/error count: 0.

## Human Manual Roundtrip Confirmation

After v0.72-02, the user manually confirmed the runtime roundtrip:

- Project run starts correctly with `res://WorldMap.tscn`.
- WorldMap screen runs normally.
- WorldMap -> `res://Battle_Land.tscn` transition works.
- `Battle_Land.tscn` runs normally.
- Battle return -> `res://WorldMap.tscn` works.
- No missing old production path error was reported for:
  - `res://WorldMap_Test.tscn`
  - `res://Battle_Fullscreen_Test.tscn`

Result:
- Manual roundtrip confirmation: PASS.

## Runtime Preservation
- Gameplay behavior changed: NO.
- Save/load schema changed: NO.
- BattleContext schema changed: NO.
- Pending invasion schema changed: NO.
- Formula changed: NO.
- Scene layout changed by this lock task: NO.
- Project main scene changed by this lock task: NO.

## Decision
- PASS.
- Scene entrypoint rename line is locked.
