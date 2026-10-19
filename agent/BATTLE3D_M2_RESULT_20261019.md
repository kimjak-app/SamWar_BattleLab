# M2-3D 3D Engine Attack Connect — 구현 및 로컬 검증 보고

기준: `integration/p1-engine-core-20261019` @ `afe03675b5abe0918951676f770a1c1516f6cd1a`.
브랜치: `feature/battle3d-m2-engine-attack-20261019`. 로컬 커밋만, push 금지.
전체 설계 v1.1 M2 기여. M0~M6 독립 전투 완주 / M7 월드맵 왕복 분리.

## 착수 전 점검

원본 M1-b 실행 및 런타임 조회에서 10개 모두 표시됐으나 배치 판정은 6개였다.

| ID | 슬롯 | 셀 | 엔진 배치·생존 | 기존 3D 표시 |
|---|---|---|---|---|
| yi_sunsin | ally_main_01 | (3,8) | true | true |
| jeong_dojeon | ally_main_02 | (5,7) | true | true |
| gwon_yul | ally_main_03 | (4,6) | true | true |
| ally_reinforce_01_demo | ally_reinforce_01 | (3,9) | false | true |
| ally_reinforce_02_test_unit | ally_reinforce_02 | (1,7) | false | true |
| guan_yu | enemy_main_01 | (14,2) | true | true |
| zhang_fei | enemy_main_02 | (12,3) | true | true |
| xiahou_dun | enemy_main_03 | (13,4) | true | true |
| enemy_reinforce_01_demo | enemy_reinforce_01 | (14,1) | false | true |
| enemy_reinforce_02_test_unit | enemy_reinforce_02 | (16,3) | false | true |

- 2D `_input`은 attack_select 중 적만 후보로 삼고 아군/빈 칸은 안내 후 단계 유지. 우클릭만 취소.
- `try_basic_attack()` 거절 관찰: 이동 총병/행동 완료는 ally_turn 유지, 적 턴은 enemy_turn 유지, 연출 중은 ally_turn+animating 유지.
- 종료 경로 소스 확인: `_handle_battle_end_guard`는 진행 중단/토스트 정리. 결과 영상·토스트는 숨은 2D에서 처리. 월드맵 버튼은 context가 있어야 표시되고 사용자 클릭 시에만 복귀. 단독 Lab은 context 없음. 전멸/승패 자동 실행 금지 유지, M5 미연결 안내 표시.
- 적 공격/이동 후 공격/혼란 무행동을 실제 Tween으로 각각 관찰: 셀 일치, 배치 부대 겹침 없음, 다음 아군 jeong_dojeon 자동 선택.
- 공격 선택 중 root 좌/우클릭이 숨은 2D로 새지 않음. 3D 카메라 유지.
- 원문 및 기존 화면: 외부 `M2_3D_Evidence/preflight_complete.txt`, `preflight_visible_reinforcements.png`.

## 지시서 대비 추가 승인 항목

김작 직접 승인(2026-10-19): 대상 `BattleUnitState.is_defending` 읽기를 대상 정보 패널에만 추가. 14필드 어댑터·엔진 불변. 피해 예측/감소 계산 없음; 피해는 `attack_resolved` 값만 표시. validator 읽기 목록과 대입 금지에 명시. A8 방어 패널 검증.

김작 추가 승인: 기본 배치의 먼 거리와 M3 대기/턴 진행 미연결 때문에 첫 공격 접근이 불가능하므로, 가까운 검증 배치의 별도 3D 체험 진입점을 제공. `tests/scripts/test_battle3d_engine_attack_manual.gd`가 관찰 전 기존 골든 A6b 초기값만 설정하고 이후 입력은 기존 3D 씬/일반 host로 전달한다. 기본 씬·엔진·원본 데이터는 불변. 창에 검증 배치임을 명시. 대화형 실행이므로 CI 무한 대기 방지를 위해 워크플로 목록에는 넣지 않으며 `-- --check`로 초기 상태의 골든 동일성을 검증한다.

김작 추가 승인: 자동 화면 조작 생략. 직접 실행 결과 “F키 누르면 공격함. 공격동작은 없지만 수치적으로 줄어들어.”를 확인했으며, 이후 “자동화면조작은 안해도 돼. 내가 직접 했으니까.”라고 지시했다. 이 증거는 F키 공격 흐름과 병력 감소에 한정한다. 다른 수동 항목 전체 통과나 자동 화면 캡처 완료를 의미하지 않는다.

## 기능 상태 / UI 상태

- 실제 엔진의 일반 공격 요청, 실제 Tween 종료, 적 자동 행동 후 다음 아군 선택을 3D에 연결했다. 피해·사거리·AI 계산은 엔진에 맡긴다.
- 공격 버튼/F, 주황 사거리, 유효 적 강조, 대상 정보(방어 여부 포함), 피해 숫자·각도·로그, 행동 잠금/거절/취소 안내를 추가했다.
- 미배치 증원과 사망 부대는 엔진 판정으로 숨기고, 병력 라벨·표시 병사 수·위치·선택 링을 동기화한다. 표시 병사 수와 실제 병력은 별개다.
- 이동/공격 이벤트 커서는 독립적이다. 적 행동은 상태 차이로 요약하고 최종 셀에 즉시 맞춘다.
- host 변경은 테스트 관찰자를 트리 진입 전에 붙일 수 있는 create_battle 팩토리 분리뿐이다. 기존 입력 격리·인트로 생략·오디오 정리를 유지했다.
- 컨트롤러·서비스·골든·14필드 어댑터·기존 M1 통합 테스트는 수정하지 않았다. 워크플로는 validator 1줄과 테스트 5줄 추가만 했다.

## 실제 조작 증거 / 체험 방법

사용자 직접 체험으로 F키 공격과 병력 감소를 확인했다. 자동 데스크톱 조작은 사용자 지시로 생략했다. 최종 화면 캡처/시연 영상은 이번 종료 자료에 없으며, preflight PNG는 변경 전 M1 화면이다.

별도 가까운 A6b 검증 배치 실행:

```powershell
godot --path . --rendering-method gl_compatibility --script res://tests/scripts/test_battle3d_engine_attack_manual.gd -- --case=A6b
```

아군 선택 → 이동할 셀 선택 → 방향 확정 → 공격 버튼/F → 강조된 적 선택. F는 공격 대상 선택 모드 진입이다. 우클릭으로 취소한다. 기본 먼 배치와 원본 데이터는 변경하지 않았다. 외부 Launch_M2_3D_Attack.cmd로도 실행할 수 있다. 테스트 진입점의 `-- --check` 초기 골든 일치 검사는 exit 0이었다.

## 자동 검증 결과

Windows Godot 4.6.2 기준 워크플로 validator 32개와 Godot 테스트 64개 모두 exit 0. import, editor parse, CI 씬 로드 3종과 diff 검사도 통과했다. 아래 6개는 최종 런타임/테스트와 동일한 직전 실행 증거를 재사용했다(표에 표시). 이후 변경은 validator와 보고서뿐이다.

신규 5개 테스트: shard1 1122, shard2 1123, shard3 1115, rejections 110, sync 364 — 합계 3834 checks. 기존 M1 통합 144 checks도 수정 없이 통과. 신규 테스트는 각각 14초 미만이었다.

골든 SHA-256 불변:

```text
attack d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c
move   b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd
```

전체 명령은 full_regression.json, 원문 stdout/stderr는 같은 이름의 txt에 보존했다. Godot 명령별 timeout은 120초다.

| 검사 | exit | 초 | 직전 동일 코드 증거 재사용 |
|---|---:|---:|---|
| full_import | 0 | 6.4 |  |
| validate_worldmap_main_integrity | 0 | 0.15 |  |
| validate_worldmap_diplomacy_controller_extraction | 0 | 1.17 |  |
| validate_worldmap_diplomacy_routing | 0 | 3.15 |  |
| validate_worldmap_diplomacy_service_separation | 0 | 0.65 |  |
| validate_worldmap_trade_routing | 0 | 0.53 |  |
| validate_worldmap_trade_controller_extraction | 0 | 0.56 |  |
| validate_worldmap_trade_phase2_extraction | 0 | 0.23 |  |
| validate_worldmap_spy_routing | 0 | 0.76 |  |
| validate_worldmap_spy_controller_extraction | 0 | 0.74 |  |
| validate_worldmap_battle_settlement_applier_extraction | 0 | 0.22 |  |
| validate_worldmap_t03_strategic_battle_transaction_extraction | 0 | 0.24 |  |
| validate_worldmap_t03_battle_presentation_extraction | 0 | 0.63 |  |
| validate_worldmap_player_attack_deployment_service_extraction | 0 | 0.77 |  |
| validate_worldmap_wounded_recovery_service_extraction | 0 | 0.23 |  |
| validate_worldmap_to_battle_input_lifecycle | 0 | 0.12 |  |
| validate_b0b_battle_production_skeleton | 0 | 0.11 |  |
| validate_b0c_battle_iso_promotion | 0 | 0.13 |  |
| validate_b1b_battle_movement_query_service | 0 | 0.28 |  |
| validate_b1c_battle_combat_query_service | 0 | 0.23 |  |
| validate_b1d_battle_damage_formula_service | 0 | 0.21 |  |
| validate_b1e_battle_action_lock_state_service | 0 | 0.33 |  |
| validate_b1f_battle_enemy_ai_reservation_state_service | 0 | 0.26 |  |
| validate_b1g_battle_unique_skill_cooldown_state_service | 0 | 0.22 |  |
| validate_battle_s1_1_observation_baseline | 0 | 0.9 |  |
| validate_battle_s2_1_attack_baseline | 0 | 0.69 |  |
| validate_battle_s2_2_attack_state_service | 0 | 2.46 |  |
| validate_battle_s1_2_ally_move_state_service | 0 | 1.71 |  |
| validate_battle3d_m1b_engine_move | 0 | 0.71 |  |
| validate_battle3d_m2_engine_attack | 0 | 1.19 |  |
| validate_battle3d_contract | 0 | 0.14 |  |
| validate_alternating_battle_action_order | 0 | 0.14 |  |
| validate_single_side_exhaustion_turn_order | 0 | 0.13 |  |
| test_worldmap_city_administration_service_extraction | 0 | 0.41 |  |
| test_worldmap_city_resource_service_extraction | 0 | 0.5 |  |
| test_worldmap_city_detail_presentation_extraction | 0 | 0.5 |  |
| test_worldmap_camera_controller_extraction | 0 | 0.5 |  |
| test_worldmap_hud_controller_extraction | 0 | 0.52 |  |
| test_worldmap_shared_ui_controller_extraction | 0 | 0.5 |  |
| test_world_calendar_service_extraction | 0 | 0.52 |  |
| test_world_turn_economy_service_extraction | 0 | 0.5 |  |
| test_world_turn_state_service_extraction | 0 | 0.5 |  |
| test_worldmap_turn_controller_extraction | 0 | 0.5 |  |
| test_battle_movement_query_service | 0 | 4.41 |  |
| test_battle_combat_query_service | 0 | 4.33 |  |
| test_battle_damage_formula_service | 0 | 4.16 |  |
| test_battle_action_lock_state_service | 0 | 4.28 |  |
| test_battle_enemy_ai_reservation_state_service | 0 | 4.07 |  |
| test_battle_unique_skill_cooldown_state_service | 0 | 4.16 |  |
| test_battle_event_log_service | 0 | 0.52 |  |
| test_battle_state_fingerprint_service | 0 | 0.62 |  |
| test_battle_attack_oracle_shard_1 | 0 | 44.62 |  |
| test_battle_attack_oracle_shard_2 | 0 | 34.71 |  |
| test_battle_attack_state_service | 0 | 0.62 |  |
| test_battle_attack_event_parity | 0 | 39.09 |  |
| test_battle_move_oracle_baseline | 0 | 21.46 |  |
| test_battle_ally_move_state_service | 0 | 0.51 |  |
| test_battle_ally_move_event_parity | 0 | 7.77 |  |
| test_battle3d_engine_move_integration | 0 | 7.76 | 예 |
| test_battle3d_engine_attack_shard_1 | 0 | 10.96 | 예 |
| test_battle3d_engine_attack_shard_2 | 0 | 11.21 | 예 |
| test_battle3d_engine_attack_shard_3 | 0 | 11.01 | 예 |
| test_battle3d_engine_attack_rejections | 0 | 13.61 | 예 |
| test_battle3d_engine_attack_sync | 0 | 12.89 | 예 |
| test_battle3d_movement_parity | 0 | 1.81 |  |
| test_battle3d_modes | 0 | 0.88 |  |
| test_battle3d_oblique_click | 0 | 7.0 |  |
| alternating_battle_action_order_test | 0 | 0.51 |  |
| test_single_side_exhaustion_turn_order | 0 | 3.47 |  |
| test_worldmap_domestic_tech_catalog_extraction | 0 | 8.2 |  |
| test_worldmap_domestic_tech_research_rules_extraction | 0 | 0.5 |  |
| test_worldmap_domestic_tech_research_service_extraction | 0 | 0.87 |  |
| test_worldmap_domestic_tech_effect_provider_extraction | 0 | 0.59 |  |
| test_worldmap_domestic_tech_tree_presentation_extraction | 0 | 2.82 |  |
| test_worldmap_domestic_tech_completion_presentation_extraction | 0 | 0.87 |  |
| test_worldmap_military_controller_extraction | 0 | 5.39 |  |
| test_worldmap_enemy_warfare_service_extraction | 0 | 5.53 |  |
| test_worldmap_battle_context_service_extraction | 0 | 5.68 |  |
| test_worldmap_battle_result_service_extraction | 0 | 5.69 |  |
| test_worldmap_battle_settlement_applier_extraction | 0 | 0.5 |  |
| test_worldmap_t03_strategic_battle_transaction_extraction | 0 | 0.5 |  |
| test_worldmap_t03_battle_presentation_extraction | 0 | 0.5 |  |
| test_worldmap_player_attack_deployment_service_extraction | 0 | 0.5 |  |
| test_worldmap_troop_rebalance_service_extraction | 0 | 0.5 |  |
| test_worldmap_wounded_recovery_service_extraction | 0 | 0.51 |  |
| test_worldmap_diplomacy_routing | 0 | 20.17 |  |
| test_worldmap_diplomacy_controller_extraction | 0 | 0.98 |  |
| test_worldmap_diplomacy_validation_extraction | 0 | 6.27 |  |
| test_worldmap_diplomacy_mutation_extraction | 0 | 5.8 |  |
| test_worldmap_diplomacy_state_extraction | 0 | 5.39 |  |
| test_worldmap_diplomacy_alliance_extraction | 0 | 5.62 |  |
| test_worldmap_trade_routing | 0 | 17.47 |  |
| test_worldmap_trade_controller_extraction | 0 | 5.53 |  |
| test_worldmap_trade_automation_extraction | 0 | 5.77 |  |
| test_worldmap_internal_trade_transfer_extraction | 0 | 5.03 |  |
| test_worldmap_spy_routing | 0 | 20.27 |  |
| test_worldmap_spy_controller_extraction | 0 | 6.34 |  |
| full_parse | 0 | 5.64 |  |
| _ci_worldmap_scene_load | 0 | 3.78 |  |
| _ci_battle_main_scene_load | 0 | 2.27 |  |
| _ci_imjin_iso_scene_load | 0 | 2.91 |  |
| full_diff_check | 0 | 0.09 |  |

## 변조 7종 원문

별도 복사본에서 수행하고 원복했다. 정상 대조군 exit 0, 변조 7종 모두 exit 1이며 구문 오류로 실패한 경우는 없다.

### control — exit 0, 12.05초

```text
control PASS
```

### ally_filter_removed — exit 1, 3.8초

```text
[ATTACK_ORACLE] FAIL ally all 40 fields/controller/events unchanged
[ATTACK_ORACLE] FAIL ally visible rejection
[ATTACK_ORACLE] FAIL ally selection preserved
[ATTACK_ORACLE] FAIL ally target function never called
[ATTACK_ORACLE] FAIL ally no damage presentation
[ATTACK_ORACLE] FAIL ally no action event
```

### direct_troop_write — exit 1, 5.49초

```text
[ATTACK_ORACLE] FAIL A1 golden requested ["units.units"]
[ATTACK_ORACLE] FAIL A1 golden animating ["units.units"]
[ATTACK_ORACLE] FAIL A1 golden finished_before_enemy ["units.units"]
[ATTACK_ORACLE] FAIL A1 golden finished_after_enemy_start ["units.units"]
[ATTACK_ORACLE] FAIL A1 golden after_enemy_callback ["units.units"]
[ATTACK_ORACLE] FAIL A1 golden after_enemy_slot ["units.units"]
```

### range_plus_one — exit 1, 6.72초

```text
[ATTACK_ORACLE] FAIL A1 exact engine range cells
[ATTACK_ORACLE] FAIL A1 rendered range exact cells
```

### visibility_filter_removed — exit 1, 11.69초

```text
[ATTACK_ORACLE] FAIL standard deployment deployed/live visible set
[ATTACK_ORACLE] FAIL four standard reinforcements initially hidden
[ATTACK_ORACLE] FAIL wait initial deployed/live visible set
[ATTACK_ORACLE] FAIL wait result deployed/live visible set
```

### enemy_input_lock_removed — exit 1, 9.93초

```text
[ATTACK_ORACLE] FAIL enemy_lock no engine command during locked phase
[ATTACK_ORACLE] FAIL enemy_lock explicit lock reason
[ATTACK_ORACLE] FAIL enemy_lock all 40 fields/controller/events unchanged
[ATTACK_ORACLE] FAIL enemy_lock visible rejection
```

### enemy_reconcile_removed — exit 1, 6.88초

```text
[ATTACK_ORACLE] FAIL after_enemy_callback cell guan_yu
```

### damage_consumed_twice — exit 1, 6.06초

```text
[ATTACK_ORACLE] FAIL A1 damage display once at request
[ATTACK_ORACLE] FAIL A1 repeated polling cannot duplicate damage
```

validator의 단순/복합/인덱스/set/set_deferred 상태 쓰기 금지도 별도 검사했다. 원문은 validator_write_probes.txt.

## 실패 수정 및 제한

- 초기 sandbox Godot 시작이 스크립트 진입 전 signal 11로 두 번 실패했다. 같은 명령을 sandbox 밖에서 실행한 뒤 정상 진행했다. 환경 문제의 근본 원인 해결을 주장하지 않는다.
- 초기 신규 rejections/sync의 최상위 하니스 preload는 autoload 이전 로딩으로 GameSession 컴파일 오류를 냈다. 기존 오라클 방식처럼 실행 시점 동적 로드로 수정한 뒤 통과했다. 초기 실패 원문은 rejections_initial_compile_failure.txt에 남겼다.
- 기존 씬의 중복 UID 경고, 일부 기존 테스트 종료 시 ObjectDB/resource 잔존 메시지는 남아 있다. exit 0과 스크립트/구문 오류 없음으로 통과를 판정했으며, 경고가 없는 실행이라고 주장하지 않는다.
- Linux·원격 CI는 실행하지 않았다. 클코치 G0~G4 독립 검수(무작위 공격 24건 포함)는 미실행이다.

## 남은 연결 / 다음 단계

공격하는 병사 모델의 동작 애니메이션은 없다. 적 이동·공격 경로 연출과 적 이벤트, 대기/턴 흐름은 M3, 방어·책략·스킬·증원 UI는 M4, 승패 결과·새 전투는 M5에 남는다. M0~M6 한 판 완주 전체가 완료된 것은 아니다. 월드맵 왕복은 M7로 분리한다.

이번 변경은 아군 공격을 막는 입력 경계, 가시성, 이벤트 소비를 포함하므로 integration 병합 전에 클코치 독립 검수를 권장한다. push/병합은 하지 않았다.

## Git / 검수 자료

구현과 validator TIP 고정/최종 보고를 별도 로컬 커밋으로 남긴다. 최종 커밋 해시, git diff --name-status afe0367..HEAD 원문은 검수 ZIP의 GIT_FINAL.txt에 기록한다. 검수 ZIP에는 전체 명령 목록, 원문 로그, 변조 스크립트/결과 및 패치를 포함한다.
