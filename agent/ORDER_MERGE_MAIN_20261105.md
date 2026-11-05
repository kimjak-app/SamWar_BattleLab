기준 화면: GitHub 원격에서 `origin/main`이 `ab9b739d767bcd10afbca4dc885ac79471bdc51c`(= `feature/wm3d-intake-20261101` 끝)이고, 기준점 태그 `baseline-pre-wm3d-main-20261105`가 옛 `main` 끝 `66b29ba13b735a0784da23fccad5632e8f65beb1`에 달려 있는 상태.
합격 기준: ① 원격 `main` = `ab9b739d…`, tree `e20215ab2939535c243f658c5e74b2c31aa64c5a` ② `main` 푸시는 fast-forward 하나(merge 커밋·force·가지 삭제·재작성 0) ③ 원격 태그가 `66b29ba1…`를 가리킴 ④ 보고서. 김작은 보고서 맨 위 세 줄과 GitHub의 `main` 해시만 본다(F6 없음).

# 지시서 — MERGE-MAIN: 3D 월드맵 작업을 `main`에 합류 (fast-forward)

- 작성: 클코치, 2026-11-05 22:35.
- **김작 승인 [사실]**: 21:54 "푸시해줘", 22:11 클코치가 대상·해시·887커밋·태그 푸시를 모두 말한 뒤 "응". 승인 범위는 **이 지시서의 `main` 푸시 1회 + 태그 푸시 1회**뿐이다. 이 승인은 다른 가지·다른 푸시에 쓸 수 없다.
- 클코치 독립 검증 [사실, 11-05 22:00~22:10, 전체 이력 받은 뒤 확인]: 끝 `ab9b739d…`/tree `e20215ab…`. 코드 커밋 `cbe28c0`과의 차이는 `agent/` 문서 4개뿐(코드 동일). `cbe28c0`의 `Verify C-track refactor` 4 shard + `Verify WorldMap3D` 모두 success(06·07·08 각 커밋도 success). 계보 `main`(66b29ba) ⊂ `integration/p1-engine-core-20261019` ⊂ intake, `main..intake` = 887커밋(merge 70, `intake..main` = 0). `main`은 2026-09-01 이후 정지, 보호 설정 없음, 저장소 private.

## 0. 규칙
1. 이 작업은 `main`을 **이 지시서의 승인으로만** 건드린다. force 금지, 가지 삭제 금지, `integration`·열린 PR 가지·`work/*`·intake 가지 수정 금지.
2. 아래 1절 사전 확인 중 **하나라도 다르면 푸시하지 말고** `agent/REPORT_MERGE_MAIN_STOP_20261105.md`로 멈춘다(어떤 값이 어떻게 달랐는지 원문). 땜빵·재시도·다른 해시로 바꿔서 진행 금지.
3. 새 폴더·worktree 금지. 정본 작업 폴더의 현재 가지/상태를 바꾸지 않는다(`git switch` 하지 않음). 푸시는 refspec으로 한다.
4. 확인 질문 없이 진행(큐 10절).

## 1. 사전 확인 (결과 원문을 보고서 표로)
1. `git fetch origin`(필요하면 `--tags`). 작업 폴더 `git status` 깨끗(아니면 멈춤).
2. `git rev-parse origin/feature/wm3d-intake-20261101` = `ab9b739d767bcd10afbca4dc885ac79471bdc51c`, `git rev-parse 'origin/feature/wm3d-intake-20261101^{tree}'` = `e20215ab2939535c243f658c5e74b2c31aa64c5a`.
3. `git rev-parse origin/main` = `66b29ba13b735a0784da23fccad5632e8f65beb1`.
4. `git merge-base --is-ancestor origin/main ab9b739d767bcd10afbca4dc885ac79471bdc51c`가 성공(0). 복제가 shallow면 `git fetch --unshallow`로 먼저 푼다(`git rev-parse --is-shallow-repository` = false 확인).
5. `git diff --name-only cbe28c0 ab9b739d767bcd10afbca4dc885ac79471bdc51c`가 정확히 `agent/PROGRESS_WM3D.md`, `agent/REPORT_AUDIT_CITYHUD_20261105.md`, `agent/REPORT_AUDIT_M7_20261105.md`, `agent/REPORT_WM3D_08_20261105.md` 네 줄.
6. `gh`(읽기 명령만)로 `cbe28c0`의 `Verify C-track refactor`와 `Verify WorldMap3D`가 success인지 run id와 함께 기록. 열린 PR 목록(`gh pr list --state open`)을 기록만 한다(변경 금지).
7. `git rev-list --count origin/main..ab9b739d…` = 887, `git rev-list --count ab9b739d…..origin/main`이 0. 다르면 멈춤.

## 2. 실행 (순서 고정)
1. 기준점 태그: `git tag baseline-pre-wm3d-main-20261105 66b29ba13b735a0784da23fccad5632e8f65beb1`(가벼운 태그, 기존 `baseline-pre-3d-units-20261029` 형식과 같게) → `git push origin refs/tags/baseline-pre-wm3d-main-20261105`. 같은 이름 태그가 이미 있으면 멈춤.
2. `main` 푸시: `git push origin ab9b739d767bcd10afbca4dc885ac79471bdc51c:refs/heads/main` (`--force` 없음, `+` 없음). 거부되면 **멈추고** 거부 메시지 원문을 보고(force·재설정 금지).
3. 푸시 직후 `git fetch origin`, `git rev-parse origin/main`이 `ab9b739d…`이고 tree가 `e20215ab…`인지, `git ls-remote origin refs/tags/baseline-pre-wm3d-main-20261105` 결과가 `66b29ba1…`인지 확인.
4. 로컬 `main` 가지가 있고 현재 가지가 `main`이 아니면 `git branch -f main origin/main`(fast-forward일 때만; 로컬에만 있는 커밋이 있으면 건드리지 말고 보고).
5. `main` 푸시가 일으킨 워크플로가 있으면(`gh run list --branch main`, 읽기) 이름·결과를 기록. 없으면 "워크플로 트리거 없음(`verify-c-track.yml`의 `branches`에 `main` 없음)"으로 기록. 새로 실패가 나와도 되돌리지 말고 보고(CI가 `main`에서 도는 것은 이번 범위가 아니다).

## 3. 하지 않는 것
force push, `main`에 새 커밋 만들기(merge 커밋 포함), intake·integration·기타 가지 수정/삭제, 태그 이동/삭제, PR 생성·병합·닫기, `.github` 수정, 재실행으로 때우기.

## 4. 보고서
`agent/REPORT_MERGE_MAIN_20261105.md`: 맨 위 "기준 화면 / 합격 기준" 두 줄 + 3줄 요약(됐나 / 원격 main 해시 / 막힌 것) + 1절 확인 표 + 2절 명령과 결과 원문 + 열린 PR 목록 + 종료 루틴 5줄. 보고서 커밋은 **그 시점의 작업 가지**(큐상 CH-2 직후라면 `feature/wm3d-cityhud-20261105`)에 `[skip ci]`로 올린다(`main`에 올리지 않는다).
