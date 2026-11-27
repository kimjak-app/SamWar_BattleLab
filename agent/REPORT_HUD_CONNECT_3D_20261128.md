# 큐 41 보고 — 3D 월드맵 HUD 연결

- 지시서: `agent/ORDER_HUD_CONNECT_3D_20261128.md` (orders `c170dd6` 추가 8절 포함)
- 가지: `feature/wm3d-hud-connect-20261128`, 기준 `main` `d2d7d34`
- 커밋: 코드 `2d34734` → 재고정 `591e4dc`(마지막, `[skip ci]` 없음) → 이 보고서(`[skip ci]`)

## 1. 확인 결과
1. **숨긴 창 다시 쓰기**
   - `CityDetailPanel`: **그대로 다시 씀.** 외교·첩보·무역의 실제 행동 카드(사절·조공·교역 협정·관계 회복·동맹 / 정탐·민심 교란·충성 교란·반란 선동·이간질 / 수동 무역 실행 버튼)가 모두 이 창의 탭 안에 있다. 숨김은 `HudPositionOwner._install`에서 한 번만 걸려(매 프레임 재숨김 없음) 메뉴가 열 때 보이게 하면 된다. 위치는 상단 메뉴 아래·오른쪽 도시 창 왼쪽에 놓고, 마우스를 막는다(`MOUSE_FILTER_STOP` — 3D 지도는 `_unhandled_input`만 받으므로 창을 뚫고 가지 않음).
   - `DiplomacySpyPanel`: **쓰지 않음.** 탭 버튼이 "deferred"만 출력하고 아무도 내용을 채우지 않는 빈 창이다(main `_setup_unified_city_detail_diplomacy_panel`이 시작 때 숨김). 실제 외교·첩보 UI는 위 `CityDetailPanel` 탭이라 그쪽으로 연결.
   - 수동 무역 창(`ManualTradeOrderPanel`): 그대로 씀(교역 메뉴 + 내 도시 선택이면 바로 열림).
   - `SaveButtonRow`: **최소 래퍼.** 목록에서 빼도 `WorldMapHudController._apply_compact_visibility`(왼쪽 창 갱신마다)와 `WorldMapTurnSummaryController._hide_post_turn_log_nodes`(턴 처리마다)가 다시 숨긴다 → 상단 **시스템** 창에 저장·불러오기·소리 설정 버튼.
   - 모병 버튼(`CityInfoPanel` 군사 카드): 간소 모드가 `show_city`마다 다시 숨김 → 상단 **군사** 창에 "모병 +100" 버튼(기존 `_on_city_info_recruitment_requested(city, 100)` 그대로, 비용·상한 현행).
   - 정탐 결과(P3 카드): `CityInfoPanel`의 `HintLabel`에 그려지는데 간소 모드가 숨김 → `CityDetailPanel` 첩보 탭의 한 칸에 같은 문구(`_format_enemy_intel_observation_lines`)를 보임.
2. **메뉴 → 창** (3절 표)
3. **모병**: `CityInfoPanel` `RecruitButtonPlaceholder` → `recruitment_requested(city, 100)` → main `_on_city_info_recruitment_requested` → `_recruit_troops`. 같은 함수로 연결.
4. **3D 화면 좌표**: `WorldMap3DAdapter.city_screen_position(city)` = 3D 성(`root3d.markers[city]`)의 `global_position`을 3D 카메라 `unproject_position`으로(3D SubViewport는 전체 화면·축소 1이라 화면 좌표와 같다). 카메라 뒤면 null. **카메라가 움직이면 메뉴가 따라감**(행동 메뉴의 기존 `_process` 배치가 매 프레임 다시 계산), **도시가 카메라 뒤로 가면 메뉴를 닫음**, 화면 밖이면 기존처럼 안쪽으로 밀어 넣음. 3D 카메라가 없으면(`can_project_cities()` false) 예전 2D 표식 좌표.
5. **숫자가 늦게 바뀌는 원인**: 창고 변경 신호는 없고, 경로마다 갱신 호출이 빠져 있었다.
   - 연구 시작 `_start_domestic_tech_research_mvp`: 테크트리만 갱신 → 왼쪽 창(국가 창고)·도시 창 갱신 추가.
   - 외교(비맥락) `_on_diplomacy_action_pressed`: 도시 창 갱신 없음 → `_refresh_city_hud_data_bindings` 추가.
   - 첩보(비맥락) `_on_spy_action_pressed`: 국가 창고 갱신 없음 → `_refresh_left_world_status_panel` 추가.
   - 모병·수동 무역·불러오기는 이미 모두 갱신. 매 프레임 갱신은 넣지 않았다.
6. **CI 로그 `set_city_owner` on `Node3D` + 3D 클래스 파싱 오류**: **시험 환경 원인.** C-track은 `worldmap3d/.gdignore`로 3D 폴더를 가져오기에서 뺀다(`verify-c-track.yml` "Exclude 3D world map from shard import") → `WorldMapConfig`·`WorldMapGeo`·`WorldMap3DCamera` 등 클래스 캐시가 없어 `worldmap3d_root.gd`가 파싱 실패 → 씬 루트가 스크립트 없는 `Node3D` → 호스트가 0.25초마다 모든 성에 `set_city_owner`를 불러 실패. 게임(F6)·WorldMap3D CI에는 없음. 어댑터 `sync_city`에 `has_method` 확인 한 줄만 넣어 로그 폭주는 멈췄다(동작 변화 없음).
   - 로컬에서 같은 조건(`.gdignore` + 새 클래스 캐시)을 재현해 새 시험·CITIES65 시험을 돌렸다 → 처음엔 행동 메뉴가 3D 좌표를 못 얻어 닫혀 CITIES65 시험 8이 깨졌고, 3D 카메라가 실제로 있을 때만 3D 좌표를 쓰게 고쳐 둘 다 통과.

## 2. 넣은 것
| 항목 | 내용 |
|---|---|
| 상단 메뉴 | 새 `WorldMapHudMenuRouter`(TopNav가 만듦). 같은 메뉴 다시 누름 = 닫힘, 다른 메뉴 = 바꿈. 테크트리를 열면 닫힘 |
| 외교 | `CityDetailPanel` 외교·첩보 탭 / 외교. 대기 중 요청 줄 "· 접수됨: 사절 파견 → 고구려 (예약 금 30) — 결과는 다음 턴", 턴 뒤 "· N턴 결과 처리: … — (결과 메시지)" |
| 첩보 | 같은 탭 / 첩보. 기존 첩보 행동 5개, 정탐 결과 카드(재고 9칸 + 재상 정치 적성 3 이상이면 소속 장수). 빈 성은 대상 아님(큐 39) |
| 교역 | 무역 탭 / 타국무역 + 내 도시면 수동 무역 창. 주문 저장 → [수동 무역 실행] → "접수됨. 쌀 100을 예약했습니다. 다음 턴에 결과가 나옵니다." → T+1 그 주문 줄에 "성사 — 받은 것 금 N · 보낸 것 쌀 100" / "무효 · 예약분 반환" / "무효 · 돌려줄 도시가 없어 반환 보류" |
| 시스템 | 저장·불러오기·소리 설정. **저장은 수동 슬롯** `user://worldmap_manual_save.json`(같은 JSON, `_serialize_worldmap_state` 그대로) — 1-7 참고 |
| 군사 | 선택 도시·병력 + "모병 +100"(내 도시일 때만) |
| 인사·정보 | "준비 중" |
| 도시 창 | 도시 클릭 → `CityDetailPanel`. 내 도시 = `resource_stock` 9칸, 빈 성 = "창고: 주인 없음(빈 성)", 외국 = 정탐 결과가 있으면 그 값, 없으면 "창고: 정보 없음 (정탐 필요)". **전에는 외국 도시도 실제 창고가 그대로 나왔다**(숨은 창이라 안 보였을 뿐) |
| 행동 메뉴 | 3D 화면 좌표 기준(1-4) |
| 즉시 갱신 | 1-5 세 곳 |

### 1-7. 저장/불러오기 — 고친 버그
기존 저장은 슬롯 하나(`user://worldmap_left_panel_state.json`)인데, 턴 끝마다 자동 체크포인트(`_checkpoint_worldmap_state_mvp`)가 **같은 파일**을 다시 쓴다. 그래서 "저장 → 턴 넘김 → 불러오기"가 저장 시점이 아니라 턴 뒤 상태로 돌아온다(김작 F6 7번이 실패하는 원인). 시스템 메뉴 저장만 같은 형식의 별도 파일에 쓰고, 불러오기는 그 파일이 있으면 그것, 없으면 예전 슬롯을 읽는다. `_save_worldmap_state()`(전투·부상 처리 등이 자동 저장으로 부름)와 자동 체크포인트는 그대로.

### 8-1. 첩보 비용 버그 — 고침
`spy_action_service.gd` 민심 교란·충성 교란·반란 선동 검사 함수가 `"cost": {}`를 돌려줘 비용 0·잔액 검사 없음이었다. 이간질과 같은 방식으로 각자의 `_get_spy_*_cost`(상수 그대로: 금 300 / 금 500+비단 50 / 금 800+비단 100)를 `cost`로 돌려주고, `_can_pay_generic_resource_cost`가 실패하면 `{"ok": false, "reason": "resources"}` → 차감 0·쿨다운 0·효과 0. 정탐(무료)은 그대로.

### 8-2. 문구
- 수동 무역 접수: "접수됨. [품목 양]을/를 예약했습니다. 다음 턴에 결과가 나옵니다."(조사는 마지막 숫자 읽기에 맞춤)
- 결과는 그 주문 줄에 "성사 / 무효 · 예약분 반환 / 무효 · 돌려줄 도시가 없어 반환 보류". 보류 결과 메시지도 "돌려줄 도시가 없어 반환 보류."로.
- 외교 요청은 성사가 아니라 "처리"(동맹 거절도 처리된 결과라서) + 결과 메시지.

## 3. 메뉴 → 창 표
| 상단 메뉴 | 창 | 비고 |
|---|---|---|
| 테크트리 | 기존 테크트리 오버레이 | 그대로(다른 창 닫음) |
| 군사 | 시스템 창 자리의 "군사 · 모병" 창 | 기존 모병 함수 |
| 인사 | "준비 중" | 기존 창 없음 |
| 외교 | `CityDetailPanel` 외교·첩보 탭 / 외교 | 기존 행동 카드 |
| 교역 | `CityDetailPanel` 무역 탭 / 타국무역 (+ 수동 무역 창) | P2 접수 |
| 첩보 | `CityDetailPanel` 외교·첩보 탭 / 첩보 | 기존 행동 카드 + 정탐 결과 카드 |
| 정보 | "준비 중" | 기존 창 없음 |
| 시스템 | 저장·불러오기·소리 설정 창 | 소리 설정 = 기존 `AudioSettingsPopup` |

## 4. 바뀐 파일
`worldmap_main.gd`(+26/−10, 재고정), `worldmap_top_nav.gd`, `worldmap_city_action_controller.gd`, `worldmap_3d_adapter.gd`, `spy_action_service.gd`, `strategy_request_service.gd`(문구), 새 `scripts/worldmap/ui/worldmap_hud_menu_router.gd`·`worldmap_hud_connect_presenter.gd`(+`.uid`), 새 시험 2개(+`.uid`), `verify-c-track.yml`, `tools/p1_exact_delta.py`(`HUD41_CHECKPOINT` + 정확한 차이 36줄). `WorldMap.tscn`·`worldmap_hud_presentation_controller.gd`는 0줄. 규칙 값(비용·확률·가격) 변경 0.

## 5. 시험
- `tests/scripts/test_worldmap_hud_connect_3d.gd` (C-track): **3D 켜짐 `checks=69 failures=[]`**, C-track 조건(3D 폴더 제외) **`checks=68 failures=[]`**(3D 카메라 뒤 확인 1개가 3D에서만 돈다).
  1. 외교·첩보·교역·시스템: 누르면 `is_visible_in_tree()` true, 다시 누르면 false, 다른 메뉴로 바뀜, 창이 마우스를 막음, 정보 = 준비 중 ✔
  2. 외교 창의 [사절 파견] → 국가 금 −30 + "접수됨" 줄 → 턴 끝 → "결과" 줄 ✔
  3. 첩보 창 [민심 교란] → 금 정확히 −300 + 왼쪽 창 숫자 즉시 / 정탐(성공 고정) → 카드 보임, 재고 + 정치 적성 3 이상이면 장수 ✔
  4. 교역 메뉴(내 도시) → 주문 창 열림 → 주문 → [수동 무역 실행] → "접수됨" → 턴 끝 → "결과" 줄, 쌀 100 한성 → 상대 ✔
  5. 시스템 [저장] → 바꿈 + 턴 → [불러오기] → 65성 주인·병력·창고, 대기 요청, 3D 주인·병력 모두 저장 때와 같음 ✔
  6. 한성 창고 9칸 숫자 = `resource_stock`, 비용 뒤 표시 = 새 값 ✔
  7. 군사 [모병 +100] → 병력 증가, 비용 차감, 표시 즉시 ✔
  8. 평양 클릭 → 메뉴 중심이 평양 화면 좌표 160px 안(3D면 3D 좌표) ✔
  9. 빈 성(개성): 그냥 / 첩보 창이 열린 상태 / 저장·불러오기 사본 뒤 — 행동 메뉴 닫힘, 평양 기준 행동 실행 0, 개성 첩보 대상 아님, 도시 창 "주인 없음(빈 성)" ✔
  - 8-1: 민심 교란 금 300 → 정확히 300 한 번, 299 → 0·쿨다운 0, 쿨다운 중 재실행 0, 내 도시 대상 0 / 충성 교란 금 500+비단 50, 반란 선동 금 800+비단 100 각각 같은 네 경우 — 도시 창고 차이로 확인, 국가 금 = 도시 합계 ✔
- `tests/scripts/test_worldmap3d_hud_menu_position.gd` (WorldMap3D, 실제 3D): `checks=7 failures=[]` — 평양 메뉴가 3D 좌표 근처, 카메라 이동 따라감, 성이 카메라 뒤 → null·메뉴 닫힘, 없는 도시·3D 끔 → null.
- 회귀: P0 86 · P3 48 · P1 49 · CITIES65 322 · P2 60 · HUD·3D host·production 시험 모두 아래 전체 실행에서 통과.

## 6. CI
- `Verify C-track refactor` 실행 `46065027034` (head `591e4dc`): **초록**, 4개 묶음(shard 0~3) 모두 success, 재실행 없음. 끝난 시각 2026-11-27 21:00 UTC.
- `Verify WorldMap3D` 실행 `46065027030` (head `591e4dc`): **초록**, 단계별 Import(3D 포함)·WorldMap3D tests(새 `test_worldmap3d_hud_menu_position` 포함)·scene load·Diff check 모두 success. 끝난 시각 20:40 UTC.

## 7. 로컬 전체
- 작업 트리 `591e4dc`: C-track 시험 216개(CI 목록 그대로, 4개 병렬) **216 실행, 216 종료 코드 0**. 검증 스크립트 72개 **72 통과**.
- WorldMap3D 시험 9개 모두 통과(adapter 56 · camera_controller 61 · camera_external_input 20 · color_parity 57 · host 58 · hud_menu_position 7 · mem_probe 37 · production 28 · roads 172).
- C-track 조건 재현(3D 폴더 제외 + 새 클래스 캐시): `test_worldmap_hud_connect_3d` 68/68, `test_worldmap_cities65_preview` 322/322.

## 8. 김작 최종 F6 순서 (지시서 6절, `c170dd6`판 그대로)
(정탐과 민심 교란은 쿨다운을 같이 쓴다. 교란은 실패해도 쿨다운이 걸리므로 순서대로 하고, 막히면 턴을 넘긴다 — 채비서 51)
1. F6 → 새 게임 → 한성 클릭: 메뉴가 한성 옆에 뜨는지. 도시 창에 창고 9칸 숫자가 있는지.
2. 상단 **첩보** → 평양 **정탐** → 결과 카드가 뜨는지(재상 정치 적성 3 이상이면 장수 칸).
3. 상단 **외교** → 아무 세력에 **사절** → "접수됨"이 뜨는지.
4. 상단 **교역** → 지금 교역 가능한 상대(예: 평양)로 감당 가능한 양(쌀 100) **수출** → "접수됨. 쌀 100을 예약했습니다. 다음 턴에 결과가 나옵니다." → 턴 넘김 → 그 주문 줄에 "성사"와 받은 금이 접수 때 견적과 같은지(창고 총합 차이 말고 그 주문 줄로 비교 — 내정 수입이 섞임). 3번 사절 결과도 이때 뜨는지.
5. (쿨다운 끝난 턴에) 상단 **첩보** → 평양 **민심 교란** → 금 **300**이 한성 창고·국가 창고에서 바로 빠지는지.
6. 한성 **모병** → 병력이 늘고 비용이 바로 빠지는지.
7. 상단 **시스템** → **저장** → 턴 하나 넘김 → **불러오기** → 저장할 때로 돌아오는지.
8. 정탐 대상(평양)을 고른 뒤 빈 성(개성) 클릭 → "주인 없음(빈 성)", 첩보 대상 목록에 개성 없음, 평양 기준 행동이 실행되지 않음.
- 조작 안내: 외교·첩보 창의 대상은 **먼저 지도에서 누른 도시**다(창을 연 채 다른 도시를 누르면 대상이 바뀐다). 교역은 **한성을 누른 뒤** 상단 교역 → 주문 창에서 상대·수량 → [확인] → 도시 창 [수동 무역 실행]. 모병은 한성을 누른 뒤 상단 **군사**.

## 9. 남은 문제
- 인사·정보 메뉴는 기존 창이 없어 "준비 중".
- 외교·첩보 창은 대상 도시를 지도에서 먼저 골라야 한다(창 안 도시 목록은 없음).
- 수동 무역은 주문 창 [확인] 뒤 도시 창 [수동 무역 실행]까지 두 번 누른다(기존 흐름 그대로).
- 수동 저장 슬롯은 하나. 자동 체크포인트 슬롯은 따로 계속 쓴다.
- `DiplomacySpyPanel`은 빈 창이라 그대로 숨김 — 지워도 되는지는 HUD 정리 때.
- C-track의 3D 폴더 제외로 C-track 안의 월드맵 시험은 3D가 실제로 그려지지 않는다(3D 확인은 WorldMap3D 작업). 클래스 캐시 소음은 사라졌지만, 3D까지 C-track에서 보려면 워크플로 변경이 필요하다(이번 범위 밖).
- 큐 39·40 보고서는 각 가지의 `[skip ci]` 커밋(`c6ad926`, `32e7fc8`)에 있고, `main` 합류는 그 앞 커밋까지라 빠져 있다.
