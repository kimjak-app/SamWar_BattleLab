# HANDOFF TO CODEX

Before making changes, read:
1. `agent/GODOT_RULES.md`
2. `agent/CURRENT_STATE.md`
3. `agent/NEXT_TASKS.md`

---

## Session Start Point
- Next session starts from `v0.64i Combat Flow + Range Gate Stabilization`.
- Do not treat `v0.65` as reached.
- Next active scene is `Battle_Fullscreen_Test.tscn`.
- Keep `Battle_WebImport_Test.tscn` as the stable verification scene.
- Continue from the fullscreen `18 x 10` grid direction.

---

## First Task
- First task is `Fullscreen 18x10 Unit Visual Manual Calibration Finalize`.
- Start from the layout visible in the Godot 2D editor on `Battle_Fullscreen_Test.tscn`.
- Before changing behavior code, confirm the 2D editor layout and F6 runtime layout still match.

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
- Do not change `attack_range`, `move_range`, or the distance formula.
- Do not rewrite combat flow.
- Do not tweak battle rules while the fullscreen visual layout standard is still being finalized.
- Do not copy the old Godot engine wholesale.

---

## Important Rule Learned
- `_unhandled_input()` alone is not reliable for unit or target selection because UI may consume mouse events.
- Handle unit and target selection early in `_input()`.
- Manual editor-visible hitboxes are acceptable for MVP.
- Manual code-side hitbox checks are acceptable for stability.
- Find the structure that makes Kimjak's work easier first.
- Before computing more code offsets, check whether scene-authored layout solves the problem more directly.
- `Scene controls layout / Code controls behavior` should be applied more strictly.
- If Kimjak adjusts layout in the 2D editor and presses `Ctrl+S`, runtime should preserve that layout.
- Prefer editor-authored offsets over hardcoded visual correction whenever possible.

---

## Source of Truth
- Follow the current ChatCoach approach.
- Use `SamWar_web` `battle_rules.js` and the web battle logic as the source of truth.
- Translate web logic into GDScript step by step.
- Existing old SamWar Godot engine is reference only.
