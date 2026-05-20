# HANDOFF TO CODEX

Before making changes, read:
1. `agent/GODOT_RULES.md`
2. `agent/CURRENT_STATE.md`
3. `agent/NEXT_TASKS.md`
4. `agent/HANDOFF_TO_CODEX.md`

## Stable Baseline
Current stable baseline is:

`v0.65h Slot-Based UnitVisual Architecture Design Stable`

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

## v0.65g Completed Work
- Added UnitVisualRoot Adapter Layer.
- Migrated Ally main visual nodes under `AllyUnitVisualRoot`.
- Migrated Ally support visual nodes under `AllySupportUnitVisualRoot`.
- Migrated Enemy main visual nodes under `EnemyUnitVisualRoot`.
- Migrated Enemy support visual nodes under `EnemySupportUnitVisualRoot`.
- Kept ClickArea / READY frame / FacingIndicator outside Root for safety.
- Kept UnitVisualTemplate nodes as layout offset references.
- Fixed ally portrait `FACING_UP` / `FACING_DOWN` offset issue.
- Fixed dead enemy main click priority blocking enemy support target selection.
- Kimjak F6 confirmed the Root migrations and fixes.

## v0.65h Completed Work
- Extended `BattleUnitState` with slot metadata.
- Injected slot metadata into the four current demo units.
- Added `slot_id` first visual slot lookup.
- Preserved direct `unit_state` comparison fallback.
- Preserved existing 2v2 battle loop behavior.
- Did not migrate ClickArea / READY frame / FacingIndicator.

Important:
- UnitVisualRoot nodes are combat slot roots.
- `slot_id` is the preferred UnitVisual slot lookup key.
- `visual_key` still controls token texture lookup.
- Existing direct unit references remain as fallback while the architecture is transitional.

## Unit Token State
Korea / China / Japan infantry / archer / gunner / cavalry token assets have been normalized around the 256 baseline.

Current visual test assignment:
- Yi Sun-sin = `korea_archer`
- Jeong Do-jeon = `korea_gunner`
- Guan Yu = `china_cavalry`
- Zhang Fei = `china_infantry`

Notes:
- Zhang Fei no longer depends on the legacy 1024 China infantry token.
- Guan Yu and Zhang Fei should share the normalized 256 token scale baseline.
- UnitCloseupPanel uses the visual_key based troop token lookup.

## Recommended Next Task
v0.65i ClickArea / READY / FacingIndicator Integration Review

Goal:
- Decide whether ClickArea, READY frame, and FacingIndicator should move under UnitVisualRoot or remain separate.
- Handle ClickArea separately because it affects collision/input coordinates.
- Handle READY frame and FacingIndicator separately because they are UI/CanvasLayer coordinate concerns.

## Important Direction
- Root is for a combat slot, not a fixed general.
- Large units and naval units need `footprint`, `domain`, and FX profile concepts.
- ClickArea should be reviewed separately because it affects collision/input coordinates.
- READY frame and FacingIndicator should be reviewed separately because they live in UI/CanvasLayer coordinates.

## Debug Cleanup Candidates
- `_debug_print_unit_visual_root_slots()`
- `[ATTACK_CLICK]` print
- `_debug_print_ally_portrait_offsets()`

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
- Do not break ally portrait up/down fix.
- Do not break dead enemy click priority fix.
- Preserve right-click move rollback.
- Preserve right-click attack cancel.
- Do not modify `Battle_WebImport_Test.tscn`.
