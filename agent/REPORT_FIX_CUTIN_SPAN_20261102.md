기준 화면: 없음(보이는 화면 변화 0). 고친 것은 CI 테스트 파일 1개(`tests/scripts/test_battle3d_cutin_result_toast.gd`)이고 게임 코드·3D 월드맵은 건드리지 않음.
합격 기준: ① 빠른 러너 흉내(2-2)에서 고치기 전 실패 → 고친 뒤 통과(재현 성공 시), 재현 실패 시 진단 출력이 올라가 있음 ② 원래 조건 3회 연속 `checks=16 failures=[]` ③ 변경 경로 정확히 1개 ④ 올린 커밋의 `Verify C-track refactor` 4개 shard 모두 success.

① 결과: 코드 커밋 `6632e5a59e2b67bcc525811c85d62873288a450b` push(원격 = 로컬). 측정 시작을 `hud.cutin_started_msec`로 바꾸고 `[CUTIN] observe lag ms=[…]` 진단 1줄 추가. 오차 0.05·4.0 기준·153행 검사식은 그대로. 로컬 3회 연속 `checks=16 failures=[]`, CI run `41472388081` 4개 shard 모두 success.
② 재현·증명: **재현 안 됨.** 로컬은 실행 옵션만으로 fps가 약 35~38에서 더 오르지 않아 90fps 조건을 만들지 못함. CI shard 0도 이번에는 느린 러너(첫 컷인 약 32fps)여서 **통과가 증명이 못 됨 — 증명 안 됨, 다음 빠른 러너에서 관찰.** 진단 출력은 올라가 있음.
③ 김작이 할 일: 보고서·CI 확인(F6 없음). 다음에 빠른 러너(첫 컷인 60fps 이상)에서 C-track이 돌면 shard 0의 `[CUTIN] 3D cut-ins`·`observe lag` 줄로 판정.

택한 해석: ① 2-2의 "렌더 부담 줄이기"는 실행 옵션(`--disable-vsync`, `--resolution 320x180`, `--audio-driver Dummy`, `--max-fps 0`, 프로세스 우선순위 High)까지만 시도하고 프로젝트·코드 설정은 건드리지 않음. ② fps는 첫 컷인의 (끝 프레임 − 시작 프레임) / 실측 초. ③ `Verify WorldMap3D`는 push 경로 필터(`worldmap3d/**`, `scripts/worldmap/map3d/**`, `WorldMap3D_*.tscn`, `tests/scripts/test_worldmap3d_*.gd`, 워크플로 자신)에 이번 파일이 없어 실행되지 않음([사실], `.github/workflows/verify-worldmap3d.yml` 5~10행) — 결과 없음으로 적음.

---

## 시작 상태 [사실]

- 가지 `feature/wm3d-intake-20261101`, HEAD `04edc48`, `git status --short` 빈 출력.
- 파일 대조: 128~130행 `if playing and not was_playing:` / `cut_start = frames` / `cut_msec = Time.get_ticks_msec()`, 137행 `(Time.get_ticks_msec() - cut_msec) / 1000.0`, 22~23행 주석·`CUTIN_SPAN_TOLERANCE_SEC := 0.05`, 153행 검사 — 지시서 설명과 같음.
- HUD: `scripts/battle3d/battle3d_cutin_toast_hud.gd` 69행 `var cutin_started_msec := 0`(공개 변수, 테스트의 `hud.`로 바로 읽힘), 154행 `cutin_started_msec = Time.get_ticks_msec()`는 `play_cutin` 안(켜는 호출마다 갱신).

## 로컬 검증 [사실]

Godot 4.6.2 headless, `--path . --script res://tests/scripts/test_battle3d_cutin_result_toast.gd`.

| 단계 | 조건 | 결과 | 첫 컷인 fps | 3D 컷인 실측 초 | observe lag ms |
|---|---|---|---|---|---|
| 2-1 기준선(고치기 전) | 기본 | rc=0 `checks=16 failures=[]` | 169/4.79 ≈ 35.3 | 4.79, 4.768, 4.871, 4.756, 5.072 | (없음) |
| 2-2 A(고치기 전) | `--disable-vsync --resolution 320x180` | rc=0 `checks=16 failures=[]` | 178/4.788 ≈ 37.2 | 4.788, 4.73, 4.874, 4.811, 5.359 | (없음) |
| 2-2 B(고치기 전) | A + `--audio-driver Dummy --max-fps 0` | rc=0 `checks=16 failures=[]` | 173/4.685 ≈ 36.9 | 4.685, 4.782, 4.812, 4.684, 5.037 | (없음) |
| 2-2 C(고치기 전) | A + 프로세스 우선순위 High | rc=0 `checks=16 failures=[]` | 179/4.761 ≈ 37.6 | 4.761, 4.73, 4.816, 4.764, 4.969 | (없음) |
| 2-3 #1(고친 뒤) | 기본 | rc=0 `checks=16 failures=[]` | 180/4.776 ≈ 37.7 | 4.776, 4.723, 4.832, 4.779, 5.023 | [11, 8, 11, 7, 6] |
| 2-3 #2(고친 뒤) | 기본 | rc=0 `checks=16 failures=[]` | 179/4.784 ≈ 37.4 | 4.784, 4.723, 4.815, 4.795, 5.225 | [11, 8, 12, 7, 8] |
| 2-3 #3(고친 뒤) | 기본 | rc=0 `checks=16 failures=[]` | 179/4.793 ≈ 37.3 | 4.793, 4.85, 4.87, 4.776, 5.054 | [11, 10, 12, 8, 8] |

- 2-2: 어떤 옵션도 fps ≥ 90을 만들지 못함(최고 약 37.6). 지시서대로 억지로 맞추지 않고 재현 실패로 기록, 고치기 전 테스트를 그 조건에서 3회 돌리는 단계는 해당 없음.
- 2-3: 3회 모두 오류 줄(`SCRIPT ERROR`·`Parse Error`) 0.
- `git status --short` = ` M tests/scripts/test_battle3d_cutin_result_toast.gd` 1줄, `git diff --check` 통과.
- [추정] observe lag(6~21ms)는 한 프레임(로컬 약 27ms, CI 약 31ms)보다 작음. 컷인을 켜는 호출(`top_hud._process`, `process_priority` 100)이 테스트가 깨어나는 `process_frame`보다 같은 프레임 안에서 조금 앞서 돌기 때문으로 보임. 바뀐 측정은 이만큼 시작을 앞당김.

## 바뀐 부분 diff 전체

```diff
diff --git a/tests/scripts/test_battle3d_cutin_result_toast.gd b/tests/scripts/test_battle3d_cutin_result_toast.gd
index c650697..ae0b18c 100644
--- a/tests/scripts/test_battle3d_cutin_result_toast.gd
+++ b/tests/scripts/test_battle3d_cutin_result_toast.gd
@@ -19,7 +19,7 @@ extends SceneTree
 #     finished signal or fallback timer) is printed, not judged.
 var h
 var hud
-# The span is measured frame to frame (process_frame + get_ticks_msec), so it can undershoot the 4.01 s schedule by about a frame or two; 0.05 s keeps real regressions (a missing time-scale compensation gives ~1 s at x4) failing.
+# The span starts at the HUD's own start time (hud.cutin_started_msec) and ends on the observed frame, so it can still be off by a frame or two; 0.05 s keeps real regressions (a missing time-scale compensation gives ~1 s at x4) failing.
 const CUTIN_SPAN_TOLERANCE_SEC := 0.05
 
 func _initialize() -> void:
@@ -95,6 +95,7 @@ func run() -> void:
 	var casts_engine := [] # [frame, msec, caster, skill_id]
 	var first_effect := {} # engine log index of the cast -> [frame, msec]
 	var cutin_spans := [] # [caster, start frame, end frame, real s]
+	var observe_lags := [] # ms from the HUD's start to the frame the test first saw the cut-in
 	var hold_violations := [] # skill events presented while a cut-in held
 	var lock_bad := 0
 	var auto_wait_bad := 0
@@ -127,7 +128,8 @@ func run() -> void:
 		var playing: bool = hud.cutin_playing
 		if playing and not was_playing:
 			cut_start = frames
-			cut_msec = Time.get_ticks_msec()
+			cut_msec = hud.cutin_started_msec
+			observe_lags.append(Time.get_ticks_msec() - cut_msec)
 			presented_before = lab.skill_presentations.size() + lab.enemy_skill_presentations.size()
 		if playing:
 			# The cast itself is presented when the hold starts; nothing after it until the release.
@@ -169,6 +171,7 @@ func run() -> void:
 		timing.append([c[2], c[3], (fe[0] - c[0]) if fe else -1, ((fe[1] - c[1]) / 1000.0) if fe else -1.0])
 	print("[CUTIN] speed x", lab.SPEED_STEPS[lab.speed_index], " Engine.time_scale=", Engine.time_scale, " casts (caster, skill, frames to first effect, real s)=", timing)
 	print("[CUTIN] 3D cut-ins (caster, start frame, end frame, real s)=", cutin_spans, " routes=", h.shell.cutin_log.map(func(c): return [c.caster, c.route]))
+	print("[CUTIN] observe lag ms=", observe_lags)
 	print("[CUTIN] toasts=", hud.toasts_played, " still toasts=", hud.still_toasts_played, " ending=", hud.endings_played, " frames: result ", result_frame, " ending ", ending_frame, " panel ", panel_frame)
 	await h.close_shell(self)
 	print("[CUTIN] checks=", h.checks, " failures=", h.failures)
```

검사 개수 변화 0(`h.expect` 추가 없음), `CUTIN_SPAN_TOLERANCE_SEC`·153행 검사식 변경 0.

## CI [사실]

| run id | 워크플로 | 커밋 | 결과 | 비고 |
|---|---|---|---|---|
| `41472388081` | Verify C-track refactor | `6632e5a59e2b67bcc525811c85d62873288a450b` | **success** | shard 0 `125369061119` / 1 `125369061085` / 2 `125369061054` / 3 `125369060859` 모두 success |
| — | Verify WorldMap3D | — | 실행 안 됨 | push 경로 필터에 해당 파일 없음 |

shard 0 "C-track Godot tests" 단계: 15:33:33Z~15:51:36Z(18분 3초) success. 원본 job 로그(`gh api --allow-escape-sequences …/jobs/125369061119/logs`, 27,602줄)의 컷인 줄 원문:

```
2026-11-02T15:49:59.0169547Z [CUTIN] 3D cut-ins (caster, start frame, end frame, real s)=[["gwon_yul", 155, 290, 4.225], ["gwon_yul", 366, 463, 4.415], ["yi_sunsin", 547, 681, 4.419], ["jeong_dojeon", 833, 991, 4.366], ["yi_sunsin", 1020, 1124, 4.293]] routes=[["gwon_yul", "video"], ["zhang_fei", "still"], ["gwon_yul", "video"], ["zhang_fei", "still"], ["yi_sunsin", "video"], ["jeong_dojeon", "video"], ["yi_sunsin", "video"]]
2026-11-02T15:49:59.0170747Z [CUTIN] observe lag ms=[19, 20, 21, 13, 16]
2026-11-02T15:49:59.1007085Z [CUTIN] checks=16 failures=[]
```

- 첫 컷인 fps: 135/4.225 ≈ **32fps**. 실패했던 `1e90b97` attempt 1·2는 약 69~102fps. 이번 러너는 통과하던 쪽(약 30fps)과 같은 느린 러너이고, 단계 시간 18분도 통과 run(약 18분)과 같음(실패 run은 13.6분).

## 막힌 것

- **증명 안 됨, 다음 빠른 러너에서 관찰.** 로컬에서 90fps를 만들 수 없어 고치기 전 실패를 재현하지 못했고, 이번 CI 러너도 느려서(약 32fps) 통과가 수정의 증명이 되지 못함.
- [추정] **이 수정만으로 빠른 러너의 실패가 사라진다고 장담할 수 없음.** 바뀐 측정은 시작을 observe lag만큼 앞당김(이번 CI 13~21ms, 로컬 6~12ms, 모두 한 프레임보다 작음). 실패 run의 최소값 3.929초는 기준 3.95까지 0.021초 모자람. 빠른 러너(69~102fps, 한 프레임 약 10~15ms)에서 lag가 한 프레임보다 작게 나오면 3.929 + 0.010~0.015 = 약 3.939~3.944로 여전히 3.95 아래일 수 있음. 그 경우 남는 부족분이 지난 보고서의 [미확인] 부분(컷인을 켜는 프레임의 영상 로드 등)이고, 그 실패 로그의 `observe lag`과 실측 초로 판정할 수 있음. 오차 값은 지시서대로 바꾸지 않음.

## 종료 루틴

1. 정본: 가지 `feature/wm3d-intake-20261101`, 코드 HEAD `6632e5a`(이 보고서 커밋이 그 위에 올라감), 보고서 커밋 뒤 `git status --short` 빈 출력. 게임 코드·하네스·워크플로·`tools/` 변경 0.
2. 새로 만든 것: 이 보고서만. 정본 밖: scratchpad 로컬 로그(`cs_base.log`, `cs_optA~C.log`, `cs_fix1~3.log`, `ci_fix_shard0.log`).
3. push한 것: 코드 커밋 `6632e5a`(1경로, +5 −2), 이어서 이 보고서 커밋(`[skip ci]`).
4. CI: `Verify C-track refactor` run `41472388081` success(4 shard 모두), shard 0 컷인 `checks=16 failures=[]`, 약 32fps 러너. `Verify WorldMap3D`는 경로 필터로 실행 안 됨.
5. 김작이 결정할 것: 이번 결과(통과, 단 느린 러너라 증명 아님)를 받아들이고 다음 빠른 러너 관찰로 넘길지.
