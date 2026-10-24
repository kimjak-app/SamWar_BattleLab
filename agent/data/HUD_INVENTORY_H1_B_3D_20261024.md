# 3D 전투 랩 UI 인벤토리 (정적 읽기)

- 기준: 읽기 전용 worktree, 커밋 `dccb306c794207c966c210f71d4928f75cf5ad28`. (사실)
- 방법: 코드 읽기와 grep만 했다. Godot는 실행하지 않았다. (사실)
- 줄 번호 약어: `EP` = `scripts/battle3d/battle3d_engine_play.gd`, `LP` = `scripts/battle3d/lab_presentation.gd`, `SH` = `scripts/battle3d/battle3d_scenario_shell.gd`, `TH` = `scripts/battle3d/battle3d_top_hud.gd`, `TS` = `scenes/battle3d/Battle3D_TopHud.tscn`.
- 화면 크기: `project.godot`에는 1920×1080이 있다 (26–27행). (사실) 그런데 3D 테스트 하네스는 거의 모두 `root.size = 1280×800`으로 바꾼다. 1920×1080을 쓰는 테스트는 `test_battle3d_top_hud.gd`(91행) 하나다. (사실)
- CanvasLayer 순서: 랩 레이어들은 기본값 1이다. 상단 HUD는 5, 셸은 10이다. (사실, `TS`:43, `SH`:40)

---

## TASK 1. UI 요소 목록 (1920×1080 기준)

표기: "목록과 다름"은 사용자가 준 측정 표와 다르거나 그 표에 없는 경우다.

### 1-A. 2D Control (랩)

| 멤버 | 만드는 곳 | 1920×1080 rect (코드 기준) | 보여주는 것 / 하는 일 | 누르면 호출 (file:line) → 엔진 쓰기 |
|---|---|---|---|---|
| 정보 PanelContainer (이름 없는 지역 변수 `panel`) | LP:167–180 | 위치 (22,20). 최소 너비 440. 실제 너비 470 → 22..492. `status`의 최소 너비 430에 좌우 여백 20+20을 더한 값이다 (EP:174). 높이는 글자에 따라 바뀐다. 목록의 20..205는 측정값이다. (사실: 위치·너비 / 추정: 높이) | 안의 VBox(LP:181)에 title, sub, info, status가 있다. `info` 줄은 자동 줄바꿈이 없다. 상태 이상 목록이 길면 오른쪽으로 커진다(최대 723 측정). | 없음 (mouse_filter IGNORE) |
| title Label (지역 변수) | LP:184–188 | 패널 안 첫 줄 | "EASTWAR / FIELD LAB 01" 고정 글자 | 없음 |
| sub Label (지역 변수) | LP:189–192 | 패널 안 둘째 줄 | "3D PRESENTATION PROTOTYPE · 18 × 10" 고정 글자 | 없음 |
| `info` | LP:193–195, 글꼴 15 EP:171 | 패널 안 | 선택한 아군: id, 병종, 병력, 셀, 엔진 phase, has_moved/has_acted, 상태 이상, "방어 중" (EP:410). 선택이 없으면 갱신하지 않고 이전 글을 둔다 (EP:407). | 없음 |
| `status` | LP:196–199, 글꼴 14·자동 줄바꿈·최소 너비 430 EP:172–174 | 패널 안 마지막 줄 | 한 줄 안내와 로그. 거절, 명령 결과, 적 재생 문구, 책략·특기·지원군·자동·AI 문구가 모두 여기에 덮어써진다. | 없음 |
| help Label (지역 변수) | LP:200–204, 글자 교체 EP:166–170 | (24,710). 크기는 글자로 정해진다. 목록의 936×49는 측정값이다. 아래쪽 기준이 아니고 y=710 고정이다. (사실) | 조작 키 안내 2줄 | 없음 |
| `hover` | LP:205–208 | (24,680). 글자가 생기기 전 크기는 0이다. **목록에 없음.** | 마우스 아래 셀 좌표, 지형, 높이 (LP:266). 값은 목업 높이맵(`lab_heightfield.gd`)에서 온다. 엔진 값이 아니다. | 없음 |
| `attack_button` | EP:191–196 | (24,254) 160×38. 목록과 같다. | "공격 [F]". 사용 가능 여부는 EP:357 | `request_attack` EP:602 → `try_basic_attack` EP:607. F 키도 같다 (EP:484–486) |
| `wait_button` | EP:197–202 | (194,254) 110×38. 같다. | "대기". 막힌 이유는 tooltip (EP:358–360) | `request_wait` EP:551 → `_end_ally_turn_by_wait` EP:560 |
| `defend_button` | EP:203–208 | (314,254) 110×38. 같다. | "방어". tooltip EP:361–363 | `request_defend` EP:576 → `_on_defend_button_pressed` EP:586 |
| `strategy_button` | EP:209–214 | (434,254) 110×38. 같다. | "책략". tooltip EP:364–366 | `request_strategy` EP:882 → `_on_strategy_button_pressed` EP:888 |
| `skill_button` | EP:216–221 | (554,254) 110×38. 같다. | "특기". tooltip EP:367–369 | `request_skill` EP:1125 → `_on_unique_skill_button_pressed` EP:1134 |
| 대상/로그 PanelContainer (지역 변수 `panel`) | EP:223–235 | 코드: `PRESET_TOP_RIGHT` 뒤에 `position = (1920-394, 20)`. 트리에 넣기 전이라 오프셋 1526이 오른쪽 앵커(1920)에 더해진다. 결과 x=3446. **화면 밖.** 목록과 같다. (사실: 코드 / 추정: 원인 설명) 1280×800 테스트에서도 886+1280=2166으로 화면 밖이다. (추정) | 안에 `target_info`, `combat_log` | 없음 |
| `target_info` | EP:239–245 | 위 패널 안 (화면 밖) | 공격·책략 대상: id, 병종, 병력, 방어 여부, 셀 (EP:676). 책략이면 성공률 한 줄 추가 (EP:936) | 없음 |
| `combat_log` | EP:246–251 | 위 패널 안 (화면 밖) | "전투 기록" + `combat_lines` 마지막 5줄 (EP:711–714) | 없음 |
| `facing_ui` (HBox, 버튼 4개) | EP:176–186 | (24,300). 버튼 너비는 글자로 정해진다. | "방향 left/up/down/right". `current_phase == "facing_select"`일 때만 보인다 (EP:349) | `confirm_facing(dir)` EP:472 → `_select_post_move_facing` EP:477 |
| `turn_label` | EP:257–265 | 랩 원래 위치 (700,18), 너비 520. 셸이 매 프레임 옮긴다: y = 120+6 = 126, 글자 폭만큼, 가운데 x 957 (SH:135–147). 정보 패널 오른쪽 끝+6보다 왼쪽이면 오른쪽으로 민다. | "라운드 N · 아군/적 턴 · 행동 중: id" 또는 "라운드 N · 전투 종료" (EP:390–391) | 없음 |
| `momentum_label` | EP:266–274 | 원래 (700,52). 셸이 turn_label 아래 +2로 옮긴다. 측정 y 159. | "기세 아군 a / 적 e · 특기 기세 메모" (EP:404) | 없음 |
| `roster_label` | EP:275–282 | (1920-394, 1080-250) = (1526,830), 최소 너비 370. 높이는 줄 수로 정해진다. 목록의 151은 측정값이다. | 부대 목록: 헤더 + 부대마다 "아군/적군 id · 병종 · 병력 · 배지 글" (EP:392–402) | 없음 |
| `result_overlay` | EP:283–292 | 전체 화면 0..1920 × 0..1080. 글꼴 96, 가운데 정렬. 처음엔 숨김. | "승리"/"패배". 적 재생이 `battle_ended`에 닿을 때 켜진다 (EP:843–847) | 없음 (IGNORE) |
| `auto_button` | EP:1301–1306 | (600,300) 150×38. 같다. | "자동 ▶" / "자동 ■ (중지)" (EP:1439) | `request_auto` EP:1314 → `_toggle_full_auto_battle` EP:1328 |
| `speed_button` | EP:1307–1311 | (760,300) 110×38. 같다. | "속도 1x/2x/4x" | `cycle_speed` EP:1342 → 엔진 쓰기 없음. `Engine.time_scale`만 바꾼다 (EP:1348) |
| 옵션 VBox (지역 변수 `box`) | EP:1360–1363 | (1920-230,16) = (1690,16), 최소 너비 210. 높이는 내용으로 정해진다. 목록의 95는 측정값이다. | 아래 3개를 담는다 | 없음 |
| `option_toggle` | EP:1364–1367 | 옵션 VBox 첫 줄 | "옵션 ▾/▸" | `toggle_option_panel` EP:1388 → 엔진 쓰기 없음 (접기만) |
| `option_panel` (VBox) | EP:1368–1369 | 옵션 VBox 안 | 접히는 영역 | 없음 |
| `ai_level_label` | EP:1370–1376 | option_panel 안, 너비 210 | "적 AI: 하/중/상 [→ 다음 단계 (다음 적 턴부터 적용)]" (EP:1406–1407) | 없음 |
| `ai_level_buttons` (하/중/상) | EP:1377–1386 | option_panel 안 가로줄, 각 64×34 | 엔진의 현재/대기 단계를 눌림 상태로 보인다 (EP:1408–1409) | `request_ai_level(level)` EP:1393 → `set_enemy_ai_level` EP:1397 |

### 1-B. 2D Control (셸, 상단 HUD)

| 멤버 | 만드는 곳 | 1920×1080 rect (코드 기준) | 보여주는 것 / 하는 일 | 누르면 호출 → 엔진 쓰기 |
|---|---|---|---|---|
| `layer` (CanvasLayer 10) | SH:39–41 | — | 셸 UI의 레이어 | — |
| `start_panel` (VBox) | SH:46–48 | (500,260). 크기는 내용으로 정해진다. **목록에 없음.** | 제목 "EASTWAR 3D 전투 · 시나리오 선택" (SH:49–52) + 버튼 2개. 전투 중에는 숨김 | — |
| `scenario_buttons` ("기본 배치", "승리 연습") | SH:53–59 | start_panel 안, 각 320×48 | 시나리오 고르기 | `start_scenario(id)` SH:93 → 엔진 직접 쓰기 없음. `Engine.set_meta("samwar_battle_setup")` 후 새 랩을 만든다 (SH:98–100). (사실) |
| `result_panel` (VBox) | SH:60–63 | (470,470). 측정 470..874 × 470..558 | 결과 글 + 버튼 2개. 결과가 있고 적 재생이 끝나면 보인다 (SH:123–126) | — |
| `result_label` | SH:64–68 | result_panel 안, 글꼴 28 | "승리/패배 · 라운드 N · 생존 아군 K부대" (SH:155) | — |
| `restart_button` | SH:71–75 | result_panel 안, 160×44 | "다시 시작" | `restart` SH:106 → `start_scenario` (엔진 쓰기 없음) |
| `choose_button` | SH:76–80 | result_panel 안, 160×44 | "시나리오 선택" | `choose_scenario` SH:109 → 랩을 닫는다 (엔진 쓰기 없음) |
| `top_hud` (CanvasLayer 5, 씬) | 마운트 SH:42–45, 씬 TS:42– | 프레임 `TopHudRoot` = (-3+500, 2+18)..(−3+1420, 2+118) = 497..1417 × 20..120. 목록과 같다. **고정 좌표다 (anchors_preset 0). 뷰포트 크기를 따르지 않는다.** (사실) | 아군 기세 마름모 10칸, "전투" + "N / 30", 적 기세 마름모 10칸. 값은 셸이 넘긴다: `lab.momentum_display`, `lab.current_round` (SH:132). 결과가 생기면 숨김 (SH:130–131) | 버튼 없음. 엔진 읽기·쓰기 없음 |
| HUD 하위 (추정 rect) | TS:84–(Ally), 296–(TurnHud), 328–(Enemy) | AllyMomentumHud 약 633..893, TurnHud 807..1107 (y 20..108), EnemyMomentumHud 1108..1368, 프레임 그림 570..1339 × 13..112 (추정: 오프셋 합산) | — | — |

### 1-C. 랩 Label3D / 월드 UI (별도)

| 이름 | 만드는 곳 | 위치 | 보여주는 것 | 언제 바뀌나 |
|---|---|---|---|---|
| 부대 이름표 Label3D | LP:114–121, 글 갱신 EP:346 | 부대 위 y+2.5 | "id \| 병종\n병력" | 매 `_sync_views` (엔진 값 즉시) |
| 행동 배지 `action_badges` 자식 | EP:144–150, 갱신 EP:393–401 | 부대 위 y+5.2 | "미행동/이동 완료/행동 완료 · 방어 중 · 상태" | 매 프레임. 상태 부분만 재생 뒤 (EP:1045) |
| 아군 피해 숫자 | EP:697–709 | 대상 위 y+3.8, 1.8초 떠오름 | "−피해 · 각도" | `attack_resolved` 수신 시 |
| 적 피해 숫자 (meta `enemy_hit`) | EP:858–871 | 대상 위 y+3.8 | "−피해 · 각도" | 적 재생 중 `enemy_attack_resolved` |
| 책략 성공률 미리보기 (meta `strategy_preview`) | EP:906–914 | 후보 위 y+4.4 | "성공률 N%" (엔진 값) | 책략 대상 선택 단계 |
| 책략/상태 틱 라벨 (meta `tactic_label`) | EP:1025–1040 | 부대 위 y+4.8, 1.6초 | "동요 2턴", "실패", "화상 −N", "~ 해제" | 책략·상태 틱 표시 시 |
| 특기 라벨 (meta `skill_label` / `enemy_skill_label`) | EP:1256–1271 | 부대 위 y+4.8 | 특기 이름, −피해, +회복, 상태 | 특기 이벤트 표시 시 |
| 지원군 라벨 (meta `arrival_label`) | EP:1096–1109 | 셀 위 y+4.8, 2초 | "지원군 도착" | 도착 이벤트 표시 시 |
| 메시 표시 (글자 아님) | `ring` LP:57, `actor_ring` EP:135, 이동 범위 점 EP:457, 공격 범위·대상 EP:624–633, 책략 표식 EP:903, 특기 표식 EP:1156 | 바닥 | 선택 아군(노랑), 행동 중 적(빨강), 범위, 대상 | 매 `_sync_views` / 명령 시 |

### 1-D. 엔진 쓰기 명령 15개 (랩)

| # | 엔진 메서드 | 랩에서 부르는 곳 (file:line) | 들어오는 입력 |
|---|---|---|---|
| 1 | `_select_ally_unit` | `_click_world` EP:450 | 좌클릭: 아군 셀 (ally_turn) |
| 2 | `_try_direct_move_to_cell` | `_click_world` EP:465 | 좌클릭: 빈 셀 |
| 3 | `_select_post_move_facing` | `confirm_facing` EP:477 | `facing_ui` 버튼 |
| 4 | `_handle_right_click_cancel` | `_unhandled_input` EP:498 | 우클릭 |
| 5 | `try_basic_attack` | `request_attack` EP:607 | `attack_button`, F 키 |
| 6 | `_try_attack_enemy_target_from_attack_select` | `_click_attack_cell` EP:658 | 좌클릭 (attack_select) |
| 7 | `_end_ally_turn_by_wait` | `request_wait` EP:560 | `wait_button` |
| 8 | `_on_defend_button_pressed` | `request_defend` EP:586 | `defend_button` |
| 9 | `_on_strategy_button_pressed` | `request_strategy` EP:888 | `strategy_button` |
| 10 | `_try_use_strategy_on_target` | `_click_strategy_cell` EP:947 | 좌클릭 (strategy) |
| 11 | `_on_unique_skill_button_pressed` | `request_skill` EP:1134 | `skill_button` |
| 12 | `_try_use_unique_skill_on_target` | `_click_skill_cell` EP:1180 | 좌클릭 (unique_skill_target_select) |
| 13 | `_toggle_full_auto_battle` | `request_auto` EP:1328 | `auto_button` |
| 14 | `set_auto_presentation_hold` | `_update_auto_hold` EP:1435 (불리는 곳: `_process` EP:314, `request_auto` EP:1333, `_exit_tree` EP:1353) | 버튼 없음. 자동 진행 중 재생 대기 |
| 15 | `set_enemy_ai_level` | `request_ai_level` EP:1397 | `ai_level_buttons` |

- 이 15개는 `tests/scripts/support/battle3d_option_harness.gd`의 `FIFTEEN` 목록(7–9행)과 같다. (사실)
- 엔진 호스트도 `_skip_battle_intro_camera_zoom`을 한 번 부른다 (`battle3d_engine_host.gd`:18). 랩 명령 15개에는 들지 않는다. (사실)
- 셸은 엔진에 쓰지 않는다. 읽기 1개만 있다 (SH:154). (사실)

### 1-E. 목록과 다른 점 요약

- 목록과 다른 rect는 없다. 목록의 rect는 코드와 맞는다. 높이는 글자에 따라 바뀌므로 측정값이다. (사실/추정)
- 목록에 없는 요소: `hover` 라벨 (24,680), 정보 패널 안 title/sub, `start_panel`과 시나리오 버튼, `option_toggle`/`option_panel`/`ai_level_label`/`ai_level_buttons` 개별 항목. (사실)
- `hover`(y 680)와 help(y 710)는 1080 화면에서 위쪽 1/3 지점에 떠 있다. 아래쪽 기준 배치가 아니다. (사실)
- `result_overlay`의 "승리/패배"(96pt, 화면 가운데)는 셸 결과 패널(470..874 × 470..558)과 일부 겹칠 수 있다. (추정)

---

## TASK 2. 테스트·검증기 참조 수

- 대상: `tests/scripts/**/*.gd`, `tools/*.py`. 패턴은 `lab.X`, `shell.X`, `h.lab.X` 등 멤버 접근이다. 파이썬은 단어 경계로 셌다. (사실)
- 방식 약어: **누름** = `pressed.emit()` 또는 `push_click`, **글** = `.text`/`tooltip_text` 읽기, **보임** = `.visible`/`.disabled` 읽기, **위치** = `get_global_rect`/좌표 검사, **소스** = 파이썬이 소스 문자열을 검사.
- 파이썬 검증기는 모두 고정된 `BASE..TIP` 커밋 범위를 git으로 읽는다. 환경 변수로 `HEAD`를 주지 않으면 현재 작업 트리 변경에 반응하지 않는다. (사실, 예: `validate_battle3d_hud_label_move.py`:16–17)

| 요소 | 테스트 파일 수 (줄) | 주요 파일 | 방식 | 검증기 (.py) |
|---|---|---|---|---|
| `attack_button` | 4 (4) | `battle3d_engine_attack_harness`, `battle3d_auto_harness`, `test_battle3d_enemy_turn_locks`, `test_battle3d_scenario_defeat` | 누름, 보임(disabled) | 1: `m5a_autoplay`:119 (소스) |
| `wait_button` | 10 (21) | `battle3d_wait_harness`, `test_battle3d_wait_rejections`, `_wait_default_round`, `_defend_default_round`, `_option_ai_level`, `_scenario_defeat`, `_scenario_gaps` 등 | 누름, 보임, 글(tooltip) | 1: `m3b_wait` (소스 2줄) |
| `defend_button` | 5 (11) | `battle3d_defend_harness`, `test_battle3d_defend_rejections`, `_defend_default_round`, `battle3d_auto_harness`, `_scenario_defeat` | 누름, 보임, 글(tooltip) | 1: `m4a_defend` (소스 4줄) |
| `strategy_button` | 6 (9) | `battle3d_strategy_harness`, `test_battle3d_strategy_rejections`, `_strategy_default_round`, `_strategy_mixed_log` 등 | 누름, 보임, 글(tooltip) | 1: `m4b_strategy` (소스 3줄) |
| `skill_button` | 6 (8) | `battle3d_skill_harness`, `test_battle3d_skill_rejections`, `_skill_default_round`, `_skill_mixed_log` 등 | 누름, 보임, 글(tooltip) | 1: `m4c1_skill` (소스 3줄) |
| `facing_ui` | 10 (14) | 하네스 3개(defend, enemy_turn, wait), `test_battle3d_auto_stop_rejections`, `_enemy_turn_locks` 등 | 자식 버튼을 글("방향 left")로 찾아 누름, 보임 | 0 |
| `auto_button` | 5 (9) | `battle3d_auto_harness`, `test_battle3d_auto_stop_rejections`, `_option_ai_level`, `_scenario_defeat`, `_scenario_new_battle` | 누름, 글, 보임 | 1: `m5a_autoplay` (소스 2줄) |
| `speed_button` | 10 (15) | `test_battle3d_auto_speed`(5줄), 하네스 2개, `_scenario_*`, `_top_hud` 등 | 누름, 글 | 1: `m5a_autoplay` (멤버 목록) |
| `option_toggle` | 1 (4) | `test_battle3d_option_ai_level` | **누름(push_click: 화면 좌표 클릭)**, 글 | 1: `m5c_option_panel` (소스 2줄) |
| `option_panel` | 1 (2) | `test_battle3d_option_ai_level` | 보임 | 1: `m5c_option_panel` |
| `ai_level_label` | 2 (2) | `_option_ai_level`, `_option_ai_level_auto` | 글 | 1: `m5c_option_panel` |
| `ai_level_buttons` | 3 (10) | `_option_ai_level`, `_option_ai_level_auto`, `_option_strategy_gaps` | **누름(push_click: 좌표)**, 글, 눌림 상태 | 1: `m5c_option_panel` |
| `target_info` | 1 (1) | `battle3d_engine_attack_harness`:153 | 글 | 0 (`m2`, `m3`, `m4a/b/c1`는 `_refresh_target_info` 함수 이름만 검사) |
| `combat_log` (Label) | 0 | — | — | 0 |
| `combat_lines` (배열) | 13 (17) | defend/wait/strategy/skill/enemy 관련 테스트 | 배열 내용 | 0 |
| `info` | 3 (6) | `battle3d_defend_harness`, `test_battle3d_defend_default_round` (글 "방어 중"), `test_battle3d_top_hud` (최소 너비 강제 + **위치**) | 글, 위치 | 1: `hud_label_move` (셸이 `lab.info`만 읽는지 소스 검사) |
| `status.text` | 16 (29) | 거절·명령 테스트 대부분. `_enemy_turn_manual`:60, `_engine_attack_manual`:27은 글을 **쓴다** | 글 | 0 |
| `hover` | 0 | — | — | 0 |
| help Label (멤버 아님) | 0 | — | — | 0 |
| `turn_label` | 5 (14) | `test_battle3d_top_hud`(11줄), `_enemy_turn_default_layout`, `_enemy_turn_locks`, `_wait_default_round`, `_defend_default_round` | 글, **위치**(top_hud) | 2: `hud_label_move`, `hud_spike_top` (소스) |
| `momentum_label` | 4 (13) | `battle3d_skill_harness`(6줄), `_skill_default_round`, `_skill_rejections`, `_top_hud` | 글, **위치**(top_hud) | 3: `hud_label_move`, `hud_spike_top`, `m4c1_skill` |
| `roster_label` | 3 (3) | `battle3d_reinforce_harness`, `_enemy_turn_default_layout`, `_reinforce_blocking` | 글(줄 수, 포함 여부) | 0 |
| `result_overlay` | 9 (10) | 하네스 2개, `_enemy_turn_locks`, `_scenario_*`, `_skill_rejections`, `_top_hud` 등 | 보임, 글 | 0 |
| `action_badges` | 9 (12) | defend/wait/reinforce/enemy_turn 테스트 | 배지 글, 보임 | 0 |
| `actor_ring` | 0 | — | — | 0 |
| 셸 `start_panel` | 1 (3) | `test_battle3d_scenario_start` | 보임 | 0 |
| 셸 `scenario_buttons` | 2 (2) | `battle3d_scenario_harness`(누름), `_scenario_start`(글) | 누름, 글 | 0 |
| 셸 `result_panel` | 6 (15) | `_scenario_defeat/gaps/new_battle/start/victory`, `_top_hud` | 보임 | 0 |
| 셸 `result_label` | 4 (5) | `_scenario_defeat/gaps/new_battle/victory` | 글 | 0 |
| 셸 `restart_button` | 3 (3) | `battle3d_scenario_harness`, `_scenario_defeat`, `_scenario_gaps` | 누름, 글, 보임 | 0 |
| 셸 `choose_button` | 4 (5) | `_scenario_defeat/gaps/start`, `_top_hud` | 누름, 글 | 0 |
| 셸 `top_hud` | 1 (1, 이후 `hud` 변수로 다수) | `test_battle3d_top_hud` | 글, 칸 채움, **위치**(frame_rect) | 2: `hud_label_move`(5줄), `hud_spike_top`(8줄) |
| Label3D `enemy_hit` | 1 | `battle3d_enemy_turn_harness`:217 | 글 | 0 |
| Label3D `tactic_label` | 1 (2) | 책략 관련 하네스 | 글 | 0 |
| Label3D `skill_label` / `enemy_skill_label` | 2 / 1 | 특기 하네스 | 글 | 0 |
| Label3D `strategy_preview` | 1 | 책략 하네스 | 글 | 0 |
| Label3D `arrival_label` | 0 | — | — | 0 |
| 부대 이름표 Label3D | 1 | `test_battle3d_scenario_start`:51 | 글 | 0 |

위치에 민감한 테스트 (사실):
- `test_battle3d_top_hud.gd`만 rect를 직접 본다. 랩·셸 레이어의 보이는 최상위 Control 전부와 두 라벨이 겹치지 않는지 검사한다 (`other_ui_rects`, 33–42행). 화면 밖 대상/로그 패널을 화면 안으로 옮기면 이 검사에 걸릴 수 있다. (추정)
- `push_click`은 Control의 화면 중심을 클릭한다 (`battle3d_option_harness.gd`:58–71). 1280×800에서 `option_toggle`, `ai_level_buttons`의 위치가 바뀌면 영향을 받는다. (사실)
- 나머지 버튼 테스트는 `pressed.emit()`을 쓴다. 위치와 무관하다. (사실)

---

## TASK 3. 2D식 HUD가 쓸 수 있는 랩 값

구분: **즉시** = 엔진 값을 곧바로 복사. **재생 후** = 랩의 적 재생/표시가 지나야 바뀜. **수신 시** = 엔진 로그를 읽은 프레임에 바뀜 (재생보다 앞섬).

| 멤버 | 선언 (file:line) | 쓰는 곳 | 내용 | 갱신 시점 |
|---|---|---|---|---|
| `momentum_display` | EP:53 | EP:403 | {ally, enemy} 기세 | **재생 후**. 적 재생이 바쁘지 않을 때만 엔진 값으로 덮는다 (사실) |
| `momentum_note` | EP:54 | EP:1210, 1237 | 마지막 아군 특기 기세 메모 | 아군 특기 표시 시 (사실) |
| `current_round` | EP:115 | EP:815, 839 | 라운드 | **재생 후**. `enemy_turn_started`/`round_started` 재생 때만 바뀐다. 엔진 `battle_round`는 읽지 않는다 (사실) |
| `selected` | LP:11 | EP:351 | 엔진 `active_unit_state.unit_id` | **즉시** (매 `_sync_views`) (사실) |
| `display_values` | EP:10 | EP:335 | unit_id → 14필드 뷰 (`Adapter.VIEW_FIELDS`: unit_id, side, unit_type, grid_cell, facing, current_troops, max_troops, allocated_troops, footprint, has_moved, has_acted, status_effects, move_range, attack_range) | **즉시** (사실). 병력·행동 플래그가 재생보다 먼저 바뀔 수 있다 (추정) |
| `status_display` | EP:38 | EP:1045 | unit_id → 상태 이상 | **재생 후** (사실) |
| `enemy_actor_id` | EP:110 | EP:818, 835, 844 | 지금 재생 중인 적 | **재생 후** (사실) |
| `enemy_texts` | EP:109 | EP:850 | 적 재생 문구 목록 | **재생 후** (사실) |
| `enemy_summaries` | EP:95 | EP:753 | 적 슬롯 요약 {before, after, text, events} | **수신 시** (재생보다 먼저) (사실) |
| `combat_lines` | EP:94 | EP:712 | 전투 기록 전체 | 섞임: 아군 줄은 즉시, 적 요약은 수신 시, 적 피해 줄은 재생 후, 적 책략·틱은 해당 적 완료 재생 후 (사실) |
| `battle_result` | EP:116 | EP:774 | "victory"/"defeat" | **수신 시**. 오버레이는 재생 후 (EP:845). 셸 결과 패널은 재생이 끝난 뒤 (SH:125) (사실) |
| `last_phase` | EP:99 | EP:374 | 엔진 phase | 즉시 (사실) |
| `target_id`, `target_defending` | EP:91–92 | EP:491, 653, 675, 934 | 지금 보는 대상 | 마우스·클릭 시 (사실) |
| `valid_target_ids`, `strategy_target_ids`, `skill_target_ids` | EP:90, 30, 49 | EP:630, 902, 1155 | 엔진이 준 후보 | 명령을 연 때 (사실) |
| `held_unit_ids` | EP:34 | EP:983, 1086 | 아직 보이지 않게 잡은 지원군 | 재생 후 풀림 (사실) |
| `tactic_texts`, `skill_texts`, `enemy_skill_texts`, `arrival_texts`, `auto_texts`, `ai_level_texts` | EP:31, 51, 62, 37, 74, 84 | 각 `_*_text` | 문구 기록 | 표시 시 (사실) |
| `rejected` | EP:18 | EP:422 | 거절 횟수 | 즉시 (사실) |
| `speed_index` | EP:71 | EP:1344 | 속도 단계 (랩 전용) | 버튼 시 (사실) |
| `auto_was_on`, `auto_marks` | EP:72, 75 | EP:1332, 1444, 1457 | 자동 상태 기억 | 즉시에 가깝다 (사실) |
| AI 단계 | 멤버 없음 | EP:1404–1405 | `get_enemy_ai_level`, `get_pending_enemy_ai_level` | 즉시 (매 `_sync_views`). 저장 멤버는 없고 라벨 글에만 남는다 (사실) |
| `enemy_queue`, `enemy_hold` | EP:105, 112 | — | 재생 대기열 | `_enemy_presentation_busy()` (EP:527) 판단 재료 (사실) |
| 셸 `result_text`, `scenario`, `lab_count` | SH:26, 18, 27 | SH:155, 96, 101 | 결과 글, 시나리오 | 결과 표시 / 시작 시 (사실) |
| HUD `shown`, `apply_count` | TH:9–10 | TH:19–25 | 마지막 표시 값 | 값이 바뀔 때만 (사실) |

엔진 읽기 목록 (랩, 사실):
- `engine.get(...)`: `active_unit_state`(19회), `current_phase`(18), `is_full_auto_battle_enabled`(7), `is_demo_animating`(6), `enemy_action_event_log`(6), `tactic_event_log`(5), `battle_action_event_log`(3), `battle_momentum`(3, `.get_value("ally"/"enemy")`), `ally_move_event_log`(2), `all_battle_unit_states`(2), `battle_grid_controller`(2, `.get_tiles_in_range` EP:621), `auto_presentation_hold`(1), `is_manual_unique_skill_preview_pending`(1).
- `engine.call(...)` 읽기: `_is_unit_state_available_for_battle_slot`, `_get_alive_enemy_units`, `is_unit_in_attack_range`, `_can_use_strategy`, `_get_strategy_targets`, `_get_strategy_success_rate`, `_get_unique_skill_for_unit`, `_get_unique_skill_valid_targets`, `_can_use_unique_skill`, `_should_unique_skill_resolve_without_manual_target`, `get_enemy_ai_level`, `get_pending_enemy_ai_level`.
- 그 밖: 이벤트 로그 `.export()`, `BattleUnitState` 필드 (`Adapter.to_view`), `unit.is_defending` (EP:414, 675), 이동 질의 서비스 (`battle3d_movement_adapter.gd`).
- 셸: `lab.engine.call("_is_unit_state_available_for_battle_slot")` (SH:154).
- 기세를 즉시 읽는 곳이 하나 더 있다: `_skill_block_reason` (EP:1119). 저장하지 않고 tooltip에만 쓴다.

---

## TASK 4. 3D "적 행동 중 · …" 줄

| 줄 | 만드는 곳 | 내용 | 표시 위치 | 언제 바뀌나 |
|---|---|---|---|---|
| "적 행동 중 · {unit_id}" | EP:819 (`_present_enemy_event`, `enemy_actor_selected`) → `_enemy_text` EP:849–852 | 고정 머리말 + 적 부대 id. 다른 정보 없음 | `status` 라벨 (왼쪽 위 정보 패널 마지막 줄). `enemy_texts`에도 쌓인다 | 적 재생 대기열이 `enemy_actor_selected`에 닿을 때 (재생 후). `enemy_hold`가 없다. 그래서 같은 프레임에 다음 이벤트 문구("적 이동 · …", "적 공격 · …", "적 {id} · 대기 사유", "적 책략 사용: …", "적 특기 사용: …")가 바로 덮을 수 있다 (사실: 코드 흐름 EP:784–796 / 추정: 화면에 거의 안 남음) |
| "라운드 N · 적 턴 · 행동 중: {enemy_actor_id}" | EP:388–390 (`_refresh_turn_ui`) | 라운드(`current_round`), 진영, 재생 중 적 id | `turn_label` (HUD 아래 y 126) | 매 `_sync_views`. 엔진 phase가 enemy_turn이거나 재생이 바쁘면 "적". `enemy_actor_id`는 `enemy_actor_selected` 재생 때 설정, `enemy_action_completed`·`battle_ended` 재생 때 지움 (EP:818, 835, 844) (사실) |
| "적 자동 행동 중 · 입력 잠금 / 결과는 엔진 상태로 동기화" | EP:373 (`_sync_views`) | 고정 문구 | `status` 라벨 | phase가 enemy_turn이고 결과가 없고 재생 대기열이 비면 매 프레임 덮는다 (사실). `_sync_views`는 `_advance_enemy_presentation` 뒤에 돈다 (EP:302, 313). 그래서 엔진이 아직 적 턴이고 대기열이 비면 위 첫 줄을 같은 프레임에 덮는다 (추정) |

- 적 재생 문구 전체 (모두 `_enemy_text`, 사실): "적 턴 · 라운드 N" (EP:816), "적 행동 중 · id" (819), "적 id · 사유" (824), "적 책략 사용: id → 대상" (828), "적 특기 사용: skill_id" (831), "라운드 N" (841), "전투 종료 · 승리/패배 / 모든 입력 잠금" (847), "적 이동 · id from→to" (810), "적 공격 · a → t 피해 d (각도)" (872).
- 재생이 끝나면 "아군 조작 가능 / 엔진이 선택한 부대: id"로 바뀐다 (EP:797–799). 조건: 결과 없음, phase ally_turn, 애니메이션 없음. (사실)
- `status`는 같은 칸이라 책략·특기·지원군·자동·AI 문구와 거절 문구도 언제든 덮는다 (EP:423, 1023, 1093, 1254, 1414, 1465). (사실)
- `enemy_hold_seconds`는 0.35초다 (EP:113). `delta`는 `Engine.time_scale`의 영향을 받으므로 속도 2x/4x에서 짧아진다. (추정)
- 이 줄을 검사하는 테스트: `test_battle3d_enemy_strategy_replay.gd`:41–42 (`enemy_texts`에서 "적 행동 중 · " + caster를 찾고 다음 줄이 "적 책략 사용"인지 본다). 화면 글(`status.text`)로는 검사하지 않는다. (사실)

---

## 미확인

- 정보 패널, 라벨, 버튼의 실제 높이와 글자 폭. 테마·글꼴에 따라 바뀐다. 측정 표의 값을 그대로 두었다. (추정)
- 대상/로그 패널이 x=3446이 되는 정확한 원인. 트리에 넣기 전에 `position`을 정해서 오프셋이 앵커 위에 더해진 것으로 본다. 실행으로 확인하지 않았다. (추정)
- `start_panel`의 실제 rect (500,260부터). 측정값이 없다.
- `facing_ui` 버튼 4개의 실제 너비. 글자 "방향 left" 등에 따라 정해진다.
- "적 행동 중 · id"가 실제 화면에 몇 프레임 보이는지. 엔진 적 행동은 트윈으로 여러 프레임에 걸친다 (`scripts/battle_web_import_test.gd`:8169, 8315 부근). 대기열 상태에 따라 0프레임일 수도 있다. (추정)
- 상단 HUD 하위 노드의 정확한 전역 rect. 오프셋을 더해 계산만 했다. (추정)
- CI 목록(`.github/workflows/verify-c-track.yml`)에서 어떤 테스트가 실제로 돌아가는지는 세지 않았다.
- `info`의 높이가 커져서 y=254 버튼 줄과 겹치는 경우가 있는지. `status`가 자동 줄바꿈되므로 긴 문구에서 가능성이 있다. (추정)
