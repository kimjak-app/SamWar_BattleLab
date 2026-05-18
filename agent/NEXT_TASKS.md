# NEXT TASKS

## Current Stable Baseline
v0.64o Fullscreen 18x10 Directional Battle Loop Stable

This baseline includes:
- fullscreen `18 x 10`
- scene-authored layout preservation
- movement / occupied cell blocking / simple grid path move
- attack / counterattack
- wait / end turn
- 4-direction post-move facing selection
- facing lock / facing indicator
- high-resolution fullscreen battlefield background

Warning:
- v0.65 is not reached.
- Do not claim Godot Battle Engine Port MVP Complete.
- Do not use `GridOverlay`, `_draw()`, or `queue_redraw()` until explicitly approved.

---

## Task Sequence

### Completed Just Before This List
- `v0.64k-fullscreen-move-flow-reconnect`
- Fullscreen `18 x 10` move flow on `Battle_Fullscreen_Test.tscn` is verified without changing move range, attack range, distance formula, or enemy counterattack logic.
- Move target selection now preserves a logical `selected_move_cell`.
- `MoveButton` clicks on the fullscreen UI are no longer consumed as battlefield clicks.
- After movement, token, shadow, portrait badge, HP bar, troop label, and click area keep following the same scene-authored layout offsets.
- `v0.64k-fullscreen-left-right-facing`
- Fullscreen `18 x 10` battle now verified auto-updates left/right facing for troop `UnitToken` only.
- Hero `PortraitBadge` stays fixed and never flips.
- Direction arrows and up/down facing sprites are still not implemented.
- `v0.64k-fullscreen-left-right-facing-hotfix`
- Ally troop `flip_h` mapping is corrected for the actual fullscreen battle view.
- Hero `PortraitBadge` still never flips, but now moves to the front side of the troop based on facing.
- HP bar, troop label, shadow, and click area remain scene-authored and are not mirrored.
- `v0.64l Turn End / Wait Command`
- `Battle_Fullscreen_Test.tscn` now has clickable `WaitButton` and `EndTurnButton`.
- Wait or turn-end command now ends the ally turn, reuses the existing enemy turn demo flow, and returns control to the ally turn.
- Existing movement, attack, counterattack, facing, and scene-authored layout behavior remain preserved.
- `v0.64m 4-Direction Facing Data Structure`
- Facing values are now prepared for `left`, `right`, `up`, and `down`.
- Existing left/right troop facing remains the current stable visual behavior.
- Up/down sprite asset integration is still pending and currently uses a fallback path.
- `v0.64n Post-Move Facing Selection UI`
- Moving now enters a facing selection step before attack/wait/end-turn.
- `left/right/up/down` can now be stored into `unit_state.facing`.
- Left/right immediately affect troop visuals; up/down currently stay on visual fallback.
- `v0.64n-hotfix Direction Arrow Selection + Facing Lock`
- Post-move facing selection now uses 4-direction arrow buttons near the ally unit instead of relying on bottom text buttons.
- Selected ally facing now stays locked until the next movement.
- `v0.64n-hotfix Facing Arrow Panel Visibility`
- Facing arrow selection phase entry already worked, and the immediate hotfix now stabilizes the panel at a fixed lower-center screen position.
- Ally-near positioning is deferred to a later polish task.
- `v0.64n-hotfix Facing Arrow Panel Position Polish`
- Facing arrow panel is now placed near the ally unit instead of the temporary fixed lower-center position.
- Panel and arrow button transparency are increased so the battlefield is less obscured.
- `v0.64n-hotfix Facing Arrow Snap To Grid Cells`
- Facing arrow buttons now snap to the ally unit's adjacent logical cells instead of using loose panel-relative placement.
- Arrow visibility is strengthened again for clearer tactical selection.
- `v0.64n-hotfix Direction Facing Indicator Overlay`
- Current facing is now shown by a small always-visible arrow indicator above units.
- Large arrows remain the selection UI, while the small indicator shows the active saved facing.

### 1. Enemy Basic Move + Attack AI
Goal:
- Let the enemy evaluate the ally during enemy turn and attack if already in range.
- If out of range, let the enemy move closer within `move_range` while preserving occupied-cell blocking.
- If attack becomes possible after movement, attack.
- If attack is still not possible after movement, wait and return to the ally turn.
- Enemy movement should reuse the current simple BFS waypoint movement and move the full visual group together.
- Enemy facing should update only during its own action timing.

Rules:
- Do not change `attack_range`, `move_range`, or the distance formula.
- Reuse the current occupied-cell blocking and path move structure.
- Enemy still occupies exactly one logical cell.
- Do not implement rear/side bonuses or breakthrough behavior yet.

### 2. Enemy Move Range / Target Cell Selection Logic
Goal:
- Choose a valid enemy destination cell that gets closer to the ally.
- Start with a simple heuristic over BFS-reachable cells.
- Keep occupied-cell blocking and non-diagonal movement.

### 3. Rear/Side Attack Concept Planning
Goal:
- Design how defender facing should classify future rear, side, and front attack states without changing damage rules yet.

Rules:
- Treat defender facing as persistent state.
- Build on the current rear-access and facing-hold foundation.
- Do not implement damage bonuses or final combat rules yet.

### 4. Up/Down Troop Sprite Asset Integration
Goal:
- Connect future `up` and `down` troop token PNG assets into the prepared texture slots.

Timing:
- Do this after the assets are prepared.
- Keep left/right stable while integrating.

### 5. UnitVisual Template Planning
Goal:
- Plan the step after the current fullscreen sample calibration is finalized.
- Do not split into `UnitVisual.tscn` yet.
- Define how later infantry, archer, cavalry, and hero-style templates should expand from the same authored layout structure.

Direction:
- Do not hand-tune 10 units forever.
- Move toward a template-driven layout structure after the fullscreen sample standard is stable.
- Use the current manual fullscreen calibration as the later template reference.
- Keep scene-authored layout as the source of truth that runtime behavior follows.

### 6. Multi-unit deployment planning
Goal:
- Plan how fullscreen `18 x 10` should scale from the current single ally / single enemy sample into multi-unit deployment.

Direction:
- Keep the current verified fullscreen sample as the tactical and visual reference.
- Avoid hand-placing every future unit without a repeatable structure.

### 7. Terrain choke point / narrow path test
Goal:
- QA the new blocked-cell path movement behavior on tighter routes and future narrow-lane layouts.

### 8. Breakthrough Skill Concept
Goal:
- Design the future exception path where a special skill can pass through occupied cells or use split-and-rejoin movement presentation.

Rules:
- Do not implement the skill behavior yet.
- Keep current base movement blocked by occupied cells until that system is explicitly added.

### 9. Facing UI additional polish later if needed
Goal:
- Further refine the large facing selection arrows only if readability or style still needs another pass after QA.
- Current `v0.64n-hotfix Facing Arrow Visual Polish 2` is color-only tuning with no behavior change.

### 7. v0.64n Hero Skill Sample Trigger
Goal:
- Prepare 10 hero image and unique skill image sample structure.

### 8. v0.64o Basic Battle Loop QA
Goal:
- Run a full loop test:
- ally select -> move -> attack or wait -> enemy reaction -> ally turn return

---

## Workflow Lesson
- Find the structure that makes Kimjak's work easier first.
- Before hardcoding new visual offsets, first inspect whether the Godot 2D editor can solve the layout problem directly.
- Prefer `Scene controls layout / Code controls behavior`.
- Prefer scene-authored layout for unit visual placement, HP bars, troop numbers, portraits, and click areas.
- If code must move visuals during gameplay, capture and reuse the editor-authored offsets.
- If Kimjak is stuck, inspect whether there is a simpler structural solution before drafting a bigger Codex instruction chain.

---

## Guardrails
- Continue the ChatCoach approach.
- Use `SamWar_web` `battle_rules.js` and web battle logic as the source of truth.
- Translate web battle logic into GDScript step by step.
- Old SamWar Godot engine is reference only.
- Do not copy the old Godot engine wholesale.

Do not implement yet:
- v0.65
- full battle engine complete claim
- pathfinding
- terrain cost
- full enemy AI
- full hero skill system
- new damage formula
- unit footprint occupancy system
- `GridOverlay` drawing
- `_draw()`
- `queue_redraw()`
