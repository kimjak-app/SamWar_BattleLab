기준 화면: 가지 `feature/wm3d-cityhud-20261105`(코드 `936aa78`)에서 `res://WorldMap.tscn`을 열면 좌측 국가 정보창 맨 위에 얇은 손잡이 띠(14px, 가는 금색 선 + 가운데 점 3개, 이동 커서)가 보이고, 그 띠를 끌면 정보창이 화면 안에서 움직인다. 성 안 창이 열려 있으면 따라온다. 위치는 저장하지 않는다.
합격 기준: 지시서 5절 자동 기준 1~7 + C-track 4 shard·`Verify WorldMap3D` success + `worldmap_main.gd` 변경 0줄. 최종 합격은 김작 F6.

# REPORT CITYHUD CH-2c — 좌측 정보창 이동 손잡이 (2026-11-06)

## 요약
- [사실] 새 루트 자식 컨트롤러 `WorldMapLeftPanelGripController`가 좌측 정보창 `MarginContainer/Content`의 첫 자식으로 14px 띠 `LeftPanelGrip`을 넣습니다. 이 띠는 main의 기존 공용 UI 컨트롤러에 손잡이로 하나 더 등록됩니다. 끌기·화면 안 클램프·끌어 둔 위치 기억은 모두 기존 경로(공용 UI → `HudPositionOwner`)를 그대로 씁니다. `worldmap_main.gd` 0줄입니다.
- [사실] 코드 커밋 `936aa78`(시작 `b587d5e`). C-track run `42145335786` success(4 shard), Verify WorldMap3D run `42145335685` success. CI 로그에서 `[LEFT_PANEL_GRIP] checks=28 failures=[]`, `[CITY_INTERIOR] checks=93`, `[CITY_INTERIOR_LAYOUT] checks=93`를 확인했습니다.
- [사실] 정보창 높이는 579에서 599px로 늘었습니다(띠 14px + 기존 VBox 간격 6px). 너비와 내용은 그대로입니다.

## 1. 먼저 확인한 결과 (모두 지시서 [사실]과 일치, 멈춤 없음)
| # | 항목 | 확인 결과 |
|---|---|---|
| 1 | 패널 구조 | `WorldMap.tscn:1333` `LeftWorldStatusPanel`(PanelContainer) → `MarginContainer`(MarginContainer) → `Content`(VBoxContainer). 띠는 `Content`의 첫 자식(`move_child(…, 0)`)으로 넣었습니다. |
| 2 | 공용 손잡이 함수 | `worldmap_shared_ui_controller.gd:27` `register_draggable_panel(panel, handles)`가 손잡이를 STOP으로 두고 `gui_input`에 연결합니다. 누르면 `_on_drag_handle_gui_input`(203행), 움직임은 main `_input`(1104행) → `handle_input` → `move_panel_to_screen_position`(97행)입니다. 1차 클램프는 화면 안에 일부가 보이게 하고, 이어서 `request_panel_position(…, true)` → `HudPositionOwner.request_hud_panel_global_position`이 `_clamp_position`(가장자리 8px)으로 **패널 전체를 화면 안에** 둡니다. |
| 3 | 공용 UI 얻기 | `main.call("_ensure_shared_ui_controller")`로 기존 컨트롤러를 받습니다(main 1231행: 없으면 만들고, 있으면 그대로 돌려줌). CH-2 컨트롤러도 도움말 모달 확인에 같은 호출을 이미 쓰고 있습니다. **main 수정 불필요.** |
| 4 | 위치 되돌림 | 아래 표. 끌어 둔 위치를 되돌리는 경로는 없습니다. 컨트롤러에서 막을 것이 없어 아무것도 하지 않았습니다. |
| 5 | 기본 위치·크기 상수 | `LEFT_WORLD_STATUS_PANEL_TOP_LEFT = (WORLD_UI_LEFT_MARGIN, WORLD_UI_TOP_MARGIN)`, `LEFT_WORLD_STATUS_PANEL_SIZE = (320, 570)`(main 54·55행). 읽기만 했습니다. |
| [미확인]→[사실] | 기존 라벨 손잡이 | `EyebrowLabel`·`CalendarLabel` 둘 다 `worldmap_hud_presentation_controller.gd`의 `LEFT_HIDDEN_CHILDREN`(14행~)에 있어 **숨겨집니다**. 그래서 지금까지는 사실상 잡을 곳이 없었습니다. |

위치 다시 고정 경로 (1절 4항):
| 경로 | 언제 | 끌어 둔 위치에 미치는 영향 |
|---|---|---|
| main `_setup_left_world_status_panel_layout()`(955행) → HUD `setup_world_status_panel` → `_request_hud_panel_position_mvp(panel, 기본 위치)` | main `_ready`에서 1번 | `HudPositionOwner.request_hud_panel_position`이 `_left_has_user_position`이 거짓일 때만 기본 위치를 씁니다. 끌기 전이라 영향 없음. |
| main `_lock_worldmap_fixed_panel_top_margin()`(975행) → `_lock_left_world_status_panel_anchor()`(4860행) | main `_ready`에서 1번 | 위와 같음. |
| `HudPositionOwner.request_layout_refresh()` → `_apply_positions()` | 도시 클릭마다, 화면 크기가 바뀔 때마다(deferred) | 끈 뒤에는 `_left_user_position`(끌어 둔 위치)을 다시 적용합니다. **되돌리지 않음.** |

## 2. 바꾼 것
- 새 `scripts/worldmap/ui/worldmap_left_panel_grip_controller.gd`(+`.uid` `uid://dgk4ismn34a1n`)
  - `main_path` 기본 `..`, 중복 방지 메타 `wm_left_panel_grip_controller`. main이 준비되면(`await main.ready`) 설치합니다.
  - 띠: `Control`, `custom_minimum_size.y = 14`, `MOUSE_FILTER_STOP`, `CURSOR_MOVE`, 툴팁 "끌어서 이동". 그리기는 `draw` 신호로 합니다(아래 가는 선 + 가운데 점 3개, 색 `(0.86, 0.70, 0.38, 0.45)`).
  - `register_draggable_panel(left_world_status_panel, [grip])`. 기존 라벨 손잡이 등록은 건드리지 않았습니다.
  - main에는 `get`·`call`·`has_method`·메타만 씁니다(메타는 CH-2와 같은 방식의 중복 방지 표시).
- `WorldMap.tscn` +4줄: ext_resource 1줄, 빈 줄 1줄, 노드 2줄(`[node …]`, `script = …`). `main_path`는 기본값이라 적지 않았습니다.
- 새 테스트 `tests/scripts/test_worldmap_left_panel_grip.gd`(+`.uid`)와 CI 목록 +1줄(마지막 목록 끝, 인덱스 201 → shard 1. 기존 테스트의 shard 배정은 그대로).

## 3. 로컬 결과 (원문)
```
[LEFT_PANEL_GRIP] checks=28 failures=[]
[CITY_BUILDING_ASSETS] checks=482 failures=[]
[CITY_INTERIOR] checks=93 failures=[]
[CITY_INTERIOR_LAYOUT] checks=93 failures=[]
[WORLDMAP3D_ADAPTER] PASS: 56 checks, 0 failures
[WORLDMAP3D_CAMERA_CONTROLLER] PASS: 61 checks, 0 failures
[WORLDMAP3D_CAMERA_EXTERNAL_INPUT] PASS: 20 checks, 0 failures
[WM3D_COLOR_PARITY] checks=57 failures=[]
[WORLDMAP3D_HOST] PASS: 58 checks, 0 failures
[WM3D_MEM_PROBE] checks=37 failures=[]
[WM3D_PRODUCTION] checks=28 failures=[]
[WM3D_ROADS] checks=121 failures=[]
[DIPLOMACY_ROUTING] PASS: 172 checks, 0 failures
validators=72 pass=72 fail=0   (커밋 뒤)
WorldMap.tscn exit=0 errors=0
WorldMap3D_Host_Test.tscn exit=0 errors=0
WorldMap_UI_Test.tscn exit=0 errors=0
WorldMap_16x9_Test.tscn exit=0 errors=1   (ERROR: 1 resources still in use at exit — CH-2 때부터 있던 것과 같음)
```
- 입력 수명주기 `test_worldmap_to_battle_input_lifecycle.gd`는 CH-2b 보고서 3절과 같이 이 PC에서 22행 오류 뒤 시간 초과입니다. 06 보고서 4절에도 "고치기 전과 같음(PASS 2, 22행, rc=124)"으로 적힌 기존 현상입니다.
- 새 테스트 28개:
  - ⓐ 첫 자식 / 이름·14px / 보임·STOP·이동 커서 / 너비 = Content 너비 / 패널 위쪽 안.
  - ⓓ 두 번째 컨트롤러는 붙지 않음 / 띠 1개 / 첫 컨트롤러가 메타 유지.
  - ⓑ 띠를 (120, 80) 끌면 패널이 그만큼 이동 / 왼쪽 위로 멀리 끌어도 화면 안 / 오른쪽 아래로 멀리 끌어도 화면 안.
  - ⓒ CalendarLabel 손잡이 등록 유지 / 그 손잡이로 끌어도 이동 / 원래 자리로 복귀.
  - ⓔ 성 안 창이 열린 채 띠를 끌면 창이 좌측 패널 오른쪽 12px로 따라옴.
  - ⓕ 3D 지도 보기로 바꾼 뒤 같은 띠 1개, 같은 끌기 검사 7개.
  - [사실] 3D 보기는 로컬과 CI 모두에서 켜졌습니다(둘 다 28개, "3d map view not available" 줄 없음).
  - 끌기는 띠의 `gui_input`에 누름 이벤트를 넣고(GUI가 주는 것과 같은 경로), 움직임·뗌은 `root.push_input`으로 main `_input`에 보냅니다.

## 4. 스샷
- [사실] 창 있는 Godot, 1920×1080, 한성을 연 화면: `C:\eastwar_tmp\cityhud_shots\CH2C_left_panel_grip_1920x1080.png`
- 띠 위치는 `(63, 168.5)`, 크기 `290×14`, 첫 자식입니다. 좌측 패널 `(48, 155.5)` 크기 `320×599`, 성 안 창은 `(380, 155.5)`입니다.

## 5. 택한 해석
1. 지시서 6절의 "`WorldMap.tscn`(+2줄)"은 CH-2와 같은 형태(ext_resource 1 + 노드 1)로 읽었습니다. 노드 블록이 머리줄과 `script` 줄 2줄이고 그 앞에 빈 줄이 있어서 실제로는 +4줄입니다(CH-2는 `main_path` 줄까지 +5).
2. 1절 4항에서 되돌리는 경로가 없어서 2절 4항(막는 처리)은 할 것이 없었습니다.
3. 띠는 `MarginContainer` 안이라 패널 테두리에서 약 13px 안쪽에 그려집니다(지시서 1절 1항의 위치).

## 6. 김작 F6 확인 방법
1. `WorldMap.tscn` F6 → 좌측 정보창 맨 위의 점 3개 띠에 마우스를 올리면 이동 커서가 뜨는지.
2. 띠를 끌어 정보창을 옮기고, 화면 끝으로 끌어도 화면 밖으로 안 나가는지.
3. 한성을 눌러 성 안 창을 연 채 띠를 끌면 창이 정보창 오른쪽에 붙어 따라오는지.
4. 옮긴 뒤 다른 도시를 클릭해도 정보창이 옮긴 자리에 그대로 있는지(다시 실행하면 기본 위치).

## 7. 다음
큐 15번 `ORDER_WM3D_PERF_CSV_READ_20261106.md`(읽기 전용).
