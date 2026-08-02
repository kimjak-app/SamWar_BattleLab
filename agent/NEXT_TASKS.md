# NEXT TASKS

## Video Cutin Hotfix 2 F5 QA

- Execute Yi Sun-sin unique skill once and capture the single `[CUTIN_TRACE]` request sequence. Expected: `registry_hit=true`, `selected_mode=video`, assigned OGV path, `play_called=true`, no `fallback_called=true`.
- Confirm the actual OGV, title, and portrait render, then trigger Kwon Yul if available. If fallback appears, retain the trace output; it states the exact path and reason.
- Turn sequencing is already user PASS; do not alter it. Do not resume T08 UI work until actual OGV F5 QA passes.

## Runtime hotfix F5 QA gate

- Do not resume T08 UI work until actual Battle_Land QA passes. In a WorldMap battle, verify A1 → E1 → A2 → E2 and that Battle Turn/supply settlement happen only after all valid actors complete.
- Trigger 이순신, then 가능하면 정도전 또는 권율 unique skill. Confirm the registered OGV, portrait/title, completion/effect, momentum cost, and combat resume; no reinforcement/ready-flag fallback may appear.
- Production test scene retains the shared runtime contract, but no UI geometry, Theme, or sample-data changes are authorized by this hotfix.

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

## T08-2B QA Gate

- Await user F5 QA of the restored legacy `Battle_Land.tscn` game flow.
- Await user F6 QA of `tests/scenes/Battle_UI_Production_Test.tscn` for the isolated Production HUD.
- Only after both PASS results, start T08-3A Theme & Font First Pass in the Production HUD test scene. Do not modify the runtime legacy scene for T08-3A.

## T08-2B-hotfix1 QA

- User F5: confirm the restored central-top runtime HUD shows ally/enemy `3/10` at battle start, follows attack/skill/round changes, and reflects save/resume.

## T08-3A F6 Visual QA Gate

- Inspect `tests/scenes/Battle_UI_Production_Test.tscn` at 1920×1080: NotoSerifKR hierarchy, compact panel balance, ally/enemy slot contrast, and unclipped `3 / 10 · 1 / 30 · 3 / 10` values.
- T08-3B remains blocked until user visual approval. Runtime `Battle_Land.tscn` is not a T08-3A target.

## T08-3A-hotfix1 F6 Recheck

- Confirm the centered title/slot/value grouping, lighter panel background, and compact central Turn HUD at 1920×1080. T08-3B stays blocked until visual approval.

## T08-3B Emergency Rollback QA

- User F5: confirm legacy Battle_Land roster visuals and central-top momentum HUD are restored with no Production roster styling.
- User F6: confirm the Production test scene retains only the T08-3A top HUD and has pre-T08-3B roster visuals.
- After QA, ChatCoach must redesign a fully isolated T08-3B path. Do not start implementation or T08-3C.

## T08-3B0 F6 Structure QA Gate

- Run `tests/scenes/Battle_UI_Production_Test.tscn` directly with F6 and confirm each visible roster card shows portrait, name, `병력 current / max`, troop icon, and troop-type name.
- Confirm `TroopBar`, `행동 가능/행동 완료`, and `고유특기 준비` text are not shown by default; status text and the ready icon appear only when their existing runtime condition is true.
- Confirm the T08-3A top HUD is unchanged and F5 `Battle_Land.tscn` remains untouched. Do not start T08-3B1 Theme/Font or T08-3C before this structure QA passes.

## T08-3B1 F6 Visual QA Gate

- Run `tests/scenes/Battle_UI_Production_Test.tscn` with F6 at 1920×1080. Confirm NotoSerifKR Bold hero names, Medium troop values/types, blue-black ally cards, and dark red-brown enemy cards are readable without obscuring the battlefield.
- Confirm portraits and troop icons remain aligned, all five card positions per side stay inside their panels, and hidden action/progress/ready-text contracts remain intact.
- Confirm the T08-3A top HUD is unchanged. Selected-card styling is intentionally deferred because no test-only selection presentation signal exists. Do not start T08-3C before visual approval.

## T08-3B1-hotfix1 F6 Status QA Gate

- In the Production test scene, place or retain a defending unit and confirm `◆ 방어 태세` appears below `병력 current / max` in the left text column.
- Confirm the right-bottom troop type remains readable with no overlap, and that clearing the status hides the row again.
- Confirm every other card preserves the same status slot, all action/progress/ready text stays hidden, and the T08-3A top HUD is unchanged. Do not start T08-3C before approval.

## T08-3C F6 Bottom HUD Visual QA Gate

- At 1920×1080, confirm the left battle log, center current action/interaction guide, and right battle-supply Preview are readable without overlap or AutoBattle command conflict.
- Confirm normal ally/enemy food, salt, consumption, sustain and turn samples. To review only the warning treatment, toggle isolated `SHOW_WARNING_SAMPLE`; never connect it to runtime supply/context.
- Confirm top HUD and five-card rosters per side are unchanged. Theme transfer to Battle_Land and final resolution work remain deferred until user PASS.
