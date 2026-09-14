# M-3 Battle Context Service 감사 및 이동표

기준 체크포인트는 `c6d922e`이다. M-2 재검증 시 repository는 `main`, origin과 ahead/behind `0/0`, clean 상태였으며 Godot parse와 enemy warfare, military, diplomacy, trade, spy, WorldMap → Battle lifecycle 회귀가 통과했다.

## 책임 경계

- `battle_context_service.gd`: 월드맵 read query와 공격/침공 입력으로 검증 결과, roster, allocation, command limit, reinforcement 후보, BattleContext dictionary를 반환한다.
- `worldmap_main.gd`: UI 입력, pending context 저장 수명주기, 카메라 handoff, scene transition, 실제 월드맵 mutation, 전투 결과 정산을 유지한다.
- 서비스는 `RefCounted`이며 Node/NodePath/UI/signal/scene API나 월드맵 상태 dictionary를 보관하지 않는다.
- `_set_pending_battle_context_mvp`, `_get_pending_battle_context_mvp`, `_clear_pending_battle_context_mvp`는 생성 책임이 아니므로 main의 `_player_state["pending_battle_context"]` store로 유지한다.

## 확정 이동표

모든 항목의 이동 대상은 `scripts/worldmap/battle/battle_context_service.gd`이며 signal 연결 변경은 없다. Node reference는 전달하지 않고 `Callable(query_id, args)` read adapter만 사용한다.

| 현재 함수명 | 함께 이동한 변수/상수/helper | main wrapper | 외부 호출부 | 예상 회귀 위험 |
|---|---|---:|---|---|
| `_validate_pending_invasion_event_for_battle_context` | 최소 침공 병력, 도시/소유/인접 read query | 예 | 방어 배치 진입 2곳 | 소유권·인접 판정 |
| `_build_battle_context_from_pending_invasion` | roster/allocation/turn/city query | 예 | 수동 방어, 자동 침공 | context key 누락 |
| `_build_player_attack_battle_context` | supply calculator, faction display, city query | 예 | 플레이어 공격 확정 | supply·roster payload |
| `_build_player_attack_selected_roster_for_battle_context` | selected roster helper | 예 | service 내부/호환 테스트 | 선택 장수 보존 |
| `_build_selected_side_roster_for_battle_context` | hero/command/allocation helpers | 예 | 방어·공격 context | 0병력 장수 제외 |
| `_build_even_troop_allocation_for_heroes` | hero id normalization | 예 | 호환/테스트 | 나머지 분배 순서 |
| `_build_command_limit_troop_allocation_for_heroes` | command rank/limit helpers | 예 | enemy warfare query, 자동 배치 | 총합·상한 초과 |
| `_apply_troop_allocation_to_roster` | hero data, command summary, troop setter | 예 | context builders | allocation field 불일치 |
| `_sum_troop_allocation` | 없음 | 예 | enemy warfare, 자동 배치 | 음수 처리 |
| `_build_invasion_side_roster_for_battle_context` | 최대 장수, reinforcement helpers | 예 | 양 context builder | 중복/진영 혼입 |
| `_append_invasion_roster_hero_id` | hero/captured read query | 예 | roster builders | 포로 장수 포함 |
| `_build_invasion_roster_result` | hero battle data helper | 예 | invasion roster | hero id/data 불일치 |
| `_get_reinforcement_candidate_city_ids_for_battle_context` | 최대 탐색 hop, neighbor query | 예 | invasion roster | 순환·중복·탐색 범위 |
| `_are_factions_reinforcement_compatible` | 동맹 faction map | 예 | invasion roster | 타 진영 증원 |
| `_get_hero_city_id_for_battle_context` | hero query | 예 | roster result | fallback 도시 |
| `_get_city_stationed_hero_ids_for_battle_context` | stationed hero read query | 예 | UI/결과/roster 호출부 | 기존 비-context 호출 호환 |
| `_get_city_battle_heroes_for_battle_context` | stationed hero, hero data | 예 | 호환 호출 | 빈/invalid hero |
| `_apply_domestic_battle_tech_modifier_to_hero_data_mvp` | tech modifier read query | 예 | hero data | 25% clamp·unit 분기 |
| `_get_hero_battle_data_for_battle_context` | runtime factory, role/portrait/skill helpers | 예 | roster 생성 | Battle hero schema |
| `_get_city_governor_id_for_battle_context` | governor read query | 예 | context/command | governor key alias |
| `_normalize_command_rank_mvp` | DefenseBattleHelpers, rank limits | 예 | command helper | legacy rank 정규화 |
| `_get_hero_command_rank_for_city_mvp` | governor override | 예 | UI/command helper | 태수 승격 |
| `_get_hero_command_limit_for_city_mvp` | rank limits | 예 | 공격/방어 UI와 allocation | UI 상한 일치 |
| `_get_hero_command_summary_for_city_mvp` | rank labels/limits | 예 | 공격 배치 UI, roster | label/limit drift |

함께 이동한 전용 helper는 `_get_hero_contract_nation_key`, `_get_hero_contract_portrait_path`, `_get_hero_contract_cutin_path`, `_format_hero_contract_skill_name`, `_format_hero_contract_skill_desc`, `_set_hero_troops`, `_normalize_hero_ids`이다. 도시 marker/runtime/HUD를 읽는 `_has_city_for_battle_context`, `_get_city_owner_id_for_battle_context`, `_get_city_troops_for_battle_context`의 실제 read 구현은 main의 월드맵 adapter 책임으로 남겼다.

## 의존성 및 호출 방향

`worldmap_main.gd orchestration/UI → battle_context_service → read-only Callable → worldmap_main.gd state queries`

서비스가 받는 query는 turn, city existence/owner/troops/name/neighbors/stationed heroes/governor/supply, invasion ownership validation, available player heroes, hero snapshot, captured 여부, domestic tech modifier뿐이다. 반환된 dictionary를 pending store에 넣거나 Battle scene에 전달하는 행위는 main만 수행한다.

## M-4 후보 경계

M-4 `battle_result_service` 후보는 결과 판별/정규화/병력 계산/점령 정산 계열이다: `_consume_worldmap_battle_result_if_any`, `_apply_returned_battle_result_mvp`, `_is_player_attack_battle_result`, `_apply_player_attack_battle_result`, `_apply_t02_player_attack_result`, `_apply_invasion_battle_result`, `_is_enemy_invasion_battle_result`, `_normalize_invasion_battle_result_kind`, `_normalize_player_attack_battle_result_kind`, `_get_invasion_result_city_id`, `_normalize_battle_result_hero_ids`, `_normalize_battle_hero_outcomes`, `_calculate_player_attack_troop_outcome_fallback`, `_calculate_invasion_casualty_result`, `_resolve_invasion_remaining_troops`, `_resolve_occupation_troops`, `_clamp_invasion_troops`, `_get_result_troop_value`, `_apply_defender_win_invasion_result`, `_apply_attacker_win_invasion_result`, `_apply_player_attack_win_result`, `_apply_player_attack_loss_result`, `_settle_defender_generals_after_occupation`, `_apply_explicit_battle_hero_outcomes`, `_apply_invasion_hero_state_placeholder`, `_set_hero_runtime_status_placeholder`, `_apply_t02_defender_supply_result`, `_add_t02_attacker_cargo_to_city`.

실제 mutation과 UI summary 표시는 pure result calculation과 분리해서 main coordinator 또는 좁은 mutation adapter에 남겨야 한다.
