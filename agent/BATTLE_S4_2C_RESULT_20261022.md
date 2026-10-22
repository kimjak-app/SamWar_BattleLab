# BATTLE S4-2c 결과 — 적 특기 분배: 감점 → 돌려쓰기 (2026-10-22)

- 작업 ID: S4-2c Enemy Skill Rotation (엔진 단계 S)
- 지시문 `S4_2C_ROTATION_RULE_20261022.md`, 설계서 `DESIGN_S4_AI_LEVEL_AND_BATTLE_SETUP_20261022.md` §2 (클코치)
- 브랜치 `feature/engine-s4-2c-skill-rotation-20261022` ← `origin/integration/p1-engine-core-20261019`(기준 `b83a402` 확인)
- 커밋 1개 `feat(battle): replace the enemy skill spread penalty with a rotation order (S4-2c)`. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- 합격 판정은 하지 않는다(검수: 클코치).
- **멈춤 규칙에 걸리지 않았다**:
  - 설계와 다른 사실 없음, 새 난수 없음
  - 분배 골든 `battle_enemy_skill_spread_base_v0.json` 불변(플래그 false 동등성 그대로 통과)
  - 기존 테스트 수정은 분배 전용 2개뿐(§5)
- **측정 결과(§3)**: 설계서 기대 효과를 **만족했다**. BEFORE(S4-2b 감점 규칙)보다 장수별 최대값 5 → 4, 0회 장수 1 → 0.
  - 다만 플래그 off(하 등급)의 최대값 3보다는 크다.
  - 적 특기 총 횟수(7)와 라운드 8 패배는 그대로다(§3 해석).

---

## 0. 사전 확인 4개

1. **현재 서비스 입력과 호출부**
   - 서비스: `ranks_ahead(a, b)`와 `should_yield_unique_skill(actor, others, momentum)`
     - 항목 = `{unit_id, raw, adjusted, last_use_round, order, cost}`
     - `adjusted`는 `adjusted_skill_score(raw, round, last_use)` = 원점수 − 감점(40/20)
   - 호출부(`battle_web_import_test.gd`):
     - `_should_enemy_yield_unique_skill`(L4514~): 후보 수집과 서비스 호출
     - `_get_enemy_skill_spread_entry`(L4547~): 항목 만들기
     - `_try_auto_unique_skill_for_actor`: 위 함수를 부르는 줄 1개, 이력 기록 1줄. 둘 다 S4-2b에서 이미 있었고 이번에 바꾸지 않음
2. **사용 이력**
   - `enemy_skill_last_use_round[unit_id] = battle_round`
   - 기록 시점: `_record_enemy_unique_skill_use`. `_try_auto_unique_skill_for_actor`에서 `enemy_action_event_log.record_skill` 직후 = 특기를 쓰기로 정한 순간이고, 시전(미리보기·연출) 전이다.
   - 적·플래그 on일 때만 기록한다.
   - "한 번도 안 씀"은 **키 없음**이다. 항목에서는 `NO_USE_ROUND = -1`로 바뀌어 어떤 라운드(≥1)보다 오래된 값이 된다.
   - 이번에 바꾸지 않았다.
3. **후보 계산 시점**
   - 적 행동자마다 그 행동자의 특기 판단 때(계획 전 고가치, 이동 후 고가치·대체) 다시 모은다.
   - 후보 = 행동 순서 목록(`enemy_unit_state` → 지원 → 주력3 → 증원1 → 증원2) 중 배치·생존, 미행동, `_can_actor_use_unique_skill`(기세가 자기 비용 이상, 쿨다운 0, 유효 대상 있음)인 장수
   - 앞선 장수가 특기를 쓰면 공용 기세가 줄고 그 장수는 행동 완료가 된다. 그래서 다음 판단에서는 후보 수·감당 여부가 그 시점 값으로 다시 계산된다(미리 정해 둔 순서가 아님).
   - 같은 라운드 안에서 이동 후 판단이 한 번 더 나오면 같은 장수가 두 번 판정될 수 있다(실측: zhang_fei 라운드 3에 2번).
4. **BEFORE 재측정**: `b83a402` 워크트리, S4-2 보고서와 같은 조건(기본 배치, 아군 엔진 자동 행동, 라운드 10까지, 시드 1~6). 결과가 S4-2 보고서와 **완전히 같다**(§3 표).

## 1. 변경

| 파일 | 변경 | 내용 |
|---|---|---|
| `scripts/battle/services/battle_enemy_tactic_rules_service.gd` | +22 −31 | 감점 상수 2개(40/20), `recent_use_penalty`, `adjusted_skill_score` **제거**. `ranks_ahead`와 `should_yield_unique_skill`을 설계서 §2로 다시 씀. 책략 규칙 3개는 바이트 그대로 |
| `scripts/battle_web_import_test.gd` | +5 −6 | 호출부 최소 수정: 항목에서 `adjusted` 줄 삭제, 판정 출력 줄의 `adjusted` → `last`, 함수 머리 주석. 플래그·이력·후보 수집·적 전용 가드는 그대로 |
| `tests/scripts/test_battle_enemy_skill_spread_behavior.gd` | 다시 씀 | 분배 전용 테스트(허용) |
| `tests/scripts/test_battle_enemy_tactic_rules_service.gd` | 분배 부분만 다시 씀 | §5 결정 참조 |
| `tests/scripts/support/battle_enemy_skill_rotation_harness.gd` | 신규 | S4-2 하니스를 확장(기존 하니스 수정 없음) |
| `tools/validate_battle_skill_rotation_s4_2c.py` | 신규 | BASE `b83a402`, TIP 기본 `HEAD`(`S4_2C_SCOPE_TIP`) |
| `.github/workflows/verify-c-track.yml` | +1 | 새 validator |
| `agent/BATTLE_S4_2C_RESULT_20261022.md` | 신규 | 이 보고서 |

**새 규칙**(서비스, 순수, 상태·난수·await 없음):

```
ranks_ahead(a, b):  마지막 사용 오래된 쪽(-1 = 한 번도 안 씀이 가장 앞) → 원점수 높은 쪽 → 기존 행동 순서
should_yield_unique_skill(actor, others, momentum):
    후보 = [actor] + (others 중 원점수 >= 130)
    후보 < 2  → 양보 없음
    후보 비용 합 <= 공용 기세 → 양보 없음 (전부 낼 수 있음)
    actor보다 앞서는 후보가 있으면 → 양보 (정렬 1위만 씀)
```

양보한 장수는 기존대로 특기 없이 계획(이동·공격·대기)으로 진행한다. 판정 함수가 false를 돌려주면 `_try_auto_unique_skill_for_actor`가 false를 반환하고, AI가 다음 단계로 간다(이 줄은 S4-2b 그대로).

## 2. 테스트

| 테스트 | 내용 | checks |
|---|---|---|
| `test_battle_enemy_skill_spread_base_parity` (기존, 수정 없음) | 플래그 off, 분배 시나리오 7개 == BASE 골든(골든 불변) | 11 |
| `test_battle_enemy_skill_spread_behavior` (다시 씀) | 플래그 on, 12시나리오. 아래 표 참조 | 59 |
| `test_battle_enemy_tactic_rules_service` (분배 부분 다시 씀) | 아래 "순수 규칙 테스트" 참조 | 29 |

**`test_battle_enemy_skill_spread_behavior` 12시나리오**:

| 시나리오 | 확인 내용 |
|---|---|
| SP01 | 후보 1명: BASE와 같음 |
| SP02 | 기세 1명분, 둘 다 안 씀 → 원점수 높은 xiahou_dun이 쓰고 guan_yu는 양보 후 공격(계획 진행) |
| SP03 | 기세 충분: 양보 없음, 둘 다 사용, 이력 기록(BASE와 같음) |
| SP04 | 지난 라운드에 쓴 guan_yu가 한 번도 안 쓴 zhang_fei에게 양보 |
| SP05 | 둘 다 안 씀 → 원점수(guan_yu) 우선(BASE와 같음) |
| SP06 | 두 라운드 전 사용 → 안 쓴 zhang_fei 우선. **S4-2b와 결과가 바뀐 케이스**(감점 20으로는 guan_yu가 앞섰음) |
| SP07 | 양보 후 상위 장수가 못 씀 → 기세 유지 |
| RT01 | 마지막 사용 동률 → 원점수 |
| RT02 | 후보 3명 + 기세 1명분 → 한 번도 안 쓴 장수 |
| RT03 | §6 ②: 이미 행동한 적(안 씀, 341)은 후보 아님 |
| RT04 | §6 ③: 원점수 75(< 130, 안 씀)는 후보 아님 |
| RT05 | §6 ①: 아군 전자동 불변 |

모든 판정에서 난수 소비 0.

**순수 규칙 테스트**:
- 정렬 4경우: 안 씀 > 사용, 오래된 사용 > 최근, 동률 → 원점수, 다시 동률 → 순서
- 양보 9경우: 기세 부족·충분, 1위는 양보 안 함, 임계 129/130, 원점수가 훨씬 높아도 최근 사용이면 양보, 후보 없음, 3명 전부 감당·부족
- **연속 3라운드 시뮬레이션**(후보 3명, 기세 1명분) → 서로 다른 3명
- 결정성
- 책략 규칙 검사(S4-2a)는 그대로

- "원점수도 동률 시 행동 순서"는 엔진 판에서 원점수가 정확히 같은 두 장수를 만들 수 없어 순수 규칙 테스트로만 확인했다.
- RT05 fixture: 아군 시전자에게 "지난 사용 라운드 1"을 fixture로 넣었다. 적 전용 가드가 있으면 무시된다. 가드가 빠지면 안 쓴 xiahou_dun이 앞서 아군이 양보한다. 처음 fixture(이력 없음)에서는 아군 원점수가 더 높아 이 변조를 못 잡았다(§4 1차 P5). 그래서 보강했다.
- 기존 S4-2 테스트(BASE 동등성 17+6판, 아군 경로 동등성 49, 적 책략 행동)는 수정 없이 통과한다(§6 CI).

## 3. 분배 측정 (게이트가 아니라 보고, 설계서 기대 효과 확인)

- 조건: 기본 배치, 라운드 10까지(또는 승패), 엔진 자동 행동 측정 스크립트(`evidence/s42c_measure/_tmp_s42_measure.gd`, 커밋 안 함)
- BEFORE는 `b83a402` 워크트리에서 돌렸다. AFTER는 이 브랜치에서 `enemy_skill_spread_enabled = true`로 돌렸다.
- 원문: zip `evidence/s42c_measure/`

**아군 전자동(시드 1~6, 6개 시드 결과가 모두 같음)**:

| 구성 | 라운드별 적 특기 | zhang_fei | guan_yu | xiahou_dun | 최대값 | 0회 장수 | 결과 |
|---|---|---|---|---|---|---|---|
| 플래그 off(하 등급) | 2 장 / 3 관 / 4·5·6 하후 | 1 | 1 | 3 | 3 | 0 | 라운드 11 진입 |
| BEFORE: S4-2b 감점 | 2 장 / 3 하후 / 4 장 / 5·6·7·8 하후 | 2 | 0 | 5 | **5** | **1** | 라운드 8 패배 |
| **AFTER: S4-2c 돌려쓰기** | 2 장 / 3 하후 / 4 장 / **5 관** / 6·7·8 하후 | 2 | 1 | 4 | **4** | **0** | 라운드 8 패배 |

**아군 대기만(시드 1·2, 2개 시드가 같음)**:

| 구성 | 라운드별 적 특기 | 결과 |
|---|---|---|
| 플래그 off | 3 하후 / 4 관·하후 / 5 관 / 6 관·하후 | 라운드 6 패배 |
| S4-2b 감점 | 3 하후 / 4 관·하후 / 5 관 / 7 관 | 라운드 7 패배 |
| S4-2c 돌려쓰기 | 감점과 같음 | 라운드 7 패배 |

**결론(기대 효과 확인)**: 설계서 §2의 기준인 BEFORE(5회)보다 최대값이 줄고(5 → 4), 0회 장수가 줄었다(1 → 0). **만족**한다.

**해석(판정 아님)**:
- 돌려쓰기는 양보가 생기는 라운드(3·5·6)에서만 작동한다. 라운드 3에서는 안 쓴 xiahou_dun이 우선이었고(그 전에 zhang_fei가 라운드 2에 씀), 라운드 5에서는 guan_yu가 처음으로 썼다.
- 라운드 7·8에는 고가치 후보가 xiahou_dun 하나뿐이라 양보 조건(후보 2명 이상)이 성립하지 않는다. 그래서 같은 장수가 연속으로 쓴다. 돌려쓰기 규칙의 범위 밖이다.
- 적 특기 총 횟수는 7회로 감점 규칙과 같다. 플래그 off의 5회보다 많다. 전체 기세 사용량은 분배가 아니라 "양보 후 남은 기세를 다음 장수가 씀"에서 나온다. 라운드 8 패배도 그대로다.
- 아군 대기만 조건에서는 양보 상황이 감점 규칙과 같은 결과를 냈다(후보 구성이 단순함).
- 상 등급 계획형(S4-4)이 다룰 영역이다.

## 4. 변조 프로브 (새로 돌린 것, 11개)

- 방식: 서비스·컨트롤러에 변조를 1개씩 적용하고 S4-2c validator, S4-2 validator, 해당 Godot 테스트를 돌린 뒤 원래 바이트로 복원했다(`cmp` 확인).
- 러너: zip `evidence/run_s42c_probes.py`. 결과: 1차 `evidence/s42c_probes_run1/`, 최종 `evidence/s42c_probes_final/`

| 지시문 예 / §6 | 프로브 | S4-2c validator | Godot 테스트 |
|---|---|---|---|
| 정렬 방향 반전 | P1 | exit 1 | exit 1 (SP04, 규칙) |
| "한 번도 안 씀"을 가장 최근으로 | P2 (`NO_USE_ROUND` = 99999) | exit 1 | exit 1 (SP04, 규칙) |
| 동률 규칙 제거 | P3 (원점수 비교 삭제) | exit 1 | exit 1 (SP02, 규칙) |
| 사용 이력 미갱신 | P4 | exit 1 | exit 1 (SP03 이력) |
| 아군에도 적용 (§6 ①) | P5 (진영 가드 삭제) | exit 1 | exit 1 (RT05) * |
| 난수 사용 | P6 | exit 1 | exit 1 (SP02 난수 검사) |
| 양보 후 계획 진행 안 함 | P7 (양보 시 행동 완료 처리) | exit 1 | exit 1 (SP02) |
| 기세 충분해도 양보 | P8 (전부 감당 검사 삭제) | exit 1 | exit 1 (SP03, 규칙) |
| 이미 행동한 적이 후보로 (§6 ②) | P9 (후보 필터 = 자기 자신만 제외) | exit 1 | exit 1 (RT03) |
| 〃 행동 여부 검사만 삭제 | P9b | exit 1 | **exit 0(못 잡음)** ** |
| 고가치 임계 낮춤 (§6 ③) | P10 (130 → 70) | exit 1 | exit 1 (RT04, 규칙) |

- S4-2 validator(TIP `04ce32d` 고정)는 모든 프로브에서 exit 0이다. 고정 범위를 검사하므로 이 브랜치 변경과 무관하다(지시문 "이 커밋 후에도 통과").
- \* P5는 **1차 실행에서 테스트가 못 잡았다**. 이력 없는 RT05에서는 아군 원점수가 xiahou_dun보다 높아 가드가 없어도 아군이 1위였다. 아군에게 지난 사용 기록을 fixture로 넣어 보강한 뒤 최종 실행에서 잡혔다.
- \*\* P9b(분배 후보 필터에서 `_has_enemy_unit_acted`만 삭제)는 **동작이 같다**. 같은 필터의 `_can_actor_use_unique_skill`이 적의 행동 완료를 이미 거른다. 그래서 어떤 테스트로도 잡을 수 없고 validator만 잡는다.
  - S4-2 검수에서 "이미 행동한 적이 후보에 들어감" 변형이 못 잡힌 이유도 같은 구조로 보인다.
  - 실제로 행동한 적이 후보에 들어가는 변조(P9)는 RT03이 잡는다.
- 대조군: 두 validator, SP02, RT05, 규칙 테스트 모두 exit 0.

## 5. 결정 사항

| 항목 | 결정 | 이유 |
|---|---|---|
| 판단하는 장수 자신 | 원점수와 무관하게 후보에 넣음(다른 장수만 ≥130 조건) | 그 장수는 이미 가치 검사(고가치 ≥130 또는 이동 후 대체 ≥70)를 통과해 쓰려는 참이다. S4-2b와 같은 범위 |
| "전부 못 내면" | 후보 비용 합 > 공용 기세 | 설계서 문구 그대로. S4-2b는 둘씩 비교했다 |
| 비용 | `_get_effective_unique_skill_cost`(기존) | 변경 없음 |
| 순수 규칙 테스트 파일 수정 | 분배 부분만 다시 씀(책략 부분은 바이트 그대로) | 지울 함수(`recent_use_penalty`, `adjusted_skill_score`)를 직접 부르고 있어 그대로 두면 컴파일이 안 된다. 분배 전용 내용이라 "분배 전용 테스트" 예외로 봤다 |
| 새 시나리오 위치 | 새 하니스 파일(기존 S4-2 하니스 수정 없음). 플래그 on 테스트에서만 사용 | 분배 골든(SP01~07)을 바꾸지 않기 위해 |
| S4-2 validator | 수정하지 않음 | TIP 고정 모드라 이 변경 뒤에도 통과(CI 확인) |
| 아군 대기 측정 | 시드 2개만 | 규칙 난수가 없어 시드가 결과를 바꾸지 않음(전자동 6시드로 확인) |
| 판정 출력 줄 | `adjusted` 대신 `last`(마지막 사용 라운드) | 측정 근거 |

## 6. 전체 CI 로컬 재현 (새로 돌린 것, 1회)

- 최종 코드(커밋 직전 작업 트리, 보고서만 자리표시) 기준. 순서: `.godot` 삭제 → `--headless --editor --import`(**1회 만에 exit 0, 65초, signal 11 없음**) → `verify-c-track.yml` 목록 그대로 실행(러너 `run_ci.py`).
- **160단계 모두 exit 0**(합계 약 2,090초):
  - validator **42** = 기준 41 + S4-2c 1
  - Godot 테스트 **113**: 개수는 그대로다. 분배 테스트 2개는 기존 파일을 다시 쓴 것이고 새 파일이 아니다.
  - 씬 로드 3개, `--editor --quit-after 2`, `git diff --check`
- 분배 관련 시간·결과:
  - S4-2 validator(고정) exit 0, 28.6초
  - 분배 BASE 동등성(골든 불변) 25.9초
  - 돌려쓰기 행동 53.4초, 순수 규칙 0.5초
- 가장 긴 파일은 기존 `test_battle3d_skill_equivalence_shard_1`(69.5초)이다.
- 그 밖의 기존 테스트(S4-2 BASE 동등성·아군 경로 동등성·적 책략 행동 포함)는 수정 없이 통과했다.
- 실행 후 `git status`에는 이번 변경 파일만 있었다. 원문: zip `evidence/s42c_ci_full_run/`.

## 7. 남은 것

- 고가치 후보가 1명뿐인 라운드의 독점(라운드 7·8 xiahou_dun)은 돌려쓰기 범위 밖이다(S4-4 계획형).
- 적 특기 총 횟수·패배 시점은 감점 규칙과 같다.
- 등급 `enemy_ai_level`과 시작 설정 입구는 S4-3이다(플래그 기본값 false 유지).
- P9b는 동작이 같은 변조라 테스트로 못 잡는다(validator만).
- 사람이 직접 한 플레이는 없다(엔진 실행 로그만).
