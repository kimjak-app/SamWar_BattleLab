# HANDOFF TO CODEX

Before making changes, read:
1. `agent/GODOT_RULES.md`
2. `agent/CURRENT_STATE.md`
3. `agent/NEXT_TASKS.md`
4. `agent/HANDOFF_TO_CODEX.md`

## Stable Baseline
Current stable baseline is:

`v0.65e Unit Token Asset Normalize Apply Verified`

## Core Scene And Scripts
- Core scene: `Battle_Fullscreen_Test.tscn`
- Core scripts:
  - `scripts/battle_web_import_test.gd`
  - `scripts/battle_unit_state.gd`

Do not modify:
- `Battle_WebImport_Test.tscn`

## Current Verified State
- 1920x1080 fullscreen battle board.
- 18x10 logical grid.
- 2v2 battle loop works.
- Ally one actor acts -> enemy one actor AI acts -> next ally actor acts.
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
- Headless scene launch is expected to remain 0 errors.

## Unit Token State
Korea / China / Japan infantry / archer / gunner / cavalry token assets have been normalized around the 256 baseline.

Current visual test assignment:
- Yi Sun-sin = `korea_archer`
- Jeong Do-jeon = `korea_gunner`
- Guan Yu = `china_cavalry`
- Zhang Fei = `china_infantry`

Notes:
- Zhang Fei no longer depends on the legacy 1024 China infantry token.
- Guan Yu and Zhang Fei should now share the normalized 256 token scale baseline.
- UnitCloseupPanel uses the visual_key based troop token lookup.

## Known Structural Issue
The battle currently has two visual structures:

Actual battle nodes:
- `AllySide/AllyUnitToken`
- `AllySide/AllySupportUnitToken`
- `EnemySide/EnemyUnitToken`
- `EnemySide/EnemySupportUnitToken`
- Their associated shadow, portrait, HPBar, troop label, click area, move dust, READY frame, and breathing logic.

Type-specific template nodes:
- `AllySide/AllyInfantryUnitVisualTemplate`
- `AllySide/AllyArcherUnitVisualTemplate`
- `AllySide/AllyGunnerUnitVisualTemplate`
- `AllySide/AllyCavalryUnitVisualTemplate`
- `EnemySide/EnemyInfantryUnitVisualTemplate`
- `EnemySide/EnemyArcherUnitVisualTemplate`
- `EnemySide/EnemyGunnerUnitVisualTemplate`
- `EnemySide/EnemyCavalryUnitVisualTemplate`
- Support templates also exist.

This coexistence can create 2D editor visual overlap. Runtime remains functionally stable, but the structure should be cleaned up next.

## Recommended Next Task
v0.65g UnitVisual Single Slot Refactor

Goal:
- Retire any active visible use of type-specific template token sprites.
- Use only the actual battle token nodes as runtime visual slots:
  - `AllyUnitToken.texture = visual_key texture`
  - `EnemyUnitToken.texture = visual_key texture`
  - `AllySupportUnitToken.texture = visual_key texture`
  - `EnemySupportUnitToken.texture = visual_key texture`
- Keep templates as slot/layout reference nodes only.
- Keep template token sprites hidden or editor-reference-only.
- Remove 2D editor overlap.
- Do not change combat logic, FX, or turn flow.

## Future Data Direction
Later world map / city / hero data should pass:
- `hero_name`
- `nation`
- `unit_type`
- `visual_key`
- `troop`
- `hp`
- `portrait`

Battle setup should place this data into `BattleUnitState`, then resolve the token texture through `visual_key`.

Example:
- `hero_name = "이순신"`
- `nation = "korea"`
- `unit_type = "archer"`
- `visual_key = "korea_archer"`

Expected token:
- `AllyUnitToken.texture = korea_archer_01.png`

## Do Not Break
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
- Do not break READY frame.
- Preserve right-click move rollback.
- Preserve right-click attack cancel.
- Do not modify `Battle_WebImport_Test.tscn`.
