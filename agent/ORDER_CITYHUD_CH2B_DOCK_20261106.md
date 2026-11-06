기준 화면: 가지 `feature/wm3d-cityhud-20261105`(끝 `ced058f`)에서 `res://WorldMap.tscn`을 열고 내 도시(한성 등)를 누르면, 성 안 창이 화면 가운데가 아니라 **좌측 국가 정보창(`left_world_status_panel`)의 오른쪽 옆, 윗변을 정보창 윗변에 맞춰** 작게 뜬다(가로 = 화면 가로의 약 30.7%, 1877px 화면에서 약 576px, 비율 1280:768 유지). 창이 떠 있어도 지도는 보이고, 지도 드래그·휠·다른 도시 클릭이 된다. 캔버스 안의 건물 배치(CH-3)는 그대로다.
합격 기준: 지시서 5절 자동 기준 1~8 + C-track 4 shard·`Verify WorldMap3D` success + `worldmap_main.gd` 변경 0줄. 최종 합격은 김작 F6(스샷 한 장: 한성을 눌렀을 때 창 위치·크기와 지도 클릭).

# ORDER_CITYHUD_CH2B — 성 안 창을 좌측 정보창 옆에 붙이기 (클코치 작성, 2026-11-06)

## 0. 배경·효력
- 김작 F6(11-06 09:08): 지금 창은 가운데 960×600 모달이라 지도 전체가 가려지고 클릭도 막힌다. 김작 확정(09:11~09:13): **좌측 국가 정보창 오른쪽에 붙이고, 크기는 640의 90%(576)로 시작**, 값은 상수 하나로 쉽게 바꿀 수 있게.
- 이건 클코치가 CH-2 지시서에 "가운데 + 전체 화면 차단막"으로 적은 것의 정정이다(위치는 김작이 미정이었음).
- 큐 규칙 그대로. 가지 `feature/wm3d-cityhud-20261105`에 이어서 커밋. `worldmap_main.gd`·`worldmap3d/`·엔진·데이터·그림 파일 수정 금지.

## 1. 먼저 읽기 전용으로 확인 (보고서에)
클코치가 `ced058f`의 `worldmap_city_interior_controller.gd`로 본 [사실]이다. 다르면 멈춤.
1. `_ensure_window()`(약 300행): `CanvasLayer`(layer 50) → `InputBlocker`(전체 화면, `MOUSE_FILTER_STOP`) → `Window`(`PanelContainer`, `PRESET_CENTER`, `WINDOW_SIZE = Vector2(960, 600)`) → `VBox` → 헤더(제목, 닫기) + `InteriorArea`(`clip_contents`, `resized → apply_canvas_transform`).
2. `try_open`이 `_block_camera_input()`으로 3D 카메라의 `input_blocked`를 켜고(키보드 축), `close`·`_exit_tree`에서 푼다. 2D 카메라에는 그 플래그가 없다.
3. 좌측 정보창은 main의 `left_world_status_panel`(`$WorldMapUI/LeftWorldStatusPanel`, 드래그 가능 — `shared_ui.register_draggable_panel`), 우측 도시 패널은 `city_info_panel_control`(`$WorldMapUI/CityInfoPanel`). 둘 다 main 멤버라 `main.get("left_world_status_panel")`로 읽기만 한다.
4. `_on_city_selected` → `try_open(city_id)`; 거절 사유는 `last_reject_reason`("not_own_city", "already_open", "busy:…" 등).

## 2. 해야 할 일 (컨트롤러 `worldmap_city_interior_controller.gd` 안에서만)
1. **차단막 제거**: `InputBlocker` 전체 화면 컨트롤을 없앤다(창 `Window`가 `_layer`의 직접 자식). 창 자신은 클릭을 먹고(`PanelContainer` 기본), 창 밖 입력은 지도로 간다.
2. **카메라 입력 차단 제거**: 모달이 아니므로 `_block_camera_input()`/`_unblock_camera_input()` 호출과 관련 필드를 제거(`_exit_tree`의 정리 호출도 함께). 키보드 이동·휠·드래그가 창이 떠 있어도 동작해야 한다.
3. **위치·크기**(상수, 파일 위쪽):
   - `WINDOW_WIDTH_RATIO := 0.307`(화면 가로 대비 창 가로), `DOCK_GAP := 12.0`, `MIN_WINDOW_WIDTH := 400.0`, `BODY_ASPECT := 768.0 / 1280.0`.
   - 창 가로 `w = clamp(viewport_w * WINDOW_WIDTH_RATIO, MIN_WINDOW_WIDTH, …)`, 본문 높이 `w * BODY_ASPECT`(+헤더). `InteriorArea.custom_minimum_size`로 본문 비율을 고정해 CH-3 캔버스 배율 `k`가 `w/1280`이 되게 한다. 기존 `WINDOW_SIZE` 상수는 삭제.
   - 위치: x = `left_world_status_panel.get_global_rect().end.x + DOCK_GAP`, y = 그 패널 `position.y`. 좌측 패널이 없거나 숨김이면 x = 12, y = 12.
   - 우측 도시 패널(`city_info_panel_control`)이 보이고 창이 겹치면(창 오른쪽 끝 > 그 패널 왼쪽 − `DOCK_GAP`) 가로를 사용 가능한 폭으로 줄이되 `MIN_WINDOW_WIDTH` 밑으로는 줄이지 않는다. 그래도 겹치면 그대로 둔다(해상도 대응은 M6).
   - 열려 있는 동안 좌측 패널을 드래그하면 창이 따라온다: `_process`에서 열려 있을 때만 위 계산을 다시 하고 위치·크기가 바뀐 경우에만 반영한다. 뷰포트 크기 변경에도 같은 계산.
4. **동작**: ESC·닫기 그대로. 이미 열린 상태에서 **다른 내 도시**를 누르면 창이 그 도시로 바뀐다(기존). **내 도시가 아닌 곳**(적 도시 등)을 누르면 `last_reject_reason == "not_own_city"`일 때 열려 있던 창을 닫는다. 같은 도시를 다시 누르면 아무 일 없음(기존 `already_open`).
5. 갱신: 위 변경으로 CH-2 테스트 `test_worldmap_city_interior_window.gd`의 "차단막/카메라 `input_blocked`/중앙 위치/960×600" 기대, CH-3 `test_worldmap_city_interior_layouts.gd`의 창 크기에서 나오는 `k` 기대만 **새 규칙으로 바꾼다**. 새 검사: ⓐ 창이 좌측 패널 오른쪽에 붙음(위치 오차 1px) ⓑ 창 가로 = 비율·최소값 규칙 ⓒ 창이 떠 있을 때 `InputBlocker`가 없고 3D 카메라 `input_blocked`가 거짓 ⓓ 좌측 패널을 옮기면 창이 따라옴 ⓔ 우측 패널과 겹치면 줄어들되 `MIN_WINDOW_WIDTH` 이상 ⓕ 적 도시 선택 시 닫힘 ⓖ 닫으면 텍스처가 풀림(기존 검사 유지).

## 3. 하지 말 것
- 건물 배치 데이터(`city_layouts.json`)·그림·`worldmap_city_interior_layouts.gd` 수정 금지(캔버스 변환 함수 `canvas_transform`은 읽기만).
- 창을 드래그 가능하게 만들기, 애니메이션, 크기 조절 손잡이 등 새 기능 금지(필요하면 보고서에 제안만).
- 기존 검사를 지우거나 약화 금지(위치·차단막처럼 **규칙이 바뀐 검사만 새 규칙으로 교체**하고 교체 전후를 보고서 표에).

## 4. 로컬 검증 (결과 줄 원문을 보고서에)
CH-1 482 · CH-2(갱신 후) · CH-3(갱신 후) · 3D 월드맵 8종 · 입력 수명주기 · 검증기 전부. 그리고 **창 있는 Godot로 한성을 연 스샷 1장**(1920×1080, 좌측 패널·창·우측 패널이 한 화면에 보이는 것)을 보고서에 경로로 남긴다.

## 5. 자동 기준 (합격)
1) 창이 좌측 패널 오른쪽·윗변 정렬 2) 가로 규칙(비율·최소값) 3) 차단막 없음, 지도 입력 통과 4) 3D 카메라 입력 차단 안 함 5) 좌측 패널 드래그 따라옴 6) 우측 패널과 겹치면 줄어듦(최소 400) 7) 적 도시 선택 시 닫힘 8) CH-3 배치 검사(93개)와 CH-1·CH-2 나머지 검사 모두 통과.

## 6. 수정·추가 경로 (이 밖은 멈춤)
`scripts/worldmap/ui/worldmap_city_interior_controller.gd`, `tests/scripts/test_worldmap_city_interior_window.gd`, `tests/scripts/test_worldmap_city_interior_layouts.gd`, 필요 시 CH-2·CH-3 테스트가 쓰는 보조 파일, `agent/REPORT_CITYHUD_CH2B_20261106.md`. 검증기·워크플로는 필요하면 한 줄 이내로만(보고서에 이유).

## 7. 멈춤 조건 (큐 4절 외)
- `left_world_status_panel`·`city_info_panel_control`을 main에서 읽을 수 없을 때(이름이 다름) — 추정하지 말고 보고.
- 기존 검사를 약화해야 할 때, 6절 밖 수정이 필요할 때.
- 창이 떠 있을 때 지도 클릭·드래그가 실제로 안 통과하는 이유가 컨트롤러 밖(main/3D 어댑터)에 있을 때: 고치지 말고 원인만 보고서에.

## 8. 보고서
`agent/REPORT_CITYHUD_CH2B_20261106.md`(`[skip ci]`), 맨 위 두 줄. 요약 3줄, 로컬 결과 원문, 테스트 교체 전후 표, 스샷 경로, 택한 해석, **김작 F6 확인 방법**(어느 도시를 눌러 무엇을 볼지). 끝나면 큐를 다시 읽는다(다음은 M7-2).
