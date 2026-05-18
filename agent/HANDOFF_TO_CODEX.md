# HANDOFF TO CODEX

Before making changes, read:
1. `agent/GODOT_RULES.md`
2. `agent/CURRENT_STATE.md`
3. `agent/NEXT_TASKS.md`

---

## Session Start Point
- Next session starts from `v0.64o Fullscreen 18x10 Directional Battle Loop Stable`.
- Do not treat `v0.65` as reached.
- Next active scene is `Battle_Fullscreen_Test.tscn`.
- Keep `Battle_WebImport_Test.tscn` as the stable verification scene.
- Continue from the fullscreen `18 x 10` grid direction.

---

## First Task
- First task is `Enemy Basic Move + Attack AI`.
- Start from `Battle_Fullscreen_Test.tscn`.
- Reuse the current occupied-cell blocking and simple BFS waypoint move structure.
- If the session goal changes later, the deferred visual branch is `Fullscreen 18x10 Unit Visual Manual Calibration Finalize`.

---

## Preserve Current Working Combat Loop
- Preserve ally unit selection.
- Preserve battlefield cell click movement target selection.
- Preserve movement range overlay.
- Preserve occupied-cell blocking.
- Preserve the current one-unit-one-cell occupancy rule.
- Preserve MoveButton movement flow.
- Preserve `grid_cell` and `has_moved` updates.
- Preserve attack target selection on Guan Yu.
- Preserve in-range `BasicAttackButton` demo flow.
- Preserve hit bounce reactions.
- Preserve enemy attack range gate.
- Preserve ally turn return after enemy reaction.
- Preserve fullscreen left/right troop facing.
- Preserve facing-aware `PortraitBadge` front-side placement without flipping the portrait itself.
- Preserve the current 4-direction facing data structure while keeping left/right as the only verified visual state for now.
- Preserve the post-move facing selection UI step after movement.
- Preserve the arrow-based post-move facing selection UX near the ally unit.
- Preserve the current high-resolution fullscreen battlefield background setup on `Battle_Fullscreen_Test.tscn`.

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
- Do not overwrite scene-authored layout if the same result can be preserved by capturing and reusing editor-authored offsets.
- `Troop UnitToken` may flip for facing.
- `Hero PortraitBadge` must not flip; only its position may become facing-aware.
- HP bar, troop label, shadow, and click area should remain scene-authored unless there is a very strong reason otherwise.
- `up/down` facing values may exist in data before matching sprite assets exist.
- If `up/down` assets are missing, keep a safe visual fallback instead of breaking the current left/right presentation.
- Direction selection after movement should not auto-skip to enemy turn before the player chooses facing.
- Manual ally facing chosen after movement should remain locked until the next movement.
- One unit occupies exactly one logical grid cell.
- Occupied cells block normal movement and cannot be passed through or entered by base movement.
- Facing is state, not always auto-look.
- Automatic facing should not erase manual facing.
- Enemy should not instantly face the ally outside its own action timing.
- Breakthrough or pass-through movement remains a future skill-only exception.

---

## Current Verified Fullscreen State
- `Battle_Fullscreen_Test.tscn` is the current primary working and verification scene.
- `1920 x 1080` fullscreen battle board is working.
- `18 x 10` logical grid is working.
- A sharper high-resolution battlefield background is now applied on the fullscreen scene.
- `scene-authored layout` is preserved from Godot 2D editor into F6 runtime.
- Yi Sun-sin selection, movement, attack, and Guan Yu counterattack are verified.
- Movement keeps HP bar, troop label, portrait badge, shadow, and click area visually synced.
- Left/right troop facing is verified.
- `Hero PortraitBadge` is verified as unflipped and facing-aware by position only.
- Facing data structure is now prepared for `left/right/up/down`, but up/down sprites and direction arrows are still not implemented.
- Post-move facing selection UI is now part of the ally move flow.
- Post-move facing selection now uses arrows near the ally unit, and the chosen ally facing persists until the next move.
- Occupied cell blocking and simple grid waypoint movement are now part of the stable fullscreen loop.
- Enemy facing now holds until enemy action timing instead of instantly reacting to ally repositioning.

---

## Source of Truth
- Follow the current ChatCoach approach.
- Use `SamWar_web` `battle_rules.js` and the web battle logic as the source of truth.
- Translate web logic into GDScript step by step.
- Existing old SamWar Godot engine is reference only.
