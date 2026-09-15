# M-9 출정·보급·병력 재배치 분리 감사

## 기준선과 이동 전 호출 구조

- 시작 기준은 M-8 `531123f81331a3b97924f6dc55b2fca50d5bc869`이며, 시작 시 local/origin은 `0 ahead / 0 behind`, working tree는 clean이었다. 따라서 M-8은 이미 remote에 보존되어 별도 push가 필요하지 않았다.
- 플레이어 수동 공격은 `_open_player_attack_deployment`가 payload를 UI에 전달하고, `_confirm_player_attack_deployment`가 validation → `BattleContextService` context 생성 → 공격/방어 도시 병력 선차감 → 보급 지불 → 출정 장수 이동 → pending context/snapshot → battle scene handoff를 순서대로 수행했다.
- handoff 실패 시 `_rollback_player_attack_handoff`가 공격/방어 도시 병력, 적재 자원, 장수 주둔 상태를 복구했다.
- 자동 병력 재배치는 `_calculate_troop_rebalance_suggestions`가 supply role별 목표 주둔 병력을 계산하고, `_apply_troop_rebalance_suggestion`이 M-1 병력 이동 wrapper를 호출했다.

## 서비스 경계와 이동 함수

두 영역은 입력, 수명, mutation 계약이 독립적이므로 하나의 거대 서비스 대신 두 `RefCounted` service로 분리했다.

| 기존 main 함수 | 이동 대상 | M-9 결과 |
|---|---|---|
| `_build_player_attack_deployment_payload` | payload domain 값 | `PlayerAttackDeploymentService.build_payload`; 도시 표시명만 main wrapper가 추가 |
| `_get_deployable_player_heroes_for_city` | 출전 가능한 장수 계산 | `get_deployable_heroes`; thin wrapper 유지 |
| `_validate_player_attack_deployment` | 출정 validation | `validate`; main은 `error_code`를 기존 한국어 문구로 변환 |
| `_calculate_player_attack_supply_cost` | 최소 보급 계산 adapter | `calculate_supply_cost`; 기존 `ExpeditionSupplyCalculator` 재사용 |
| `_can_pay_player_attack_supply_cost` | 보유량 확인 | `can_pay_supply`; thin wrapper 유지 |
| `_pay_player_attack_supply_cost` | 자원 차감 | `pay_supply`; UI refresh만 main 유지 |
| `_move_generals_for_pending_expedition` | 출정 장수 state/location mutation | `move_generals_for_expedition`; thin wrapper 유지 |
| `_select_city_battle_supply` | 식량 선택/적재량 조회 | `select_city_battle_supply`; thin wrapper 유지 |
| `_apply_context_side_troop_pre_decrement_mvp` | 도시 병력 선차감 | `apply_context_side_pre_decrement`; thin wrapper 유지 |
| `_calculate_troop_rebalance_suggestions` | 재배치 pure rule | `TroopRebalanceService.calculate_suggestions`; 문구/state 저장은 main 유지 |
| `_apply_troop_rebalance_suggestion` | 재배치 mutation | `TroopRebalanceService.apply_suggestion`; M-1 이동 API 재사용 |

`_confirm_player_attack_deployment`와 `_rollback_player_attack_handoff`는 UI, BattleContext, pending state, snapshot, scene handoff를 연결하는 coordinator로 main에 남겼다. 실제 출정 mutation은 각각 `apply_departure`와 `rollback_departure` 한 번으로 위임한다.

## Dependency 설계

두 service 모두 scene tree나 main host를 받지 않는다. `configure(host)` 없이 query/mutation `Callable`과 상수 config만 주입한다.

- deployment query: 도시 존재/소유/병력/자원/주둔 장수, hero data/state/exclusion/지휘 한계, 공격 source/block, 해상·공성 요구와 tech unlock.
- deployment mutation: 도시 병력/자원/주둔 장수 교체, hero state 갱신, rollback 시 hero 복귀.
- rebalance query: supply city role, 아군 도시, 인구/병력, M-1 `_can_move_troops` 결과.
- rebalance mutation: M-1 `_move_troops` 호출 하나.

`BattleContextService`, `MilitaryController`, `ExpeditionSupplyCalculator`의 기존 책임을 복제하지 않았다. M-4~M-8 result/settlement/T03/recovery/presentation 파일도 변경하지 않았다.

## Deployment validation 계약

service는 display 문구 대신 structured result를 반환한다. 정상 결과에는 정규화된 `selected_hero_ids`, command/garrison 한계로 clamp한 `attacker_troop_allocation`, `total_troops`, `supply_cost`, `food_type`이 들어간다. 실패는 `error_code`, 선택적으로 `hero_id`, `resource_id`, `detail`을 반환한다.

검증 순서는 공격 block/source/route unlock → 선택 장수 존재 및 출전 가능 상태 → 장수별 command limit 및 병력 allocation → 최소 주둔 병력 → food type → 최소 식량/금 → 실제 도시 보유량이다. 기존 UI 문구는 main `_format_player_attack_deployment_error`가 결정한다.

## 보급 계산·지불 계약

- 최소 식량/금은 기존 `ExpeditionSupplyCalculator.minimum_food/minimum_gold`가 계산한다.
- service는 선택 food type과 rice/barley/seafood, gold, salt 실제 보유량을 확인하고 도시 resource stock을 한 번 교체한다.
- validation은 read-only이고 payment와 분리되어 있다.
- `apply_departure`는 handoff용 non-empty `transaction_id`를 요구하며 `_paid_transaction_ids`와 `_applied_transaction_ids`로 같은 runtime transaction의 이중 지불/이중 출정을 no-op 처리한다.
- snapshot은 기존과 같이 payment 및 출정 mutation이 끝난 뒤 생성된다.

## 병력 선차감과 rollback

mutation 순서는 affordability 재확인 → attacker 선차감 → defender 선차감 → cargo 지불 → 장수 출정 상태 적용이다. context의 기존 `troop_deployed_from_city`와 `defender_troop_deployed_from_city`가 각 side의 중복 선차감을 막으며, before/after troop snapshot을 그대로 보존한다.

battle scene handoff 실패 시 main coordinator가 `rollback_departure`를 호출한다. service는 저장된 before troop, 실제 paid cargo, 출정 장수를 원 source city로 복구하고 `_rolled_back_transaction_ids`로 같은 rollback의 중복 적용을 막는다. 이는 현재 플레이어 공격에 필요한 최소 runtime guard이며 새 persistence/범용 transaction framework는 추가하지 않았다. 기존 legacy wrapper 테스트처럼 transaction ID 없이 전달되는 context도 종전 rollback 동작을 유지한다.

## 출정 장수 이동 경계

선택 장수만 source city 주둔 배열에서 제거하고 `current_city_id`, `city_id`, `location_city_id`를 비우며 `status=deployed`로 변경한다. 실패 rollback은 기존 main adapter를 통해 source city로 복귀시킨다. generic 도시 간 이동, 전투 settlement 이동/faction, occupation index 및 전체 hero-location sync는 건드리지 않았다.

## Troop rebalance 경계

`calculate_suggestions`는 supply service가 만든 city role snapshot과 인구/병력 query로 후방 surplus와 frontline shortage를 짝짓는 pure calculation이다. suggestion 문구와 `_player_state.last_troop_rebalance_suggestions` 저장은 main의 presentation/coordinator 책임으로 남았다. `apply_suggestion`은 입력과 M-1 `_can_move_troops`를 재확인한 뒤 `_move_troops` adapter를 호출하므로 최소 주둔/소유/인접 규칙을 다시 정의하지 않는다.

## Main에 남긴 coordinator

공격 버튼과 deployment panel open/close, 상태 문구, HUD refresh, `BattleContextService` 호출, pending context, serialized snapshot, camera handoff, scene transition과 save lifecycle은 main이 계속 소유한다. service는 UI node, SFX, save, scene transition을 알지 못한다.

## M-1~M-9 최종 구조

1. Military administration: `military_controller.gd`.
2. Enemy warfare: `enemy_warfare_service.gd`.
3. Battle context: `battle_context_service.gd`.
4. Battle result: `battle_result_service.gd`.
5. Battle settlement: `battle_settlement_applier.gd`.
6. T03 strategic transaction: `strategic_battle_transaction_service.gd`와 기존 resolver.
7. Wounded/recovery: `wounded_recovery_service.gd`.
8. T03 battle presentation: `t03_battle_presentation_controller.gd`.
9. Player deployment/supply: `player_attack_deployment_service.gd`.
10. Troop rebalance: `troop_rebalance_service.gd`, 실제 이동은 M-1 controller 재사용.

## Main 잔여 군사 함수 최종 분류

### A. 정상 coordinator/wrapper

`_start_player_attack_battle`, `_open_player_attack_deployment`, `_confirm_player_attack_deployment`, `_on_player_attack_deployment_confirmed`, `_on_player_attack_deployment_cancelled`, `_open_defense_deployment_panel_from_pending_invasion`, `_confirm_defense_deployment`, `_build_player_attack_battle_context`, `_handoff_battle_context_to_battle_scene`, `_change_scene_to_battle_with_context`, `_rollback_player_attack_handoff`, `_consume_worldmap_battle_result_if_any`, `_apply_returned_battle_result_mvp`와 M-1~M-9 compatibility wrappers.

### B. Generic world/hero adapter

`_get_available_player_attack_main_hero_ids`, `_get_existing_hero_runtime_state`, `_normalize_hero_runtime_state`, `_set_hero_runtime_city`, `_ensure_hero_in_city_runtime_roster`, `_remove_hero_from_other_city_runtime_rosters`, `_set_city_runtime_troops`, `_set_city_runtime_stationed_hero_ids`, `_ensure_city_supply_resource_defaults`, `_get_city_supply_resource_amount`, `_get_world_city_troop_total`.

### C. Hero/Occupation cross-domain tail

`_transfer_stationed_hero_between_player_cities`, `_apply_battle_settlement_move_hero`, `_apply_battle_settlement_hero_faction`, `_rebuild_occupation_runtime_indexes_mvp`, `_sync_worldmap_hero_locations_from_city_runtime_states`, `_is_hero_captured_for_battle`, `_get_hero_battle_exclusion_reason`.

### D. 아직 남은 순수 military domain

없음. M-8에서 D였던 11개 함수는 service delegate wrapper 또는 main presentation/coordinator로 전환됐다. C 항목은 Hero/Occupation cross-domain 후속 영역이며 군사 핵심 계산/transaction은 아니다.

따라서 “M-1~M-9 군사/전투 핵심 도메인 분리 완료”로 판정한다. C-tail은 별도 Hero/Occupation 작업으로 이관하고, 다음 대형 감사 영역은 Tech Tree T-0이다.
