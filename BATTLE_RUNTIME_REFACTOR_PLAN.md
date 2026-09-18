# Battle Runtime Refactor Plan

Status: Approved design baseline for the next battle refactor track.
Repository: `kimjak-app/SamWar_BattleLab`
Working branch at the time of approval: `recovery/worldmap-iso-sfx-services-20260912`

## 1. Core decision

Do **not** refactor the current battle code while continuing to treat `*_Test` files as the production runtime.

Before the large battle refactor begins, separate the real battle runtime from test/scenario/QA layers.

The target relationship is:

```text
Production battle runtime = the authoritative battle implementation
        ↓
Scenario / smoke / movement / skill / AI / visual QA tests = consumers or subclasses of production
```

The current direction must move away from:

```text
Test scene/script = de facto production runtime
        ↓
more Test scenes/scripts inherit from it
```

## 2. Current observed hierarchy

Current scene chain:

```text
tests/scenes/Battle_UI_Production_Test.tscn
    ↓
tests/scenes/Battle_UI_Production_Imjin_Test.tscn
    ↓
tests/scenes/Battle_UI_Production_Imjin_IsoMovement_Test.tscn
```

Current script chain:

```text
scripts/battle_web_import_test.gd
    ↓
tests/scripts/battle_ui_production_imjin_test.gd
    ↓
tests/scripts/battle_ui_production_imjin_iso_movement_test.gd
```

Important interpretation:

- `Battle_UI_Production_Test.tscn` and `battle_web_import_test.gd` currently act much more like a real battle base/runtime than ordinary tests.
- `battle_ui_production_imjin_test.gd` is scenario-specific. It should remain an Imjin scenario fixture/extension, not become the generic battle engine.
- `battle_ui_production_imjin_iso_movement_test.gd` currently contains presentation experiment code on top of the inherited logical battle rules. Generic ISO functionality that becomes part of the actual game must eventually move out of `tests/` and into production battle modules.

## 3. When to remove the `Test` role from real battle code

The correct timing is **before the major battle runtime refactor**, not after it.

Approved sequence:

```text
B-0A Test Inventory & Ownership
    ↓
B-0B Create canonical Production Battle runtime/skeleton
    ↓
B-0C Promote generic battle + ISO runtime responsibilities from tests to production
    ↓
B-1+ Refactor the production battle runtime by responsibility
    ↓
Parity verification against the existing battle tests
    ↓
Switch WorldMap battle entry to the canonical production battle scene
```

Do not wait until every refactor is complete before creating the production runtime. The production/runtime boundary must exist first so that later refactors have a clear owner.

## 4. Target production structure

Names can be adjusted during implementation, but the ownership model should be approximately:

```text
scenes/battle/Battle_Main.tscn
scripts/battle/battle_controller.gd
scripts/battle/... dedicated controllers/services/helpers
```

`Battle_Main.tscn` becomes the single canonical battle scene used by the actual game.

The battle controller should become an orchestration/wiring owner, while concrete responsibilities move into focused modules as needed.

Likely responsibility families to audit/extract include:

- turn / phase orchestration
- player action flow
- movement / path / facing
- attack / targeting / range
- skill execution
- AI turn execution
- unit runtime state
- battle result / victory / retreat
- reinforcement / formation
- HUD / presentation wiring
- camera / animation / cut-in orchestration
- ISO projection / overlay presentation

This is an audit list, not a mandate to create one file per bullet. Reuse existing clear owners before creating new files.

## 5. Test topology after promotion

Keep multiple tests. Do **not** merge all tests into one scene.

Target shape:

```text
tests/
  battle_smoke_test
  imjin_scenario_test
  movement_test
  skill_test
  ai_turn_test
  cutin_visual_qa
  sfx_preview
  other focused regression/QA tests
```

Tests should verify production behavior rather than secretly contain the only authoritative implementation of that behavior.

## 6. What should move to production

Move/promote code when it is a generic rule or runtime responsibility used by the real game, such as:

- turn progression
- unit state
- movement and attack execution
- AI invocation/orchestration
- skill execution
- victory/result handling
- production HUD wiring
- generic camera/animation sequencing
- generic ISO projection and overlay behavior once confirmed as the final battle presentation

If generic ISO helpers are currently under `tests/scripts/`, promote them to the production battle domain when they become part of the actual game.

Examples currently used by the ISO test that must be audited for promotion:

- `battle_iso_grid_projection.gd`
- `battle_iso_range_overlay_tile.gd`
- `battle_iso_facing_arrow_tile_button.gd`
- `battle_iso_facing_indicator_label.gd`

Promotion does not mean blindly moving every file. Only generic production responsibility moves.

## 7. What should stay in tests / QA

Keep test-specific/scenario-specific code out of production, including:

- Imjin-only hero roster / scenario identity
- Imjin-only camera guards or scenario patches
- authored test fixtures
- forced QA states
- cut-in visual QA harnesses
- SFX preview harnesses
- experimental-only overrides that are not accepted game behavior
- temporary diagnostics / markers

`battle_ui_production_imjin_test.gd` should remain a scenario layer unless a specific piece of its behavior proves generic and is explicitly promoted.

## 8. ISO decision

The current ISO movement test is no longer treated as disposable merely because its filename contains `Test`.

It is the current candidate presentation direction for the actual SamWar battle screen.

However:

- logical battle rules remain authoritative and must not be changed merely to satisfy projection code;
- presentation-only ISO code should be separated from combat rules;
- generic ISO behavior should be promoted to production;
- Imjin-specific or experiment-only overrides remain in tests;
- parity with the existing logical battle behavior must be verified before switching the game entry point.

## 9. WorldMap integration rule

Do **not** immediately change WorldMap battle entry to the new `Battle_Main.tscn` as soon as the production skeleton is created.

First confirm parity for:

- battle context intake
- unit/hero deployment
- player/enemy turn order
- movement/attack/skill behavior
- AI behavior
- battle result output
- retreat/victory/defeat paths
- return to WorldMap
- wounded/recovery/result settlement integration

Only after these are green should WorldMap use the canonical production battle scene.

## 10. B-0 execution plan

### B-0A | Test Inventory & Ownership

Classify every battle-related scene/script as one of:

- Core/runtime candidate
- Scenario fixture
- Presentation experiment
- QA/regression test
- Legacy/dead candidate

Deliverable: ownership map and promotion list.

### B-0B | Canonical Production Battle Skeleton

Create the production battle scene/runtime boundary without changing battle behavior.

Do not delete the existing tests.
Do not switch WorldMap yet.
Do not redesign rules or balance.

### B-0C | Production Promotion / Parity Bridge

Move only confirmed generic runtime responsibilities from the current test hierarchy into production ownership.

Keep compatibility bridges thin where necessary.
Run old and new paths side-by-side or through focused parity tests until equivalent.

## 11. B-1 and later refactor rule

After B-0, refactor **the production runtime**, not the test hierarchy.

`battle_web_import_test.gd` is the main god-script candidate to audit. Its responsibilities should be separated gradually with checkpoints and regression tests, similar in discipline to the completed WorldMap refactor but not by blindly copying the same boundaries.

Battle refactoring is more sequencing-sensitive than WorldMap because input, turn order, AI, animation, timers, skills, movement, and scene state interact tightly.

Therefore:

- preserve call order;
- preserve signal timing;
- preserve await/timer sequencing;
- preserve combat values and balance;
- preserve AI decisions unless explicitly changing them;
- preserve input consumption and animation lifecycle;
- do not optimize merely to reduce line count.

## 12. Standing architecture rule

For future battle features:

1. First identify the production responsibility owner.
2. Add the feature to an existing appropriate Controller/Service/Helper when one exists.
3. Create a new dedicated module only for a genuinely independent responsibility.
4. Keep the canonical battle controller focused on wiring, orchestration, and scene-level coordination.
5. Do not put new real game logic back into `*_test.gd` simply because the current test scene is convenient.
6. Scenario-only behavior stays in scenario tests/fixtures.

## 13. Current status / next action

Verified on 2026-09-18:

- B-0A ownership audit recorded in `agent/BATTLE_RUNTIME_OWNERSHIP_AUDIT_20260918.md`.
- B-0B canonical production boundary created as `scenes/battle/Battle_Main.tscn` + `scripts/battle/battle_controller.gd`.
- B-0C generic ISO presentation modules promoted into `scripts/battle/presentation/iso/`.
- Production HUD and Imjin scenario consumers now route through `scripts/battle/battle_controller.gd`.
- B-0C final HEAD `1a9b8fb05323f825ca9ef5f8adbe3d61f64872c3` passed workflow run `35290623012`.
- WorldMap still intentionally enters `res://Battle_Land.tscn`.

B-1A refreshed the current god-script baseline:

- `scripts/battle_web_import_test.gd`: 669,000 bytes / 16,046 lines / 859 functions.
- Historical function-map line numbers are no longer authoritative.
- Current audit: `agent/BATTLE_ENGINE_B1A_CURRENT_FUNCTION_AUDIT_20260918.md`.

Current next task:

**B-1B | Extract BattleMovementQueryService with compatibility wrappers**

Implementation brief for Codex:

`agent/BATTLE_ENGINE_B1B_CODEX_MOVEMENT_QUERY_EXTRACTION_20260918.md`

The first extraction is limited to synchronous Grid/Path query logic. Do not combine it with AI decisions, move animation, selection flow, attack range, turn orchestration, or WorldMap handoff.

This document is the persistent source of truth for continuing the battle refactor in a new chat/session.
