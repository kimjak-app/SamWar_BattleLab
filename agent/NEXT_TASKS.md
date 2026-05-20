# NEXT TASKS

## Current Stable Baseline
v0.65g Root Migration Stable QA Verified

## Priority 1
v0.65h Slot-Based UnitVisual Architecture Design

Goal:
- Treat `AllyUnitVisualRoot`, `AllySupportUnitVisualRoot`, `EnemyUnitVisualRoot`, and `EnemySupportUnitVisualRoot` as combat slot roots, not fixed hero roots.
- Prepare for larger unit counts and data-driven battle setup.
- Design a structure that can handle land, naval, and siege units such as Mongol troops, geobukseon, panokseon, tower ships, and siege engines.

Required design fields:
- `slot_id`
- `side`
- `unit_id`
- `hero_name`
- `nation`
- `unit_type`
- `visual_key`
- `portrait_key`
- `domain`: `land` / `naval` / `siege`
- `footprint`: `1x1` / `2x1` / `2x2` / `3x1`
- `hp`
- `troop`
- `move_range`
- `attack_range`
- `move_fx_profile`: `dust` / `wake` / `none`
- `attack_fx_profile`: `slash` / `arrow` / `gun` / `cannon` / `fire` / `ram`
- `click_area_profile`
- `visual_scale_profile`

Important:
- This is a design step first.
- Do not start by moving ClickArea / READY / FacingIndicator.
- Do not change combat formulas or turn flow.

## Priority 2
ClickArea / READY / FacingIndicator integration review

Goal:
- Decide whether each should move under UnitVisualRoot or remain separate.

Notes:
- ClickArea has collision/input coordinate risks and must be handled in its own migration step.
- READY frame and FacingIndicator are CanvasLayer/UI coordinate concerns and should be reviewed separately from world visual roots.

## Priority 3
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

## Priority 4
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
