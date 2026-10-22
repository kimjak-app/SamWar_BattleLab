# BATTLE3D M5-a2 결과 — 자동 플레이가 3D 연출을 기다리기 (2026-10-23 밤샘 ③ 단계 ②)

- 작업 ID: M5-a2. 지시문 `NIGHT3_STACK_20261023.md` §4, 설계서 `DESIGN_S4_AI_LEVEL_AND_BATTLE_SETUP_20261022.md` §3-2, 공통 3D 규칙·보고서 형식 `NIGHT2_M5A_M4C2_M5B_20261022.md` §0
- 브랜치 `feature/night3-stack-20261023`(스택). BASE = 직전 단계 커밋 `79471b2`(S4-3).
- 이 단계 커밋 1개: `feat(battle3d): hold the engine auto play while the 3D presentation runs (M5-a2)`. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- 합격 판정은 하지 않는다(검수: 클코치).
- **멈춤 규칙에 걸리지 않았다**. 엔진·서비스·어댑터 diff 0, 쓰기는 승인된 14번째 하나, 읽기 추가 0, 기존 테스트·하니스·골든 수정 0, 새 난수 0.
- **최종 상태 동등성(b)이 성립했다**. hold를 쓰는 3D 자동(4x, 시드 1~3) 결과가 엔진 직접 자동과 같다. 비교 항목은 유닛·컨트롤러·로그 4개·라운드 2/3 시작 스냅샷(다음 난수 포함)·쓰기 순서다. 엔진 쪽 프레임 의존은 발견되지 않았다.

## 0. 사전 확인

1. **엔진 게이트 위치와 해제 시 재호출**(S4-3, 실행 확인)
   - 게이트는 `_tick_full_auto_battle_if_needed` 맨 앞의 `if auto_presentation_hold: return` 한 곳이다.
   - `set_auto_presentation_hold(false)`는 이전 값이 true이고 자동 on·`ally_turn`·`is_demo_animating` 아님일 때만 `call_deferred("_tick_full_auto_battle_if_needed")`를 부른다.
   - 막힌 틱을 다시 부를 곳이 엔진에 없어서 이 재호출이 필요하다(S4-3 보고서 §0-2).
   - 3D 쪽에서는 hold가 false로 바뀌는 프레임 끝(지연 호출)에 다음 자동 행동이 시작된다. 아래 3의 trace에서 같은 프레임 번호로 보인다.
2. **3D 연출 상태 목록**(현재 3D 코드)

   | 상태 | 3D 변수/판정 | hold에 포함 |
   |---|---|---|
   | 아군 이동 경로 재생(M1-b) | `playback`(unit_id → 경로) | 예 |
   | 적 이동 경로 재생(M3) | `playback` + `enemy_moving_id` | 예(`playback`) |
   | 적 재생 큐(이동·공격·특기·책략·상태 틱·종료) | `enemy_queue` | 예(`_enemy_presentation_busy()`) |
   | 적 재생 사이 대기 | `enemy_hold`(초) | 예(`_enemy_presentation_busy()`) |
   | 엔진 로그를 3D가 아직 소비 안 함 | `event_cursor`·`action_cursor`·`enemy_cursor`·`tactic_cursor` < 각 로그 크기 | 예 |
   | 엔진이 아직 행동 중 | `is_demo_animating`, `current_phase == "enemy_turn"`(이미 승인된 읽기) | 예(§5 결정) |
   | 아군 공격 피해 라벨 | `_show_attack_damage` 트윈 1.8초 | **아니오(라벨)** |
   | 적 피격 라벨 | `_show_enemy_hit` 트윈 | 아니오(라벨) |
   | 책략·상태 라벨 | `_tactic_label` 트윈 | 아니오(라벨) |
   | 증원 도착 라벨 | `_present_arrival` 트윈 | 아니오(라벨) |
   | 특기 라벨(아군·적) | `_skill_label` 트윈 1.6초 | 아니오(라벨) |

   - 아군 공격·특기·책략은 3D에서 라벨과 줄 표시뿐이고 시간이 걸리는 연출이 없다. "공격 연출"과 "특기·책략 연출"은 해당 이벤트의 커서 소비로 판정된다.
3. **자동 한 사이클의 프레임 순서**(실행, `test_battle3d_auto_hold_release.gd` trace, 시드 1). 앞 숫자는 첫 행동 시작 기준 프레임 차이다.
   - 1x: `+0 자동 행동 시작(3D idle) · +0 hold true · +181 hold false · +181 자동 행동 시작(3D idle) · +182 hold true · +484 hold false · +484 시작 · +485 hold true · +659 hold false · +659 시작`
   - 4x: `+0 시작 · +0 hold true · +30 hold false · +30 시작 · +31 hold true · +91 hold false · +91 시작 · +92 hold true · +116 hold false · +116 시작`
   - 읽는 법:
     - 엔진이 행동을 시작한다(그 순간 3D는 idle).
     - 같은 프레임의 3D `_process`가 엔진 행동 중(`is_demo_animating`)을 보고 hold true를 보낸다.
     - 엔진 행동·적 슬롯·3D 재생·로그 소비가 모두 끝난 프레임에 hold false를 보낸다.
     - 엔진의 지연 틱이 같은 프레임 끝에 다음 행동을 시작한다.
     - 다음 프레임에 다시 hold true가 된다.
   - 사이클마다 hold 호출은 2번이다(시드 1 4x 전체: 행동 37회, 호출 74회).

## 1. 변경 (`scripts/battle3d/battle3d_engine_play.gd`만, +22)

- 멤버 1개: `auto_hold_sent := false`(마지막으로 보낸 값)
- 새 함수 2개:
  - `_presentation_busy()`: 위 표의 "예" 항목뿐이다. 기존 판정 재사용(`_enemy_presentation_busy()`)과 이미 승인된 엔진 읽기만 쓴다.
  - `_update_auto_hold(closing := false)`:
    - `hold = not closing and 자동 on and battle_result 비어 있음 and _presentation_busy()`
    - `hold == auto_hold_sent`이면 돌아간다(에지에서만 전송).
    - 바뀌면 기록하고 `engine.call("set_auto_presentation_hold", hold)`를 부른다. **쓰기 14번째, 호출 지점 1곳.**
- 공용 함수 변경(각 한 줄):
  - `_process` 마지막: `_update_auto_hold()`. 이벤트 소비·재생·뷰 동기 뒤다.
  - `request_auto`: 토글 직후 `_update_auto_hold()`. 3D에서 중지하면 그 자리에서 false를 보낸다.
  - `_exit_tree`: `Engine.time_scale = 1.0` 다음에 `_update_auto_hold(true)`. 랩 해제 시 무조건 false다.
- **false가 되는 모든 경로**:
  - 자동 중지(3D: `request_auto`, 엔진 스스로: 다음 `_process`에서 자동 off 감지)
  - 전투 결과(`battle_result` 확정)
  - 연출 종료
  - `_exit_tree`
- 켜진 채로 남는 경로가 없다(validator가 식을 고정하고, 테스트가 확인).

## 2. 테스트 (CI 편입 7개 파일 + 하니스 1)

| 파일 | 내용 |
|---|---|
| `support/battle3d_auto_hold_harness.gd` | M5-a 하니스 확장. 스파이가 hold 호출(값·프레임)을 기록하고, 엔진 자동 행동 시작(`_run_auto_action_for_active_ally_once`, 자동 틱에서만 도달)마다 3D idle 여부를 기록한다. idle = 이동 재생 없음·적 큐 비어 있음·`enemy_hold` 0·커서 4개 = 로그 크기 |
| `test_battle3d_auto_hold_seed_1/2/3` | 4x, 끝까지. (a) 모든 자동 행동 시작에서 3D idle, (b) 엔진 직접 자동과 최종 상태 동일, hold 호출 교대·마지막 false, 쓰기 14개 안 |
| `test_battle3d_auto_hold_1x_seed_1/2/3` | 1x, 라운드 3 시작까지(전체 1x는 120초 초과). (a)와 라운드 2/3 스냅샷 동일 |
| `test_battle3d_auto_hold_release` | (c) hold 중 3D 중지 → 즉시 false·수동 복귀, hold 중 랩 해제 → 마지막 호출 false, 수동 플레이 → hold 호출 0, 1x/4x 프레임 순서 trace |

- (e) 기존 M5-a 테스트 5개는 **수정 없이** 통과했다(§4). 이제 이 테스트들도 hold를 쓰는 3D로 돈다. 그래서 M5-a의 3D == 엔진 동등성이 hold 아래에서 다시 확인됐다.
- (c)의 "결과 확정 시 false"는 seed 테스트의 끝 상태로 확인했다. 패배로 끝난 뒤 마지막 호출 false, 엔진 `auto_presentation_hold == false`, 3D `auto_hold_sent == false`다.

- 결과(단독 실행, 시드 1):
  - 4x: 자동 행동 37회 전부 시작 때 3D idle, hold 호출 74회(교대), 최종 상태 동일, 59 checks, 약 57초
  - 1x 라운드 3까지: 행동 12회, hold 호출 23회, 24 checks, 약 57초
  - release: 9 checks
  - 시드 2·3 결과는 §4 CI 표

## 3. 변조 프로브

- 방식: `battle3d_engine_play.gd`에 변조를 1개씩 적용하고 M5-a2 validator와 해당 테스트를 돌린 뒤 원래 바이트로 복원했다(`cmp` 확인 `RESTORED_OK`).
- 러너 `evidence/run_m5a2_probes.py`
- 1차 실행 `evidence/m5a2_probes_run1/`는 R1~R4다. R5는 변조 문자열이 원본과 맞지 않아 러너가 멈췄다.
- 2차 실행 `evidence/m5a2_probes_run2/`는 R5~R12다. R5 문자열을 고치고, 테스트 시간 한도를 300초 → 150초로 줄였다.
- 대조군: validator, seed 1(4x), 1x seed 1, release 모두 exit 0.

| # | 변조 | validator | 테스트 | 잡은 테스트 |
|---|---|---|---|---|
| R1 | hold 안 켬(busy 대신 false) | 잡음 | 잡음 | release(시간 초과: hold를 기다림), seed 1(시간 초과) |
| R2 | hold 안 끔(false 전송 막음) | 잡음 | 잡음 | release, seed 1(자동이 멈춰 시간 초과) |
| R3 | 3D 중지 때 안 끔(`request_auto`의 갱신 제거) | 잡음 | 잡음 | release |
| R4 | 결과 때 안 끔(`battle_result` 조건 제거) | 잡음 | **못 잡음** | — |
| R5 | 커서 소비 조건 제거 | 잡음 | **못 잡음** | — |
| R6 | 매 프레임 호출(에지 판정 제거) | 잡음 | 잡음 | seed 1(교대 검사) |
| R7 | 에지 판정 반전 | 잡음 | 잡음 | release, seed 1 |
| R8 | 연출 상태 일부 누락(이동 재생·적 큐) | 잡음 | 잡음 | seed 1, 1x seed 1(겹침 불변식) |
| R9 | `_exit_tree` 누락 | 잡음 | 잡음 | release |
| R10 | 엔진 행동 중 조건 누락 | 잡음 | 잡음 | seed 1, 1x seed 1(겹침: 이동 이벤트 3개를 3D가 아직 못 본 채 다음 행동 시작) |
| R11 | `closing` 무시 | 잡음 | 잡음 | release |
| R12 | 갱신을 이벤트 소비 앞으로 이동 | 잡음 | **못 잡음** | — |

- validator는 12개 모두 잡았다. 테스트는 9개를 잡았다.
- **테스트가 못 잡는 것(숨기지 않음)**:
  - **R4**: 결과가 확정되면 엔진이 자동을 스스로 끈다. 그러면 "자동 on" 조건 하나로 hold가 false가 된다. 그래서 `battle_result` 조건은 이중 안전장치이고, 빠져도 동작이 같다.
  - **R5**: 엔진 행동 중 조건(`is_demo_animating`/`enemy_turn`)이 커서 뒤처짐을 덮는다. 엔진이 이벤트를 낸 프레임에는 엔진이 아직 행동 중이다.
  - **R12**: 갱신이 소비 앞으로 가도 엔진 행동 중 조건 덕분에 겹침이 생기지 않는다. 대신 hold 해제가 한 프레임 늦어진다.
- R10은 "엔진 행동 중"을 hold에 넣은 결정(§5)의 근거다. 3D 연출 상태만으로는 실제로 겹침이 생겼다.

## 4. CI

- 범위: **영향받는 것만**(지시 §0: 전체 CI는 ①·③·마지막 단계). `verify-c-track.yml`의 validator 47개 전부와 3D 테스트 49개(`test_battle3d_*`, 새 7개 포함)를 돌렸다. 씬 로드·엔진 단독 테스트는 이 단계에서 돌리지 않았다(엔진 diff 0).
- 순서: `--headless --editor --import` → 러너 `run_ci_subset.py`(`run_ci.py`에 테스트 이름 필터만 더함)
- **98단계 중 97단계 exit 0. 1개 실패: `validate_battle_enemy_strategy_s4_2.py`(S4-2, 고정 validator)**:
  - 원인: 이 validator는 고정(TIP `04ce32d`) 모드에서도 파일 목록을 **현재 HEAD**의 `git ls-files scripts scenes *.gd`로 만든다. 그 파일을 TIP에서 읽으려 하므로, 그 뒤에 새로 추적되는 `.gd`가 있으면 `git show 04ce32d:<새 파일>`에서 실패한다.
  - 처음 걸린 파일은 S4-3의 `scripts/battle/services/battle_setup_rules_service.gd`다.
  - 단계 ①의 전체 CI는 커밋 **전**(새 파일이 untracked)에 돌아서 이것을 못 봤다. 커밋 뒤에 생긴 실패이고 M5-a2와 무관하다(M5-a2는 `scripts/` 아래 새 파일이 없음).
  - 처리: 이 커밋 다음에 **별도 커밋**으로 그 validator의 파일 목록을 고정 모드에서는 TIP 트리에서 읽게 고쳤다(§5 결정, 최종 상태 보고에도 적음).
- M5-a2 관련 결과:

  | 항목 | 결과 | 시간 |
  |---|---|---|
  | M5-a2 validator | PASS | 0.8초 |
  | M5-a validator(고정) | PASS | 3.1초 |
  | M5-a 기존 테스트 5개 | 수정 없이 통과 | 자동 동등성 51.3~51.5초, 속도 62.2초, 중지 15.7초 |
  | `auto_hold_seed_1/2/3` | 통과 | 51.2~51.5초 |
  | `auto_hold_1x_seed_1/2/3` | 통과 | 53.6초 |
  | `auto_hold_release` | 통과 | 14.1초 |

- 가장 긴 파일은 기존 `test_battle3d_skill_equivalence_shard_1`(66.3초)이다. 실행 전후 `git status`가 같다. 원문: zip `evidence/m5a2_ci_subset/`.

## 5. 결정 사항

| 항목 | 결정 | 이유 |
|---|---|---|
| 엔진 행동 중(`is_demo_animating`, `enemy_turn`)도 hold에 포함 | 포함 | 엔진이 행동을 끝내고 아군 턴으로 돌아오는 순간 이미 hold가 켜져 있어야 그 프레임의 지연 틱이 막힌다. 3D 연출만 보면 엔진이 이벤트를 낸 같은 프레임에 3D가 아직 못 본 상태로 틱이 지나갈 수 있다. 이미 승인된 읽기 2개라 읽기 목록은 늘지 않는다 |
| 라벨 | 기다리지 않음 | 지시문 "라벨은 제외" |
| 엔진 자동 스텝 = 틱 | 이동과 그 뒤 공격·대기가 서로 다른 틱이다 | 엔진 구조(S4-3 §0-2). 이동 재생이 끝나야 같은 장수의 다음 동작 틱이 열린다 |
| 1x 테스트 범위 | 라운드 3 시작까지(시드당 약 57초, 파일 3개) | 1x 전체 전투는 120초 한도를 넘는다 |
| hold 중 3D 중지 뒤 수동 상태 | `ally_turn` 또는 `facing_select` | 이동 도중 자동을 끄면 엔진이 그 장수의 방향 선택에서 멈춘다(기존 M5-a 동작). 수동 조작이 가능한 상태다 |
| 이전 단계 validator | S4-3 validator의 TIP 기본값을 `79471b2`로 고정(한 줄). 새 validator가 "TIP 줄만 바뀜"을 검사 | 스택 규칙 "이전 단계 validator는 자기 TIP이 고정되어 있어야" |
| CI 범위 | 영향받는 것만(모든 validator + 3D 테스트 전체 + 새 테스트) | 지시 §0: 전체 CI는 ①·③·마지막 단계 |
| S4-2 고정 validator 실패 | 다음 별도 커밋에서 그 validator의 파일 목록만 고침(고정 모드 = TIP 트리) | 새 `.gd`가 하나라도 추적되면 무조건 실패하는 validator 결함이다(스택의 S4-3·M5-b 모두 새 스크립트가 필요). 규칙 내용은 바꾸지 않는다. 클코치가 버리기 쉽게 따로 커밋했다 |

## 6. 남은 것

- 라벨(1.6~1.8초 트윈)은 다음 행동과 겹칠 수 있다(지시대로 제외).
- 사람이 직접 한 플레이는 없다.

## 7. 실제 조작 증거 (Godot 창 캡처, 뷰포트 입력 주입)

- 드라이버 `evidence/m5a2_capture/capture_driver.gd`(커밋 안 함): 렌더링 창, 제품 랩·호스트, 픽스처 없음. 입력은 `root.push_input`(버튼 화면 위치 클릭)뿐이다.
- 순서: [속도] 2번 → 4x → [자동 ▶]. hold가 바뀔 때마다 찍었다(6장). 마지막에 [자동 ■] 1장.
- 로그 요약(`evidence/m5a2_capture/run.log`):
  - `00_hold_on_3d_replaying`: 엔진 `ally_turn`, hold true, 3D가 yi_sunsin 이동 재생 중(playback), 엔진 스텝 1
  - `02_hold_on_3d_replaying`: hold true, 3D가 guan_yu 이동 재생 중 + 적 큐 3. 엔진은 아군 턴인데 다음 자동 행동을 시작하지 않음(스텝 2 그대로)
  - `01/03/05_hold_off_next_action`: hold false가 된 프레임 다음에 찍었다. 그사이 엔진이 다음 행동을 시작해 hold가 다시 true다(스텝 +1)
  - `06_auto_stopped`: 자동 off, hold false, 3D는 남은 적 재생을 계속함
- 그림 `evidence/m5a2_capture/out/*.png`
