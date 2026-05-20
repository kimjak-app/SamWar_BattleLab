# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.65e Unit Token Asset Normalize Apply Verified

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

## Unit Token Asset State
- Korea / China / Japan infantry / archer / gunner / cavalry token assets are normalized around the 256 baseline.
- Country/type folder structure is used.
- `visual_key -> texture path` lookup is maintained.
- UnitCloseupPanel uses the same visual_key based troop token lookup.
- Zhang Fei no longer uses the legacy 1024 China infantry token in the current test setup.
- Guan Yu and Zhang Fei are normalized against the same 256 baseline.

## Remaining Structural Issue
Functionally the scene is stable, but two visual structures still coexist:

Actual battle nodes:
- `AllySide/AllyUnitToken`
- `AllySide/AllyMoveDustSprite`
- `AllySide/AllyPortraitBadge`
- `AllySide/AllyHPBar`
- `AllySide/AllyTroopLabel`
- `EnemySide/EnemyUnitToken`
- `EnemySide/EnemyMoveDustSprite`
- `EnemySide/EnemyPortraitBadge`
- `EnemySide/EnemyHPBar`
- `EnemySide/EnemyTroopLabel`

Type-specific template nodes:
- `AllySide/AllyInfantryUnitVisualTemplate`
- `AllySide/AllyArcherUnitVisualTemplate`
- `AllySide/AllyGunnerUnitVisualTemplate`
- `AllySide/AllyCavalryUnitVisualTemplate`
- `EnemySide/EnemyInfantryUnitVisualTemplate`
- `EnemySide/EnemyArcherUnitVisualTemplate`
- `EnemySide/EnemyGunnerUnitVisualTemplate`
- `EnemySide/EnemyCavalryUnitVisualTemplate`

This can make unit visuals overlap in the 2D editor. It is the next structural cleanup target.

## Next Structural Direction
v0.65g UnitVisual Single Slot Refactor

Unify runtime visuals around the actual battle token nodes:
- `AllyUnitToken.texture = visual_key texture`
- `EnemyUnitToken.texture = visual_key texture`
- `AllySupportUnitToken.texture = visual_key texture`
- `EnemySupportUnitToken.texture = visual_key texture`

Type-specific templates should remain only as slot/layout references, not active visible unit visuals.

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
- Preserve right-click move rollback.
- Preserve right-click attack cancel.
