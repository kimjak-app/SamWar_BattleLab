기준 화면: 가지 `feature/wm3d-cityhud-20261105`(CH-2b 위)에서 `res://WorldMap.tscn`을 열면 좌측 국가 정보창(`LeftWorldStatusPanel`) 맨 위에 **보이는 얇은 손잡이 띠**(가로 전체, 높이 약 14px, 점 3개 표시, 마우스를 올리면 이동 커서)가 있고, 그 띠를 끌면 정보창이 화면 안에서 움직인다. 성 안 창이 열려 있으면 CH-2b 규칙대로 따라온다. 위치는 저장하지 않는다(실행할 때마다 기본 위치).
합격 기준: 지시서 5절 자동 기준 + C-track 4 shard·`Verify WorldMap3D` success + `worldmap_main.gd` 변경 0줄. 최종 합격은 김작 F6(좌측 정보창 위 띠를 끌어 옮기고, 성 안 창이 따라오는지).

# ORDER_CITYHUD_CH2C — 좌측 정보창 이동 손잡이 (클코치 작성, 2026-11-06)

## 0. 배경·효력
- 김작(11-06 09:15~09:18): 좌측 정보창이 사실상 고정이라 움직일 수 있어야 한다. 손잡이는 **맨 위 얇은 띠**(클코치 추천 채택). 위치 저장은 이번엔 하지 않음.
- 클코치가 코드로 본 [사실]: main이 `shared_ui.register_draggable_panel(left_world_status_panel, [left_world_status_eyebrow_label, calendar_label])`로 등록해 두었지만 손잡이가 안쪽 라벨 2개뿐이고, 스샷에서는 보이지 않아 사실상 못 잡는다. [미확인] 그 라벨이 숨겨졌는지.
- 큐 규칙 그대로. 가지 `feature/wm3d-cityhud-20261105`에 이어서 커밋. **`worldmap_main.gd` 수정 0.** CH-2 컨트롤러처럼 `WorldMap.tscn` 루트 자식 노드 1개 + 새 스크립트로 붙인다.

## 1. 먼저 읽기 전용으로 확인 (보고서에, 하나라도 다르면 멈춤)
1. `WorldMap.tscn:1333` `LeftWorldStatusPanel`은 `PanelContainer`다 → 자식으로 `Control`을 그냥 넣으면 패널 전체를 덮도록 늘어난다. 그래서 띠는 `MarginContainer/Content`(VBox)의 **첫 자식**(`move_child(…, 0)`, 높이 14 `custom_minimum_size`)으로 넣는다. 실제 노드 구조·타입을 읽어 확인.
2. `scripts/worldmap/ui/worldmap_shared_ui_controller.gd`의 `register_draggable_panel(panel, handles)`(27행)는 공개 함수: 손잡이 `Control`의 `mouse_filter`를 STOP으로 하고 `gui_input`에 연결한다. 이동은 `move_panel_to_screen_position`. 화면 밖으로 못 나가게 막는지(클램프) 확인.
3. main이 공용 UI 컨트롤러를 어떻게 주는지(`_ensure_shared_ui_controller()`는 main 안 함수) 읽기 전용으로 얻는 방법: `main.call("_ensure_shared_ui_controller")`로 부를 수 있는지, 아니면 `main.get(...)` 멤버가 있는지. **main을 고치지 않고는 못 얻으면 멈춤.**
4. `_lock_left_world_status_panel_anchor()` → `_ensure_hud_controller().setup_world_status_panel(…)`(main 4860행)과 `_request_hud_panel_position_mvp`가 창 크기 변경·갱신 때 좌측 패널 위치를 **다시 고정**하는지. 다시 고정하면 끌어 둔 위치가 되돌아간다 → 어느 경로가 언제 돌리는지 표로 보고서에(고치는 방법이 컨트롤러 안에서 가능한지 포함).
5. 기본 위치와 크기 상수(`LEFT_WORLD_STATUS_PANEL_TOP_LEFT`, `…_SIZE`)는 읽기만.

## 2. 해야 할 일
1. 새 스크립트 `scripts/worldmap/ui/worldmap_left_panel_grip_controller.gd`(+`.uid`): `main_path` 기본 `..`, CH-2 컨트롤러와 같은 방식으로 main이 준비된 뒤 붙고 중복 방지 메타(`wm_left_panel_grip_controller`)를 둔다. main에는 읽기(`get`/`call`)만, 쓰기 없음.
2. 띠: 높이 14px `Control`, 코드로 그린다(`_draw`: 가는 구분선 + 가운데 점 3개, 색은 기존 패널 테두리 금색 계열 낮은 불투명도), `mouse_default_cursor_shape = CURSOR_MOVE`, `mouse_filter = STOP`, 이름 `LeftPanelGrip`. 기존 안쪽 라벨 손잡이 등록은 건드리지 않는다.
3. 띠를 공용 UI 컨트롤러에 손잡이로 등록(`register_draggable_panel(left_world_status_panel, [grip])`). 끌기·클램프는 공용 컨트롤러 기능을 그대로 쓴다.
4. 1절 4항에서 "다시 고정"이 끌어 둔 위치를 되돌리면, 컨트롤러 안에서 막을 수 있는 방법(예: 끌린 뒤에는 그 호출을 건드리지 않음)이 **main 수정 없이** 가능하면 적용, 아니면 멈춤.
5. `WorldMap.tscn`에 ext_resource 1줄 + 노드 1개(CH-2 방식과 같은 형태)만 추가.
6. 새 테스트 `tests/scripts/test_worldmap_left_panel_grip.gd`(+`.uid`) + CI 목록 한 줄: ⓐ 띠가 존재하고 패널 맨 위 첫 자식, 높이 14 ⓑ 띠를 끌면(`gui_input` 마우스 이벤트 시뮬레이션) 패널 위치가 바뀌고 화면 밖으로 안 나감 ⓒ 기존 라벨 손잡이도 여전히 동작 ⓓ 중복 컨트롤러 생성 없음 ⓔ CH-2b 창이 열려 있을 때 패널을 끌면 창이 따라옴 ⓕ 2D·3D 지도 설정 모두에서 같은 결과(가능하면).

## 3. 하지 말 것
- `worldmap_main.gd`·씬(`WorldMapUI` 안 노드 구조)·공용 UI 컨트롤러·HUD 컨트롤러 수정 금지. 위치 저장 금지. 패널 크기·내용 변경 금지(띠 14px 추가분 제외).
- 다른 패널(우측 도시 패널 등)에 손잡이 추가 금지(김작이 따로 정함).

## 4. 로컬 검증
CH-1 482 · CH-2·CH-3(갱신된 CH-2b 기준) · 새 테스트 · 3D 월드맵 8종 · 입력 수명주기 · 검증기 전부. 창 있는 Godot 스샷 1장(띠가 보이는 좌측 패널, 1920×1080).

## 5. 자동 기준
1) 띠가 보이고 첫 자식 2) 끌면 이동·클램프 3) 기존 손잡이 유지 4) 중복 없음 5) CH-2b 창이 따라옴 6) `worldmap_main.gd` 0줄, 기존 검사 약화 0 7) CI success.

## 6. 수정·추가 경로 (이 밖은 멈춤)
`scripts/worldmap/ui/worldmap_left_panel_grip_controller.gd`(+`.uid`), `WorldMap.tscn`(+2줄), `tests/scripts/test_worldmap_left_panel_grip.gd`(+`.uid`), `.github/workflows/verify-c-track.yml`(+1줄), `agent/REPORT_CITYHUD_CH2C_20261106.md`.

## 7. 멈춤 조건 (큐 4절 외)
- 1절 3·4항에서 main 수정 없이는 불가능하다고 나올 때(그 경우 필요한 main 변경 줄을 보고서에만 적는다. main 변경은 M7-3의 pin 재고정 묶음과 같이 김작 승인).
- 띠가 `PanelContainer` 레이아웃을 깨뜨려 기존 테스트가 실패할 때.

## 8. 보고서
`agent/REPORT_CITYHUD_CH2C_20261106.md`(`[skip ci]`), 맨 위 두 줄, 1절 확인 결과 표, 로컬 결과 원문, 스샷 경로, **김작 F6 방법**.
