기준 화면: GitHub 원격 `origin/main` = `8cc0640b741447151eebb7ed98d3193136a5ad59`(30번 디버그 치트+경고 2개, 31번 경고 12개 합류), 태그 `baseline-pre-debugcheats-warnfix-20261109` = `a9e3b84229f63286bbdc784d78826b0e2cdb792d`.
합격 기준: ① 합친 가지(`feature/wm3d-warnmerge2-20261109`)의 C-track 4 shard·`Verify WorldMap3D` 초록 ② 원격 `main` = 그 가지 끝(fast-forward 하나, merge 커밋·force·가지 삭제 0) ③ 원격 태그 = `a9e3b84…` ④ 이 보고서. 최종 확인은 김작이 `main`에서 F6 → 디버거 Errors 탭 0개와 치트 키 동작.

# REPORT_MERGE_MAIN_CHEATS_WARNFIX — 30번과 31번을 합쳐 `main`에 합류 (큐 32번 + 답신 1) (클코드, 2026-11-09)

## 요약
- 30번 끝 `3e391b1` 위에 31번 커밋 3개를 답신 1 순서(문서 2개 → 코드 커밋 마지막)로 얹은 `feature/wm3d-warnmerge2-20261109`(끝 `8cc0640`)를 만들었다. 충돌은 `agent/PROGRESS_WM3D.md` 1회뿐이고, 코드 변경은 30번+31번의 합과 같으며, 고정 파일 4개는 0줄이다.
- 그 가지의 `Verify C-track refactor` `42545277972`(4 shard)와 `Verify WorldMap3D` `42545278007`가 success. 새 테스트 4줄도 원문 그대로 나왔다.
- 백업 태그 `baseline-pre-debugcheats-warnfix-20261109` → `a9e3b84`를 푸시하고, `main`을 `a9e3b84..8cc0640` fast-forward 1회로 옮겼다. `main` tree = `d485bb95439ef21a794f48449fa707d6a35113c0`.

## 판정
**조건부 합격: 자동 기준·CI 통과, 김작 F6(아래 체크리스트) 대기.**
경위: 첫 합친 가지 `feature/wm3d-warnmerge-20261109`는 푸시 끝 커밋이 `[skip ci]`라 CI 0회 → STOP(`REPORT_MERGE_MAIN_CHEATS_WARNFIX_STOP_20261109.md`, 그 가지에만 있음) → 답신 1(A′, 커밋 순서만 바꿔 새 가지) → 재진행.

## 1. 사전 확인 (원 지시서 1절, 전부 통과)
| # | 확인 | 결과 |
|---|---|---|
| 1 | `git status --short` / `is-shallow-repository` | 빈 출력 / `false` |
| 2 | `origin/main` | `a9e3b84229f63286bbdc784d78826b0e2cdb792d` |
| 3 | 30번 끝 / 31번 끝 | `3e391b16f6760b4b64e19d48c7f594ee30717f9a` / `e1bf1e39220d45be0e919dee1bd07cb298cc75a7` |
| 4 | `a9e3b84..30번` 6개 | `dc63ec86c0d3dc781eb7c180d5b49a8a4d0a76d1`, `5a51ebf638389b2f3c08f306ea9a7eb14cd67b4d`, `0e849ee49398b0f26ecc480496b74758a095f017`, `355688c11ec77dc6bb65976e3d54b1a07d3d747c`, `c2c674030aacb3855e39b4547a1f8a679fc760fc`, `3e391b16f6760b4b64e19d48c7f594ee30717f9a` |
| 4 | `a9e3b84..31번` 3개 | `1738d41894a3228ed7f320cf57e6f4457872106a`, `645ffcf5b9a7ed8aa0954428abce9c3ed5d551c1`, `e1bf1e39220d45be0e919dee1bd07cb298cc75a7` |
| 5 | 변경 파일 교집합 | `agent/PROGRESS_WM3D.md` 하나 |
| 6 | 고정 파일 4개 `git diff a9e3b84 <끝>` | 30번 0줄, 31번 0줄 |
| 7 | 기존 CI(읽기) | `42484972498 Verify C-track refactor c2c6740 success`(shard 0~3 success) / `42488036136 Verify C-track refactor 645ffcf success`(shard 0~3 success) / `42488036103 Verify WorldMap3D 645ffcf success` |
| 8 | 원격 태그·합친 가지·보고서 가지 | 모두 빈 출력(`warnmerge2`는 답신 1 뒤 `git ls-remote`로 다시 확인, 빈 출력) |

열린 PR(기록만, 변경 없음): #18(`feature/samwar-sfx-integration` → `experiment/imjin-iso-movement`), #10·#9·#8·#7·#6(`t06-7-*` → `main`).

## 2. 합친 가지 (답신 1 2절)
```
git switch -c feature/wm3d-warnmerge2-20261109 3e391b16f6760b4b64e19d48c7f594ee30717f9a
--pick 1738d41894a3228ed7f320cf57e6f4457872106a
conflicts: agent/PROGRESS_WM3D.md
resolved 1 conflict block(s)          (31번 블록 위, 30번 블록 아래, 문장 수정 0)
continued
--pick e1bf1e39220d45be0e919dee1bd07cb298cc75a7   (충돌 없음)
--pick 645ffcf5b9a7ed8aa0954428abce9c3ed5d551c1   (충돌 없음)
 4 files changed, 22 insertions(+), 6 deletions(-)
```
커밋(위가 최신):
```
8cc0640b741447151eebb7ed98d3193136a5ad59 WARNFIX: clear the 12 GDScript warnings on main (3 shadowed names renamed, 9 intended integer divisions annotated) - no behavior change (queue 31, reply 1)
cdca03d412dc9fb0abc10bf3a649fa355f6b36af docs(agent): WARNFIX report + evidence (queue 31, reply 1) [skip ci]
ac7ee633ebec83831cf71c8eb52f552a3c883f29 docs(agent): WARNFIX stop - 12 warnings on main, 2 more come from the queue-30 cheats controller (queue 31) [skip ci]
```
끝 커밋 메시지(`git log -1 --format=%s%n%b`, `[skip ci]` 없음):
```
WARNFIX: clear the 12 GDScript warnings on main (3 shadowed names renamed, 9 intended integer divisions annotated) - no behavior change (queue 31, reply 1)
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```
(두 번째 줄은 31번 원래 커밋 `645ffcf`의 본문 그대로다.)

푸시 전 자체 확인 원문:
- `git diff --name-only 3e391b1 HEAD`: `agent/` 아래 11개 + `scripts/worldmap/worldmap_turn_compass.gd`, `worldmap3d/scripts/worldmap3d_root.gd`, `worldmap3d/scripts/worldmap_geo.gd`, `worldmap3d/scripts/worldmap_region_labels.gd`(코드는 31번 `.gd` 4개뿐)
- 코드 diff 합 비교(`git diff a9e3b84 HEAD -- scripts worldmap3d tests .github WorldMap.tscn project.godot tools` ↔ `git diff a9e3b84 3e391b1 -- scripts tests .github WorldMap.tscn` + `git diff a9e3b84 645ffcf -- scripts worldmap3d`, 파일별 대조): `files merged 11 sum 11 identical True`, `11 files changed, 736 insertions(+), 6 deletions(-)`
- 고정 파일 4개(`worldmap_main.gd`·`tools/p1_exact_delta.py`·`battle_settlement_applier.gd`·`project.godot`) `git diff a9e3b84 HEAD` 줄 수: `0`
- `git diff 078a406 HEAD --stat -- . ':!agent'`: 빈 출력(이전 합친 가지와 코드 tree 같음)
- tree: `HEAD^{tree}` = `d485bb95439ef21a794f48449fa707d6a35113c0`, 이전 합친 가지 `9a38c1a^{tree}` = `d485bb95439ef21a794f48449fa707d6a35113c0`
- 새 `.uid` 0개, `git status --short` 빈 출력
- `PROGRESS_WM3D.md` 블록 순서: 31번 완료 → 31번 멈춤 → 30번 완료 → 30번 멈춤 → 기존 내용

푸시:
```
git push origin feature/wm3d-warnmerge2-20261109
 * [new branch]      feature/wm3d-warnmerge2-20261109 -> feature/wm3d-warnmerge2-20261109
8cc0640b741447151eebb7ed98d3193136a5ad59	refs/heads/feature/wm3d-warnmerge2-20261109
42545278007 Verify WorldMap3D 8cc0640 in_progress
42545277972 Verify C-track refactor 8cc0640 in_progress
```

## 3. CI (재실행 0)
```
42545277972 Verify C-track refactor 8cc0640 success | verify (shard 3 of 4)=success, verify (shard 1 of 4)=success, verify (shard 0 of 4)=success, verify (shard 2 of 4)=success
42545278007 Verify WorldMap3D 8cc0640 success | worldmap3d=success
```
로그의 새 테스트 줄(원문):
```
[DEBUG_CHEATS] checks=61 failures=[]
[TURN_BUTTON_DAYNIGHT] checks=43 failures=[]
[TURN_SEAM] checks=18 failures=[]
[WORLDMAP3D_HOST] PASS: 58 checks, 0 failures
```
- `[CUTIN]` 실패 줄: 없음(기록할 흔들림 없음).
- 끝 커밋 = CI 커밋(`8cc0640`)이라 "CI 커밋 tree = 최종 끝 tree"는 자명하다(답신 1 3절).

## 4. `main` 합류
```
git tag baseline-pre-debugcheats-warnfix-20261109 a9e3b84229f63286bbdc784d78826b0e2cdb792d
git push origin refs/tags/baseline-pre-debugcheats-warnfix-20261109
 * [new tag]         baseline-pre-debugcheats-warnfix-20261109 -> baseline-pre-debugcheats-warnfix-20261109
git fetch origin; git rev-parse origin/main
a9e3b84229f63286bbdc784d78826b0e2cdb792d
git merge-base --is-ancestor origin/main HEAD   -> exit=0
git rev-list --count HEAD..origin/main          -> 0
git push origin 8cc0640b741447151eebb7ed98d3193136a5ad59:refs/heads/main
   a9e3b84..8cc0640  8cc0640b741447151eebb7ed98d3193136a5ad59 -> main
git fetch origin
origin/main 8cc0640b741447151eebb7ed98d3193136a5ad59
main tree d485bb95439ef21a794f48449fa707d6a35113c0 / HEAD tree d485bb95439ef21a794f48449fa707d6a35113c0
a9e3b84229f63286bbdc784d78826b0e2cdb792d	refs/tags/baseline-pre-debugcheats-warnfix-20261109
git branch -f main origin/main   (로컬 main 전용 커밋 0개, fast-forward)
local main 8cc0640b741447151eebb7ed98d3193136a5ad59
```
- `main` 푸시가 일으킨 워크플로: 없음(`gh run list --branch main` 최신이 2026-07-28 run. `verify-c-track.yml`·`verify-worldmap3d.yml` 둘 다 `push` 가지 목록에 `main`이 없다).

## 되돌리는 법
`baseline-pre-debugcheats-warnfix-20261109` = `a9e3b84229f63286bbdc784d78826b0e2cdb792d`(합류 직전 `main`). 되돌릴 때는 김작 승인 후 별도 지시서로.

## 김작 F6 체크리스트 (원 지시서 6절 그대로)
1. 정본 폴더를 **`main`**(합류 뒤 `origin/main`과 같은 가지)으로 체크아웃한 상태에서 Godot로 `WorldMap.tscn` F6 → 하단 디버거 **Errors 탭이 0개**.
2. 디버그 빌드에서 **Ctrl+Shift+G**: 내 도시 창고가 채워지고 좌측 국고 숫자가 오른다(전에 본 대로 0/9999로 보이면 그건 알려진 이월 건 — 보고서에 쓸 필요 없음).
3. **Ctrl+Shift+T**: 선택한 테크가 즉시 완료되고 도시 안 건물이 켜진다(CH-4 F6 2번과 겹침).
4. **Ctrl+Shift+I**: 첩보 없이 적 성 정보 전부 보임, 한 번 더 누르면 원래대로.
5. 턴 나침반 모양·3D 지역 이름 라벨 위치·채움 프리셋 바꾸기가 전과 같음.

## 종료 루틴 5줄
1. 정본 폴더 가지: 로컬 `main` = `8cc0640`(= `origin/main`), 작업 트리 깨끗. 김작이 바로 F6 가능.
2. 원격 push: `feature/wm3d-warnmerge2-20261109`, 태그 `baseline-pre-debugcheats-warnfix-20261109`, `main` fast-forward 1회, 이 보고서 가지 `feature/wm3d-mergereport3-20261109`. force·삭제 0. 30·31번 가지 변경 0.
3. CI: `42545277972` C-track 4 shard success, `42545278007` WorldMap3D success. 재실행 0.
4. 다음 할 일: 김작 F6(위 1~5). 큐에 다른 '준비됨' 항목(27번 CH-4)이 남아 있으면 이어서.
5. 새로 생긴 가지: `feature/wm3d-warnmerge-20261109`(STOP 가지, 사용 안 함), `feature/wm3d-warnmerge2-20261109`, `feature/wm3d-mergereport3-20261109`. 삭제는 김작 승인 후 별도(30·31번 가지와 함께).
