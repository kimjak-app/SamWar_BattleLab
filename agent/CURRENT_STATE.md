# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.64i Combat Flow + Range Gate Stabilization

This baseline includes:
- v0.64i Move-Then-Attack Flow + Hit Bounce Polish
- v0.64i-hotfix Basic Attack Range Restore
- v0.64i-hotfix-2 Attack Target Fallback
- v0.64i-hotfix-3 Post-Move Attack Range Branch
- v0.64i-hotfix-4 Attack Range Debug + Enemy Range Gate

Do not bump to v0.65 yet.
v0.65 means Godot Battle Engine Port MVP Complete later.

---

## Project Direction
- Continue the current ChatCoach approach.
- Use `SamWar_web` `battle_rules.js` and the web battle logic as the source of truth.
- Translate the web battle logic into GDScript step by step.
- Treat the existing old SamWar Godot engine as reference only.
- Do not copy the old Godot engine wholesale.

---

## Completed Milestones
- v0.64a Movement Command MVP
- v0.64b Runtime Move Target Selection
- v0.64c MoveHighlight Cell Size Sync
- v0.64d Active Unit Selection
- v0.64d-hotfix Manual Ally ClickArea
- v0.64d-hotfix-2 Manual Hitbox Detection
- v0.64d-hotfix-3 _input-based Ally Selection
- v0.64e Occupied Cell Blocking
- v0.64e-hotfix Unified Click Input
- v0.64f Movement Range Overlay
- v0.64f-hotfix Movement Overlay Bounds + Hide After Move
- v0.64f-hotfix-2 Overlay UX Cleanup
- v0.64f-hotfix-3 Clean Move Target UX
- v0.64g Attack Target Selection
- v0.64i Move-Then-Attack Flow + Hit Bounce Polish
- v0.64i-hotfix Basic Attack Range Restore
- v0.64i-hotfix-2 Attack Target Fallback
- v0.64i-hotfix-3 Post-Move Attack Range Branch
- v0.64i-hotfix-4 Attack Range Debug + Enemy Range Gate
- v0.64j-pre Cell Size Visual Guide
- v0.64j Unit Visual Footprint Calibration
- v0.64k-pre Melee Adjacent QA Preset
- v0.64k Melee/Range Feel QA
- v0.64k-hotfix Combat Distance Debug
- v0.64k-hotfix Visual Anchor Consistency

---

## Current Working Features
- Yi Sun-sin can be selected.
- Movement target can be selected by clicking battlefield cells.
- Movement range overlay appears.
- Valid movement cells are shown cleanly.
- Occupied cells are blocked.
- MoveButton moves Yi Sun-sin.
- Movement updates `grid_cell` and `has_moved`.
- Guan Yu can be selected as attack target.
- BasicAttackButton runs attack demo when in range.
- Yi Sun-sin and Guan Yu have hit bounce reactions.
- Enemy range gate exists.
- Guan Yu does not damage Yi Sun-sin when out of enemy attack range.
- Ally turn returns after enemy reaction.
- Editor-visible cell size guides can show the ally logical cell plus right and down neighbor cells.
- Cell guide label shows current ally `grid_cell` and logical cell size.
- After moving Yi Sun-sin, the cell size guide follows the new ally logical cell.
- v0.64j-pre Cell Size Visual Guide is verified as the visual truth for calibration.
- v0.64j Unit Visual Footprint Calibration is verified against the logical cell guide.
- Unit tokens, shadows, HP bars, troop labels, and click areas are more tightly anchored to the same tactical footprint.
- v0.64k-pre Melee Adjacent QA Preset is verified in right, left, up, and down adjacent cells.
- v0.64k Melee/Range Feel QA is complete.
- Melee attack range remains 1.
- QA preset code remains available for future debugging, but QA mode is off by default.
- Combat distance debug output is added to confirm whether visually close vertical placements are logical `dist=1` or `dist>1`.
- Side-specific visual anchor offsets are added so ally and enemy visual groups align to logical cell footprint more consistently.

---

## Critical Godot Input Rule Learned
- `_unhandled_input()` alone is not reliable for unit or target selection because `Control` or UI nodes may consume mouse events.
- Unit selection and target selection should be handled early in `_input()`.
- Manual editor-visible `Area2D` and `CollisionShape2D` hitboxes are acceptable for MVP.
- Actual hitbox detection can be calculated manually in code for stability.

---

## Important Positioning Distinction
- `grid_cell` = tactical logical position
- `UnitToken` = troop formation visual
- `PortraitBadge` = informational hero label only
- `ClickArea` = selection convenience helper
- Move, attack, and occupied-cell logic must use `grid_cell`, not portrait position

---

## Known Current Issue
- Visual unit footprint and logical grid distance are not yet aligned.
- Units may look visually close while grid distance still reports 2 or 3.
- This causes melee and range feel mismatch.
- This is not a blocker for the current baseline, but it must be addressed next.
- The real logical cell size is now visible through the cell guide.
- Exact adjacent-cell visual feel has been checked without changing melee range.
- Do not increase melee range from 1.
- Visual anchor consistency is improved so ally and enemy guide coverage should read more similarly.

---

## Next Immediate Task
v0.64l Turn End / Wait Command

Goal:
- Add an explicit way to end ally turn after moving without attacking.
- Preserve the current select -> move -> attack or enemy reaction flow.

Note:
- Keep `v0.64l` as the next task after `v0.64k-hotfix Combat Distance Debug` is verified.

Constraints:
- No `_draw()`
- No `queue_redraw()`
- No `GridOverlay` drawing
