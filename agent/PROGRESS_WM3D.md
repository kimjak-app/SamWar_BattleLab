기준 화면: 없음(진행 기록). 각 단계의 기준 화면은 단계 지시서·보고서 맨 위에 있다.
합격 기준: 김작이 하루 끝에 F6 한 번으로 T-WM3D-06·07·08을 확인한다. 그 전까지 클코드는 자동 검증(로컬 테스트 + CI 초록 + 보고서)으로 다음 단계로 넘어간다.

# PROGRESS — T-WM3D-06 → 07 → 08 작전

- 큐: `git fetch origin feature/wm3d-orders-20261105` → `git show origin/feature/wm3d-orders-20261105:agent/ORDER_QUEUE.md` (그 가지에는 push 금지)
- 세션이 새로 시작되면: 이 파일 → 큐 → 아래 "다음 할 일" 순서로 읽는다.

## 현재 상태 (최신이 위)

### 2026-11-11 — 큐 35번 답신 3 멈춤 (구현 완료, CI shard 0 빨강: 육전 컷인 길이 검사)
- 현재 단계: 35번 답신 3, 가지 `feature/wm3d-naval-20261110`
- 마지막 코드 커밋: `c72747210c27b8909595351bfbb1ffd967ef84f7`
- 마지막 보고서: `agent/REPORT_NAVAL_HANSANDO_REPLY3_STOP_20261111.md`, 본문은 `agent/REPORT_NAVAL_HANSANDO_20261110.md` "답신 3" 절
- CI: Verify C-track refactor `43028220617`(`c727472`): shard 1·2·3 success, **shard 0 failure**. 실패한 것은 육전 시험 `test_battle3d_cutin_result_toast.gd`의 `[CUTIN]` 길이 검사 하나다(컷인 5개가 3.943~3.972초, 기준 3.95초 이상). 큐 4절 1의 알려진 컷인 관찰이고 수전 시험 2개는 shard 1·2에서 통과했다(`checks=64`, `checks=249`). CI가 빨개서 문 조건 3을 못 채우므로 멈췄다. 재실행은 하지 않았다(큐 6절). 멈춤 보고 `agent/REPORT_NAVAL_HANSANDO_REPLY3_STOP_20261111.md`. Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.
- 수전 전용 파일 3개 + 새 에셋만 변경. 엔진·육전·셸·랩·강 셰이더 0줄
- 다음 할 일: 클코치 답신 대기(A: shard 0 재실행 승인 / B: 컷인 검사 지시서 따로 / C: 빨간 채로 F6 진행). 그 뒤 김작 F6(배 4종, 물선, 돛·노, 돛 색). 클코치 확인: 보고서 답3-3(5가지), 답3-6(안택선 지붕)
- 멈춘 이유: 큐 4절 1. CI shard 0이 `[CUTIN]` 길이 검사(3.943초, 기준 3.95초)로 빨개 문 조건 3 미충족. 재실행 금지(큐 6절)라 다시 돌리지 않았다
- 정정: 답신 2의 shard 0 첫 실패(`42839927991` 1차)도 같은 `[CUTIN]` 검사였다(3.934초). 당시 "로그가 끊겨 원인 불명"이라고 쓴 것은 `gh run view --log-failed` 출력이 중간에서 잘린 탓이다

### 2026-11-11 — 큐 35번 답신 2 완료 (바다 전용 셰이더 + 포탄 물보라)
- 현재 단계: 35번 답신 2 완료, 가지 `feature/wm3d-naval-20261110`
- 마지막 코드 커밋: `4dfcfca`
- 마지막 보고서: `agent/REPORT_NAVAL_HANSANDO_20261110.md` "답신 2" 절
- CI: Verify C-track refactor `42839927991`(`4dfcfca`) 4 shard 전부 success. 첫 시도에서 shard 0이 실패했는데, 로그가 육전 시험 `test_battle_attack_oracle_shard_2` 도중에 끊겨 원인을 알 수 없었다. 같은 커밋으로 그 shard만 다시 돌려 통과했다(코드 변경 없음, 일시적 실패로 본다). Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.
- 수전 전용 파일만 변경. 강 셰이더·육전·엔진 0줄
- 다음 할 일: 김작 F6(바다 느낌, 물보라, F8 세 설정 중 선택). 배 모델은 11-11 록코치 납품 뒤
- 멈춘 이유: 없음(정상 완료)

### 2026-11-10 — 큐 35번 NAVAL-HANSANDO 완료 (답신 1 A안)
- 현재 단계: 35번 완료, 가지 `feature/wm3d-naval-20261110`
- 마지막 코드 커밋: `57bae9f`(시험 대기 방식 수정), 그 앞 `1165036`(수전 본체)
- 마지막 보고서: `agent/REPORT_NAVAL_HANSANDO_20261110.md`
- CI: Verify C-track refactor `42832011165`(`57bae9f`) 4 shard 전부 success. 첫 실행 `42828138719`(`1165036`)은 shard 2 실패 — 새 수전 시험이 결과 화면을 프레임 수로 기다린 한 줄 때문이었고, 시간으로 기다리게 고친 시험 커밋 `57bae9f`로 해결했다(제품 코드 변경 없음). Verify WorldMap3D는 경로 조건에 안 걸려 실행되지 않았다.
- `worldmap_main.gd`·`data/heroes/generated/*.json` 변경 0줄. 엔진은 시작 설정 세 자리 + preload 1줄 + `battle_type` 줄 2곳
- 다음 할 일: 김작 F6(보고서 7절), 병력 숫자·배 모형·지형 칸 글자 결정(보고서 5절). `main` 합류 없음
- 멈춘 이유: 없음(정상 완료)

### 2026-11-10 — 큐 35번 NAVAL-HANSANDO 멈춤 (코드 0, §4 조사만)
- 현재 단계: 35번 `agent/ORDER_NAVAL_HANSANDO_LAB_20261110.md`(19:40판), 가지 `feature/wm3d-naval-20261110`(시작 `main` `8cc0640`)
- 마지막 코드 커밋: 없음(코드는 `8cc0640`과 같음)
- 마지막 보고서: `agent/REPORT_NAVAL_HANSANDO_STOP_20261110.md`
- CI: 실행 0(`[skip ci]` 보고서만)
- 다음 할 일: 클코치 답신 대기(A: 엔진 시작 설정에 수전 키 추가 / B: 랩이 엔진 상태에 직접 쓰기 / C: 범위 축소)
- 멈춘 이유: 지시서 §4 멈춤 조건. 엔진에 시나리오별 병종·장수·시작 칸 입구가 없고(시작 설정은 `troops_ratio`·`enemy_ai_level`만), 학익진 반경 3은 월드맵 문맥 `battle_type`으로만 켜진다 → §3-1 허용 자리 밖 수정 필요

### 2026-11-08 — 큐 31번 WARNFIX 완료 (답신 1 A안) + 30번 경고 2개 정리
- 31번: 가지 `feature/wm3d-warnfix-20261108`, 코드 `645ffcf5b9a7ed8aa0954428abce9c3ed5d551c1`, 보고서 `agent/REPORT_WARNFIX_20261108.md`. 경고 12 → 0
- 31번 CI(`645ffcf`): Verify C-track refactor `42488036136` 4 shard success, Verify WorldMap3D `42488036103` success
- 30번: `feature/wm3d-debugcheats-20261108` 코드 `c2c6740`(이름 2개), 보고서 덧붙임 `3e391b1`. C-track `42484972498` success. 경고 14 → 12(나머지 12는 31번 몫)
- 금지 파일(`worldmap_main.gd`·`battle_settlement_applier.gd`·`p1_exact_delta.py`·`project.godot`) 변경 0
- 다음 할 일: 김작 F6(30번 8절, 31번 6절), 30·31번 `main` 합류 결정. 정본 폴더는 30번 가지로 체크아웃
- 멈춘 이유: 없음(정상 완료)

### 2026-11-08 — 큐 31번 WARNFIX 멈춤 (코드 0)
- 현재 단계: 31번 `agent/ORDER_WARNFIX_20261108.md`, 가지 `feature/wm3d-warnfix-20261108`(시작 `main` `a9e3b84`)
- 마지막 코드 커밋: 없음(코드는 `a9e3b84`와 같음)
- 마지막 보고서: `agent/REPORT_WARNFIX_STOP_20261108.md`
- CI: 실행 0(`[skip ci]` 보고서만)
- 다음 할 일: 클코치 답신 대기(A: 31번은 main 12개 + 30번 가지에서 컨트롤러 2개 / B / C)
- 멈춘 이유: `main`에서 경고 12개(지시서는 14개). 나머지 2개는 30번 `worldmap_debug_cheats_controller.gd`(31번 수정 금지 파일). 지시서 1절

### 2026-11-08 — 큐 30번 DEBUG-CHEATS 완료 (답신 1 A안)
- 현재 단계: 30번 완료, 가지 `feature/wm3d-debugcheats-20261108`
- 마지막 코드 커밋: `0e849ee49398b0f26ecc480496b74758a095f017`(테스트 `.uid`), 그 앞 `5a51ebf`(치트 본체)
- 마지막 보고서: `agent/REPORT_DEBUG_CHEATS_20261108.md`
- CI(`0e849ee`): Verify C-track refactor `42475007954` 4 shard success. Verify WorldMap3D는 미트리거(경로 조건) → 로컬 재현. `5a51ebf`는 `.uid` 미커밋으로 Diff check 실패
- `worldmap_main.gd`·`tools/p1_exact_delta.py` 변경 0줄
- 다음 할 일: 김작 F6(보고서 8절 1~5), `main` 합류 결정. 큐에 다른 '준비됨' 항목이 오면 이어서
- 멈춘 이유: 없음(정상 완료)

### 2026-11-08 — 큐 30번 DEBUG-CHEATS 멈춤 (코드 0)
- 현재 단계: 30번 `agent/ORDER_DEBUG_CHEATS_20261108.md`, 가지 `feature/wm3d-debugcheats-20261108`(시작 `main` `a9e3b84`)
- 마지막 코드 커밋: 없음(코드는 `a9e3b84`과 같음)
- 마지막 보고서: `agent/REPORT_DEBUG_CHEATS_STOP_20261108.md`
- CI: 실행 0(`[skip ci]` 보고서만)
- 다음 할 일: 클코치 답신(A: `WorldMap.tscn` 루트 자식, main 0줄 / B: main 몇 줄 + `p1_exact_delta.py` 재고정 / C) 대기
- 멈춘 이유: `worldmap_main.gd`가 `9b2cd8e`와 바이트 단위로 고정(`validate_worldmap_diplomacy_routing.py` → `p1_exact_delta.py`), 연결 몇 줄도 실패. 큐 4절 3·4번

### 2026-11-05 — 큐 5번 CITY-HUD 감사 완료, 큐 끝
- CITY-HUD 감사 완료: `agent/REPORT_AUDIT_CITYHUD_20261105.md` (읽기 전용, 코드·에셋 변경 0)
- 다음 할 일: 없음(큐 1~5 모두 완료). 김작 F6(06·07·08), M7·CITY-HUD 결정, 구현 지시서 대기
- 멈춘 이유: 큐 완료(정상 종료)

### 2026-11-05 — 큐 4번 M7 감사 완료, 5번 CITY-HUD 감사 시작
- M7 감사 완료: `agent/REPORT_AUDIT_M7_20261105.md` (읽기 전용, 코드 변경 0, 코드 HEAD `cbe28c0` 그대로)
- 다음 할 일: 큐 5번 `agent/ORDER_AUDIT_CITYHUD_20261105.md`(읽기 전용 감사)
- 멈춘 이유: 없음

### 2026-11-05 13:08 +0900 — 08 완료, 큐 끝 (06·07·08 모두 완료)
- 현재 단계: 08 완료. 큐의 마지막 단계라 다음 지시서 없음 → 김작 F6·`main` 합류 승인 대기
- 마지막 코드 커밋: `cbe28c018c2a1dd9b5f9fc2237bccc74fa43149e` (T-WM3D-08)
- 마지막 보고서: `agent/REPORT_WM3D_08_20261105.md`
- CI(`cbe28c0`): Verify WorldMap3D `41963496218` success, Verify C-track refactor `41963496308` 4 shard success. 첫 컷인 33.2 fps(60 미만).
- 다음 할 일: 없음(김작 F6 06·07·08 한꺼번에, 합격 시 `main` 합류 승인). 새 지시서나 답신이 오면 이 파일 → 큐 순서로 읽고 시작.
- 멈춘 이유: 큐 완료(정상 종료)
- 미완: 08 2-E 3D/2D 카메라 컨트롤러 분리 보류(main 707·1173행 타입 + 핀 재고정 필요, 08 보고서 5절)
- `worldmap_main.gd` 변경: 06·07·08 모두 0줄(재고정 없음)
- 김작 F6 대기 항목: 06 (보고서 7절), 07 (보고서 7절), 08 (보고서 8절)

### 2026-11-05 12:19 +0900 — 07 완료, 08 시작
- 현재 단계: 07 완료 → 08 시작(`agent/ORDER_WM3D_08_PRODUCTION_20261105.md`, orders 가지 `a9b3148`)
- 마지막 코드 커밋: `4e5ed786b835e82e0d9eb800756df98a7c98f350` (T-WM3D-07)
- 마지막 보고서: `agent/REPORT_WM3D_07_20261105.md`
- CI(`4e5ed78`): Verify WorldMap3D `41958276300` success, Verify C-track refactor `41958276324` 4 shard success. 첫 컷인 29.9 fps(60 미만).
- 다음 할 일: 08 1절 읽기 전용 조사부터(main 수정이 정말 필요한지 먼저 판단).
- 멈춘 이유: 없음
- 김작 F6 대기 항목: 06 (보고서 7절), 07 (보고서 7절)
- 참고: 07·08 지시서는 11:17·11:20에 올라와 06 뒤 대기는 1회(11:08~11:2x)로 끝남.

### 2026-11-05 11:08 +0900 — 06 완료, 07 지시서 대기 시작
- 현재 단계: 06 완료 → 07 대기
- 마지막 코드 커밋: `cb48f4c9debd12917cecfc9c24a0a4cf160f6898` (T-WM3D-06)
- 마지막 보고서: `agent/REPORT_WM3D_06_20261105.md`
- CI(`cb48f4c`): Verify WorldMap3D `41950345658` success, Verify C-track refactor `41950345727` 4 shard success. 첫 컷인 32.6 fps(60 미만).
- 다음 할 일: `agent/ORDER_WM3D_07_BATTLE_ENTRY_20261105.md`가 orders 가지에 올라오면 시작. 11:08 기준 없음 → 5분마다 fetch, 최대 90분(12:38까지). 그래도 없으면 "대기 중: ORDER_WM3D_07_BATTLE_ENTRY_20261105.md 없음"을 적고 멈춤.
- 멈춘 이유: 없음
- 김작 F6 대기 항목: 06 (보고서 7절)
