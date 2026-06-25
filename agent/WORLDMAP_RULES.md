# WORLDMAP RULES

## v0.70-55 Enemy Goal QA & Strategy Hint Polish Lock Rule
- Baseline is local `v0.70-54 Enemy Strategic Goal Seed MVP` (`617883d0fc71db1cdf9668e5c1148a98a5a04766`).
- This rule is a QA/hint polish pass for v0.70-54 strategic goal seeds. It is not a new enemy AI pass, not full enemy AI, not a long-term war planner, not pathfinding, and not enemy economy, diplomacy, or spy system expansion.
- Strategic goal remains seed metadata only: target city ids, target region hints, pressure, compact label, and bounded weight. It may provide only conservative scoring bonuses.
- Goal seed influence remains limited to reinforcement target scoring, strategic action type/target scoring, and already eligible invasion pair scoring.
- PLAYER must not receive enemy strategic goal behavior. Unknown, default, malformed, or empty goal data must fall back safely.
- Goal weights must stay inside `1.00..1.15`; missing target city ids must be ignored.
- Goal label/hint is compact display metadata only. It must not expose hidden enemy resources, chancellor detail, raw faction state, city intel, national stock, or planning internals.
- Summary/hint output may hide default/empty goals and should avoid repeated `목표:` fragments across multi-faction summaries while preserving compact `이번 턴 적 행동`, `침공 대기`, and `외 N건` style.
- Enemy spy pressure remains display/history only and must not mutate player city stats, resources, troops, publicSupport, loyalty, `city_intel`, spy cooldowns, detection penalties, or relation state.
- Enemy diplomacy remains non-player-pair-only score drift and must not directly create alliances, trade agreements, PLAYER relation changes, cooldown changes, resource changes, chancellor changes, or national stock changes.
- Enemy spy actual damage, enemy diplomacy alliance/trade simulation, enemy economy simulation, Battle scene behavior expansion, and repo-wide refactors remain forbidden.
- Existing regression locks remain active: v0.70-51 enemy turn chain, v0.70-52 personality seed scope, v0.70-53 personality tuning, v0.70-54 strategic goal seed MVP, `last_enemy_faction_turn_processed_turn`, `last_enemy_faction_turn_result`, `last_enemy_strategic_action_result`, `strategic_actions` max-one semantics, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext handoff, left PLAYER scope, right selected-city scope, Fog of War, `city_intel`, market formula, alliance behavior, wedge behavior, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scene/asset/`.uid`/`.ogv` stability.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-54 Enemy Strategic Goal Seed MVP Lock Rule
- Baseline was `v0.70-53 Enemy Personality QA Balance Tuning Pass` (`1952388b5ac31a1fede63e9febc87f5bc9a559e9`).
- This rule authorizes conservative enemy faction strategic goal seeds only. It is not full enemy AI, not a long-term war planner, not pathfinding, not enemy economy simulation, and not multi-action strategic behavior.
- Strategic goal data is seed/metadata based: goal id, compact label, target city ids, target region hints, pressure, and bounded weight.
- Strategic goal weights must stay inside `1.00..1.15`; malformed or unknown seeds must fall back to the default goal, and PLAYER must not receive enemy strategic goal behavior.
- Missing target city ids must be ignored. Goal labels must remain compact and must not reveal hidden enemy resources, chancellor detail, city intel, or national state.
- Goal seed influence is limited to small scoring bonuses for reinforcement target selection, strategic action type/target selection, and eligible invasion pair scoring.
- Reinforcement amount constants, one reinforcement action per faction, owner mismatch guards, and player city reinforcement ban remain stable.
- Strategic follow-up remains capped at at most one action per world turn, must skip during pending invasion or pending battle context, and must remain replay-safe through `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, `_player_state["last_enemy_strategic_action_result"]`, and `strategic_actions`.
- Enemy spy pressure remains display/history only and must not mutate player city stats, resources, troops, publicSupport, loyalty, `city_intel`, spy cooldowns, detection penalties, or relation state.
- Enemy diplomacy relation drift remains limited to non-player faction pairs and small score-only changes. It must not directly change PLAYER relations, relation status, alliance state, trade agreement state, cooldowns, resources, chancellor state, or national stock.
- Invasion goal influence may sort already eligible pairs only. `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext handoff, and v0.70-49 eligibility guards must not change.
- Existing regression locks remain active: v0.70-51 enemy turn chain, v0.70-52 personality seed scope, v0.70-53 personality tuning, left PLAYER scope, right selected-city scope, Fog of War, `city_intel` display-only restore, market formula, alliance behavior, wedge behavior, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scene/asset/`.uid`/`.ogv` stability.
- Enemy spy actual damage, enemy diplomacy alliance/trade simulation, enemy economy simulation, Battle scene behavior expansion, and repo-wide refactors remain forbidden.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-53 Enemy Personality QA & Balance Tuning Lock Rule
- Baseline was `v0.70-52 Enemy Faction Personality Seed MVP` (`4ee00833ac7ea4f953ec6e006362ff51b361551f`).
- This rule is a QA/tuning pass for v0.70-52 personality seeds. It is not a new enemy AI pass and not authorization for planning, economy simulation, or multi-action strategic behavior.
- Personality weights may be adjusted only within the bounded `0.75..1.25` range and only for conservative feel tuning.
- Personality remains limited to reinforcement target scoring, strategic action type selection, eligible invasion pair scoring, and compact display metadata.
- Personality labels must stay compact and must not reveal hidden enemy resources, chancellor detail, city intel, or national state.
- Strategic follow-up remains capped at at most one action per world turn, must skip during pending invasion or pending battle context, and must remain replay-safe through `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, `_player_state["last_enemy_strategic_action_result"]`, and `strategic_actions`.
- Enemy spy pressure remains display/history only and must not mutate player city stats, resources, troops, publicSupport, loyalty, `city_intel`, spy cooldowns, detection penalties, or relation state.
- Enemy diplomacy relation drift remains limited to non-player faction pairs and small score-only changes. It must not directly change PLAYER relations, relation status, alliance state, trade agreement state, cooldowns, resources, chancellor state, or national stock.
- Invasion personality influence may sort already eligible pairs only. `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext handoff, and v0.70-49 eligibility guards must not change.
- Enemy spy actual damage, enemy diplomacy alliance/trade simulation, enemy economy simulation, Battle scene behavior expansion, and repo-wide refactors remain forbidden.
- Existing regression locks remain active: left PLAYER scope, right selected-city scope, Fog of War, `city_intel` display-only restore, market formula, alliance behavior, wedge behavior, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scene/asset/`.uid`/`.ogv` stability.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-52 Enemy Faction Personality Seed MVP Lock Rule
- Baseline was `v0.70-51 Enemy Turn QA Pass Manual F6 Feedback Polish` (`682c1002bab46474d72c5ff2ca2d3c4ced977222`).
- This rule authorizes conservative faction personality seeds only. It is not authorization for full enemy AI, planning, economy simulation, or multi-action strategic behavior.
- Faction personality is weight/seed based and must remain bounded. Unknown non-player factions must fall back to `default_balanced`, and PLAYER must not receive enemy personality behavior.
- Personality may influence only reinforcement target scoring, strategic follow-up type selection, eligible invasion pair scoring, and compact display metadata.
- Reinforcement amount constants, frontline/chancellor bonus formulas, faction turn replay guard, and one reinforcement action per faction must remain stable.
- Strategic follow-up remains capped at at most one action per world turn, must skip during pending invasion or pending battle context, and must remain replay-safe through `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, `_player_state["last_enemy_strategic_action_result"]`, and `strategic_actions`.
- Enemy spy pressure remains display/history only and must not mutate player city stats, resources, troops, publicSupport, loyalty, `city_intel`, spy cooldowns, detection penalties, or relation state.
- Enemy diplomacy relation drift, if applied, remains limited to non-player faction pairs and small score-only changes. It must not directly change PLAYER relations, relation status, alliance state, trade agreement state, cooldowns, resources, chancellor state, or national stock.
- Invasion personality influence may sort already eligible pairs only. `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext handoff, and v0.70-49 eligibility guards must not change.
- Existing regression locks remain active: left PLAYER scope, right selected-city scope, Fog of War, `city_intel` display-only restore, market formula, alliance behavior, wedge behavior, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scene/asset/`.uid`/`.ogv` stability.
- Enemy spy actual damage, enemy diplomacy alliance/trade simulation, enemy economy simulation, Battle scene behavior expansion, and repo-wide refactors remain forbidden.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-51 Enemy Turn QA Pass Lock Rule
- Baseline was `v0.70-50 Enemy Faction Diplomacy Spy Behavior Follow-up` (`7fa73bfe31efd76bebefc595768fc55a8d98e3b5`).
- This rule is an enemy turn chain QA pass, not a new feature pass and not authorization for full enemy AI.
- The locked chain is reinforcement -> strategic action -> invasion roll -> pending invasion -> defense deployment -> BattleContext handoff -> battle result apply -> save/load replay guard.
- v0.70-49 invasion guard and v0.70-50 strategic action guard must remain active.
- `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, `_player_state["last_enemy_strategic_action_result"]`, `strategic_actions`, `enemy_invasion_roll_turn`, pending invasion payload shape, and BattleContext handoff must remain replay-safe.
- `strategic_actions` may be normalized for display/history safety and clamped to at most one supported action.
- Enemy spy pressure remains display/history only and must not mutate player city stats, resources, troops, publicSupport, loyalty, or `city_intel`.
- Enemy diplomacy follow-up remains non-player-pair-only score drift and must not directly create enemy alliances, trade agreements, or PLAYER relation changes.
- Enemy full AI, real enemy spy damage, enemy alliance/trade agreement simulation, enemy economy simulation, and Battle scene behavior expansion remain forbidden.
- Existing regression locks remain active: left PLAYER scope, right selected-city scope, Fog of War, market formula, alliance behavior, wedge behavior, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scene/asset/`.uid`/`.ogv` stability.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-50 Enemy Faction Diplomacy/Spy Behavior Follow-up Lock Rule
- Baseline was `v0.70-49 Enemy Invasion Defense Balance Polish` (`1d00fb4402033a88c0c7aeb87f94b48cb3120800`).
- This rule authorizes only a conservative enemy faction diplomacy/spy follow-up. It is not full enemy AI and must not become multi-action strategic simulation.
- Enemy diplomacy/spy follow-up is capped at one strategic action per world turn and must run under the existing enemy faction turn replay guard.
- `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, save/load display/history semantics, pending invasion, and BattleContext handoff must remain stable.
- Enemy turn result may include `strategic_actions`, but reinforcement `actions` must keep its existing meaning.
- Enemy spy pressure is display/history only. It must not directly mutate player city publicSupport, loyalty, troops, resources, `city_intel`, spy cooldowns, detection penalties, or relation state.
- Enemy diplomacy relation drift, if applied, must be limited to non-player faction pairs and small score-only changes. It must not directly change PLAYER relations, relation status, alliance state, trade agreement state, cooldowns, resources, chancellor state, or national stock.
- Strategic follow-up must be skipped while pending invasion or pending battle context exists.
- Existing v0.70-49 locks remain active: invasion candidate guard, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `ENEMY_INVASION_CHANCE`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext, player attack/defense deployment, and invasion result apply must not regress.
- Existing v0.70-47 and diplomacy/spy locks remain active: left panel PLAYER scope, right panel selected-city scope, enemy Fog of War, `city_intel` display-only restore, market formula, alliance behavior, wedge behavior, player chancellor candidate scope, and `_player_state["faction_chancellors"]` must not change.
- This rule does not authorize scene/asset/`.uid`/`.ogv` changes or repo-wide refactors.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-49 Enemy Invasion/Defense Balance Polish Lock Rule
- Baseline was `v0.70-47 WorldMap Strategic UX Final Polish` (`669da7976600db60b8a6283b1c9fb3f4d9078f70`). `v0.70-48 Enemy Faction Diplomacy/Spy Behavior Follow-up` remains deferred.
- This rule authorizes invasion/defense balance guards and QA polish only. It is not authorization for full enemy AI, enemy diplomacy behavior, enemy spy behavior, or enemy economy simulation.
- `ENEMY_INVASION_CHANCE`, `enemy_invasion_roll_turn`, same-turn replay guards, pending invasion payload shape, BattleContext key/shape, and Battle handoff semantics must remain stable.
- Candidate eligibility may be strengthened for missing city data, owner mismatch, wrong owner scope, non-adjacent pairs, attacker troop readiness, and BattleContext readiness.
- Candidate scoring may sort already eligible invasion pairs for more plausible selection, but it must remain a small display/selection helper and must not become multi-turn strategy simulation.
- Defense deployment must keep `source = defender city` and `target = attacker city`, preserve selected defender hero validation, captured/dead exclusion through existing availability checks, command limits, and deployable troop clamp.
- Invasion result application may add safety guards for defender win, attacker win, retreat, unknown, missing city data, troop safety, pending cleanup, and summary clarity. It must not expand Battle scene combat logic, player attack system scope, hero death/capture systems, or placeholder wounded/captured mechanics.
- Existing v0.70-47 locks remain active: left panel is PLAYER national/court scope, right panel is selected-city scope, enemy Fog of War and `city_intel` reveal rules remain payload-backed, and market/alliance/wedge/chancellor formulas and scopes must not change.
- This rule does not authorize scene/asset/`.uid`/`.ogv` changes or repo-wide refactors.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-47 WorldMap Strategic UX Final Polish Lock Rule
- Baseline was `v0.70-46 Enemy Faction Turn Behavior QA Balance Polish` (`97046321ae51f7ea0fd6a726e7b6dc42f4742ab8`).
- This rule authorizes copy, hint, tooltip, and compact summary polish only for the existing WorldMap strategic UX.
- Left World Status must remain PLAYER national/court scope. It may polish turn, calendar, phase, player resources, chancellor, domestic, market, and compact enemy phase hint copy, but must not switch to foreign/enemy national state or expose hidden enemy resources/chancellor details.
- Right Selected City must remain selected-city scope. Player-owned cities keep the existing full-info path; enemy/foreign cities keep Fog of War and may only reveal payload-backed `city_intel` fields.
- Unified City Detail, Diplomacy, Spy, and Trade tabs may polish labels, summaries, hints, and tooltips. They must not change formulas, chances, costs, cooldowns, validation gates, execution paths, or save/load replay behavior.
- Enemy turn result and pending invasion copy may be compacted, including `외 N건` summaries, but `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]` display/history semantics, `ENEMY_INVASION_CHANCE`, pending invasion event payload shape, and BattleContext handoff must not change.
- This rule does not authorize enemy AI expansion, enemy diplomacy/spy/economy simulation, market formula changes, alliance/wedge changes, Fog of War weakening, player chancellor candidate scope changes, `_player_state["faction_chancellors"]` structure changes, BattleContext changes, scene/asset changes, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-46 Enemy Faction Turn QA / Balance Lock Rule
- Baseline was `v0.70-45 Enemy Faction Turn Behavior MVP` (`964d8db3d61a2154e268ba1f905691f9ac493262`).
- This rule is a QA/balance lock over v0.70-45 enemy faction turn behavior, not authorization for full enemy AI.
- Enemy reinforcement is limited to enemy-owned city troops only: base `+60`, frontline `+40`, valid enemy faction chancellor seed `+20`, max `+120`.
- The lower `+120` max replaces the v0.70-45 `+150` max to slow multi-faction turn-by-turn troop accumulation while preserving visible enemy action.
- `_player_state["last_enemy_faction_turn_processed_turn"]` remains the authoritative same-turn replay guard. Save/load may restore it and must not replay enemy reinforcement or rerun the same-turn enemy invasion roll for an already processed turn.
- `_player_state["last_enemy_faction_turn_result"]` remains display/history state only.
- Enemy city ownership must be conservative. If marker owner and HUD/runtime owner both exist but disagree, enemy turn selection and reinforcement must skip that city.
- Enemy turn summary/hint should remain compact; when several actions exist, show a short set and summarize omitted entries with `외 N건`.
- `ENEMY_INVASION_CHANCE`, pending invasion event payload shape, and BattleContext handoff must not change in this rule.
- Verification for this pass included `git diff --check`, required enemy-turn/search verification, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- This rule does not authorize player city/resource direct mutation, enemy diplomacy AI, enemy spy AI, enemy economy simulation, target city storage mutation, foreign stock simulation, market formula changes, alliance/wedge changes, Fog of War weakening, player chancellor candidate scope changes, left/right panel scope changes, BattleContext changes, scene/asset changes, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-45 Enemy Faction Turn Behavior MVP Rule
- Baseline was `v0.70-44 WorldMap Domestic/Turn Flow QA & Polish` (`cc977ad461a971819ba5be2a4d2a6d414aabe7a8`).
- Enemy phase may run conservative non-player faction behavior, but this rule authorizes only one reinforcement/log action per faction per `turn_number`.
- `_player_state["last_enemy_faction_turn_processed_turn"]` is the authoritative same-turn replay guard. Save/load may restore it and must not replay enemy reinforcement or rerun the same-turn enemy invasion roll for an already processed turn.
- `_player_state["last_enemy_faction_turn_result"]` is display/history state. It may include processed factions, action payloads, chancellor bonus metadata, pending invasion flags, and a compact summary.
- Enemy faction selection must exclude PLAYER, empty factions, unknown/no-city factions, and player-owned cities.
- Enemy city selection should prefer a faction-owned city adjacent to a player-owned city, then the faction-owned city with the lowest troops.
- Enemy reinforcement is limited to enemy-owned city troops only: base `+80`, frontline `+40`, valid enemy faction chancellor seed `+20`, max `+150`.
- `_player_state["faction_chancellors"]` remains the existing seed structure. This rule only allows reading it for the small reinforcement bonus and result metadata; it does not authorize enemy chancellor UI or enemy domestic policy simulation.
- Enemy turn MVP must not directly reduce player city troops/resources, capture player cities without battle, mutate player resources/chancellor/market/diplomacy/spy/city intel, mutate target city storage, or simulate foreign stock.
- Existing enemy invasion event generation remains authoritative. Do not change `ENEMY_INVASION_CHANCE`, pending invasion payload shape, or BattleContext handoff; enemy result state may only record whether the existing roll created a pending event.
- Left World Status remains PLAYER/nation scope. Enemy turn summaries may be shown as compact logs, but hidden enemy resources, raw city details, or enemy national panel state must not be exposed.
- This rule does not authorize market formula changes, manual/chancellor trade pricing changes, alliance/wedge behavior changes, spy/diplomacy formula changes, Fog of War weakening, player chancellor candidate scope changes, left/right panel scope changes, BattleContext changes, scene/asset changes, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-44 Domestic / Turn Flow QA Lock Rule
- This pass is a regression guard over player turn end, domestic apply, world turn progression, save/load replay safety, market same-turn state, diplomacy/alliance duration, spy/revolt duration, city intel display-only restore, pending invasion event flow, and chancellor/left-panel scope.
- Baseline was `v0.70-43 WorldMap Diplomacy Spy Intel Final QA Pass` (`aa7ba353a7eaec2bf38868b2110922d179ba1995`).
- This rule does not authorize enemy faction behavior, new domestic systems, new diplomacy/spy actions, market formula changes, alliance/wedge formula changes, BattleContext changes, scene/asset changes, `.uid`, or `.ogv` changes.
- Player turn end must continue to set enemy phase and `domestic_apply_pending`, then apply domestic once at enemy-turn finish before advancing `turn_number` and returning to player phase.
- `_player_state["last_domestic_apply_turn"]` is the authoritative same-turn domestic replay guard. Loading saved result payloads must not reapply resource, city storage, loyalty, cooldown, market, trade, spy, or tech effects.
- Trade market state must remain turn-scoped through `_player_state["last_trade_market_result"]`, `trade_market_prices`, and `trade_market_turn`; same-turn save/load must keep prices stable and only a new turn or missing state may generate a new market.
- Chancellor automatic trade must keep `_player_state["last_chancellor_auto_trade_turn"]` as its same-turn replay guard. Loading `last_chancellor_auto_trade_result` must restore display/history only and must not reapply resource or storage deltas.
- Diplomacy action cooldowns, trade agreement duration, and alliance duration may tick only through world-turn domestic advancement. Trade agreement state and alliance state must remain separate; alliance expiry may return relation status to neutral but must not clear active trade agreement metadata.
- Spy cooldown and `revolt_instigation` duration may tick only through world-turn domestic advancement. `last_spy_wedge_result` and other last spy result payloads are display/history state and must not replay relation, city, cost, detection, or alliance-break effects on load.
- `_player_state["city_intel"]` remains display-only Fog of War state. Failed spy results must not open intel, and load may restore display only without replaying spy effects.
- Pending invasion event and pending battle context remain transient runtime state for this lock. Save/load may clear them to prevent resolved or half-prepared invasions from replaying.
- Left World Status remains player/nation scope, foreign city selection must not clear player chancellor state, player chancellor candidates must remain scoped to the player candidate city roster, and `_player_state["faction_chancellors"]` remains intact.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-43 Diplomacy/Spy/Intel QA Lock Rule
- This pass is a regression guard over `v0.70-39 Trade Market / Price Variation MVP`, `v0.70-40 Diplomacy Action Polish / Alliance MVP`, `v0.70-41 Spy Action Polish / Alienation MVP`, and `v0.70-42 Enemy Intel UI Polish / Fog of War`.
- Baseline was `v0.70-42 Enemy Intel UI Polish / Fog of War` (`7e0d27b887c7cd5989efc2a18038665c7e99854b`).
- This rule does not authorize new diplomacy actions, spy actions, trade systems, market formulas, enemy AI behavior, map fog overlays, battle features, or large UI restructuring.
- Market pricing must continue to use `MANUAL_TRADE_PREVIEW_PRICES` as base authority and `_get_trade_market_price()` through the shared import/export helpers so manual preview, manual execution, and chancellor external auto trade stay aligned.
- Alliance proposal must remain validation-first. Alliance duration belongs to relation entry `alliance_turns_remaining`; trade agreement duration remains separate and must not be overwritten by alliance expiry.
- Wedge / `이간질` must remain selected-foreign-city scoped. PLAYER must never be the target-counterpart faction; validation failures must not spend resources, apply cooldown, mutate relations, or break alliances.
- Rolled wedge attempts may apply cost/cooldown by existing rule; success may mutate only target-counterpart relation, and detection penalty applies only to the PLAYER-target relation.
- Enemy city intel remains display-only Fog of War state. Failed spy results must not open intel, payload-missing fields must stay locked, and load must never replay spy costs, relation changes, detection penalties, city effects, wedge effects, or alliance breaks.
- Left World Status remains player/nation scope. Foreign city selection must not clear `_player_state["chancellor_id"]`, and player chancellor candidates must remain scoped to the player candidate city roster.
- `_player_state["faction_chancellors"]` remains seed/display state for non-player factions and must not leak into the player chancellor dropdown.
- Future QA fixes in this area should be minimal guards, display copy fixes, malformed-state normalization, result payload completion, or warning cleanup only.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-42 Enemy Intel Fog of War UI Rule
- Enemy/foreign selected-city display may polish Fog of War copy, but must remain selected-city scope.
- Baseline was `v0.70-41 Spy Action Polish / Alienation MVP` (`aae97d12676cea97c065a67f6366a9593e9e26ef`).
- Player-owned cities must keep the existing full city information display path.
- Enemy cities without intel may show city name, owner faction, and city type, plus locked detail copy.
- Enemy intel display levels are `none` / `미확인`, `basic` / `기초 정탐`, `military` / `군사 정탐`, `resource` / `군사/자원 정탐`, `domestic` / `내정 정탐`, and `full` / `상세 정탐`.
- Revealed labels should map `troops_estimated` to `병력 추정`, `troops` to `병력`, `resources` to `자원`, `publicSupport` to `민심`, `loyalty` to `충성도`, `governor` to `태수`, and `tech` to `기술`.
- A field is revealed only when the city-intel field and matching payload data are both present; unknown fields or payload-missing fields must remain locked.
- Locked details should clearly use `정탐 필요` when no intel exists and `추가 정탐 필요` when partial intel exists.
- Spy-tab known-info summaries should use the same information level, revealed field, and locked field vocabulary as the right selected City Info panel.
- `_player_state["city_intel"]` is display-only state. Loading a save may restore Fog of War display but must never replay spy effects, costs, relation changes, detection penalties, wedge effects, or alliance breaks.
- This rule does not authorize spy formula/effect changes, `이간질` behavior changes, alliance proposal changes, market price formula changes, external trade pricing changes, chancellor candidate scope changes, `faction_chancellors` changes, left panel scope changes, BattleContext changes, player-owned city display changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-41 Spy Alienation Rule
- Spy action card may execute `wedge` / `이간질` against a selected foreign city.
- Baseline was `v0.70-40 Diplomacy Action Polish / Alliance MVP` (`0f516a7473cadd371afa04f9b1352c3e9823d85a`).
- Validation must complete before any resource cost, relation mutation, cooldown, alliance break, detection penalty, or result mutation.
- Validation must block empty/player-owned targets, missing national chancellor, missing political aptitude, active spy cooldown, iron-wall targets, missing counterpart faction, already-hostile target-counterpart relations, and insufficient wedge resources.
- Counterpart faction must be a non-player third faction and must never be PLAYER or the target faction.
- Counterpart selection should prefer target-counterpart allied relations, then relation score 60+, then active alliance/trade-agreement metadata, then the highest remaining relation score.
- Wedge cost is `SPY_WEDGE_COST` (`gold 600`, `silk 150`); validation failures must not spend resources.
- Rolled wedge attempts spend the operation cost and apply `SPY_WEDGE_COOLDOWN_TURNS`, regardless of success or failure.
- Success lowers the target-counterpart relation score by a conservative political aptitude delta and must use the existing faction relation score path.
- If a successful wedge drops an allied target-counterpart relation below `ALLIANCE_ACCEPTANCE_THRESHOLD`, allied status may be cleared and `alliance_turns_remaining` set to 0.
- Detection applies `SPY_DETECTED_RELATION_PENALTY_WEDGE` only to the PLAYER-target faction relation; detection and success may both apply.
- `_player_state["last_spy_wedge_result"]` is display/history data. Loading a save may restore it but must never replay costs, relation changes, detection penalties, or alliance breaks.
- This rule does not authorize changes to existing spy formulas/effects for `gather_info`, `public_support_disrupt`, `loyalty_disrupt`, or `revolt_instigate`; diplomacy alliance proposal behavior; market price formulas; enemy city intel visibility; player chancellor candidate scope; `faction_chancellors`; left national panel scope; right selected-city scope; BattleContext; Selected City Panel; `project.godot`; scenes; assets; `.uid`; or `.ogv`.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-40 Diplomacy Alliance Rule
- Diplomacy action card may execute `alliance_proposal` / `동맹 제안` against selected foreign factions.
- Baseline was `v0.70-39 Trade Market / Price Variation MVP` (`84bbf9c5e12e3afff523d3e389043a7126dce732`).
- Validation must complete before any proposal cost, relation mutation, cooldown, or alliance state mutation.
- Validation must block empty/player targets, hostile or suspended relations, already active alliances, active target-faction diplomacy action cooldown, and insufficient proposal resources.
- Proposal cost is `gold 200` and `silk 50`; validation failures must not spend resources.
- Rejected proposals may spend the proposal package and apply diplomacy cooldown, but must not change relation status or relation score.
- Accepted proposals set the player-target relation entry to `allied` and store `alliance_turns_remaining = 8`.
- Alliance acceptance must use the existing alliance acceptance score/threshold path; do not add complex AI response or random diplomacy rolls in this rule.
- Active alliance duration belongs to the relation entry and may be mirrored into `_player_state["alliances"]` for save/load fallback.
- Loading a save may restore active alliance duration but must never replay proposal costs, acceptance, or relation mutations.
- World-turn diplomacy advancement may decrement alliance duration and must return expired alliances to `neutral` without changing trade agreement duration.
- Existing envoy, tribute, trade agreement, and restore-relations behavior must remain intact.
- This rule does not authorize market price formula changes, external trade pricing changes, spy formula/effect changes, `이간질`, military support request execution, enemy diplomacy/spy execution, chancellor candidate scope changes, `faction_chancellors` changes, enemy city intel filter changes, BattleContext changes, Selected City Panel changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-39 Trade Market / Price Variation Rule
- External trade pricing may use turn-scoped market prices derived from `MANUAL_TRADE_PREVIEW_PRICES`.
- Baseline was `v0.70-38-hotfix1 Chancellor Candidate Scope & Enemy Chancellor Seed` (`71c61f331a7185a1ebbb2d042b53d791dcb556a8`).
- Market multipliers must remain conservative, clamped to `0.80..1.20`, with minimum price `1`.
- Same-turn market state must remain stable for manual preview, manual execution, chancellor external auto trade, and save/load.
- Market state may be stored in `_player_state["last_trade_market_result"]` and mirrored to `_player_state["trade_market_prices"]` / `_player_state["trade_market_turn"]`.
- Import formula is `ceil(market_price * amount / efficiency)`.
- Export formula is `floor(market_price * amount * efficiency)`.
- Relation efficiency and trade availability gates must continue to use the existing relation/trade agreement path.
- Pending manual external orders must recalculate preview from current market price and relation efficiency on load/refresh.
- This rule does not authorize target city storage mutation changes, foreign faction stock, relation score mutation, random trade rolls, diplomacy/spy behavior changes, chancellor candidate scope changes, enemy city intel filter changes, BattleContext changes, Selected City Panel changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-38-hotfix1 Chancellor Candidate Scope Rule
- Player chancellor assignment remains player/nation scope, but player chancellor candidates must come from the player chancellor candidate city roster, not all player-side heroes.
- Baseline was `v0.70-38 Enemy City Intel Visibility Filter` (`6b61e1f045c461eeff5a53f5a4b77aae6cbada53`).
- Candidate city priority is valid `_player_state["capital_city_id"]`, then `hanseong`, then first valid player-owned city.
- Candidate heroes must be in the candidate city's `stationed_hero_ids` / `hero_ids` and must pass player-side, alive/uncaptured, chancellor aptitude validation.
- Pyeongyang/foreign stationed heroes must not appear as Hanseong chancellor candidates unless they are actually stationed in the player candidate city.
- A current valid player chancellor may remain assigned and visible as display-only even if outside the candidate city; this rule does not authorize automatic chancellor dismissal.
- Non-player faction chancellor seed state may live in `_player_state["faction_chancellors"]` and should be normalized/reseeded on load for missing, invalid, player-faction, dead, or captured entries.
- Enemy faction chancellors are seed state only; this rule does not authorize enemy domestic execution, enemy diplomacy/spy actions, or enemy chancellor UI expansion.
- This rule must not weaken the left national panel scope lock or the enemy city intel visibility filter.
- This rule does not authorize spy formula/effect changes, diplomacy action changes, trade price/efficiency changes, chancellor auto trade changes, BattleContext changes, Selected City Panel changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-38 Enemy City Intel Visibility Rule
- Right-side selected City Info remains selected-city scope, but foreign/enemy city details must be gated by spy intel.
- Baseline was `v0.70-37-hotfix1 Left National Panel Scope Lock` (`f5b74da8c1d24ae6db4390562eb16a69018d1625`).
- Player-owned cities must keep the existing full city information display.
- Foreign/enemy cities without intel may show only basic identity such as city name, owner faction, city type, and locked detail text.
- Foreign/enemy cities without intel must not reveal city loyalty, public support/security, governor, full garrison, troop/defense detail, recruitment, resources/storage, or tech details.
- Successful `정탐` may record `_player_state["city_intel"][target_city_id]` with `turn`, `fields`, `estimated`, and `payload` for display.
- Supported intel fields are `troops_estimated`, `troops`, `resources`, `publicSupport`, `loyalty`, `governor`, and `tech`.
- Loading a save may restore `_player_state["city_intel"]` for display, but must never replay spy effects or mutate city state from intel payloads.
- Spy-tab known-info summaries should use the same city intel registry and should not reveal hidden enemy-city detail before intel exists.
- Left World Status panel remains player/nation scope; this rule must not weaken the `v0.70-37-hotfix1` left panel scope lock.
- This rule does not authorize spy formula changes, spy effect amount changes, diplomacy action changes, trade price/efficiency changes, chancellor auto trade changes, BattleContext changes, player-owned city display changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-37-hotfix1 Left National Panel Scope Lock Rule
- Left World Status panel is player/nation scope and must not derive national state from the currently selected city.
- Baseline was `v0.70-37 Spy Action MVP` (`3c0a03be6163230f029eadf464a7b4afee12e775`).
- Left-panel national state includes national loyalty, tax, national warehouse/resource stock, chancellor assignment, chancellor policy, save controls, and ally turn ending.
- Right City Detail, diplomacy/spy target display, and trade target display remain selected-city scope.
- Selecting a foreign city must never clear `_player_state["chancellor_id"]` because the national chancellor is not stationed in that selected city.
- `_sync_chancellor_assignment_for_selected_city()` may clear only missing or invalid non-player chancellor ids, not selected-city stationing mismatches.
- Chancellor assignment UI should use player-side national candidates or preserve the current valid player chancellor display when selected-city candidates are unavailable.
- Spy validation must read national chancellor state; `no_chancellor` should mean no assigned national chancellor, not foreign-city selection.
- This rule does not authorize spy formula changes, spy effect changes, diplomacy action changes, trade price/efficiency changes, chancellor auto trade changes, save/load schema changes, Selected City Panel changes, BattleContext changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-37 Spy Action Rule
- Spy actions may execute only from City Detail `외교·첩보 > 첩보` against a selected foreign city.
- Baseline was `v0.70-36 Diplomacy Action MVP` (`b0f40e4ca4f9acac568a23b73652afc145a1eb66`).
- MVP executable action ids are:
  1. `gather_info`: run existing spy info roll/payload logic and apply spy cooldown.
  2. `public_support_disrupt`: lower target city public support only on successful undetected execution.
  3. `loyalty_disrupt`: lower target city loyalty only on successful undetected execution.
  4. `revolt_instigate`: record existing `revolt_instigation` boost only on successful undetected execution.
- Validation must complete before any target city effect, relation penalty, cooldown, or result mutation.
- Validation must block empty targets, player-owned targets, missing chancellor, missing political aptitude, active spy cooldown, iron-wall targets, and action-specific revolt prerequisites.
- This MVP does not authorize separate spy gold/resource costs.
- Detection may apply a conservative relation score penalty through the existing faction relation helper and must record before/after score metadata.
- Spy cooldown remains `_player_state["spy_cooldown"]` and may advance during existing domestic-turn cooldown processing.
- Result payloads are display/history data in the existing `_player_state` keys: `last_spy_result`, `last_spy_public_support_disrupt_result`, `last_spy_loyalty_disrupt_result`, and `last_spy_revolt_instigation_result`.
- Loading a save may restore recent results, cooldown, and revolt instigation state but must never replay spy effects.
- This rule does not authorize `이간질`, faction-to-faction relation manipulation, spy units, spy networks, diplomacy action behavior changes, trade pricing changes, chancellor auto trade changes, target city storage mutation, foreign faction stock mutation, Selected City Panel changes, BattleContext changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-36 Diplomacy Action Rule
- Diplomacy actions may execute only from City Detail `외교·첩보 > 외교` against a selected foreign city/faction.
- Baseline was `v0.70-35 Trade Balance / Relation Efficiency Polish` (`f0d03010829b72a64479712fd97833a509e7bad6`).
- MVP executable action ids are:
  1. `envoy`: gold 30, relation +5, diplomacy action cooldown 1.
  2. `tribute`: gold 100, relation +12, diplomacy action cooldown 2.
  3. `trade_agreement`: gold 80, relation +4, trade agreement 6 turns, diplomacy action cooldown 2.
  4. `restore_relations`: gold 120, relation +18, diplomacy action cooldown 3.
- Validation must complete before any cost, relation, cooldown, or agreement mutation.
- Validation must block empty targets, player-owned targets, active target-faction diplomacy action cooldown, insufficient national gold, trade agreement under relation score 45, trade agreement in hostile/suspended status, and restore relations outside hostile/suspended status.
- Costs are paid from national `_player_state["resource_stock"].gold`.
- Relation score changes must clamp to the existing `0..100` range and use the existing relation entry path.
- Diplomacy action cooldown belongs to the target faction relation entry and may be mirrored into `_player_state["diplomacy_action_cooldowns"]` for save/load fallback.
- Trade agreements must reuse existing relation entry fields and the existing trade agreement multiplier path; do not add a second independent trade efficiency formula.
- Trade agreement mirror state may live in `_player_state["trade_agreements"]`, but load must not replay action effects.
- `_player_state["last_diplomacy_action_result"]` is display/result history only.
- World-turn diplomacy cooldown advancement may decrement diplomacy action cooldowns and trade agreement turns.
- This rule does not authorize alliance proposal execution, military support request execution, war declaration, treaty breaking, AI response/rolls, spy action execution, target city storage mutation, foreign faction stock mutation, external trade pricing changes, chancellor auto trade restructuring, manual trade panel changes, Selected City Panel changes, BattleContext changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-35 Trade Balance / Relation Efficiency Rule
- External trade pricing may now apply relation efficiency for manual external trade and chancellor external auto trade.
- Baseline was `v0.70-33 Chancellor Auto Trade Logic Connect` (`1cf079873163784da6620b5b3ecdf6cffdaa6e18`).
- Efficiency must come from the existing relation/trade agreement multiplier path and be clamped before price calculation.
- Import formula: `ceil(base_price * amount / efficiency)`.
- Export formula: `floor(base_price * amount * efficiency)`.
- Higher efficiency is better for the player: imports cost less and exports gain more.
- Efficiency `<= 0.0` means no trade; hostile/suspended relations remain blocked by `_can_trade_between_factions()`.
- Manual external trade preview and execution must use the same delta helper so preview and result match.
- Pending manual external orders must recalculate preview on load/refresh from current relation efficiency; saved preview values are display metadata, not authority.
- Chancellor external auto trade may use relation-aware pricing and may prefer higher-efficiency valid candidates, but must keep the existing policy/aptitude/cap structure.
- External trade may mutate source city `storage` only.
- This rule does not authorize target city storage mutation, foreign faction stock, national `resource_stock` mutation, relation score mutation, turn cost, random success/failure rolls, market price fluctuation, diplomacy actions, spy actions, Selected City Panel changes, BattleContext changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-33 Chancellor Auto Trade Rule
- This rule was implemented after `v0.70-34` and `v0.70-34-hotfix1` to fill the skipped `v0.70-33 Chancellor Auto Trade Logic Connect` candidate.
- Baseline was `v0.70-34-hotfix1 GDScript Shadowing Warning Cleanup` (`83cbf79c45bd66959cf0c0478c161ce275de6c47`).
- Chancellor auto trade may run only during player domestic-turn processing and only once per turn.
- The same-turn guard is `_player_state["last_chancellor_auto_trade_turn"]`; the display/result payload is `_player_state["last_chancellor_auto_trade_result"]`.
- Preconditions:
  1. At least one player-owned city exists.
  2. A valid player-side chancellor hero is assigned.
  3. At least one trade tab mode is `chancellor`.
- No chancellor, invalid chancellor, no player city, disabled modes, and no actionable trade must be no-op result payloads, not crashes.
- Internal chancellor auto trade:
  1. Runs only when internal trade mode is `chancellor`.
  2. Uses connected player-owned city pairs from `_get_internal_trade_connected_player_city_ids()`.
  3. May mutate source and target player-owned city `storage` only.
  4. Must preserve total player city storage amount for moved resources.
  5. Must keep source above target minimum plus surplus buffer.
  6. Must use conservative resource and turn caps.
- External chancellor auto trade:
  1. Runs only when external trade mode is `chancellor`.
  2. Uses `_get_external_trade_candidate_city_ids()` and `_can_trade_between_factions()`.
  3. May mutate source city `storage` only.
  4. May import shortage resources if source city gold can pay using `MANUAL_TRADE_PREVIEW_PRICES`.
  5. May export surplus resources without dropping the resource below target minimum.
  6. Must not mutate target city storage, foreign faction stock, relation score, national `resource_stock`, or turn state.
- Chancellor policy priority:
  1. `balanced`: stable small replenishment across food, strategy, specialty, and gold.
  2. `agriculture`: rice, barley, seafood, salt first.
  3. `commerce`: gold and surplus silk/salt/seafood exports first.
  4. `trade`: seafood, salt, silk focus and higher external cap.
  5. `military`: iron, horses, wood, then food baseline.
- Chancellor `diplomatic`, `economic`, or `administrative` aptitude may modestly increase caps; caps must remain conservative.
- Loading a save may restore the last result display and turn guard but must never replay automatic trade effects.
- Manual external order/execution and internal manual transfer remain valid separate paths. Pending manual external orders should keep display priority.
- This rule does not authorize target city storage mutation for external trade, foreign faction stock, relation efficiency pricing, price variation, random success/failure rolls, diplomacy actions, spy actions, troop movement, turn cost, Selected City Panel changes, BattleContext changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.
- Keep `v0.70-34-hotfix1` warning cleanup intact: do not reintroduce local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.

## v0.70-34-hotfix1 GDScript Warning Cleanup Rule
- Warning-cleanup hotfixes may rename local variables or parameters that shadow class members or built-in functions.
- The class members `resource_label`, `selected_city_id`, and `loyalty_card` are legitimate existing state and should not be removed for this warning cleanup.
- Local variables inside WorldMap or Selected City Panel functions must not reuse those class-member names.
- Function parameters must not use `sign` where Godot reports a built-in-name collision.
- This hotfix rule does not authorize behavior changes, UI layout changes, formula changes, trade persistence changes, manual trade changes, internal transfer changes, external execution changes, save/load structure changes, BattleContext changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.

## v0.70-34 Trade Persistence Rule
- Trade persistence for `v0.70-29` through `v0.70-32` belongs in the existing worldmap save/load path.
- Trade control modes must be saved as data, not UI state, and must restore internal and external trade modes separately.
- Missing or invalid trade control modes must fall back to `chancellor`.
- Pending external manual trade orders may be saved and restored only as confirmed order payloads.
- Pending external manual order load must normalize source/target ids, allowed resource ids, `import/export` action ids, nonnegative integer amounts, and recalculated preview deltas.
- Invalid or corrupt pending external manual orders should be pruned and logged; load must not crash on malformed payloads.
- Recent external manual execution result and recent internal manual transfer result are display-only payloads. Loading them must not replay trade execution, internal transfer, relation changes, turn changes, or any storage mutation.
- City storage persistence remains the existing city runtime `storage` save/load path. Missing storage in old saves must continue to use the existing default/fallback behavior.
- UI node state, open panel state, SpinBox in-progress values, OptionButton current selections, and other transient UI state must not be saved.
- `v0.70-33 Chancellor Auto Trade Logic Connect` remains a follow-up and is not authorized by this persistence rule.
- This rule does not authorize relation efficiency pricing, price variation, target city storage mutation for external trade, foreign faction stock, turn cost, random trade rolls, Selected City Panel changes, diplomacy/spy behavior changes, BattleContext changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.

## v0.70-32 External Manual Trade Execution Rule
- City Detail `무역 > 타국무역` may execute a saved manual external trade order only through the external-trade execution UI.
- The source city must be the selected player-owned city and must match the saved order source.
- The target city must still be returned by `_get_external_trade_candidate_city_ids(source_city_id)`.
- Source and target factions must be non-empty, different, and pass `_can_trade_between_factions()`.
- Execution must reuse the `v0.70-30` order payload and `MANUAL_TRADE_PREVIEW_PRICES` so preview and execution deltas match.
- Relation efficiency may be displayed but must not affect execution pricing until a dedicated Trade Balance / Diplomacy Connect task authorizes it.
- Import orders apply to source city `storage` only:
  1. `storage.gold -= price * amount`
  2. `storage[resource] += amount`
- Export orders apply to source city `storage` only:
  1. `storage[resource] -= amount`
  2. `storage.gold += price * amount`
- Validation must finish before mutation and must block missing/invalid order, non-player source, invalid/expired target, blocked relation, invalid resource id, invalid action, negative amount, empty actionable order, gold shortage, and export resource shortage.
- Validation failure must not partially apply storage changes.
- Successful execution may record a runtime recent execution result and must clear the pending external manual order for that source city.
- Failed execution may record a failure message for display and must keep the pending order.
- This rule does not authorize target city storage changes, foreign faction stock changes, national `resource_stock` changes, relation score changes, turn changes, random success rolls, price variation, chancellor automatic trade, save/load schema rewrites, Selected City Panel changes, diplomacy/spy behavior changes, BattleContext changes, `project.godot`, scenes, assets, `.uid`, or `.ogv` changes.

## v0.70-31 Internal Trade Manual Transfer Rule
- City Detail `무역 > 자국무역` may open a manual internal transfer panel only from internal-trade `수동 조정`.
- The source city must be the currently selected player-owned city.
- The target city must be a connected player-owned city returned by `_get_internal_trade_connected_player_city_ids()`.
- Foreign cities must never appear as internal transfer targets.
- The internal transfer UI should expose:
  1. source city,
  2. connected player-owned target selector,
  3. per-resource source-owned amount display,
  4. per-resource transfer amount input,
  5. source/target expected transfer preview,
  6. apply and cancel controls.
- Internal manual transfer resources are `gold`, `rice`, `barley`, `seafood`, `wood`, `iron`, `horses`, `silk`, and `salt`.
- Each amount input must be capped by the source city `storage` amount.
- Applying a valid transfer may mutate city `storage` for the source and target cities only.
- Applying a transfer must not mutate national `resource_stock`, relation scores, turn state, troop movement, external trade orders, or BattleContext.
- Empty/all-zero transfer requests must be blocked.
- Source/target ownership, source != target, connected target membership, allowed resource ids, nonnegative amounts, and source storage availability must be validated before mutation.
- Recent internal transfer summaries may be stored in runtime player state for display.
- City storage persistence follows the existing city storage save/load path; this rule does not authorize a large save/load schema rewrite.
- External trade execution and chancellor automatic trade remain deferred.
- This rule does not authorize changes to external manual trade order behavior, Resource tab structure beyond refreshed storage display, diplomacy/spy tab behavior including `v0.70-28-hotfix1` subtab visibility, Selected City Panel, formulas, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-30 Manual Trade Order Panel Rule
- City Detail `무역 > 타국무역` may open a manual external trade order panel only from external-trade `수동 조정`.
- The source city must be selected, player-owned, and have at least one valid external trade candidate.
- The panel must stay under `WorldMapUI` / CanvasLayer so it is not affected by worldmap camera pan or zoom.
- The manual external order UI should expose:
  1. source city,
  2. external candidate selector,
  3. relation/trade availability/efficiency display,
  4. per-resource `안함 / 수입 / 수출`,
  5. per-resource integer amount input,
  6. expected gold/resource delta preview,
  7. save and cancel controls.
- MVP manual trade resources are `rice`, `barley`, `seafood`, `wood`, `iron`, `horses`, `silk`, and `salt`.
- MVP prices are preview-only constants and must not be treated as final trade formulas.
- `수입` means the preview resource amount increases and preview gold decreases; `수출` means the preview resource amount decreases and preview gold increases.
- Relation efficiency may be displayed in this MVP, but must not mutate formulas or actual values.
- `명령 저장` stores a runtime placeholder order only. It must not change `resource_stock`, city `storage`, relation, turn, route state, or save/load data.
- Empty/all-zero orders should not be saved as valid orders.
- `자국무역` manual transfer remains deferred to `Internal Trade Manual Transfer MVP`.
- Chancellor automatic trade remains deferred to `Chancellor Auto Trade Logic Connect`.
- Save/load persistence for manual trade orders remains deferred to a later Trade Execution/Control persistence step.
- This rule does not authorize changes to Resource tab, diplomacy/spy tab behavior including `v0.70-28-hotfix1` subtab visibility, Selected City Panel, formulas, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-29 Trade Control Mode UI Rule
- City Detail `무역 > 자국무역` and `무역 > 타국무역` own a visible trade-control UI card.
- The trade-control UI must expose two mode choices: `재상에게 일임` and `수동 조정`.
- Internal trade mode and external trade mode are separate state slots and should not overwrite each other.
- The default mode for both trade tabs is `chancellor`.
- For this MVP, trade-control mode may remain runtime-only; save/load persistence belongs to a later Trade Control Connect task.
- `수동 조정` must be disabled when there is no valid target:
  1. Internal trade requires at least one connected player-owned neighboring city.
  2. External trade requires at least one adjacent foreign trade candidate.
- Selecting a trade-control mode may refresh the City Detail trade UI, but must not execute trade or mutate resources, gold, relations, turns, city storage, or save data.
- Manual trade details remain deferred to `Manual Trade Order Panel MVP`.
- Chancellor automatic trade remains deferred to `Chancellor Auto Trade Logic Connect`.
- Resource tab, diplomacy/spy tab behavior including `v0.70-28-hotfix1` subtab visibility, Selected City Panel, formulas, BattleContext, save/load schema, `project.godot`, scenes, assets, `.uid`, and `.ogv` files must remain unchanged unless a dedicated task authorizes them.

## v0.70-28-hotfix1 Diplomacy Spy Subtab Visibility Rule
- In City Detail `외교·첩보` primary mode, the reused subtab buttons for `외교` and `첩보` must both be explicitly visible.
- `city_detail_resource_tab_button_placeholder` is reused as `외교` and must set `visible = true` in diplomacy/spy mode.
- `city_detail_internal_trade_tab_button_placeholder` is reused as `첩보` and must set `visible = true` in diplomacy/spy mode.
- `city_detail_external_trade_tab_button_placeholder` remains hidden in diplomacy/spy mode.
- Secondary-tab routing in diplomacy/spy mode is index based: index 0 selects diplomacy content, index 1 selects spy content.
- This hotfix rule does not authorize diplomacy/spy execution, relation mutation, spy rolls, resource spending, turn consumption, resource/trade tab changes, Selected City Panel changes, BattleContext changes, save/load schema changes, `project.godot`, assets, `.uid`, or `.ogv` changes.

## v0.70-28 Diplomacy and Spy Tab Rule
- City Detail `외교·첩보 > 외교` shows only selected city owner, PLAYER relation status, relation score, trade availability, and diplomacy action candidates.
- City Detail `외교·첩보 > 첩보` shows only target city information level, known information scope, spy action candidates, and selected-city-related recent spy result.
- Public support details, city loyalty details, revolt-risk details, troop movement, recruitment, conscription, city storage, resource potential, trade details, supply adjustments, and military-card information do not belong in the diplomacy/spy tab.
- Revolt risk belongs in the Selected City Panel stability area, not in the diplomacy/spy tab.
- Raw internal relation or spy status ids must be converted to Korean UI labels before display.
- Visible UI copy must not use web-version, display-only, placeholder, Godot-facing, debug, or no-effect wording.
- Diplomacy and spy execution behavior is follow-up work; this rule does not authorize action execution, random rolls, turn consumption, resource spending, relation mutation, or save/load schema changes.
- This rule does not authorize changes to resource tab/storage cards, internal trade, external trade, Selected City Panel, recruitment, troop movement, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-27 Selected City Stability and Military Card Rule
- The right Selected City Panel owns city stability and revolt-risk judgment display.
- City Detail internal/external trade tabs must not reintroduce revolt-risk or troop/recruitment decision blocks.
- The Selected City Panel stability area should show:
  1. `성 안정도`
  2. `성 충성도` with a Korean stability label.
  3. `반란 위험` with Korean UI labels such as `낮음`, `주의`, or `위험`.
- Raw revolt-risk ids such as `stable`, `warning`, and `danger` must not be exposed in the Selected City Panel UI.
- The Selected City Panel military area should group `병력`, `방어`, `치안 기준`, `병사 충원`, `징병`, `모병`, and the existing recruitment button together.
- Moving selected-city military/recruitment nodes into a card must preserve existing node references, signals, and button behavior.
- Governor assignment/policy, garrison, hero movement, attack, help, and panel drag flows must remain stable during selected-city layout polish.
- This rule does not authorize changes to revolt-risk formulas, recruitment/conscription formulas, public-support/loyalty formulas, troop movement, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-26 External Trade Tab Rule
- City Detail `무역 > 타국무역` shows trade candidates, relation status, availability, and efficiency between player-owned cities and external-faction cities only.
- Player-owned cities must not appear as external trade targets.
- External trade route candidates must satisfy:
  1. The selected city is player-owned.
  2. The target city is not player-owned.
  3. The target city is a neighbor/connected candidate of the selected city.
  4. The target city has a non-empty owner/faction.
  5. The target city is not the same faction as the selected city.
- If the selected city has no adjacent foreign trade candidate, show an empty state instead of forcing recent trade-result details.
- The external trade tab must not expose public support, city loyalty, loyalty drift, seasonal loyalty, revolt risk, troop movement, recruitment, conscription, military supply judgment, or supply-adjustment details.
- Relation status must be shown in Korean UI labels, not raw ids such as `allied`, `neutral`, `hostile`, or `suspended`.
- Trade availability should be shown as `교역 가능` or `교역 제한`.
- Trade efficiency may use existing relation/trade constants for display, but this rule does not authorize formula changes.
- `재상 위임 / 수동 조정` is a future trade-leadership slot only until a dedicated task connects behavior.
- This rule does not authorize changes to resource tab/storage cards, internal trade, diplomacy/spy, Selected City Panel, troop movement logic, recruitment logic, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-25 Internal Trade Tab Rule
- City Detail `무역 > 자국무역` shows resource/supply flow between player-owned cities only.
- Foreign cities must not appear as internal trade targets.
- Internal trade route candidates must satisfy:
  1. The selected city is player-owned.
  2. The target city is player-owned.
  3. The target city is a neighbor/connected candidate of the selected city.
- If the player owns only one city or the selected city has no connected player-owned neighbor, show an empty state.
- The internal trade tab must not expose public support, loyalty drift, seasonal loyalty, revolt risk, troop movement, recruitment, or conscription information.
- Troop movement and recruitment controls/text do not belong in the internal trade tab.
- Supply role/status must be shown in Korean UI labels, not raw ids such as `hub`, `supplied`, `isolated`, or `unsupplied`.
- Supply adjustment details such as loyalty/security deltas should remain internal and should not be displayed in this tab.
- `재상 위임 / 수동 조정` is a future trade-leadership slot only until a dedicated task connects behavior.
- This rule does not authorize changes to resource tab/storage cards, external trade, diplomacy/spy, Selected City Panel, troop movement logic, recruitment logic, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-24a City Storage Gold Source and Resource Card Rule
- City Detail `자원` tab must not display `city_data.gold` as city-held money.
- Real city-held gold is displayed only from `storage.gold` in the `성 창고` section.
- The upper economy block is `경제 잠재력` and should show population and commerce potential only.
- Storage fallback must distinguish missing storage from explicit saved storage:
  1. Missing `storage` key or non-Dictionary value uses `_build_default_city_storage()`.
  2. Explicit Dictionary storage is normalized and preserved, including all-zero values.
  3. Hanseong missing storage defaults from current national `resource_stock`.
- `성 창고` group display should keep summary and details on separate lines: group total/status first, resource breakdown next.
- `자원 잠재력` and `성 창고` should remain visually separated as cards, while preserving existing City Detail label references, tab buttons, collapse button, and drag handles.
- This rule does not authorize national warehouse changes, national `resource_stock` formula changes, trade, turn production, supply consumption, upkeep, recruitment, battle loot, BattleContext, resource_seed/domestic_seed changes, `project.godot`, assets, `.uid`, or `.ogv` changes.

## v0.70-24 City Storage Resource Tab Rule
- City Detail `자원` tab has two distinct concepts:
  1. Existing star rows are `자원 잠재력` / production potential.
  2. New `storage` data is `성 창고` / current city-held amount.
- Do not conflate city `storage` with national `resource_stock`, city `resource_seed`, or city `domestic_seed`.
- City `storage` keys are `gold`, `rice`, `barley`, `seafood`, `wood`, `iron`, `horses`, `silk`, and `salt`.
- Hanseong default storage follows the current national warehouse/resource stock values at initialization.
- Other city storage should use explicit runtime/loaded values when present; otherwise, use safe zero/default values until a dedicated balancing pass defines real city inventories.
- `성 창고` display may group:
  1. Food: `rice`, `barley`, `seafood`.
  2. Strategy: `wood`, `iron`, `horses`.
  3. Specialty: `silk`, `salt`.
- MVP storage state labels are simple display labels: 300+ `안정`, 100-299 `주의`, below 100 `부족`.
- Save/load should preserve city runtime `storage` when present and must tolerate older saves without `storage`.
- This rule does not authorize national warehouse changes, turn production, trade movement, supply consumption, upkeep, recruitment cost changes, battle loot, BattleContext changes, formula changes, `project.godot`, scenes, or assets.
- Continue the hotfix2 ternary rule: do not add type-risk GDScript ternaries for `Dictionary`, `Array`, `Control`, `Label`, `Button`, `Callable`, `String`, `int`, or `null` branches.

## v0.70-23-hotfix2 GDScript Ternary Sweep Rule
- For WorldMap hotfix work, search all repo `.gd` files with `rg " if .* else " --glob "*.gd"` before assuming only `Dictionary` ternaries are relevant.
- Convert ternaries to explicit `if/else` when branch values are different node/control subclasses, may be `null`, are `Variant`-derived, or require Godot to infer across object/container types.
- Same-type scalar ternaries such as String/String, int/int, float/float, bool/bool, and Color/Color may remain only when headless reload is clean and no concrete warning line points to them.
- Do not use a reload-warning sweep to change UI content, help copy, city detail/trade/diplomacy/spy structure, calculations, save/load, BattleContext, `project.godot`, scenes, or assets.
- If headless project/scene load is clean but the open Godot editor still reports an older ternary compatibility warning, restart the editor before deleting cache or changing repo-external files.

## v0.70-23-hotfix1 City Detail Drag and Reload Warning Rule
- CityDetailPanel must remain draggable in both expanded and collapsed states.
- Expanded drag should use a visible top non-button area such as `city_detail_header_row`; collapsed drag may continue through the collapsed heading label.
- Do not register `CollapseButtonPlaceholder`, primary tab buttons, diplomacy/trade/resource tab buttons, or resource/trade secondary buttons directly as drag handles.
- Button clicks must continue to win on the buttons themselves; panel drag should start from non-button top-row space or visible label/header regions.
- Collapsed click-to-expand must preserve the existing `_collapsed_unified_panel_click_candidate` flow: drag after threshold moves the panel, click-only expands it.
- `_move_hud_panel_to_screen_position()` clamp behavior remains the WorldMap HUD drag boundary contract.
- GDScript functions in WorldMap UI scripts must not use local parameters named `visible`; use names such as `should_show` or `is_visible` instead.
- Type-unclear GDScript ternaries that can mix `Dictionary`, `Array`, `Control`, `Button`, `Label`, `Callable`, `String`, `int`, or `null` should be written as explicit `if/else` with `Variant` type checks.
- This hotfix rule must not change City Detail resource content, trade/diplomacy/spy structure, help copy, recruitment, governor/chancellor formulas, city data values, battle scenes, BattleContext, save/load schema, `project.godot`, or assets.

## v0.70-23 City Detail Resource Tab Slim Rule
- City Detail resource tab is a deep-view panel for city resource and economy potential, not a duplicate of the Selected City Panel.
- Resource tab should show city name, `식량 자원`, `전략 자원`, `특산 자원`, and `경제` only at this stage.
- Gold belongs in the economy block with population and commerce, not in the resource category block.
- Do not show duplicated Selected City data in the resource tab: type, faction/region ownership, city loyalty, troops, security baseline, defense, status, governor, stationed hero count, or selected-city action state.
- Keep category labels visually distinguishable from resource names, while preserving the existing dark panel / gold accent WorldMap tone.
- Unified panel primary tabs should stay conceptually split as `도시 상세`, `외교·첩보`, and `무역`; `자국무역` / `타국무역` belong under the trade family.
- City tech-tree UI, research start, and agriculture/commerce/military/special/trade expansion remain deferred until a dedicated tech-tree task.
- This polish must not change city data values, resource seeds, domestic formulas, governor/chancellor formulas, trade/diplomacy/spy calculations, battle scenes, BattleContext, save/load schema, `project.godot`, or assets.
- Preserve the existing help modal MVP, recruitment, governor assignment/policy, attack, panel drag, and battle handoff flows.

## v0.70-22 Implemented Help Modal Rule
- WorldMap help UI must describe only currently implemented behavior.
- Help buttons may be small `?` controls near important values, but must not move or rename existing stable Label/Button/OptionButton paths.
- The reusable help modal belongs under `WorldMapUI` so camera pan/zoom does not affect it.
- Help content must not expose formulas, multipliers, or internal calculation steps.
- 국가충성도 help is limited to tax burden, political chancellor loss management, and stable domestic operation.
- 성 충성도 help is limited to tax, security, supply, political governor/chancellor support, and publicSupport stability.
- 민심 help is limited to tax, food, commerce, and supply.
- 치안 help is limited to stationed troops, supply, minimum garrison, and invasion/battle readiness.
- 주둔무장 help is limited to implemented usage: governor candidates, battle deployment, city defense, and governor command-limit contribution.
- Do not describe hero personal loyalty increase actions unless a real player-facing implementation exists and has been verified in code.
- Help work must not change domestic formulas, tax formulas, governor/chancellor formulas, battle scenes, BattleContext, save/load schema, `project.godot`, or assets.

## v0.70-21 Recruitment Loyalty-Based Rule
- 모병 amount limit is based on selected city loyalty, not publicSupport.
- Loyalty thresholds are fixed for this patch: below 40 -> 0, 40-59 -> 100, 60-79 -> 200, 80-89 -> 300, and 90+ -> 500.
- `_can_recruit_troops(city_id, amount)` must keep ownership, amount, peacetime, and national resource affordability checks, then enforce the loyalty-based limit.
- Recruitment cost remains gold = amount and food = floor(amount / 2). Food is paid from national `resource_stock` in rice -> barley -> seafood order.
- `_recruit_troops()` must continue to increase city runtime troops, deduct resources, record `last_recruitment_result`, and refresh city HUD bindings. The result should include `loyalty` and `loyalty_limit`; publicSupport may remain compatibility/future-risk data but must not drive the amount limit.
- 징병 is the automatic loyalty + `barracks` + `conscription_system` axis. `barracks` remains required for automatic turn conscription, and `conscription_system` keeps the existing 1.10 effect.
- 모병 is the immediate loyalty + resources + peacetime axis. It is not tech-locked in this patch.
- The right Selected City Panel should show only decision-grade summaries in `병사 충원`: one conscription status line, one recruitment summary line, and `모병 100` or disabled `모병 불가`.
- Do not expose detailed formulas, multipliers, or internal calculation steps in the selected-city UI.
- publicSupport remains reserved for future recruitment fatigue, dissatisfaction, and revolt-risk work. This patch must not implement population loss, recruitment fatigue, post-recruitment publicSupport/loyalty loss, or revolt-risk changes.

## v0.70-20a Selected City Panel Layout Order Rule
- The selected-city panel should present information in this order: city name, faction, type, city loyalty, `민심 / 치안 / 상업 / 농업`, governor card, garrison card, hero transfer button/panel, `병력 / 방어 / 치안 기준`, and recruit button.
- The city state summary (`민심 / 치안 / 상업 / 농업`) belongs directly under the loyalty card and should remain a compact decision summary, not a debug/formula display.
- Governor effect/policy copy belongs inside the governor card as `효과: ...` and `정책: ...`. Do not reintroduce a lower duplicate `태수 정책: 효과: ...` hint.
- The `주둔 무장` display should remain card-bounded and show compact portrait/name/stat rows using the existing portrait helper path.
- `무장 이동` belongs near the garrison section and must keep the existing v0.70-20 inline transfer contract.
- The selected-city `내정` button is hidden until City Detail / Domestic Panel work defines its real UX.
- v0.70-21 supersedes the old recruit placeholder: the area below the military summary is now `병사 충원` with compact conscription status and connected `모병 100`.
- Do not change governor assignment logic, governor policy persistence, hero transfer data movement, battle entry, BattleContext, domestic/chancellor/governor formulas, `project.godot`, `.uid` / `.ogv`, or assets as part of this layout rule.

## v0.70-20 Selected City Governor, Garrison, and Hero Transfer Rule
- The selected-city governor card should show a visible `태수` section title above portrait/name/stats, `GovernorAssignOption`, `GovernorPolicyOption`, and policy effect copy.
- `GovernorAssignOption` and `GovernorPolicyOption` remain the stable governor assignment/policy controls and must not be repurposed for hero transfer.
- The selected-city garrison section title is `주둔 무장`; garrison display should use compact portrait/name/stat rows and reuse `WorldMapHeroPortraitHelper`.
- Hero state badges such as `[부상]`, `[포로]`, and `[사망]` remain display helpers and should not trigger new release/exclusion rules in this polish.
- `무장 이동` MVP may move heroes only from the selected source city to adjacent player-owned cities.
- Transfer confirmation updates source and target `stationed_hero_ids` / `hero_ids`, updates the moved hero runtime city, and refreshes selected-city UI.
- If the moved hero was the source governor, source `governor_id` is cleared. Do not auto-assign the moved hero as target governor.
- Existing save/load coverage for city rosters and hero runtime city state is the persistence contract for this MVP.
- Do not implement global governor exclusivity, wounded/captured/dead governor release, hero-state redesign, domestic/trade/relation formula changes, battle entry changes, BattleContext changes, or asset changes as part of this rule.

## v0.70-19a Domestic UI Philosophy and Handoff Rule
- Current stable baseline is `v0.70-19 WorldMap Selected City Governor Assignment & Policy Connect` at `4c671b0e7599ade817d1274768f04b879a757ca4`.
- 삼국워 내정 시스템은 내부적으로 복잡하게 돌아가야 하지만, WorldMap UI should expose only the key information needed for player decisions.
- Do not expose every formula, multiplier, or intermediate number in left/right panels. Keep detailed calculations internal unless a task explicitly asks for audit/debug display.
- Chancellor policy and governor policy are separate contracts:
  1. Chancellor policy is national operating direction, national income/upkeep, and country-level operation modifiers.
  2. Governor policy is selected-city operating direction, city yield, recruitment, and loyalty-flow modifiers.
- UI copy should prefer policy name plus short effect summary. Avoid returning to developer copy such as `재상 정책 수행`, `Godot에서는 표시 전용`, `placeholder`, or no-effect debug messages.
- Do not delete `.uid` / `.ogv` files, do not use `git clean`, and confirm any `WorldMap_Test.tscn` serialization diff before starting feature work.
- Next WorldMap panel work should begin with `v0.70-20 WorldMap Selected City Panel Troop Stats Polish`, then city-detail polish, battle-entry camera handoff, and governor exclusivity/hero-state rules.

## v0.70-19 Selected City Governor Assignment and Policy Connect Rule
- `CityInfoPanel` may expose a governor assignment dropdown, but candidates are limited to the selected city's current `stationed_hero_ids` plus `미임명`.
- Governor assignment changes only the selected city's mutable runtime `governor_id`. It must not move heroes, mutate `stationed_hero_ids`, or enforce global duplicate-governor rules until a dedicated task defines those rules.
- `GovernorPolicyOption` remains the selected-city governor policy selector and updates `_city_policy_state[city_id]`.
- Save/load must preserve city `governor_id`, city `governor_policy_id`, and top-level `city_policy_state`, while older saves fall back to seed city data/default policy.
- Selected-city governor policy copy must not expose `재상 정책 수행`, `Godot에서는 표시 전용`, placeholder/no-effect wording, or "No city stat or turn effect applied".
- This connection work must not change governor effect formulas, chancellor/tax formulas, domestic/trade/relation formulas, turn-income/security calculations, hero movement, wounded/captured/dead coupling, city ownership/troop/resource calculations, battle entry, `BattleContext`, or battle scenes.

## v0.70-18 Selected City Panel Anchor and Summary Slim Rule
- `CityInfoPanel` must remain a direct `WorldMapUI` CanvasLayer child so it is independent from `WorldMapCamera` pan/zoom and battle-entry camera handoff motion.
- The selected-city panel startup position is right-side fixed at the shared `WORLD_UI_TOP_MARGIN = 10.0` and a 10px right margin for the current viewport baseline.
- Existing selected-city panel drag behavior must remain available through the visible city name handle after startup.
- The selected-city panel top summary should stay slim: city name, `세력: ...`, `유형: ...`, and the city loyalty card.
- Do not reintroduce the visible `SELECTED CITY` eyebrow, owner/region/nation duplicate rows, city resource list, city status sentence, or governor summary label unless a later UX task explicitly asks for them.
- Governor card/dropdown, garrison list, military/domestic summary, policy hint, and selected-city action buttons remain in the selected-city panel contract.
- This polish must not change left panel behavior, city detail/diplomacy panels, city data, city click, battle entry, camera handoff, safe-zone camera, domestic/trade/relation formulas, governor internals, resource data, save/load, or battle scenes.

## v0.70-16 Left Panel Chancellor Card Rule
- The current left WorldMap status panel anchor is top-left `(10, 10)` with size/minimum size `320 x 570`.
- Keep `WORLD_UI_TOP_MARGIN = 10.0` and `WORLD_UI_LEFT_MARGIN = 10.0` unless a later panel-baseline task changes both deliberately.
- Right-side fixed panels keep their own existing X positions; chancellor-card polish must not move `DiplomacySpyPanel`, `CityDetailPanel`, or `CityInfoPanel`.
- Chancellor card unassigned display should stay compact: `미임명`, dropdowns, `효과: 없음`, and `정책: 보정 없음`. Do not reintroduce repeated `재상 없음` / `재상 임명: 미임명` copy.
- Chancellor card assigned display should show the chancellor name once in the summary area, then primary/secondary aptitude lines. Do not repeat `재상 임명: 이름` or `효과: 이름: ...` in descriptive copy.
- Chancellor policy/effect labels are display-only polish. Do not change chancellor effect calculations, policy data, dropdown behavior, tax formulas, save/load structure, city data, battle entry, or BattleContext as part of this rule.
- Chancellor portrait frame currently uses `56 x 64`, clipped, aspect-covered display for the runtime texture and the same frame for the `?` placeholder.

## v0.70-15 Left Panel Header and Tax Slim Rule
- The current fixed WorldMap information panels share one top baseline: `WORLD_UI_TOP_MARGIN = 10.0`.
- `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` must remain direct `WorldMapUI` CanvasLayer children and screen-fixed during camera pan/zoom, mouse drag pan, wheel zoom, and battle-entry camera handoff.
- Superseded by v0.70-16 for the left-panel X margin: `LeftWorldStatusPanel` runtime anchor is top-left `(10, 10)` with size/minimum size `320 x 570` for the current 1920x1080 viewport baseline.
- The left panel top header is intentionally slim: only the runtime `CalendarLabel` line such as `154년 봄 1턴` should be visible. `EyebrowLabel`, `TurnLabel`, and `NationLabel` may remain as hidden nodes to preserve existing node paths.
- The left panel tax card should show one national loyalty label/bar and one tax level label/slider. Do not reintroduce the long tax preview sentence, duplicate tax bar, or duplicate public-order bar unless a later UX task explicitly asks for it.
- This polish must not change city data, city click behavior, battle entry, BattleContext, domestic/trade/relation formulas, chancellor formulas, tax internal calculations, save/load structure, or battle scenes.

## v0.70-14a Fixed Panel Top Margin Baseline Rule
- Superseded by v0.70-15: the current fixed WorldMap information panels share `WORLD_UI_TOP_MARGIN = 10.0`; the prior v0.70-14a value was `16.0`.
- `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` must remain direct `WorldMapUI` CanvasLayer children unless a later task explicitly changes the HUD root contract.
- These panels should stay screen-fixed during `WorldMapCamera` pan/zoom, mouse drag pan, wheel zoom, and battle-entry camera handoff.
- Initial scene offsets should preserve each panel's X position, width, height, content order, and web-parity information structure while using the current shared top baseline.
- The retired `WorldMapUI/TitleLabel` / `SamWar HUD MVP` debug label should stay hidden unless a future debug task deliberately re-enables it in a non-overlapping position.
- Do not use this top-margin baseline work to redesign the left panel, right panel, city detail panel, diplomacy panel, city click behavior, battle entry, domestic/trade/relation formulas, or BattleContext.

## v0.70-14 Left Panel Anchor & World Turn Lock Rule
- `LeftWorldStatusPanel` must remain a `WorldMapUI` CanvasLayer child so it is independent from `WorldMapCamera` pan/zoom and battle-entry camera handoff motion.
- The left panel is intentionally fixed to the screen top-left. It should not be registered as a draggable HUD panel unless a later task explicitly reintroduces a lock/unlock UX.
- Superseded by v0.70-15: the stable runtime anchor is top-left `(18, 10)` with size/minimum size `320 x 570` for the current 1920x1080 viewport baseline.
- The World Turn header block node paths should stay at the top of the left panel content, but v0.70-15 intentionally makes only `CalendarLabel` visible in that block.
- Runtime cards such as pending invasion, post-battle result, save management, warehouse, and status hints must be inserted below the World Turn header block.
- Left-panel anchor work must not change worldmap camera logic, city marker/click behavior, battle entry, BattleContext, domestic/trade/relation formulas, right-panel structure, or battle scenes.

## v0.70-14 Battle Entry Camera Handoff Rule
- WorldMap battle-entry camera handoff must remain a wrapper around the existing final transition boundary, not a replacement for BattleContext creation or result handling.
- Player attack and enemy invasion defense must continue to build/validate context and run existing troop pre-decrement before `_handoff_battle_context_to_battle_scene()`.
- City focus lookup should use `_city_markers_by_id` and scene-authored `WorldMapCityMarker.global_position` first; if visual coordinates are missing, skip the camera handoff and call the existing transition immediately.
- Handoff may tween `world_map_camera.position` and `world_map_camera.zoom`, but must use existing world-rect clamp behavior and must not change `WorldMap_Test.tscn` camera ownership unless a future scene patch explicitly requires it.
- `_worldmap_battle_entry_handoff_in_progress` is the duplicate-entry guard for attack buttons, defense buttons, deployment confirmation, final handoff, and camera input while the tween is active.
- Skip input is valid only during handoff and must complete through the same one-shot path as natural tween completion.
- Do not add default city ids, new BattleContext keys, city ownership changes, troop-result changes, hero-state changes, battle intro changes, or result-video changes as part of the camera handoff.

## v0.70-13c Battle WorldMap Return Contract Rule
- WorldMap -> Battle handoff currently uses `Engine` meta key `samwar_worldmap_battle_context`; Battle -> WorldMap return currently uses `samwar_worldmap_battle_result`.
- The battle scene path for WorldMap handoff is `res://Battle_Fullscreen_Test.tscn`; the battle return scene path is `res://WorldMap_Test.tscn`.
- Player attack context must continue to identify itself with `source: "player_attack"` and `type: "attack"`.
- Enemy invasion defense context must continue to identify itself with `source: "enemy_invasion"` and `type: "defense"`.
- Side-specific city and troop keys are the active contract: `attacker_city_id`, `defender_city_id`, `attacker_source_city_id`, `defender_source_city_id`, `attacker_troop_allocation`, `defender_troop_allocation`, `attacker_total_allocated_troops`, `defender_total_allocated_troops`, and side-specific source-city troop before/after keys.
- Result payload currently uses `result` plus `winner`, not separate `battle_result`, `winner_side`, or `loser_side` keys. WorldMap normalizers accept several aliases, but Battle emits the documented keys only.
- Result troop accounting currently travels through `player_troop_outcome` and `enemy_troop_outcome` dictionaries with `source_city_id`, `allocated`, `survivors`, `losses`, `wounded`, `dead`, `allocations`, and `survivor_allocations`.
- There is no explicit payload-level `result_applied` flag. One-shot behavior currently relies on immediate Engine meta removal and existing pending context/event cleanup.
- Do not introduce generic city/troop aliases or default city ids unless a later migration explicitly updates both Battle and WorldMap consumers.
- v0.70-14 camera handoff work should use existing city marker lookup and camera helpers before the final scene handoff, while preserving the current Engine meta boundary.

## v0.68b-12b-31 Troop Accounting Parity Rule
- Both sides' allocated troops must be subtracted from their source city garrison before battle handoff.
- Player attack: attacker allocation is subtracted from the player source city; defender allocation is subtracted from the enemy target city.
- Enemy invasion defense: attacker allocation is subtracted from the enemy attacker city; defender allocation is subtracted from the player defender city.
- Result application must add only survivor troops and woundedQueue entries back to the appropriate post-battle city. Pre-deployed troops must not also remain in the source garrison.
- Defense victory returns player survivors/wounded to the defended city and enemy wounded to attacker city woundedQueue.
- Defense defeat sends enemy survivors/wounded to the captured city and player wounded to the nearest player-owned neighbor; no-retreat wounded are logged as lost in this MVP.

## v0.68b-12b-30 Web Parity Gap Audit Rule
- Current P0 parity target is troop accounting consistency across both player attack and enemy invasion defense.
- Player attack must next subtract defender allocated troops from the defender city before battle start, matching the web enemy-side pre-decrement rule.
- Enemy invasion defense must next use allocated troop outcomes, woundedQueue, and retreat-city wounded return instead of the older bounded casualty MVP.
- CommandRank/commandLimit allocation clamp is required for web parity but is P1 behind troop-accounting correctness.
- Hero recruit/conversion on captured cities remains deferred until prisoner/recruit policy is explicitly defined.

## v0.68b-12b-29A Web-Parity Troop Allocation Rule
- Player attack deployment confirmation subtracts total allocated sortie troops from the source city immediately; source city must still keep at least one garrison troop.
- BattleContext must preserve `attacker_troop_allocation`, `attacker_total_allocated_troops`, `attacker_source_city_id`, and source-city before/after troop values.
- Battle units may store `allocated_troops` and `initial_allocated_troops`, but troop count must not scale HP, attack, defense, unit size, or animation in this patch.
- Survivor calculation uses `floor(initialAllocatedTroops * clamp(hp / maxHp, 0, 1))` for alive winning units. Defeated side survivors are forced to `0` for player attack outcome accounting.
- Player attack victory formula: survivors = min(allocated, raw survivors), losses = allocated - survivors, wounded = floor(losses * 0.30), dead = allocated - survivors - wounded.
- Player attack defeat formula: survivors = 0, wounded = floor(allocated * 0.50), dead = allocated - wounded.
- Troop `woundedQueue` is city-level soldier recovery data, not hero wound state. Entry shape is `{ "turnsLeft": 3, "troops": wounded_troops }`.
- WorldMap strategy turn advance reduces woundedQueue `turnsLeft`; entries at `0` recover into city garrison and are removed.
- Player attack victory puts survivors in the occupied target city and queues wounded troops there. Player attack defeat queues wounded troops at the source city and does not immediately return survivors.
- Captured/dead hero exclusion and wounded hero battle penalties remain separate systems.

## v0.68b-12b-28 Player Attack Deployment UX Rule
- Deployment panel must show source city, target city, source troops, total assigned troops, remaining garrison, and food/rice, gold, and salt supply status.
- Confirm must be blocked and explained when no hero is selected, selected troops are zero, assigned troops exceed source city troops, source city would fall below one troop, or food/gold/salt is insufficient.
- Supply status text should show `충분` or `부족` per resource. The formula remains food/rice = troops, gold = ceil(troops * 0.2), salt = ceil(troops * 0.1).
- Sortie confirmation should provide immediate WorldMap feedback with source/target, assigned troops, and supply consumption.
- Player attack result card copy should distinguish occupation success from attack failure. Owner/troop application logic remains unchanged.
- F6 manual QA is required for panel readability and click flow because headless validation cannot exercise SpinBox and button interaction.

## v0.68b-12b-26 Player City Attack MVP Rule
- Player attack is allowed only against enemy-owned target cities that are directly adjacent to at least one player-owned city.
- Source city resolution uses the current valid player origin city first; otherwise it uses the first player-owned neighbor of the target city.
- WorldMap must block player attack during pending enemy invasion/event handling or non-player turn state.
- Player attack BattleContext uses `source: player_attack` and `type: attack`; attacker is the player source city and defender is the enemy target city.
- Captured/dead heroes remain battle-ineligible; wounded heroes remain battle-eligible and keep their existing battle penalties.
- Player victory occupies the target city for `player`; player defeat keeps the target owner unchanged.
- MVP excludes deployment selection, troop allocation UI, sea/route-type attacks, 2-hop attacks, marching/supply costs, siege-specific UI, AI counterattack, and enemy hero recruitment.

## v0.68b-12b-26 Wounded Recovery Turn Rule
- Wounded recovery is based on WorldMap strategy turns only.
- Default MVP wound duration is 3 WorldMap turns via `wounded_turns_remaining`.
- Battle rounds, auto-battle turns, and battle-scene timers must not reduce wounded recovery turns.
- When `wounded_turns_remaining` reaches `0`, the hero returns to normal state and loses wounded battle penalties.
- Captured/dead heroes are not recovery targets and keep wound recovery turns at `0`.
- UI may display `[부상 N턴]`; treatment buildings, recovery items, and ability-based recovery duration are out of scope.

## v0.68b-12b-25 Wounded Battle Penalty Rule
- Wounded heroes remain eligible for BattleContext rosters and battle deployment.
- Wounded markers should remain visible in existing roster labels as `[부상]`.
- Battle MVP penalties are attack damage `75%`, defense represented by incoming damage `120%`, and unique-skill numeric effects `70%`.
- Captured/dead heroes remain battle-ineligible under the v24 exclusion rule.
- Wound recovery, treatment UI, prisoner systems, death handling, and refined stat-based wounded penalties are still out of scope.

## v0.68b-12b-24 Captured Hero Battle Exclusion Rule
- Captured heroes remain in city `stationed_hero_ids` / `hero_ids` and must still be visible in WorldMap city information with `[포로]`.
- BattleContext roster generation must exclude heroes with `captured == true` or `status == "captured"`.
- `dead == true` or `status == "dead"` is also treated as battle-ineligible as a safety guard, although death is not currently applied by gameplay.
- Wounded heroes are not excluded in this MVP.
- The exclusion applies to main attacker/defender rosters and nearby reinforcement/support candidates; missing eligible heroes must not be force-filled from sample rosters.

## v0.68b-12b-23 Hero State Visual Badge Rule
- WorldMap UI may display runtime hero state markers in existing text labels without creating new prisoner or wound systems.
- Display priority is `dead` -> `captured` -> `wounded` -> normal.
- Marker text is `[사망]`, `[포로]`, `[부상]`, or empty for normal heroes.
- WorldMap selected-city hero lists should read merged runtime hero state, not seed-only `HERO_DATA`.
- Captured heroes remain visible in city rosters and may still enter battles until a dedicated captured-hero exclusion patch exists.

## v0.68b-12b-22 Hero Status Placeholder Rule
- Invasion battle result may apply placeholder hero status only to the losing side.
- MVP rule is deterministic and temporary: first eligible losing hero becomes wounded; second eligible losing hero becomes captured; dead is not used.
- Captured heroes remain in city `stationed_hero_ids` / `hero_ids` until a dedicated prisoner movement system exists.
- Hero status changes must use `_hero_runtime_states` and `worldmap_hero_state`, not seed `HERO_DATA` mutation.
- Post-battle result summary may show the placeholder hero state line, but no prison, recruitment, execution, recovery, death, or stat-based roll system exists yet.

## v0.68b-12b-21 Post-Battle Result Summary Rule
- WorldMap invasion battle return should present an immediate display-only result summary after applying owner/troop changes.
- Defender win, attacker win/city fall, retreat, and unknown results should have separate readable copy.
- The summary may show ownership change/retention, defender city troop change, attacker source-city troop change, and occupation troops.
- Result summary UI state is not save/load data; persistence remains limited to actual runtime city/hero state.
- Do not add prisoner/wound/death, resource loot, detailed combat statistics, or full report UI until dedicated patches.

## v0.68b-12b-20 Invasion Casualty / Hero State Rule
- Invasion result troop changes must be applied to mutable runtime city state, not seed city dictionaries.
- Defender victory preserves ownership, applies bounded defender city losses, and applies heavier attacker source-city losses.
- Attacker victory transfers ownership and applies occupation troops from attacker survivor/fallback values while reducing the attacker source city.
- All invasion troop values must be integer-normalized and clamped to safe nonnegative bounds; current loss rates are MVP placeholders, not final balance.
- Hero runtime state may persist future status fields (`status`, `wounded`, `captured`, `dead`), but this patch does not execute actual wound/capture/death outcomes.

## v0.68b-12b-19 Battle Result Persistence Rule
- WorldMap battle-result changes must persist as runtime overrides, not seed mutations.
- Save payload uses `worldmap_city_state` for city owner/nation/owner_faction_id, troops, and stationed hero ids, and `worldmap_hero_state` for hero current city ids.
- Load order is seed data first, then runtime override merge into mutable state, then city marker/UI refresh.
- Resolved pending invasion event/context must be cleared in save/load so an already resolved invasion does not reappear.
- This MVP does not persist wounds, capture, death, resource looting, precise casualty math, AI strategy recalculation, or multi-invasion queues.

## v0.68b-12b-18b Formation Panel Context Source Guard
- WorldMap enemy-invasion formation/roster panels must use the same BattleContext roster source as battlefield slots.
- Empty or inactive context support slots are valid and must remain hidden/disabled in the side panels; they must not display sample `TEST_BATTLE_ROSTER` heroes.
- Direct `Battle_Fullscreen_Test.tscn` sample fallback remains test-only and does not apply to normal WorldMap invasion panels.
- The same-faction/ally plus 1-hop/2-hop reinforcement source rule remains unchanged.

## v0.68b-12b-18a Invasion Context Fallback Guard
- WorldMap `enemy_invasion` BattleContext slots must not use sample `TEST_BATTLE_ROSTER` fallback when requested hero ids are missing.
- Missing nearby support is valid: leave the context slot inactive/hidden rather than pulling distant or sample heroes.
- Direct battle sample fallback remains a battle-scene test path only, not a normal WorldMap invasion reinforcement source.
- The 1-hop/2-hop same-faction/ally reinforcement rule from `v0.68b-12b-18` remains unchanged.

## Role
- Defines the future SamWar worldmap system contract.
- Owns region, city, route, connection, encounter, and battle launch context decisions.
- Produces `BattleContext` for the battle engine.

## Current Canvas Foundation
- `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control` makes scene-authored Tile node positions the source of truth for worldmap tile layout.
- Runtime must not overwrite the four Tile node positions during `_ready()`.
- Runtime camera clamp should read the union of the current tile Sprite2D world rects, not a hardcoded 2x2 layout.
- Kimjak can manually adjust `Tile_A1_TopLeft`, `Tile_A2_TopRight`, `Tile_B1_BottomLeft`, and `Tile_B2_BottomRight` in the Godot 2D editor and save the scene.
- `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix` updates the scene-authored four-tile layout so the Godot 2D editor shows one contiguous map for manual city placement.
- The current editor-visible tile positions are A1 `(0, 0)`, A2 `(512, 0)`, B1 `(0, 512)`, and B2 `(512, 512)`, with `Sprite2D.centered = false`.
- Runtime tile configuration must match the scene-authored layout result and must not hide a broken editor layout.
- `v0.68b-1 WorldMap Four-Tile Canvas Foundation` adds `WorldMap_Test.tscn` as the current visual worldmap canvas foundation.
- The four prepared tiles under `assets/worldmap/tiles/` are arranged as NW, NE, SW, and SE Sprite2D nodes with `centered = false`.
- `scripts/worldmap_test.gd` uses the A1 tile texture size to place A2 at `(tile_width, 0)`, B1 at `(0, tile_height)`, and B2 at `(tile_width, tile_height)`.
- `WorldMapCamera` is the scene-authored Camera2D foundation for large-map pan and zoom, clamped to the combined 2x2 world rect.
- `RouteLayer` is now populated by the route foundation described below; `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` remain prepared worldmap layers.
- City marker click and route visualization exist, but route click, city data runtime systems, army movement, battle entry, and `BattleContext` creation remain forbidden until their dedicated tasks.

## Current City Marker Foundation
- `v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat` is a docs-only bridge into `v0.68b-12b-1 WorldMap Hero City Seed Data Import`.
- Next new chat handoff: 새 채팅에서는 먼저 agent 문서를 순차 읽고, 현재 기준선을 확인한 뒤 `v0.68b-12b-1 WorldMap Hero City Seed Data Import`를 진행한다. 이 작업은 웹버전 hero/city/battle_rosters 데이터를 Godot seed data로 가져오는 작업이며, 실제 기능 실행이 아니라 데이터 기준선 정렬 작업이다.
- `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit` established the next seed import source map.
- Web `heroes.js` is an array structure with hero fields including `id`, `name`, `factionId`, `side`, `role`, `stats`, `portraitImage`, `battlefieldPortraitImage`, and `chancellorProfile`.
- Web `cities.js` contains city fields including `id`, `name`, `region`, `ownerFactionId`, `neighbors`, `routeTypes`, `governorHeroId`, `cityLoyalty`, `resources`, `military`, `domestic`, and `yields`.
- Web `battle_rosters.js` `cityDefenderRosters` is the key source for city stationed hero seed data.
- Web chancellor initial state is `app_state.createInitialDomesticPolicy()` `chancellorHeroId: null`.
- Web chancellor candidates from `getEligibleChancellorHeroes()` are active heroes where `hero.side === playerFactionId`.
- Web governor candidates are selected-city stationed heroes where `hero.side === playerFactionId` and `hero.locationCityId === selectedCity.id`.
- Current Godot worldmap seed data lives in `scripts/worldmap_test.gd` through `HERO_DATA`, `CITY_HUD_DATA`, `CHANCELLOR_POLICY_DATA`, `GOVERNOR_POLICY_DATA`, and `_player_state`.
- Current Godot `_player_state.chancellor_id` has been fixed to `"jeong_do_jeon"`. The import task must explicitly decide whether to set the default back to null/empty for web parity; prefer no chancellor / no chancellor effect unless blocked.
- Current Godot seed data is display-only string-oriented data, not the full web numeric/stat object model.
- `v0.68b-12b-1 WorldMap Hero City Seed Data Import` should align only Godot seed data with web `heroes.js`, `cities.js`, and `battle_rosters.js`: map `cityDefenderRosters` into `CITY_HUD_DATA.stationed_hero_ids`, `governorHeroId` into `CITY_HUD_DATA.governor_id`, city loyalty/resources/military/population/rating-like fields into display seed data where possible, and hero identity/faction/side/role/stats/portrait/chancellor profile fields into `HERO_DATA`.
- `v0.68b-12b-1` must not implement actual hero movement, governor/chancellor appointment logic, policy effects, resource/troop/turn mutation, `BattleContext`, battle scene transition, route/pathfinding changes, scene layout changes, castle icon reactivation, or repo-outside `SamWar_web` edits.
- `v0.68b-12b Left World HUD Web Content Parity` tightens only the Godot left main `LeftWorldStatusPanel` against the actual web `world_hud_ui.js` / `resource_ui.js` output.
- The left HUD content order should follow the web `renderWorldHud()` flow: `World Turn`, turn number, calendar, turn owner, `국가충성도`, `세금 수준`, `재상`, `재상 임명`, `재상 정책`, `보유 자원`, `국가 창고`, `내부 보급망`, `내부 병력 재배치`, `대외 무역`, income/policy/tax summary, turn/save controls.
- `renderChancellorCard()` parity means the Godot chancellor card keeps a portrait slot/fallback and shows the chancellor name plus web `주`/`보조` chancellor type lines; it must not invent non-web chancellor categories.
- `renderChancellorPolicyControl()` parity means chancellor policies remain `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`, with web descriptions and description-only selection behavior.
- Left HUD resource/supply/trade copy may use display-only fallback values when Godot lacks web `lastIncomeResult`, `lastUpkeepResult`, `lastSupplyNetworkResult`, `lastTroopRebalanceResult`, or `lastInterFactionTradeResult`.
- `v0.68b-12b` must not execute turn processing, tax changes, resource mutation, upkeep, policy effects, save/load/reset, domestic execution, diplomacy/spy actions, battle entry, `BattleContext`, hero transfer, army movement, pathfinding, route mutation, sea arrow changes, or AI.
- `v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch` tightens the unified panel UX after `v0.68b-12`.
- Expanded unified panel headers should use the primary tab buttons directly: `도시 상세` and `외교·첩보`, with no duplicate Korean title beside them.
- Collapsed unified panel text is `도시상세 / 외교·첩보 열기`.
- Collapsed unified panel headers are draggable independently at runtime; short click opens the panel and drag moves only the unified panel.
- Unified panel height should shrink toward its visible content and avoid excessive empty lower space, while still remaining screen-clamped.
- `외교` / `첩보` content should follow the web `diplomacy_spy_ui.js` display structure: `외교 현황`, `외교 행동`, `첩보 가시성`, and `첩보 행동`.
- Diplomacy action copy may show `사절 교환`, `교섭 요청`, and `교역 압박`; spy action copy may show `정탐`, `유언비어`, and `내통 시도`.
- These diplomacy/spy entries remain display-only. They must not execute diplomacy, spy, relation, resource, turn, save/load, battle, army, hero transfer, pathfinding, route, or AI logic.
- `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP` consolidates the former separate `CityDetailPanel` and `DiplomacySpyPanel` surfaces into one `CityDetailPanel`-backed unified HUD panel.
- Unified panel primary tabs are `도시 상세` and `외교·첩보`.
- In `도시 상세` mode, the secondary tabs must remain the web-source city detail tabs: `자원`, `자국무역`, and `타국무역`.
- In `외교·첩보` mode, the secondary tabs are `외교` and `첩보`, and they may update display-only placeholder copy only.
- The standalone `DiplomacySpyPanel` is hidden at runtime and should not occupy separate worldmap HUD space while this unified panel MVP is active.
- Unified panel collapse/expand is runtime-only and must not create save files, user config, localStorage, or project setting changes.
- `CityInfoPanel` / selected-city panel remains independent from the unified panel and should keep its own independent drag behavior.
- The unified panel must not execute domestic effects, diplomacy/spy effects, resource changes, turn processing, save/load, recruitment, hero transfer, army movement, battle entry, `BattleContext`, pathfinding, route changes, or AI.
- `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP` removes the retired top `SamWar Web` banner and old `도시 HUD 위치 이동 · Godot MVP fixed` dragbar from the active runtime HUD.
- The web grouped `city-hud-stack` drag UX is reference-only. Godot worldmap HUD panels should move independently instead of dragging the whole right HUD group together.
- Current independent draggable panels are `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel`; drag starts only from title/header labels.
- Panel positions are runtime-only and must not be persisted to save files, user config, localStorage, or project settings in this phase.
- Button, tab, and `OptionButton` inputs must remain usable and must not be treated as drag handles.
- Draggable HUD behavior must stay CanvasLayer/screen-space and must not affect worldmap camera pan/zoom, city marker positions, route curves, sea arrow flow, battle entry, domestic execution, or `BattleContext`.
- `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP` realigns the Godot worldmap HUD with actual `SamWar_web` source structure instead of adding arbitrary domestic UI.
- Web parity references include `world_hud_ui.js`, `selected_city_ui.js`, `resource_ui.js`, `diplomacy_spy_ui.js`, `world_map_ui.js`, `ui_render.js`, `governor_ui.js`, `garrison_ui.js`, `military_ui.js`, `constants.js`, `app_state.js`, `world_rules.js`, `data/cities.js`, `data/heroes.js`, `data/battle_rosters.js`, `css/main.css`, and `index.html`.
- `CityDetailPanel` should follow the web `resource_ui.js` tabs: `자원`, `자국무역`, and `타국무역`. Tab switching may update local display copy only and must not execute resource, trade, supply, troop, or turn logic.
- `Selected City` / `CityInfoPanel` should follow the web `selected_city_ui.js` hierarchy: city profile, loyalty, city status, governor, garrison, hero transfer placeholder, military panel, and attack placeholder.
- Chancellor policies should follow the web constants: `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`.
- Governor policies should follow the web constants: `재상 정책 수행`, `농업 중심`, `상업 중심`, and `군사 중심`.
- City/garrison/governor seed data should prioritize web `data/cities.js`, `data/heroes.js`, and `data/battle_rosters.js`. Unknown data should remain placeholder instead of being expanded into new systems.
- `v0.68b-10` remains UI/data-display parity only. It must not execute domestic effects, mutate resources, advance turns, save/load, recruit troops, move heroes, move armies, create `BattleContext`, transition to battle, run pathfinding, or alter route/sea-arrow systems.
- `v0.68b-9 WorldMap HUD Data Binding MVP` binds the web-style Godot HUD to local display-only player, hero, policy, and selected-city dictionaries.
- `LeftWorldStatusPanel` now displays mock-bound turn/calendar/phase, national bars, chancellor portrait slot, chancellor name/stats, chancellor policy selection, resources, supply, logistics, and trade copy.
- `CityInfoPanel` now displays selected-city governor portrait slot, governor name/stats, governor policy selection, city loyalty, stationed hero chips, military copy, and trade/supply copy.
- `CityDetailPanel` now displays selected-city resource, loyalty/policy, military, trade, rating, governor, and stationed hero count summaries.
- Chancellor and governor policy selection is UI state only. It may update labels, descriptions, hint copy, and debug logs, but must not apply domestic effects, mutate resources, advance turns, recruit troops, move heroes, move armies, or create `BattleContext`.
- The HUD data binding remains a worldmap UI foundation patch. It must not alter city marker positions, route `Path2D` curves, sea arrow flow, castle icon visual-disable state, battle scenes, battle entry, pathfinding, or AI.
- `v0.68b-8 WorldMap Web HUD Visual Parity MVP` tunes the Godot `WorldMapUI` HUD visuals against the actual web HTML/CSS/JS structure.
- Web visual references include `index.html`, `css/main.css`, `world_map_ui.js`, `ui_render.js`, `world_hud_ui.js`, `diplomacy_spy_ui.js`, `resource_ui.js`, and `selected_city_ui.js`.
- The worldmap HUD visual style is dark navy/black translucent panels, thin gold borders, gold/beige eyebrow titles, dense small text, inner dark cards, small tab buttons, red action buttons, and progress-bar placeholders.
- `WorldMapUI` now includes a centered `SamWar Web` title banner placeholder and a fixed right HUD layout that visually approximates the web `city-hud-stack`.
- The visual parity layer is UI-only. It must not create `BattleContext`, change scenes, execute domestic changes, run diplomacy/spy logic, move heroes, move armies, alter resources, advance turns, or modify route/sea-arrow systems.
- `v0.68b-8 WorldMap Web HUD Panel Structure Import MVP` expands the screen-fixed `WorldMapUI` toward the web `renderAllWorldUI()` layout.
- The Godot MVP HUD structure is `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and expanded `CityInfoPanel` under the CanvasLayer.
- `LeftWorldStatusPanel` is a placeholder-only port of the web `renderWorldHud()` shape: world turn, calendar, national status, chancellor, resources, internal supply, logistics, and wild-army edit placeholder.
- `DiplomacySpyPanel` is a placeholder-only port of the web `renderDiplomacySpyPanel()` shape: diplomacy/spy tabs, faction relation summary, intel summary, and prepared-state copy.
- `CityDetailPanel` is a placeholder-only port of the web `renderCityDetailPanel()` shape: selected city name, type, region/owner, resource/security/military/commerce placeholders, city status, and domestic placeholder.
- `CityInfoPanel` remains the selected-city summary and now includes the web selected-city hierarchy at MVP scope: description, city id, region, owner, type, neighbors, route types, status, garrison placeholder, military placeholder, attack placeholder, hero-move placeholder, and domestic placeholder.
- City marker clicks must refresh both `CityDetailPanel` and `CityInfoPanel` while preserving `selected_city_id`, `selected_city_marker`, and marker-local `SelectionRing`.
- All HUD actions in this phase are placeholder-only. They must not create `BattleContext`, transition to battle, execute domestic changes, move heroes, move armies, run pathfinding, or alter turn/resource state.
- Castle icon visuals remain disabled during this HUD work; route lines and sea arrow flow remain unchanged.
- `v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch` defers castle icon visuals and returns the visible city marker to the lightweight functional `CityDot`.
- Castle icon assets and `CastleIcon` scene nodes must not be deleted; they are retained with `visible = false` and controlled by `CASTLE_ICON_VISUALS_ENABLED` in `scripts/worldmap_city_marker.gd`.
- The current visible marker bundle is functional-first: `CityDot`, `NameText`, `SelectionRing`, and `ClickArea/CollisionShape2D` stay under each `CityMarker_*` root.
- CityInfoPanel, selected city state, metadata, route lines, and sea arrow flow remain active while castle visuals are deferred.
- `v0.68b-6 WorldMap Selected City Panel Web Parity MVP` adds selected city state and a screen-fixed `WorldMapUI/CityInfoPanel`.
- City marker clicks update `selected_city_id`, clear the previous marker selection, show the selected marker's `SelectionRing`, and refresh the panel from marker metadata.
- Each `CityMarker_*` now owns a hidden `SelectionRing` Polygon2D child behind the castle icon; it remains attached to the marker root during pan/zoom and editor root movement.
- `CityInfoPanel` is an MVP port of the web `renderSelectedCityPanel()` structure and displays city name, id, region/owner, type, neighbors, route type summary, status text, and placeholder attack / hero-move buttons.
- Attack and hero-move buttons are placeholders only. They must not create `BattleContext`, change scenes, move heroes/armies, or start combat until later tasks.
- Route lines and sea arrow flow remain visual-only. Sea arrow spacing is initialized by `scripts/worldmap_route_flow_fx.gd`, not by saved `PathFollow2D.progress_ratio` scene properties.
- `v0.68b-2-hotfix5 WorldMap City Marker Label Reparent Fix` standardizes each city as one scene-authored marker bundle under `CityLayer`.
- `v0.68b-3 WorldMap City Castle Icon Apply` replaces the visible city dot with a regional `CastleIcon` Sprite2D child.
- Korean peninsula cities use `castle_korea.png`, China mainland cities use `castle_china.png`, Japanese archipelago cities use `castle_japan.png`, and Karakorum / northern steppe uses `castle_ordo.png`.
- Castle icons should be scaled to a shared MVP target height around `56px`; city positions still remain the scene-authored `CityMarker_*`.`position`.
- Each `CityMarker_*` root owns local city visual/text/click children.
- Current city marker bundle children are `CastleIcon`, Node2D `NameText`, hidden fallback `CityDot`, and `ClickArea/CollisionShape2D`.
- `NameText` should be a `Node2D` worldmap text node, not a `Label` / `Control` node, so marker root movement in the Godot 2D editor carries the city name reliably.
- Moving a `CityMarker_*` root in the Godot 2D editor should move the icon/dot, label, and click area together.
- Runtime code may refresh local label text and marker color from metadata, but must not place `NameLabel` with independent world coordinates.
- Runtime may update label text/color from marker metadata and process click signals, but it must not detach label/click geometry from the marker root.
- City marker positions remain scene-authored `CityMarker_*`.`position`; tile manual layout control does not make web `x` / `y` authoritative.
- After `v0.68b-2-hotfix2`, corrected `CityMarker_*` seed positions use the 1024x1024 four-tile combined rect so markers sit on the map image in the Godot 2D editor.
- `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix` aligns the city marker layer with the four-tile worldmap coordinate space.
- `WorldMapRoot`, `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` use the same zero-offset parent coordinate basis.
- Scene-authored tile positions are A1 `(0, 0)`, A2 `(tile_width, 0)`, B1 `(0, tile_height)`, and B2 `(tile_width, tile_height)` with `Sprite2D.centered = false`.
- Corrected `CityMarker_*` positions are a one-time seed fix against the 4-tile combined rect; future edits should move the marker nodes directly in the Godot 2D editor.
- `v0.68b-2 WorldMap City Marker Layer MVP` adds the first 13 city markers under `WorldMap_Test.tscn > WorldMapRoot > CityLayer`.
- City marker metadata is based on `SamWar_web/data/cities.js`: `id`, `name`, `regionKey`, `ownerFactionId`, `neighbors`, and `routeTypes`.
- Web `x` / `y` values are only seed/fallback placement data. They are recorded as `web_seed_position` but must not become the final Godot source of truth.
- Final city placement source of truth is each scene-authored `CityMarker_*` node's `position` in `WorldMap_Test.tscn`.
- Kimjak may move `CityMarker_*` nodes directly in the Godot 2D editor and save the scene; runtime must preserve those edited positions.
- `scripts/worldmap_city_marker.gd` stores marker metadata and lightweight visual label/color behavior only. It must not override the marker root position from web data at runtime.
- City click and route drawing MVPs exist; selection UI, route interaction, army movement, battle entry, and `BattleContext` creation remain forbidden until their dedicated tasks.

## Current Route Layer Foundation
- `v0.68b-4 WorldMap Route Layer Path2D MVP` adds the first scene-authored route graph under `WorldMap_Test.tscn > WorldMapRoot > RouteLayer`.
- Route connection meaning is code-owned metadata: `route_id`, `start_city_id`, `end_city_id`, and `route_type`.
- Actual route shape is scene-owned `Path2D.curve`. Kimjak can adjust `Path2D` / `Curve2D` points directly in the Godot 2D editor and save the scene.
- Runtime route code may refresh `Line2D` from `Path2D.curve.get_baked_points()`, but it must not overwrite an existing scene-authored curve from city positions.
- Initial route curves are one-time seeds from current `CityMarker_*` root positions only.
- Land routes use muted earth-tone thin lines; sea routes use pale blue thin lines.
- `v0.68b-4-hotfix1` tunes land route readability to width `4.5` and `Color(0.86, 0.62, 0.32, 0.72)` while preserving the existing sea route width/color.
- `v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP` adds visual-only arrow flow FX to sea routes.
- Sea route arrow flow uses an `ArrowFlowRoot` Path2D that references the route's scene-authored `Path2D.curve`; it must not regenerate route curves from city positions.
- Sea arrow flow is one-way from `start_city_id` to `end_city_id` for the MVP.
- Land routes must remain line-only unless a future task explicitly adds land route FX.
- RouteLayer is a visual/path foundation only. Route click, pathfinding, army movement, battle entry, naval battle logic, and `BattleContext` runtime injection remain deferred.
- When the same city pair appears from both directions, create only one route node. For route type conflicts, prefer explicit `routeTypes` metadata over default land inference.
- Known issue retained outside this route-layer scope: CityMarker root movement / name text attachment still needs 김작 manual 2D/F6 confirmation.

## Canonical Direction
- The battle engine does not choose heroes directly.
- The battle engine does not read worldmap state directly.
- The worldmap / army system creates an encounter and converts it into `BattleContext`.
- The battle engine consumes `BattleContext.roster`, map metadata, and battle rules as prepared input.

## World Scope
- The worldmap is based on China, the Korean peninsula, and the Japanese archipelago.
- Worldmap data should support land regions, coastal regions, sea routes, ports, cities, and strategic connections.

## Core Concepts
- `city`: controllable settlement, base, port, capital, fortress, or supply node.
- `region`: larger geographic grouping used for terrain, map selection, ownership, and encounter rules.
- `route`: sea movement path between ports, coasts, islands, or naval regions.
- `connection`: land or sea adjacency used for movement, invasion, reinforcement, and supply.
- `encounter`: resolved worldmap event that requests a battle.

## Movement Types
- Land movement occurs through land connections between cities or regions.
- Sea movement occurs through sea routes and port/coastal connections.
- Mixed coastal movement may connect land armies, fleets, ports, and coastal battle rules.

## Battle Type Selection
- Worldmap rules decide `battle_type`.
- Supported future battle types:
  - `land`
  - `naval`
  - `coastal`
  - `siege`
  - `mountain`
- Region, route, city, terrain, attacker approach, defender position, and encounter type may all affect battle type.

## Map Variant Selection
- `map_variant_id` is chosen by worldmap / region rules, not by the battle engine.
- The battle engine should receive a resolved `map_variant_id` in `BattleContext`.
- Map variant selection may use:
  - `region_id`
  - `city_id`
  - `route_id`
  - `battle_type`
  - `terrain_tags`
  - attacker / defender approach direction

## Battle Context Responsibility
- Worldmap owns encounter creation.
- Worldmap resolves attacker and defender armies.
- Worldmap resolves battle type, terrain, region, map variant, and initial scenario metadata.
- Worldmap produces `BattleContext`.
- Battle engine consumes `BattleContext` and reports battle result back through a future result contract.

## v0.68b-12b-18 Invasion Reinforcement Source Rule
- WorldMap invasion BattleContext roster creation must use the attacker and defender source city stationed heroes first.
- Reinforcements are limited to same-faction or explicit-ally cities within MVP adjacency: direct neighbors first, then 2-hop neighbors only.
- 3-hop cities, disconnected cities, and full `HERO_DATA` pool searches are forbidden for normal reinforcements.
- If eligible nearby reinforcements are insufficient, leave the roster short. Do not force-fill distant city heroes.
- Battle-scene sample roster fallback is a crash guard only for direct sample battles or fully empty/broken context sides.
- 평양 -> 한성 ordinary invasion support must not pull 성도 유비/제갈량 unless a future explicit event/alliance rule says so.
- Save/Load persistence, wounds/capture, hero movement, resource looting, and precise strategic AI remain outside this rule.

## Future Expansion Hooks
- `weather`
- `season`
- `fog`
- `river_crossing`
- `supply`
- naval wind/current conditions
- siege equipment and wall state
- road quality and movement fatigue

## Forbidden Coupling
- Do not make battle scripts query worldmap ownership directly.
- Do not make battle scripts select armies directly from city or region state.
- Do not encode region-specific map selection inside the battle engine.
- Do not treat scene node placement as worldmap deployment data.
## v0.68b-12b-27 Player Attack Deployment Rules
- Player attack uses a deployment preparation step before battle scene handoff.
- Source city selection remains direct-neighbor MVP: current valid player source city first, otherwise the first player-owned neighbor of the enemy target.
- Deployable heroes are the source city's stationed heroes after battle-exclusion filtering. Captured/dead heroes are excluded; wounded heroes remain deployable and keep their wounded badge/penalty.
- Deployment requires at least one selected hero and positive troop allocation. Total assigned troops cannot exceed source city troops minus one, so the source city keeps at least one garrison troop.
- Supply cost MVP formula: food/rice = assigned troops, gold = ceil(assigned troops * 0.2), salt = ceil(assigned troops * 0.1).
- Supply is checked and paid from the source city's runtime `resource_stock`; missing food/rice, gold, or salt fields are defaulted only for the source city when deployment opens.
- Source-city `resource_stock` is saved/loaded through `worldmap_city_state`. BattleContext carries selected attacker ids, per-hero troop allocation, supply cost, and supply source city id.
- Deferred: sea route attacks, 2-hop attacks, travel time, in-battle supply penalties, supply plunder/loss recovery, troop type composition, manual support selection, siege-specific UI, and hero recruitment/faction conversion.

## v0.68b-12b-32 CommandRank / CommandLimit Allocation Rules
- Godot follows the web command rank constants: `governor=10000`, `general=8000`, `lieutenant=6000`, `officer=5000`.
- Labels follow web copy: 태수, 장군, 부장, 군관.
- Unknown command rank falls back to `officer`; legacy `captain` is normalized to `lieutenant`.
- A city governor is treated as `governor` rank for that city when calculating command limit.
- Player attack deployment UI must show each deployable hero's command limit and cap allocation input by commandLimit and source deployable troops.
- Confirm validation must clamp allocation again before BattleContext handoff; UI validation alone is not authoritative.
- Default allocations for player attack defenders and enemy invasion attack/defense sides use commandLimit distribution, capped by city garrison and total command limit.
- Troop count still does not scale battle HP/attack/defense. Allocated troops remain accounting metadata for survivor/wounded/dead and woundedQueue results.

## v0.68b-12b-33D Defense Deployment Rules
- Enemy invasion defense must open a deployment panel before battle handoff for both manual and auto defense choices.
- Defense candidates are the defender city's stationed player heroes after battle-exclusion filtering. Captured/dead heroes are excluded; wounded heroes remain selectable.
- Defense deployment uses the same commandLimit display and clamp rules as player attack deployment.
- Defense confirmation requires at least one selected defender and positive troop allocation per selected hero.
- Total defender allocation cannot exceed defender city troops minus one, preserving a minimum city garrison reserve.
- Confirmed defense BattleContext must carry `selected_defender_hero_ids`, `defender_troop_allocation`, `defender_total_allocated_troops`, and `defender_source_city_id`.
- Enemy attacker allocation remains automatic commandLimit allocation. No enemy attacker manual selection UI is implemented.
- Existing attacker/defender source-city pre-decrement and woundedQueue result rules remain authoritative after defense confirmation.
- Canceling the defense panel must not clear the pending invasion event.
