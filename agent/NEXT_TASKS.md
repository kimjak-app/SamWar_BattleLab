# NEXT TASKS

## Current Stable Baseline
v0.64i Combat Flow + Range Gate Stabilization

This baseline includes:
- v0.64i Move-Then-Attack Flow + Hit Bounce Polish
- v0.64i-hotfix Basic Attack Range Restore
- v0.64i-hotfix-2 Attack Target Fallback
- v0.64i-hotfix-3 Post-Move Attack Range Branch
- v0.64i-hotfix-4 Attack Range Debug + Enemy Range Gate

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

### 1. Facing UI Visual Polish
Goal:
- Improve the visual design of both the large selection arrows and the small facing indicators.

Timing:
- Keep the current functional overlay behavior intact.

### 2. Up/Down Troop Sprite Asset Integration
Goal:
- Connect future `up` and `down` troop token PNG assets into the prepared texture slots.

Timing:
- Do this after the assets are prepared.
- Keep left/right stable while integrating.

### 3. Fullscreen 18x10 Unit Visual Manual Calibration Finalize
Goal:
- In the Godot 2D editor, finalize manual calibration of unit body, HP bar, troop number, portrait, click area, and shadow against one fullscreen cell.
- After `Ctrl+S`, confirm the same layout remains during F6 runtime.
- Lock Yi Sun-sin and Guan Yu as the standard fullscreen infantry sample `UnitVisual` reference.

Rules:
- Keep `Battle_Fullscreen_Test.tscn` as the current working scene.
- Keep `Battle_WebImport_Test.tscn` as the stable verification scene.
- Fit the unit body to the `18 x 10` fullscreen grid.
- Allow flags, portraits, HP bars, and troop numbers to overflow the cell when needed.
- Preserve scene-authored layout capture behavior.
- Do not change battle logic while doing this calibration.

### 4. UnitVisual Template Planning
Goal:
- Plan the step after the current fullscreen sample calibration is finalized.
- Do not split into `UnitVisual.tscn` yet.
- Define how later infantry, archer, cavalry, and hero-style templates should expand from the same authored layout structure.

Direction:
- Do not hand-tune 10 units forever.
- Move toward a template-driven layout structure after the fullscreen sample standard is stable.
- Use the current manual fullscreen calibration as the later template reference.
- Keep scene-authored layout as the source of truth that runtime behavior follows.

### 5. Enemy basic decision AI
Goal:
- Port simple web or basic engine AI rules step by step.

Priority rules:
- attack if in range
- prefer weak target when multiple targets exist
- prefer back attack if possible
- prefer unique skill if available
- otherwise approach or wait

### 7. Multi-unit deployment planning
Goal:
- Plan how fullscreen `18 x 10` should scale from the current single ally / single enemy sample into multi-unit deployment.

Direction:
- Keep the current verified fullscreen sample as the tactical and visual reference.
- Avoid hand-placing every future unit without a repeatable structure.

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
