# HANDOFF TO CODEX

## Video Cutin Hotfix 2 QA hold

Actual presentation playback is covered by `tests/scripts/test_actual_video_cutin_playback.gd`: it instantiates the real presentation scene and verifies OGV stream assignment/playback for runtime and mixed IDs. Live F5 tracing is enabled under `CUTIN_TRACE_ENABLED`; wait for user visual confirmation before declaring the video fixed or resuming UI work.

---

## Runtime emergency hotfix hold

The current runtime regression hotfix restores one-enemy-per-initiative alternation and maps live battle hero/skill IDs to the existing Korea MVP OGV registry. All automated checks pass; wait for user F5 QA before any T08 UI continuation. `Battle_Land.tscn`, T08 Theme/geometry, and test Preview data were not changed.

Focused checks: `tools/validate_alternating_battle_action_order.py`, `tools/validate_korea_mvp_video_cutin_routing.py`, and their Godot scripts under `tests/scripts/`.

---

## Current T08-3C QA hold

T08-3C is implemented. All validators and Godot 4.6.2 project, `Battle_Land.tscn`, and Production test-scene headless loads pass. Await only user F6 visual QA; do not modify Battle_Land, shared scripts/adapters, BattleSupplyRuntime, WorldMap context, top HUD, or rosters, and do not transfer Theme before approval.

The test-only Preview is `BattleUI/ProductionHudRoot/BottomHudRoot/BattleSupplyPreviewPanel`, driven only by `tests/scripts/battle_ui_production_test_bottom_hud.gd`. It has fixed normal samples and default-off `SHOW_WARNING_SAMPLE`. Use `tools/validate_t08_3c_bottom_hud.py` for focused protection checks.

---

## SamWar_BattleLab 자동 작업 권한 헤더

이번 작업은 SamWar_BattleLab 폴더 내부 작업이다.

읽기 / 검색 / 코드 수정 / 씬 파일의 필요한 범위 수정 / 검증 실행 / agent 문서 업데이트 / 로컬 git commit까지는 모두 자동으로 진행한다.

중간에 확인 질문하지 말고, 지시문에 적힌 목표 완료까지 진행한다.

단, 아래 작업은 하지 않는다:

- git push
- 파일 삭제
- repo 밖 시스템 변경
- 프로그램 설치
- 패키지 전역 설치
- OS 설정 변경
- 요청 범위 밖 대규모 리팩토링

설치나 repo 밖 변경이 필요하다고 판단되면 작업을 멈추고 이유와 대안을 보고한다.

작업 완료 후 수정 파일 목록, 검증 결과, 로컬 커밋 해시, 남은 F6 QA 항목을 보고한다.

---

# T08-2-hotfix1 Production HUD Scene Recovery, Layout & Legacy Visibility Correction

## Completion note

Implemented locally after the original F6 failure. The malformed standalone `+` scene line was removed, the `visible` local was renamed to `should_show_slot`, production/legacy visibility parity was added, and the focused validator now checks malformed lines, parent graph/order, layout bounds, safe defaults, and shadowing. Automated static checks pass; Godot headless launch is unavailable in this execution environment, so user F6 retest remains required.

## User QA result

T08-2 implementation commit `6b648369dc3b6f1e5d419c97acbe56ece79f9d0e` was pushed to `main`, but user `Battle_Land.tscn` F6 QA failed.

Observed:

- Godot error counter: 148.
- Cascading messages such as:
  - `Parent path './BattleUI/ProductionHudRoot' for node 'TopHudRoot' has vanished`
  - descendants under momentum, roster, actor, guide, and log roots also vanished.
- GDScript warning:
  - local variable `visible` shadows the inherited `CanvasItem.visible` property.
- Production and legacy HUDs overlap.
- Top momentum/turn/title text is unreadable.
- Large empty translucent panels obscure the battlefield.

Confirmed remote evidence:

- `Battle_Land.tscn` contains a literal standalone `+` line immediately after `AnimationPlayer_Cutin` and immediately before the `ProductionHudRoot` declaration.
- `scripts/battle_web_import_test.gd` production roster refresh contains:

```gdscript
var visible := bool(unit.get("visible", false))
slot.visible = visible
if not visible:
```

- `tools/validate_t08_2_production_hud.py` currently checks string presence and counts, but does not reject malformed standalone scene lines, validate parent declaration order, or detect the shadowing variable.

Treat the 148 parent messages as a cascading scene-instantiation failure until proven otherwise, not as 148 independent defects.

## Starting procedure

1. Confirm branch `main`.
2. Report local HEAD, `origin/main`, and dirty status.
3. Fetch remote.
4. If the working tree is clean, fast-forward to current `origin/main`.
5. Read:
   - `agent/WORKFLOW_MANAGER.md`
   - `agent/TRANSACTION_DEVELOPMENT_RULES.md`
   - `agent/GODOT_RULES.md`
   - `agent/CURRENT_STATE.md`
   - `agent/NEXT_TASKS.md`
   - `agent/transactions/T08_2_SCENE_AUTHORED_PRODUCTION_HUD_SKELETON_AND_UI_STATE_ADAPTER.md`
6. Inspect exact current versions of:
   - `Battle_Land.tscn`
   - `scripts/battle_web_import_test.gd`
   - `scripts/battle/ui/battle_hud_state_adapter.gd`
   - `tools/validate_t08_2_production_hud.py`

Do not revert `6b6483`, reset history, or force-push. Repair forward with a new hotfix commit.

---

# Phase A — Scene integrity recovery

This phase must complete before layout polishing.

## A1. Remove malformed scene content

Remove the standalone literal `+` line before `ProductionHudRoot`.

Audit the complete newly added production HUD section for any other bare patch markers or invalid lines, including standalone:

- `+`
- `-`
- `@@ ... @@`
- conflict markers such as `<<<<<<<`, `=======`, `>>>>>>>`

Do not remove valid numeric signs inside properties.

## A2. Validate actual parent graph and declaration order

Parse every `[node ...]` declaration in `Battle_Land.tscn`.

For the production HUD tree, verify:

- `ProductionHudRoot` parent is `BattleUI`.
- `TopHudRoot` parent is `BattleUI/ProductionHudRoot`.
- Momentum roots parent to `TopHudRoot`.
- Slot rows parent to their momentum roots.
- Momentum slots parent to the matching slot row.
- Roster roots parent to `ProductionHudRoot`.
- Roster slots parent to their roster root.
- Slot children parent to the matching slot.
- Actor, guide, command, log, tooltip, and facing children parent to declared roots.
- Every parent exists in the scene.
- Every parent is declared before its child.

Do not blindly rewrite valid parent strings merely because Godot error output displays them with a leading `./`.

## A3. Remove shadowing warning

Change the local roster variable from `visible` to a non-shadowing name such as:

```gdscript
var should_show_slot := bool(unit.get("visible", false))
slot.visible = should_show_slot
if not should_show_slot:
```

Search all T08-2 modified/new GDScript for any additional local variable or parameter named `visible`. Rename only local identifiers; do not rename the engine property.

## A4. Scene-load blocker rule

Do not proceed to final visual layout work while any production-HUD node still produces `has vanished` or parse/instantiation errors.

---

# Phase B — Functional 1920×1080 layout correction

After the scene tree is structurally valid, correct the initial functional layout. This is not final graphics work.

## B1. Top HUD

- Compact top-center safe zone.
- Clearly separated:
  - left: ally momentum `3 / 10` and ten slots;
  - center: turn `1 / 30`;
  - right: enemy momentum `3 / 10` and ten slots.
- Battle title and active side use a separate line/area.
- No text overlap.
- Keep total top HUD height near the minimum required; target approximately 100–120 px, not a large battlefield-covering panel.

## B2. Rosters

- Ally roster at left edge.
- Enemy roster at right edge.
- Three main and two reinforcement slots per side.
- Existing roster content must remain readable.
- Do not cover the central tactical field more than necessary.

## B3. Actor comparison and placeholders

- Actor comparison uses a compact lower-center safe zone.
- Do not show large empty translucent rectangles when actor or subject data is absent.
- Hide or collapse unused left/right/center surfaces until meaningful data exists.
- Do not display `지형 정보: T09 예정` as persistent player-facing text.
- Keep the T09 field internally reserved but empty/hidden.
- Tooltip and facing-selection roots default to hidden unless actively used.

## B4. Legacy/new visibility parity

Once the matching production surface is valid:

- production top HUD visible → legacy `TopBar`/`TurnBanner` hidden;
- production rosters visible → legacy formation-guide roster panels hidden;
- production battle log visible → duplicate legacy visible mini-log hidden or routed to one canonical visible source;
- production actor comparison visible → obsolete legacy close-up surface hidden when redundant.

Do not delete nodes. Preserve fallback capability.

Do not hide:

- battlefield-local unit tokens;
- portrait badges;
- HP/troop labels;
- facing arrows;
- range/target overlays;
- cutin/result/toast layers;
- actual global command controls still needed for gameplay.

## B5. Command semantics

Preserve the T08-2 correction:

- defend handler is visibly labeled `방어`;
- true movement action remains labeled `이동`.

Do not change battle rules.

---

# Phase C — Validator strengthening

Update `tools/validate_t08_2_production_hud.py` so the original failure cannot pass again.

Required checks:

1. Reject standalone malformed lines in the scene, especially bare `+`, bare `-`, patch hunks, and conflict markers.
2. Parse node declarations and build full node paths.
3. Confirm each production node parent exists.
4. Confirm each parent is declared before the child.
5. Confirm exactly ten ally and ten enemy momentum slots.
6. Confirm three main and two reinforcement slots per side.
7. Confirm no local declaration/parameter named `visible` exists in T08-2 new or modified GDScript where it shadows CanvasItem.
8. Confirm production top/roster/log nodes and their legacy equivalents are not all default-visible simultaneously.
9. Confirm Tooltip/Facing/T09 placeholder surfaces are hidden by default where applicable.
10. Add basic 1920×1080 rect sanity checks for major production roots:
    - within viewport bounds;
    - top HUD height constrained;
    - actor comparison height constrained;
    - no full-screen default-visible empty panel except the non-rendering root container.
11. Preserve previous hierarchy, field, refresh-entry, slot-count, and command-label checks.

The validator must fail on the exact pre-hotfix `6b6483` content.

---

# Protected contracts

Do not change:

- T01–T07 gameplay logic.
- Momentum start `3` and maximum `10`.
- Battle maximum turn `30`.
- Unit stats, damage, movement, range, facing, AI, reinforcement, supply, cutin, result, save/resume, or WorldMap return behavior.
- Final UI art assets.
- Hanseong battlefield art.
- T09 terrain or T10 tactic behavior.

Do not delete files or scene nodes.

---

# Verification

Run all available checks:

```text
python tools/validate_t08_2_production_hud.py
python tools/validate_t06_t07_playable_transaction.py
python tools/validate_five_unit_type_full_completion.py
python tools/validate_five_unit_type_damage_auto_battle_and_skill_parity.py
git diff --check
```

Also run any focused scene parser/checker available in the repository.

Use `agent/LOCAL_ENV.md` only to discover a local Godot executable path; do not commit it.

When Godot is executable, run:

- project headless parse/load;
- direct `Battle_Land.tscn` load;
- any available smoke test that instantiates the scene.

Godot success criteria:

- no `Parent path ... has vanished` production-HUD messages;
- no GDScript `visible` shadowing warning;
- no new parse or runtime errors.

If Godot still cannot be launched, state that honestly and leave user F6 QA pending. Static validators alone are not sufficient to mark the hotfix complete.

---

# Documentation

Update:

- `agent/transactions/T08_2_SCENE_AUTHORED_PRODUCTION_HUD_SKELETON_AND_UI_STATE_ADAPTER.md`
- `agent/CURRENT_STATE.md`
- `agent/NEXT_TASKS.md`
- `agent/HANDOFF_TO_CODEX.md`
- `agent/CHANGELOG.md`

Record the original user F6 FAIL, exact root causes fixed, validation commands, Godot availability/result, remaining legacy surfaces, and user F6 retest checklist.

## Local commit

```text
fix: recover production HUD scene and layout
```

Do not push.

## Completion report

Return:

1. starting local HEAD and fetched `origin/main`;
2. ending local HEAD;
3. modified files;
4. exact malformed scene content removed;
5. exact shadowing identifier renamed;
6. parent-graph validation result;
7. layout/legacy visibility corrections;
8. validator changes;
9. all command results;
10. Godot load result or honest unavailable status;
11. local commit hash;
12. exact user F6 checks still required.

## Current next step

1. Wait for user F5/F6 QA results.
2. After PASS, perform T08-3A Theme & Font First Pass in `tests/scenes/Battle_UI_Production_Test.tscn` only.

## T08-2B-hotfix1

- Wait for user F5 confirmation that the legacy runtime momentum HUD is visible at the central top and updates correctly. Do not start T08-3A before this QA gate passes.

## T08-3A Result

- User F5 QA passed for the isolated runtime legacy scene. The Production top HUD now uses `assets/ui/battle_ui_theme.tres` in `tests/scenes/Battle_UI_Production_Test.tscn` only.
- Await user F6 visual QA of the compact three-panel top HUD. Do not prepare or begin T08-3B until that approval.

## T08-3A-hotfix1 Result

- Applied only alignment, density, and panel-alpha polish to the Production top HUD. Await the user F6 recheck; do not begin T08-3B.

## T08-3B Emergency Rollback

- T08-3B was reverted because shared runtime scripts caused Production roster presentation to appear in F5 Battle_Land despite no scene-file diff.
- Next step: user F5/F6 recovery confirmation. After that, ChatCoach designs a fully isolated T08-3B rework. Do not prepare an implementation instruction or begin T08-3C.

## T08-3B0 Result

- The isolated Production scene now has legacy roster content parity through a scene-only bridge; shared battle scripts, `Battle_Land.tscn`, and `battle_ui_theme.tres` were not changed.
- Await user F6 structure QA: portraits, names, troop values, troop icons, and troop-type names must be visible; progress/action/ready text must remain hidden by default; the T08-3A top HUD must remain unchanged.
- Do not begin T08-3B1 Theme/Font work or T08-3C before the user records F6 structure approval.

## T08-3B1 Result

- The Production test-scene roster now uses isolated Theme variations: NotoSerifKR Bold 19 hero names, Medium 15 troop values, Medium 14 troop types, subdued blue-black ally cards, and dark red-brown enemy cards.
- `Battle_Land.tscn`, shared scripts, test bridge data logic, roster NodePaths, and the T08-3A top HUD remain unchanged. Selection styling is deferred because no safe test-only selection signal is available.
- Await user F6 visual QA only; do not start T08-3C before approval.

## T08-3B1-hotfix1 Result

- User F6 found Production roster status/type overlap. Status is now left-aligned below troop values at `80,66–188,88`; the unchanged troop-type area starts at x=196.
- The scene-only bridge uses the existing legacy status formatter, so `◆ 방어 태세` parity is retained without shared-code or gameplay changes.
- Await user F6 status QA only; do not start T08-3C before approval.
# Video Cutin Hotfix 3 handoff

- Preserve the Part-A Godot-saved Production UI commit; the T08 UI validators use it as their locked semantic baseline. Do not change Theme, fonts, panels, or production-scene geometry during cutin QA.
- Cutin hero identity must use `KoreaMvpHeroCutinRegistry.canonicalize_hero_id()` at every cutin boundary. Never restore raw caster/skill-owner comparison or add isolated per-hero routing conditions.
- Automated 10-hero identity and 13-hero scene-tree playback coverage passes. Remaining work is user F5/F6 visual QA only; do not resume T08 UI slices beforehand.
# Runtime Hero ID Hotfix 4 handoff

- `_get_hero_id_for_unit_state()` is a runtime/legacy contract for `HERO_REGISTRY`, display name, portrait, close-up, retreat toast, reinforcement, and current-action paths. Do not canonicalize its return value.
- Canonicalization is only permitted inside `_play_committed_hero_cutin()` for caster/owner parity and Korea MVP registry resources.
- Required user QA: Kim Yu-sin must display normally and play the Kim Yu-sin OGV; Yi Sun-sin and Jeong Do-jeon are the paired regressions.
