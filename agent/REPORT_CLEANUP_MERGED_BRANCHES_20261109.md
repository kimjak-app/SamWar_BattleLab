기준 화면: GitHub 원격 `origin/main` = `8cc0640b741447151eebb7ed98d3193136a5ad59`, 원격 가지 63개 → 56개(`main`에 통째로 들어간 `feature/wm3d-*` 7개 삭제), 태그 5개·열린 PR 6개 그대로. 기록 `C:\dev\_archive\cleanup_20261029\deleted_remote_merged_20261109.tsv`.
합격 기준: ① 7개 가지가 원격과 로컬 사본에서 사라짐 ② 그 밖의 원격 가지·태그·PR 변화 0 ③ 삭제 전 끝 해시·`main` 포함 확인과 기록이 `C:\dev\_archive\cleanup_20261029\`에 있음 ④ 이 보고서.
판정: **합격** — 7개 삭제(원격·로컬), 다른 가지·태그·PR 변화 0, 7개 모두 `main` 조상이라 `git branch <이름> <해시>`로 되살릴 수 있음.

# REPORT_CLEANUP_MERGED_BRANCHES — `main`에 들어간 가지 7개 삭제 (큐 34번) (클코드, 2026-11-09)

## 요약
- 삭제 전 확인 5개가 모두 지시서와 같았다: `origin/main` = `8cc0640`, 7개의 끝 해시, 7개 전부 `main` 조상(is-ancestor 0), PR 무관, 삭제 전 목록 기록(가지 63·태그 5·PR 6).
- 번들은 만들지 않고(지시서 2절), 끝 해시 기록 tsv 1개를 `C:\dev\_archive\cleanup_20261029\`에 저장했다.
- `git push origin --delete` 1회로 원격 7개를 지우고, 로컬 사본 7개는 끝 해시를 tsv와 맞춰 본 뒤 `git branch -D`로 지웠다. 원격 가지는 정확히 7개만 줄었다(63 → 56). 뺀 가지는 없다.

## 1. 삭제 전 확인
| # | 확인 | 결과 |
|---|---|---|
| 1 | `git fetch origin --tags`, `git status --short`, 현재 가지, `is-shallow-repository`, `origin/main` | 빈 출력, `main`, `false`, `8cc0640b741447151eebb7ed98d3193136a5ad59`(로컬 `main`도 같음) |
| 2·3 | `feature/wm3d-ci-prep-20261101` | `66e8ae1a29f7c9bc21102800cef5a91dac81b21d` 같음, ancestor=0 |
| 2·3 | `feature/wm3d-cityhud-20261105` | `ad80253d42f5c0717772ef5c512ee20095f28fc0` 같음, ancestor=0 |
| 2·3 | `feature/wm3d-hudfix-20261106` | `a9e3b84229f63286bbdc784d78826b0e2cdb792d` 같음, ancestor=0 |
| 2·3 | `feature/wm3d-intake-20261101` | `ab9b739d767bcd10afbca4dc885ac79471bdc51c` 같음, ancestor=0 |
| 2·3 | `feature/wm3d-integrate-20261106` | `042b0708f9af4fe3f30d51caa1c988d9b064f8b0` 같음, ancestor=0 |
| 2·3 | `feature/wm3d-m7prep-20261105` | `0bfff7cdecc1e5b8844df750d4dcf13d3a5f7605` 같음, ancestor=0 |
| 2·3 | `feature/wm3d-turnbtn-20261106` | `ff033bb6b36f8dd3e97426f384f5b9ebbe79495f` 같음, ancestor=0 |
| 4 | 열린 PR(`gh api …/pulls?state=open`, 읽기) | #18 `feature/samwar-sfx-integration -> experiment/imjin-iso-movement`, #10 `t06-7-hotfix7-full-overlay-trigger -> main`, #9 `t06-7-range-overlay-audit-trigger -> main`, #8 `t06-7-hotfix5-self-area-manual-confirm-trigger -> main`, #7 `t06-7-hotfix4-self-area-range-trigger -> main`, #6 `t06-7-skill-range-audit-trigger -> main`. 7개 가지가 머리·바닥으로 쓰인 횟수 `0 0 0 0 0 0 0`. 보호 목록 `[]`, 이름은 `work/*`·`integration/*`·`archive/*`와 겹치지 않음 |
| 5 | 삭제 전 기록 | 원격 가지 `63`, 태그 `5`, 열린 PR `6` |

## 2. 복구 기록 (`C:\dev\_archive\cleanup_20261029\deleted_remote_merged_20261109.tsv`, 706바이트, 새 폴더·번들 0)
```
feature/wm3d-ci-prep-20261101	66e8ae1a29f7c9bc21102800cef5a91dac81b21d	main에 포함(is-ancestor 0)
feature/wm3d-cityhud-20261105	ad80253d42f5c0717772ef5c512ee20095f28fc0	main에 포함(is-ancestor 0)
feature/wm3d-hudfix-20261106	a9e3b84229f63286bbdc784d78826b0e2cdb792d	main에 포함(is-ancestor 0)
feature/wm3d-intake-20261101	ab9b739d767bcd10afbca4dc885ac79471bdc51c	main에 포함(is-ancestor 0)
feature/wm3d-integrate-20261106	042b0708f9af4fe3f30d51caa1c988d9b064f8b0	main에 포함(is-ancestor 0)
feature/wm3d-m7prep-20261105	0bfff7cdecc1e5b8844df750d4dcf13d3a5f7605	main에 포함(is-ancestor 0)
feature/wm3d-turnbtn-20261106	ff033bb6b36f8dd3e97426f384f5b9ebbe79495f	main에 포함(is-ancestor 0)
```
저장소 `git status --short`: 빈 출력(tsv는 저장소 밖).

## 3. 삭제
삭제 직전 재확인(`git fetch`, `git rev-parse origin/<가지>` == tsv 해시):
```
match feature/wm3d-ci-prep-20261101
match feature/wm3d-cityhud-20261105
match feature/wm3d-hudfix-20261106
match feature/wm3d-intake-20261101
match feature/wm3d-integrate-20261106
match feature/wm3d-m7prep-20261105
match feature/wm3d-turnbtn-20261106
```
원격 삭제(1회, `--force` 없음):
```
git push origin --delete feature/wm3d-ci-prep-20261101 feature/wm3d-cityhud-20261105 feature/wm3d-hudfix-20261106 feature/wm3d-intake-20261101 feature/wm3d-integrate-20261106 feature/wm3d-m7prep-20261105 feature/wm3d-turnbtn-20261106
To https://github.com/kimjak-app/SamWar_BattleLab.git
 - [deleted]         feature/wm3d-ci-prep-20261101
 - [deleted]         feature/wm3d-cityhud-20261105
 - [deleted]         feature/wm3d-hudfix-20261106
 - [deleted]         feature/wm3d-intake-20261101
 - [deleted]         feature/wm3d-integrate-20261106
 - [deleted]         feature/wm3d-m7prep-20261105
 - [deleted]         feature/wm3d-turnbtn-20261106
```
로컬 사본(끝 해시 == tsv 확인 뒤 `git branch -D`):
```
Deleted branch feature/wm3d-ci-prep-20261101 (was 66e8ae1).
Deleted branch feature/wm3d-cityhud-20261105 (was ad80253).
Deleted branch feature/wm3d-hudfix-20261106 (was a9e3b84).
Deleted branch feature/wm3d-intake-20261101 (was ab9b739).
Deleted branch feature/wm3d-integrate-20261106 (was 042b070).
Deleted branch feature/wm3d-m7prep-20261105 (was 0bfff7c).
Deleted branch feature/wm3d-turnbtn-20261106 (was ff033bb).
```
삭제 후(`git fetch --prune origin`, 삭제 전 저장본과 `diff`):
```
heads before 63 after 56
--heads diff
1d0
< 042b0708f9af4fe3f30d51caa1c988d9b064f8b0	refs/heads/feature/wm3d-integrate-20261106
4d2
< 0bfff7cdecc1e5b8844df750d4dcf13d3a5f7605	refs/heads/feature/wm3d-m7prep-20261105
17d14
< 66e8ae1a29f7c9bc21102800cef5a91dac81b21d	refs/heads/feature/wm3d-ci-prep-20261101
35d31
< a9e3b84229f63286bbdc784d78826b0e2cdb792d	refs/heads/feature/wm3d-hudfix-20261106
37d32
< ab9b739d767bcd10afbca4dc885ac79471bdc51c	refs/heads/feature/wm3d-intake-20261101
39d33
< ad80253d42f5c0717772ef5c512ee20095f28fc0	refs/heads/feature/wm3d-cityhud-20261105
63d56
< ff033bb6b36f8dd3e97426f384f5b9ebbe79495f	refs/heads/feature/wm3d-turnbtn-20261106
--tags
tags same (5)
--PR
PR same (6)
--7 names left (remote list / local+tracking)
0
0
```
- 다른 가지 변화 0(`>` 줄 없음, `<` 줄은 7개뿐), 태그 변화 0, 열린 PR 변화 0.
- 남은 `feature/wm3d-*`(지우지 않는 것 목록과 같음): `perf-20261106`, `mergereport-20261106`, `evidence-20261106`, `archivereport-20261107`, `cityhud4-20261106`, `orders-20261105`, `mergereport3-20261109`, `bake-20261106`, `mergereport2-20261106`, `cleanupreport-20261109`.

## 되돌리는 법
tsv의 해시가 모두 `main` 안에 있으므로 `git branch <가지 이름> <해시>`(예: `git branch feature/wm3d-cityhud-20261105 ad80253d42f5c0717772ef5c512ee20095f28fc0`) → 필요하면 김작 승인 후 `git push origin <가지 이름>`.

## 종료 루틴 5줄
1. 정본 폴더 가지: 로컬 `main` = `8cc0640`(= `origin/main`), 작업 트리 깨끗.
2. 원격 push: 7개 가지 삭제 1회 + 기존 보고서 가지 `feature/wm3d-cleanupreport-20261109`에 이 보고서 커밋 1개(fast-forward). `main`·태그·다른 가지 변경 0, force 0.
3. CI: 해당 없음(코드 변경 0, 보고서 `[skip ci]`).
4. 다음 할 일: 큐에 '준비됨' 항목 없음. 김작 F6(32번). 남은 `feature/wm3d-*`·옛 `t06-*` 정리는 별도 결정 대기.
5. 새로 생긴 가지: 없음(보고서는 기존 `cleanupreport` 가지). 지운 가지 7개는 tsv 해시로 되살릴 수 있음.
