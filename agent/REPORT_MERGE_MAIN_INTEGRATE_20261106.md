기준 화면: GitHub 원격에서 `origin/main`이 `ab9b739d767bcd10afbca4dc885ac79471bdc51c`이고, `feature/wm3d-integrate-20261106` 끝이 `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`(코드 끝 `dac3a8b4587098dddcbfca613ba52016361b7f85`)인 상태. 백업 태그 `baseline-pre-integrate-20261106`은 아직 없음.
합격 기준: ① 원격 `main` = `042b0708…`, tree `84dfe9474027fa87780541d6d5179bec927b9f82` ② `main` 푸시는 fast-forward 하나(merge 커밋·force·가지 삭제·재작성 0) ③ 원격 태그 `baseline-pre-integrate-20261106`이 `ab9b739d…`를 가리킴 ④ 보고서.

# REPORT_MERGE_MAIN_INTEGRATE — 통합 가지를 `main`에 fast-forward로 합류 (클코드, 2026-11-06)

- **됐나**: 됐다. 태그 푸시 1회 + `main` fast-forward 푸시 1회, 둘 다 exit 0.
- **원격 `main`**: `042b0708f9af4fe3f30d51caa1c988d9b064f8b0` (tree `84dfe9474027fa87780541d6d5179bec927b9f82`).
- **막힌 것**: 없음. 눈으로 보는 F6는 아직이다.

판정: **조건부 합격(F6 미확인)**

- [사실] 실행 승인: 지시서의 김작 승인(클코치 전달)에 더해, 김작이 클코드 대화창에서 직접 "큐 다시 읽고 23번 진행해"라고 지시했다(11-06).
- [미확인] 눈으로 보는 F6(도시창 도킹, 좌측 패널 그립 드래그, 5성 배치, 턴 버튼 동작), 입력 라이프사이클 Godot 테스트(CI 목록 밖). 지시서대로 이번 병합의 합격 근거가 아니다.
- [사실] 넣지 않은 것: PERF3(`feature/wm3d-bake-20261106`, 22번 멈춤 중), perf·evidence 가지.

## 1. 사전 확인 (푸시 직전, 11-06 17:5x KST)

| # | 확인 | 기대 | 결과 원문 | 판정 |
|---|---|---|---|---|
| 1 | `git fetch origin --tags` / `git status --porcelain` 줄 수 / 현재 가지 / `--is-shallow-repository` | 깨끗 / false | `0` / `feature/wm3d-integrate-20261106` / `false` | 같음 |
| 2 | `git rev-parse origin/feature/wm3d-integrate-20261106` | `042b0708f9af4fe3f30d51caa1c988d9b064f8b0` | `042b0708f9af4fe3f30d51caa1c988d9b064f8b0` | 같음 |
| 2 | `git rev-parse 'origin/feature/wm3d-integrate-20261106^{tree}'` | `84dfe9474027fa87780541d6d5179bec927b9f82` | `84dfe9474027fa87780541d6d5179bec927b9f82` | 같음 |
| 3 | `git rev-parse origin/main` | `ab9b739d767bcd10afbca4dc885ac79471bdc51c` | `ab9b739d767bcd10afbca4dc885ac79471bdc51c` | 같음 |
| 4 | `git merge-base --is-ancestor origin/main 042b0708…` | 0 | `ancestor_exit=0` | 같음 |
| 5 | `git rev-list --count origin/main..042b0708…` / `042b0708…..origin/main` | 34 / 0 | `34` / `0` | 같음 |
| 6 | `git diff --name-only dac3a8b… 042b0708…` | 한 줄 | `agent/REPORT_INTEGRATE_F6_20261106.md` | 같음 |
| 7 | `gh run list --commit dac3a8b…` | 42172124442, 42172124412 success | `Verify WorldMap3D` `42172124412` success, `Verify C-track refactor` `42172124442` success — shard 0·1·2·3 모두 `success` | 같음 |
| 8 | `git ls-remote origin refs/tags/baseline-pre-integrate-20261106` | 빈 값 | `tag_remote=[]` | 같음 |

- [사실] 기존 baseline 태그 형식: `refs/tags/baseline-pre-3d-units-20261029 commit 5868190`, `refs/tags/baseline-pre-wm3d-main-20261105 commit 66b29ba` → 가벼운 태그. 새 태그도 같은 형식.
- [사실] 로컬 `main` = `ab9b739d…`, `origin/main..main` = 0(로컬 전용 커밋 없음).

## 2. 실행 명령과 결과 원문

### 2-1. 백업 태그
```
$ git tag baseline-pre-integrate-20261106 ab9b739d767bcd10afbca4dc885ac79471bdc51c
exit=0
$ git push origin refs/tags/baseline-pre-integrate-20261106
To https://github.com/kimjak-app/SamWar_BattleLab.git
 * [new tag]         baseline-pre-integrate-20261106 -> baseline-pre-integrate-20261106
exit=0
```

### 2-2. `main` 푸시 (`--force`·`+` 없음)
```
$ git push origin 042b0708f9af4fe3f30d51caa1c988d9b064f8b0:refs/heads/main
To https://github.com/kimjak-app/SamWar_BattleLab.git
   ab9b739..042b070  042b0708f9af4fe3f30d51caa1c988d9b064f8b0 -> main
exit=0
```
- [사실] `ab9b739..042b070`(점 두 개) = fast-forward. `main`에 새 커밋(merge 커밋 포함) 0.

### 2-3. 푸시 직후 확인
```
$ git fetch origin
exit=0
$ git rev-parse origin/main origin/main^{tree}
042b0708f9af4fe3f30d51caa1c988d9b064f8b0
84dfe9474027fa87780541d6d5179bec927b9f82
$ git ls-remote origin refs/heads/main refs/tags/baseline-pre-integrate-20261106
042b0708f9af4fe3f30d51caa1c988d9b064f8b0	refs/heads/main
ab9b739d767bcd10afbca4dc885ac79471bdc51c	refs/tags/baseline-pre-integrate-20261106
```

### 2-4. 로컬 `main` 따라잡기 (현재 가지는 integrate, 바꾸지 않음)
```
$ git branch --show-current
feature/wm3d-integrate-20261106
$ git merge-base --is-ancestor main origin/main
exit=0
$ git branch -f main origin/main
branch 'main' set up to track 'origin/main'.
exit=0
$ git rev-parse main
042b0708f9af4fe3f30d51caa1c988d9b064f8b0
$ git status --porcelain | wc -l
0
```

### 2-5. `main` 푸시가 일으킨 워크플로
```
$ gh run list --commit 042b0708f9af4fe3f30d51caa1c988d9b064f8b0
(빈 결과)
$ gh run list --branch main --limit 5
가장 최근 실행이 2026-07-28(T06-9 hotfix 등) — 11-06 실행 없음
```
- [사실] **워크플로 트리거 없음.**
- [추정] 끝 커밋 `042b070`의 메시지에 `[skip ci]`가 있어 GitHub가 push 실행을 건너뛰었다. 같은 tree의 코드는 `dac3a8b`에서 C-track 4/4·`Verify WorldMap3D` success(1절 7번).

## 3. 열린 PR 목록 (기록만, 건드리지 않음)
```
#18 feature/samwar-sfx-integration -> experiment/imjin-iso-movement | Integrate SamWar audio system into isometric battle test
#10 t06-7-hotfix7-full-overlay-trigger -> main | Trigger T06-7 hotfix7 full self-area overlay
#9 t06-7-range-overlay-audit-trigger -> main | Trigger T06-7 range overlay audit
#8 t06-7-hotfix5-self-area-manual-confirm-trigger -> main | Trigger T06-7 hotfix5 self-area manual confirm
#7 t06-7-hotfix4-self-area-range-trigger -> main | Trigger T06-7 hotfix4 self-area range overlay
#6 t06-7-skill-range-audit-trigger -> main | Trigger T06-7 skill range audit
```
- [추정] #6~#10은 `main` 대상이라 GitHub의 "변경 파일"이 이번 34커밋만큼 달라 보일 수 있다. PR 가지 자체는 그대로다.

## 4. 되돌리는 법
`git push origin baseline-pre-integrate-20261106:refs/heads/main --force-with-lease=main:042b0708f9af4fe3f30d51caa1c988d9b064f8b0` — 태그 `baseline-pre-integrate-20261106` = `ab9b739d767bcd10afbca4dc885ac79471bdc51c`. (김작 승인 있을 때만. 클코드는 실행하지 않았다.)

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-integrate-20261106` 그대로, `git status` 깨끗. 김작은 지금 이 상태로 F6 하면 `main`과 같은 코드를 본다.
2. 원격 `main` = `042b0708…`, 태그 `baseline-pre-integrate-20261106` = `ab9b739d…`. 그 밖의 가지·태그·PR 변경 0.
3. 이 보고서는 새 가지 `feature/wm3d-mergereport-20261106`(시작 `042b0708…`)에 `[skip ci]` 커밋 1개로 올렸다. 작업 폴더 가지 전환 없이 임시 index로 만들었다.
4. 22번(PERF3)은 C-track shard 0 `[CUTIN]` 길이 검사로 멈춘 상태 그대로, 클코치 답신 대기. bake 가지는 `main`(`ab9b739`)에서 시작했으므로 다음에 쓰려면 새 `main` 위로 다시 맞춰야 할 수 있다 [추정].
5. 김작 다음 할 일: 일어나서 F6 확인(도시창 도킹·좌측 패널 그립·5성 배치·턴 버튼).
