# S1-2 아군 이동 상태 분리 결과

## 전체 설계에서의 위치

- 승인된 설계: EASTWAR 3D 통합 v1.0, M0~M6 독립 진입점 한 판 완주. 월드맵 왕복은 M7 별도 승인.
- 이번 단계: **M1-a / S1-2**. 기존 아군 이동 상태 연산과 이벤트 출처를 분리했다. 아직 3D에서 엔진 이동을 실행하는 M1-b는 구현하지 않았다.
- 기준: `integration/p1-engine-core-20261019` @ `bc2c433b698ed261410b2754c6d500256ea83f2e` (fetch로 확인).
- 작업 브랜치: `refactor/s1-2-ally-move-state-20261019`. push/merge 없음. Production 경로 수정 없음.
- 구현과 검증기 TIP 고정/최종 보고를 별도 로컬 커밋으로 남긴다. 최종 정확한 해시와 clean 상태는 검수 ZIP의 `evidence/FINAL_CLOSEOUT.txt`에 기록한다.

## 구현

`BattleAllyMoveStateService`는 무상태 RefCounted다. 유닛과 값만 받으며 콜백을 받지 않는다. 권장 apply_step_facing의 normalizer 인자 대신 이미 있는 순수 `BattleFormationFacingHelper`를 직접 사용한다. 이는 개정본의 Callable 금지와 기존 정규화 규칙을 함께 보존한다.

승인된 두 조정 사항:

1. 원래 좌표 쓰기 위치에서 apply_destination 호출, 중간 시각 갱신/로그 유지, 원래 has_moved/last_action 쓰기 위치에서 commit_move_metadata 호출. 좌표 중복 쓰기 없음.
2. 기존 마지막 Tween 콜백에 move_path.duplicate(true)를 네 번째 인자로 bind. 완료 함수의 기존 앞 세 인자는 그대로이며 마지막 인자는 기본값 []로 추가. 새 경로 멤버나 서비스 실행 컨텍스트 없음. 기존 3인자 직접 호출 시 메타데이터는 갱신하지만 경로를 꾸며 이벤트를 만들지 않는다; 실제 유일한 호출처는 항상 전체 경로를 전달한다.

기존 다섯 함수만 수정하고 아군 구간 방향 wrapper와 이벤트 기록 helper 두 개를 추가했다. 서비스/로그 멤버 두 개만 추가했다. 공용 facing 함수, 모든 적 이동/공격/턴/AI/이어하기 함수는 그대로다. 컨트롤러가 ally_has_moved 및 시각 스냅샷을 계속 소유한다.

이벤트 반환 형태는 `{events:[{kind,fields}, ...]}`. 단계 방향은 수평일 때만 적용하며 같은 방향이어도 기존 시각 갱신은 수행한다. 실제 변화가 없으면 step 이벤트는 추가하지 않는다. 방향 확정은 facing_changed/manual과 move_confirmed를 순서대로 반환한다. snapshot은 기존 논리 필드 다섯 개만 복사한다. rollback은 cell/has_moved/facing만 원래 순서로 복원하고 last_action을 복원하지 않는다. acted를 등록하지 않는다.

새 이벤트 parity 하니스는 기존 S1-1 하니스를 복사하고 최종 events 취득만 실제 컨트롤러 서비스 로그로 교체했다. 원래 하니스/테스트/골든은 모두 읽기 전용으로 유지했다. sequence만 제외하고 kind/schema/모든 필드를 비교한다.

## 컨트롤러 변경 함수와 줄 수

아래 +/-는 기준 대비 함수별 텍스트 차이이며 helper의 구분 빈 줄을 포함한다. 전체 diff도 ZIP에 제공한다.

| 함수 | 추가 | 삭제 | 내용 |
|---|---:|---:|---|
| play_basic_move_demo | 2 | 2 | 아군 step wrapper와 경로 복사 bind |
| _finish_basic_move_demo | 3 | 9 | 기본값 인자 추가, 두 위치 상태 위임 |
| _select_post_move_facing | 1 | 1 | 방향 확정 상태 위임 |
| _rollback_pending_ally_move | 7 | 3 | 기존 논리 스냅샷 값으로 복원 위임 |
| _store_pending_ally_move_snapshot | 5 | 4 | 값 스냅샷 생성 위임 |
| _record_ally_move_events (신규) | 5 | 0 | 기존 이벤트 로그 수집 |
| _apply_ally_move_step_facing (신규) | 9 | 0 | 상태 위임 후 기존 시각 호출 |

## 검증 결과

- 새 서비스 단위 테스트: **25 checks, 0 failures**.
- 수정하지 않은 S1-1 오라클: **283 checks, 0 failures**, 7사례 각각 2회, 골든 일치.
- 실제 서비스 이벤트 ↔ 골든: **117 checks, 0 failures**, M1/M2/M4/M5의 이벤트 수 4/4/2/4, 차이 없음.
- 새 validator: 범위/순수성/두 쓰기 위치/기존 앞 3인자/호출처 1개/적·공용 함수 불변/스키마 키/읽기 전용 하니스 조건 PASS. 런타임 이벤트 스키마의 정확한 필드 집합은 단위 테스트에서 기존 로그 서비스 수락 여부 및 이벤트 parity로 검증.
- 워크플로의 validator **28개**, Godot 스크립트 **57개**(배열 테스트 54개 + 인라인 씬 로드 3개), 프로젝트 parse 1개: **86개 모두 exit 0**, 명령당 timeout 120초, 전체 **262.94초**. 실제 로컬 Godot 4.6.2, Python 3.14. 원격 CI 미실행.
- 워크플로는 호출 세 줄 추가만 (+3/-0). 기존 호출 삭제/변경 없음.

오라클 골든 SHA-256은 기준과 동일:

```text
b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd
```

골든 파일, 원래 오라클 테스트, 원래 하니스는 git show 기준 바이트와 실제 파일 바이트를 직접 비교했다. 골든 갱신 옵션은 사용하지 않았다.

### 음성 프로브

별도 로컬 복사본에서만 변조했다. 원본 작업 브랜치에는 변조를 적용하지 않았다. 각 변조마다 수정되지 않은 오라클을 실행했다.

1. rollback에 초기 fixture last_action (`fixture_before_move`, sentinel 73) 복원 추가 → M4 실패, exit 1.
2. moved_distance를 path.size()-1로 대체 → M2 우회 사례 실패, exit 1.
3. 이동 시 has_acted=true 추가 → M1 실패, exit 1.

변조 전 대조군 및 복원 후 오라클은 exit 0. 구문 오류가 아니라 보존 동작 assertion으로 실패한 것을 확인했다. 전체 원문과 소요 시간은 아래 및 ZIP evidence에 제공한다.

### 실제 창 조작

Computer Use로 실제 Battle_Main 게임 창을 실행했다. 이순신 선택 → (3,8)에서 (3,7) 이동 → 방향 선택 화면 → 우클릭 취소로 (3,8) 복귀 → 같은 셀로 재이동 → 화면 방향 화살표 클릭으로 right 확정 및 명령 패널 복귀를 확인했다. 화면 캡처:

- `evidence/manual_facing_select.png`
- `evidence/manual_reverted.png`
- `evidence/manual_confirmed.png`

처음 창 크기 조정 직후 카메라 위치가 바뀌는 동안 범위 밖 셀을 한 번 클릭하여 이동 불가가 출력됐다. 이후 화면을 재확인하고 유효 셀을 선택했다. 테스트 게임 창만 종료했으며 기존 에디터는 유지했다. 이 확인은 Codex 조작 증거이고 김작 본인의 수동 확인을 대체하지 않는다.

## 진단과 미검증 사항

모든 명령은 exit 0이지만 경고 없는 전체 통과라고 보고하지 않는다. 일부 기존 테스트에 ObjectDB/리소스 종료 경고가 있다. 기준 컨트롤러로 별도 복사본에서 기존 이동 테스트를 재실행하여 동일한 2 resources 경고를 재현했고, city detail 테스트도 CanvasItem/ShapedTextData 잔류 경고를 동일하게 재현했다. 이 정리 코드는 범위 밖이므로 수정하지 않았다.

에디터 parse에서는 기존 씬 UID 중복 두 건과 quit-after 종료 시 Scan thread aborted 경고가 출력됐다. 스크립트 컴파일 오류는 없었다. 모든 진단은 원문에 남긴다.

S1-0 관찰 동작과 다른 결과는 없었다. 설계 차이는 착수 전에 발견해 확정받은 완료 쓰기 분리와 경로 전달 예외이며, 개정 지시서대로 반영했다.

미실행/대기: 원격 CI, 클코치 독립 임의 이동 20회 비교, 클코치 G0~G4 최종 검수, 김작 직접 수동 확인, M1-b 3D 명령 연결. 전체 설계의 M1 전체 완료 또는 M0~M6 완주를 주장하지 않는다.

## 검증기 범위 고정

자기 커밋 해시를 그 커밋 내용에 넣을 수 없으므로, 구현 checkpoint를 먼저 커밋하고 후속 커밋에서 validator의 기본 TIP을 그 해시로 고정한다. 기본 검사는 BASE..TIP의 경로와 해당 TIP의 소스를 검사한다. `S1_2_SCOPE_TIP=HEAD`는 현재 작업트리까지 포함한 라이브 검사다. 후속 S1 단계의 컨트롤러 변경은 기본 검사 범위에 들어오지 않는다.

## 재현 명령

```text
godot --headless --editor --path . --import
godot --headless --path . --script tests/scripts/test_battle_ally_move_state_service.gd
godot --headless --path . --script tests/scripts/test_battle_move_oracle_baseline.gd
godot --headless --path . --script tests/scripts/test_battle_ally_move_event_parity.gd
python tools/validate_battle_s1_2_ally_move_state_service.py
```

전체 회귀는 verify-c-track.yml의 모든 validator/테스트 배열을 추출해 실행하고 인라인 씬 로드 세 개도 동일 소스로 실행했다. 인라인 임시 스크립트는 checkout 밖 evidence에 저장했다. 모든 테스트에 120초 timeout을 적용했다.

## 전체 회귀 실행 목록

| 명령 | exit | 초 | 진단 줄 수 |
|---|---:|---:|---:|
| tools/validate_worldmap_main_integrity.py | 0 | 0.14 | 0 |
| tools/validate_worldmap_diplomacy_controller_extraction.py | 0 | 1.18 | 0 |
| tools/validate_worldmap_diplomacy_routing.py | 0 | 2.91 | 0 |
| tools/validate_worldmap_diplomacy_service_separation.py | 0 | 0.61 | 0 |
| tools/validate_worldmap_trade_routing.py | 0 | 0.51 | 0 |
| tools/validate_worldmap_trade_controller_extraction.py | 0 | 0.49 | 0 |
| tools/validate_worldmap_trade_phase2_extraction.py | 0 | 0.23 | 0 |
| tools/validate_worldmap_spy_routing.py | 0 | 0.71 | 0 |
| tools/validate_worldmap_spy_controller_extraction.py | 0 | 0.68 | 0 |
| tools/validate_worldmap_battle_settlement_applier_extraction.py | 0 | 0.24 | 0 |
| tools/validate_worldmap_t03_strategic_battle_transaction_extraction.py | 0 | 0.25 | 0 |
| tools/validate_worldmap_t03_battle_presentation_extraction.py | 0 | 0.63 | 0 |
| tools/validate_worldmap_player_attack_deployment_service_extraction.py | 0 | 0.76 | 0 |
| tools/validate_worldmap_wounded_recovery_service_extraction.py | 0 | 0.44 | 0 |
| tools/validate_worldmap_to_battle_input_lifecycle.py | 0 | 0.13 | 0 |
| tools/validate_b0b_battle_production_skeleton.py | 0 | 0.12 | 0 |
| tools/validate_b0c_battle_iso_promotion.py | 0 | 0.13 | 0 |
| tools/validate_b1b_battle_movement_query_service.py | 0 | 0.27 | 0 |
| tools/validate_b1c_battle_combat_query_service.py | 0 | 0.21 | 0 |
| tools/validate_b1d_battle_damage_formula_service.py | 0 | 0.2 | 0 |
| tools/validate_b1e_battle_action_lock_state_service.py | 0 | 0.34 | 0 |
| tools/validate_b1f_battle_enemy_ai_reservation_state_service.py | 0 | 0.25 | 0 |
| tools/validate_b1g_battle_unique_skill_cooldown_state_service.py | 0 | 0.22 | 0 |
| tools/validate_battle_s1_1_observation_baseline.py | 0 | 0.91 | 0 |
| tools/validate_battle_s1_2_ally_move_state_service.py | 0 | 0.8 | 0 |
| tools/validate_battle3d_contract.py | 0 | 0.12 | 0 |
| tools/validate_alternating_battle_action_order.py | 0 | 0.13 | 0 |
| tools/validate_single_side_exhaustion_turn_order.py | 0 | 0.13 | 0 |
| tests/scripts/test_worldmap_city_administration_service_extraction.gd | 0 | 0.44 | 0 |
| tests/scripts/test_worldmap_city_resource_service_extraction.gd | 0 | 0.54 | 0 |
| tests/scripts/test_worldmap_city_detail_presentation_extraction.gd | 0 | 0.53 | 3 |
| tests/scripts/test_worldmap_camera_controller_extraction.gd | 0 | 0.53 | 0 |
| tests/scripts/test_worldmap_hud_controller_extraction.gd | 0 | 0.53 | 0 |
| tests/scripts/test_worldmap_shared_ui_controller_extraction.gd | 0 | 0.53 | 0 |
| tests/scripts/test_world_calendar_service_extraction.gd | 0 | 0.54 | 0 |
| tests/scripts/test_world_turn_economy_service_extraction.gd | 0 | 0.54 | 0 |
| tests/scripts/test_world_turn_state_service_extraction.gd | 0 | 0.54 | 0 |
| tests/scripts/test_worldmap_turn_controller_extraction.gd | 0 | 0.53 | 0 |
| tests/scripts/test_battle_movement_query_service.gd | 0 | 3.88 | 2 |
| tests/scripts/test_battle_combat_query_service.gd | 0 | 3.89 | 2 |
| tests/scripts/test_battle_damage_formula_service.gd | 0 | 3.78 | 2 |
| tests/scripts/test_battle_action_lock_state_service.gd | 0 | 3.68 | 2 |
| tests/scripts/test_battle_enemy_ai_reservation_state_service.gd | 0 | 3.69 | 2 |
| tests/scripts/test_battle_unique_skill_cooldown_state_service.gd | 0 | 3.69 | 2 |
| tests/scripts/test_battle_event_log_service.gd | 0 | 0.55 | 0 |
| tests/scripts/test_battle_state_fingerprint_service.gd | 0 | 0.53 | 0 |
| tests/scripts/test_battle_move_oracle_baseline.gd | 0 | 21.4 | 2 |
| tests/scripts/test_battle_ally_move_state_service.gd | 0 | 0.83 | 0 |
| tests/scripts/test_battle_ally_move_event_parity.gd | 0 | 10.58 | 2 |
| tests/scripts/test_battle3d_movement_parity.gd | 0 | 2.02 | 0 |
| tests/scripts/test_battle3d_modes.gd | 0 | 0.82 | 0 |
| tests/scripts/test_battle3d_oblique_click.gd | 0 | 8.19 | 0 |
| tests/scripts/alternating_battle_action_order_test.gd | 0 | 0.56 | 0 |
| tests/scripts/test_single_side_exhaustion_turn_order.gd | 0 | 4.82 | 2 |
| tests/scripts/test_worldmap_domestic_tech_catalog_extraction.gd | 0 | 10.51 | 2 |
| tests/scripts/test_worldmap_domestic_tech_research_rules_extraction.gd | 0 | 0.55 | 0 |
| tests/scripts/test_worldmap_domestic_tech_research_service_extraction.gd | 0 | 1.02 | 0 |
| tests/scripts/test_worldmap_domestic_tech_effect_provider_extraction.gd | 0 | 0.66 | 0 |
| tests/scripts/test_worldmap_domestic_tech_tree_presentation_extraction.gd | 0 | 2.63 | 0 |
| tests/scripts/test_worldmap_domestic_tech_completion_presentation_extraction.gd | 0 | 1.26 | 0 |
| tests/scripts/test_worldmap_military_controller_extraction.gd | 0 | 6.23 | 2 |
| tests/scripts/test_worldmap_enemy_warfare_service_extraction.gd | 0 | 6.42 | 2 |
| tests/scripts/test_worldmap_battle_context_service_extraction.gd | 0 | 6.46 | 2 |
| tests/scripts/test_worldmap_battle_result_service_extraction.gd | 0 | 6.84 | 2 |
| tests/scripts/test_worldmap_battle_settlement_applier_extraction.gd | 0 | 0.56 | 0 |
| tests/scripts/test_worldmap_t03_strategic_battle_transaction_extraction.gd | 0 | 0.64 | 0 |
| tests/scripts/test_worldmap_t03_battle_presentation_extraction.gd | 0 | 0.65 | 0 |
| tests/scripts/test_worldmap_player_attack_deployment_service_extraction.gd | 0 | 0.55 | 0 |
| tests/scripts/test_worldmap_troop_rebalance_service_extraction.gd | 0 | 0.55 | 0 |
| tests/scripts/test_worldmap_wounded_recovery_service_extraction.gd | 0 | 0.55 | 0 |
| tests/scripts/test_worldmap_diplomacy_routing.gd | 0 | 21.42 | 2 |
| tests/scripts/test_worldmap_diplomacy_controller_extraction.gd | 0 | 1.02 | 0 |
| tests/scripts/test_worldmap_diplomacy_validation_extraction.gd | 0 | 5.76 | 2 |
| tests/scripts/test_worldmap_diplomacy_mutation_extraction.gd | 0 | 6.34 | 2 |
| tests/scripts/test_worldmap_diplomacy_state_extraction.gd | 0 | 6.26 | 2 |
| tests/scripts/test_worldmap_diplomacy_alliance_extraction.gd | 0 | 6.25 | 2 |
| tests/scripts/test_worldmap_trade_routing.gd | 0 | 18.19 | 2 |
| tests/scripts/test_worldmap_trade_controller_extraction.gd | 0 | 5.65 | 2 |
| tests/scripts/test_worldmap_trade_automation_extraction.gd | 0 | 5.79 | 2 |
| tests/scripts/test_worldmap_internal_trade_transfer_extraction.gd | 0 | 5.55 | 2 |
| tests/scripts/test_worldmap_spy_routing.gd | 0 | 21.34 | 2 |
| tests/scripts/test_worldmap_spy_controller_extraction.gd | 0 | 6.54 | 2 |
| project_parse | 0 | 5.69 | 3 |
| _ci_worldmap_scene_load.gd | 0 | 3.32 | 0 |
| _ci_battle_main_scene_load.gd | 0 | 2.59 | 0 |
| _ci_imjin_iso_scene_load.gd | 0 | 3.14 | 0 |

## 테스트 및 validator 출력 원문

줄바꿈은 Markdown 문서용으로 정규화했다. 원본 바이트 로그는 ZIP evidence에도 있다.

### validate_worldmap_main_integrity

```text
PASS: WorldMap main integrity guard (14108 main lines, 15594 orchestration lines, 1083 main functions, all sentinels present).
```

### validate_worldmap_diplomacy_controller_extraction

```text
PASS: diplomacy 2F Controller/Presenter ownership, exact moved bodies, thin main, explicit Spy boundary, unchanged Trade/Military
```

### validate_worldmap_diplomacy_routing

```text
PASS: diplomacy routing/static 2D guard; service owns rules/state, dead legacy removed, production coordinator route retained, military/spy boundaries protected
PASS: diplomacy routing guard + exact C-1/C-2/C-3/M-5/M-FINAL-A/M-FINAL-B + WorldMap warning-cleanup checkpoint bridge; historical T-4 guard preserved
```

### validate_worldmap_diplomacy_service_separation

```text
PASS: diplomacy 2D service separation; legacy callers 0, production service-only, main wrappers/adapters thin, military boundary preserved
```

### validate_worldmap_trade_routing

```text
PASS: Trade Controller/Service/Presenter ownership; Diplomacy service/presenter and Military boundaries frozen
```

### validate_worldmap_trade_controller_extraction

```text
PASS: Trade Controller/Service/Presenter ownership; Diplomacy service/presenter and Military boundaries frozen
```

### validate_worldmap_trade_phase2_extraction

```text
PASS: WorldMap Trade Phase 2 extraction boundaries
```

### validate_worldmap_spy_routing

```text
PASS: Spy Controller/Service/Presenter ownership; Diplomacy boundary explicit; manual Trade service/presenter and Military/Battle frozen
PASS: Spy production routing uses WorldMapMain thin bridge -> Coordinator -> SpyController -> SpyActionService
```

### validate_worldmap_spy_controller_extraction

```text
PASS: Spy Controller/Service/Presenter ownership; Diplomacy boundary explicit; manual Trade service/presenter and Military/Battle frozen
```

### validate_worldmap_battle_settlement_applier_extraction

```text
PASS: M-5 settlement applier boundary, coordinator route, report contract, wrappers, and T03 protection
```

### validate_worldmap_t03_strategic_battle_transaction_extraction

```text
PASS: M-6 T03 transaction service boundary, structured result, thin wrappers, resolver reuse, and presentation protection
```

### validate_worldmap_t03_battle_presentation_extraction

```text
PASS: M-8 T03 presentation controller, queue ownership, exactly-once callback, and turn/save boundary
```

### validate_worldmap_player_attack_deployment_service_extraction

```text
PASS: M-9 deployment/supply transaction, pre-decrement guard, pure rebalance, thin wrappers, and protected boundaries
```

### validate_worldmap_wounded_recovery_service_extraction

```text
PASS: M-7 wounded/recovery domain, thin wrappers, lifecycle guard, UI boundary, and settlement adapter
```

### validate_worldmap_to_battle_input_lifecycle

```text
WORLDMAP TO BATTLE INPUT LIFECYCLE PASS: canonical Battle_Main route; camera-controller handoff guard; duplicate-input execution coverage; roundtrip settlement regression contract present
```

### validate_b0b_battle_production_skeleton

```text
B-0B canonical battle production skeleton static validation: PASS
```

### validate_b0c_battle_iso_promotion

```text
B-0C production ISO promotion static validation: PASS
```

### validate_b1b_battle_movement_query_service

```text
B-1B BattleMovementQueryService static validation: PASS
```

### validate_b1c_battle_combat_query_service

```text
B-1C BattleCombatQueryService static validation: PASS
```

### validate_b1d_battle_damage_formula_service

```text
B-1D BattleDamageFormulaService static validation: PASS
```

### validate_b1e_battle_action_lock_state_service

```text
B-1E BattleActionLockStateService static validation: PASS
```

### validate_b1f_battle_enemy_ai_reservation_state_service

```text
B-1F BattleEnemyAiReservationStateService static validation: PASS
```

### validate_b1g_battle_unique_skill_cooldown_state_service

```text
B-1G BattleUniqueSkillCooldownStateService static validation: PASS
```

### validate_battle_s1_1_observation_baseline

```text
S1_1_OBSERVATION_BASELINE PASS: 18 paths; controllers byte-identical; workflow +4/-0; golden 5 scenarios / 7 cases
```

### validate_battle_s1_2_ally_move_state_service

```text
S1_2_ALLY_MOVE_STATE PASS: scope=HEAD; 12 paths; only five existing functions changed; enemy/shared functions unchanged; split write ordering; workflow +3/-0
```

### validate_battle3d_contract

```text
BATTLE3D_CONTRACT PASS: 14-field ordered view contract, projection inheritance, engine query ownership, resources, 18x10 metadata
```

### validate_alternating_battle_action_order

```text
ALTERNATING BATTLE ACTION ORDER PASS: 3v3/3v2/2v3/1v5/5v1/1v1/skip contract, one-enemy completion, exhaustion and supply boundary
```

### validate_single_side_exhaustion_turn_order

```text
ONE-SIDE EXHAUSTION TURN ORDER PASS: 1v5/5v1/1v1/skip contracts; no acted-ally input deadlock; one round and supply settlement
```

### test_worldmap_city_administration_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[CITY_ADMINISTRATION_SERVICE] PASS: 22 checks, 0 failures
```

### test_worldmap_city_resource_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[CITY_RESOURCE_SERVICE] PASS: 26 checks, 0 failures
```

### test_worldmap_city_detail_presentation_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[CITY_DETAIL_PRESENTATION] PASS: 20 checks, 0 failures
WARNING: 16 RIDs of type "CanvasItem" were leaked.
   at: _free_rids (servers/rendering/renderer_canvas_cull.cpp:2692)
ERROR: 8 RID allocations of type 'PN18TextServerAdvanced22ShapedTextDataAdvancedE' were leaked at exit.
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
```

### test_worldmap_camera_controller_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WORLDMAP_CAMERA_CONTROLLER] PASS: 8 checks, 0 failures
```

### test_worldmap_hud_controller_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WORLDMAP_HUD_CONTROLLER] PASS: 5 checks, 0 failures
```

### test_worldmap_shared_ui_controller_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WORLDMAP_SHARED_UI_CONTROLLER] PASS: 5 checks, 0 failures
```

### test_world_calendar_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WORLD_CALENDAR_SERVICE] PASS: 10 checks, 0 failures
```

### test_world_turn_economy_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WORLD_TURN_ECONOMY_SERVICE] PASS: 10 checks, 0 failures
```

### test_world_turn_state_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WORLD_TURN_STATE_SERVICE] PASS: 10 checks, 0 failures
```

### test_worldmap_turn_controller_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WorldMap] Enemy turn MVP hook reached. Enemy faction reinforcement and invasion event roll are running.
[WORLDMAP_TURN_CONTROLLER] PASS: 11 checks, 0 failures
```

### test_battle_movement_query_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_MOVEMENT_QUERY_SERVICE] PASS: 30 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_combat_query_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_COMBAT_QUERY_SERVICE] PASS: 29 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_damage_formula_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_DAMAGE_FORMULA_SERVICE] PASS: 33 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_action_lock_state_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[ENEMY_TURN] round=1 actor=guan_yu acted remaining=2
[BATTLE_ACTION_LOCK_STATE_SERVICE] PASS: 61 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_enemy_ai_reservation_state_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_ENEMY_AI_RESERVATION_STATE_SERVICE] PASS: 29 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_unique_skill_cooldown_state_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_UNIQUE_SKILL_COOLDOWN_STATE_SERVICE] PASS: 22 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_event_log_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[BATTLE_EVENT_LOG] PASS: 20 checks, 0 failures
```

### test_battle_state_fingerprint_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[BATTLE_STATE_FINGERPRINT] PASS: 53 checks, 0 failures
```

### test_battle_move_oracle_baseline

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M1 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M2 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[MOVE_ORACLE_CASE] M3_occupied PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_range PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_no_path PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M4 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M5 PASS: runs=2 deterministic=true checkpoints=4
[MOVE_ORACLE_GOLDEN] PASS: unchanged baseline
[BATTLE_MOVE_ORACLE] PASS: 283 checks, 0 failures; scenarios=5; cases=7; runs=14
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle_ally_move_state_service

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[BATTLE_ALLY_MOVE_STATE] PASS: 25 checks, 0 failures
```

### test_battle_ally_move_event_parity

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[ALLY_MOVE_EVENT_CASE] M1 events=4 differences=[]
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[ALLY_MOVE_EVENT_CASE] M2 events=4 differences=[]
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[ALLY_MOVE_EVENT_CASE] M4 events=2 differences=[]
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[ALLY_MOVE_EVENT_CASE] M5 events=4 differences=[]
[BATTLE_ALLY_MOVE_EVENTS] PASS: 117 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_battle3d_movement_parity

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

SCENARIO PASS empty_infantry budget=3
SCENARIO PASS empty_cavalry budget=4
SCENARIO PASS empty_archer budget=3
SCENARIO PASS empty_gunner budget=2
SCENARIO PASS empty_mounted_archer budget=4
SCENARIO PASS blockers_false budget=3
SCENARIO PASS blockers_true budget=3
SCENARIO PASS edge_(0, 0) budget=3
SCENARIO PASS edge_(17, 9) budget=3
SCENARIO PASS edge_(0, 5) budget=3
SCENARIO PASS edge_(17, 0) budget=3
SCENARIO PASS status_{ "mobility_up": 2 } budget=4
SCENARIO PASS status_{ "movement_down": 2 } budget=2
SCENARIO PASS zero_budget budget=0
SCENARIO PASS enclosed budget=3
[BATTLE3D_PARITY] PASS: 66148 checks, 0 failures; scenarios=15; visible_rays=540
```

### test_battle3d_modes

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":591,"renderer":"gl_compatibility","units":4}
{"event":"move_accepted","milliseconds":610,"steps":2,"unit_id":"lab_ally_01"}
[BATTLE3D_MODES] PASS: 20 checks, 0 failures
```

### test_battle3d_oblique_click

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[OBLIQUE_CAMERA] yaw=0.32 zoom=24 visible=139 passed=139 flat_different=17 outside=41 occluded=0
[OBLIQUE_CAMERA] yaw=0.32 zoom=40 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.32 zoom=60 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=24 visible=140 passed=140 flat_different=21 outside=40 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=40 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=60 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=24 visible=135 passed=135 flat_different=5 outside=45 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=40 visible=180 passed=180 flat_different=17 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=60 visible=180 passed=180 flat_different=17 outside=0 occluded=0
[BATTLE3D_OBLIQUE] PASS: 1522 checks, 0 failures; cameras=9; visible=1494; flat_different=177
```

### alternating_battle_action_order_test

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

ALTERNATING BATTLE ACTION ORDER GODOT PASS
```

### test_single_side_exhaustion_turn_order

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[ONE_SIDE_EXHAUSTION_TURN_PASS] Battle_Land scene loads
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] WorldMap battle context received: type=attack mode=manual attacker=한성(hanseong) defender=평양(pyeongyang)
[WORLD_CONTEXT_HERO] hero=gwanggaeto runtime=gwanggaeto portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=uija_wang runtime=uija_wang portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=kim_chun_chu runtime=kim_chun_chu portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=jang_bo_go runtime=jang_bo_go portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=heukchi_sangji runtime=heukchi_sangji portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=yi_sun_sin runtime=yi_sun_sin portrait=unit_blue_battlefield.png skill=고유기
[CONTEXT_SLOT] source=player_attack side=attacker requested=["yi_sun_sin"] sample_fallback=false
[CONTEXT_SLOT_SKIP] slot=ally_main_02 side=attacker reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=attacker slot=ally_main_02 city=hanseong reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=ally_main_03 side=attacker reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=attacker slot=ally_main_03 city=hanseong reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=ally_reinforce_01 side=attacker reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=attacker slot=ally_reinforce_01 city=hanseong reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=ally_reinforce_02 side=attacker reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=attacker slot=ally_reinforce_02 city=hanseong reason=no_eligible_context_hero
[CONTEXT_SLOT] source=player_attack side=defender requested=["gwanggaeto", "uija_wang", "kim_chun_chu", "jang_bo_go", "heukchi_sangji"] sample_fallback=false
[ROSTER_PANEL_SLOT] source=worldmap_context side=ally slot=ally_main_01 hero_id=yi_sun_sin display_name=yi_sun_sin active=true reason=context_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=ally slot=ally_main_02 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=ally slot=ally_main_03 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=ally slot=ally_reinforce_01 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=ally slot=ally_reinforce_02 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=enemy slot=enemy_main_01 hero_id=gwanggaeto display_name=gwanggaeto active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=enemy slot=enemy_main_02 hero_id=uija_wang display_name=uija_wang active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=enemy slot=enemy_main_03 hero_id=kim_chun_chu display_name=kim_chun_chu active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=enemy slot=enemy_reinforce_01 hero_id=jang_bo_go display_name=jang_bo_go active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=enemy slot=enemy_reinforce_02 hero_id=heukchi_sangji display_name=heukchi_sangji active=true reason=context_slot
[Battle] WorldMap roster applied: ally=["yi_sun_sin"] enemy=["gwanggaeto", "uija_wang", "kim_chun_chu", "jang_bo_go", "heukchi_sangji"]
[BATTLE_RESUME] saved battle=turn-order-1v5 round=1 phase=ally_turn
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=false deployed=false
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=1 adapter_alive_enemy_count=3 fallback_alive_ally_count=1 fallback_alive_enemy_count=3 all_alive_count=4
active_capacity_slots ally=["ally_main_01"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=1 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=1
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=1 enemy=3 target_candidates ally=3 enemy=1 all_alive_deployed_count=4 phase=ally_turn parity_ok=false
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v5 fixture has one ally and five enemies
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v5 fixture configures BattleSupplyRuntime
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v5 preview matches the first live enemy selector result without mutation
[ENEMY_TURN] round=1 actor=gwanggaeto_battle_unit acted remaining=4
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v5 preview skips the enemy actor already consumed by turn order
[BATTLE_RESUME] saved battle=turn-order-1v5 round=1 phase=enemy_turn
[ENEMY_TURN_START] ally=(3, 8) enemy=(14, 2) dist=17 ally_range=3 enemy_range=1
[ENEMY_AI_DECISION] actor_slot=enemy_main_02 actor=uija_wang preferred_target=ally_main_01/yi_sun_sin final_target=ally_main_01/yi_sun_sin dest=(9, 3) reason=ENGAGE action=ENGAGE wait_reason=
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v5 exhaustion stays in enemy turn
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v5 clears acted ally selection
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v5 schedules exactly the next unacted enemy
[ONE_SIDE_EXHAUSTION_TURN_PASS] Battle_Land scene loads
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] WorldMap battle context received: type=attack mode=manual attacker=한성(hanseong) defender=평양(pyeongyang)
[WORLD_CONTEXT_HERO] hero=gwanggaeto runtime=gwanggaeto portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=yi_sun_sin runtime=yi_sun_sin portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=jeong_do_jeon runtime=jeong_do_jeon portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=kwon_yul runtime=kwon_yul portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=kim_yu_sin runtime=kim_yu_sin portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=eulji_mundeok runtime=eulji_mundeok portrait=unit_blue_battlefield.png skill=고유기
[CONTEXT_SLOT] source=player_attack side=attacker requested=["yi_sun_sin", "jeong_do_jeon", "kwon_yul", "kim_yu_sin", "eulji_mundeok"] sample_fallback=false
[CONTEXT_SLOT] source=player_attack side=defender requested=["gwanggaeto"] sample_fallback=false
[CONTEXT_SLOT_SKIP] slot=enemy_main_02 side=defender reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=defender slot=enemy_main_02 city=pyeongyang reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=enemy_main_03 side=defender reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=defender slot=enemy_main_03 city=pyeongyang reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=enemy_reinforce_01 side=defender reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=defender slot=enemy_reinforce_01 city=pyeongyang reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=enemy_reinforce_02 side=defender reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=defender slot=enemy_reinforce_02 city=pyeongyang reason=no_eligible_context_hero
[ROSTER_PANEL_SLOT] source=worldmap_context side=ally slot=ally_main_01 hero_id=yi_sun_sin display_name=yi_sun_sin active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=ally slot=ally_main_02 hero_id=jeong_do_jeon display_name=jeong_do_jeon active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=ally slot=ally_main_03 hero_id=kwon_yul display_name=kwon_yul active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=ally slot=ally_reinforce_01 hero_id=kim_yu_sin display_name=kim_yu_sin active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=eulji_mundeok active=true reason=context_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=enemy slot=enemy_main_01 hero_id=gwanggaeto display_name=gwanggaeto active=true reason=context_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=enemy slot=enemy_main_02 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=enemy slot=enemy_main_03 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=enemy slot=enemy_reinforce_01 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=enemy slot=enemy_reinforce_02 active=false reason=hidden_empty_slot
[Battle] WorldMap roster applied: ally=["yi_sun_sin", "jeong_do_jeon", "kwon_yul", "kim_yu_sin", "eulji_mundeok"] enemy=["gwanggaeto"]
[BATTLE_RESUME] saved battle=turn-order-5v1 round=1 phase=ally_turn
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=false deployed=false
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=1 fallback_alive_ally_count=3 fallback_alive_enemy_count=1 all_alive_count=4
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=1 target_candidates_for_ally_actor_count=1 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01"]
actor_candidates ally=3 enemy=1 target_candidates ally=1 enemy=3 all_alive_deployed_count=4 phase=ally_turn parity_ok=false
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[ONE_SIDE_EXHAUSTION_TURN_PASS] 5v1 fixture has five allies and one enemy
[ENEMY_TURN] round=1 actor=gwanggaeto_battle_unit acted remaining=0
[BATTLE_RESUME] saved battle=turn-order-5v1 round=1 phase=ally_turn
[BATTLE_RESUME] saved battle=turn-order-5v1 round=1 phase=ally_turn
[ALLY_TURN_RETURN] ally=(3, 8) enemy=(14, 2) dist=17 ally_range=3 enemy_range=1
[ONE_SIDE_EXHAUSTION_TURN_PASS] 5v1 returns player control
[ONE_SIDE_EXHAUSTION_TURN_PASS] 5v1 selects next unacted ally
[ONE_SIDE_EXHAUSTION_TURN_PASS] Battle_Land scene loads
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] WorldMap battle context received: type=attack mode=manual attacker=한성(hanseong) defender=평양(pyeongyang)
[WORLD_CONTEXT_HERO] hero=gwanggaeto runtime=gwanggaeto portrait=unit_blue_battlefield.png skill=고유기
[WORLD_CONTEXT_HERO] hero=yi_sun_sin runtime=yi_sun_sin portrait=unit_blue_battlefield.png skill=고유기
[CONTEXT_SLOT] source=player_attack side=attacker requested=["yi_sun_sin"] sample_fallback=false
[CONTEXT_SLOT_SKIP] slot=ally_main_02 side=attacker reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=attacker slot=ally_main_02 city=hanseong reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=ally_main_03 side=attacker reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=attacker slot=ally_main_03 city=hanseong reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=ally_reinforce_01 side=attacker reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=attacker slot=ally_reinforce_01 city=hanseong reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=ally_reinforce_02 side=attacker reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=attacker slot=ally_reinforce_02 city=hanseong reason=no_eligible_context_hero
[CONTEXT_SLOT] source=player_attack side=defender requested=["gwanggaeto"] sample_fallback=false
[CONTEXT_SLOT_SKIP] slot=enemy_main_02 side=defender reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=defender slot=enemy_main_02 city=pyeongyang reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=enemy_main_03 side=defender reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=defender slot=enemy_main_03 city=pyeongyang reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=enemy_reinforce_01 side=defender reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=defender slot=enemy_reinforce_01 city=pyeongyang reason=no_eligible_context_hero
[CONTEXT_SLOT_SKIP] slot=enemy_reinforce_02 side=defender reason=empty_context_slot_no_fallback
[REINFORCE_SKIP] battle_side=defender slot=enemy_reinforce_02 city=pyeongyang reason=no_eligible_context_hero
[ROSTER_PANEL_SLOT] source=worldmap_context side=ally slot=ally_main_01 hero_id=yi_sun_sin display_name=yi_sun_sin active=true reason=context_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=ally slot=ally_main_02 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=ally slot=ally_main_03 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=ally slot=ally_reinforce_01 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=ally slot=ally_reinforce_02 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SLOT] source=worldmap_context side=enemy slot=enemy_main_01 hero_id=gwanggaeto display_name=gwanggaeto active=true reason=context_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=enemy slot=enemy_main_02 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=enemy slot=enemy_main_03 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=enemy slot=enemy_reinforce_01 active=false reason=hidden_empty_slot
[ROSTER_PANEL_SKIP] source=worldmap_context side=enemy slot=enemy_reinforce_02 active=false reason=hidden_empty_slot
[Battle] WorldMap roster applied: ally=["yi_sun_sin"] enemy=["gwanggaeto"]
[BATTLE_RESUME] saved battle=turn-order-1v1 round=1 phase=ally_turn
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01"] enemy_active=["enemy_main_01"] ally_deployed=["ally_main_01"] enemy_deployed=["enemy_main_01"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=false deployed=false
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=false deployed=false
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=1 adapter_alive_enemy_count=1 fallback_alive_ally_count=1 fallback_alive_enemy_count=1 all_alive_count=2
active_capacity_slots ally=["ally_main_01"] enemy=["enemy_main_01"] deployed_capacity_slots ally=["ally_main_01"] enemy=["enemy_main_01"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=1 actor_candidates_enemy_count=1 target_candidates_for_ally_actor_count=1 target_candidates_for_enemy_actor_count=1
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01"] enemy=["enemy_main_01"] deployed_slots ally=["ally_main_01"] enemy=["enemy_main_01"]
actor_candidates ally=1 enemy=1 target_candidates ally=1 enemy=1 all_alive_deployed_count=2 phase=ally_turn parity_ok=false
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[ENEMY_TURN] round=1 actor=gwanggaeto_battle_unit acted remaining=0
[REINFORCEMENT_TOAST_SKIP] source=reinforce_01 round=2 reason=no_arriving_units
[BATTLE_RESUME] saved battle=turn-order-1v1 round=2 phase=ally_turn
[BATTLE_RESUME] saved battle=turn-order-1v1 round=2 phase=ally_turn
[ALLY_TURN_RETURN] ally=(3, 8) enemy=(14, 2) dist=17 ally_range=3 enemy_range=1
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v1 increments one completed round
[ONE_SIDE_EXHAUSTION_TURN_PASS] 1v1 opens next round for ally
[ONE_SIDE_EXHAUSTION_TURN] PASS
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_domestic_tech_catalog_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DOMESTIC_TECH_CATALOG] PASS: 19 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_domestic_tech_research_rules_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DOMESTIC_TECH_RULES] PASS: 17 checks, 0 failures
```

### test_worldmap_domestic_tech_research_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DOMESTIC_TECH_RESEARCH_SERVICE] PASS: 35 checks, 0 failures
```

### test_worldmap_domestic_tech_effect_provider_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DOMESTIC_TECH_EFFECT_PROVIDER] PASS: 34 checks, 0 failures
```

### test_worldmap_domestic_tech_tree_presentation_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DOMESTIC_TECH_TREE_PRESENTATION] PASS: 25 checks, 0 failures
```

### test_worldmap_domestic_tech_completion_presentation_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DOMESTIC_TECH_COMPLETION_VIDEO_LOAD] path=res://assets/ui/research/videos/research_completion_city_theora_q8_1920x1080.ogv file_exists=true resource_loader_exists=true load_null=false class=VideoStreamTheora is_video_stream=true
[DOMESTIC_TECH_COMPLETION_VIDEO] play scope=city tech_id=agri_tool_upgrade path=res://assets/ui/research/videos/research_completion_city_theora_q8_1920x1080.ogv
[DOMESTIC_TECH_COMPLETION_VIDEO] complete source=test_skip tech_id=agri_tool_upgrade
[DOMESTIC_TECH_COMPLETION_VIDEO_LOAD] path=res://assets/ui/research/videos/research_completion_city_theora_q8_1920x1080.ogv file_exists=true resource_loader_exists=true load_null=false class=VideoStreamTheora is_video_stream=true
[DOMESTIC_TECH_COMPLETION_VIDEO] play scope=city tech_id=agri_irrigation path=res://assets/ui/research/videos/research_completion_city_theora_q8_1920x1080.ogv
[DOMESTIC_TECH_COMPLETION_VIDEO] complete source=finished_signal tech_id=agri_irrigation
[DOMESTIC_TECH_COMPLETION_PRESENTATION] PASS: 22 checks, 0 failures
```

### test_worldmap_military_controller_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[RECRUIT_TROOPS] city=hanseong amount=100 publicSupport=70 loyalty=90 troops=300->400 cost={ "gold": 100, "food": 50 } paid={ "before": { "gold": 1000, "rice": 1000, "barley": 0, "seafood": 0 }, "after": { "gold": 900, "rice": 950, "barley": 0, "seafood": 0 }, "gold": 100, "food": 50, "food_breakdown": { "rice": 50, "barley": 0, "seafood": 0 }, "food_order": ["rice", "barley", "seafood"] }
[TROOP_MOVE] from=hanseong to=pyeongyang commanded=100 departed=100 arrived=100 lost=0 loyalty=100 from_after=900 to_after=200 total=4810->4810
[MILITARY_CONTROLLER] PASS: 17 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_enemy_warfare_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[PLAYER_ATTACK_SUPPLY_DEFAULT] city=pyeongyang resources={ "rice": 219, "barley": 219, "seafood": 74, "gold": 420, "salt": 20 }
[PLAYER_ATTACK_SUPPLY_DEFAULT] city=gyeongju resources={ "rice": 165, "barley": 110, "seafood": 167, "gold": 580, "salt": 40 }
[PLAYER_ATTACK_SUPPLY_DEFAULT] city=sabi resources={ "rice": 155, "barley": 103, "seafood": 156, "gold": 620, "salt": 60 }
[ENEMY_WARFARE_SERVICE] PASS: 20 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_battle_context_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[PLAYER_ATTACK_SUPPLY_DEFAULT] city=pyeongyang resources={ "rice": 219, "barley": 219, "seafood": 74, "gold": 420, "salt": 20 }
[BATTLE_CONTEXT_SERVICE] PASS: 29 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_battle_result_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[INVASION_RESULT_PANEL] result=defender_win city=hanseong title=방어 성공 lines=["한성을 지켜냈습니다.", "소유권: 유지 (PLAYER)", "도시 병력: 300 → 255", "공격 출발지 평양 병력: 280 → 84", "장수 상태: 부상 광개토대왕 [부상 3턴] / 포로 상태 을지문덕 [포로]"]
[WorldMap] Invasion battle result applied: 방어 성공: 한성을 지켜냈습니다. / payload={ "source": "enemy_invasion", "type": "defense", "winner": "defender", "attacker_city_id": "pyeongyang", "defender_city_id": "hanseong", "attacker_city_name": "평양", "defender_city_name": "한성", "player_troop_outcome": { "allocated": 100, "survivors": 40, "losses": 60, "wounded": 20, "dead": 40 }, "enemy_troop_outcome": { "allocated": 100, "survivors": 0, "losses": 100, "wounded": 30, "dead": 70 }, "_settlement_plan": { "battle_kind": "enemy_invasion", "result_kind": "defender_win", "winner_side": "defender", "loser_side": "attacker", "attacker_city_id": "pyeongyang", "defender_city_id": "hanseong", "target_city_id": "hanseong", "player_troop_outcome": { "allocated": 100, "survivors": 40, "losses": 60, "wounded": 20, "dead": 40 }, "enemy_troop_outcome": { "allocated": 100, "survivors": 0, "losses": 100, "wounded": 30, "dead": 70 }, "casualty_plan": { "attacker_before": 280, "defender_before": 300, "attacker_remaining_troops": 84, "defender_remaining_troops": 255, "occupied_city_troops": 0, "attacker_source_remaining_troops": 84, "attacker_loss": 196, "defender_loss": 45 }, "attacker_remaining_troops": 84, "defender_remaining_troops": 255, "occupation_troops": 0, "hero_outcomes": { "attacker": {  }, "defender": {  } }, "hero_status_plan": [{ "hero_id": "gwanggaeto", "status": "wounded", "outcome": {  } }, { "hero_id": "eulji_mundeok", "status": "captured", "outcome": {  } }], "defender_disposition": {  }, "hero_movements": [], "settlement_profile": "standard", "troop_settlement": { "attacker_healthy": 84, "attacker_wounded": 0, "defender_healthy": 255, "defender_wounded": 0 }, "faction_transfer": { "required": false, "city_id": "hanseong", "old_owner": "player", "new_owner": "player" }, "supply_settlement": { "defender": { "city_id": "hanseong", "food_type": "rice", "remaining_food": 0, "remaining_salt": 0 }, "attacker_cargo": { "destination_city_id": "pyeongyang", "food_type": "rice", "food": 0, "salt": 0, "gold": 0 } }, "apply_supply_settlement": false, "transaction_id": "", "result_id": "", "raw_result": { "source": "enemy_invasion", "type": "defense", "winner": "defender", "attacker_city_id": "pyeongyang", "defender_city_id": "hanseong", "attacker_city_name": "평양", "defender_city_name": "한성", "player_troop_outcome": { "allocated": 100, "survivors": 40, "losses": 60, "wounded": 20, "dead": 40 }, "enemy_troop_outcome": { "allocated": 100, "survivors": 0, "losses": 100, "wounded": 30, "dead": 70 } } }, "_settlement_report": { "ok": true, "battle_kind": "enemy_invasion", "result_kind": "defender_win", "target_city_id": "hanseong", "transaction_id": "", "result_id": "", "duplicate": false, "troop_changes": [{ "city_id": "hanseong", "before": 300, "after": 255 }, { "city_id": "pyeongyang", "before": 280, "after": 84 }], "ownership_changed": false, "old_owner": "player", "new_owner": "player", "hero_changes": [{ "hero_id": "gwanggaeto", "status": "wounded", "kind": "status" }, { "hero_id": "eulji_mundeok", "status": "captured", "kind": "status" }], "supply_changes": [], "cargo_changes": [], "indexes_rebuilt": true, "warnings": [] } }
[BATTLE_RESULT_SERVICE] PASS: 31 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_battle_settlement_applier_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[BATTLE_SETTLEMENT_APPLIER] PASS: 28 checks, 0 failures
```

### test_worldmap_t03_strategic_battle_transaction_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[T03_TRANSACTION_PASS] service is RefCounted without scene-node API
[T03_TRANSACTION_PASS] transaction id uses stable turn and city pair
[T03_TRANSACTION_PASS] food type selects largest stock
[T03_TRANSACTION_PASS] food type tie is stable
[T03_TRANSACTION_PASS] food stock sum clamps malformed negatives
[T03_TRANSACTION_PASS] hero filtering applies allocation
[T03_TRANSACTION_PASS] cargo plan meets expedition minimum
[T03_TRANSACTION_PASS] cargo plan preserves food breakdown total
[T03_TRANSACTION_PASS] cargo payment mutates source stock
[T03_TRANSACTION_PASS] normal transaction preparation succeeds
[T03_TRANSACTION_PASS] preparation reserves attacker troops and leaves garrison
[T03_TRANSACTION_PASS] preparation reserves defender troops
[T03_TRANSACTION_PASS] direct preparation advances pending event stage
[T03_TRANSACTION_PASS] rollback restores pre-payment troop state
[T03_TRANSACTION_PASS] rollback restores paid cargo
[T03_TRANSACTION_PASS] insufficient cargo rejects before mutation
[T03_TRANSACTION_PASS] automatic transaction invokes injected resolver once
[T03_TRANSACTION_PASS] attacker victory applies ownership and occupation troops
[T03_TRANSACTION_PASS] attacker remaining cargo settles into occupied city
[T03_TRANSACTION_PASS] successful settlement marks result applied
[T03_TRANSACTION_PASS] successful settlement clears pending event
[T03_TRANSACTION_PASS] duplicate transaction is rejected before resolver
[T03_TRANSACTION_PASS] defender victory preserves ownership
[T03_TRANSACTION_PASS] defender victory returns healthy survivors to both cities
[T03_TRANSACTION_PASS] defender victory records wounded settlement
[T03_TRANSACTION_PASS] malformed resolver result rolls transaction back
[T03_TRANSACTION_PASS] resolver rollback restores troops and resources
[T03_TRANSACTION_PASS] settlement mutation failure rolls transaction back
[T03_TRANSACTION_PASS] settlement rollback restores pre-transaction domain state
[T03_TRANSACTION_PASS] partial or invalid request fails structurally
[T03_TRANSACTION_SERVICE] PASS: 30 checks, 0 failures
```

### test_worldmap_t03_battle_presentation_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[T03_PRESENTATION_PASS] setup hides presentation overlay
[T03_PRESENTATION_PASS] existing T03 video is loaded
[T03_PRESENTATION_PASS] report build preserves identities
[T03_PRESENTATION_PASS] report build preserves victory wording
[T03_PRESENTATION_PASS] report build preserves casualty presentation
[T03_PRESENTATION_PASS] defender report wording is preserved
[T03_PRESENTATION_PASS] malformed domain result does not build a report
[T03_PRESENTATION_PASS] report enqueue writes persistent queue
[T03_PRESENTATION_PASS] duplicate queued report is rejected
[T03_PRESENTATION_PASS] queue preserves FIFO order
[T03_PRESENTATION_PASS] malformed report enqueue is rejected
[T03_PRESENTATION_PASS] first queued report becomes current
[T03_PRESENTATION_PASS] available video starts playback phase
[T03_PRESENTATION_PASS] current report cannot start twice
[T03_PRESENTATION_PASS] video skip opens result card
[T03_PRESENTATION_PASS] result card displays current report
[T03_PRESENTATION_PASS] confirm emits completion exactly once
[T03_PRESENTATION_PASS] confirm acknowledges and removes only current report
[T03_PRESENTATION_PASS] duplicate confirm cannot emit completion again
[T03_PRESENTATION_PASS] video finish opens result card
[T03_PRESENTATION_PASS] next queued report completes in order
[T03_PRESENTATION_PASS] empty queue emits one completion signal
[T03_PRESENTATION_PASS] empty queue signal is deduplicated
[T03_PRESENTATION_PASS] acknowledged report cannot be enqueued again
[T03_PRESENTATION_PASS] missing video falls back directly to result card
[T03_PRESENTATION_PASS] presentation reset clears transient state
[T03_PRESENTATION] PASS: 26 checks, 0 failures
```

### test_worldmap_player_attack_deployment_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DEPLOYMENT_PASS] deployment payload preserves source and target
[DEPLOYMENT_PASS] payload preserves minimum source garrison
[DEPLOYMENT_PASS] deployable hero list excludes captured or wounded hero
[DEPLOYMENT_PASS] payload includes route domain facts
[DEPLOYMENT_PASS] payload includes supply stock
[DEPLOYMENT_PASS] payload snapshot cannot mutate city state
[DEPLOYMENT_PASS] missing source payload fails
[DEPLOYMENT_PASS] no deployable troops payload fails
[DEPLOYMENT_PASS] normal deployment validates
[DEPLOYMENT_PASS] allocation is preserved below command limit
[DEPLOYMENT_PASS] allocation clamps to hero command limit
[DEPLOYMENT_PASS] allocation preserves source garrison
[DEPLOYMENT_PASS] non-adjacent or wrong source fails
[DEPLOYMENT_PASS] blocked target fails
[DEPLOYMENT_PASS] naval or siege lock fails
[DEPLOYMENT_PASS] no hero fails
[DEPLOYMENT_PASS] captured hero fails
[DEPLOYMENT_PASS] missing command limit fails
[DEPLOYMENT_PASS] zero troop allocation fails
[DEPLOYMENT_PASS] malformed deployment fails structurally
[DEPLOYMENT_PASS] invalid food type fails
[DEPLOYMENT_PASS] minimum food is enforced
[DEPLOYMENT_PASS] minimum gold is enforced
[DEPLOYMENT_PASS] city food affordability is enforced
[DEPLOYMENT_PASS] city gold affordability is enforced
[DEPLOYMENT_PASS] city salt affordability is enforced
[DEPLOYMENT_PASS] existing expedition calculator supplies minimum cost
[DEPLOYMENT_PASS] largest city food type is selected
[DEPLOYMENT_PASS] supply payment deducts selected resources
[DEPLOYMENT_PASS] supply payment is idempotent by transaction
[DEPLOYMENT_PASS] troop pre-decrement mutates city and marks context
[DEPLOYMENT_PASS] troop pre-decrement flag prevents duplicate deduction
[DEPLOYMENT_PASS] expedition movement removes stationed hero
[DEPLOYMENT_PASS] expedition movement updates hero lifecycle state
[DEPLOYMENT_PASS] departure atomically pre-decrements both sides
[DEPLOYMENT_PASS] duplicate departure does not repeat mutation
[DEPLOYMENT_PASS] handoff rollback restores troop snapshots
[DEPLOYMENT_PASS] handoff rollback restores supply and hero location
[DEPLOYMENT_PASS] rollback is idempotent
[PLAYER_ATTACK_DEPLOYMENT] PASS: 39 checks, 0 failures
```

### test_worldmap_troop_rebalance_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[REBALANCE_PASS] rebalance computes one valid transfer
[REBALANCE_PASS] rebalance selects rear supplier and frontline demand
[REBALANCE_PASS] rebalance caps transfer at frontline shortage
[REBALANCE_PASS] suggestion calculation is pure
[REBALANCE_PASS] rebalance apply reuses troop movement mutation
[REBALANCE_PASS] malformed suggestion is rejected
[REBALANCE_PASS] invalid move is rejected
[TROOP_REBALANCE] PASS: 7 checks, 0 failures
```

### test_worldmap_wounded_recovery_service_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WOUNDED_RECOVERY_PASS] service is RefCounted without scene-node API
[WOUNDED_RECOVERY_PASS] empty wounded queue reads as empty
[WOUNDED_RECOVERY_PASS] queue read returns a detached snapshot
[WOUNDED_RECOVERY_PASS] wounded troop batch is added
[WOUNDED_RECOVERY_PASS] queue preserves wounded count and recovery months
[WOUNDED_RECOVERY_PASS] duplicate transaction batch is idempotent
[WOUNDED_RECOVERY_PASS] queue clear writes both queue aliases
[WOUNDED_RECOVERY_PASS] legacy and snake-case queue keys remain compatible
[WOUNDED_RECOVERY_PASS] battle settlement status registers wounded hero
[WOUNDED_RECOVERY_PASS] normal hero recovery remains three months
[WOUNDED_RECOVERY_PASS] battle transaction marker is retained
[WOUNDED_RECOVERY_PASS] duplicate settlement cannot reset recovery
[WOUNDED_RECOVERY_PASS] malformed hero id is rejected
[WOUNDED_RECOVERY_PASS] missing hero is rejected
[WOUNDED_RECOVERY_PASS] malformed status is rejected
[WOUNDED_RECOVERY_PASS] natural recovery advances once
[WOUNDED_RECOVERY_PASS] same month recovery is idempotent
[WOUNDED_RECOVERY_PASS] completed recovery clears wounded hero state
[WOUNDED_RECOVERY_PASS] completion reports recovered hero id
[WOUNDED_RECOVERY_PASS] recovered troops return to city and completed queue entry is removed
[WOUNDED_RECOVERY_PASS] different city queues progress independently
[WOUNDED_RECOVERY_PASS] multiple wounded heroes progress together
[WOUNDED_RECOVERY_PASS] fast treatment domain eligibility reports cost
[WOUNDED_RECOVERY_PASS] fast treatment deducts exact salt cost
[WOUNDED_RECOVERY_PASS] fast treatment changes matching troop queue to one month
[WOUNDED_RECOVERY_PASS] fast treatment shortens matching wounded hero recovery
[WOUNDED_RECOVERY_PASS] fast treatment updates lifecycle state
[WOUNDED_RECOVERY_PASS] insufficient salt fails without mutation
[WOUNDED_RECOVERY_PASS] missing city treatment is rejected
[WOUNDED_RECOVERY_PASS] empty wounded treatment is rejected
[WOUNDED_RECOVERY_PASS] already-fast treatment is rejected
[WOUNDED_RECOVERY_PASS] forty world turns preserve twelve-month calendar mapping
[WOUNDED_RECOVERY_SERVICE] PASS: 32 checks, 0 failures
```

### test_worldmap_diplomacy_routing

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DIPLOMACY_ROUTING] PASS: 172 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_diplomacy_controller_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DIPLOMACY_CONTROLLER_2F] PASS: 131 checks, 0 failures
```

### test_worldmap_diplomacy_validation_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DIPLOMACY_VALIDATION_2A] PASS: 54 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_diplomacy_mutation_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DIPLOMACY_MUTATION_2B] PASS: 67 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_diplomacy_state_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DIPLOMACY_STATE_2C1] PASS: 50 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_diplomacy_alliance_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DIPLOMACY_ALLIANCE_2C2] PASS: 52 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_trade_routing

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[WorldMap] Manual external trade order stored: { "source_city_id": "hanseong", "target_city_id": "pyeongyang", "trade_type": "external", "mode": "manual", "orders": { "rice": { "action": "export", "amount": 10 }, "salt": { "action": "import", "amount": 4 } }, "preview": { "gold": 6, "rice": -10, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 4, "efficiency": 1.0, "market_turn": 1 }, "efficiency": 1.0 }
[WorldMap] Manual external trade order stored: { "source_city_id": "hanseong", "target_city_id": "pyeongyang", "trade_type": "external", "mode": "manual", "orders": { "rice": { "action": "export", "amount": 10 }, "salt": { "action": "import", "amount": 4 } }, "preview": { "gold": 6, "rice": -10, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 4, "efficiency": 1.0, "market_turn": 1 }, "efficiency": 1.0 }
[WorldMap] Manual external trade order stored: { "source_city_id": "hanseong", "target_city_id": "pyeongyang", "trade_type": "external", "mode": "manual", "orders": { "rice": { "action": "export", "amount": 10 }, "salt": { "action": "import", "amount": 4 } }, "preview": { "gold": 6, "rice": -10, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 4, "efficiency": 1.0, "market_turn": 1 }, "efficiency": 1.0 }
[WorldMap] Manual external trade order stored: { "source_city_id": "hanseong", "target_city_id": "pyeongyang", "trade_type": "external", "mode": "manual", "orders": { "rice": { "action": "export", "amount": 10 }, "salt": { "action": "import", "amount": 4 } }, "preview": { "gold": 6, "rice": -10, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 4, "efficiency": 1.0, "market_turn": 1 }, "efficiency": 1.0 }
[TRADE_ROUTING] PASS: 73 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_trade_controller_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TRADE_SAVE_LOAD] dropped invalid manual trade order for source=missing
[TRADE_CONTROLLER] PASS: 32 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_trade_automation_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TRADE_AUTOMATION] PASS: 15 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_internal_trade_transfer_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[INTERNAL_TRADE_TRANSFER] PASS: 21 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_spy_routing

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[SPY_ROUTING] PASS: 71 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 3 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### test_worldmap_spy_controller_extraction

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[SPY_CONTROLLER] PASS: 49 checks, 0 failures
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 3 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### project_parse

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[   0% ] [90m[1mfirst_scan_filesystem[22m | Started Project initialization (5 steps)[39m[0m
[   0% ] [90m[1mfirst_scan_filesystem[22m | Scanning file structure...[39m[0m
[  16% ] [90m[1mfirst_scan_filesystem[22m | Loading global class names...[39m[0m
[  33% ] [90m[1mfirst_scan_filesystem[22m | Verifying GDExtensions...[39m[0m
[  50% ] [90m[1mfirst_scan_filesystem[22m | Creating autoload scripts...[39m[0m
[  66% ] [90m[1mfirst_scan_filesystem[22m | Initializing plugins...[39m[0m
[  83% ] [90m[1mfirst_scan_filesystem[22m | Starting file scan...[39m[0m
[92m[ DONE ][39m [1mfirst_scan_filesystem[22m
[0m
WARNING: UID duplicate detected between res://tests/scenes/Battle_UI_Production_Test.tscn and res://_incoming/Battle_Land_BEFORE_T08_BACKUP.tscn.
   at: _process_file_system (editor/file_system/editor_file_system.cpp:1377)
WARNING: UID duplicate detected between res://Battle_Land.tscn and res://tests/scenes/Battle_UI_Production_Test.tscn.
   at: _process_file_system (editor/file_system/editor_file_system.cpp:1377)
WARNING: Scan thread aborted...
   at: _notification (editor/file_system/editor_file_system.cpp:1729)
```

### _ci_worldmap_scene_load

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[CI_WORLDMAP_LOAD] PASS
```

### _ci_battle_main_scene_load

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[CI_BATTLE_MAIN_LOAD] PASS
```

### _ci_imjin_iso_scene_load

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[CI_IMJIN_ISO_LOAD] PASS
```

### probe_control

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M1 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M2 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[MOVE_ORACLE_CASE] M3_occupied PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_range PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_no_path PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M4 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M5 PASS: runs=2 deterministic=true checkpoints=4
[MOVE_ORACLE_GOLDEN] PASS: unchanged baseline
[BATTLE_MOVE_ORACLE] PASS: 283 checks, 0 failures; scenarios=5; cases=7; runs=14
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### probe_move_acts

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[MOVE_ORACLE] FAIL: M1 moved but not acted
[MOVE_ORACLE] FAIL: M1 movement never acts
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[BATTLE_MOVE_ORACLE] STOP: actual controller case failed: M1
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### probe_path_distance

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M1 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[MOVE_ORACLE] FAIL: M2 grid distance not path length
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[BATTLE_MOVE_ORACLE] STOP: actual controller case failed: M2
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### probe_restored

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M1 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M2 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[MOVE_ORACLE_CASE] M3_occupied PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_range PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_no_path PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M4 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M5 PASS: runs=2 deterministic=true checkpoints=4
[MOVE_ORACLE_GOLDEN] PASS: unchanged baseline
[BATTLE_MOVE_ORACLE] PASS: 283 checks, 0 failures; scenarios=5; cases=7; runs=14
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### probe_rollback_last_action

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M1 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(4, 2) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (4, 2) target_cell: (4, 2)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[MOVE_ORACLE_CASE] M2 PASS: runs=2 deterministic=true checkpoints=3
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[OCCUPIED BLOCK] mover=이순신 target=(3, 2) occupied_by_other=true
[MOVE_ORACLE_CASE] M3_occupied PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_range PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[MOVE_ORACLE_CASE] M3_no_path PASS: runs=2 deterministic=true checkpoints=2
[IDENTITY_OK] ally_main_01 hero=yi_sunsin name=이순신 portrait=yi_sunsin_battlefield.png click=AllyUnitClickArea
[IDENTITY_OK] ally_main_02 hero=jeong_dojeon name=정도전 portrait=jeong_dojeon_battlefield.png click=AllySupportUnitClickArea
[IDENTITY_OK] ally_main_03 hero=kwon_yul name=권율 portrait=kwon_yul_battlefield.png click=AllyMain03UnitClickArea
[IDENTITY_OK] ally_reinforce_01 hero=gim_yusin name=김유신 portrait=gim_yusin_battlefield.png click=AllyReinforce01UnitClickArea
[IDENTITY_OK] ally_reinforce_02 hero=eulji_mundeok name=을지문덕 portrait=eulji_mundeok_battlefield.png click=AllyReinforce02UnitClickArea
[IDENTITY_OK] enemy_main_01 hero=guan_yu name=관우 portrait=guan_yu_battlefield.png click=EnemyUnitClickArea
[IDENTITY_OK] enemy_main_02 hero=zhang_fei name=장비 portrait=zhang_fei_battlefield.png click=EnemySupportUnitClickArea
[IDENTITY_OK] enemy_main_03 hero=xiahou_dun name=하후돈 portrait=xiahou_dun_battlefield.png click=EnemyMain03UnitClickArea
[IDENTITY_OK] enemy_reinforce_01 hero=liu_bei name=유비 portrait=liu_bei_battlefield.png click=EnemyReinforce01UnitClickArea
[IDENTITY_OK] enemy_reinforce_02 hero=zhuge_liang name=제갈량 portrait=zhuge_liang_battlefield.png click=EnemyReinforce02UnitClickArea
GRID CELL SIZE: (106.6667, 108.0)
ALLY GRID: (3, 8) ENEMY GRID: (14, 2)
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_01 hero_id=yi_sunsin display_name=이순신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_02 hero_id=jeong_dojeon display_name=정도전 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_main_03 hero_id=kwon_yul display_name=권율 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_01 hero_id=gim_yusin display_name=김유신 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=ally slot=ally_reinforce_02 hero_id=eulji_mundeok display_name=을지문덕 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_01 hero_id=guan_yu display_name=관우 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_02 hero_id=zhang_fei display_name=장비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_main_03 hero_id=xiahou_dun display_name=하후돈 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_01 hero_id=liu_bei display_name=유비 active=true reason=sample_fallback
[ROSTER_PANEL_SLOT] source=sample_battle side=enemy slot=enemy_reinforce_02 hero_id=zhuge_liang display_name=제갈량 active=true reason=sample_fallback
BATTLE UNIT STATE ADAPTER:
ally_count=5 enemy_count=5 all_count=10 legacy_keys=["ally_main", "ally_support", "enemy_main", "enemy_support"] capacity_keys=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02", "enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
HP TROOP RUNTIME VISIBILITY:
ally_main token_global=(372.0, 909.0001) hp_ref=true troop_ref=true hp_local=(326.0, 955.0) troop_local=(326.0, 964.0) hp_global=(326.0, 955.0) troop_global=(326.0, 964.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=94 / 94 hp_value=94.0 hp_max=94.0 root_visible=true token_visible=true
ally_support token_global=(585.3334, 801.0001) hp_ref=true troop_ref=true hp_local=(539.3333, 847.0) troop_local=(539.3333, 856.0) hp_global=(539.3333, 847.0) troop_global=(539.3333, 856.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=60 / 60 hp_value=60.0 hp_max=60.0 root_visible=true token_visible=true
enemy_main token_global=(1546.667, 262.0) hp_ref=true troop_ref=true hp_local=(1499.0, 305.0) troop_local=(1498.667, 312.0) hp_global=(1499.0, 305.0) troop_global=(1498.667, 312.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=100 / 100 hp_value=100.0 hp_max=100.0 root_visible=true token_visible=true
enemy_support token_global=(1333.333, 370.0) hp_ref=true troop_ref=true hp_local=(1285.667, 413.0) troop_local=(1285.333, 420.0) hp_global=(1285.667, 413.0) troop_global=(1285.333, 420.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=80 / 80 hp_value=80.0 hp_max=80.0 root_visible=true token_visible=true
ally_main_03 token_global=(480.6667, 691.0001) hp_ref=true troop_ref=true hp_local=(434.6667, 737.0) troop_local=(434.6667, 746.0) hp_global=(434.6667, 737.0) troop_global=(434.6667, 746.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=72 / 72 hp_value=72.0 hp_max=72.0 root_visible=true token_visible=true
enemy_main_03 token_global=(1434.0, 476.0) hp_ref=true troop_ref=true hp_local=(1386.333, 519.0) troop_local=(1386.0, 526.0) hp_global=(1386.333, 519.0) troop_global=(1386.0, 526.0) hp_visible=true troop_visible=true hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=76 / 76 hp_value=76.0 hp_max=76.0 root_visible=true token_visible=true
ally_reinforce_01 token_global=(370.6667, 983.0001) hp_ref=true troop_ref=true hp_local=(324.6667, 1065.0) troop_local=(324.6667, 1074.0) hp_global=(324.6667, 1029.0) troop_global=(324.6667, 1038.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=64 / 64 hp_value=64.0 hp_max=64.0 root_visible=false token_visible=false
enemy_reinforce_01 token_global=(1547.0, 150.0) hp_ref=true troop_ref=true hp_local=(1499.333, 193.0) troop_local=(1499.0, 200.0) hp_global=(1499.333, 193.0) troop_global=(1499.0, 200.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=68 / 68 hp_value=68.0 hp_max=68.0 root_visible=false token_visible=false
ally_reinforce_02 token_global=(195.6667, 827.0001) hp_ref=true troop_ref=true hp_local=(149.6667, 873.0) troop_local=(149.6667, 882.0) hp_global=(149.6667, 873.0) troop_global=(149.6667, 882.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=62 / 62 hp_value=62.0 hp_max=62.0 root_visible=false token_visible=false
enemy_reinforce_02 token_global=(1712.0, 328.0) hp_ref=true troop_ref=true hp_local=(1664.333, 371.0) troop_local=(1664.0, 378.0) hp_global=(1664.333, 371.0) troop_global=(1664.0, 378.0) hp_visible=false troop_visible=false hp_alpha=0.80000001192093 troop_alpha=1.0 hp_z=8 troop_z=20 hp_size=(96.0, 9.0) troop_size=(96.0, 20.0) troop_text=66 / 66 hp_value=66.0 hp_max=66.0 root_visible=false token_visible=false
[Battle] No WorldMap battle context; using test battle setup
UNIT VISUAL ROOT SLOTS:
ally_main cache=true root=true token=true click=true ready=true facing=true dict=true
ally_support cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main cache=true root=true token=true click=true ready=false facing=true dict=true
enemy_support cache=true root=true token=true click=true ready=false facing=true dict=true
ally_main_03 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_main_03 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_01 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_01 cache=true root=true token=true click=true ready=false facing=true dict=true
ally_reinforce_02 cache=true root=true token=true click=true ready=true facing=true dict=true
enemy_reinforce_02 cache=true root=true token=true click=true ready=false facing=true dict=true
MVP SCENE SLOT SCAFFOLD:
slot_container_found_count=6 capacity_scene_slot_path_count=10
ally_main_03=true ally_reinforce_01=true ally_reinforce_02=true enemy_main_03=true enemy_reinforce_01=true enemy_reinforce_02=true
CAPACITY SLOT REGISTRY:
capacity_slot_count=20 ally_active=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy_active=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] ally_deployed=["ally_main_01", "ally_main_02", "ally_main_03"] enemy_deployed=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
ally_main -> ally_main_01 visual=true active=true deployed=true
ally_support -> ally_main_02 visual=true active=true deployed=true
enemy_main -> enemy_main_01 visual=true active=true deployed=true
enemy_support -> enemy_main_02 visual=true active=true deployed=true
UNIT STATE VISUAL BINDINGS:
ally_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_support state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_main_03 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_01 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ally_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
enemy_reinforce_02 state=true alive=true hp_ref=true troop_ref=true visual_nodes=6
ADAPTER ALIVE PARITY SNAPSHOT:
adapter_alive_ally_count=3 adapter_alive_enemy_count=3 fallback_alive_ally_count=3 fallback_alive_enemy_count=3 all_alive_count=6
active_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_capacity_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"] parity_ok=true
ACTOR TARGET ADAPTER SNAPSHOT:
actor_candidates_ally_count=3 actor_candidates_enemy_count=3 target_candidates_for_ally_actor_count=3 target_candidates_for_enemy_actor_count=3
auto_target_parity_ok=true enemy_ai_target_parity_ok=true enemy_actor_order_parity_ok=true
DEPLOYED ACTIVE FILTER SNAPSHOT:
capacity_active_slots ally=["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"] deployed_slots ally=["ally_main_01", "ally_main_02", "ally_main_03"] enemy=["enemy_main_01", "enemy_main_02", "enemy_main_03"]
actor_candidates ally=3 enemy=3 target_candidates ally=3 enemy=3 all_alive_deployed_count=6 phase=ally_turn parity_ok=true
[ISO_PRODUCTION] primary ally cache synced unit=(342.8571, 462.8572) portrait=(372.5238, 432.8572)
[ISO_PRODUCTION] ISO_PRODUCTION_V1 active · BattleIsoGridProjection 18x10 top_left=(0.0, 0.0) bottom_right=(1920.0, 1080.0) diamond_size=(137.1429, 77.14286) basis_x=(68.57143, 38.57143) basis_y=(-68.57143, 38.57143)
[BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 1 texture=round_toast_ink_war_01.png queue_remaining=0
[BATTLE_INTRO_CAMERA] battle_intro_camera_zoom_begin
[BATTLE_INTRO_CAMERA] complete source=skip_input
[ROLLBACK] snapshot stored unit=이순신 cell=(2, 2)
[MOVE_FINISH] ally=(2, 4) enemy=(14, 6) dist=14 ally_range=3 enemy_range=1
ALLY MOVED grid_cell: (2, 4) target_cell: (2, 4)
ENTER FACING SELECT
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(64.0, 64.0)
[RIGHT_CLICK_CANCEL] phase=facing_select
[ROLLBACK] phase=facing_select
[ROLLBACK] unit=이순신 cell=(2, 2)
[ROLLBACK] restored unit=이순신 grid=(2, 2)
[MOVE_ORACLE] FAIL: M4 last_action deliberately NOT restored
[D5_CAMERA_HANDOFF] focused active ally after automatic turn return
[BATTLE_MOVE_ORACLE] STOP: actual controller case failed: M4
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```
