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
- The next step is not range tweaking first.
- The next step is showing the real logical cell size.

---

## Next Immediate Task
v0.64j-pre Cell Size Visual Guide

Goal:
- Show the real `BattleGridController` logical cell size.
- Show current and neighbor cell positions using safe editor-visible guide nodes.
- Do this before unit visual footprint calibration.

Constraints:
- No `_draw()`
- No `queue_redraw()`
- No `GridOverlay` drawing
