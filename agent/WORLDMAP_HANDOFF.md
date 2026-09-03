# WORLDMAP HANDOFF

**Project:** SamWar_BattleLab / 삼국WAR  
**Working branch:** `experiment/imjin-iso-movement`  
**Starting HEAD for this handoff:** `e6852e65eadb490f67cd3e41308d4c434338ee8a`  
**Starting commit:** `월드맵 상단 메뉴 아이콘`  
**Date:** 2026-09-03

---

## 1. 현재 작업 위치

현재 월드맵 / 아이소메트릭 / 신규 월드맵 UI 작업은 **`experiment/imjin-iso-movement` 브랜치에서 계속 진행한다.**

`main`은 현재 작업 브랜치가 아니다.  
이 브랜치에서 기능과 시각 QA를 끝낸 뒤, 이상 없을 때만 최종적으로 `main`에 합친다.

새 세션에서는 반드시 아래 순서로 확인한다.

1. 이 파일 `agent/WORLDMAP_HANDOFF.md` 읽기
2. 브랜치가 `experiment/imjin-iso-movement`인지 확인
3. 해당 브랜치 최신 HEAD 확인
4. 해당 브랜치 기준 실제 파일 확인
5. 그 뒤에만 수정 / 구현

기본 브랜치 `main`을 현재 작업 기준으로 먼저 보지 않는다.

---

## 2. 방금 확정된 상단 메뉴 디자인

메뉴 순서:

1. 테크트리
2. 군사
3. 인사
4. 외교
5. 교역
6. 첩보
7. 정보
8. 시스템

확정 UX:

- 평상시: 8개 메뉴 모두 동일하게 문양 아이콘만 표시
- 테크트리도 예외 없이 기본 상태에서는 라벨을 표시하지 않음
- Hover: 같은 자리에서 문양을 약 `1.10x` 확대
- Hover: 문양 위에 작은 검은 금테 라벨과 메뉴명 표시
- Mouse out: 라벨은 사라지고 문양은 원래 크기로 복귀
- 클릭한 메뉴 id는 내부 selection 상태로 추적할 수 있으나, selection 때문에 라벨을 상시 노출하지 않음
- 아이콘 슬롯 자체는 움직이지 않음
- Hover 때문에 옆 아이콘 위치가 밀리지 않음
- 문양은 사용자가 Photoshop에서 시각적 크기를 맞춘 원본을 그대로 사용
- 엔진에서 메뉴별 임의 optical-scale 보정을 넣지 않음

---

## 3. 확정 아이콘 자산

경로:

`assets/ui/worldmap/top_menu/icons/`

파일:

- `wm_topmenu_techtree.png`
- `wm_topmenu_military.png`
- `wm_topmenu_personnel.png`
- `wm_topmenu_diplomacy.png`
- `wm_topmenu_trade.png`
- `wm_topmenu_intel.png`
- `wm_topmenu_info.png`
- `wm_topmenu_system.png`

아이콘은 2026-09-03 사용자 Photoshop 재축소본으로 교체되었다.  
표시 크기는 Godot에서 `56px`, Hover는 `1.10x`를 유지한다.

---

## 4. 이번 구현 범위

Production `WorldMap.tscn`은 직접 수정하지 않는다.

현재 실제 시각 QA 씬인:

`WorldMap_16x9_Test.tscn`

에 독립 컴포넌트:

`WorldMapTopNav.tscn`

을 `CanvasLayer`로 올린다.

TopNav 로직:

`scripts/worldmap/ui/worldmap_top_nav.gd`

기존 임시 단일 버튼:

`scripts/worldmap/ui/worldmap_tech_tree_test_button.gd`

은 파일 삭제하지 않고, Test scene에서 더 이상 instance/controller로 사용하지 않는다.

테크트리 메뉴 클릭은 기존 ProductionWorldMap의
`_open_domestic_tech_tree_overlay_mvp()`
호출을 그대로 유지한다.

다른 7개 메뉴는 이번 단계에서는 시각 hover / click selection 추적까지만 검증하고 실제 기능은 추가하지 않는다.

---

## 5. 1차 시각 QA 기준

사용자 F6 / 실행 화면에서 확인:

- 상단 바가 `동방천하도` 현판과 과하게 겹치지 않는가
- 아이콘 8개의 시각적 크기가 Photoshop 목업과 비슷한가
- 기본 상태에서 8개 모두 문양만 동일하게 보이는가
- 기본 상태에서 아이콘 디테일이 죽지 않는가
- Hover 확대가 과하지 않고 약 10% 수준으로 자연스러운가
- Hover한 메뉴에만 라벨이 나타나는가
- Mouse out 시 해당 라벨이 다시 사라지는가
- Hover 때문에 메뉴 row가 좌우로 흔들리지 않는가
- 테크트리 클릭이 기존 overlay를 정상적으로 여는가
- 좌우 국가/도시 패널, 지도 이동, 도시 클릭, 턴 종료 등 기존 월드맵 기능에 회귀가 없는가

시각 QA 전에는 Production `WorldMap.tscn`으로 이식하지 않는다.

---

## 6. 다음 단계

1. `WorldMap_16x9_Test.tscn`에서 상단 메뉴 F6 재QA
2. 사용자 피드백에 따라 bar 폭 / 아이콘 표시 크기 / 간격 / label 위치만 미세조정
3. TopNav visual lock
4. 이후 메뉴 기능 연결 범위를 하나씩 확정
5. 월드맵 작업 전체 QA PASS 후에만 `main` 통합 검토

---

## 7. W2-3B TopNav 시각 refinement — 2026-09-03

사용자 F6 QA 결과:

- 8개 문양 아이콘 배치와 Hover 구조는 PASS
- 기존 상단 배경판은 너무 짙어 지도와 분리된 검은 띠처럼 보였음
- 배경판과 `동방천하도` 현판이 너무 붙어 있었음
- 아이콘은 사용자가 Photoshop에서 더 작은 최종 PNG로 교체함

적용값:

- `BAR_SIZE.y`: `62 -> 58`
- `SLOT_SIZE.y`: `58 -> 54`
- 상단 배경판 alpha: `0.90 -> 0.72`
- `BAR_TOP = 4` 유지
- 결과적으로 상단바 하단이 4px 위로 올라가 `동방천하도` 현판과 추가 간격 확보
- 아이콘 표시 크기 `56px`, Hover `1.10x`, 라벨 규칙은 변경하지 않음

수정 파일:

- `scripts/worldmap/ui/worldmap_top_nav.gd`
- `agent/WORLDMAP_HANDOFF.md`

다음 QA:

- 반투명 배경으로 지도가 적당히 비치는지
- 현판과 상단바 간격이 자연스러운지
- 새 아이콘의 선명도가 개선되었는지
- 아이콘이 얇아진 bar 안에서 위아래로 답답하거나 잘리지 않는지

---

## 8. W2-3C TopNav corner softening — 2026-09-03

사용자 F6 QA에서 현재 반투명도, 현판과의 간격, 아이콘 배치는 PASS. 상단 배경판의 완전한 직사각형 실루엣만 다소 딱딱하다는 피드백에 따라 장식 문양은 추가하지 않고 형태만 부드럽게 조정한다.

적용값:

- TopMenuBar 4개 corner radius: `2 -> 8`
- 배경 alpha `0.72`, bar 높이 `58`, slot 높이 `54`, 아이콘 `56px`, Hover `1.10x`는 유지
- 별도 배경 문양 / 용호 장식은 추가하지 않음
- Production `WorldMap.tscn`은 계속 미수정

수정 파일:

- `scripts/worldmap/ui/worldmap_top_nav.gd`
- `agent/WORLDMAP_HANDOFF.md`

다음 QA:

- 양끝이 웹앱 버튼처럼 과하게 둥글지 않고 사각형의 긴장감은 유지되는지
- 금색 문양 아이콘과 `동방천하도` 현판의 시각적 위계를 해치지 않는지

---

## 9. W2-3D Tech Tree overlay hierarchy + split detail — 2026-09-03

사용자 요구:

- 테크트리 창이 열리면 `TopNavCanvas(layer 40)`보다 반드시 위에 표시
- 기존 하단 단일 `선택 테크 상세 정보`를 좌/우 50:50 구조로 보이게 정리
- 국가 테크 선택 시 좌측 상세, 도시 테크 선택 시 우측 상세
- 반대쪽 / 미선택 상세 영역에는 테크트리 문양 워터마크 표시
- 연구 시작 / 비용 / 조건 / 효과 / 연구 상태 로직은 기존 ProductionWorldMap 구현을 그대로 사용

테스트 단계 구현:

- 신규 controller: `scripts/worldmap/ui/worldmap_tech_tree_split_detail_test_controller.gd`
- `WorldMap_16x9_Test.tscn`에 `TechTreeSplitDetailController` 연결
- Production `WorldMap.tscn` / 1.2MB `worldmap_main.gd`는 직접 수정하지 않음
- 기존 `WorldMapUI/tech_tree_overlay_mvp`를 runtime에 `TechTreeOverlayCanvasW23D(layer 60)`로 reparent하여 TopNav(layer 40) 위 계층 확보
- 기존 `DomesticTechDetailInspectorMVP` 자체를 재사용하여 기존 detail label / 연구 버튼 reference와 연구 로직을 보존
- inspector를 `DomesticTechDetailSplitW23D` HBox에 넣고 국가/도시 placeholder panel을 추가해 50:50 슬롯 구성
- 선택 scope는 기존 `_selected_domestic_tech_id_mvp` / `_selected_domestic_tech_city_id_mvp` 상태를 읽어 routing
- 국가 선택: 기존 inspector를 좌측에 표시하고 우측 도시 placeholder + watermark 표시
- 도시 선택: 좌측 국가 placeholder + watermark, 기존 inspector를 우측에 표시
- 미선택: 양쪽 placeholder + watermark 표시

워터마크:

- asset: `assets/ui/worldmap/tech_tree/wm_techtree_detail_watermark.png`
- 표시 크기: `240 x 240`
- alpha: `0.25`
- 중앙 정렬 / mouse ignore

다음 F6 QA:

- 테크트리 overlay가 상단 메뉴를 완전히 덮고 TopNav가 위로 튀어나오지 않는지
- 국가 테크 클릭 시 상세 정보 + 연구 시작 UI가 정확히 좌측에 표시되는지
- 도시 테크 클릭 시 동일 UI가 정확히 우측으로 이동하는지
- 반대쪽 워터마크가 25% alpha로 충분히 보이되 텍스트보다 강하지 않은지
- 국가↔도시를 반복 클릭해도 연구 버튼 / 비용 / 조건 / 효과가 기존과 동일하게 갱신되는지
- 닫기→재열기 후에도 split/detail routing이 다시 정상 적용되는지

---

## 10. W2-3D hotfix1 — keep detail panel visible — 2026-09-03

사용자 F6 QA 결과:

- overlay layer 문제는 해결되어 TopNav보다 테크트리 창이 위에 표시됨
- 그러나 기존 `DomesticTechTreeSplit`의 `SIZE_EXPAND_FILL` 때문에 상단 국가/도시 테크 영역이 세로 공간을 거의 전부 차지함
- 그 결과 새 `DomesticTechDetailSplitW23D`가 삭제된 것이 아니라 화면 하단 밖으로 밀려 상세 설명이 보이지 않음

핫픽스:

- 상단 `DomesticTechTreeSplit`을 runtime에서 `SIZE_SHRINK_BEGIN`으로 변경
- 상단 트리 목표 높이는 overlay 높이의 약 `42%`
- 상세 영역의 실제 combined minimum height를 먼저 계산하고 그만큼 하단 공간을 반드시 예약
- 상단 트리 최소 높이는 `190px`
- 상세 영역 최소 높이는 `270px`
- 상단 국가/도시 트리 panel 내부 scroll 동작은 유지
- 하단 `DomesticTechDetailSplitW23D`는 `SIZE_EXPAND_FILL`로 남은 세로 공간을 사용
- 국가/도시 상세 panel도 vertical expand 처리
- Production `WorldMap.tscn` / `worldmap_main.gd`는 계속 미수정

수정 파일:

- `scripts/worldmap/ui/worldmap_tech_tree_split_detail_test_controller.gd`
- `agent/WORLDMAP_HANDOFF.md`

다음 F6 QA:

- 그림2처럼 위쪽에 국가/도시 테크트리, 아래쪽에 상세 설명 영역이 동시에 보이는지
- 상단 트리 내부 세로 스크롤이 정상인지
- 국가 선택 시 좌측 상세 / 도시 선택 시 우측 상세가 보이는지
- 반대쪽 워터마크가 정상 표시되는지

---

## 11. W2-3F Domestic Tech Tree Ownership Consolidation — 2026-09-03

**Branch:** `experiment/imjin-iso-movement`
**Start HEAD:** `d3201405734262c761cb05705c07844764ad24b7`
**Implementation end HEAD:** `3c498a7` (`fix: consolidate domestic tech tree overlay ownership`)

### Actual root cause

`worldmap_main.gd` destructively refreshed `DomesticTechTreeOverlayContent`, while the separate
`worldmap_tech_tree_split_detail_test_controller.gd` polled every frame, reparented the overlay to
a new CanvasLayer, then detached and repackaged the main-owned tree and inspector nodes. The two
scripts therefore concurrently owned the same runtime subtree. `queue_free()` alone also left old
children parented until the end of the frame, allowing old and newly-built `EXPAND_FILL` content to
coexist during container layout.

### Final owner and lifecycle

- The only structural owner is now `scripts/worldmap/worldmap_main.gd`.
- It creates `DomesticTechTreeOverlayCanvasMVP` at `CanvasLayer.layer = 60`; the overlay therefore
  renders above the QA TopNav layer 40 without an external controller reparenting it.
- The initial build creates Header → bounded `DomesticTechBoundedBody` → `DomesticTechTreeRegion`
  (top 42%) and anchored `DomesticTechDetailSplit` (bottom 58%). The tree viewport clips its
  contents, so large tree minimum sizes cannot push detail content below the overlay.
- National/city `ScrollContainer`s use both horizontal and vertical `SCROLL_MODE_AUTO`.
- The detail owner routes the existing inspector to the national or city side, while the opposite
  side shows the existing watermark asset
  `assets/ui/worldmap/tech_tree/wm_techtree_detail_watermark.png` at 240×240 and alpha 0.25.
  Research cost, conditions, effects, button and research logic remain the existing main-owned logic.
- `_clear_domestic_tech_tree_children_mvp()` now immediately `remove_child()`s each old child before
  `queue_free()`, eliminating same-parent old/new overlap in the rebuild frame.
- `worldmap_tech_tree_split_detail_test_controller.gd` and its `.uid` were removed; its QA-scene
  instance was removed from `WorldMap_16x9_Test.tscn`. Production `WorldMap.tscn` was not edited.

## 12. W2-3G WorldMap Test Controller Conflict Risk Audit — 2026-09-03

The repository contains 16 current WorldMap UI test/bridge/guard/mirror scripts, rather than the
approximately 23 expected by the preliminary audit. The table is an inventory of actual files at
this revision; the deleted Tech Tree controller is recorded above as the resolved A conflict.

| File | Type | Uses `_process` | Finds production nodes | Mutates production structure | Risk/status | Recommended action |
|---|---|---:|---:|---:|---|---|
| `worldmap_warehouse_tabs_test_controller.gd` | test controller | no | yes | adds test card | C, stable test presentation | MIGRATE LATER |
| `worldmap_v2_background_test_controller.gd` | test controller | one-shot | yes | no | D, one-shot QA asset replacement | KEEP |
| `worldmap_turn_transition_late_guard.gd` | guard | no | yes | no | D, deferred test-host coordination | KEEP |
| `worldmap_turn_summary_test_bridge.gd` | test bridge | no | yes | adds popup/card rows | C, stable bridge | MIGRATE LATER |
| `worldmap_territory_test_controller.gd` | test controller | one-shot | yes | adds territory layer | D, isolated QA layer | KEEP |
| `worldmap_tech_tree_test_button.gd` | test controller | no | yes | adds legacy button | D, superseded by TopNav but retained unused | AUDIT LATER |
| `worldmap_tech_badge_test_controller.gd` | test controller | no | yes | adds badge sections | C, stable test presentation | MIGRATE LATER |
| `worldmap_stable_hud_mirror_controller.gd` | mirror controller | no | yes | adds mirror controls | C, explicit mirror surface | MIGRATE LATER |
| `worldmap_readability_test_controller.gd` | test controller | disabled | yes | no | C, startup style/value refinement for HUD cards | MIGRATE LATER |
| `worldmap_panel_refinement_test_controller.gd` | test controller | no | yes | adds supplemental HUD row/tooltip | C, stable test patch | MIGRATE LATER |
| `worldmap_left_panel_lock_guard.gd` | guard | yes | yes | no | B, per-frame position/size enforcement | REFACTOR TO SIGNAL |
| `worldmap_hud_position_test_controller.gd` | test controller | yes | yes | no | B, per-frame panel positioning | REFACTOR TO SIGNAL |
| `worldmap_garrison_compact_test_controller.gd` | test controller | yes | yes | adds compact grid; hides source | B, polling production garrison card | MIGRATE LATER |
| `worldmap_city_action_test_controller.gd` | test controller | conditional | yes | own overlay only | D, own test overlay follows selected city | KEEP |
| `worldmap_character_speech_test_bridge.gd` | test bridge | yes | yes | own popup; hides source labels | B, polling production role labels | REFACTOR TO SIGNAL |
| `worldmap_16x9_editor_preview.gd` | preview controller | no | yes | editor-only layout aid | D, editor QA only | KEEP |

### Specific required audit decisions

- **garrison_compact:** `MIGRATE LATER`. It performs `_process()` polling and adds a compact mirror
  below `GARRISON_CARD_PATH`, but the actual garrison list is assembled by
  `worldmap_16x9_test_host.gd`; `worldmap_main.gd` has no destructive rebuild of that subtree in
  the audited paths. Do not force a migration in this change. A future owner should update the
  compact view from an explicit garrison-data/UI-ready signal rather than polling.
- **readability:** `MIGRATE LATER`. It calls `set_process(false)` and applies only startup
  typography/size/value presentation changes to the left/right HUD cards. It neither reparents nor
  clears those cards. It is a production-presentation promotion candidate, but migration is not
  small enough to bundle with the active Tech Tree lifecycle fix.

### Permanent WorldMap UI ownership rule

> A destructively regenerated (`clear + rebuild`) UI subtree must never be directly modified by a
> separate controller that polls it from `_process()`. Integrate the behavior in the owning
> function/formal component, or emit a rebuild-complete signal and let an external listener react
> once. Per-frame polling plus a destructive owner on the same node tree is prohibited.

Review routine for every new test controller/bridge:

1. Identify every production node it reaches through `_process()` via `find_child` or `get_node_or_null`.
2. Search the owning main/component code for `clear`, `rebuild`, `queue_free`, `remove_child`, or
   `reparent` on that node or a parent subtree.
3. If both touch the same subtree, classify it as an ownership conflict before merging.
4. Prefer owner integration; otherwise provide a rebuild-complete signal for a one-shot listener.

Remaining Godot F6 QA: open/close/reopen the Tech Tree; verify the first frame has the 42/58 split
with no flicker or duplicate body; select national then city tech and verify opposite watermark;
scroll both trees without moving detail; change city while open; verify research text/button logic;
verify overlay is above TopNav; then sanity-check left/right HUD, garrison, chancellor/governor cards,
and readability presentation.
