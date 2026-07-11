# v0.72-00 Scene Entrypoint Rename Plan

## Baseline
- Commit: `a3b90beaa315da75489ebb84eff3edd71b79ea23` (`v0.71-14 Refactor Complete Lock`).
- Date: 2026-07-11.
- Active worldmap script: `res://scripts/worldmap/worldmap_main.gd`.
- Current main scene: `res://WorldMap_Test.tscn`.
- Current runtime battle scene: `res://Battle_Fullscreen_Test.tscn`.

## Audit Summary
- Runtime scene path references found: 3 critical references.
- Documentation-only references found: historical/current agent docs and archive notes only.
- Hardcoded constants found: 2 runtime script constants.
- Rename blockers: none found in static audit.
- Proceed to v0.72-01 rename: YES.

This task is planning/documentation only. No scene files, runtime scripts, `project.godot`, script paths, schema, formula, asset, import, or `.gd.uid` files were changed.

## Scene Inventory

| Scene | Current Path | Role | Runtime Entrypoint? | Dev/Test Only? | v0.72 Rename? | Proposed Path |
|---|---|---|---:|---:|---:|---|
| WorldMap | `res://WorldMap_Test.tscn` | MVP main worldmap scene | YES | NO | YES | `res://WorldMap.tscn` |
| Battle Fullscreen | `res://Battle_Fullscreen_Test.tscn` | Runtime land battle scene | YES | NO | YES | `res://Battle_Land.tscn` |
| Singijeon Battle Test | `res://Battle_Singijeon_Test.tscn` | Dev battle experiment | NO | YES | NO | unchanged |
| Web Import Battle Test | `res://Battle_WebImport_Test.tscn` | Dev/sample battle import scene | NO / DEV ONLY | YES | NO | unchanged |
| Video Theora Test | `res://scenes/dev/video_theora_test.tscn` | Dev video playback test | NO | YES | NO | unchanged |

Inventory commands confirmed these five `.tscn` files and no separate `.tscn.uid` files.

## Hardcoded Scene Path References

| Symbol / Reference | File | Current Value | New Value in v0.72-01 | Runtime Critical? | Action Needed |
|---|---|---|---|---:|---|
| `run/main_scene` | `project.godot` | `res://WorldMap_Test.tscn` | `res://WorldMap.tscn` | YES | Update in v0.72-01 |
| `WORLDMAP_BATTLE_SCENE_PATH` | `scripts/worldmap/worldmap_main.gd` | `res://Battle_Fullscreen_Test.tscn` | `res://Battle_Land.tscn` | YES | Update in v0.72-01 |
| `WORLDMAP_SCENE_PATH` | `scripts/battle_web_import_test.gd` | `res://WorldMap_Test.tscn` | `res://WorldMap.tscn` | YES / DEV | Update in v0.72-01 to keep sample/dev battle return valid |

Runtime usage:
- `scripts/worldmap/worldmap_main.gd` checks `ResourceLoader.exists(WORLDMAP_BATTLE_SCENE_PATH)` and then calls `change_scene_to_file(WORLDMAP_BATTLE_SCENE_PATH)`.
- `scripts/battle_web_import_test.gd` calls `change_scene_to_file(WORLDMAP_SCENE_PATH)` for the WorldMap return path.
- `project.godot` has one `run/main_scene` entrypoint.

Scene file notes:
- `WorldMap_Test.tscn` and `Battle_Fullscreen_Test.tscn` contain root node names matching their current filenames.
- The current audit found no `.tscn` file that references another `.tscn` by ExtResource path.
- Historical references in `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and archived docs are documentation-only and do not block v0.72-01.

## Current Runtime Entrypoints

- Project main scene:
  - `res://WorldMap_Test.tscn`
- Active worldmap script:
  - `res://scripts/worldmap/worldmap_main.gd`
- Runtime battle scene:
  - `res://Battle_Fullscreen_Test.tscn`
- WorldMap -> Battle path:
  - `scripts/worldmap/worldmap_main.gd`
  - `WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Fullscreen_Test.tscn"`
- Battle/WebImport -> WorldMap return path:
  - `scripts/battle_web_import_test.gd`
  - `WORLDMAP_SCENE_PATH := "res://WorldMap_Test.tscn"`
- Dev/test-only scenes:
  - `res://Battle_Singijeon_Test.tscn`
  - `res://Battle_WebImport_Test.tscn`
  - `res://scenes/dev/video_theora_test.tscn`

## Rename Scope

v0.72-01 should rename exactly two production runtime scenes:

| Current | New |
|---|---|
| `res://WorldMap_Test.tscn` | `res://WorldMap.tscn` |
| `res://Battle_Fullscreen_Test.tscn` | `res://Battle_Land.tscn` |

Reason:
- `WorldMap_Test.tscn` is the MVP main scene and should lose the legacy `Test` suffix.
- `Battle_Fullscreen_Test.tscn` is the runtime land battle scene. `Battle_Land.tscn` aligns with a future `Battle_Naval.tscn` naming pattern.

## v0.72-01 Execution Plan

### Files to Update

1. `project.godot`
   - `run/main_scene="res://WorldMap.tscn"`

2. `scripts/worldmap/worldmap_main.gd`
   - `WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"`

3. `scripts/battle_web_import_test.gd`
   - `WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"`

4. `agent/SCENE_ENTRYPOINT_MAP.md`
   - Update runtime entrypoint paths.

5. `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`
   - Update v0.72-01 result after execution.

### Rename Mechanics

- Use `git mv` for scene file renames to preserve history.
- Check for Godot-generated scene UID/path metadata after the rename.
- If metadata files are generated or moved, report them in the v0.72-01 completion report.

### Dev/Test Scenes Not Renamed

The following scenes must not be renamed in v0.72-01:

- `res://Battle_Singijeon_Test.tscn`
- `res://Battle_WebImport_Test.tscn`
- `res://scenes/dev/video_theora_test.tscn`

## v0.72-01 PASS Criteria

- Use `git mv` for scene file renames to preserve history.
- `WorldMap.tscn` exists.
- `Battle_Land.tscn` exists.
- `WorldMap_Test.tscn` retired.
- `Battle_Fullscreen_Test.tscn` retired.
- `project.godot` main scene points to `res://WorldMap.tscn`.
- `WORLDMAP_BATTLE_SCENE_PATH` points to `res://Battle_Land.tscn`.
- `WORLDMAP_SCENE_PATH` points to `res://WorldMap.tscn`.
- Dev/test scenes remain unchanged.
- No scene node/layout changes.
- No gameplay logic changes except path string updates.
- Godot headless project load PASS.
- `WorldMap.tscn` headless load PASS.
- `Battle_Land.tscn` headless load PASS.
- Manual F6 QA confirms WorldMap -> Battle_Land -> WorldMap flow.

## v0.72-01 FAIL / Rollback Criteria

FAIL if any of the following occurs:

- Godot project load fails.
- `WorldMap.tscn` load fails.
- `Battle_Land.tscn` load fails.
- Missing resource/script error appears.
- `project.godot` main scene points to a missing scene.
- WorldMap -> Battle path fails.
- Battle -> WorldMap return path fails.
- Dev/test scenes are accidentally renamed.
- Scene layout/node diff appears beyond path/resource reference updates.
- Gameplay code changes beyond path string constants.

Rollback policy:
- Do not hotfix blindly.
- Record the failing path and exact error.
- Preserve logs/status before reverting so the failure cause is not lost.
- Revert the rename patch to the previous safe commit using the safest non-destructive method available for the situation.
- Retry only with updated instruction.

## Decision

- Proceed to v0.72-01: YES.
- Recommended scope:
  - `WorldMap_Test.tscn` -> `WorldMap.tscn`
  - `Battle_Fullscreen_Test.tscn` -> `Battle_Land.tscn`
