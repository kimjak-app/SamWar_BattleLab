# HUD 블록 4-2 조사 (부대 명령 패널 + 방향 선택) — 2026-10-25

- 기준: 브랜치 `feature/hud-block42-survey-20261025`, HEAD `3f8f83e`. 블록 4-1(아군 로스터)은 이 기준에 없다. [사실: `git log`]
- 문서만 썼다. 코드·씬·테스트·에셋 변경 0. Godot는 실행하지 않았다. [사실]
- 방법: 정적 읽기, grep, 분류용 파이썬 스크립트 1개(스크래치패드, 저장소 밖). [사실]
- 표기: 줄마다 **[사실]**(코드 file:line 또는 내가 돌린 명령) / **[추정]**(추론). 합격·불합격 판정은 쓰지 않는다.
- 약어:
  - C = `scripts/battle_web_import_test.gd` (16,175줄. 제안서 기준 `2b08270`과 C는 바뀐 줄이 없다 [사실: `git diff --stat 2b08270 HEAD`])
  - EP = `scripts/battle3d/battle3d_engine_play.gd` (1,523줄. `2b08270` 뒤 EP:123-178에 58줄이 들어가 그 아래 줄 번호가 +58 밀렸다 [사실: `git diff`])
  - LP = `scripts/battle3d/lab_presentation.gd` (EP의 부모 클래스, EP:1)
  - SH = `scripts/battle3d/battle3d_scenario_shell.gd`, TC = `scripts/battle3d/battle3d_top_commands.gd`
  - P = `scenes/battle/Battle_Production.tscn`
  - T = `tests/scripts/`, S = `tests/scripts/support/`
- 딸린 표: `agent/data/HUD_BLOCK42_LAB_UI_TEST_DEPS_20261025.tsv` (테스트의 랩 UI 사용 178줄, file·line·요소·의존 종류·하네스 종류).

## 핵심

1. 2D 패널은 매 프레임(C:2250) 행동 부대 기준점을 화면 좌표로 바꾸고, 후보 12곳 중 이동 범위 칸과 덜 겹치고 가까운 곳에 놓는다(C:6292-6372). [사실]
2. 2D 5버튼과 방향 4버튼은 랩의 `request_attack/skill/strategy/defend/wait`, `confirm_facing`과 엔진 함수가 하나씩 같다. 새 쓰기는 필요 없다. [사실: C:1446-1470, EP:618·644·665·946·1192·535]
3. 3D 위치는 `camera.unproject_position(3D 좌표)`로 구할 수 있다. 카메라는 직교 투영이라 "카메라 뒤" 문제는 없다(LP:50). 회전(yaw)·줌·이동 때마다 다시 계산해야 한다. [사실: LP:210-213 / 추정: 방법]
4. 랩 UI를 셸에서 숨기면 랩 단독 테스트 63파일은 영향이 없다. 셸을 쓰는 테스트는 10파일이다. [사실: grep / 추정: 영향]
5. 숨김 방법별 셸 테스트 예상: 화면 밖 이동(정보 상자 포함) 9/10, 화면 밖 이동(정보 상자는 visible=false) 10/10, visible=false 10/10(단 방향 줄은 랩이 매 프레임 다시 켬), 알파 0 10/10(단 보이지 않는 버튼이 클릭을 먹음), CanvasLayer 숨김 10/10. [추정: grep 근거]
6. 2D에서도 [대기]와 [턴 종료]는 같은 `_end_ally_turn_by_wait`를 부른다(C:1437-1439, C:1454). 추천: 둘 다 두고 같은 `lab.request_wait()`로 보낸다. [사실 / 추천]
7. N7 함수 본문은 제안서와 같다. 바뀐 것은 EP 줄 번호뿐이다(EP:1120 → EP:1178). 랩 특기 사유 글은 이미 있고, `skill_cost_up`일 때만 사유가 덜 정확하다. [사실]

---

## 1. 2D `FloatingAllyCommandPanel`

### 1-1. 노드와 연결

| 순서 | 노드 (P) | 글자(씬) | 누르면 (C) |
|---|---|---|---|
| 1 | `FloatingBasicAttackButton` (P:3458, 12..164 × 12..46) | "기본공격" | `try_basic_attack` (C:1446) |
| 2 | `FloatingUniqueSkillButton` (P:3467, y 52..86) | "고유특기" | `_on_unique_skill_button_pressed` (C:1448) |
| 3 | `FloatingTacticsButton` (P:3477, y 92..126) | "책략" | `_on_strategy_button_pressed` (C:1450) |
| 4 | `FloatingMoveButton` (P:3487, y 132..166) | "방어" | `_on_defend_button_pressed` (C:1452) |
| 5 | `FloatingWaitButton` (P:3496, y 172..206) | "대기" | `_end_ally_turn_by_wait` (C:1454) |

- 패널: `BattleUI/FloatingAllyCommandPanel` 176×214, z 200, 처음 숨김(P:3451-3456). 버튼 z 201(P:3459 등). [사실]
- 이름은 `FloatingMoveButton`이지만 글자는 "방어"이고 방어 함수에 연결된다(C:1452, C:6103, C:6238). [사실]
- 스타일: 패널 남색 바탕+금색 테두리 2px·모서리 8(C:6087-6092). 버튼 바탕 (0.16,0.18,0.23), 테두리 2px·모서리 6, 비활성은 회색(C:6169-6195). [사실]

### 1-2. 여는 조건

- 표시 여부는 `_should_show_floating_ally_command_panel`(C:6198-6219)이 정한다. 모두 참이어야 보인다. [사실]
  - `is_floating_ally_command_panel_requested`가 참(C:6201)
  - 대상 선택 단계(`attack_select`, `strategy`, `unique_skill_target_select`)가 아님(C:6203, C:6308-6313)
  - 전투 결과 미확정(C:6205), `is_demo_animating` 아님(C:6207), 자동전투 아님(C:6209)
  - `current_phase == ally_turn`(C:6211), 행동 부대 있음·아군·전투 슬롯 가능(C:6213-6218)
- 요청 플래그를 켜는 곳(`= true`) [사실]:
  - 아군 클릭 선택: `_select_ally_unit(…, true, true, false)`(C:2639) → C:14526 `= should_open_command_panel`
  - 방향 확정 뒤(C:6773), 공격 취소(C:8027), 책략 취소(C:3821), 특기 취소(C:3769), 특기 실행 실패(C:5507)
- 자동 선택(턴 시작 등)은 `should_open_command_panel=false`로 부른다(C:3271, C:6927, C:8472). 그래서 클릭하거나 방향을 확정해야 패널이 뜬다. [사실]
- 랩도 선택할 때 `_select_ally_unit(unit,false,false,false)`(EP:508)로 부른다. 그래서 랩 선택만으로는 엔진 플래그가 켜지지 않는다. [사실]
- 갱신: `_process`가 매 프레임 `_refresh_floating_ally_command_panel()`(C:2250). 카메라 연동(C:2569), 단계 변경(C:6009), 기세 변경(C:6843)에서도 부른다. [사실]

### 1-3. 위치 계산 (유닛을 따라감) — 이번에 전부 읽음

1. 기준점: `ui_anchor = _world_to_battle_ui_position(_get_visual_anchor_position_for_unit(active_unit_state))`(C:6296). [사실]
   - `_get_visual_anchor_position_for_unit`(C:14358-)는 슬롯 이름(`ally_main` 등)별 기준점 함수를 고른다. [사실]
   - `_world_to_battle_ui_position`(C:15806-15813): 카메라가 있으면 `화면중심 + (월드좌표 − 카메라위치)`를 카메라 회전만큼 되돌린 뒤 `× camera.zoom`. 없으면 `canvas_transform × world`. [사실]
2. 크기: 현재 크기와 최소 크기 중 큰 값. 0이면 176×214(C:6297-6303). [사실]
3. 후보 12곳(C:6336-6351), 간격 `ANCHOR_GAP=22`(C:64) [사실]:
   - 가까운 후보 8곳(`NEAR_CANDIDATE_COUNT=8`, C:68): 오른쪽 가운데, 왼쪽 가운데, 위 가운데, 아래 가운데, 오른쪽 아래, 왼쪽 아래, 오른쪽 위, 왼쪽 위.
   - 먼 후보 4곳: 화면 네 모서리(여백 12, C:63). 순서는 오른쪽 아래, 왼쪽 아래, 오른쪽 위, 왼쪽 위.
4. 각 후보를 화면 안으로 자른다: x·y를 `[12, 화면 − 패널 − 12]`로 clamp(C:6354-6358). [사실]
5. 점수(낮을수록 좋음, C:6361-6372) [사실]:
   - 패널 사각형을 10만큼 키운 뒤(`GRID_AVOID_PADDING=10`, C:65) 보이는 이동 범위 칸들과 겹친 넓이의 합
   - + 패널 중심과 기준점 거리 × 8(`DISTANCE_SCORE_WEIGHT`, C:66)
   - + 먼 후보면 1,000,000(`FAR_FALLBACK_SCORE`, C:67)
   - + 후보 순번 × 0.01(같은 점수일 때 앞 후보)
   - 비교 기본값은 `기준점 + (52, −높이−22)`를 clamp한 위치(C:6320-6324).
6. 피하는 칸 = `move_range_cells` 중 보이는 것만(C:6385-6401). 칸의 화면 크기 = 칸 크기 × 카메라 줌 × 스케일. [사실]
   - 적 부대, 로스터, 로그 같은 다른 HUD는 피하지 않는다. [사실: 코드에 없음]
7. 위치를 정할 때마다 패널과 버튼 `mouse_filter = STOP`을 되돌린다(C:6278-6289, C:6295). [사실]

### 1-4. 버튼 활성 조건 (C:6222-6268)

- 공통 `can_issue_ally_command` = `ally_turn` + 연출 아님 + `_is_active_ally_action_available()`(C:6229-6233). [사실]
  - `_is_active_ally_action_available`(C:14051-14060): 행동 부대 있음, 아군, 생존, 혼란류 아님(`_is_unit_confused`), 아직 행동 안 함. [사실]

| 버튼 | 비활성 조건 | 글자 | 툴팁 |
|---|---|---|---|
| 기본공격 | `not can_issue`(C:6235) | 씬 그대로 "기본공격" | 코드·씬 모두 설정 없음 [사실: grep] |
| 고유특기 | `phase != ally_turn or not _can_use_unique_skill(active)`(C:6244). `can_issue`는 안 씀 | 데이터 있으면 `"%s · 기세 %d" % [name, _get_effective_unique_skill_cost(...)]`(C:6246-6250), 없으면 "고유특기"(C:6258) | 있으면 `"%s\n공용 기세 %d/%d · 소비 %d" % [description, 아군 기세, MAX_MOMENTUM(10), 비용]`(C:6251-6256), 없으면 "고유기 데이터 없음"(C:6259) |
| 책략 | `not can_issue or not _can_use_strategy(active)`(C:6261) | `STRATEGY_NAME`="책략"(C:81, C:6262) | 지력 < 80이면 "지력 80 이상 필요", 아니면 ""(C:6263-6266) |
| 방어 | `not can_issue`(C:6237) | "방어"(C:6238) | ""(C:6239) |
| 대기 | `not can_issue`(C:6241) | 씬 그대로 "대기" | 설정 없음 [사실: grep] |

- `_can_use_unique_skill`(C:3631-3654): 단계, 특기 연출 중 아님, 행동 부대 본인, 생존, 행동 가능, 재사용 대기 0, 특기 데이터 있음, `_has_valid_unique_skill_action`(유효 비용으로 기세 확인 + 대상 있음, C:4423-4428). [사실]
- `_can_use_strategy`(C:3832-3848): 단계, 연출·자동 아님, 생존, 아군, 미행동, 혼란 아님, 지력 ≥ 80. **사거리 안 적 여부는 보지 않는다.** [사실]

### 1-5. 닫는 조건

- `_should_show…`가 거짓이 되면 다음 갱신에서 `visible=false`(C:6225-6227). 단계가 `enemy_turn`·`resolving`·`facing_select`가 되거나 연출·자동·결과가 시작되면 닫힌다. [사실]
- 명시적으로 닫는 곳 [사실]:
  - 공격 대상 선택 진입(C:3462), 특기 대상 선택 진입(C:3704), 책략 대상 선택 진입(C:3808) → `_hide_…_for_tactical_selection`(C:6271-6275): 플래그 끔, 숨김, `mouse_filter=IGNORE`.
  - 책략 실행(C:3962-3964), 특기 실행 시작(C:4744), 방어(C:6442-6444): 플래그 끔·숨김.
- 대기(`_end_ally_turn_by_wait`, C:6482-6517)는 직접 숨기지 않는다. `enemy_turn`으로 바꾸면서 `_set_phase` 안 갱신(C:6009)으로 닫힌다. [사실: 코드 / 추정: 순서]

### 1-6. 방향 선택 위치 계산

- 표시: `_set_phase`에서 `facing_select`면 `_show_facing_selection_panel()`, 아니면 숨김(C:6004-6007). 이동 뒤 `_enter_post_move_facing_selection`(C:6735-6747)이 이 단계로 바꾼다. [사실]
- `FacingSelectionPanel`(P:3776, 720..1200 × 878..980, 글자 버튼 4개)은 **늘 숨긴다**(C:6594-6595). 실제로 쓰는 것은 `FacingArrowPanel`(P:3824)이다. [사실]
- `_position_facing_arrow_panel_near_ally`(C:6620-6634) [사실]:
  - 패널을 화면 전체 크기로 펼친다(position 0, size = 화면).
  - 화살표 4개를 행동 부대의 **이웃 칸 위에** 놓는다: 위 (0,−1) "↑", 아래 (0,+1) "↓", 왼쪽 (−1,0) "←", 오른쪽 (+1,0) "→".
- `_place_facing_arrow_button_on_cell`(C:6637-6659) [사실]:
  - 칸이 격자 밖이거나 칸 크기가 0이면 그 버튼은 숨기고 비활성.
  - 크기 = 칸 크기 × 0.96(`FACING_ARROW_BUTTON_SIZE_SCALE`, C:410).
  - 위치 = `_world_to_battle_ui_position(grid_to_world(칸)) − 크기/2`.
- 카메라가 움직이면 다시 놓는다(C:2566-2567). 등장 애니메이션(0.12초 커짐, C:6715-6733). 글꼴 36, 타일 스타일 스크립트(C:6680-6702). [사실]
- 누르면 `_select_post_move_facing(방향)`(C:1455-1470). 값은 "left/right/up/down"(C:378-381). [사실]

---

## 2. 3D 매핑

### 2-1. 버튼 ↔ 랩 함수 ↔ 엔진 함수

| 2D 버튼 | 2D 연결 (C) | 랩 함수 (EP) | 랩이 부르는 엔진 함수 (EP) | 대상 클릭 단계 (EP) |
|---|---|---|---|---|
| 기본공격 | `try_basic_attack` (C:1446) | `request_attack` (EP:660) | `try_basic_attack` (EP:665) | `_try_attack_enemy_target_from_attack_select` (EP:716) |
| 고유특기 | `_on_unique_skill_button_pressed` (C:1448) | `request_skill` (EP:1183) | `_on_unique_skill_button_pressed` (EP:1192) | `_try_use_unique_skill_on_target` (EP:1238) |
| 책략 | `_on_strategy_button_pressed` (C:1450) | `request_strategy` (EP:940) | `_on_strategy_button_pressed` (EP:946) | `_try_use_strategy_on_target` (EP:1005) |
| 방어 | `_on_defend_button_pressed` (C:1452) | `request_defend` (EP:634) | `_on_defend_button_pressed` (EP:644) | — |
| 대기 | `_end_ally_turn_by_wait` (C:1454) | `request_wait` (EP:609) | `_end_ally_turn_by_wait` (EP:618) | — |
| 방향 ×4 | `_select_post_move_facing.bind(dir)` (C:1455-1470) | `confirm_facing(dir)` (EP:530) | `_select_post_move_facing` (EP:535) | — |
| [턴 종료] | `_end_ally_turn_by_wait` (C:1438-1439) | 상단 버튼 → `lab.request_wait()` (SH:74) | `_end_ally_turn_by_wait` (EP:618) | — |

- 모든 엔진 함수가 15개 쓰기 목록 `FIFTEEN`(S/battle3d_option_harness.gd:7-9) 안에 있다. 새 쓰기는 없다. [사실]
- 랩 함수는 엔진 호출 앞에 `_input_locked()`(EP:565-583)와 거절 사유 검사를, 뒤에 수락 확인(행동 완료 플래그·이벤트 수)을 붙인다. [사실: EP:609-632 등]
- 랩 단축키: F = 공격(EP:542-544). 나머지는 단축키 없음(EP:21-22 주석). [사실]

### 2-2. 활성 조건 차이 (2D 패널 vs 랩 버튼)

| 버튼 | 2D (C) | 랩 (EP) | 차이 |
|---|---|---|---|
| 공격 | `can_issue` (C:6235) | 단계·연출·행동자·재생·종료·자동 (EP:415) | 랩은 행동 완료·혼란을 안 본다. 눌러도 엔진이 거절하고 랩이 사유를 띄운다(EP:666-668). [사실] |
| 대기·방어 | `can_issue` | `_ally_command_block_reason` (EP:594-607) | 랩은 혼란을 안 본다(제안서에도 있음). [사실] |
| 책략 | `can_issue` + `_can_use_strategy` | + `_get_strategy_targets` 비어 있으면 비활성 (EP:937) | 사거리 안 적이 없을 때 2D는 켜짐, 랩은 꺼짐. [사실] |
| 특기 | `_can_use_unique_skill` | 사전 검사 4개 + `_can_use_unique_skill` (EP:1169-1181) | 최종 판정은 같은 엔진 함수. [사실] |
| 패널 자체 | 자동전투 중 숨김 (C:6209) | 랩 버튼은 보이고 비활성 | [사실] |

### 2-3. "유닛 옆" 3D 화면 좌표 후보

- 랩 카메라: 직교 투영(LP:50), `camera.size = zoom`(LP:211), 위치 = focus + (sin yaw·43, 40, cos yaw·43), `look_at(focus)`(LP:212-213). [사실]
- 카메라는 매 프레임 `_update_camera()`(LP:222). 줌 20..70(LP:252), 회전 Q/E·가운데 드래그(LP:221, LP:262, LP:275), 이동 WASD, Home 초기화(LP:269). [사실]
- 셸 HUD는 `process_priority = 100`(battle3d_top_hud.gd:14)으로 랩 다음에 돈다. 위치 계산을 그 자리에서 하면 같은 프레임 카메라를 쓴다. [사실: 코드 / 추정: 효과]

| 방법 | 내용 | 근거 | 위험 |
|---|---|---|---|
| A. `camera.unproject_position(views[id].position + 높이)` | 부대 모델 위치(재생 중 움직이는 위치)를 화면 좌표로 | 테스트가 이미 같은 함수로 칸을 클릭한다(S/battle3d_engine_attack_harness.gd:45, T/test_battle3d_engine_move_integration.gd:21) [사실]. 배지는 +5.2 높이(EP:458) [사실] | 이동 재생 중 패널이 따라 움직인다. 2D와 비슷 [추정] |
| B. `unproject_position(board.world(grid_cell))` | 엔진 칸 중심(`lab_heightfield.gd:25-28`) | `grid_to_world_3d`(battle3d_grid_projection.gd:10-11)도 같은 값 [사실] | 재생 중에는 모델과 어긋난다 [추정] |
| C. 칸 네 모서리를 각각 투영 | 칸의 화면 사각형(회전 시 평행사변형의 경계 상자) | 2D `_get_visible_tactical_cell_ui_rects`(C:6385) 대응 | 범위 칸(EP:512-515 원판)마다 4번 투영. 계산량 늘어남 [추정] |
| D. 3D 공간 UI(Label3D·Sprite3D) | 버튼을 3D에 둔다 | 배지가 Label3D 빌보드(EP:202-208) [사실] | Button이 아니라서 툴팁·비활성 스타일·클릭을 새로 만들어야 한다 [추정] |
| E. 고정 위치 | 유닛을 따라가지 않음 | — | 2D와 다르다 [추정] |

- `battle3d_grid_projection.gd`에는 화면 투영 함수가 없다. 칸→3D(`grid_to_world_3d`, :10)와 화면 광선→칸(`world_to_grid_from_ray`, :13)뿐이다. 그래서 A·B는 `Camera3D.unproject_position`을 따로 불러야 한다. [사실]
- 공통 위험 [추정]:
  - **회전**: yaw가 바뀌면 격자 "위"가 화면 위가 아니다. 방향 화살표를 이웃 칸 투영 위치에 놓으면 자리는 맞지만 "↑" 글자 방향이 화면과 어긋난다.
  - **줌**: 직교 크기 20..70이면 칸 화면 크기가 약 3.5배 바뀐다. 2D처럼 화살표 크기 = 칸 크기면 줌마다 다시 재야 한다.
  - **화면 밖**: 2D처럼 clamp하면 패널이 유닛과 멀어진다. 유닛이 화면 밖이면 숨길지, 모서리에 둘지 정해야 한다. 직교라 `is_position_behind` 문제는 없다.
  - **HUD 겹침**: 2D 점수는 이동 범위 칸만 피한다(C:6361-6372). 3D 셸에는 상단 HUD 497..1417×20..120, 상단 버튼 1435..1789×27..95, 로그 39..301×793..1055, 적 로스터 1595..1865×156..680, 4-1 아군 로스터 54..324×150..674가 있다(H1·SH·TC 값). 먼 후보 "오른쪽 위 모서리"는 1920×1080에서 1732..1908 × 12..226이라 상단 버튼 줄과 겹친다(계산). HUD 사각형을 점수에 넣어야 한다.
  - **클릭 가로채기**: 패널은 `MOUSE_FILTER_STOP`. 이웃 칸(공격·책략 대상) 위에 오면 그 칸 월드 클릭을 막는다. 랩 월드 클릭은 `_unhandled_input`(EP:540)이라 GUI가 먼저 먹는다.
  - **해상도**: 테스트 창이 1280×800(S/battle3d_scenario_harness.gd:21 등)과 1920×1080(T/test_battle3d_top_hud.gd:91 등) 두 가지다. 위치 테스트는 두 크기를 다 봐야 한다.

---

## 3. 랩 UI를 숨기면 영향받는 테스트

### 3-1. 범위와 방법

- 검색: `tests/scripts/*.gd`, `tests/scripts/support/*.gd`에서 `lab.(attack_button|wait_button|defend_button|strategy_button|skill_button|facing_ui|auto_button|speed_button|option_toggle|option_panel|roster_label|turn_label|momentum_label|target_info|combat_log|ai_level_buttons|ai_level_label|info|status)`와 `"방향 "`. [사실]
- 결과: 42파일, 178줄. 전체 줄은 딸린 TSV. [사실: 스크립트 출력]
  - `slab.wait_button`(T/test_battle3d_option_strategy_gaps.gd:44)은 정규식 `\blab`에 안 걸려 손으로 더했다. [사실]
- `test_battle3d_*.gd`는 73파일이다. 셸(`battle3d_scenario_harness.gd`)을 쓰는 것은 10파일이다. [사실: grep]
  - 셸 10: enemy_roster, lab_roster_label_offscreen, log_hud, scenario_defeat, scenario_gaps, scenario_new_battle, scenario_start, scenario_victory, top_commands, top_hud.
  - 나머지 63파일은 랩 씬을 직접 만든다(S/battle3d_wait_harness.gd:33 등). [사실]
- **숨김을 셸에서 하면(블록 1의 `_place_lab_commands` SH:185-194 방식) 랩 단독 63파일은 숨김 코드를 거치지 않는다.** [사실: 구조 / 추정: 영향 0]

### 3-2. 4-2 숨김 대상(5버튼·방향 줄·정보 상자)에 닿는 테스트 — 종류별

| 요소 | 의존 종류 | 줄 수 | 대표 file:line |
|---|---|---|---|
| wait_button | pressed.emit | 9 | S/battle3d_wait_harness.gd:48, T/test_battle3d_option_ai_level.gd:43·50·59, T/test_battle3d_enemy_strategy_replay.gd:25, T/test_battle3d_scenario_defeat.gd:24·44, T/test_battle3d_scenario_gaps.gd:75, T/test_battle3d_option_strategy_gaps.gd:44 |
| wait_button | .disabled | 11 | T/test_battle3d_wait_rejections.gd:19·55·89·137, T/test_battle3d_wait_default_round.gd:43·47, T/test_battle3d_defend_default_round.gd:49·53, S/battle3d_wait_harness.gd:108, T/test_battle3d_scenario_defeat.gd:23, T/test_battle3d_scenario_gaps.gd:74 |
| wait_button | .tooltip_text | 1 | T/test_battle3d_wait_default_round.gd:43 |
| defend_button | emit / disabled / tooltip | 2 / 8 / 1 | S/battle3d_defend_harness.gd:17·88·93, T/test_battle3d_defend_rejections.gd:21·57·92·139 |
| attack_button | emit / disabled | 2 / 1 | S/battle3d_engine_attack_harness.gd:49, T/test_battle3d_scenario_defeat.gd:44, T/test_battle3d_enemy_turn_locks.gd:95 |
| strategy_button | emit / disabled / tooltip | 2 / 6 / 2 | S/battle3d_strategy_harness.gd:57·116, T/test_battle3d_strategy_default_round.gd:79·88, T/test_battle3d_strategy_rejections.gd:19·151 |
| skill_button | emit / disabled / tooltip | 2 / 5 / 3 | S/battle3d_skill_harness.gd:60·142, T/test_battle3d_skill_default_round.gd:56·66, T/test_battle3d_skill_rejections.gd:19 |
| 5버튼 목록 | disabled(자동 중) | 1 | S/battle3d_auto_harness.gd:92-93 |
| facing_ui | 자식 글자 "방향 left/right"로 찾아 emit | 10 | S/battle3d_wait_harness.gd:105-106, S/battle3d_defend_harness.gd:89-90, S/battle3d_enemy_turn_harness.gd:197-198, T/test_battle3d_wait_default_round.gd:44-45 외 |
| facing_ui | 모든 자식 emit | 1 | T/test_battle3d_enemy_turn_locks.gd:24 |
| facing_ui | .visible | 2 | T/test_battle3d_auto_stop_rejections.gd:30 (참 기대), T/test_battle3d_enemy_turn_locks.gd:95 (거짓 기대) |
| info | .text | 2 | S/battle3d_defend_harness.gd:73, T/test_battle3d_defend_default_round.gd:78 |
| info | 사각형·크기 | 4 | T/test_battle3d_top_hud.gd:47·108·109·115 |
| status (정보 상자 안 Label, LP:196) | .text | 28 | T/test_battle3d_wait_rejections.gd:23 외 |
| target_info | .text | 1 | S/battle3d_engine_attack_harness.gd:153 |

- 위치·화면 좌표 클릭으로 5버튼·방향 줄을 누르는 테스트는 없다. 모두 `pressed.emit()`이다. [사실: grep]
- 실제 마우스 클릭(`push_input`)은 상단 버튼·옵션 버튼(T/test_battle3d_top_commands.gd:23-33, S/battle3d_option_harness.gd:58-69)과 월드 칸(S/battle3d_engine_attack_harness.gd:41-45, T/test_battle3d_engine_move_integration.gd:20-22, T/test_battle3d_engine_attack_rejections.gd:49-53)뿐이다. [사실]

### 3-3. 셸 테스트 10파일의 의존

| 파일 | 4-2 대상 의존 | 종류 |
|---|---|---|
| test_battle3d_scenario_defeat.gd | wait_button (:23-24), 5버튼 (:44) | disabled, emit [사실] |
| test_battle3d_scenario_gaps.gd | wait_button (:74-75) | disabled, emit [사실] |
| test_battle3d_top_hud.gd | info 상자 사각형 (:47-49, :108-117), 보이는 랩 Control 겹침 검사 (:35-42), `h.press_wait` | rect, visible, emit [사실] |
| test_battle3d_log_hud.gd | 보이는 랩 Control과 로그 패널 겹침 (:59-63), `h.press_wait` | visible, emit [사실] |
| test_battle3d_top_commands.gd | 셸이 [턴 종료] 상태를 `lab.wait_button.disabled/tooltip_text`에서 읽음(SH:181-183) → :117·:121 | 간접 disabled·tooltip [사실] |
| test_battle3d_enemy_roster.gd | `h.press_wait` | emit [사실] |
| test_battle3d_lab_roster_label_offscreen.gd | `h.press_wait` | emit [사실] |
| scenario_start / scenario_new_battle / scenario_victory | 없음 (auto·speed 버튼만) | — [사실] |

- `h.press_wait` = `lab.wait_button.pressed.emit()`(S/battle3d_wait_harness.gd:47-48). [사실]

### 3-4. 숨김 방법별 예상 (코드 변경 없이 grep으로 센 값)

- 전제: 숨김은 셸에서 한다. 대상은 5버튼, `facing_ui`, 정보 상자(`lab.info`의 CanvasLayer 바로 아래 PanelContainer). [추정: 4-2 설계]
- `emit()`은 숨김·화면 밖·비활성과 상관없이 연결된 함수를 부른다. [추정: Godot 동작]
- 랩은 버튼 `disabled`·`tooltip_text`를 보임 여부와 상관없이 매 프레임 쓴다(EP:415-427). [사실]
- 랩은 `facing_ui.visible`을 매 프레임 쓴다(EP:407). 버튼·정보 상자의 `visible`·`position`은 만든 뒤 다시 쓰지 않는다(EP:238, EP:251-276, LP:168). [사실]
- 셸은 정보 상자의 오른쪽 끝을 상단 글자 위치 기준으로 쓴다(SH:220-228). [사실]

| 방법 | 셸 10파일 예상 | 랩 단독 63파일 | 근거·주의 |
|---|---|---|---|
| ① 화면 밖 이동 x=4000 (정보 상자 포함) | 9/10. top_hud 실패 예상 | 63/63 | 정보 상자 오른쪽 끝이 4000+ → SH:222 `left_limit`이 4006+ → 라운드·기세 글자가 화면 밖으로 간다. T/test_battle3d_top_hud.gd:72 "가운데 정렬" 기대와 어긋난다 [추정]. 게임 화면에서도 글자가 사라진다 [추정] |
| ①' 화면 밖 이동 (5버튼·방향 줄만) + 정보 상자는 visible=false | 10/10 | 63/63 | `get_global_rect()`는 보임 여부를 안 본다 → `left_limit` 그대로 [추정]. 겹침 검사(top_hud:40, log_hud:63)는 `is_visible_in_tree()`인 것만 센다 → 대상이 줄어들 뿐 [사실: 코드] |
| ② visible=false (전부) | 10/10 | 63/63 | 단 `facing_ui`는 랩이 EP:407에서 매 프레임 다시 켠다 → 방향 선택 때 랩 방향 줄이 다시 보인다. 셸 테스트는 방향 선택 화면을 검사하지 않아 못 잡는다 [사실: grep / 추정: 결과] |
| ③ modulate 알파 0 | 10/10 | 63/63 | 보이지 않는 버튼이 여전히 클릭을 받는다(Button 기본 `MOUSE_FILTER_STOP` [추정]). 24..664×254..292와 24..340×300..331에서 월드 클릭이 막히고, 실수로 명령이 나갈 수 있다 [추정]. 겹침 검사 대상은 지금과 같다 |
| ④ 숨긴 CanvasLayer 아래로 옮기기 (reparent) | 10/10 | 63/63 | 새 부모가 CanvasLayer여야 한다. SH:221과 T/test_battle3d_top_hud.gd:48은 "CanvasLayer가 나올 때까지 부모로 올라가기"다. 일반 Node 아래로 옮기면 `Control` 변수에 Node가 들어가 오류 → 셸이 매 프레임 이 함수를 부르므로 셸 10파일 전부 위험 [추정] |
| ⑤ 랩 CanvasLayer 자체 숨김 (`layer.visible=false`) | 10/10 | 63/63 | 공격 층(EP:247)에는 대상 정보 상자도 있다(이미 x=3446, H1 rects TSV:67). LP 층(LP:165)에는 도움말(LP:201)·hover(LP:206)도 있다 → 같이 숨는다 [사실: 코드]. `facing_ui.visible` 플래그는 랩 값 그대로라 테스트 기대도 그대로 [추정] |
| (참고) 랩 코드에서 직접 숨김 | — | ② 방식이면 1파일 위험 | T/test_battle3d_auto_stop_rejections.gd:30이 `facing_ui.visible` 참을 기대 [사실]. 노드를 지우면 42파일 + SH:181-183 모두 깨진다 [추정] |

- 방향 줄만 따로 보면: ① 화면 밖 이동이 가장 단순하다. 랩이 위치는 다시 쓰지 않기 때문이다(EP:238). [사실: 코드 / 추정: 평가]

---

## 4. 랩 [대기] vs 상단 [턴 종료] 중복

### 4-1. 사실

- 2D: `wait_button`(하단 명령줄, C:1437), `end_turn_button`(C:1438-1439), `floating_wait_button`(C:1454) 셋 다 `_end_ally_turn_by_wait`에 연결된다. [사실]
- 2D 하단 `wait_button`은 숨긴다(C:6128-6130). `end_turn_button`은 숨기지 않는다(툴팁 "턴 종료", C:6134-6135). 그래서 2D 화면에는 패널 [대기]와 [턴 종료]가 함께 보인다. [사실: 코드 / 추정: 화면]
- `_end_ally_turn_by_wait`(C:6482-6517)는 **행동 부대 하나**만 행동 완료로 만들고 적 턴으로 넘긴다. 아군 전원 종료가 아니다. [사실]
- 3D: 랩 [대기] → `request_wait`(EP:259) → 엔진 `_end_ally_turn_by_wait`(EP:618). 상단 [턴 종료] → `lab.request_wait()`(SH:74). 같은 길이다. [사실]
- 상단 [턴 종료]의 비활성·툴팁은 랩 `wait_button`에서 읽는다(SH:181-183). [사실]
- 테스트가 [턴 종료] 클릭 = `_end_ally_turn_by_wait` 1번을 검사한다(T/test_battle3d_top_commands.gd:117). [사실]

### 4-2. 선택지

| 안 | 내용 | 2D와 같음 | 장점 | 단점 |
|---|---|---|---|---|
| A | 패널 [대기]와 상단 [턴 종료] 둘 다 두고, 둘 다 `lab.request_wait()` | 같음 | 2D 그대로. 엔진 호출 1곳. 테스트 기대 그대로 [추정] | 같은 일을 하는 버튼 2개 [사실] |
| B | 패널에서 [대기]를 빼고 4버튼 | 다름 | 중복 없음 | 2D와 달라진다. 유닛 옆에서 바로 대기를 못 누른다 [추정] |
| C | 상단 [턴 종료]를 "아군 전원 대기"로 바꿈 | 다름 | 이름과 동작이 맞는다 | 엔진에 그런 함수가 없다. 랩에서 대기를 반복하면 적 턴이 사이사이 끼어든다(C:6516-6518). 새 동작이라 이번 범위 밖 [추정] |
| D | A와 같되 랩 `wait_button` 노드는 숨긴 채 남겨 상태 출처로 계속 씀 | 같음 | SH:181-183, 랩 테스트 그대로 [추정] | 숨은 노드가 남는다 |

- **추천(결정 아님): A + D.** [추천]
  - 2D도 두 버튼이 같은 엔진 함수를 부른다. 그대로 따르는 것이 이식 원칙에 맞다. [사실 근거]
  - 엔진 쓰기 경로가 `request_wait` 하나로 남는다. 거절 사유도 하나다(EP:588-589). [사실]
  - 랩 `wait_button`을 남기면 상단 버튼 상태 코드(SH:181-183)와 테스트 20여 줄을 고치지 않는다. [추정]
  - 패널 [대기] 비활성·툴팁도 같은 `_wait_block_reason()`(EP:588) 값을 쓰면 상단 [턴 종료]와 늘 같다. [추정]

---

## 5. N7 `_get_effective_unique_skill_cost` 갱신

### 5-1. 제안서(`agent/HUD_READ_PROPOSALS_BLOCKS_3_4_5_20261024.md`)와 비교

| 항목 | 제안서 | 지금 (HEAD `3f8f83e`) | 바뀜 |
|---|---|---|---|
| 위치 | C:5486-5490 (제안서 :284) | C:5486-5490 | 없음 [사실] |
| 본문 | 기본 비용 `max(0)`, `skill_cost_up`이면 `+max(magnitude,1)`, `min(MAX_MOMENTUM)` | 같음 | 없음 [사실] |
| 2D 사용처 | C:6246 | C:6246(글자), C:4426(`_has_valid_unique_skill_action`), C:4538(AI 점수), C:4662(적 분산), C:4719(실행 시작) | 제안서는 C:4426만 언급. 나머지 3곳은 이번에 확인 [사실] |
| 랩 특기 기세 판단 줄 | EP:1120 | EP:1178 | 줄 번호만 +58 [사실] |
| 랩 사유 함수 범위 | EP:1111-1123 | EP:1169-1181 | 줄 번호만 [사실] |
| 랩 버튼 함수 줄 | 대기 EP:551, 방어 576, 공격 602, 책략 882, 특기 1125, 방향 472/477 | 609, 634, 660, 940, 1183, 530/535 | 줄 번호만 [사실] |
| 승인 상태 | 추천 후보 | 이번 조사는 새 읽기 승인 없음 | — |

- `skill_cost_up`을 거는 효과는 `skill_cost_debuff`다(battle_skill_resolver.gd:447-448). 특기 데이터에 1줄 있다(`data/heroes/generated/hero_unique_skills.json`, `grep -c` = 1). [사실]

### 5-2. 랩에 사유 글이 이미 있는가

- 있다. `_skill_block_reason`(EP:1169-1181)이 만든다. 버튼 툴팁(EP:427)과 거절 글(`_reject`, EP:479-481 → `status`)로 쓰인다. [사실]
  - "특기 불가 · 고유특기가 없는 부대입니다"(EP:1176)
  - "특기 불가 · 기세가 부족합니다 (필요 %d / 현재 %d)"(EP:1178) — **원래 비용** `skill.momentum_cost` 사용
  - "특기 불가 · 유효 대상이 없습니다"(EP:1179)
  - "특기 불가 · 엔진 조건을 충족하지 않습니다"(EP:1180)
  - 앞의 공통 사유: 전투 종료·자동·적 턴·연출·재생·단계·미선택·행동 완료(EP:594-607)
- 요청에 적힌 EP:1229-1244는 사유 함수가 아니라 `_click_skill_cell`이다. 거기 글은 "대상 아님 · 표시된 부대만 특기 대상입니다"(EP:1234), "행동 불가 · 엔진이 특기를 수락하지 않았습니다"(EP:1241). [사실]
- 책략·대기·방어 사유도 있다: EP:932-938, EP:588-607. 툴팁 쓰기는 EP:418·421·424. [사실]
- `skill_cost_up`일 때 [사실: 코드 / 추정: 화면]:
  - EP:1178은 원래 비용이라 통과할 수 있다.
  - 그다음 EP:1180 `_can_use_unique_skill` → C:4426(유효 비용)이 거짓 → 사유는 "엔진 조건을 충족하지 않습니다".
  - 그래서 버튼은 맞게 꺼진다. 사유 글만 덜 구체적이다.
- N7 없이 2D 글자 "특기명 · 기세 N"을 만들면 `skill_cost_up`일 때만 N이 작게 나온다(제안서 :309와 같음). [사실]
- 2D 특기 툴팁의 설명·기세 부분은 이미 읽는 값으로 만들 수 있다(`_get_unique_skill_for_unit`, `battle_momentum`, MAX 10은 battle_momentum_state.gd:6). [사실]
- 2D 책략 툴팁 "지력 80 이상 필요"는 `intelligence` 읽기(N10)가 필요하다. 랩 사유(EP:936)를 쓰면 새 읽기 0. [사실]

---

## 6. 4-1 겹침이 4-2에서 풀리는 방식

- 4-1 아군 로스터: 54..324 × 150..674 (H1 `agent/HUD_INVENTORY_H1_20261024.md:26`, 4-1 브랜치는 이 기준에 없음). [사실: 문서 / 미확인: 4-1 코드]
- 랩 사각형은 H1 실측(1920×1080) `agent/data/HUD_INVENTORY_H1_rects_20261024.tsv:58-74`. [사실: 문서]
- 확인(정리하며 추가): 블록 4-1 가지 `feature/hud-block41-ally-roster-actor-20261025`(끝 `ed4993b`) 결과 문서 §6-1의 실측 겹침(1920×1080 캡처)도 같다. 정보 상자 270×55, [공격] 130×38, [대기] 110×38, [방어] 10×38, 방향 줄 270×31. 현재 행동 장수 패널과 겹치는 랩 버튼은 없다. 그 가지에서는 로스터 위 [대기] 자리를 실제 마우스로 클릭하면 랩 [대기]가 눌렸다. [사실: 4-1 결과 문서]

| 요소 | 지금 사각형 | 로스터와 겹침 | 4-2 뒤 (①' 방식 예) | 4-2 뒤 겹침 | 대체하는 2D 요소 |
|---|---|---|---|---|---|
| 정보 상자 (LP:168, `info`·`status` 포함) | 22..492 × 20..205 | 270×55 (54..324 × 150..205) [계산] | 같은 자리, visible=false | 0 [추정] | 4-1 CurrentActorInfoHud(451..1463 × 825..1045, 제안서 :246) [사실: 문서] |
| 공격 (EP:251) | 24..184 × 254..292 | 130×38 [계산] | 4024..4184 × 254..292 | 0 | 패널 기본공격 |
| 대기 (EP:257) | 194..304 × 254..292 | 110×38 [계산] | 4194..4304 | 0 | 패널 대기 |
| 방어 (EP:263) | 314..424 × 254..292 | 10×38 [계산] | 4314..4424 | 0 | 패널 방어 |
| 책략 (EP:269) | 434..544 × 254..292 | 0 | 4434..4544 | 0 | 패널 책략 |
| 특기 (EP:276) | 554..664 × 254..292 | 0 | 4554..4664 | 0 | 패널 고유특기 |
| 방향 줄 (EP:238) | 24..340 × 300..331 (보일 때만) | 270×31 [계산] | 4024..4340 × 300..331 | 0 | 이웃 칸 화살표 4개 |
| 새 명령 패널 | — | — | 유닛 옆, 176×214 (P:3451) | 유닛이 화면 왼쪽이면 생길 수 있음 [추정] | — |
| 새 방향 화살표 | — | — | 이웃 칸 위, 칸 크기×0.96 | 유닛이 로스터 아래 칸이면 생길 수 있음 [추정] | — |

- ① 방식(정보 상자도 x=4000)이면 정보 상자 행은 4022..4492가 되지만 3-4의 상단 글자 문제가 생긴다. [추정]
- 도움말(24..960 × 710..759)과 hover(24..25 × 680..703)는 로스터와 겹치지 않는다(로스터 아래끝 674, 왼끝 54). [계산]
- 새 패널·화살표가 로스터와 겹치지 않게 하려면 2D 점수식(C:6361)에 로스터 등 HUD 사각형을 더해야 한다. 2D에는 그 항이 없다. [사실: 2D / 추정: 필요]

---

## 김작이 정할 것

1. 랩 UI 숨김 방법: ①'(버튼·방향 줄 화면 밖 + 정보 상자 visible=false), ⑤(CanvasLayer 숨김), 또는 다른 방법.
2. 정보 상자를 숨긴 뒤 SH:220-228의 "정보 상자 오른쪽으로 글자 밀기" 규칙을 남길지.
3. [대기]/[턴 종료] 중복: 추천은 A+D(둘 다 두고 같은 `request_wait`, 랩 `wait_button`은 숨긴 상태 출처). 결정 필요.
4. 3D 위치 기준: 모델 위치(A, 재생 따라감) 또는 엔진 칸(B).
5. 패널이 HUD(로스터·상단 버튼·로그 등)를 피하게 할지. 2D에는 없는 규칙이다.
6. 유닛이 화면 밖일 때: 숨김 / 모서리 / 화면 안으로 clamp.
7. 카메라 회전 때 화살표 글자(↑↓←→)를 화면 방향에 맞출지, 격자 방향 그대로 둘지.
8. 패널 여는 시점: 2D처럼 "클릭·방향 확정·취소 뒤"(N11 필요) 또는 랩 규칙("행동자 있음 + ally_turn").
9. N7 승인 여부. 승인하면 EP:1178 사유의 비용 기준도 맞출지.
10. 활성 조건 차이(공격·대기·방어의 혼란·행동 완료, 책략 사거리)를 2D 쪽에 맞출지, 랩 사유를 그대로 쓸지.

## 못 한 것

- Godot 실행 없음. 테스트 통과 수는 모두 grep 근거 추정이다. [사실]
- `emit()`이 숨긴 버튼에서 동작함, `get_global_rect()`가 보임 여부를 안 봄, Button 기본 `mouse_filter`, `CanvasLayer.visible`의 동작은 Godot 4.6에서 직접 확인하지 않았다. [미확인]
- 블록 4-1 코드(아군 로스터 층 번호, 마우스 필터)는 이 기준에 없어 읽지 못했다. 겹침 표의 로스터 값은 H1 문서 값이다. [미확인]
- `facing_ui` 실제 너비(316)는 H1 실측값이다. 글꼴에 따라 달라질 수 있다. [미확인]
- 2D 기준점 함수들(`_get_ally_visual_anchor_position` 등 슬롯별 10개) 본문은 열지 않았다. 고르는 부분(C:14358-)만 읽었다. [미확인]
- `skill_cost_debuff`를 가진 장수 이름과 기본 전투 등장 여부는 확인하지 않았다. [미확인]
- 테스트 분류 스크립트는 한 줄 기준 정규식이다. 여러 줄에 걸친 식이나 변수에 담아 쓰는 경우(예: `var b = lab.wait_button`)는 놓칠 수 있다. [사실: 방법]
