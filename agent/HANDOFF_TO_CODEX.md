# HANDOFF TO CODEX

Before making changes, read:
1. `agent/GODOT_RULES.md`
2. `agent/CURRENT_STATE.md`
3. `agent/NEXT_TASKS.md`

---

## Session Start Point
- Next session starts from `v0.64i Combat Flow + Range Gate Stabilization`.
- Do not treat `v0.65` as reached.

---

## First Task
- First task is `v0.64j-pre Cell Size Visual Guide`.
- Show the real `BattleGridController` logical cell size first.
- Use safe editor-visible guide nodes.
- Do not use `GridOverlay`, `_draw()`, or `queue_redraw()`.

---

## Preserve Current Working Combat Loop
- Preserve ally unit selection.
- Preserve battlefield cell click movement target selection.
- Preserve movement range overlay.
- Preserve occupied-cell blocking.
- Preserve MoveButton movement flow.
- Preserve `grid_cell` and `has_moved` updates.
- Preserve attack target selection on Guan Yu.
- Preserve in-range `BasicAttackButton` demo flow.
- Preserve hit bounce reactions.
- Preserve enemy attack range gate.
- Preserve ally turn return after enemy reaction.

---

## Do Not Touch Yet
- Do not adjust attack or range rules before cell guide work and footprint calibration.
- Do not tweak melee or range feel before `v0.64j-pre` and `v0.64j`.
- Do not copy the old Godot engine wholesale.

---

## Important Rule Learned
- `_unhandled_input()` alone is not reliable for unit or target selection because UI may consume mouse events.
- Handle unit and target selection early in `_input()`.
- Manual editor-visible hitboxes are acceptable for MVP.
- Manual code-side hitbox checks are acceptable for stability.

---

## Source of Truth
- Follow the current ChatCoach approach.
- Use `SamWar_web` `battle_rules.js` and the web battle logic as the source of truth.
- Translate web logic into GDScript step by step.
- Existing old SamWar Godot engine is reference only.
