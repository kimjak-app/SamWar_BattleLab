# M-6 T03 Strategic Battle Transaction Audit

## Baseline

- Start branch: `recovery/worldmap-iso-sfx-services-20260912`
- Start HEAD and origin branch: `cbfcaa14ca08e64a177929a12f97984051c9140c`
- M-5 (`cbfcaa1`) was the local/remote tip, was in history, and the working tree was clean.
- There were no commits or working-tree changes after M-5 when M-6 began.

## Before M-6

`worldmap_main.gd` owned the complete sequence:

`_resolve_t03_automatic_invasion` → `_build_battle_context_from_pending_invasion` → `_prepare_t03_battle_transaction` → cargo payment / troop pre-decrement / hero expedition mutation → `T03AutoBattleResolver.resolve` → `_apply_t03_strategic_battle_result` → supply, ownership, troop, wounded, hero, and cargo mutation → report / HUD / save.

Direct defense used `_prepare_t03_battle_transaction` before scene handoff. A failed handoff called `_rollback_t03_battle_transaction`; a returned T03 result entered `_apply_t03_strategic_battle_result` through `_apply_returned_battle_result_mvp`.

## Function classification and movement

| Function | Before | M-6 destination |
| --- | --- | --- |
| `_make_t03_transaction_id` | A: calculation | `make_transaction_id`; thin main wrapper retained |
| `_build_t03_expedition_cargo_plan` | A: calculation/query | `build_expedition_cargo_plan`; thin wrapper retained |
| `_filter_t03_context_heroes` | A: calculation | `filter_context_heroes`; thin wrapper retained |
| `_prepare_t03_battle_transaction` | A/B/C: preparation and pre-mutation | `prepare`; thin wrapper retained |
| `_select_t03_food_type` | A: calculation | `select_food_type`; thin wrapper retained |
| `_sum_t03_food_stock` | A: calculation | `sum_food_stock`; thin wrapper retained |
| `_pay_t03_expedition_cargo` | B: resource mutation | `pay_expedition_cargo`; thin wrapper retained |
| `_rollback_t03_battle_transaction` | B: state restoration | `rollback`; thin wrapper retained; HUD refresh remains in main |
| `_resolve_t03_automatic_invasion` | C: orchestration | service `execute`; main wrapper builds the existing Battle Context and finalizes presentation |
| `_apply_t03_strategic_battle_result` | B plus presentation tail | domain settlement moved to `apply_result`; thin wrapper and presentation tail retained |
| `_apply_t03_defender_supply_result` | B: resource mutation | `apply_defender_supply`; thin wrapper retained |
| `_add_t03_attacker_cargo_to_city` | B: resource mutation | `add_attacker_cargo`; thin wrapper retained |

`_get_t03_city_food_stock` and `_get_t03_city_food_total` are compatibility wrappers. Food normalization and summing used by the transaction are service-owned.

## Main-owned coordinator and presentation

The following remain in `worldmap_main.gd`: transaction trigger timing, pending-event UI, scene handoff, `_finalize_t03_strategic_battle_result`, report creation/queueing, video playback and callbacks, result card and confirmation, status text, camera, HUD refresh, turn continuation, save/checkpoint, and scene transition.

Protected presentation functions retained in main are `_build_t03_battle_report`, `_queue_t03_automatic_battle_report`, `_setup_t03_battle_presentation`, `_try_present_next_t03_battle_report`, `_on_t03_battle_video_skipped`, `_on_t03_battle_video_finished`, `_show_t03_battle_report_card`, and `_on_t03_battle_report_confirmed`.

The service returns raw battle and mutation data. It does not format city/faction/general names, Korean outcome text, card labels, video selection, or UI labels. Domain result and presentation report remain separate.

## Dependencies

`StrategicBattleTransactionService` is `RefCounted`. It receives three narrow dependencies:

- Query callable: turn/scenario, invasion eligibility, city existence/owner/troops/resources/defense, player faction/defense modifier, command-limit allocation from the existing `BattleContextService`, applied-result state, pending transaction identity, and state serialization.
- Mutation callable: city resource/troop/owner writes, pending expedition hero movement, hero movement, wounded queue operations, existing M-4/M-5 defender disposition, pending transaction state, applied-result marking, and state restore.
- Resolver callable: the unchanged `T03AutoBattleResolver.resolve`.

The service owns no Node, NodePath, signal, camera, popup, HUD, scene transition, or save dependency. It does not receive `self` or an unrestricted host object.

## Transaction, payment, and rollback

Automatic flow after M-6 is:

`main builds existing Battle Context` → `service.execute` → validate → stable transaction ID → hero selection/allocation → cargo plan → pre-mutation snapshot → cargo payment → troop pre-decrement → pending hero movement → existing resolver → validate resolver identity → T03 settlement → structured result → `main` report/HUD/save finalization.

Cargo is paid only after validation, allocation, cargo sufficiency, and rollback snapshot creation. Troops and pending hero locations are mutated after payment. Settlement then applies defender remaining supply; ownership/disposition/troops/wounded/cargo/heroes follow according to the winner; the result ID is marked only after settlement mutations complete.

Rollback scope intentionally remains the pre-existing serialized worldmap snapshot—no wider transaction framework was introduced. It restores cargo, troops, hero locations, pending event/context, and other state represented by that snapshot. M-6 invokes it for direct handoff failure as before, and additionally for payment/preparation failure after mutation, unavailable/malformed resolver output, and settlement rejection/failure when a snapshot is available. The direct battle result now carries `rollback_worldmap_state` separately from the post-preparation `worldmap_state_snapshot`.

## Idempotency

The stable ID remains `t03-{turn}-{attacker city}-{defender city}`. The resolver derives `{transaction_id}-result`. `applied_battle_result_ids` is checked before resolver execution and again before settlement, and is saved in worldmap state. Pending invasion/context transaction identity guards direct results. Report queue insertion separately deduplicates by `result_id`, and acknowledgement state prevents replay of consumed presentation. These existing guards provide exactly-once settlement and presentation for the current T03 event model; no new persistence subsystem was added.

## M-5 / M-6 boundary

M-6 reuses the existing `BattleContextService` for context and command-limit allocation, the existing M-4 `BattleResultService` plus M-5 `BattleSettlementApplier` for defender disposition, and the existing `T03AutoBattleResolver` for combat calculation. It does not copy or replace general Battle Result, Battle Settlement, Military Controller, Enemy Warfare, Diplomacy, Trade, or Spy behavior. M-5 remains the general settlement boundary; M-6 owns only T03 expedition transaction and T03 strategic settlement sequencing.

## M-7 Wounded / Recovery candidates

The exact main functions to audit/move in M-7 are:

- `_apply_battle_settlement_hero_status`
- `_get_city_wounded_queue_mvp`
- `_add_wounded_to_city_mvp`
- `_clear_city_wounded_queue_mvp`
- `_apply_wounded_recovery_for_world_turn_mvp`
- `_get_world_month_serial`
- `_advance_wounded_hero_recovery_turns`
- `_on_fast_wounded_treatment_pressed` (split mutation from UI callback)

`_refresh_wounded_treatment_controls` must remain presentation/UI in main or a future presentation helper. `_advance_world_turn_mvp` must remain the turn coordinator and call the extracted recovery service at month boundaries.
