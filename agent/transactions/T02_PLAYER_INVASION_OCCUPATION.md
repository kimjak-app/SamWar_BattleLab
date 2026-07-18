# T02 PLAYER INVASION LOGISTICS, BATTLE SUPPLY & OCCUPATION

Status: Implementation Complete / Manual QA Pending (`v0.74-02`).

## Player Flow

The player selects an adjacent enemy city, chooses currently stationed and battle-eligible generals, assigns healthy troops, selects exactly one food type, and loads gold, food, and optional salt. The deployment panel recalculates the gold/food troop ceiling, source-city remainder, per-turn consumption, salt exhaustion effect, and simulated 30-turn endurance. A final dialog repeats the exact cargo-loss risk before the transaction starts.

Confirmation transfers troops, generals, and cargo from the source CityState into a transaction-scoped BattleContext. A transition failure rolls all transferred state back. `Battle_Land` consumes both sides' food and salt exactly once at each battle-round boundary, applies food-zero desertion, shows both supply balances and `N / 30`, and gives the defender victory when round 30 ends without an attacker victory.

WorldMap validates the returned transaction/result IDs, restores the pre-battle strategic snapshot, atomically applies occupation or retreat, registers wounded recovery, clears pending state, refreshes UI, checks four-city unification, and then writes the checkpoint. Reapplying a consumed result is a no-op.

## Formation And Cargo

- Candidates come from the selected source city's authoritative `stationed_hero_ids`; dead, captured, or wounded/recovering generals are excluded. No sample roster enters a production BattleContext.
- Troops are healthy city troops and preserve the existing per-general command limit and one-soldier source-garrison minimum.
- Food is one of `rice`, `barley`, or `seafood`; salt may be zero. Gold and at least one worst-case no-salt food turn are mandatory.
- The minimum gold formula reuses the former `0.2 gold/troop` value as the centralized equivalent `20 gold / 100 troops`.
- Defender supply uses the greatest city food stock, with stable tie order rice, barley, seafood. Only actually consumed defender food/salt is removed.

## State Transition And Settlement

Victory changes target ownership to `attacker_faction_id`, stations surviving attacker generals and healthy troops at the target, registers wounded there, applies defender consumption, and adds remaining attacker gold/food/salt to the occupied CityState. Surviving defender generals retreat to an adjacent same-faction city, then another same-faction city; unsupported non-stationed state is used when none exists.

Defeat and `turn_limit` preserve target ownership, return surviving attacker generals, healthy troops, and wounded to the source, and lose all attacker cargo. Cancel before confirmation mutates nothing. Context/scene handoff failure restores all transferred state.

## Wounded Recovery

Troop losses after deserters are split 50/50 wounded/dead without losing rounding remainder. Wounded queues persist `wounded_count`, `recovery_months_remaining`, `recovery_mode`, and `source_transaction_id`. Normal recovery is three months. The result card offers fast recovery for one month at `ceil(wounded / 100)` salt and disables it when the destination city lacks salt. Because the existing calendar is 40 world turns/year rather than one month/turn, recovery ticks only when the derived 12-month boundary changes.

## Persistence And Duplicate Protection

Save version is `v0.74-02`. City owner, healthy troops, wounded queue, city cargo stock, stationed generals, hero locations/states, research, session faction, selected city, world turn, victory flag, and applied result IDs persist. Pending battle state is transient and is cleared before the post-result checkpoint. `transaction_id` must match pending state and `result_id` must not already be consumed.

## Technology Audit

- Connected through existing attack eligibility/UI: city siege unlocks and the already implemented national/city siege modifier lookup.
- Defined but not connected to T02 supply arithmetic: `nation_logistics_system`, `nation_expedition_system`, `fish_dried_supply_base` (`expedition_food_cost_percent`), recruitment/weapon technologies, granary technologies, watchtower/beacon, and intelligence disclosure.
- No new technology values were invented. `tech_effect_snapshot` is reserved in BattleContext; the absolute 30-turn cap is never modified.

## Automated QA

- `t02_smoke_test.gd`: formation limits, zero-salt legality/math, 30+ turn cargo, one-food choice contract, both-side supply, once-per-turn guard, desertion, reduced later consumption, normal/fast wounded recovery, handoff rollback, victory/defeat/turn-limit settlement, general non-duplication, duplicate result, save/reload, and four-faction formation/side/settlement.
- `t02_battle_context_smoke.gd`: production context roster application, round-one supply consumption, scene-authored supply HUD, round-30 defender result, and expanded BattleResult supply/ID fields.
- Project/editor parse and NewGameFactionSelect, WorldMap, and Battle_Land scene loads are required before commit.

## Manual QA

Required: F5 four-faction entry, formation-panel visual fit and live edits, final warning dialog, cancel immutability, actual manual battle round transitions/HUD/logs, victory and defeat return visuals, fast-treatment button state, month-boundary recovery, checkpoint Continue/load, and four-city victory notice/state. Headless verification does not establish visual or input PASS.

## Completion Decision

Implementation Complete / Manual QA Pending. Do not promote T03 or mark T02 COMPLETE until the manual checklist passes.
