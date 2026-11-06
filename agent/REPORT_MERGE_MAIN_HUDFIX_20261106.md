기준 화면: GitHub 원격에서 `origin/main`이 `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`이고, `feature/wm3d-hudfix-20261106` 끝이 `a9e3b84229f63286bbdc784d78826b0e2cdb792d`(코드 끝 `de53500`)인 상태. 백업 태그 `baseline-pre-hudfix-20261106`은 아직 없음.
합격 기준: ① 원격 `main` = `a9e3b842…`, tree `1a79d075d0965c483adf4c5de12ddd6063b8469f` ② `main` 푸시는 fast-forward 하나(merge 커밋·force·가지 삭제·재작성 0) ③ 원격 태그 `baseline-pre-hudfix-20261106`이 `042b0708…`을 가리킴 ④ 보고서.

# REPORT_MERGE_MAIN_HUDFIX — 도시창 "그림만" + 턴 버튼 틈 수정을 `main`에 fast-forward로 합류 (클코드, 2026-11-06)

- **됐나**: 됐다. 태그 푸시 1회 + `main` fast-forward 푸시 1회, 둘 다 exit 0.
- **원격 `main`**: `a9e3b84229f63286bbdc784d78826b0e2cdb792d` (tree `1a79d075d0965c483adf4c5de12ddd6063b8469f`).
- **막힌 것**: 없음.

판정: **합격(F6 확인 완료)**

- [사실] 실행 승인: 지시서의 김작 승인(11-06 21:16 "병합해!", 클코치 전달)에 더해, 김작이 클코드 대화창에서 직접 "큐 다시 읽고 28번 진행해"라고 지시했다(11-06).
- [사실] 넣지 않은 것: PERF3(`feature/wm3d-bake-20261106`), CH-4(27번, 보류).

## 1. 사전 확인 (푸시 직전)

| # | 확인 | 기대 | 결과 원문 | 판정 |
|---|---|---|---|---|
| 1 | `git fetch origin --tags` / `git status --porcelain` 줄 수 / 현재 가지 / `--is-shallow-repository` | 깨끗 / false | `exit=0` / `0` / `feature/wm3d-hudfix-20261106` / `false` | 같음 |
| 2 | `git rev-parse origin/feature/wm3d-hudfix-20261106` | `a9e3b84229f63286bbdc784d78826b0e2cdb792d` | `a9e3b84229f63286bbdc784d78826b0e2cdb792d` | 같음 |
| 2 | `git rev-parse 'origin/feature/wm3d-hudfix-20261106^{tree}'` | `1a79d075d0965c483adf4c5de12ddd6063b8469f` | `1a79d075d0965c483adf4c5de12ddd6063b8469f` | 같음 |
| 3 | `git rev-parse origin/main` | `042b0708f9af4fe3f30d51caa1c988d9b064f8b0` | `042b0708f9af4fe3f30d51caa1c988d9b064f8b0` | 같음 |
| 4 | `git merge-base --is-ancestor origin/main a9e3b842…` | 0 | `exit=0` | 같음 |
| 5 | `git rev-list --count origin/main..a9e3b842…` / `a9e3b842…..origin/main` | 3 / 0 | `3` / `0` | 같음 |
| 6 | `git diff --name-only de53500 a9e3b842…` | `agent/` 문서·증거뿐 | 14줄 모두 `agent/` 아래(아래 원문) — 코드·테스트·워크플로 0 | 같음 |
| 7 | `gh run list --commit de53500…` | 42208336062, 4 shard success | `42208336062 Verify C-track refactor success`; shard 0 `127860473699`·1 `127860473777`·2 `127860473125`·3 `127860473501` 모두 `success` | 같음 |
| 8 | `git ls-remote origin refs/tags/baseline-pre-hudfix-20261106` | 빈 값 | `[]` | 같음 |

6번 원문:
```
agent/REPORT_HUDFIX_20261106.md
agent/evidence/hudfix_20261106/capture_log.txt
agent/evidence/hudfix_20261106/capture_script.gd.txt
agent/evidence/hudfix_20261106/citywin_hanseong_1920.png
agent/evidence/hudfix_20261106/citywin_hanseong_crop.png
agent/evidence/hudfix_20261106/local_tests.txt
agent/evidence/hudfix_20261106/seam_test_after_fix.txt
agent/evidence/hudfix_20261106/seam_test_before_fix.txt
agent/evidence/hudfix_20261106/turnbtn_after_dawn_magenta_x4.png
agent/evidence/hudfix_20261106/turnbtn_after_day_magenta_x4.png
agent/evidence/hudfix_20261106/turnbtn_after_dusk_magenta_x4.png
agent/evidence/hudfix_20261106/turnbtn_after_night_magenta_x4.png
agent/evidence/hudfix_20261106/turnbtn_before_day_magenta_x4.png
agent/evidence/hudfix_20261106/turnbtn_ingame_after_x4.png
```
- [사실] 로컬 `main` = `042b0708…`, `origin/main..main` = 0(로컬 전용 커밋 없음). `Verify WorldMap3D`는 hudfix 변경 경로가 그 워크플로 조건 밖이라 트리거되지 않았다(HUDFIX 보고서 5절, 같은 묶음 로컬 8개 통과).

## 2. 실행 명령과 결과 원문

### 2-1. 백업 태그
```
$ git tag baseline-pre-hudfix-20261106 042b0708f9af4fe3f30d51caa1c988d9b064f8b0
exit=0
$ git push origin refs/tags/baseline-pre-hudfix-20261106
To https://github.com/kimjak-app/SamWar_BattleLab.git
 * [new tag]         baseline-pre-hudfix-20261106 -> baseline-pre-hudfix-20261106
exit=0
```

### 2-2. `main` 푸시 (`--force`·`+` 없음)
```
$ git push origin a9e3b84229f63286bbdc784d78826b0e2cdb792d:refs/heads/main
To https://github.com/kimjak-app/SamWar_BattleLab.git
   042b070..a9e3b84  a9e3b84229f63286bbdc784d78826b0e2cdb792d -> main
exit=0
```
- [사실] `042b070..a9e3b84`(점 두 개) = fast-forward. `main`에 새 커밋(merge 커밋 포함) 0.

### 2-3. 푸시 직후 확인
```
$ git fetch origin
exit=0
$ git rev-parse origin/main origin/main^{tree}
a9e3b84229f63286bbdc784d78826b0e2cdb792d
1a79d075d0965c483adf4c5de12ddd6063b8469f
$ git ls-remote origin refs/heads/main refs/tags/baseline-pre-hudfix-20261106
a9e3b84229f63286bbdc784d78826b0e2cdb792d	refs/heads/main
042b0708f9af4fe3f30d51caa1c988d9b064f8b0	refs/tags/baseline-pre-hudfix-20261106
```

### 2-4. 로컬 `main` 따라잡기 (현재 가지는 hudfix, 바꾸지 않음)
```
$ git branch --show-current
feature/wm3d-hudfix-20261106
$ git merge-base --is-ancestor main origin/main
exit=0
$ git branch -f main origin/main
branch 'main' set up to track 'origin/main'.
exit=0
$ git rev-parse main
a9e3b84229f63286bbdc784d78826b0e2cdb792d
$ git status --porcelain | wc -l
0
```

### 2-5. `main` 푸시가 일으킨 워크플로
```
$ gh run list --commit a9e3b84229f63286bbdc784d78826b0e2cdb792d
(빈 결과)
$ gh run list --branch main --limit 3
가장 최근 실행이 2026-07-28(T06-9 hotfix 등) — 11-06 실행 없음
```
- [사실] **워크플로 트리거 없음.**
- [추정] 끝 커밋 `a9e3b84`의 메시지에 `[skip ci]`가 있어 GitHub가 push 실행을 건너뛰었다. 코드는 `de53500`에서 C-track 4/4 success(1절 7번).

## 3. 열린 PR 목록 (기록만, 건드리지 않음)
```
#18 feature/samwar-sfx-integration -> experiment/imjin-iso-movement | Integrate SamWar audio system into isometric battle test
#10 t06-7-hotfix7-full-overlay-trigger -> main | Trigger T06-7 hotfix7 full self-area overlay
#9 t06-7-range-overlay-audit-trigger -> main | Trigger T06-7 range overlay audit
#8 t06-7-hotfix5-self-area-manual-confirm-trigger -> main | Trigger T06-7 hotfix5 self-area manual confirm
#7 t06-7-hotfix4-self-area-range-trigger -> main | Trigger T06-7 hotfix4 self-area range overlay
#6 t06-7-skill-range-audit-trigger -> main | Trigger T06-7 skill range audit
```

## 4. 되돌리는 법
`git push origin baseline-pre-hudfix-20261106:refs/heads/main --force-with-lease=main:a9e3b84229f63286bbdc784d78826b0e2cdb792d` — 태그 `baseline-pre-hudfix-20261106` = `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`. (김작 승인 있을 때만. 클코드는 실행하지 않았다.)

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-hudfix-20261106` 그대로(= 새 `main`과 같은 커밋), `git status` 깨끗.
2. 원격 `main` = `a9e3b842…`, 태그 `baseline-pre-hudfix-20261106` = `042b0708…`. 그 밖의 가지·태그·PR 변경 0.
3. 이 보고서는 새 가지 `feature/wm3d-mergereport2-20261106`(시작 `a9e3b842…`)에 `[skip ci]` 커밋 1개로 올렸다. 작업 폴더 가지 전환 없이 임시 index로 만들었다.
4. 27번(CH-4)은 큐에서 아직 "보류". 시작 `origin/main`은 이제 `a9e3b84`.
5. 22번 bake 가지는 옛 `main`(`ab9b739`)에서 시작했으므로 합류하려면 새 `main` 위로 다시 맞추는 별도 지시서가 필요하다.
