# M-8 T03 전투 Presentation 분리 감사

## 기준선과 기존 호출 흐름

- 시작 기준: M-7 `ccd0f4b958ecbe8ca7418388b1379235c06e2569`, origin과 `0 ahead / 0 behind`, clean.
- 기존 흐름은 `_finalize_t03_strategic_battle_result` → `_build_t03_battle_report` → `_queue_t03_automatic_battle_report` → turn 완료 뒤 `_try_present_next_t03_battle_report` → video → card → `_on_t03_battle_report_confirmed` → save/다음 report였다.
- `t03_automatic_battle_reports`와 `t03_acknowledged_report_ids`는 save되는 `_player_state`에 있었고, `_t03_active_report` 및 video/card visibility는 일시 presentation state였다.

## 역할 분류와 이동

| 기존 함수 | 분류 | M-8 결과 |
|---|---|---|
| `_build_t03_battle_report` | A formatting | controller `build_report`; thin wrapper 유지 |
| `_queue_t03_automatic_battle_report` | B queue | controller `enqueue_report`; thin wrapper 유지 |
| `_setup_t03_battle_presentation` | C node/signal setup | controller `setup`; thin wrapper 유지 |
| `_try_present_next_t03_battle_report` | B/C + D gate | player-turn/terminal gate는 main, dequeue/play는 controller |
| `_on_t03_battle_video_skipped` | C | controller `skip_video`; wrapper 유지 |
| `_on_t03_battle_video_finished` | C | controller `finish_video`; wrapper 유지 |
| `_show_t03_battle_report_card` | C | controller `show_result_card`; wrapper 유지 |
| `_on_t03_battle_report_confirmed` | B/C | controller `confirm_report`; wrapper 유지 |
| confirm 뒤 save/terminal/다음 queue | D/E | main `_on_t03_battle_presentation_completed` |

## Controller 타입과 dependency

`T03BattlePresentationController`는 `Node`다. 실제 `VideoStreamPlayer`, button signal, overlay/card visibility를 소유하므로 scene lifecycle과 signal을 자연스럽게 관리하는 Node가 pure `RefCounted`보다 적합하다. 다만 scene을 탐색하지 않고 main이 명시적으로 전달한 8개 UI node만 보관한다. worldmap host를 받지 않으며 다음 narrow dependency만 사용한다.

- state query: persisted report queue, acknowledged report IDs snapshot.
- state mutation: persisted report queue, acknowledged report IDs 교체.
- formatter: faction label, city label.
- configuration: 기존 T03 video path.

GameAudio/SFX 직접 접근은 새로 만들지 않았다. 기존 presentation 흐름에 별도 SFX 호출이 없었으므로 SFX timing과 `/root/GameAudio` lookup도 변경되지 않았다.

## Report와 state ownership

`StrategicBattleTransactionService`의 structured battle result는 main coordinator를 거쳐 `build_report`에서 presentation model로 변환된다. controller는 title, labels, casualty lines, turn-limit wording만 만들고 troop/ownership/cargo/wounded/hero state를 변경하거나 결과를 재정산하지 않는다.

- canonical persisted state: main `_player_state.t03_automatic_battle_reports`, `_player_state.t03_acknowledged_report_ids`.
- controller transient state: active report, `idle/video/card` phase, completion-emitted guard, queue-empty-emitted guard.
- main의 기존 `_t03_active_report` 복제 state는 제거했다.

## Queue와 duplicate 계약

- enqueue에는 non-empty `report_id`가 필요하다.
- acknowledged, active 또는 queued report와 같은 ID는 `duplicate=true`로 no-op 처리한다.
- FIFO 순서를 유지하며 acknowledged/stale queue item은 presentation 선택 전에 제거한다.
- confirm 시 현재 report ID를 한 번만 acknowledged에 넣고 동일 ID를 queue에서 제거한다.
- card phase가 아니거나 이미 완료한 confirm은 completion signal을 다시 발생시키지 않는다.
- empty-queue signal도 queue가 다시 채워질 때까지 한 번만 발생한다.
- 이는 M-6의 domain transaction/result exactly-once와 별개의 presentation exactly-once guard다.

## Video → card → confirm

1. player turn이고 terminal outcome이 아닐 때 main이 `try_present_next`를 호출한다.
2. 기존 video resource가 있으면 labels/skip/video를 표시하고 재생한다.
3. skip 또는 finished가 같은 `show_result_card` 경로로 합류한다.
4. video가 없으면 즉시 card fallback으로 진행한다.
5. card는 기존 title, 두 줄 간격 body wording을 그대로 표시한다.
6. confirm은 acknowledgement/queue를 갱신하고 overlay를 닫은 뒤 `presentation_completed`를 한 번 emit한다.
7. main callback이 save하고 terminal outcome 또는 다음 queued report로 이어간다.

## Turn/save 및 M-6 경계

controller에는 world turn 증가, enemy turn, save, scene transition, settlement 또는 rollback 호출이 없다. `_try_present_next_t03_battle_report`의 terminal/player-turn gate와 `_on_t03_battle_presentation_completed`의 save/T05/next-report orchestration은 main에 남았다. M-6 `StrategicBattleTransactionService`와 `T03AutoBattleResolver`는 변경하지 않았으며 transaction 성공 뒤 만들어진 raw result만 presentation input으로 사용한다.

## M-1~M-8 구조 최종 감사

1. Military administration: `military_controller.gd`.
2. Enemy warfare: `enemy_warfare_service.gd`.
3. Battle context: `battle_context_service.gd`.
4. Battle result: `battle_result_service.gd`.
5. Battle settlement: `battle_settlement_applier.gd`.
6. T03 transaction: `strategic_battle_transaction_service.gd`, 기존 resolver 재사용.
7. Wounded/recovery: `wounded_recovery_service.gd`.
8. Battle presentation: `t03_battle_presentation_controller.gd`.

## Main 잔여 군사 함수 분류

### A. 정상 coordinator/wrapper

`_start_player_attack_battle`, `_open_player_attack_deployment`, `_confirm_player_attack_deployment`, `_on_player_attack_deployment_confirmed`, `_on_player_attack_deployment_cancelled`, `_open_defense_deployment_panel_from_pending_invasion`, `_confirm_defense_deployment`, `_handoff_battle_context_to_battle_scene`, `_change_scene_to_battle_with_context`, `_consume_worldmap_battle_result_if_any`, `_apply_returned_battle_result_mvp`, `_finalize_t03_strategic_battle_result`, `_try_present_next_t03_battle_report`, `_on_t03_battle_presentation_completed` 및 M-1~M-8 compatibility wrapper들은 UI/scene/save/cross-service sequencing이므로 main에 두는 것이 정상이다.

### B. Generic hero/world state

`_get_existing_hero_runtime_state`, `_normalize_hero_runtime_state`, `_set_hero_runtime_city`, `_ensure_hero_in_city_runtime_roster`, `_remove_hero_from_other_city_runtime_rosters`, `_set_city_runtime_troops`, `_get_world_city_troop_total`은 save와 여러 도메인이 공유하는 canonical world-state adapter다.

### C. Occupation/captured/movement tail

`_transfer_stationed_hero_between_player_cities`, `_apply_battle_settlement_move_hero`, `_apply_battle_settlement_hero_faction`, `_rebuild_occupation_runtime_indexes_mvp`, `_sync_worldmap_hero_locations_from_city_runtime_states`, `_is_hero_captured_for_battle`, `_get_hero_battle_exclusion_reason`가 남았다. 이들은 hero/world-state 또는 occupation 교차 도메인으로 별도 bounded extraction 후보이며 M-8에서는 변경하지 않았다.

### D. 아직 분리되지 않은 의미 있는 military domain

`_build_player_attack_deployment_payload`, `_get_deployable_player_heroes_for_city`, `_validate_player_attack_deployment`, `_calculate_player_attack_supply_cost`, `_can_pay_player_attack_supply_cost`, `_pay_player_attack_supply_cost`, `_move_generals_for_pending_expedition`, `_select_city_battle_supply`, `_apply_context_side_troop_pre_decrement_mvp`, `_calculate_troop_rebalance_suggestions`, `_apply_troop_rebalance_suggestion`이 남았다. BattleContext 생성 자체는 M-3 service로 이동했지만, 출정 전 UI payload/보급 결제/pre-decrement와 자동 병력 재배치 rule은 아직 main 구현이다.

핵심 calculation/result/settlement/T03 transaction/recovery/presentation은 분리되었으므로 “M-1~M-8 군사/전투 1차 분리 완료”로 판정할 수 있다. 다만 C/D tail이 존재하므로 전체 군사 분리 100%로 보지는 않으며, 정량 평가는 약 90%다.
