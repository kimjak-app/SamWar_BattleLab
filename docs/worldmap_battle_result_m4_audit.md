# M-4 Battle Result Service 감사 및 이동표

기준 체크포인트는 `20cef38`이다. 현재 브랜치와 upstream은 ahead/behind `0/0`, working tree clean이었으며 Godot parse, M-3 Battle Context, Military, Enemy Warfare, Diplomacy, Trade, Spy, WorldMap → Battle lifecycle 16개 스크립트를 다시 통과했다.

## 책임 경계

- `battle_result_service.gd`: raw result 판별, result kind/ID/hero outcome 정규화, 병력·사상자·점령 수치 계산, settlement plan 생성을 담당한다.
- `worldmap_main.gd`: Engine meta 결과 수신, 중복/transaction 검증, 실제 도시·세력·영웅·보급 mutation, runtime index/HUD 갱신, 저장과 후속 이벤트를 담당한다.
- 서비스는 `RefCounted`이며 Node/NodePath/signal/UI/scene API 및 mutable worldmap state를 보관하지 않는다.

## Pure 함수 이동표

모든 함수의 대상은 `scripts/worldmap/battle/battle_result_service.gd`이다. 기존 내부 호출부 호환을 위해 main wrapper를 유지하며 signal 연결 변경은 없다. Node reference 대신 city existence/troops/owner, faction label, player faction의 read-only query만 사용한다.

| 현재 함수명 | 분류 | 함께 이동할 상수/helper | 외부 호출부 | 예상 회귀 위험 |
|---|---|---|---|---|
| `_is_player_attack_battle_result` | A | player attack source | 결과 router | attack type alias |
| `_is_enemy_invasion_battle_result` | A | enemy invasion source | invasion router | defense type alias |
| `_normalize_invasion_battle_result_kind` | A | 4 result kind | invasion/hero fallback | player 관점 반전 |
| `_normalize_player_attack_battle_result_kind` | A | 4 result kind | attack/outcome fallback | attacker 관점 반전 |
| `_get_invasion_result_city_id` | A | key precedence | attack/invasion/hero | legacy key 우선순위 |
| `_build_invasion_result_summary` | A | read query, faction label | 9 settlement paths | mutation 후 snapshot 표시 |
| `_normalize_battle_result_hero_ids` | A | hero compatibility map | T02/T03 settlement | alias·중복 제거 |
| `_normalize_battle_hero_outcomes` | A | hero compatibility map | hero settlement | invalid value 제외 |
| `_get_player_troop_outcome_from_result` | A | attack result normalizer | 4 result appliers | explicit payload 보존 |
| `_get_enemy_troop_outcome_from_result` | A | attack result normalizer | 4 result appliers | defender 관점 |
| `_calculate_player_attack_troop_outcome_fallback` | A | 30%/50% fallback | outcome readers | 승패별 survivor 처리 |
| `_calculate_invasion_casualty_result` | A | 4 loss rates/minimum | settlement plan/tests | city snapshot·payload fallback |
| `_resolve_invasion_remaining_troops` | A | clamp/minimum | casualty calculation | minimum > before |
| `_resolve_occupation_troops` | A | 60%, minimum 80 | casualty calculation | 0 survivor fallback |
| `_clamp_invasion_troops` | A | maximum 99999 | AI delta/casualty | excessive payload |
| `_get_result_troop_value` | A | key precedence/clamp | casualty calculation | missing과 0 구분 |

추가 public 계산 진입점 `build_settlement_plan(raw_result)`은 위 함수들을 합성해 mutation 전 명시적 plan을 반환한다.

## Mutation 후보 A–E 분류

| 함수 | 분류 | M-4 처리 | 근거/후속 경계 |
|---|---|---|---|
| `_consume_worldmap_battle_result_if_any` | C | main 유지 | Engine meta 수신/제거 |
| `_apply_returned_battle_result_mvp` | C | main 유지 | snapshot/T03/router 및 plan 요청 |
| `_apply_player_attack_battle_result` | C | main 유지 | result 분기, UI/HUD orchestration |
| `_apply_t02_player_attack_result` | C | main 유지 | transaction 검증부터 save까지 묶임 |
| `_apply_invasion_battle_result` | C | main 유지 | invasion 분기, pending event/UI 정리 |
| `_apply_defender_win_invasion_result` | B | main 유지 | troops/wounded queue mutation |
| `_apply_attacker_win_invasion_result` | B | main 유지 | owner/troops/retreat mutation |
| `_apply_player_attack_win_result` | B | main 유지 | owner/troops/wounded mutation |
| `_apply_player_attack_loss_result` | B | main 유지 | troops/wounded mutation |
| `_settle_defender_generals_after_occupation` | E | M-5 후보 | occupation hero disposition 경계 |
| `_set_hero_faction_after_conquest_mvp` | B | main 유지 | hero faction/runtime mutation |
| `_rebuild_occupation_runtime_indexes_mvp` | E | M-5 후보 | derived worldmap index rebuild 경계 |
| `_move_hero_to_city_t02` | B | main 유지 | city roster/runtime mutation |
| `_apply_explicit_battle_hero_outcomes` | B | main 유지 | hero runtime status mutation |
| `_apply_invasion_hero_state_placeholder` | C | main 유지 | explicit/fallback hero mutation routing |
| `_set_hero_runtime_status_placeholder` | B | main 유지 | hero runtime status mutation |
| `_apply_t02_defender_supply_result` | B | main 유지 | target stock mutation |
| `_add_t02_attacker_cargo_to_city` | B | main 유지 | destination stock mutation |

지정 후보 중 D 단독 함수는 없다. Presentation은 `_format_invasion_result_status_from_summary`, `_show_post_battle_result_summary`, `_append_hero_state_result_lines` 등 별도 함수에 있으며 main에 유지한다.

## Settlement plan 계약

- identity: `battle_kind`, `result_kind`, `winner_side`, `loser_side`, city IDs, transaction/result ID
- force: `player_troop_outcome`, `enemy_troop_outcome`, `casualty_plan`, remaining/occupation troops
- hero: attacker/defender normalized `hero_outcomes`
- ownership: `faction_transfer {required, city_id, old_owner, new_owner}`
- logistics: defender supply와 attacker cargo를 담은 `supply_settlement`
- trace: deep-copied `raw_result`

main은 T03 전략 결과를 제외한 일반 Battle result를 수신하면 plan을 먼저 요청해 `_settlement_plan`에 첨부한 후 기존 mutation router로 전달한다.

## M-5 후보

대규모 mutation 이동은 M-4에서 수행하지 않는다. 다음 단계는 `battle_settlement_applier` 또는 더 좁은 `occupation_settlement_service`가 적합하다.

- top-level apply orchestration: `_apply_t02_player_attack_result`, `_apply_defender_win_invasion_result`, `_apply_attacker_win_invasion_result`, `_apply_player_attack_win_result`, `_apply_player_attack_loss_result`
- occupation/hero mutation: `_settle_defender_generals_after_occupation`, `_set_hero_faction_after_conquest_mvp`, `_move_hero_to_city_t02`, `_apply_explicit_battle_hero_outcomes`, `_apply_invasion_hero_state_placeholder`, `_set_hero_runtime_status_placeholder`
- logistics/index mutation: `_apply_t02_defender_supply_result`, `_add_t02_attacker_cargo_to_city`, `_rebuild_occupation_runtime_indexes_mvp`

M-5에서는 settlement plan을 실제 mutation command로 소비하도록 만들되 UI/HUD/save/event orchestration은 main에 남기는 경계가 필요하다.
