기준 화면: GitHub 원격에서 `origin/main` = `8cc0640b741447151eebb7ed98d3193136a5ad59`이고, 이미 `main`에 통째로 들어간 `feature/wm3d-*` 가지 7개(`ci-prep-20261101`, `cityhud-20261105`, `hudfix-20261106`, `intake-20261101`, `integrate-20261106`, `m7prep-20261105`, `turnbtn-20261106`)가 원격에 남아 있는 상태. 코드 변경 0.
합격 기준: ① 7개 가지가 원격(과 로컬 사본)에서 사라지고 ② 그 밖의 원격 가지·태그·PR이 하나도 안 바뀌고 ③ 삭제 전 끝 해시·`main` 포함 확인과 기록이 `C:\dev\_archive\cleanup_20261029\`에 있고 ④ 보고서. 김작은 보고서 맨 위 세 줄만 본다.

# 지시서 — CLEANUP-MERGED-BRANCHES: `main`에 들어간 가지 7개 삭제 (큐 34번)

- 작성: 클코치, 2026-11-09. **상태: 준비됨.** 33번(가지 4개 삭제)과 같은 방식, 대상만 다르다.
- **김작 삭제 승인 [사실]**: 11-09 11:53 클코치가 "병합 끝난 원격 가지 7개(ci-prep, intake, cityhud, m7prep, turnbtn, integrate, hudfix) 삭제"를 추천하며 정리 5개 항목을 물은 뒤 "**추천대로**". 승인 범위는 **아래 7개 가지의 원격 삭제와 같은 이름 로컬 사본 삭제**뿐이다.
- 클코치 독립 확인 [사실, 11-09, GitHub compare `main…<끝>`]: 7개 모두 `ahead_by = 0`(`main`에 통째로 포함). 끝 해시:
  - `feature/wm3d-ci-prep-20261101` `66e8ae1a29f7c9bc21102800cef5a91dac81b21d`
  - `feature/wm3d-cityhud-20261105` `ad80253d42f5c0717772ef5c512ee20095f28fc0`
  - `feature/wm3d-hudfix-20261106` `a9e3b84229f63286bbdc784d78826b0e2cdb792d`
  - `feature/wm3d-intake-20261101` `ab9b739d767bcd10afbca4dc885ac79471bdc51c`
  - `feature/wm3d-integrate-20261106` `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`
  - `feature/wm3d-m7prep-20261105` `0bfff7cdecc1e5b8844df750d4dcf13d3a5f7605`
  - `feature/wm3d-turnbtn-20261106` `ff033bb6b36f8dd3e97426f384f5b9ebbe79495f`
  
  (hudfix 끝·intake 끝·integrate 끝은 각각 옛 `main`이었던 커밋이고 백업 태그 `baseline-pre-hudfix-20261106`·`baseline-pre-wm3d-main-20261105`·`baseline-pre-integrate-20261106`이 같은 계보를 가리킨다.) 열린 PR #6~#10(`t06-7-*` → `main`)·#18(→ `experiment/imjin-iso-movement`)은 이 7개 가지와 무관.
- **지우지 않는 것**: `main`, `integration/*`, `work/*`, `archive/*`, orders 가지, 열린 PR의 머리·바닥 가지, **`main`에 안 들어간 `feature/wm3d-*`**(`archivereport`, `bake`, `cityhud4`, `evidence`, `mergereport`, `mergereport2`, `mergereport3`, `cleanupreport`, `perf`) 전부, 옛 `t06-*` 가지와 PR(이번 범위 아님).

## 0. 규칙
1. 새 폴더·worktree 금지(기록은 기존 `C:\dev\_archive\cleanup_20261029\` 안에 파일로만). `main`·태그·다른 가지에 푸시 없음(보고서 푸시 제외). force 금지.
2. 1절 확인이 하나라도 다르면 **삭제하지 말고** `agent/REPORT_CLEANUP_MERGED_STOP_20261109.md`로 멈춘다(원문). 가지 하나가 다르면 그 가지만 빼고 나머지로 진행해도 되며, 뺀 가지와 이유를 보고서에 적는다.
3. 정본 현재 가지가 7개 중 하나이거나 로컬 `main`이 `origin/main`과 다르면 멈춘다(정본은 로컬 `main`이어야 한다).
4. 확인 질문 없이 진행(큐 10절).

## 1. 삭제 전 확인 (결과 원문을 보고서 표로)
1. `git fetch origin --tags`, `git status` 깨끗, `git rev-parse --is-shallow-repository` = false, `origin/main` = `8cc0640b…`.
2. 7개의 원격 끝 해시가 위 표와 같다.
3. 각 가지가 `main`의 조상: `git merge-base --is-ancestor origin/<가지> origin/main` = 0(7개 전부). 아니면 그 가지는 삭제 대상에서 뺀다.
4. `gh api …/pulls?state=open`(읽기)에서 7개 가지가 머리·바닥으로 쓰이지 않는다. 보호 목록·`work/*`와 이름이 겹치지 않는다.
5. 원격 가지 목록 전체(`git ls-remote --heads origin`) 줄 수와 이름을 삭제 전 기준으로 기록(보고서에 개수). 태그 목록(5개)과 열린 PR 목록(6개)도 기록.

## 2. 복구 기록 (삭제 전)
- 7개가 전부 `main`에 포함되어 있으므로 **번들은 만들지 않는다**(번들이 아주 크다). 대신 `C:\dev\_archive\cleanup_20261029\deleted_remote_merged_20261109.tsv`에 줄마다 `가지 이름<TAB>삭제 전 끝 해시<TAB>main에 포함(is-ancestor 0)`을 적는다. 복구는 `git branch <이름> <해시>`로 가능(해시가 `main` 안에 있으므로).

## 3. 삭제 (확인·기록이 끝난 뒤)
1. 가지마다 삭제 직전에 `git rev-parse origin/<가지>`가 tsv 해시와 같은지 다시 확인한다(다르면 그 가지는 건너뛰고 보고).
2. `git push origin --delete <7개 이름>`(한 번에, `--force` 없음).
3. 로컬 사본이 있으면 끝 해시가 tsv와 같은지 확인한 뒤 `git branch -D`(OPERATING_RULES §2: `-d`를 믿지 않는다). 없으면 건너뜀.
4. 삭제 후 `git fetch --prune origin`, `git ls-remote --heads origin`에서 7개가 없고, 삭제 전 목록과 비교해 **정확히 7개만 줄었음**(태그·열린 PR·다른 가지 변화 0)을 보고서에 원문.

## 4. 하지 않는 것
다른 가지·태그 삭제/이동, `main`·orders·`archive/*` 변경, PR 닫기·병합, 옛 `t06-*` 가지 삭제, `main`에 안 들어간 `feature/wm3d-*` 삭제, 새 폴더·번들 생성, 코드·워크플로 수정.

## 5. 보고서
`agent/REPORT_CLEANUP_MERGED_BRANCHES_20261109.md`: 맨 위 "기준 화면 / 합격 기준" 두 줄 + 3줄 요약 + 1절 확인 표 + 2절 tsv 내용 + 3절 삭제 명령·결과 + 삭제 전후 원격 가지 개수 + 되돌리는 법 한 줄 + 종료 루틴 5줄(OPERATING_RULES §4).
보고서는 **기존 가지 `feature/wm3d-cleanupreport-20261109`**(33번 보고서가 있는 가지)에 새 커밋 1개(`[skip ci]`)로 올린다(fast-forward 푸시, 새 가지를 만들지 않는다). 정본은 끝날 때 로컬 `main`에 둔다.
