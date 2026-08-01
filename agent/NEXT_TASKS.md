# NEXT TASKS

## Completed QA locks

- T06-10H occupation portrait QA: PASS.
- T06-10I unique-skill Korean display QA: PASS.
- T06-11A enemy multi-actor turn orchestration QA: PASS.
- T06-11B engagement reservation and surround-pressure QA: PASS.
- T07 five-unit-type automated validation: PASS.
- T07 dedicated gunner and mounted-archer visual metadata: PASS.

## Current status

- T07: `IMPLEMENTED / AUTOMATED VALIDATION PASS / DEDICATED VISUALS BOUND / USER F5 QA PENDING`.
- T08-1: `AUDIT COMPLETE / PRODUCTION IA LOCKED`.
- T08-2-hotfix1: `IMPLEMENTED / AUTOMATED STATIC VALIDATION PASS / USER F6 RETEST PENDING`.

Do not begin T08-3 graphics, final theme binding, or Hanseong battlefield integration until T08-2-hotfix1 passes user F6 QA.

## Confirmed T08-2 defects

- `Battle_Land.tscn` contains a standalone `+` line immediately before `ProductionHudRoot`.
- Godot produced 148 cascading `Parent path ... has vanished` messages for the production HUD tree.
- `scripts/battle_web_import_test.gd` uses local variable `visible`, shadowing `CanvasItem.visible`.
- The focused validator did not detect malformed scene syntax or validate real parent declaration order.
- Production and legacy HUD surfaces are simultaneously visible.
- Top HUD elements overlap.
- Large empty production panels obscure the battlefield.
- Default placeholder and T09-reserved text is visible when it should be hidden.

## Immediate next implementation

### T08-2-hotfix1 Production HUD Scene Recovery, Layout & Legacy Visibility Correction

Execution source:

- `agent/HANDOFF_TO_CODEX.md`

Required phase order:

### Phase A — Scene integrity

- Remove malformed standalone scene content.
- Confirm every production node parent exists and is declared before the child.
- Remove all `vanished` parent cascades.
- Rename the local `visible` variable to a non-shadowing name.
- Add validator checks for standalone malformed lines, parent existence/order, and shadowing patterns.

### Phase B — Functional 1920×1080 layout

- Keep the top HUD compact and centered.
- Keep ally and enemy rosters on the left and right edge safe zones.
- Keep actor comparison at the bottom in the minimum necessary area.
- Hide large empty actor/target panels when no meaningful data exists.
- Hide Tooltip/Facing/T09 placeholder surfaces by default.
- Prevent production and legacy top/roster/log surfaces from being visible together.
- Preserve battlefield-local HP, troop, portrait, facing, range, targeting, and unit visuals.

### Phase C — Validation and QA handoff

Run:

- `python tools/validate_t08_2_production_hud.py`
- `python tools/validate_t06_t07_playable_transaction.py`
- `python tools/validate_five_unit_type_full_completion.py`
- `python tools/validate_five_unit_type_damage_auto_battle_and_skill_parity.py`
- `git diff --check`
- local Godot scene/project load when executable is available.

Completion requires:

- zero new Godot scene-instantiation errors;
- zero `visible` shadowing warning;
- no production/legacy duplication;
- readable `3 / 10`, `1 / 30`, `3 / 10` top HUD;
- no critical battlefield obstruction at 1920×1080;
- user F6 QA result recorded.

## Protected contracts

- T01–T07 gameplay behavior and validators.
- Momentum start `3`, maximum `10`.
- Battle maximum turn `30`.
- WorldMap battle context, supply, cutins, results, AI, save/resume, and return flow.
- No terrain, cooperative attack, common tactic, or balance changes.
- No file/node deletion.
- No final UI PNG or Hanseong battlefield integration.
