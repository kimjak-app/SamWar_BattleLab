# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.64l Turn End / Wait Command

This baseline includes:
- v0.64i Move-Then-Attack Flow + Hit Bounce Polish
- v0.64i-hotfix Basic Attack Range Restore
- v0.64i-hotfix-2 Attack Target Fallback
- v0.64i-hotfix-3 Post-Move Attack Range Branch
- v0.64i-hotfix-4 Attack Range Debug + Enemy Range Gate
- v0.64k-fullscreen-grid-18x10
- v0.64k-fullscreen-scene-authored-unit-layout
- v0.64k-fullscreen-move-flow-reconnect verified
- v0.64k-fullscreen-left-right-facing verified
- v0.64k-fullscreen-left-right-facing-hotfix verified
- v0.64l Turn End / Wait Command added
- v0.64m 4-Direction Facing Data Structure added
- v0.64n Post-Move Facing Selection UI added
- v0.64n-hotfix Direction Arrow Selection + Facing Lock added
- v0.64n-hotfix Facing Arrow Panel Visibility added
- v0.64n-hotfix Facing Arrow Panel Position Polish added
- v0.64n-hotfix Facing Arrow Snap To Grid Cells added
- v0.64n-hotfix Direction Facing Indicator Overlay added
- v0.64n-hotfix Facing Indicator Cleanup added
- v0.64n-hotfix Facing Arrow Visual Polish added
- v0.64n-hotfix Facing Arrow Visual Polish 2 added

Do not bump to v0.65 yet.
v0.65 means Godot Battle Engine Port MVP Complete later.

---

## Project Direction
- Continue the current ChatCoach approach.
- Use `SamWar_web` `battle_rules.js` and the web battle logic as the source of truth.
- Translate the web battle logic into GDScript step by step.
- Treat the existing old SamWar Godot engine as reference only.
- Do not copy the old Godot engine wholesale.
- Find the structure that makes it easiest for Kimjak to work first.
- Prefer scene-authored layout over code-side visual correction whenever possible.

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
- v0.64k-hotfix Logical 14x8 Grid Guide
- v0.64k-hotfix Bake Logical Grid Guide Points Into Scene
- v0.64k-fullscreen-pre Fullscreen Battle Board Layout Prototype
- v0.64k-fullscreen-grid-18x10
- v0.64k-fullscreen-scene-authored-unit-layout

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
- Full logical 14x8 guide lines can show the actual movement and attack cells across the whole board.
- Full logical 14x8 guide points are baked into the scene so the same grid is visible in the Godot 2D editor before runtime.
- `Battle_WebImport_Test.tscn` remains the stable small-board verification scene.
- `Battle_WebImport_Test.tscn` remains preserved as the smaller battle-board functional verification scene.
- `Battle_Fullscreen_Test.tscn` is the current main working scene and fullscreen battle verification scene.
- `v0.64k-fullscreen-pre` fullscreen layout prototype is completed.
- `Battle_Fullscreen_Test.tscn` now uses a full 18x10 logical grid across the whole 1920x1080 board.
- Actual fullscreen cell size is approximately `Vector2(106.6667, 108.0)`.
- The 18x10 fullscreen grid is intended for future 7v7 to 10v10 battle scale.
- The fullscreen logical grid remains editor-visible before runtime and the UI remains a CanvasLayer overlay.
- `v0.64k-fullscreen-scene-authored-unit-layout` captures scene-authored unit layout offsets at runtime start.
- Manual layout changes saved in the Godot 2D editor persist during F6 runtime on `Battle_Fullscreen_Test.tscn`.
- `scene-authored layout` is verified on the fullscreen scene.
- Unit placement, HP bar, portrait badge, troop label, shadow, and click area edited in the Godot 2D editor remain aligned during runtime.
- `v0.64k-fullscreen-move-flow-reconnect` is verified on the fullscreen `18 x 10` board.
- Move target selection keeps an explicit logical `selected_move_cell` instead of depending only on the marker transform.
- Fullscreen `BattleUI` clicks are no longer misread as battlefield move-target clicks.
- Ally move, attack, and enemy counterattack flow are verified on `Battle_Fullscreen_Test.tscn`.
- After ally movement, token, shadow, portrait badge, HP bar, troop label, and click area follow the same scene-authored anchor offsets.
- `v0.64k-fullscreen-left-right-facing` is verified.
- Left/right troop facing is verified so Yi Sun-sin and Guan Yu face each other correctly on the fullscreen board.
- Hero `PortraitBadge` never flips.
- Hero `PortraitBadge` position stays on the front side of the troop based on current facing.
- HP bar, troop label, click area, and shadow remain scene-authored and are not mirrored.
- Up/down facing sprites and direction arrows are still not implemented.
- Godot Output audio device warnings were observed, but they are not treated as battle-logic failures.
- `Battle_Fullscreen_Test.tscn` now includes clickable `WaitButton` and `EndTurnButton` in the command bar.
- Wait or turn-end command now ends the ally turn, reuses the existing enemy turn demo flow, and then returns to the ally turn.
- Movement, attack, enemy counterattack, facing, and scene-authored layout behavior remain preserved with the wait command added.
- Facing data now accepts `left`, `right`, `up`, and `down`.
- Existing left/right facing remains the verified visual behavior.
- Up/down troop sprite assets are still not available.
- Up/down facing currently uses a safe visual fallback path without changing the stable left/right presentation.
- Direction arrows are still not implemented.
- After movement, `FacingSelectionPanel` now appears and allows `left/right/up/down` facing choice.
- Selected facing is stored in `ally_unit_state.facing`.
- Left/right choice immediately updates troop facing visuals.
- Up/down choice currently stores data and keeps the existing visual fallback path.
- Post-move facing selection now uses 4-direction arrow buttons near the ally unit.
- Selected ally facing is now locked until the next movement instead of being overwritten by automatic facing refresh.
- Enemy facing still auto-tracks the ally as before.
- Up/down choice currently stores data and keeps the existing visual fallback path.
- Dedicated up/down troop sprites are still not implemented.
- Always-on direction indicator overlay is still not implemented.
- Post-move facing selection phase entry is verified, and the arrow panel visibility path is now stabilized.
- `FacingArrowPanel` is now positioned near the ally unit instead of the temporary fixed lower-center placement.
- Facing arrow panel and arrow buttons now use a lighter transparent presentation so they block less of the battlefield.
- Facing arrow buttons now snap directly onto the ally unit's adjacent logical grid cells.
- Each arrow button now uses the neighboring cell center and nearly one-cell size for clearer tactical selection.
- Facing arrow visibility is strengthened again so the buttons are easier to read during selection.
- Current `unit_state.facing` is now also shown with a small always-visible arrow indicator above ally and enemy units.
- Large arrows are used for post-move facing selection, while small arrows are used for current facing display.
- Up/down troop sprites are still missing, but `↑` and `↓` indicators now make the selected facing readable.
- Small facing indicators are now positioned closer to the troop body and flag area instead of the portrait/head area.
- Small facing indicators now hide during movement and during the post-move facing selection step, then reappear after the new facing is confirmed.
- Legacy `CellGuide` debug right/down tiles and the `ally=... enemy=... dist=...` runtime label are now disabled by default.
- Large facing selection arrows now use a web-style yellow translucent cell box with clearer yellow arrow text.
- Large facing selection arrows are now softened again toward a more muted ivory and gold guide look with lower border and fill intensity.
- Small facing indicators remain unchanged during this visual polish step.
- Existing facing selection, facing lock, movement, attack, counterattack, and wait flow remain preserved.
- This is the staging step before later `UnitVisual.tscn` template separation.

---

## Fullscreen Direction
- Keep `Battle_WebImport_Test.tscn` as the stable functional verification scene.
- Use `Battle_Fullscreen_Test.tscn` as the new fullscreen battle layout scene.
- The project is now moving toward a `1920 x 1080` fullscreen battle board.
- The fullscreen grid is now planned around `18 x 10`.
- This `18 x 10` grid is the current candidate base spec for future `7v7` to `10v10` battle scale.
- One fullscreen logical cell is approximately `106.6667 x 108.0`.
- Stop further tuning work that is based on the old small rectangular battle board.
- From now on, fit unit body footprint and attached info UI against the fullscreen `18 x 10` grid.
- Fullscreen `18 x 10` movement, attack, enemy reaction, and left/right facing are now the current stable verification target.

---

## Workflow Lesson Learned Today
- Find the structure that makes Kimjak's work easier first.
- Before forcing visual fixes with code offsets, first check whether the problem can be solved directly in the Godot 2D editor.
- Apply `Scene controls layout / Code controls behavior` more strictly.
- Unit visual placement, HP bars, troop numbers, portraits, and click areas should stay scene-authored when possible.
- Runtime code should capture that authored layout and make movement or attack animation follow it.
- If Kimjak adjusts the layout in the 2D editor and presses `Ctrl+S`, F6 runtime should preserve that layout.
- Prefer a structure that is easy and intuitive for the worker to edit over chasing a "correct" hardcoded offset solution.
- If Kimjak is stuck, inspect whether there is an easier structural solution before writing a new Codex instruction chain.

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
- The remaining calibration target is the fullscreen `18 x 10` scene.
- Runtime layout should follow scene-authored unit placement instead of snapping HP bars, portraits, labels, shadows, and click areas back to hardcoded offsets.
- `v0.65` is still not reached.

---

## Next Immediate Task
Fullscreen 18x10 Unit Visual Manual Calibration Finalize

Goal:
- Verify ally and enemy body footprint on `Battle_Fullscreen_Test.tscn`.
- Manually fit troop body, shadow center, and click area to the fullscreen 18x10 logical grid.
- Fit the unit body to the grid rather than moving the grid.
- Treat the troop body center and shadow center as the tactical footprint anchor.
- Flags, portraits, HP bars, and troop labels may overflow outside one logical cell.
- Confirm that scene-authored layout from the 2D editor stays consistent during F6 runtime.

Note:
- After visual anchor verification, proceed to `v0.64l Turn End / Wait Command`.

Constraints:
- No `_draw()`
- No `queue_redraw()`
- No `GridOverlay` drawing
