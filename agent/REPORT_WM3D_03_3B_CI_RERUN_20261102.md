기준 화면: 없음(읽기 전용 조사). 대상: C-track run `41381822288`(커밋 `74cebe4`) shard 2에서 실패한 `tests/scripts/test_battle3d_command_panel.gd` 168행 검사 `unit off screen (zoom 20, focus far side): panel hidden`.
합격 기준: 조사 1~5를 채운 이 보고서 한 파일을 `[skip ci]`로 올림. 코드·테스트·워크플로 수정 0, 이 보고서 커밋 외 push 0.

택한 해석: 같은 파일 이름(`agent/REPORT_WM3D_03_3B_CI_RERUN_20261102.md`)에 이번 조사(2~5)를 더해 덮어씀(1번 재실행 원문은 그대로 유지). 바탕화면 원본은 이번에 만들지 않음(요청 경로가 `agent/`뿐이고, 작업 시점에 바탕화면의 `REPORT_*` 파일들이 없어진 상태였음 — 지우거나 옮긴 사람은 내가 아님).

① 결과: 같은 검사가 CI에서 2회 연속 실패(attempt 1·2). 최근 C-track 10건 중 실패는 `74cebe4`가 처음이고 그 앞 9건(같은 가지 6, 다른 가지 3)은 모두 통과. 로컬은 10/10 통과(기본 5, `gl_compatibility` 지정 5).
② 원인 추정: 어댑터 커밋이 이 테스트에 닿는 경로는 **없음**[사실 근거]. 실패는 **쉘의 카메라 중앙 맞춤 트윈(0.35초, 실제 시간 기준)이 아직 돌고 있을 때 테스트가 `lab.focus`를 직접 바꾸고 2프레임만 기다리는 경쟁 상태**로 보임[추정]. 실패한 두 번은 10건 중 이 검사에 가장 빨리 도달했음(인트로 종료→검사 0.234·0.237초, 통과 9건은 추정 0.253~0.348초).
③ 김작이 할 일: 고칠지·어떻게 고칠지 결정(예: 168행 앞에서 트윈 종료 대기 / 테스트에서 중앙 맞춤 끄기 / 시간 기준 대기). 이번에는 고치지 않음.

---

# 1. 재실행(attempt 2) 원문과 1차 비교

## attempt 2 상태 [사실]

`gh run view 41381822288 --attempt 2`: `attempt=2 status=completed conclusion=failure sha=74cebe43ca469ce92c677f8461649ee34081c16a`

| job | id | 결과 |
|---|---|---|
| verify (shard 2 of 4) | 125082557141 | failure |
| verify (shard 1 of 4) | 125082558307 | success |
| verify (shard 3 of 4) | 125082558772 | success |
| verify (shard 0 of 4) | 125082594392 | success |

shard 2 단계: Set up job·Checkout full history·Setup Godot 4.6.2·Versions·Verify source assets exist·Exclude 3D world map from shard import·Import Godot resources and build class cache = success / Static validators = skipped / **C-track Godot tests = failure** / Tech-tree·Military·Diplomacy Trade Spy regression tests·Project parse and WorldMap/Battle Main load·Diff check = skipped.

## FAIL 줄 앞뒤 5줄 (원문) [사실]

로그에서 `FAIL`이 들어간 줄은 이 1줄뿐. 테스트 머리줄: `2026-11-02T03:56:36.4940730Z ===== tests/scripts/test_battle3d_command_panel.gd (shard 2) =====`

```text
2026-11-02T03:56:38.4235628Z [ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
2026-11-02T03:56:39.0871972Z [BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
2026-11-02T03:56:39.0872812Z [BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
2026-11-02T03:56:39.1237243Z [BATTLE_INTRO_CAMERA] complete source=skip_input
2026-11-02T03:56:39.2230949Z [COMMAND_PANEL] start panel [P: (682.7073, 228.7981), S: (176.0, 214.0)] texts ["기본공격", "학익진 · 기세 4", "책략", "방어", "대기"] disabled [false, true, true, false, false]
2026-11-02T03:56:39.3608389Z [M3] FAIL unit off screen (zoom 20, focus far side): panel hidden
2026-11-02T03:56:39.4298511Z [COMMAND_PANEL] overlap yaw=0.32 zoom=60.0 panel [P: (454.2982, 146.5806), S: (176.0, 214.0)] with {  }
2026-11-02T03:56:39.4435384Z [COMMAND_PANEL] overlap yaw=0.32 zoom=20.0 panel [P: (346.0, 233.0), S: (176.0, 214.0)] with {  }
2026-11-02T03:56:39.4573588Z [COMMAND_PANEL] overlap yaw=1.2 zoom=45.0 panel [P: (807.0, 275.0), S: (176.0, 214.0)] with {  }
2026-11-02T03:56:39.4711804Z [COMMAND_PANEL] overlap yaw=-0.9 zoom=70.0 panel [P: (520.5989, 409.5367), S: (176.0, 214.0)] with {  }
2026-11-02T03:56:39.7754339Z {"event":"ready","grid":"18x10 square","milliseconds":3274,"renderer":"gl_compatibility","units":0}
```

## `[COMMAND_PANEL] checks=` 줄 앞뒤 5줄 (원문) [사실]

```text
2026-11-02T03:58:10.6324499Z [BATTLE_RESULT_VIDEO] play state=victory path=res://assets/ui/result/videos/victory_result_theora_q8_1920x.ogv
2026-11-02T03:58:10.6324999Z [BATTLE_RESULT] state=victory ally_alive=5 enemy_alive=0
2026-11-02T03:58:11.6768096Z [BATTLE_RESULT_VIDEO] complete source=finished_signal state=victory
2026-11-02T03:58:11.6813403Z [BATTLE_TOAST_PLAY] tag=result_victory text=승리! texture=battle_result_victory.png queue_remaining=0
2026-11-02T03:58:14.3155102Z [COMMAND_PANEL] manual={ "frames": 2121, "open_frames": 9, "lag": 7, "bad": 0, "waits": 8 } auto={ "frames": 2159, "open_frames": 1, "bad": 0, "lag": 1 } auto open frames=[[1, "resolving", true, "yi_sunsin"]]
2026-11-02T03:58:14.3813821Z [COMMAND_PANEL] checks=62 failures=["unit off screen (zoom 20, focus far side): panel hidden"]
2026-11-02T03:58:14.4500975Z WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
2026-11-02T03:58:14.4501421Z      at: cleanup (core/object/object.cpp:2641)
2026-11-02T03:58:14.4954599Z ##[error]Process completed with exit code 1.
2026-11-02T03:58:14.5045934Z Post job cleanup.
2026-11-02T03:58:14.5625986Z [command]/usr/bin/git version
```

## 1차와의 비교 [사실]

| | 1차 (attempt 1) | 재실행 (attempt 2) |
|---|---|---|
| 테스트 | `test_battle3d_command_panel.gd` (shard 2) | 같음 |
| FAIL 줄 | `[M3] FAIL unit off screen (zoom 20, focus far side): panel hidden` (03:26:05.5185109Z) | 같은 문구 (03:56:39.3608389Z) |
| checks 줄 | `checks=62 failures=["unit off screen (zoom 20, focus far side): panel hidden"]` | 같음 |
| 바로 앞 `start panel` 위치 | `P: (678.8676, 229.8909)` | `P: (682.7073, 228.7981)` |
| manual frames | 2448 | 2121 |

한 줄 비교: **두 번 모두 같은 검사(`unit off screen (zoom 20, focus far side): panel hidden`) 1건만 실패했고, 다른 61개 검사는 통과함.**

참고 사실(판정 아님):
- 직전 커밋 `4b415cd`의 C-track run `41378943190` shard 2에서는 같은 테스트가 `checks=62 failures=[]`로 통과했음(03-3b 보고서에 기록).
- shard 2의 테스트 실행 순서: `4b415cd`(통과)와 이번 attempt 2 모두 1~31번째가 같은 순서이고 31번째가 `test_battle3d_command_panel.gd`(바로 앞 30번째는 `test_battle3d_top_commands.gd`). attempt 2는 여기서 실패해 32번째 이후(`test_battle3d_facing_arrows.gd` 등 18개)는 실행되지 않음.
- 이번 HEAD에서 로컬(Windows)로 같은 테스트 1회 실행 시 `checks=62 failures=[]`(03-3b 보고서에 기록).
- [추정] 1차 보고서의 "가끔 실패하는 검사(flaky)" 추정은 CI에서 2회 연속 같은 검사가 실패해 근거가 약해짐. 원인은 조사하지 않음.


# 2. 최근 C-track run 10건에서 이 테스트의 결과 [사실]

`gh run list --workflow "Verify C-track refactor" --limit 10`(모든 가지). 각 run에서 `test_battle3d_command_panel.gd`가 돈 job(모두 shard 2) 로그의 `[COMMAND_PANEL] checks=` 줄과 시각. 시각은 그 테스트 안에서 처음 나온 `[BATTLE_INTRO_CAMERA] complete`(인트로), `[COMMAND_PANEL] start panel`(시작), `[M3] FAIL`(실패), 첫 `overlap yaw=0.32 zoom=60`(겹침1) 줄.

| run id | 가지 | 커밋 | 만든 시각(UTC) | 이 테스트 결과 | 인트로 | 시작 | 실패 | 겹침1 |
|---|---|---|---|---|---|---|---|---|
| 41381822288 (attempt 2) | feature/wm3d-intake-20261101 | 74cebe4 | 11-02 03:12 | **failures=["unit off screen …"]** | 03:56:39.123 | 03:56:39.223 | 03:56:39.360 | 03:56:39.429 |
| 41381822288 (attempt 1) | feature/wm3d-intake-20261101 | 74cebe4 | 11-02 03:12 | **failures=["unit off screen …"]** | 03:26:05.284 | 03:26:05.381 | 03:26:05.518 | 03:26:05.587 |
| 41378943190 | feature/wm3d-intake-20261101 | 4b415cd | 11-02 02:40 | failures=[] | 02:54:48.169 | 02:54:48.289 | - | 02:54:48.504 |
| 41361883442 | feature/wm3d-intake-20261101 | 6c806f2 | 11-01 23:23 | failures=[] | 23:37:07.004 | 23:37:07.129 | - | 23:37:07.336 |
| 41317008432 | feature/wm3d-intake-20261101 | 5bf2f2d | 11-01 14:36 | failures=[] | 14:52:46.271 | 14:52:46.438 | - | 14:52:46.689 |
| 41309095016 | feature/wm3d-intake-20261101 | 8877dfe | 11-01 12:59 | failures=[] | 13:14:39.052 | 13:14:39.168 | - | 13:14:39.375 |
| 41306410823 | feature/wm3d-intake-20261101 | 0bd8730 | 11-01 12:25 | failures=[] | 12:41:26.719 | 12:41:26.867 | - | 12:41:27.074 |
| 41294729428 | feature/wm3d-ci-prep-20261101 | 66e8ae1 | 11-01 09:48 | failures=[] | 10:04:48.329 | 10:04:48.497 | - | 10:04:48.708 |
| 41275718126 | integration/p1-engine-core-20261019 | 8be8435 | 11-01 05:07 | failures=[] | 05:24:01.499 | 05:24:01.645 | - | 05:24:01.862 |
| 41267964843 | integration/p1-engine-core-20261019 | eb5d8fc | 11-01 03:08 | failures=[] | 03:24:42.440 | 03:24:42.608 | - | 03:24:42.817 |
| 41265815994 | feature/unit3d-run-carry-ci-20261030 | eb5d8fc | 11-01 02:35 | failures=[] | 02:51:20.173 | 02:51:20.320 | - | 02:51:20.539 |

- [사실] 실패가 처음 나온 커밋: **`74cebe4`**(attempt 1·2 모두). 그 앞 9건은 모두 `checks=62 failures=[]`.
- [사실] attempt 1 시각은 1차 때 받아 둔 로그 원문에서 옮김(`gh run view --job <attempt 1 job id> --log`가 attempt 2와 같은 내용을 돌려줘서).
- 간격 계산(위 시각의 차, 초):

| run | 인트로→시작 | 인트로→168행 검사 | 시작→겹침1 |
|---|---|---|---|
| 74cebe4 a1 (실패) | 0.097 | **0.234** (FAIL 줄) | 0.206 |
| 74cebe4 a2 (실패) | 0.100 | **0.237** (FAIL 줄) | 0.206 |
| 통과 9건 | 0.116~0.168 | 0.253~0.348 [추정: 겹침1 − 0.069초. 0.069초는 실패 run의 FAIL→겹침1 간격] | 0.207~0.251 |

- [사실] 인트로→시작 간격은 실패 2건(0.097·0.100)이 10건 중 가장 짧음(통과 9건 최소 0.116).

# 3. 어댑터 커밋(`74cebe4`)이 이 테스트에 영향을 줄 경로 — **없음**

| 확인한 경로 | 결과 | 근거 [사실] |
|---|---|---|
| 바뀐 파일 | 새 파일 4개 + 앞 보고서 1개뿐 | `git diff --stat 4b415cd 74cebe4`: `agent/REPORT_WM3D_03_3A_20261102.md`, `scripts/worldmap/map3d/worldmap_3d_adapter.gd`(+`.uid`), `tests/scripts/test_worldmap3d_adapter.gd`(+`.uid`). 전투 코드·이 테스트·하네스·워크플로 변경 0 |
| 테스트 실행 순서·shard 배정 | 바뀌지 않음 | `.github/workflows/verify-c-track.yml:16`("dealt round-robin over 4 shards"), 테스트 목록이 워크플로 안에 고정되어 있고(예: 186~227행, 330~336행), 339~344행 `index % SHARD_COUNT == SHARD`로 배정. 새 테스트 `test_worldmap3d_adapter.gd`는 이 목록에 없음. shard 2의 1~31번째 테스트가 `4b415cd`와 같은 순서이고 31번째가 이 테스트(바로 앞은 `test_battle3d_top_commands.gd`) |
| 테스트 사이 상태 공유 | 없음 | 343행 `timeout 300s godot --headless --path . --script "res://$test_script"` — 테스트마다 별도 Godot 프로세스 |
| class_name 추가 / 클래스 캐시 | 이 테스트가 읽지 않음 | `scripts/`·`tests/`의 `.gd`에서 `get_global_class_list`·`ClassDB.get_class_list`·`global_script_class` 검색 0건. `scripts/battle3d`, 이 테스트, `tests/scripts/support`에서 `WorldMap3DAdapter`·`map3d` 검색 0건. 캐시는 import 단계(`verify-c-track.yml:73~74`, `rm -rf .godot` 뒤 `godot --headless --editor --path . --import`)에서 한 번 만들어짐 |
| 실행 시간 | 같은 수준 | 이 테스트의 시작→겹침1 간격이 실패 0.206초, 통과 0.207~0.251초. 테스트 전체 시간(헤더→checks 줄) attempt 2 = 03:56:36.494→03:58:14.381(약 98초) |

- [추정] 어댑터 커밋은 이 실패의 원인이 아니고, 같은 커밋에서 두 번 다 실패한 것은 그 시간대 CI 실행 환경의 프레임 속도 차이일 가능성이 있음(아래 5절). 이 추정은 같은 커밋을 다른 시간에 다시 돌려 보지 않아 [미확인].

# 4. 로컬 5회 연속 실행 [사실]

명령: `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tests/scripts/test_battle3d_command_panel.gd` (HEAD `5ea4b4e`, 이 테스트·전투 코드는 `74cebe4`와 같음).

| 방식 | #1 | #2 | #3 | #4 | #5 | 통과 |
|---|---|---|---|---|---|---|
| 기본(`--headless`) | PASS 144.4초 | PASS 151.0초 | PASS 141.1초 | PASS 140.1초 | PASS 143.0초 | **5/5** |
| `--headless --rendering-method gl_compatibility` | PASS 139.8초 | PASS 142.3초 | PASS 142.6초 | PASS 141.7초 | PASS 142.4초 | **5/5** |

모든 실행 exit 0, `[COMMAND_PANEL] checks=62 failures=[]`, `[M3] FAIL` 0줄.

- [사실] 로그의 `"renderer":"gl_compatibility"`는 `scripts/battle3d/lab_presentation.gd:82`에 **문자열로 박혀 있는 값**(`_event("ready",{…,"renderer":"gl_compatibility"})`)이라 실제 렌더러를 뜻하지 않음.
- [추정] `--headless`에서는 Godot가 렌더링을 더미로 돌리므로 `--rendering-method`를 바꿔도 실제 차이가 없을 가능성이 큼. CI도 `--headless`(343행).
- [사실] 로컬 1회 약 140초, CI는 약 98초 — 로컬이 더 느림.

# 5. 168행 근처 "2프레임만 기다리는" 구조와 실패의 관계

### 코드 [사실]

`tests/scripts/test_battle3d_command_panel.gd`:
```gdscript
163		lab.yaw = 0.32
164		lab.zoom = 20.0
165		var unit_pos: Vector3 = lab.views[lab.hud_active_unit_id()].position
166		lab.focus = Vector3(lab.board.SIZE.x * lab.board.CELL - unit_pos.x, 0, lab.board.SIZE.y * lab.board.CELL - unit_pos.z) # the far side of the board
167		for i in range(2): await process_frame
168		h.expect(not expected_open(lab) and not panel.panel.visible, "unit off screen (zoom 20, focus far side): panel hidden")
```
- 75~78행 `expected_open`: `lab.camera.unproject_position(유닛 위치 + 높이)`가 화면 안이면 true.
- 시나리오 시작 뒤 대기: 131행 `await h.press_scenario(self, "default")` → `tests/scripts/support/battle3d_scenario_harness.gd`의 `wait_lab`(`while not lab.ready_for_input: await tree.process_frame` + `await tree.physics_frame`) → 132행 5프레임 → 153~161행 카메라 9조합 × 2프레임 → 167행 2프레임. **모두 프레임 수 기준이고 시간 기준 대기는 없음.**

`scripts/battle3d/lab_presentation.gd`:
- 240~243행 `_update_camera()`: `camera.position = focus + …; camera.look_at(focus)`.
- 245행 `_process`: 끝에서 `_update_camera()` 호출 → 매 프레임 `focus`로 카메라를 다시 놓음.

`scripts/battle3d/battle3d_scenario_shell.gd`:
- 111행 `const CAMERA_CENTER_SEC := 0.35`
- 252~272행 `_refresh_top_hud()`: 매 프레임(`battle3d_top_hud.gd:11,14` `process_priority = 100`, 랩의 `_process` 뒤) 명령 패널 상태 계산(272행 `command_panel.show_state(command_state())`) 다음에 274행 `_refresh_camera_center()` 호출.
- 518~530행 `_refresh_camera_center()`: 아군 턴마다 한 번(`camera_turn_key()` = `"라운드:유닛"`, 502~504행) `create_tween()`으로 `tween_property(lab, "focus", camera_target, CAMERA_CENTER_SEC)` — `lab.focus`를 0.35초 동안 활성 유닛을 화면 가운데로 두는 위치로 옮김.
- 이 트윈을 멈추는 곳: 532~539행 `_input`(키 `CAMERA_KEYS`, 휠, 가운데 버튼 입력) / 541~544행 `_on_edge_scrolled`. **테스트가 166행에서 `lab.focus`를 직접 바꾸는 것은 트윈을 멈추지 않음.**
- 392행 `command_state()`, 399~400행: 앵커(유닛 화면 좌표)가 화면 밖이면 패널 `open = false`.

### 추정 [추정]
1. 시나리오 시작 직후 첫 아군 턴에서 중앙 맞춤 트윈이 시작되고 0.35초(실제 시간) 동안 매 프레임 `lab.focus`를 덮어씀.
2. 테스트는 시작부터 168행까지 약 26프레임을 프레임 수로만 기다림. 프레임이 빠른 환경에서는 26프레임이 0.35초 안에 끝남.
3. 그러면 166행에서 정한 "먼 쪽" `focus`를 바로 다음 프레임에 트윈이 유닛 쪽 값으로 되돌리고, 2프레임 뒤 168행에서는 유닛이 화면 안에 있음 → `expected_open`이 true이거나 패널이 보임 → 검사 실패.
4. 근거로 맞는 사실: 실패 2건은 10건 중 이 검사에 가장 빨리 도달함(2절 간격 표). 로컬은 CI보다 느리고(140초 대 98초) 10/10 통과.
5. 맞지 않거나 확인 못 한 점: 통과 9건의 "인트로→검사" 추정값(0.253~0.348초)도 0.35초보다 짧음 → 트윈 시작 시점이 인트로 종료 줄보다 이른지 [미확인]. 168행의 두 조건(`expected_open` / `panel.panel.visible`) 중 어느 쪽이 거짓이었는지는 로그에 없음 [미확인].

---

## 종료 루틴
1. 정본 `git status`·가지·HEAD: 시작 기준 빈 출력 / `feature/wm3d-intake-20261101` / `5ea4b4e`. push 뒤 값은 이 보고서 커밋 해시(자기 해시는 파일 안에 넣을 수 없어 대화 보고로 대신함).
2. 새로 만든 것: 이 보고서 갱신 커밋 하나(`agent/REPORT_WM3D_03_3B_CI_RERUN_20261102.md`). 코드·테스트·워크플로 변경 0. 바탕화면 원본 없음.
3. push한 것: `feature/wm3d-intake-20261101` — 이 보고서 커밋 하나(`[skip ci]`). force 없음.
4. CI: 이 커밋은 `[skip ci]`. 조사 대상 run `41381822288`은 attempt 1·2 모두 failure(shard 2).
5. 김작이 결정할 것: 168행 경쟁 상태를 고칠지와 방법(테스트 쪽 대기 보강 / 테스트에서 중앙 맞춤 트윈 정지 / 쉘의 트윈을 `focus` 직접 변경 시 멈추게 하기 등).
