기준 화면: GitHub 원격에서 `origin/main` = `ab9b739d767bcd10afbca4dc885ac79471bdc51c`(= `feature/wm3d-intake-20261101` 끝), 기준점 태그 `baseline-pre-wm3d-main-20261105` → 옛 `main` 끝 `66b29ba13b735a0784da23fccad5632e8f65beb1`.
합격 기준: 지시서 `agent/ORDER_MERGE_MAIN_20261105.md` ① 원격 main = `ab9b739d…`, tree `e20215ab…` ② fast-forward 푸시 1회(merge 커밋·force·삭제·재작성 0) ③ 원격 태그 → `66b29ba1…` ④ 이 보고서.

# 보고서 — MERGE-MAIN (큐 10번)

## 요약 (3줄)
1. 됐나: 됐다. 사전 확인 7개가 전부 지시서 값과 같았고, 태그 푸시 1회 → `main` fast-forward 푸시 1회(`66b29ba..ab9b739`)를 했다.
2. 원격 main: `ab9b739d767bcd10afbca4dc885ac79471bdc51c`, tree `e20215ab2939535c243f658c5e74b2c31aa64c5a`. 태그 `baseline-pre-wm3d-main-20261105` = `66b29ba13b735a0784da23fccad5632e8f65beb1`.
3. 막힌 것: 없음. `main` 푸시로 돈 워크플로 없음.

## 진행 기록 (정본 `PROGRESS_WM3D.md` 대신 여기에 쓴다)
- 2026-11-05 — 큐 9번(CH-2) 끝(`ffb8778`·`846f128`) 직후 10번 시작 → 사전 확인 → 태그 → main 푸시 → 확인. 이 보고서는 지시서 4절대로 작업 가지 `feature/wm3d-cityhud-20261105`에 `[skip ci]`로 올린다.
- 다음 할 일: 큐 11번 `ORDER_M7_1_CONTEXT_ENTRY_20261105.md`.

## 1. 사전 확인 [사실]
| # | 확인 | 기대 | 실제 | 같음 |
|---|---|---|---|---|
| 1 | `git fetch origin --tags`, `git status --short` | 깨끗 | 0줄(가지 `feature/wm3d-cityhud-20261105`, 지시서 가지 끝 `681f6f3`) | 예 |
| 2 | `origin/feature/wm3d-intake-20261101` / tree | `ab9b739d…` / `e20215ab…` | `ab9b739d767bcd10afbca4dc885ac79471bdc51c` / `e20215ab2939535c243f658c5e74b2c31aa64c5a` | 예 |
| 3 | `origin/main` | `66b29ba1…` | `66b29ba13b735a0784da23fccad5632e8f65beb1` | 예 |
| 4 | shallow / `merge-base --is-ancestor origin/main ab9b739d…` | false / 0 | `false` / `is_ancestor_exit=0` | 예 |
| 5 | `git diff --name-only cbe28c0 ab9b739d…` | 4줄 | `agent/PROGRESS_WM3D.md`, `agent/REPORT_AUDIT_CITYHUD_20261105.md`, `agent/REPORT_AUDIT_M7_20261105.md`, `agent/REPORT_WM3D_08_20261105.md` | 예 |
| 6 | `cbe28c0` CI(`gh run list --commit`) | success | `41963496308 Verify C-track refactor completed success`, `41963496218 Verify WorldMap3D completed success` | 예 |
| 7 | `rev-list --count origin/main..ab9b739d…` / 반대 | 887 / 0 | `887` / `0` | 예 |
| - | 같은 이름 태그 | 없음 | 로컬·원격 모두 없음(형식 참고 `baseline-pre-3d-units-20261029`는 가벼운 태그 `commit`) | 예 |

## 2. 명령과 결과 원문
```
$ git tag baseline-pre-wm3d-main-20261105 66b29ba13b735a0784da23fccad5632e8f65beb1
exit=0
$ git push origin refs/tags/baseline-pre-wm3d-main-20261105
To https://github.com/kimjak-app/SamWar_BattleLab.git
 * [new tag]         baseline-pre-wm3d-main-20261105 -> baseline-pre-wm3d-main-20261105
exit=0
$ git push origin ab9b739d767bcd10afbca4dc885ac79471bdc51c:refs/heads/main
To https://github.com/kimjak-app/SamWar_BattleLab.git
   66b29ba..ab9b739  ab9b739d767bcd10afbca4dc885ac79471bdc51c -> main
exit=0
$ git fetch origin
$ git rev-parse origin/main / tree
ab9b739d767bcd10afbca4dc885ac79471bdc51c
e20215ab2939535c243f658c5e74b2c31aa64c5a
$ git ls-remote origin refs/tags/baseline-pre-wm3d-main-20261105
66b29ba13b735a0784da23fccad5632e8f65beb1	refs/tags/baseline-pre-wm3d-main-20261105
$ (local main) merge-base --is-ancestor main origin/main
exit=0
$ git branch -f main origin/main
branch 'main' set up to track 'origin/main'.
exit=0
ab9b739d767bcd10afbca4dc885ac79471bdc51c
$ gh run list --branch main --limit 5
30331908129 Apply T06-9 Hotfix1 Typed Outcome IDs 4ac05a4 completed success 2026-07-28T05:32:02Z
30331585916 Apply T06-9 Hero Data Parity df3dd89 completed success 2026-07-28T05:25:19Z
30328112925 Apply T06-7 Hotfix7 Full Self Area Overlay 6730079 completed success 2026-07-28T04:12:50Z
30326795161 Apply T06-7 Hotfix6 Self Area Ally Confirm 902e621 completed success 2026-07-28T03:45:10Z
30324902599 Apply T06-7 Hotfix3 Topbar Cleanup 95623c3 completed success 2026-07-28T03:04:21Z
$ grep branches in verify-c-track.yml
3:on:
4-  push:
5:    branches:
6-      - recovery/worldmap-iso-sfx-services-20260912
7-      - refactor/engine-core-20260918
8-      - integration/p1-engine-core-20261019
9-      - "feature/**"
```
- [사실] 로컬 `main`(`66b29ba`)은 `origin/main`의 조상 → fast-forward라 `git branch -f main origin/main` 실행(로컬에만 있는 커밋 없음). 현재 가지는 바꾸지 않았다(`git switch` 없음).
- [사실] 워크플로 트리거 없음: `verify-c-track.yml`의 `push.branches`에 `main`이 없다. `gh run list --branch main`의 최신 run은 2026-07-28 것이 그대로다.

## 3. 열린 PR 목록 (기록만, 변경 없음)
```
#18 feature/samwar-sfx-integration -> experiment/imjin-iso-movement | Integrate SamWar audio system into isometric battle test
#10 t06-7-hotfix7-full-overlay-trigger -> main | Trigger T06-7 hotfix7 full self-area overlay
#9 t06-7-range-overlay-audit-trigger -> main | Trigger T06-7 range overlay audit
#8 t06-7-hotfix5-self-area-manual-confirm-trigger -> main | Trigger T06-7 hotfix5 self-area manual confirm
#7 t06-7-hotfix4-self-area-range-trigger -> main | Trigger T06-7 hotfix4 self-area range overlay
#6 t06-7-skill-range-audit-trigger -> main | Trigger T06-7 skill range audit
```
- [사실] #6~#10은 바닥 가지가 `main`이다. 이번 fast-forward로 이 PR들의 비교 기준이 바뀐다(PR 자체는 건드리지 않음). [추정] 그 PR들의 diff가 커지거나 충돌로 표시될 수 있다 — 정리는 김작·클코치 판단.

## 4. 하지 않은 것
force push, `main` 새 커밋(merge 포함), intake·integration·기타 가지 수정/삭제, 태그 이동/삭제, PR 생성·병합·닫기, `.github` 수정.

## 5. 종료 루틴
1. 원격 `main` = `ab9b739d767bcd10afbca4dc885ac79471bdc51c`(tree `e20215ab…`), fast-forward 1회.
2. 원격 태그 `baseline-pre-wm3d-main-20261105` = `66b29ba13b735a0784da23fccad5632e8f65beb1`.
3. 워크플로 트리거 없음.
4. 이 보고서는 `feature/wm3d-cityhud-20261105`에 `[skip ci]`(main에 올리지 않음).
5. 다음: 큐 11번 M7-1.
