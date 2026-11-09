기준 화면: GitHub 원격에서 `origin/main` = `8cc0640b741447151eebb7ed98d3193136a5ad59`이고, 이미 `main`에 들어간 작업 가지 4개(`feature/wm3d-debugcheats-20261108`, `feature/wm3d-warnfix-20261108`, `feature/wm3d-warnmerge-20261109`, `feature/wm3d-warnmerge2-20261109`)가 원격에 남아 있는 상태. 코드 변경 0.
합격 기준: ① 4개 가지가 원격(과 로컬 사본)에서 사라지고 ② 그 밖의 원격 가지·태그·PR이 하나도 안 바뀌고 ③ 삭제 전 끝 해시·내용 확인과 복구용 번들·기록이 `C:\dev\_archive\cleanup_20261029\`에 있고 ④ 보고서. 김작은 보고서 맨 위 세 줄만 본다.

# 지시서 — CLEANUP-BRANCHES: 병합 끝난 가지 4개 삭제 (큐 33번)

- 작성: 클코치, 2026-11-09. **상태: 준비됨.**
- **김작 삭제 승인 [사실]**: 11-09 11:07 클코치가 "열린 가지 정리(warnmerge, warnmerge2, 30·31번 가지)는 승인해 주면 한다"고 말한 뒤 "지워주고". 승인 범위는 **아래 4개 가지의 원격 삭제와 같은 이름 로컬 사본 삭제**뿐이다. 다른 가지·태그·PR·파일에는 쓸 수 없다.
- 클코치 독립 확인 [사실, 11-09]: 끝 해시 `3e391b16f6760b4b64e19d48c7f594ee30717f9a`(debugcheats), `e1bf1e39220d45be0e919dee1bd07cb298cc75a7`(warnfix), `078a406d9c0ab794fc6f006b1c917141fe195d9a`(warnmerge), `8cc0640b741447151eebb7ed98d3193136a5ad59`(warnmerge2). debugcheats·warnmerge2는 `main`의 조상(warnmerge2 = `main` 끝). warnfix는 31번 커밋을 cherry-pick해 `main`에 넣었으므로 해시는 다르지만 31번 파일 내용이 `main`과 같다. warnmerge는 `agent/REPORT_MERGE_MAIN_CHEATS_WARNFIX_STOP_20261109.md` 한 파일과 `PROGRESS_WM3D.md` 블록만 따로 가진다. 열린 PR #6~#10(`t06-7-*` → `main`)·#18은 이 4개 가지와 무관.
- **지우지 않는 것**: `main`, `integration/*`, `work/*`, `archive/*`, orders 가지, 열린 PR의 머리·바닥 가지, `feature/wm3d-mergereport3-20261109`(합류 보고서가 있음), 이미 병합된 다른 `feature/wm3d-*`(ci-prep·intake·cityhud·m7prep·turnbtn·integrate·hudfix 등 — 별도 결정 대기).

## 0. 규칙
1. 새 폴더·worktree 금지(기록은 기존 `C:\dev\_archive\cleanup_20261029\` 안에 파일로만 둔다). `main`·태그·다른 가지에 어떤 푸시도 하지 않는다(보고서 가지 제외). force 금지.
2. 1절 확인이 하나라도 다르면 **삭제하지 말고** `agent/REPORT_CLEANUP_BRANCHES_STOP_20261109.md`로 멈춘다(무엇이 달랐는지 원문). 멈춤은 이 항목만 막는다.
3. 정본 작업 폴더의 현재 가지가 지울 4개 중 하나면 먼저 `git switch main`(로컬 `main`이 `origin/main`과 같을 때만; 로컬 전용 커밋·변경이 있으면 멈춤).
4. 확인 질문 없이 진행(큐 10절).

## 1. 삭제 전 확인 (결과 원문을 보고서 표로)
1. `git fetch origin --tags`, `git status` 깨끗, `git rev-parse --is-shallow-repository` = false.
2. 원격 끝 해시가 위 4개와 같다(`git rev-parse origin/<가지>`). `origin/main` = `8cc0640b…`.
3. `gh api repos/.../pulls?state=open`(읽기)에서 4개 가지가 머리·바닥으로 쓰이지 않는다. 보호 목록·`work/*`와 이름이 겹치지 않는다.
4. `git merge-base --is-ancestor origin/feature/wm3d-debugcheats-20261108 origin/main`과 `… warnmerge2-20261109 origin/main` 둘 다 0.
5. warnfix: `git diff --name-only origin/main origin/feature/wm3d-warnfix-20261108`에 나오는 파일이 **30번 작업 파일과 `PROGRESS_WM3D.md`뿐**이다. 30번 파일 = `.github/workflows/verify-c-track.yml`, `WorldMap.tscn`, `scripts/worldmap/actions/spy_presentation_helper.gd`, `scripts/worldmap/ui/worldmap_debug_cheats_controller.gd`(+`.uid`), `tests/scripts/test_worldmap_debug_cheats.gd`(+`.uid`), `agent/REPORT_DEBUG_CHEATS*`, `agent/evidence/debugcheats_20261108/*`. 31번 파일(`worldmap_turn_compass.gd`, `worldmap3d_root.gd`, `worldmap_geo.gd`, `worldmap_region_labels.gd`, `agent/REPORT_WARNFIX*`, `agent/evidence/warnfix_20261108/*`)은 `main`과 **diff 0**.
6. warnmerge: `git diff --name-only origin/feature/wm3d-warnmerge2-20261109 origin/feature/wm3d-warnmerge-20261109`이 `agent/PROGRESS_WM3D.md`와 `agent/REPORT_MERGE_MAIN_CHEATS_WARNFIX_STOP_20261109.md` 둘뿐이다.

## 2. 복구용 기록 (삭제 전, 순서 고정)
1. `C:\dev\_archive\cleanup_20261029\`에 **새 파일 3개**를 만든다(폴더는 이미 있음):
   - `branches_20261109.bundle`: `git bundle create … feature/wm3d-debugcheats-20261108 feature/wm3d-warnfix-20261108 feature/wm3d-warnmerge-20261109 feature/wm3d-warnmerge2-20261109`(원격 ref 기준 `origin/…`에서 만들어도 된다). 만든 뒤 `git bundle verify` 통과를 보고서에 원문.
   - `deleted_remote_20261109.tsv`: 줄마다 `가지 이름<TAB>삭제 전 끝 해시<TAB>삭제 이유(main 합류 방식)`.
   - `warnmerge_STOP_report_20261109.md`: warnmerge 가지의 `agent/REPORT_MERGE_MAIN_CHEATS_WARNFIX_STOP_20261109.md` 원문 사본(이 파일만 `main`에 없다).
2. 세 파일이 저장소 **바깥**(`C:\dev\_archive`)에 있으므로 저장소 `git status`는 영향이 없다. 파일 크기와 번들 `verify` 결과를 보고서에 적는다.

## 3. 삭제 (확인·기록이 모두 끝난 뒤)
1. 가지마다 삭제 직전에 `git rev-parse origin/<가지>`가 tsv 해시와 같은지 다시 확인하고, 다르면 그 가지는 건너뛰고 보고한다.
2. `git push origin --delete feature/wm3d-debugcheats-20261108 feature/wm3d-warnfix-20261108 feature/wm3d-warnmerge-20261109 feature/wm3d-warnmerge2-20261109`(한 번에 4개, `--force` 없음).
3. 로컬 사본이 있으면 가지마다 `merge-base --is-ancestor`가 아니라 **끝 해시가 tsv와 같은지**로 확인한 뒤 `git branch -D`(OPERATING_RULES §2: `-d`를 믿지 않는다).
4. 삭제 후 `git fetch --prune origin`, `git ls-remote --heads origin`에서 4개가 없고, 삭제 전 목록과 비교해 **정확히 4개만 줄었음**(다른 가지 변화 0, 태그 변화 0, 열린 PR 목록 변화 0)을 보고서에 원문.

## 4. 하지 않는 것
다른 가지·태그 삭제/이동, `main`·orders·`archive/*` 변경, PR 닫기·병합, 이미 병합된 다른 `feature/wm3d-*` 삭제(별도 결정), 번들·기록 파일 외 새 폴더 생성, 코드·워크플로 수정.

## 5. 보고서
`agent/REPORT_CLEANUP_BRANCHES_20261109.md`: 맨 위 "기준 화면 / 합격 기준" 두 줄 + 3줄 요약 + 1절 확인 표 + 2절 번들 `verify`·tsv 내용 + 3절 삭제 명령·결과 + 삭제 전후 원격 가지 개수 + 되돌리는 법 한 줄(번들 경로와 `git fetch <번들> <가지>:<가지>`) + 종료 루틴 5줄(OPERATING_RULES §4).
보고서는 **새 가지 `feature/wm3d-cleanupreport-20261109`**(시작 `main` `8cc0640b…`)에 `[skip ci]`로 올린다. 정본은 끝날 때 로컬 `main`에 둔다.
