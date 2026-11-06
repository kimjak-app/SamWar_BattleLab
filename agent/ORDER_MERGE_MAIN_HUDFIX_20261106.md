기준 화면: GitHub 원격에서 `origin/main`이 `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`이고, `feature/wm3d-hudfix-20261106` 끝이 `a9e3b84229f63286bbdc784d78826b0e2cdb792d`(코드 끝 `de53500`)인 상태. 백업 태그 `baseline-pre-hudfix-20261106`은 아직 없음.
합격 기준: ① 원격 `main` = `a9e3b842…`, tree `1a79d075d0965c483adf4c5de12ddd6063b8469f` ② `main` 푸시는 fast-forward 하나(merge 커밋·force·가지 삭제·재작성 0) ③ 원격 태그 `baseline-pre-hudfix-20261106`이 `042b0708…`을 가리킴 ④ 보고서. **판정: 합격(김작 F6 확인 완료).** 김작은 보고서 맨 위 세 줄과 GitHub의 `main` 해시만 본다.

# 지시서 — MERGE-MAIN-HUDFIX: 도시창 "그림만" + 턴 버튼 틈 수정을 `main`에 합류 (fast-forward)

- 작성: 클코치, 2026-11-06 21:25. **상태: 보류** — 큐 28번. 김작이 "병합해"라고 승인한 뒤 클코치가 "준비됨"으로 바꾼다. 그 전에는 시작하지 않는다.
- **김작 F6 확인 [사실]**: 11-06 21:15 도시창·턴 버튼 스크린샷과 함께 "도시창과 턴버튼 좋아! 굿이야!". (`main` 합류 승인은 별도: 위 "병합해" 확인 뒤에 이 줄을 승인 인용으로 바꾼다.)
- 클코치 독립 검증 [사실, 11-06 21:20]: `main`(`042b070`)은 hudfix 끝의 조상이며 `main..hudfix` = 3커밋(`a24c951` STOP 보고서, `de53500` 코드, `a9e3b84` 보고서·증거), `hudfix..main` = 0(fast-forward 가능). 코드 끝 `de53500`의 `Verify C-track refactor` run `42208336062` = success. 변경 파일: 코드 2(`worldmap_city_interior_controller.gd`, `worldmap_turn_compass.gd`) + 테스트 4(수정 3, 신규 1 + `.uid`) + `.github/workflows/verify-c-track.yml`(새 테스트 목록 끝에 1줄) + `agent/` 문서·증거. `Verify WorldMap3D`는 이번 변경 경로가 그 워크플로 조건 밖이라 트리거되지 않았다(클코드 보고서 확인됨).
- 이번 병합에 넣지 않는 것: PERF3(bake), CH-4.

## 0. 규칙
1. `main`은 **이 지시서의 승인으로만** 건드린다. force·가지 삭제·다른 가지 수정 금지. **hudfix 가지에 새 커밋 금지**(끝 해시가 병합 대상).
2. 1절 확인 중 **하나라도 다르면 푸시하지 말고** `agent/REPORT_MERGE_MAIN_HUDFIX_STOP_20261106.md`로 멈춘다(어떤 값이 어떻게 달랐는지 원문). 다른 해시로 바꿔 진행·재시도·땜빵 금지. 멈춤은 이 항목만 막는다.
3. 새 폴더·worktree 금지. 정본 작업 폴더의 현재 가지/상태를 바꾸지 않는다(`git switch` 하지 않음). 푸시는 refspec으로 한다.
4. 확인 질문 없이 진행(큐 10절).

## 1. 사전 확인 (결과 원문을 보고서 표로)
1. `git fetch origin --tags`. 작업 폴더 `git status` 깨끗(아니면 멈춤). `git rev-parse --is-shallow-repository` = false.
2. `git rev-parse origin/feature/wm3d-hudfix-20261106` = `a9e3b84229f63286bbdc784d78826b0e2cdb792d`, `git rev-parse 'origin/feature/wm3d-hudfix-20261106^{tree}'` = `1a79d075d0965c483adf4c5de12ddd6063b8469f`.
3. `git rev-parse origin/main` = `042b0708f9af4fe3f30d51caa1c988d9b064f8b0`.
4. `git merge-base --is-ancestor origin/main a9e3b84229f63286bbdc784d78826b0e2cdb792d` 성공(0).
5. `git rev-list --count origin/main..a9e3b842…` = 3, `git rev-list --count a9e3b842…..origin/main` = 0.
6. `git diff --name-only de53500 a9e3b842…`가 `agent/` 아래 문서·증거 파일뿐(코드·테스트·워크플로 0).
7. `gh`(읽기만)로 `de53500`의 `Verify C-track refactor` 4 shard success와 run id 기록(기대: 42208336062). 열린 PR 목록 기록만.
8. `git ls-remote origin refs/tags/baseline-pre-hudfix-20261106`이 비어 있음(있으면 멈춤).

## 2. 실행 (순서 고정)
1. 백업 태그: `git tag baseline-pre-hudfix-20261106 042b0708f9af4fe3f30d51caa1c988d9b064f8b0`(가벼운 태그) → `git push origin refs/tags/baseline-pre-hudfix-20261106`.
2. `main` 푸시: `git push origin a9e3b84229f63286bbdc784d78826b0e2cdb792d:refs/heads/main` (`--force`·`+` 없음). 거부되면 **멈추고** 메시지 원문 보고.
3. 푸시 직후 `git fetch origin`: `origin/main` = `a9e3b842…`, tree = `1a79d075…`, 태그 = `042b0708…` 확인.
4. 로컬 `main` 가지가 있고 현재 가지가 `main`이 아니면 `git branch -f main origin/main`(fast-forward일 때만; 로컬 전용 커밋이 있으면 보고만).
5. `main` 푸시가 일으킨 워크플로가 있으면 이름·결과 기록(읽기). 없으면 "워크플로 트리거 없음". 새 실패가 나와도 되돌리지 말고 보고.

## 3. 하지 않는 것
force push, `main`에 새 커밋(merge 커밋 포함), hudfix·integrate·bake·cityhud4 등 다른 가지 수정/삭제, 태그 이동/삭제, PR 생성·병합·닫기, `.github` 수정, CI 재실행·허용 오차 조정.

## 4. 보고서
`agent/REPORT_MERGE_MAIN_HUDFIX_20261106.md`: 맨 위 "기준 화면 / 합격 기준" 두 줄 + 3줄 요약 + 판정 "**합격(F6 확인 완료)**" + 1절 확인 표 + 2절 명령·결과 원문 + 열린 PR 목록 + 되돌리는 법 한 줄(`baseline-pre-hudfix-20261106` = `042b0708…`) + 종료 루틴 5줄.
보고서는 **새 가지 `feature/wm3d-mergereport2-20261106`**(시작 `a9e3b842…`)에 `[skip ci]`로 올린다. `main`·hudfix 가지에는 올리지 않는다.
