기준 화면: GitHub 원격에서 `origin/main`이 `a9e3b84229f63286bbdc784d78826b0e2cdb792d`이고, 큐 30번 가지(`feature/wm3d-debugcheats-20261108` 끝 `3e391b16f6760b4b64e19d48c7f594ee30717f9a`, 코드 끝 `c2c674030aacb3855e39b4547a1f8a679fc760fc`)와 큐 31번 가지(`feature/wm3d-warnfix-20261108` 끝 `e1bf1e39220d45be0e919dee1bd07cb298cc75a7`, 코드 `645ffcf5b9a7ed8aa0954428abce9c3ed5d551c1`)가 아직 `main`에 없는 상태. 백업 태그 `baseline-pre-debugcheats-warnfix-20261109`는 아직 없음.
합격 기준: ① 두 가지를 합친 새 가지(`feature/wm3d-warnmerge-20261109`)의 C-track 4 shard·`Verify WorldMap3D` 초록 ② 원격 `main` = 그 가지의 끝(`main` 푸시는 fast-forward 하나, merge 커밋·force·가지 삭제 0) ③ 원격 태그 `baseline-pre-debugcheats-warnfix-20261109` = `a9e3b84…` ④ 보고서. 최종 확인은 김작이 `main`에서 F6 → 디버거 Errors 탭 **0개**와 치트 키 동작.

# 지시서 — MERGE-MAIN-CHEATS-WARNFIX: 30번(디버그 치트+경고 2개)과 31번(경고 12개)을 합쳐 `main`에 합류 (큐 32번)

- 작성: 클코치, 2026-11-09. **상태: 준비됨.**
- **김작 `main` 합류 승인 [사실]**: 11-09 10:08 "**병합해.**" (직전에 클코치가 "30번 먼저, 31번 다음, `main`에서 F6로 경고 0 확인"이라고 말한 뒤). 승인 범위는 **이 지시서의 `main` 푸시 1회 + 태그 푸시 1회 + 새 가지 `feature/wm3d-warnmerge-20261109`·`feature/wm3d-mergereport3-20261109` 푸시**뿐이다.
- **김작 F6 상태 [사실]**: 31번 가지에서 경고 0은 클코드 측정(증거 있음), 김작은 30번 가지에서 Errors 12개(=31번 몫)를 직접 봤다. 치트 3개 키 F6(30번 보고서 8절 1~5)는 **김작이 아직 다 안 눌러봄 [미확인]** — 디버그 빌드 전용이고 `main` 0줄 구조라 위험이 작다고 보고 합류를 승인받았다. 합류 뒤 `main`에서 확인한다.
- 클코치 독립 검증 [사실, 11-08~09]: 30번 변경은 `main`에서 `.github/workflows/verify-c-track.yml`(+1), `WorldMap.tscn`(+5), `spy_presentation_helper.gd`(+5), 컨트롤러·테스트·`.uid` 신규 + `agent/` 문서. 31번 변경은 `.gd` 4개(`worldmap_turn_compass.gd`·`worldmap3d_root.gd`·`worldmap_geo.gd`·`worldmap_region_labels.gd`) + `agent/` 문서. **코드 파일은 겹치지 않는다.** 겹치는 파일은 **`agent/PROGRESS_WM3D.md` 하나**(둘 다 "현재 상태" 맨 위에 블록을 끼워 넣음). `worldmap_main.gd`·`tools/p1_exact_delta.py`·`project.godot` 변경은 두 가지 모두 0줄.
- 두 가지의 시작점은 둘 다 `main` `a9e3b84`라서 **둘을 그대로 fast-forward로 연달아 넣을 수는 없다**. 그래서 30번 끝 위에 31번 커밋 3개를 얹은 합친 가지를 만들고, 그 가지를 CI에 돌린 뒤 `main`을 fast-forward한다.

## 0. 규칙
1. `main`은 **이 지시서의 승인으로만** 건드린다. force·가지 삭제·다른 가지 수정 금지. **30번·31번 가지에 새 커밋 금지**(끝 해시가 합류 재료).
2. 1절 확인이 하나라도 다르거나, 합치다 **`agent/PROGRESS_WM3D.md` 밖의 파일에서 충돌이 나거나**, 합친 가지의 CI가 실패하면 **`main`을 푸시하지 말고** `agent/REPORT_MERGE_MAIN_CHEATS_WARNFIX_STOP_20261109.md`로 멈춘다(원문). 재실행·허용 오차·땜빵 금지. 멈춤은 이 항목만 막는다.
3. 새 폴더·worktree 금지. 합치기는 정본 작업 폴더에서 새 가지로 한다(끝나면 정본은 7절 마지막 줄대로 로컬 `main` 가지로 둔다).
4. 확인 질문 없이 진행(큐 10절).

## 1. 사전 확인 (결과 원문을 보고서 표로)
1. `git fetch origin --tags`. 작업 폴더 `git status` 깨끗(아니면 멈춤). `git rev-parse --is-shallow-repository` = false.
2. `origin/main` = `a9e3b84229f63286bbdc784d78826b0e2cdb792d`.
3. `origin/feature/wm3d-debugcheats-20261108` = `3e391b16f6760b4b64e19d48c7f594ee30717f9a`, `origin/feature/wm3d-warnfix-20261108` = `e1bf1e39220d45be0e919dee1bd07cb298cc75a7`.
4. `git rev-list --reverse a9e3b84..origin/feature/wm3d-debugcheats-20261108`가 `dc63ec8`·`5a51ebf`·`0e849ee`·`355688c`·`c2c6740`·`3e391b1` 6개이고, `a9e3b84..origin/feature/wm3d-warnfix-20261108`가 `1738d41`·`645ffcf`·`e1bf1e3` 3개(전체 해시는 보고서에 적는다).
5. 두 가지의 `git diff --name-only a9e3b84 <끝>` 교집합이 `agent/PROGRESS_WM3D.md` 하나뿐.
6. 두 가지 모두 `worldmap_main.gd`·`tools/p1_exact_delta.py`·`scripts/worldmap/military/battle_settlement_applier.gd`·`project.godot`의 `git diff a9e3b84 <끝>`이 0줄.
7. `gh`(읽기만)로 확인·기록: 30번 `c2c6740`의 `Verify C-track refactor` run `42484972498` 4 shard success, 31번 `645ffcf`의 C-track run `42488036136`·`Verify WorldMap3D` run `42488036103` success. 열린 PR 목록 기록만.
8. `git ls-remote origin refs/tags/baseline-pre-debugcheats-warnfix-20261109`, `refs/heads/feature/wm3d-warnmerge-20261109`가 비어 있음(있으면 멈춤).

## 2. 합친 가지 만들기 (순서 고정)
1. `git switch -c feature/wm3d-warnmerge-20261109 3e391b16f6760b4b64e19d48c7f594ee30717f9a`(30번 끝에서 시작).
2. 31번 커밋 3개를 **순서대로** `git cherry-pick 1738d41… 645ffcf… e1bf1e3…`(전체 해시). 코드 커밋 `645ffcf` 복사본은 커밋 메시지를 그대로 둔다(`[skip ci]` 없음 → CI가 이 커밋에서 돈다). 나머지 둘은 원래 `[skip ci]`.
3. 충돌은 **`agent/PROGRESS_WM3D.md`에서만** 허용한다. 해결 방법: 31번 블록 2개(큐 31번 WARNFIX 완료·멈춤)를 위, 30번 블록 2개(큐 30번 DEBUG-CHEATS 완료·멈춤)를 그 아래, 기존 내용은 그대로. 어느 블록도 지우거나 문장을 고치지 않는다. 다른 파일에서 충돌하면 즉시 `git cherry-pick --abort`하고 0절 2번대로 멈춘다.
4. 합친 가지 자체 확인(원문을 보고서에):
   - `git diff --name-only 3e391b1 HEAD`: 31번이 바꾼 `.gd` 4개 + `agent/` 아래 파일뿐. 코드 파일이 더 있으면 멈춤.
   - `git diff a9e3b84 HEAD -- scripts worldmap3d tests .github WorldMap.tscn project.godot tools`가 30번 코드 변경 + 31번 코드 변경의 합과 같다(`git diff a9e3b84 3e391b1 -- scripts tests .github WorldMap.tscn`과 `git diff a9e3b84 645ffcf -- scripts worldmap3d`를 이어 붙인 것과 비교).
   - `worldmap_main.gd`·`tools/p1_exact_delta.py`·`battle_settlement_applier.gd`·`project.godot`의 `git diff a9e3b84 HEAD`가 0줄.
   - 새 `.uid` 파일이 생기면(생기지 않을 것) 같이 커밋.
5. `git push origin feature/wm3d-warnmerge-20261109`(이 가지에만).

## 3. CI 기다리기 (재실행 금지)
- 푸시가 일으킨 `Verify C-track refactor`(4 shard)·`Verify WorldMap3D` run을 기다린다. **CI는 `645ffcf` 복사본에서 돈다**(뒤따르는 `e1bf1e3` 복사본은 문서만이라 `[skip ci]`).
- 둘 다 success가 아니면(Diff check 단계 포함) `main`을 건드리지 않고 멈춘다. 이미 알려진 `[CUTIN]` 흔들림은 큐 4절 규칙대로 **기록만**, 재실행하지 않는다.
- 로그에서 새 테스트 줄 원문 기록: `[DEBUG_CHEATS] checks=61 failures=[]`, `[TURN_BUTTON_DAYNIGHT] checks=43 failures=[]`, `[TURN_SEAM] checks=18 failures=[]`, `[WORLDMAP3D_HOST] PASS: 58 checks, 0 failures`.
- `645ffcf` 복사본의 tree와 최종 끝의 tree가 `agent/` 밖에서 같음을 보인다(`git diff <복사본> HEAD --stat -- . ':!agent'`가 비어 있음).

## 4. `main` 합류 (CI 둘 다 success일 때만, 순서 고정)
1. 백업 태그: `git tag baseline-pre-debugcheats-warnfix-20261109 a9e3b84229f63286bbdc784d78826b0e2cdb792d`(가벼운 태그) → `git push origin refs/tags/baseline-pre-debugcheats-warnfix-20261109`.
2. 푸시 직전 `git fetch origin` 후 `origin/main`이 아직 `a9e3b84…`인지 다시 확인(다르면 멈춤).
3. `git merge-base --is-ancestor origin/main HEAD` 성공(0), `git rev-list --count HEAD..origin/main` = 0.
4. `git push origin <합친 가지 끝 해시>:refs/heads/main`(`--force`·`+` 없음). 거부되면 멈추고 메시지 원문 보고.
5. 푸시 직후 `git fetch origin`: `origin/main` = 합친 가지 끝, tree 일치, 태그 = `a9e3b84…` 확인.
6. 로컬 `main` 가지가 있으면 `git branch -f main origin/main`(fast-forward일 때만; 로컬 전용 커밋이 있으면 보고만).
7. `main` 푸시가 일으킨 워크플로가 있으면 이름·결과 기록(읽기). 새 실패가 나와도 되돌리지 말고 보고.

## 5. 하지 않는 것
force push, `main`에 새 커밋(merge 커밋 포함), 30번·31번 가지 수정/삭제, 합친 가지·두 가지 삭제(삭제는 김작 승인 후 별도), 태그 이동/삭제, PR 생성·병합·닫기, `.github` 수정, CI 재실행·허용 오차 조정, 치트 ① 용량(9999) 같은 동작 변경.

## 6. 김작 F6 체크리스트 (보고서 맨 아래에 그대로)
1. 정본 폴더를 **`main`**(합류 뒤 `origin/main`과 같은 가지)으로 체크아웃한 상태에서 Godot로 `WorldMap.tscn` F6 → 하단 디버거 **Errors 탭이 0개**.
2. 디버그 빌드에서 **Ctrl+Shift+G**: 내 도시 창고가 채워지고 좌측 국고 숫자가 오른다(전에 본 대로 0/9999로 보이면 그건 알려진 이월 건 — 보고서에 쓸 필요 없음).
3. **Ctrl+Shift+T**: 선택한 테크가 즉시 완료되고 도시 안 건물이 켜진다(CH-4 F6 2번과 겹침).
4. **Ctrl+Shift+I**: 첩보 없이 적 성 정보 전부 보임, 한 번 더 누르면 원래대로.
5. 턴 나침반 모양·3D 지역 이름 라벨 위치·채움 프리셋 바꾸기가 전과 같음.

## 7. 보고서
`agent/REPORT_MERGE_MAIN_CHEATS_WARNFIX_20261109.md`: 맨 위 "기준 화면 / 합격 기준" 두 줄 + 3줄 요약 + 판정(**조건부 합격: 자동 기준·CI 통과, 김작 F6 6절 대기**) + 1절 확인 표 + 2·3·4절 명령·결과 원문 + 열린 PR 목록 + 되돌리는 법 한 줄(`baseline-pre-debugcheats-warnfix-20261109` = `a9e3b84…`) + F6 체크리스트 + 종료 루틴 5줄(OPERATING_RULES §4).
보고서는 **새 가지 `feature/wm3d-mergereport3-20261109`**(시작 = 합류된 `main` 끝)에 `[skip ci]`로 올린다. `main`·합친 가지에는 올리지 않는다.
종료 루틴 1번의 정본 가지: 작업을 마칠 때 정본은 `main`과 같은 해시의 로컬 `main` 가지로 둔다(김작이 바로 F6). 새로 생긴 가지(`warnmerge`, `mergereport3`)와 삭제 예정 시점(김작 승인 후)을 5줄에 적는다.
