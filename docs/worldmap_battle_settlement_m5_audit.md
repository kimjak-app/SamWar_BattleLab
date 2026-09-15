# M-5 Battle Settlement Applier 감사

## 기준선

- M-4 체크포인트: `2ee28db607cc5b6f2060a3a3c2087b53b89188be` (`월드맵 군사 분리 작업 -4`). `battle_result_service.gd`, main coordinator 변경, 감사 문서와 31-check 테스트가 독립 커밋으로 보존되어 있다.
- SFX-1 validator는 Windows 기본 CP949에서 UTF-8 GDScript를 읽지 못하던 문제를 `1798868`에서 보정했다. 보정 직후 SFX validator, Godot parse, Battle Result/Context, Enemy Warfare, Military Controller 기준선은 모두 PASS였다.
- M-5 시작 시 working tree는 깨끗했다. 예상 밖 변경의 삭제/reset/restore/stash는 수행하지 않았다.

## 함수 감사 및 이동표

분류: A Settlement mutation, B Orchestration, C UI/presentation, D Persistence/save, E Derived index rebuild.

| 후보 | 기존 실제 책임 | M-5 결정 |
|---|---|---|
| `_apply_t02_player_attack_result` | A+B+C+D | A는 `apply()`로 이동. pending 정리, index/UI refresh, popup, save를 수행하는 B+C+D coordinator wrapper 유지 |
| `_apply_defender_win_invasion_result` | A+C | A 이동. plan/report에서 표시 summary를 만드는 B+C wrapper 유지 |
| `_apply_attacker_win_invasion_result` | A+C | A 이동. B+C wrapper 유지 |
| `_apply_player_attack_win_result` | A+C | A 이동. B+C wrapper 유지 |
| `_apply_player_attack_loss_result` | A+C | A 이동. B+C wrapper 유지 |
| `_settle_defender_generals_after_occupation` | A | disposition plan 생성은 Result Service, 적용은 applier로 이동. T03 호환 wrapper 유지 |
| `_set_hero_faction_after_conquest_mvp` | A | applier `set_hero_faction()` 위임 wrapper 유지 |
| `_move_hero_to_city_t02` | A | applier `move_hero()` 위임 wrapper 유지 |
| `_apply_explicit_battle_hero_outcomes` | A | concrete `hero_status_plan` 적용은 applier로 이동. 기존 반환 형식 호환 wrapper 유지 |
| `_apply_invasion_hero_state_placeholder` | A+C | fallback outcome 선택은 Result Service plan으로 이동, A는 applier로 이동. report를 presentation summary에 합치는 C wrapper 유지 |
| `_set_hero_runtime_status_placeholder` | A | applier `set_hero_status()` 위임 wrapper 유지 |
| `_apply_t02_defender_supply_result` | A | applier `apply_defender_supply()` 위임 wrapper 유지 |
| `_add_t02_attacker_cargo_to_city` | A | applier `apply_attacker_cargo()` 위임 wrapper 유지 |
| `_rebuild_occupation_runtime_indexes_mvp` | E | 국가 합계, AI cache generation, 승패 평가까지 결합되어 있어 main coordinator에 유지 |

## 이동된 mutation

새 `battle_settlement_applier.gd`가 다음 mutation 흐름을 소유한다.

- canonical remaining/occupation troop 적용과 wounded queue mutation
- `faction_transfer`의 city owner 적용
- `hero_movements`, `hero_status_plan`, `defender_disposition` 적용
- 영웅 city 이동, runtime status, 정복 후 faction/직위 초기화
- defender supply의 잔량 대입과 승리 시 attacker cargo 귀속
- `result_id` 적용 완료 기록

main에는 각 mutation을 실제 runtime dictionary에 반영하는 좁은 `_battle_settlement_mutation(mutation_id, args)` adapter만 있다. 서비스는 Node/NodePath, signal, camera, scene, HUD, popup, save API를 보유하거나 호출하지 않는다.

## Plan 계약의 최소 확장

기존 필드는 그대로 유지했다. 실제 적용에 없던 정보만 아래처럼 추가했다.

- `settlement_profile`: 기존 T02 return과 standard 경로의 도시 병력 적용 방식 구분
- `troop_settlement`: T02에서 이미 산출된 attacker/defender healthy/wounded 값
- `hero_status_plan`: normalization/legacy fallback까지 끝난 concrete status 목록
- `hero_movements`: T02 출전 영웅의 concrete destination
- `defender_disposition`: 점령 후 영웅별 faction/city assignment와 unstation 목록
- `apply_supply_settlement`: legacy 결과에 0 supply를 덮어쓰지 않고 T02 계약에서만 적용

이 확장은 mutation에 필요한 값을 applier가 raw result에서 재해석하지 않게 하기 위한 것이다. applier는 `winner_side`, casualty, remaining, occupation, hero outcome, faction-transfer 필요 여부를 계산하지 않는다.

## Coordinator 흐름

`_apply_returned_battle_result_mvp`의 일반 경로는 다음 순서다.

`raw result 수신 → BattleResultService.build_settlement_plan → BattleSettlementApplier.apply → player-attack/invasion coordinator → pending/UI/HUD/save/event 후처리`

T03 transaction은 기존 early branch로 빠지므로 이 흐름에 들어오지 않는다.

## Report와 중복 적용

`apply()`는 `ok`, battle/result kind, target/transaction/result id, `troop_changes`, ownership before/after, `hero_changes`, `supply_changes`, `cargo_changes`, `indexes_rebuilt`, `warnings`, `duplicate`를 반환한다.

식별자가 있는 결과는 가장 작은 기존 저장 계약을 재사용한다. 적용 전 pending transaction 일치와 `applied_battle_result_ids`를 검사하고, 모든 mutation 뒤 같은 배열에 `result_id`를 기록한다. 동일 plan 재호출은 mutation 전에 `duplicate_result`로 거절된다. 식별자가 없는 legacy 결과는 Engine meta를 먼저 제거하고 pending invasion event를 후처리에서 비우는 기존 single-consume lifecycle에 의존한다.

## 다음 작업 후보

### A. T03 strategic battle transaction

- `_prepare_t03_battle_transaction`
- `_pay_t03_expedition_cargo`
- `_rollback_t03_battle_transaction`
- `_resolve_t03_automatic_invasion`
- `_apply_t03_strategic_battle_result`
- `_apply_t03_defender_supply_result`
- `_add_t03_attacker_cargo_to_city`
- `_build_t03_battle_report`
- `_queue_t03_automatic_battle_report`
- `_try_present_next_t03_battle_report`
- `_show_t03_battle_report_card`

M-5에서는 변경하지 않았다. 다만 기존 T03가 공유하던 defender disposition/move wrapper만 호환 위임을 통한다.

### B. wounded/recovery 및 남은 battle-domain implementation

- `_get_city_wounded_queue_mvp`
- `_add_wounded_to_city_mvp`
- `_clear_city_wounded_queue_mvp`
- `_apply_wounded_recovery_for_world_turn_mvp`
- `_advance_wounded_hero_recovery_turns`
- `_refresh_wounded_treatment_controls`
- `_on_fast_wounded_treatment_pressed`
- `_is_hero_captured_for_battle`
- `_get_hero_battle_exclusion_reason`
- `_sync_worldmap_hero_locations_from_city_runtime_states`
- `_rebuild_occupation_runtime_indexes_mvp`

이 계열은 recovery lifecycle, UI control, global derived state 경계를 다시 감사한 뒤 별도 작업으로 분리한다.
