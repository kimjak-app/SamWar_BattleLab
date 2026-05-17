# NEXT TASKS

## Current Stable Baseline
v0.64e Occupied Cell Blocking

---

## Current Patch — v0.64f-hotfix Movement Overlay Bounds + Hide After Move

Goal:
When Yi Sun-sin is selected, show all currently movable cells as blue range highlights.

Implemented:
- Add editor-visible MoveRangeOverlayLayer.
- Add MoveRangeCell_00 through MoveRangeCell_111 as a fixed ColorRect pool.
- Collect the prebuilt ColorRect pool once from script.
- Show only cells returned by BattleGridController.get_tiles_in_range() that also pass is_valid_move_target().
- Exclude origin, occupied ally cells, occupied enemy cells, and post-move cells.
- Hide range overlay during movement/attack resolving and after movement.
- Double-check board bounds before showing each pooled range cell.
- Hide MoveHighlight after successful movement.
- Log "이순신 이동 완료" after successful movement.
- Keep MoveHighlight as the separate selected-target feedback.

Notes:
- No GridOverlay drawing, _draw(), or queue_redraw() was added.
- Attack target selection and attack range validation are not implemented.
- v0.65 is not reached.

---

## Completed — v0.64e Occupied Cell Blocking

Goal:
Prevent movement into occupied cells.

Implemented:
- Add is_cell_occupied(cell) helper.
- Treat ally_unit_state.grid_cell as occupied.
- Treat enemy_unit_state.grid_cell as occupied.
- Keep origin-cell invalidation separate from occupied-cell checks.
- Make occupied cells invalid move targets.
- Keep existing MoveHighlight valid/invalid feedback.
- Include occupied=true/false in target-selection debug output.

Notes:
- Only empty cells are valid movement destinations.
- Attack target selection and attack range validation are not implemented.
- v0.65 is not reached.

---

## Completed — v0.64d Active Unit Selection

Goal:
Allow the player to click an ally unit and set it as the active unit.

Implemented:
- Add active_unit_state and active_unit_side MVP state.
- Set the single ally as active during reset_demo_state().
- Add editor-visible AllyUnitClickArea with a CollisionShape2D over Yi Sun-sin.
- Use AllyUnitClickArea/CollisionShape2D as a manual hitbox reference from _input().
- Handle left-click ally selection and battlefield move target selection in _input().
- Make _unhandled_input() ignore left mouse clicks to prevent duplicate handling.
- Do not depend on Area2D.input_event for active ally selection.
- Select the ally without changing the current move target.
- Show selection feedback through the battle log.
- Use active_unit_state for movement origin, movement range, and has_moved validation.
- Keep AllyUnitClickArea synced to the ally unit position during _reset_unit_group_positions().
- Keep movement visuals tied to the ally group for now.

Notes:
- This is still a single-ally MVP.
- Grid visual sync remains postponed.
- v0.65 is not reached.

---

## Completed — v0.64c MoveHighlight Cell Size Sync

Goal:
Make MoveHighlight match the actual BattleGridController logical cell size and position.

Implemented:
- Use BattleGridController.get_cell_size() for MoveHighlight sizing.
- Center MoveHighlight on the selected logical cell world position.
- Keep the existing MOVE_HIGHLIGHT_SIZE as a safe fallback when grid controller or cell size is invalid.
- Preserve runtime click target selection and MoveButton movement confirmation.

Notes:
- Grid visual sync remains postponed.
- v0.65 is not reached.

---

## Completed — v0.64b Runtime Move Target Selection

Goal:
Allow the player to select a movement target at runtime by clicking an in-bounds battlefield cell.

Implemented:
- Use _unhandled_input() for left-click target selection.
- Ignore clicks unless the battle is in ally turn, no demo animation is running, and ally_unit_state exists.
- Convert click world position through BattleGridController.world_to_grid().
- Ignore out-of-bounds clicks safely.
- Move MoveTargetMarker to the selected cell's BattleGridController.grid_to_world() position.
- Refresh MoveHighlight valid/invalid feedback after target selection.
- Keep MoveButton as the only movement confirmation action.
- Print one debug line per selected target click.

Notes:
- Grid visual sync is postponed to a later v0.64 patch.
- v0.65 is not reached.

---

## Completed — v0.64a Movement Command MVP

Goal:
Validate and confirm a snapped MoveTargetMarker cell as the active unit's first playable movement command.

Implemented:
- Use active unit BattleUnitState.grid_cell as origin.
- Use active unit BattleUnitState.move_range as movement limit.
- Use BattleGridController.is_in_bounds().
- Use BattleGridController.get_distance().
- Treat out-of-bounds cells as invalid.
- Treat cells beyond move_range as invalid.
- Treat the origin cell as invalid for movement preview.
- Treat units with has_moved == true as invalid for movement preview.
- Add simple valid/invalid visual feedback to MoveTargetMarker.
- Confirm valid movement with MoveButton.
- Update BattleUnitState.grid_cell after confirmed move.
- Set BattleUnitState.has_moved = true after confirmed move.
- Do not implement pathfinding yet.
- Do not implement terrain/occupied-cell blocking yet.

Expected result:
- MoveTargetMarker still snaps to grid.
- Valid move cells show valid feedback.
- Invalid move cells show invalid feedback.
- Valid move target moves the active unit visual group.
- The same unit cannot move twice in the same ally turn.
- No scene layout shifts.
- No major runtime-created battlefield nodes.

## Priority 1 — v0.64g Attack Target Selection

Goal:
Allow selecting an enemy target separately from movement target selection.

Requirements:
- Keep movement validation separate from attack validation.
- Do not combine movement and attack actions too early.

---

## Priority 2 — v0.64h Attack Range Validation

Goal:
Validate attackable enemy targets based on active unit attack_range.

Requirements:
- Use BattleGridController.get_distance().
- Use BattleUnitState.attack_range.
- Enemy target must be alive.

---

## Priority 3 — v0.64i Turn Action Flow Cleanup

Goal:
Clarify selected unit, selected target, and action availability during ally/enemy turn transitions.

Requirements:
- Preserve v0.64a movement behavior.
- Keep command buttons as explicit confirmation controls.
- Avoid introducing AI movement.

---

## Priority 4 — v0.64j Basic Battle Loop QA

Goal:
Run a focused QA pass on the basic battle loop before any v0.65 milestone.

Requirements:
- Verify no repeated Godot Output error spam.
- Verify movement and attack demo flow.
- Verify same-turn re-move blocking.
- Verify no unintended scene layout changes.

---

## Later — Move Command UX Cleanup

Goal:
Make the movement command flow easier to read and test.

Requirements:
- Clarify selected unit and selected target state.
- Keep the existing MoveButton confirmation behavior.
- Keep valid/invalid feedback visible and lightweight.
- Do not add advanced pathfinding yet.
- Do not redesign Battle_WebImport_Test.tscn.

---

## Later — Unit Move Animation Polish

Goal:
Polish the current simple movement Tween without adding pathfinding.

Requirements:
- Use BattleGridController.grid_to_world().
- Preserve unit visual group hierarchy.
- Preserve facing behavior.
- Keep animation simple and stable.
- Do not disturb existing attack/defense demo.

---

## Future Battle Expansion
- Terrain cost and blocking rules
- Pathfinding
- Multi-unit selection
- Formation rules
- Hit reactions
- Skill range previews
- Naval battle prototype
- Better shadows and grounding
- Better battlefield perspective
- Better projectile/explosion effects
