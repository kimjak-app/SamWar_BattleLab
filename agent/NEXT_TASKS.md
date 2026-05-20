# NEXT TASKS

## Current Stable Baseline
v0.65h Slot-Based UnitVisual Architecture Design Stable

## Priority 1
v0.65i ClickArea / READY / FacingIndicator Integration Review

Goal:
- Decide whether ClickArea, READY frame, and FacingIndicator should move under UnitVisualRoot or remain separate.
- Keep each category separable; do not batch-migrate all coordinate systems at once.

Notes:
- ClickArea has collision/input coordinate risks and must be handled in its own migration step.
- READY frame and FacingIndicator are CanvasLayer/UI coordinate concerns and should be reviewed separately from world visual roots.

## Completed
v0.65h Slot-Based UnitVisual Architecture Design

Completed items:
- `BattleUnitState` has slot-based metadata.
- Four demo units carry slot metadata.
- UnitVisual slot lookup prioritizes `unit_state.slot_id`.
- Direct `unit_state` comparison fallback remains.
- No ClickArea / READY / FacingIndicator migration was done.
- No combat formula, turn flow, AI order, or visual node movement changed.

## Priority 2
Target selection policy for overlapping live units

Current temporary behavior:
- Dead enemy main no longer blocks living enemy support target selection.
- If enemy main and enemy support are both alive and both clicked, existing enemy main priority is preserved.

TODO:
- Design target selection policy for overlapping living enemy units.

Future candidates:
1. Nearest unit first.
2. Currently attackable target first.
3. Visual center closest to click point first.
4. Overlapped target list popup.
5. Tab or button target cycling.

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
