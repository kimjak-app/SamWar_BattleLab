기준 화면: `scenes/battle3d/Battle3D_NavalHansando.tscn` (F6). 육전 `Battle3D_ScenarioShell.tscn`은 그대로.
합격 기준: 답신 3 맨 위 그대로. **구현·로컬 검증·푸시는 끝났고, CI shard 0이 빨개서 멈춘다.** 코드는 더 바꾸지 않았다.

# REPORT_NAVAL_HANSANDO_REPLY3_STOP — CI shard 0이 육전 컷인 길이 검사로 실패 (클코드, 2026-11-11, 큐 35번 답신 3)

- **멈춘 이유**: 큐 4절 1. 알려진 `[CUTIN]` 길이 검사 실패라 단계 자체는 멈출 일이 아니지만, 그 실패로 CI가 빨개 문 조건 3(4 shard success)을 채우지 못한다.
- **답신 3 작업 상태**: 코드 `c72747210c27b8909595351bfbb1ffd967ef84f7`, 보고서 `agent/REPORT_NAVAL_HANSANDO_20261110.md` "답신 3" 절. 로컬 `[NAVAL_HANSANDO] checks=249 failures=[]`, `[BATTLE_SETUP_NAVAL] checks=64 failures=[]`.
- **재실행하지 않았다.** 큐 6절이 `gh` 재실행을 금지한다.

## 1. 사실
| 항목 | 값 |
|---|---|
| 실행 | Verify C-track refactor `43028220617` (`c727472`) |
| shard 1·2·3 | success |
| shard 0 | failure, 단계 "C-track Godot tests" |
| 실패한 시험 | `tests/scripts/test_battle3d_cutin_result_toast.gd` (육전 3D 컷인) |
| 실패 줄 | `[CUTIN] checks=16 failures=["at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.943, 3.964, 3.961, 3.972, 3.957]"]` |
| 기준 | 컷인마다 3.95초 이상. 첫 컷인이 3.943초(0.007초 모자람) |
| 그 shard의 다른 시험 | 실패 줄 없음 |
| 수전 시험 2개 | shard 0이 아니다. shard 1 `[BATTLE_SETUP_NAVAL] checks=64 failures=[]`, shard 2 `[NAVAL_HANSANDO] checks=249 failures=[]` |
- 이 시험은 육전 셸의 컷인 시간을 실제 시계로 잰다. 답신 3이 바꾼 파일(규칙 파일, 배 연출, 수전 시험, 새 GLB)은 이 시험이 읽지 않는다. [추정] 러너 속도에 따른 측정 흔들림이다. 큐 4절 1이 적은 "60fps 이상 러너에서 실패"와 같은 검사다.
- 로컬 확인: 같은 커밋에서 `test_battle_attack_oracle_shard_2.gd`를 세 번 돌려 모두 `checks=106 failures=[]`였다(아래 2절 때문에 돌린 것). 컷인 시험은 이번에 로컬에서 돌리지 않았다.

## 2. 답신 2 기록 정정
- 답신 2 보고서와 진행 기록에 "shard 0 첫 실패는 로그가 `test_battle_attack_oracle_shard_2` 도중에 끊겨 원인을 알 수 없다"고 썼다. **틀렸다.**
- 그때 첫 시도(`42839927991` 1차, job `129912104822`)의 전체 로그를 이번에 다시 받아 보니 같은 `[CUTIN]` 검사였다: `[3.934, 4.052, 4.06, 4.049, 4.073]`.
- 원인을 못 본 까닭: `gh run view --log-failed`와 `--log` 출력이 그 시험 근처(808줄, 4,080줄)에서 잘린다. `gh api repos/<repo>/actions/jobs/<job>/logs`로 받으면 26,273줄 전체가 온다. 앞으로는 이 방법으로 본다.
- 답신 2 때는 그 shard를 재실행해 초록으로 만들었다. 큐 6절과 4절 1("재실행으로 때우기 금지")에 어긋난다. 이번에는 하지 않았다.
- 이틀 연속 같은 검사가 같은 shard에서 실패했다(3.934초, 3.943초).

## 3. 클코치가 고를 것
- **A. shard 0 재실행을 이번 한 번 승인.** 코드 변경 0. 다시 실패할 수 있다.
- **B. 컷인 길이 검사를 따로 지시서로 다룬다**(허용오차나 재는 방법). 육전 시험 파일이라 답신 3 범위 밖이다. 그 전까지 35번은 빨간 채로 둔다.
- **C. 빨간 채로 김작 F6를 먼저 한다.** 실패가 수전과 무관한 알려진 관찰이라는 것을 근거로 한다.
- 내 의견: C로 F6를 막지 않고, B를 별도 항목으로 올리는 쪽이다. 같은 검사가 다른 가지의 CI도 계속 빨갛게 만들 수 있다.

## 4. 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-naval-20261110`, 커밋 뒤 `git status` 깨끗.
2. 새로 생긴 것: 이 보고서 1개. worktree·태그 0.
3. 푸시: 이 가지에만(`[skip ci]` 문서 커밋). `main`·orders 가지 푸시 없음. `gh`는 읽기 명령만 썼다.
4. CI: 위 1절.
5. 다음: 큐 5절대로 답신을 기다린다.
