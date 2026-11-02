기준 화면: 없음(읽기 전용 CI 로그 확인). 대상: `gh run view 41381822288`(Verify C-track refactor, 커밋 `74cebe4`)의 재실행 attempt 2, shard 2 로그.
합격 기준: attempt 2 shard 2의 `[COMMAND_PANEL] checks=` 줄과 FAIL 줄 앞뒤 5줄을 원문 그대로 보고하고, 1차 실패와 같은 검사인지 한 줄로 비교. 코드 변경·코드 push 없음, 이 보고서 한 파일만 `[skip ci]`로 올림.

택한 해석: "고치거나 push하지 말고"는 코드 수정·코드 push 금지로 읽고, 요청대로 이 보고서 한 파일만 커밋·push함.

① 결과: attempt 2도 **failure** — shard 0·1·3 success, shard 2만 `C-track Godot tests` failure(job id `125082557141`).
② 비교: **1차와 같은 검사** — 두 번 모두 `tests/scripts/test_battle3d_command_panel.gd`의 `unit off screen (zoom 20, focus far side): panel hidden` 1건(62개 검사 중)만 실패.
③ 김작이 할 일: 이 실패를 우연한 흔들림이 아닌 CI 재현 실패로 보고 원인 조사 지시를 낼지 결정(코드 수정은 이번 범위 밖, 하지 않음).

---

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

## 종료 루틴
1. 정본 `git status`·가지·HEAD: push 뒤 바탕화면 원본에 기록(시작 기준: 빈 출력 / `feature/wm3d-intake-20261101` / `be43912`).
2. 새로 만든 것: 바탕화면 `REPORT_WM3D_03_3B_CI_RERUN_20261102.md`, 보고서 커밋(`agent/REPORT_WM3D_03_3B_CI_RERUN_20261102.md`). 코드 변경 0.
3. push한 것: `feature/wm3d-intake-20261101` — 이 보고서 커밋 하나(`[skip ci]`). force 없음.
4. CI: 이 보고서 커밋은 `[skip ci]`. 대상 run `41381822288` attempt 2 = failure(shard 2).
5. 김작이 결정할 것: `test_battle3d_command_panel.gd` "unit off screen (zoom 20, focus far side)" CI 실패의 원인 조사를 지시할지, 03-4를 먼저 진행할지.
