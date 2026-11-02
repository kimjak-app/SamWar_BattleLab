기준 화면: 없음(보이는 화면 변화 0). 대상: `tests/scripts/test_battle3d_command_panel.gd` 하나.
합격 기준: ① 쉘 `CAMERA_CENTER_SEC` 임시 3.0초에서 고친 테스트 `failures=[]` ② 0.35초에서 3회 연속 통과 ③ 변경 경로 1개 ④ 올린 커밋에서 `Verify C-track refactor` success.

① 결과: 코드 커밋 `37f7f0d06fe7f839040aae9024951149ec0e4b21` push(원격 해시 = 로컬). 합격 기준 ①②③④ 모두 충족. C-track run `41435623340` success, shard 2 `[COMMAND_PANEL] checks=63 failures=[]`.
② 3.0초 증명 결과: 고친 테스트가 3.0초에서 `checks=63 failures=[]`(245초)[사실]. 앞 작업에서 실패하던 `yi_sunsin button 4` 2건이 사라짐 → 앞 작업에서 반쪽이던 증명이 닫힘.
③ 김작이 할 일: 아래 `rg` 표의 "범위 밖, 대기 없음" 2곳(facing 화살표 클릭 314행, manual stretch 클릭 340행)과 하네스 공용 대기 함수를 후속 숙제로 둘지 결정.

택한 해석: ① 1-3의 3번(facing 반복)에서 `h.click(unit.grid_cell)`(282행)은 **이미 행동 중인 같은 유닛**을 고르는 것이고 `h.click(target_cell)`(285행)은 이동이라, 지시서의 "또 다른 유닛을 선택하는 `h.click`"에 해당하지 않는다고 보고 그 뒤에는 대기를 넣지 않음. ② 2-1(0.35초)과 2-2(3.0초)를 한 명령으로 연달아 돌리고, 명령 끝에서 쉘을 0.35로 되돌림(2-3).

---

## 시작 상태 [사실]

- HEAD `12b5380`(`docs(agent): report REPORT_FIX_CMDPANEL_RACE_20261102 [skip ci]`), 가지 `feature/wm3d-intake-20261101`, `git status --short` 빈 출력.
- 지시서가 가리킨 원문과 다른 것 없음: 52행 `func real_click(control: Control) -> Control:`, 150행 뒤 앞 작업 블록(주석 3줄 + 대기 3줄 + `h.expect` 1줄), 버튼 반복 `for actor in ["yi_sunsin", "jeong_dojeon"]:`, `# Target selection hides the panel (attack): the 2D _should_show rule.`, `for direction in DIRS:`. 쉘 502행 `func camera_turn_key() -> String:`, 521행 `var key := camera_turn_key()`.

## 로컬 검증 결과 (Godot 4.6.2, `--headless --path . --script res://tests/scripts/test_battle3d_command_panel.gd`)

| 단계 | 조건 | 시간 | 결과 줄 원문 |
|---|---|---|---|
| 2-1 | 고친 뒤, 0.35초 | 151초, exit 0 | `[COMMAND_PANEL] checks=63 failures=[]` |
| 2-2 | 고친 뒤, **3.0초(임시)** | 245초, exit 0 | `[COMMAND_PANEL] checks=63 failures=[]` |
| 2-3 | 쉘 원복 | — | 111행 `const CAMERA_CENTER_SEC := 0.35`, `git diff --stat` = `tests/scripts/test_battle3d_command_panel.gd \| 23 ++++++++++++++++-------` 1개(쉘 변경 0) |
| 2-4 #1 | 고친 뒤, 0.35초 | 153초, exit 0 | `[COMMAND_PANEL] checks=63 failures=[]` |
| 2-4 #2 | 고친 뒤, 0.35초 | 150초, exit 0 | `[COMMAND_PANEL] checks=63 failures=[]` |
| 2-4 #3 | 고친 뒤, 0.35초 | 150초, exit 0 | `[COMMAND_PANEL] checks=63 failures=[]` |

- 시간 비교[사실]: 앞 작업의 0.35초 실행 139~143초 → 이번 150~153초(약 +10초). 3.0초에서는 245초.
- 2-5: `git status --short` = ` M tests/scripts/test_battle3d_command_panel.gd` 1경로, `git diff --check` 통과(출력 없음).

## 1-3 `rg` 표 (`rg -n "press_restart|press_scenario|real_click|h\.click\(" tests/scripts/test_battle3d_command_panel.gd`, 커밋 `37f7f0d` 기준)

| 줄 | 원문 요약 | 무엇 | 대기 |
|---|---|---|---|
| 61 | `func real_click(control: Control) -> Control:` | 클릭 함수 정의 | 해당 없음 |
| 140 | `await h.press_scenario(self, "default")` | 첫 시나리오 열기 | 카메라 섹션 앞 161행 대기(1-2)가 받음 |
| 211 | `var hovered: Control = await real_click(panel.button_at(i))` | 비활성 버튼 실제 클릭 | 넣지 않음(1-3 범위 밖). 161행 대기 뒤 턴 변화 없음[추정] |
| 220 | `await h.press_restart(self)` | 버튼 반복 재시작 | **넣음**(224행) |
| 226 | `h.click(…filter(func(u): return u.unit_id == actor)[0].grid_cell)` | 다른 아군 선택 | **넣음**(229행) |
| 237 | `await real_click(panel.button_at(i))` | 버튼 실제 클릭 | 224·229행 대기가 받음 |
| 252 | `await h.press_restart(self)` | 공격 대상 선택 재시작 | **넣음**(256행) |
| 257 | `await real_click(panel.button_at(0))` | 공격 버튼 실제 클릭 | 256행 대기가 받음 |
| 267 | `await h.press_restart(self)` | facing 반복 재시작 | **넣음**(271행) |
| 282 | `h.click(unit.grid_cell) # select first, like the lab's own move tests` | 행동 중인 같은 유닛 선택 | 넣지 않음(택한 해석 ①) |
| 285 | `h.click(target_cell)` | 이동 칸 클릭 | 넣지 않음(택한 해석 ①) |
| 314 | `var hovered: Control = await real_click(panel.arrow_for(direction))` | facing 화살표 실제 클릭 | 넣지 않음, **범위 밖, 클릭 직전 대기 없음**(271행 대기 뒤 같은 유닛이라 새 트윈 없음[추정]) |
| 321 | `await h.press_restart(self)` | manual stretch 재시작 | 넣지 않음, **범위 밖** |
| 340 | `await real_click(panel.button_at(4))` | manual stretch 대기 버튼 실제 클릭(8회) | 넣지 않음, **범위 밖, 클릭 직전 대기 없음**. 대기마다 행동 유닛이 바뀌어 새 트윈이 시작될 수 있음[추정] |
| 349 | `await h.press_scenario(self, "win_practice")` | 자동 시나리오 | 뒤에 실제 클릭 없음 |

## 바뀐 부분 diff 전체 (커밋 `37f7f0d`)

```diff
diff --git a/tests/scripts/test_battle3d_command_panel.gd b/tests/scripts/test_battle3d_command_panel.gd
index 96dafdb..d23abd8 100644
--- a/tests/scripts/test_battle3d_command_panel.gd
+++ b/tests/scripts/test_battle3d_command_panel.gd
@@ -49,6 +49,15 @@ func mouse(at: Vector2, kind: String) -> void:
 	event.global_position = at
 	root.push_input(event)
 
+func wait_camera_centred() -> bool:
+	# The shell's camera-centre tween (CAMERA_CENTER_SEC, real time) restarts whenever the acting ally changes (a new
+	# "round:unit" turn key) and moves lab.focus, so the panel moves with it. Wait for that tween before anything that
+	# depends on a still camera (a real mouse click on the panel, a camera move). Real-time cap so a stuck tween cannot hang CI.
+	var start := Time.get_ticks_msec()
+	while is_instance_valid(h.shell.camera_tween) and h.shell.camera_tween.is_running() and Time.get_ticks_msec() - start < 5000:
+		await process_frame
+	return not (is_instance_valid(h.shell.camera_tween) and h.shell.camera_tween.is_running())
+
 func real_click(control: Control) -> Control:
 	# Move, press, release at the control's centre; returns the control under the mouse.
 	var at := control.get_global_rect().get_center()
@@ -148,13 +157,9 @@ func run() -> void:
 		for u in b.all_battle_unit_states.filter(func(x): return x.side == "ally"): lab.hud_skill_cost(u.unit_id)
 		h.shell.command_state()
 	h.expect(engine_print(b) == before, "N7 x20 for five allies (+ shell command_state): engine fingerprint unchanged")
-	# The shell centres the camera on the acting ally with a real-time tween (CAMERA_CENTER_SEC) that owns lab.focus.
-	# A frame-count wait can end before it does, and the tween would then pull the camera back in the middle of the
-	# camera checks below (CI race). So wait for the tween itself, with a real-time cap.
-	var centre_start := Time.get_ticks_msec()
-	while is_instance_valid(h.shell.camera_tween) and h.shell.camera_tween.is_running() and Time.get_ticks_msec() - centre_start < 5000:
-		await process_frame
-	h.expect(not (is_instance_valid(h.shell.camera_tween) and h.shell.camera_tween.is_running()), "camera centring tween finished before the camera checks")
+	# Wait for the shell's camera-centre tween before the camera checks below (CI race; see wait_camera_centred).
+	var centred: bool = await wait_camera_centred()
+	h.expect(centred, "camera centring tween finished before the camera checks")
 	# Camera: the panel follows the unit model; inside the screen; hidden when the unit is off screen.
 	var follow_bad := []
 	for yaw in [0.32, 1.2, -0.9]:
@@ -216,10 +221,12 @@ func run() -> void:
 				lab = h.lab
 				b = lab.engine
 				for k in range(3): await process_frame
+				await wait_camera_centred()
 				if actor != b.active_unit_state.unit_id:
 					h.click(b.all_battle_unit_states.filter(func(u): return u.unit_id == actor)[0].grid_cell)
 					lab._sync_views()
 					for k in range(3): await process_frame
+					await wait_camera_centred()
 				var enabled: bool = not lab_buttons(lab)[i].disabled
 				if not enabled and path == "lab_emit": break # a disabled button is not pressed in the 2D either
 				var writes_before: Array = b.writes.duplicate()
@@ -246,6 +253,7 @@ func run() -> void:
 	lab = h.lab
 	b = lab.engine
 	for k in range(3): await process_frame
+	await wait_camera_centred()
 	await real_click(panel.button_at(0))
 	for k in range(2): await process_frame
 	h.expect(b.current_phase == "attack_select" and not panel.panel.visible, "attack target selection: panel hidden (phase %s)" % b.current_phase)
@@ -260,6 +268,7 @@ func run() -> void:
 		lab = h.lab
 		b = lab.engine
 		for k in range(3): await process_frame
+		await wait_camera_centred()
 		var unit: BattleUnitState = b.active_unit_state
 		var targets: Array = lab.queries.query(unit.unit_id, unit.grid_cell).get("reachable", {}).keys()
 		var target_cell = null
```

## CI [사실]

| run id | 워크플로 | 커밋 | 결과 | shard 2 `checks=` 줄 원문 |
|---|---|---|---|---|
| `41435623340` | Verify C-track refactor | `37f7f0d06fe7f839040aae9024951149ec0e4b21` | **success**(shard 0·1·2·3 모두 success) | `2026-11-02T11:32:36.5194177Z [COMMAND_PANEL] checks=63 failures=[]` |

- shard 2(job `125244542721`) 단계별: 1 Set up job = success / 2 Checkout full history = success / 3 Setup Godot 4.6.2 = success / 4 Versions = success / 5 Verify source assets exist = success / 6 Exclude 3D world map from shard import = success / 7 Import Godot resources and build class cache = success / 8 Static validators = skipped / 9 C-track Godot tests = success / 10 Tech-tree regression tests = success / 11 Military regression tests = success / 12 Diplomacy Trade Spy regression tests = success / 13 Project parse and WorldMap/Battle Main load = skipped / 14 Diff check = success / 28 Post Checkout full history = success / 29 Complete job = success.
- `Verify WorldMap3D`: 이 커밋에서는 돌지 않음(`gh run list --commit 37f7f0d…` 결과에 C-track 1건뿐).

## 막힌 것

없음.

## 종료 루틴

1. 정본: 가지 `feature/wm3d-intake-20261101`, 코드 HEAD `37f7f0d`(이 보고서 커밋이 그 위에 올라감), 보고서 커밋 뒤 `git status --short` 빈 출력. 쉘 111행 `const CAMERA_CENTER_SEC := 0.35` 원복 확인.
2. 새로 만든 것: 이 보고서 1개. 로그는 scratchpad의 `r2_2_1.log`·`r2_2_2.log`·`r2_2_4_1~3.log`(정본 밖).
3. push한 것: 코드 커밋 `37f7f0d`(`tests/scripts/test_battle3d_command_panel.gd` +16 −7), 이어서 이 보고서 커밋(`[skip ci]`).
4. CI: C-track run `41435623340` success, shard 2 `[COMMAND_PANEL] checks=63 failures=[]`.
5. 김작이 결정할 것: 범위 밖 2곳(314·340행 실제 클릭 직전 대기 없음)과 하네스 공용 대기 함수를 후속 숙제로 둘지.
