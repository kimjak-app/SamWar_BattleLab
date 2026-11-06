기준 화면: `origin/main` = `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`에서 새 가지 `feature/wm3d-hudfix-20261106`을 만들어, F6로 월드맵(3D)에서 ① 내 도시를 클릭하면 **성 그림만** 있는 창이 좌측 패널 옆에 뜨고(제목줄·닫기 버튼·안내 글자 없음) ② 오른쪽 아래 턴 버튼의 하늘 원과 금속 테두리 사이에 **월드맵이 비치는 틈이 없다**. (24번 지시서 + 답신 1 `ORDER_HUDFIX_REPLY_1_20261106.md`의 정정 반영)
합격 기준: 김작이 최종본에서 F6로 ① 성 그림 외에 아무것도 없는 창(ESC 또는 창 밖 빈 지도 클릭으로 닫힘) ② 턴 버튼의 낮·해질녘·밤·새벽 네 상태와 하늘이 바뀌는 중간에도 테두리 사이 틈이 안 보임. 자동 조건: C-track 4 shard·`Verify WorldMap3D` 초록, 새 틈 테스트가 수정 전 실패/수정 후 통과.

# REPORT_HUDFIX — 도시창 "그림만" + 턴 버튼 하늘/테두리 틈 원인 수정 (클코드, 2026-11-06)

- **됐나**: 됐다. 코드 커밋 `de53500`(push됨), C-track 4/4 success. 남은 것은 김작 F6.
- **턴 버튼**: 하늘 두 겹을 테두리 구멍 실측 중심 (120.00, 119.06)에 놓고 반지름 71.44(구멍 68.44 + 3)로 키웠다. 마젠타 틈 픽셀 수정 전 **708~948개** → 수정 후 **0개**(계산), 실제 렌더 수정 전 **762~849개** → 수정 후 **0개**.
- **막힌 것**: 없음. [사실] `Verify WorldMap3D`는 이번 변경 경로(`scripts/worldmap/ui`, `scripts/worldmap/worldmap_turn_compass.gd`, `tests/scripts/test_worldmap_*`)가 그 워크플로의 `paths` 조건에 없어 **트리거되지 않았다**(`gh` 실행 금지라 수동 실행 안 함). 대신 같은 테스트 묶음 `tests/scripts/test_worldmap3d_*.gd` 8개를 로컬에서 돌려 모두 통과(5절).

## 1. 1절 수치 재확인 (구멍 실측 vs 지시서)
측정: `turn_btn_frame.png`(512×512) 가운데에서 이어진 알파 < 0.5 영역의 경계 상자. 같은 값을 코드(`get_frame_hole()`)와 새 테스트(독립 구현)가 각각 잰다.

| 항목 | 지시서 24번 1절 | 답신 1 | 실측(코드·테스트 동일) |
|---|---|---|---|
| 구멍 경계 상자 @512 | — | — | x 112~399, y 108~399 |
| 구멍 중심 @240 | (119.77, 118.83) | (120.00, 119.06) | **(120.0, 119.0625)** |
| 구멍 반지름 @240 (가로, 세로) | 67.5 | 68.44(큰 값) | **(67.5, 68.4375)** |
| 하늘 원(수정 전) | (119.65, 120.82) r 67.5 | — | (119.63, 120.82) r 67.5 → `SkyA` (52.15, 53.32) 135×135 |
| 하늘 원(수정 후) `get_sky_circle()` | 구멍 + 3 | r 71.44 | 중심 (120.0, 119.0625), **r 71.4375** → `SkyA` (48.56, 47.63) 142.875×142.875 |
| 클릭 원 `get_window_circle()` | 그대로 | 그대로 | (119.63, 120.82) r 67.5 — **변경 없음** |

- 지시서 1절 중심과의 차이 (+0.23, +0.23)는 측정 방법 차이로 본다 [추정]. 답신 1 값과는 일치.

## 2. 도시 내부창 — 변경 요약 (`scripts/worldmap/ui/worldmap_city_interior_controller.gd`)
- 제목줄 삭제: `TitleLabel`·`CloseButton`·`header`(HBox)·`VBoxContainer`를 만들지 않는다. 창(`PanelContainer "Window"`)의 유일한 자식이 `InteriorArea`(성 그림). `_ensure_window()`(360행~).
- 빈 패널 스타일: `add_theme_stylebox_override("panel", StyleBoxEmpty.new())` → 여백·테두리·배경 0. 창 크기 = 그림 크기(1920 기준 589.44×353.664, 캡처 로그). 창 자신은 여전히 클릭을 먹는다(`MOUSE_FILTER_STOP`, PanelContainer 기본).
- 도킹 규칙(`compute_dock`)·좌측 패널 따라가기·오른쪽 패널 피하기·`_draw_city`·레이아웃·`PLACEHOLDER_TEXT`는 **바꾸지 않았다**.
- API: `get_title_text()`·`get_close_button()` 삭제(호출처는 두 테스트뿐이었고 이번에 고침). 쓰이지 않게 된 `_city_display_name()`도 삭제. 새 공개 접근자 없음(상수 `CLICK_MOVE_LIMIT`·`OUTSIDE_CLICK_SETTLE_FRAMES`만 추가).
- 닫기 규칙(답신 1 2절) — `_process`(218행~)·`_input`(230행~)·`_unhandled_input`(새, 249행~)·`_on_city_selected`(282행):
  1. **"빈 지도" 판정**: 창이 열린 동안 왼쪽 버튼 눌림이 `_unhandled_input`까지 온 경우 = 어떤 HUD 컨트롤(창, 좌·우 패널, 그립, 위쪽 메뉴, 턴 버튼)도 그 눌림을 먹지 않은 경우. 이유: Godot은 GUI 컨트롤이 먹은 마우스 눌림을 `_unhandled_input`으로 보내지 않는다. 컨트롤러는 main의 자식이라 main(2D/3D 카메라)보다 먼저 받는다. 눌림은 `set_input_as_handled`로 삼키지 않는다.
  2. 뗌(`_input`, 어디서 떼든)이 눌린 곳에서 **6px 미만**이면 클릭 → 2프레임 뒤에 판정. 6px 이상이면 드래그(카메라 이동)라 아무것도 안 한다. 6px = `worldmap_camera.gd`의 3D 클릭-선택 한계(`< 6.0`)와 같은 값, 상수 `CLICK_MOVE_LIMIT`.
  3. 2프레임 안에 그 클릭이 도시를 골랐으면(`city_selected`가 옴) 기존 도시 규칙(내 도시면 유지/전환, 남의 도시면 닫힘)만 적용하고, 고르지 않았으면 닫는다.
- 3D에서 닫힘/유지 표 [추정: 코드 경로로 판단, 실제 F6는 김작 확인 대기]:

| 3D에서 한 일 | 결과 | 이유 |
|---|---|---|
| 바다·주인 없는 빈 땅 클릭(<6px) | **닫힘** | 3D 집기가 빈 도시 id → 어댑터가 무시 → 도시 선택 없음 |
| 남의 도시 지역 땅 클릭 | **닫힘** | 기존 규칙(남의 도시 → 닫힘) |
| 내 도시 지역 땅 클릭(열린 도시) | **유지** | 그 도시 선택 = `already_open` |
| 다른 내 도시 지역 땅 클릭 | **그 도시로 전환** | 기존 규칙 |
| 왼쪽 버튼으로 6px 이상 끌고 뗌 | **유지** | 드래그는 클릭이 아님(답신 1 보완 1) |
| 가운데·오른쪽 버튼 끌기(카메라 이동·회전), 휠 | **유지** | 왼쪽 버튼이 아님 |
| 창·좌측 패널(그립 포함)·오른쪽 패널·위쪽 메뉴·턴 버튼 누름 | **유지** | GUI가 눌림을 먹음(테스트로 확인) |
| ESC | **닫힘** | 그대로 |

- 지도 드래그 관찰(지시서 2절 3항): 위 표대로 닫히지 않는다(테스트: 31.6px 끌기·정확히 6px 모두 유지).
- 레이아웃 없는 도시에서 창이 어떻게 보이는지 [사실, 코드 판단]: 성 레이아웃은 5개 도시(`edo`, `hanseong`, `jianye`, `kyoto`, `pyeongyang`)뿐. 그 밖의 내 도시(예: `gyeongju`)는 패널 배경이 없어져 **지도 위에 안내 글자 "건물 그림은 다음 단계에서 연결됩니다"만 떠 있는 모양**이 된다(창 영역 클릭은 여전히 창이 먹음). `PLACEHOLDER_TEXT`는 지시대로 건드리지 않았다 — 김작 결정 대기.

## 3. 턴 버튼 — 변경 요약 (`scripts/worldmap/worldmap_turn_compass.gd`)
- 새 상수 `FRAME_TEXTURE_PATH`·`SKY_OVERLAP_PX := 3.0`(33~34행), 캐시 `static var _frame_hole_cache`(64행).
- 새 `static func get_frame_hole()`(144행~): 위 1절 방법으로 1회 측정, 캐시. 이미지를 못 읽으면 옛 창 원으로 대체(`measured: false`).
- 새 `get_sky_circle()`(182행~): 구멍 중심, 반지름 = max(가로, 세로 반지름) + 3.
- `_layout_daynight_layers()`(188행~): `SkyA`·`SkyB`만 `get_sky_circle()`로 배치. `get_window_circle()`과 클릭 마스크(`_window_click_mask(circle)`)는 옛 창 원 그대로.
- 3절 4항 확인 [사실]: `SkyA`의 `modulate`를 바꾸는 코드 없음. `_apply_sky_progress`는 `SkyB.modulate.a`만, `_refresh_center_texture`는 두 겹의 `self_modulate`를 알파 1로만 바꾼다 → `SkyA`는 항상 불투명 100%, 절반 투명 두 겹 경로 없음. 고칠 것 없음.
- 스핀·턴 대기: `SPIN_DURATION_SEC`·`CYCLE_SEC`·`TURN_WAIT_TIMEOUT_MSEC`·`_finish_sky_cycle` 등 **변경 0**. p1b 검증기 5개 PASS(수정 전과 같은 결과).
- 테스트 72행(답신 1 1절, 한 줄만): `tests/scripts/test_worldmap_turn_button_daynight.gd` diff = −1/+1줄. 새 기대: 구멍 측정됨 + 구멍 중심 (120.0, 119.0625) ±0.05 + 하늘 중심 = 구멍 중심 + 하늘 반지름 71.4375 ±0.01 + **하늘 반지름 ≥ 구멍 가로·세로 반지름 큰 값 + 3** + `SkyA` 위치·크기 = 하늘 원. 70행·클릭 원 검사는 그대로.

## 4. 새 틈 테스트 `tests/scripts/test_worldmap_turn_compass_seam.gd` (C-track 목록 끝, shard 3)
- 방법: headless에는 렌더러가 없어(더미) **알파 합성 계산**으로 검사한다. 240×240 각 픽셀 중심에서 배경이 보이는 비율 = (1−a_SkyA)(1−a_SkyB)(1−a_Frame)(1−a_Center). 각 층은 노드의 실제 위치·크기에서 선형 보간 샘플(TextureRect 그리기와 같은 방식). 1/255 이상이면 틈 픽셀. 검사 범위 = 구멍 반지름 + 10px(테두리 아래 띠 포함, 19,292픽셀). 창 있는 실행에서는 SubViewport에 마젠타/초록 배경으로 실제 렌더해 두 결과가 다른 픽셀도 센다.
- 구멍은 테스트가 코드와 따로 잰다(코드의 측정이 틀려도 통과하지 못하게).
- 진행도 9개: 0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 0.99(각 구간 시작과 중간).

| 진행도 | 수정 전(계산, `042b070` 코드) | 수정 후(계산) | 수정 전(실제 렌더) | 수정 후(실제 렌더) |
|---|---|---|---|---|
| 0 낮 | **948** | 0 | **849** | 0 |
| 0.125 낮→해질녘 중간 | 804 | 0 | 762 | 0 |
| 0.25 해질녘 | 948 | 0 | 849 | 0 |
| 0.375 | 804 | 0 | — | — |
| 0.5 밤 | 948 | 0 | 848 | 0 |
| 0.625 | 804 | 0 | — | — |
| 0.75 새벽 | 948 | 0 | 849 | 0 |
| 0.875 | 804 | 0 | — | — |
| 0.99 | 708 | 0 | — | — |

- 수정 전 첫 틈 픽셀 (110, 50) = **위쪽** → STOP 때 잰 위쪽 2.7px 틈과 같은 방향(답신 1 1절 4항). 수정 후 배경 비율 최댓값 0.0000.
- 수정 전 숫자는 `042b070`의 compass 코드 그대로에서 잰 것이다(계산: 수정 전 작업 폴더, 렌더: `origin/main` 파일 사본을 `class_name`만 빼고 로드).

## 5. 검증 숫자
로컬(Godot 4.6.2 headless, 테스트마다 임시 `APPDATA`):

| 테스트 | 결과 |
|---|---|
| `test_worldmap_turn_compass_seam` (새) | `[TURN_SEAM] checks=18 failures=[]`, total_seam_pixels=0 |
| `test_worldmap_turn_button_daynight` (72행 수정) | `checks=43 failures=[]` |
| `test_worldmap_city_interior_window` (수정 + 8절 새 검사) | `checks=125 failures=[]` |
| `test_worldmap_city_interior_layouts` (86행 수정) | `checks=93 failures=[]` |
| `test_worldmap_left_panel_grip` | `checks=28 failures=[]` |
| `test_worldmap_integrated_hud_smoke` | `checks=12 failures=0` |
| `tools/validate_p1b1~4`, `validate_p1b_16x9_functional_parity` | 5개 모두 PASS |
| `test_worldmap3d_*.gd` 8개(Verify WorldMap3D와 같은 묶음) | 모두 exit 0 — host 58/0, adapter 56/0, camera_controller 61/0, camera_external_input 20/0, color_parity 57/0, mem_probe 37/0, production 28/0, roads 121/0 |

- [사실] host 테스트 로그의 `hero_cutin_presentation.gd ... Identifier not found: GameAudio` 줄은 이번 변경 전 다른 가지 실행 로그(bake, ch2b, ch2c)에도 똑같이 있던 기존 줄이다. 테스트 결과(PASS)와 무관.
- 창 테스트 8절 새 검사(실제 마우스 이벤트를 viewport로 넣음, 2D 지도 1920×1080): 빈 곳 클릭(3.6px 이동) 닫힘 / 31.6px 끌기 유지 / 정확히 6px 유지 / 같은 내 도시 고름 유지 / 다른 내 도시 전환 / 남의 도시 닫힘 / 창·그립·좌측 패널·오른쪽 패널·위쪽 메뉴 버튼·턴 버튼 눌림은 `_unhandled_input`까지 안 오고 창 유지 / ESC 닫힘 / 창 = 그림 영역(여백 0)·제목줄·닫기 버튼 노드 없음. 테스트 `_settle()` 뒤 원래 순서 검사(`already_open`)를 위해 8절 끝에 창을 다시 연다.
- shard 표: 기존 207개 테스트의 shard 변화 0, 새 테스트 idx 207 → shard 3.

CI(코드 커밋 `de53500`):
- `Verify C-track refactor` run `42208336062`: **success** — shard 0 `127860473699`, 1 `127860473777`, 2 `127860473125`, 3 `127860473501` 모두 success. 로그 원문: `[CITY_INTERIOR] checks=125 failures=[]`, `[INTEGRATED_HUD_SMOKE] checks=12 failures=0`, `[CITY_INTERIOR_LAYOUT] checks=93 failures=[]`, `[TURN_SEAM] total_seam_pixels=0`, `[TURN_SEAM] checks=18 failures=[]`, `[LEFT_PANEL_GRIP] checks=28 failures=[]`, `[TURN_BUTTON_DAYNIGHT] checks=43 failures=[]`.
- `Verify WorldMap3D`: 트리거 없음(경로 조건). 위 로컬 8개로 대신.

## 6. 캡처 (`agent/evidence/hudfix_20261106/`, 창 있는 Godot `--resolution 1920x1080`, 렌더러 `forward_plus`, 저장 전 `frame_post_draw`)

| 파일 | 내용 |
|---|---|
| `citywin_hanseong_1920.png` | 3D 지도에서 한성 창 열림, 화면 전체 |
| `citywin_hanseong_crop.png` | 같은 창 주변 잘라냄 — 성 그림만, 제목줄·닫기 없음 |
| `turnbtn_before_day_magenta_x4.png` | **수정 전** 낮, 마젠타 배경, 4배 — 구멍 위쪽 마젠타 초승달 |
| `turnbtn_after_{day,dusk,night,dawn}_magenta_x4.png` | 수정 후 네 상태, 마젠타 배경, 4배 — 틈 없음 |
| `turnbtn_ingame_after_x4.png` | 실제 월드맵 화면 속 턴 버튼, 4배 |
| `capture_log.txt` | 렌더 틈 픽셀 수·창 크기 원문 |
| `seam_test_before_fix.txt` / `seam_test_after_fix.txt` | 새 테스트 출력 원문(수정 전/후) |
| `local_tests.txt` | 로컬 테스트·검증기 요약 |
| `capture_script.gd.txt` | 캡처에 쓴 스크립트(저장소에서 실행하지 않음, 기록용) |

**남은 것: 김작 F6** — 성 그림만 있는 창, 빈 바다·남의 땅 클릭으로 닫힘·드래그로는 안 닫힘, 턴 버튼 네 상태와 전환 중 틈 없음.

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-hudfix-20261106` 체크아웃, `git status` 깨끗 → 김작이 바로 F6 가능.
2. 커밋: STOP 보고서 `a24c951` → 코드 `de53500` → 이 보고서·증거(`[skip ci]`). `main` 푸시 없음, 다른 가지 수정 없음(26번 bake 가지 문서 한 줄은 별도 항목).
3. 바꾼 파일: 컨트롤러·compass·창 테스트·layouts 테스트(86행)·daynight 테스트(72행)·새 틈 테스트(+`.uid`)·`verify-c-track.yml` 목록 끝 1줄. 허용 범위 밖 파일 0.
4. 측정·캡처용 임시 스크립트는 실행 뒤 지웠다. Godot은 모두 임시 `APPDATA`로 돌렸다.
5. 22번(PERF3)은 26번 답신대로 조건부 합격 문구를 넣었다(`dd19b39`). 큐에 남은 "준비됨" 항목 없음.
