기준 화면: 새 가지 `feature/wm3d-bake-20261106`(시작 `origin/main` `ab9b739`)에서 `res://WorldMap.tscn`(F6)이 3D 지도를 같은 모양으로 띄우되, 도로·바닷길 경로 계산(지금 약 4초)이 미리 구운 파일을 읽는 것으로 바뀌어 시작이 그만큼 빨라진다. 화면(도로·바닷길 위치와 모양)은 지금과 **똑같다**.
합격 기준: 지시서 5절 — 새 테스트 통과 + 기존 `worldmap3d` 테스트·검증기 변화 없음 + push 후 C-track 4 shard·`Verify WorldMap3D` success + 2-D 측정표. **이 중 "C-track 4 shard success"를 못 채워 멈춘다.**

# REPORT_WM3D_PERF3_STOP — C-track shard 0이 알려진 `[CUTIN]` 길이 검사로 빨개짐 (클코드, 2026-11-06)

## 멈춘 이유 (큐 4절 1항)
- [사실] 코드 커밋 `cb121b0`의 `Verify C-track refactor` run `42173394148`: shard 1 `127746197339`·2 `127746197614`·3 `127746197645` success, **shard 0 `127746197637` failure**.
- [사실] `Verify WorldMap3D` run `42173394109`: success(새 테스트 `[BAKED_PATHS] checks=105 failures=0`, `[WM3D_ROADS] checks=121 failures=[]`).
- [사실] shard 0의 유일한 실패 줄(CI 로그 원문):
```
[M3] FAIL at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.951, 3.966, 3.935, 3.961, 3.939]
[CUTIN] 3D cut-ins (caster, start frame, end frame, real s)=[["gwon_yul", 240, 642, 3.951], ["gwon_yul", 838, 1050, 3.966], ["yi_sunsin", 1261, 1616, 3.935], ["jeong_dojeon", 1927, 2358, 3.961], ["yi_sunsin", 2455, 2777, 3.939]] …
[CUTIN] checks=16 failures=["at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.951, …]"]
##[error]Process completed with exit code 1.
```
- 큐 4절 1항의 알려진 예외("shard 0의 `[CUTIN]` 길이 검사가 60fps 이상 러너에서 실패하면 컷인 관찰 자료로 적고 단계를 멈추지 않는다 — 단 CI가 그 실패 때문에 빨개서 문 조건 3을 못 채우면 멈춘다")에서 **뒤쪽 단서**에 해당한다. 22번 합격 기준이 C-track 4 shard success이므로 멈춘다. 재실행으로 때우지 않았다(`gh` 쓰기 명령 없음).

## 한 번의 읽기 전용 조사 — 원인은 이번 변경과 무관 [사실]
1. 이 가지의 변경 파일 7개(`git diff --stat origin/main..cb121b0`): `worldmap3d/scripts/worldmap_roads.gd`, `worldmap3d/scripts/worldmap3d_root.gd`, `worldmap3d/maps/eastasia/baked_paths.json`, `tools/bake_worldmap3d_paths.gd`(+`.uid`), `tests/scripts/test_worldmap3d_baked_paths.gd`(+`.uid`). 전투·컷인 코드는 0줄.
2. C-track은 `worldmap3d/`를 `.gdignore`로 빼고 돈다(`verify-c-track.yml` 61~66행). 새 도구·테스트는 C-track 테스트 목록에 없다. C-track 목록은 `origin/main`과 같다(198개, shard 배정 변화 0) → 실패 테스트 `test_battle3d_cutin_result_toast.gd`(목록 295행)는 `main`과 같은 shard 0에서 같은 코드로 돌았다.
3. 같은 검사·같은 shard의 이전 실패 2건(코드와 무관하게 났다가 다음 실행에서 통과):
   - run `42049548382`(m7prep, 11-05) job `127321630391`: `[3.952, 3.954, 3.965, 3.955, 3.935]`
   - run `41447864206`(intake, 11-02) job `125300148841`: `[3.942, 3.977, 3.959, 3.956, 3.934]`
4. 러너 프레임 속도(컷인 프레임 수 ÷ 실제 초, x4 배속): 101.7 · 53.5 · 90.2 · 108.8 · 81.7 fps. [사실] 5개 중 4개는 60fps 이상, 1개(두 번째 권율 컷인)는 53.5fps. [추정] 예외 조항의 "60fps 이상 러너"에 해당하는 것으로 본다(1개 구간만 60 미만).
5. 같은 시각 통합 가지(21번, run `42172124442`)의 shard 0에서는 같은 테스트가 통과했다.

## 이 단계의 나머지는 끝남
- 코드·구운 파일·도구·테스트: `cb121b0`(push됨).
- 로컬: 새 테스트 105/0, 기존 3D 테스트 8개 변화 없음(`WM3D_ROADS` 121/0 등), 검증기 72/72.
- 2-D 측정: 3D 시작(창, 2~5회 중앙값) 13,052 → 9,112 ms(−3,940), 도로+바닷길 4,425 → 447 ms.
- 2-E 측정과 전체 내용은 `agent/REPORT_WM3D_PERF3_20261106.md`(같은 커밋), 증거 `agent/evidence/perf3_*.txt`.

## 클코치에게 필요한 판단
- A. 이 실패를 알려진 예외로 보고 22번을 합격 처리(C-track 3/4 + 실패 원인 기록).
- B. 김작님이 실패한 job만 다시 돌려(클코드는 `gh` 재실행 금지) 4/4를 확인.
- C. 다른 방법(예: 빈 커밋으로 다시 돌리기 허용 등).
답신(`agent/ORDER_WM3D_PERF3_REPLY_1.md` 등)이 오면 그대로 잇는다. 21번은 이미 끝났고(4/4 + 3D success), 큐에 다른 "준비됨" 항목은 없다.
