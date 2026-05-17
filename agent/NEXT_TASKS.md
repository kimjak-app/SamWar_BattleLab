# NEXT TASKS

## Current Stable Baseline
v0.64a Movement Command MVP

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

---

## Priority 1 — v0.64b Movement Range Visual Overlay

Goal:
Show the active unit's movement range visually.

Requirements:
- Keep overlay lightweight.
- Prefer existing scene-friendly nodes if available.
- Do not create major battlefield layout nodes at runtime.
- Overlay must not replace MoveTargetMarker validation.
- Overlay should be optional/debug-friendly.

---

## Priority 2 — v0.64c Move Command UX Cleanup

Goal:
Make the movement command flow easier to read and test.

Requirements:
- Clarify selected unit and selected target state.
- Keep the existing MoveButton confirmation behavior.
- Keep valid/invalid feedback visible and lightweight.
- Do not add advanced pathfinding yet.
- Do not redesign Battle_WebImport_Test.tscn.

---

## Priority 3 — v0.64d Unit Move Animation Polish

Goal:
Polish the current simple movement Tween without adding pathfinding.

Requirements:
- Use BattleGridController.grid_to_world().
- Preserve unit visual group hierarchy.
- Preserve facing behavior.
- Keep animation simple and stable.
- Do not disturb existing attack/defense demo.

---

## Priority 4 — v0.65a Occupied Cell / Collision Rules

Goal:
Prevent movement into occupied cells.

Requirements:
- Track unit occupancy by grid_cell.
- Friendly occupied cells block movement.
- Enemy occupied cells block movement for move command.
- Do not implement attack-on-enter yet.

---

## Priority 5 — v0.65b Basic Attack Range Validation

Goal:
Validate attackable enemy targets based on active unit attack_range.

Requirements:
- Use BattleGridController.get_distance().
- Use BattleUnitState.attack_range.
- Enemy target must be alive.
- Do not combine attack validation with movement validation too early.

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
