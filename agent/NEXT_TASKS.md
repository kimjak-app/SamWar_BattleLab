# NEXT TASKS

## Current Stable Baseline
v0.65j-1 Auto Battle Action Policy Design

## Priority 1
v0.65j-2 Auto Battle Helper Functions Scaffold

Goal:
- Introduce side-agnostic helper functions for auto battle planning.
- Reuse existing battle legality checks without changing combat behavior.

Notes:
- This should remain data-driven and not depend on `ClickArea`.
- This should not add the auto battle button yet.

## Completed
v0.65j-1 Auto Battle Action Policy Design

Completed items:
- Added `agent/AUTO_BATTLE_ACTION_POLICY.md`.
- Defined shared auto action purpose and core flow.
- Defined draft target priority policy.
- Defined draft movement destination priority policy.
- Documented current reusable function candidates for future implementation.
- Kept this step documentation-only with no code/scene changes.

## Previously Completed
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
v0.65j-3 Ally Auto Battle One-Action MVP

Goal:
- Execute one ally auto-battle action using the policy document.
- Keep turn flow and manual systems intact.

Notes:
- One acting ally only.
- No full-loop automation yet.

## Priority 3
v0.65j-4 Auto Battle Button Hook

Goal:
- Connect a UI trigger after one-action auto battle is stable.

## Priority 4
v0.65j-5 Full Auto Battle Loop Prototype

Goal:
- Iterate automatic action flow until turn or battle completion.

## Priority 5
v0.65i-2 ClickArea Root Migration Spike

Goal:
- Test whether ClickArea can move closer to slot-root ownership without breaking collision/input coordinates.
- Keep this isolated from auto battle and from combat logic changes.

## Priority 6
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
