기준 화면: GitHub 원격 `origin/main` = `8cc0640b741447151eebb7ed98d3193136a5ad59`, 원격 가지 66개 → 62개(병합 끝난 4개 삭제), 태그 5개·열린 PR 6개 그대로. 복구용 번들 `C:\dev\_archive\cleanup_20261029\branches_20261109.bundle`.
합격 기준: ① 4개 가지가 원격과 로컬 사본에서 사라짐 ② 그 밖의 원격 가지·태그·PR 변화 0 ③ 삭제 전 확인과 복구용 번들·기록이 `C:\dev\_archive\cleanup_20261029\`에 있음 ④ 이 보고서.
판정: **합격** — 4개 삭제(원격·로컬), 다른 가지·태그·PR 변화 0, 번들 `verify` 통과(되돌리기 가능).

# REPORT_CLEANUP_BRANCHES — 병합 끝난 가지 4개 삭제 (큐 33번) (클코드, 2026-11-09)

## 요약
- 삭제 전 확인 6개가 모두 지시서와 같았다: 끝 해시 4개, `origin/main` = `8cc0640`, PR 무관, debugcheats·warnmerge2는 `main` 조상, warnfix는 30번 파일만 다름, warnmerge는 문서 2개만 다름.
- 삭제 전에 4개 가지의 전체 이력 번들(`verify` 통과), 끝 해시 tsv, warnmerge의 STOP 보고서 사본을 `C:\dev\_archive\cleanup_20261029\`에 저장했다.
- `git push origin --delete` 1회로 원격 4개를 지우고, 로컬 사본 4개는 끝 해시를 tsv와 맞춰 본 뒤 `git branch -D`로 지웠다. 원격 가지는 정확히 4개만 줄었다(66 → 62). 태그 5개와 열린 PR 6개는 그대로다.

## 1. 삭제 전 확인
| # | 확인 | 결과 |
|---|---|---|
| 1 | `git fetch origin --tags`, `git status --short`, 현재 가지, `is-shallow-repository` | 빈 출력, `main`(로컬 `main` = `origin/main` = `8cc0640…`), `false` |
| 2 | `origin/feature/wm3d-debugcheats-20261108` | `3e391b16f6760b4b64e19d48c7f594ee30717f9a` |
| 2 | `origin/feature/wm3d-warnfix-20261108` | `e1bf1e39220d45be0e919dee1bd07cb298cc75a7` |
| 2 | `origin/feature/wm3d-warnmerge-20261109` | `078a406d9c0ab794fc6f006b1c917141fe195d9a` |
| 2 | `origin/feature/wm3d-warnmerge2-20261109` | `8cc0640b741447151eebb7ed98d3193136a5ad59` |
| 2 | `origin/main` | `8cc0640b741447151eebb7ed98d3193136a5ad59` |
| 3 | 열린 PR(`gh api …/pulls?state=open`, 읽기) | #18 `feature/samwar-sfx-integration -> experiment/imjin-iso-movement`, #10 `t06-7-hotfix7-full-overlay-trigger -> main`, #9 `t06-7-range-overlay-audit-trigger -> main`, #8 `t06-7-hotfix5-self-area-manual-confirm-trigger -> main`, #7 `t06-7-hotfix4-self-area-range-trigger -> main`, #6 `t06-7-skill-range-audit-trigger -> main`. 4개 가지가 머리·바닥으로 쓰인 횟수 `0 0 0 0 0 0 0 0`. 보호 목록(`branches?protected=true`) 빈 출력, 이름은 `work/*`·`integration/*`·`archive/*`와 겹치지 않음 |
| 4 | `merge-base --is-ancestor … origin/main` | `debugcheats=0`, `warnmerge2=0` |
| 5 | `git diff --name-only origin/main origin/feature/wm3d-warnfix-20261108` | `.github/workflows/verify-c-track.yml`, `WorldMap.tscn`, `agent/PROGRESS_WM3D.md`, `agent/REPORT_DEBUG_CHEATS_20261108.md`, `agent/REPORT_DEBUG_CHEATS_STOP_20261108.md`, `agent/evidence/debugcheats_20261108/` 7개, `scripts/worldmap/actions/spy_presentation_helper.gd`, `scripts/worldmap/ui/worldmap_debug_cheats_controller.gd`(+`.uid`), `tests/scripts/test_worldmap_debug_cheats.gd`(+`.uid`) — 30번 파일과 `PROGRESS_WM3D.md`뿐 |
| 5 | 31번 파일(`.gd` 4개 + `agent/REPORT_WARNFIX*` + `agent/evidence/warnfix_20261108`) `git diff origin/main origin/feature/wm3d-warnfix-20261108` 줄 수 | `0` |
| 6 | `git diff --name-only origin/feature/wm3d-warnmerge2-20261109 origin/feature/wm3d-warnmerge-20261109` | `agent/PROGRESS_WM3D.md`, `agent/REPORT_MERGE_MAIN_CHEATS_WARNFIX_STOP_20261109.md` |

## 2. 복구용 기록 (`C:\dev\_archive\cleanup_20261029\`, 새 파일 3개, 새 폴더 0)
```
git bundle create C:/dev/_archive/cleanup_20261029/branches_20261109.bundle refs/remotes/origin/feature/wm3d-debugcheats-20261108 refs/remotes/origin/feature/wm3d-warnfix-20261108 refs/remotes/origin/feature/wm3d-warnmerge-20261109 refs/remotes/origin/feature/wm3d-warnmerge2-20261109
git bundle verify C:/dev/_archive/cleanup_20261029/branches_20261109.bundle
C:/dev/_archive/cleanup_20261029/branches_20261109.bundle is okay
The bundle contains these 4 refs:
3e391b16f6760b4b64e19d48c7f594ee30717f9a refs/remotes/origin/feature/wm3d-debugcheats-20261108
e1bf1e39220d45be0e919dee1bd07cb298cc75a7 refs/remotes/origin/feature/wm3d-warnfix-20261108
078a406d9c0ab794fc6f006b1c917141fe195d9a refs/remotes/origin/feature/wm3d-warnmerge-20261109
8cc0640b741447151eebb7ed98d3193136a5ad59 refs/remotes/origin/feature/wm3d-warnmerge2-20261109
The bundle records a complete history.
The bundle uses this hash algorithm: sha1
```
| 파일 | 크기(바이트) | 비고 |
|---|---|---|
| `branches_20261109.bundle` | 1838337734 | 위 `verify` 통과, 전체 이력(바닥 커밋 없음) |
| `deleted_remote_20261109.tsv` | 579 | 아래 내용 |
| `warnmerge_STOP_report_20261109.md` | 8295 | `git hash-object` = `a41a565f60b3d550212440540da4679c1b09ce04` = 원본 blob(`origin/feature/wm3d-warnmerge-20261109:agent/REPORT_MERGE_MAIN_CHEATS_WARNFIX_STOP_20261109.md`) |

`deleted_remote_20261109.tsv` 내용:
```
feature/wm3d-debugcheats-20261108	3e391b16f6760b4b64e19d48c7f594ee30717f9a	main 조상(fast-forward로 합류, main 8cc0640)
feature/wm3d-warnfix-20261108	e1bf1e39220d45be0e919dee1bd07cb298cc75a7	31번 커밋 3개를 cherry-pick으로 main 합류(파일 내용 main과 같음)
feature/wm3d-warnmerge-20261109	078a406d9c0ab794fc6f006b1c917141fe195d9a	CI 0회 STOP 가지, 같은 tree를 warnmerge2로 다시 만들어 main 합류(STOP 보고서는 별도 사본)
feature/wm3d-warnmerge2-20261109	8cc0640b741447151eebb7ed98d3193136a5ad59	main 끝과 같음(fast-forward로 합류)
```
저장소 `git status --short`: 빈 출력(세 파일은 저장소 밖).

## 3. 삭제
삭제 직전 재확인(`git fetch`, `git rev-parse origin/<가지>` == tsv 해시):
```
match feature/wm3d-debugcheats-20261108
match feature/wm3d-warnfix-20261108
match feature/wm3d-warnmerge-20261109
match feature/wm3d-warnmerge2-20261109
```
원격 삭제(1회, `--force` 없음):
```
git push origin --delete feature/wm3d-debugcheats-20261108 feature/wm3d-warnfix-20261108 feature/wm3d-warnmerge-20261109 feature/wm3d-warnmerge2-20261109
To https://github.com/kimjak-app/SamWar_BattleLab.git
 - [deleted]         feature/wm3d-debugcheats-20261108
 - [deleted]         feature/wm3d-warnfix-20261108
 - [deleted]         feature/wm3d-warnmerge-20261109
 - [deleted]         feature/wm3d-warnmerge2-20261109
```
로컬 사본(끝 해시 == tsv 확인 뒤 `git branch -D`):
```
Deleted branch feature/wm3d-debugcheats-20261108 (was 3e391b1).
Deleted branch feature/wm3d-warnfix-20261108 (was e1bf1e3).
Deleted branch feature/wm3d-warnmerge-20261109 (was 078a406).
Deleted branch feature/wm3d-warnmerge2-20261109 (was 8cc0640).
```
삭제 후(`git fetch --prune origin`, `git ls-remote --heads/--tags origin`, PR 목록을 삭제 전 저장본과 `diff`):
```
heads before 66 after 62
--heads diff (before only <, after only >)
3d2
< 078a406d9c0ab794fc6f006b1c917141fe195d9a	refs/heads/feature/wm3d-warnmerge-20261109
14d12
< 3e391b16f6760b4b64e19d48c7f594ee30717f9a	refs/heads/feature/wm3d-debugcheats-20261108
27d24
< 8cc0640b741447151eebb7ed98d3193136a5ad59	refs/heads/feature/wm3d-warnmerge2-20261109
60d56
< e1bf1e39220d45be0e919dee1bd07cb298cc75a7	refs/heads/feature/wm3d-warnfix-20261108
--tags diff (expect none)
tags same (5)
--PR diff
PR same (6)
--grep 4 names in remote
0
8cc0640b741447151eebb7ed98d3193136a5ad59	refs/heads/main
```
- 다른 가지 변화 0(`diff`에 `>` 줄 없음, `<` 줄은 4개 가지뿐), 태그 변화 0, 열린 PR 변화 0. 로컬·원격 추적 사본에 4개 이름 남은 것 0.

## 되돌리는 법
`git fetch C:/dev/_archive/cleanup_20261029/branches_20261109.bundle refs/remotes/origin/<가지>:refs/heads/<가지>`(예: `refs/remotes/origin/feature/wm3d-warnmerge-20261109:refs/heads/feature/wm3d-warnmerge-20261109`) → 필요하면 김작 승인 후 `git push origin <가지>`. 번들 안 ref 이름은 `refs/remotes/origin/…`다.

## 종료 루틴 5줄
1. 정본 폴더 가지: 로컬 `main` = `8cc0640`(= `origin/main`), 작업 트리 깨끗.
2. 원격 push: 4개 가지 삭제 1회 + 이 보고서 가지 `feature/wm3d-cleanupreport-20261109`. `main`·태그·다른 가지 변경 0, force 0.
3. CI: 해당 없음(코드 변경 0, 보고서 `[skip ci]`).
4. 다음 할 일: 큐에 '준비됨' 항목 없음(27번 CH-4는 11-06에 `c989fdc`·`ac4be24`로 끝났고 큐 표만 '준비됨'). 다른 병합 끝난 `feature/wm3d-*` 정리는 별도 결정 대기.
5. 새로 생긴 가지: `feature/wm3d-cleanupreport-20261109`(삭제는 김작 승인 후 별도). 삭제한 가지 4개는 번들로 복구 가능.
