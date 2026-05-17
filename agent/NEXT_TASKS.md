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

### 1. Fullscreen 18x10 Unit Visual Manual Calibration Finalize
Goal:
- In the Godot 2D editor, manually calibrate unit body, HP bar, troop number, portrait, and click area against one fullscreen cell.
- After `Ctrl+S`, confirm the same layout remains during F6 runtime.
- Lock Yi Sun-sin as the standard fullscreen sample `UnitVisual` reference.
- Fit Guan Yu to the same standard.

Rules:
- Keep `Battle_Fullscreen_Test.tscn` as the current working scene.
- Keep `Battle_WebImport_Test.tscn` as the stable verification scene.
- Fit the unit body to the `18 x 10` fullscreen grid.
- Allow flags, portraits, HP bars, and troop numbers to overflow the cell when needed.
- Do not change battle logic while doing this calibration.

### 2. UnitVisual Template Planning
Goal:
- Plan the step after manual fullscreen sample calibration.
- Do not split into `UnitVisual.tscn` yet.
- Define how later infantry, archer, cavalry, and hero-style templates should expand from the same authored layout structure.

Direction:
- Do not hand-tune 10 units forever.
- Move toward a template-driven layout structure after the fullscreen sample standard is stable.
- Keep scene-authored layout as the source of truth that runtime behavior follows.

### 3. v0.64l Turn End / Wait Command
Goal:
- Add an explicit way to end ally turn after moving without attacking.

Timing:
- Do this after the fullscreen visual layout standard is settled.

### 4. v0.64m Enemy Basic Decision Rules
Goal:
- Port simple web or basic engine AI rules step by step.

Priority rules:
- attack if in range
- prefer weak target when multiple targets exist
- prefer back attack if possible
- prefer unique skill if available
- otherwise approach or wait

### 5. v0.64n Hero Skill Sample Trigger
Goal:
- Prepare 10 hero image and unique skill image sample structure.

### 6. v0.64o Basic Battle Loop QA
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
