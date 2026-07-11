# v0.72-02 Scene Rename F6 Roundtrip QA

## Baseline
- Commit: `5bc176291ba52cc5bafdbb1a0fdd003c50d7c1bb` (`v0.72-01 WorldMap + Land Battle Scene Filename Rename`).
- Date: 2026-07-11.
- Main scene: `res://WorldMap.tscn`.
- Land battle scene: `res://Battle_Land.tscn`.
- Active worldmap script: `res://scripts/worldmap/worldmap_main.gd`.

## Summary
- Overall result: PASS WITH MANUAL QA REQUIRED.
- Blockers: 0.
- Major issues: 0.
- Minor issues: 1.
- Manual F6 performed: NO.
- Proceed to complete lock: CONDITIONAL.

Codex static/path and headless validation passed, but the tactile F6 click-through roundtrip was not performed in this non-interactive session. Complete lock should either wait for human-confirmed F6 roundtrip QA or explicitly accept this manual-QA note.

## Path / Reference Verification

| Check | Result | Notes |
|---|---|---|
| `WorldMap.tscn` exists | PASS | File exists. |
| `Battle_Land.tscn` exists | PASS | File exists. |
| `WorldMap_Test.tscn` retired | PASS | File absent. |
| `Battle_Fullscreen_Test.tscn` retired | PASS | File absent. |
| Dev/test scenes preserved | PASS | `Battle_Singijeon_Test.tscn`, `Battle_WebImport_Test.tscn`, and `scenes/dev/video_theora_test.tscn` exist. |
| Old production paths absent from runtime/config | PASS | No `WorldMap_Test.tscn` or `Battle_Fullscreen_Test.tscn` matches in `project.godot`, `scripts`, active `.tscn` files, or `scenes`. |
| New main scene reference | PASS | `project.godot` uses `run/main_scene="res://WorldMap.tscn"`. |
| New battle path constant | PASS | `WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"`. |
| New worldmap return path constant | PASS | `WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"`. |

## Headless Verification

| Check | Result | Notes |
|---|---|---|
| Godot project headless load | PASS | Exit code 0. |
| `WorldMap.tscn` headless load | PASS | Exit code 0. |
| `Battle_Land.tscn` headless load | PASS | Exit code 0; existing diagnostic logs only. |

New warning/error count: 0.

## Manual F6 Roundtrip QA

- F6 starts project with `res://WorldMap.tscn`: NOT PERFORMED - requires human tactile QA.
- WorldMap visible: NOT PERFORMED - requires human tactile QA.
- No missing scene/resource error on startup: Covered by headless/static validation; tactile F6 not performed.
- Battle entry action available: NOT PERFORMED - requires human tactile QA.
- WorldMap -> Battle_Land transition: NOT PERFORMED - requires human tactile QA.
- Battle_Land visible: NOT PERFORMED - requires human tactile QA.
- Battle diagnostic logs only / no new error: Covered by direct `Battle_Land.tscn` headless load; tactile F6 not performed.
- Battle end or return action available: NOT PERFORMED - requires human tactile QA.
- Battle_Land -> WorldMap return: NOT PERFORMED - requires human tactile QA.
- WorldMap visible after return: NOT PERFORMED - requires human tactile QA.
- No old `WorldMap_Test.tscn` path error: Covered by static runtime/config search; tactile F6 not performed.
- No old `Battle_Fullscreen_Test.tscn` path error: Covered by static runtime/config search; tactile F6 not performed.
- Result: NOT PERFORMED.

Manual checklist for human confirmation:
1. Run F6 and confirm `WorldMap.tscn` starts from the project main scene.
2. Trigger a normal WorldMap battle entry.
3. Confirm the scene transition reaches `Battle_Land.tscn`.
4. Complete or return from battle through the existing return flow.
5. Confirm the return path reaches `WorldMap.tscn`.
6. Confirm no old production scene path error appears in Godot Output.

## Findings

No blocker, major, minor, or cosmetic finding was identified by Codex static/path/headless validation.

### QA Finding: Manual F6 roundtrip not performed
- Area: Manual QA coverage.
- Severity: Minor.
- Reproduction: This Codex session cannot perform tactile editor F6 click-through and battle roundtrip interaction.
- Expected: Human F6 confirms WorldMap -> Battle_Land -> WorldMap runtime flow.
- Actual: Static/path/headless validation passed; tactile F6 roundtrip remains unverified.
- Logs / screenshot note: No screenshot captured; headless project and scene loads exited 0.
- Suspected cause: Non-interactive execution environment.
- Regression risk: Scene path regressions that require real UI actions could remain undetected by headless load alone.
- Recommendation:
  - Run human-confirmed `Manual F6 Roundtrip Confirmation` before complete lock, or explicitly accept complete lock with this manual-QA note.

## Decision
- Decision: PASS WITH MANUAL QA REQUIRED.
- Recommendation: Do not treat tactile roundtrip as fully confirmed until human F6 validates WorldMap -> Battle_Land -> WorldMap. If human confirmation is available, proceed to `v0.72-03 Scene Entrypoint Rename Complete Lock`; otherwise run `Manual F6 Roundtrip Confirmation` first.
