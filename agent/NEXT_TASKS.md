# NEXT TASKS

## Current Stable Baseline
v0.65e Unit Token Asset Normalize Apply Verified

## Priority 1
v0.65g UnitVisual Single Slot Refactor

Goal:
- Stop using type-specific template token sprites as active visible unit visuals.
- Use actual battle nodes as the single runtime visual slots:
  - `AllySide/AllyUnitToken`
  - `AllySide/AllySupportUnitToken`
  - `EnemySide/EnemyUnitToken`
  - `EnemySide/EnemySupportUnitToken`
- Swap only those token textures from `visual_key`.
- Keep type-specific templates as slot/layout reference nodes only.
- Keep template token sprites hidden at runtime.
- Remove 2D editor visual overlap between actual unit nodes and template visuals.

Reason:
- This is the foundation for later world map / city / hero data integration.
- Future battle setup should receive `hero_name`, `nation`, `unit_type`, `visual_key`, `troop`, `hp`, and `portrait`, then apply the visual automatically.

Example future input:
- `hero_name = "이순신"`
- `nation = "korea"`
- `unit_type = "archer"`
- `visual_key = "korea_archer"`

Expected result:
- `AllyUnitToken.texture = korea_archer_01.png`

## v0.65g Hard Guardrails
Do not change:
- `AllyUnitToken` node path/name.
- `EnemyUnitToken` node path/name.
- `AllySupportUnitToken` / `EnemySupportUnitToken` path/name.
- `AllyHPBar` / `AllyTroopLabel` / `AllyPortraitBadge` paths.
- `EnemyHPBar` / `EnemyTroopLabel` / `EnemyPortraitBadge` paths.
- `attack_range`.
- `move_range`.
- `distance formula`.
- Movement range cell calculation.
- Facing selection logic.
- Basic attack judgement.
- Damage formula.
- Enemy AI order.
- Active ally lock.
- HP 0 cleanup.
- BATTLE Round Toast.
- Basic Battle FX Pack 1.
- Right-click move rollback.
- Right-click attack cancel.
- `Battle_WebImport_Test.tscn`.

## Priority 2
World map / city / hero data handoff design

Goal:
- Define how external campaign data will populate `BattleUnitState`.
- Keep battle scene visual application data-driven through `visual_key`.

## Priority 3
Reusable UnitVisual package cleanup

Goal:
- After v0.65g, decide whether type-specific templates should remain in the scene, move to separate `.tscn` assets, or become editor-only reference packages.

## Ongoing QA Checklist
- Battle starts with BATTLE 1 toast.
- 2v2 loop remains stable.
- Active ally lock remains stable.
- Move dust appears only during movement.
- Attack slash / hit spark / damage number remain stable.
- UnitCloseupPanel remains stable.
- READY frame remains stable.
- HP 0 cleanup remains stable.
- Headless launch remains 0 errors.
