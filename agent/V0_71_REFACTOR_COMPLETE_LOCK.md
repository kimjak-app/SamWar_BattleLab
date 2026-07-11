# v0.71 Refactor Complete Lock

## Baseline
- Commit: `232683d4f4c24a5afaf74cd0839f0d01a8820fd9` (`리팩토링 작업 중`, metadata-only `.gd.uid` follow-up after `v0.71-13 WorldMap Main Script Rename`).
- Active main scene: `res://WorldMap_Test.tscn`.
- Active worldmap script: `res://scripts/worldmap/worldmap_main.gd`.
- Date: 2026-07-11.

## Final Result
- Overall lock result: PASS.
- Proceed to v0.72: YES.
- Blockers: None.
- Major issues: None.
- Minor notes: `godot` is not available on PATH in this shell; verification used the local Godot 4.6.2 console executable. `Battle_Fullscreen_Test.tscn` prints existing diagnostic logs during headless startup.

v0.71 Refactor Complete Lock does not mean every worldmap function was extracted. It means all approved low-risk extraction batches were completed or explicitly deferred, and high-risk schema/runtime orchestration functions remain locked in `scripts/worldmap/worldmap_main.gd` by design.

## Active Runtime Entrypoints
- Main scene: `res://WorldMap_Test.tscn`.
- Active worldmap script: `res://scripts/worldmap/worldmap_main.gd`.
- Battle fullscreen scene: `res://Battle_Fullscreen_Test.tscn`.
- Legacy script path: `res://scripts/worldmap_test.gd` is retired.

## Extraction Summary

| Step | Domain | Result | Helper File | Extracted Count | Wrapper Kept |
|---|---|---|---|---:|---:|
| v0.71-05 | Domestic Tech | Extracted | `scripts/worldmap/domestic_tech/domestic_tech_helpers.gd` | 8 | 8 |
| v0.71-06 | Economy / City | Extracted | `scripts/worldmap/economy_city/economy_city_helpers.gd` | 13 | 13 |
| v0.71-07 | Defense / Battle | Extracted | `scripts/worldmap/defense_battle/defense_battle_helpers.gd` | 4 | 4 |
| v0.71-08 | Diplomacy / Spy | Extracted | `scripts/worldmap/diplomacy_spy/diplomacy_spy_helpers.gd` | 5 | 5 |
| v0.71-09 | Naval / Siege | No-op / Deferred | None | 0 | 0 |
| v0.71-10 | UI Formatter / Summary | Extracted | `scripts/worldmap/ui_formatter/ui_formatter_helpers.gd` | 12 | 12 |
| v0.71-11 | Orchestrator Slim | Boundary consolidated | None | 0 | 0 |
| v0.71-13 | Main Script Rename | Renamed | `scripts/worldmap/worldmap_main.gd` | N/A | N/A |

## Deferred / Locked Domains

The following domains intentionally remain in `scripts/worldmap/worldmap_main.gd` for v0.71:

### Schema / Persistence
- Save/load serialization and restoration.
- Active research payload schema.
- Completed tech schema.
- BattleContext schema.
- Pending invasion schema.
- Ship/siege persistent storage.

### Runtime Orchestration
- `_ready`.
- Signal wiring.
- Turn advance.
- Completion queue / video / card presentation queue.
- Scene lifecycle and scene tree ownership.

### Gameplay Formula / Mutation
- Battle formula/stat calculation.
- Diplomacy/spy formula.
- Relation mutation.
- Spy result mutation.
- City state mutation.
- City resource/storage mutation.
- City defense mutation.
- Siege result mutation.
- Deployment payload mutation.

### UI / Scene Ownership
- UI node mutation.
- Selection state mutation.
- Panel open/close/drag behavior.
- Left/right panel scope behavior.
- Graph layout and graph node creation.

### Deferred Domains
- Debug / QA / Dev Tools.
- Enemy Baseline / AI-lite.
- Mixed / Unsafe.

## Headless Verification

Verification command executable:
- `C:\Users\seong\Desktop\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe`

| Check | Result | Notes |
|---|---|---|
| Godot project headless load | PASS | Exit code 0. |
| `WorldMap_Test.tscn` headless load | PASS | Exit code 0. |
| `Battle_Fullscreen_Test.tscn` headless load | PASS | Exit code 0; existing diagnostic logs only. |

New warning/error count: 0.

## Runtime Preservation
- Gameplay behavior changed: NO.
- Save/load schema changed: NO.
- BattleContext schema changed: NO.
- Pending invasion schema changed: NO.
- Formula changed: NO.
- Scene layout changed: NO.
- Project main scene changed: NO.

## Deferred Scene Filename Cleanup

`WorldMap_Test.tscn` remains the MVP main scene for v0.71.

Scene filename cleanup is deferred to v0.72 because renaming scene entrypoints affects:
- `project.godot` main scene.
- Battle return paths.
- Scene preload/load references.
- Scene entrypoint documentation.
- Godot resource UID/path references.
- Distinction between MVP runtime scenes and dev/test scenes.

Recommended future task:
- `v0.72-00 Scene Entrypoint Rename Plan`
- `v0.72-01 WorldMap Scene Filename Rename`

## Next Recommended Tasks
- `v0.72-00 Scene Entrypoint Rename Plan`
- `v0.72-01 WorldMap Scene Filename Rename`
