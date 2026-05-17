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

### 1. v0.64j-pre Cell Size Visual Guide
Goal:
- Show the actual logical cell size from `BattleGridController`.
- Add safe editor-visible guide nodes.
- Make current cell and neighbor cell positions visible for calibration work.

Rules:
- No `_draw()`
- No `queue_redraw()`
- No `GridOverlay` drawing

Why first:
- Visual footprint calibration must be based on the real logical grid, not guesswork.

Status:
- Verified.
- Guide follows ally logical cell only.
- No combat rule changes.

### 2. v0.64j Unit Visual Footprint Calibration
Goal:
- Align troop formation visual size to logical cells.

Focus:
- `UnitToken`
- shadow
- HP bar
- troop label
- `ClickArea`

Reminder:
- `PortraitBadge` is only a label and does not define footprint.

Status:
- Verified.
- `v0.64j-pre` cell guide is verified and remains the visual truth.
- Sample ally and enemy token, shadow, HP bar, troop label, and click area were tightened without combat logic changes.

### 3. v0.64k Melee/Range Feel QA
Goal:
- Re-evaluate attack range feel only after visual footprint calibration.

Rules:
- Do not randomly increase range before visual calibration.
- Compare visible spacing against logical `grid_cell` distance.

Current QA support:
- `v0.64k-pre Melee Adjacent QA Preset` added.
- QA preset places Guan Yu at an exact adjacent logical cell from Yi Sun-sin.
- Purpose: compare visual feel of true adjacent melee distance before changing melee or range rules.

Status:
- Complete.
- `v0.64k-pre` adjacent QA preset was verified in right, left, up, and down directions.
- Basic attack works.
- Enemy counterattack works.
- Melee range remains 1.
- Do not increase range.

Hotfix:
- `v0.64k-hotfix Combat Distance Debug` added.
- Purpose: confirm whether visually below-adjacent placement is truly `dist=1` or actually `dist>1`.
- Cell guide label can now show ally grid, enemy grid, and current distance for quick inspection.

Hotfix:
- `v0.64k-hotfix Visual Anchor Consistency` added.
- Purpose: align ally and enemy visual group anchors to their logical cell footprint in similar proportions.
- Melee range remains 1.
- Combat logic is unchanged.

### 4. v0.64l Turn End / Wait Command
Goal:
- Add an explicit way to end ally turn after moving without attacking.

### 5. v0.64m Enemy Basic Decision Rules
Goal:
- Port simple web or basic engine AI rules step by step.

Priority rules:
- attack if in range
- prefer weak target when multiple targets exist
- prefer back attack if possible
- prefer unique skill if available
- otherwise approach or wait

### 6. v0.64n Hero Skill Sample Trigger
Goal:
- Prepare 10 hero image and unique skill image sample structure.

### 7. v0.64o Basic Battle Loop QA
Goal:
- Run a full loop test:
- ally select -> move -> attack or wait -> enemy reaction -> ally turn return

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
