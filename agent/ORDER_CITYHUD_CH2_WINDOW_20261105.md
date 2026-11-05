기준 화면: 정본이 아닌 작업 가지 `feature/wm3d-cityhud-20261105`(시작점 = 그 가지 끝 `ef509c1`)에서 `res://WorldMap.tscn` F6 → 내 도시를 클릭하면 도시 패널이 갱신되고 **성 안 창(빈 틀)**이 열린다. 적 도시·외교/첩보/무역/공격 대상 고르는 중·전투 진입 연출 중에는 열리지 않는다. 창은 닫기 버튼과 Esc로 닫히고, 열려 있는 동안 지도(3D·2D)로 클릭·키 입력이 새지 않는다. 아직 건물 그림은 없다.
합격 기준: 자동 테스트(새 테스트 + CI 등록) 전부 통과, `worldmap_main.gd` 변경 0줄, 변경 경로가 5절 목록 안, C-track 4 shard success. 김작 F6는 오늘 밤이 아니라 **CH-4 뒤 한 번에**(이 단계는 자동 검증으로 넘어간다).

# 지시서 — CITYHUD CH-2: 성 안 창 틀과 열기 조건 (main 0줄)

- 작성: 클코치, 2026-11-05 20:25 / 김작 결정(11-05 19:13): 도시를 누르면 **내 도시일 때 자동으로 열리게**, main에 넣지 않고 테크트리·외교처럼 **따로 붙인다**. 근거 감사: `agent/REPORT_AUDIT_CITYHUD_20261105.md` 1-1·1-6·1-7, CH-1 보고서(`REPORT_CITYHUD_CH1_20261105.md`).
- 확정된 것: Q1 자동 열기(내 도시 + 대상 고르는 중 아님) + "성 안 보기" 버튼은 보험(아래 2-5), Q4 카라코룸(몽골)은 그림 세트가 없으므로 열지 않음, Q2 에셋 폴더 허가는 CH-1에서 사용됨.
- [사실, 클코치가 11-05 20:20 정본 `worldmap_main.gd`에서 확인] `_on_city_marker_selected`(1395행)가 `city_marker.city_selected`를 받아 도시 패널을 갱신. 같은 신호를 다른 노드가 따로 받을 수 있다. 밖에서 부를 수 있는 함수: `_is_city_owned_by_player_mvp(city_id)`(6242행), `_is_domestic_tech_tree_overlay_open_mvp()`(8788행). "대상 고르는 중" 후보 값(main 비공개 변수): `_pending_diplomacy_action_id`(748), `_pending_spy_action_id`(749), `_pending_trade_action_id`(750), `_contextual_worldmap_action_pending`(721), `_player_attack_deployment_panel`(819), 그 밖 `_pending_invasion_*`(803~806), `_enemy_turn_mvp_pending`(823), `_domestic_turn_apply_pending`(828). **이 목록이 충분한지는 [미확인]** → 1절에서 확인한다.

## 0. 규칙
1. 시작 전 `git status` 깨끗, `git fetch origin`, `git switch feature/wm3d-cityhud-20261105`(원격 끝이 `ef509c1`인지 확인; 아니면 멈춤). **이 가지에 이어서 커밋**한다(새 가지 아님). push 대상은 이 가지뿐. 정본 가지·`main`·`integration/*`·`work/*`·열린 PR 가지 금지, force·삭제 금지, `gh` 읽기만.
2. 수정·추가 경로는 5절 목록이 전부. `scripts/worldmap/worldmap_main.gd`·`worldmap3d/` 수정 금지(핀). 목록 밖이 필요하면 멈추고 보고(`agent/REPORT_CITYHUD_CH2_STOP_20261105.md`).
3. 코드 커밋 → CI → 보고서 커밋(`[skip ci]`). 보고서 `agent/REPORT_CITYHUD_CH2_20261105.md`는 이 가지에만. 정본 `PROGRESS_WM3D.md` 수정 금지.
4. 확인 질문 없이 진행한다(큐 10절). 지시서의 [사실]과 실제 코드가 다르면 추정하지 말고 STOP 보고서.

## 1. 먼저 읽기 전용 확인 (보고서 표로)
1. **"대상 고르는 중"의 완전한 목록**: main에서 도시 클릭이 "선택"이 아니라 **대상 지정**으로 쓰이는 모든 경로(`rg`로 `_on_city_marker_selected` 뒤의 분기, `_contextual_worldmap_action_*`, 외교·첩보·무역·공격 배치·파병·증원 등)를 찾아, 그 상태를 나타내는 변수·함수를 표로. 위 후보 8개가 전부 필요한지, 더 필요한지. 이 표의 이름들은 7절 테스트가 "존재한다"를 검사한다.
2. **도시 클릭 처리 순서**: main의 `_on_city_marker_selected`와 3D 선택 경로(어댑터 `worldmap_3d_adapter.gd:93-100`, `worldmap3d_root.gd:602-606`)를 따라, 새 컨트롤러가 같은 신호를 받을 때 main이 **먼저** 처리되도록 연결하는 방법(`CONNECT_DEFERRED` 등)과 검증 방법.
3. **붙이는 자리**: `WorldMap.tscn`의 `WorldMap3DHost`(2343행 근처)처럼 루트 자식 노드 1개로 붙이면 main 없이 되는지, 컨트롤러가 main을 찾는 방법(호스트의 `main_path` 방식 참고), `WorldMap_16x9_Test.tscn`·`WorldMap_UI_Test.tscn`·`WorldMap3D_Host_Test.tscn`에도 같이 들어가는 영향.
4. **입력 차단 수단**: 3D 카메라(`WorldMap3DCamera.external_input`/컨트롤러의 입력 차단, 03-2·03-3), 2D 카메라 키 가드(03-1), 마우스 클릭이 지도로 새지 않게 하는 방법(창 뒤에 전체 화면 투명 `Control`, `mouse_filter = STOP`)을 코드에서 찾아 쓴다. 새 메커니즘을 만들지 말고 기존 것을 쓴다.
5. **HUD 빈 자리와 레이어**: 기존 HUD·패널(`WorldMap.tscn`의 `CanvasLayer`·`z_index`·`layer` 값)의 층 번호와 차지하는 영역을 표로. 새 창의 `CanvasLayer.layer`(감사 제안 45~55)가 기존 창들과 겹치지 않는 값, "성 안 보기" 버튼을 둘 **빈 자리**(좌표·앵커)가 있는지.
6. **Esc 처리 충돌**: 기존 Esc 사용처(전투 진입 건너뛰기, 테크트리 오버레이 닫기, 외교 창 닫기, 3D 입력칸 해제 등)를 목록으로. 새 창이 열려 있을 때만 Esc를 먹고(`set_input_as_handled`), 닫힌 뒤에는 기존 동작이 그대로여야 한다.

## 2. 구현
### 2-1. 컨트롤러 `scripts/worldmap/ui/worldmap_city_interior_controller.gd` (새)
- `class_name WorldMapCityInteriorController extends Node`. main을 **타입으로 알지 않는다**(`Node`로 받고 `get()`/`call()` 사용). `WorldMap3D*` 클래스 참조 금지(문자열 경로로만).
- 시작 시 main이 준비될 때까지 기다린 뒤(호스트의 `await main.ready` 방식 참고) 마커 전부의 `city_selected`를 연결(중복 연결 방지, `is_connected`).
- 열기 조건(**모두** 만족할 때만, 순서대로 검사, 이유를 `last_reject_reason` 문자열로 남겨 테스트가 읽게 함):
  1. `main._is_city_owned_by_player_mvp(city_id)`가 true
  2. 1절 1번에서 확정한 "대상 고르는 중" 변수들이 모두 비어 있음/꺼져 있음
  3. 도시 지역 키로 `WorldMapCityBuildingAssets.region_style_for_region_key`가 비어 있지 않음(카라코룸 → 열지 않음, 이유 `no_art`)
  4. 전투 진입 연출 중이 아님(`_ensure_camera_controller().is_battle_entry_handoff_in_progress()` false)
  5. 테크트리 오버레이 등 모달이 열려 있지 않음(`_is_domestic_tech_tree_overlay_open_mvp()` false, 그 밖 1절 1번 결과)
- 이미 열린 창에서 같은 도시를 다시 눌러도 다시 열지 않음. 다른 내 도시를 누르면 내용만 갱신(헤더의 도시 이름).
- 창이 열려 있는 동안 도시 선택이 **main 상태를 바꾸지 않아야 한다**: 컨트롤러는 main의 변수를 쓰지 않는다(읽기만). 테스트가 `selected_city_id` 불변을 확인.

### 2-2. 창 (코드로 만든다, `.tscn` 새로 만들지 않음)
- `CanvasLayer`(1절 5번 값) 아래: ① 전체 화면 투명 `Control`(`mouse_filter = STOP`, 클릭이 지도로 새지 않게) ② 가운데 `PanelContainer`: 위쪽에 "도시 이름 — 성 안", 오른쪽 위 `닫기` 버튼, 가운데는 **빈 영역**(후속 CH-3·CH-4가 그림을 올릴 자리, 안내 글 "건물 그림은 다음 단계에서 연결됩니다"만).
- 닫기: 버튼, Esc, 창 밖(투명 `Control`) 클릭은 닫지 않는다(실수 방지). 닫은 뒤 같은 도시를 다시 누르면 다시 열린다(2-1과 모순 아님: 닫힌 상태에서만).
- 열릴 때 3D 카메라 입력·2D 카메라 키 입력을 차단하고, 닫힐 때 **반드시** 풀어준다(창이 열린 채 도시가 바뀌거나 장면이 해제될 때도 `_exit_tree`에서 풀기). 차단을 두 번 걸거나 풀지 않는 일이 없게 한 번에 하나만(참조 카운트 금지, 불리언 하나).

### 2-3. 붙이기
- `WorldMap.tscn`에 루트 자식 노드 1개 추가(`WorldMap3DHost`와 같은 방식, ext_resource 1 + 노드 1). 컨트롤러 스크립트가 없으면(모바일·테스트 환경) 노드가 아무것도 하지 않도록 방어. 지시서 1절 3번 결과에 따라 필요하면 호스트가 대신 만들어도 된다(더 작은 변경 쪽).

### 2-4. 3D·2D 공통
- 2D 설정(`user://samwar_worldmap3d.cfg` `map_view="2d"`)에서도 같은 조건으로 열린다(허드창은 3D 전용이 아님).

### 2-5. "성 안 보기" 버튼 (보험)
- 1절 5번에서 **빈 자리**가 확인되면, 컨트롤러 자신의 `CanvasLayer`에 작은 버튼 1개("성 안 보기")를 둔다. 내 도시가 선택돼 있고 창이 닫혀 있을 때만 보이고, 누르면 열기 조건 1·3·4·5를 같은 함수로 검사해 연다(2번 "대상 고르는 중"은 무시하지 않음). 빈 자리가 없으면 **버튼을 만들지 말고** 보고서에 "빈 자리 없음, 좌표 후보"만 적는다(HUD를 겹치지 않는다).

## 3. CI 등록 (워크플로 수정은 이 단계에서만 허용)
- CH-1의 `tests/scripts/test_worldmap_city_building_assets.gd`가 C-track 고정 목록에 없어 CI에서 안 돈다(CH-1 보고서). `.github/workflows/verify-c-track.yml`의 테스트 목록 구조를 읽고 **이 테스트와 이번 새 테스트를 같은 방식으로 추가**한다(가장 가벼운 shard 하나, 기존 항목은 건드리지 않음, 목록 위치·shard 균형 근거를 보고). shard 시간이 `timeout 300s`를 넘기지 않는지 로컬 시간으로 확인.

## 4. 새 테스트 `tests/scripts/test_worldmap_city_interior_window.gd`
결과 줄 `[CITY_INTERIOR] checks=N failures=[]`. 실제 `WorldMap.tscn`을 인스턴스해서(3D 설정 로드 없이 2D 설정 기준, 필요하면 호스트 테스트 장면으로 3D도 한 경우):
1. **열기 조건 표**: 내 도시 → 열림 / 적 도시 → 안 열림(`last_reject_reason`) / 카라코룸(내 도시로 설정해도) → `no_art` / 각 "대상 고르는 중" 변수를 하나씩 켠 경우(1절 1번 목록 전부) → 안 열림 / 전투 진입 연출 중 → 안 열림 / 테크트리 오버레이 열림 → 안 열림.
2. **main 불변**: 열고 닫은 뒤 `selected_city_id`, `_player_state`의 핵심 키(선택 도시, 출발 도시)가 컨트롤러 때문에 바뀌지 않음.
3. **닫기**: 버튼·Esc로 닫힘, Esc는 열려 있을 때만 소비(닫힌 상태에서 Esc가 이 컨트롤러에 먹히지 않음), 닫힌 뒤 카메라 입력 차단이 풀림.
4. **입력 차단**: 열린 동안 3D 카메라 외부 입력이 차단 상태, 닫힌 뒤 해제. 장면 해제 때도 해제(`_exit_tree`).
5. **비공개 이름 존재 검사**: 1절 1번 표의 main 변수·함수 이름이 지금도 `main`에 존재(바뀌면 이 검사가 실패해 알린다).
6. **중복 방지**: 같은 신호 중복 연결 0, 같은 도시 재클릭 시 창 1개, 다른 도시로 갱신.
7. 고치기 전(컨트롤러 없음) 실패하는 것을 한 번 확인한 기록.

## 5. 수정·추가 가능 경로 (이 목록이 전부)
1. `scripts/worldmap/ui/worldmap_city_interior_controller.gd` (+ `.uid`)
2. `WorldMap.tscn`
3. `tests/scripts/test_worldmap_city_interior_window.gd` (+ `.uid`)
4. `.github/workflows/verify-c-track.yml` (3절의 목록 추가만)
5. `agent/REPORT_CITYHUD_CH2_20261105.md` (보고서 커밋)
(호스트가 만들도록 바꾸는 것이 더 작다고 1절 3번이 판단하면 `scripts/worldmap/map3d/worldmap_3d_host.gd`와 `tests/scripts/test_worldmap3d_host.gd`를 추가로 허용, 이유를 보고.)

## 6. 로컬 검증 (결과 줄 원문을 표로)
1. 새 테스트(고치기 전 실패 → 후 통과), CH-1 테스트 482 유지.
2. 정적 검증기 72/72(커밋 뒤 깨끗한 트리; `WorldMap.tscn` 변경으로 `validate_worldmap_trade_phase2_extraction.py`가 작업 트리에서 실패하는 것은 알려진 구조, 커밋 뒤 통과 확인).
3. 기존 3D 테스트 8종 + 호스트 58·프로덕션 28 변화 없음. 2D 설정의 기존 `WorldMap.tscn` 테스트 3개(roundtrip 28, diplomacy 131, lifecycle는 M7-0b 가지에서 따로)가 변화 없음.
4. `WorldMap.tscn`·`WorldMap3D_Host_Test.tscn` `--quit-after 5` 오류 줄 0.
5. `git status --short`이 5절 목록 안, `git diff --check`, `git diff --stat`에 `worldmap_main.gd`·`worldmap3d/` 0.

## 7. 커밋·push·CI
1. 커밋 1: `feat(worldmap): city interior window frame opens on own-city click, attached outside main (CITY-HUD CH-2)`
2. push `feature/wm3d-cityhud-20261105`, 원격 해시 = 로컬 HEAD. `gh run watch`로 `Verify C-track refactor`(4 shard)·`Verify WorldMap3D` 결과(경로 조건에 안 걸리면 "실행 안 됨" + 로컬 결과 첨부), 컷인 예외는 큐 4절 1번.
3. 보고서 커밋(`[skip ci]`).

## 8. 보고서
맨 위 "기준 화면 / 합격 기준" 두 줄, 3줄 요약, "택한 해석", 1절 표(특히 "대상 고르는 중" 완전 목록·Esc 사용처), 6절 결과 표, diff 전체, CI 표, 막힌 것, **김작 F6 안내(CH-4 뒤 한 번에 쓸 것)**: ① 한성 클릭 → 창 열림·도시 패널 갱신 ② 적 도시·카라코룸 클릭 → 안 열림 ③ 외교·무역 대상 고르는 중 클릭 → 안 열림 ④ 열린 동안 지도 클릭·휠·WASD 무반응 ⑤ 닫기·Esc 후 정상 ⑥ 2D 설정에서도 같음. 종료 루틴 5줄.

## 9. 하지 않는 것
- `worldmap_main.gd`·`worldmap3d/` 수정, 건물 그림 표시·슬롯·테크 연결(CH-3·CH-4), 워크플로의 3절 외 수정, HUD 겹쳐 놓기, 새 입력 차단 메커니즘 발명, 새 폴더, 정본 가지 push, 재실행으로 때우기.
