# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.65i-3 READY/Facing UI Slot Registry Cleanup

## Main Scene
`Battle_Fullscreen_Test.tscn`

Attached scripts:
- `scripts/battle_web_import_test.gd`
- `scripts/battle_unit_state.gd`

This is the current stable 2v2 Godot battle verification scene.

## Engine / Layout Baseline
- Godot 4 based SamWar battle engine port and visual experiment.
- 1920x1080 fullscreen battle board on `Battle_Fullscreen_Test.tscn`.
- 18x10 logical grid maintained.
- Scene controls layout.
- Code controls behavior.

## Current Battle Setup
- Ally: 이순신, 정도전
- Enemy: 관우, 장비

Current visual test assignment:
- 이순신 = `korea_archer`
- 정도전 = `korea_gunner`
- 관우 = `china_cavalry`
- 장비 = `china_infantry`

## Current Battle Flow
1. One ally actor acts.
2. One enemy AI actor acts.
3. Next available ally actor acts.
4. Next enemy AI actor acts.
5. New round starts.

Verified principle:
아군 1부대 행동 -> 적 1부대 AI 행동 -> 다음 아군 1부대 행동.

## Current Working Features
- 2v2 battle loop works.
- BATTLE 1 / BATTLE 2 Round Toast works.
- Basic Battle FX Pack 1 works:
  - move dust
  - attack slash
  - hit spark
  - damage number
- Move dust appears only during movement.
- Idle breathing works.
- READY frame works.
- UnitCloseupPanel works.
- Active ally lock works.
- Right-click move rollback works.
- Right-click attack cancel works.
- HP 0 cleanup works.
- Headless scene launch has been kept at 0 errors.

## v0.65g Completed Structure
- UnitVisualRoot Adapter Layer is in place.
- Ally main visual nodes are under `AllySide/AllyUnitVisualRoot`.
- Ally support visual nodes are under `AllySide/AllySupportUnitVisualRoot`.
- Enemy main visual nodes are under `EnemySide/EnemyUnitVisualRoot`.
- Enemy support visual nodes are under `EnemySide/EnemySupportUnitVisualRoot`.
- Actual visual nodes for all 4 combat slots are now grouped under their UnitVisualRoot.
- ClickArea / READY frame / FacingIndicator / UnitVisualTemplate nodes remain separate for safety.
- UnitVisualTemplate nodes remain as layout offset references.

## v0.65g Fixes
- Ally portrait `FACING_UP` / `FACING_DOWN` offset issue fixed.
- Dead enemy main click priority issue fixed.
- After Guan Yu dies, Yi Sun-sin and Jeong Do-jeon can attack living Zhang Fei.
- Enemy support AI remained valid after enemy main death.

## v0.65h Slot Metadata State
- `BattleUnitState` now includes slot-based metadata:
  - `slot_id`
  - `nation`
  - `portrait_key`
  - `domain`
  - `footprint`
  - `move_fx_profile`
  - `attack_fx_profile`
  - `click_area_profile`
  - `visual_scale_profile`
- Current demo units carry slot metadata:
  - Yi Sun-sin = `ally_main` / `korea` / `land` / `1x1` / `arrow`
  - Jeong Do-jeon = `ally_support` / `korea` / `land` / `1x1` / `gun`
  - Guan Yu = `enemy_main` / `china` / `land` / `1x1` / `slash`
  - Zhang Fei = `enemy_support` / `china` / `land` / `1x1` / `slash`
- Unit visual slot lookup now prioritizes `unit_state.slot_id`.
- Existing direct `unit_state` comparison fallback remains.
- No combat formula, turn flow, AI order, or visual node movement changed in v0.65h.

## v0.65i-3 READY/Facing UI Slot Registry State
- `READY frame` and `FacingIndicator` remain under `BattleUI`.
- No `BattleUI` node migration was done.
- No `UnitVisualRoot` parent change was done.
- Existing visual slot dictionaries still include:
  - `ready_frame`
  - `facing_indicator`
- READY frame refresh now resolves slot UI through slot-based visual slot lookup.
- FacingIndicator refresh now resolves slot UI through slot-based visual slot lookup.
- Existing direct `unit_state` comparison fallback remains for anchor/position dispatch safety.
- `_position_ready_frame_for_unit()` flow is preserved.
- `_position_facing_indicator_for_ally*()` / `_position_facing_indicator_for_enemy*()` flows are preserved.
- `_world_to_battle_ui_position()` based UI coordinate conversion is preserved.
- ClickArea code path was not modified in v0.65i-3.
- No combat formula, turn flow, AI order, or HP cleanup behavior was intentionally changed.

## Unit Token Asset State
- Korea / China / Japan infantry / archer / gunner / cavalry token assets are normalized around the 256 baseline.
- Country/type folder structure is used.
- `visual_key -> texture path` lookup is maintained.
- UnitCloseupPanel uses the same visual_key based troop token lookup.
- Zhang Fei no longer uses the legacy 1024 China infantry token in the current test setup.
- Guan Yu and Zhang Fei are normalized against the same 256 baseline.

## Structural Notes
- The 4 UnitVisualRoot nodes are current combat slot roots, not fixed hero-specific roots.
- Future units such as Mongol troops, naval units, geobukseon, panokseon, tower ships, and siege weapons should be represented through data such as `visual_key`, `unit_type`, `domain`, and `footprint`.
- ClickArea / READY / FacingIndicator are not inside UnitVisualRoot yet.
- ClickArea uses collision/input coordinates and should only be migrated in a separate focused step.
- READY frame and FacingIndicator are UI/CanvasLayer concerns and should be evaluated separately from world visual roots.
- READY frame and FacingIndicator slot attachment is now cleaned up around slot-based visual slot lookup while staying under `BattleUI`.
- UnitVisualTemplate nodes are still used as scene-authored layout offset references.

## Debug Notes
- `_debug_print_unit_visual_root_slots()` currently remains and prints one startup slot check.
- `[ATTACK_CLICK]` print currently remains and prints only during attack target clicks.
- `ALLY PORTRAIT OFFSET DEBUG` function may exist, but its reset-time call is removed.
- Debug cleanup is a future cleanup task, not part of the verified v0.65g behavior.

## QA Notes
- Headless project launch exit code 0 confirmed after v0.65i-3.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65i-3.
- Full interactive QA items such as movement, attack, facing selection, and overlap targeting still require in-editor/manual verification.

## Guardrails
- Do not modify `Battle_WebImport_Test.tscn`.
- Do not change `attack_range`.
- Do not change `move_range`.
- Do not change `distance formula`.
- Do not change movement range cell calculation.
- Do not change facing selection logic.
- Do not change basic attack judgement.
- Do not change damage formula.
- Do not change enemy AI order.
- Do not change active ally lock.
- Do not change HP 0 cleanup.
- Do not break BATTLE Round Toast.
- Do not break Basic Battle FX Pack 1.
- Do not break UnitCloseupPanel.
- Do not break ally portrait up/down fix.
- Do not break dead enemy click priority fix.
- Preserve right-click move rollback.
- Preserve right-click attack cancel.
