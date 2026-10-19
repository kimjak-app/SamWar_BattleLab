# S2-1 공격 관찰 기준 / B3D-F2 결과 — 2026-10-19

기준: `2ba04645f7736fbee3a0eecd8a9ef0a38ef13b02`
브랜치: `test/s2-1-attack-observation-baseline-20261019`. 로컬 커밋만, push 없음.
전체 설계 v1.1의 M2 준비 단계. S2-2 공격 상태/이벤트 분리와 M2-3D 공격 연결은 미착수. 플레이 기능은 기존 M1-b 그대로다.

## 범위와 관찰 방법
프로덕션 scripts/**, scenes/**, project.godot, 기존 이동 골든/하니스 바이트 동일. 기존 테스트 수정은 별도 B3D-F2 커밋의 우회 경로 단언 6줄뿐. 워크플로는 호출 2줄 추가만.
실제 씬을 deferred 이후 동적 로드한다. 테스트 전용 BoundaryBattle 서브클래스는 적 행동 진입/복귀를 관찰하고 super를 즉시 정확히 한 번 호출한다. Tween과 종료 콜백은 실제로 실행하며 완료 함수를 직접 호출하지 않는다. 픽스처 상태 쓰기는 관찰 시작 전에만 수행한다.
모든 스냅샷은 10유닛×40필드와 phase/animation/pending/선택 ID/모멘텀/라운드/행동 잠금/사망 ID를 보존한다. 비결정 필드 제외 없음. 각 사례 2회 비교. 정상 공격은 자동 적 행동 종료까지 진행한다.
승패 판정 guard의 정상 false 호출은 허용하고 결과 확정 true 또는 결과 표시 경로 진입은 즉시 exit 1로 막는다. A9에서도 다른 적이 남는다.

## 감사 문서 및 지시서와의 차이 / 사용자 확정 사항
- A7의 아군 거절 가정은 사용자 정정에 따라 A7a/A7b로 분리했다. A7a: **엔진 함수는 대상 진영을 검사하지 않음(알려진 미보호 경계)**. 직접 호출 결과를 기록했으며 엔진 수정이나 평가를 하지 않았다.
- A7b: 실제 클릭 후보 함수가 사용하는 `_get_alive_enemy_units()`를 호출하여 모든 아군이 제외되고 후보가 enemy임을 확인했다. 후보는 현재 배치된 관우·장비·하후돈 3명이다. 예비 슬롯까지 포함한 전체 5명을 후보로 가정하지 않는다. 물리 마우스 클릭/입력 디스패치 시뮬레이션은 미실행이다.
- 총병 post_fire_penalty는 요청 시 {turns:1,magnitude:40}로 부여되지만 종료 시 `_mark_ally_unit_acted` → `_consume_strategy_status_after_unit_action` → `tick_status_effects`에서 제거된다. S2-0의 부여 설명에 더해 이 실제 수명도 골든에 기록했다.
- 적 행동 종료 후 다음 아군 정도전이 선택되고 ally_has_moved가 false로 재설정됨을 확인했다. A11 우클릭 취소는 ally_turn 복귀, 유닛 상태 소모 없음.
- A9 사망 ID 추가와 사망 대상의 잠금 제거를 finished_before_enemy에서 관찰했다. 공격자는 살아 있으므로 active=null 경로는 이 픽스처에서 발생하지 않았다. 이후 다음 아군 선택을 기록했다.
- M2에서 자동 적 행동을 유지한다는 사용자 승인을 따랐다. 적 선택 규칙을 새로 만들거나 평가하지 않았다.

## 쓰기 시점 표
| 시점 | 관찰된 쓰기 |
|---|---|
| 요청 직후 같은 프레임 | 대상 HP/병력 감소, attacked_this_turn, last_action(이동거리 보존), 총병 상태, 기세 변경. resolving/animating=true. has_acted는 아직 false |
| 실제 Tween 종료, 적 행동 직전 | has_acted/has_moved 및 아군 잠금, ally_has_moved=true, pending 해제, 상태 턴 소비, 사망 ID/사망 대상 잠금 정리. phase=enemy_turn |
| 적 행동 시작 직후 | 엔진의 적 행동 진입 상태를 별도 체크포인트로 보존 |
| 적 행동 후 | 엔진이 선택한 적 이동/공격/행동 잠금과 다음 아군 선택을 기록. ally_turn 복귀 |

## 사례와 체크포인트 (각 2회 동일)
| 사례 | 방향 | 체크포인트 |
|---|---|
| A1 | front | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A2_side | side | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A2_back | back | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A3 | front | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A4 | front | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A5 | front | start, attack_select, requested |
| A6 | front | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A7_range | front | start, attack_select, requested |
| A7_acted | front | start, attack_select, requested |
| A7a | front | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A7b | front | start, attack_select, input_candidates_checked |
| A8 | front | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A9 | front | start, attack_select, requested, animating, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A10 | front | start, attack_select, requested, animating, duplicate_cancel_input, finished_before_enemy, finished_after_enemy_start, after_enemy_callback, after_enemy_slot |
| A11 | front | start, attack_select, cancelled |

## 체크포인트별 실제 변경 필드
이전 체크포인트 대비. 아래는 요약이며 모든 원값은 골든에 있다.
| 사례 / 시점 | 유닛 변경 | 컨트롤러 변경 |
|---|---|---|
| A1 / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A1 / requested | yi_sunsin: attacked_this_turn, last_action; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A1 / animating | 없음 | 없음 |
| A1 / finished_before_enemy | yi_sunsin: has_acted, has_moved | acted_ally_ids: {} → {'yi_sunsin': True}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A1 / finished_after_enemy_start | 없음 | is_demo_animating: False → True |
| A1 / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A1 / after_enemy_slot | 없음 | 없음 |
| A2_side / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A2_side / requested | yi_sunsin: attacked_this_turn, last_action; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A2_side / animating | 없음 | 없음 |
| A2_side / finished_before_enemy | yi_sunsin: has_acted, has_moved | acted_ally_ids: {} → {'yi_sunsin': True}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A2_side / finished_after_enemy_start | guan_yu: facing | is_demo_animating: False → True |
| A2_side / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A2_side / after_enemy_slot | 없음 | 없음 |
| A2_back / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A2_back / requested | yi_sunsin: attacked_this_turn, last_action; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A2_back / animating | 없음 | 없음 |
| A2_back / finished_before_enemy | yi_sunsin: has_acted, has_moved | acted_ally_ids: {} → {'yi_sunsin': True}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A2_back / finished_after_enemy_start | guan_yu: facing | is_demo_animating: False → True |
| A2_back / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A2_back / after_enemy_slot | 없음 | 없음 |
| A3 / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A3 / requested | yi_sunsin: attacked_this_turn, last_action; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A3 / animating | 없음 | 없음 |
| A3 / finished_before_enemy | yi_sunsin: has_acted, has_moved | acted_ally_ids: {} → {'yi_sunsin': True}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A3 / finished_after_enemy_start | 없음 | is_demo_animating: False → True |
| A3 / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, grid_cell, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A3 / after_enemy_slot | 없음 | 없음 |
| A4 / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A4 / requested | yi_sunsin: attacked_this_turn, last_action, status_effects; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A4 / animating | 없음 | 없음 |
| A4 / finished_before_enemy | yi_sunsin: has_acted, has_moved, status_effects | acted_ally_ids: {} → {'yi_sunsin': True}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A4 / finished_after_enemy_start | 없음 | is_demo_animating: False → True |
| A4 / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, grid_cell, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A4 / after_enemy_slot | 없음 | 없음 |
| A5 / attack_select | 없음 | 없음 |
| A5 / requested | 없음 | 없음 |
| A6 / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A6 / requested | yi_sunsin: attacked_this_turn, last_action; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A6 / animating | 없음 | 없음 |
| A6 / finished_before_enemy | yi_sunsin: has_acted | acted_ally_ids: {} → {'yi_sunsin': True}; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A6 / finished_after_enemy_start | 없음 | is_demo_animating: False → True |
| A6 / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A6 / after_enemy_slot | 없음 | 없음 |
| A7_range / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A7_range / requested | 없음 | 없음 |
| A7_acted / attack_select | 없음 | 없음 |
| A7_acted / requested | 없음 | 없음 |
| A7a / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A7a / requested | yi_sunsin: attacked_this_turn, last_action; jeong_dojeon: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A7a / animating | 없음 | 없음 |
| A7a / finished_before_enemy | yi_sunsin: has_acted, has_moved | acted_ally_ids: {} → {'yi_sunsin': True}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A7a / finished_after_enemy_start | 없음 | is_demo_animating: False → True |
| A7a / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A7a / after_enemy_slot | 없음 | 없음 |
| A7b / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A7b / input_candidates_checked | 없음 | 없음 |
| A8 / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A8 / requested | yi_sunsin: attacked_this_turn, last_action; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A8 / animating | 없음 | 없음 |
| A8 / finished_before_enemy | yi_sunsin: has_acted, has_moved | acted_ally_ids: {} → {'yi_sunsin': True}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A8 / finished_after_enemy_start | 없음 | is_demo_animating: False → True |
| A8 / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A8 / after_enemy_slot | 없음 | 없음 |
| A9 / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A9 / requested | yi_sunsin: attacked_this_turn, last_action; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A9 / animating | 없음 | 없음 |
| A9 / finished_before_enemy | yi_sunsin: has_acted, has_moved | acted_ally_ids: {} → {'yi_sunsin': True}; acted_enemy_ids: {'guan_yu': True} → {}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; dead_unit_ids: {} → {'guan_yu': True}; is_demo_animating: True → False |
| A9 / finished_after_enemy_start | zhang_fei: facing | is_demo_animating: False → True |
| A9 / after_enemy_callback | jeong_dojeon: current_hp, current_troops; zhang_fei: attacked_this_turn, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'zhang_fei': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A9 / after_enemy_slot | 없음 | 없음 |
| A10 / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A10 / requested | yi_sunsin: attacked_this_turn, last_action; guan_yu: current_hp, current_troops | ally_momentum: 3 → 4; current_phase: attack_select → resolving; enemy_momentum: 3 → 2; is_demo_animating: False → True |
| A10 / animating | 없음 | 없음 |
| A10 / duplicate_cancel_input | 없음 | 없음 |
| A10 / finished_before_enemy | yi_sunsin: has_acted, has_moved | acted_ally_ids: {} → {'yi_sunsin': True}; ally_has_moved: False → True; current_phase: resolving → enemy_turn; is_demo_animating: True → False |
| A10 / finished_after_enemy_start | 없음 | is_demo_animating: False → True |
| A10 / after_enemy_callback | yi_sunsin: current_hp, current_troops; guan_yu: attacked_this_turn, has_acted, has_moved, last_action | acted_enemy_ids: {} → {'guan_yu': True}; active_unit_id: yi_sunsin → jeong_dojeon; ally_has_moved: True → False; ally_momentum: 4 → 3; current_phase: enemy_turn → ally_turn; enemy_momentum: 2 → 3; is_demo_animating: True → False |
| A10 / after_enemy_slot | 없음 | 없음 |
| A11 / attack_select | 없음 | current_phase: ally_turn → attack_select |
| A11 / cancelled | 없음 | current_phase: attack_select → ally_turn |

## 음성 프로브 원문
별도 복사본만 변조, 실행 후 원본 바이트 복구. 구문 오류가 아니라 단언/골든 비교 실패.

### damage_plus_one (A1)
exit=1, 8.94초
```text
[ATTACK_ORACLE_CASE] A1 PASS runs=2
[ATTACK_ORACLE] FAIL golden parity
[ATTACK_ORACLE] checks=16 failures=["golden parity"]
```

### acted_early (A1)
exit=1, 5.09초
```text
[ATTACK_ORACLE] FAIL A1 requested before action consumed
```

### cleanup_removed (A9)
exit=1, 7.79초
```text
[ATTACK_ORACLE_CASE] A9 PASS runs=2
[ATTACK_ORACLE] FAIL golden parity
[ATTACK_ORACLE] checks=18 failures=["golden parity"]
```

### distance_zero (A6)
exit=1, 5.08초
```text
[ATTACK_ORACLE] FAIL A6 move distance preserved
```

### B3D-F2 시작/끝 직선 변조
exit=1
```text
M1B FAIL detour playback equals engine executed path
M1B integration checks=144 failures=["detour playback equals engine executed path"]
```
정상 대조군: 144 checks, failures=[]; 기존 M1-b validator PASS.

## 전체 로컬 회귀
명령별 timeout 120초. 워크플로 기존 호출을 그대로 읽어 실행했다. 새 오라클 골든 생성 65.91초, exit=0. 원문 로그와 실행 경로는 외부 검수 묶음에 보존한다.
| 명령 | exit | 초 |
|---|---:|---:|
| `python tools/validate_worldmap_main_integrity.py` | 0 | 0.14 |
| `python tools/validate_worldmap_diplomacy_controller_extraction.py` | 0 | 1.16 |
| `python tools/validate_worldmap_diplomacy_routing.py` | 0 | 2.88 |
| `python tools/validate_worldmap_diplomacy_service_separation.py` | 0 | 0.58 |
| `python tools/validate_worldmap_trade_routing.py` | 0 | 0.5 |
| `python tools/validate_worldmap_trade_controller_extraction.py` | 0 | 0.49 |
| `python tools/validate_worldmap_trade_phase2_extraction.py` | 0 | 0.2 |
| `python tools/validate_worldmap_spy_routing.py` | 0 | 0.69 |
| `python tools/validate_worldmap_spy_controller_extraction.py` | 0 | 0.7 |
| `python tools/validate_worldmap_battle_settlement_applier_extraction.py` | 0 | 0.22 |
| `python tools/validate_worldmap_t03_strategic_battle_transaction_extraction.py` | 0 | 0.22 |
| `python tools/validate_worldmap_t03_battle_presentation_extraction.py` | 0 | 0.66 |
| `python tools/validate_worldmap_player_attack_deployment_service_extraction.py` | 0 | 0.78 |
| `python tools/validate_worldmap_wounded_recovery_service_extraction.py` | 0 | 0.24 |
| `python tools/validate_worldmap_to_battle_input_lifecycle.py` | 0 | 0.12 |
| `python tools/validate_b0b_battle_production_skeleton.py` | 0 | 0.12 |
| `python tools/validate_b0c_battle_iso_promotion.py` | 0 | 0.13 |
| `python tools/validate_b1b_battle_movement_query_service.py` | 0 | 0.28 |
| `python tools/validate_b1c_battle_combat_query_service.py` | 0 | 0.22 |
| `python tools/validate_b1d_battle_damage_formula_service.py` | 0 | 0.2 |
| `python tools/validate_b1e_battle_action_lock_state_service.py` | 0 | 0.31 |
| `python tools/validate_b1f_battle_enemy_ai_reservation_state_service.py` | 0 | 0.25 |
| `python tools/validate_b1g_battle_unique_skill_cooldown_state_service.py` | 0 | 0.22 |
| `python tools/validate_battle_s1_1_observation_baseline.py` | 0 | 0.94 |
| `python tools/validate_battle_s2_1_attack_baseline.py` | 0 | 0.64 |
| `python tools/validate_battle_s1_2_ally_move_state_service.py` | 0 | 1.65 |
| `python tools/validate_battle3d_m1b_engine_move.py` | 0 | 0.72 |
| `python tools/validate_battle3d_contract.py` | 0 | 0.15 |
| `python tools/validate_alternating_battle_action_order.py` | 0 | 0.16 |
| `python tools/validate_single_side_exhaustion_turn_order.py` | 0 | 0.14 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_city_administration_service_extraction.gd` | 0 | 0.54 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_city_resource_service_extraction.gd` | 0 | 0.55 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_city_detail_presentation_extraction.gd` | 0 | 0.56 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_camera_controller_extraction.gd` | 0 | 0.56 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_hud_controller_extraction.gd` | 0 | 0.54 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_shared_ui_controller_extraction.gd` | 0 | 0.54 |
| `godot --headless --path . --script res://tests/scripts/test_world_calendar_service_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_world_turn_economy_service_extraction.gd` | 0 | 0.54 |
| `godot --headless --path . --script res://tests/scripts/test_world_turn_state_service_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_turn_controller_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_battle_movement_query_service.gd` | 0 | 3.88 |
| `godot --headless --path . --script res://tests/scripts/test_battle_combat_query_service.gd` | 0 | 3.59 |
| `godot --headless --path . --script res://tests/scripts/test_battle_damage_formula_service.gd` | 0 | 3.59 |
| `godot --headless --path . --script res://tests/scripts/test_battle_action_lock_state_service.gd` | 0 | 3.69 |
| `godot --headless --path . --script res://tests/scripts/test_battle_enemy_ai_reservation_state_service.gd` | 0 | 3.59 |
| `godot --headless --path . --script res://tests/scripts/test_battle_unique_skill_cooldown_state_service.gd` | 0 | 3.73 |
| `godot --headless --path . --script res://tests/scripts/test_battle_event_log_service.gd` | 0 | 0.44 |
| `godot --headless --path . --script res://tests/scripts/test_battle_state_fingerprint_service.gd` | 0 | 0.52 |
| `godot --headless --path . --script res://tests/scripts/test_battle_attack_oracle_baseline.gd` | 0 | 64.91 |
| `godot --headless --path . --script res://tests/scripts/test_battle_move_oracle_baseline.gd` | 0 | 22.54 |
| `godot --headless --path . --script res://tests/scripts/test_battle_ally_move_state_service.gd` | 0 | 0.54 |
| `godot --headless --path . --script res://tests/scripts/test_battle_ally_move_event_parity.gd` | 0 | 7.48 |
| `godot --headless --path . --script res://tests/scripts/test_battle3d_engine_move_integration.gd` | 0 | 8.13 |
| `godot --headless --path . --script res://tests/scripts/test_battle3d_movement_parity.gd` | 0 | 1.95 |
| `godot --headless --path . --script res://tests/scripts/test_battle3d_modes.gd` | 0 | 0.71 |
| `godot --headless --path . --script res://tests/scripts/test_battle3d_oblique_click.gd` | 0 | 6.82 |
| `godot --headless --path . --script res://tests/scripts/alternating_battle_action_order_test.gd` | 0 | 0.44 |
| `godot --headless --path . --script res://tests/scripts/test_single_side_exhaustion_turn_order.gd` | 0 | 3.41 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_catalog_extraction.gd` | 0 | 6.51 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_research_rules_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_research_service_extraction.gd` | 0 | 0.79 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_effect_provider_extraction.gd` | 0 | 0.51 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_tree_presentation_extraction.gd` | 0 | 1.91 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_domestic_tech_completion_presentation_extraction.gd` | 0 | 0.8 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_military_controller_extraction.gd` | 0 | 4.89 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_enemy_warfare_service_extraction.gd` | 0 | 4.97 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_battle_context_service_extraction.gd` | 0 | 5.16 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_battle_result_service_extraction.gd` | 0 | 5.06 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_battle_settlement_applier_extraction.gd` | 0 | 0.43 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_t03_strategic_battle_transaction_extraction.gd` | 0 | 0.51 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_t03_battle_presentation_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_player_attack_deployment_service_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_troop_rebalance_service_extraction.gd` | 0 | 0.42 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_wounded_recovery_service_extraction.gd` | 0 | 0.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_routing.gd` | 0 | 19.53 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_controller_extraction.gd` | 0 | 1.02 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_validation_extraction.gd` | 0 | 5.16 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_mutation_extraction.gd` | 0 | 5.36 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_state_extraction.gd` | 0 | 4.97 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_diplomacy_alliance_extraction.gd` | 0 | 5.17 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_trade_routing.gd` | 0 | 16.85 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_trade_controller_extraction.gd` | 0 | 5.07 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_trade_automation_extraction.gd` | 0 | 4.97 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_internal_trade_transfer_extraction.gd` | 0 | 4.8 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_spy_routing.gd` | 0 | 20.14 |
| `godot --headless --path . --script res://tests/scripts/test_worldmap_spy_controller_extraction.gd` | 0 | 5.92 |
| `godot --headless --path . --script _ci_worldmap_scene_load.gd` | 0 | 3.31 |
| `godot --headless --path . --script _ci_battle_main_scene_load.gd` | 0 | 2.28 |
| `godot --headless --path . --script _ci_imjin_iso_scene_load.gd` | 0 | 3.51 |
| `godot --headless --editor --path . --quit` | 0 | 6.7 |

## 해시와 미실행 범위
- tests/golden/battle_attack_baseline_v0.json: `cb390e228c34f2a93f37d59cbaf5179660e460d44e778fab13cfbf1de328880d`
- tests/golden/battle_move_baseline_v0.json: `b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd`
- 원격 CI/push, 실제 마우스 입력, 3D 공격 UI, 승패/월드맵 왕복은 실행하지 않았다.
- 테스트는 일반 공격과 현재 픽스처의 적 후속 행동을 검증한다. 모든 병종·상태 조합이나 모든 AI 선택을 포괄한다고 주장하지 않는다.
- 다음 단계: 클코치 검수 후 S2-2 공격 상태/이벤트 분리. 이후 M2-3D에서 공격 명령과 적 결과 상태 동기 연결.

## 최종 재검증 및 진단 기록
- 전체 워크플로 90개 명령 모두 exit 0. 새 하니스 종료 정리 후 최종 오라클 추가 실행: 64.65초, 198 checks, failures=[], WARNING/ERROR 0건. 전체 회귀의 이전 오라클 로그도 교체하지 않고 보존했다.
- 테스트 전용 teardown에서 부모 없는 ISO projection Node를 해제하여 정상 실행 종료 경고를 제거했다. 관찰 완료 후에만 정리하며 프로덕션 수명 관리 코드는 변경하지 않았다.
- 초기에 preload로 생산 컨트롤러 클래스를 너무 일찍 읽던 하니스를 deferred 동적 load로 수정했다.
- 초기 A7 거절 단언 실패를 보고하고 사용자 정정 후 A7a/A7b로 분리했다. 최초 진단 로그도 검수 묶음에 보존했다.
- 원문 로그/negative runner/전체 회귀 runner는 외부 검수 묶음에 포함. 최종 로컬 HEAD와 diff 원문은 묶음의 GIT_FINAL.txt에 기록한다.

## 로컬 구현 커밋 / 변경 경로 원문
- B3D-F2: `71ac6dabc79f811f597400dacfd13de2cabb720e`
- S2-1 구현 및 validator 고정 대상: `ab036c6392cbf682e999fe0117b22a5a3dc5d3c8`
- 이후 커밋은 validator TIP 고정과 이 최종 보고 추가만 포함한다.

```text
M	.github/workflows/verify-c-track.yml
A	agent/BATTLE_ENGINE_S2_1_RESULT_20261019.md
A	tests/golden/battle_attack_baseline_v0.json
A	tests/scripts/support/battle_attack_oracle_harness.gd
A	tests/scripts/support/battle_attack_oracle_harness.gd.uid
M	tests/scripts/test_battle3d_engine_move_integration.gd
A	tests/scripts/test_battle_attack_oracle_baseline.gd
A	tests/scripts/test_battle_attack_oracle_baseline.gd.uid
A	tools/validate_battle_s2_1_attack_baseline.py
```
