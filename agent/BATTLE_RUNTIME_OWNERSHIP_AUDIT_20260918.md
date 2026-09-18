# B-0A | Battle Runtime Ownership Audit

Date: 2026-09-18  
Repository: `kimjak-app/SamWar_BattleLab`  
Working branch: `refactor/engine-core-20260918`  
Baseline: `recovery/worldmap-iso-sfx-services-20260912@97a47279647a37ed6055fb0f54f73fc59e0b375e`

## 1. Goal

Establish the production battle runtime boundary before any large refactor.

This audit does not change battle rules, balance, turn order, AI decisions, WorldMap handoff, scene transition, signals, await/timer sequencing, or presentation behavior.

The required ownership classes are:

- Core / production runtime
- Scenario fixture
- Presentation staging / promotion candidate
- QA / regression harness
- Legacy / dead candidate

## 2. Verified production entry path

Current WorldMap production handoff is still:

```text
WorldMap.tscn
  -> scripts/worldmap/worldmap_main.gd
  -> WORLDMAP_BATTLE_SCENE_PATH = res://Battle_Land.tscn
  -> Battle_Land.tscn
  -> res://scripts/battle_web_import_test.gd
```

The Battle -> WorldMap return contract also remains bound to the same runtime script and the existing Engine meta keys.

Therefore:

- `Battle_Land.tscn` is the actual production battle scene today.
- `scripts/battle_web_import_test.gd` is the de facto production battle controller despite its `_test` name.
- The production runtime boundary is semantically real but structurally mislabeled.

## 3. Current scene inheritance topology

```text
Battle_Land.tscn
  -> scripts/battle_web_import_test.gd

tests/scenes/Battle_UI_Production_Test.tscn
  -> scripts/battle_web_import_test.gd
  -> test-only Production HUD bridge scripts

tests/scenes/Battle_UI_Production_Imjin_Test.tscn
  -> instance Battle_UI_Production_Test.tscn
  -> tests/scripts/battle_ui_production_imjin_test.gd
     extends scripts/battle_web_import_test.gd

tests/scenes/Battle_UI_Production_Imjin_IsoMovement_Test.tscn
  -> instance Battle_UI_Production_Imjin_Test.tscn
  -> tests/scripts/battle_ui_production_imjin_iso_movement_test.gd
     extends tests/scripts/battle_ui_production_imjin_test.gd
```

The current direction is therefore still:

```text
test-named controller = real runtime authority
        ↓
production-HUD staging test
        ↓
Imjin scenario fixture
        ↓
ISO presentation experiment
```

This must be inverted before the major controller split.

## 4. Controller size / risk baseline

Existing function map for `scripts/battle_web_import_test.gd` records:

- 14,810 lines
- 791 functions
- 317 constants
- 225 `@onready` variables
- Stage B review-required: 145 functions
- Stage C coupled / keep in battle main: 575 functions
- Stage D contract-locked: 71 functions

The 71 Stage D functions include WorldMap context/result/scene-transition ownership and must not be casually moved during the production-boundary creation.

This confirms that B-0B must be a compatibility-boundary task, not a mass extraction.

## 5. Ownership map

### A. Core / production runtime

These are already generic runtime responsibilities or are the current production authority.

| File | Ownership decision | B-0 action |
|---|---|---|
| `Battle_Land.tscn` | Current production scene | Preserve unchanged as known-good compatibility scene during B-0B |
| `scripts/battle_web_import_test.gd` | De facto production controller / god-script | Preserve behavior; place behind canonical production controller boundary before later split |
| `scripts/battle_grid_controller.gd` | Generic logical battle grid | Keep production |
| `scripts/battle_range_overlay_tile.gd` | Generic orthogonal tactical overlay renderer | Keep production |
| `scripts/battle_facing_arrow_tile_button.gd` | Generic facing-selection renderer | Keep production |
| `scripts/battle_unit_state.gd` | Core runtime unit model/state | Keep production |
| `scripts/battle/battle_momentum_state.gd` | Core momentum state model | Keep production |
| `scripts/battle/battle_runtime_snapshot.gd` | Core runtime snapshot/restore | Keep production |
| `scripts/battle/battle_skill_resolver.gd` | Generic skill plan/target/command resolver | Keep production |
| `scripts/battle/hero_battle_design_adapter.gd` | Hero-data -> battle contract adapter | Keep production |
| `scripts/battle/ui/battle_hud_state_adapter.gd` | Generic battle state -> HUD state adapter | Keep production |
| `scripts/battle/unit_type_contract.gd` | Canonical unit-type rule contract | Keep production |
| `scripts/battle/helpers/*` | Locked generic helper ownership from Stage B | Keep production; do not reopen without a concrete reason |

### B. WorldMap-owned boundary, not Battle refactor ownership

| File | Ownership decision | B-0 action |
|---|---|---|
| `scripts/worldmap/battle/battle_context_service.gd` | WorldMap prepares BattleContext | Do not move into battle runtime |
| `scripts/worldmap/battle/battle_result_service.gd` | WorldMap validates/applies persistent result | Do not move into battle runtime |
| `scripts/worldmap/worldmap_main.gd` handoff code | Scene/meta orchestration boundary | Keep locked until parity gate |

Battle consumes prepared context and emits a battle result. It must not take ownership of persistent WorldMap state.

### C. Scenario fixture

| File | Ownership decision | B-0 action |
|---|---|---|
| `tests/scenes/Battle_UI_Production_Imjin_Test.tscn` | Imjin scenario fixture | Keep in tests |
| `tests/scripts/battle_ui_production_imjin_test.gd` | Imjin roster/content + scenario overrides | Keep in tests; promote only individually proven generic behavior |
| `tests/scripts/imjin_auto_turn_camera_guard.gd` | Imjin/Test2 camera parity guard | Keep scenario-side for now; investigate separately if a generic runtime defect is proven |
| `tests/scripts/imjin_status_empty_legend.gd` | Test2 empty-state presentation helper | Keep in tests |

The Imjin script explicitly identifies itself as Demo/Test2 scenario-only. It must not become the generic battle engine.

### D. Presentation staging / promotion candidate

| File | Ownership decision | B-0 action |
|---|---|---|
| `tests/scenes/Battle_UI_Production_Test.tscn` | Production HUD staging scene, not canonical runtime | Keep as staging/QA until production HUD promotion is explicit |
| `tests/scripts/battle_ui_production_test_roster.gd` | Test-only roster bridge | Presentation promotion candidate only |
| `tests/scripts/battle_ui_production_test_bottom_hud.gd` | Production-test bottom HUD bridge | Presentation promotion candidate only |
| `tests/scripts/battle_ui_production_roster_collapse.gd` | Test-scene presentation bridge / temporary global action UI | Presentation promotion candidate only |
| `tests/scenes/Battle_UI_Production_Imjin_IsoMovement_Test.tscn` | ISO presentation candidate | Keep in tests through B-0B; generic ISO may be promoted in B-0C |
| `tests/scripts/battle_ui_production_imjin_iso_movement_test.gd` | ISO projection/presentation overrides on inherited logical rules | Split generic ISO presentation from Imjin/test overrides in B-0C |
| `tests/scripts/battle_iso_grid_projection.gd` | Generic logical->ISO projection adapter | Strong production-promotion candidate |
| `tests/scripts/battle_iso_range_overlay_tile.gd` | Generic ISO overlay renderer | Strong production-promotion candidate |
| `tests/scripts/battle_iso_facing_arrow_tile_button.gd` | Generic ISO facing renderer | Strong production-promotion candidate |
| `tests/scripts/battle_iso_facing_indicator_label.gd` | Generic ISO persistent-facing renderer | Strong production-promotion candidate |

Important: the ISO test explicitly preserves the inherited orthogonal logical grid, Manhattan range/path/facing, and changes screen projection/presentation only. That separation is desirable and should be retained.

### E. QA / regression harness

| File | Ownership decision | B-0 action |
|---|---|---|
| `tests/scripts/battle_supply_hud_mock.gd` | Explicit TEST-ONLY mock | Keep in QA |
| `tests/scripts/imjin_cutin_visual_qa.gd` | Cut-in visual QA harness | Keep in QA |
| existing focused battle validators under `tools/` and `tests/` | Regression protection | Keep and reuse for parity gates |

### F. Legacy / dead candidate

| File | Ownership decision | B-0 action |
|---|---|---|
| `Battle_WebImport_Test.tscn` | Legacy standalone harness using the same god-script | Do not delete in B-0; require usage/reference audit before removal |

No file is deleted during B-0.

## 6. B-0B canonical production boundary design

Approved minimal shape:

```text
scenes/battle/Battle_Main.tscn
scripts/battle/battle_controller.gd
```

B-0B must create a canonical production-owned scene/controller boundary **without moving hundreds of coupled functions yet**.

### Recommended compatibility bridge

1. `scripts/battle/battle_controller.gd` becomes the canonical production controller name.
2. During B-0B it may temporarily inherit/delegate to `scripts/battle_web_import_test.gd` so behavior remains byte-for-byte equivalent at the call boundary.
3. `scenes/battle/Battle_Main.tscn` should reuse the known-good production scene structure rather than rebuilding nodes by hand.
4. Existing `Battle_Land.tscn` remains intact as the current WorldMap production path.
5. WorldMap must **not** switch `WORLDMAP_BATTLE_SCENE_PATH` during B-0B.
6. Existing test scenes remain intact and may begin consuming the new production controller/scene only after parse/load parity is proven.

This creates the missing ownership boundary first. B-0C then promotes generic runtime and ISO responsibilities incrementally.

## 7. B-0C promotion order

After B-0B parse/load parity:

1. Make test/runtime consumers depend on the canonical production boundary.
2. Promote only generic ISO helpers from `tests/scripts/` to production battle presentation ownership.
3. Separate Imjin scenario overrides from generic ISO behavior.
4. Keep Production HUD test bridges in tests until each presentation owner is explicitly promoted.
5. Only after parity is green begin responsibility extraction from the 669 KB / 791-function controller.

## 8. Locked behavior for B-0

Do not change:

- WorldMap -> Battle Engine meta contract
- Battle -> WorldMap result contract
- `Battle_Land.tscn` production entry path
- 5v5 / 3 main + 2 reinforcement contract
- turn/phase order
- one-side exhaustion behavior
- AI decisions
- movement/range/facing rules
- attack/skill/strategy/defend formulas
- reinforcement timing
- result/retreat/victory flow
- signal order
- await/timer sequencing
- cut-in timing/routing
- supply settlement
- Hero ID compatibility
- current UI geometry/content

## 9. Validation gates

B-0B/B-0C must reuse repository-established checks, including:

- Godot 4.6 import/class-cache check
- project/editor headless load
- battle scene headless load
- WorldMap scene load
- existing battle turn-order validators
- WorldMap -> Battle input lifecycle validator
- existing Hero/cutin/unit-type validators when touched
- `git diff --check`
- generated `.gd.uid` review
- GitHub Actions `Verify C-track refactor` until a dedicated battle-refactor workflow replaces it

Baseline `recovery/worldmap-iso-sfx-services-20260912@97a4727` has a successful `Verify C-track refactor` run: `35286543433`.

## 10. B-0A decision

B-0A ownership audit result:

- Production battle authority is identified.
- Scenario-specific code is identified.
- Test-only QA code is identified.
- Generic ISO promotion candidates are identified.
- WorldMap handoff/result contracts remain explicitly locked.
- No mass extraction is authorized.
- B-0B should create only the canonical production ownership boundary and compatibility bridge.

Next task: **B-0B | Canonical Production Battle Skeleton**.
