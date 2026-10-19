# S2-2 공격 상태·이벤트 분리 결과

기준: `3269385529f16bc8e77ce299ad05c53e022c4a11`
브랜치: `refactor/s2-2-attack-state-events-20261019`
권한: 사용자 직접 승인으로 Codex가 세부 설계 및 구현. **로컬 커밋만, push/merge 없음.**
검증: **Level 2 범위 회귀**. 전체 프로젝트 Full Green 또는 클코치 독립 검수 완료를 뜻하지 않는다.

## 구현과 전체 진행 위치

M2 준비 단계 S2-2를 구현했다. 3D 화면의 플레이 범위는 기존 선택·이동·방향·취소와 동일하며, **3D 공격 명령/UI는 아직 연결하지 않았다.** 다음은 M2-3D, 그 뒤 M3 적 AI·턴 연결이다. 월드맵 왕복은 여전히 M7이다.

- `BattleAttackStateService`: 기존 피해 적용과 공격 metadata/총병 penalty/공격 후 이동 flag 쓰기 분리. 총병 로그 사이의 쓰기 순서도 유지하도록 함수 분할.
- 컨트롤러의 변경 함수는 `play_basic_attack_demo`, `_finish_basic_attack_demo`, `_commit_basic_attack_unit_contract`, `_cleanup_dead_units` 네 개뿐. 새 서비스/로그 멤버 두 개 추가.
- 피해 공식·입력 게이트·모멘텀·action lock·상태 tick·Tween·적 자동 행동·사망 처리의 기존 순서와 소유권 유지. 공용 공격 contract의 적 측 호출도 같은 서비스를 사용하지만 적 공격 이벤트는 아직 없다.
- `battle_action_event_log`에 세 종류 추가. 기존 이동 로그와 독립된 sequence이며 상태의 두 번째 원장이나 signal/callback을 만들지 않는다.
- 기존 16사례 오라클을 CI에서 8+8로 나눔. 각 사례 두 번 실행과 기존 골든 비교는 유지. 기존 전체 runner도 계속 호출 가능. 신규 서비스·이벤트 테스트와 validator를 CI에 추가. 기존 다른 호출은 보존.

## 쓰기·이벤트 발생 시점

| 시점 | 기존 상태 쓰기 | 추가 관찰 이벤트 |
|---|---|---|
| 요청, `resolving` | HP/병력 감소 → attacked flag/last_action → 총병 penalty/후속 이동 flag → 조건부 모멘텀 | `attack_resolved`, 위 쓰기 후 target visual 갱신 전 |
| 실제 Tween 완료 | 기존 pending clear → auto flag clear → mark ally acted(잠금·has_acted·has_moved·상태 소모) | `action_completed`, mark 직후 |
| 기존 사망 정리 | 최초 dead ID 등록 → action lock 삭제 | `unit_defeated`, 기존 전멸 로그 전 |
| 이후 | 기존 승패 guard → 적 phase → 자동 적 행동 → 다음 아군 | 적 공격/action 이벤트 추가 없음. 공용 사망 정리 이벤트는 원인에 관계없이 나올 수 있음 |

`_clear_pending_move_snapshot()`은 `_finish_basic_attack_demo`의 원래 컨트롤러 위치에서 정확히 한 번 호출한다. A6b의 호출 관찰 단언도 그대로다. A7a의 아군 직접 호출 허용과 A7b의 입력 후보 제외를 수정하지 않았다.

`damage_applied`는 `BattleUnitState.apply_damage`의 HP 제한 반환값이며 병력 감소량을 별도로 재계산하지 않는다. `killed`는 피해 직후의 생존 상태, `unit_defeated`는 완료/사망 정리 시점이다.

## 검증 결과

- Godot 4.6.2 실제 프로세스로 import와 headless 테스트 실행.
- 공격 골든: **16사례 × 2회**, shard 1 **128 checks / 41.38초**, shard 2 **106 checks / 32.32초**, 모두 exit 0. 각 runner의 골든 존재/비교 검사 때문에 단일 실행의 232보다 총 checks가 2 늘었다. 사례 누락·중복 없음.
- 신규 서비스/schema: **70 checks**, exit 0.
- 신규 실제 이벤트/상태 parity: **16사례, 213 checks / 37.02초**, exit 0. 요청/연출 중/완료/적 행동 전후를 기존 골든과 대조. 기존 callback을 직접 호출하거나 Tween을 우회하지 않았다.
- 마지막 변경은 이벤트 테스트의 잘못된 `--case` 거절 보강뿐. A6b 정상 선택 재검증 **25 checks**, exit 0; 잘못된 사례는 예상한 exit 1. 기존 16사례 기본 선택 로직/생산 코드/골든은 이 보강으로 바뀌지 않았다.
- 기존 이동 골든 **283 checks**, 실제 이동 이벤트 **117 checks**, 3D 이동 통합 **144 checks** 통과. 인접 전투 계산·잠금·AI 예약·턴 회귀 포함 **Godot 테스트 16개** 통과.
- 기존/신규 정적 validator **20개** 통과. 새 validator는 네 함수 외 코드 불변과 기존 호출/쓰기 순서, 기존 골든/하니스 불변, 정확한 CI shard 구성을 검사한다.
- 전체 월드맵 Godot 회귀, Linux, 원격 CI는 이번에 실행하지 않았다. push하지 않아 원격 CI 결과도 없다.

## 보존된 기준 파일 SHA-256

- `tests/golden/battle_attack_baseline_v0.json`: `d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c` — 기준 커밋과 바이트 동일.
- `tests/golden/battle_move_baseline_v0.json`: `b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd` — 기준 커밋과 바이트 동일.
- `tests/scripts/support/battle_attack_oracle_harness.gd`: `d688d033f98d1f172f27270870ab13cd1d330a7333f92b8382aafdaeb253e5f6` — 기준 커밋과 바이트 동일.

## 변조 검증 원문

기존 검증용 복사본을 재사용해 용량 큰 새 프로젝트 사본을 만들지 않았다. 정상 대조군 A6b가 먼저 exit 0인 것을 확인한 뒤 한 번에 한 변조만 적용했다. 모든 변경 파일은 finally에서 원래 바이트로 복구. **9종 모두 exit 1이고 parse/compile 오류 없이 단언 실패로 검출**했다.

### damage_plus_one (A1)

exit=1, 5.06초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A1 unchanged authoritative golden
[ATTACK_ORACLE] FAIL A1 request event values and count
[ATTACK_ORACLE] FAIL A1 no completion before tween finishes
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: finished_before_enemy
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: finished_after_enemy_start
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: after_enemy_callback
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: after_enemy_slot
```

### distance_zero (A6b)

exit=1, 5.28초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A6b move distance preserved
[ATTACK_ORACLE] FAIL A6b unchanged authoritative golden
```

### cleanup_removed (A6b)

exit=1, 5.64초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A6b pending cleanup observed at attack finish before enemy
[ATTACK_ORACLE] FAIL A6b attack finish preserves pending cleanup call
[ATTACK_ORACLE] FAIL A6b unchanged authoritative golden
```

### cleanup_duplicate (A6b)

exit=1, 5.51초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A6b pending cleanup observed at attack finish before enemy
[ATTACK_ORACLE] FAIL A6b attack finish preserves pending cleanup call
[ATTACK_ORACLE] FAIL A6b unchanged authoritative golden
```

### attack_event_missing (A1)

exit=1, 5.38초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A1 request event values and count
[ATTACK_ORACLE] FAIL A1 no completion before tween finishes
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: finished_before_enemy
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: finished_after_enemy_start
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: after_enemy_callback
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: after_enemy_slot
```

### attack_event_duplicate (A10)

exit=1, 5.14초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A10 request event values and count
[ATTACK_ORACLE] FAIL A10 no completion before tween finishes
[ATTACK_ORACLE] FAIL duplicate input emits no duplicate event
[ATTACK_ORACLE] FAIL A10 completion/death exactly once before enemy: finished_before_enemy
[ATTACK_ORACLE] FAIL A10 completion/death exactly once before enemy: finished_after_enemy_start
[ATTACK_ORACLE] FAIL A10 completion/death exactly once before enemy: after_enemy_callback
[ATTACK_ORACLE] FAIL A10 completion/death exactly once before enemy: after_enemy_slot
```

### completion_early (A1)

exit=1, 5.07초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A1 request event values and count
[ATTACK_ORACLE] FAIL A1 no completion before tween finishes
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: finished_before_enemy
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: finished_after_enemy_start
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: after_enemy_callback
[ATTACK_ORACLE] FAIL A1 completion/death exactly once before enemy: after_enemy_slot
```

### death_event_missing (A9)

exit=1, 5.2초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A9 completion/death exactly once before enemy: finished_before_enemy
[ATTACK_ORACLE] FAIL A9 completion/death exactly once before enemy: finished_after_enemy_start
[ATTACK_ORACLE] FAIL A9 completion/death exactly once before enemy: after_enemy_callback
[ATTACK_ORACLE] FAIL A9 completion/death exactly once before enemy: after_enemy_slot
```

### gunner_penalty_41 (A4)

exit=1, 5.83초, parse_error=False
```text
[ATTACK_ORACLE] FAIL A4 unchanged authoritative golden
```

## 진단·제한 사항

- 일부 Windows console 실행 시 **프로그램 시작 단계 signal 11 / exit 3221225477**이 총 5회 발생했다. GDScript 진단이나 테스트 출력 이전이며 원인은 확정하지 못했다. 실패 실행 기록과 최초 crash 원문을 보존했다. 변경 전 복사본, 새 로그만 적용한 복사본, 새 controller/service까지 적용한 복사본의 이동 오라클은 모두 통과했다. 생산 코드를 바꾸지 않고 일반 Godot 실행 파일과 stdout/stderr 개별 수집으로 실행한 실제 작업 트리의 이동/3D/주변 회귀는 모두 통과했다. 실행 파일 문제로 단정하지 않는다.
- 기존 이동/컨트롤러 기반 테스트 일부에서 종료 시 `ObjectDB instances leaked` / `2 resources still in use` 경고가 남는다. 변경 전 복사본 이동 테스트에서도 동일 경고를 확인했다. 이번에 기존 teardown/생산 수명 코드를 수정하지 않았다.
- import에서 기존 `_incoming`/Battle_Land/Production_Test 씬 간 중복 UID 경고가 있었다. 관련 씬은 수정하지 않았다.
- 신규 테스트 초기의 GDScript 타입 추론 오류는 명시 bool로 수정. 별도 테스트 기대값의 기병 후속 이동을 실제 병종 계약(궁기병만 2칸)과 대조해 정정했다. 생산 규칙을 바꾼 것이 아니다.
- 실제 Godot 창에서 마우스로 공격하는 검증/캡처는 이번 S2-2에 수행하지 않았다. 이번은 상태/이벤트 경계 검증이며 3D 공격 UI와 사용자 조작 증거는 M2-3D에서 수행한다.
- `battle_action_event_log`와 이동 로그는 별도 sequence. 미래 소비자가 전역 순서로 섞어 해석하면 안 된다. 새 씬에서는 초기화되지만 현재 resume 저장 형식에는 이벤트 로그를 넣지 않았다.
- 새 서비스 자체는 유효한 non-null 유닛을 받는 내부 쓰기 경계다. 대상/phase 검증은 기존 컨트롤러 그대로이며 3D 입력은 M2-3D에서 적 진영 후보만 전달해야 한다.

## 실행 목록

기본 형태: `godot --headless --path . --script res://tests/scripts/<파일>.gd`, `python tools/<validator>.py`. 원문 및 실행 환경 경로는 외부 검수 ZIP의 로그/runner에 있다.

| 검사 | exit | 초 |
|---|---:|---:|
| `test_battle_attack_state_service` | 0 | 0.61 |
| `test_battle_attack_event_parity` | 0 | 37.02 |
| `test_battle_attack_oracle_shard_1` | 0 | 41.38 |
| `test_battle_attack_oracle_shard_2` | 0 | 32.32 |
| `test_battle_move_oracle_baseline` | 0 | 21.95 |
| `test_battle_ally_move_event_parity` | 0 | 8.02 |
| `test_battle_ally_move_state_service` | 0 | 0.52 |
| `test_battle_damage_formula_service` | 0 | 3.62 |
| `test_battle3d_engine_move_integration` | 0 | 8.23 |
| `test_battle_event_log_service` | 0 | 0.5 |
| `test_battle_state_fingerprint_service` | 0 | 0.5 |
| `test_battle_combat_query_service` | 0 | 3.98 |
| `test_battle_action_lock_state_service` | 0 | 3.79 |
| `test_battle_enemy_ai_reservation_state_service` | 0 | 3.84 |
| `alternating_battle_action_order_test` | 0 | 0.41 |
| `test_single_side_exhaustion_turn_order` | 0 | 3.62 |
| `validate_worldmap_battle_settlement_applier_extraction` | 0 | 0.24 |
| `validate_worldmap_t03_strategic_battle_transaction_extraction` | 0 | 0.25 |
| `validate_worldmap_t03_battle_presentation_extraction` | 0 | 0.64 |
| `validate_worldmap_to_battle_input_lifecycle` | 0 | 0.12 |
| `validate_b0b_battle_production_skeleton` | 0 | 0.13 |
| `validate_b0c_battle_iso_promotion` | 0 | 0.17 |
| `validate_b1b_battle_movement_query_service` | 0 | 0.3 |
| `validate_b1c_battle_combat_query_service` | 0 | 0.24 |
| `validate_b1d_battle_damage_formula_service` | 0 | 0.28 |
| `validate_b1e_battle_action_lock_state_service` | 0 | 0.39 |
| `validate_b1f_battle_enemy_ai_reservation_state_service` | 0 | 0.25 |
| `validate_b1g_battle_unique_skill_cooldown_state_service` | 0 | 0.23 |
| `validate_battle_s1_1_observation_baseline` | 0 | 1.0 |
| `validate_battle_s2_1_attack_baseline` | 0 | 0.84 |
| `validate_battle_s2_2_attack_state_service` | 0 | 1.07 |
| `validate_battle_s1_2_ally_move_state_service` | 0 | 1.68 |
| `validate_battle3d_m1b_engine_move` | 0 | 0.7 |
| `validate_battle3d_contract` | 0 | 0.13 |
| `validate_alternating_battle_action_order` | 0 | 0.14 |
| `validate_single_side_exhaustion_turn_order` | 0 | 0.14 |

## 검수 권장

이번 변경은 **클코치 독립 검수를 권장**한다. 특히 요청/완료 시점 보존, 공용 공격 helper의 적 측 호출, 사망 이벤트의 공용 범위, A6b 정리 호출, 두 CI shard의 전체 커버리지를 확인하면 된다. 구현자가 수행한 변조 검증은 독립 검수를 대체했다고 주장하지 않는다.

검수 통과 후 M2-3D에서 공격 입력·범위·피해 표시·적 행동 결과 동기·배치 가시성을 연결한다. push는 브랜치명 지정 승인이 있을 때만 수행한다.
