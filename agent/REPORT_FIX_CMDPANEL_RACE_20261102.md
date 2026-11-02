기준 화면: 없음(보이는 화면 변화 0). 대상: `tests/scripts/test_battle3d_command_panel.gd` 하나.
합격 기준: ① 3초 트윈에서 고치기 전 실패 / 고친 뒤 통과 ② 0.35초에서 3회 연속 통과 ③ 변경 경로 1개 ④ 올린 커밋에서 `Verify C-track refactor` success.

① 결과: 코드 커밋 `2dacaa95a9cb5a0b4e0e08542fe91293dbc9b104` push(원격 해시 = 로컬). 합격 기준 ②③④ 충족(0.35초 3/3 통과, 변경 1경로, C-track run `41426918702` success, shard 2 `[COMMAND_PANEL] checks=63 failures=[]`). ①은 고치기 전 실패는 확인, 고친 뒤 3초 통과는 버튼 클릭 구간 2건 때문에 미충족 → 김작 지시(11-02)로 그 2건은 고치지 않고 아래 "후속 숙제"에 적음.
② 가설 증명 결과: 가설 **맞음**[사실]. 3초 트윈에서 고치기 전 테스트는 168행 검사(`unit off screen … panel hidden`)와 바로 위 follow 검사가 실패했고, 고친 뒤에는 카메라 구간 검사가 모두 통과함. 3초 설정에서만 **뒤쪽 버튼 클릭 구간**에서 새 실패 2건이 나옴[사실]. 같은 트윈이 재시작 뒤 카메라를 옮기는 중에 실제 마우스 클릭이 패널 대신 보드에 떨어진 것으로 보임[추정].
③ 김작이 할 일: 후속 숙제(버튼 클릭 구간의 같은 경쟁 상태)를 언제·어떻게 다룰지 결정.

택한 해석: ① 2-2에서 기대한 168행 실패 문구가 `failures`에 있었으므로, follow 검사 실패 1건이 더 있어도 "실패 문구가 다르다"로 보지 않고 계속 진행함(같은 트윈 가설과 맞음). ② 2-3의 기대(`failures=[]`)가 어긋나 처음에는 커밋·push 전에 멈추고 보고함. 이후 김작 지시("현재 테스트 변경(1파일)을 그대로 커밋하고 push", 버튼 구간 실패 2건은 후속 숙제)에 따라 쉘 0.35초와 `git diff --stat` 1파일을 다시 확인한 뒤 커밋·push함.

---

## 시작 상태 [사실]

- HEAD `2bcf9568d8b6cc6381209cb8a8190e8bb208e2d3`, 가지 `feature/wm3d-intake-20261101`, `git status --short` 빈 출력.
- 150행 `h.expect(engine_print(b) == before, "N7 x20 for five allies (+ shell command_state): engine fingerprint unchanged")`, 151행 주석 `# Camera: the panel follows the unit model; …` 정확히 1곳(지시서와 같음).
- 쉘: 111행 `const CAMERA_CENTER_SEC := 0.35`, 115행 `var camera_tween: Tween`, 529~530행 `camera_tween = create_tween()` / `tween_property(lab, "focus", camera_target, CAMERA_CENTER_SEC)`. 테스트의 `h.shell`은 하네스가 연 쉘(126~129행). 지시서 코드의 이름과 다른 것 없음.

## 로컬 검증 결과 (Godot 4.6.2, `--headless --path . --script res://tests/scripts/test_battle3d_command_panel.gd`)

| 단계 | 조건 | 시간 | 결과 줄 원문 |
|---|---|---|---|
| 2-1 | 고치기 전, 0.35초 | 143초, exit 0 | `[COMMAND_PANEL] checks=62 failures=[]` |
| 2-2 | 고치기 전, **3.0초(임시)** | 145초, exit 1 | `[COMMAND_PANEL] checks=62 failures=["yaw 0.32/1.2/-0.9 x zoom 20/45/70: panel = rule around the unit model, inside the screen [[0.32, 20.0, \"\", [P: (346.0, 336.5), S: (176.0, 214.0)]], [1.2, 20.0, \"\", [P: (400.0, 268.0), S: (176.0, 214.0)]], [1.2, 45.0, \"\", [P: (435.0, 258.5), S: (176.0, 214.0)]], [-0.9, 20.0, \"\", [P: (869.0, 589.0), S: (176.0, 214.0)]]]", "unit off screen (zoom 20, focus far side): panel hidden"]` |
| 2-3 | **고친 뒤**, 3.0초(임시) | 144초, exit 1 | `[COMMAND_PANEL] checks=63 failures=["yi_sunsin button 4: engine fingerprint after a real panel click = after the lab\'s own button (writes [\"_try_direct_move_to_cell\"] / [\"_end_ally_turn_by_wait\", \"_select_ally_unit\"], phase ally_turn / ally_turn)", "yi_sunsin button 4: _end_ally_turn_by_wait first and called 0 time(s) on both paths"]` |
| 2-4 | 쉘 원복 | — | 111행 `const CAMERA_CENTER_SEC := 0.35`, `git diff --stat` = `tests/scripts/test_battle3d_command_panel.gd \| 7 +++++++` 1개(쉘 변경 0) |
| 2-5 #1 | 고친 뒤, 0.35초 | 140초, exit 0 | `[COMMAND_PANEL] checks=63 failures=[]` |
| 2-5 #2 | 고친 뒤, 0.35초 | 139초, exit 0 | `[COMMAND_PANEL] checks=63 failures=[]` |
| 2-5 #3 | 고친 뒤, 0.35초 | 140초, exit 0 | `[COMMAND_PANEL] checks=63 failures=[]` |

### 2-3 실패 앞뒤 원문 (로그 1581~1588행)

```
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ENEMY_TURN_START] ally=(3, 8) enemy=(14, 2) dist=17 ally_range=3 enemy_range=1
[ENEMY_AI_DECISION] actor_slot=enemy_main_01 actor=관우 preferred_target=ally_main_02/정도전 final_target=ally_main_02/정도전 dest=(10, 2) reason=ENGAGE action=ENGAGE wait_reason=
[ENEMY_TURN] round=1 actor=guan_yu acted remaining=2
[ALLY_TURN_RETURN] ally=(3, 8) enemy=(10, 2) dist=13 ally_range=3 enemy_range=1
[M3] FAIL yi_sunsin button 4: engine fingerprint after a real panel click = after the lab's own button (writes ["_try_direct_move_to_cell"] / ["_end_ally_turn_by_wait", "_select_ally_unit"], phase ally_turn / ally_turn)
[M3] FAIL yi_sunsin button 4: _end_ally_turn_by_wait first and called 0 time(s) on both paths
```

### 2-3 실패 해석

- [사실] 실패한 곳은 이번 변경 위치(150행 뒤)가 아니라 209~243행 버튼 클릭 구간. 반복마다 `h.press_restart(self)` 다음 3프레임만 기다리고 `real_click`(52~62행: 패널 중앙으로 마우스 이동 → 1프레임 → 누름 → 1프레임 → 뗌)을 함.
- [사실] 실제 클릭 경로의 첫 기록이 `_try_direct_move_to_cell`(보드 칸 클릭)이고, 같은 조건에서 랩 버튼을 직접 누른 경로는 `_end_ally_turn_by_wait`.
- [추정] 3초 트윈이 카메라를 옮기는 동안 패널도 따라 움직여, 마우스를 누를 때 패널이 이미 그 자리를 벗어나 클릭이 보드에 떨어짐. 0.35초에서는 2-5 3회와 CI 기존 기록 모두 이 구간이 통과했으므로 지금은 드러나지 않는 경쟁 상태일 수 있음.
- [미확인] 0.35초에서 이 구간이 CI에서 실패할 가능성. 버튼 4(`대기`)·`yi_sunsin` 조합에서만 실패한 이유.

## 2-6 작업 트리 [사실] (커밋 전)

```
$ git status --short
 M tests/scripts/test_battle3d_command_panel.gd
$ git diff --check
(출력 없음, 통과)
```

## 2-7 다른 테스트의 `lab.focus` 직접 대입 (`rg -n "lab\.focus *=" tests/scripts`, 판정 없음)

| 파일 | 줄 | 직접 대입 |
|---|---|---|
| `test_battle3d_block46b_marker_layout.gd` | 42 | 있음 |
| `test_battle3d_block46b_panel_avoid.gd` | 50, 55, 69 | 있음 |
| `test_battle3d_block46c_chip.gd` | 36 | 있음 |
| `test_battle3d_block46c_panel_hud.gd` | 40 | 있음 |
| `test_battle3d_block46d_panel_sweep.gd` | 94 | 있음 |
| `test_battle3d_block46_marker_mouse.gd` | 81 | 있음 |
| `test_battle3d_block46_unit_markers.gd` | 30 | 있음 |
| `test_battle3d_block6a_panel_body_gap.gd` | 75 | 있음 |
| `test_battle3d_block6a_roster_fold.gd` | 101 | 있음 |
| `test_battle3d_block7_outside_cells.gd` | 70, 110 | 있음 |
| `test_battle3d_command_panel.gd` | 173, 176(변경 뒤 줄 번호) | 있음 |
| `test_battle3d_edge_scroll_gates.gd` | 35 | 있음 |
| `test_battle3d_edge_scroll_limits.gd` | 63, 85 | 있음(96행은 비교식 `==`이라 제외) |

## 후속 숙제: 3초 설정에서 실패한 버튼 클릭 구간 2건 (이번에 고치지 않음)

| # | 검사 이름(형식 문자열) | 줄 번호(커밋 `2dacaa9` 기준 / 고치기 전) | 실패 줄 원문(2-3, 로그 1586·1587행) |
|---|---|---|---|
| 1 | `"%s button %d: engine fingerprint after a real panel click = after the lab's own button (writes %s / %s, phase %s / %s)"` | 240행 / 233행 | `[M3] FAIL yi_sunsin button 4: engine fingerprint after a real panel click = after the lab's own button (writes ["_try_direct_move_to_cell"] / ["_end_ally_turn_by_wait", "_select_ally_unit"], phase ally_turn / ally_turn)` |
| 2 | `"%s button %d: %s first and called %d time(s) on both paths"` | 241행 / 234행 | `[M3] FAIL yi_sunsin button 4: _end_ally_turn_by_wait first and called 0 time(s) on both paths` |

- 조건: 쉘 `CAMERA_CENTER_SEC`를 임시 3.0으로 둔 로컬 실행(2-3)에서만 나옴. 0.35초 로컬 3회와 CI run `41426918702`에서는 통과[사실].
- 구간: 버튼 반복(커밋 `2dacaa9` 기준 216~250행)이 반복마다 `h.press_restart(self)` 뒤 3프레임만 기다리고 `real_click`(52~62행)으로 실제 마우스 이동·누름·뗌을 함[사실].
- [추정] 재시작 뒤 트윈이 도는 동안 패널이 움직여 클릭이 보드 칸(`_try_direct_move_to_cell`)에 떨어짐. 168행과 같은 종류의 경쟁 상태.

## 바뀐 부분 diff 전체 (커밋 `2dacaa9`)

```diff
diff --git a/tests/scripts/test_battle3d_command_panel.gd b/tests/scripts/test_battle3d_command_panel.gd
index 3661574..96dafdb 100644
--- a/tests/scripts/test_battle3d_command_panel.gd
+++ b/tests/scripts/test_battle3d_command_panel.gd
@@ -148,6 +148,13 @@ func run() -> void:
 		for u in b.all_battle_unit_states.filter(func(x): return x.side == "ally"): lab.hud_skill_cost(u.unit_id)
 		h.shell.command_state()
 	h.expect(engine_print(b) == before, "N7 x20 for five allies (+ shell command_state): engine fingerprint unchanged")
+	# The shell centres the camera on the acting ally with a real-time tween (CAMERA_CENTER_SEC) that owns lab.focus.
+	# A frame-count wait can end before it does, and the tween would then pull the camera back in the middle of the
+	# camera checks below (CI race). So wait for the tween itself, with a real-time cap.
+	var centre_start := Time.get_ticks_msec()
+	while is_instance_valid(h.shell.camera_tween) and h.shell.camera_tween.is_running() and Time.get_ticks_msec() - centre_start < 5000:
+		await process_frame
+	h.expect(not (is_instance_valid(h.shell.camera_tween) and h.shell.camera_tween.is_running()), "camera centring tween finished before the camera checks")
 	# Camera: the panel follows the unit model; inside the screen; hidden when the unit is off screen.
 	var follow_bad := []
 	for yaw in [0.32, 1.2, -0.9]:
```

## CI [사실]

| run id | 워크플로 | 커밋 | 결과 | shard 2 `checks=` 줄 원문 |
|---|---|---|---|---|
| `41426918702` | Verify C-track refactor | `2dacaa95a9cb5a0b4e0e08542fe91293dbc9b104` | **success**(shard 0·1·2·3 모두 success) | `2026-11-02T10:31:10.8934894Z [COMMAND_PANEL] checks=63 failures=[]` |

- shard 2(job `125215641593`) 단계별: 1 Set up job = success / 2 Checkout full history = success / 3 Setup Godot 4.6.2 = success / 4 Versions = success / 5 Verify source assets exist = success / 6 Exclude 3D world map from shard import = success / 7 Import Godot resources and build class cache = success / 8 Static validators = skipped / 9 C-track Godot tests = success / 10 Tech-tree regression tests = success / 11 Military regression tests = success / 12 Diplomacy Trade Spy regression tests = success / 13 Project parse and WorldMap/Battle Main load = skipped / 14 Diff check = success / 28 Post Checkout full history = success / 29 Complete job = success.
- `Verify WorldMap3D`: 이 커밋에서는 돌지 않음(`gh run list --commit 2dacaa9…` 결과에 C-track 1건뿐, 경로 필터로 보임).

## 막힌 것

- 2-3 기대(`checks=63 failures=[]`)가 3초 설정에서 어긋남(버튼 클릭 구간 2건). 김작 지시로 그 2건은 고치지 않고 위 "후속 숙제"에 적음. 그 밖에 막힌 것 없음.

## 종료 루틴

1. 정본: 가지 `feature/wm3d-intake-20261101`, 코드 HEAD `2dacaa9`(이 보고서 커밋이 그 위에 올라감), 보고서 커밋 뒤 `git status --short` 빈 출력. 쉘 `CAMERA_CENTER_SEC := 0.35` 원복 확인.
2. 새로 만든 것: 이 보고서 1개. 로그는 scratchpad의 `fix_2_1.log` ~ `fix_2_5_3.log`(정본 밖).
3. push한 것: 코드 커밋 `2dacaa9`(`tests/scripts/test_battle3d_command_panel.gd` +7줄), 이어서 이 보고서 커밋(`[skip ci]`).
4. CI: C-track run `41426918702` success, shard 2 `[COMMAND_PANEL] checks=63 failures=[]`.
5. 김작이 결정할 것: 후속 숙제(버튼 클릭 구간 240·241행 검사의 같은 트윈 경쟁 상태)를 다룰지·언제 다룰지.
