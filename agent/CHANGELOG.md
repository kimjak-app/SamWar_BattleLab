# CHANGELOG

## v0.69-3 Troop Move Loyalty Efficiency Final Patch
- Replaced C1 troop movement total preservation with the final source-city loyalty movement efficiency formula in `scripts/worldmap_test.gd`.
- Added `_calculate_troop_move_arrived_amount(commanded_amount, from_loyalty)`.
- `_move_troops` now subtracts the full commanded/departed amount from the source city and adds only the loyalty-adjusted arrived amount to the destination city.
- `last_troop_move_result` now records `commanded_amount`, `departed_amount`, `arrived_amount`, `lost_amount`, `from_loyalty`, source/destination after values, turn, and compatibility `amount`.
- `_can_move_troops` validation remains commanded-amount based, including minimum source-garrison checks.
- `_apply_troop_rebalance_suggestion` still delegates to `_move_troops`, so C2 approval uses the same loyalty-loss formula without direct troop writes.
- Added minimal movement preview/status copy for arrived and lost troops.
- `publicSupport` is not used directly for movement loss; movement uses current city loyalty after any seasonal effects.
- Did not change publicSupport calculation, seasonal loyalty calculation, P0-2 city loyalty drift, recruitment/conscription, revolt, tech trees, trade deepening, diplomacy/espionage, battle/invasion/defense logic, battle scene code, save/load core, or large UI.

## v0.69-2 Seasonal Loyalty From Public Support MVP
- Added `_is_seasonal_loyalty_turn`, `_get_next_seasonal_loyalty_turn`, `_calculate_loyalty_delta_from_public_support`, and `_apply_seasonal_loyalty_from_public_support` to `scripts/worldmap_test.gd`.
- Added `_player_state["last_seasonal_loyalty_result"]` for seasonal loyalty result recording.
- Connected seasonal loyalty after publicSupport drift and existing P0-2 city loyalty drift in `_apply_domestic_turn_mvp`.
- Implemented MVP publicSupport thresholds for seasonal loyalty: `90+ => +2`, `80+ => +1`, `60..79 => -1`, `40..59 => -2`, `0..39 => -3`.
- Added minimal City Detail and turn-summary display for seasonal loyalty results.
- Kept publicSupport calculation formula unchanged and kept existing P0-2 city loyalty drift intact.
- Deferred payroll/gold surplus and equipment surplus loyalty modifiers to a future pass.
- Did not implement recruitment/conscription, troop-move loyalty efficiency, revolt, tech trees, trade deepening, diplomacy/espionage, battle/invasion/defense changes, save/load core rewrites, or large UI refactors.

## v0.69-1 Public Support MVP
- Added city-level `publicSupport` runtime support to `scripts/worldmap_test.gd`.
- Added `CITY_PUBLIC_SUPPORT_DEFAULT := 70`, `PUBLIC_SUPPORT_DELTA_MIN := -7`, and `PUBLIC_SUPPORT_DELTA_MAX := 3`.
- Added `_get_city_public_support`, `_set_city_public_support`, `_calculate_city_public_support_delta`, and `_apply_city_public_support_drift_for_world_turn`.
- Public support drift uses MVP tax, food, commerce, and supply-isolation components, with final delta clamped to `-7..+3`.
- Domestic turn now records `_player_state["last_public_support_result"]` and includes public support in `last_domestic_apply_result`.
- City runtime save/load minimally preserves `publicSupport` without rewriting the save/load core structure.
- City Detail internal/supply tab and domestic turn summary show minimal public support values and recent deltas.
- Kept public support and loyalty as separate axes. Existing `loyalty` / `cityLoyalty` and P0-2 city loyalty drift were not replaced.
- Did not implement Seasonal Loyalty From Public Support, recruitment/conscription, troop-move loyalty efficiency, revolt, tech trees, trade deepening, diplomacy/espionage, battle/invasion/defense changes, save/load core rewrites, or large UI refactors.

## v0.69-0 EASTWAR Strategic Simulation Foundation Roadmap Lock
- Compared the five latest confirmed design inputs under `_incoming_confirmed_designs/` against the official `agent/CONFIRMED_*` documents.
- Replaced the official `agent/` design documents with the incoming confirmed versions, keeping `_incoming_confirmed_designs/` out of the commit scope.
- Added five confirmed design lock documents under `agent/`:
  - `CONFIRMED_LOYALTY_PUBLICSUPPORT_DESIGN.md`
  - `CONFIRMED_NATIONAL_TECHTREE_DESIGN.md`
  - `CONFIRMED_CITY_TECHTREE_DESIGN.md`
  - `CONFIRMED_TRADE_SYSTEM_DESIGN.md`
  - `CONFIRMED_DIPLOMACY_ESPIONAGE_REVOLT.md`
- Locked v0.68b as the web MVP port plus first-pass domestic logic baseline at `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions` / commit `aec588b`.
- Recorded completed first-pass domestic logic: governor income effects, city loyalty drift, inter-faction trade income, trade tuning, supply connectivity bonus, City Detail display, manual troop movement C1, and chancellor troop rebalance suggestions C2.
- Recorded the v0.69 EASTWAR strategic simulation foundation principles: `publicSupport` for livelihood/domestic stability, `loyalty` for voluntary military service will/military operation reliability, and `security` as the pressure variable affecting both.
- Recorded the v0.69 task order from Public Support MVP through Diplomacy/Espionage Foundation MVP, with final WorldMap UX/UI information architecture deferred to v0.70.
- Documentation only. Did not modify `scripts/worldmap_test.gd` or implement public support, loyalty formula changes, troop movement formula changes, tech tree, trade deepening, diplomacy, espionage, revolt, UI, battle/invasion/defense, or save/load changes.

## v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions
- Added Phase C C2 chancellor troop rebalance suggestion calculation to `scripts/worldmap_test.gd`.
- Added `ROLE_TARGET_GARRISON_RATIO` as the target-garrison ratio table required by the C2 formula because no existing constant was present.
- Added `_calculate_troop_rebalance_suggestions()` to compute rear/hub surplus -> frontline shortage suggestions from existing supply roles.
- Each generated suggestion includes `from`, `to`, `amount`, `reason`, `from_role`, `to_role`, `from_surplus_before`, and `to_shortage_before`.
- Every suggestion is validated through existing C1 `_can_move_troops`; calculation stores `last_troop_rebalance_suggestions` and does not move troops.
- Added `_apply_troop_rebalance_suggestion()` as a future approval hook that delegates to `_move_troops`.
- Did not implement UI, suggestion cards, automatic redistribution, direct troop writes in C2, C1 validation formula changes, resource changes, Phase A/B/P0-1/P0-2 calculation changes, battle/invasion/defense changes, or save/load core rewrites.

## v0.68b-13-6C1 Troop Move Manual MVP
- Added Phase C C1 manual troop movement to `scripts/worldmap_test.gd`.
- Added minimum source-city garrison rule with `TROOP_MOVE_MIN_GARRISON_RATIO := 0.6`.
- Added validation for positive amount, player ownership, different cities, peacetime, all-player supply path, and minimum garrison.
- Added movement execution that writes only through `_set_city_runtime_troops`, subtracting from source and adding the same amount to destination.
- Added `last_troop_move_result` runtime summary with source, destination, amount, turn, post-move troop counts, and total-preservation audit fields.
- Added minimal City Detail internal/supply tab action for selected-city source movement.
- Did not implement C2 chancellor suggestions, automatic redistribution, resource movement, calculation formula changes, battle scene changes, battle troop formula changes, or save/load core rewrites.

## v0.68b-13-5A City Info Display Spacing Micro Polish
- Polished 13-5 City Info display helper output only.
- Added section titles and line breaks for supply state, supply adjustments, trade result, trade routes, and loyalty drift details.
- Normalized empty-state wording to recent-result messages.
- Limited route display with a simple existing-order `routes.slice(0, 3)` and `외 N개` suffix; routes are not sorted, prioritized, filtered by value, or mutated.
- Did not change calculation logic, result structures, actual resource/loyalty/upkeep/troop values, P0-1, P0-2, Phase A, Phase B, Phase C, battle/invasion/defense, or save/load.

## v0.68b-13-5 City Info Trade Supply Loyalty Display Polish
- Filled the existing City Detail internal/external trade tab cases with display-only result/state text.
- Internal/supply tab now displays selected-city supply role, supplied/isolated state, income multiplier, loyalty delta, and security delta from existing Phase B supply state.
- Internal/supply tab now displays latest selected-city loyalty drift factors from existing result fields and `reasons[]`.
- External trade tab now displays latest Phase A trade route count, applied totals with player totals fallback, gold/rice/barley/seafood/salt summary, and selected-city route snippets.
- Turn result/status summary now includes trade, supply, and city loyalty drift summary text.
- Added formatting helpers only; did not change P0-1, P0-2, Phase A, Phase B, resources, loyalty, upkeep, result structure, Phase C, battle/invasion/defense, or save/load core behavior.

## v0.68b-13-4A Supply Connectivity F6 QA Closeout
- Documented Phase B F6/headless QA results without changing gameplay code.
- Verified starting WorldMap supply state: Hanseong hub, no frontline bonus, no isolated penalty, and normal turn progression.
- Verified connected multi-city ownership classification and supplied-frontline bonuses for income, loyalty, security, and hero-upkeep discount floor.
- Verified isolated disconnected frontline behavior with Kyoto: income penalty, loyalty penalty, security penalty, and no isolated upkeep surcharge.
- Verified save/load recalculation behavior: `last_supply_state_result` can be stale immediately after load but is overwritten by topology-based recalculation.
- Verified light regressions for Phase A trade income, city loyalty/runtime save-load, `faction_relations`, player attack context creation, and enemy invasion/defense event creation.
- Recorded remaining risks and next task candidates: Phase C internal troop rebalance or City Info supply-state display polish.

## v0.68b-13-4 Phase B Supply Connectivity Bonus MVP
- Added Phase B supply connectivity constants and helpers to `scripts/worldmap_test.gd`.
- Added player supply hub selection by largest owned-city population and BFS connectivity through player-owned neighbor cities only.
- Added per-city supply state with `hub`, `frontline`, and `rear` roles; enemy/other-faction adjacent player cities are frontline, and non-hub disconnected cities are isolated.
- Added whole-turn supply calculation once in `_apply_domestic_turn_mvp` and stored the summary in `last_supply_state_result`.
- Wired supply state into domestic income by multiplying existing city effects instead of replacing P0-1 governor/chancellor policy effects.
- Wired supply state into P0-2 city loyalty drift as separate loyalty and security adjustments while preserving the final `-3..+3` clamp.
- Wired supplied-frontline count into hero upkeep as a bounded discount.
- Kept the national single-warehouse model; no city-specific resource storage or resource transfer pipeline was added.
- Did not implement Phase C troop redistribution, battle/invasion/defense supply effects, Phase A trade formula changes, save/load core rewrites, or supply UI.
- Kept `worldmap_test_FULL.gd` out of the commit as the untracked source integration file.

## v0.68b-13-3 Final Merged WorldMap Domestic Trade Loyalty QA
- Applied `worldmap_test_FULL.gd` to `scripts/worldmap_test.gd`.
- Confirmed the merged file contains P0-1 governor income effects, P0-2 city loyalty drift, Phase A inter-faction trade income, and trade tuning C.
- Added/confirmed trade tuning C values: `TRADE_GLOBAL_DAMPENER := 0.5` and `TRADE_FOOD_FACTOR := 1.5`.
- Trade route value calculation now applies the global dampener and uses `TRADE_FOOD_FACTOR` for rice, barley, seafood, and salt.
- Confirmed `_apply_domestic_turn_mvp` order: income, upkeep, Phase A trade, national loyalty, city loyalty drift.
- Diff review found no battle, invasion, or defense logic changes from the integrated file application.
- Did not implement Phase B supply connectivity, internal supply network, troop redistribution, or new gameplay systems.

## v0.68b-13-2 City Loyalty Drift Patch Acceptance QA
- Added P0-2 city loyalty drift constants to `scripts/worldmap_test.gd`: `CITY_LOYALTY_DRIFT_MIN := -3`, `CITY_LOYALTY_DRIFT_MAX := 3`, and `STATIONED_HERO_SECURITY_WEIGHT := 1.0`.
- Added `_apply_city_loyalty_drift_for_world_turn`, `_calculate_city_loyalty_drift`, `_get_city_security_required_troops`, and `_governor_has_aptitude`.
- Wired `_apply_city_loyalty_drift_for_world_turn(tax_level, policy_id)` into `_apply_domestic_turn_mvp` after national loyalty update.
- City loyalty drift now combines tax delta, city security delta, economy delta, military burden delta, and political/administrative governor control mitigation, then clamps to `-3..+3`.
- P0-1 `city_loyalty_loss_multiplier` is now consumed through `_adjust_loyalty_delta` for city tax loyalty drift.
- `recruitable_troops_bonus` remains unconnected and is not used by this patch.
- City loyalty writes through `_get_mutable_city_runtime_state` into `_city_runtime_states`; existing city runtime save/load now minimally preserves `loyalty` and `cityLoyalty`.
- Did not implement Phase A trade, Phase B internal supply, Phase C troop redistribution, battle/invasion/defense changes, governor income formula rewrites, recruitable troop consumers, or save/load core rewrites.

## v0.68b-13-2A Inter-Faction Trade Income MVP
- Added Phase A inter-faction trade income MVP to `scripts/worldmap_test.gd`.
- Added relation/trade constants: `FACTION_RELATION_STATUS`, `TRADE_SUSPENSION_TURNS := 3`, `RELATION_TRADE_MULTIPLIER`, and `TRADE_ROUTE_CAP`.
- Added lazy flat `faction_relations` state under `_player_state`; relation keys use sorted `a|b`, missing keys fall back to `neutral`, and same-faction pairs are excluded.
- Added route helpers for relation keys, trade eligibility, trade pair keys, route value calculation, inter-faction trade result calculation, and player income application.
- Integrated trade income into `_apply_domestic_turn_mvp` after domestic income/upkeep resource application, preserving the existing domestic result and adding `inter_faction_trade_result`.
- Stored `last_inter_faction_trade_result` with `turn`, `route_count`, `player_totals`, `routes`, and `applied_player_totals`.
- Reused existing `_apply_resource_delta` for warehouse-cap clamping and existing `_player_state` full save/load persistence.
- Did not implement Phase B internal supply network, Phase C troop redistribution, diplomacy manipulation UI, trade setting UI, battle/invasion/defense changes, governor income formula rewrites, or P0-2 loyalty/recruitment connection.

## v0.68b-13-1 Governor Income Effect Patch Acceptance QA
- Confirmed the requested P0-1 governor income patch gates were absent from `scripts/worldmap_test.gd`, then added only the narrow missing domestic-income patch points.
- Added `GOVERNOR_PRIMARY_RATE := 0.025` and `GOVERNOR_SECONDARY_RATE := 0.0125`.
- Added `_calculate_city_domestic_effects`, `_apply_governor_type_effect`, and `_apply_governor_policy_effect` using the existing chancellor profile fields and web-parity governor policy multipliers.
- Updated `_calculate_city_domestic_income(..., city_effects: Dictionary = {})` so city-level effects apply before existing chancellor policy and national multipliers.
- Updated `_calculate_player_domestic_income_delta` to calculate city effects per owned city and pass them into city income.
- Left `city_loyalty_loss_multiplier` and `recruitable_troops_bonus` as effect fields only; current Godot code has no loyalty/recruitment consumer for them yet.
- No battle, invasion, defense, save/load, deployment, scene, broad refactor, function move, or whole-file rewrite was performed.

## v0.68b-12b-31 Player Defense Troop Accounting Parity Fix
- Added player attack defender garrison pre-decrement using `defender_total_allocated_troops` and preserved defender source city before/after metadata.
- Added enemy invasion defense attacker/defender troop allocations and pre-decrement for both source cities before battle handoff.
- Extended battle result payload generation so defense battles also return `player_troop_outcome` and `enemy_troop_outcome`.
- Reworked defense victory result application to return player survivors/wounded to the defended city and enemy wounded to the attacker city woundedQueue.
- Reworked defense defeat result application to occupy the defender city with enemy survivors/wounded and return player wounded to the nearest player-owned neighbor when one exists.
- Kept troop counts out of HP/attack/defense scaling and left commandRank/commandLimit clamp, defense deployment UI, hero recruit/conversion, prisoner soldiers, and siege formulas deferred.

## v0.68b-12b-30 Invasion Attack Web Parity Gap Audit
- Added `agent/INVASION_ATTACK_WEB_PARITY_GAP_AUDIT.md`.
- Compared web player attack, enemy invasion/defense, battle result formulas, troop woundedQueue, save/load cleanup, and UI/UX flows against current Godot.
- Confirmed Godot 29A implements player source troop decrement, allocated troop fields, player attack outcome formulas, and player attack woundedQueue persistence.
- Identified P0 gaps: player attack defender garrison pre-decrement, defense battle allocation/result parity, defense woundedQueue/retreat-city troop return, and woundedQueue F6/save-load QA.
- Identified P1 gaps: commandRank/commandLimit allocation clamp, defense default allocation/deployment UI, and player attack F6 allocation QA.
- Marked hero recruit/faction conversion on captured cities, prisoner soldier handling, troop-count combat scaling, and siege-specific formulas as deferred.

## v0.68b-12b-29A Web-Parity Troop Allocation Wounded Queue Import
- Subtracted player attack sortie troops from the source city at deployment confirmation and stored source before/after garrison values in the `player_attack` BattleContext.
- Preserved per-hero `attacker_troop_allocation`, total allocated troops, and defender allocation metadata through BattleContext and battle result return payloads.
- Added `allocated_troops` and `initial_allocated_troops` to battle unit state setup and context hero identity application without changing HP/maxHP from troop counts.
- Added allocated-troop survivor calculation in the battle scene using remaining HP ratio for winning sides, with defeat forcing survivors to 0.
- Added web-parity player attack troop outcomes: win wounded = floor(losses * 0.30), defeat wounded = floor(allocated * 0.50), dead = remaining losses.
- Added city-level troop `woundedQueue` helpers, save/load persistence, and WorldMap turn recovery into garrison troops after 3 turns.
- Player attack victory now places survivors and woundedQueue in the occupied target city; player attack defeat queues wounded troops at the source city and leaves survivors at 0.
- Deferred: defender-side pre-battle troop decrement, troop-count combat scaling, supply combat effects, troop types, siege formulas, loot, and prisoner soldier handling.

## v0.68b-12b-26 Player City Attack MVP Import
- Connected `scripts/worldmap_city_info_panel.gd` attack placeholder to a real `attack_requested(city_id)` signal and WorldMap callback.
- Added player attack eligibility in `scripts/worldmap_test.gd`: enemy target, direct player-owned neighbor, player turn, no pending invasion, and at least one non-captured/dead main attacker in the source city.
- Added player attack source-city selection using the current valid player origin city first, then the first player-owned target neighbor.
- Added `source: player_attack`, `type: attack` BattleContext construction with attacker/defender city ids, owners, troops, hero ids, hero payloads, and existing support metadata.
- Updated `scripts/battle_web_import_test.gd` so player attack contexts place attacker heroes on ally slots and defender heroes on enemy slots, while enemy-invasion defense still maps defender to ally and attacker to enemy.
- Added player attack result handling in WorldMap: player victory occupies the target city for `player`; player defeat leaves target owner unchanged; existing casualty/result-card/hero-state/save-load paths are reused.
- No deployment UI, troop allocation UI, sea/route-type attack, 2-hop attack, siege presentation, AI counterattack, or enemy hero recruitment was added.

## v0.68b-12b-26 Wounded Hero Recovery Turn MVP
- Added `DEFAULT_WOUNDED_RECOVERY_TURNS := 3` and `wounded_turns_remaining` normalization in `scripts/worldmap_test.gd`.
- Wounded placeholder application now assigns a 3-turn recovery counter; captured/dead/normal state clears the counter.
- WorldMap strategy turn advancement now ticks wounded recovery once through `_advance_world_turn_mvp()`.
- Heroes recover to `status: normal`, `wounded: false`, and `wounded_turns_remaining: 0` when the counter reaches zero.
- `worldmap_hero_state` save/load now persists `wounded_turns_remaining`, and older wounded payloads without the field are normalized to 3 turns.
- WorldMap city info, battle formation panels, and result-card naming paths now show `[부상 N턴]` when a wounded hero has remaining recovery turns.
- No treatment UI, recovery item, ability-based recovery duration, prisoner release/recruit/execute, or death handling was added.

## v0.68b-12b-25 Wounded Hero Battle Penalty MVP
- Added wounded combat penalty constants and helpers in `scripts/battle_web_import_test.gd`.
- Wounded heroes remain eligible for battle and keep existing `[부상]` labels; captured/dead exclusion remains unchanged.
- Basic attack damage now applies a `0.75` wounded attacker multiplier on actual damage resolution.
- Wounded defenders now take `1.20x` incoming damage as the MVP defense-performance penalty.
- Unique-skill numeric effects now apply a `0.70` wounded caster multiplier for damage, splash, attack buff, and defense buff amounts.
- No new save fields were added; battle penalty lookup uses the existing context/hero registry status fields preserved from `worldmap_hero_state`.
- No wound recovery, treatment UI, prisoner flow, death processing, or full stat-balance pass was added.

## v0.68b-12b-24 Captured Hero Battle Exclusion MVP
- Added captured/dead battle-exclusion helpers in `scripts/worldmap_test.gd`.
- WorldMap invasion BattleContext roster construction now skips heroes whose runtime state is `captured == true`, `status == "captured"`, or `dead == true`.
- Main attacker/defender picks and support/reinforcement candidate picks share the same append guard, with concise `[HERO_BATTLE_EXCLUDE]` / `[REINFORCE_SKIP]` logs.
- Captured heroes remain in city `stationed_hero_ids` / `hero_ids` and continue to show `[포로]` in WorldMap city information; wounded heroes are still battle-eligible.
- Added a battle-scene defensive guard in `scripts/battle_web_import_test.gd` so captured/dead WorldMap context heroes are deactivated before slot assignment.
- No prisoner movement, holding UI, recruit/execute/release, wound recovery, wounded penalty, or real death system was added.

## v0.68b-12b-23 Hero State Visual Marker Roster Badge MVP
- Added hero state badge helpers for WorldMap and battle roster display paths.
- Badge priority is `dead` -> `captured` -> `wounded` -> normal, rendering `[사망]`, `[포로]`, `[부상]`, or no badge.
- WorldMap selected-city/right city panel hero data now receives runtime `_hero_runtime_states` merged over `HERO_DATA`, so saved/loaded wounded or captured state can be displayed.
- Right city stationed hero lists and governor labels append the state badge through the existing text labels.
- BattleContext hero registry entries now preserve `status`, `wounded`, `captured`, and `dead`, and battle formation panels append the badge to the displayed hero name.
- Post-battle result card hero summaries now reuse the name-with-state marker style.
- No captured hero battle exclusion, roster removal, prisoner movement, wound recovery, death processing, icon art, or stat penalty system was added.

## v0.68b-12b-22 Hero Wound Capture Placeholder MVP
- Added losing-side hero status placeholder application in `scripts/worldmap_test.gd` after invasion battle results.
- Deterministic MVP rule: first eligible losing-side hero is marked `wounded`, second eligible losing-side hero is marked `captured`, and `dead` is never applied.
- Existing captured/dead or missing heroes are skipped with concise `[HERO_STATE_SKIP]` logs.
- Status changes update `_hero_runtime_states` only; `HERO_DATA` and city rosters are not mutated for prisoner movement.
- Captured heroes remain in `stationed_hero_ids` / `hero_ids`; no prison, recruitment, execution, movement, or recovery system was added.
- The post-battle result card now includes a compact hero status summary line.
- Existing `worldmap_hero_state` save/load persists the new wounded/captured placeholder state.

## v0.68b-12b-21 Post Battle Result Panel Polish MVP
- Added a display-only post-battle result summary path in `scripts/worldmap_test.gd` after WorldMap invasion battle return.
- Reused the left World HUD by adding a compact `PostBattleResultCard` programmatically instead of creating a new scene or large UI flow.
- Defender victory summaries show city defense success, ownership retention, defender city troop change, and attacker source-city troop change.
- Attacker victory summaries show city fall, ownership change, defender city/occupation troops, and attacker source-city troop change.
- Retreat/unknown paths now produce non-crashing summary copy with ownership-change notes.
- Result summaries are not saved/restored; save/load still persists the actual owner/troop/runtime hero state only.
- Deferred: prisoner/wound/death display, resource loot display, detailed battle statistics, and a full result report UI.

## v0.68b-12b-20 Invasion Casualty Formula Hero State MVP
- Added MVP invasion casualty calculation in `scripts/worldmap_test.gd` for defender-win and attacker-win result application.
- Defense victory now preserves ownership, applies a bounded defender city troop loss, and applies heavier attacker source-city troop loss.
- Defense defeat now transfers city ownership, applies occupation troops from attacker survivors/fallbacks, and reduces the attacker source city by the detached occupation force.
- Troop values are normalized through nonnegative clamp guards with a temporary upper bound; current rates are MVP balance placeholders.
- Extended `worldmap_hero_state` save/load with `status`, `wounded`, `captured`, and `dead` while defaulting missing fields to `normal` / `false`.
- No actual wound/capture/death roll, hero removal, resource looting, strategic AI recalculation, or multi-invasion queue behavior was implemented.

## v0.68b-12b-19 WorldMap Battle Result Save Load Persistence MVP
- Extended `scripts/worldmap_test.gd` save payload to include `worldmap_city_state` runtime overrides for city owner/nation/owner_faction_id, troops, and stationed hero ids.
- Added `worldmap_hero_state` runtime overrides for hero current city id fields (`current_city_id`, `city_id`, `location_city_id`).
- Load now keeps seed data read-only, clears stale runtime state, applies city/hero overrides with missing id skip logs, refreshes city marker ownership, and rebinds WorldMap UI data.
- Invasion result application now syncs hero runtime locations from mutable city runtime rosters after pending invasion cleanup.
- Save/load clears pending invasion event/context and `enemy_invasion_roll_turn`, so resolved invasion prompts do not reappear after reload.
- Added concise `[SAVE_WORLD_STATE]`, `[LOAD_WORLD_STATE]`, `[SAVE_CITY_STATE]`, `[LOAD_CITY_STATE]`, `[SAVE_HERO_STATE]`, `[LOAD_HERO_STATE]`, and `[LOAD_STATE_SKIP]` logs.
- Deferred: hero wounds/capture/death, resource looting, precise casualty calculation, AI strategy recalculation, and multi-invasion queues.

## v0.68b-12b-18c Reinforcement Toast Auto Battle Final Stop Hotfix
- Fixed false reinforcement arrival toast display in `scripts/battle_web_import_test.gd`: support arrival toasts now require at least one actually deployed arriving unit.
- Root cause: the round-based reinforcement path attempted deployment and always queued the toast/log, even if WorldMap context support slots were inactive/empty and no unit was deployed.
- `reinforce_01` and city reinforcement arrival paths now collect successful arriving hero ids, skip toast on an empty list, and log `[REINFORCEMENT_TOAST_SKIP]` / `[REINFORCEMENT_ARRIVAL]`.
- Inactive context support slots are excluded from city reinforcement readiness and generic reinforcement deploy checks.
- Strengthened result-finalized guards across enemy turn/action callbacks, move/attack finish callbacks, confused ally auto-consume, round start, reinforcement deploy checks, auto action start, and toast enqueue/playback.
- Non-result pending/current battle toasts are cleared or blocked after victory/defeat finalization; result toast and worldmap return remain intact.
- Deferred/manual QA: F6 no-support invasion turn-3 toast check, sample battle real support toast check, immediate auto battle stop after victory/defeat, and worldmap return.

## v0.68b-12b-18b Roster Panel Source Auto Battle End Hotfix
- Fixed the remaining formation-panel sample roster leak in `scripts/battle_web_import_test.gd`: WorldMap context panel slots now use assigned context hero ids first and hide empty/inactive context slots.
- Root cause: `_refresh_formation_slot_guide_for_entry()` read capacity-slot `unit_state` first, and `_get_hero_id_for_unit_state()` could still return `TEST_BATTLE_ROSTER` fallback identities for inactive support slots.
- Empty support cells in WorldMap enemy-invasion panels now stay hidden instead of showing sample heroes such as 김유신/을지문덕/유비/제갈량. Direct sample battle fallback remains available outside WorldMap context.
- Added concise `[ROSTER_PANEL_SLOT]` / `[ROSTER_PANEL_SKIP]` logs for context-vs-sample panel source decisions.
- Added battle-end guards so finalized victory/defeat stops full auto battle and blocks deferred auto tick / ally-turn scheduling after result.
- Save/Load, hero wounds/capture, hero movement, city ownership result logic, portrait binding, skill binding, and reinforcement 1-hop/2-hop rules remain unchanged.
- Deferred/manual QA: live F6 백제/사비 invasion panel roster, empty support panel visibility, auto battle stop timing after result, and worldmap return.

## v0.68b-12b-18a Reinforcement Fallback Leak Toast Layer Hotfix
- Fixed the confirmed 유비/제갈량 support leak source in `scripts/battle_web_import_test.gd`: WorldMap `enemy_invasion` context sides no longer fill empty slots from `TEST_BATTLE_ROSTER`.
- Empty invasion support slots now deactivate and stay hidden when nearby eligible reinforcements are unavailable; direct sample battle fallback remains available outside WorldMap invasion context.
- Added concise `[CONTEXT_SLOT]`, `[CONTEXT_SLOT_SKIP]`, and `[CONTEXT_SLOT_FALLBACK]` logs around context slot fallback decisions.
- Set `RoundToastRoot.z_index = 300` and suppress facing indicators during round/reinforcement/unique-skill toast playback, restoring them after the toast ends.
- Deferred/manual QA: F6 사비/백제 invasion support leak check, toast arrow visibility/restoration, automatic battle flow, and worldmap return.

## v0.68b-12b-18 Invasion Reinforcement Source Rule MVP
- Added WorldMap invasion BattleContext roster source rules in `scripts/worldmap_test.gd`: main attacker/defender heroes come from the attacker/defender city stationed roster first.
- Reinforcement candidates now come only from same-faction or explicitly allied cities within MVP adjacency range: direct neighbors first, then 2-hop neighbors. No 3-hop or full `HERO_DATA` pool search is used.
- Missing reinforcements are left empty instead of force-filled from distant cities; fallback is documented and logged as a crash guard only.
- Updated `scripts/battle_web_import_test.gd` so WorldMap context battles deactivate empty context slots instead of filling them with sample `TEST_BATTLE_ROSTER` heroes.
- Added concise `[REINFORCE_RULE]`, `[REINFORCE_PICK]`, `[REINFORCE_SKIP]`, and `[REINFORCE_FALLBACK]` logs for source city, faction, candidate city, chosen hero, duplicate, wrong faction, missing city, and empty roster cases.
- Static 평양 -> 한성 verification excludes 성도 from the 2-hop candidate set, so 성도 유비/제갈량 are not eligible as ordinary support heroes.
- Save/Load persistence, hero wounds/capture, precise strategic AI, resource looting, and city ownership result logic remain unchanged.

## v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix
- Restored battlefield portrait badge sizing in `scripts/battle_web_import_test.gd` to the previous engine baseline: existing `128x128` battlefield portrait assets used scene scale `0.32`, so 512-source portraits now scale to about `41px` on the battlefield badge.
- Kept the single 512 `portrait_path` source contract. No image files were generated, moved, or deleted, and no `portrait_128_path` / `portrait_512_path` fields were added.
- Changed WorldMap context skill entry creation so real `skill_name` is preferred and `장수명 전법` is used only as a final fallback.
- When context skill data only has a generated fallback name or missing cutin path, the existing sample unique-skill registry supplies the established skill name and cutin path where available. This preserves the existing unique-skill toast frame/animation path instead of forcing the common fallback icon.
- Updated sample Yi Sunsin skill display from `학익진 포격` to `학익진`; Eulji Mundeok keeps `살수대첩 매복`, and v0.68b-12b-16b heroes keep their confirmed skill names.
- Full cutin presentation, save/load expansion, capture/wounds/death, hero movement, and resource looting remain unimplemented.

## v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP
- Updated `scripts/battle_web_import_test.gd` so WorldMap context hero and skill registries take priority over sample `HERO_REGISTRY` / `UNIQUE_SKILL_REGISTRY` fallbacks when a battle is launched from WorldMap context.
- Added a safe hero portrait resolver that checks `portrait_path` / portrait registry fields with `ResourceLoader.exists()` before loading and falls back to a named common unknown portrait texture instead of a specific sample hero face.
- Battle portrait `Sprite2D` slots now load the single 512-source `portrait_path` texture and scale it to the existing 128 portrait slot target. No split `portrait_128_path` / `portrait_512_path` fields or new image files were added.
- Formation guide and closeup portrait lookups now use the same resolver/fallback path.
- Unique-skill toast lookup now prefers WorldMap context `skill_name` / skill data and uses a common skill fallback icon when no dedicated skill toast/cutin image exists.
- Cutin presentation, save/load expansion, capture/wounds/death, hero movement, and resource looting remain unimplemented.

## v0.68b-12b-16c Hero Portrait Import Metadata Audit
- Audited Godot hero portrait import metadata policy without changing battle logic, `HERO_DATA`, image files, or existing 128 folders.
- Confirmed this repo already tracks many `.png.import` files, including the current `assets/heroes/portraits/**` portrait imports, despite `.gitignore` also ignoring the generated `.import/` cache directory.
- `assets/heroes/portraits` had no remaining untracked or ignored `.import` files, so no portrait import metadata files were deleted or newly added.
- Next task is `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`.

## v0.68b-12b-16b Hero Placement Data Patch
- Updated `scripts/worldmap_test.gd` hero seed data for five key heroes: `liu_bei`, `kwon_yul`, `cheok_jun_gyeong`, `lu_bu`, and `xiahou_dun`.
- Added or strengthened combat/skill contract fields for those heroes, including `unit_type`, troop counts, command/leadership, attack/defense/mobility/ranges, `unique_skill_id`, `skill_id`, `skill_name`, `skill_desc`, `skill_effect_type`, `skill_power`, `skill_cooldown`, and `skill_toast_icon`.
- Applied confirmed unique skill names: 유비 `인의의 깃발`, 권율 `행주대첩 항전`, 척준경 `검왕돌파`, 여포 `무쌍난무`, 하후돈 `발검돌파`.
- Updated city placement: 유비 -> 성도, 권율 -> 한성, 척준경 -> 평양, 여포 -> 낙양, 하후돈 -> 업성. 척준경 was removed from 한성 and moved to 평양.
- Preserved the 512-source portrait contract with one `portrait_path` and separate `cutin_path`; no `portrait_128_path` / `portrait_512_path` fields were added.
- Adjusted WorldMap BattleContext hero-copy logic to preserve explicit `portrait_path` / `cutin_path` values when present, so hero IDs can differ from normalized asset filenames.
- Verification: `git diff --check`, target hero/skill/path strings, city roster strings, no split portrait fields in `scripts`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Deferred: save/load hero placement persistence expansion, capture/wound/death, hero movement system, precise unique-skill balancing, and cutin presentation.

## v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP
- Added a runtime hero battle-data contract path for WorldMap invasion BattleContext in `scripts/worldmap_test.gd`.
- Existing sample battle structure confirmed: `scripts/battle_web_import_test.gd` owns `HERO_REGISTRY`, `TEST_BATTLE_ROSTER`, and `UNIQUE_SKILL_REGISTRY`; direct battle launch still uses that fallback unchanged.
- Actual WorldMap heroes remain sourced from `HERO_DATA` and city `stationed_hero_ids` / `hero_ids`; BattleContext now includes `attacker_heroes` and `defender_heroes` enriched from that data.
- Every BattleContext hero copy now carries combat contract fields including `unit_type`, `troop_count`, `leadership` / `command`, `war`, `attack`, `defense`, `intelligence`, `move_range` / `mobility`, `attack_range`, `skill_id`, `skill_name`, `skill_desc`, `skill_effect_type`, `skill_power` / `skill_value`, `skill_range`, `skill_cooldown`, and `skill_toast_icon`.
- Added portrait/cutin contract fields: one canonical 512-source `portrait_path` under `res://assets/heroes/portraits/{nation}/{nation}_{hero_id}.png`, and separate `cutin_path` under `res://assets/heroes/cutins/{nation}/{nation}_{hero_id}_cutin.png`.
- The 128 battle slots are expected to scale down from `portrait_path`; no `portrait_128_path` or `portrait_512_path` split was added, and existing 128 folders were not deleted.
- Battle scene now registers WorldMap context hero/skill data into runtime registries before roster assignment; missing or unsupported heroes still fall back to `TEST_BATTLE_ROSTER`.
- Image loading remains safe: context portrait/cutin paths are treated as contract data and only passed to battle runtime if `ResourceLoader.exists()` confirms the file exists.
- Deferred: actual bulk image binding, 512 asset import, cutin presentation completion, save/load expansion, hero movement/capture/wounds/death, resource looting, and precise unique-skill balance.
- Verification: `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, root `Battle_Fullscreen_Test.tscn` headless load, no new `portrait_128_path` / `portrait_512_path` fields, and existing sample battle fallback output stayed intact.

## v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix
- Fixed F6 manual invasion battle return crash in `scripts/worldmap_test.gd`: `Dictionary is in read-only state` during `_set_city_runtime_troops()`.
- Cause: the previous result-apply MVP wrote `troops`, `owner`, and `nation` directly into `CITY_HUD_DATA` city dictionaries, which can be read-only seed/static data in Godot.
- Added mutable runtime city state storage in `_city_runtime_states`; troop/owner changes now duplicate the source city dictionary with `duplicate(true)`, modify the copy, and store it back into runtime state.
- Rebound the right `CityInfoPanel` to a merged seed + runtime city data map so ownership/troop changes are visible without mutating seed data.
- Renamed the unused attacker-city-name parameter in `_apply_attacker_win_invasion_result()` to `_attacker_city_name`.
- Verification: `git diff --check` passed, Godot project headless load passed, root `WorldMap_Test.tscn` headless load passed, and root `Battle_Fullscreen_Test.tscn` headless load passed.
- Remaining risk: full F6 manual invasion victory/defeat return still needs live click-through confirmation because headless load cannot complete the battle-return UI loop.

## v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP
- Applied returned WorldMap enemy-invasion battle results in `scripts/worldmap_test.gd` through a bounded `_apply_invasion_battle_result()` flow.
- Warning/cause context: the previous result-return MVP only consumed the payload, cleared pending invasion state, and displayed a status; ownership/troop application remained intentionally deferred.
- Extended `scripts/battle_web_import_test.gd` result payloads with attacker/defender owner ids, starting troop counts, and surviving deployed troop totals so WorldMap can apply a minimal runtime result.
- Defense victory keeps target-city ownership unchanged, clears the pending invasion/context, shows a defense-success message, and applies minimal nonnegative troop reductions when current/payload troop fields are available.
- Defense defeat transfers the target city to the attacker owner using existing `owner` / `nation` city fields plus `WorldMapCityMarker.owner_faction_id`, updates the player owned-city list, sets safe occupation troops from attacker survivors or a fallback, and refreshes marker/panels.
- Retreat/cancel/aborted/unknown results do not change ownership, clear the pending invasion safely, and show a non-crashing Korean status message.
- Kept deferred: hero capture, hero city movement, resource losses/looting, detailed casualty calculation, AI strategy recalculation, multi-invasion queues, and save/load persistence expansion for resolved city ownership.
- Verification: patch strings present, `git diff --check` passed, Godot project headless load passed, root `WorldMap_Test.tscn` headless load passed, and root `Battle_Fullscreen_Test.tscn` headless load passed with no integer division or owner-shadow warnings in headless output.
- Remaining risk: full interactive F6 flow should still confirm manual defense, battle return button, victory/defeat ownership visuals, and retreat/unknown handling because headless scene load cannot click through the complete battle loop.

## v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup
- Fixed the remaining Godot warning where local variable `owner` shadowed the base `Node.owner` property.
- Cause: `scripts/battle_web_import_test.gd` used a local `owner` variable while applying WorldMap context-side roster metadata.
- Renamed the local variable to `city_owner_id` and updated only the two references in that local scope.
- Kept behavior unchanged: the returned summary key remains `"owner"` and capacity-slot metadata still writes `"source_owner"` with the same context value.
- Kept the hotfix bounded: no battle result apply, city ownership logic, troop/resource mutation, invasion flow, battle transition, turn/domestic logic, or save/load behavior changed.
- Verification: repo-local GDScript search found no remaining `var owner` locals, `git diff --check` passed, Godot project headless load passed, root `WorldMap_Test.tscn` headless load passed, and root `Battle_Fullscreen_Test.tscn` headless load passed.
- Remaining risk: full interactive F6 console warning cleanliness still needs 김작 confirmation because headless load does not exercise every live UI path.

## v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup
- Fixed Godot yellow `GDScript::reload: Integer division. Decimal part will be discarded.` warnings in `scripts/worldmap_test.gd`.
- Cause: WorldMap calendar helpers used integer `/` for year and season-index calculation: `zero_based_turn / 40` and `(zero_based_turn % 40) / 10`.
- Made the intended integer division explicit with `floori(float(... ) / float(...))` while preserving the calendar contract: start year `154`, `10` turns per season, and `40` turns per year.
- Kept the hotfix bounded: no gameplay behavior, battle result ownership apply, troop/resource mutation, invasion flow, turn cycle behavior, domestic apply, save/load, panel layout redesign, or portrait binding behavior was changed.
- Verification: patch strings present, calendar constants reviewed, ambiguous calendar integer divisions removed, `git diff --check` passed, Godot project headless load passed, root `WorldMap_Test.tscn` headless load passed, and root `Battle_Fullscreen_Test.tscn` headless load passed.
- Remaining risk: full interactive F6 console warning cleanliness still needs 김작 visual/runtime confirmation because headless scene load does not exercise every UI interaction path.

## v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard
- Fixed a WorldMap F6 runtime error in `scripts/worldmap_test.gd` where `_refresh_unified_panel_chrome()` could assign `.visible` on missing unified panel chrome nodes.
- Cause: the unified panel chrome refresh path assumed runtime-created primary tab buttons and scene tab controls were always non-null.
- Added guarded primary-tab creation, null checks before `.visible` / `.modulate` writes, and a concise one-time warning for missing unified panel chrome nodes.
- Kept the hotfix bounded: no gameplay behavior, battle result apply, city ownership, troop/resource mutation, invasion flow, turn logic, domestic apply, or save/load behavior was changed.
- Verification: patch strings present, `_refresh_unified_panel_chrome()` visible writes guarded, `git diff --check` passed, Godot project headless load passed, and root `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-14 WorldMap Battle Result Return MVP
- Added runtime-only battle result return in `scripts/battle_web_import_test.gd` and `scripts/worldmap_test.gd`.
- Inspected local read-only web references: `C:\dev\SamWar_web\js\core\battle_state.js`, `js\core\battle_rules.js`, `js\core\world_rules.js`, `js\core\app_state.js`, `js\ui\world_map_ui.js`, `js\ui\world_hud_ui.js`, and `js\main.js`.
- Battle result payload uses Godot `Engine` metadata key `samwar_worldmap_battle_result` with source/type/mode/result/winner, attacker/defender city ids and names, and turn number.
- WorldMap-launched battles now reveal a runtime `월드맵으로 돌아가기` button after victory/defeat; pressing it stores the result payload and transitions back to `res://WorldMap_Test.tscn`.
- Direct `Battle_Fullscreen_Test.tscn` launch remains unchanged: missing WorldMap context keeps the return button hidden and the demo battle path intact.
- WorldMap consumes and clears the result metadata on startup, shows a Korean result status, clears pending invasion event and pending battle context, hides the pending choice card, and refreshes panels.
- Kept the patch bounded: no city ownership change, troop/resource loss apply, hero movement/capture, auto battle resolution change, combat balance change, defense deployment UI, or broad battle refactor was added.
- Verification: patch strings present, result metadata paths present, forbidden implementation search reviewed, `git diff --check` passed, Godot project headless load passed, root `WorldMap_Test.tscn` headless load passed, and root `Battle_Fullscreen_Test.tscn` direct headless load passed.

## v0.68b-12b-13 Battle Roster Context Apply MVP
- Updated `scripts/battle_web_import_test.gd` so `Battle_Fullscreen_Test.tscn` applies WorldMap handoff context to the existing battle capacity slots when launched from WorldMap.
- Inspected local read-only web references: `C:\dev\SamWar_web\data\battle_rosters.js`, `data\heroes.js`, `data\cities.js`, `js\core\battle_state.js`, `js\core\battle_rules.js`, `js\core\battle_ai.js`, `js\core\world_rules.js`, and `js\core\app_state.js`.
- Roster mapping follows the web defense direction: defender governor/stationed hero ids feed ally slots, attacker governor/stationed hero ids feed enemy slots.
- Added a compact compatibility map for current battle-registry hero ids such as `yi_sun_sin` -> `yi_sunsin`, `jeong_do_jeon` -> `jeong_dojeon`, and `kim_yu_sin` -> `gim_yusin`.
- Direct battle scene launch remains unchanged: if no `samwar_worldmap_battle_context` metadata exists, the existing `TEST_BATTLE_ROSTER` demo setup is used.
- Fallback behavior is safe for missing context, empty hero arrays, unknown hero ids, missing governors, and missing portraits; unresolved heroes fall back per slot to the demo roster.
- City troop/garrison values are kept as context metadata only for now; combat HP/troop scaling remains deferred to avoid a balance rewrite.
- Kept the patch bounded: no battle result return, WorldMap ownership apply, WorldMap troop/resource mutation, auto battle resolution, defense deployment UI, or broad battle refactor was added.
- Verification: patch strings present, direct/context paths reviewed, forbidden implementation search reviewed, `git diff --check` passed, Godot project headless load passed, root `WorldMap_Test.tscn` headless load passed, and root `Battle_Fullscreen_Test.tscn` headless load passed.

## v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP
- Connected WorldMap pending invasion defense choices to the current stable battle scene `Battle_Fullscreen_Test.tscn`.
- Added runtime-only handoff in `scripts/worldmap_test.gd`: manual/auto defense builds or reuses pending battle context, stores a deep copy in Godot `Engine` metadata, and calls `change_scene_to_file("res://Battle_Fullscreen_Test.tscn")`.
- Added safe battle-scene intake in `scripts/battle_web_import_test.gd`: the controller reads the metadata once, clears it immediately, stores a local `worldmap_battle_context`, and logs mode plus attacker/defender city names.
- Passed the full previous BattleContext MVP payload: type, source, mode, attacker/defender ids and names, turn numbers, owners, troop counts, stationed hero ids, and governor ids.
- Preserved direct battle test behavior: if no WorldMap context exists, `Battle_Fullscreen_Test.tscn` keeps the existing demo setup and logs `No WorldMap battle context; using test battle setup`.
- Kept the patch bounded: no battle result return, city ownership change, troop/resource loss, hero movement/capture, auto battle resolution, defense deployment UI, enemy AI expansion, pathfinding, diplomacy/cooldown, or broad battle refactor was added.
- Verification: patch strings present, battle scene path documented in code, handoff/intake paths present, `git diff --check` passed, Godot project headless load passed, root `WorldMap_Test.tscn` headless load passed, and `Battle_Fullscreen_Test.tscn` direct headless load passed.

## v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge
- Added a safe runtime BattleContext bridge in `scripts/worldmap_test.gd`; `WorldMap_Test.tscn`, `scripts/worldmap_city_info_panel.gd`, and `scripts/worldmap_hero_portrait_helper.gd` were inspected but not modified for this patch.
- Inspected local read-only web references: `C:\dev\SamWar_web\js\core\battle_state.js`, `js\core\battle_rules.js`, `js\core\world_rules.js`, `js\core\app_state.js`, `js\ui\world_map_ui.js`, `js\ui\world_hud_ui.js`, `js\main.js`, `data\battle_rosters.js`, `data\cities.js`, and `data\heroes.js`.
- Manual and auto defense buttons now validate `_player_state.pending_invasion_event`, build `_player_state.pending_battle_context`, and show concise Korean preparation status without opening battle scenes or dumping raw dictionaries.
- BattleContext MVP shape includes defense type/source/mode, attacker/defender city ids and names, turn numbers, owner ids, troop totals, stationed hero ids, and governor ids where available from current seed/state.
- Validation fails safely for missing event, non-defense type, unknown attacker/defender city ids, non-enemy attacker ownership, or non-player defender ownership; failure clears only the runtime pending battle context.
- Save/load/reset policy follows the web audit: pending invasion event and pending battle context are runtime-only, excluded from save serialization, and cleared on load/reset normalization.
- Kept the patch bounded: no battle scene transition, defense deployment UI, auto battle resolution, battle result application, city ownership mutation, troop/resource loss, hero movement, governor appointment execution, enemy AI expansion, pathfinding, diplomacy, cooldowns, or multiple enemy actions were added.
- Verification: patch strings present, context/validation/manual/auto paths present, forbidden implementation search reviewed, `git diff --check` passed, Godot project headless load passed, and root `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP
- Added shared portrait lookup/apply helper `scripts/worldmap_hero_portrait_helper.gd` for WorldMap UI reuse.
- Inspected repo-local asset folders including `assets/web_battle/portraits` and `assets/web_battle/portraits_battlefield`; no image files were moved, deleted, edited, or generated.
- Portrait lookup uses existing `HERO_DATA` portrait fields such as `portrait_image`, maps legacy seed paths under `assets/portraits/...` to existing `assets/web_battle/portraits/...`, and includes compact compatibility paths for known available portrait files.
- Updated the left chancellor card and right taesu/governor card to show a `TextureRect` portrait when a texture resolves and keep the existing dark `?` fallback when missing or failed.
- Kept stationed hero list text-only for this MVP to avoid crowding the cleaned right city panel; future pending invasion/defense UI can call the shared helper.
- Kept the patch bounded: no BattleContext, battle scene transition, defense deployment, auto defense resolution, city ownership change, troop loss, hero movement, governor/chancellor appointment execution, enemy AI expansion, or asset import/move work was added.
- Verification: patch strings present, portrait helper/bindings present, `git diff --check` passed, Godot project headless load passed, and root `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup
- Cleaned the right `CityInfoPanel` / selected-city panel in `scripts/worldmap_city_info_panel.gd`, with pending invasion state supplied from `scripts/worldmap_test.gd`.
- Inspected local read-only web references: `C:\dev\SamWar_web\js\ui\world_map_ui.js`, `js\ui\world_hud_ui.js`, `js\ui\ui_render.js`, `js\ui\selected_city_ui.js`, `js\core\app_state.js`, `js\core\world_rules.js`, `data\cities.js`, and `data\heroes.js`.
- The selected city panel now shows a clean Korean layout for city name, owner/nation/region, population, gold, food, resource ratings, troops, defense, public support/order, commerce, agriculture, governor/taesu, and stationed heroes.
- No selected city now displays `선택 도시 없음` and `월드맵에서 도시를 선택하십시오.` without raw ids, nulls, dictionary dumps, or visible placeholder blocks.
- Pending invasion integration remains display-only: selected defender cities show `침공 대상 도시 · 방어전 준비 중`, while selected attacker cities show `침공 출발 도시`.
- Kept the patch bounded: no BattleContext, battle scene transition, defense deployment, auto defense resolution, ownership change, troop loss, hero movement, governor appointment execution, enemy AI expansion, pathfinding, or route logic was added.
- Verification: patch strings present, right-panel fallback/field/taesu/stationed-hero/pending-invasion strings present, `git diff --check` passed, Godot project headless load passed, and root `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-10.5 Session Handoff Docs Update Before Stop
- Updated handoff documentation only; no gameplay code or scene files were modified.
- Recorded the current stable baseline as `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP` at commit `6d3616339e5d555127c5f4eb5eb91160d362aa2e`.
- Documented the completed WorldMap flow from `v0.68b-12b-1` seed import through `v0.68b-12b-10` enemy invasion choice UI.
- Documented current implemented systems: web seed import, left panel web-parity controls, turn loop/calendar, save/load/reset, domestic apply, and enemy invasion event/choice UI.
- Documented explicit deferred systems: right city info cleanup, hero portrait binding, BattleContext generation, battle scene handoff, defense deployment, auto defense, battle return/result ownership apply, enemy AI, internal supply/troop/trade systems, soldier upkeep/salt consumption, and full governor appointment execution.
- Updated the next recommended task order to start with `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup`, then `12b-10b` portrait binding, then `12b-11` BattleContext bridge and later battle handoff/result/ownership tasks.
- Recorded operational notes: active scene is root `WorldMap_Test.tscn`, `scenes/WorldMap_Test.tscn` may not exist, runtime save path is `user://worldmap_left_panel_state.json`, `agent/LOCAL_ENV.md` and `.godot/` stay ignored, pending invasion state is not persisted, and BattleContext remains intentionally deferred.
- Verification: docs-only diff reviewed, `git diff --check` passed, `git status --short --ignored` reviewed, and no code/scene files were changed.

## v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP
- Added a web-like pending invasion choice UI in `scripts/worldmap_test.gd`; the active root `WorldMap_Test.tscn` was inspected but not modified.
- Inspected local read-only web references: `C:\dev\SamWar_web\js\ui\ui_render.js`, `js\ui\world_map_ui.js`, `js\core\app_state.js`, `js\core\world_rules.js`, `js\core\battle_state.js`, `js\core\battle_rules.js`, `js\ui\world_hud_ui.js`, and `js\main.js`.
- Added runtime `PendingInvasionChoiceCard` under the existing left world status panel, hidden when `_player_state.pending_invasion_event` is empty and visible when an event exists.
- The card shows `Enemy Invasion`, `적군 침공 발생`, attacker/defender city lines, `방어전을 준비하십시오.`, and `수동 방어` / `자동 방어` buttons.
- Added placeholder-only button handlers: manual defense reports that manual defense preparation will be connected later, auto defense reports that auto defense will be connected later, and both keep the pending event intact.
- Blocked/disabled `아군 턴 종료` while a pending invasion event exists so new enemy invasion events cannot stack before the pending choice is handled.
- Preserved the existing save/load/reset policy: pending invasion event state is excluded from saves and cleared on load/reset, so the card hides after load/reset.
- Kept the patch bounded: no `BattleContext`, battle scene transition, defense hero deployment UI, auto battle resolution, city ownership change, troop loss, hero movement, enemy AI expansion, route/pathfinding, diplomacy/cooldown rule, or battle result resolution was added.
- Verification: patch strings present, choice card/button paths present, save/load/reset clearing policy reviewed, forbidden implementation search reviewed, `git diff --check` passed, Godot project headless load passed, and `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-9 WorldMap Enemy Invasion Event MVP
- Added the first Godot enemy invasion event MVP in `scripts/worldmap_test.gd`; the active root `WorldMap_Test.tscn` was inspected but not modified.
- Rechecked local read-only web sources: `C:\dev\SamWar_web\js\core\world_rules.js`, `js\core\app_state.js`, and `js\core\save_load.js`.
- Ported the audited web candidate rule at event-only scope: `ENEMY_INVASION_CHANCE = 0.45`, attacker is an enemy-owned city marker, defender is a neighboring player-owned city marker, and the selected pair is random.
- Integrated the roll into the existing enemy-turn placeholder path with a same-turn roll guard and pending-event guard so duplicate timer callbacks cannot create repeated invasion events for the same pending event.
- Added `_player_state.pending_invasion_event` as a display-only defense event containing attacker city id, defender city id, source, and turn number; no final battle context is created.
- Added visible left-panel status text for an invasion and selected the defender city for visibility while preserving the existing turn loop and domestic apply behavior.
- Runtime save data clears/excludes pending invasion event state, and load/reset clear the event; load also normalizes enemy-phase saves back to player turn to avoid resuming a pending invasion roll.
- Kept the patch bounded: no `BattleContext`, battle scene transition, defense deployment UI, city ownership change, troop loss, hero movement, enemy AI, pathfinding, route-type requirement, diplomacy/cooldown rule, or battle result resolution was added.
- Verification: patch strings present, invasion constant/helpers present, save/load/reset policy reviewed, forbidden implementation search reviewed, `git diff --check` passed, Godot project headless load passed, and `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit
- Completed a docs-only audit of the web worldmap enemy invasion flow and added `agent/ENEMY_INVASION_AUDIT.md`.
- Inspected local read-only web sources: `C:\dev\SamWar_web\js\core\app_state.js`, `world_rules.js`, `world_calendar.js`, `save_load.js`, `battle_state.js`, `battle_rules.js`, `battle_ai.js`, `js\ui\world_hud_ui.js`, `world_map_ui.js`, `ui_render.js`, `main.js`, and `constants.js`.
- Found that web enemy invasion is rolled from `app_state.endWorldTurn()` after player-side turn systems, using `world_rules.rollEnemyInvasion()` with `ENEMY_INVASION_CHANCE = 0.45`.
- Documented the web selection rules: eligible candidates are enemy-owned cities with player-owned neighboring cities; selection is random among eligible pairs; route type, troop threshold, diplomacy/peace, city strength priority, cooldown, and multiple enemy world actions were not found in the audited candidate path.
- Documented the web handoff path: successful invasion creates a defense `pendingBattleChoice` with a minimal defense `battleContext`; manual/auto defense later calls `startBattle()`, and ownership changes only after defense battle retreat/return.
- Documented save/load behavior: web snapshots normalize to world/player turn and clear pending invasion, pending deployment, active battle, and pending enemy-turn result.
- Updated current-state, next-task, handoff, changelog, and session docs with the Godot gap analysis and recommended next sequence: `12b-9` event MVP, `12b-10` BattleContext bridge, `12b-11` result/ownership apply.
- Verification: no gameplay code or scene files changed, audit doc exists, target docs updated, source files/gap analysis/next tasks documented, `git diff --check` passed, and `git status --short --ignored` reviewed.

## v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check
- Stabilized the visible domestic apply loop in `scripts/worldmap_test.gd` without modifying the root `WorldMap_Test.tscn`.
- Added `_player_state.last_domestic_apply_turn` and a same-turn guard in `_apply_domestic_turn_mvp()` so stale or duplicate callbacks cannot apply resource/loyalty deltas twice for the same turn.
- Updated runtime save metadata to `v0.68b-12b-7`; save/load/reset continue to persist the domestic state, turn/calendar, tax/chancellor controls, pending state, and last applied turn guard through `_player_state`.
- QA-covered the default turn-cycle path, preview-only tax/policy/chancellor handlers, warehouse/loyalty/status refresh paths, save/load/reset restoration, resource capacity clamps, loyalty bounds, and hidden bottom/internal warehouse lines by static/headless verification.
- Kept the patch bounded: no enemy invasion, enemy AI, target selection, hero movement, city ownership change, governor appointment execution, new domestic systems, `BattleContext`, battle transition, route/pathfinding change, or broad simulation was added.
- Verification: patch strings present, one-cycle apply guard present, preview-only handlers reviewed, save/load/reset paths reviewed, hidden-line assignments reviewed, forbidden implementation search reviewed, `git diff --check` passed, Godot project headless load passed, and `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP
- Added the first controlled player-side domestic apply path to `scripts/worldmap_test.gd`, running once when the enemy-turn placeholder finishes and the turn loop returns to the next player turn.
- Inspected local read-only web sources: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\core\world_calendar.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\world_map_ui.js`.
- Ported the narrow web domestic MVP subset: owned-city seasonal income, population/commerce tax gold, chancellor policy income multipliers, active chancellor national modifiers, player hero upkeep deduction, tax loyalty delta, warehouse capacity clamp, and concise result/status text.
- Added duplicate-apply protection with a pending domestic-apply guard tied to the player-initiated turn-end path; load/reset cancels pending timers and does not apply domestic changes.
- Kept tax slider and chancellor policy dropdown as preview controls until full turn completion; UI refresh, save, load, reset, tax movement, and policy selection do not mutate resources or loyalty.
- Updated save metadata to `v0.68b-12b-6` while continuing to serialize the existing `_player_state`, including updated resource stock, national loyalty, tax, chancellor id/policy, phase, turn, and calendar labels.
- Kept the patch bounded: no enemy invasion, enemy AI, enemy target selection, enemy movement, city ownership changes, governor appointment execution, soldier upkeep application, salt consumption, internal supply/troop rebalance, `BattleContext`, battle transition, route/pathfinding change, or repo-outside web edit was added.
- Verification: patch strings present, domestic apply/helper paths present, preview handlers reviewed, forbidden implementation search reviewed, `git diff --check` passed, Godot project headless load passed, and `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP
- Closed the minimal worldmap turn loop in `scripts/worldmap_test.gd`: `아군 턴 종료` now enters enemy phase, runs a short placeholder enemy-turn timer, returns to player phase, and increments `turn_number` once per completed cycle.
- Inspected local read-only web sources: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\ui\world_hud_ui.js`, `js\ui\world_map_ui.js`, `js\main.js`, `js\core\world_calendar.js`, and `js\constants.js`.
- Ported the safe web calendar MVP rule for labels: start year `154`, season order `봄/여름/가을/겨울`, `10` turns per season, and `40` turns per year.
- Added pending enemy-turn timer guards so the turn-end button is disabled during placeholder processing and load/reset cancels pending timers to avoid duplicate callbacks.
- Updated save/load/reset compatibility for phase and turn/calendar state through existing `_player_state` serialization; loading an enemy-phase save resumes the placeholder return path.
- Kept the patch non-simulating: no enemy invasion, enemy target selection, enemy hero movement, city ownership changes, resource production tick, domestic turn application, `BattleContext`, battle transition, route/pathfinding changes, or broad AI simulation was added.
- Verification: patch strings present, turn-cycle helper paths present, save metadata updated, forbidden implementation search reviewed, `git diff --check` passed, Godot project headless load passed, and `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP
- Cleaned the `LeftWorldStatusPanel` bottom area after the `국가 창고` card by hiding remaining visible internal/debug lines for selected city, stationed heroes, internal supply, troop rebalance, external trade, and bottom policy/resource explanatory text.
- Inspected local read-only web sources: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\ui\world_hud_ui.js`, `js\ui\world_map_ui.js`, and `js\main.js`.
- Replaced the old `야군 편집` action with the web-parity `아군 턴 종료` button.
- Added `_player_state.turn_phase` / `turn_number` defaults and phase-label normalization so `아군 턴 종료` changes the visible phase from `아군 턴` to `적군 턴` and refreshes the left panel.
- Added `_run_enemy_turn_mvp()` as a documented enemy-turn hook only. It logs/statuses the placeholder state and intentionally does not perform enemy invasion, AI movement, city ownership changes, `BattleContext`, battle transition, resource ticks, or turn-cycle return.
- Added a web-like `저장 관리` section with `저장`, `불러오기`, and `초기화`; runtime save data is stored as JSON at `user://worldmap_left_panel_state.json`.
- Save/load/reset persists and restores the current `_player_state` UI/runtime seed state and resets to the startup baseline without using repo files as runtime save storage.
- Verification: patch strings present, turn-end/save/hook paths present, save path uses `user://`, bottom debug labels hidden in the left panel refresh path, `git diff --check` passed, Godot project headless load passed, and `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup
- Cleaned up the `LeftWorldStatusPanel` `국가 창고` display into a boxed card-style UI focused only on resource rows.
- Added a runtime `WarehouseCard` `PanelContainer` with dark HUD styling, gold border, section title, and aligned rows for `쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, `소금`, and `금전`.
- Bound each row from `_player_state.resource_stock` and existing `WAREHOUSE_CAPACITY` / `_get_resource_status_label()` logic so visible values remain data-driven.
- Hid the previous plain multiline `SupplyLabel` output and stopped rendering internal preview details in the visible warehouse card.
- Hidden from visible warehouse UI: `영웅 유지비`, `병사 유지비 preview`, `보존 소금`, `유지비 정상`, and other internal maintenance preview lines.
- Kept internal policy/upkeep helper data available for later tasks; no resource production, upkeep application, turn simulation, appointment behavior, `BattleContext`, battle transition, route/pathfinding, or broader UI redesign was added.
- Verification: patch strings present, warehouse card helper paths present, rows bound from resource state, visible `SupplyLabel` text cleared/hidden, `git diff --check` passed, Godot project headless load passed, and `WorldMap_Test.tscn` headless load passed.

## v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP
- Extended the existing `LeftWorldStatusPanel` web-parity controls with a functional `재상 정책` dropdown and a consolidated `국가 창고` resource card.
- Inspected local read-only web sources: `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\resource_ui.js`.
- Added `ChancellorPolicyOption` to the root `WorldMap_Test.tscn`; the requested `scenes/WorldMap_Test.tscn` path remains absent in this repo.
- Bound policy selection to `_player_state.chancellor_policy_id` with web policy options `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`.
- Ported structured policy preview metadata from the web constants so effect text, resource multiplier summary, hero upkeep preview, soldier upkeep preview, and salt preservation preview refresh when the policy changes.
- Retired the duplicate visible `보유 자원: ...` line and made `국가 창고` the authoritative resource display, with rows bound from `_player_state.resource_stock`, web-like capacities, and status labels.
- Kept the patch non-simulating: policy changes update UI state and previews only, with no current resource mutation, turn income application, loyalty change, full end-turn simulation, movement, appointment execution, `BattleContext`, battle transition, route/pathfinding, castle icon, or repo-outside web edits.
- Verification: patch strings present, policy dropdown/helper paths present, warehouse binding/helpers present, duplicate visible resource assignment absent, forbidden implementation search returned no matches, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.

## v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP
- Upgraded the existing `LeftWorldStatusPanel` from mostly seed/debug-style text toward web-parity controls for national loyalty, tax level, and chancellor assignment.
- Inspected local read-only web sources: `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, and `js\ui\world_hud_ui.js`.
- Added a scene-authored tax `HSlider` to the root `WorldMap_Test.tscn` left national gauge card. The requested `scenes/WorldMap_Test.tscn` path is absent in this repo.
- Bound tax display to `_player_state.tax_level` using web `DOMESTIC_TAX_RULES`-style preview math for gold multiplier and loyalty delta text only.
- Bound national loyalty label/progress to `_player_state.national_loyalty` with clean status text and no permanent loyalty mutation from the tax slider.
- Replaced the old chancellor policy option node with `ChancellorAssignmentOption`, populated from the currently selected city's stationed heroes plus the first `미임명` option.
- Chancellor selection updates only `_player_state.chancellor_id` for left-panel UI state, refreshes the visible chancellor card, and previews chancellor profile effect text from imported `HERO_DATA.chancellor_profile`.
- Added portrait fallback behavior that uses a dark text placeholder `?` when no portrait path exists or the texture is unavailable.
- Kept all controls non-simulating: no actual turn income, resource mutation, loyalty application, policy effect execution, movement, appointment system, `BattleContext`, battle transition, route/pathfinding, castle icon, or repo-outside web edits were added.
- Verification: patch strings/data blocks present, Hanseong stationed hero candidates present, dropdown `미임명` path present, portrait fallback present, forbidden implementation search returned no matches, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.

## v0.68b-12b-2 WorldMap Left Panel Seed Binding QA
- Stabilized existing `LeftWorldStatusPanel` display binding against the imported `_player_state`, `CITY_HUD_DATA`, and `HERO_DATA` seed dictionaries.
- Updated city marker selection to copy the selected city id into `_player_state.selected_city_id` and refresh the left panel, so selected/origin city display follows current city clicks.
- Added display-only formatting helpers for city names, hero names, city/hero lists, and player resource stock.
- Left panel now shows clean seed-backed selected/origin city, selected city owner/region/governor/stationed heroes, owned city list, owned hero list, resource stock, and no-chancellor fallback text.
- Kept the existing scene-authored `LeftWorldStatusPanel` layout; no scene file changes were needed.
- Did not implement hero movement, governor/chancellor appointment execution, policy effects, resource/troop/turn processing, `BattleContext`, battle scene transition, combat roster resolution, route/pathfinding changes, scene layout changes, castle icon changes, or repo-outside web file edits.
- Verification: patch strings/data blocks present, forbidden implementation search returned no matches, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.

## v0.68b-12b-1 WorldMap Hero City Seed Data Import
- Aligned `scripts/worldmap_test.gd` seed data with local read-only web sources `C:\dev\SamWar_web\data\heroes.js`, `C:\dev\SamWar_web\data\cities.js`, and `C:\dev\SamWar_web\data\battle_rosters.js`.
- Updated `HERO_DATA` to preserve existing Godot HUD keys while adding web identity, faction/side, command rank, web role, troop/hp/combat stat, portrait path, unique skill, and chancellor profile seed fields.
- Updated `CITY_HUD_DATA` to preserve existing display strings while adding city identity, owner/nation/region/type, population, gold/food/troops, public order, commerce, agriculture, defense, `hero_ids`, resource seed, domestic seed, and yield seed fields.
- Kept `CITY_HUD_DATA.stationed_hero_ids` aligned with `battle_rosters.js` `cityDefenderRosters` and `governor_id` aligned with `cities.js` `governorHeroId`; Hanseong remains governor-unassigned because the web city seed has no governor.
- Updated `_player_state` with web-aligned player faction/current city/selected city/owned city/owned hero/resource stock seed values and changed the initial chancellor seed to empty for parity with web `chancellorHeroId: null`.
- Added inactive reserve `lu_bu` to `HERO_DATA` as seed metadata only; it is not in city rosters and no runtime roster behavior was added.
- Did not implement hero movement, governor/chancellor appointment logic, policy effects, resource/troop/turn processing, `BattleContext`, battle scene transition, combat roster resolution, route/pathfinding changes, scene layout changes, castle icon changes, or repo-outside web file edits.
- Verification: patch strings/data blocks present, forbidden implementation search returned no matches, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.

## v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat
- Updated agent handoff docs only; no code, scenes, assets, or seed data were modified.
- Recorded the current worldmap HUD flow through `v0.68b-8 WorldMap Web HUD Visual Parity MVP`, `v0.68b-9 WorldMap HUD Data Binding MVP`, `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`, `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`, `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`, `v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch`, `v0.68b-12b-pre Codex Auto Work Header Rule Documentation`, `v0.68b-12b Left World HUD Web Content Parity`, and `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit`.
- Noted that `v0.68b-12b-pre` made `[SamWar_BattleLab 자동 작업 권한 헤더]` mandatory before future SamWar_BattleLab task names/goals.
- Noted that `v0.68b-12b` included a left HUD web content parity attempt/investigation flow before implementation: inspect web render/resource/trade sources, then keep Godot behavior display-only.
- Captured the seed data audit result: web `heroes.js` is an array with hero identity, faction/side, role, stats, portrait, battlefield portrait, and chancellor profile fields; web `cities.js` carries city identity, ownership, route, governor, loyalty, resource, military, domestic, and yield fields; web `battle_rosters.js` `cityDefenderRosters` is the city stationed-hero source.
- Captured web domestic parity notes: `createInitialDomesticPolicy()` starts with `chancellorHeroId: null`; chancellor candidates are active player-side heroes; governor candidates are selected-city stationed player-side heroes at the selected city.
- Captured Godot seed state: `scripts/worldmap_test.gd` currently owns display-only `HERO_DATA`, `CITY_HUD_DATA`, `CHANCELLOR_POLICY_DATA`, `GOVERNOR_POLICY_DATA`, and `_player_state`; `_player_state.chancellor_id` is currently fixed to `"jeong_do_jeon"` and should be revisited for web parity.
- Set the immediate next task to `v0.68b-12b-1 WorldMap Hero City Seed Data Import`, a data baseline alignment task using web `heroes.js`, `cities.js`, and `battle_rosters.js` without real movement, appointment, policy, turn/resource mutation, battle, route/pathfinding, scene layout, castle icon, or repo-outside web changes.

## v0.68b-12b Left World HUD Web Content Parity
- Checked the actual web left HUD sources in `C:\dev\SamWar_web`, including `world_hud_ui.js`, `resource_ui.js`, `constants.js`, `app_state.js`, `world_rules.js`, `css/main.css`, `index.html`, and `data/heroes.js`.
- Realigned the Godot `LeftWorldStatusPanel` runtime copy toward `renderWorldHud()`: `World Turn`, turn/calendar/owner, `국가충성도`, `세금 수준`, chancellor card, chancellor policy, `보유 자원`, `국가 창고`, `내부 보급망`, `내부 병력 재배치`, `대외 무역`, income/policy/tax summary, wild-army edit, and save/load/reset copy.
- Updated the chancellor card display to follow `renderChancellorCard()` more closely with portrait initial fallback, name, web `주`/`보조` chancellor type lines, `재상 임명`, and `재상 정책` summary.
- Kept the chancellor policy `OptionButton` aligned with web constants: `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`; selection updates explanation text only.
- Replaced stronger placeholder wording in the left HUD with web-source labels for warehouse, upkeep preview, salt preservation, internal supply, troop rebalance, external trade, save management, and turn/tax summaries.
- Left all controls display-only; no turn processing, resource mutation, policy effect application, save/load/reset, domestic execution, diplomacy/spy, battle entry, `BattleContext`, hero transfer, army movement, pathfinding, route, sea arrow, or AI behavior was added.
- Preserved the unified City Detail / Diplomacy panel, Selected City panel, independent drag/collapse behavior, castle icon visual-disable state, route lines, sea arrow flow, and existing battle scenes.
- 김작 F6 should confirm the left HUD section order/content against the web left HUD, policy description-only behavior, reduced placeholder feel, no excess lower blank space, no other panel regressions, route/sea arrow continuity, castle icons hidden, and existing battle scene stability.

## v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch
- Reworked the unified `CityDetailPanel` header so the visible top row is the primary tab pair `도시 상세` / `외교·첩보` plus `접기`, without the duplicate Korean title.
- Changed the collapsed unified panel label to `도시상세 / 외교·첩보 열기`.
- Added click-vs-drag handling for the collapsed unified panel: a short click expands it, while dragging the collapsed header moves only that panel at runtime.
- Strengthened the `외교` and `첩보` tab content against web `diplomacy_spy_ui.js`: `외교 현황`, `외교 행동`, `첩보 가시성`, `첩보 행동`, `사절 교환`, `교섭 요청`, `교역 압박`, `정탐`, `유언비어`, and `내통 시도` are now reflected in Godot display copy.
- Added content-based unified panel height resizing so shorter city-detail or diplomacy/spy tab content reduces excess bottom empty space while staying clamped to the viewport.
- Preserved independent dragging for the unified panel and selected-city panel, display-only tab/button behavior, castle icon visual-disable state, route lines, sea route arrow flow, and existing battle scenes.
- Did not add actual diplomacy, spy, domestic, turn, resource, save/load, `BattleContext`, battle entry, hero transfer, army movement, pathfinding, or AI behavior.

## v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP
- Consolidated the Godot worldmap City Detail and Diplomacy/Spy HUD surfaces into one `CityDetailPanel`-backed unified panel.
- Added unified primary tabs for `도시 상세` and `외교·첩보`; the city-detail mode keeps the existing `자원`, `자국무역`, and `타국무역` secondary tabs.
- Added diplomacy/spy secondary tab behavior using the same tab row: `외교` and `첩보` switch display-only placeholder copy inside the unified panel.
- Hid the standalone `DiplomacySpyPanel` at runtime so it no longer occupies separate HUD space.
- Replaced the old City Detail collapse placeholder with a real runtime collapse/expand state; the collapsed panel shows a small `도시 상세 열기` header and can be reopened.
- Preserved independent dragging for the unified panel, `CityInfoPanel`, and `LeftWorldStatusPanel`; panel positions remain runtime-only and are not saved.
- Kept all buttons/tabs placeholder-only; no domestic, diplomacy, spy, battle entry, `BattleContext`, save/load, hero transfer, army movement, route, pathfinding, or AI behavior was added.
- Preserved selected-city data binding, CityInfoPanel independence, castle icon visual-disable state, route lines, sea route arrow flow, and existing battle scenes.

## v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP
- Referenced the web `world_map_ui.js` draggable HUD flow, which moves the grouped `city-hud-stack` through one `data-city-hud-drag-handle` and stores an offset in localStorage.
- Improved the Godot UX instead of copying the grouped web movement: `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` now support independent runtime dragging from their title/header labels.
- Hid the retired top `SamWar Web` banner and the old `도시 HUD 위치 이동 · Godot MVP fixed` dragbar at runtime.
- Drag handling uses left mouse on header labels only, moves the active panel to the front, clamps panels so a visible portion remains on-screen, and does not persist positions to disk/user config.
- Kept buttons, tabs, and policy `OptionButton` controls outside the drag handles so placeholder button/tab/policy behavior remains usable.
- Preserved city selection, selected-city/City Detail data binding, castle icon visual-disable state, route lines, sea route arrow flow, existing battle scenes, and all no-real-feature boundaries.

## v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP
- Checked the actual web source structure in `world_hud_ui.js`, `selected_city_ui.js`, `resource_ui.js`, `diplomacy_spy_ui.js`, `world_map_ui.js`, `ui_render.js`, `governor_ui.js`, `garrison_ui.js`, `military_ui.js`, `constants.js`, `app_state.js`, `world_rules.js`, `data/cities.js`, `data/heroes.js`, `data/battle_rosters.js`, `css/main.css`, and `index.html`.
- Realigned Godot `CityDetailPanel` with the web `resource_ui.js` structure: `자원`, `자국무역`, and `타국무역` tabs now switch display-only content using web section names.
- Realigned chancellor and governor policy options with web constants: chancellor `균형형/농업 중심/상업 중심/무역 중심/군사 중심`, governor `재상 정책 수행/농업 중심/상업 중심/군사 중심`.
- Updated selected-city copy toward the web `selected_city_ui.js` order and wording: city status, governor, stationed heroes, military state, attack, hero movement, and recruit placeholders.
- Reworked local Godot city/hero HUD seed data to prioritize web `data/cities.js`, `data/heroes.js`, and `data/battle_rosters.js` for governors, loyalty/resource/military summaries, and stationed hero rosters.
- Kept all controls placeholder-only; no domestic execution, resource mutation, turn processing, save/load, `BattleContext`, battle entry, hero transfer, army movement, route/pathfinding, or AI behavior was added.
- Preserved castle icon visual disable state, city positions, route lines, sea route arrow flow, and existing battle scenes.

## v0.68b-9 WorldMap HUD Data Binding MVP
- Added a Godot-side HUD data binding MVP for `WorldMap_Test.tscn` using local display dictionaries for player state, heroes, city HUD data, chancellor policies, and governor policies.
- Bound the left World Turn panel to turn/calendar/phase, national power/tax/public order bars, chancellor portrait placeholder, chancellor name/stats, current chancellor policy, resource, supply, logistics, and trade placeholder lines.
- Added chancellor policy `OptionButton` UI; selection updates local HUD state and explanatory copy only, with no resource, turn, or domestic effects applied.
- Bound selected-city HUD to governor portrait placeholder, governor name/stats, governor policy, city loyalty, stationed hero chip list, city military/trade summary, and placeholder-only action copy.
- Added governor policy `OptionButton` UI; selection updates the selected city's local policy display only and does not mutate real city resources, turn state, troops, or army data.
- Strengthened `CityDetailPanel` binding with city resources, loyalty/policy, military, trade, rating, governor name, and stationed hero count.
- Preserved placeholder-only behavior for attack, hero move, domestic, recruit, diplomacy, spy, save/load/reset, and wild-army edit controls.
- Preserved castle icon visual disable state, city positions, route lines, sea route arrow flow, existing battle scenes, and the `BattleContext` / battle entry / army movement deferrals.

## v0.68b-8 WorldMap Web HUD Visual Parity MVP
- Referenced the web HUD visual sources: `index.html`, `css/main.css`, `world_map_ui.js`, `ui_render.js`, `world_hud_ui.js`, `diplomacy_spy_ui.js`, `resource_ui.js`, and `selected_city_ui.js`.
- Tuned Godot `WorldMap_Test.tscn > WorldMapUI` toward the web HUD look: dark navy translucent panels, thin gold borders, gold/beige eyebrow headings, dense text, inner cards, tab buttons, red action buttons, and progress-bar placeholders.
- Added a centered `SamWar Web` title banner placeholder and changed the right HUD into a fixed multi-panel visual layout for Diplomacy/Spy, City Detail, and Selected City.
- Expanded the left World Turn panel visuals with turn/calendar/owner, progress placeholder bars, chancellor, national resources, internal supply, logistics plan, external trade, wild-army edit, and save/load/reset placeholders.
- Expanded selected-city visuals with loyalty progress placeholder, governor placeholder, selected hero chips placeholder, military state placeholder, recruit placeholder, and web-like button styling.
- Kept all controls placeholder-only; no `BattleContext`, battle entry, domestic execution, diplomacy/spy logic, turn/resource changes, pathfinding, AI, or hero/army movement was added.
- Preserved castle icon visual disable state, city positions, route lines, sea route arrow flow, and existing battle scenes.

## v0.68b-8 WorldMap Web HUD Panel Structure Import MVP
- Referenced the actual web worldmap HUD sources: `world_map_ui.js`, `ui_render.js`, `world_hud_ui.js`, `diplomacy_spy_ui.js`, `resource_ui.js`, `selected_city_ui.js`, `data/cities.js`, and `data/factions.js`.
- Expanded `WorldMap_Test.tscn > WorldMapUI` from a single selected-city panel into a web-like HUD MVP: left `LeftWorldStatusPanel`, upper-right `DiplomacySpyPanel`, right `CityDetailPanel`, and expanded selected-city `CityInfoPanel`.
- Added placeholder-only world turn/status, diplomacy/spy, city detail, selected city, garrison, military, attack, hero-move, domestic, and wild-army edit HUD elements.
- Updated `scripts/worldmap_test.gd` so city clicks refresh both `CityDetailPanel` and `CityInfoPanel` while preserving `selected_city_id`, `selected_city_marker`, and marker-local `SelectionRing`.
- Extended `scripts/worldmap_city_info_panel.gd` with selected-city description, garrison placeholder, military placeholder, hint text, and a domestic placeholder button.
- Kept castle icon visuals disabled and preserved city positions, route lines, sea route arrow flow, battle scenes, `BattleContext`, battle entry, domestic execution, and hero/army movement as deferred.

## v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch
- Disabled `CastleIcon` visuals for the current functional marker phase without deleting castle icon nodes or asset files.
- Kept `CastleIcon` Sprite2D nodes and texture references in `WorldMap_Test.tscn`, with `visible = false` saved for each city.
- Added `CASTLE_ICON_VISUALS_ENABLED := false` in `scripts/worldmap_city_marker.gd` so castle visuals can be re-enabled later from one runtime flag.
- Restored the lightweight colored `CityDot` as the visible functional city marker while keeping city names, `ClickArea`, metadata, `SelectionRing`, and `CityInfoPanel` behavior.
- Preserved route lines and sea route arrow flow; no battle entry, `BattleContext`, domestic UI, or hero/army movement behavior was added.

## v0.68b-6 WorldMap Selected City Panel Web Parity MVP
- Ported the web `renderSelectedCityPanel()` structure into a reduced Godot `WorldMapUI/CityInfoPanel`.
- Added `scripts/worldmap_city_info_panel.gd` for selected city name, id, region/owner, type, neighbors, route type summary, and MVP status text.
- Added worldmap selected city state in `scripts/worldmap_test.gd`: `selected_city_id`, `selected_city_marker`, marker lookup, previous-selection clear, and panel refresh.
- Added scene-authored `SelectionRing` children under all 13 `CityMarker_*` nodes and a `WorldMapCityMarker.set_selected()` API.
- Kept attack and hero movement as placeholder buttons only; no battle entry, `BattleContext`, domestic detail UI, or army movement was implemented.
- Preserved route layer and sea arrow flow; moved sea arrow initial spacing into `scripts/worldmap_route_flow_fx.gd` so scene load no longer emits `PathFollow2D.progress_ratio` errors.

## v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP
- Added `scripts/worldmap_route_flow_fx.gd` for sea-only route arrow flow FX.
- Added `ArrowFlowRoot` Path2D nodes with four `PathFollow2D` arrow markers to each sea route in `WorldMap_Test.tscn`.
- The arrow flow references the scene-authored route `Path2D.curve` and moves from `start_city_id` to `end_city_id`.
- Kept land routes as line-only routes with no arrow flow FX.
- Kept the feature visual-only; no movement, pathfinding, trade, battle entry, naval battle, or `BattleContext` logic was added.

## v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning
- Increased land route visibility by changing land `Line2D` width from `2.5` to `4.5`.
- Changed land route color from muted dark earth `Color(0.72, 0.50, 0.25, 0.44)` to brighter ochre `Color(0.86, 0.62, 0.32, 0.72)`.
- Kept sea route width/color unchanged.
- Preserved the scene-authored `Path2D.curve` source-of-truth rule; no route curves were regenerated.

## v0.68b-4 WorldMap Route Layer Path2D MVP
- Added scene-authored route nodes under `WorldMap_Test.tscn > WorldMapRoot > RouteLayer`.
- Added `scripts/worldmap_route_path.gd` so route metadata is code-owned while route shape remains owned by each `Path2D` / `Curve2D`.
- Seeded initial land / sea route curves from the current `CityMarker_*` root positions using weak land bends and larger sea bends.
- Added `Line2D` visualization from baked `Path2D` points, with muted earth-tone land routes and pale blue sea routes.
- Preserved city marker structure and city click behavior; route click, movement, pathfinding, battle entry, and `BattleContext` injection remain deferred.

## v0.68b-3 WorldMap City Castle Icon Apply
- Added `CastleIcon` Sprite2D children under all 13 `CityMarker_*` roots in `WorldMap_Test.tscn`.
- Mapped city castle icons by city/region: Korean peninsula cities use `castle_korea.png`, China mainland cities use `castle_china.png`, Japanese archipelago cities use `castle_japan.png`, and Karakorum uses `castle_ordo.png`.
- Updated `scripts/worldmap_city_marker.gd` to apply the regional castle texture, scale it to `CITY_CASTLE_ICON_TARGET_HEIGHT = 56.0`, hide the old dot marker, and preserve city metadata / click info behavior.
- Renamed the marker-local city text node to `NameText` while keeping it Node2D-based so root marker movement carries the castle icon, name text, and click area together.
- Enlarged the shared city click shape to a 40px radius around the marker root for the castle icon MVP.

## v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix
- Replaced all 13 city `NameLabel` nodes in `WorldMap_Test.tscn` from `Label` / `Control` nodes with `Node2D` text nodes using `scripts/worldmap_city_name_label.gd`.
- Kept `NameLabel` under each `CityMarker_*` root with local `position = Vector2(0, 16)`, so moving the marker root in the 2D editor moves the displayed city name with it.
- Restored scene-authored `ClickArea/CollisionShape2D` children under each city marker root.
- Updated `scripts/worldmap_city_marker.gd` to refresh the new Node2D name label through `set_label_text()` while keeping existing marker metadata and click behavior.

## v0.68b-2-hotfix5 WorldMap City Marker Label Reparent Fix
- Standardized all 13 `CityMarker_*` scene bundles in `WorldMap_Test.tscn` to use local `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D` children.
- Kept city marker root positions as the scene-authored source of truth, so moving the root in the Godot 2D editor moves icon/dot, label, and click area together.
- Updated `scripts/worldmap_city_marker.gd` to refresh marker color and label text from local child nodes without assigning world-space label positions.
- Preserved city metadata, marker click info panel behavior, manual tile layout control, camera clamp behavior, route/army/battle-entry deferrals, and `BattleContext` non-integration.

## v0.68b-2-hotfix4 WorldMap City Marker Root Attachment Fix
- Added scene-authored `ClickArea` / `CollisionShape2D` children under each `CityMarker_*` root in `WorldMap_Test.tscn`.
- Kept each city icon/dot, name label, and click area attached under its `CityMarker_*` root so moving the root moves the whole marker bundle.
- Added `WorldMapCityMarker.city_selected` click signal and connected the worldmap scene to update a screen-fixed `WorldMapUI/CityInfoLabel`.
- Preserved city metadata, `CityMarker_*`.`position` source-of-truth rules, manual tile layout control, and camera clamp behavior.
- Kept route drawing, army movement, battle entry, and `BattleContext` runtime injection unimplemented.

## v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control
- Changed `scripts/worldmap_test.gd` so runtime no longer overwrites `Tile_A1_TopLeft`, `Tile_A2_TopRight`, `Tile_B1_BottomLeft`, or `Tile_B2_BottomRight` positions.
- Made scene-authored Tile node positions in `WorldMap_Test.tscn` the source of truth for worldmap tile layout.
- Camera clamp now reads the union of the current tile Sprite2D world rects, considering texture size, centered state, scale, rotation, and node transform.
- Preserved scene-authored `CityMarker_*` positions as the city placement source of truth.
- Kept route drawing, army movement, battle entry, and `BattleContext` runtime injection unimplemented.

## v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix
- Fixed `WorldMap_Test.tscn` scene-authored tile positions so the four worldmap tiles attach in the Godot 2D editor, not only at runtime.
- Set the visible editor tile layout to A1 `(0, 0)`, A2 `(512, 0)`, B1 `(0, 512)`, and B2 `(512, 512)`, matching the tile texture display size.
- Kept all worldmap layers under the same zero-offset `WorldMapRoot` coordinate basis.
- Re-seeded the 13 city marker root positions and `web_seed_position` values to the corrected 1024x1024 four-tile combined rect so markers stay on the map image.
- Preserved the rule that final city positions are scene-authored `CityMarker_*`.`position`; runtime code still does not overwrite marker root positions from web data.
- Kept battle scenes, route drawing, army movement, battle entry, and `BattleContext` runtime injection untouched.

## v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix
- Re-aligned `WorldMap_Test.tscn` city markers to the same `WorldMapRoot` coordinate space as `WorldMapTileLayer`.
- Made `WorldMapRoot`, `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` explicit zero-offset scene layers.
- Added scene-authored tile placement for the 2D editor: A1 `(0, 0)`, A2 `(1024, 0)`, B1 `(0, 1024)`, B2 `(1024, 1024)`.
- Re-seeded all 13 `CityMarker_*` root positions and `web_seed_position` values against the 4-tile combined rect instead of the oversized coordinate space.
- Kept final city placement source of truth as scene-authored `CityMarker_*`.`position`; runtime code still does not overwrite marker positions from web data.
- Kept battle scenes, route drawing, army movement, battle entry, and `BattleContext` runtime injection untouched.

## v0.68b-2 WorldMap City Marker Layer MVP
- Added 13 scene-authored `CityMarker_*` nodes under `WorldMap_Test.tscn > WorldMapRoot > CityLayer`, based on `SamWar_web/data/cities.js`.
- Added `scripts/worldmap_city_marker.gd` with exported city metadata: `city_id`, `display_name`, `region_id`, `owner_faction_id`, `neighbors`, `route_types`, and `web_seed_position`.
- Used web `x` / `y` only as initial 4096x4096 seed placement; final city positions are the saved `CityMarker_*` node positions in the Godot scene.
- Added simple marker body and label visuals so markers are visible and draggable/selectable in the 2D editor.
- Kept city click, route drawing, army movement, battle entry, and `BattleContext` runtime injection unimplemented.
- Left existing battle scenes and battle scripts untouched.

## v0.68b-1 WorldMap Four-Tile Canvas Foundation
- Added `WorldMap_Test.tscn` with a 2x2 four-tile worldmap canvas using the prepared `assets/worldmap/tiles/` PNGs.
- Added `scripts/worldmap_test.gd` to position the four Sprite2D tiles from `texture.get_size()`, configure `WorldMapCamera`, and clamp pan/zoom movement to the combined world rect.
- Added empty future strategy layers: `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer`.
- Kept city clicking, route data, army movement, battle entry, and `BattleContext` runtime injection unimplemented.
- Left existing battle scenes and battle scripts untouched.

## v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion
- Added root-level punch motion to unique skill fullscreen cut-ins: alpha fade-in, scale `0.85 -> 1.12 -> 1.0`, minimal hold, and upward fade-out / shrink to `0.92`.
- Kept existing cut-in image, skill-name, slide, and ink flash structure while avoiding particles, glow shaders, audio, or new assets.
- Kept effect apply timing aligned after the punch/exit sequence so damage / buff / FX and camera shake continue naturally.
- Preserved unique skill effect values, target selection, cooldowns, AI judgment, damage formulas, Camera2D policy, battlefield background, and status badge rules.
- Added 김작 F6 checks for fast punch-in, upward shrink/fade exit, no lingering/buffering feel, no repeated-use scale/position accumulation, UI stability, and status badge fix6.

## v0.68a-4-hotfix4 Unique Skill Dynamic Impact Presentation
- Changed unique skill fullscreen cut-in from a static large toast into a short dynamic impact presentation.
- Reused `UniqueSkillInkBurst`, `UniqueSkillCutinImage`, and `UniqueSkillNameLabel` to add ink flash, side-based slide-in, image scale punch, delayed skill-name pop, and fast slide/fade-out.
- Adjusted `UNIQUE_SKILL_EFFECT_APPLY_DELAY` to include the delayed-name enter window so battlefield damage / buff / FX and camera shake begin after cut-in exit.
- Preserved unique skill effect values, target selection, cooldowns, AI judgment, damage formulas, Camera2D policy, battlefield background, and status badge rules.
- Added 김작 F6 checks for slide-in impact, scale punch, ink flash, skill-name pop, quick exit, immediate battlefield FX connection, camera focus/shake stability, UI stability, and status badge fix6.

## v0.68a-4-hotfix3 Unique Skill Cutin Fast Impact Timing
- Tuned unique skill fullscreen cut-in into a short impact presentation.
- Changed unique skill cut-in timing to `0.10s` enter, `0.40s` hold, and `0.12s` exit, for roughly `0.62s` before battlefield effects resume.
- Kept `UNIQUE_SKILL_EFFECT_APPLY_DELAY` tied to enter + hold + exit so damage / buff / FX and camera shake begin after the cut-in exits.
- Preserved unique skill effect values, targets, cooldowns, AI judgment, damage formulas, Camera2D policy, battlefield background, and status badge rules.
- Added 김작 F6 checks for strong but brief cut-in feel, readable momentary skill presentation, natural post-cutin effects, uninterrupted battle tempo, and clean GDScript warnings.

## v0.68a-4-hotfix2 Unique Skill Cutin Toast Tempo Match
- Matched the unique skill fullscreen cut-in closer to turn-exchange toast tempo.
- Changed unique skill cut-in timing to `0.14s` enter, `0.9s` hold, and `0.14s` exit; the previous `1.5s` hold is no longer used.
- Referenced existing battle toast timings: round start hold `1.15s`, reinforcement arrival hold `0.82s`, with battle toast enter/fade timing around `0.42s` in and `0.32s` out.
- Preserved unique skill effect values, targets, cooldowns, AI judgment, damage formulas, Camera2D policy, battlefield background, and status badge rules.
- Added 김작 F6 checks for readable but faster cut-in tempo, short enter/exit, normal post-cutin effects, camera shake return, and clean GDScript warnings.

## v0.68a-4-hotfix2 Unique Skill Cutin Timing Trace
- Added `UNIQUE_SKILL_CUTIN_TIMING_DEBUG` and `[UNIQUE_CUTIN]` console logs for SHOW_START, ENTER_DONE, HOLD_START, HOLD_DONE, EXIT_START, HIDE_DONE, and EFFECT_APPLY.
- Made the fullscreen unique skill cut-in tween sequence explicit: enter animations run in parallel, then the `1.5s` hold interval, then exit animations run in parallel.
- Kept unique skill effect values, targets, cooldowns, AI judgment, damage formulas, Camera2D policy, battlefield background, and status badge rules unchanged.
- Added 김작 F6 console checks to verify whether HOLD_START to HOLD_DONE is actually about `1.5s` and whether enter/exit/effect timing explains the perceived shortness.

## v0.68a-4-hotfix1 Unique Skill Cutin Hold + Shadow Warning Fix
- Increased unique skill fullscreen cut-in/toast hold from `0.66s` to `1.5s`.
- Renamed local `global_scale` and `position` variables in `scripts/battle_web_import_test.gd` to remove Node2D property shadowing warnings.
- Preserved unique skill effect values, target rules, cooldowns, AI judgment, damage formulas, Camera2D policy, battlefield background, and status badge rules.
- Added 김작 F6 checks for the longer hold feel, short enter/exit feel, post-cutin effects, camera shake return, and clean GDScript warning output.

## v0.68a-4 Unique Skill Fullscreen Cut-In Presentation
- Enlarged unique skill presentation into a screen-fixed wide cut-in on `BattleUI/UniqueSkillToastRoot`.
- Reused existing per-skill cutin images and skill-name text, scaling the banner to the viewport for the large battlefield / Camera2D focus setup.
- Sequenced actual unique skill damage / buff / FX and camera shake after the cut-in exits.
- Preserved unique skill effect values, target rules, cooldowns, registry data, AI value gates, battle formulas, and Camera2D focus policy.
- Added 김작 F6 checks for cut-in scale, UI overlap feel, timing, post-cutin effect application, camera focus/shake return, status badge fix6, and normal battle flow.

## v0.68a-3 Battlefield Large Background Apply + Camera Clamp
- Applied `assets/web_battle/battlefield/battlefield_3200x1800_worldmap_test_01.png` as the `Battle_Fullscreen_Test.tscn` battlefield background.
- Kept the new battlefield texture at 1:1 scale and centered it as a 3200x1800 world rect.
- Updated Camera2D clamp to prefer the visible battlefield texture rect, preventing focus movement from exposing gray/empty area when the large background is available.
- Preserved current separated deployment, logical grid structure, battle formulas, AI, status badge rules, scene slot structure, and existing assets.

## v0.68a-2-hotfix1 Camera-Bound Overlay Sync Fix
- Made camera-bound CanvasLayer overlays refresh during and after Camera2D focus movement.
- Changed world-to-UI conversion to use current `MainCamera` position/zoom, avoiding stale viewport canvas transform results immediately after camera movement.
- Repositioned facing indicators, post-move FacingArrowPanel, READY frames, floating command panel, and status badges through the shared camera-bound overlay refresh path.
- Preserved status badge fix6 placement rules, Camera2D focus policy, battle formulas, AI, grid size, deployment layout, scene files, and assets.

## v0.68a-2 Combat Focus Camera Follow
- Added Camera2D combat focus helpers for world-position, unit, combat-pair midpoint, unit focus anchor, and battlefield clamp.
- Camera focus now triggers on battle start, ally selection, ally move start/finish, ally attack, enemy move/attack, strategy, unique skill, and reinforcement arrival.
- Unique-skill camera shake now returns to the current focus baseline instead of snapping back to the scene-authored center.
- No battle formulas, AI decisions, grid size, deployment layout, scene files, or assets were changed.

## v0.68a-1 Camera2D World/UI Layer Foundation
- Confirmed `MainCamera` exists as a scene-authored `Camera2D` and marked it enabled in the scene.
- Added runtime camera configure/reset helpers that make `MainCamera` current and preserve its scene-authored position/zoom baseline.
- Kept existing unique-skill camera shake on `MainCamera` and reset it through the same baseline.
- Confirmed battle UI is CanvasLayer-based; no battlefield scale, deployment recenter, combat focus follow, worldmap, or BattleContext runtime injection was added.
- Kept battle logic, formulas, AI, marker/slot structure, status badge rules, and current `5v5` flow unchanged.

## v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix
- Changed up/down-facing battlefield status badges from arrow top/bottom tail placement to the arrow's left edge snap.
- Final placement is `→` badge left of arrow, `←` badge right of arrow, `↑` badge left of arrow, and `↓` badge left of arrow.
- Preserved left/right-facing edge snap from `v0.68a-fix4`.
- Preserved confusion fallback as `◎N`.
- Kept status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts unchanged.

## v0.68a-fix5 Vertical Facing Status Badge Arrow Tail Fix
- Changed up/down-facing battlefield status badge placement to use facing-arrow tail edge placement instead of portrait/visual-anchor side placement.
- Up-facing badges now attach below the arrow bottom edge; down-facing badges attach above the arrow top edge.
- Preserved left/right-facing badge edge snap from `v0.68a-fix4`.
- Preserved confusion fallback as `◎N`.
- Kept status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts unchanged.

## v0.68a-fix4 Status Badge Edge Snap To Facing Arrow
- Changed battlefield status badge placement from full facing-indicator Control width math to approximate facing-arrow visual edge snapping.
- Added approximate facing-arrow visual dimensions for status badge placement so left/right badge blocks attach to arrow edge with a `2px` gap.
- Kept up/down-facing badge placement on the side that avoids the unit body center while using the same arrow visual edge snap.
- Preserved confusion fallback as `◎N`.
- Kept status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts unchanged.

## v0.68a-fix3 Status Icon Tighten + Confusion Fallback Restore
- Tightened battlefield status badge placement further by reducing the arrow gap from `6px` to `2px`.
- Restored confusion battlefield badge display from numeric-only `N` to the stable `◎N` fallback because the attempted blank-symbol display did not render reliably in Godot.
- Removed the unused `centered_badge_x` local variable warning in the status badge position helper.
- Confirmed the status badge refresh path keeps null guards for `battle_fx_root`, `unit_state`, facing indicator lookup, and child labels.
- Kept status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts unchanged.

## v0.68a-fix2 Status Icon Tight Arrow Anchor + Confusion Icon Patch
- Tightened battlefield status badge placement from a `10px` arrow gap to a `6px` arrow gap.
- Kept left/right-facing badges directly behind the facing arrow while aligning them closer to the arrow center line.
- Changed up/down-facing badge placement to use the nearby arrow side that avoids putting badges into the unit body center.
- Changed confusion battlefield badge display from `◎N` to turn count only, such as `N`.
- Kept status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts unchanged.

## v0.68a-fix1 Status Icon Anchor Consistency Patch
- Unified battlefield status badge placement for ally, enemy, support, and reinforce units.
- Anchored status badges to the backside of the facing arrow: right-facing units place badges left, left-facing units place badges right, up-facing units place badges below, and down-facing units place badges above.
- Tightened the arrow-to-badge gap to `10px` so badges stay closer to the unit while preserving horizontal multi-icon layout.
- Kept status logic, strategy effects, defend effects, marker/slot structure, battle size, AI, and worldmap contracts unchanged.

## v0.68 Agent Contract Split for WorldMap + Hero Scale Prep
- Added contract docs for worldmap rules, hero data, army deployment, BattleContext, battle engine boundaries, and skill system rules.
- Defined the future flow where worldmap / army encounter logic creates `BattleContext` and the battle engine consumes `BattleContext.roster`.
- Documented that battle type, terrain, region, and `map_variant_id` are decided by worldmap / region rules before battle startup.
- Documented `hero_id` as source of truth, portrait textures as non-authoritative, and the hero registry direction as global rather than battle-scene-only.
- Updated handoff, current state, next tasks, and session log for the new contract baseline.
- Docs-only architecture contract patch; no runtime code, scene, script, or asset changes.

## v0.67z-4 Agent Role Split Foundation
- Added role-based agent docs for architecture, implementation, QA, runtime QA, visual QA, and workflow management responsibilities.
- Linked the new role docs from `CODEX_WORKFLOW_RULES.md` while keeping task classification, autonomous execution, approval handling, and verification depth canonical there.
- Updated handoff, current state, next tasks, changelog, and session log around the new role split.
- No feature code, scene, or asset changes.

## v0.67z-3 Strategy Status Badge Near Facing Arrow Patch
- Changed battlefield status badge placement from a fixed right-side unit offset to a facing-indicator-based position.
- Left-facing units now place status badges to the right of the arrow, while right-facing units place them to the left.
- Up/down facings choose the near side of the arrow/portrait line so badges stay visually attached to the unit.
- Kept status text, colors, strategy effects, defend effects, marker/slot structure, and battlefield size unchanged.

## v0.67z-2 Deployment Anchor Source Unification
- Synced all active `5v5` deployment `UnitMarker` nodes from scene-authored `Slot` / `UnitVisualRoot` anchors before demo state creation and marker-to-grid-cell sync.
- Added slot-id based helpers for resolving unit markers, portrait markers, visual roots, portraits, and visual anchors without hardcoded new coordinates.
- Kept `UnitMarker` and `PortraitMarker` nodes as compatibility runtime sync targets rather than deleting or reparenting them.
- Left 김작 F6 visual QA for `Slots/AllyReinforce01Slot` ROUND 2 김유신 spawn alignment and related HP/troop/portrait/click/facing/status positioning.

## v0.67z Unit Visual Attachment / Manual Layout Control Patch
- Synced unit markers from scene-authored `UnitVisualRoot` global movement at runtime start so Godot 2D editor slot/root movement becomes the shared unit visual anchor.
- Changed unit group offset application to write global positions, preserving root/slot-relative movement for token, portrait, HP bar, troop label, shadow, and move dust nodes.
- Kept click areas as compatibility `Area2D` nodes but positioned them through the `UnitVisualSlot` anchor and captured scene-authored offsets.
- Kept READY frames, facing indicators, and status badges in UI/FX layers while resolving their positions from the same slot-synced visual anchor.

## v0.67y-3 Web Defend Command + Formation Status Layout Guard
- Added manual defend wounded-troop recovery for `10%` of missing troops, with a green floating recovery number and updated mini-log text.
- Added a short `◆ 방어` hit reaction for defending units when they take basic or single-target unique-skill damage.
- Changed formation-guide status summaries to compact one-line text with `외 N` overflow guarding.
- Reduced formation-guide troop icon bounds to `46 x 46` and adjusted troop/status label sizing so status text and troop art do not collide.
- Enlarged the battle mini-log panel slightly and increased its text area for the new defend/recovery log lines.

## v0.67y-2-hotfix1 Status Icon Readability Fix
- Changed confusion unit badges from bare turn numbers to `◎N` so the status meaning remains visible.
- Split status tones so defense `◆` uses steel blue and attack-up `▲` uses amber on battlefield badges and formation status lines.
- Enlarged formation troop icons to `56 x 56` and strengthened troop-type text contrast for faster class reading.

## v0.67y-2 Web Defend Command Port + Status Icon Tone Polish
- Replaced the floating panel move slot with a manual `방어` command while keeping direct move-click unchanged.
- Added `is_defending` / defend last-action state, immediate action consume, defend floating text, and mini-log output.
- Applied defend incoming-damage reduction through the existing directional damage helper and cleared defend on action-lock reset.
- Updated status display tone and icon rules so defend/defense use `◆`, attack buffs use `▲`, and status text/badges are less harsh.

## v0.67y-1-hotfix1 Unified Status Display + Toast Fade Polish
- Unified unit/formation status display through shared formatter entries for strategy statuses and unique-skill buffs.
- Added `◆` unit badges and formation-guide text for active unique-skill attack / defense buffs.
- Changed confusion unit badge from `혼N` style to icon-style `N`, while shake remains `⚠N`.
- Polished defeat-retreat toast hide with a short `0.18s` fade plus subtle scale/position settle after hold.

## v0.67y-1 Strategy Status UX + Result Sequence Fix
- Tuned defeat-retreat toast hold to `1.2s` for the first exit and `1.0s` for queued follow-ups, keeping fade-out after hold.
- Enlarged battlefield strategy status icons, added formation-guide status summaries, and enlarged troop icons to `52 x 52`.
- Applied a light `동요` attack/defense penalty through shared damage calculation.
- Deferred victory/defeat result toast display until defeat-retreat toast playback finishes, and moved strategy status turn decrease to after action/skip resolution.

## v0.67y Web Strategy Port MVP
- Ported the web single `strategy` command into the floating `책략` button for manual ally use.
- Added intelligence-based strategy range / tier / success-rate / outcome helpers and cyan range + valid-target markers.
- Added `혼란` / `동요` status storage, max-turn refresh, compact unit/formation status icons, floating effects, and mini-log entries.
- `혼란` now skips affected ally/enemy actions; enemy/auto strategy casting is deferred to `v0.67y-2 Strategy AI/Auto Expansion`.

## v0.67x-7-hotfix4 Defeat Toast Duration + Size Tune
- Tuned ally defeat and enemy retreat toast hold time from `3.0s` to `1.5s`, including queued exits.
- Reduced the defeat-retreat toast panel, portrait, name text, and dialogue text for a less intrusive battle-screen footprint.
- Kept SHOW / HOLD_DONE / HIDE elapsed logs and the non-blocking snapshot queue intact.

## v0.67x-7-hotfix3 Defeat Toast Actual 3s Hold Fix
- Fixed defeat-retreat toast tween sequencing so fade-out starts after the `3.0s` hold instead of overlapping it.
- Added DEBUG-gated SHOW / HOLD_DONE / HIDE elapsed logs for actual portrait/name/dialogue toast lifetime checks.
- Kept snapshot queue, cleanup, result checks, turn flow, and full-auto progression non-blocking.

## v0.67x-7-hotfix2 Defeat Toast 3s + Hakikjin Range Sync
- Increased ally defeat and enemy retreat toast hold time to `3.0s`, including queued sequential exits.
- Changed 학익진 포격 damage targets to use the same caster-range valid-target helper as range overlay and target markers.
- Kept snapshot toast queue, unique skill cooldown/action flow, and full-auto progression non-blocking.

## v0.67x-7-hotfix1 Defeat Toast Hold Duration 2s
- Increased ally defeat and enemy retreat toast hold time to `2.0s`, including sequential queued exits.
- Kept the existing snapshot queue non-blocking for cleanup, result checks, full-auto flow, and turn progression.

## v0.67x-7 Defeat Retreat Toast Actual Apply
- Generalized the existing enemy retreat toast into an ally/enemy defeat-retreat toast queue.
- Snapshot portrait / name / side / fallback line before cleanup so battle-exit messages remain visible even after units are removed.
- Added separate ally defeat and enemy retreat dialogue pools with `1.25s` default hold and `1.05s+` queued playback.
- Kept dead-unit cleanup, untargetable state, victory/defeat result checks, and full-auto flow non-blocking.

## v0.67x-7 Enemy Retreat Toast Actual Apply
- Moved the existing enemy retreat toast UI onto a dedicated scene-authored `EnemyRetreatToastLayer` so it is actually visible over battle/result UI.
- Changed enemy defeat handling to snapshot portrait / name / fallback line before visual cleanup.
- Added a sequential enemy retreat toast queue for simultaneous defeats, capped per cleanup to preserve battle tempo.
- Kept dead-unit cleanup, untargetable state, victory/defeat result checks, and full-auto flow non-blocking.

## v0.67x-6 Targeting UX + Buff Preview + Retreat Toast Polish
- Added manual buff unique-skill range / valid-target preview before auto-resolve for 정도전 / 권율 style skills.
- Hid the floating ally command panel during attack and unique-skill targeting, then restored it after cancel / resolve.
- Strengthened gold/orange valid-target markers while keeping purple unique-skill range cells visible.
- Added an enemy retreat toast MVP with portrait, name, and short fallback line before normal dead-unit cleanup continues.
- Verified full-auto result flow still reaches victory/defeat with unique-skill previews and retreat toasts active.

## v0.67x-5 Unique Skill Regression Fix Gate
- Restored formation-guide troop icons to readable `40 x 40` while preserving `UniqueSkillReadyIcon` at `64 x 64`.
- Unified unique skill readiness / valid target / auto-enemy value checks around range-limited targets.
- Fixed 정도전 / 권율 buff unique skill manual resolve and reuse by resolving buff skills immediately and applying only to valid in-range allies.
- Kept 김유신 and other attack unique skills on the same target validation path.
- Limited 유비-style buff use to valuable in-range unbuffed allies and preserved basic attack / move / wait fallback.
- Changed unique skill overlay so purple range cells remain visible with separate gold valid-target markers.
- Added a short auto/enemy unique skill range preview before resolve.
- Documented WASAPI output-device warnings as external Godot/Windows audio-device warnings, not battle logic errors.

## v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance
- Restored formation-guide troop icon readability while keeping the `UniqueSkillReadyIcon` at `64 x 64`.
- First-normalized unique skill ranges so melee skills require close engagement and AOE skills remain mid-range.
- Reduced enemy/auto unique skill overuse with high-value and fallback-value checks before skill use.
- Restored enemy movement / approach / basic attack pressure in full-auto battle flow.
- Preserved directional damage bonus behavior with front `1.0`, side `1.15`, back `1.3`.
- Kept `SkillInfoPanel`, detailed unique skill range balance, and tactics status/explanation UI deferred.

## v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus
- Enabled auto battle ally unique skill use before normal attack / move / wait fallback.
- Enabled enemy AI unique skill use on enemy turns and after movement rechecks.
- Replaced one-use unique skill gating with cooldown-state readiness.
- Applied directional damage bonus to basic attacks, enemy hits, and single-target attack unique skills.
- Matched web directional multipliers: front `1.0`, side `1.15`, back `1.3`.
- Enlarged formation-guide `UniqueSkillReadyIcon` display to `64 x 64`.
- Kept unique skill range balance and `SkillInfoPanel` deferred.

## v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix
- Removed the `is_visible` parameter shadowing warning in the formation guide ready icon helper.
- Hid the unique skill toast black rectangular backdrop while preserving the cutin image and skill name.
- Kept `FloatingUniqueSkillButton` hover tooltip text empty while preserving the button label.
- Enlarged the formation-guide `UniqueSkillReadyIcon` to `36 x 36`.
- Changed ally manual unique skill UX to enter range/target selection first and resolve only after a valid target click.
- Added purple unique skill range cells and gold/orange valid target cells using the existing overlay pool.
- Kept `SkillInfoPanel` deferred to a future pass.

## v0.67x-1 Unique Skill Hover Cleanup + Ready Icon
- Removed duplicate hover tooltip text from `FloatingUniqueSkillButton` while keeping the button label itself visible.
- Added a small `UniqueSkillReadyIcon` to ally/enemy formation guide slots and only show it for the currently usable active ally.
- Kept `SkillInfoPanel` deferred to the next UX pass instead of adding a new panel in this patch.
- No battle logic change intended.

## v0.67x Unique Skill MVP Per Hero Cutin
- Added `10` hero unique skill registry entries for the current battle roster.
- Linked the `6` new cutin images plus existing Yi Sunsin / Jeong Dojeon / Guan Yu / Zhang Fei cutins.
- Enabled ally manual unique skill use through the floating command panel.
- Added a world-anchored ink unique skill toast with cutin image, skill name text, and `2200ms` display timing.
- Added MVP effects for cannon AOE, ally attack buff, self-defense single strike, and single damage with adjacent shake.
- Added larger red unique skill damage numbers and short camera shake for unique skills only.
- Enemy / auto unique skill use remains deferred.

## v0.67w Battle Screen Basic UX Stable Lock
- Locked the current battle-screen MVP UX as the stable baseline.
- Verified the battle UI structure around ally/enemy formation guides, lower-left mini log, bottom command bar, and floating command panel.
- Confirmed legacy large side panels remain hidden and `UnitCloseupPanel` remains hidden.
- Confirmed bottom command `TextureButton` handlers, direct move-click, rollback, post-move reopen, active ally pulse pivot lock, reinforcement flow, and result toast flow remain stable.
- No battle logic change intended.

## v0.67v Bottom Command Bar Background Panel Apply
- Applied `bottom_command_bar_bg.png` as the scene-authored `CommandBar` background.
- Added `BottomCommandBarBackground` under `BattleUI/CommandBar`.
- Hid the old black `Panel` fill by overriding the `CommandBar` panel style to transparent.
- Preserved `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` handlers and layout.
- No battle logic change intended.

## v0.67u-3 Formation Guide Card Compact Info Polish
- Hid `UnitCloseupPanel` while preserving its node structure for later reuse.
- Reworked ally/enemy formation guide cards into compact portrait / name / troop / troop-icon / troop-type layout.
- Removed card status text and kept active/reserve distinction through visual styling only.
- Reduced guide-card text sizes for a tighter strategy UI read.
- Reused existing token textures and hero visual fallback data for troop icon rendering.
- No battle logic change intended.

## v0.67u Formation Slot Guide Layout MVP
- Hid/deprecated the large legacy `LeftPanel` and `RightPanel` info panels.
- Added `BattleMiniLogPanel`.
- Added ally/enemy formation slot guide panels for main `3` + reinforce `2` per side.
- Kept the guide display-only with no click behavior and no battle logic changes.

## v0.67t-hotfix Bottom Command TextureButton Scene Fix
- Converted the 3 bottom command buttons from `Button` to scene-authored `TextureButton`.
- Connected the 6 PNG assets directly in `Battle_Fullscreen_Test.tscn`.
- Restored bottom command button visibility in the Godot 2D editor.
- Kept existing handlers unchanged and kept `RetreatButton` as a disabled placeholder.

## v0.67t Bottom Command Button PNG Apply QA
- Applied the 6 real bottom-command PNG files to the bottom global command bar.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` as existing `Button` nodes with existing handlers unchanged.
- `RetreatButton` remains a disabled placeholder.
- Button text is cleared only when image style apply succeeds, so text overlap is avoided without breaking fallback behavior.

## v0.67s Bottom Command Button Actual Asset Integration
- Added safe bottom-command art helpers for real optional PNG loading.
- Kept `Button` nodes and existing handlers unchanged.
- Missing PNG files remain a safe fallback path with no intended behavior change.

## v0.67r Bottom Command Bar Art Asset Structure Prep
- Prepared `assets/web_battle/ui/bottom_command/README.md` and the planned button PNG naming structure.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` as existing `Button` nodes.
- Reused existing handlers with no intended behavior change.
- Added optional bottom-command art mapping in runtime code.
- If the PNG files are absent, the project keeps current button behavior and avoids load errors.

## v0.67-docs Agent Docs Slimdown
- Slimmed top-level `agent` docs for faster Codex session startup and wrap-up.
- Preserved full pre-slimdown history in:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
- Rebased top-level operational docs on the current stable baseline `v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable`.

## v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable
- Stable baseline locked around unified root active-ally pulse with pivot lock and clean restore.
- Floating command panel remains hidden at ally turn start, opens on active ally click, and auto-reopens after movement + facing completion.
- Direct move-click UX, floating panel behavior, bottom command bar, reinforcement toast, result toast, and `5v5` result path remain stable.
- `GDScript` warning count expected `0`.

## v0.67p-1 to v0.67p-3 UX Summary
- Bottom command bar simplified to global commands.
- Floating command panel added and stabilized as the active ally command surface.
- Direct move-click was restored and stabilized.
- Floating panel opacity/layer priority were stabilized.
- Active ally pulse replaced ally-turn-start auto-open as the primary active-unit emphasis.
- Post-move floating panel auto-reopen was stabilized.

## v0.67m-1 Result Toast Tuning Summary
- Victory / defeat result toast scale and hold duration were increased on the shared battle toast queue.
- Reinforcement toast and round-start toast behavior remained stable.

## v0.67k-5 Enemy AI Multi-Target Engagement Fix Summary
- Enemy AI reservation and fallback-target planning were improved for multi-target battles.
- Rear / distant enemies can now continue engagement planning instead of passively idling in the validated smoke path.
- This is completed stable history, not the current active task.

## Older History
- Older detailed history is archived at `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`.
## v0.68b-12b-33D Defense Deployment Panel Parity
- Reused `PlayerAttackDeploymentPanel` as a shared attack/defense deployment panel through `deployment_type`.
- Enemy invasion manual/auto defense now opens a defense preparation panel instead of immediately entering battle.
- Added defense deployment payload, validation, confirm, and BattleContext update flow.
- Defense candidates are defender-city stationed player heroes after captured/dead exclusion; wounded heroes remain selectable.
- Defense allocation uses per-hero SpinBox, commandLimit clamp, at least one selected defender, positive troop allocation, and defender-city reserve guard.
- BattleContext carries `selected_defender_hero_ids`, selected defender allocation, and defender total allocation before existing troop pre-decrement.
- Preserved enemy attacker automatic commandLimit allocation, pre-decrement, troop outcome, woundedQueue, and result application rules.
- F6 manual QA remains pending.

## v0.68b-12b-32 CommandRank CommandLimit Allocation Parity
- Mirrored web command rank constants: governor 10000, general 8000, lieutenant 6000, officer 5000.
- Added command rank normalization, governor command-rank override, commandLimit summary helpers, and commandLimit-based default troop allocation.
- Player attack deployment UI now displays command limit and caps per-hero SpinBox allocation by commandLimit and source deployable troops.
- Player attack confirm validation now re-clamps selected allocation by commandLimit before source troop pre-decrement and BattleContext handoff.
- Player attack defender allocation and enemy invasion attacker/defender default allocation now use commandLimit distribution.
- Preserved troop accounting, woundedQueue, captured/dead exclusion, wounded hero penalties, and save/load structures.
- F6 manual QA remains pending for UI display, clamp behavior, player attack win/loss, enemy invasion defense, and woundedQueue recovery.

## v0.68b-12b-28 Player Attack Deployment UX Polish
- Improved deployment panel layout to 560px width with viewport clamping and clearer source/target header.
- Added explicit total assigned troops and remaining garrison troop summary.
- Added per-resource supply preview lines with enough/shortage text for food/rice, gold, and salt.
- Added clearer sortie-blocking reason text near the confirm button.
- Added stronger sortie confirmation feedback with assigned troop and supply consumption details.
- Improved player_attack victory/defeat result copy without changing owner/troop application logic.
- F6 manual QA remains pending; headless project/worldmap/battle scene loads passed.

## v0.68b-12b-27 Player Attack Deployment UI MVP
- Added a runtime player attack deployment panel before battle handoff.
- Added deployable hero selection from the player source city; captured/dead heroes are excluded and wounded heroes remain selectable with badges.
- Added per-hero troop SpinBox allocation with minimum selection/positive troop validation and source-city troop reserve guard.
- Added supply preview and validation: food/rice = assigned troops, gold = ceil(troops * 0.2), salt = ceil(troops * 0.1).
- Added source-city runtime `resource_stock` defaulting/payment and city save/load persistence for supply stock.
- Extended `player_attack` BattleContext with selected attacker ids, troop allocation, supply cost, and supply source city id.
- Deferred sea/2-hop attacks, troop type UI, in-battle supply effects, support selection UI, plunder, siege UI, and hero recruit/faction conversion.
