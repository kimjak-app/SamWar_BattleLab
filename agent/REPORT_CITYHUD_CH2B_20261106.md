기준 화면: 가지 `feature/wm3d-cityhud-20261105`(코드 `ab65ef0`)에서 `res://WorldMap.tscn`을 열고 한성을 누르면, 성 안 창이 좌측 국가 정보창 오른쪽 12px 옆에 윗변을 맞춰 뜬다(1920 화면에서 가로 589px, 본문 1280:768). 창 밖의 지도 드래그·휠·다른 도시 클릭이 그대로 된다.
합격 기준: 지시서 5절 자동 기준 1~8 + C-track 4 shard success(`Verify WorldMap3D`는 경로 조건으로 미실행, 로컬 3D 8종으로 대신) + `worldmap_main.gd` 변경 0줄. 최종 합격은 김작 F6.

# REPORT CITYHUD CH-2b — 성 안 창을 좌측 정보창 옆에 붙이기 (2026-11-06)

## 요약
- [사실] 성 안 창이 모달에서 일반 창으로 바뀌었습니다. 전체 화면 차단막(`InputBlocker`)과 3D 카메라 `input_blocked` 켜기를 없앴고, 창은 좌측 정보창 오른쪽에 붙습니다. 가로는 화면의 30.7%(최소 400px)이고, 우측 도시 패널과 겹치면 줄어들며(최소 400px), 좌측 정보창을 옮기면 따라갑니다.
- [사실] 내 도시가 아닌 도시를 누르면 열려 있던 창이 닫힙니다. 같은 도시는 그대로(`already_open`), 다른 내 도시는 내용이 바뀝니다(기존).
- [사실] 코드 커밋 `ab65ef0`(파일 2개: 컨트롤러, CH-2 테스트). `worldmap_main.gd` 0줄. C-track run `42141975071` success(4 shard), CI 로그에서 `[CITY_INTERIOR] checks=93`, `[CITY_INTERIOR_LAYOUT] checks=93`, `[CITY_BUILDING_ASSETS] checks=482` 확인.

## 1. 먼저 확인한 [사실] (`ced058f` 기준, 지시서와 모두 일치)
| 항목 | 지시서 | 코드 | 일치 |
|---|---|---|---|
| 창 구성 | CanvasLayer 50 → InputBlocker(STOP) → Window(PanelContainer, PRESET_CENTER, 960×600) → VBox → 헤더 + InteriorArea | `_ensure_window()` 282~336행 같음 | 예 |
| 카메라 차단 | `try_open`에서 `_block_camera_input()`, `close`·`_exit_tree`에서 해제 | 150·183·88행 | 예 |
| 좌측·우측 패널 | `left_world_status_panel`, `city_info_panel_control` main 멤버 | `worldmap_main.gd:651`, `:648` (`@onready`) | 예 |
| 클릭 경로 | `_on_city_selected` → `try_open`, 거절 사유 `last_reject_reason` | 208~211행 | 예 |

## 2. 바꾼 것 (`scripts/worldmap/ui/worldmap_city_interior_controller.gd`만)
- 상수: `WINDOW_WIDTH_RATIO := 0.307`, `DOCK_GAP := 12.0`, `MIN_WINDOW_WIDTH := 400.0`, `BODY_ASPECT := 768.0 / 1280.0`, `FALLBACK_POSITION := (12, 12)`. `WINDOW_SIZE`는 삭제했습니다.
- `compute_dock()`: 가로 `max(화면 가로 × 0.307, 400)`. 위치는 좌측 패널 `get_global_rect().end.x + 12`, y는 좌측 패널 윗변입니다. 좌측 패널이 없거나 숨김이면 (12, 12)입니다. 우측 패널이 보이고 창 오른쪽 끝이 `우측 패널 왼쪽 − 12`를 넘으면 그 폭으로 줄이되 400 밑으로는 줄이지 않습니다.
- `_update_dock()`: `InteriorArea.custom_minimum_size = (본문 가로, 본문 가로 × 0.6)` 뒤 `reset_size()`. 직전과 위치·가로가 같으면 아무것도 하지 않습니다. `try_open` 직후와 열려 있는 동안 `_process`에서 부릅니다(좌측 패널 이동·화면 크기 변경 모두 이 경로).
- 제목 라벨 `clip_text = true`(긴 이름이 창을 넓히지 않게).
- `_on_city_selected`: `try_open`이 `not_own_city`로 거절되면 `close()`.
- `MAIN_MEMBERS`: 더는 읽지 않는 `_camera_controller`를 빼고 두 패널 이름을 넣었습니다.
- 공개 함수 추가: `get_window_panel()`(`get_window`는 Node의 기본 함수와 이름이 겹쳐 쓸 수 없음), `compute_dock()`.

## 3. 로컬 결과 (원문)
```
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
validators=72 pass=72 fail=0   (커밋 뒤 깨끗한 트리)
```
- [사실] 커밋 전(작업 트리 변경 있음) 검증기는 71/72였습니다. `validate_worldmap_trade_phase2_extraction.py`가 `git diff HEAD`에 `/ui/` 경로가 있으면 실패하는 검사라서이고, CH-3 때와 같은 현상입니다. 커밋 뒤 72/72.
- [사실] 입력 수명주기 `test_worldmap_to_battle_input_lifecycle.gd`는 이 PC에서 300초 시간 초과입니다. 22행 `bool(worldmap.get("_worldmap_battle_entry_handoff_in_progress"))`에서 "Nonexistent 'bool' constructor" 오류 뒤 멈춥니다. 이 PC에서는 지도가 3D로 뜨기 때문입니다(로그에 `[WorldMap3D] map 'eastasia' built`). **변경 전 `ced058f`로 되돌려(stash) 같은 조건에서 돌려도 똑같이 멈춰서** 이번 변경과는 무관합니다. 사용자 데이터 경로를 빈 폴더로 바꿔도 같았습니다. CI에서는 C-track 4 shard 모두 success입니다. [미확인] 이 PC에서 3D가 기본으로 뜨는 정확한 이유(김작 설정 파일 `user://samwar_worldmap3d.cfg`에 `map_view="3d"`가 있지만, 빈 사용자 폴더에서도 3D였음) — 이 단계 범위 밖이라 조사하지 않았습니다.

## 4. 테스트 교체 전후 (`tests/scripts/test_worldmap_city_interior_window.gd`, 74 → 93)
규칙이 바뀐 검사만 바꿨고 지운 검사는 없습니다. CH-3 테스트(`test_worldmap_city_interior_layouts.gd`)에는 창 크기에서 나오는 `k` 기대가 없어서(넓이를 직접 넣어 검사) **바꾸지 않았고** 93/0 그대로입니다.

| 전 | 후 |
|---|---|
| real 3D camera controller blocked while open | real 3D camera controller **not** blocked while open |
| real 3D camera controller unblocked after close | real 3D camera controller not blocked after close |
| 3D camera input blocked while open (가짜 3D 컨트롤러) | 3D camera input not blocked while open |
| 3D camera input unblocked after close | 3D camera input not blocked after close |
| blocked before scene removal | not blocked before scene removal |
| _exit_tree releases the 3D camera input block | _exit_tree leaves the 3D camera input unblocked |
| main member exists: `_camera_controller` | main member exists: `left_world_status_panel`, `city_info_panel_control` (+1) |

[사실] 이전 테스트에는 "중앙 위치·960×600·InputBlocker"를 직접 보는 검사가 없었습니다. 그래서 교체 대신 아래 새 검사로 채웠습니다.

새 검사 18개(ⓐ~ⓖ):
- ⓒ 창이 창 레이어의 직접 자식 / 레이어에 `InputBlocker` 없음(자식은 창 하나) / 창 자신은 클릭을 받음(STOP).
- 두 main 패널 읽기 가능 / 상수 0.307·400·12.
- ⓑ 화면 1920 → 가로 589.44.
- ⓐ 좌측 패널 오른쪽 12px, 윗변 정렬(1px).
- 본문 1280:768(1px) / 캔버스 k = 본문 가로 / 1280.
- ⓓ 좌측 패널을 (+40, +30) 옮기면 그 자리에 있음, 창이 따라옴, 되돌리면 다시 따라옴.
- ⓔ 우측 패널까지 450px만 남으면 450으로 줄어듦 / 200px만 남아도 400.
- 좌측 패널 숨김 → (12, 12).
- ⓑ 화면 1000 → 400(최소값).
- ⓕ 열린 상태에서 적 도시(평양) 클릭 → 닫힘(`not_own_city`).
- ⓖ 그때 텍스처도 풀림.

테스트는 headless 창이 작아서, 위치 검사 동안만 `root.size = 1920×1080`으로 두고 끝나면 원래대로 돌립니다.

## 5. 스샷
- [사실] 창 있는 Godot, 1920×1080, 한성 마커 클릭 신호로 연 화면: `C:\eastwar_tmp\cityhud_shots\CH2B_hanseong_dock_1920x1080.png`
- 같은 실행의 값: 창 `(380, 155.5)` 크기 `589×388`, 좌측 패널 `(48, 155.5)` 크기 `320×579`, 우측 패널 `(1564, 155.5)`, k = 0.4605(= 589.4 / 1280). 좌측 패널·창·우측 패널과 그 사이 지도가 한 화면에 보입니다.

## 6. 택한 해석
1. "창 가로 = 비율 규칙"과 "k = w/1280": 창 바깥 가로를 w로 두고, 본문 가로 = w − 창 테두리 여백으로 했습니다. 지금 테마의 창 여백이 0이라 실제로는 본문 가로 = w, k = w/1280입니다.
2. 가로 상한: 지시서의 `clamp(…, MIN, …)` 상한이 비어 있어 따로 두지 않았습니다(우측 패널 겹침 규칙이 사실상 상한).
3. 적 도시 클릭으로 닫는 것은 클릭 경로(`_on_city_selected`)에서만 합니다. `try_open`을 직접 부르는 경로(거절 표 검사)는 창 상태를 바꾸지 않습니다.
4. 지도 입력 통과는 구조로 확인했습니다(레이어에 창 하나뿐, 창 밖 GUI 컨트롤 없음, 카메라 차단 없음). 실제 마우스 드래그·휠은 F6에서 확인해 주세요.
5. 제안만 하고 만들지 않은 것: 창 끌기·크기 조절 손잡이.

## 7. 김작 F6 확인 방법
1. `WorldMap.tscn` F6 → 한성 클릭 → 창이 좌측 정보창 바로 오른쪽에, 윗변을 맞춰 작게(가로 약 화면의 1/3) 뜨는지.
2. 창이 떠 있는 채로 지도 드래그·휠·WASD(3D)가 되는지, 경주(내 도시면) 클릭 시 창 내용이 바뀌는지.
3. 평양(적 도시) 클릭 시 창이 닫히는지. ESC·닫기 버튼도 그대로.
4. (14번 CH-2c 뒤) 좌측 정보창을 끌면 창이 따라오는지.

## 8. 다음
큐 14번 `ORDER_CITYHUD_CH2C_LEFT_PANEL_GRIP_20261106.md`.
