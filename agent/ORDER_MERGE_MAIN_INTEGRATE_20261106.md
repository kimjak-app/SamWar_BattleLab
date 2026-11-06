기준 화면: GitHub 원격에서 `origin/main`이 `ab9b739d767bcd10afbca4dc885ac79471bdc51c`이고, `feature/wm3d-integrate-20261106` 끝이 `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`(코드 끝 `dac3a8b4587098dddcbfca613ba52016361b7f85`)인 상태. 백업 태그 `baseline-pre-integrate-20261106`은 아직 없음.
합격 기준: ① 원격 `main` = `042b0708…`, tree `84dfe9474027fa87780541d6d5179bec927b9f82` ② `main` 푸시는 fast-forward 하나(merge 커밋·force·가지 삭제·재작성 0) ③ 원격 태그 `baseline-pre-integrate-20261106`이 `ab9b739d…`를 가리킴 ④ 보고서. **판정은 "조건부 합격(F6 미확인)"** — 김작이 눈으로 보는 F6는 병합 뒤에 한다. 김작은 보고서 맨 위 세 줄과 GitHub의 `main` 해시만 본다.

# 지시서 — MERGE-MAIN-INTEGRATE: cityhud + m7prep + turnbtn 통합 가지를 `main`에 합류 (fast-forward)

- 작성: 클코치, 2026-11-06 15:40.
- **김작 승인 [사실]**: 11-06 "이상 없으면 합격일 것 같아 일단 합격하고 병합하는게 어때? 그 후에 일어나서 눈으로 볼게" → 클코치가 대상·해시·조건(조건부 합격, 백업 태그, PERF3 제외)을 말한 뒤 "써줘^^ / 진행해". 승인 범위는 **이 지시서의 `main` 푸시 1회 + 태그 푸시 1회**뿐. 다른 가지·다른 푸시에 쓸 수 없다.
- 클코치 독립 검증 [사실, 11-06 15:35]: `main`(`ab9b739`)은 integrate 끝의 조상이며 `main..integrate` = 34커밋, `integrate..main` = 0 (fast-forward 가능). `dac3a8b..042b070` 차이는 `agent/REPORT_INTEGRATE_F6_20261106.md` 한 파일뿐. 코드는 세 가지(cityhud `ad80253`, m7prep `0bfff7c`, turnbtn `ff033bb`)의 합과 스모크 테스트.
- **[미확인]**: 눈으로 보는 F6(도시창 도킹, 좌측 패널 그립 드래그, 5성 배치, 턴 버튼 동작), 입력 라이프사이클 Godot 테스트(CI 목록 밖). 이 두 가지는 이번 병합의 합격 근거가 아니다.
- **이번 병합에 넣지 않는 것**: PERF3(`feature/wm3d-bake-20261106`), perf·evidence 가지.

## 0. 규칙
1. `main`은 **이 지시서의 승인으로만** 건드린다. force 금지, 가지 삭제 금지, 다른 가지·열린 PR 가지 수정 금지. **integrate 가지에 새 커밋 금지**(끝 해시가 병합 대상이다).
2. 1절 사전 확인 중 **하나라도 다르면 푸시하지 말고** `agent/REPORT_MERGE_MAIN_INTEGRATE_STOP_20261106.md`로 멈춘다(어떤 값이 어떻게 달랐는지 원문). 다른 해시로 바꿔서 진행·재시도·땜빵 금지. **단, 멈춤은 이 항목만 막는다**(큐 규칙: 다른 가지의 독립 항목은 계속).
3. 새 폴더·worktree 금지. 정본 작업 폴더의 현재 가지/상태를 바꾸지 않는다(`git switch` 하지 않음). 푸시는 refspec으로 한다.
4. 확인 질문 없이 진행(큐 10절).

## 1. 사전 확인 (결과 원문을 보고서 표로)
1. `git fetch origin --tags`. 작업 폴더 `git status` 깨끗(아니면 멈춤). `git rev-parse --is-shallow-repository` = false(아니면 `git fetch --unshallow`).
2. `git rev-parse origin/feature/wm3d-integrate-20261106` = `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`, `git rev-parse 'origin/feature/wm3d-integrate-20261106^{tree}'` = `84dfe9474027fa87780541d6d5179bec927b9f82`.
3. `git rev-parse origin/main` = `ab9b739d767bcd10afbca4dc885ac79471bdc51c`.
4. `git merge-base --is-ancestor origin/main 042b0708f9af4fe3f30d51caa1c988d9b064f8b0` 성공(0).
5. `git rev-list --count origin/main..042b0708…` = 34, `git rev-list --count 042b0708…..origin/main` = 0.
6. `git diff --name-only dac3a8b4587098dddcbfca613ba52016361b7f85 042b0708f9af4fe3f30d51caa1c988d9b064f8b0`가 정확히 `agent/REPORT_INTEGRATE_F6_20261106.md` 한 줄.
7. `gh`(읽기 명령만)로 코드 끝 `dac3a8b…`의 `Verify C-track refactor` 4 shard와 `Verify WorldMap3D`가 모두 success인지 run id와 함께 기록(기대: 42172124442, 42172124412). 열린 PR 목록(`gh pr list --state open`)은 기록만 한다.
8. `git ls-remote origin refs/tags/baseline-pre-integrate-20261106`이 비어 있음(있으면 멈춤).

## 2. 실행 (순서 고정)
1. 백업 태그: `git tag baseline-pre-integrate-20261106 ab9b739d767bcd10afbca4dc885ac79471bdc51c`(가벼운 태그, 기존 baseline 태그와 같은 형식) → `git push origin refs/tags/baseline-pre-integrate-20261106`.
2. `main` 푸시: `git push origin 042b0708f9af4fe3f30d51caa1c988d9b064f8b0:refs/heads/main` (`--force`·`+` 없음). 거부되면 **멈추고** 거부 메시지 원문을 보고(force·재설정 금지).
3. 푸시 직후 `git fetch origin`, `origin/main` = `042b0708…`, tree = `84dfe947…`, `git ls-remote origin refs/tags/baseline-pre-integrate-20261106` = `ab9b739d…` 확인.
4. 로컬 `main` 가지가 있고 현재 가지가 `main`이 아니면 `git branch -f main origin/main`(fast-forward일 때만; 로컬 전용 커밋이 있으면 건드리지 말고 보고).
5. `main` 푸시가 일으킨 워크플로가 있으면(`gh run list --branch main`, 읽기) 이름·결과 기록. 없으면 "워크플로 트리거 없음"으로 기록. 새 실패가 나와도 되돌리지 말고 보고.

## 3. 하지 않는 것
force push, `main`에 새 커밋 만들기(merge 커밋 포함), integrate·cityhud·m7prep·turnbtn·bake·perf·evidence 가지 수정/삭제, 태그 이동/삭제, PR 생성·병합·닫기, `.github` 수정, CI 재실행·허용 오차 조정으로 때우기.

## 4. 보고서
`agent/REPORT_MERGE_MAIN_INTEGRATE_20261106.md`: 맨 위 "기준 화면 / 합격 기준" 두 줄 + 3줄 요약(됐나 / 원격 main 해시 / 막힌 것) + 판정 문구 "**조건부 합격(F6 미확인)**" + 1절 확인 표 + 2절 명령과 결과 원문 + 열린 PR 목록 + 되돌리는 법 한 줄(`baseline-pre-integrate-20261106` = `ab9b739d…`) + 종료 루틴 5줄.
보고서는 **새 가지 `feature/wm3d-mergereport-20261106`**(시작 `042b0708…`)에 `[skip ci]`로 올린다. `main`·integrate 가지에는 올리지 않는다.
