# BATTLE S4-2 결과 — 적 책략 + 적 고유특기 분배 (엔진, 플래그 뒤) (2026-10-22)

- 작업 ID: S4-2 Enemy Strategy & Skill Spread (엔진 단계 S)
- 지시문 `S4_2_ENEMY_STRATEGY_SKILL_SPREAD_20261022.md`, 설계서 `DESIGN_S4_2_ENEMY_STRATEGY_AND_SKILL_SPREAD_20261022.md` (클코치)
- 브랜치 `feature/engine-s4-2-enemy-strategy-20261022` ← `origin/integration/p1-engine-core-20261019`(기준 `8957b27` 확인)
- 커밋 2개:
  - (1) `adcf4f9` `feat(battle): add enemy strategy to the enemy AI behind a flag (S4-2a)`
  - (2) `feat(battle): spread enemy unique skills across actors behind a flag (S4-2b)` (이 보고서를 담은 커밋이라 해시는 zip `commit_info.txt`)
- 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함. 합격 판정은 하지 않는다(검수: 클코치).
- **두 플래그 모두 기본값 `false`로 커밋했다.** 플래그 false에서 기존 테스트·골든·pinned validator는 수정 없이 통과한다(§10).
- **멈춤 규칙에 걸리지 않았다.** 설계와 다른 사실 없음, 아군 동작 변경 없음, 기존 골든·테스트 수정 없음, 새 난수 없음.
- **측정 결과 중 김작이 볼 것 (§8)**: 기본 시나리오에서 분배 규칙을 켜도 **xiahou_dun 독점은 풀리지 않았다**. 오히려 적 특기 사용이 5회 → 7회로 늘었고 아군이 라운드 8에 패배했다. 원인은 점수 차이(341~521 대 240~448)가 감점 40/20보다 훨씬 크기 때문이다. 수치 조정은 설계서 §8-2의 열린 결정이라 바꾸지 않았다.

---

## 0. 사전 확인 9개 (엔진 직접 실행, 새로 돌린 것)

스크립트: zip `evidence/s42_precheck/_tmp_s42_precheck.gd`(커밋 안 함), 원문 `precheck.log`.

### 1. 적 한 행동의 종료 경로 — 모든 경로가 `_mark_enemy_unit_acted` → `_advance_enemy_turn_or_return_to_ally`

- `enemy_action_completed`는 **`_mark_enemy_unit_acted` 안에서만** 기록된다(처음 행동 처리할 때 1번. 같은 유닛을 다시 표시해도 기록하지 않음). 그 직전에 `_consume_strategy_status_after_unit_action`(상태 틱)이 돈다.
- 공격: Tween 끝 `_finish_enemy_actor_basic_attack` → mark → advance.
- 이동: Tween 끝 → `_play_enemy_actor_basic_attack_or_wait_after_move` → 공격(Tween) / 특기 / 대기(mark → advance).
- 특기: `_finalize_unique_skill_action`(타이머) → `_mark_enemy_unit_acted` → `_advance_enemy_turn_or_return_to_ally`.
- **대기(`enemy_waited`)는 Tween·타이머 없는 즉시 행동**이다: `record_waited` → mark → advance(같은 프레임). 적 책략도 이 모양을 그대로 따른다(즉시 행동, 완료 1번).
- 실행 확인: 기본 배치 라운드 1, 아군 대기 3회. 적 슬롯 3개, `enemy_actor_selected` 3 = `enemy_action_completed` 3. 슬롯은 모두 이동 → 대기 → 완료.

### 2. `_resolve_strategy` 분리 가능성 — 가능, 분리함

- 호출자는 `_try_use_strategy_on_target` 1곳뿐이다(아군 수동 책략).
- 본문은 세 덩어리다:
  - ① 아군 UI 사전 처리: 범위 표시 숨김, 대상 선택 해제, 떠 있는 명령 패널, `_set_phase(RESOLVING)`, 카메라
  - ② **효과 코어**: "책략을 펼쳤습니다" 로그, "책략!" FX, 성공 판정 `_strategy_roll_success`, 결과 `_roll_strategy_outcome`, `apply_status_effect`, 성공/실패 FX·로그, `tactic_event_log.record_strategy_cast`
  - ③ 아군 후처리: `_mark_ally_unit_acted`, 클로즈업, 준비 프레임, 슬롯 가이드, 상태 아이콘, 사망 정리, 결과 확정이면 ally_turn, 아니면 `_set_phase(ENEMY_TURN)` + "적군 턴" + `_play_enemy_turn_demo()`
- ②를 `_resolve_strategy_effect`로 옮기고, `_resolve_strategy`는 ① → `_resolve_strategy_effect` → ③을 **같은 순서**로 호출한다.
  - validator는 코어를 원래 자리에 다시 펼치면 BASE 본문과 같다는 것을 검사한다.
  - 코어에는 진영 분기가 없다(`side`, `_mark_*`, `_set_phase` 없음 — validator 검사).
- 아군 동등성: S4-1 오라클 49케이스(S1~S8 책략, 특기 36종, 아군 자동, 처치 후 전진, 확정 실패, 상태 틱, 적 단일 특기)를 **두 플래그를 켠 채** 돌렸다. 결과가 S4-1 골든과 같다(§7 `ally_parity` 샤드 4개). 로그 줄 순서·난수 소비 순서도 골든 비교에 들어 있다.

### 3. 책략 조건 읽기

- `_can_use_strategy`의 조건과 진영 의존 여부:

  | 조건 | 진영 의존 |
  |---|---|
  | `current_phase`가 ally_turn/strategy | 진영 의존 |
  | `is_demo_animating`, `is_full_auto_battle_enabled` | 아군 UI용 |
  | `unit.is_alive()` | 중립 |
  | `side != "ally"`면 불가 | 진영 의존 |
  | `_has_ally_unit_acted` | 진영 의존 |
  | `_is_unit_confused`(confusion / action_lock / fear) | 중립 |
  | `intelligence < STRATEGY_BASIC_INTELLIGENCE(80)` | 중립 |

- 적 쪽은 중립 조건만 재사용한다: 살아 있음, `_has_enemy_unit_acted` 아님, `_is_unit_confused` 아님, INT ≥ 80. 순수 함수 `can_enemy_use_strategy`로 옮겼다.
- `_get_strategy_range`, `_get_strategy_tier`, `_get_strategy_outcome_pool`, `_get_strategy_targets`(상대 진영 기준), `_get_strategy_success_rate`는 진영 중립이고, 수정하지 않았다.
- 결과 풀의 상태 id:
  - basic: `shake` 1턴
  - advanced: `confusion` 1턴 / `shake` 2턴
  - master: `confusion` 2턴 / `shake` 3턴
  - 풀 전체 id는 `{confusion, shake}`다.

### 4. 기본 시나리오의 지력 표

| 진영 | 부대 | INT | 티어 | 사거리 | 시작 배치 | 고유특기(비용, 모드) |
|---|---|---|---|---|---|---|
| 아군 | yi_sunsin | 96 | master | 5 | 예 | yi_sun_sin_unique (4, enemy_area) |
| 아군 | jeong_dojeon | 97 | master | 5 | 예 | jeong_do_jeon_unique (3, self_area) |
| 아군 | gwon_yul | 84 | basic | 3 | 예 | kwon_yul_unique (3, self_area) |
| 아군 | ally_reinforce_01_demo | 78 | — | 0 | 증원 | 없음 |
| 아군 | ally_reinforce_02_test_unit | 88 | basic | 3 | 증원 | 없음 |
| 적 | guan_yu | 72 | — | 0 | 예 | guan_yu_unique (3, enemy_line) |
| 적 | zhang_fei | 50 | — | 0 | 예 | zhang_fei_unique (3, self_area_enemy) |
| 적 | xiahou_dun | 62 | — | 0 | 예 | xiahou_dun_unique (2, single_enemy) |
| 적 | enemy_reinforce_01_demo | 86 | basic | 3 | 증원 | 없음 |
| 적 | enemy_reinforce_02_test_unit | 98 | master | 5 | 증원 | 없음 |

- **기본 시나리오의 시작 적 3부대는 모두 INT < 80이라 책략을 쓸 수 없다.** 책략을 쓸 수 있는 적은 증원 2부대뿐이다.
- 실측(§8)에서 실제로 책략을 쓴 적은 증원 02(INT 98)뿐이었고, 라운드 7부터 썼다. 증원 01(INT 86)은 책략을 쓰지 않았다(원인은 따로 확인하지 않음).
- 설계서와 모순은 아니다(설계서는 기본 시나리오 INT를 적지 않았다). 그래서 멈추지 않았다. 다만 기본 시나리오에서는 적 책략이 늦게, 드물게 나온다.

### 5. 재사용할 적 대상 선정 함수

- `_get_enemy_ai_target_state_from_candidates(enemy_actor_state, target_candidates: Array[BattleUnitState]) -> BattleUnitState`
  - 후보 중 공격 사거리 안 가장 가까운 대상, 없으면 가장 가까운 대상
  - `_get_enemy_ai_target_state_for_actor`가 이 함수를 쓴다
- 순수성: 적 3부대 × 3회 호출 전후 유닛 40필드, 컨트롤러 12값, 로그 4개 + 전투 로그 줄이 같았다. 난수 다음 값도 같았다.
- 적 책략 대상 선택 순서:
  1. 계획의 `final_target_state`가 책략 후보(사거리 안이고 풀 상태가 없는 대상)이면 그 대상
  2. 아니면 책략 후보만 넘겨 위 함수가 고른 대상
- 새 점수식은 없다.

### 6. 적 특기 독점의 현재 분포 (BEFORE)

- 원인 3가지를 코드로 확인했다.
  - `_get_next_available_enemy_ai_actor`의 순서가 고정이다: `enemy_unit_state` → `enemy_support_unit_state` → `enemy_main_03_unit_state` → 증원 01 → 증원 02, 미행동 중 첫 번째.
  - `battle_momentum`은 진영당 풀 하나다. `_try_auto_unique_skill_for_actor`는 자기 점수 ≥ 130이면 바로 쓴다(다른 장수와 비교하지 않음).
  - 쿨다운: 데이터 44개 모두 0이다(S4-1/M4-c1 확인).
- 측정 방법:
  - **BASE 워크트리**(`8957b27`, 이 작업 코드 없음), 기본 시나리오
  - 아군은 엔진 자동 행동 `_run_auto_action_for_active_ally_once`로 진행. 못 하면 대기
  - 라운드 10까지(라운드 11 진입 시 종료), 시드 1~6
  - 드라이버: zip `evidence/s42_measure/_tmp_s42_measure.gd`

| 라운드 | 2 | 3 | 4 | 5 | 6 | 7~10 |
|---|---|---|---|---|---|---|
| 적 특기 | zhang_fei | guan_yu | xiahou_dun | xiahou_dun | xiahou_dun | 없음 |

- **시드 6개 결과가 완전히 같았다.** 규칙 난수는 책략 헬퍼 2개뿐이고(아군 자동 행동은 책략을 쓰지 않음), 나머지 `randf_range`는 FX 시간뿐이다.
- 장수별 횟수: xiahou_dun 3 / guan_yu 1 / zhang_fei 1. 라운드 4~6에 xiahou_dun이 3연속으로 썼다(비용이 2로 가장 싸고 점수가 가장 높음).
- 라운드 7~10에는 기세가 10(최대)인데도 적 특기가 없었다(전투 끝 적 기세 10).

### 7. `_try_auto_unique_skill_for_actor` 공유

- 호출 위치:
  - 아군 전자동 `_run_auto_action_for_active_ally_once`: 고가치(true) 1회, 대체(false) 1회
  - 적 AI `_play_enemy_ai_for_actor`: 계획 전 고가치(true) 1회
  - 적 이동 후 `_play_enemy_actor_basic_attack_or_wait_after_move`: 고가치 1회, 대체 1회
- 분배는 **이 함수 안 가치 검사 바로 뒤** 한 줄에서 판정한다. 판정 함수는 첫 줄에서 `side != "enemy"`이거나 플래그가 꺼져 있으면 false를 돌려준다.
- 아군 전자동 결과 불변은 `ally_parity`(K_ally_auto_skill 포함)로 확인했다.

### 8. 사용 이력 저장 위치

- 저장 위치: 컨트롤러 멤버 `var enemy_skill_last_use_round := {}`(unit_id → `battle_round`).
- 라운드 번호는 컨트롤러 `battle_round`다.
- 초기화:
  - 전투 노드가 새로 만들어질 때 `{}`로 시작한다.
  - `reset_demo_state()`는 `_ready`에서 한 번만 호출된다(호출 위치 1곳). 그래서 따로 지우는 줄을 넣지 않았다(기존 함수 수정 범위 밖).
- **이어하기 스냅샷에 넣지 않는다**: `_persist_battle_resume_snapshot`은 기세·쿨다운만 저장한다. validator가 이 함수의 불변과 이력 미포함을 검사한다.

### 9. 3D 기존 소비자 호환 — 깨지지 않음(읽기만)

- `_consume_enemy_events`의 `match`에서 모르는 kind는 `_:` 분기로 가서 슬롯 배열에만 붙는다.
- `_present_enemy_event`와 `_finish_enemy_summary`의 `match`에는 기본 분기가 없어서 아무것도 하지 않는다. 오류는 나지 않는다.
- 새 kind는 플래그가 켜져야만 나온다. 플래그 false에서는 M3~M4-c1 3D 테스트가 전부 통과했다(§10).
- 플래그 true일 때의 3D 영향은 §9 영향 측정 표에 있다.
- 적 책략이 3D에서 "이동·병력 변화 없음" 요약으로만 보이는 문제는 M4-c2 범위다.

---

## 1. 기능 상태

| 항목 | 상태 | 근거 |
|---|---|---|
| 적 책략(D 순서: 확정 처치 → 특기 → 계획, 계획이 ATTACK이 아니면 현재 자리에서 책략) | 동작(플래그 on) | 행동 테스트 17시나리오 |
| 책략 조건 = 아군과 동일(INT ≥ 80, 사거리 3/4/5, 성공률·풀·턴, 혼란·행동불가·공포 불가) | 동작 | ES01~03(티어별 사거리), ES04(INT 79), ES05(사거리 밖), ES06·07 |
| 중복 상태 제외(시전자 풀의 상태가 이미 있는 대상 제외) | 동작 | ES08, ES12(계획 대상 제외 → 기존 선택 함수가 다른 대상), ES13(두 번째 적이 건너뜀) |
| 기세 비용 없음 | 동작 | 시전 직전 == 시전자 완료 시점 기세 |
| 행동 완료 1번(`enemy_actor_selected` → `enemy_strategy_used` → `enemy_action_completed`), 라운드 진행 | 동작 | 매 시나리오 슬롯 모양, ES16(라운드 완료) |
| 책략 후 상태 틱, 화상 틱으로 전투 종료 | 동작 | ES14, ES15(`battle_ended victory`) |
| `_resolve_strategy` 분리(아군 동작 불변) | 동작 | ally_parity 49케이스 == S4-1 골든(플래그 on) |
| 적 특기 분배(양보·감점·동률·이력) | 동작(플래그 on) | 분배 행동 7시나리오 + 규칙 단위 테스트 29 |
| 분배 판정 난수 0 | 동작 | 매 판정 전후 전역 난수 다음 값 일치 |
| 플래그 false == BASE | 동작 | 책략 골든 23케이스(17 + 전투 6판) + 분배 골든 7 |
| 3D 수정 | 0 | validator |

## 2. UI 상태

해당 없음(엔진 단계). 3D 재생은 M4-c2다. 엔진 2D 화면에는 기존 책략 FX("책략!", 결과 문구)와 전투 로그 줄이 적 책략에서도 그대로 나온다(효과 코어 공유).

## 3. 실제 조작 증거

사람 조작이 아니라 엔진 실행 로그다.

- **적 책략**: 행동 테스트 로그 `evidence/s42_dev/test_battle_enemy_strategy_behavior.log` 발췌(ES01, basic, 사거리 3, 강제 성공 → 동요 1턴):
  - `enemy=[enemy_turn_started, enemy_actor_selected, enemy_strategy_used, enemy_action_completed]`
  - `choices=[[guan_yu, yi_sunsin, yi_sunsin]]` (시전자, 계획 대상, 선택 대상)
- **전투 한 판(플래그 on, 증원 02)**: §8 측정 로그 `strategy_seed2.log`
  - 라운드 7 `enemy_reinforce_02_test_unit` → `ally_reinforce_01_demo` 동요
  - 라운드 9 → `ally_reinforce_02_test_unit` 혼란
- **특기 분배**: 엔진이 찍는 판정 줄(`spread_seed1.log`):
  - `[ENEMY_SKILL_SPREAD] round=3 yield=guan_yu raw=268 adjusted=268 others=[[zhang_fei, 240, 200, 3], [xiahou_dun, 341, 341, 2]] momentum=3`
- **분배 행동 SP02**(기세 4): guan_yu가 양보하고 계획대로 공격 → xiahou_dun이 자기 슬롯에서 특기. BASE에서는 guan_yu가 특기를 쓰고 xiahou_dun은 공격만 했다.

## 4. 남은 연결

- M4-c2: 적 책략(`enemy_strategy_used` + `strategy_cast`)과 적 특기(`skill_*` side=enemy)의 3D 재생.
- 플래그 기본값 true 전환: 검수와 김작 결정 뒤 별도 커밋(설계서).
- 분배 수치(감점 40/20, 양보 조건) 조정: §8 측정 결과를 보고 김작이 결정(열린 결정 §8-2).
- 사용 이력의 이어하기 저장: B-1H와 함께 결정(열린 결정 §8-3). 지금은 저장하지 않는다.

## 5. 결정 사항 (질문 대신 보수적으로 정한 것)

| 항목 | 결정 | 이유 |
|---|---|---|
| 적 책략 삽입 위치 | `_play_enemy_ai_for_actor`에서 ATTACK 분기 바로 뒤 한 곳. 이동 후(`…_after_move`)에는 넣지 않음 | 설계 §3.1 "이동 없이 현재 자리". 계획 전 판단 1회만 |
| 적 책략 적용 범위 | 계획 이유가 MOVE_ATTACK·ENGAGE·WAIT일 때 이동 대신 책략 | D안 그대로. 이동 경로·예약은 만들지 않음(예약 함수 호출 전에 끝냄) |
| 효과 코어 범위 | "책략을 펼쳤습니다" 로그와 "책략!" FX부터 `record_strategy_cast`까지 | 아군 호출 순서·로그 순서가 BASE와 같고, 적도 같은 로그·FX를 냄 |
| 적 책략의 카메라·UI | 호출하지 않음(코어 + 상태 아이콘 갱신 + 적 후처리만) | 아군 UI·페이즈 전환 금지(설계 §3.3) |
| 중복 제외 규칙 | 시전자 풀의 상태 id 중 하나라도 대상에게 있으면 제외. basic 시전자는 혼란 걸린 대상에게 동요를 걸 수 있음 | `_get_strategy_outcome_pool`을 읽어 정함(설계 §3.2) |
| `enemy_strategy_used` 필드 | `unit_id`, `target_id`(둘 다 빈 문자열 불가) | 지시문 그대로. `enemy_skill_used`처럼 효과 전 "시도" 기록 |
| 분배 판정 위치 | `_try_auto_unique_skill_for_actor`의 가치 검사 뒤(고가치·대체 둘 다) | 이동 후 대체(≥70) 판단도 같은 기세를 쓰므로, 상위 후보 몫의 기세를 지키려면 같은 규칙이 필요 |
| 후보 점수 | 각 후보의 `_get_best_unique_skill_target_for_actor` 대상으로 `_score_unique_skill_plan_for_actor`(기존 점수), 비용은 `_get_effective_unique_skill_cost` | 새 점수식 없음. 순수함 확인(사전 확인 5) |
| 행동 순서(동률 마지막) | `_get_next_available_enemy_ai_actor`와 같은 목록을 새 함수에 복제 | 기존 함수 수정·리팩터링 금지 |
| 이력 기록 시점 | 특기를 쓰기로 정한 순간(`record_skill` 직후) | 기존 `enemy_skill_used` 기록 시점과 같음. 확정 실패는 드묾(S4-1) |
| 임계 130 | 서비스 상수 `HIGH_VALUE_SKILL_SCORE := 130`(컨트롤러 값과 같음, validator가 둘 다 확인) | 기존 임계 유지 |
| 플래그 설정 | 테스트에서만 `set()`(배틀 스크립트·하니스) | 지시문 |
| 분배 측정 지표 "양보 후 못 쓴 횟수" | 양보가 나온 라운드에 그 진영 특기 사용이 0이면 1회로 셈 | 이벤트를 추가하지 않으므로 엔진 판정 줄과 기존 이벤트로 계산 |
| 시드 6개가 같게 나옴 | 그대로 보고 | 규칙 난수는 책략 헬퍼뿐이라 책략이 없으면 결정적(사전 확인 6) |

## 6. 변경 파일

| 파일 | 변경 | 내용 |
|---|---|---|
| `scripts/battle_web_import_test.gd` | +123 −11 | preload 1 + 멤버 3 + 새 함수 8. 바뀐 기존 함수 3개: `_resolve_strategy`(코어 호출로 대체), `_play_enemy_ai_for_actor`(2줄 삽입), `_try_auto_unique_skill_for_actor`(3줄 삽입) |
| `scripts/battle/services/battle_enemy_event_log_service.gd` | +10 | 스키마 1줄 + `record_strategy` + 검증 분기 2줄. 기존 9종 불변 |
| `scripts/battle/services/battle_enemy_tactic_rules_service.gd` | 신규 | 순수 규칙 7개(static, 상태·난수 없음) |
| `.github/workflows/verify-c-track.yml` | +12 | validator 1, 테스트 11 |
| `tools/validate_battle_enemy_strategy_s4_2.py` | 신규 | BASE `8957b27`, TIP 기본 `HEAD`(`S4_2_SCOPE_TIP`) |
| `tests/golden/battle_enemy_strategy_base_v0.json` / `battle_enemy_skill_spread_base_v0.json` | 신규 | **BASE 워크트리에서 생성**, 케이스마다 2회 실행으로 결정성 확인 |
| `tests/scripts/support/battle_enemy_*`(5개) | 신규 | 오라클 하니스, 관찰자 2, 플래그 on 배틀, 분배 이음새 |
| `tests/scripts/test_battle_enemy_*`(본체 2 + CI 11) | 신규 | §7 |
| `.uid` 사이드카 | 신규 | import |
| `agent/BATTLE_S4_2_RESULT_20261022.md` | 신규 | 이 보고서 |

## 7. 테스트 (CI 편입, 11개)

| 테스트 | 내용 | checks | 초(CI 재현) |
|---|---|---|---|
| `test_battle_enemy_strategy_base_parity_shard_1` | 플래그 off, 적 책략 시나리오 17개 == BASE 골든(유닛 40필드, 컨트롤러 12값, 체크포인트 3, 로그 4 + 전투 로그 줄) | 21 | 33 |
| `…_base_parity_shard_2·3` | 플래그 off, 기본 전투 한 판(아군 자동 10행동) 시드 1~3 / 4~6 == BASE 골든(행동마다 체크포인트) | 4/4 | 67/67 |
| `test_battle_enemy_rules_ally_parity_shard_1~4` | **두 플래그 on**, S4-1 49케이스 == S4-1 골든(아군 책략·특기·전자동 불변) | 59/67/67/44 | 31~40 |
| `test_battle_enemy_strategy_behavior` | 플래그 on, 17시나리오. 안 나가야 하는 8개(INT 79·사거리 밖·혼란·행동불가·이미 걸린 대상·ATTACK 계획·확정 처치·특기 우선)는 BASE 골든과 같음. 나가는 경우는 슬롯 모양·이벤트 필드·시도/효과 대상 일치·풀 결과·기세 불변·턴 반환·틱 순서·전투 종료를 확인 | 151 | 29 |
| `test_battle_enemy_skill_spread_base_parity` | 플래그 off, 분배 시나리오 7개 == BASE 골든 | 11 | 27 |
| `test_battle_enemy_skill_spread_behavior` | 플래그 on, 아래 7개 시나리오 | 43 | 27 |
| `test_battle_enemy_tactic_rules_service` | 순수 규칙: 자격, 중복 제외, 감점 경계(d=0/1/2/3), 동률 3단계, 양보 조건(기세·임계·감점), 결정성 | 29 | <1 |

`test_battle_enemy_skill_spread_behavior`의 7개 시나리오:
- 후보 1명(BASE와 같음)
- 기세 1명분 → 양보 + 양보한 장수가 계획대로 공격 + 상위 장수가 자기 슬롯에서 특기
- 둘 다 가능 → 둘 다 사용 + 이력 기록(BASE와 같음)
- d=1 감점으로 양보
- 이력 없음 / d=2 → 양보 안 함(BASE와 같음)
- 양보 후 상위 장수가 못 쓰게 됨(이음새) → 기세 유지
- 모든 판정에서 난수 소비 0

- 측정(§8)과 영향 측정(§9)은 테스트 게이트가 아니라 보고다.
- 이음새 `battle_enemy_skill_seam_battle.gd`: 지정한 장수가 **자기 차례에만** 특기를 못 쓰게 한다(그 사이 대상이 죽거나 사거리를 벗어난 경우). BASE에도 있는 함수만 덮어써서 BASE 골든 생성에도 썼다.

## 8. 분배 측정 (§4.3, 새로 돌린 것)

- 조건: 기본 시나리오, 아군 엔진 자동 행동, 라운드 10까지(또는 승패), 시드 1~6
- BEFORE는 BASE 워크트리에서, AFTER는 이 브랜치에서 플래그를 바꿔 실행
- 원문: zip `evidence/s42_measure/{before,after}/`

| 구성 | 시드별 차이 | 적 특기(라운드: 장수) | 장수별 | 결과 |
|---|---|---|---|---|
| BEFORE(BASE) | 6개 동일 | 2 zhang_fei / 3 guan_yu / 4·5·6 xiahou_dun | xiahou_dun 3, guan_yu 1, zhang_fei 1 | 라운드 11 진입(승패 없음) |
| 책략만 on | 특기 동일, 책략 결과만 시드별 | BEFORE와 같음 | 같음 | 시드 4만 라운드 12 패배, 나머지 승패 없음 |
| 분배만 on | 6개 동일 | 2 zhang_fei / 3 xiahou_dun / 4 zhang_fei / 5·6·7·8 xiahou_dun | **xiahou_dun 5, zhang_fei 2, guan_yu 0** | **라운드 8 아군 패배** |
| 둘 다 on | 6개 동일, 분배만 on과 같음 | 같음 | 같음 | 라운드 8 패배(증원 02가 책략을 쓰기 전에 끝남) |

**양보 판정**(분배 on, 시드 1, 6개 시드 같음):

| 라운드 | 양보 | 판정 시 점수(원/보정) | 상위 후보 | 기세 |
|---|---|---|---|---|
| 3 | guan_yu | 268/268 | xiahou_dun 341/341 | 3 |
| 3 | zhang_fei ×2(계획 전·이동 후) | 240/200 | xiahou_dun 341/341 | 4 |
| 5 | guan_yu | 448/448 | xiahou_dun 521/501 | 3 |
| 5 | zhang_fei | 240/200 | xiahou_dun 521/501 | 4 |
| 6 | zhang_fei | 240/220 | xiahou_dun 357/317 | 4 |

- 양보는 판정 6번(슬롯 5개)이다. 양보가 나온 라운드에 그 진영 특기가 0인 경우("양보 후 못 쓴 횟수")는 **0회**였다.

**책략 측정**(책략만 on): 6개 시드 모두 증원 02만 책략을 썼다.
- 라운드 7부터 판당 2~3회, 모두 14회(성공 10 / 실패 4). 결과는 동요·혼란이었다.
- 대상은 아군 증원 2부대였다.

**해석(판정이 아니라 사실)**:
- 목표("후보 2명 이상이 계속 자격이 있는 구간에서 한 장수가 독점하지 않을 것")는 **이 시나리오에서 달성되지 않았다.** xiahou_dun은 원점수가 다른 후보보다 73~100점 높다. 감점 40(d=1)·20(d=2)으로는 순위가 바뀌지 않는다.
- 분배는 독점을 줄이기보다 **양보로 남은 기세를 상위 장수에게 몰아줘서** 적 특기 횟수를 늘렸다(5 → 7, 3라운드 → 7라운드 동안). 그 결과 아군이 라운드 8에 졌다.
- zhang_fei는 이번 측정에서 2회로 늘었다(라운드 2·4. 라운드 2는 BEFORE와 같고, 라운드 4는 xiahou_dun이 d=1 감점을 받은 라운드).
- 수치(감점 크기·적용 라운드, 임계, 양보 조건)는 바꾸지 않았다. 김작 결정 사항이다.

## 9. 영향 측정 (§1-4, 커밋 안 함)

- 방법: 엔진 파일의 두 플래그 기본값을 **임시로 `true`** 로 바꿨다. 커밋 2 직전 작업 트리에서 CI 목록 전체(validator 41, 테스트 113, 씬 로드 3, editor, diff-check)를 돌린 뒤 원래 바이트로 되돌렸다(`cmp` 확인).
- 골든은 재생성하지 않았다. 원문은 zip `evidence/s42_ci_impact_flags_on/`.
- **결과: 154단계 중 3개가 exit 1이었고, 셋 다 이번 단계에서 새로 만든 검사다. 기존 테스트·골든·pinned validator 중 결과가 달라진 것은 0개다.**

| 달라진 것 | 원인 |
|---|---|
| `tools/validate_battle_enemy_strategy_s4_2.py` | "플래그 기본값 false" 검사(의도대로) |
| `test_battle_enemy_strategy_base_parity_shard_1` | 적 책략이 나가는 9개 시나리오(ES01·02·03·12·13·14·15·16·17)의 적 로그·상태가 BASE 골든과 다름. 나머지 8개(안 나가야 하는 경우)는 같음 |
| `test_battle_enemy_skill_spread_base_parity` | 양보가 일어나는 SP02·SP04·SP07이 BASE 골든과 다름 |

**기존 테스트가 달라지지 않은 이유**(확인한 사실):
- 기존 적 턴 fixture(S3-1 E1~E20, M3 3D 18케이스, M3-b~M4-c1의 3D fixture, S4-1 보드)의 적 행동자는 guan_yu(INT 72)·zhang_fei·xiahou_dun(INT < 80)이다. 그래서 적 책략이 나가지 않는다.
- 같은 fixture에서 미행동 적 중 특기 후보는 1명이라 양보가 일어나지 않는다.
- 기본 배치 완주 테스트(M3 기본 라운드, M3-b~M4-d 기본 배치, S4-1 R1, M4-c1 기본 라운드)는 라운드 2~3에서 끝난다.
  - 분배 측정(아군 자동 행동)에서 첫 양보는 라운드 3 guan_yu였다. 이 테스트들은 아군 행동이 다르다(대기·방어·책략·특기). 결과가 BASE와 같았으므로 양보가 일어나지 않은 것으로 본다(양보 횟수를 따로 세지는 않음).
  - 증원 02의 첫 책략은 라운드 7이다.
- 이번 단계의 전투 한 판 동등성(아군 자동 10행동, 라운드 4 근처까지)도 플래그 on에서 BASE와 같았다(shard 2·3 exit 0).

**3D**: 플래그 on에서도 M1~M4-c1 3D 테스트와 validator는 모두 통과했다. 적 책략·양보가 나오는 장면이 그 테스트들에 없기 때문이다. 실제 전투에서 적 책략이 나오면 3D는 `enemy_strategy_used`를 슬롯에 붙이기만 하고 표시하지 않는다(사전 확인 9). M4-c2 전에는 3D 플레이 확인을 하지 않는다(설계서 §3.4).

## 10. 전체 CI 로컬 재현 (새로 돌린 것)

**커밋 1 시점**(S4-2a만, 작업 트리 = 커밋 `adcf4f9` 내용):
- `.godot` 삭제 → `--headless --editor --import`(**1회 만에 exit 0, 43초, signal 11 없음**) → `verify-c-track.yml` 목록 그대로 실행(러너 `run_ci.py`)
- **155단계 모두 exit 0**(합계 약 1,965초): validator 40, 테스트 **110** = 102 + S4-2a 8, 씬 로드 3, editor, diff-check
- 원문: zip `evidence/s42_ci_commit1/`

**커밋 2 시점**(최종, 보고서만 자리표시, 플래그 false):
- `.godot` 삭제 → import(**1회 만에 exit 0, signal 11 없음**) → 목록 그대로 실행
- **159단계 모두 exit 0**(합계 약 2,077초):
  - validator **41** = 40 + S4-2 1
  - 테스트 **113** = 102 + S4-2 11
  - 씬 로드 3, editor, diff-check
- 기존 테스트·골든·pinned validator는 수정 없이 통과했다(S3-1·S4-1 오라클, M1~M4-c1 3D 포함).
- 가장 긴 파일은 기존 `test_battle3d_skill_equivalence_shard_1`(85.9초)이다. S4-2 파일은 최대 67.4초(`base_parity_shard_2`)다.
- 실행 후 `git status`에는 이번 변경 파일만 있었다. 원문: zip `evidence/s42_ci_commit2/`
- 환경 크래시는 없었다.

## 11. 변조 프로브 (새로 돌린 것, 15개)

- 방식: 엔진·이벤트 로그 서비스·규칙 서비스에 변조를 1개씩 적용하고 validator와 Godot 테스트를 돌린 뒤 원래 바이트로 복원했다(`cmp` 확인).
- 러너: zip `evidence/run_s42_probes.py`. 결과: `evidence/s42_probes_final/`

| 지시문 예 | 프로브 | validator | Godot 테스트 |
|---|---|---|---|
| 플래그 false인데 책략 발동 | P1(플래그 검사 삭제) | exit 1 | exit 1 (BASE 동등성 ES01) |
| 〃 (추가) 기본값 true | P1b | exit 1 | exit 1 (BASE 동등성 ES01) |
| 계획이 ATTACK인데 책략 | P2(ATTACK 분기 앞으로 이동) | exit 1 | exit 1 (행동 ES09 == BASE 아님) |
| 이미 걸린 대상에 책략 | P3(중복 제외 삭제) | exit 1 | exit 1 (ES08). ES13은 exit 0 * |
| 책략 후 행동 완료 누락 | P4(`_mark_enemy_unit_acted` 삭제) | exit 1 | exit 1 (ES01: 슬롯 미완료) |
| 아군 후처리가 적 책략에서 호출 | P5 | exit 1 | exit 1 (ES01) |
| 적 후처리가 아군 책략에서 호출 | P6 | exit 1 | exit 1 (ally_parity S1 ≠ S4-1 골든) |
| 양보 조건 반전 | P7 | exit 1 ** | exit 1 (SP02, SP03, 규칙) |
| 감점 부호 반전 | P8 | exit 1 ** | exit 1 (SP04, 규칙) |
| 사용 이력 미갱신 | P9 | exit 1 | exit 1 (SP03 이력) |
| 분배가 아군 전자동에도 적용 | P10(진영 검사 삭제) | exit 1 | **exit 0(못 잡음)** — ally_parity K_ally_auto_skill, K_single_burst |
| 분배에 난수 사용 | P11 | exit 1 | exit 1 (SP02 난수 검사) |
| 새 kind 필드 누락 | P12(`target_id` 빠짐) | exit 1 ** | exit 1 (ES01: 서비스가 거부해 이벤트 없음) |
| 기세 비용을 책략에 부과 | P13 | exit 1 | exit 1 (ES01 기세) |
| (추가) 분배 임계 변경 | P14(130 → 400) | exit 1 | exit 1 (SP02, 규칙) |

- \* P3에서 ES13은 못 잡았다. 두 번째 적(basic, INT 86)은 이미 동요가 걸린 대상만 사거리 안에 있다. 중복 제외를 지워도 그 대상에게 책략을 걸 수 있지만, 슬롯 모양 단언은 첫 번째 시전자만 보기 때문에 잡히지 않았다. ES08은 잡는다.
- \*\* P7·P8·P12는 **1차 실행에서 validator가 못 잡았다**. 그래서 validator에 규칙 서비스 함수 7개 본문과 `record_strategy` 본문 고정을 넣었고, 최종 실행에서 모두 잡혔다.
- 보강 직후 실행은 무효였다. 처음 넣은 고정 검사에 버그가 있어 대조군 validator도 실패했기 때문이다. 고친 뒤 대조군 exit 0을 확인하고 15개 전부를 다시 돌렸다. 1차 원문은 `evidence/s42_probes_run1/`.
- P10은 테스트로 못 잡는다. S4-1 보드에서 아군 시전자보다 순위가 높고 고가치인 적 후보가 없어서, 진영 검사를 지워도 양보가 일어나지 않는다. validator만 잡는다.
- 대조군: validator, 행동 ES01, BASE 동등성 ES01, ally_parity S1, 분배 SP02, 규칙 테스트 모두 exit 0.

## 12. 새로 돌린 것 / 재사용 / 못 덮은 영역

- **새로 돌린 것**:
  - 사전 확인 스크립트 1개
  - BEFORE 측정 6시드(BASE 워크트리), AFTER 측정 18회(책략만·분배만·둘 다 × 6시드)
  - 골든 2개 생성(BASE 워크트리, 2회 결정성)
  - 개발 실행, 변조 프로브 3회(1차 / 무효 / 최종)
  - 영향 측정 CI 1회, 전체 CI 2회(커밋 1, 커밋 2)
  - 커밋 후 validator 고정 모드
- **재사용**: S3-1 오라클(SeamBattle·`_setup_unit`·스냅샷), S4-1 오라클 하니스와 골든(아군 경로 동등성), S4-1 S1~S8·K 케이스, M4-c1 CI 러너(변경 없음).
- **못 덮은 영역(숨기지 않음)**:
  - 분배가 아군 전자동에 새는 변조(P10)는 테스트로 못 잡는다(validator만).
  - 기본 시나리오에서는 적 책략이 증원 02에서만, 라운드 7 이후에 나온다. 시작 적 3부대는 INT < 80이다.
  - 동률 규칙 2·3단계(오래된 사용, 행동 순서)는 순수 규칙 단위 테스트로만 확인했다. 엔진 판에서 정확히 동점을 만드는 fixture는 만들지 않았다.
  - 양보 후 상위 장수가 못 쓰는 경우는 이음새로만 만들었다. 실측에서는 0회였다.
  - 플래그 on의 3D 표시는 M4-c2 전이라 보지 않았다.
  - 사람이 직접 한 플레이는 없다. 모든 증거는 엔진 실행 로그다.
