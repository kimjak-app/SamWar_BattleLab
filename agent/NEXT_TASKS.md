# NEXT TASKS

## Current Stable Baseline
v0.64i-hotfix-4 Attack Range Debug + Enemy Range Gate

---

## Current Patch — v0.64j Unit Visual Footprint Calibration

Goal:
Calibrate unit visual footprint so formation, portrait, HP bar, troop label, click area, and logical grid_cell feel aligned.

Implemented:
- Use BattleGridController cell size, about 62.86 x 55.0, as visual reference.
- Reduce AllyUnitToken and EnemyUnitToken scale from 0.5 to 0.38.
- Reduce AllyPortraitBadge and EnemyPortraitBadge scale from 0.4 to 0.32.
- Pull ally portrait marker closer to the formation center.
- Pull enemy portrait marker closer to the formation center.
- Tighten SHADOW_OFFSET from Vector2(0.0, 42.0) to Vector2(0.0, 34.0).
- Tighten HP_BAR_OFFSET from Vector2(-54.0, 52.0) to Vector2(-54.0, 44.0).
- Tighten TROOP_LABEL_OFFSET from Vector2(-48.0, 64.0) to Vector2(-54.0, 56.0).
- Reduce AllyUnitClickArea and EnemyUnitClickArea RectangleShape2D hitboxes to 108 x 112.
- Add one-time reset debug prints for grid cell size and initial ally/enemy grid cells.
- Preserve grid_cell logic, occupied-cell rules, movement validation, attack range checks, and hit bounce logic.

Notes:
- Attack range overhaul is not implemented.
- Unit footprint occupancy system is not implemented.
- Enemy AI is not implemented.
- No GridOverlay drawing, _draw(), or queue_redraw() was added.
- v0.65 is not reached.

---

## Completed — v0.64i-hotfix-4 Attack Range Debug + Enemy Range Gate

Goal:
Add range debug output and prevent Guan Yu from hitting Yi Sun-sin from outside enemy attack range.

Implemented:
- Add get_unit_grid_distance(attacker, target).
- Add is_unit_in_attack_range(attacker, target).
- Set current demo attack ranges: Yi Sun-sin = 3, Guan Yu = 1.
- Print "ALLY MOVED" grid_cell and target_cell once after movement completes.
- Print "ALLY RANGE CHECK" once during the post-move attack range branch.
- Print "ALLY BASIC ATTACK CHECK" once when BasicAttackButton is pressed.
- Print "ENEMY RANGE CHECK" once when enemy reaction starts.
- Gate enemy reaction with enemy_unit_state.attack_range before applying ally damage or hit bounce.
- If Guan Yu is out of range, log "관우 사거리 밖" and return to ally turn without ally damage or hit bounce.
- Keep ally turn active after successful movement.
- Preserve movement state updates: visual position, portrait position, active unit grid_cell, has_moved, and ally_has_moved.
- Hide MoveHighlight and movement range overlay after movement.
- Keep MoveButton disabled after movement through ally_has_moved.
- Keep BasicAttackButton available after movement during ally turn.
- Add is_enemy_in_active_attack_range().
- Use ally_unit_state.attack_range for post-move range branching.
- If Guan Yu is in range after movement, log "공격 가능", keep ally turn, select Guan Yu, and show AttackHighlight.
- If Guan Yu is out of range after movement, log "공격 사거리 밖", start enemy turn/reaction, then return to ally turn.
- Confirm _start_idle_breathing() exists and call it only on the ally-turn branch.
- Preserve try_basic_attack() selected target fallback and "사거리 밖입니다" guard.
- Preserve BasicAttackButton -> play_basic_attack_demo().
- Smooth the enemy hit bounce during Yi Sun-sin's attack with an immediate recoil-and-return sequence.
- Add ENEMY_DEMO_DAMAGE for the enemy reaction demo.
- Add ally recoil, red flash, and HP/troop update during enemy reaction.
- Preserve enemy reaction after the attack demo and ally turn return after enemy reaction.

Notes:
- Turn End / Wait button is not implemented.
- New attack damage formulas are not implemented.
- Full attack range/unit type rule polish is not implemented.
- Enemy AI is not implemented.
- No GridOverlay drawing, _draw(), or queue_redraw() was added.
- v0.65 is not reached.

---

## Completed — v0.64h Turn Flow After Move

Goal:
After movement, prove that the battle can transition through enemy reaction and return to ally turn.

Implemented:
- Movement completion state cleanup.
- Existing enemy reaction/defense demo reuse.
- Ally turn reset through _return_to_ally_turn().

Notes:
- v0.64i supersedes this flow so movement no longer consumes the whole turn.

---

## Completed — v0.64g Attack Target Selection

Goal:
Allow the player to click Guan Yu and select him as an attack target.

Implemented:
- Add editor-visible EnemyUnitClickArea under the scene root.
- Add EnemyUnitClickArea/CollisionShape2D with a RectangleShape2D hitbox over Guan Yu.
- Add selected_attack_target_state and selected_attack_target_side.
- Check enemy hitbox manually from _input() after ally selection and before movement target selection.
- Clicking Guan Yu selects enemy_unit_state as the attack target.
- Clicking Guan Yu appends "관우 공격 대상 선택" to the battle log.
- Clicking Guan Yu does not move MoveTargetMarker and does not show MoveHighlight.
- Show AttackHighlight over Guan Yu using BattleGridController grid_to_world() and cell size when available.
- Clear AttackHighlight when selecting the ally, selecting a movement target, starting movement, finishing movement, or resetting demo state.
- Keep BasicAttackButton wired to the existing basic attack demo for v0.64g.

Notes:
- New attack damage formulas are not implemented.
- Enemy AI is not implemented.
- No GridOverlay drawing, _draw(), or queue_redraw() was added.
- v0.65 is not reached.

---

## Completed — v0.64f-hotfix-3 Clean Move Target UX

Goal:
Keep movement target UX clean by showing strong MoveHighlight only for valid selected movement targets.

Implemented:
- Add editor-visible MoveRangeOverlayLayer.
- Add MoveRangeCell_00 through MoveRangeCell_111 as a fixed ColorRect pool.
- Collect the prebuilt ColorRect pool once from script.
- Show only cells returned by BattleGridController.get_tiles_in_range() that also pass is_valid_move_target().
- Exclude origin, occupied ally cells, occupied enemy cells, and post-move cells.
- Hide range overlay during movement/attack resolving and after movement.
- Double-check board bounds before showing each pooled range cell.
- Apply a small visual inset check before showing range overlay cells to keep them out of the battlefield margin.
- Add has_selected_move_target state.
- Clear selected movement target during reset, ally selection, and successful movement.
- Show MoveHighlight only after the player clicks an in-bounds movement target cell.
- Do not show a red MoveHighlight for invalid, occupied, enemy-occupied, or out-of-range movement clicks.
- Keep invalid movement clicks as a one-click log/debug event instead of a visual selected target.
- Hide the selected MoveHighlight immediately when confirmed movement starts, before the movement tween begins.
- Hide MoveHighlight after successful movement.
- Keep MoveRangeOverlay faint and separate from the strong selected-target MoveHighlight.
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

## Priority 1 — v0.64k Melee/Range Feel QA

Goal:
Verify that calibrated unit visuals, grid_cell distance, and attack range feedback feel coherent.

Requirements:
- Compare visual closeness against printed grid distances.
- Keep attack range rules unchanged unless QA shows a concrete mismatch.
- Do not add unit footprint occupancy yet.

---

## Priority 2 — v0.64l Turn End / Wait Command

Goal:
Add a clear command to end the ally turn without attacking.

Requirements:
- Keep movement then attack available.
- Use the existing enemy reaction path after waiting.
- Avoid introducing AI movement.

---

## Priority 3 — v0.64m Basic Battle Loop QA

Goal:
Run a focused QA pass on the basic battle loop before any v0.65 milestone.

Requirements:
- Verify no repeated Godot Output error spam.
- Verify movement and attack demo flow.
- Verify same-turn re-move blocking.
- Verify no unintended scene layout changes.

---

## Priority 4 — v0.64n Unit Type / Hero Skill Range Rules

Goal:
Add attack range and unit type restrictions after the basic turn loop feels stable.

Requirements:
- Do not combine with damage formula changes.
- Keep movement validation separate from attack validation.

---

## Later — Attack Confirm Flow Cleanup

Goal:
Clarify the BasicAttackButton flow after an attack target has been selected.

Requirements:
- Keep attack target selection separate from attack confirmation.
- Avoid changing damage formulas in the same patch.

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
