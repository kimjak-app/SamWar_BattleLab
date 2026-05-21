# NEXT TASKS

## Current Stable Baseline
v0.65j-4 Auto Battle Button Hook

## Priority 1
v0.65j-5 Full Auto Battle Loop Prototype

Goal:
- Iterate automatic action flow until turn or battle completion.
- Build on the current one-action button-triggered implementation.

Notes:
- Keep manual control paths intact.

## Completed
v0.65j-4 Auto Battle Button Hook

Completed items:
- Added `AutoBattleButton` to `BattleUI/CommandBar`.
- Connected button press to `_run_auto_action_for_active_ally_once()`.
- Added auto-battle button enabled/disabled control to `_set_phase()`.
- Kept the button scoped to one active ally auto action only.
- Kept the full auto battle loop unimplemented.
- Preserved existing manual command buttons.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.65j-3a Auto Move + Auto Facing Completion

Completed items:
- Extended `_try_auto_move_for_active_ally()` to start actual movement through the existing move demo path.
- Added auto-action flags for auto move/facing flow separation.
- Added nearest-enemy auto facing selection after move.
- Auto move no longer stops at facing-select wait state during auto flow.
- Preserved manual move + facing UX for non-auto flow.
- Kept the implementation disconnected from any auto battle button.
- Kept the implementation disconnected from any full auto loop.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65j-3 Ally Auto Battle One-Action MVP

Completed items:
- Added `_run_auto_action_for_active_ally_once()`.
- Added `_try_auto_attack_for_active_ally()`.
- Added `_try_auto_move_for_active_ally()`.
- Added `_auto_wait_active_ally()`.
- Connected auto attack MVP to the existing ally basic attack flow.
- Kept auto move at candidate-selection-only level for safety.
- Kept auto wait at scaffold level.
- Kept the new MVP disconnected from any button or full auto loop.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65j-2 Auto Battle Helper Functions Scaffold

Completed items:
- Added auto battle helper scaffold functions to `scripts/battle_web_import_test.gd`.
- Added actionable-unit and living-target side helpers.
- Added demo-damage-based auto kill helper.
- Added score-based auto attack target helper.
- Added best auto attack target helper.
- Added best auto move cell scaffold helper.
- Added optional auto policy debug snapshot helper.
- Kept helper functions disconnected from existing battle execution flow.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65j-1 Auto Battle Action Policy Design

Completed items:
- Added `agent/AUTO_BATTLE_ACTION_POLICY.md`.
- Defined shared auto action purpose and core flow.
- Defined draft target priority policy.
- Defined draft movement destination priority policy.
- Documented current reusable function candidates for future implementation.
- Kept this step documentation-only with no code/scene changes.

## Earlier Completed
v0.65i-3 READY/Facing UI Slot Registry Cleanup

Completed items:
- Kept `AllyReadyFrame` / `AllySupportReadyFrame` under `BattleUI`.
- Kept all 4 `FacingIndicator` labels under `BattleUI`.
- Preserved `ready_frame` / `facing_indicator` entries in the slot visual dictionaries.
- Connected READY/Facing refresh through slot-based visual slot lookup helpers.
- Preserved `_position_ready_frame_for_unit()` flow.
- Preserved `_position_facing_indicator_for_*()` flows.
- Preserved `_world_to_battle_ui_position()` UI conversion flow.
- Did not modify ClickArea code path.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65h Slot-Based UnitVisual Architecture Design

Completed items:
- `BattleUnitState` has slot-based metadata.
- Four demo units carry slot metadata.
- UnitVisual slot lookup prioritizes `unit_state.slot_id`.
- Direct `unit_state` comparison fallback remains.
- No ClickArea / READY / FacingIndicator migration was done.
- No combat formula, turn flow, AI order, or visual node movement changed.

## Priority 2
v0.65i-2 ClickArea Root Migration Spike

Goal:
- Test whether ClickArea can move closer to slot-root ownership without breaking collision/input coordinates.
- Keep this isolated from auto battle and from combat logic changes.

## Priority 3
Debug cleanup

Review and decide whether to remove:
- `_debug_print_unit_visual_root_slots()`
- `[ATTACK_CLICK]` print
- `_debug_print_ally_portrait_offsets()` if no longer needed

## Ongoing QA Checklist
- Battle starts with BATTLE 1 toast.
- 2v2 loop remains stable.
- Active ally lock remains stable.
- Move dust appears only during movement.
- Attack slash / hit spark / damage number remain stable.
- UnitCloseupPanel remains stable.
- READY frame remains stable.
- HP 0 cleanup remains stable.
- Ally portrait up/down positions remain stable.
- Guan Yu death does not block Zhang Fei target selection.
- Headless launch remains 0 errors.
