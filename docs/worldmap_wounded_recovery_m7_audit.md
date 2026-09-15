# M-7 부상·회복 도메인 분리 감사

## 기준과 이동 전 구조

- 기준 커밋: M-6 `d2d9686c8bb9b41f00c27b227a50c0678b3ab94a`.
- `BattleSettlementApplier`의 `set_hero_status` mutation callback이 `worldmap_main.gd::_apply_battle_settlement_hero_status`에서 영웅 상태를 직접 변경했다.
- T02/T03 settlement callback은 `_add_wounded_to_city_mvp`로 도시의 부상 병력 queue를 직접 변경했다.
- `_advance_world_turn_mvp`가 월 경계를 계산한 뒤 도시 부상 병력과 영웅 부상을 서로 다른 두 함수로 진행했다.
- `_on_fast_wounded_treatment_pressed`가 소금 차감, queue 변경, UI 갱신, 저장을 한 함수에서 수행했다.

## 함수 분류와 이동 결과

| 기존 함수/블록 | 분류 | M-7 결과 |
|---|---|---|
| `_apply_battle_settlement_hero_status` | B domain mutation | service `apply_battle_hero_status`; main에는 thin wrapper 유지 |
| `_get_city_wounded_queue_mvp` | A pure normalization | service `get_city_wounded_queue`; wrapper 유지 |
| `_add_wounded_to_city_mvp` | B domain mutation | service `add_wounded_to_city`; wrapper 유지 |
| `_clear_city_wounded_queue_mvp` | B domain mutation | service `clear_city_wounded_queue`; wrapper 유지 |
| `_apply_wounded_recovery_for_world_turn_mvp` | A/B progression | service `advance_recovery_month`; wrapper 유지 |
| `_get_world_month_serial` | A recovery timing | service `world_month_serial`; wrapper 유지 |
| `_advance_wounded_hero_recovery_turns` | B progression | 통합 service progression으로 대체; wrapper 유지 |
| `_on_fast_wounded_treatment_pressed`의 치료 판정/차감/상태 변경 | A/B | service `evaluate_fast_treatment`/`apply_fast_treatment` |
| `_on_fast_wounded_treatment_pressed`의 버튼/HUD/save | C/D | main 유지 |
| `_refresh_wounded_treatment_controls` | D | main 유지, service의 구조화된 판정값만 소비 |
| `_advance_world_turn_mvp` | C | main 유지, 월 경계에서 service 한 번 호출 |

## Service dependency

`WorldMapWoundedRecoveryService`는 `RefCounted`이고 두 개의 narrow adapter만 주입받는다.

- query: hero/city 존재, hero/city snapshot, hero/city ID, 도시 병력, 도시 자원, 마지막 회복 월 serial.
- mutation: hero snapshot, 도시 wounded queue, 도시 병력/자원, 마지막 회복 월 serial, 마지막 치료 record.
- 기존 `scripts/t02/wounded_recovery.gd`의 queue 생성/월 진행 규칙과 `expedition_supply_calculator.gd`의 집중 치료 소금 비용 규칙을 재사용한다.
- Node, UI, signal, camera, scene transition, save 또는 unrestricted host 접근은 없다.

## Wounded queue 계약

도시 queue는 영웅 ID queue가 아니라 부상 병력 batch queue다. save 호환성을 위해 도시 데이터의 `woundedQueue`와 `wounded_queue`를 함께 유지한다. 정규 entry는 다음 기존 필드를 보존한다.

- `wounded_count` (`troops` 호환 필드)
- `recovery_months_remaining` (`turnsLeft` 호환 필드)
- `recovery_mode`: `normal` 또는 `fast`
- `source_transaction_id`

영웅 부상은 별도의 hero runtime state에 `status`, `wounded`, `wounded_turns_remaining`으로 저장된다. 동일한 non-legacy transaction의 동일 batch는 중복 추가하지 않는다. 회복 완료 queue entry는 제거하고, 빈 queue는 두 alias에 빈 배열로 기록한다.

## Recovery timing과 idempotency

- 일반 회복: 3개월. 집중 치료: 1개월. 밸런스 값은 변경하지 않았다.
- 40 world turn을 12개월 serial로 변환하는 기존 규칙을 service로 이동했다. `_get_world_month_serial`의 유일한 실사용자가 부상 회복 진행이었으므로 전역 calendar helper로 남기지 않았다.
- main은 world month serial이 바뀌는 경계에서 `advance_recovery_month(next_month_serial)`을 호출한다.
- `_player_state.last_wounded_recovery_month_serial`을 save 가능한 최소 marker로 사용한다. 같은 또는 이전 serial 재호출은 `duplicate=true`로 성공 처리하고 hero/queue를 다시 감소시키지 않는다.
- 영웅의 `last_battle_transaction_id`와 전투 병력 snapshot도 hero runtime save에 유지하여 reload 뒤 집중 치료의 matching이 깨지지 않게 했다.

## Fast treatment mutation 흐름

1. main callback이 `last_wounded_treatment` snapshot을 service에 전달한다.
2. service가 도시, wounded 수, 기존 fast 여부, transaction에 대응하는 queue entry와 소금 비용을 검증한다.
3. 성공할 때만 소금을 차감하고 matching queue를 `fast/1개월`로 바꾼다.
4. 같은 도시와 transaction에 연결된 wounded hero의 남은 기간도 1개월로 줄인다.
5. service는 resource delta, queue 변경, 처리된 hero ID를 구조화해 반환한다.
6. main이 버튼/힌트, HUD를 갱신하고 저장한다. service는 UI 문자열을 만들지 않는다.

## BattleSettlementApplier 연계

M-5 `BattleSettlementApplier`와 M-4 `BattleResultService`는 변경하지 않았다. casualty 또는 hero outcome을 재계산하지 않는다. 이미 결정된 settlement plan의 `set_hero_status` callback이 main의 narrow adapter를 거쳐 `WoundedRecoveryService.apply_battle_hero_status`를 호출한다. T02/T03의 wounded 병력 callback도 유지된 main wrapper를 통해 service로 들어간다.

## Presentation 경계와 제외 범위

main에는 버튼 callback, 버튼 문구/활성화, HUD refresh, status/popup/SFX, save, turn orchestration이 남는다. T03 report/영상/card 함수는 M-6 기준과 동일하며 service에 포함하지 않았다.

M-7에서 제외한 남은 military-domain 함수는 `_is_hero_captured_for_battle`, `_get_hero_battle_exclusion_reason`, `_sync_worldmap_hero_locations_from_city_runtime_states`, `_rebuild_occupation_runtime_indexes_mvp`다. captured hero, 전체 battle eligibility, hero movement 및 occupation index는 wounded lifecycle과 직접 결합하지 않았다.

M-8 Presentation Cleanup의 정확한 우선 후보는 `_build_t03_battle_report`, `_queue_t03_automatic_battle_report`, `_setup_t03_battle_presentation`, `_try_present_next_t03_battle_report`, `_on_t03_battle_video_skipped`, `_on_t03_battle_video_finished`, `_show_t03_battle_report_card`, `_on_t03_battle_report_confirmed`다.
