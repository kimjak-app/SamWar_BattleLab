# T02 PLAYER INVASION LOGISTICS, BATTLE SUPPLY & OCCUPATION

Status: `COMPLETE` (`v0.74-02-hotfix6`, commit `ff642424e28f98d6b390c457d6913d8b4c2f6c71`).

Completion lock: integrated F5 manual QA and final Editor Output verification passed on 2026-07-20. The implementation, automated evidence, and manual acceptance checklist below are now the locked T02 baseline. Future enemy-invasion/player-defense work belongs to T03 and must reuse this transaction's supply, casualty, wounded, settlement, persistence, and duplicate-protection rules without silently changing them.

## Hotfix 6: Final GDScript Warning Cleanup

No gameplay, resource, research, occupation, save, or layout behavior changed. The defender alignment count now spells its existing `floor(survivors / 3)` rule as `floor(float / 3.0)`, removing the integer-division reload warning without changing the 1/3 result. The private portrait-template helper retains its interface and behavior while marking its intentionally unused up/down parameters with underscores. Headless parse, NewGameFactionSelect, WorldMap, Battle_Land, T01, T02, and portrait/battle smoke pass. Editor Output final confirmation passed as part of the completion lock.

## Hotfix 5: Resource Source-of-Truth Unification & Production Victory Settlement Fix

`CityState.resource_stock` is the only persisted resource inventory. National warehouse UI is a freshly rebuilt aggregate of runtime player-owned city stock, seeded before the first WorldMap render and rebuilt after new game, load, ownership/resource settlement, expedition payment, and research payment. It is not a separate spendable store.

National technology validates an atomic capital-first, stable-city-order payment plan against all owned city stock, then commits only if fully funded. City technology validates and pays only the selected city stock. Expedition cargo continues to read and deduct only the source city stock. Battle_Land production aliases (`yi_sunsin`, `jeong_dojeon`, `gim_yusin`) are translated back to WorldMap IDs before victory settlement, preventing live BattleResult survivor IDs from being silently dropped and returned to the source roster.

## Hotfix 4: Victory Occupation Settlement, General Disposition & Faction Elimination

Victory is now an atomic WorldMap settlement. Surviving attacking generals, healthy troops, wounded queue, and remaining expedition cargo are placed in the occupied city; defeat and turn-limit routes return them to the source. The occupied city is entered in the player registry from runtime `owner_faction_id`, starts with no governor, and is immediately usable by player-city commands.

Defender survivors are never deleted. With adjacent same-faction cities remaining, sorted survivors deterministically place `max(1, floor(n / 3))` with the victor and distribute the rest across sorted adjacent cities. With no adjacent retreat, or when the last city falls, all survivors align with the victor in the occupied city. Aligned and escaped generals are unappointed; aligned runtime state persists `conquest_mvp` provenance for a later loyalty migration. City ownership changes rebuild the player registry/national aggregation snapshot and increment the AI ownership-cache generation. A defeated-faction registry and once-only notification consumption state are persisted with the checkpoint.

## Hotfix 3: GDScript Reload Warning Cleanup

No gameplay, supply, settlement, BattleContext/Result, balance, or UI-layout behavior changed. Global-class/preload name collisions were removed in the Battle and T02 callers; the city-resource local `seed` was renamed without changing the persisted `resource_seed` key; the static battle faction resolver is called through its script type rather than the autoload instance; and unused portrait-facing parameters were removed from the private helper signature and its callers. Headless editor reload, scene loads, T02 battle/context/supply/settlement/save-load smoke, and helper call paths pass without these warnings. Editor F5 Output confirmation passed as part of the integrated manual QA.

## Hotfix 2: Supply Integrity, Compact HUD, Dynamic Title

The bottom-right supply panel is now a 560×262 compact two-column layout: turn/remaining-turn header, then ally and enemy columns with food type/amount, salt, combined food/salt consumption, sustain estimate, and one fixed-height warning row. It no longer stacks both sides vertically.

Defender food is selected from the target CityState `resource_stock` (greatest rice/barley/seafood; stable order rice, barley, seafood) and defender salt is the same target-city persistent stock. `T02_INITIAL_SALT_PER_RESOURCE_RATING` is only a missing-key first-state seed inside `_ensure_city_supply_resource_defaults`; it is never recalculated for a populated city or BattleContext. Battle runtime is transient, and `BattleResult` remaining defender food/salt is atomically written back to target CityState before checkpoint/save. The deterministic Sabi 90/120/142/56 smoke verifies context, runtime, one-turn consumption, settlement, save/load, and no salt reseed.

Production invasion context now carries `battle_mode=invasion`, faction/city display names, and the battle title is `{공격 국가명}군이 {목표 도시명}을 공격하고 있습니다.` The canonical Korean battle faction resolver is `GameSession`; test title text is limited to explicit `battle_mode=test`.

## Hotfix 1: Battle Supply HUD Readability

Manual QA found that the original top-left multiline supply label was hidden behind the ally formation guide. Hotfix 1 removes that legacy label and moves the same `BattleSupplyRuntime` data into a scene-authored, dark translucent panel anchored above the bottom-right auto/end-turn/retreat command bar. The panel separates ally and enemy food, salt, per-turn consumption, sustain estimate, battle turn, and remaining turns; it also gives explicit salt-zero and food-zero warnings. Automated node-path, value-binding, quadrant, overlap, overflow, and warning smoke passes. Live BattleContext play and window-size visual QA remains required.

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
- `t02_battle_context_smoke.gd`: production context roster application, round-one supply consumption, scene-authored right-bottom supply panel, legacy-label removal, value/warning binding, command/formation overlap and text-fit audit, round-30 defender result, and expanded BattleResult supply/ID fields. `T02_HUD_VISUAL_QA=1` holds the populated panel for local visual inspection.
- Project/editor parse and NewGameFactionSelect, WorldMap, and Battle_Land scene loads are required before commit.

## Manual QA

PASS: F5 four-faction entry, formation-panel visual fit and live edits, final warning dialog, cancel immutability, actual manual battle round transitions/HUD/logs, compact two-column panel fit, live target-city-vs-HUD defender supply comparison and post-result/save reload comparison, dynamic battle title, victory and defeat return visuals, wounded-treatment flow, checkpoint Continue/load, and final Editor Output were manually verified on the completion baseline.

## Completion Decision

`COMPLETE`. T02 is locked at `ff642424e28f98d6b390c457d6913d8b4c2f6c71`; T03 may now enter audit and design. Any later change to a protected T02 rule requires an explicit compatibility decision in the active transaction.
