# SESSION LOG

## 2026-07-07

### v0.70-76 Domestic Tech Manual QA Scenario Pack
- Started from local and `origin/main` `8a50087 v0.70-75-hotfix1 Cost Display QA Polish`; the working tree was clean.
- Required workflow/worldmap docs were read before edits.
- Implemented:
  - Domestic Tech manual QA scenario pack at `agent/DOMESTIC_TECH_MANUAL_QA.md`.
  - National and city research start/progress/completion scenarios.
  - Completion refresh, same-city only, enemy/unknown/insufficient-intel no-display, Safe Set, cost display-only, no charge/no gating, UI64/click/overlay, and warning cleanliness scenarios.
  - Manual QA result template.
  - Side-effect-free `_get_domestic_tech_manual_qa_scenario_pack_mvp()` QA helper with forbidden mutation counters fixed at 0.
- Preserved no gameplay mutation, no actual research cost application, no cost-based research blocking, no affordability check, no paid-cost state, no reservation/refund/cancel flow, no extra research slots, no enemy research/effect, no battle/diplomacy/spy/market/city_intel/AI mutation, no troop/ship/siege count mutation, no BattleContext/pending invasion change, no tech definition change, no asset/icon/UI64/import change, and all current Safe Set locks.
- Manual F6 QA remains required by executing `agent/DOMESTIC_TECH_MANUAL_QA.md`.

## 2026-07-05

### v0.70-75-hotfix1 Cost Display QA Polish
- Started from local `8b29e26 v0.70-75 Research Cost Display Safe Set`; `origin/main` was `6c74bc5`, so local was ahead by Domestic Tech commits and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Expected-cost formatter guard for negative or malformed planned cost values.
  - Preserved compact display-only cost copy and `금` / `군량` / `노역` / `정책` ordering.
  - Reconfirmed state-specific cost display rules without adding cost-shortage or payment wording.
  - Cost display QA summary flags for state-specific display and explicit no-charge behavior.
  - Research balance summary consistency with no charge, no gating, no paid state, no affordability check, unchanged research flow, and enemy research disabled.
- Preserved no actual research cost application, no cost-based research blocking, no affordability check, no paid-cost state, no reservation/refund/cancel flow, no battle/diplomacy/spy/market/city_intel/AI mutation, no enemy research/effect, no troop/ship/siege count mutation, no BattleContext/pending invasion change, no tech id/name/category/branch/prerequisite change, no asset/icon/UI64/import change, and all current Safe Set locks.
- Manual F6 QA remains required for national/city cost display, expected-cost display-only wording, state-specific display, no resource deduction, no cost gating, no affordability check, research flow, Safe Set preservation, enemy no research/effect, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-75 Research Cost Display Safe Set
- Started from local `1c96397 v0.70-74-hotfix1 Cost & Research Balance QA Polish`; `origin/main` was `6c74bc5`, so local was ahead by Domestic Tech commits and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Common Domestic Tech research cost display formatter for planned gold/food/labor/policy output.
  - National/city scope-separated expected-cost display standards by tier.
  - Unified display labels/order: `금`, `군량`, `노역`, and `정책`, with zero values hidden and display-only copy retained.
  - State-specific Domestic Tech inspector lines for completed, researching, available, and locked/blocked states.
  - Research cost display QA summary helper plus balance summary alignment for no charge, no blocking, no paid state, and no affordability check.
- Preserved no actual research cost application, no cost-based research blocking, no paid-cost state, no reservation/refund/cancel flow, no battle/diplomacy/spy/market/city_intel/AI mutation, no enemy research/effect, no troop/ship/siege count mutation, no BattleContext/pending invasion change, no tech id/name/category/branch/prerequisite change, no asset/icon/UI64/import change, and all current Safe Set locks.
- Manual F6 QA remains required for national/city cost display, expected-cost display-only wording, state-specific display, no resource deduction, no cost gating, research flow, Safe Set preservation, enemy no research/effect, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## 2026-07-04

### v0.70-74-hotfix1 Cost & Research Balance QA Polish
- Started from local `7793082 v0.70-74 Domestic Tech Cost & Research Balance Planning`; `origin/main` was `6c74bc5`, so local was ahead by Domestic Tech commits and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - State-specific Domestic Tech inspector display for completed, researching, available, and locked/blocked research states.
  - Compact `예상 비용 ... · 표시 전용` wording for available techs only.
  - Cost plan and balance summary flags confirming no start, per-turn, completion, blocking, or paid-state cost behavior.
  - Active research duration normalization guard so existing positive remaining turns are not shortened by missing/malformed duration data.
  - Explicit positive `duration_turns` support before duration hint and tier fallback.
- Preserved no actual research cost application, no cost-based research blocking, no paid-cost state, no reservation/refund/cancel flow, no battle/diplomacy/spy/market/city_intel/AI mutation, no enemy research/effect, no troop/ship/siege count mutation, no BattleContext/pending invasion change, no tech id/name/category/branch/prerequisite change, no asset/icon/UI64/import change, and all current Safe Set locks.
- Manual F6 QA remains required for duration display, remaining turns, expected cost display-only wording, no resource deduction, no cost gating, active research compatibility, research flow, Safe Set preservation, enemy no research/effect, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-74 Domestic Tech Cost & Research Balance Planning
- Started from local `fd4e659 v0.70-73-hotfix1 Domestic Tech Final Manual QA Polish`; `origin/main` was `6c74bc5`, so local was ahead by the hotfix commit and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Tier-based Domestic Tech duration planning for new research: Tier 1 = 2 turns through Tier 5 = 6 turns.
  - Duration fallback helper and compatibility guard so existing active research duration is not shortened by the new fallback.
  - Display-only expected research cost helper for national/city Domestic Tech planning.
  - Domestic Tech inspector lines for `연구 소요` and `예상 비용 ... (표시 전용)`.
  - Research balance summary helper reporting display-only cost planning, unchanged active/completion flow, and enemy research disabled.
- Preserved no actual research cost application, no cost-based research blocking, no paid-cost state, no battle/diplomacy/spy/market/city_intel/AI mutation, no enemy research/effect, no troop/ship/siege count mutation, no BattleContext/pending invasion change, no tech id/name/category/branch/prerequisite change, no asset/icon/UI64/import change, and all current Safe Set locks.
- Manual F6 QA remains required for duration display, remaining turns, expected cost display, no resource deduction, no cost gating, research flow, Safe Set preservation, enemy no research/effect, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-73-hotfix1 Domestic Tech Final Manual QA Polish
- Started from local and `origin/main` `6c74bc5 v0.70-73 Domestic Tech Full Effect Integration QA & Balance Pass`; the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Compact, unique Domestic Tech source display through `_format_domestic_tech_source_display_mvp()`.
  - Zero-value no-display guard for economy turn summary and retained empty city spy/intel mapping no-display.
  - Safer display-safe copy for military/defense, national policy, naval/siege, and diplomacy/spy sections.
  - Research-completion display refresh for left national panel, selected PLAYER city detail, and Domestic Tech inspector.
  - Full integration summary flag `empty_mapping_false_display = false`.
- Preserved no battle formula change, no diplomacy/spy success formula change, no relation score mutation, no city_intel visibility change, no spy detection/action result change, no market/trade modifier, no enemy intel reveal, no AI diplomacy/spy behavior, no enemy tech effect, no troop/ship/siege count mutation, no BattleContext/pending invasion change, no tech definition change, no asset/icon/UI64/import change, and all current Safe Set locks.
- Manual F6 QA remains required for UI length/source truncation, zero-value no-display, research completion refresh, turn income consistency, same-city only, enemy no-effect/no-display, no battle/diplomacy/spy/city_intel mutation, no troop/ship/siege count mutation, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## 2026-07-02

### v0.70-73 Domestic Tech Full Effect Integration QA & Balance Pass
- Started from local `38eb5fc v0.70-72-hotfix1 Diplomacy/Spy Display Effect QA Polish`; `origin/main` was still `23b90f4`, so local was ahead and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Full Domestic Tech Safe Set integration QA summary helper covering economy, military/defense, national policy, naval/siege, and diplomacy/spy.
  - Consolidated completed-only, researching no-effect, PLAYER-only, same-city-only, non-persistence, source uniqueness, and forbidden-effect zero counters.
  - Extra source-tech uniqueness normalization for economy, military/defense, and national policy helper outputs.
  - Compact, consistent UI effect section titles while preserving zero/empty section hiding.
- Preserved no battle formula change, no diplomacy/spy success formula change, no relation score mutation, no city_intel visibility change, no spy detection/action result change, no market/trade modifier, no enemy intel reveal, no AI diplomacy/spy behavior, no enemy tech effect, no troop/ship/siege count mutation, no BattleContext/pending invasion change, no tech definition change, no asset/icon/UI64/import change, and all current Safe Set locks.
- Manual F6 QA remains required for full effect display, turn income consistency, same-city only, enemy no-effect, no battle/diplomacy/spy/city_intel mutation, no troop/ship/siege count mutation, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-72-hotfix1 Diplomacy/Spy Display Effect QA Polish
- Started from local and `origin/main` `23b90f4 v0.70-72 Domestic Tech Diplomacy/Spy Display Safe Set`; the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Reconfirmed PLAYER completed national tech diplomacy/spy display helper behavior with source uniqueness and no persisted computed bonus state.
  - Added explicit empty Safe Set guards to the city spy/intel helper and city display formatter so the current empty city mapping cannot produce false/zero local spy display.
  - Extended QA summary with city spy/intel source uniqueness, empty mapping status, and empty mapping no-display flags.
  - Preserved helper-driven display consistency for left national panel, Domestic Tech inspector, and selected PLAYER city detail.
- Preserved no actual diplomacy success formula change, no spy success formula change, no relation score mutation, no city_intel visibility change, no spy detection/action result change, no enemy intel reveal, no AI diplomacy/spy behavior, no enemy tech effect, no BattleContext/pending invasion change, no market/trade formula change, no battle/troop/naval/siege formula change, no tech definition change, no asset/icon/UI64/import change, and economy/military-defense/national-policy/naval-siege Safe Set behavior.
- Manual F6 QA remains required for diplomacy/spy display bonus, PLAYER only, city spy/intel no false display, enemy no-effect, no diplomacy/spy success mutation, no relation/city_intel mutation, UI bonus display, economy Safe Set, military/defense Safe Set, national policy Safe Set, naval/siege Safe Set, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-72 Domestic Tech Diplomacy/Spy Display Safe Set
- Started from local and `origin/main` `4a0e298 v0.70-71-hotfix1 Naval/Siege Display Effect QA Polish`; the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - PLAYER completed national tech `_get_domestic_tech_diplomacy_spy_bonus_mvp()` with unique source techs and no persisted computed bonus state.
  - Existing-id Safe Set mapping for diplomacy/tribute/world diplomacy/intelligence/inspection readiness plus centralization/bureaucracy display preparation values.
  - PLAYER-city, same-city, completed-only `_get_domestic_tech_city_spy_intel_bonus_mvp(city_id)` with empty current mapping because no city spy/intel tech definitions exist yet.
  - Left national panel and Domestic Tech inspector display for diplomacy/spy readiness lines and source tech names.
  - QA summary helper for diplomacy/spy display counters with actual success, relation, city_intel, and enemy counters fixed at 0.
- Preserved no actual diplomacy success formula change, no spy success formula change, no relation score mutation, no city_intel visibility change, no enemy intel reveal, no spy action result change, no AI diplomacy/spy behavior, no enemy tech effect, no BattleContext/pending invasion change, no market/trade formula change, no battle/troop/naval/siege formula change, no tech definition change, no asset/icon/UI64/import change, and economy/military-defense/national-policy/naval-siege Safe Set behavior.
- Manual F6 QA remains required for diplomacy/spy display bonus, PLAYER only, same-city city helper guard, enemy no-effect, no diplomacy/spy success mutation, no relation/city_intel mutation, UI bonus display, economy Safe Set, military/defense Safe Set, national policy Safe Set, naval/siege Safe Set, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## 2026-06-30

### v0.70-71-hotfix1 Naval/Siege Display Effect QA Polish
- Started from local and `origin/main` `2f3ddf3 v0.70-71 Domestic Tech Naval/Siege Display Safe Set`; the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Completed-only naval/siege helper polish using one normalized same-city completed tech map and completed `true` Safe Set ids.
  - Same-city-only, PLAYER-city-only, enemy/no-display, and no-persist behavior retained for naval/siege display calculation.
  - Source-tech uniqueness guard in helper output and QA summary.
  - City detail and Domestic Tech inspector display consistency polish for naval/siege source labels.
  - QA summary additions for `researching_has_naval_siege_effect = false`, `display_safe_only = true`, and `source_techs_unique`.
- Preserved no actual naval/siege battle modifier, no battle formula change, no troop stat/count mutation, no ship/siege weapon count mutation, no BattleContext change, no pending invasion change, no enemy city effect/display, no diplomacy/spy/market/trade effect, no national policy expansion, no AI research, no tech definition change, no asset/icon/UI64/import change, and economy/military-defense/national-policy Safe Set behavior.
- Manual F6 QA remains required for city naval/siege bonus, same-city only, enemy no-effect, no battle mutation, no ship/siege count mutation, UI bonus display, economy Safe Set, military/defense Safe Set, national policy Safe Set, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-71 Domestic Tech Naval/Siege Display Safe Set
- Started from local and `origin/main` `4bde6a0 v0.70-70-hotfix1 National Policy Effect QA Polish`; the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - PLAYER-city-only naval/siege display helper from completed city Domestic Tech.
  - Safe Set mapping for current shipyard/naval/siege ids only.
  - Same-city-only source tech handling with duplicate source prevention.
  - City detail and Domestic Tech inspector display for selected PLAYER city naval/siege preparation bonuses and source techs.
  - QA summary helper for `naval_display_effects_applied`, `siege_display_effects_applied`, `ship_count_effects_applied = 0`, `siege_weapon_count_effects_applied = 0`, `battle_effects_applied = 0`, and `enemy_effects_applied = 0`.
- Preserved no actual naval/siege battle modifier, no battle formula change, no troop stat/count mutation, no ship/siege weapon count mutation, no BattleContext change, no pending invasion change, no enemy city effect/display, no diplomacy/spy/market/trade effect, no national policy expansion, no AI research, no tech definition change, no asset/icon/UI64/import change, and economy/military-defense/national-policy Safe Set behavior.
- Manual F6 QA remains required for city naval/siege bonus, same-city only, enemy no-effect, no battle mutation, no ship/siege count mutation, UI bonus display, economy Safe Set, military/defense Safe Set, national policy Safe Set, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-70-hotfix1 National Policy Effect QA Polish
- Started from local `51d8cbb v0.70-70 Domestic Tech National Policy Effects Safe Set`; `origin/main` was still `ed7bb43`, so local was ahead and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Completed-only national policy helper polish using one normalized completed national tech map and completed `true` Safe Set ids.
  - Researching/incomplete no-effect and no-persist behavior retained for policy bonus calculation.
  - Display consistency polish so left national panel and Domestic Tech inspector use the same computed policy helper result.
  - Tax gold duplicate-prevention flags and non-negative national tax percent clamp before the existing final gold clamp.
  - QA summary additions for `national_completed_only`, `researching_has_policy_effect = false`, `tax_gold_applied_once = true`, and `source_techs_unique`.
- Preserved no new national policy scope, no enemy national effects, no AI research, no diplomacy/spy/market formula changes, no battle formula change, no troop stat/count mutation, no BattleContext change, no pending invasion change, no tech definition change, no asset/icon/UI64/import change, and existing economy and military/defense Safe Set behavior.
- Manual F6 QA remains required for national policy bonus, tax gold effect once, PLAYER only, enemy no-effect, no battle/diplomacy/spy/market mutation, no troop stat/count mutation, economy Safe Set, military/defense Safe Set, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-70 Domestic Tech National Policy Effects Safe Set
- Started from local `12cf490 v0.70-69-hotfix1 Military/Defense Effect QA Polish`; `origin/main` was still `ed7bb43`, so local was ahead by the prior hotfix commit and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - PLAYER completed national tech policy helper with unique sources and no persisted computed bonus state.
  - Safe Set mapping for law, bureaucracy, centralization, tax, conscription, logistics, population, foundation storage, and national monopoly.
  - Minimal `tax_gold_percent` hook into existing PLAYER city gold income calculation with non-negative clamp.
  - Display/preparation-only policy values for admin, recruit, logistics, population, law/order, and storage.
  - Left national panel and Domestic Tech inspector display for active national policy bonuses and source national techs.
  - QA summary helper for national policy counters with battle, troop stat/count, diplomacy, spy, market, and enemy effects fixed at 0.
- Preserved no enemy national effects, no AI research, no diplomacy/spy/market formula changes, no battle formula change, no troop stat/count mutation, no BattleContext change, no pending invasion change, no tech definition change, no asset/icon/UI64/import change, and existing economy and military/defense Safe Set behavior.
- Manual F6 QA remains required for national policy bonus, PLAYER only, tax gold effect, enemy no-effect, no battle/diplomacy/spy/market mutation, economy Safe Set, military/defense Safe Set, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-69-hotfix1 Military/Defense Effect QA Polish
- Started from local `ed7bb43 v0.70-69 Domestic Tech Military/Defense Effects Safe Set`; `origin/main` matched local HEAD and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Defense display clamp/order polish: percent then flat, final value clamped to `0+`.
  - QA summary additions for completed/player/same-city guard flags.
  - QA summary zero counters for `battle_effects_applied`, `troop_stat_effects_applied`, and `troop_count_effects_applied`.
- Preserved no battle formula change, no troop stat mutation, no troop count auto increase, no BattleContext change, no pending invasion change, no enemy city effect/display, no diplomacy/spy/market/trade effect, no national policy numeric effect, no AI research, no tech definition change, no asset/icon/UI64/import change, and economy Safe Set behavior.
- Manual F6 QA remains required for city military/defense bonus, same-city only, enemy no-effect, no battle mutation, no troop stat/count mutation, UI bonus display, economy Safe Set, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## 2026-06-29

### v0.70-69 Domestic Tech Military/Defense Effects Safe Set
- Started from local `5eeda38 v0.70-68-hotfix1 Domestic Tech Economy Effect QA Polish`; `origin/main` matched local HEAD and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - PLAYER-city-only military/defense helper from completed city Domestic Tech.
  - Safe Set mapping for barracks recruitment capacity display, infantry/archer/cavalry training display, and wall/moat/watchtower/beacon/iron defense display.
  - Same-city-only source tech handling with duplicate source prevention.
  - City detail and Domestic Tech inspector display for selected PLAYER city military/defense bonuses and source techs.
  - QA summary helper for `city_defense_effects_applied`, `training_display_effects_applied`, `battle_effects_applied = 0`, and `enemy_effects_applied = 0`.
- Preserved no battle formula change, no troop stat mutation, no troop count auto increase, no BattleContext change, no pending invasion change, no enemy city effect/display, no naval/siege numeric effect, no diplomacy/spy/market/trade effect, no national policy numeric effect, no AI research, no tech definition change, no asset/icon/UI64/import change, and economy Safe Set behavior.
- Manual F6 QA remains required for city military/defense bonus, same-city only, enemy no-effect, no battle mutation, no troop count mutation, UI bonus display, research flow, economy Safe Set, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-68-hotfix1 Domestic Tech Economy Effect QA Polish
- Started from local `1fc67e0 v0.70-68 Domestic Tech Numeric Effects Phase 1 - Economy Safe Set`; `origin/main` matched local HEAD and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Economy helper category guard for city-scope agri/fish/commerce only.
  - Completed-only, same-city-only, PLAYER-city-only behavior retained and documented in QA summary flags.
  - Unique source-tech helper so display and count paths do not duplicate sources.
  - Shared non-negative clamp helper for food/gold economy application.
  - Domestic turn economy bonus summary based on the same helper used by city detail and Domestic Tech inspector.
  - QA summary additions for agri/fish/commerce counts, `market_effects_applied = 0`, same-city, researching-no-effect, and no-persist flags.
- Preserved no new economy category, no combat/troop/battle/diplomacy/spy/market effect, no national policy numeric effect, no resource payment, no AI research, no enemy research/effect, UI64 priority, click latency behavior, overlay lifecycle, enemy/insufficient-intel hiding, BattleContext, pending invasion, tech definitions, assets, icon PNG files, UI64 PNG files, and `.import` files.
- Manual F6 QA remains required for city economy bonus, turn income change, same-city only, enemy no-effect, no duplicate accumulation, UI bonus display, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## 2026-06-28

### v0.70-68 Domestic Tech Numeric Effects Phase 1 - Economy Safe Set
- Started from local `8a90673 v0.70-67-hotfix1 Domestic Tech Effect Phase 1 QA Polish`; `origin/main` matched local HEAD and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - PLAYER-city-only economy bonus helper from completed city Domestic Tech.
  - Agri/fish/commerce Safe Set values for food, gold, and display-level supply bonuses.
  - Existing player domestic income hook for city food/gold bonuses without storing derived bonus state.
  - Selected PLAYER city economy bonus/source display in city detail and Domestic Tech inspector.
  - Numeric effect QA helper output with economy count and combat/diplomacy/spy/enemy counters at 0.
- Preserved no combat/troop/battle/diplomacy/spy/market effect, no national policy numeric effect, no resource payment, no AI research, no enemy research/effect, UI64 priority, click latency behavior, overlay lifecycle, enemy/insufficient-intel hiding, BattleContext, pending invasion, tech definitions, assets, icon PNG files, UI64 PNG files, and `.import` files.
- Manual F6 QA remains required for city economy bonus, turn income change, same-city only, enemy no-effect, UI bonus display, research flow, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-67-hotfix1 Domestic Tech Effect Phase 1 QA Polish
- Started from local `4a4632b v0.70-67 Domestic Tech Actual Effects Phase 1`; local HEAD was one commit ahead of `origin/main` and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Required-national condition display now distinguishes completed, researching, and incomplete states.
  - Same-city city prerequisite display now distinguishes completed, researching, and incomplete states.
  - Relation copy now uses compact connected-city / required-national / enhanced-by status lines.
  - `effect_stub` copy now says effect readiness and later-version numeric deferral.
  - Phase 1 summary helper now includes QA counts and no-effect safety flags.
- Preserved no numeric Domestic Tech effects, no resource payment, no resource/income/troop/battle/diplomacy/spy/market mutation, no AI research, no enemy research/effect, UI64 priority, click latency behavior, overlay lifecycle, enemy/insufficient-intel hiding, BattleContext, pending invasion, assets, icon PNG files, UI64 PNG files, and `.import` files.
- Manual F6 QA remains required for national-to-city unlock, researching-not-unlocked, same-city city prerequisite only, relation display, effect display, no gameplay-number mutation, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-67 Domestic Tech Actual Effects Phase 1
- Started from local `c2f8d7d v0.70-66-hotfix1 Domestic Tech Research QA & Completion Polish`; `origin/main` matched local HEAD and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Explicit completed-only required national tech helper for city tech conditions.
  - Continued same-city-only city tech prerequisite behavior.
  - Completed-state relation display for national unlock/enhance and city required/enhanced-by links.
  - Phase 1 `effect_stub` display as description plus application-readiness copy.
  - Internal effect coverage summary with `numeric_effects_applied = 0`.
- Preserved no numeric Domestic Tech effects, no resource payment, no resource/income/troop/battle/diplomacy/spy/market mutation, no AI research, no enemy research/effect, UI64 priority, click latency behavior, overlay lifecycle, enemy/insufficient-intel hiding, BattleContext, pending invasion, assets, icon PNG files, UI64 PNG files, and `.import` files.
- Manual F6 QA remains required for national-to-city unlock, same-city city prerequisite only, relation display, effect display, no resource/troop/battle/diplomacy/spy/market mutation, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-66-hotfix1 Domestic Tech Research QA & Completion Polish
- Started from local `1f9bb84 v0.70-66 Domestic Tech Research Progress & Completion MVP`; tracked files were clean and local HEAD was ahead of `origin/main`.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Safer national and city active research normalize.
  - Completed state normalize for missing/null/list-shaped national and city completed data.
  - `remaining_turns` clamp to 0 during turn advancement.
  - Safe completion/clear handling for 0 or negative active research state.
  - Duplicate completion notification guard for already completed active entries.
  - Per-city completed mirror sync from `_player_state["city_domestic_tech_completed"]`.
  - Completed-only prerequisite behavior remains intact; researching/active state is not prerequisite credit.
- Preserved no Domestic Tech actual effects, no resource payment, no AI research, no enemy research, no gameplay formula changes, UI64 priority, click latency behavior, overlay lifecycle, enemy/insufficient-intel hiding, BattleContext, pending invasion, assets, icon PNG files, UI64 PNG files, and `.import` files.
- Manual F6 QA remains required for national/city progress, completion, duplicate notification absence, city-specific completed separation, save/load, follow-up tech availability, no resource/effect mutation, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-66 Domestic Tech Research Progress & Completion MVP
- Started from local `c27e460 테크트리완성`; `origin/main` matched local HEAD and the working tree was clean.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - `_advance_domestic_tech_research_for_world_turn_mvp()` in the existing domestic turn apply flow.
  - National active research `remaining_turns` decrement, completion write to `_player_state["national_domestic_tech_completed"]`, and active clear.
  - PLAYER city active research `remaining_turns` decrement, per-city completion write to `_player_state["city_domestic_tech_completed"]`, city `city_tech.completed` mirror, and per-city active clear.
  - Domestic research completion messages in the turn summary and overlay refresh after completion when the tech tree is open.
  - Completed-only prerequisite recognition remains intact; researching/active techs are not prerequisite credit.
- Preserved no Domestic Tech actual effects, no resource payment, no AI research, no enemy research, no gameplay formula changes, UI64 priority, hotfix4 click latency behavior, overlay lifecycle, enemy/insufficient-intel hiding, BattleContext, pending invasion, assets, icon PNG files, UI64 PNG files, and `.import` files.
- Verification passed: `git diff --check`, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual F6 QA remains required for national/city research progress, completion display, follow-up tech availability, active clear, no resource/effect mutation, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-65 Domestic Tech Research Start MVP
- Started from local `d442f1e v0.70-64 Domestic Tech Research Readiness Layer`.
- Fetched `origin/main`; local HEAD was ahead of `origin/main`, with existing untracked Godot-generated UI64 `.import` files intentionally left untouched.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - National active research state in `_player_state["national_tech_research"]["active"]`.
  - Per-city active research state in `city_data["city_tech"]["research"]["active"]`.
  - Research start button enablement for available techs only, with same-scope active research blocking.
  - `researching` node/inspector state with remaining/total turn display.
  - Immediate UI refresh after research start without using the lightweight node-click path.
- Preserved no resource payment, no turn progression, no research completion, no completed-tech mutation, no actual effect application, no AI research, no gameplay formula changes, UI64 priority, hotfix4 click latency behavior, overlay lifecycle, enemy/insufficient-intel hiding, assets, icon PNG files, UI64 PNG files, and `.import` files.
- Verification passed: `git diff --check`, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual F6 QA remains required for national/city research start, duplicate research blocking, researching display, resource/completed invariance, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

### v0.70-64 Domestic Tech Research Readiness Layer
- Started from local `53908b8 v0.70-63-hotfix6 Domestic Tech Tree Final UI QA & Overlay Lifecycle Polish`.
- Fetched `origin/main`; local HEAD was 2 commits ahead of `origin/main` and the working tree had untracked Godot-generated UI64 `.import` files that were intentionally left untouched.
- Required workflow/worldmap docs were read before runtime changes.
- Implemented:
  - Detail inspector research-readiness format for selected Domestic Tech Tree nodes.
  - Readiness copy for completed, available, locked, and special-locked states.
  - Disabled display-only research action slot with `연구 시작`; no `pressed` signal is connected.
  - Human-readable condition formatting for prerequisites, national requirements, city conditions, special requirements, governor/chancellor aptitudes, resources, and hero flags.
  - Display-only relation lines for national/city unlocks, enhancements, required national techs, and enhanced-by national techs.
- Preserved read-only tech tree behavior, UI64 priority, hotfix4 click latency fix, selected highlight, overlay lifecycle, left PLAYER national scope, right selected PLAYER city scope, enemy/insufficient-intel hiding, gameplay formulas, scenes, assets, icon PNG files, UI64 PNG files, and `.import` files.
- Verification passed: `git diff --check`, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual F6 QA remains required for available/locked/special-locked/completed readiness states, disabled action slot, no resource/completed mutation, relation display, icon visibility, click latency, overlay lifecycle, enemy-city safety, and warning cleanliness.

### v0.70-63-hotfix6 Domestic Tech Tree Final UI QA & Overlay Lifecycle Polish
- Started from local `77eb052 v0.70-63-hotfix5 Domestic Tech Tree UI64 Icon Binding`.
- Fetched `origin/main`; local HEAD was 1 commit ahead of `origin/main` and tracked files were clean. Untracked Godot-generated UI64 `.import` files were present and intentionally left untouched.
- Required workflow/worldmap docs were read before auditing runtime files.
- Audited and confirmed:
  - `DomesticTechTreeButtonMVP` is created once, labeled `테크트리`, and connected to `_open_domestic_tech_tree_overlay_mvp()`.
  - Overlay open calls ensure/hide/refresh/visible/top-layer steps and keeps `MOUSE_FILTER_STOP`, absolute high z-index, and `move_to_front()`.
  - Overlay content rebuild clears previous children and compact node references before rebuilding title, split panels, graph content, and detail inspector.
  - `닫기` and ESC close paths hide the overlay, reset selected tech ids, restore hidden panel visibility, and clear hidden-state storage.
  - Node click remains display-only and lightweight: set selected id/city, refresh detail inspector, consume input, and update previous/current selected node styles only.
  - Enemy/insufficient-intel safety remains: left side is PLAYER national tech only, right side city tech detail returns safe copy unless selected city is PLAYER-owned.
  - UI64 coverage remains complete: 85 total domestic tech definitions, 85 UI64 mapped, 0 missing mapped files, 0 `etc/` mappings, 0 expected existing-icon fallback, and 0 expected remaining `?` fallback.
- No runtime code change was required. Docs were updated for final QA/handoff/lock state only.
- Preserved read-only tech tree behavior, UI64 priority, hotfix4 click latency fix, modal/top-layer behavior, gameplay formulas, scenes, assets, icon PNG files, and `.import` files.
- Manual F6 QA remains required for repeated open/close/reopen, visible-state restore feel, scroll/layout, enemy-city safety, top-layer input blocking, and warning cleanliness.

### v0.70-63-hotfix5 Domestic Tech Tree UI64 Icon Binding
- Started from `95752d1 수정`, where local `main` matched `origin/main` and `assets/ui/tech_icons_ui64/` was present.
- Required workflow/worldmap docs were read before touching runtime files.
- Implemented:
  - Added UI64 icon root and explicit UI64 filename map for all current domestic city/national tech definitions.
  - Added resolved icon path helper with UI64 -> existing `icon_path` -> `?` fallback order.
  - Updated Domestic Tech Tree icon rendering to use the resolved path even when definition `icon_path` is empty.
  - Added path-based texture caching for Domestic Tech Tree icon textures.
  - Left `assets/ui/tech_icons_ui64/etc/` unmapped.
- Preserved read-only tech tree behavior, left PLAYER national scope, right selected-city scope, enemy/insufficient-intel hiding, prerequisite lines, overlay top-layer behavior, hotfix4 lightweight node click selection, gameplay formulas, scenes, assets, existing icon PNG files, and `.import` files.
- Coverage result: 85 total domestic tech definitions, 85 UI64 mapped, 0 missing mapped files, 0 `etc/` mappings, 0 expected existing-icon fallback, and 0 expected remaining `?` fallback for current definitions.
- Manual F6 QA remains required for the v0.70-63-hotfix5 checklist.

## 2026-06-27

### v0.70-63-hotfix4 Domestic Tech Tree Click Latency & Icon Readability Polish
- Started from `dfc48ed v0.70-63-hotfix3 Domestic Tech Tree Node Text Restore & Click Responsiveness Fix`.
- Confirmed local `main` was clean and local HEAD matched the requested baseline before editing.
- Required workflow/worldmap docs were read before touching runtime files.
- Root cause: compact node click called `_refresh_domestic_tech_tree_overlay_mvp()`, rebuilding the full overlay, both tree panels, category graphs, lines, nodes, and icon controls before the detail inspector visibly settled.
- Implemented:
  - Split graph rebuild from node click selection.
  - Node click now stores selected ids, refreshes the detail inspector immediately, and updates only previous/current selected node card styles.
  - Compact node roots are registered by city/tech selection key at graph build time.
  - Increased compact icon UI slot to fixed integer `64px` and tuned `TextureRect` sizing/filter settings.
  - Adjusted compact node size and global graph spacing to preserve text and avoid overlap.
- Preserved read-only tech tree behavior, left PLAYER national scope, right selected-city scope, enemy/insufficient-intel hiding, prerequisite lines, overlay top-layer behavior, gameplay formulas, scenes, icon PNG files, `.import` files, and no-new-thumbnail-asset policy.
- Verification:
  - `git diff --check`
  - click handler / detail inspector update keyword search
  - graph rebuild call path search
  - selected node style update keyword search
  - mouse_filter / gui_input search
  - icon size / TextureRect / stretch mode keyword search
  - graph spacing / stack spacing / category height search
  - removed copy search
  - modal/top-layer guard search
  - enemy-intel hiding guard search
  - warning cleanup regression search
  - tech icon PNG no-touch check
  - `.import` no-touch check
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-63-hotfix4 checklist.

### v0.70-63-hotfix3 Domestic Tech Tree Node Text Restore & Click Responsiveness Fix
- Started from `32f92d2 v0.70-63-hotfix2 Domestic Tech Tree Global Graph Spacing & Node Size Polish`.
- Confirmed local `main` was clean and local HEAD matched the requested baseline before editing.
- Required workflow/worldmap docs were read before touching runtime files.
- Implemented:
  - Restored compact node tech name/status visibility with an icon-left, text-right layout.
  - Kept compact node content limited to icon or `?`, tech name, rarity `★`, and short state.
  - Made compact node child icon/text/layout controls ignore mouse input so the root card remains the click target.
  - Preserved display-only node selection with selected highlight and detail inspector refresh.
  - Changed graph row placement to reserve extra vertical space for same-branch/same-tier stacks before the next branch row.
  - Removed developer-facing overlay copy and changed the title to `EASTWAR 테크트리`.
  - Retuned compact graph icon display size through fixed integer UI sizing only.
  - Added `v0.70-63-hotfix3 Domestic Tech Tree Node Text Restore & Click Responsiveness Fix Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved left PLAYER national tree, right selected-city tree, enemy/insufficient-intel city detail hiding, detail inspector, prerequisite lines, city/national domestic tech state normalization, enemy pressure plan locks, pending invasion/BattleContext locks, income/resource/troop/battle/diplomacy/spy formulas, scenes, icon PNG files, and `.import` files.
- Verification:
  - `git diff --check`
  - node title/status label keyword search
  - detail inspector update/click handler keyword search
  - mouse_filter / gui_input search
  - graph line layer mouse ignore search
  - graph spacing / stack spacing / category height calculation search
  - removed copy search
  - branch label localization regression search
  - modal/top-layer guard search
  - enemy-intel hiding guard search
  - warning-cleanup regression searches
  - tech icon PNG no-touch check
  - `.import` no-touch check
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-63-hotfix3 checklist.

## 2026-06-26

### v0.70-63-hotfix2 Domestic Tech Tree Global Graph Spacing & Node Size Polish
- Started from `6b22491 v0.70-63-hotfix1 Compact Tech Node & Detail Inspector Polish`.
- Confirmed local `main` was clean and local HEAD/origin main matched the requested baseline before editing.
- Required workflow/worldmap docs were read before touching runtime files.
- Implemented:
  - Added shared category section margins for the national and city Domestic Tech Tree graph lists.
  - Increased graph top margin, branch row spacing, same-branch stack spacing, and next-category separation as global layout constants.
  - Rebalanced compact graph nodes to one fixed smaller size with tighter internal padding and reduced lower empty space.
  - Increased compact graph icon display size through UI helper parameters while preserving the existing icon assets and `?` fallback.
  - Added missing display-only Korean branch label mappings for `inspection`, `population`, `monopoly`, and `archer`.
  - Added `v0.70-63-hotfix2 Domestic Tech Tree Global Graph Spacing & Node Size Polish Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved left PLAYER national tree, right selected-city tree, enemy/insufficient-intel city detail hiding, detail inspector, city/national domestic tech state normalization, enemy pressure plan locks, pending invasion/BattleContext locks, income/resource/troop/battle/diplomacy/spy formulas, scenes, icon PNG files, and `.import` files.
- Verification:
  - `git diff --check`
  - domestic tech graph constant / spacing keyword search
  - compact node / icon / label helper keyword search
  - branch label localization keyword search
  - modal/top-layer guard search
  - enemy-intel hiding guard search
  - warning-cleanup regression searches
  - tech icon PNG no-touch check
  - `.import` no-touch check
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-63-hotfix2 checklist.

### v0.70-63-hotfix1 Compact Tech Node & Detail Inspector Polish
- Started from `ad1d812 v0.70-63 Domestic Tech Tree Branch Graph UI MVP`.
- Confirmed local `main` was clean and ahead of `origin/main` by the expected unpublished v0.70-62 through v0.70-63 commits, fetched `origin/main`, and verified local HEAD matched the requested baseline before editing.
- Required workflow/worldmap docs were read before touching runtime files.
- Implemented:
  - Reduced Domestic Tech Tree graph node dimensions and branch/tier spacing for compact graph readability.
  - Replaced the full-info graph card builder with compact nodes showing icon or `?`, tech name, rarity `★`, and short state only.
  - Added display-only node click selection and selected-node highlight.
  - Added a bottom `DomesticTechDetailInspectorMVP` panel for full selected-tech details: scope, category/branch/tier, effect, cost, duration hint, state, prerequisites, national requirements, special requirements, lock reasons, and missing-icon note.
  - Preserved prerequisite `ColorRect` graph lines and v0.70-62-hotfix1 modal/top-layer behavior.
  - Added `v0.70-63-hotfix1 Compact Tech Node & Detail Inspector Polish Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved left PLAYER national tree, right selected-city tree, enemy/insufficient-intel city detail hiding, city/national domestic tech state normalization, enemy pressure plan locks, pending invasion/BattleContext locks, income/resource/troop/battle/diplomacy/spy formulas, scenes, icon PNG files, and `.import` files.
- Verification:
  - `git diff --check`
  - compact/detail inspector keyword search
  - graph lock keyword search
  - modal lock search
  - domestic tech UI lock search
  - tech icon PNG no-touch check
  - `.import` no-touch check
  - guard keyword search
  - warning-cleanup regression searches
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-63-hotfix1 checklist.

### v0.70-63 Domestic Tech Tree Branch Graph UI MVP
- Started from `9c2e830 v0.70-62-hotfix1 Fullscreen Tech Tree Modal Fix`.
- Confirmed local `main` was clean and ahead of `origin/main` by the expected v0.70-62 and v0.70-62-hotfix1 commits, fetched `origin/main`, and verified local HEAD matched the requested baseline before editing.
- Required workflow/worldmap docs were read before touching runtime files.
- Implemented:
  - Added domestic tech graph layout constants.
  - Replaced category grid rendering with `DomesticTechGraphCanvas` sections.
  - Positioned graph nodes by branch row and tier column, stacking same branch/tier nodes vertically.
  - Added `ColorRect` prerequisite line segments behind nodes, with state-based line colors.
  - Reused the existing read-only node card, icon fallback, state, cost/effect, and lock reason rendering.
  - Preserved v0.70-62-hotfix1 modal/top-layer behavior.
  - Added `v0.70-63 Domestic Tech Tree Branch Graph UI MVP Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved left PLAYER national tree, right selected-city tree, enemy/insufficient-intel city detail hiding, city/national domestic tech state normalization, enemy pressure plan locks, pending invasion/BattleContext locks, income/resource/troop/battle/diplomacy/spy formulas, scenes, icon PNG files, and `.import` files.
- Verification:
  - `git diff --check`
  - graph UI keyword search
  - modal lock search
  - domestic tech UI lock search
  - tech icon PNG no-touch check
  - `.import` no-touch check
  - guard keyword search
  - warning-cleanup regression searches
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-63 checklist.

### v0.70-62-hotfix1 Fullscreen Tech Tree Modal Fix
- Started from `3f2cff7 v0.70-62 Domestic Tech Tree Fullscreen Read-Only UI MVP`.
- Confirmed local `main` was clean and ahead of `origin/main` by the expected v0.70-62 commit, fetched `origin/main`, and verified local HEAD matched the requested baseline before editing.
- Required workflow/worldmap docs were read before touching runtime files.
- Implemented:
  - Promoted `tech_tree_overlay_mvp` to high z-index top-layer modal behavior and call `move_to_front()` on open.
  - Added `_tech_tree_hidden_ui_state_mvp` plus hide/restore helpers for overlapping worldmap floating/detail panels.
  - Restores only the panels' pre-open `visible` states when the overlay closes.
  - Consumes unhandled background input while the tech tree overlay is open and keeps ESC / `닫기` close behavior.
  - Added `v0.70-62-hotfix1 Fullscreen Tech Tree Modal Fix Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-62 read-only tech tree content, left PLAYER national tree, right selected-city tree, Fog of War / `city_intel` enemy city hiding, icon `?` fallback, locked/special lock display, v0.70-61 state normalization, enemy pressure plan locks, pending invasion/BattleContext locks, scenes, icon PNG files, and `.import` files.
- Verification:
  - `git diff --check`
  - tech icon PNG no-touch check
  - `.import` no-touch check
  - modal hotfix keyword search
  - domestic tech UI lock search
  - guard keyword search
  - warning-cleanup regression searches
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load, with existing debug output only
- Manual F6 QA remains required for the v0.70-62-hotfix1 checklist.

### v0.70-62 Domestic Tech Tree Fullscreen Read-Only UI MVP
- Started from `208e326 v0.70-61 Domestic Tech Tree Confirmed Design Foundation MVP`.
- Confirmed local `main` was clean, fetched `origin/main`, and verified local HEAD matched the requested baseline before editing.
- Required workflow/worldmap docs were read before touching runtime files.
- Implemented:
  - Added a 월드맵 `테크트리` button.
  - Added fullscreen read-only `tech_tree_overlay_mvp` under `WorldMapUI`, with `닫기` and ESC close behavior.
  - Added left PLAYER national tech tree rendering and right selected-player-city tech tree rendering.
  - Added no-city guidance and enemy/insufficient-intel city detail hiding under Fog of War / `city_intel` policy.
  - Added tech node icon loading with `?` fallback, `★` rarity, cost/effect text, completed/available/locked/special_locked state display, gray locked styling, `[잠김]`, and compact lock reason text.
  - Added `v0.70-62 Domestic Tech Tree Fullscreen Read-Only UI MVP Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-61 domestic tech state normalization, v0.70-60 pressure balance, v0.70-59 strategy hint UX, v0.70-58 replay lock, pending invasion/BattleContext locks, left PLAYER scope, right selected-city scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, scenes, icon PNG files, and `.import` files.
- Verification:
  - `git diff --check`
  - tech icon no-touch check
  - `.import` no-touch check
  - domestic tech UI keyword search
  - domestic tech foundation search
  - guard keyword search
  - warning-cleanup regression searches for `seed`, `target_label`, `resource_label`, `selected_city_id`, `loyalty_card`, and `func .*sign`
  - project headless load
  - `WorldMap_Test.tscn` headless load, including hidden overlay construction
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-62 checklist.

## 2026-06-25

### v0.70-61 Domestic Tech Tree Confirmed Design Foundation MVP
- Started from `78ab5e4 테크트리 준비`.
- Confirmed local `main` was clean, fetched `origin/main`, and verified local HEAD and origin/main matched the requested baseline before editing.
- Required workflow/worldmap docs and similar confirmed tech design docs were read before touching runtime files.
- Implemented:
  - Added confirmed-design domestic city and national tech definition foundation helpers.
  - Added category/branch/scope lookup, definition lookup, prerequisite/national requirement, availability, icon path, icon missing, and fallback-label helpers.
  - Added save/load-safe normalization for `city_domestic_tech_completed`, `city_domestic_tech_unlocked`, `national_domestic_tech_completed`, and `national_domestic_tech_unlocked`.
  - Kept all new domestic `effect_stub` entries disabled and disconnected from actual gameplay formulas.
  - Added `v0.70-61 Domestic Tech Tree Confirmed Design Foundation MVP Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-60 pressure balance, v0.70-59 strategy hint UX, v0.70-58 replay lock, pending invasion/BattleContext locks, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, scenes, icon PNG files, and `.import` files.
- Manual F6 QA remains required for the v0.70-61 checklist.

### v0.70-60 Enemy Pressure Balance Pass
- Started from `7491790 v0.70-59 Enemy Strategy Hint UX Polish`.
- Confirmed local `main` was clean, fetched `origin/main`, and verified local HEAD matched the requested baseline before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- QA audit:
  - Checked pressure plan bonus use in reinforcement target scoring, strategic diplomacy scoring, strategic spy pressure scoring, and invasion pair scoring.
  - Confirmed v0.70-59 hint UX and v0.70-58 save/load/replay locks remain the active display and scoring safety boundaries.
- Implemented:
  - Lowered pressure plan target/source/adjacency and pressure-type bonus values.
  - Added purpose caps for reinforcement, strategic diplomacy, strategic spy, and invasion pressure bonuses.
  - Added invalid city guards so malformed saved plan source/target ids do not contribute scoring bonuses.
  - Moved invasion base-score guard before pressure bonus application so pressure does not revive zero/negative base pair scores.
  - Added `v0.70-60 Enemy Pressure Balance Pass Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-59 strategy hint UX, v0.70-58 pressure plan replay/scoring lock, v0.70-56 pending BattleContext guards, v0.70-56-hotfix1 warning cleanup, reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext shape, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, `.ogv`, and `assets/ui/tech_icons` PNG files.
- Verification:
  - `git diff --check`
  - tech icon no-touch check
  - guard keyword search
  - warning-cleanup regression searches for `seed`, `target_label`, `resource_label`, `selected_city_id`, `loyalty_card`, and `func .*sign`
  - internal id exposure risk search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-60 checklist.

### v0.70-59 Enemy Strategy Hint UX Polish
- Started from `ac3939e v0.70-58 Enemy Pressure Plan QA Replay Pending SaveLoad Lock`.
- Confirmed local `main` was clean and ahead of `origin/main` by the expected v0.70-58 commit, fetched `origin/main`, and verified local HEAD matched the requested baseline before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- QA audit:
  - Checked pressure plan, strategic action, pending invasion, enemy turn summary, save/load display, Fog/city_intel, and panel-scope display boundaries.
  - Confirmed this pass stays display-only and does not touch scoring, generation, pending invasion payload, or BattleContext.
- Implemented:
  - Added safe label filtering, line clamp, and unique-line append helpers for enemy hints.
  - Added compact pressure plan and pending invasion hint formatters.
  - Changed enemy strategic action copy to abstract `외교 압박` / `첩보 압박` wording.
  - Changed summary/hint output from detailed enemy troop delta lines to compact action counts.
  - Added `v0.70-59 Enemy Strategy Hint UX Polish Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-58 pressure plan replay/scoring lock, v0.70-56 pending BattleContext guards, v0.70-56-hotfix1 warning cleanup, reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext shape, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, `.ogv`, and `assets/ui/tech_icons` PNG files.
- Verification:
  - `git diff --check`
  - tech icon no-touch check
  - guard keyword search
  - warning-cleanup regression searches for `seed`, `target_label`, `resource_label`, `selected_city_id`, `loyalty_card`, and `func .*sign`
  - internal id exposure risk search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-59 checklist.

### v0.70-58 Enemy Pressure Plan QA Replay Pending SaveLoad Lock
- Started from `70a1e93 내정테크아이콘`.
- Confirmed clean worktree, fetched `origin/main`, and verified local HEAD and `origin/main` matched the requested baseline before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- QA audit:
  - Checked pressure plan generation guard, same-turn replay guard, pending invasion guard, pending BattleContext guard, save/load display normalization, summary/hint compactness, and scoring helper use.
  - Confirmed pressure plan remains max one per world turn and `effect = display_scoring_only`.
  - Confirmed pending invasion and pending BattleContext guards are still in the pressure plan, strategic action, invasion roll, and turn-end paths.
- Implemented:
  - Prevented missing `turn_number` pressure plan payloads from normalizing to the current turn.
  - Added a current-turn match guard before pressure plan scoring hints are used.
  - Changed the detailed pressure plan hint line to `적 전략: 세력 · 목표` to avoid repeated label noise.
  - Added `v0.70-58 Enemy Pressure Plan QA Replay Pending SaveLoad Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved Enemy Strategic AI Phase 2 ban, enemy spy actual damage ban, enemy diplomacy alliance/trade simulation ban, enemy economy simulation ban, reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext shape, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, `.ogv`, and `assets/ui/tech_icons` PNG files.
- Verification:
  - `git diff --check`
  - tech icon no-touch check
  - guard keyword search
  - warning-cleanup regression searches for `seed`, `target_label`, `resource_label`, `selected_city_id`, `loyalty_card`, and `func .*sign`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-58 checklist.

### v0.70-57 Enemy Strategic AI Phase 1 Target Pressure Planner
- Started from `602a199 v0.70-56-hotfix1 GDScript Reload Shadowing Warning Fix`.
- Confirmed clean worktree, fetched `origin/main`, and verified local HEAD matched the requested baseline before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- Implemented:
  - Added `_player_state["last_enemy_pressure_plan_result"]` and `last_enemy_faction_turn_result.pressure_plan` display/history state.
  - Added pressure plan skip guard, candidate builder, candidate scoring, picker, display normalizer, scoring helper, and compact summary/hint display.
  - Connected pressure plan picking before enemy reinforcement/strategic action/invasion scoring in the enemy turn processing path.
  - Added small pressure-plan scoring bonuses to reinforcement, diplomacy/spy strategic action choice, and eligible invasion pair choice.
  - Added `v0.70-57 Enemy Strategic AI Phase 1 Target Pressure Planner Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-56 pending BattleContext guards, v0.70-56-hotfix1 warning cleanup, reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, strategic action max-one clamp, pending invasion payload, BattleContext shape, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - guard keyword search
  - warning-cleanup regression searches for `seed`, `target_label`, `resource_label`, `selected_city_id`, `loyalty_card`, and `func .*sign`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for the v0.70-57 checklist.

### v0.70-56-hotfix1 GDScript Reload Shadowing Warning Fix
- Started from `e06c174 v0.70-56 Enemy Turn Manual F6 QA Fix Pass`.
- Confirmed clean worktree, fetched `origin/main`, and verified local HEAD matched the requested baseline before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- Implemented:
  - Renamed local `seed` temporaries in enemy personality/strategic goal helpers to domain-specific names.
  - Renamed the diplomacy formatter target label local to avoid `target_label` block shadowing.
- Preserved enemy turn, personality, strategic goal, invasion, BattleContext, battle result, market, alliance, wedge, player action, `city_intel`, Fog of War, balance values, scenes, assets, `.uid`, and `.ogv` behavior.
- Verification:
  - `git diff --check`
  - warning keyword searches for `seed` and `target_label`
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required to confirm the two reload warnings stay absent in Godot Output.

### v0.70-56 Enemy Turn Manual F6 QA Fix Pass
- Started from `e96bbd4 v0.70-55 Enemy Goal QA Strategy Hint Polish`.
- Confirmed clean worktree, fetched `origin/main`, and verified local HEAD and `origin/main` both matched the requested baseline before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- QA audit:
  - Checked enemy turn replay guard through `_run_enemy_turn_mvp()` and `_process_enemy_faction_turn_mvp()`.
  - Checked reinforcement owner guards, one reinforcement per faction, and v0.70-46 constants.
  - Checked strategic action max-one behavior, non-player diplomacy, display-only spy pressure, and compact personality/goal labels.
  - Checked invasion roll guard, candidate eligibility, weak attacker guard, pending invasion duplicate guard, and personality/goal invasion scoring.
  - Checked defense deployment source/target semantics, deployable/command clamp, BattleContext handoff, and result apply safety paths.
  - Checked save/load clears pending invasion/context while preserving display/history normalization.
- Implemented:
  - Blocked player turn end while a pending battle context exists.
  - Blocked enemy invasion roll while a pending battle context exists.
  - Added `v0.70-56 Enemy Turn Manual F6 QA Fix Pass Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-51 enemy turn chain locks, v0.70-52 personality seed scope, v0.70-53 personality tuning guard, v0.70-54 strategic goal seed MVP lock, v0.70-55 goal hint polish, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext shape, defense deployment, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug output only.
- Manual F6 QA remains required for the v0.70-56 checklist.

### v0.70-55 Enemy Goal QA & Strategy Hint Polish
- Started from local `617883d v0.70-54 Enemy Strategic Goal Seed MVP`.
- Confirmed `main` was expectedly ahead of `origin/main` by one v0.70-54 commit, fetched `origin/main`, and verified the requested local HEAD before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- QA audit:
  - Confirmed strategic goal seed coverage for current non-player faction ids.
  - Confirmed target city ids are existing worldmap city ids and helper guards ignore missing targets.
  - Confirmed goal weights remain within the `1.00..1.15` helper clamp.
  - Confirmed v0.70-54 scoring remains a conservative nudge and does not overpower low-troop/frontline/personality scoring.
  - Confirmed strategic action, invasion, replay, hidden-data, and player-action guard boundaries remained unchanged.
- Implemented:
  - Added a goal-label display helper that hides default/empty goals and formats visible metadata as `목표: ...`.
  - Applied the helper to enemy strategic action summary and detailed faction-turn hint output.
  - Removed repeated goal label fragments from reinforcement one-line summaries to keep multi-faction summaries compact.
  - Added `v0.70-55 Enemy Goal QA & Strategy Hint Polish Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-51 enemy turn chain locks, v0.70-52 personality seed scope, v0.70-53 personality tuning guard, v0.70-54 strategic goal seed MVP lock, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext, defense deployment, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug output only.
- Manual F6 QA remains required for the v0.70-55 checklist.

### v0.70-54 Enemy Strategic Goal Seed MVP
- Started from `1952388 v0.70-53 Enemy Personality QA Balance Tuning Pass`.
- Confirmed clean worktree, expected HEAD, fetched `origin/main`, and confirmed local/origin HEAD match before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- Implemented:
  - Added `ENEMY_FACTION_STRATEGIC_GOAL_SEEDS` with default fallback, compact labels, pressure metadata, target city ids, region hints, and bounded weights.
  - Added goal helpers for fallback, PLAYER exclusion, malformed seed fallback, target city existence filtering, pressure lookup, and weight clamp.
  - Added small goal bonuses to reinforcement target scoring, diplomacy/spy strategic follow-up selection, and already eligible invasion pair scoring.
  - Added compact goal display metadata to reinforcement and strategic action payloads plus summary/hint copy.
  - Added `v0.70-54 Enemy Strategic Goal Seed MVP Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-51 enemy turn chain locks, v0.70-52 personality seed scope, v0.70-53 personality tuning guard, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext, defense deployment, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug output only.
- Manual F6 QA remains required for the v0.70-54 checklist.

## 2026-06-18

### v0.70-53 Enemy Personality QA & Balance Tuning Pass
- Started from `4ee0083 v0.70-52 Enemy Faction Personality Seed MVP`.
- Confirmed clean worktree, expected HEAD, fetched `origin/main`, and confirmed local/origin HEAD match before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- QA audit:
  - Confirmed personality helpers exclude PLAYER and fall back through `default_balanced`.
  - Confirmed current personality weights stay inside the bounded `0.75..1.25` helper clamp.
  - Confirmed reinforcement amount constants remain `+60` base, `+40` frontline, `+20` chancellor, max `+120`.
  - Confirmed strategic actions remain clamped to one display/action result and still skip pending invasion or pending battle context.
  - Confirmed invasion chance, minimum attacker troops, eligibility guards, pending payload, and BattleContext handoff remain unchanged.
- Implemented:
  - Added explicit `chu` balanced personality seed.
  - Changed `kyushu_faction` to `계략` / `schemer_pressure` with a modest spy-pressure lean.
  - Reduced spy-pressure strategic scoring base/troop/frontline bonus so diplomacy profiles are not overwhelmed by default spy candidates.
  - Guarded invasion pair personality weighting to affect only positive eligible-pair scores.
  - Added `v0.70-53 Enemy Personality QA & Balance Tuning Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-51 enemy turn chain locks, v0.70-49 invasion guards, v0.70-50 strategic action guard, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext, defense deployment, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug output only.
- Manual F6 QA remains required for the v0.70-53 checklist.

### v0.70-52 Enemy Faction Personality Seed MVP
- Started from `682c100 v0.70-51 Enemy Turn QA Pass Manual F6 Feedback Polish`.
- Confirmed clean worktree, expected HEAD, fetched `origin/main`, and confirmed local/origin HEAD match before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- Implemented:
  - Added bounded non-player enemy faction personality seeds with `default_balanced` fallback.
  - Added profile helpers for profile id, compact label, and behavior weights.
  - Reworked enemy reinforcement target choice into a small score helper that biases already-owned candidates by low troops and frontline preference.
  - Added personality-influenced candidate scores for enemy diplomacy follow-up and display-only spy pressure, while keeping one strategic action per world turn.
  - Added a small personality multiplier to already eligible invasion pair scoring without changing invasion chance or eligibility.
  - Added compact personality labels to enemy reinforcement and strategic action display metadata.
  - Added `v0.70-52 Enemy Faction Personality Seed MVP Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-51 enemy turn chain locks, v0.70-49 invasion guards, v0.70-50 strategic action guard, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext, defense deployment, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug output only.
- Manual F6 QA remains required for the v0.70-52 checklist.

### v0.70-51 Enemy Turn QA Pass & Manual F6 Feedback Polish
- Started from `7fa73bf v0.70-50 Enemy Faction Diplomacy Spy Behavior Follow-up`.
- Confirmed clean worktree, expected local HEAD, fetched `origin/main`, and confirmed baseline before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- Audited enemy reinforcement replay guard, strategic action max-one behavior, pending invasion/pending battle skips, invasion roll guard, defense deployment source/target semantics, command/deployable clamp, BattleContext handoff, invasion/player-attack result separation, and save/load replay safety.
- Implemented:
  - Added enemy faction turn result display normalization for loaded or malformed payloads.
  - Clamped `strategic_actions` to at most one valid supported action.
  - Rejected malformed enemy diplomacy display entries involving PLAYER.
  - Forced enemy spy pressure display entries to `effect = "display_only"`.
  - Synced `last_enemy_strategic_action_result` from normalized `strategic_actions`.
  - Added `v0.70-51 Enemy Turn QA Pass Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-49 invasion guards, v0.70-50 strategic action guard, reinforcement balance, `ENEMY_INVASION_CHANCE`, pending invasion payload, BattleContext, defense deployment, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player spy/diplomacy actions, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug output only.
- Manual F6 QA remains required for the v0.70-51 checklist.

### v0.70-50 Enemy Faction Diplomacy/Spy Behavior Follow-up
- Started from `1d00fb4 v0.70-49 Enemy Invasion Defense Balance Polish`.
- Confirmed clean worktree, expected HEAD, fetched `origin/main`, and confirmed local/origin HEAD match before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- Audited enemy faction turn replay/result flow, faction relation helpers, spy/city-intel locks, pending invasion guards, and summary/hint output.
- Implemented:
  - Added `strategic_actions` to enemy faction turn result while preserving reinforcement `actions`.
  - Added display/history `_player_state["last_enemy_strategic_action_result"]`.
  - Added at-most-one strategic follow-up per world turn under the existing enemy faction replay guard.
  - Skipped strategic follow-up when pending invasion or pending battle context exists.
  - Added non-player-only diplomacy drift using existing relation score helper with conservative `±3` delta and no status/alliance/trade mutation.
  - Added display-only enemy spy pressure against player-owned cities adjacent to safe enemy-owned cities.
  - Integrated compact `적 외교` / `적 첩보` lines into enemy turn summary/hint output.
  - Added `v0.70-50 Enemy Faction Diplomacy/Spy Behavior Follow-up Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved v0.70-49 invasion guards, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload, BattleContext, player attack/defense deployment, battle result apply, left/right panel scope, Fog of War, `city_intel`, market/alliance/wedge behavior, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug output only.
- Manual F6 QA remains required for the v0.70-50 checklist: reinforcement display, one strategic action per turn, non-player diplomacy drift safety, display-only spy pressure, compact summary, pending invasion continuity, save/load replay safety, panel scope/Fog of War, existing player actions, and warning cleanliness.

### v0.70-49 Enemy Invasion/Defense Balance Polish
- Started from `669da79 v0.70-47 WorldMap Strategic UX Final Polish`.
- Confirmed clean worktree, expected HEAD, fetched `origin/main`, and confirmed local/origin HEAD match before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- Audited enemy invasion candidate generation, pending event creation, defense deployment validation, BattleContext build/handoff, and invasion result application.
- Implemented:
  - Added `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS = 160` to keep weak enemy cities out of invasion-start candidates without changing result/occupation troop constants.
  - Added invasion pair eligibility checks for missing city data, marker/HUD owner mismatch, wrong owner scope, non-adjacent pairs, and attacker troop readiness.
  - Added simple eligible-pair scoring/sorting to prefer stronger attacker cities and plausible adjacent player targets while keeping the existing roll chance.
  - Reused eligibility checks for pending invasion event creation and pending invasion BattleContext validation.
  - Added a safe unknown-result path when an enemy invasion battle result lacks attacker/source city data.
  - Added `v0.70-49 Enemy Invasion/Defense Balance Polish Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved `ENEMY_INVASION_CHANCE = 0.45`, `enemy_invasion_roll_turn`, enemy faction replay guard, pending event payload keys, BattleContext key/shape, Battle scene logic, player attack system scope, left/right panel scope, Fog of War, market/alliance/wedge behavior, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Scene loads emitted existing debug output only.
- Manual F6 QA remains required for the v0.70-49 checklist: invasion eligibility/frequency, duplicate pending guard, weak city exclusion, adjacent player targets, defense source/target UI, command/deployable clamp, BattleContext handoff, defender/attacker win handling, retreat/unknown safety, save/load replay guards, v0.70-47 scope locks, and warning cleanliness.

### v0.70-47 WorldMap Strategic UX Final Polish
- Started from `9704632 v0.70-46 Enemy Faction Turn Behavior QA Balance Polish`.
- Confirmed clean worktree, expected HEAD, fetched `origin/main`, and confirmed local/origin HEAD match before editing.
- Required workflow and worldmap docs were read before touching runtime files.
- Implemented:
  - Left World Status turn/calendar/phase copy was consolidated into a compact PLAYER-scope header line.
  - Right Selected City copy was tightened for player defense/domestic lines, enemy locked/revealed intel hints, pending invasion selected-city status, and Fog of War wording.
  - Unified City Detail resource, city storage, internal trade, external trade, manual trade, diplomacy, and spy hints/tooltips were polished.
  - Enemy turn summary and pending invasion hints now use compact `이번 턴 적 행동`, `침공 대기`, and `외 N건` wording.
  - Added `v0.70-47 WorldMap Strategic UX Final Polish Lock Rule` to `WORLDMAP_RULES.md`.
- Preserved formulas, costs, chances, cooldowns, validation gates, market prices, chancellor auto trade, alliance, wedge, spy/diplomacy effects, city-intel display-only behavior, enemy replay guard, pending invasion payload, BattleContext, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required guard keyword search
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug logs only.
- Manual F6 QA remains required for the v0.70-47 checklist: left PLAYER scope, right selected-city scope, player full info, no/partial intel locking, diplomacy/spy tooltips, market/trade copy with price parity, compact enemy phase summary, replay guards, pending invasion/BattleContext continuity, and warning cleanliness.

## 2026-06-15

### v0.70-46 Enemy Faction Turn Behavior QA & Balance Polish
- Started from `964d8db v0.70-45 Enemy Faction Turn Behavior MVP`.
- Confirmed clean worktree, `main`, expected HEAD, fetched `origin/main`, and confirmed local/origin HEAD match before editing.
- Required docs and enemy turn replay, reinforcement, pending invasion, market/alliance/wedge/city-intel/faction-chancellor, and warning-cleanup search paths were checked.
- QA audit:
  - `_player_state["last_enemy_faction_turn_processed_turn"]` remains the same-turn enemy reinforcement guard.
  - Save/load can restore `_player_state["last_enemy_faction_turn_result"]` as display/history state without replaying reinforcement.
  - Same-turn re-entry skips the enemy invasion roll when the enemy faction turn for that `turn_number` is already processed.
  - Pending invasion event generation still uses the existing `ENEMY_INVASION_CHANCE` and existing pending event/BattleContext flow.
  - Enemy behavior remains limited to enemy-owned city troop reinforcement and summary logging.
- Implemented:
  - Adjusted reinforcement from `base +80 / max +150` to `base +60 / max +120`; frontline `+40` and valid enemy chancellor seed `+20` remain.
  - Added marker/HUD owner mismatch guard for enemy turn city selection and reinforcement application.
  - Polished enemy turn summary/hint to compact omitted actions as `외 N건`.
- Preserved v0.70-39 market formulas, v0.70-40 alliance, v0.70-41 wedge, v0.70-42 Fog of War, spy/diplomacy formulas, player chancellor candidate scope, `_player_state["faction_chancellors"]` structure, left/right panel scope, BattleContext, scenes, assets, `.uid`, and `.ogv`.
- Verification:
  - `git diff --check`
  - required enemy-turn/search verification
  - warning-cleanup regression search
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - Battle scene emitted existing debug logs only.
- Manual F6 QA remains required for enemy phase progression, compact enemy result log, once-per-turn reinforcement, `+120` clamp, frontline priority, no direct player city/resource mutation, replay guards, pending invasion continuity/no duplication, Fog of War, wedge, alliance, market pricing, Hanseong chancellor candidate scope, foreign-city left panel scope, and warning cleanliness.

## 2026-06-14

### v0.70-45 Enemy Faction Turn Behavior MVP
- Started from `cc977ad v0.70-44 WorldMap Domestic Turn Flow QA Polish`.
- Confirmed clean worktree, `main`, expected HEAD, and fetched `origin/main` before editing.
- Required docs and enemy phase, pending invasion, city ownership, city troop, faction chancellor, save/load, left-status, and warning-cleanup search paths were checked.
- Implemented:
  - Added `_player_state["last_enemy_faction_turn_result"]` and `_player_state["last_enemy_faction_turn_processed_turn"]`.
  - Added enemy faction selection for non-player factions with owned cities.
  - Added per-faction one-action city selection: player-adjacent frontline first, then lowest-troop owned city.
  - Added conservative enemy city reinforcement using existing city troop getter/setter only.
  - Added enemy chancellor seed bonus from existing `_player_state["faction_chancellors"]`.
  - Connected existing enemy invasion event roll result into the enemy turn result payload.
  - Added compact enemy turn result hint to the left world status without changing PLAYER/nation scope.
  - Renamed an existing chancellor internal auto-trade source local to keep the warning-cleanup `selected_city_id` search pattern clear.
- Reinforcement rule:
  - Base `+80`, frontline `+40`, valid enemy chancellor seed `+20`, max `+150`.
- Save/load safety:
  - Result and processed-turn guard persist through `_player_state`.
  - Load restores display/history only and does not replay reinforcement or rerun the same-turn enemy invasion roll.
- Preserved v0.70-39 market formulas, v0.70-40 alliance, v0.70-41 wedge, v0.70-42 Fog of War, spy/diplomacy formulas, player chancellor candidate scope, `faction_chancellors` structure, left/right panel scope, BattleContext, scenes, assets, `.uid`, and `.ogv`.
- Manual F6 QA remains required for enemy phase progression, enemy result log, enemy troop reinforcement, no direct player city/resource mutation, same-turn replay guard, pending invasion continuity/no duplication, save/load replay guard, Fog of War, wedge, alliance, market pricing, Hanseong chancellor candidate scope, foreign-city left panel scope, and warning cleanliness.

### v0.70-44 WorldMap Domestic/Turn Flow QA & Polish
- Started from `aa7ba35 v0.70-43 WorldMap Diplomacy Spy Intel Final QA Pass`.
- Confirmed clean worktree, `main`, expected HEAD, and fetched `origin/main` before editing.
- Required docs and turn/domestic/market/diplomacy/spy/city-intel/pending-invasion/save-load/warning-cleanup search paths were checked.
- QA audit:
  - Player turn end enters enemy phase, sets `domestic_apply_pending`, runs the enemy placeholder, applies domestic once at enemy-turn finish, advances `turn_number`, then returns to player phase.
  - `_player_state["last_domestic_apply_turn"]` prevents same-turn domestic replay and protects player resource stock / city storage from double apply.
  - Save/load restores player phase, clears pending enemy/invasion runtime state, clears `domestic_apply_pending`, and does not replay already stored domestic result payloads.
  - Trade market state remains current-turn scoped through `last_trade_market_result`, `trade_market_prices`, and `trade_market_turn`; pending manual preview recalculates from current market and relation efficiency.
  - `_player_state["last_chancellor_auto_trade_turn"]` prevents same-turn chancellor auto trade replay.
  - Diplomacy action cooldowns, trade agreement duration, and alliance duration decrement in the world-turn cooldown helper; alliance expiry returns to neutral without overwriting trade agreement state.
  - Spy cooldown and `revolt_instigation` duration tick once per world turn; `last_spy_wedge_result` remains display/history state and load does not replay wedge effects.
  - `_player_state["city_intel"]` remains display-only; failed `정탐` does not record intel and enemy no-intel display remains locked.
  - Left panel player/nation scope, player chancellor candidate city roster scope, and `_player_state["faction_chancellors"]` remain intact.
- Code change 없음 / domestic-turn flow QA + docs update.
- Documentation updated for QA pass results, preserved scope, verification, next candidates, and manual F6 QA.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required domestic, market, alliance, spy, city intel, faction chancellor, pending invasion, and warning-cleanup searches
- Manual F6 QA remains required for turn labels, same-turn domestic guard, save/load replay guard, market refresh, chancellor auto trade guard, diplomacy/alliance ticks, spy/revolt ticks, city_intel display restore, pending invasion continuity, left panel player scope, Hanseong chancellor candidate scope, and Godot Output warning cleanliness.

### v0.70-43 WorldMap Diplomacy/Spy/Intel Final QA Pass
- Started from `7e0d27b v0.70-42 Enemy Intel UI Polish / Fog of War`.
- Confirmed clean worktree, `main`, expected HEAD, and fetched `origin/main` before editing.
- Required docs and market, alliance, wedge, city intel, chancellor candidate, faction chancellor, and warning-cleanup search paths were checked.
- QA audit:
  - v0.70-39 market pricing still uses `MANUAL_TRADE_PREVIEW_PRICES` as base authority and `_get_trade_market_price()` through shared import/export helpers.
  - v0.70-40 alliance proposal remains validation-first, stores `alliance_turns_remaining`, mirrors display state, and keeps trade agreement state separate.
  - v0.70-41 wedge remains selected-foreign-city scoped, excludes PLAYER from target-counterpart pairs, spends resources only on rolled attempts, and applies detection penalty only to PLAYER-target relations.
  - v0.70-42 city intel remains display-only, failed `정탐` does not record city intel, and UI reveals only payload-backed fields.
  - Chancellor candidate scope and `_player_state["faction_chancellors"]` seed state remain intact.
- Code change 없음: no runtime script edits were required.
- Documentation updated for QA pass results, preserved scope, verification, next candidates, and manual F6 QA.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required market, alliance, wedge, city intel, faction chancellor, and warning-cleanup searches
- Manual F6 QA remains required for player-city full display, enemy no-intel lock, field-by-field intel reveal, failed spy behavior, save/load display restore, market price parity, alliance accepted/rejected/expiry, wedge success/detection/alliance-break, left panel national scope, chancellor candidate scope, and Godot Output warning cleanliness.

### v0.70-42 Enemy Intel UI Polish / Fog of War
- Started from `aae97d1 v0.70-41 Spy Action Polish / Alienation MVP`.
- Confirmed clean worktree, `main`, expected HEAD, and fetched `origin/main` before editing.
- Required docs and enemy intel, city intel, wedge, alliance, market, faction chancellor, and warning-cleanup search paths were checked.
- Implemented:
  - Added payload-backed enemy intel reveal helpers to the right selected City Info panel.
  - Added explicit enemy intel levels: `미확인`, `기초 정탐`, `군사 정탐`, `군사/자원 정탐`, `내정 정탐`, and `상세 정탐`.
  - Added revealed/locked field summaries for 병력 추정, 병력, 자원, 민심, 충성도, 태수, and 기술.
  - Updated enemy city loyalty, public support, governor, garrison, military, domestic, resource, and tech copy to distinguish `정탐 필요` from `추가 정탐 필요`.
  - Updated spy-tab visibility and known-info summaries to match the right selected city panel's intel level/revealed/locked wording.
- Preserved player-owned city full display, existing spy formulas/effects, v0.70-41 wedge, v0.70-40 alliance proposal, v0.70-39 market pricing, chancellor candidate scope, `faction_chancellors`, left national panel scope, right selected-city scope, BattleContext, Selected City Panel behavior, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required enemy intel, city intel, wedge, alliance, market, faction chancellor, and warning-cleanup searches
- Manual F6 QA remains required for player-city full display, no-intel enemy locking, partial/full intel display, spy-tab/right-panel wording parity, failed spy not opening intel, save/load city intel display, wedge/alliance/market regressions, chancellor candidate scope, left panel scope, and Godot Output warning cleanliness.

### v0.70-41 Spy Action Polish / Alienation MVP
- Started from `0f516a7 v0.70-40 Diplomacy Action Polish / Alliance MVP`.
- Confirmed clean worktree, `main`, expected HEAD, and fetched `origin/main` before editing.
- Required docs and spy action, wedge, faction relation, city intel, faction chancellor, alliance, market, and warning-cleanup search paths were checked.
- Implemented:
  - Added spy action id `wedge` and runtime `이간질` button to the spy action card.
  - Added selected-city validation for wedge using existing foreign target, chancellor, political aptitude, cooldown, and iron-wall gates.
  - Added automatic target-counterpart faction selection that excludes PLAYER/self pairs and prioritizes allied or high-score non-player relations.
  - Connected `SPY_WEDGE_COST`, `SPY_WEDGE_COOLDOWN_TURNS`, and `SPY_DETECTED_RELATION_PENALTY_WEDGE`.
  - Charged wedge cost on rolled attempts, applied spy cooldown, and stored `_player_state["last_spy_wedge_result"]`.
  - Successful wedge attempts lower target-counterpart relation score and can break active allied status if the resulting score is below `ALLIANCE_ACCEPTANCE_THRESHOLD`.
  - Detection applies a PLAYER-target faction relation penalty and can happen alongside a successful wedge.
  - Updated recent spy result and turn-summary display paths for wedge success, failure, detection, and alliance break metadata.
- Preserved existing spy action formulas/effects, v0.70-40 alliance proposal flow, v0.70-39 market pricing, city intel visibility filtering, player chancellor candidate scope, `faction_chancellors`, left national panel scope, right selected-city scope, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required wedge, market, city intel, faction chancellor, alliance, and warning-cleanup searches
- Manual F6 QA remains required for wedge button/status, counterpart selection, insufficient resources, relation decrease, alliance break, detection penalty, spy cooldown, save/load state, existing spy/diplomacy/trade regressions, enemy intel lock, chancellor candidate scope, left panel scope, and Godot Output warning cleanliness.

### v0.70-40 Diplomacy Action Polish / Alliance MVP
- Started from `84bbf9c v0.70-39 Trade Market / Price Variation MVP`.
- Confirmed clean worktree, `main`, expected HEAD, and fetched `origin/main` before editing.
- Required docs and alliance/diplomacy action, market, city intel, faction chancellor, and warning-cleanup search paths were checked.
- Implemented:
  - Added diplomacy action id `alliance_proposal` and a `동맹 제안` runtime button to the diplomacy action card.
  - Added alliance validation for invalid/player targets, hostile/suspended relations, existing active alliances, diplomacy cooldown, and proposal resource costs.
  - Reused `_calculate_alliance_acceptance_chance()` and `ALLIANCE_ACCEPTANCE_THRESHOLD` for accepted/rejected result payloads.
  - Connected accepted proposals to relation `allied` state with 8-turn `alliance_turns_remaining`.
  - Mirrored active alliance relation entries to `_player_state["alliances"]` for save/load fallback.
  - Stored alliance results in `_player_state["last_alliance_proposal_result"]` and `_player_state["last_diplomacy_action_result"]`.
  - Extended diplomacy cooldown advancement to decrement alliance duration and expire alliances to neutral.
- Preserved v0.70-39 market price formulas/state, existing diplomacy actions, spy formulas/effects, player chancellor candidate scope, `faction_chancellors`, enemy city intel visibility filter, left panel scope, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required alliance, market, city intel, faction chancellor, and warning-cleanup searches
- Manual F6 QA remains required for alliance button/status display, accepted/rejected/cost-shortage outcomes, cooldown and duration ticks, expiry to neutral, save/load duration/result persistence, existing diplomacy actions, market pricing, chancellor candidate scope, left panel scope, enemy intel lock, and Godot Output warning cleanliness.

### v0.70-39 Trade Market / Price Variation MVP
- Started from `71c61f3 v0.70-38-hotfix1 Chancellor Candidate Scope & Enemy Chancellor Seed`.
- Confirmed clean worktree, `main`, expected HEAD, and fetched `origin/main` before editing.
- Required docs and trade market, manual external trade, chancellor external auto trade, hotfix1 chancellor scope, city intel, and warning-cleanup search paths were checked.
- Implemented:
  - Changed trade market base prices to use `MANUAL_TRADE_PREVIEW_PRICES`.
  - Normalized market result payloads and mirrored same-turn state to `_player_state["trade_market_prices"]` / `_player_state["trade_market_turn"]`.
  - Added `_ensure_trade_market_for_current_turn()` to keep save/load and preview/execution on the same turn-scoped market state.
  - Connected `_calculate_trade_import_cost()` and `_calculate_trade_export_gain()` to `_get_trade_market_price()`.
  - Added market turn/price metadata to manual execution and chancellor external auto trade result payloads.
  - Added compact market price/delta copy to external manual trade relation and preview UI.
- Pricing:
  - Import cost: `ceil(market_price * amount / efficiency)`.
  - Export gain: `floor(market_price * amount * efficiency)`.
- Preserved left national panel scope lock, player chancellor candidate scope, `faction_chancellors`, enemy city intel visibility filter, spy/diplomacy formulas, target city storage rules, foreign stock, relation score behavior, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required trade market, hotfix scope, city intel, and warning-cleanup searches
- Manual F6 QA remains required for market display, manual preview/execution parity, relation efficiency over market price, chancellor external auto trade pricing, save/load same-turn market persistence, once-per-turn refresh, chancellor candidate scope, left panel scope, enemy intel lock, and Godot Output warning cleanliness.

### v0.70-38-hotfix1 Chancellor Candidate Scope & Enemy Chancellor Seed
- Started from `6b61e1f v0.70-38 Enemy City Intel Visibility Filter`.
- Confirmed clean worktree and expected HEAD before editing.
- Required docs and chancellor candidate, city roster, hero ownership, faction relation, city intel, and warning-cleanup search paths were checked.
- Root cause:
  - `v0.70-37-hotfix1` moved left-panel chancellor UI to national scope, but `_get_player_chancellor_candidate_hero_ids()` still used all player-side `HERO_DATA`.
  - Player-side heroes stationed outside Hanseong, including Pyeongyang-stationed `cheok_jun_gyeong`, could therefore appear as Hanseong chancellor candidates.
- Implemented:
  - Added a player chancellor candidate city resolver: valid `capital_city_id`, then `hanseong`, then first valid player-owned city.
  - Limited player chancellor candidates to that city stationed roster plus existing aptitude/dead/captured validation.
  - Kept valid current chancellor display without auto-dismissal when the current assignment is outside the candidate city.
  - Added `_player_state["faction_chancellors"]` for non-player faction chancellor seed state.
  - Seeded enemy faction chancellors from faction-owned city stationed heroes by aptitude score, with stats fallback, and normalized the state during defaults/restore/save.
- Preserved left national panel scope lock, `v0.70-38` enemy city intel visibility filter, spy formulas/effects, diplomacy actions, trade pricing/efficiency, chancellor auto trade, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required chancellor, city intel, and warning-cleanup searches
- Manual F6 QA remains required for Hanseong dropdown candidate scope, current chancellor retention on foreign-city selection, spy action validation, enemy intel filter preservation, save/load seed state, and Godot Output warning cleanliness.

### v0.70-38 Enemy City Intel Visibility Filter
- Started from `f5b74da v0.70-37-hotfix1 Left National Panel Scope Lock`.
- Confirmed clean worktree and expected HEAD before editing.
- Required docs and city info panel, spy visibility, city intel, selected city info, left-panel scope, and warning-cleanup search paths were checked.
- Implemented:
  - Added enemy-city intel context setters and a foreign-city display branch to `WorldMapCityInfoPanel`.
  - Locked enemy city details behind `정탐 필요` / `추가 정탐 필요` unless city intel fields are known.
  - Preserved the existing full display path for player-owned cities.
  - Added `_player_state["city_intel"]` normalization and save/load fallback.
  - Recorded successful `정탐` payloads into the city intel registry.
  - Refreshed the selected city info panel after spy actions and updated spy-tab known-info summaries to read city intel.
- Preserved spy formulas/effect amounts, diplomacy actions, trade pricing/efficiency, chancellor auto trade, left national panel scope lock, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required city intel, spy payload, left panel, and warning-cleanup searches
- Manual F6 QA remains required for player-city full display, enemy-city locked display before intel, successful/failed `정탐` visibility behavior, save/load city intel, left panel national scope, and Godot Output warning cleanliness.

### v0.70-37-hotfix1 Left National Panel Scope Lock
- Started from `3c0a03b v0.70-37 Spy Action MVP`.
- Confirmed clean worktree and expected HEAD before editing.
- Required docs and left-panel, chancellor assignment, selected-city, spy validation, and warning-cleanup search paths were checked.
- Root cause:
  - `_refresh_left_world_status_panel()` passed selected-city data into chancellor sync/dropdown refresh.
  - `_sync_chancellor_assignment_for_selected_city()` cleared global `_player_state["chancellor_id"]` if the assigned chancellor was not stationed in the selected city.
  - Foreign city selection therefore made the left national panel show `미임명` and caused spy validation to report missing chancellor.
- Implemented:
  - Locked left panel chancellor refresh to player/nation scope.
  - Made chancellor sync clear only missing/non-player invalid chancellor ids, not selected-city stationing mismatches.
  - Changed the dropdown to player-side national chancellor candidates and kept the current valid player chancellor visible.
  - Kept the right City Detail, diplomacy/spy target, and trade target paths selected-city scoped.
- Preserved spy formulas/effects, diplomacy actions, trade pricing/efficiency, chancellor auto trade, save/load schema, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
  - required chancellor scope and warning-cleanup searches
- Manual F6 QA remains required for chancellor display after foreign city selection, spy button enablement, save/load chancellor retention, and Godot Output warning cleanliness.

### v0.70-37 Spy Action MVP
- Started from `b0f40e4 v0.70-36 Diplomacy Action MVP`.
- Confirmed clean worktree and expected HEAD before editing.
- Required docs and current spy candidate display, can/roll/apply helper, cooldown, detection, relation penalty, resource cost, save/load, and warning-cleanup search paths were checked.
- Implemented:
  - Added a runtime `SpyActionCard` with `정탐`, `민심 교란`, `성 충성도 교란`, and `반란 조장` buttons for selected foreign cities.
  - Added common spy action definition, validation, execution, failure recording, and button refresh helpers.
  - Reused existing spy roll/apply helpers for info gathering, public support disruption, loyalty disruption, and revolt instigation.
  - Removed separate connected-action resource costs for this MVP and kept validation focused on target, chancellor/political aptitude, cooldown, iron-wall, and revolt prerequisites.
  - Added conservative detection relation penalties and before/after relation score metadata.
  - Improved recent spy result display and cooldown/status copy in the spy tab.
- Preserved `이간질`, advanced alienation, spy units/networks, diplomacy action behavior, trade price/efficiency behavior, manual trade, chancellor auto trade, target city storage, foreign faction stock, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved v0.70-36 diplomacy actions, v0.70-35 relation efficiency pricing, trade persistence, and `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check` passed after code edit
  - project headless load passed after code edit
  - final verification covered project headless load, `WorldMap_Test.tscn`, `Battle_Fullscreen_Test.tscn`, required search checks, and clean diff whitespace before commit
- Manual F6 QA remains required for spy card visibility, foreign/self target behavior, success/failure/detection results, relation penalties, cooldown blocking, save/load display-only restoration, diplomacy/trade regressions, and Godot Output warning cleanliness.

### v0.70-36 Diplomacy Action MVP
- Started from `f0d0301 v0.70-35 Trade Balance / Relation Efficiency Polish`.
- Confirmed clean worktree and expected HEAD before editing.
- Required docs and current diplomacy relation, action candidate display, cooldown, trade agreement, resource spending, trade efficiency, persistence, and warning-cleanup search paths were checked.
- Implemented:
  - Added a runtime `DiplomacyActionCard` with `사절 파견`, `조공`, `교역 협정`, and `관계 회복` buttons for selected foreign cities.
  - Added validation and execution helpers for diplomacy actions.
  - Applied national `resource_stock.gold` costs and relation score deltas after validation.
  - Added target-faction diplomacy action cooldowns.
  - Added 6-turn trade agreement state that reuses the existing trade agreement multiplier path for trade efficiency.
  - Recorded `_player_state["last_diplomacy_action_result"]` for success/failure display.
  - Added save/load fallback mirror keys for diplomacy action cooldowns and trade agreements.
  - Extended world-turn diplomacy cooldown advancement to decrement action cooldowns and trade agreement duration.
- Preserved alliance proposal execution, military support request execution, war/peace logic, AI response/rolls, spy action execution, target city storage, foreign faction stock, external trade pricing, chancellor auto trade structure, manual trade panels, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved manual/internal trade, relation efficiency pricing, trade persistence, and `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - project headless load passed before documentation update
  - final verification commands are expected before commit
- Manual F6 QA remains required for foreign-city action card visibility, action cost/relation/cooldown behavior, trade agreement efficiency bonus, save/load persistence, spy tab display-only behavior, and Godot Output warning cleanliness.

### v0.70-35 Trade Balance / Relation Efficiency Polish
- Started from `1cf0798 v0.70-33 Chancellor Auto Trade Logic Connect`.
- Confirmed clean worktree and expected HEAD before editing.
- Required docs and current manual trade, relation multiplier, chancellor auto trade, persistence, and warning-cleanup search paths were checked.
- Implemented:
  - Added shared relation-aware external trade pricing helpers.
  - Connected manual external preview to relation efficiency.
  - Connected manual external execution and validation to the same relation-aware delta helper.
  - Connected chancellor external auto trade import/export to relation-aware cost/gain and higher-efficiency candidate preference.
  - Recalculated pending manual order preview on normalize/load from current relation efficiency.
  - Added concise efficiency/applied-pricing text to external trade UI summaries.
- Preserved target city storage for external trade, foreign faction stock, national `resource_stock`, relation score mutation, turn cost, random rolls, market price fluctuation, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved manual internal transfer, chancellor internal redistribution, trade persistence, and `v0.70-34-hotfix1` warning cleanup.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for manual preview/execution parity, neutral/allied efficiency pricing, gold shortage validation, chancellor external auto trade display, save/load pending preview recalculation, internal trade regressions, and Godot Output warning cleanliness.

### v0.70-33 Chancellor Auto Trade Logic Connect
- Started from `83cbf79 v0.70-34-hotfix1 GDScript Shadowing Warning Cleanup`.
- Confirmed clean worktree and expected HEAD before editing.
- Required docs and existing chancellor policy, trade control mode, manual trade, city storage, internal/external candidate, domestic turn, and inter-faction trade income paths were checked.
- Numbering note: `v0.70-34` and `v0.70-34-hotfix1` landed first; this session fills the skipped `v0.70-33` candidate afterward.
- Implemented:
  - Added chancellor auto trade storage targets, buffers, internal/external caps, and policy/aptitude priority helpers.
  - Connected player domestic-turn processing to `_apply_chancellor_auto_trade_for_world_turn()`.
  - Added same-turn guard with `_player_state["last_chancellor_auto_trade_turn"]`.
  - Added internal chancellor auto trade for connected player-owned city storage redistribution.
  - Added external chancellor auto trade for source-city import/export against valid external candidates.
  - Recorded `_player_state["last_chancellor_auto_trade_result"]` and normalized it through the existing player-state persistence path.
  - Added recent chancellor auto trade summaries to internal/external trade tabs while preserving manual displays.
- Preserved target city storage for external trade, foreign faction stock, national `resource_stock`, relation, turn cost, random rolls, manual trade panels, internal transfer panel, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserved `v0.70-34-hotfix1` warning cleanup; no shadowing warning names were reintroduced.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for chancellor assignment, policy priority feel, internal redistribution, external source-city import/export, same-turn guard, no-chancellor no-op, manual mode regressions, save/load display-only behavior, and Godot Output warning cleanliness.

## 2026-06-10

### v0.70-34-hotfix1 GDScript Shadowing Warning Cleanup
- Started from `c7897b2 v0.70-34 Trade Persistence Polish`.
- Required docs and the reported Godot reload warning names were checked.
- Implemented:
  - Renamed WorldMap local `resource_label` variables in manual/external trade row construction.
  - Renamed WorldMap diplomacy/spy local `selected_city_id`.
  - Renamed the internal transfer signed amount formatter parameter from `sign`.
  - Renamed Selected City Panel layout-order local `loyalty_card`.
- Preserved functionality, UI layout, formulas, save/load structure, trade persistence, manual trade, internal transfer, external execution, diplomacy/spy behavior, Selected City Panel behavior, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv` files.
- Manual F6 QA remains required for visible Godot Output warning confirmation and trade/diplomacy/save-load tab regression checks.

### v0.70-34 Trade Persistence Polish
- Started from `5cd3425 v0.70-32 Trade Execution Connect MVP`.
- Required docs, save/load helpers, trade control state, pending manual external orders, recent external execution results, recent internal transfer results, and city storage persistence paths were checked.
- `v0.70-33 Chancellor Auto Trade Logic Connect` was skipped by instruction and remains a follow-up.
- Implemented:
  - Added trade persistence normalize/sync/restore helpers in `scripts/worldmap_test.gd`.
  - Synced `_trade_control_modes` into `_player_state["trade_control_modes"]` before save and restored it after load/reset/default initialization.
  - Synced `_manual_trade_orders` into `_player_state["manual_trade_orders"]` before save and restored it after load.
  - Normalized pending external manual orders and recalculated previews from `MANUAL_TRADE_PREVIEW_PRICES`.
  - Pruned invalid pending manual orders with `[TRADE_SAVE_LOAD]` warnings.
  - Normalized recent external manual execution and recent internal manual transfer result payloads as display-only data.
  - Kept city storage persistence on the existing `worldmap_city_state` path.
- Preserved chancellor auto trade, relation efficiency pricing, price variation, target city storage mutation, foreign faction stock, relation, turn, formulas, Selected City Panel, diplomacy/spy visibility hotfix, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv` files.
- Manual F6 QA remains required for trade-control mode save/load, pending external order save/load, restored order execution, recent external execution display persistence, recent internal transfer display/storage persistence, and old-save fallback.

### v0.70-32 Trade Execution Connect MVP
- Started from `856f411 v0.70-31 Internal Trade Manual Transfer MVP`.
- Required docs, v0.70-30 saved external manual order structure, v0.70-31 city storage helpers, external candidate filtering, relation trade availability helpers, and manual preview price helpers were checked.
- Implemented:
  - Added a runtime `ManualTradeExecutionButton` under City Detail content for `무역 > 타국무역`.
  - Displayed the button only when a saved external manual order exists and external trade candidates are still valid.
  - Added validation-first external manual execution with no partial apply.
  - Applied imports to selected source city storage as `gold` decrease plus resource increase.
  - Applied exports to selected source city storage as resource decrease plus `gold` increase.
  - Reused `MANUAL_TRADE_PREVIEW_PRICES` so preview and execution deltas match.
  - Recorded `_player_state["last_external_manual_trade_execution_result"]`, displayed success/failure results in the external trade tab, and cleared the pending order only on success.
- Preserved target city storage, foreign faction stock, national `resource_stock`, relation, turn, formulas, internal manual transfer, Selected City Panel, diplomacy/spy visibility hotfix, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv` files.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for save order -> execute, import/export city storage deltas, resource tab refresh, shortage validation, pending-order clearing, internal transfer regression, and diplomacy/spy visibility.

### v0.70-31 Internal Trade Manual Transfer MVP
- Started from `df761af v0.70-30 Manual Trade Order Panel MVP`.
- Required docs, v0.70-29 trade-control paths, v0.70-30 manual external panel paths, internal-trade candidate filtering, and city storage helpers were checked.
- Implemented:
  - Added a runtime `InternalTradeTransferPanel` under `WorldMapUI`.
  - Opened the panel from internal-trade `수동 조정` when connected player-owned targets exist.
  - Added target dropdown, source-owned amount display, transfer SpinBoxes, preview, apply, and cancel.
  - Added validation for ownership, adjacency, source/target identity, nonzero amounts, allowed resource ids, and source storage availability.
  - Added actual city storage movement from source city to target city.
  - Recorded `_player_state["last_internal_trade_transfer_result"]` and displayed recent transfer summary in the internal trade tab.
- Preserved national `resource_stock`, relation, turn, formulas, troop movement, external manual trade order panel, Selected City Panel, diplomacy/spy visibility hotfix, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv` files.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for a connected-player-city scenario, source/target storage deltas, amount caps, invalid input blocking, resource tab refresh, external panel regression, and diplomacy/spy visibility.

### v0.70-30 Manual Trade Order Panel MVP
- Started from `d55c76e v0.70-29 WorldMap Trade Control Mode UI MVP`.
- Required docs and the v0.70-29 Trade Control connection points were checked.
- Implemented:
  - Added a runtime `ManualTradeOrderPanel` under `WorldMapUI`.
  - Opened the panel from external-trade `수동 조정` when candidates exist.
  - Added candidate selection, relation/trade availability display, resource action dropdowns, quantity SpinBoxes, preview text, save, and cancel.
  - Added preview-only prices and expected gold/resource delta calculation.
  - Stored the last valid external manual trade order in runtime `_manual_trade_orders`.
  - Added external trade tab copy for saved/no-saved manual order state.
  - Kept internal-trade manual mode as a follow-up placeholder.
- Preserved actual trade execution, `resource_stock`, city `storage`, relation, turn, formulas, save/load schema, Resource tab, diplomacy/spy tab visibility hotfix, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv` files.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for panel opening, dropdown/SpinBox interaction, preview updates, save/cancel, saved summary display, no actual resource/gold/relation/turn mutation, and tab-switch visibility.

### v0.70-29 WorldMap Trade Control Mode UI MVP
- Started from `48fa669 v0.70-28-hotfix1 Diplomacy Spy Subtab Visibility Fix`.
- Required docs and WorldMap trade render paths were checked, including internal/external trade candidate helpers and unified panel chrome/content refresh.
- Implemented:
  - Added a runtime `TradeControlCard` inside City Detail trade content.
  - Added `재상에게 일임` and `수동 조정` buttons.
  - Added current mode display and guidance text.
  - Separated runtime state for internal trade mode and external trade mode, both defaulting to `chancellor`.
  - Disabled `수동 조정` when no internal or external trade target exists.
  - Kept manual mode as placeholder-only for `Manual Trade Order Panel MVP`.
  - Kept chancellor mode as placeholder-only for `Chancellor Auto Trade Logic Connect`.
  - Removed duplicated legacy `재상 위임 / 수동 조정` text from the old label path.
- Preserved actual trade execution, resource movement, gold purchase/sale, resource exchange, chancellor auto-trade logic, trade/relation formulas, turn handling, Resource tab, diplomacy/spy tab visibility hotfix, Selected City Panel, BattleContext, save/load schema, `project.godot`, scenes, assets, `.uid`, and `.ogv` files.
- Verification:
  - `git diff --check`
  - project headless load
  - `WorldMap_Test.tscn` headless load
  - `Battle_Fullscreen_Test.tscn` headless load
- Manual F6 QA remains required for visible button state, disabled state, tab switching, and no resource/gold/relation/turn mutation.

## 2026-06-09

### v0.70-28-hotfix1 Diplomacy Spy Subtab Visibility Fix
- Started from `fbc6a6e v0.70-28 Diplomacy Spy Tab Structure Polish`.
- Checked `_refresh_unified_panel_chrome()` and `_on_unified_secondary_tab_pressed()` for the reused City Detail subtab buttons.
- Implemented:
  - Explicitly set the reused `외교` subtab button visible in `외교·첩보` primary mode.
  - Explicitly set the reused `첩보` subtab button visible in `외교·첩보` primary mode.
  - Kept the third reused tab button hidden in diplomacy/spy mode.
  - Kept existing click routing: index 0 -> diplomacy, index 1 -> spy.
  - Clarified action copy to point execution to Diplomacy Action MVP / Spy Action MVP.
- Preserved diplomacy/spy execution, relation mutation, spy rolls, resource spending, turn consumption, resource/trade tabs, Selected City Panel, formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, and `.ogv` files.
- Manual F6 QA remains required for Hanseong/Pyeongyang/Gyeongju diplomacy/spy subtab visibility and switching, plus resource/trade tab restoration.

### v0.70-28 Diplomacy Spy Tab Structure Polish
- Started from `6136aa2 v0.70-27 Selected City Stability + Military Card Polish`.
- Required docs and City Detail diplomacy/spy relation/spy helper paths were checked.
- Implemented:
  - Replaced the City Detail diplomacy/spy tab's web-version/display-only copy with player-facing decision summaries.
  - Rebuilt `외교` display around selected city, owner faction, PLAYER relation status, relation score, trade status, and diplomacy action candidates.
  - Rebuilt `첩보` display around target city, information level, known information scope, spy action candidates, and selected-city-related recent spy result.
  - Kept spy candidate status to side-effect-free `_can_...` checks and did not execute spy actions.
  - Hid the diplomacy/spy action placeholder button in this tab.
- Removed public support details, city loyalty details, revolt-risk details, troop movement, recruitment, city storage, resource potential, trade details, supply adjustments, military-card information, and raw internal relation ids from the City Detail diplomacy/spy tab display.
- Preserved resource tab/cards, internal/external trade, Selected City Panel stability/military cards, governor/garrison/hero movement/attack/help flows, recruitment, troop movement, formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, and `.ogv` files.
- Manual F6 QA remains required for Hanseong self-city diplomacy/spy states, foreign-city relation/spy candidate states, absence of developer copy, unchanged trade/resource/Selected City flows, and drag/collapse behavior.

## 2026-06-08

### v0.70-27 Selected City Stability + Military Card Polish
- Started from `5021d47 v0.70-26 External Trade Tab Structure Polish`.
- Required docs and Selected City Panel/revolt-risk/recruitment code paths were checked.
- Implemented:
  - Added a `성 안정도` title to the existing loyalty card.
  - Added a loyalty stability label beside `성 충성도`.
  - Added Selected City Panel revolt-risk summaries using the existing WorldMap revolt-risk calculation path.
  - Localized the Selected City Panel revolt-risk display to `낮음`, `주의`, and `위험`.
  - Added a runtime `군사` card and moved the existing military summary, recruitment section, and `모병 100` button into it.
- Preserved governor assignment/policy dropdowns, garrison card, hero movement panel, attack button, help buttons, Selected City Panel drag, City Detail resource/internal-trade/external-trade/diplomacy tabs, recruitment signal flow, formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, and `.ogv` files.
- Manual F6 QA remains required for Hanseong stability/military cards, Korean revolt-risk text, `모병 100`, governor/policy dropdowns, garrison, hero movement, attack/help/drag, and unchanged City Detail tab behavior.

### v0.70-26 External Trade Tab Structure Polish
- Started from `e36569c v0.70-25 Internal Trade Tab Ownership Filter Polish`.
- Required docs and WorldMap external-trade/relation/ownership helpers were checked.
- Implemented:
  - Replaced the external trade tab's broad recent-result display with a foreign-neighbor candidate filter.
  - Added empty-state copy for no adjacent foreign trade candidates.
  - Added localized relation status display for external trade UI.
  - Added trade availability and relation-based efficiency summaries using existing relation/trade helpers and constants.
  - Kept recent trade records to a short selected-city-related route count only.
  - Hid the trade adjustment button path on the external trade tab.
  - Kept trade leadership as future copy only: `재상 위임 / 수동 조정`.
- Removed public support, city loyalty, loyalty drift, seasonal loyalty, revolt risk, troop movement, recruitment/conscription, military supply judgment, and supply-adjustment details from the external trade tab display.
- Preserved resource tab/storage cards, internal trade, diplomacy/spy, Selected City Panel, troop movement logic, recruitment logic, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, and `.ogv` files.
- Manual F6 QA remains required for Hanseong external trade candidates, localized relation/availability/efficiency display, hidden internal-management/troop/recruitment blocks, raw relation id absence, and unchanged internal-trade/resource/diplomacy/Selected City/battle-adjacent flows.

### v0.70-25 Internal Trade Tab Ownership Filter Polish
- Started from `43aa5a6 v0.70-24a City Storage Gold Source Fix + Resource Card Polish`.
- Required docs and WorldMap internal-trade/supply/ownership helpers were checked.
- Implemented:
  - Replaced the internal trade tab's neighbor listing with a player-owned-neighbor filter.
  - Added Hanseong-only empty state copy for no connected player-owned city.
  - Removed public support, loyalty drift, seasonal loyalty, revolt risk, troop movement, and recruitment/conscription blocks from the internal trade tab.
  - Hid the troop-move button path on the internal trade tab.
  - Localized supply role/status display to Korean UI labels.
  - Kept trade leadership as future copy only: `재상 위임 / 수동 조정`.
- Preserved resource tab/storage cards, external trade, diplomacy/spy, Selected City Panel, troop movement logic, recruitment logic, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, and `.ogv` files.
- Manual F6 QA remains required for Hanseong internal trade empty state, hidden foreign neighbors, hidden internal-management/troop/recruitment blocks, localized supply text, and unchanged resource/external-trade/diplomacy/Selected City/battle-adjacent flows.

### v0.70-24a City Storage Gold Source Fix + Resource Card Polish
- Started from the v0.70-24 City Storage Resource Tab MVP baseline.
- Required checks completed for current status/history and the City Detail resource/storage/save-load code paths.
- Implemented:
  - Removed upper economy `금전` display from the City Detail `자원` tab.
  - Renamed the upper economy block to `경제 잠재력` and kept only population and commerce potential.
  - Kept actual city-held gold in `성 창고`, sourced from `storage.gold`.
  - Fixed `_get_city_storage()` fallback so missing storage builds defaults before normalization.
  - Preserved explicit saved storage dictionaries, including all-zero storage.
  - Improved `성 창고` line breaks so group totals and details are shown on separate lines.
  - Added runtime `PanelContainer` wrappers to visually split `자원 잠재력` and `성 창고` without scene restructuring.
- Preserved national warehouse UI, national `resource_stock`, trade, turn production, supply consumption, upkeep, recruitment, battle loot, BattleContext, resource/domestic seeds, formulas, `project.godot`, assets, `.uid`, and `.ogv` files.
- Manual F6 QA remains required for Hanseong card display, `storage.gold` gold display, save/load persistence, drag/collapse/tab/help/recruitment/governor/attack regressions, and clean Godot Output.

## 2026-06-08

### v0.70-24 City Storage Resource Tab MVP
- Started from `207a76e v0.70-23-hotfix2 Full GDScript Ternary Compatibility Sweep`.
- Pre-work `git status --short` showed a pre-existing modified `WorldMap_Test.tscn`; it was not edited or staged for this task.
- Required docs and code paths reviewed: WorldMap workflow/state/next/handoff/rules docs, resource tab rendering, national warehouse/resource stock helpers, city runtime state helpers, and WorldMap save/load.
- Implemented:
  - Added `storage` normalization/default/display helpers in `scripts/worldmap_test.gd`.
  - Kept existing resource star rows as city resource potential.
  - Added `성 창고` below the economy block in City Detail `자원` tab.
  - Initialized Hanseong city storage from current national `resource_stock`: gold 500, rice 300, barley 250, seafood 80, wood 100, iron 50, horses 30, silk 30, salt 50.
  - Defaulted other missing city storage to zero values unless explicit runtime/loaded storage exists.
  - Added city runtime save/load coverage for `storage` with older-save defaults.
- Preserved national warehouse UI, national `resource_stock`, turn production, trade movement, supply consumption, upkeep, recruitment, battle loot, BattleContext, formulas, `WorldMap_Test.tscn`, `project.godot`, and assets.
- Manual F6 QA remains required for Hanseong storage display, save/load persistence, expanded/collapsed drag, collapse/expand, tab switching, help, Selected City Panel, attack/governor/recruitment buttons, and Godot Output warning cleanliness.

## 2026-06-05

### v0.70-23-hotfix2 Full GDScript Ternary Compatibility Sweep
- Started from clean `b8ca197 v0.70-23-hotfix1 City Detail Drag + GDScript Reload Warning Fix`.
- Required baseline checks completed: `git status --short`, `git log --oneline -10`, current `HEAD`, and Godot headless project load.
- Godot headless did not provide a concrete file/line for the user's remaining editor reload warning, so a full repo ternary inventory was gathered with `rg " if .* else " --glob "*.gd"`.
- Implemented:
  - Rewrote selected-city panel layout/control/index ternaries in `scripts/worldmap_city_info_panel.gd`.
  - Rewrote deployment panel text, color, spin value, warning, summary, and supply status ternaries in `scripts/player_attack_deployment_panel.gd`.
  - Rewrote battle WorldMap context/result/cutin/debug/formation ternaries in `scripts/battle_web_import_test.gd`.
  - Rewrote city marker selected scale/color ternaries in `scripts/worldmap_city_marker.gd`.
  - Rewrote recent City Detail chrome/tab/resource/supply ternaries in `scripts/worldmap_test.gd`.
- Remaining `rg " if .* else " --glob "*.gd"` hits are in `scripts/worldmap_test.gd` only and are same-type scalar/value choices.
- Preserved City Detail content, trade/diplomacy/spy content, help copy, recruitment, formulas, save/load, BattleContext, `project.godot`, scenes, and assets.
- Headless project, WorldMap scene, and Battle scene loads were clean for the reported ternary reload message in this environment.

### v0.70-23-hotfix1 City Detail Drag + GDScript Reload Warning Fix
- Started from clean `94b404b v0.70-23 WorldMap City Detail Resource Tab Slim Polish`.
- Required baseline checks completed: `git status --short`, `git log --oneline -10`, and current `HEAD`.
- Reproduced investigation path:
  - Project, WorldMap, and Battle headless loads did not print the reported reload messages in this environment before patching.
  - Static search found `_set_city_detail_body_labels_visible(visible: bool)` as the `visible` parameter shadowing source.
  - CityDetailPanel expanded drag root cause was hidden registered handles: expanded mode hides the eyebrow and heading label, while collapsed mode shows the heading label.
- Implemented:
  - Registered `city_detail_header_row` as an additional CityDetailPanel drag handle.
  - Kept collapse button and all primary/secondary tab buttons out of the direct drag handle list.
  - Preserved collapsed drag-vs-click behavior and `_move_hud_panel_to_screen_position()` clamp logic.
  - Renamed the `visible` parameter to `should_show`.
  - Replaced type-unclear `Dictionary` ternaries in the recently touched WorldMap scripts with explicit `Variant` extraction and `if` checks.
- Preserved City Detail resource content, trade/diplomacy/spy structure, help copy, recruitment, formulas, battle scenes, BattleContext, save/load, `project.godot`, and assets.
- Manual F6 QA remains required for expanded/collapsed drag, click-to-expand, tab/collapse clicks, resource tab display, right Selected City Panel drag, help buttons, attack/governor/recruit buttons, and Godot Output warning cleanliness.

### v0.70-23 WorldMap City Detail Resource Tab Slim Polish
- Started from clean `789c2de v0.70-22-hotfix1 GDScript Ternary Type Compatibility Fix`.
- Required reading completed: workflow/current/next/handoff/WorldMap rules, `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, and `WorldMap_Test.tscn`.
- Inspected unified City Detail / diplomacy-spy panel setup, primary/secondary tab refresh, city detail reset/show/content functions, and existing resource/trade display helpers.
- Implemented:
  - Hid the old English City Detail eyebrow/title path.
  - Added `무역` as a primary unified-panel tab.
  - Kept `도시 상세` resource view separate from `외교·첩보` and moved `자국무역` / `타국무역` into the trade secondary-tab flow.
  - Rebuilt the resource tab body around city name, food/strategy/special resource potential, and economy potential.
  - Removed duplicate type/faction/loyalty/troop/security/defense/status/governor/stationed-hero copy from the resource tab.
  - Added compact resource category coloring for `식량 자원`, `전략 자원`, and `특산 자원`.
- Preserved help modal topics, recruitment, governor assignment, governor policy, attack button, save/load, battle entry, BattleContext, city data values, formulas, `project.godot`, and assets.
- Tech tree UI remains deferred after the city detail / diplomacy-spy / trade panel cleanup.

### v0.70-22-hotfix1 GDScript Ternary Type Compatibility Fix
- Started from clean `720c0a9 v0.70-22 WorldMap Implemented Help Modal MVP`.
- Checked the v0.70-22 GDScript diff and searched ternary patterns in `scripts/worldmap_test.gd` and `scripts/worldmap_city_info_panel.gd`.
- Fixed the added `_apply_selected_city_layout_order()` ternary that selected between `_domestic_help_row` and `military_state_label`.
- Replaced it with an explicit `Control` variable and `if/else` assignment to avoid GDScript ternary type compatibility reload errors.
- Preserved help text, topic coverage, UI structure, domestic formulas, battle scenes, save/load, `project.godot`, and assets.

### v0.70-22 WorldMap Implemented Help Modal MVP
- Started from clean `5d730bb v0.70-21 WorldMap Recruitment Loyalty-Based Connect`.
- Required reading completed: workflow/current/next/handoff/WorldMap rules, `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, and `WorldMap_Test.tscn`.
- Implementation evidence checked in the current code:
  - National loyalty is managed through tax pressure and active chancellor national effects.
  - City loyalty display/drift paths include tax, security, economy, military burden, supply, supply security, control, publicSupport seasonal effects, and governor/chancellor effects.
  - publicSupport display/drift paths include tax, food, commerce, and supply.
  - Security/garrison movement paths use stationed troops, supply path checks, and minimum garrison checks.
  - Governor command rank/limit helpers give governor assignment a command-limit role.
  - No player-facing hero personal loyalty increase action was confirmed.
- Implemented:
  - Added small help buttons for 국가충성도, 성 충성도, 민심, 치안, and 주둔무장.
  - Added `help_requested(topic_id)` from `WorldMapCityInfoPanel`.
  - Added a reusable `WorldMapHelpModal` under `WorldMapUI` with topic title/body and close controls.
  - Kept help copy compact and limited to implemented systems, without formulas or multipliers.
- Preserved existing attack, governor assignment, governor policy, hero transfer, recruitment, panel drag, save/load, battle scene, BattleContext, `project.godot`, and assets.

### v0.70-21 WorldMap Recruitment Loyalty-Based Connect
- Started from `v0.70-20a WorldMap Selected City Panel Layout Order Polish`.
- Required reading completed: workflow/current/next/handoff/WorldMap rules, `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, and `WorldMap_Test.tscn`.
- Implemented:
  - Replaced the old recruitment limit axis with loyalty-based thresholds.
  - Preserved ownership, amount, peacetime, and national resource affordability validation.
  - Kept cost at gold = amount and food = floor(amount / 2), paid from rice -> barley -> seafood.
  - Preserved automatic conscription behavior with loyalty capacity, `barracks` requirement, and `conscription_system` 1.10 effect.
  - Added compact `병사 충원` summary lines to the right Selected City Panel.
  - Connected `모병 100` through `recruitment_requested(city_id, 100)` to actual resource payment and city troop increase.
  - Recorded `loyalty` and `loyalty_limit` in `last_recruitment_result`; publicSupport remains compatibility/future-risk data, not the limit basis.
- Preserved battle scenes, BattleContext, city ownership, hero movement, governor/chancellor policy calculations, save/load structure beyond existing city troop/resource coverage, `project.godot`, and assets.

### v0.70-20a WorldMap Selected City Panel Layout Order Polish
- Started from `0e5cd21 v0.70-20 WorldMap Selected City Governor Garrison & Hero Transfer Polish`.
- Required git analysis:
  - `git status --short`: `WorldMap_Test.tscn` already had a selected-city panel serialization metadata diff.
  - `git show --stat HEAD` / `git show --name-only HEAD`: v0.70-20 changed selected-city panel scripts and agent docs.
  - The pre-existing scene diff was limited to `GovernorAssignOption` `unique_id` serialization and was kept as part of this selected-city panel polish scope.
- Implemented:
  - Reordered the selected-city panel to city summary, loyalty, `민심 / 치안 / 상업 / 농업`, governor card, garrison card, hero transfer, military summary, and recruit button.
  - Kept governor effect/policy inside the governor card and removed duplicate lower governor policy hint output.
  - Wrapped the `주둔 무장` portrait/name/stat rows in a card-style `GarrisonCard`.
  - Moved `무장 이동` under the garrison card while keeping the v0.70-20 transfer UI and data path.
  - Hid the selected-city `내정` button/path.
  - Placed `병력 / 방어 / 치안 기준` below garrison/transfer and the recruit area below that summary; v0.70-21 supersedes it with connected `병사 충원`.
- Preserved governor assignment logic, governor policy save/load, hero transfer data movement, battle/BattleContext, domestic/chancellor/governor formulas, recruit processing, `project.godot`, `.uid` / `.ogv`, and assets.

### v0.70-20 WorldMap Selected City Governor Garrison & Hero Transfer Polish
- Started from clean `5b1d131 v0.70-19a Agent Docs Handoff & ChatCoach Role Lock`.
- Required git analysis:
  - `git status --short`: clean.
  - Recent log confirmed `5b1d131`, `4c671b0`, `fd2eb4e`, `7f937fe`, `9b8b186`, `110f0e8`, `91713d8`, `4535a3f`, `5dec9b2`, `502f1eb`, `ab91b34`, and `e53a9fb`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: v0.70-19a changed agent docs only.
- Read required agent docs and inspected `scripts/worldmap_city_info_panel.gd`, `scripts/worldmap_test.gd`, `WorldMap_Test.tscn`, `scripts/worldmap_hero_portrait_helper.gd`, and `scripts/worldmap_city_marker.gd`.
- Web reference checked:
  - `SamWar_web/js/core/app_state.js` transfer functions.
  - `SamWar_web/js/core/world_rules.js` `transferHeroToCity`.
  - `SamWar_web/js/ui/world_map_ui.js`, `hero_transfer_ui.js`, and `selected_city_ui.js` transfer UI/event binding.
- Implemented:
  - Visible `태수` section title above the governor card.
  - Dynamic `주둔 무장` rows with portrait/placeholder, name, and stat summary.
  - Inline hero-transfer UI opened by `무장 이동`.
  - Adjacent-player-city-only transfer validation and runtime roster movement in `worldmap_test.gd`.
  - Source `governor_id` clearing when the moved hero was governor.
- Preserved existing governor assignment/policy dropdowns, policy formulas, save/load schema, city click, right-panel drag, battle entry, BattleContext, combat/result accounting, `.uid` / `.ogv`, and assets.

### v0.70-19a Agent Docs Handoff & ChatCoach Role Lock
- Started from clean `4c671b0 v0.70-19 WorldMap Selected City Governor Assignment & Policy Connect`.
- Required git analysis:
  - `git status --short`: clean.
  - Recent log confirmed v0.70-19 on top of v0.70-18, v0.70-17b, v0.70-16, v0.70-15, v0.70-14a, v0.70-14, and v0.70-13d.
  - `git show --stat HEAD` / `git show --name-only HEAD`: v0.70-19 changed `WorldMap_Test.tscn`, selected-city scripts, and agent docs for governor assignment/policy connection.
- Read the required workflow, Godot, current-state, next-task, handoff, changelog, session-log, WorldMap rules, and hero-data-contract docs.
- Updated agent docs only with:
  - Stable baseline `v0.70-19` at `4c671b0e7599ade817d1274768f04b879a757ca4`.
  - Recent work summary for battle cinematic guards, movement facing, left panel polish, selected-city slim polish, and governor assignment/policy connection.
  - Domestic-system philosophy: rich internal systems with compact decision summaries in UI.
  - ChatCoach role lock: code/docs evidence first, then scoped Codex execution instruction.
  - Safety cautions around `.uid` / `.ogv`, `git clean`, `git push`, dirty worktrees, and scene serialization diffs.
  - Next candidates: `v0.70-20`, `v0.70-21`, `v0.70-22`, and `v0.70-23`.
- No code, scene, asset, `project.godot`, battle, `WorldMap_Test.tscn`, or script files were changed.

### v0.70-19 WorldMap Selected City Governor Assignment & Policy Connect
- Started from clean actual HEAD `fd2eb4e 월드맵작업`; requested baseline `7f937fe v0.70-18 WorldMap Selected City Panel Anchor & Summary Slim Polish` was one local commit behind.
- Required git analysis:
  - `git status --short`: clean.
  - Recent log: `fd2eb4e`, `7f937fe`, `9b8b186`, `110f0e8`, `91713d8`, `4535a3f`, `5dec9b2`, `502f1eb`, `ab91b34`, `e53a9fb`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD changed only `WorldMap_Test.tscn`.
- Inspected required docs and the selected-city governor/policy paths in `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and `scripts/worldmap_city_info_panel.gd`.
- Implemented minimal governor connection:
  - Added `GovernorAssignOption` to the selected-city governor card.
  - Added a `governor_assignment_requested` signal from the panel.
  - Populated assignment choices from selected-city `stationed_hero_ids` plus `미임명`.
  - Updated mutable city runtime `governor_id` in `worldmap_test.gd` and refreshed selected-city/city-detail display.
  - Kept the existing governor policy dropdown connected to `_city_policy_state`.
- Save/load:
  - City runtime save includes `governor_id` and `governor_policy_id`.
  - Top-level `city_policy_state` is saved and loaded.
  - Missing keys in older saves fall back to seed city data/default policy.
- Removed selected-city governor policy developer wording: no visible `재상 정책 수행`, `Godot에서는 표시 전용`, placeholder/no-effect, or "No city stat or turn effect applied" copy remains in this path.
- Preserved governor effect formulas, chancellor/tax formulas, domestic/trade/relation formulas, hero movement, stationed rosters, governor exclusivity, wounded/captured/dead coupling, city ownership/troop/resource calculations, battle scripts, `BattleContext`, and `project.godot`.
- Verification passed: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Manual F6 QA remains recommended for dropdown/save-load behavior.

### v0.70-18 WorldMap Selected City Panel Anchor & Summary Slim Polish
- Started from clean `9b8b186 v0.70-17b Restore Theora Test UID Files`.
- Required git analysis:
  - `git status --short`: clean.
  - Recent log: `9b8b186`, `110f0e8`, `91713d8`, `4535a3f`, `5dec9b2`, `502f1eb`, `ab91b34`, `e53a9fb`, `8991b9b`, `0c91744`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD restored the two Theora test `.uid` files and updated five agent docs.
- Inspected required docs, `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and `scripts/worldmap_city_info_panel.gd`.
- Findings:
  - `CityInfoPanel` is under `WorldMapUI` CanvasLayer and already camera-independent.
  - Existing drag registration includes `CityInfoPanel` via `EyebrowLabel` and `CityNameLabel`.
  - Selected-city display text is owned by `scripts/worldmap_city_info_panel.gd`.
- Implemented minimal selected-city polish:
  - Anchored `CityInfoPanel` startup placement to the right side with the shared top margin and 10px right-side margin.
  - Preserved drag movement through the visible city name handle.
  - Hid `SELECTED CITY`, owner/region/nation duplication, population/gold/food, resource list, city status sentence, and governor summary label.
  - Kept city name, `세력`, `유형`, loyalty label/bar, governor card/dropdown, garrison, military/domestic summary, policy hint, and action buttons.
  - Removed `표시 전용` from selected-city loyalty copy.
- Preserved left panel, city detail/diplomacy panels, city data, city click, battle entry, camera handoff, safe-zone camera, formulas, governor internals, resource data, save/load, battle scripts, `project.godot`, `.uid`/`.ogv` files, and assets.
- Manual F6 QA remains recommended for visual right-side placement, drag movement, city switching, and retained controls.

### v0.70-17b Restore Theora Test UID Files
- Started from `110f0e8 v0.70-17a Repo Sanity Cleanup Before Selected City Panel Work` with `WorldMap_Test.tscn` tracked modified.
- Required git analysis:
  - `git status --short`: `M WorldMap_Test.tscn`.
  - Recent log: `110f0e8`, `91713d8`, `4535a3f`, `5dec9b2`, `502f1eb`, `ab91b34`, `e53a9fb`, `8991b9b`, `0c91744`, `f56903d`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD deleted the two Theora test `.uid` files and updated five agent docs for v0.70-17a.
- Restored the two Theora test `.uid` files from `HEAD~1`:
  - `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid`
  - `assets/video_test/theora_safe/test_safe_q8_1920x.ogv.uid`
- The `.uid` files are retained for Godot resource UID reference stability.
- The `.ogv` source files were preserved.
- `WorldMap_Test.tscn` was not staged, committed, or discarded. WorldMap_Test.tscn modified remains uncommitted.
- No scripts, `project.godot`, battle scenes, selected-city panel logic, or `.ogv` source files were changed.
- Next task before selected-city panel work: explicitly decide whether to keep, normalize, or revert the existing `WorldMap_Test.tscn` diff.

### v0.70-17a Repo Sanity Cleanup Before Selected City Panel Work
- Started from reported state: HEAD `91713d8 제거목적` with `WorldMap_Test.tscn` tracked modified.
- Required git analysis:
  - `git status --short`: `M WorldMap_Test.tscn`.
  - Recent log: `91713d8`, `4535a3f`, `5dec9b2`, `502f1eb`, `ab91b34`, `e53a9fb`, `8991b9b`, `0c91744`, `f56903d`, `6f46bf1`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD added only `test_safe_q7_1280x.ogv.uid` and `test_safe_q8_1920x.ogv.uid`.
  - `git diff -- WorldMap_Test.tscn`: scene serialization/property-order diff around the left panel; no selected-city panel work identified.
- Cleanup:
  - Removed the two incorrectly tracked Theora test `.uid` files with `git rm`.
  - Preserved the `.ogv` source files.
  - Did not use `git clean`.
- `WorldMap_Test.tscn` was not staged, committed, or discarded. WorldMap_Test.tscn modified remains uncommitted.
- No scripts, `project.godot`, battle scene, selected-city panel logic, or `.ogv` source files were changed.
- Next task before selected-city panel work: explicitly decide whether to keep, normalize, or revert the existing `WorldMap_Test.tscn` serialization diff.

### v0.70-16 WorldMap Left Panel Chancellor Card Polish
- Started from `5dec9b2 v0.70-15 WorldMap Left Panel Header & Tax Slim Polish`.
- Required git analysis:
  - `git status --short`: pre-existing untracked `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `test_safe_q8_1920x.ogv.uid`; pre-existing untracked Godot .uid files ignored.
  - Recent log: `5dec9b2`, `502f1eb`, `ab91b34`, `e53a9fb`, `8991b9b`, `0c91744`, `f56903d`, `6f46bf1`, `493c8e8`, `76e0421`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD modified `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and six agent docs for the left panel header/tax slim polish.
- Read required docs and inspected `WorldMap_Test.tscn` plus `scripts/worldmap_test.gd`.
- Chancellor card findings:
  - `LeftWorldStatusPanel` was at `(18, 10)` while the top baseline was `10`.
  - The chancellor card used `PortraitBox` at `42 x 42`, `ChancellorNameLabel`, `ChancellorStatsLabel`, assignment/policy dropdowns, and `ChancellorPolicyDescriptionLabel`.
  - Runtime copy repeated unassigned/assigned state through `재상 없음`, `재상 임명: ...`, `재상 효과: 이름: ...`, and `재상 정책: 정책명 · ...`.
- Implemented minimal polish:
  - Changed left panel X baseline to `10` without moving right-side panels.
  - Simplified unassigned display to `미임명`, `효과: 없음`, and `정책: 보정 없음`.
  - Kept assigned name once, kept primary/secondary aptitude lines, and removed repeated assignment/name copy.
  - Shortened effect/policy labels to `효과:` and `정책:` without changing underlying effect/policy calculation.
  - Enlarged the chancellor portrait frame to `56 x 64`, enabled clipping, and used aspect-covered portrait display.
- Preserved worldmap city data, city click, battle entry, camera handoff logic, domestic/trade/relation formulas, chancellor formulas, tax calculations, save/load structure, warehouse content, right/city-detail panels, battle scenes, and `project.godot`.
- Verification passed: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, and docs marker check.
- Manual F6 QA remains recommended for visible margin, portrait crop, unassigned/assigned copy, dropdown interaction, turn end, save/load/reset, and unchanged right panels.
- Next candidate work:
  1. `v0.70-17 WorldMap Left Panel Resource Warehouse Polish`
  2. `v0.70-18 WorldMap City Detail Panel Right Side Polish`
  3. `v0.70-19 WorldMap Battle Entry Camera Zoom Handoff`
  4. `v0.70-20 WorldMap Left Panel Save Button Polish`

### v0.70-15 WorldMap Left Panel Header & Tax Slim Polish
- Started from `502f1eb v0.70-14a WorldMap Panel Top Margin Baseline Polish`.
- Required git analysis:
  - `git status --short`: pre-existing untracked `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `test_safe_q8_1920x.ogv.uid`; pre-existing untracked Godot .uid files ignored.
  - Recent log: `502f1eb`, `ab91b34`, `e53a9fb`, `8991b9b`, `0c91744`, `f56903d`, `6f46bf1`, `493c8e8`, `76e0421`, `d2dbefa`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD modified `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and six agent docs for the panel top-margin baseline.
- Read required docs and inspected `WorldMap_Test.tscn` plus `scripts/worldmap_test.gd`.
- Panel/header findings:
  - `WorldMapUI` is a `CanvasLayer`; fixed panels are already camera-independent.
  - `LeftWorldStatusPanel` contained visible `World Turn`, `TurnLabel`, `CalendarLabel`, and phase/selected/base-city `NationLabel` lines.
  - The tax card contained national loyalty, tax label/bar/slider, and a long tax preview/public-order label/bar path.
- Implemented minimal slim polish:
  - Reduced shared `WORLD_UI_TOP_MARGIN` from `16.0` to `10.0`.
  - Kept the left header visually to one calendar/turn line such as `154년 봄 1턴`.
  - Hid `World Turn`, `제 N턴`, and phase/selected/base-city header labels without deleting nodes.
  - Kept one national loyalty label/bar and one tax level label/slider.
  - Hid the duplicate tax bar, tax preview text, and public-order duplicate bar.
- Preserved worldmap city data, city click, battle entry, camera handoff logic, domestic/trade/relation formulas, chancellor formulas, tax calculations, save/load structure, battle scenes, and `project.godot`.
- Verification passed: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, and docs marker check.
- Manual F6 QA remains recommended for one-line header appearance, tax slider interaction, turn end/save/load, and visible top baseline alignment.
- Next candidate work:
  1. `v0.70-16 WorldMap Left Panel Chancellor Card Polish`
  2. `v0.70-17 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-18 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-19 WorldMap Battle Entry Camera Zoom Handoff`

### v0.70-14a WorldMap Panel Top Margin Baseline Polish
- Started from `ab91b34 v0.70-14 WorldMap Left Panel Anchor & World Turn Lock`.
- Required git analysis:
  - `git status --short`: pre-existing untracked `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `test_safe_q8_1920x.ogv.uid`.
  - Recent log: `ab91b34`, `e53a9fb`, `8991b9b`, `0c91744`, `f56903d`, `6f46bf1`, `493c8e8`, `76e0421`, `d2dbefa`, `edac641`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD modified `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and six agent docs for the left panel anchor lock.
- Read required docs and inspected `WorldMap_Test.tscn` plus `scripts/worldmap_test.gd`.
- Panel position findings:
  - `WorldMapUI` is a `CanvasLayer`; fixed panels are already camera-independent.
  - `LeftWorldStatusPanel` started at top `56`.
  - `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` started at top `96`.
  - `TitleLabel` / `SamWar HUD MVP` started at top `18` and would visually collide with the raised left panel.
- Implemented minimal top-margin baseline:
  - Added shared `WORLD_UI_TOP_MARGIN = 16.0`.
  - Moved left, selected-city, city-detail, and diplomacy/spy panels to top `16` in the scene without changing content structure.
  - Added runtime fixed-panel top-margin lock helpers.
  - Hid the retired debug title label without deleting it.
- Preserved worldmap city data, city click, battle entry, camera handoff logic, domestic/trade/relation formulas, battle scenes, and `project.godot`.
- Verification target: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, docs string check, and tracked post-commit status.
- Manual F6 QA remains recommended for visible panel baseline alignment and camera pan/zoom independence.
- Next candidate work:
  1. `v0.70-15 WorldMap Left Panel Visual Hierarchy Polish`
  2. `v0.70-16 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-17 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-18 WorldMap Battle Entry Camera Zoom Handoff`

### v0.70-14 WorldMap Left Panel Anchor & World Turn Lock
- Started from actual HEAD `e53a9fb v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`; user-requested baseline `8991b9b v0.70-13d Battle Movement Facing Direction Polish` was already one commit behind local HEAD.
- Required git analysis:
  - `git status --short`: pre-existing untracked `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `test_safe_q8_1920x.ogv.uid`.
  - Recent log: `e53a9fb`, `8991b9b`, `0c91744`, `f56903d`, `6f46bf1`, `493c8e8`, `76e0421`, `d2dbefa`, `edac641`, `3800c99`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD modified `scripts/worldmap_test.gd` and six agent docs for battle-entry camera handoff.
- Inspected required docs, `WorldMap_Test.tscn`, and `scripts/worldmap_test.gd`.
- Left panel finding: `LeftWorldStatusPanel` is a `PanelContainer` under `WorldMapUI` CanvasLayer, so it is already screen-space and independent from `WorldMapCamera` pan/zoom.
- World Turn finding: top labels are `EyebrowLabel`, `TurnLabel`, `CalendarLabel`, and `NationLabel` inside `MarginContainer/Content` `VBoxContainer`; runtime cards are inserted below existing content.
- Implemented minimal layout lock:
  - Scene top-left anchor and size/min-size for `LeftWorldStatusPanel`.
  - Scene `WorldTurnSeparator` after `NationLabel`.
  - Runtime anchor/position/size guard.
  - Runtime World Turn child order guard.
  - Removed left panel drag registration while keeping right-side panel drag behavior.
- Verification target: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, docs string check, and tracked post-commit status.
- Manual F6 QA remains recommended for visible fixed-panel behavior during pan/zoom/drag and for confirming existing left controls are still reachable.
- Next candidate work:
  1. `v0.70-15 WorldMap Left Panel Visual Hierarchy Polish`
  2. `v0.70-16 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-17 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-18 WorldMap Battle Entry Camera Zoom Handoff`

### v0.70-14 WorldMap Battle Entry Camera Zoom Handoff
- Started from requested baseline `8991b9b v0.70-13d Battle Movement Facing Direction Polish`.
- Required git analysis:
  - `git status --short`: pre-existing untracked `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `test_safe_q8_1920x.ogv.uid`.
  - Recent log: `8991b9b`, `0c91744`, `f56903d`, `6f46bf1`, `493c8e8`, `76e0421`, `d2dbefa`, `edac641`, `3800c99`, `6262206`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD modified five agent docs and `scripts/battle_web_import_test.gd` for v0.70-13d movement-facing polish.
- Read required docs and inspected `scripts/worldmap_test.gd`, `WorldMap_Test.tscn`, `scripts/player_attack_deployment_panel.gd`, `project.godot`, `scripts/worldmap_city_marker.gd`, `agent/WORLDMAP_RULES.md`, `agent/HERO_DATA_CONTRACT.md`, and `agent/ENEMY_INVASION_AUDIT.md`.
- WorldMap camera finding: `WorldMap_Test.tscn` already has root `WorldMapCamera`; `_configure_camera()` sets zoom `0.7`, `_apply_zoom()` increases zoom value for zoom-in, and `_clamp_camera_to_world()` constrains camera center to the existing world rect.
- Battle entry finding: player attack and enemy invasion defense both converge on `_handoff_battle_context_to_battle_scene()` after existing validation/context build and troop pre-decrement.
- Implemented the camera handoff in `scripts/worldmap_test.gd` only:
  - City visual positions come from `_city_markers_by_id` marker `global_position`, with safe fallback to existing city data position fields.
  - Focus uses source/target when both exist and weights toward target with `lerp(0.72)`.
  - Camera tween pans and zooms to clamped focus, holds briefly, then calls `_change_scene_to_battle_with_context()`.
  - Skip input is limited to the handoff state and supports left-click, Space, Enter, keypad Enter, and Esc.
  - Duplicate entry guard blocks repeated attack/defense/deployment/handoff and camera input while active.
- Preserved existing battle context keys, Engine meta keys, troop pre-decrement timing, result application, battle scene intro, and all battle calculations.
- Verification target: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, docs string check, and tracked post-commit status.
- Manual F6 QA remains recommended for camera timing/focus, skip feel, repeated-click guard, and enemy invasion defense path.
- Next candidate work:
  1. `v0.70-15 WorldMap Battle Entry Camera Handoff Timing Polish`
  2. `v0.70-16 WorldMap City Click UX Polish`
  3. `v0.70-17 WorldMap Domestic UX Detail Polish`

### v0.70-13d Battle Movement Facing Direction Polish
- Started from clean actual HEAD `0c91744 v0.70-13c Battle WorldMap Return Contract Prep`; user-requested baseline `f56903d v0.70-13b Battle Cinematic Lifecycle Guard Audit` was the immediate parent code baseline because v0.70-13c changed docs only.
- Required git analysis:
  - `git status --short`: clean before edits.
  - Recent log: `0c91744`, `f56903d`, `6f46bf1`, `493c8e8`, `76e0421`, `d2dbefa`, `edac641`, `3800c99`, `6262206`, `740fea0`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD modified only six agent docs for v0.70-13c.
- Inspected `scripts/battle_web_import_test.gd` movement and facing paths:
  - Ally movement: `play_basic_move_demo()` path tween loop and `_finish_basic_move_demo()`.
  - Enemy movement: `_play_enemy_actor_path_move_then_act()` path tween loop and `_finish_enemy_actor_basic_move()`.
  - Pathfinding: `_find_ally_move_path()` and `_find_enemy_path_to_destination_for_actor()` were read but not modified.
  - Facing visuals: `_set_unit_facing()`, `_apply_unit_facing_visuals()`, `_apply_token_facing_visual()`, and facing-aware portrait offset helpers.
- Updated segment movement visuals:
  - Added horizontal-facing helper from `from_cell` / `to_cell`.
  - Added segment-start movement-facing application for ally and enemy path movement.
  - Vertical-only segments keep existing facing.
  - Current group offset is reapplied after facing change to avoid a visual snap during tween movement.
- Updated ally move finish so last movement-facing visual is preserved until the existing direction-selection UI applies the final chosen facing.
- No pathfinding, move range, move duration, action flow, combat formula, WorldMap logic, intro guard, or result-video lifecycle changes were intended.
- Verification target: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, docs string check, and post-commit clean status.
- Manual F6 QA remains recommended for the visual cases in the task instruction.
- Next candidate work:
  1. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  2. `v0.70-15 WorldMap City Click UX Polish`
  3. `v0.70-16 WorldMap Domestic UX Detail Polish`

### v0.70-13c Battle WorldMap Return Contract Prep
- Started from clean baseline `f56903d v0.70-13b Battle Cinematic Lifecycle Guard Audit`.
- Required git analysis:
  - `git status --short`: clean before edits.
  - Recent log: `f56903d`, `6f46bf1`, `493c8e8`, `76e0421`, `d2dbefa`, `edac641`, `3800c99`, `6262206`, `740fea0`, `da200ac`.
  - `git show --stat HEAD` / `git show --name-only HEAD` / `git show --stat HEAD~1..HEAD`: HEAD modified five agent docs and `scripts/battle_web_import_test.gd`.
  - HEAD script work was battle cinematic lifecycle guard only; no WorldMap entry/return code changed in the baseline commit.
- Read required project docs and audited the required files: `scripts/battle_web_import_test.gd`, `scripts/worldmap_test.gd`, `WorldMap_Test.tscn`, and `project.godot`.
- WorldMap -> Battle finding: both player attack and enemy invasion defense converge on `_handoff_battle_context_to_battle_scene()`, which writes `samwar_worldmap_battle_context` and changes to `res://Battle_Fullscreen_Test.tscn`.
- Battle internal finding: battle consumes/removes the context meta once, applies worldmap rosters, stores `worldmap_battle_context`, and builds return payload only after final `victory` / `defeat`.
- Battle -> WorldMap finding: battle writes `samwar_worldmap_battle_result` and returns to `res://WorldMap_Test.tscn`; worldmap consumes/removes the result meta and dispatches to existing attack/defense result application.
- Documented current contract keys, missing/non-literal keys, and v0.70-14 camera handoff connection points.
- No runtime code changes were made; this was a contract audit and documentation patch.
- Verification target: `git diff --check`, Godot headless project load, battle scene headless load, worldmap scene headless load, docs string check, and post-commit clean status.
- Next candidate work:
  1. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  2. `v0.70-15 WorldMap City Click UX Polish`
  3. `v0.70-16 WorldMap Domestic UX Detail Polish`

### v0.70-13b Battle Cinematic Lifecycle Guard Audit
- Started from clean baseline `6f46bf1 Tune battle intro wide shot hold timing`, documented as `v0.70-13a Battle Intro Wide Hold Timing Polish Stable`.
- Required git analysis:
  - `git status --short`: clean before edits.
  - Recent log: `6f46bf1`, `493c8e8`, `76e0421`, `d2dbefa`, `edac641`, `3800c99`, `6262206`, `740fea0`.
  - `git show --stat HEAD` / `git show --name-only HEAD` / `git show --stat HEAD~1..HEAD`: HEAD modified five agent docs and `scripts/battle_web_import_test.gd`.
  - HEAD script diff changed only intro timing constants: wide hold `0.4 -> 0.85`, zoom `1.0 -> 1.15`.
- Inspected the related cinematic commits:
  - `493c8e8`: battle intro camera wide-shot / zoom-in, UI hide/restore, skip input, input guards.
  - `d2dbefa`: result video before existing victory/defeat toast, fallback timer, WorldMap return refresh.
  - `76e0421`: centered 16:9 result video panel sizing.
- Updated `scripts/battle_web_import_test.gd` only for lifecycle guards:
  - Added duplicate-start guard for battle intro via `battle_intro_camera_has_started`.
  - Routed intro natural finish and skip finish through `_complete_battle_intro_camera_zoom()`.
  - Made repeated skip/finish calls idempotent after camera/UI cleanup.
  - Kept intro completion camera restore limited to captured gameplay camera state; no combat camera formula changes.
  - Hardened result video hide/reset path to clear stream, visibility, backdrop, pending state, and completion guard.
  - Guarded repeated same-state result video starts while playback is already pending.
- Agent docs updated: `CURRENT_STATE`, `NEXT_TASKS`, `HANDOFF_TO_CODEX`, `CHANGELOG`, and `SESSION_LOG`.
- No battle calculation, attack/damage/result judgment, unique skill cutin, archer volley, gunner FX, BattleContext, WorldMap logic, scene, asset, or `project.godot` changes were intended.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. Visible F6 QA remains recommended for intro feel, skip spam, victory/defeat result video, and WorldMap return button flow.
- Next candidate work:
  1. `v0.70-13c Battle WorldMap Return Contract Prep`
  2. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  3. `v0.70-15 WorldMap Domestic UX Detail Polish`

### v0.70-12 Battle Result Video Before Victory/Defeat Toast
- Started from `edac641 Set unit type attack range baseline for test battle`.
- Confirmed the expected source MP4s exist under `assets/video_source_test/result_dry_run/`.
- Source ffprobe:
  - Victory: h264, 1920x1080, yuv420p, `30000/1001`, duration `4.004000`.
  - Defeat: h264, 1920x1080, yuv420p, `30000/1001`, duration `4.004000`.
- Encoded q8 Theora result videos:
  - `assets/ui/result/videos/victory_result_theora_q8_1920x.ogv`: Theora, 1920x1080, yuv420p, `30/1`, duration `4.000000`, size `13550758` bytes.
  - `assets/ui/result/videos/defeat_result_theora_q8_1920x.ogv`: Theora, 1920x1080, yuv420p, `30/1`, duration `4.000000`, size `8176454` bytes.
- Added a dedicated `ResultOverlay/VideoStreamPlayer_Result` node to the battle scene.
- Added result-video-before-toast playback helpers in `scripts/battle_web_import_test.gd`.
- Existing victory/defeat toast behavior is preserved and now starts after result video completion.
- Added load-failure fallback and a duration-based fallback timer guard so the existing toast still appears if video playback fails.
- No battle result judgment, WorldMap result payload/return, cutin mapping/assets, archer volley FX, or gunner shot FX changes were intended.
- Remaining manual QA: win and lose a battle in F6 and confirm the result video appears before the matching toast and WorldMap return still works.

### v0.70-11 Unit Type Attack Range Baseline
- Started from clean repo state at `3800c99 Add gunner muzzle flash and tracer impact visual`.
- Diagnosed the short gunner range as test battle unit setup data in `scripts/battle_web_import_test.gd`.
- Added unit-type normal attack range helpers:
  - infantry: `1`
  - cavalry: `1`
  - archer: `3`
  - gunner: `4`
- Updated test battle `BattleUnitState.create()` attack ranges to use the baseline helper.
- Jeong Do Jeon, Eulji Mundeok, and Zhuge Liang now resolve to normal gunner `attack_range = 4`.
- Yi Sunsin, Kim Yu-sin, and Liu Bei remain archer `attack_range = 3`; infantry/cavalry remain adjacent `attack_range = 1`.
- WorldMap source data was inspected but not rewritten in this patch; this task is scoped to test battle range consistency.
- No unique skill range, strategy range, move range, damage, hit, troop, turn, archer/gunner FX, cutin mapping, or WorldMap script changes were intended.

### v0.70-10 Gunner Muzzle Flash + Tracer Impact Visual
- Started from clean repo state at `6262206 Add curved archer volley path and completion timing guard`.
- Confirmed gunner unit data uses `UNIT_TYPE_GUNNER` plus `korea_gunner` / `china_gunner` visual keys.
- Added `_is_gunner_unit()` using existing unit type, visual key inference, and hero default visual key fallback.
- Added `_play_gunner_shot_effect()` to the ally and enemy normal/basic attack visual hook path only.
- Added runtime primitive muzzle flash, tracer, target spark impact, and smoke fade functions.
- Kept gunner FX separate from archer volley; archer and gunner hooks are mutually exclusive.
- No gunner assets were created.
- Kept the effect visual-only and gunner-basic-attack-only: no damage, hit, troop, turn, unique-skill, cutin, q8 mapping, or WorldMap logic changes were intended.
- Remaining manual QA: verify Jeong Do Jeon / Eulji Mundeok / Zhuge Liang basic attacks show a short sharp muzzle/tracer/impact effect, and non-gunners/special skills do not.

## 2026-06-04

### v0.70-9c Archer Curved Volley + Visual Completion Timing Guard
- Started from clean repo state at `740fea0 Tune archer volley readability and slower arrow travel`.
- Preserved the existing v0.70-9b runtime `Line2D` arrow readability baseline: 9 arrows, `0.34`-`0.50` second travel, and `0.05`-`0.12` second stagger.
- Kept the slightly lengthened/brightened arrow stroke so the arrows read more like arrows and less like bullet tracers.
- Added subtle curved source-midpoint-impact projectile travel using `_get_arrow_curve_midpoint()`.
- Added an archer-only basic attack completion guard using `_get_arrow_volley_blocking_duration()` / `_get_arrow_volley_completion_extra_wait()` so the next action waits for the last arrow flight and initial impact.
- Pin linger/fade remains non-blocking after the flight/impact guard.
- Kept the effect visual-only and archer-basic-attack-only: no damage, hit, troop, turn, unique-skill, cutin, q8 mapping, or WorldMap logic changes were intended.
- Remaining manual QA: verify Yi Sunsin / Kim Yu-sin / Liu Bei basic attacks show a heavier slower curved arrow stream, that the next action waits until arrow impact, and that non-archers/special skills do not show the volley.

### v0.70-8b Yi Sun-sin + Eulji Mundeok Mirrored Cutin Layouts
- Started from clean repo state at `e69dd46 을지문덕,김유신까지 컷인 완성`.
- Confirmed current specialty cutin presentation uses per-hero config in `scripts/battle_web_import_test.gd`.
- Changed only Yi Sunsin and Eulji Mundeok configs to mirrored layout: hero portrait right, title image left.
- Added mirrored enter/settle/exit offset handling keyed by `layout_mirror`, preserving default motion for all other heroes.
- Kept Kwon Yul, Jeong Do Jeon, and Kim Yu-sin configs in the existing hero-left/title-right layout.
- No q8 OGV path, fallback chain, trigger flow, production asset, or WorldMap logic was changed.

### v0.70-8 Kim Yu-sin + Eulji Mundeok Special-Skill Cutin Integration
- Started from `514e2ff 버그 수정및 기본유닛 컷인 완성`.
- Confirmed the six expected Kim Yu-sin / Eulji Mundeok source assets existed in the repo as untracked files.
- Confirmed existing specialty cutins are triggered from `_begin_unique_skill_sequence()` and `_show_specialty_skill_video_cutin()`, not reinforcement arrival.
- Verified source MP4s with ffprobe:
  - Kim Yu-sin: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
  - Eulji Mundeok: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Verified portrait/title PNG dimensions and alpha:
  - Kim Yu-sin portrait `1672x941`, title `1133x639`.
  - Eulji Mundeok portrait `1672x941`, title `1133x639`.
- Encoded Kim Yu-sin and Eulji Mundeok source MP4s to q8 1920x Theora OGVs under `assets/ui/cutin/videos/`.
- Output ffprobe:
  - Kim Yu-sin q8 OGV: Theora, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `6365944` bytes.
  - Eulji Mundeok q8 OGV: Theora, 1920x1080, yuv420p, `30/1`, stream duration `N/A`, format duration `2.005333`, size `8318109` bytes.
- Ran Godot import to generate PNG `.import` metadata and q8 OGV `.uid` metadata for the new production cutin resources.
- Added `gim_yusin` and `eulji_mundeok` to the existing special-skill cutin video/config dictionaries.
- Confirmed no older Kim Yu-sin / Eulji Mundeok legacy fallback videos existed; q8 OGV is the primary candidate for each.
- Removed only tracked Theora-safe frame-capture `.import` junk and the regenerated untracked q7/q8 test `.uid` junk; preserved real test OGV outputs.
- Direct ResourceLoader verification passed for Kim/Eulji q8 OGVs, portrait/title PNGs, and existing Yi/Kwon/Jeong q8 OGVs.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Remaining manual QA: trigger Kim Yu-sin and Eulji Mundeok unique skills in battle and confirm video/title/portrait display, no black screen, no reinforcement-arrival trigger, and battle-flow return.

### v0.70-7c GDScript Position Parameter Shadow Warning Cleanup
- Started from `599d8e2 Fix Kim Yu-sin tactical panel and move cell clickability`.
- Found the remaining Node2D `position` shadow warning in `scripts/battle_web_import_test.gd` command-panel helper parameters.
- Renamed `_clamp_floating_ally_command_panel_position(position, ...)` and `_score_floating_ally_command_panel_position(position, ...)` parameters to `panel_position`.
- No behavior change intended; this only removes the base `Node2D.position` property shadow warning after the Kim Yu-sin tactical fix.
- No cutin assets, q8 mappings, title PNGs, production videos, or WorldMap logic were changed.

### v0.70-7b Kim Yu-sin Tactical Cell Clickability Root-Cause Fix
- Started from `19afc67 Replace Jeong Do Jeon q8 cutin video source`.
- Confirmed the working tree only had regenerated untracked Theora-safe `.import` junk before editing; no cutin/video or WorldMap changes were pending.
- Re-inspected the current v0.70-7/v0.70-7a command panel placement and input priority code.
- Found that ally-turn input still selected ally units before trying valid highlighted move-cell clicks.
- Root cause for the Kim Yu-sin / Kwon Yul-adjacent cell: a visible valid move cell could overlap Kwon Yul's ally click area, causing Kwon Yul selection to win before Kim Yu-sin movement was attempted.
- Moved valid move-cell click handling before ally unit selection during ally turn; occupied ally cells remain invalid move targets, so direct ally selection still works after the move check fails.
- Strengthened panel placement distance behavior by raising the selected-unit distance weight and making viewport-corner fallback positions a true last resort.
- Changed ally click hit resolution to choose the closest clicked ally when click areas overlap.
- Added a guard so disabled/non-pickable click areas are ignored by the manual unit hit test.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- No cutin assets, q8 mappings, title PNGs, production videos, or WorldMap logic were changed.
- Remaining manual QA: select Kim Yu-sin, confirm panel attachment, click the highlighted cell below/near Kwon Yul, and confirm command buttons/battle flow remain stable.

### v0.70-6b Jeong Do Jeon Source Replacement + q8 Theora Regeneration
- Started from clean repo state at `5c9b8cc 정도전 고유특기 영상 교체`.
- Confirmed the latest commit replaced `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4` and also accidentally tracked Godot Theora-safe frame `.import` junk.
- Verified new Jeong Do Jeon source MP4 with ffprobe: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Regenerated `assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv` from the new source with libtheora q8, 1920x1080, yuv420p, `30fps`, GOP 60, and Vorbis audio.
- Output ffprobe: Theora, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `7101765` bytes.
- Confirmed `scripts/battle_web_import_test.gd` already keeps the Jeong Do Jeon q8 OGV as first candidate and preserves WebM/MP4 fallbacks; no mapping edit was made.
- Confirmed Yi Sunsin and Kwon Yul q8 assets/mappings were not changed.
- Removed only tracked `assets/video_test/theora_safe/godot_q7_frame*.png.import`, `godot_q8_frame*.png.import`, `godot_q7_frame.wav.import`, `godot_q8_frame.wav.import`, and `source_frame_1s.png.import` junk from the source-replacement commit.
- Direct ResourceLoader verification passed through a temporary script in `C:\tmp`: Jeong Do Jeon q8 OGV loads as `VideoStreamTheora`; Jeong Do Jeon title PNG loads as `CompressedTexture2D`.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- Remaining manual QA: visible battle flow should confirm the new Jeong Do Jeon video, non-black playback, title display, and battle-flow return.

### v0.70-7a Tactical Panel Distance Clamp + Move Cell Clickability Fix
- Started from clean repo state at `694065a Prevent battle command panel from blocking tactical cells`.
- Re-read the workflow/Godot/current-state docs and inspected the current v0.70-7 floating command panel patch.
- Confirmed the previous panel scorer used tactical-cell overlap only, so any zero-overlap screen-corner fallback could win without considering distance from the selected unit.
- Added command panel distance scoring, far fallback penalty, and additional near diagonal candidates to keep the panel close to the selected unit unless nearby positions are substantially worse.
- Investigated the visible move cell below/near Xiahou Dun and identified a likely input-priority cause: enemy unit hit testing ran before valid move-cell handling in ally turn.
- Added `_try_handle_valid_move_cell_click()` before enemy hit testing so a visibly valid movement target can be selected even if an enemy click area overlaps the same screen region.
- Preserved target-selection panel hiding, command buttons, direct move-click, attack target selection for actual enemy cells, and battle continuation behavior.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- No cutin assets, q8 mappings, title PNGs, production video files, or WorldMap logic were changed.
- Remaining manual QA: select Kim Yu-sin and confirm the panel is not detached; click the highlighted move cell below/near Xiahou Dun and confirm it is clickable if highlighted.

### v0.70-7 Tactical Command Panel Grid Overlap Avoidance
- Started from `ce4d7c7 Add Kwon Yul and Jeong Do Jeon q8 Theora cutin dry runs`.
- Cleared only regenerated untracked `assets/video_test/theora_safe/*.import` junk before editing; no production or test `.ogv` files were removed.
- Located the floating command panel in `scripts/battle_web_import_test.gd` as `BattleUI/FloatingAllyCommandPanel`.
- Confirmed the panel uses `Control.MOUSE_FILTER_STOP`, so when it overlaps reachable grid cells the UI can block tactical clicks.
- Added floating panel placement helpers: candidate generation, viewport clamp, visible tactical cell rect collection, overlap area scoring, and least-overlap choice.
- The panel now considers visible move/attack/strategy/unique overlay cells and moves around the selected ally or to a safe viewport corner when needed.
- Added `_hide_floating_ally_command_panel_for_tactical_selection()` and `_restore_floating_ally_command_panel_input()`.
- Attack target select, unique-skill target select, and strategy target select now hide the panel while target interaction is active.
- Attack and unique-skill cancel paths now restore panel request state when returning to ally turn; strategy cancel already restored request state.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- No cutin assets, q8 mappings, title PNGs, or WorldMap logic were changed.
- Remaining manual QA: visible battle flow should confirm the panel avoids reachable cells, hides during target selection, no longer blocks covered cells, and command buttons still work.

### v0.70-6a Kwon Yul + Jeong Do Jeon q8 Theora Production Dry Runs
- Started from the clean asset-intake checkpoint `46f60c0 Remove Theora safe import junk after cutin asset intake`.
- Re-read workflow/Godot/current-state docs before changing runtime assets or mappings.
- Reconfirmed source MP4 specs with ffprobe:
  - Kwon Yul: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
  - Jeong Do Jeon: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Encoded Kwon Yul with libtheora q8 and Vorbis audio to `assets/ui/cutin/videos/kwon_yul_cutin_bg_theora_q8_1920x.ogv`; ffprobe result is theora, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `9054001` bytes.
- Encoded Jeong Do Jeon with libtheora q8 and Vorbis audio to `assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv`; ffprobe result is theora, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `4472743` bytes.
- Ran Godot import to generate OGV `.uid` metadata, then removed only the regenerated `assets/video_test/theora_safe/` `.import` and q7/q8 `.uid` test junk.
- Updated `scripts/battle_web_import_test.gd` so Kwon Yul and Jeong Do Jeon q8 OGVs are first candidates in their cutin chains while preserving fallbacks and leaving Yi Sunsin unchanged.
- Wired Kwon Yul title PNG `res://assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png` and Jeong Do Jeon title PNG `res://assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png`.
- Added per-hero cutin config entries for Yi Sunsin, Kwon Yul, and Jeong Do Jeon to allow independent portrait/title layout tuning later.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- Direct ResourceLoader verification passed: Kwon Yul and Jeong Do Jeon q8 OGVs load as `VideoStreamTheora`; both title PNGs load as `CompressedTexture2D`; Yi Sunsin q8/title resources still load.
- Remaining manual QA: visible battle flow should confirm Kwon Yul and Jeong Do Jeon q8 playback, title image display, no black screen, layout suitability, and battle-flow return.

### v0.70-6 Kwon Yul + Jeong Do Jeon Cutin Source Asset Intake
- Started from clean repo state after `c7173fb 컷인 관련`.
- Inspected `git show --name-status --oneline HEAD`; latest commit added Kwon Yul and Jeong Do Jeon source MP4s, added two title PNGs, and modified `assets/ui/cutin/portraits/jeong_do_jeon_cutin.png`.
- Verified no `assets/video_test/theora_safe/` files were added by the latest commit.
- ffprobe for `assets/video_source_test/production_dry_run/kwon_yul_cutin_source_02s.mp4`: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- ffprobe for `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4`: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Verified `assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png` is `1133x639`, PNG color type `6`, alpha true.
- Verified `assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png` is `1133x639`, PNG color type `6`, alpha true.
- Ran Godot `--import` to generate required texture import metadata for the new title PNGs.
- Added `assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png.import` and `assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png.import`.
- Removed only the incidental untracked `test_safe_q7_1280x.ogv.uid` and `test_safe_q8_1920x.ogv.uid` files generated under `assets/video_test/theora_safe/`.
- Removed tracked frame-capture import junk under `assets/video_test/theora_safe/`: `godot_q7_frame*.png.import`, `godot_q8_frame*.png.import`, `godot_q7_frame.wav.import`, `godot_q8_frame.wav.import`, and `source_frame_1s.png.import`.
- Preserved `assets/video_test/theora_safe/README.md`, `test_safe_q7_1280x.ogv`, and `test_safe_q8_1920x.ogv`.
- Direct Godot resource verification passed for both title PNGs as `CompressedTexture2D`; source MP4s remain ffmpeg source assets and are not Godot ResourceLoader resources.
- No production mapping or Yi Sunsin q8 baseline file/mapping was changed.

### v0.70-5e Yi Sun-sin Final Exit Snap Tuning
- Started from clean repo state at `fbe1219 Tune Hakikjin hold timing and large burst fade`.
- Focused only on final cutin tail/exit timing for the Yi Sunsin specialty cutin.
- Kept Hakikjin title behavior unchanged: readable hold, large burst scale `2.25`, fade-out, and upward drift.
- Preserved the Hakikjin-first structure; Hakikjin still finishes before Yi Sunsin and before the full cutin exit.
- Shortened final tail by changing `SPECIALTY_SKILL_CUTIN_EXIT_START` from `2.55` to `1.18`.
- Reduced final fade duration by changing `SPECIALTY_SKILL_CUTIN_EXIT_DURATION` from `0.45` to `0.14`.
- Reduced `SPECIALTY_SKILL_CUTIN_TOTAL_DURATION` from `3.0` to `1.38` so the unique-skill effect and battle-flow continuation are aligned with the faster visible exit.
- Tuned the final Yi Sunsin exit drift to a quick left/down movement ending at `hero_base_position + Vector2(-86.0, 14.0)`.
- Preserved q8 Theora first candidate and all existing fallbacks. Kwon Yul / Jeong Do Jeon mappings were not changed.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- Direct ResourceLoader verification passed: Hakikjin PNG loads as `CompressedTexture2D`, q8 OGV loads as `VideoStreamTheora`.
- Remaining manual QA: visible F6 battle flow should confirm Hakikjin exits first, Yi Sunsin only lingers briefly, the final cutin snaps out, and battle rhythm feels better.

### v0.70-5d Hakikjin Readable Hold + Large Burst Fade Tuning
- Started from clean repo state at `1134d80 Increase Hakikjin burst scale and tune Yi Sun-sin balance`.
- Focused only on Hakikjin readable hold and large burst fade timing.
- Kept Yi Sunsin portrait layout unchanged from v0.70-5c: `viewport_size.x * 0.86`, `viewport_size.y * 1.42`, left overflow `size.x * 0.28`, and `+28px` vertical balance offset.
- Kept Hakikjin title image path unchanged: `res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Increased Hakikjin sequence length by changing `SPECIALTY_SKILL_CUTIN_TEXT_POP_DURATION` from `0.38` to `0.68`.
- Added explicit title timing constants: `SPECIALTY_SKILL_CUTIN_TEXT_READABLE_HOLD := 0.34` and `SPECIALTY_SKILL_CUTIN_TEXT_BURST_DURATION := 0.34`.
- Changed Hakikjin impact scale from `1.72` to `2.25`.
- Reworked title tweening so Hakikjin appears at readable base scale, holds briefly, then scales to `2.25` while fading to alpha `0.0` and drifting upward `22px`.
- Preserved q8 Theora first candidate and all existing fallbacks. Kwon Yul / Jeong Do Jeon mappings were not changed.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- Direct ResourceLoader verification passed: Hakikjin PNG loads as `CompressedTexture2D`, q8 OGV loads as `VideoStreamTheora`.
- Remaining manual QA: visible F6 battle flow should confirm readable hold, dramatic burst fade, Yi Sunsin position, satisfying impact feel, and battle-flow return.

### v0.70-5c Yi Sun-sin Vertical Balance + Hakikjin Large Burst-Out Tuning
- Started from clean repo state at `7bdaefd Increase Yi Sun-sin dominance and animate Hakikjin burst`.
- Focused only on Yi Sunsin vertical balance and Hakikjin title burst behavior.
- Kept Yi Sunsin scale at the current oversized layout: `viewport_size.x * 0.86`, `viewport_size.y * 1.42`.
- Nudged Yi Sunsin downward by `28px` in `_layout_specialty_skill_cutin()` to improve top/bottom spacing balance.
- Kept Hakikjin title image path unchanged: `res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Increased Hakikjin impact scale from `1.26` to `1.72`.
- Increased Hakikjin fade-out enlargement from `1.34` to `1.90`.
- Added upward drift of `18px` during the Hakikjin fade burst.
- Preserved q8 Theora first candidate and all existing fallbacks. Kwon Yul / Jeong Do Jeon mappings were not changed.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- Direct ResourceLoader verification passed: Hakikjin PNG loads as `CompressedTexture2D`, q8 OGV loads as `VideoStreamTheora`.
- Remaining manual QA: visible F6 battle flow should confirm vertical balance, dramatic Hakikjin burst-out, stronger impact feel, and battle-flow return.

### v0.70-5b Yi Sun-sin Dominance + Hakikjin Pop-and-Burst Tuning
- Started from clean repo state at `09e92ba Integrate Hakikjin title image and tune Yi Sun-sin cutin impact`.
- Focused only on Yi Sunsin specialty cutin presentation tuning.
- Increased Yi Sunsin portrait layout from `viewport_size.x * 0.73`, `viewport_size.y * 1.22` to `viewport_size.x * 0.86`, `viewport_size.y * 1.42`.
- Shifted the Yi Sunsin portrait farther left by increasing panel-overflow placement from `size.x * 0.20` to `size.x * 0.28`.
- Increased hero entry distance from `Vector2(-330.0, 16.0)` to `Vector2(-390.0, 16.0)` to keep the stronger left-to-right whoosh after scaling up.
- Kept Hakikjin title image path unchanged: `res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Changed title timing from static pop-and-settle to burst behavior: alpha appears quickly, scale jumps to `1.26`, then fades out while expanding to `1.34`.
- Preserved q8 Theora first candidate and existing fallbacks. Kwon Yul / Jeong Do Jeon mappings were not changed.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- Direct ResourceLoader verification passed: Hakikjin PNG loads as `CompressedTexture2D`, q8 OGV loads as `VideoStreamTheora`.
- Remaining manual QA: visible F6 battle flow should confirm Yi Sunsin dominance, Hakikjin burst behavior, more dynamic composition, and battle-flow return.

### v0.70-5a Yi Sun-sin Hero Scale + Skill Title Image Impact Tuning
- Started from latest local baseline after `6264171 고유특기글씨업로드`, which tracked `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Confirmed the expected title image exists at `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png` and is tracked.
- Replaced the old `Label_HeroName` / `Label_SkillName` cutin text nodes with a single `TextureRect_SkillTitle` image node under `BattleUI/SkillCutinLayer/Control_Text`.
- Removed runtime references to the hero-name and skill-name labels from `scripts/battle_web_import_test.gd`.
- Added `SPECIALTY_SKILL_YI_SUNSIN_HAKIKJIN_TITLE_PATH` and load validation for the title PNG before starting the specialty cutin.
- Increased Yi Sunsin portrait layout from the previous large size to a much larger panel-overflowing hero-splash size and moved it further left/center-left.
- Tuned the hero entrance to a faster left-to-right whoosh with overshoot and settle.
- Tuned the title image entrance to a stronger pop scale sequence after the hero settles.
- Ran Godot import for the new title PNG. This generated the intended `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png.import`.
- Godot import also produced out-of-scope untracked test OGV `.uid` files under `assets/video_test/theora_safe/`; those two generated files were removed specifically without running a broad clean.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn`.
- Direct ResourceLoader verification passed: title PNG loads as `CompressedTexture2D`, q8 OGV loads as `VideoStreamTheora`.
- q8 Theora path and fallback chain remain preserved. Kwon Yul / Jeong Do Jeon mappings were not changed.
- Remaining manual QA: visible F6 battle flow should confirm larger hero impact, removed `이순신` text, Hakikjin PNG title quality, forceful motion, premium composition, and battle-flow return.

### v0.70-5 Yi Sun-sin Cutin Cinematic Layout Polish
- Started from the stable Yi Sunsin q8 Theora production dry-run baseline, with the cutin video playing correctly in real Godot battle flow.
- Confirmed the current task was presentation polish, not playback repair or asset conversion.
- Kept `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` as the first Yi Sunsin cutin video candidate and preserved all existing fallbacks.
- Identified the presentation weakness: flat pasted-on portrait feel, a tacky thick yellow diagonal bar, and low-impact `이순신` / `학익진!` text.
- Updated `Battle_Fullscreen_Test.tscn` with dedicated label settings for the Yi Sunsin cutin hero name and skill name.
- Updated `scripts/battle_web_import_test.gd` cutin layout so the Yi Sunsin portrait is much larger, placed left/center-left, and staged over the moving q8 OGV background.
- Reworked the former yellow slash into a thin steel-blue/sea-spray accent and changed runtime color/timing to keep it restrained.
- Tuned the animation sequence: deeper dim, immediate video layer, hero slide/settle, staggered text reveal, subtle text impact scale, accent entrance, and fade/drift exit.
- Scope stayed on the cutin presentation layer and docs. No `.ogv` was re-encoded, no production cutin file was deleted, and no Kwon Yul / Jeong Do Jeon mapping was modified.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load using `Godot_v4.6.2-stable_win64_console.exe`.
- Verification passed: Godot headless load of `Battle_Fullscreen_Test.tscn` with existing identity/battle setup logs and no blocking error observed.
- Codex headless verification cannot judge final cinematic taste, so F6/manual visual QA remains required for hero scale/presence, text quality, accent quality, overall feel, and battle-flow return.

### v0.70-4a Yi Sun-sin q8 Theora Manual QA Documentation
- Started from latest commit `f3d53e0 Add Yi Sun-sin q8 Theora production cutin dry run`.
- Confirmed `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` exists.
- Confirmed `scripts/battle_web_import_test.gd` had no working-tree changes before this documentation-only pass.
- Kimjak manually ran the Godot battle scene and confirmed the Yi Sunsin q8 Theora cutin displays correctly in the real battle flow.
- User QA quote: "드디어 제대로 뜸! 깔끔하게 떠^^".
- Recorded visual QA result: playback is clean, no black-screen lock was observed, no obvious color corruption was observed, and the q8 1920x Theora quality is acceptable for production dry-run.
- Documented `f3d53e0` as the current working q8 Theora dry-run connection baseline for Yi Sunsin.
- Existing fallback chain remains in place after q8: 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Documentation-only scope: no production cutin files, `.ogv` files, `scripts/battle_web_import_test.gd`, battle logic, WorldMap logic, or cutin logic were modified.

### v0.70-4 Production Cutin Theora Dry Run - Yi Sun-sin q8
- Started from commit `17c6334 Replace Yi Sun-sin dry-run source with real 1080p 2s asset` with a clean worktree.
- Confirmed source exists: `assets/video_source_test/production_dry_run/yi_sun_sin_cutin_source_02s.mp4`.
- Confirmed repo-local FFmpeg tools exist: `tools/ffmpeg/bin/ffmpeg.exe` and `tools/ffmpeg/bin/ffprobe.exe`.
- Confirmed existing production cutin files remain present: `yi_sun_sin_cutin_bg.mp4`, `yi_sun_sin_cutin_bg_vp8.webm`, `yi_sun_sin_cutin_bg_theora_540p.ogv`, `yi_sun_sin_cutin_bg_theora_540p.ogv.uid`, `kwon_yul_cutin_bg.mp4`, and `jeong_do_jeon_cutin_bg.mp4`.
- Source ffprobe result: `codec_name=h264`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30000/1001`, `duration=2.002000`.
- Encoded q8 production dry-run output:
  - `.\tools\ffmpeg\bin\ffmpeg.exe -y -i "assets/video_source_test/production_dry_run/yi_sun_sin_cutin_source_02s.mp4" -vf "fps=30,scale=1920:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 8 -g 60 -c:a libvorbis -q:a 4 "assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv"`
- Output size: `7580014` bytes.
- Output ffprobe result: `codec_name=theora`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.000000`.
- Godot generated `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv.uid` for the new production dry-run OGV.
- Updated `scripts/battle_web_import_test.gd` so only Yi Sunsin's video candidate list tries `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` first. Existing 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4 fallbacks remain.
- Godot headless project load passed with `Godot_v4.6.2-stable_win64_console.exe`.
- Godot `Battle_Fullscreen_Test.tscn` headless load passed with existing identity/battle setup logs and no blocking error observed.
- Direct Godot resource verification passed through a repo-external temporary script: `file_exists=true`, `resource_exists=true`, `loaded_class=VideoStreamTheora`, `is_video_stream=true`, and direct `VideoStreamTheora.file` was set to the q8 path.
- Headless verification did not auto-trigger the Yi Sunsin cutin, so actual frame color, black-screen check, finished signal, and post-cutin battle-flow return still require Kimjak F6/manual visual QA.

### v0.70-3 Portable FFmpeg Setup + Theora Safe Encode Execution
- Started from previous commit `4c1aa6342a07594546611e15748d53f0dbccaed8`.
- Confirmed existing files: `assets/video_source_test/cutin_test_01.mp4`, `assets/video_test/theora_safe/`, `scenes/dev/video_theora_test.tscn`, and `scripts/video_theora_test.gd`.
- Confirmed FFmpeg was still unavailable from PATH via `ffmpeg -version`, `Get-Command ffmpeg`, and `where.exe ffmpeg`.
- Downloaded gyan.dev portable FFmpeg essentials zip to `tools/ffmpeg/ffmpeg-release-essentials.zip`, extracted to `tools/ffmpeg/extracted/`, and copied `ffmpeg.exe` / `ffprobe.exe` to `tools/ffmpeg/bin/`.
- Verified FFmpeg and ffprobe version: `8.1.1-essentials_build-www.gyan.dev`.
- Left `tools/ffmpeg/` ignored because the zip and binaries are about 100MB each and should remain a local dependency.
- Encoded q7:
  - `.\tools\ffmpeg\bin\ffmpeg.exe -y -i "assets/video_source_test/cutin_test_01.mp4" -vf "fps=30,scale=1280:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 7 -g 60 -c:a libvorbis -q:a 4 "assets/video_test/theora_safe/test_safe_q7_1280x.ogv"`
  - Output size: `3426729` bytes.
- Encoded q8:
  - `.\tools\ffmpeg\bin\ffmpeg.exe -y -i "assets/video_source_test/cutin_test_01.mp4" -vf "fps=30,scale=1920:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 8 -g 60 -c:a libvorbis -q:a 4 "assets/video_test/theora_safe/test_safe_q8_1920x.ogv"`
  - Output size: `7295937` bytes.
- No audio fallback was needed; both files encoded with Vorbis stereo audio.
- ffprobe q7 video: `codec_name=theora`, `width=1280`, `height=720`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.166667`.
- ffprobe q7 audio: `codec_name=vorbis`, `sample_rate=48000`, `channels=2`, `duration=2.154667`.
- ffprobe q8 video: `codec_name=theora`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.166667`.
- ffprobe q8 audio: `codec_name=vorbis`, `sample_rate=48000`, `channels=2`, `duration=2.154667`.
- Updated `scripts/video_theora_test.gd` to accept `--video-test-q7` and `--video-test-q8` for repeatable diagnostics.
- Godot headless q7 load: `file_exists=true`, `resource_exists=true`, `loaded_class=VideoStreamTheora`, `is_video_stream=true`, `is_playing=true`.
- Godot headless q8 load: `file_exists=true`, `resource_exists=true`, `loaded_class=VideoStreamTheora`, `is_video_stream=true`, `is_playing=true`.
- Godot headless movie-maker capture crashed with dummy renderer texture storage error, so visual capture was rerun with the normal Windows display driver.
- Godot Windows display-driver movie-maker q7: recorded 75 frames at 30fps, emitted `finished signal`, and produced non-black frames.
- Godot Windows display-driver movie-maker q8: recorded 75 frames at 30fps, emitted `finished signal`, and produced non-black frames.
- Visual color result from representative captured frames: q7 and q8 both preserve the source's muted brown/gray war-scene tone; no rainbow/glitch corruption, red/blue/green channel swap, severe washout, oversaturation, crushed contrast, or black-frame lock was observed.
- Final recommendation: q7 1280x as the safe Theora preset because it satisfies Godot load/play/color and is substantially smaller/lighter than q8.
- Production cutin assets, battle logic, WorldMap logic, and cutin activation logic were not modified.

### v0.70-2 Theora Safe Encoding Test + Godot Color Playback Verification
- Started from current `git status` where `assets/video_source_test/` was the only new user-provided test source folder.
- Read the required agent docs before implementation.
- Confirmed test source: `assets/video_source_test/cutin_test_01.mp4` (`2314245` bytes).
- Confirmed production cutin candidates exist separately under `assets/ui/cutin/videos/`, including `yi_sun_sin_cutin_bg.mp4`, `yi_sun_sin_cutin_bg_vp8.webm`, and `yi_sun_sin_cutin_bg_theora_540p.ogv`.
- Created test output folder `assets/video_test/theora_safe/` and documented the expected q7/q8/noaudio `.ogv` output names in its README.
- Attempted FFmpeg discovery with `ffmpeg -version`, `Get-Command ffmpeg`, and repo-local executable search. Result: FFmpeg was not available, so no Theora encode command was executed successfully.
- FFmpeg commands intended for this test:
  - `ffmpeg -y -i "assets/video_source_test/cutin_test_01.mp4" -vf "fps=30,scale=1280:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 7 -g 60 -c:a libvorbis -q:a 4 "assets/video_test/theora_safe/test_safe_q7_1280x.ogv"`
  - `ffmpeg -y -i "assets/video_source_test/cutin_test_01.mp4" -vf "fps=30,scale=1920:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 8 -g 60 -c:a libvorbis -q:a 4 "assets/video_test/theora_safe/test_safe_q8_1920x.ogv"`
  - fallback if needed: `ffmpeg -y -i "assets/video_source_test/cutin_test_01.mp4" -an -vf "fps=30,scale=1280:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 7 -g 60 "assets/video_test/theora_safe/test_safe_q7_1280x_noaudio.ogv"`
- Added `scenes/dev/video_theora_test.tscn`, an isolated test scene that is not connected to existing battle or worldmap flow.
- Added `scripts/video_theora_test.gd` for stream switching and logs: stream path, `FileAccess.file_exists`, `ResourceLoader.exists`, load result, direct Theora fallback, `is_playing()`, and `finished`.
- Verification passed: `git diff --check`.
- Verification passed: Godot headless project load using `Godot_v4.6.2-stable_win64_console.exe`.
- Verification passed: Godot headless load of `scenes/dev/video_theora_test.tscn`; because `.ogv` outputs are missing, it cleanly logs `reason=missing file` instead of crashing.
- Playback result: not verified. The `.ogv` output files were not generated.
- Color result: not verified. No actual q7/q8 frame playback was available for visual color judgment.
- Current recommendation: test q7 1280x first once FFmpeg is available; do not choose a final production preset until q7 and q8 are both visually checked in Godot.
- Remaining risks: local FFmpeg availability, audio-track fallback behavior, actual Theora resource import/load result, non-black playback, color corruption, and q8 1920x performance.

## 2026-06-02

### v0.70-10A VideoStreamPlayer Debug Checkpoint Documentation
- Started from `v0.70-10 VideoStreamTheora Direct Load Test` commit `22c519f8654600229000e3f833a39867a23a769a`.
- Documentation-only pass. Code, scene, and asset files were not intentionally modified.
- Recorded current cutin stability: Yi Sunsin cutin layer, PNG portrait, hero name, skill name, centered layout, 3-second timing, busy guard, fallback, and post-cutin effect flow remain functional.
- Recorded VideoStreamPlayer progress: previous WebM/MP4 attempts failed as loadable `VideoStream` resources, but selecting `yi_sun_sin_cutin_bg_theora_540p.ogv` in Godot FileSystem made the Inspector show `VideoStream`, and a local `.ogv.uid` sidecar appeared.
- Recorded current problem: Theora 540p OGV playback reaches the video path but displays rainbow/glitch-like corrupted output, so the active issue is likely Theora encoding/decoding compatibility.
- Recorded why VideoStreamPlayer remains required for future intro, specialty cutin, battle result, worldmap event, opening, and ending videos; image sequence fallback remains last resort.
- Added next-chat handoff for `v0.70-11 Cutin Safe Theora Encoding Test` with conservative 360p and q6/g64 540p ffmpeg candidate commands.
- Added next-chat reading order: `WORKFLOW_MANAGER`, `CODEX_WORKFLOW_RULES`, `GODOT_RULES`, `CURRENT_STATE`, `NEXT_TASKS`, `HANDOFF_TO_CODEX`, `CHANGELOG`, and `SESSION_LOG`.

### v0.70-10 VideoStreamTheora Direct Load Test
- Started from local `v0.70-9 VideoStreamPlayer Cutin Debug Pass` plus asset commit `9fe21d2 Add Yi Sun-sin Theora 540p cutin video`.
- Focused only on the Yi Sunsin specialty cutin video loading pipeline. Unique-skill 판정/effect/damage, AI, result, wounded/prisoner/death, battle overlay, camera, pop wave, direction-selection, and WorldMap UX were not intentionally changed.
- Confirmed assets: PNG, Theora 540p OGV, VP8 WebM, and MP4 exist; legacy `yi_sun_sin_cutin_bg.ogv` and `yi_sun_sin_cutin_bg.webm` are absent.
- Updated Yi Sunsin candidate priority to Theora 540p OGV first, then VP8 WebM, legacy OGV, snake_case WebM, and MP4.
- Kept ResourceLoader diagnostics and added failure-guess output for each candidate/load attempt.
- Added the Theora direct fallback path using `VideoStreamTheora.new()` with dynamic `file` property verification and logging.
- Preserved `VideoStreamPlayer_Cutin` reuse, stop/clear before assignment, play after stream assignment, delayed state logging, and stop/clear on hide.
- Preserved `CUTIN_VIDEO_DEBUG_FORCE_TOP := false`, centered cutin layout, PNG/text fallback, busy guard, 3-second flow, and post-cutin unique-skill effect continuation.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load with no GDScript warning/error output observed.
- No tracked `.ogv.uid`, `.ogv.import`, or other video sidecar for `yi_sun_sin_cutin_bg_theora_540p.ogv` was observed after Codex verification.
- Codex headless load does not auto-trigger the Yi Sunsin cutin, so F6/manual QA remains required for selected `_theora_540p.ogv`, ResourceLoader logs, direct Theora logs, stream class, `is_playing`, visible video, debug force-top behavior, fallback integrity, and post-cutin effect continuation.

### v0.70-9 VideoStreamPlayer Cutin Debug Pass
- Started from local `v0.70-8 Cutin VP8 WebM Video Connection`.
- Treated this as the first practical SamWar VideoStreamPlayer pipeline diagnostic task, not as visual polish.
- Added candidate diagnostics for the Yi Sunsin cutin video path: candidate path, file existence, `ResourceLoader.exists`, `load()` null/class result, and `VideoStream` cast result.
- Added player diagnostics for `VideoStreamPlayer_Cutin`: stream set/class, `is_playing()`, visible/modulate/self_modulate, size, position/global_position, z-index, parent visible/modulate, and draw-order indexes.
- Kept logs to start-before-assign, after-play-call, and after about `0.3s` to avoid frame-spam.
- Added `CUTIN_VIDEO_DEBUG_FORCE_TOP := false`; final committed default is false.
- Added `_debug_play_cutin_video_only()` for manual QA-only 3-second VideoStreamPlayer playback without changing normal play flow.
- Confirmed the scene child order already matches darken -> video -> slash -> hero -> text, and made runtime z-index match that order.
- Confirmed local tracked asset state: `yi_sun_sin_cutin_bg_vp8.webm` and MP4 are present; requested OGV and snake_case non-VP8 WebM fallback files are absent; no tracked video sidecar was generated.
- Preserved central cutin layout, PNG/text fallback, busy guard, 3-second flow, and post-cutin unique-skill effect continuation.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load with no GDScript warning/error output observed.
- Codex headless load does not auto-trigger the Yi Sunsin cutin, so F6/manual QA remains required for actual video frame visibility and new console log interpretation.

### v0.70-8 Cutin VP8 WebM Video Connection
- Started from latest local state after `v0.70-7 Cutin OGV Video Fallback`.
- Focused only on Yi Sunsin cutin video selection and load fallback. Unique-skill 판정/effect/damage, AI, results, battle overlay, camera, pop wave, direction-selection, and WorldMap UX were not intentionally changed.
- Confirmed required Yi Sunsin cutin assets exist: `assets/ui/cutin/portraits/yi_sun_sin_cutin.png` and `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm`.
- Confirmed tracked fallback state in this local repo: `assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4` exists, while `assets/ui/cutin/videos/yi_sun_sin_cutin_bg.ogv` and `assets/ui/cutin/videos/yi_sun_sin_cutin_bg.webm` are not present.
- Updated Yi Sunsin cutin video selection to `vp8 webm > ogv > webm > mp4`, with `yi_sun_sin_cutin_bg_vp8.webm` selected first when present.
- Kept OGV as unstable fallback only and did not delete or convert video assets.
- Preserved the existing `VideoStreamPlayer_Cutin` start/hide stop-and-clear behavior and the PNG/text fallback path.
- Preserved the centered v0.70-6/v0.70-7 cutin banner/card layout.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load with no GDScript warning/error output observed.
- No tracked `.webm.uid`, `.webm.import`, or other video sidecar was generated for `yi_sun_sin_cutin_bg_vp8.webm` during Codex verification.
- F6 manual QA remains: VP8 WebM visibility, image quality, centered banner feel, PNG/text fallback, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.

### v0.70-7 Cutin OGV Video Fallback
- Started from latest local state after `v0.70-6 Cutin WebM Video Connection + Center Layout Fix`.
- Focused only on Yi Sunsin cutin video selection and load fallback. Unique-skill 판정/effect/damage, AI, results, battle overlay, camera, pop wave, direction-selection, and WorldMap UX were not intentionally changed.
- Confirmed tracked Yi Sunsin cutin assets include `assets/ui/cutin/portraits/yi_sun_sin_cutin.png`, `assets/ui/cutin/videos/yi_sun_sin_cutin_bg.ogv`, and `assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4`. The requested snake_case WebM path is kept as a fallback candidate, but it was not present in tracked files during this pass.
- Confirmed no tracked `.ogv.import` file exists; Godot has a `yi_sun_sin_cutin_bg.ogv.uid` sidecar for the OGV asset.
- Updated Yi Sunsin cutin video selection to `ogv > webm > mp4`, with `yi_sun_sin_cutin_bg.ogv` selected before WebM/MP4 when present.
- Added debug logs for selected video candidate, successful selected video, no candidate, and selected-candidate load failure.
- Preserved the existing `VideoStreamPlayer_Cutin` start/hide stop-and-clear behavior and the PNG/text fallback path.
- Preserved the centered v0.70-6 cutin banner/card layout.
- F6 manual QA remains: OGV visibility, centered banner feel, PNG/text fallback, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.

## 2026-06-01

### v0.70-6 Cutin WebM Video Connection + Center Layout Fix
- Started from base commit `e6c0a170b428dfa2bf1da845d831a917530ca35f` / `v0.70-5 Specialty Skill Video Cutin MVP`.
- Focused only on Yi Sunsin cutin video connection and layout. Unique-skill 판정/effect/damage, AI, results, battle overlay, camera, pop wave, direction-selection, and WorldMap UX were not intentionally changed.
- Confirmed tracked WebM assets exist in `assets/ui/cutin/videos/`: `Yi Sun Sin Cutin Bg.webm`, `Kwon Yul Cutin Bg.webm`, and `Jeong Do Jeon Cutin Bg.webm`.
- Updated Yi Sunsin cutin video selection to prioritize WebM candidates, then OGV, then MP4. The actual repo WebM filename is included before OGV/MP4 fallback.
- Reworked the cutin from side-biased slide placement into a centered banner/card composition with center scale/fade entry and exit.
- Kept Yi Sunsin PNG size feel close to v0.70-5 while arranging portrait, hero name, and skill name around the centered composition.
- Preserved busy guard and PNG/text fallback when no candidate video can be loaded.
- Godot headless did not generate tracked WebM `.import` files, so actual F6 WebM playback remains a manual QA item.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load with clean warning/error output.
- F6 manual QA remains: WebM visibility, centered banner feel, portrait/text composition, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.

### v0.70-5 Specialty Skill Video Cutin MVP
- Started from latest local HEAD after `v0.70-4 Battle Overlay Rollback Shape + Palette Retune`.
- Focused only on ally Yi Sunsin unique-skill presentation; battle rules, formulas, AI, results, overlays, camera, pop wave, direction-selection, and WorldMap UX were not intentionally changed.
- Found the requested assets in repo: `assets/ui/cutin/portraits/yi_sun_sin_cutin.png` and `assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4`.
- Added a reusable scene-authored `BattleUI/SkillCutinLayer` with darken, video player, slash accent, transparent portrait, hero name, skill name, and animation-player placeholder nodes.
- Connected ally `yi_sunsin` unique skill to a 3-second specialty cutin path and delayed existing effect application until the cutin finishes.
- Preserved existing toast fallback for non-Yi-Sunsin heroes and for Yi Sunsin if the specialty cutin layer or portrait cannot be loaded.
- Added a busy guard to prevent overlapping specialty cutins.
- mp4 playback remains a risk: the mp4 file exists, but no imported Godot VideoStream metadata was found. Runtime code logs this and continues with the portrait/text cutin if ResourceLoader cannot load the video.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. GDScript warning/error output was clean after fixing one enum typo and one full-rect size warning.
- F6 manual QA remains: video playback, cutin impact, 3-second pacing, portrait placement, skill-name readability, effect continuation after cutin, fallback behavior, no soft lock, and normal battle flow.

### v0.70-4 Battle Overlay Rollback Shape + Palette Retune
- Started from latest local HEAD after `v0.70-3 Battle Overlay Palette Pop Wave Polish`.
- Focused only on battle overlay visual rollback/palette tuning; camera zoom remained at `0.84` and the default grid remained hidden.
- Preserved the successful v0.70-3 pop wave/stagger timing, distance-based scale overshoot, settle behavior, and tween cleanup.
- Removed the center-fade/internal band rendering that made overlay tiles look like stacked inner octagons.
- Restored overlay tiles to a simpler single-fill octagonal structure closer to v0.70-2.
- Retuned movement range to a clearer blue tactical tone and restored stronger role separation for attack, single-target, multi-target/unique-skill, and strategy overlays.
- Restored direction-selection tiles to the original gold/yellow role color while keeping the octagonal shape and short pop reveal.
- No battle rules, move/attack 판정, damage formula, AI, result, wounded/prisoner/death, or WorldMap UX logic was intentionally changed.
- Verification passed: Godot headless project load and `Battle_Fullscreen_Test.tscn` headless load. GDScript warning/error output was clean.
- F6 manual QA remains: pop wave retention, no multi-layer internal octagons, simple v0.70-2-like tile shape, movement blue taste, role-color separation, restored direction-selection color, and click feel.

### v0.70-3 Battle Overlay Palette + Pop Wave Polish
- Started from latest local HEAD after `v0.70-2 Battle Overlay Shape + Wave Tuning`.
- Focused only on battle overlay visual/UX polish; camera zoom remained at `0.84`.
- Retuned movement, attack, single-target, multi-target, and strategy colors into a more cohesive toned tactical palette while preserving type distinction.
- Updated `BattleRangeOverlayTile` rendering from inner-octagon layering to center-fade edge bands so terrain shows more naturally through the tile center.
- Strengthened wave timing to `0.06s` per grid distance and changed pop scaling to distance-sensitive start/overshoot values.
- Added `BattleFacingArrowTileButton` and applied it to the four direction-selection arrow buttons, preserving the existing button click handlers while matching the octagonal overlay design language.
- Added short pop reveal for direction-selection tiles.
- No battle rules, move/attack 판정, damage formula, AI, result, wounded/prisoner/death, or WorldMap UX logic was intentionally changed.
- Verification passed: Godot headless project load and `Battle_Fullscreen_Test.tscn` headless load. GDScript warning/error output was clean.
- F6 manual QA remains: distinct but cohesive overlay palette, reduced sky-blue casual feel, center-fade interior, natural terrain visibility, visible unit-centered pop wave, near/far pop strength, direction tile unification, and click feel.

### v0.70-2 Battle Overlay Shape + Wave Tuning
- Started from baseline `v0.70-1 Battle Visual Detail Polish Start` / base commit `60bdf2cc5955180a93cf4ea9e439d1a103f6cf7e`.
- Focused only on battle visual/UX overlay tuning and deferred WorldMap final IA work.
- Changed the scene-authored `MainCamera` zoom from `0.88` to `0.84` to show more battlefield background.
- Added `scripts/battle_range_overlay_tile.gd` so existing range overlay `ColorRect` cells draw as clipped-corner octagonal tactical tiles.
- Kept the existing `MoveRangeOverlayLayer` cell pool and movement/attack range calculations unchanged.
- Tuned tile rendering with low-alpha fill, softer inner fill, clear outline, and subtle inner highlight for a less debug-like tactical UI read.
- Strengthened range wave timing to distance `* 0.04s`, with alpha fade and scale `0.86 -> 1.04 -> 1.0`.
- Preserved tween cleanup on overlay hide paths to avoid delayed ghost cells during cancel, action resolve, or selection changes.
- No battle rules, move/attack 판정, damage formula, AI, result, wounded/prisoner/death, or WorldMap UX logic was intentionally changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. GDScript warning/error output was clean.
- F6 manual QA remains: zoom `0.84` feel, background visibility, unit size, octagonal tile shape, outline clarity, fill alpha, terrain visibility, wave direction/timing, direct move click, attack click, right-click cancel, floating command panel, and auto/turn progression.

### v0.70-1 Battle Visual Detail Polish Start
- Started from baseline `v0.69-14A GDScript Reload Warning Cleanup Before v0.70` / base commit `f0795b4`.
- Focused the first v0.70 detail-polish pass on battle-engine visuals, deferring WorldMap final UX/UI work.
- Hid the default logical grid by setting the normal-play grid flag off and saving `LogicalGridGuideLayer` hidden in `Battle_Fullscreen_Test.tscn`.
- Set the scene-authored `MainCamera` zoom to `0.88`, showing more battlefield background art without forcing camera position from code.
- Improved movement/attack range overlay read by using stronger translucent blue/red cells with inset bounds.
- Added quick distance-based range overlay wave/stagger reveal from the selected/casting unit with alpha and scale tweening.
- Added tween cleanup on range overlay hide paths to prevent stale cells after cancel, movement, attack, strategy, or unique-skill transitions.
- Reused the existing `MoveRangeOverlayLayer` cell pool. No external assets, new large UI system, battle formula change, AI change, result change, wounded/prisoner/death change, or WorldMap UX logic change was made.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. GDScript reload warning/error output was clean in the headless load.
- F6 manual QA remains: camera zoom-out feel, background readability, unit size, hidden default grid feel, move/attack overlay visual taste, wave timing, direct move click, attack click, right-click cancel, floating command panel, and auto/turn progression.

### v0.69-14A GDScript Reload Warning Cleanup Before v0.70
- Cleaned the reported Godot GDScript reload warnings in `scripts/worldmap_test.gd` before `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Renamed inner food-cost variables to avoid `before_amount` / `paid_amount` parent-block redeclaration warnings.
- Renamed tech definition factory parameters from `name` to `tech_name` to avoid `Node.name` shadowing warnings.
- Replaced the mixed-type spy tech payload ternary with an equivalent branch that preserves the existing payload behavior.
- Renamed the unused seasonal loyalty parameter to `_supply_states`.
- No strategic logic, formulas, balance values, save/load structure, battle, invasion, diplomacy, espionage, tech, trade, or resource behavior was intentionally changed.
- Remaining work is `v0.70-1 WorldMap Final UX/UI Information Architecture`.

### v0.69-14 EASTWAR Strategic Logic Final Checkpoint
- Started from baseline commit `0565f2d5f0acfde609e9df9e96d8e3b25726196c` / `v0.69-13 Espionage Action Foundation MVP`.
- Performed a documentation-only checkpoint. No code implementation was added.
- Recorded v0.69 as the completed EASTWAR strategic simulation logic foundation.
- Summarized the completed v0.69 systems from publicSupport and loyalty through tech, trade, diplomacy, and espionage foundations.
- Documented that most v0.69 verification was helper/API/headless QA and that real F6 mouse-based UX verification should happen during the v0.70 WorldMap final UI pass.
- Updated the handoff so the next new chat/session starts from `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Noted that current City Detail / WorldMap UI is temporary/minimal and that v0.70 should prioritize information architecture before additional logic.
- Deferred high-risk follow-ups beyond v0.70 UI foundation: real revolt, neutral owner conversion, suppression battle, assassination, actual allied military support troop movement, and joint invasion.

### v0.69-13 Espionage Action Foundation MVP
- Started from baseline commit `3da9193b33b523b5de6d0230a988f4d374bbc108` / `v0.69-12 Diplomacy Action Foundation MVP`.
- `GUIDE_v0.69_12_13_to_v0.70.md` was not present in the repo, so this pass followed the explicit v0.69-13 task text.
- Implemented loyalty disruption, revolt instigation, and wedge driving in `scripts/worldmap_test.gd`.
- Reused the existing chancellor political aptitude, spy success chance, detection chance, generic resource cost, relation score adjustment, city publicSupport, city loyalty, and shared `spy_cooldown` structures.
- Loyalty disruption uses cost `gold 500 + silk 50`, base cooldown `10`, political-primary cooldown `8`, and detection penalty `-40`.
- Revolt instigation uses cost `gold 800 + silk 100`, base cooldown `15`, political-primary cooldown `13`, and detection penalty `-60`. Success records a 3-turn boost only.
- Wedge driving uses cost `gold 600 + silk 150`, base cooldown `12`, political-primary cooldown `10`, and detection penalty `-20` against each target faction from the player.
- Added `_advance_revolt_instigation_for_world_turn()` and connected it to the domestic turn pipeline. It only decrements/removes stored boosts.
- Did not implement assassination, actual revolt, owner neutral conversion, suppression battle, war declaration, automatic hostile conversion, alliance break, UI, or battle/invasion/defense changes.
- QA runner confirmed own/enemy validation, aptitude effect tables, forced success/failure/detection behavior, cost deduction, cooldown set/decrement path, relation penalties, no status auto-change, no owner change, wedge allied-only gate, publicSupport disruption still working, and save/load preservation of relevant state.
- v0.69 can now move toward `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Remaining risks: all spy actions are API-only; revolt boost has no real revolt consumer; final balance and F6 UX validation are pending.

### v0.69-12 Diplomacy Action Foundation MVP
- Started from baseline commit `b74c40e` / `v0.69-11B`.
- `GUIDE_v0.69_12_13_to_v0.70.md` was not present in the repo, so this pass followed the explicit v0.69-12 task text.
- Implemented `_propose_alliance`, `_request_military_support`, and `_propose_trade_agreement` in `scripts/worldmap_test.gd`.
- Added deterministic alliance acceptance chance. High-score/resource packages can pass the `>= 70` threshold; accepted alliances set `allied` and record duration.
- Alliance proposals deduct the provided resource package on attempt.
- Military support requires allied status and records result only. Rejection applies relation `-20`; third and later repeated rejection applies `-40`.
- Trade agreements require relation score `>= 50`, cost `gold 200 + silk 50`, and add a separate `+0.15` trade route bonus without changing base Phase A relation multipliers.
- Did not implement war declaration, actual troop support movement, joint invasion, battle/invasion/defense changes, diplomacy UI, or publicSupport/loyalty/tech/supply formula changes.
- QA runner confirmed alliance chance values, accepted alliance status/duration, proposal cost deduction, military support allied-only gate, rejection penalties, trade agreement score gate, trade agreement cost deduction, and route bonus.
- Remaining risks: guide file is absent; acceptance values are MVP balance; alliance/trade duration expiry is not yet advanced by turn pipeline; no UI trigger exists.

### v0.69-11B Espionage Public Support Disrupt MVP
- Started from baseline commit `e3cf2f57fb0ada9e902976f1d8622f347c37ed56` / `v0.69-11 Espionage Info Gathering MVP`.
- Implemented the first offensive espionage action, publicSupport disruption, in `scripts/worldmap_test.gd`.
- Added fixed cost `gold 300`, cooldown `8`, and detected relation penalty `-30`.
- Added aptitude-based effect amounts: `5/4/3/2/1 -> 20/15/10/5/3`.
- Added `_can_disrupt_city_public_support`, `_roll_spy_public_support_disrupt_result`, and `_disrupt_city_public_support`.
- Reused shared `spy_cooldown`; primary political chancellor applies cooldown `-2`, so disruption cooldown is `6` for primary political chancellors.
- Successful non-detected disruption lowers target publicSupport. Failed non-detected disruption leaves publicSupport unchanged.
- Detected disruption cancels the effect and applies relation score `-30`; status does not auto-convert to hostile and war is not declared.
- Did not implement loyalty disruption, revolt instigation, alienation, assassination, real revolt, owner neutral conversion, espionage UI, battle changes, or save/load core rewrites.
- QA runner confirmed validation failures, iron-wall block, effect amount table, success/failure/detection outcomes, relation penalty, status non-conversion, cooldown set/decrement, save/load preservation, and no unintended loyalty/troop/tech mutation.
- Next candidates are `v0.69-11C Espionage Detection Penalty Audit` or `v0.69-10C Alliance War Status Foundation MVP`.
- Remaining risks: no player-facing UI trigger exists; detection penalty is score-only; disruption balance needs later review.

### v0.69-11 Espionage Info Gathering MVP
- Started from baseline commit `dd61a57cbaa9dc7da484b80d9ff76ad5f557dab6` / `v0.69-10B Tribute Diplomacy Action MVP`.
- Implemented chancellor-driven enemy city information gathering in `scripts/worldmap_test.gd`.
- Added political aptitude lookup using existing chancellor hero data.
- Added success chance table for political aptitude `5/4/3/2/1 -> 80/65/50/35/20`.
- Added visibility levels from `troops_estimated` at aptitude `1` up to troops/resources/publicSupport/loyalty/governor/tech at aptitude `5`.
- Added target detection chance based on security/public order and loyalty, with primary political chancellor detection `-10`.
- Added forced-roll spy result helper for deterministic QA and `_gather_spy_info()` result/payload recording.
- Added `spy_cooldown`, `last_spy_result`, and `last_spy_cooldown_result`; cooldown is base `6`, or `4` for primary political chancellor.
- Connected spy cooldown decrement to the domestic world turn. No automatic spy action is run.
- Detection is recorded only. No relation score penalty, status change, war, revolt, or target-city mutation was added.
- Did not implement publicSupport disruption, loyalty disruption, revolt instigation, alienation, assassination, espionage UI, battle changes, or save/load core rewrites.
- QA runner confirmed no-chancellor/no-political/own-city blocks, success and visibility tables, enemy target availability, forced success/failure/detection, payload fields, cooldown `4/6`, cooldown decrement, save/load preservation, and no target city/relation/resource/tech mutation.
- Next candidates are `v0.69-11B Espionage Public Support Disrupt MVP` or `v0.69-10C Alliance War Status Foundation MVP`.
- Remaining risks: no UI trigger exists; detection has no gameplay penalty yet; target tech visibility is limited by existing data.

### v0.69-10B Tribute Diplomacy Action MVP
- Started from baseline commit `ef1e5aa6d3fd53ba2ecbc29a04aa8ee44082e872` / `v0.69-10 Diplomacy Relation Score MVP`.
- Implemented the first diplomacy action MVP, tribute, in `scripts/worldmap_test.gd`.
- Added tribute cost helper with MVP cost `gold 300` + `silk 100`.
- Added deterministic tribute relation gain `+20`, within the documented `15..25` future balance range.
- Added `_can_send_tribute` and `_send_tribute` with validation for invalid/self targets, hostile status, suspended status, active cooldown, and insufficient resources.
- Tribute uses a separate `tribute_cooldown` field set to `5` turns. The existing relation `cooldown` field is not reused.
- Added `_advance_diplomacy_cooldowns_for_world_turn` and connected it to the domestic world turn after relation normalization.
- Added `last_tribute_result` and `last_diplomacy_cooldown_result`.
- Kept status separate from score; tribute does not auto-convert status to allied or hostile.
- Kept Phase A trade multiplier status-based and unchanged.
- Did not implement alliance proposal, trade agreement, declaration of war, espionage, revolt instigation, specialty trade execution, diplomacy UI, battle changes, or save/load core rewrites.
- QA runner confirmed tribute validation, cost payment, score gain/clamp, status non-conversion, cooldown set/decrement/re-enable behavior, save/load preservation, Phase A trade income invariance, and no unintended publicSupport/loyalty/troop/tech mutation.
- Next candidates are `v0.69-10C Alliance War Status Foundation MVP` or `v0.69-11 Espionage Info Gathering MVP`.
- Remaining risks: no player-facing UI trigger exists; fixed tribute cost/gain need future balance review; no AI response exists.

### v0.69-10 Diplomacy Relation Score MVP
- Started from baseline commit `64351822aa0acd80079b135862c983bec4803043` / `v0.69-9 Trade Deepening Data Market Price MVP`.
- Implemented score-based diplomacy relation foundation in `scripts/worldmap_test.gd`.
- Added `DIPLOMACY_SCORE_MIN`, `DIPLOMACY_SCORE_MAX`, and `DIPLOMACY_DEFAULT_SCORE`.
- Added relation entry normalization so existing or new `faction_relations` entries contain `status`, `score`, and `cooldown`.
- Added `_get_faction_relation_score`, `_get_faction_relation_band`, `_adjust_faction_relation_score`, and `_normalize_faction_relations_for_world_state`.
- Kept `status` and `relation_band` separate. Score changes do not auto-change status to allied or hostile.
- Kept Phase A trade income status-based; route entries now include `relation_score` and `relation_band` for display/debug context only.
- Domestic turn now normalizes faction relations before Phase A trade calculation.
- Did not implement tribute, trade agreement, alliance proposal, declaration of war, espionage, revolt instigation, specialty trade execution, diplomacy UI, battle changes, or save/load core rewrites.
- QA runner confirmed score patching, status/cooldown preservation, score clamp, band thresholds, status non-conversion, Phase A trade income invariance, route score/band fields, save/load preservation, and no resource/publicSupport/loyalty/troop/tech mutation.
- Next candidates are `v0.69-10B Tribute Diplomacy Action MVP` or `v0.69-11 Espionage Info Gathering MVP`.
- Remaining risks: score has no diplomacy action consumer yet; normalization creates all known city-owner faction pairs; final F6 diplomacy UX validation remains deferred.

## 2026-05-31

### v0.69-9 Trade Deepening Data Market Price MVP
- Started from baseline commit `547699fa8365bdf53c085dfef59150e809b5a05b` / `v0.69-8B Tech Effect Application MVP`.
- Implemented deterministic trade market price data/calculation in `scripts/worldmap_test.gd`.
- Added `_get_trade_market_base_prices`, `_get_trade_resource_display_name`, `_get_trade_season_multiplier`, `_get_trade_situation_multiplier`, `_calculate_trade_market_prices`, and `_update_trade_market_for_world_turn`.
- Recorded market prices in `_player_state["last_trade_market_result"]` with `turn`, `season`, `season_label`, `context`, and per-resource price entries.
- Connected market update to the domestic turn pipeline after tech progress/effects so the current supply isolation count can influence prices.
- Added a compact turn summary line for market prices.
- Kept existing Phase A inter-faction trade income unchanged and separate.
- Did not implement manual trade, resource exchange, trade agreements, diplomacy, maritime trade, pirate loss, hero trade traits, random price volatility, trade UI, battle changes, or save/load core rewrites.
- QA runner confirmed base prices, seasonal wrap, situation multipliers, deterministic calculation, no resource stock mutation, no inter-faction trade result mutation, and `last_trade_market_result` recording.
- Next candidates are `v0.69-9B Specialty Trade Data MVP` or `v0.69-10 Diplomacy Relation Score MVP`.
- Remaining risks: market prices are calculation-only until transaction systems exist; most situation flags are future-context placeholders; final F6 trade UX validation remains deferred.

### v0.69-8B Tech Effect Application MVP
- Started from baseline commit `f4c21f9d2d46712c2e1e9c40f66f768db323cada` / `v0.69-8 Tech Start Progress Pipeline MVP`.
- Implemented the first Tech Effect Application MVP in `scripts/worldmap_test.gd`.
- Added one-time completed tech effect handling through `_apply_completed_tech_effects_for_world_turn()`.
- Implemented `legal_reform`: all player-owned cities get publicSupport `+5` once, with duplicate prevention via `applied_tech_effects`.
- Implemented `tax_reform`: domestic gold income `x1.10`; inter-faction trade income is not affected.
- Implemented `street_market`: city domestic gold income `x1.05`; inter-faction trade income is not affected.
- Implemented `barracks`: automatic conscription now requires completed city `barracks`; missing barracks records reason `barracks_required`.
- Implemented `conscription_system`: turnly automatic conscription add `x1.10`, capped by available conscription. Capacity remains unchanged.
- Recorded no-consumer recognized effects for `national_foundation`, `improved_farming_tools`, and `fishing_village`.
- Did not implement all tech effects, battle effects, turtle ship/special units, diplomacy/espionage, real revolt, trade deepening, tech UI, auto tech selection, battle scene changes, or save/load core rewrites.
- Verification passed: `rg` checks, temporary QA runner, scoped diff review, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load.
- QA runner confirmed legal_reform +5 and duplicate prevention, applied_tech_effects save/load preservation, tax_reform/street_market domestic gold multipliers and non-trade behavior, multiplier stacking, barracks conscription gate, conscription_system +10% add with cap, no-consumer recognition, and no unintended loyalty/troop/resource mutation.
- Godot `--headless --check-only` timed out after 134 seconds and is recorded as inconclusive.
- Next candidate is `v0.69-9 Trade Deepening MVP`.
- Remaining risks: most tech effects are still pending; barracks gating needs balance review; no tech UI or final F6 UX validation exists.

## 2026-05-31

### v0.69-8 Tech Start Progress Pipeline MVP
- Started from baseline commit `adb9ce7c2dbfa3bd019abe882a6120b0fff8a788` / `v0.69-7A National City Tech Data Consistency Audit`.
- Implemented the common national/city tech start and progress pipeline in `scripts/worldmap_test.gd`.
- Added `_get_tech_duration_turns(tier)` with MVP defaults: basic 4, mid 9, advanced 18, capstone 28, rare 30.
- Added generic resource cost check/deduction helpers. `food` uses the existing rice+barley+seafood pool and deducts in order `rice -> barley -> seafood`.
- Implemented `_start_national_tech(tech_id)` and `_start_city_tech(city_id, tech_id)` as real MVP start functions.
- Start flow now checks requirements/cost, deducts cost, registers `in_progress`, records duration/remaining turns, and writes `last_tech_start_result`.
- Added `_advance_national_tech_progress_for_world_turn()` and `_advance_city_tech_progress_for_world_turn()`.
- Completed tech moves from `in_progress` to `completed`; completed entries include `effect_summary` and `effect_applied: false`.
- Connected tech progress to `_apply_domestic_turn_mvp()` after revolt warning, under the existing `last_domestic_apply_turn` guard so same-turn duplicate calls do not double-decrement.
- Added minimal turn-summary text for completed national/city tech.
- Did not implement tech effect application, UI, auto tech selection, governor/chancellor auto progress, formula changes, battle/invasion/defense changes, or save/load core rewrites.
- Verification passed: `rg` for new/changed helpers and result fields, temporary QA runner, scoped diff reviews, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load.
- QA runner confirmed national/city tech start, cost deduction, in-progress registration, duration setup, progress decrement, completed migration, completed restart block, city tech completion, food-pool deduction order, cost shortage rejection, placeholder-condition rejection, no publicSupport/loyalty/troop mutation from tech progress helpers, no effect application, and no same-turn double decrement.
- Godot `--headless --check-only` timed out after 134 seconds and is recorded as inconclusive.
- Next candidates are `v0.69-8B Tech Effect Application MVP` or `v0.69-9 Trade Deepening MVP`.
- Remaining risks: no effect application, no player-facing UI, no automatic selection, and several placeholder conditions still block advanced techs.

## 2026-05-31

### v0.69-7A National City Tech Data Consistency Audit
- Started from baseline commit `3a5ac0f35adcca50ef42813511c3ed9d50f9be0c` / `v0.69-7 City Tech Tree Data MVP`.
- Completed National/City Tech Data Consistency Audit in `scripts/worldmap_test.gd`.
- Added `_validate_tech_data_consistency()` as a QA/debug-only helper that checks definitions without mutating player_state, resources, troops, publicSupport, or loyalty.
- Required national tech cross-check found `mint -> unified_currency`, `armored_infantry -> military_reform`, and `turtle_ship -> military_reform` valid.
- Required national tech cross-check found `dried_fish_supply_base -> logistics_system` missing; added documented national tech `logistics_system` / `병참 제도` as the minimal correction.
- City and national `requires` cross-checks pass with no missing prerequisite IDs.
- Cost key audit passes against allowed keys; `food` remains the MVP rice+barley+seafood pool key.
- Aptitude type audit passes; `maritime` remains allowed even though current hero data may not provide a dedicated maritime source.
- Added `icon_path` and `image_path` placeholders to national tech definitions. No image loading or UI was added.
- Placeholder conditions remain blocking: `chancellor_type_turns`, `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, `has_hero_yi_sunsin`, `has_city_tech_mint`, `has_silkroad_or_trade_port`, `neutral_faction_count`, and `allied_faction_count`.
- Did not implement tech progress/completion, cost deduction, effect application, UI, formula changes, battle/invasion/defense changes, or save/load core rewrites.
- Verification passed: `rg` for audit helper, temporary QA runner, scoped diff reviews, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load.
- Godot `--headless --check-only` timed out after 134 seconds and is recorded as inconclusive.
- Next candidate is `v0.69-8 Tech Start/Progress Pipeline MVP`.
- Remaining risks: `connected_supply_city_count` still needs a real data source; maritime remains data-allowed but not hero-data-backed; tech lifecycle/effects/UI are still unimplemented.

## 2026-05-31

### v0.69-7 City Tech Tree Data MVP
- Started from baseline commit `f4f80e8` / `v0.69-6 National Tech Tree Data MVP`.
- Implemented City Tech Tree Data MVP in `scripts/worldmap_test.gd`.
- Added city tech definitions for agriculture, commerce, fishery/coastal, military, and coastal/naval MVP branches.
- Added `icon_path` and `image_path` placeholders as empty strings for future tech UI image connection.
- Added per-city `city_tech` runtime state with `completed`, `in_progress`, and `available_cache`, normalized through `_ensure_city_tech_state(city_id)`.
- Added lookup helpers, city governor aptitude type lookup, requirement checks, cost checks, and start eligibility checks.
- Added `_start_city_tech` as a no-op skeleton returning `false`; it does not deduct costs or register progress.
- Placeholder conditions are blocking and reported as missing: `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, and `has_hero_yi_sunsin`.
- Food cost is checked as rice+barley+seafood pool only. No resource deduction occurs.
- Minimal save/load preservation was added for the city runtime `city_tech` field without rewriting save/load core flow.
- Did not implement national tech progress/completion, city tech start/progress/completion, effect application, UI, governor auto-selection, battle/invasion/defense changes, save/load core rewrite, or changes to publicSupport/loyalty/recruitment/revolt/national tech/trade/supply/troop move formulas.
- Verification passed: `rg` for new helpers/state, scoped diff reviews, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless QA runner.
- QA runner confirmed required definitions, icon/image placeholders, prerequisite blocking, national tech requirement blocking, governor mismatch blocking, coastal true/false checks, loyalty true/false checks, placeholder blocking, cost missing report, completed/in-progress blocking, and no mutation from check helpers.
- Godot `--headless --check-only` timed out after 134 seconds and is recorded as inconclusive.
- Next candidates are `v0.69-8 Tech Start/Progress Pipeline MVP` or `v0.69-6B National Tech Start/Progress MVP`.
- Remaining risks: placeholder conditions block several advanced city techs; maritime governor type is not backed by current hero data unless explicitly added later; no research lifecycle, effects, UI, or final UX validation exists yet.

## 2026-05-31

### v0.69-6 National Tech Tree Data MVP
- Started from baseline commit `c3c181c` / `v0.69-5 Revolt Warning Foundation MVP`.
- Implemented National Tech Tree Data MVP in `scripts/worldmap_test.gd`.
- Added national tech definitions for the MVP branch spine: foundation, administrative, economic, military, diplomatic, and political.
- Added `national_tech` player state with `completed`, `in_progress`, and `available_cache`, normalized through `_ensure_national_tech_state()`.
- Added lookup helpers, current chancellor primary aptitude type lookup, requirement checks, cost checks, and start eligibility checks.
- Added `_start_national_tech` as a no-op skeleton returning `false`; it does not deduct costs or register progress.
- Placeholder conditions are blocking and reported as missing: `chancellor_type_turns`, `allied_faction_count`, `neutral_faction_count`, `has_city_tech_mint`, and `has_silkroad_or_trade_port`.
- Food cost is checked as rice+barley+seafood pool only. No resource deduction occurs.
- Did not implement city tech tree, national tech start/progress/completion, effect application, UI, auto tech selection, battle/invasion/defense changes, save/load core rewrite, or changes to publicSupport/loyalty/revolt/recruitment/trade/supply formulas.
- Verification passed: `rg` for new helpers/state, scoped diff reviews, `battle_web_import_test.gd` unchanged, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless QA runner.
- QA runner confirmed definitions, foundation start eligibility, prerequisite blocking, chancellor mismatch blocking, owned city count, national loyalty, average loyalty, average commerce, placeholder blocking, cost missing report, completed/in-progress blocking, and no mutation from check helpers.
- Godot `--headless --check-only` timed out after 134 seconds and is recorded as inconclusive.
- Superseded by `v0.69-7`: City Tech Tree Data MVP is complete.
- Next candidates are `v0.69-8 Tech Start/Progress Pipeline MVP` or `v0.69-6B National Tech Start/Progress MVP`.
- Remaining risks: placeholder conditions block several techs; no research lifecycle, effects, UI, or final UX validation exists yet.

## 2026-05-31

### v0.69-5 Revolt Warning Foundation MVP
- Started from baseline commit `dd531db` / `v0.69-4 Recruitment Conscription Foundation MVP`.
- Implemented revolt warning foundation logic in `scripts/worldmap_test.gd`.
- Added `REVOLT_RISK_STABLE`, `REVOLT_RISK_WARNING`, and `REVOLT_RISK_DANGER`.
- Added `_calculate_city_revolt_risk(city_id)` using current city publicSupport and loyalty only.
- Added `_apply_revolt_warning_check_for_world_turn()` to scan player-owned cities, aggregate warning/danger counts, and record `last_revolt_warning_result`.
- Warning threshold: publicSupport `<= 40` and loyalty `<= 40`.
- Danger threshold: publicSupport `<= 30` and loyalty `<= 30`.
- Connected revolt warning after publicSupport drift, city loyalty drift, seasonal loyalty from publicSupport, and conscription in `_apply_domestic_turn_mvp`.
- Added minimal City Detail and turn-summary display for revolt risk.
- Did not implement actual revolt occurrence, neutral owner changes, suppression battles, espionage revolt agitation, map markers, or final UI.
- Did not modify publicSupport, seasonal loyalty, conscription/recruitment, troop movement, P0-1/P0-2/Phase A/Phase B, battle scene code, save/load core, tech tree, trade deepening, diplomacy, or espionage formulas/logic.
- Verification passed: `rg` for new constants/helpers/result field, scoped diff reviews for owner/neutral/save-load/formula non-changes, `battle_web_import_test.gd` unchanged, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless QA runner.
- QA runner confirmed stable/warning/danger thresholds, low-only cases, result recording, warning/danger count aggregation, no publicSupport/loyalty/troops/owner mutation, and turn summary danger text.
- Godot `--headless --check-only` timed out after 134 seconds and is recorded as inconclusive.
- Real F6 mouse-based UX verification remains deferred to the June City Detail/WorldMap UI overhaul.
- Remaining risks: warning-only system; no actual revolt lifecycle, no espionage integration, no map warning UI, and no final UX validation yet.

## 2026-05-31

### v0.69-4 Recruitment/Conscription Foundation MVP
- Started from baseline commit `9df4e49` / `v0.69-3A Strategic Logic Checkpoint Documentation`.
- Implemented recruitment/conscription foundation logic in `scripts/worldmap_test.gd`.
- Added loyalty-based conscription capacity and available helpers.
- Added automatic domestic-turn conscription as slow free troop growth: player-owned cities add `min(available, 100)` troops when below loyalty-based capacity.
- Placed automatic conscription after publicSupport drift, existing P0-2 city loyalty drift, and seasonal loyalty from publicSupport so it uses current post-seasonal loyalty.
- Added initial recruitment limit, cost, validation, and execution helpers; v0.70-21 later corrected the amount-limit axis to city loyalty.
- Recruitment is immediate paid troop growth and is helper/API only in this MVP. No explicit recruitment button/panel was added.
- Recruitment cost uses `gold = amount` and `food = amount / 2`; MVP food payment deducts national `resource_stock` in order `rice -> barley -> seafood`.
- Added `last_conscription_result` and `last_recruitment_result` recording.
- Added minimal City Detail internal/supply text for conscription and recruitment values.
- Did not reduce population. Did not directly change publicSupport or loyalty from conscription/recruitment. Did not implement recruitment fatigue or publicSupport decline.
- Did not modify publicSupport formula, seasonal loyalty formula, troop movement loyalty-efficiency formula, P0-1/P0-2/Phase A/Phase B calculations, battle scene code, save/load core, revolt, tech trees, trade deepening, diplomacy/espionage, or large UI.
- Verification passed: `rg` for new helpers/result fields, scoped diff reviews, `battle_web_import_test.gd` unchanged, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless QA runner.
- QA runner confirmed conscription capacity thresholds, available=0 when troops meet capacity, auto conscription adds only `min(available, 100)`, no direct publicSupport/loyalty changes, save/load troop preservation, recruitment limits by publicSupport, recruitment costs, resource shortage rejection, successful recruitment troop/resource changes, no automatic recruitment, and last-result recording.
- Godot `--headless --check-only` timed out after 134 seconds and is recorded as inconclusive.
- Real F6 mouse-based UX verification remains deferred to the June City Detail/WorldMap UI overhaul.
- Remaining risks: no explicit recruitment UI, MVP-level national food-pool payment, no population/fatigue effects, and final UX validation still pending.

## 2026-05-31

### v0.69-3A Strategic Logic Checkpoint Documentation
- Started from baseline commit `0b6defa` / `v0.69-3 Troop Move Loyalty Efficiency Final Patch`.
- Performed documentation-only checkpoint work.
- Recorded `v0.69-1 Public Support MVP`, `v0.69-2 Seasonal Loyalty From Public Support MVP`, and `v0.69-3 Troop Move Loyalty Efficiency Final Patch` as complete.
- Recorded the strategic logic chain as the current v0.69 foundation: `publicSupport` -> seasonal `loyalty` -> troop movement loss.
- Recorded that current verification is headless/API-centered and that actual F6 mouse-based UX verification is deferred to the June city information panel and WorldMap UX/UI redesign phase.
- Recorded that the current City Detail UI is a minimal temporary display/connection surface rather than final UX.
- Recorded that `v0.69-4 Recruitment/Conscription Foundation MVP` remains the next implementation candidate, with UX verification to be coordinated with later UI overhaul work.
- Did not modify `scripts/worldmap_test.gd` or any code. Did not change publicSupport, loyalty, troop movement, recruitment, revolt, tech tree, trade, diplomacy, espionage, UI, or save/load behavior.
- Verification planned: confirm `scripts/worldmap_test.gd` unchanged, run `git diff --check`, and confirm CURRENT_STATE/NEXT_TASKS/HANDOFF_TO_CODEX contain the follow-up validation principle.

## 2026-05-31

### v0.69-3 Troop Move Loyalty Efficiency Final Patch
- Started from baseline commit `79036b0` / `v0.69-2 Seasonal Loyalty From Public Support MVP`.
- Implemented source-city loyalty based movement loss in `scripts/worldmap_test.gd`.
- Replaced C1 movement total preservation with the final formula: `arrived_amount = floor(commanded_amount * from_loyalty / 100.0)`, with the remainder recorded as `lost_amount`.
- Kept `_can_move_troops` validation on commanded amount, including minimum garrison.
- Extended `last_troop_move_result` with commanded/departed/arrived/lost/from_loyalty and post-move city troop values while keeping `amount` for compatibility.
- Kept C2 approval on the existing `_apply_troop_rebalance_suggestion()` -> `_move_troops()` path so C2 applies the same loss formula.
- Added minimal preview/status text showing commanded, arrived, and lost troops.
- Did not use `publicSupport` directly for movement loss; movement uses current city loyalty after seasonal publicSupport effects.
- Did not change Phase A/B/P0-1/P0-2 formulas, publicSupport formula, seasonal loyalty formula, recruitment/conscription, revolt, tech trees, trade deepening, diplomacy/espionage, battle scene code, battle/invasion/defense logic, save/load core, or large UI.
- Verification passed: `rg` checks, `_can_move_troops` commanded validation review, C2 delegation review, `battle_web_import_test.gd` unchanged review, publicSupport/seasonal/P0-2 formula diff review, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless QA runner.
- Godot `--headless --check-only` timed out after 134 seconds and is recorded as inconclusive.
- QA runner confirmed loyalty `100/90/50/20` cases, minimum-garrison commanded check, save/load post-move troop preservation, player attack BattleContext destination troop read, C2 approval loss formula, and `last_troop_move_result` recording.
- Remaining risks: movement UI remains minimal and manual F6 visual QA is still recommended for final display feel.

## 2026-05-31

### v0.69-2 Seasonal Loyalty From Public Support MVP
- Started from baseline commit `76b9015` / `v0.69-1 Public Support MVP`.
- Implemented publicSupport-to-loyalty seasonal bridge only in `scripts/worldmap_test.gd`.
- Added `_is_seasonal_loyalty_turn(turn_number)` with MVP rule `turn_number % 10 == 0`; current domestic apply runs before `_advance_world_turn_mvp()`, so turn 10 is the first seasonal apply point.
- Added `_calculate_loyalty_delta_from_public_support(public_support)` with thresholds `90+ +2`, `80+ +1`, `60..79 -1`, `40..59 -2`, and `0..39 -3`.
- Added `_apply_seasonal_loyalty_from_public_support(turn_number, supply_states)` and `last_seasonal_loyalty_result`.
- Wired domestic turn order as publicSupport drift, existing P0-2 city loyalty drift, then seasonal loyalty from publicSupport.
- Added minimal City Detail and turn summary display for seasonal loyalty.
- Did not modify publicSupport calculation formula. Did not remove or replace P0-2 city loyalty drift.
- Payroll/gold surplus and equipment surplus loyalty factors are deferred.
- Verification passed: `rg`, publicSupport formula diff review, P0-2 loyalty drift diff review, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless QA runner.
- QA runner confirmed non-seasonal skip, seasonal apply, publicSupport `95 -> +2`, `85 -> +1`, `70 -> -1`, `50 -> -2`, `30 -> -3`, loyalty clamp `0..100`, publicSupport unchanged by seasonal loyalty, save/load city loyalty preservation, and `last_seasonal_loyalty_result` recording.
- Godot `--headless --check-only` timed out after 129 seconds and is recorded as inconclusive.
- Remaining risks: seasonal bridge currently uses publicSupport only; payroll/equipment/supply seasonal modifiers and final UI polish are later work.

## 2026-05-31

### v0.69-1 Public Support MVP
- Started from baseline commit `fe73fc4` / `v0.69-0 EASTWAR Strategic Simulation Foundation Roadmap Lock`.
- Implemented city-level `publicSupport` only in `scripts/worldmap_test.gd`.
- Added `publicSupport` default/clamp constants, getter/setter helpers, delta calculation, turn application, and `last_public_support_result`.
- Wired public support drift into `_apply_domestic_turn_mvp` after income/upkeep/trade resource application and before existing national/city loyalty drift.
- Preserved existing `loyalty` / `cityLoyalty` fields and P0-2 city loyalty drift. Public support does not affect loyalty in this version.
- Added minimal City Detail internal/supply tab display and one-line domestic summary integration for public support changes.
- Added minimal city runtime save/load field preservation for `publicSupport` without rewriting save/load core structure.
- Verification passed: `rg` for new symbols, scoped diff review confirming loyalty functions were not removed/replaced, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless QA runner.
- QA runner confirmed default `publicSupport = 70`, stable low-tax public support rise, high-tax drop, isolated `supply_delta = -2`, `+3/-7` delta clamps, save/load preservation, loyalty unchanged by public support drift, and `last_public_support_result` recording.
- Godot `--headless --check-only` timed out after 130 seconds and is recorded as inconclusive.
- Remaining risks: MVP food/commerce surplus uses current national stock plus recent result fallbacks; final UX/UI and publicSupport-to-loyalty seasonal linkage are deferred.

## 2026-05-31

### v0.69-0 EASTWAR Strategic Simulation Foundation Roadmap Lock
- Started from clean tracked status at baseline commit `aec588b`.
- Performed documentation-only roadmap lock for v0.69.
- Compared `_incoming_confirmed_designs/` confirmed design inputs against the official `agent/CONFIRMED_*` documents.
- Replaced the five official `agent/` design documents with the incoming confirmed versions and kept `_incoming_confirmed_designs/` out of the commit scope.
- Added confirmed design lock documents under `agent/`:
  - `CONFIRMED_LOYALTY_PUBLICSUPPORT_DESIGN.md`
  - `CONFIRMED_NATIONAL_TECHTREE_DESIGN.md`
  - `CONFIRMED_CITY_TECHTREE_DESIGN.md`
  - `CONFIRMED_TRADE_SYSTEM_DESIGN.md`
  - `CONFIRMED_DIPLOMACY_ESPIONAGE_REVOLT.md`
- Updated `CURRENT_STATE.md` to close v0.68b as the web MVP port plus first-pass domestic logic baseline and to start v0.69 as the EASTWAR Strategic Simulation Foundation stage.
- Updated `NEXT_TASKS.md` with the ordered v0.69 roadmap from Public Support MVP through Diplomacy/Espionage Foundation MVP, followed by `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Updated `HANDOFF_TO_CODEX.md` to emphasize that v0.69 is a strategic simulation foundation transition, not a UI-first feature pass.
- Updated `CHANGELOG.md` with the documentation-only scope and explicit non-implementation boundaries.
- Did not modify `scripts/worldmap_test.gd`.
- Did not implement public support, loyalty formula changes, troop movement formula changes, tech tree, trade deepening, diplomacy, espionage, revolt, UI, battle/invasion/defense, or save/load changes.

## 2026-05-30

### v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions
- Started from baseline commit `1505053` / `v0.68b-13-6C1 Troop Move Manual MVP`.
- `HANDOFF_P2C2_REBALANCE_SUGGESTIONS.md` was not present at repo root or under `agent/`, so implementation followed the explicit task text.
- Confirmed `ROLE_TARGET_GARRISON_RATIO` was not present and added it minimally for the requested target-garrison formula.
- Implemented C2 only. Did not implement UI, suggestion cards, automatic movement, direct troop writes, resource changes, C1 validation formula changes, Phase A/B/P0-1/P0-2 calculation changes, battle/invasion/defense changes, or save/load core rewrites.
- Added `_calculate_troop_rebalance_suggestions()`: reads `_calculate_all_city_supply_states()`, uses `owned_city_ids`, builds hub/rear surplus suppliers and frontline shortage demands, processes shortage/surplus in descending order, calls `_can_move_troops` for each candidate, stores `last_troop_rebalance_suggestions`, and returns the array.
- Added `_apply_troop_rebalance_suggestion()`: extracts `from`, `to`, and `amount`, then calls `_move_troops`; C2 does not call `_set_city_runtime_troops`.
- Ran `rg` for new constant/functions: present.
- Confirmed only `scripts/worldmap_test.gd` changed before docs; `battle_web_import_test.gd` was not modified.
- Ran `git diff --check`: passed.
- Ran Godot headless project load: passed.
- Ran Godot headless `WorldMap_Test.tscn` load: passed.
- Ran Godot `--headless --check-only`: timed out after 124 seconds, inconclusive.
- Ran a temporary headless QA runner, then deleted it before commit. It confirmed start state with Hanseong only produced 0 suggestions; crafted Hanseong/Gyeongju scenario produced 1 valid suggestion; all suggestions passed `_can_move_troops`; suggestion calculation preserved world troop total and city troop values; `_apply_troop_rebalance_suggestion` moved through `_move_troops` with total preservation; save/load preserved moved city troops through the existing C1 path.
- Remaining risks: no C2 UI yet; target-garrison ratios are first-pass constants; manual F6 QA remains for any future approval UI.

### v0.68b-13-6C1 Troop Move Manual MVP
- Started from baseline commit `3fdb56d` / `v0.68b-13-5A City Info Display Spacing Micro Polish`.
- `HANDOFF_P2C_TROOP_REBALANCE.md` was not present at repo root or under `agent/`, so implementation followed the explicit task text.
- Precheck confirmed existing movement-lock state: `_enemy_turn_mvp_pending`, `_player_state.pending_invasion_event`, `_player_state.pending_battle_context`, `Engine` battle context meta, and `turn_phase`. No new flag was added.
- Implemented C1 only. Did not implement C2 chancellor suggestions, automatic redistribution, resource movement, P0-1/P0-2/Phase A/Phase B calculation changes, battle scene edits, battle troop formula changes, battle/invasion/defense rewrites, or save/load core rewrites.
- Added `TROOP_MOVE_MIN_GARRISON_RATIO := 0.6`.
- Added `_is_supply_path_between` using BFS through player-owned marker neighbors only, with visited tracking.
- Added `_get_city_min_garrison` using `_get_city_security_required_troops(city) * 0.6` rounded with current style.
- Added `_is_peacetime_for_troop_move`, `_can_move_troops`, `_move_troops`, and a world city troop total audit helper.
- `_move_troops` validates first, then calls `_set_city_runtime_troops` for source `-amount` and destination `+amount`, and records `last_troop_move_result`.
- Added minimal manual UI in the existing City Detail internal/supply tab and existing action button. The selected city is source, the first connected player-owned city in existing `owned_city_ids` is target, and amount is capped at 100 and source surplus over minimum garrison.
- Ran `rg` for new constants/helpers: present.
- Confirmed only `scripts/worldmap_test.gd` changed before docs; `battle_web_import_test.gd` was not modified.
- Ran `git diff --check`: passed.
- Ran Godot headless project load: passed.
- Ran Godot headless `WorldMap_Test.tscn` load: passed.
- Ran Godot `--headless --check-only`: timed out after 124 seconds, inconclusive.
- Ran a temporary headless QA runner, then deleted it before commit. It confirmed peacetime gate success, min-garrison value `300`, min-garrison rejection, no-supply-path rejection, movement success, world troop total preservation `5770 -> 5770`, source/destination troop deltas, `last_troop_move_result`, save/load troop preservation, player attack BattleContext reading moved Hanseong troops, and pending-invasion movement rejection.
- Remaining risks: UI is minimal and does not expose explicit target/amount controls; manual F6 visual QA is still recommended.

### v0.68b-13-5A City Info Display Spacing Micro Polish
- Started from baseline commit `b564292` / `v0.68b-13-5 City Info Trade Supply Loyalty Display Polish`.
- Kept the code change to 13-5 display helper output only. `_apply_*`, `_calculate_*`, `_is_*`, `_move_*`, P0-1, P0-2, Phase A, Phase B, result structure, resources, loyalty, upkeep, troops, Phase C, battle/invasion/defense, and save/load were not modified.
- Added section titles to the display helper output: supply state, supply adjustment, trade, trade routes, and loyalty drift.
- Split long route and loyalty drift text into multiple lines.
- Normalized empty states to recent-result messages such as recent trade/supply/loyalty results not being present.
- Replaced the prior route display loop cap with `routes.slice(0, 3)` over the existing route order and an `외 N개` suffix. The route source array is not mutated.
- Verified scoped diff with `git diff -U0`; changes are limited to formatting helper output.
- Verified route limit is a simple slice and the temporary QA confirmed the original routes array was unchanged after formatting.
- Ran `git diff --check`: passed.
- Ran Godot headless project load: passed.
- Ran Godot headless `WorldMap_Test.tscn` load: passed.
- Ran Godot `--headless --check-only`: timed out after 124 seconds, inconclusive.
- Ran a temporary headless display-spacing QA runner, then deleted it before commit. It confirmed section titles/line breaks, route `외 1개`, first-three route display, original route array immutability, and no resource/national loyalty/Hanseong troop changes from display calls.
- Remaining risks: manual F6 visual QA still needed for actual font/spacing; Phase C remains unimplemented.

### v0.68b-13-5 City Info Trade Supply Loyalty Display Polish
- Started from baseline commit `aaef579` / `v0.68b-13-4A Supply Connectivity F6 QA Closeout`.
- Kept the work to `scripts/worldmap_test.gd` display polish plus agent docs; no P0-1/P0-2/Phase A/Phase B calculations, result schemas, resources, loyalty, upkeep, Phase C troop redistribution, battle/invasion/defense logic, or save/load core were changed.
- Updated the existing `CITY_DETAIL_TAB_INTERNAL_TRADE` case to display current selected-city supply role/state/income multiplier/loyalty/security fields from existing supply result data.
- Updated the internal tab to show latest selected-city loyalty drift factors from existing `last_city_loyalty_drift_result` entries and `reasons[]`.
- Updated the existing `CITY_DETAIL_TAB_EXTERNAL_TRADE` case to display latest trade route count, applied totals with player totals fallback, gold/rice/barley/seafood/salt, and selected-city route snippets from `last_inter_faction_trade_result`.
- Updated domestic turn summary formatting so the status/log text includes existing trade, supply, and city loyalty drift summaries.
- Added formatting helpers only; helpers build strings/arrays and do not apply resources or mutate gameplay values. The selected-city supply display uses the existing `_calculate_all_city_supply_states()` source and therefore can refresh the runtime `last_supply_state_result` summary.
- Verified helper/tab presence with `rg`.
- Ran `git diff --check`: passed.
- Ran Godot headless project load: passed.
- Ran Godot headless `WorldMap_Test.tscn` load: passed.
- Ran Godot `--headless --check-only`: timed out after 125 seconds, inconclusive.
- Ran a temporary headless display QA runner, then deleted it before commit. It confirmed turn result text includes trade/supply/loyalty summaries, external tab matches latest trade result, internal tab matches supply/drift result, and tab display did not change resources or national loyalty after the turn.
- Remaining risks: manual visual F6 mouse QA still recommended; long multi-line label text may need later spacing polish.

### v0.68b-13-4A Supply Connectivity F6 QA Closeout
- Started from clean tracked status at baseline commit `99b8a21` / `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP`.
- Performed QA/documentation only; no new feature implementation, Phase C troop redistribution, resource movement, supply UI, trade formula changes, combat/invasion/defense rewrites, or save/load core rewrites were made.
- Ran a temporary headless QA runner against `WorldMap_Test.tscn`, then deleted the runner before committing.
- Start-state checks passed: Hanseong resolves as hub, Hanseong role is `hub`, `supplied_frontline_count = 0`, `isolated_count = 0`.
- Turn progression check passed: `_on_ally_turn_end_pressed()` followed by `_finish_enemy_turn_mvp()` advanced the world turn, recorded domestic apply result, and preserved Phase A trade result.
- Connected scenario checks passed after making Pyeongyang, Gyeongju, and Sabi player-owned: each classified as supplied frontline with a path to Hanseong, and `supplied_frontline_count = 3`.
- Bonus checks passed: supplied frontline income `x1.10`, loyalty supply delta `+1`, security supply delta `+1`, calculated gold income above no-supply baseline, hero upkeep discount lower than no-supply baseline, and `SUPPLY_UPKEEP_DISCOUNT_FLOOR = 0.85`.
- Isolated scenario checks passed after making Kyoto player-owned while disconnected from Hanseong: Kyoto classified as isolated frontline with income `x0.80`, loyalty `-2`, security `-1`, lower calculated gold than baseline, and no isolated upkeep surcharge.
- Save/load checks passed with caveat: a stale `last_supply_state_result` inside saved `_player_state` can load back, but `_calculate_all_city_supply_states()` recalculates from loaded ownership/neighbors and overwrites it.
- Regression checks passed lightly: Phase A trade income after load, city loyalty/runtime city state payload, `faction_relations` payload, player attack BattleContext build, and enemy invasion/defense event creation.
- Verification commands passed: Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and the temporary QA runner.
- Remaining risks: headless/API-driven QA rather than full mouse-driven visual F6 pass; no supply-state UI; loaded runtime summary can be stale before recalculation; Phase C troop redistribution remains future work.

### v0.68b-13-4 Phase B Supply Connectivity Bonus MVP
- Started from HEAD `8cad028`; tracked changes were clean and `worldmap_test_FULL.gd` was kept out of the commit as the untracked source integration file.
- `HANDOFF_P2B_SUPPLY_REDESIGN.md` was not present in the repo, so implementation followed the explicit task scope.
- Added the requested Phase B supply constants and helper functions in `scripts/worldmap_test.gd`.
- Implemented hub selection by largest player-owned city population; starting state should resolve Hanseong as hub.
- Implemented BFS supply connectivity through player-owned city marker neighbors only, with visited tracking.
- Implemented city supply roles and state summary: hub/rear/frontline, supplied, isolated, income multiplier, loyalty delta, and security delta.
- Wired one supply-state calculation into `_apply_domestic_turn_mvp`, then shared it with income, hero upkeep, and city loyalty drift.
- Applied supplied-frontline income `x1.10`, isolated-frontline income `x0.80`, supplied-frontline loyalty/security bonuses, isolated-frontline loyalty/security penalties, and supplied-frontline upkeep discount with `0.85` floor.
- Did not add Phase C troop redistribution, resource movement, city-level warehouse state, Phase A trade changes, battle/invasion/defense changes, or save/load core rewrites.
- `last_supply_state_result` stores `hub_id`, `supplied_frontline_count`, `isolated_count`, and `city_states`; this is recalculated each turn rather than treated as save/load source of truth.
- Verified with `rg`, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and Godot `--check-only`.
- F6 manual QA was not executed in this environment; multi-city connected/isolation scenarios and save/load recalculation remain manual.

### v0.68b-13-3 Final Merged WorldMap Domestic Trade Loyalty QA
- Confirmed starting HEAD `fdd41fc` and clean tracked status before applying the uploaded file; `worldmap_test_FULL.gd` was present as an untracked source file.
- Copied `worldmap_test_FULL.gd` over `scripts/worldmap_test.gd` without creating a backup file.
- Verified core strings: P0-1 governor income, P0-2 city loyalty drift, Phase A trade income, `TRADE_GLOBAL_DAMPENER`, and `TRADE_FOOD_FACTOR`.
- Confirmed `_apply_domestic_turn_mvp` order: income, upkeep, Phase A trade, national loyalty, city loyalty drift.
- Reviewed `git diff`; only trade tuning C changed versus previous HEAD, with no battle/invasion/defense diff.
- Static trade check: Hanseong has Pyeongyang, Gyeongju, and Sabi neighbors; tuned gold income calculates to +40.
- `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load passed.
- Godot `--check-only` timed out locally.
- F6 manual QA was not executed in this environment; trade display, city loyalty save/load, `faction_relations` save/load, and light battle/invasion/defense entry checks remain manual.
- Phase B supply connectivity was not implemented. Next task recorded as `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP`.

### v0.68b-13-2 City Loyalty Drift Patch Acceptance QA
- Checked requested P0-2 gates in `scripts/worldmap_test.gd`; city loyalty drift constants/functions/wiring were missing.
- `PATCH_NOTE_P0-2_city_loyalty.md` was not present in the repo, so the implementation followed the explicit task formula and the referenced web `domestic_effects.js` functions.
- Added the three requested constants and four requested functions only.
- Wired city loyalty drift at the end of `_apply_domestic_turn_mvp`, after national loyalty update.
- P0-1 `city_loyalty_loss_multiplier` is now used for city tax loyalty drift; `recruitable_troops_bonus` remains unconnected.
- City loyalty now persists through existing city runtime save/load payloads via `loyalty` and `cityLoyalty`; save/load core structure was not rewritten.
- Phase A trade was not implemented in this task. Since this branch already had Phase A, the docs record future merge order caution for P0-1 income, Phase A trade, upkeep, national loyalty, and P0-2 city drift.
- Verified with `rg`, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally.

### v0.68b-13-2A Inter-Faction Trade Income MVP
- Implemented Phase A only for inter-faction trade income.
- Could not find `HANDOFF_P2_TRADE_SUPPLY_DESIGN.md` or `CODEX_PROMPTS.md` in the repo; proceeded from the explicit task scope and the requested web source functions in `SamWar_web/js/core/inter_faction_trade.js`.
- Added relation constants, lazy `faction_relations`, sorted `a|b` relation keys, neutral fallback for missing relation keys, and same-faction route exclusion.
- Added trade route calculation from player-owned city marker neighbors to adjacent other-faction cities.
- Added route result storage under `last_inter_faction_trade_result` with `turn`, `route_count`, `player_totals`, `routes`, and `applied_player_totals`.
- Integrated trade income after domestic income/upkeep resource application through `_apply_resource_delta`, preserving existing warehouse clamping and full `_player_state` save/load behavior.
- Did not implement Phase B internal supply network, Phase C troop redistribution, diplomacy manipulation UI, trade settings UI, battle/invasion/defense changes, or P0-2 loyalty/recruitment consumers.
- Verified with `rg`, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally.

### v0.68b-13-1 Governor Income Effect Patch Acceptance QA
- Checked `scripts/worldmap_test.gd` for the requested acceptance gates. The governor income constants/functions/signature/pass-through were missing before this pass.
- Added the missing P0-1 governor income patch points only in the domestic income area.
- Verified patch strings with `rg`.
- Ran Godot `--headless --path . --quit`: passed.
- Ran Godot `--headless --path . WorldMap_Test.tscn --quit`: passed.
- Tried Godot `--headless --path . --check-only`: timed out locally before completion, so no pass/fail result was recorded for that mode.
- Documented that `city_loyalty_loss_multiplier` and `recruitable_troops_bonus` are expected to have no current Godot consumers.
- Manual F6 save/load QA remains recommended; Hanseong default governor candidates may not produce a visible rounded turn-income delta despite effects being calculated.

## 2026-05-29

### v0.68b-12b-31 Player/Defense Troop Accounting Parity Fix
- Implemented player attack defender garrison pre-decrement before battle handoff.
- Added defense BattleContext troop allocation metadata for enemy attacker and player defender sides.
- Added pre-decrement for both enemy attacker source city and player defender source city during enemy invasion defense battle preparation.
- Extended battle result payload outcome calculation to non-player-attack defense contexts.
- Replaced defense result troop application with allocated outcome parity and troop woundedQueue rules.
- Added nearest player-owned neighbor lookup for defense-defeat wounded return; if no retreat city exists, player wounded are logged as lost for this MVP.
- Verified with `git diff --check`, Godot project headless load, WorldMap scene headless load, and Battle scene headless load. F6 manual QA remains required.

### v0.68b-12b-30 Invasion Attack Web Parity Gap Audit
- Performed a docs-only comparison of SamWar_web and Godot invasion/attack parity.
- Inspected web `world_rules.js`, `app_state.js`, `battle_state.js`, `save_load.js`, and relevant UI modules for attack choice, defense choice, deployment, troop allocation, result return, woundedQueue, and save/load behavior.
- Inspected Godot `worldmap_test.gd`, `worldmap_city_info_panel.gd`, `player_attack_deployment_panel.gd`, `battle_web_import_test.gd`, and `battle_unit_state.gd`.
- Added `agent/INVASION_ATTACK_WEB_PARITY_GAP_AUDIT.md` with P0/P1/P2/Deferred classification and a final summary table.
- P0 next work: defender garrison pre-decrement for player attack, defense allocation/result parity, defense woundedQueue/retreat-city return, and woundedQueue F6/save-load QA.

### v0.68b-12b-29A Web-Parity Troop Allocation + Wounded Queue Import
- Added player attack deployment troop decrement: selected sortie troops are removed from the source city before battle scene handoff.
- Preserved allocation metadata through `player_attack` BattleContext, including per-hero allocation, total allocated troops, source city id, and source before/after garrison values.
- Added battle unit allocated troop fields and result-payload survivor accounting based on allocated troops and remaining HP ratio, without scaling HP or combat stats by troop count.
- Applied web-parity troop outcomes: victory survivor count uses HP ratio with 30% wounded losses; defeat has 0 survivors with 50% wounded allocated troops.
- Added city troop `woundedQueue` persistence and recovery on WorldMap turn advance; this is separate from hero wounded status and battle penalties.
- Updated player attack victory/defeat result application so survivors/wounded go to the occupied target on victory, while defeat queues wounded troops back at the source.
- Deferred defender pre-battle garrison decrement parity, troop-count combat scaling, in-battle supply effects, troop types, siege formulas, loot, and prisoner soldier handling.

### v0.68b-12b-26 Player City Attack MVP Import
- Ported the web player city attack MVP into the Godot WorldMap flow.
- Added selected-city attack request signaling and WorldMap-side enable/disable state for the `공격` button.
- Implemented direct-neighbor player attack eligibility and source-city resolution using current origin city first, then the first player-owned target neighbor.
- Built `source: player_attack`, `type: attack` BattleContext payloads with existing city roster/support helpers, preserving captured/dead exclusion and wounded eligibility.
- Updated battle context side mapping so player attack attacker heroes enter ally slots and target defenders enter enemy slots; enemy-invasion defense mapping remains unchanged.
- Added player attack result application: victory changes target owner to `player`, defeat keeps target owner, and casualty/result-card/hero-state/save-load flows are reused.
- Deferred deployment selection, troop allocation, sea/route-type attacks, 2-hop attacks, marching/supply, siege UI, AI counterattack, and enemy hero recruitment.

### v0.68b-12b-26 Wounded Hero Recovery Turn MVP
- Added `wounded_turns_remaining` to runtime hero state and save/load normalization.
- Wounded placeholder state now starts at 3 WorldMap strategy turns; captured/dead/normal state clears the counter.
- Recovery ticks only when `_advance_world_turn_mvp()` advances the WorldMap turn, not during battle rounds.
- Recovery logs `[HERO_RECOVERY_TICK]` and `[HERO_RECOVERED]`; recovered heroes return to `normal` and lose the wounded battle penalty.
- Updated WorldMap city info and battle formation badge text to show `[부상 N턴]`.
- Deferred treatment UI/items, ability-based recovery duration, prisoner release/recruit/execute, and death handling.

### v0.68b-12b-25 Wounded Hero Battle Penalty MVP
- Added battle-side wounded helper lookup through the existing hero registry/context hero registry state fields.
- Kept wounded heroes battle-eligible and preserved `[부상]` display behavior.
- Applied MVP penalties: attack damage `75%`, wounded defender incoming damage `120%`, and unique-skill numeric effects `70%`.
- Unique skill penalty covers damage, splash, attack buff, and defense buff values without changing toast presentation.
- Captured/dead battle exclusion remains unchanged; no new save/load fields were added.
- Deferred wound recovery, treatment UI, prisoner systems, death handling, and refined stat-based wound balance.

### v0.68b-12b-24 Captured Hero Battle Exclusion / Holding Placeholder MVP
- Added a WorldMap battle-exclusion helper for captured/dead hero runtime state.
- BattleContext roster creation now skips captured/dead heroes for main attacker/defender rosters and same-faction/2-hop support picks.
- Captured heroes remain in city rosters and WorldMap city information; wounded heroes are intentionally still eligible for battle.
- Added battle-scene context slot protection so captured/dead context heroes are deactivated before unit assignment.
- Existing `worldmap_hero_state` save/load status persistence is reused; no new save payload fields were added.
- Deferred prisoner holding/movement, recruitment/execution/release, wound recovery, wounded penalties, and actual death handling.

### v0.68b-12b-23 Hero State Visual Marker / Roster Status Badge MVP
- Added display helpers that mark hero state as `[부상]`, `[포로]`, or `[사망]` with priority `dead` -> `captured` -> `wounded`; normal heroes show no marker.
- Merged `_hero_runtime_states` into the WorldMap hero data passed to the selected-city info panel.
- Updated the right city panel stationed hero and governor name formatting to append state badges through existing labels.
- Preserved `status`, `wounded`, `captured`, and `dead` in WorldMap BattleContext hero registry entries and showed badges in battle formation/roster panel names.
- Updated the post-battle result-card hero summary to use the same marker style.
- Kept captured heroes in city/battle rosters; captured hero exclusion, prisoner movement, wound recovery, death, and state penalties remain deferred.

### v0.68b-12b-22 Hero Wound/Capture Placeholder MVP
- Confirmed `_hero_runtime_states` and `worldmap_hero_state` already carry `status`, `wounded`, `captured`, and `dead` fields from v20.
- Added deterministic losing-side placeholder logic after invasion result summary creation.
- MVP rule: first eligible losing-side hero becomes `wounded`, second eligible losing-side hero becomes `captured`; dead is always left false.
- Skips missing heroes and heroes already captured/dead; captured heroes remain in their city rosters for this placeholder phase.
- Added `[HERO_STATE_APPLY]`, `[HERO_STATE_SKIP]`, and `[HERO_STATE_RESULT]` logs.
- Added a one-line hero status summary to the post-battle result card.
- Deferred actual prisoner movement, prison/recruit/execution UI, wound recovery turns, death, stat-based rolls, and detailed prisoner panels.

### v0.68b-12b-21 Post-Battle Result Panel Polish MVP
- Confirmed the previous WorldMap battle result return displayed only a compact status string through the save-management status label.
- Added a reusable `PostBattleResultCard` to the left World HUD at runtime, without adding scene files or changing battle UI.
- Built display-only invasion result summaries for defender win, attacker win/city fall, retreat, and unknown result paths.
- Summary lines show ownership change/retention, defender city troop change, attacker source-city troop change, and occupation troops when present.
- Result summary state is cleared on load/reset/new invasion and is not included in save data.
- Deferred prisoner/wound/death display, resource loot display, detailed battle statistics, and full result report UI.

### v0.68b-12b-20 Invasion Casualty Formula + Hero State MVP
- Replaced minimal invasion troop-rate result apply with a bounded casualty helper for defender victory and attacker victory.
- Defender victory keeps ownership, reduces defender city troops modestly, and reduces attacker source-city troops heavily.
- Attacker victory transfers ownership, derives occupation troops from attacker survivor/fallback values, and reduces the attacker source city by the occupation commitment.
- Added nonnegative troop clamp guards and `[INVASION_CASUALTY]` / `[INVASION_TROOP_APPLY]` logs for result QA.
- Extended hero runtime state save/load with `status`, `wounded`, `captured`, and `dead`; old save payloads default to `normal` / `false`.
- Deferred actual wound/capture/death judgment, hero removal/holding movement, resource looting, detailed power-based casualty, AI strategy recalculation, and multi-invasion queues.

### v0.68b-12b-19 WorldMap Battle Result Save/Load Persistence MVP
- Inspected existing WorldMap save/load flow in `scripts/worldmap_test.gd`: it saved `player_state`, intentionally cleared pending invasion fields, and previously discarded `_city_runtime_states` on load.
- Added city runtime persistence for battle-result owner/nation/owner_faction_id, troops, and stationed hero ids without mutating `CITY_HUD_DATA`.
- Added hero runtime persistence for `current_city_id` / `city_id` / `location_city_id` without mutating `HERO_DATA`.
- Load now applies seed + runtime override merge, skips missing city/hero ids without crashing, refreshes marker owner visuals, and rebinds the city info/world HUD data.
- Pending invasion event/context remains cleared on save/load to prevent resolved invasion UI from appearing again.
- Verification target: after F6 invasion result, save/load should preserve city ownership, troops, stationed rosters, hero current city overrides, and clean pending invasion state.
- Deferred: wounds, capture, death, resource looting, precise casualty calculation, strategic AI recalculation, and multi-invasion queues.

### v0.68b-12b-18c Reinforcement Toast + Auto Battle Final Stop Hotfix
- Confirmed the false support-toast path: reinforcement arrival logic keyed off round/deploy attempt state and queued the toast even when no active support unit actually deployed.
- Changed reinforcement deployment helpers to return success/failure and made toast display require a nonempty arriving hero-id list.
- Empty/inactive WorldMap context support slots are excluded from generic and city reinforcement arrival checks; support toast is skipped with `[REINFORCEMENT_TOAST_SKIP]` when no unit arrives.
- Strengthened battle-result final guards across deferred enemy callbacks, move/attack finish callbacks, confused ally consume, round start, auto action start, reinforcement checks, and non-result toast queue/playback.
- Result-finalized state now clears or blocks non-result toasts while preserving result toast and worldmap return behavior.
- Verification passed: `git diff --check`, no split portrait fields in `scripts`, Godot project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load with sample fallback intact.
- Remaining QA: live F6 should confirm no turn-3 support toast in no-support invasion, sample support toast still appears when real support arrives, auto battle stops immediately at result, and worldmap return remains stable.

### v0.68b-12b-18b Roster Panel Source + Auto Battle End Hotfix
- Confirmed the formation-panel leak source: after 18a deactivated empty WorldMap context slots, the side-panel refresh still read capacity-slot `unit_state` first, which could resolve sample `TEST_BATTLE_ROSTER` heroes.
- Changed WorldMap context panel refresh so assigned context `hero_id` is authoritative; empty/inactive context slots are hidden and never sample-filled.
- Added bounded roster-panel source logs for shown/hidden panel slots while preserving direct sample battle fallback.
- Confirmed auto battle extra-turn source: result toast/final state existed, but full-auto and deferred ally-turn/auto tick paths were not stopped at every entry point.
- Added battle-end guard handling for result toast, phase setting, return-to-ally-turn, auto-enable, and auto tick paths; full auto stops at finalized victory/defeat.
- Verification passed: `git diff --check`, no split portrait fields in `scripts`, Godot project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load with sample fallback intact.
- Remaining QA: live F6 백제/사비 invasion should verify no sample panel heroes in empty support cells, auto battle stops immediately after result, and worldmap return remains stable.

### v0.68b-12b-18a Reinforcement Fallback Leak + Toast Facing Layer Hotfix
- Fixed the confirmed battle-side leak: `enemy_invasion` / WorldMap context slots no longer use `TEST_BATTLE_ROSTER` fallback when requested hero ids are missing.
- Missing invasion support now deactivates the empty slot instead of force-filling sample heroes; direct sample battle fallback remains preserved outside invasion context.
- Added context slot decision logs for sample fallback allow/skip/fallback cases.
- Raised `RoundToastRoot` above facing indicators and temporarily hides facing indicators during battle toast and unique-skill toast playback, restoring them after playback ends.
- Remaining QA: F6 사비/백제 invasion should confirm no `liu_bei` / `zhuge_liang` support leak, empty support slots stay hidden, toast arrows stay hidden during toasts, arrows restore afterward, and auto battle/worldmap return remain stable.

### v0.68b-12b-18 Invasion Reinforcement Source Rule MVP
- Root cause: WorldMap BattleContext used city stationed rosters, but the battle scene filled any missing context slots from `TEST_BATTLE_ROSTER`, so distant sample heroes such as 성도 유비/제갈량 could appear as support in unrelated invasions.
- Implemented invasion roster construction in `scripts/worldmap_test.gd`: attacker and defender main rosters start from each side's source city `stationed_hero_ids` / `hero_ids`.
- Added MVP reinforcement source filtering: same faction or explicit ally only, direct neighbors first and then 2-hop neighbors only. Missing reinforcements are not force-filled from distant cities.
- Added cross-side duplicate prevention through one `used_hero_ids` set while building attacker and defender rosters.
- Updated `scripts/battle_web_import_test.gd` so WorldMap context battles deactivate empty context slots instead of falling back to sample heroes. Sample battle fallback remains intact for direct battle launches or fully empty/broken context sides.
- Added concise `[REINFORCE_RULE]`, `[REINFORCE_PICK]`, `[REINFORCE_SKIP]`, and `[REINFORCE_FALLBACK]` logs for QA.
- Static 평양 -> 한성 check: 평양 2-hop candidates are 한성/카라코룸/경주/사비/업성, not 성도; same-faction support candidates are empty, so 성도 유비/제갈량 are excluded.
- Save/Load, hero wounds/capture, hero movement, resource looting, city ownership result logic, and precise strategic AI remain deferred.

### v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix
- Confirmed the scale regression source: v0.68b-12b-17 scaled 512-source portraits to `128px`, while the previous battlefield portrait badge baseline was `128x128` portrait assets displayed at scene scale `0.32`, about `41px`.
- Changed the battlefield Sprite2D portrait badge target to `41px`, preserving the existing badge offsets and UI layout.
- Kept 512 `portrait_path` as the only source image and did not add split portrait fields or generate 128 images.
- Fixed skill-name resolution so generated `장수명 전법` names are fallback-only. Existing sample unique-skill registry names/cutin paths are reused for known heroes when context data only provides generated fallback values.
- Updated Yi Sunsin display to `학익진`; Eulji Mundeok keeps `살수대첩 매복`; confirmed v0.68b-12b-16b heroes remain on their explicit skill names.
- Preserved the existing unique-skill toast frame/animation path where dedicated assets exist; common `skill_unknown`/fallback icon is only for missing assets.
- Cutin presentation, save/load, capture/wounds/death, hero movement, and resource looting remain deferred.

### v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP
- Inspected WorldMap context battle roster registration, context hero/skill registry creation, sample roster fallback, battle portrait Sprite2D badges, formation guide TextureRect portraits, and unique-skill toast lookup.
- Changed battle hero lookup to prefer `worldmap_context_hero_registry` before sample `HERO_REGISTRY`, so actual WorldMap `portrait_path` data is not overwritten by sample portraits when hero ids overlap.
- Added ResourceLoader-safe portrait resolution for `portrait_path` / registry portrait fields with a named common unknown portrait fallback.
- Battle portrait Sprite2D slots now scale loaded 512-source portraits to the existing 128 target size; existing 128 folders and image files were not moved, deleted, or regenerated.
- Changed unique-skill lookup to prefer WorldMap context skill data and added `skill_desc` into the runtime skill entry for future UI use. Toast name text now uses the context `skill_name` path.
- Missing skill toast/cutin images now use a common skill fallback icon rather than a hero portrait. Full cutin presentation remains deferred.
- Save/load expansion, capture/wounds/death, hero movement, resource looting, and battle balance changes remain unimplemented.

### v0.68b-12b-16c Hero Portrait Import Metadata Audit
- Ran the requested import metadata audit: `git status --short`, `git ls-files "*.import"`, `Get-ChildItem assets\heroes\portraits -Recurse -Filter "*.import"`, and `.gitignore` import-rule checks.
- Policy result: the repo tracks many Godot `.png.import` files, including all listed `assets/heroes/portraits/**` portrait imports, while `.gitignore` ignores the generated `.import/` cache directory.
- Current `assets/heroes/portraits` had no untracked or ignored `.import` files, so the audit did not delete files and did not add new portrait import metadata.
- Kept the task bounded to metadata/docs only: no battle logic, `HERO_DATA`, image movement/deletion, or 128-folder changes.
- Next task is `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`.

### v0.68b-12b-16b Hero Placement Data Patch
- Confirmed target hero IDs against current code: `liu_bei`, `kwon_yul`, `cheok_jun_gyeong`, `lu_bu`, and `xiahou_dun`.
- Added missing WorldMap `HERO_DATA` entries for 유비, 권율, and 하후돈; strengthened existing 척준경 and 여포 data from contract/fallback state into full battle-ready hero records.
- Applied confirmed unique skill names and effects: 유비 `인의의 깃발` / `command_aura`, 권율 `행주대첩 항전` / `guard_stance`, 척준경 `검왕돌파` / `power_strike`, 여포 `무쌍난무` / `charge_bonus`, 하후돈 `발검돌파` / `charge_bonus`.
- Updated city rosters: 성도 includes 유비, 한성 includes 권율 and no longer includes 척준경, 평양 includes 척준경, 낙양 includes 여포, and 업성 includes 하후돈.
- Kept the 512 portrait contract as one `portrait_path` and separate `cutin_path`; no split 128/512 portrait fields were introduced.
- Verification passed: `git diff --check`, target hero/skill/path strings, city roster strings, no split portrait fields in `scripts`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Kept image files untouched; save/load expansion, capture/wounds, hero movement systems, detailed balance, and cutin presentation remain deferred.

### v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP
- Confirmed the existing battle sample data structure in `scripts/battle_web_import_test.gd`: `HERO_REGISTRY`, `TEST_BATTLE_ROSTER`, and `UNIQUE_SKILL_REGISTRY`.
- Confirmed actual WorldMap hero placement comes from `scripts/worldmap_test.gd` `HERO_DATA` plus city `stationed_hero_ids` / `hero_ids`.
- Added WorldMap hero battle contract helpers that build mutable BattleContext copies instead of mutating seed dictionaries.
- BattleContext now carries `attacker_heroes` and `defender_heroes` arrays with combat fields, 512-source `portrait_path`, separate `cutin_path`, and required unique-skill fields for every included actual hero.
- Skill fields are generated from existing `unique_skill_id` plus role-based temporary contracts; balance remains intentionally rough.
- Battle scene now accepts context hero/skill data through runtime registries and still falls back to `TEST_BATTLE_ROSTER` when a hero is missing or unsupported.
- Portrait contract decision: one `portrait_path` points at 512-source assets; 128 battle slots should scale down from that same source. No `portrait_128_path` / `portrait_512_path` split was introduced.
- Cutin contract decision: cutin/effect images use separate `cutin_path`; files are not required yet and are not bulk-added.
- Existing 128 folders were not deleted; actual image binding is deferred to `v0.68b-12b-17` or `16a`.
- Verification passed: `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, root `Battle_Fullscreen_Test.tscn` headless load, no new portrait split fields, and direct sample battle fallback remained intact.

### v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix
- Fixed the F6 manual invasion battle return crash: `_set_city_runtime_troops()` attempted to assign into a read-only city Dictionary.
- Root cause: `CITY_HUD_DATA` is seed/static city data and may be read-only; the previous MVP wrote `troops`, `owner`, and `nation` directly into that dictionary.
- Added `_city_runtime_states` as the mutable runtime city-state map for invasion-result ownership/troop changes.
- `_set_city_runtime_troops()` and `_set_city_runtime_owner()` now create a `duplicate(true)` city-state copy, mutate only that runtime copy, and store it by `city_id`.
- `_get_city_hud_entry()` now prefers runtime city state when available, while `CityInfoPanel` receives a merged seed + runtime data map so the right panel reflects changed owner/troops.
- Renamed unused `_apply_attacker_win_invasion_result()` parameter to `_attacker_city_name`.
- Verification passed: `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: live F6 manual invasion victory/defeat return should still be clicked through to confirm the reported read-only crash is gone in the exact UI path.

### v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP
- Implemented bounded WorldMap invasion battle result application in `scripts/worldmap_test.gd`.
- Root cause addressed: the previous return path received the battle result payload but intentionally stopped before ownership/troop apply, so invasion outcomes did not alter city runtime state.
- `scripts/battle_web_import_test.gd` now returns owner ids, initial troop counts, and deployed survivor troop totals in the WorldMap result payload.
- Result interpretation accepts `result`, `battle_result`, `outcome`, `state`, `winner`, and `is_player_win` variants; unknown values are handled without ownership change.
- Defense victory preserves target ownership, clears pending invasion/context, refreshes UI, and applies minimal nonnegative defender/attacker troop reductions where data exists.
- Defense defeat changes the defender city to the attacker owner using existing `owner` / `nation` city fields plus marker `owner_faction_id`, updates `_player_state.owned_city_ids`, applies safe occupation troops, and refreshes marker/right panel/world HUD.
- Retreat/cancel/aborted/unknown results clear the pending invasion safely, do not change ownership, and show safe Korean status messages.
- Deferred by design: hero capture, hero city movement, resource losses, detailed casualty formulas, save/load persistence expansion for resolved city ownership, AI strategy recalculation, and multi-invasion queues.
- Verification passed: patch strings, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load. Headless output did not show integer division or owner-shadow warnings.
- Remaining risk: full F6 manual click-through still needs 김작 confirmation for victory/defeat/retreat visual state because headless load cannot complete the interactive battle-return flow.

### v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup
- Fixed the remaining Godot warning: local variable `owner` shadowed the base `Node.owner` property.
- Root cause: `scripts/battle_web_import_test.gd` used local `owner` inside `_apply_worldmap_context_side_roster()` for WorldMap context owner metadata.
- Renamed the local to `city_owner_id` and updated only its local metadata references.
- Behavior preservation: capacity slot `"source_owner"` metadata and returned summary `"owner"` key still receive the same context value; no ownership/apply logic changed.
- Verification passed: repo-local GDScript search found no remaining `var owner` locals, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- No battle result apply, city ownership logic, troop/resource mutation, invasion flow, battle scene transition, turn/domestic logic, or save/load behavior changed.
- Remaining risk: interactive F6 should be rechecked because headless load cannot fully prove the live console warning stream across every interaction.

### v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup
- Fixed the F6 yellow `Integer division. Decimal part will be discarded.` warning source in `scripts/worldmap_test.gd`.
- Root cause: calendar helpers used ambiguous integer `/` expressions for `zero_based_turn / WORLD_CALENDAR_YEAR_TURNS` and `(zero_based_turn % WORLD_CALENDAR_YEAR_TURNS) / WORLD_CALENDAR_SEASON_TURNS`.
- Replaced those calendar divisions with explicit `floori(float(... ) / float(...))` integer intent.
- Preserved calendar behavior: start year remains `154`, seasons remain `봄 / 여름 / 가을 / 겨울`, season length remains `10` turns, and year length remains `40` turns.
- Inspected recently touched warning candidates: `scripts/worldmap_test.gd`, `scripts/battle_web_import_test.gd`, `scripts/worldmap_city_info_panel.gd`, and `scripts/worldmap_hero_portrait_helper.gd`.
- Verification passed: patch strings, calendar constants, no remaining obvious ambiguous calendar divisions in touched files, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- No battle result ownership apply, troop/resource loss apply, city ownership change, invasion logic, BattleContext behavior, scene transition behavior, turn cycle behavior, domestic apply behavior, save/load behavior, panel redesign, or portrait binding behavior was changed.
- Remaining risk: interactive F6 should be rechecked because headless load cannot fully prove the live console warning stream across every interaction.

### v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard
- Fixed the F6 runtime error `_refresh_unified_panel_chrome: Invalid assignment of property or key 'visible' ... Nil`.
- Cause: unified panel chrome refresh assumed primary tab buttons and tab-row controls were always available before assigning `.visible`.
- Changed `scripts/worldmap_test.gd` only: added patch marker, guarded primary tab button creation, added null checks around unified panel chrome `.visible` / `.modulate` writes, and added a one-time warning helper for missing chrome nodes.
- `WorldMap_Test.tscn` was inspected but not modified for this hotfix.
- Verification passed: patch strings, guarded visible assignments, forbidden-scope search, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- Remaining risk: interactive F6 should be rechecked visually because headless load cannot reproduce every click/drag path.

### v0.68b-12b-14 WorldMap Battle Result Return MVP
- Confirmed current HEAD baseline `0217bd160b23981c06e9108c0fbaf3e41ed7f776` from `v0.68b-12b-13 Battle Roster Context Apply MVP`.
- Inspected required agent docs, WorldMap scripts/scene, battle controller/scene, and local web battle return references.
- Web references inspected: `C:\dev\SamWar_web\js\core\battle_state.js`, `js\core\battle_rules.js`, `js\core\world_rules.js`, `js\core\app_state.js`, `js\ui\world_map_ui.js`, `js\ui\world_hud_ui.js`, and `js\main.js`.
- Added battle-side runtime result payload creation with `samwar_worldmap_battle_result`, including source/type/mode/result/winner, attacker/defender city ids and names, and turn number.
- Added a runtime `월드맵으로 돌아가기` button that appears only for WorldMap-launched battles after victory/defeat and transitions to root `WorldMap_Test.tscn`.
- Added WorldMap result intake that consumes and clears metadata, shows defense success/failure status, clears pending invasion/context, hides the pending choice card, and refreshes panels.
- Direct battle scene launch remains preserved because no WorldMap context keeps the return button hidden and the demo battle path unchanged.
- Verification passed: patch strings, result metadata paths, forbidden implementation search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- No city ownership change, troop/resource loss apply, hero movement/capture, auto battle resolution change, combat balance change, defense deployment UI, or broad battle refactor was added.
- Historical note: this recommendation is superseded by completed `v0.68b-12b-15`; current follow-up is `v0.68b-12b-16 WorldMap Invasion Result Persistence / QA Follow-up`.

### v0.68b-12b-13 Battle Roster Context Apply MVP
- Confirmed current HEAD baseline after `v0.68b-12b-12` and inspected required agent docs, battle controller, WorldMap handoff references, and local web roster/battle source references.
- Web references inspected: `C:\dev\SamWar_web\data\battle_rosters.js`, `data\heroes.js`, `data\cities.js`, `js\core\battle_state.js`, `js\core\battle_rules.js`, `js\core\battle_ai.js`, `js\core\world_rules.js`, and `js\core\app_state.js`.
- Updated `scripts/battle_web_import_test.gd` to apply WorldMap defense context to the existing demo capacity-slot roster only when `samwar_worldmap_battle_context` metadata exists.
- Defender governor/stationed hero ids now map to ally slots, attacker governor/stationed hero ids map to enemy slots, and compatible web/Godot hero ids resolve through a compact local compatibility map.
- Direct `Battle_Fullscreen_Test.tscn` launch without context preserves the existing `TEST_BATTLE_ROSTER` demo setup.
- Missing/empty/unknown hero ids and missing governors fall back per slot to the demo roster; city troop scaling remains deferred.
- Verification passed: patch strings, context roster paths, fallback paths, forbidden implementation search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- No battle result return, WorldMap ownership apply, WorldMap troop/resource mutation, auto battle resolution, defense deployment UI, hero movement/capture, or broad battle refactor was added.
- Recommended next task: `v0.68b-12b-14 WorldMap Battle Result Return MVP`.

### v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP
- Inspected required agent docs, WorldMap scripts/scene, battle scenes, battle controller script, project settings, and BattleContext/battle engine contract docs.
- Selected `Battle_Fullscreen_Test.tscn` as the handoff target because it is the documented current stable 5v5 battle scene and uses `scripts/battle_web_import_test.gd`.
- Implemented runtime-only handoff through Godot `Engine` metadata key `samwar_worldmap_battle_context`; no save file, repo file, autoload, or persistent setting was added.
- Updated `scripts/worldmap_test.gd` so `수동 방어` and `자동 방어` prepare context, store a deep copy for handoff, and transition to `res://Battle_Fullscreen_Test.tscn`.
- Updated `scripts/battle_web_import_test.gd` to read and clear the handoff context, store it locally, and log attacker/defender city names plus manual/auto mode.
- Direct battle test launch remains supported: missing context falls back to the existing demo setup and logs `No WorldMap battle context; using test battle setup`.
- Verification passed: patch strings, battle scene path, handoff/intake paths, forbidden implementation search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and direct `Battle_Fullscreen_Test.tscn` headless load.
- No battle result return, ownership change, troop/resource loss, hero movement/capture, auto battle resolution, defense deployment UI, enemy AI, pathfinding, diplomacy/cooldown, or broad battle refactor was added.
- Historical note: this recommendation was superseded by `v0.68b-12b-13 Battle Roster Context Apply MVP`.

### v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge
- Inspected required agent docs, `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `scripts/worldmap_hero_portrait_helper.gd`, root `WorldMap_Test.tscn`, and local read-only web battle/invasion references.
- Web references inspected: `C:\dev\SamWar_web\js\core\battle_state.js`, `js\core\battle_rules.js`, `js\core\world_rules.js`, `js\core\app_state.js`, `js\ui\world_map_ui.js`, `js\ui\world_hud_ui.js`, `js\main.js`, `data\battle_rosters.js`, `data\cities.js`, and `data\heroes.js`.
- Updated `scripts/worldmap_test.gd` so `수동 방어` and `자동 방어` validate the current pending invasion event and create runtime `_player_state.pending_battle_context`.
- BattleContext data now includes `type: defense`, `source: enemy_invasion`, `mode`, attacker/defender ids and names, turn numbers, owner ids, troops, stationed hero ids, and governor ids from existing marker/HUD seed data.
- Save/load/reset policy is runtime-only: saves exclude both pending invasion event and pending battle context, while load/reset clear both and normalize back to the world/player turn path.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_hero_portrait_helper.gd.uid`, and agent docs.
- Verification passed: patch strings, context/validation/manual/auto paths, forbidden implementation search, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- No battle scene transition, defense deployment UI, auto battle resolution, city ownership change, troop/resource loss, hero movement, governor appointment execution, enemy AI expansion, pathfinding, diplomacy/cooldown, or result apply was added.
- Recommended next task: `v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`.

### v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP
- Inspected required agent docs, `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, root `WorldMap_Test.tscn`, and repo-local portrait/image asset listings.
- Asset folders inspected included `assets/web_battle/portraits`, `assets/web_battle/portraits_battlefield`, worldmap assets, and battle UI/unit asset listings.
- Added `scripts/worldmap_hero_portrait_helper.gd` as the shared WorldMap portrait lookup/apply path.
- Portrait lookup reads existing `HERO_DATA` portrait fields such as `portrait_image`, maps legacy `assets/portraits/...` seed paths to `assets/web_battle/portraits/...`, and includes compact compatibility paths for known available assets.
- Updated the chancellor card and right taesu/governor card to show resolved portrait textures and hide the `?`; missing or failed texture loads clear the texture and keep the `?` fallback.
- Kept stationed hero list text-only in this MVP to preserve the compact right-panel layout.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `scripts/worldmap_hero_portrait_helper.gd`, and agent docs.
- Verification passed: patch/helper strings present, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- No BattleContext, battle scene transition, defense deployment, auto defense resolution, ownership change, troop loss, hero movement, governor/chancellor appointment execution, enemy AI expansion, or asset file edit/move was added.
- Recommended next task: `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`.

### v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup
- Inspected required agent docs, `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and right panel script `scripts/worldmap_city_info_panel.gd`.
- Inspected local read-only web references: `C:\dev\SamWar_web\js\ui\world_map_ui.js`, `js\ui\world_hud_ui.js`, `js\ui\ui_render.js`, `js\ui\selected_city_ui.js`, `js\core\app_state.js`, `js\core\world_rules.js`, `data\cities.js`, and `data\heroes.js`.
- Updated the right selected-city panel to show city name, owner/nation/region, population, gold, food, resource ratings, troops, defense, public support/order, commerce, agriculture, governor/taesu, and stationed hero names from existing seed data.
- Hid raw city id display and replaced old runtime placeholder/debug-style text with clean Korean fallbacks: `선택 도시 없음`, `태수 없음`, `주둔 장수 없음`, `알 수 없는 장수`, and `정보 없음`.
- Added display-only pending invasion city clarity: defender city shows `침공 대상 도시 · 방어전 준비 중`; attacker city shows `침공 출발 도시`.
- Modified only `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, root `WorldMap_Test.tscn`, and agent docs; no repo-outside web files were changed.
- Verification passed: patch strings, right-panel strings, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- No BattleContext, battle scene transition, defense deployment UI, auto defense resolution, city ownership change, troop loss, hero movement, governor appointment execution, enemy AI, pathfinding, or route logic was added.
- Recommended next task: `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP`.

### v0.68b-12b-10.5 Session Handoff Docs Update Before Stop
- Confirmed local HEAD is `6d36163 v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP`.
- Updated docs only: current state, next tasks, handoff, changelog, session log, and enemy invasion audit.
- Recorded current stable baseline as `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP` at commit `6d3616339e5d555127c5f4eb5eb91160d362aa2e`.
- Documented today's completed flow: `12b-1` seed import, `12b-2` left controls, `12b-3` chancellor policy/warehouse, `12b-3a` warehouse cleanup, `12b-4` turn/save, `12b-5` turn loop, `12b-6` domestic apply, `12b-7` QA, `12b-8` invasion audit, `12b-9` invasion event, and `12b-10` choice UI.
- Documented implemented systems: web seed import, left panel controls, turn/calendar, save/load/reset, domestic apply, and enemy invasion event/choice MVP.
- Documented deferred systems: right city info cleanup, hero portrait binding, BattleContext, battle handoff, defense deployment, auto defense, battle result return, ownership/troop/resource apply, enemy AI, internal supply/troop/trade systems, soldier upkeep/salt consumption, and governor execution.
- Recorded handoff notes: root `WorldMap_Test.tscn` is active, `scenes/WorldMap_Test.tscn` may not exist, runtime save path is `user://worldmap_left_panel_state.json`, `agent/LOCAL_ENV.md` and `.godot/` are ignored, pending invasion events are not persisted and load/reset clears them, and BattleContext is intentionally deferred.
- Updated next recommended task order to `12b-10a` right city info panel cleanup, `12b-10b` hero portrait binding, `12b-11` BattleContext bridge, `12b-12` battle scene handoff, `12b-13` battle result return, and `12b-14` ownership/troop apply.
- Verification: docs-only diff, `git diff --check`, `git status --short --ignored`, and no code/scene file changes.

### v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP
- Inspected the required agent docs, `agent/ENEMY_INVASION_AUDIT.md`, `scripts/worldmap_test.gd`, and the active root `WorldMap_Test.tscn`.
- Inspected local read-only web references for pending defense choice rendering and routing: `C:\dev\SamWar_web\js\ui\ui_render.js`, `js\ui\world_map_ui.js`, `js\core\app_state.js`, `js\core\world_rules.js`, `js\core\battle_state.js`, `js\core\battle_rules.js`, `js\ui\world_hud_ui.js`, and `js\main.js`.
- Added a runtime `PendingInvasionChoiceCard` to the existing left world status panel and kept the root scene file unchanged.
- The card is hidden with no pending event and visible when `_player_state.pending_invasion_event` exists; it shows attacker city, defender city, `적군 침공 발생`, `방어전을 준비하십시오.`, `수동 방어`, and `자동 방어`.
- Added placeholder-only `수동 방어` / `자동 방어` button handlers that update status text and keep the pending event intact.
- Disabled/blocked `아군 턴 종료` while a pending invasion event exists so invasion events cannot stack.
- Save/load/reset policy remains unchanged: saves exclude pending event state, and load/reset clear it so the card hides.
- Verification passed: `git diff --check`, forbidden implementation search, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- No BattleContext generation, battle scene transition, defense deployment UI, auto battle resolution, city ownership change, troop loss, hero movement, enemy AI expansion, pathfinding, or battle result resolution was added.
- Recommended next task: `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`.

### v0.68b-12b-9 WorldMap Enemy Invasion Event MVP
- Inspected the required agent docs, `agent/ENEMY_INVASION_AUDIT.md`, `scripts/worldmap_test.gd`, and the active root `WorldMap_Test.tscn`.
- Rechecked local read-only web references: `C:\dev\SamWar_web\js\core\world_rules.js`, `js\core\app_state.js`, and `js\core\save_load.js`.
- Added `ENEMY_INVASION_CHANCE = 0.45` and a patch marker for `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`.
- Integrated `_roll_enemy_invasion_event_mvp()` into the existing enemy-turn placeholder path, using enemy-owned scene city markers and neighboring player-owned markers as the web-parity candidate rule.
- Added `_player_state.pending_invasion_event` plus helpers for candidate generation, ownership lookup, event creation/clear, and invasion status formatting.
- The visible left-panel status now reports `적군 침공 발생: {attacker} → {defender} · 방어전 준비 필요`, and the defender city is selected for visibility.
- Save serialization excludes pending invasion state, load/reset clear it, and load normalizes enemy-phase saves back to player turn; runtime saves continue to use `user://worldmap_left_panel_state.json`.
- No BattleContext generation, battle scene transition, city ownership change, troop loss, hero movement, enemy AI, pathfinding, diplomacy/cooldown rule, or battle resolution was added.
- Verification passed: `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- Recommended next task: `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP`.

### v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit
- Inspected the required agent docs plus context-only Godot files `scripts/worldmap_test.gd` and root `WorldMap_Test.tscn`; no gameplay code or scene file was modified.
- Inspected local read-only web enemy-turn/invasion references: `C:\dev\SamWar_web\js\core\app_state.js`, `world_rules.js`, `world_calendar.js`, `save_load.js`, `battle_state.js`, `battle_rules.js`, `battle_ai.js`, `js\ui\world_hud_ui.js`, `world_map_ui.js`, `ui_render.js`, `main.js`, and `constants.js`.
- Created `agent/ENEMY_INVASION_AUDIT.md` with source files, web call flow, enemy turn entry, action selection, eligibility, target selection, force/roster selection, BattleContext handoff, ownership/result handling, UI feedback, save/load behavior, Godot gaps, and recommended implementation sequence.
- Confirmed the web enemy invasion roll happens in `app_state.endWorldTurn()` after player-side turn systems, with `ENEMY_INVASION_CHANCE = 0.45` and candidates from enemy-owned cities adjacent through `neighbors` to player-owned cities.
- Confirmed successful web invasion creates a defense `pendingBattleChoice` and a minimal defense `battleContext`, while city ownership changes are deferred until defense battle retreat/return.
- Confirmed web save/load clears pending invasion/battle state and normalizes to player-turn world mode.
- Updated `CURRENT_STATE`, `NEXT_TASKS`, `HANDOFF_TO_CODEX`, `CHANGELOG`, and this session log with audit results and the next task sequence.
- Recommended next task: `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`.

### v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check
- Inspected the required agent docs, `scripts/worldmap_test.gd`, and the active root `WorldMap_Test.tscn`; the scene file was not modified.
- Updated `scripts/worldmap_test.gd` with the patch marker `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`.
- Added `_player_state.last_domestic_apply_turn` and a same-turn guard in `_apply_domestic_turn_mvp()` so a stale or duplicate callback cannot apply domestic resource/loyalty changes twice in the same turn.
- Updated save metadata to `v0.68b-12b-7`; the existing `_player_state` serialization continues to preserve resources, loyalty, tax, chancellor id/policy, phase, turn/calendar, pending state, and last applied turn.
- Verified the QA scenarios by static/headless checks: one-cycle apply path, preview-only tax/policy/chancellor handlers, warehouse/loyalty/status refresh, save/load/reset restoration, resource/loyalty bounds, and hidden internal warehouse/debug lines.
- No enemy invasion, enemy AI, target selection, hero movement, city ownership change, governor execution, new domestic system, `BattleContext`, battle transition, route/pathfinding change, or broad simulation was added.
- Recommended next task: `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit`.

### v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP
- Inspected `scripts/worldmap_test.gd` and the active root `WorldMap_Test.tscn`; the scene file was not modified.
- Inspected local read-only web domestic references: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\core\world_calendar.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\world_map_ui.js`.
- Updated `scripts/worldmap_test.gd` with the patch marker `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`.
- Added `_apply_domestic_turn_mvp()` and compact local helpers for web-parity owned-city seasonal income, population/commerce tax gold, chancellor policy income multipliers, active chancellor national modifiers, player hero upkeep, tax loyalty delta, warehouse capacity clamp, and result summary formatting.
- Domestic apply now runs exactly once when the enemy-turn placeholder finishes and the turn loop returns to player phase; `_domestic_turn_apply_pending` prevents duplicate timer callbacks or load/reset paths from applying resources twice.
- Tax slider changes and chancellor policy selection remain preview-only until full turn completion; UI refresh, save, load, and reset do not apply domestic values.
- Save metadata now records `v0.68b-12b-6`, and the existing `_player_state` serialization preserves updated resource stock, national loyalty, tax, chancellor id/policy, phase, turn number, and calendar labels.
- Verification passed: patch strings, domestic apply/helper paths, preview-only handlers, forbidden implementation search review, `git diff --check`, Godot project headless load, and `WorldMap_Test.tscn` headless load.
- No enemy invasion, enemy AI, target selection, hero movement, city ownership change, governor appointment execution, soldier upkeep application, salt consumption, internal supply/troop rebalance, `BattleContext`, battle transition, route/pathfinding change, or repo-outside web edit was added.
- Recommended next task: `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`.

## 2026-05-28

### v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP
- Inspected `scripts/worldmap_test.gd` and the active root `WorldMap_Test.tscn`; the scene file was not modified.
- Inspected local read-only web turn-cycle references: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\ui\world_hud_ui.js`, `js\ui\world_map_ui.js`, `js\main.js`, `js\core\world_calendar.js`, and `js\constants.js`.
- Updated `scripts/worldmap_test.gd` with the patch marker `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`.
- Added a Timer-backed enemy-turn placeholder so `아군 턴 종료` changes to `적군 턴`, shows `적군 턴 진행 중...`, then returns to `아군 턴`.
- Added `_finish_enemy_turn_mvp()` and `_advance_world_turn_mvp()` so each completed enemy placeholder increments `turn_number` exactly once.
- Calendar labels now follow the web MVP calendar rule: start year `154`, `10` turns per season, `40` turns per year, and seasons `봄/여름/가을/겨울`.
- Save/load/reset now cancel pending enemy timers as needed and preserve phase/turn/calendar state through `_player_state`; enemy-phase loads resume the placeholder return path.
- Verification passed: patch strings, turn-cycle helper paths, save metadata, forbidden implementation search, `git diff --check`, Godot project headless load, and `WorldMap_Test.tscn` headless load.
- No enemy invasion, target selection, hero movement, city ownership change, domestic/resource turn application, `BattleContext`, battle transition, route/pathfinding change, or broad AI simulation was added.
- Recommended next task: `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`.

### v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP
- Inspected `scripts/worldmap_test.gd` and the active root `WorldMap_Test.tscn` path; no `scenes/WorldMap_Test.tscn` path was used for this task.
- Inspected local read-only web parity references: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\ui\world_hud_ui.js`, `js\ui\world_map_ui.js`, and `js\main.js`.
- Updated `scripts/worldmap_test.gd` with the patch marker `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP`.
- Hid remaining visible internal/debug bottom lines under the national warehouse card and added a runtime `저장 관리` title/status area around the existing save button row.
- Replaced the old `야군 편집` button behavior/text with `아군 턴 종료`.
- `아군 턴 종료` now updates `_player_state.turn_phase` from `player` to `enemy`, normalizes the visible phase label to `적군 턴`, refreshes the left panel, and enters `_run_enemy_turn_mvp()`.
- `_run_enemy_turn_mvp()` is a hook only for future enemy invasion logic and does not implement invasion, enemy AI, ownership changes, hero movement, `BattleContext`, battle transition, resource ticks, or turn-cycle return.
- Added `저장` / `불러오기` / `초기화` behavior using `user://worldmap_left_panel_state.json`; reset restores the startup seed baseline without deleting repo files or using repo files as runtime save storage.
- Verification passed: patch strings, `아군 턴 종료`, `user://` save path, turn-end/save/reset helpers, `git diff --check`, Godot project headless load, and `WorldMap_Test.tscn` headless load.
- Recommended next task: `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`.

### v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup
- Inspected `scripts/worldmap_test.gd` and confirmed the requested `scenes/WorldMap_Test.tscn` path does not exist; the active scene remains root `WorldMap_Test.tscn`.
- Updated `scripts/worldmap_test.gd` with the patch marker `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup`.
- Replaced the visible plain multiline `국가 창고` text output with a runtime `WarehouseCard` `PanelContainer` using the existing dark HUD card style.
- The card shows only the 9 resource rows: `쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, `소금`, and `금전`.
- Each row reads `_player_state.resource_stock`, uses `WAREHOUSE_CAPACITY`, and displays current/max plus the existing status label calculation.
- Hid `영웅 유지비`, `병사 유지비 preview`, `보존 소금`, `유지비 정상`, and other internal maintenance preview lines from the visible warehouse card while leaving helper data available internally.
- Verified patch strings, warehouse card/helper paths, data-bound row logic, hidden `SupplyLabel` output, `git diff --check`, Godot project headless load, and `WorldMap_Test.tscn` headless load.
- No gameplay systems were added: no movement, appointment execution, actual upkeep/resource production, resource mutation, turn simulation, `BattleContext`, battle transition, route/pathfinding, or broader HUD redesign.
- Recommended next task: `v0.68b-12b-3b WorldMap Chancellor Policy Effect Web Parity`.

### v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP
- Inspected `scripts/worldmap_test.gd` and the root `WorldMap_Test.tscn` left panel node structure. The requested `scenes/WorldMap_Test.tscn` path does not exist in this repo; the active scene is `WorldMap_Test.tscn`.
- Inspected local read-only web references for parity: `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\resource_ui.js`.
- Updated `WorldMap_Test.tscn` with a `ChancellorPolicyOption` dropdown in the existing chancellor card.
- Updated `scripts/worldmap_test.gd` with the patch marker `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP`.
- Chancellor policy selection now uses the five web policy options and stores the selected value in `_player_state.chancellor_policy_id`.
- Policy effect text and preview lines now come from structured local metadata aligned with web policy effect constants; selecting a policy refreshes visible effect copy, resource multiplier summary, hero upkeep preview, soldier upkeep preview, and salt preservation preview.
- Retired the duplicate visible `보유 자원: ...` line and consolidated resource display into the `국가 창고` section, which reads `_player_state.resource_stock` for current amount, capacity, and status rows.
- Verified patch strings, policy dropdown/helpers, warehouse helpers, duplicate visible resource assignment removal, forbidden implementation search, Godot project headless load, `WorldMap_Test.tscn` headless load, and `git diff --check`.
- No gameplay systems were added: no movement, appointment execution beyond UI state, actual policy effect application, resource mutation, loyalty mutation, full turn simulation, `BattleContext`, battle transition, route/pathfinding, castle icon, or web repo changes.
- Recommended next task: `v0.68b-12b-4 WorldMap City Detail Governor / Stationed Hero Web Parity MVP`.

### v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP
- Inspected `scripts/worldmap_test.gd` and the root `WorldMap_Test.tscn` left panel node structure. The requested `scenes/WorldMap_Test.tscn` path does not exist in this repo; the active scene is `WorldMap_Test.tscn`.
- Inspected local read-only web references for parity: `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, and `js\ui\world_hud_ui.js`.
- Updated `WorldMap_Test.tscn` with a left-panel tax `HSlider` and renamed the chancellor option control to `ChancellorAssignmentOption`.
- Updated `scripts/worldmap_test.gd` with the patch marker `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP`.
- National loyalty now displays seed-backed value/status/progress, while the tax slider updates `_player_state.tax_level`, visible tax label, web-like tax preview, and status text without applying turn income or loyalty changes.
- Chancellor assignment now shows `미임명` first and populates candidates from the selected city's stationed heroes in `CITY_HUD_DATA`, not from a global hardcoded list.
- Selecting a chancellor updates only `_player_state.chancellor_id` for left-panel UI state and refreshes the chancellor card/effect preview using imported `HERO_DATA.chancellor_profile`.
- Portrait fallback now shows a stable `?` placeholder when no portrait texture is available, without blocking assignment display.
- Verified patch strings and seed blocks, Hanseong stationed hero candidates, dropdown `미임명`, portrait fallback, forbidden implementation search, Godot project headless load, `WorldMap_Test.tscn` headless load, and `git diff --check`.
- No gameplay systems were added: no turn simulation, resource mutation, loyalty application, policy effects, movement, appointment execution, `BattleContext`, battle transition, route/pathfinding, castle icon, or web repo changes.
- Recommended next task: `v0.68b-12b-3 WorldMap City Detail Hero/Governor Binding QA`.

### v0.68b-12b-2 WorldMap Left Panel Seed Binding QA
- Inspected `scripts/worldmap_test.gd` and the root `WorldMap_Test.tscn` left panel node structure. The requested `scenes/WorldMap_Test.tscn` path does not exist in this repo; the active scene is `WorldMap_Test.tscn`.
- Updated only `scripts/worldmap_test.gd` runtime display binding plus agent docs.
- Added the patch marker `v0.68b-12b-2 WorldMap Left Panel Seed Binding QA`.
- City marker selection now updates `_player_state.selected_city_id` and refreshes `LeftWorldStatusPanel`.
- Left panel now reads imported `_player_state`, `CITY_HUD_DATA`, and `HERO_DATA` seeds for selected/origin city, selected city owner/region/governor/stationed heroes, owned city list, owned hero list, resource stock, and no-chancellor fallback.
- Added safe display helpers for unknown city ids, unknown hero ids, empty governor, empty chancellor, empty stationed heroes, empty owned heroes, and resource stock labels.
- Verified patch strings and seed blocks, searched for forbidden implementation additions, loaded the Godot project headlessly, loaded `WorldMap_Test.tscn` headlessly, and ran `git diff --check`.
- No gameplay systems were added: no movement, appointments, policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding, scene layout, castle icon, or web repo changes.
- Recommended next task: `v0.68b-12b-3 WorldMap City Detail Hero Binding QA`.

### v0.68b-12b-1 WorldMap Hero City Seed Data Import
- Used local read-only web data sources from `C:\dev\SamWar_web`: `data/heroes.js`, `data/cities.js`, and `data/battle_rosters.js`.
- Also checked constants/app-state references for faction IDs, resource keys, initial resource stock, selected city baseline, and web `chancellorHeroId: null` default.
- Updated only seed data in `scripts/worldmap_test.gd`: `HERO_DATA`, `CITY_HUD_DATA`, and `_player_state`.
- `HERO_DATA` now keeps existing Godot display/stat compatibility fields and adds web seed fields for `id`, `hero_id`, `name`, faction/side/nation, command rank, web role, troops/max troops/max hp, attack/defense/ranges, unique skill id, portrait paths, and chancellor profile.
- `CITY_HUD_DATA` now keeps existing panel strings and adds web city fields for identity, owner/nation/region/type, population, gold/food/troops, public order, commerce, agriculture, defense, `hero_ids`, resource seeds, domestic seeds, and yield seeds.
- `cityDefenderRosters` remained the source for stationed hero lists, and `cities.js` `governorHeroId` remained the source for `governor_id`.
- `_player_state` now records player faction, ruler/current selected city, origin city, owned city/hero seed lists, resource stock, and an empty `chancellor_id` for web parity with no initial chancellor.
- Verified the patch strings and seed blocks, searched for forbidden implementation additions, loaded the Godot project headlessly, loaded `WorldMap_Test.tscn` headlessly, and ran `git diff --check`.
- No gameplay systems were added: no movement, appointments, policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding, scene layout, castle icon, or web repo changes.
- Recommended next task: `v0.68b-12b-2 WorldMap Hero/City Seed Binding QA`.

### v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat
- Completed a docs-only handoff update for the next Codex chat. No code, scenes, assets, or actual seed import changes were made.
- Updated `CURRENT_STATE`, `NEXT_TASKS`, `HANDOFF_TO_CODEX`, `CHANGELOG`, `SESSION_LOG`, and `WORLDMAP_RULES`.
- Recorded the current worldmap HUD sequence: `v0.68b-8 WorldMap Web HUD Visual Parity MVP`, `v0.68b-9 WorldMap HUD Data Binding MVP`, `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`, `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`, `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`, `v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch`, `v0.68b-12b-pre Codex Auto Work Header Rule Documentation`, `v0.68b-12b Left World HUD Web Content Parity`, and `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit`.
- Recorded that `v0.68b-12b-pre` made `[SamWar_BattleLab 자동 작업 권한 헤더]` mandatory before future SamWar_BattleLab task names/goals.
- Recorded that `v0.68b-12b Left World HUD Web Content Parity` was a web-source attempt/investigation flow before implementation: inspect actual web left HUD/resource/trade sources and keep Godot behavior display-only.
- Recorded the web data audit summary: `heroes.js` is an array with `id`, `name`, `factionId`, `side`, `role`, `stats`, `portraitImage`, `battlefieldPortraitImage`, and `chancellorProfile`; `cities.js` includes `id`, `name`, `region`, `ownerFactionId`, `neighbors`, `routeTypes`, `governorHeroId`, `cityLoyalty`, `resources`, `military`, `domestic`, and `yields`; `battle_rosters.js` `cityDefenderRosters` is the city stationed-hero source.
- Recorded domestic selection parity: web initial `chancellorHeroId` is `null`; chancellor candidates are active heroes where `hero.side === playerFactionId`; governor candidates are selected-city stationed heroes where `hero.side === playerFactionId` and `hero.locationCityId === selectedCity.id`.
- Recorded Godot seed state: `scripts/worldmap_test.gd` currently owns display-only `HERO_DATA`, `CITY_HUD_DATA`, `CHANCELLOR_POLICY_DATA`, `GOVERNOR_POLICY_DATA`, and `_player_state`; `_player_state.chancellor_id` currently points to `"jeong_do_jeon"` and should be explicitly decided in the next task.
- Set the next task to `v0.68b-12b-1 WorldMap Hero City Seed Data Import`, with the handoff note that this is data baseline alignment from web hero/city/battle_rosters data into Godot seed data, not real feature execution.

### v0.68b-12b Left World HUD Web Content Parity
- Confirmed the required web files live outside the Godot repo at `C:\dev\SamWar_web`; used them as read-only references and did not modify them.
- Analyzed `renderWorldHud`, `renderChancellorCard`, `renderChancellorPolicyControl`, `resource_ui.js` resource/trade sections, `constants.js` policy/resource labels, `app_state.js` world/resource/chancellor state, `world_rules.js` domestic seed defaults, `css/main.css`, `index.html`, and `data/heroes.js`.
- Updated the Godot left main HUD runtime data/copy to follow the web left HUD order: turn/calendar/owner, `국가충성도`, `세금 수준`, chancellor card, chancellor policy, `보유 자원`, `국가 창고`, `내부 보급망`, `내부 병력 재배치`, `대외 무역`, income/policy/tax summary, wild-army edit, and save/load/reset.
- Added web chancellor type labels and 정도전's web `chancellorProfile` display data so the chancellor card shows `주: 정치형 4` and `보조: 행정형 3` instead of only generic stats.
- Kept the portrait as a first-character fallback because portrait asset naming/application remains a later task.
- Kept all buttons and policy selection display-only; policy selection refreshes the description/hint but does not change resources, turn, tax, loyalty, or upkeep.
- Did not add save/load/reset, domestic execution, turn processing, resource mutation, `BattleContext`, battle transition, recruitment, hero transfer, army movement, pathfinding, AI, route mutation, or sea arrow changes.
- Castle icon visuals remain disabled; route lines and sea route arrow flow were preserved.
- 김작 F6 should confirm left HUD section order, turn/date/phase wording, chancellor card structure, policy list/description, resource/warehouse/supply/troop-rebalance/external-trade wording, button copy, reduced placeholder feel, panel bottom spacing, unified panel drag/collapse, Selected City retention, city-click refresh, route/sea arrow flow, castle icons hidden, and existing battle scene stability.

### v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch
- Rechecked the web worldmap sources requested for this UX pass, including `diplomacy_spy_ui.js`, `world_hud_ui.js`, `resource_ui.js`, `world_map_ui.js`, `ui_render.js`, `app_state.js`, `world_rules.js`, `constants.js`, `data/cities.js`, `data/heroes.js`, and `css/main.css`.
- Removed the expanded unified panel's duplicate Korean title; the top row now uses `도시 상세` and `외교·첩보` as the primary tab buttons beside `접기`.
- Changed the collapsed unified panel text to `도시상세 / 외교·첩보 열기`.
- Added collapsed-panel click/drag discrimination so click expands and drag moves the collapsed panel without moving other HUD panels.
- Replaced the diplomacy/spy placeholder-heavy copy with web-source terms: `외교 현황`, `외교 행동`, `첩보 가시성`, `첩보 행동`, `사절 교환`, `교섭 요청`, `교역 압박`, `정탐`, `유언비어`, and `내통 시도`.
- Added content-based height resizing for the unified panel to reduce excess empty space at the bottom while keeping the panel screen-clamped.
- Did not add actual diplomacy, spy, domestic execution, resource mutation, turn processing, save/load, `BattleContext`, battle transition, recruitment, hero transfer, army movement, pathfinding, AI, or route logic.
- Castle icon visuals remain disabled; route lines and sea route arrow flow were preserved.
- 김작 F6 should confirm collapsed text and drag, simplified primary tab header, secondary tab switching, web-like diplomacy/spy content, reduced empty panel height, independent unified/selected panel drag, city-click refresh, placeholder-only buttons, castle icons hidden, route/sea arrow continuity, and existing battle scene stability.

### v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP
- Consolidated the previously separate City Detail and Diplomacy/Spy HUD surfaces into the existing `CityDetailPanel` runtime surface.
- Added primary mode buttons for `도시 상세` and `외교·첩보` in the unified panel header.
- Reused the existing secondary tab row: city-detail mode shows `자원`, `자국무역`, and `타국무역`; diplomacy/spy mode shows `외교` and `첩보`.
- Hid the standalone `DiplomacySpyPanel` at runtime so it no longer occupies independent screen space.
- Implemented real collapse/expand behavior for the unified panel. Collapsed state keeps a compact `도시 상세 열기` header on-screen and reopens from the header/collapse button.
- Kept the v0.68b-11 independent drag behavior for the unified panel, `CityInfoPanel`, and `LeftWorldStatusPanel`; positions remain runtime-only and are not persisted.
- Did not add domestic execution, diplomacy/spy execution, resource mutation, turn processing, save/load, `BattleContext`, battle transition, recruitment, hero transfer, army movement, pathfinding, AI, or route logic.
- Castle icon visuals remain disabled; route lines and sea route arrow flow were preserved.
- 김작 F6 should confirm the unified panel displays City Detail and Diplomacy/Spy in one panel, primary and secondary tabs switch visible content, collapse/expand reduces map coverage, unified and selected-city panels drag independently, no panel drag pans the camera, city clicks still update unified and Selected City content, all controls remain placeholder-only, castle icons stay hidden, route/sea arrow flow remains normal, and existing battle scenes remain stable.

### v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP
- Checked the web `world_map_ui.js` HUD drag flow and confirmed the web version moves a grouped city HUD stack through one drag handle with localStorage persistence.
- Godot now intentionally uses independent runtime panel drag instead: `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` can each move by left-dragging their title/header labels.
- The old top `SamWar Web` banner and `도시 HUD 위치 이동 · Godot MVP fixed` dragbar are hidden at runtime.
- Dragging brings only the active panel to the front, clamps panel position so it cannot disappear completely, and does not save positions between runs.
- Buttons, tabs, and policy `OptionButton` controls remain outside the drag handles and keep their display-only/placeholder behavior.
- Did not add save/load, domestic execution, resource mutation, turn processing, `BattleContext`, battle transition, recruitment, hero transfer, army movement, pathfinding, AI, or route logic.
- Castle icon visuals remain disabled; route lines and sea route arrow flow were preserved.
- 김작 F6 should confirm the top banner/dragbar are gone, each HUD panel drags independently from header labels, other panels do not follow, controls do not start drags, panel dragging does not pan the camera, pan/zoom keeps HUD screen-fixed, city-click panel refresh still works, tabs/policies still work, castle icons remain hidden, route/sea arrow flow remains normal, and existing battle scenes remain stable.

### v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP
- Checked the actual `SamWar_web` source before implementation, including world HUD, selected city, resource/city detail, diplomacy/spy, governor, garrison, military, constants, app state, world rules, city data, hero data, battle rosters, CSS, and HTML.
- Ported the web City Detail structure into Godot at MVP scope: `자원`, `자국무역`, and `타국무역` tabs now switch display-only content and use web section labels.
- Changed Godot chancellor/governor policy data to match the web constants and kept policy selection as UI text state only.
- Updated local Godot city/hero HUD seed data toward the web city/governor/roster sources, including web battle roster stationed heroes and web city loyalty/resource/military summaries.
- Updated Selected City wording toward the web panel order: `주둔 무장`, `군대 상태`, `공격`, `무장 이동`, and recruit placeholder language.
- Did not add domestic execution, resource mutation, turn processing, save/load, `BattleContext`, battle transition, recruitment application, hero transfer, army movement, pathfinding, AI, or route logic.
- Castle icon visuals remain disabled; route lines and sea route arrow flow were preserved.
- 김작 F6 should confirm web-source parity of City Detail tabs/text/buttons, Selected City wording/order, chancellor/governor policy labels, city roster data, display-only tab/policy behavior, placeholder-only buttons, city-click dual panel refresh, fixed HUD behavior during pan/zoom, castle icon disabled state, route/sea arrow continuity, and existing battle scene stability.

### v0.68b-9 WorldMap HUD Data Binding MVP
- Checked the actual web data/HUD flow in `world_hud_ui.js`, `selected_city_ui.js`, `resource_ui.js`, `diplomacy_spy_ui.js`, `governor_ui.js`, `garrison_ui.js`, `world_map_ui.js`, `ui_render.js`, `constants.js`, `data/heroes.js`, and `data/cities.js`.
- Added local Godot HUD display data for player turn/status, chancellor, policies, heroes, selected-city governor, city loyalty/resources/military/trade, and stationed hero IDs.
- Bound the left World Turn panel to mock player state and added a chancellor portrait slot plus chancellor policy `OptionButton`; policy changes update local UI copy only.
- Bound selected-city HUD to governor portrait/name/stats, governor policy `OptionButton`, city loyalty, stationed hero chips, and city military/trade copy; policy changes update selected-city UI state only.
- Bound `CityDetailPanel` to selected city resource/rating/military/trade/governor/stationed hero count data.
- Kept attack, hero movement, domestic, recruit, diplomacy, spy, save/load/reset, and wild-army controls placeholder-only.
- Did not add `BattleContext`, battle transition, domestic execution, turn/resource mutation, recruitment, hero/army movement, route/pathfinding logic, or existing battle-scene changes.
- Castle icon visuals remain disabled; route lines and sea route arrow flow were preserved.
- 김작 F6 should confirm chancellor portrait/name/policy display, policy description changes, selected-city governor/policy/stationed heroes update on city click, buttons remain non-executing placeholders, HUD stays fixed during pan/zoom, castle icons remain hidden, route/sea arrow flow remains normal, and existing battle scenes remain stable.

### v0.68b-8 WorldMap Web HUD Visual Parity MVP
- Checked the actual web visual structure in `SamWar_web/index.html`, `css/main.css`, and the worldmap HUD UI modules.
- Tuned the Godot `WorldMapUI` HUD toward the web look with dark navy translucent panels, thin gold borders, beige/gold headings, compact text, inner cards, small tab buttons, red action buttons, and progress placeholders.
- Added a centered `SamWar Web` title banner placeholder.
- Expanded the left World Turn panel visuals with turn/calendar/owner, national progress bars, chancellor, resources, internal supply, logistics, external trade, wild-army edit, and save/load/reset placeholders.
- Expanded Diplomacy/Spy, City Detail, and Selected City panel visuals with web-like tabs/cards and placeholder content while keeping city-click selection updates intact.
- Kept every button placeholder-only; no `BattleContext`, battle transition, domestic execution, diplomacy/spy execution, turn/resource mutation, pathfinding, AI, or hero/army movement was added.
- Castle icon visuals remain disabled; city positions, route lines, and sea route arrow flow were preserved.
- 김작 F6 should confirm web-HUD visual similarity, fixed screen placement during pan/zoom, selected-city/city-detail refresh on city click, placeholder-only button behavior, castle icon disabled state, route/sea arrow continuity, and battle scene stability.

### v0.68b-8 WorldMap Web HUD Panel Structure Import MVP
- Checked the actual web HUD structure in `SamWar_web/js/ui/world_map_ui.js`, `ui_render.js`, `world_hud_ui.js`, `diplomacy_spy_ui.js`, `resource_ui.js`, and `selected_city_ui.js`, plus `data/cities.js` and `data/factions.js`.
- Expanded Godot `WorldMapUI` into a screen-fixed HUD structure closer to the web layout: left World Turn/Status, upper-right Diplomacy/Spy, right City Detail, and expanded Selected City / `CityInfoPanel`.
- City clicks still update `selected_city_id`, `selected_city_marker`, and `SelectionRing`, and now update both City Detail and Selected City panels together.
- All new controls are placeholders only: attack, hero movement, domestic, diplomacy, spy, and wild-army edit do not launch real behavior.
- Did not add `BattleContext`, battle scene transition, domestic execution, resource/turn processing, hero movement, army movement, pathfinding, AI, or naval logic.
- Castle icon visuals remain disabled; city positions, route lines, and sea route arrow flow were preserved.
- 김작 F6 should confirm the left status panel, upper-right diplomacy/spy panel, city detail panel, selected city panel, dual panel update on city click, fixed HUD behavior during pan/zoom, placeholder-only buttons, castle icon disable state, route/sea arrow continuity, and battle scene stability.

### v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch
- Switched the current worldmap city read from castle icon visuals back to functional markers.
- Kept all `CastleIcon` nodes and castle icon asset references, but saved each scene node as `visible = false`.
- Added `CASTLE_ICON_VISUALS_ENABLED := false` in `scripts/worldmap_city_marker.gd` so castle icon visuals are deferred but recoverable.
- Made the existing colored `CityDot` visible again for a simple functional marker while preserving `NameText`, `ClickArea`, metadata, selected city state, `SelectionRing`, and `CityInfoPanel`.
- Did not change city positions, route lines, sea route arrow flow, battle scenes, `BattleContext`, domestic UI, or hero/army movement.
- 김작 F6 should confirm castle icons are not visible, city labels and simple markers remain visible, clicks still select cities, `SelectionRing` and `CityInfoPanel` still work, pan/zoom does not break clicking, route/sea arrow flow remains normal, and battle scenes remain stable.

### v0.68b-6 WorldMap Selected City Panel Web Parity MVP
- Referenced the web `renderWorldMap()` / `onCitySelect()` / `city-hud-stack` / `renderSelectedCityPanel()` flow and ported the selected-city HUD shape into Godot at MVP scope.
- Replaced the minimal `CityInfoLabel` click result with a scene-authored `WorldMapUI/CityInfoPanel` backed by `scripts/worldmap_city_info_panel.gd`.
- City clicks now update `selected_city_id`, switch the selected `CityMarker`, show a marker-local `SelectionRing`, and refresh the panel.
- The panel shows city name, city id, region, owner label, city type, neighbors, route type summary, status copy, and attack / hero-move placeholder buttons.
- Attack and hero-move placeholders only print deferred debug messages; no battle scene transition, `BattleContext`, domestic detail, garrison detail, or army movement behavior was added.
- Sea route arrow flow and route lines were preserved. Sea arrow initial spacing now runs from script instead of saved `progress_ratio` scene properties, removing scene-load errors while keeping the visual FX.
- 김작 F6 should confirm city icon click selection, selection ring readability, fixed screen panel placement, listed metadata, placeholder buttons, pan/zoom click behavior, route/sea arrow continuity, and no battle scene regression.

### v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP
- Added sea-only arrow flow FX to the five current sea routes: Gyeongju-Kyoto, Gyeongju-Osaka, Sabi-Kyushu, Sabi-Jianye, and Kyushu-Osaka.
- Added `ArrowFlowRoot` Path2D nodes under those route roots, with four `PathFollow2D` arrow markers each.
- Added `scripts/worldmap_route_flow_fx.gd`; it references the route's scene-authored `Path2D.curve`, keeps arrows evenly spaced in the editor, and advances them along the curve at runtime.
- Arrow flow direction is MVP one-way from `start_city_id` to `end_city_id`.
- Land routes remain line-only; no movement, pathfinding, trade, battle entry, naval battle, or `BattleContext` behavior was added.
- 김작 F6 should confirm sea arrows flow naturally along curves, wrap at route end, do not cover city names/icons, land routes have no arrows, city click info remains normal, and battle scenes remain stable.

### v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning
- Tuned only land route visibility after 김작 F6 review found land routes too weak against the map's earth tones.
- Land route `Line2D` width is now `4.5`; land color is brighter ochre with higher alpha: `Color(0.86, 0.62, 0.32, 0.72)`.
- Sea route style remains unchanged at width `2.5` and pale blue `Color(0.55, 0.82, 1.0, 0.48)`.
- Preserved route node structure and scene-authored `Path2D.curve` behavior; no route curves or city marker positions were changed.
- 김작 F6 should confirm land routes are readable without overpowering castle icons, sea route feel is unchanged, pan/zoom keeps routes attached, and city click info remains normal.

### v0.68b-4 WorldMap Route Layer Path2D MVP
- Added the first route layer MVP to `WorldMap_Test.tscn`.
- Created route root nodes under `WorldMapRoot/RouteLayer`, each with route metadata, a `Path2D`, and a `Line2D`.
- Route connection meaning is stored on `scripts/worldmap_route_path.gd`; actual route shape is the scene-authored `Path2D.curve` source of truth.
- Land routes use muted earth-tone thin lines; sea routes use pale blue thin lines.
- Did not implement route clicking, army movement, pathfinding, battle entry, naval battle logic, or `BattleContext` runtime injection.
- Known issue retained: CityMarker root movement / name label attachment still needs 김작 manual 2D/F6 confirmation and is not treated as a blocker for this route-layer work.

### v0.68b-3 WorldMap City Castle Icon Apply
- Confirmed the four city castle icon assets exist under `assets/worldmap/city_icons/`.
- Added `CastleIcon` Sprite2D children under each `CityMarker_*` root and kept marker root positions unchanged.
- Renamed marker-local `NameLabel` nodes to `NameText` while preserving Node2D-based city text so root movement carries the name with the icon.
- Added city/region fallback icon mapping in `scripts/worldmap_city_marker.gd`: Korea, China, Japan, and Ordo.
- Scaled castle icons to a common target height of `56px`, hid the old `CityDot`, and enlarged the shared city click circle to `40px` radius.
- Preserved city metadata, click info panel behavior, manual tile layout, camera behavior, route/army/battle deferrals, and battle scenes.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.

### v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix
- Follow-up from 김작 confirmation that the `Label` / `Control`-type city name still did not follow marker root movement as expected in the Godot 2D editor.
- Added `scripts/worldmap_city_name_label.gd`, a `@tool` `Node2D` text drawer for city names.
- Converted all 13 `NameLabel` scene nodes from `Label` to `Node2D` under their existing `CityMarker_*` roots and preserved local name offset at `Vector2(0, 16)`.
- Restored `ClickArea/CollisionShape2D` as root children for all 13 city markers.
- Preserved marker root positions, city metadata, tile layout, camera behavior, and battle scenes.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.

### v0.68b-2-hotfix5 WorldMap City Marker Label Reparent Fix
- Audited `WorldMap_Test.tscn` city marker hierarchy and confirmed each city remains under `WorldMapRoot/CityLayer/CityMarker_*`.
- Renamed each marker's local visual children to the explicit structure `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D`.
- Updated `scripts/worldmap_city_marker.gd` to resolve `CityDot` and `NameLabel` as marker-root children, with legacy fallback names only for compatibility.
- Preserved current `CityMarker_*` root positions, label local offsets, click areas, exported metadata, info-panel click behavior, manual tile layout control, and camera behavior.
- Did not modify worldmap tiles, battle scenes, route drawing, army movement, battle entry, or `BattleContext` runtime injection.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.

### v0.68b-2-hotfix4 WorldMap City Marker Root Attachment Fix
- Audited `WorldMap_Test.tscn` city marker structure and kept icon/dot and name label as children of each `CityMarker_*` root.
- Added `ClickArea` and `CollisionShape2D` as children of each `CityMarker_*` root so root movement carries icon, label, and click area together.
- Added marker click signal plumbing through `scripts/worldmap_city_marker.gd` and connected it from `scripts/worldmap_test.gd`.
- Added a minimal screen-fixed `WorldMapUI/CityInfoLabel` that updates from marker metadata on click.
- Preserved current city root positions, metadata, manual tile layout control, and camera behavior.
- Did not add route drawing, army movement, battle entry, or `BattleContext` runtime injection.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.

### v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control
- Removed the runtime tile auto-layout behavior that forced tile positions from texture size during `_ready()`.
- Added tile rect union calculation from the current scene-authored Sprite2D transforms, using each tile's texture size and centered state.
- Kept the camera clamp driven by `_world_rect`, but `_world_rect` now comes from the saved Tile node layout rather than a hardcoded 2x2 placement.
- Preserved the 4 tile nodes, 13 city markers, marker metadata, and zero-offset worldmap layers.
- 김작 can now move `WorldMapRoot/WorldMapTileLayer/Tile_A1_TopLeft`, `Tile_A2_TopRight`, `Tile_B1_BottomLeft`, and `Tile_B2_BottomRight` in the Godot 2D editor, save, and have F6 respect that layout.
- Did not add route drawing, city click expansion, army movement, battle entry, or `BattleContext` runtime injection.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.

### v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix
- Audited the scene-authored tile layout after 김작 confirmed the 2D editor showed a large gray band between top and bottom tile rows.
- Changed the editor-visible tile positions to the actual displayed tile spacing: A1 `(0, 0)`, A2 `(512, 0)`, B1 `(0, 512)`, and B2 `(512, 512)`.
- Kept `Sprite2D.centered = false`, scale default, and zero-offset `WorldMapTileLayer` / `CityLayer` / `RouteLayer` / `ArmyLayer` / `EffectLayer` / `DebugLayer`.
- Re-seeded all 13 `CityMarker_*` root positions against the corrected 1024x1024 combined rect so markers remain on top of the map image.
- Preserved scene-authored city marker positions as the final source of truth; runtime only configures/validates tile layout and camera clamp.
- Did not add route drawing, city click expansion, army movement, battle entry, or `BattleContext` runtime injection.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.

### v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix
- Audited `WorldMap_Test.tscn` layer parents and confirmed `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` all live under `WorldMapRoot`.
- Made the shared worldmap layer origins explicit at `Vector2(0, 0)` and authored the four tile positions in the scene so the Godot 2D editor shows the same combined rect foundation as runtime.
- Repositioned all 13 `CityMarker_*` root nodes from the prior oversized seed coordinates to the 4-tile combined rect seed coordinates.
- Updated `web_seed_position` to match the corrected 4-tile rect seed while preserving scene-authored marker positions as the final source of truth.
- Kept marker metadata, label/color visuals, camera pan/zoom/clamp behavior, and worldmap UI structure intact.
- Did not add route drawing, city click expansion, army movement, battle entry, or `BattleContext` runtime injection.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.

### v0.68b-2 WorldMap City Marker Layer MVP
- Read `SamWar_web/data/cities.js` and used its 13 city entries as the marker metadata baseline.
- Added `scripts/worldmap_city_marker.gd` with exported metadata and simple marker label/color behavior.
- Added scene-authored `CityMarker_*` nodes under `WorldMapRoot/CityLayer` for Luoyang, Yecheng, Chengdu, Jianye, Karakorum, Pyeongyang, Hanseong, Gyeongju, Sabi, Kyoto, Osaka, Kyushu, and Edo.
- Converted web `x` / `y` percent-style values into initial 4096x4096 seed positions and stored them as `web_seed_position`; root node `position` in `WorldMap_Test.tscn` is the final editable source of truth.
- Preserved the current worldmap camera/canvas foundation and did not add city click, route drawing, army movement, battle entry, or `BattleContext` injection.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.

## 2026-05-27

### v0.68b-1 WorldMap Four-Tile Canvas Foundation
- Created `WorldMap_Test.tscn` as the first worldmap visual canvas scene.
- Placed four scene-authored Sprite2D tiles under `WorldMapRoot/WorldMapTileLayer` with `centered = false`; runtime layout uses the A1 texture size so A2, B1, and B2 attach as NE, SW, and SE without coordinate compensation.
- Added `WorldMapCamera` movement foundation with WASD/arrow pan, right/middle mouse drag pan, optional wheel zoom, and viewport/zoom-aware clamp inside the 2x2 map rect.
- Added screen-fixed `WorldMapUI` labels for title, camera/zoom debug, and input hint.
- Prepared empty `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` only; no city click, route graph, army movement, battle entry, or `BattleContext` injection was added.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Kimjak F6 manual QA remains: confirm four tiles attach without visible gap/overlap, camera pan is smooth and clamped, UI labels stay fixed, future layers exist in the scene tree, and `Battle_Fullscreen_Test.tscn` remains stable.

## 2026-05-26

### v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion
- Added root-level punch motion for unique skill cut-ins: alpha `0 -> 1`, scale `0.85 -> 1.12 -> 1.0`, minimal hold, and upward fade-out / shrink to `0.92`.
- Kept the existing fullscreen cut-in nodes and avoided particles, glow shaders, sound, and new assets.
- Updated effect apply timing to stay aligned after the punch/exit motion.
- Preserved unique skill effects, targeting, cooldowns, AI decisions, formulas, Camera2D policy, battlefield background, and status badge rules.
- 김작 F6 follow-up: confirm fast punch-in, upward shrink/fade exit, no buffer-like linger, no accumulated scale/position on repeated use, UI stability, and status badge fix6.

### v0.68a-4-hotfix4 Unique Skill Dynamic Impact Presentation
- Reused the existing fullscreen unique skill nodes for dynamic presentation: `UniqueSkillInkBurst`, `UniqueSkillCutinImage`, and `UniqueSkillNameLabel`.
- Added a brief ink flash, caster-side-aware slide-in direction, image scale punch from `1.10x` to `1.0x`, delayed skill-name pop, and fast slide/fade-out.
- Updated effect apply delay to include the delayed skill-name enter timing so battlefield damage/buff/FX and camera shake follow cut-in exit.
- Preserved unique skill effects, targeting, cooldowns, AI decisions, formulas, Camera2D policy, battlefield background, and status badge rules.
- 김작 F6 follow-up: confirm slide-in impact, scale punch, brief flash, skill-name pop, quick exit into battlefield FX, camera focus/shake return, UI stability, and status badge fix6.

### v0.68a-4-hotfix3 Unique Skill Cutin Fast Impact Timing
- Changed `UNIQUE_SKILL_CUTIN_ENTER_DURATION` to `0.10s`, `UNIQUE_SKILL_CUTIN_HOLD_DURATION` to `0.40s`, and `UNIQUE_SKILL_CUTIN_EXIT_DURATION` to `0.12s`.
- Kept `UNIQUE_SKILL_EFFECT_APPLY_DELAY` as the enter + hold + exit sum, so post-cutin damage/buff/FX and camera shake still follow cut-in exit.
- Preserved unique skill effects, targeting, cooldowns, AI decisions, formulas, Camera2D policy, battlefield background, and status badge rules.
- 김작 F6 follow-up: confirm the cut-in hits hard, reads briefly, exits around `0.6s`, and does not break battle tempo.

### v0.68a-4-hotfix2 Unique Skill Cutin Toast Tempo Match
- Compared unique skill cut-in tempo against existing battle toast timings: round start hold `1.15s`, reinforcement arrival hold `0.82s`, and battle toast fade timing around `0.42s` in / `0.32s` out.
- Changed `UNIQUE_SKILL_CUTIN_ENTER_DURATION` to `0.14s`, `UNIQUE_SKILL_CUTIN_HOLD_DURATION` to `0.9s`, and `UNIQUE_SKILL_CUTIN_EXIT_DURATION` to `0.14s`.
- Removed the `1.5s` hold from the current unique skill cut-in tempo because 김작 F6 found it too long.
- Preserved unique skill effect values, targeting, cooldowns, AI decisions, formulas, Camera2D policy, battlefield background, and status badge rules.
- 김작 F6 follow-up: confirm the cut-in reads clearly, feels close to turn-exchange toast tempo, exits quickly into damage/buff/FX, and keeps camera shake focus stable.

### v0.68a-4-hotfix2 Unique Skill Cutin Timing Trace
- Added `UNIQUE_SKILL_CUTIN_TIMING_DEBUG := true`.
- Added `[UNIQUE_CUTIN]` timing logs for SHOW_START, ENTER_DONE, HOLD_START, HOLD_DONE, EXIT_START, HIDE_DONE, and EFFECT_APPLY.
- Reworked the fullscreen cut-in tween into explicit enter-parallel, hold interval, and exit-parallel sequencing so the `1.5s` hold can be measured directly.
- Preserved unique skill effect values, targeting, cooldowns, AI decisions, formulas, Camera2D policy, battlefield background, and status badge rules.
- 김작 F6 follow-up: trigger a unique skill and compare HOLD_START to HOLD_DONE elapsed times, then check whether effect/exit timing explains the short perceived hold.

### v0.68a-4-hotfix1 Unique Skill Cutin Hold + Shadow Warning Fix
- Set `UNIQUE_SKILL_CUTIN_HOLD_DURATION` to `1.5s` so the fullscreen unique skill cut-in/toast stays on screen longer.
- Renamed the local battlefield texture scale variable to `battlefield_global_scale`.
- Renamed the local cutin rect origin variable to `cutin_position`.
- Preserved unique skill effects, targeting, cooldowns, AI decisions, formulas, Camera2D policy, battlefield background, and status badge rules.
- 김작 F6 follow-up: confirm the longer hold feel, short enter/exit, post-cutin damage/buff/FX, camera shake focus return, and no `global_scale` / `position` shadowing warnings.

### v0.68a-4 Unique Skill Fullscreen Cut-In Presentation
- Converted the existing `BattleUI/UniqueSkillToastRoot` presentation from a caster-anchored small toast into a screen-fixed wide cut-in.
- Added viewport-scaled cutin layout, large skill-name overlay, and short `enter / hold / exit` timing before applying the real unique skill effect.
- Delayed unique skill damage / buff / FX and camera shake until after cut-in exit, preserving existing effect logic, values, target selection, cooldowns, AI gates, and registry data.
- Updated `Battle_Fullscreen_Test.tscn` defaults so the cut-in nodes are editor-visible as a fullscreen overlay structure.
- 김작 F6 follow-up: verify fullscreen scale on the 3200x1800 battlefield, UI overlap feel, timing, post-cutin effects, camera focus/shake return, status badge fix6, and normal battle flow.

### v0.68a-3 Battlefield Large Background Apply + Camera Clamp
- Confirmed the target background exists at `assets/web_battle/battlefield/battlefield_3200x1800_worldmap_test_01.png`.
- Replaced the scene-authored `BattlefieldTexture` texture reference with the large 3200x1800 battlefield and positioned it as a 1:1 world background centered at `Vector2(1600, 900)`.
- Updated Camera2D clamp to use the battlefield texture's visual world rect before falling back to board marker bounds.
- Preserved current separated unit deployment, logical board/grid setup, battle formulas, AI behavior, status badge rules, scene slot structure, and old background asset.
- 김작 F6 QA should confirm no gray/empty area appears during camera follow/shake and that overlays remain synced on the large background.

### v0.68a-2-hotfix1 Camera-Bound Overlay Sync Fix
- Audited camera-bound CanvasLayer overlays after F6 showed facing indicators and post-move direction arrows could remain at stale screen positions after Camera2D focus.
- Updated `_world_to_battle_ui_position()` to compute UI coordinates from current `MainCamera` position/zoom when available.
- Switched combat focus movement to a tween method that refreshes camera-bound overlays each step and added deferred refresh after immediate/complete focus.
- Expanded `_refresh_camera_bound_world_overlays()` to update facing indicators, FacingArrowPanel, READY frames, floating command panel, and status badges.
- Preserved status badge fix6 rules, Camera2D focus policy, battle formulas, AI, grid/deployment, scene files, and assets.

### v0.68a-2 Combat Focus Camera Follow
- Added Camera2D focus helpers in `scripts/battle_web_import_test.gd` while keeping the scene-authored `MainCamera` and CanvasLayer UI foundation intact.
- Focus timing now covers initial active ally, ally selection, move start/finish, ally attack midpoint, enemy move/attack, strategy target pairs, unique skill presentation, and reinforcement arrival.
- Split scene-authored camera reset baseline from current focus baseline so unique-skill camera shake returns to the active focus position.
- Left battlefield scale, deployment recenter, battle formulas, AI behavior, status badge placement, scene files, and assets unchanged.
- 김작 F6 QA should confirm smooth focus movement, screen-fixed UI, status badge fix6 preservation, and stable camera shake return.

### v0.68a-1 Camera2D World/UI Layer Foundation
- Audited `Battle_Fullscreen_Test.tscn` and confirmed scene-authored `MainCamera` exists as `Camera2D` at `Vector2(960, 540)`.
- Confirmed primary UI containers are CanvasLayer-based: `BattleUI`, `EnemyRetreatToastLayer`, `CutinOverlay`, and `ResultOverlay`.
- Added `_get_main_camera_or_null()`, `_configure_main_camera()`, and `_reset_main_camera_to_scene_position()`.
- Runtime now enables and makes `MainCamera` current, stores scene-authored position/zoom as the camera baseline, and resets camera state before demo reset paths.
- Updated unique-skill camera shake to use the resolved MainCamera and the same baseline.
- Did not implement battlefield scale expansion, deployment recenter, combat focus follow, worldmap, or BattleContext runtime injection.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for normal battle display, fixed UI panels/buttons/toasts, MainCamera current behavior, camera initial framing, existing camera shake, stable battle loop, and status badge preservation.

### v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix
- Audited vertical-facing status badge placement after F6 showed top/bottom tail placement pushed badges into awkward body/flag positions.
- Changed `FACING_UP` and `FACING_DOWN` to use the same arrow-left-edge snap as right-facing units.
- Removed the vertical center-X calculation from the helper so no unused local warning can recur.
- Preserved left/right-facing edge snap from `v0.68a-fix4` and kept confusion fallback `◎N`.
- Preserved status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for final `→` left, `←` right, `↑` left, `↓` left placement, `0-4px` visual gap, no top/bottom vertical placement, body/face/flag overlap checks, and multi-status badge block alignment.

### v0.68a-fix5 Vertical Facing Status Badge Arrow Tail Fix
- Audited vertical-facing status badge placement after F6 showed up/down badges still following the portrait side.
- Removed the visual-anchor side-choice branch for `FACING_UP` / `FACING_DOWN`.
- Changed up-facing badges to attach below the arrow bottom edge and down-facing badges to attach above the arrow top edge, centered on the arrow visual rect.
- Preserved left/right-facing edge snap from `v0.68a-fix4` and kept confusion fallback `◎N`.
- Preserved status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for `→` left, `←` right, `↑` below, `↓` above arrow-tail placement, vertical body-overlap checks, confusion `◎N`, and multi-status badge block alignment.

### v0.68a-fix4 Status Badge Edge Snap To Facing Arrow
- Audited `_get_strategy_status_badge_position_for_unit()` after F6 showed the badge gap did not visually shrink.
- Changed the calculation to derive an approximate facing-arrow visual rect instead of treating the full facing indicator Control width as the arrow edge.
- Snapped right-facing badge blocks by their right edge to the arrow's left edge, and left-facing badge blocks by their left edge to the arrow's right edge, with a `2px` gap.
- Kept up/down-facing badge placement on the nearby side that avoids body-center overlap.
- Preserved confusion fallback `◎N` and left status/effect logic unchanged.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for true arrow-edge attachment, `0-4px` visual gap, ally/enemy parity, up/down body-overlap avoidance, confusion `◎N`, and multi-status badge block alignment.

### v0.68a-fix3 Status Icon Tighten + Confusion Fallback Restore
- Tightened `STATUS_BADGE_ARROW_GAP` from `6px` to `2px` so status badges sit closer to the facing arrow.
- Restored confusion battlefield badge text from numeric-only `N` to the stable `◎N` fallback after the attempted blank-symbol display failed to render reliably in Godot.
- Removed the unused `centered_badge_x` local variable from `_get_strategy_status_badge_position_for_unit()`.
- Confirmed the status badge refresh path keeps null guards for `battle_fx_root`, `unit_state`, facing indicator lookup, and child labels.
- Preserved status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for near-attached arrow placement, Y-axis stability, up/down body-overlap avoidance, confusion `◎N`, shake `⚠N`, first-run stability, and multi-icon horizontal alignment.

### v0.68a-fix2 Status Icon Tight Arrow Anchor + Confusion Icon Patch
- Audited status badge display entries and `_get_strategy_status_badge_position_for_unit()`.
- Changed confusion battlefield badge text from `◎N` to turn count only, such as `N`.
- Tightened `STATUS_BADGE_ARROW_GAP` from `10px` to `6px`.
- Kept horizontal-facing badges behind the arrow and changed up/down-facing badges to the nearby arrow side that avoids body-center overlap.
- Preserved status effects, turn decrement logic, strategy behavior, defend behavior, unique skills, damage/move/attack formulas, marker/slot structure, battle size, AI, and worldmap contracts.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for ally/enemy same-rule placement, tight unit distance, up/down body-overlap avoidance, confusion `N`, shake `⚠N`, multi-icon horizontal alignment, and severe face/arrow overlap checks.

### v0.68a-fix1 Status Icon Anchor Consistency Patch
- Audited `_refresh_strategy_status_icon_labels()` and `_get_strategy_status_badge_position_for_unit()`.
- Replaced the old vertical-facing side-choice branch with one shared backside-of-facing-arrow rule for all units.
- Set status badge gap from the facing arrow to `10px` and kept multi-status icons horizontally arranged.
- Preserved status/effect logic, defend logic, marker/slot structure, battle size, AI, and worldmap contract docs.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for ally/enemy/support/reinforce badge distance, arrow-backside placement, face-line fit, and severe overlap checks.

### v0.68 Agent Contract Split for WorldMap + Hero Scale Prep
- Added `WORLDMAP_RULES.md`, `HERO_DATA_CONTRACT.md`, `ARMY_DEPLOYMENT_RULES.md`, `BATTLE_CONTEXT_CONTRACT.md`, `BATTLE_ENGINE_RULES.md`, and `SKILL_SYSTEM_RULES.md`.
- Defined worldmap / army systems as owners of encounter creation, battle type, terrain, region, `map_variant_id`, and roster preparation.
- Defined the battle engine as a consumer of prepared `BattleContext.roster`, not a direct hero-selection owner.
- Split `HeroData` static metadata from battle runtime state and documented future army / deployment / skill metadata boundaries.
- Documented `hero_id` as source of truth, global hero registry direction, BattleContext-only battle engine input, and future naval/coastal/siege expansion hooks.
- Updated handoff, current state, next tasks, and changelog.
- Docs-only architecture contract patch; no runtime code, scene, script, or asset changes.

### v0.67z-4 Agent Role Split Foundation
- Split mixed agent responsibilities into role-based docs: architect, implementation, QA, runtime QA, visual QA, and workflow manager.
- Kept `CODEX_WORKFLOW_RULES.md` as the canonical source for task classification, autonomous execution, approval handling, and verification depth.
- Updated `HANDOFF_TO_CODEX.md` reading order and linked `QA_AGENT.md` as the regression guard reference.
- Updated current state and next tasks toward worldmap / BattleContext / hero-army deployment contract preparation.
- No feature code, scene, or asset changes.

## 2026-05-25

### v0.67z-3 Strategy Status Badge Near Facing Arrow Patch
- Audited `_refresh_strategy_status_icon_labels()` and replaced the fixed visual-anchor right offset with `_get_strategy_status_badge_position_for_unit()`.
- Status badges now anchor near the facing indicator line: left-facing badges sit to the arrow's right, right-facing badges sit to the arrow's left, and up/down facings choose the near arrow/portrait side.
- Reduced badge root width to the actual active icon strip width so single/multiple badges do not inherit the old wide spacing.
- Kept status/effect logic, defend logic, marker/slot structure, and battlefield size unchanged.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for 좌→우 / 우→좌 / up/down badge distance and hero-face overlap checks.

### v0.67z-2 Deployment Anchor Source Unification
- Added deployment-marker sync from scene-authored `Slot` / `UnitVisualRoot` anchors before demo state creation and marker-to-grid-cell sync.
- Resolved all `10` active visual slot IDs through shared marker/root/portrait helper functions instead of adding unit-specific coordinate patches.
- Kept `UnitMarker` / `PortraitMarker` nodes as compatibility targets while making slot/root placement the manual layout source.
- Godot headless validation was blocked in Codex by `windows sandbox: spawn setup refresh`; `git diff --check` passed.
- Left 김작 F6 QA for moving `Slots/AllyReinforce01Slot` and checking ROUND 2 김유신 spawn plus HP/troop/portrait/click/facing/status alignment.

### v0.67z Unit Visual Attachment / Manual Layout Control Patch
- Audited the `10` active visual slots and confirmed token, shadow, portrait, HP bar, troop label, and move dust are already under `UnitVisualRoot`.
- Added runtime marker sync from scene-authored `UnitVisualRoot` global movement so moving a slot/root in the Godot 2D editor drives the shared visual anchor.
- Switched unit group offset application to global positioning and kept click areas anchored through the `UnitVisualSlot` registry.
- Kept READY frames, facing indicators, and status badges as UI/FX overlays but positioned from the same slot-synced anchor.

### v0.67y-3 Web Defend Command + Formation Status Layout Guard
- Added defend wounded-troop recovery equal to `10%` of missing troops, including green floating recovery text and updated battle-log wording.
- Added defending-unit hit reactions on basic attacks and single-target unique skills.
- Compacted formation-guide status text to the first summary plus `외 N` overflow and trimmed long text with ellipsis.
- Adjusted formation-guide troop icon/type/status bounds and enlarged the mini-log panel/text area for cleaner layout.

### v0.67y-2-hotfix1 Status Icon Readability Fix
- Fixed confusion battlefield badges to render as `◎N` instead of bare numbers.
- Separated defense `◆` and attack-up `▲` status colors into blue / amber tones across unit badges and formation status text.
- Improved formation guide troop readability by enlarging troop icons to `56 x 56` and brightening / outlining troop-type labels.

### v0.67y-2 Web Defend Command Port + Status Icon Tone Polish
- Reused the floating move button as `방어` and kept movement on direct move-click / bottom command paths.
- Added manual defend resolve with `is_defending`, action consume, floating `방어`, and mini-log output.
- Applied defend incoming damage reduction in the existing directional damage helper and clear defend on next action-lock reset.
- Toned down status badge/text alpha and changed attack-buff display to `▲ 공격+N`.

### v0.67y-1-hotfix1 Unified Status Display + Toast Fade Polish
- Unified status rendering so strategy statuses and unique-skill buffs share one unit badge / formation text formatter.
- Added `◆` display for active unique-skill attack / defense buffs on unit badges and formation guide status lines.
- Changed confusion unit badge to icon-style `N` and kept shake as `⚠N`, with badges closer to the unit.
- Polished defeat-retreat toast disappearance with a short fade / slight settle after hold.

### v0.67y-1 Strategy Status UX + Result Sequence Fix
- Retuned defeat-retreat toast hold to `1.2s` first / `1.0s` queued and deferred result toast display until the exit queue is done.
- Enlarged battlefield strategy status icons and added formation-guide status summaries below troop counts.
- Enlarged formation troop icons to `52 x 52` while keeping unique-skill-ready icons at `64 x 64`.
- Applied `동요` as a light attack/defense penalty and moved status turn decrease to after action/skip resolution.

### v0.67y Web Strategy Port MVP
- Enabled the floating `책략` command for manual ally units with intelligence `80+`.
- Added strategy mode, cyan range/valid target markers, success/failure resolve, mini-log entries, and floating effects.
- Added `혼란` / `동요` status storage and compact unit/formation status icons.
- `혼란` skips affected ally/enemy actions; enemy/auto strategy casting is deferred.

### v0.67x-7-hotfix4 Defeat Toast Duration + Size Tune
- Tuned defeat-retreat toast hold from `3.0s` to `1.5s` for single and queued exits.
- Reduced the scene-authored toast panel / portrait bounds and lowered runtime name / dialogue font sizes.
- Preserved elapsed logs, snapshot queue playback, and non-blocking battle flow.

### v0.67x-7-hotfix3 Defeat Toast Actual 3s Hold Fix
- Traced the short display to defeat-retreat fade-out being appended in parallel with the hold interval.
- Rechained the tween so the readable hold runs for `3.0s` before fade-out and added DEBUG elapsed logs.
- Preserved snapshot queue playback, cleanup, result checks, turn flow, and full-auto progression.

### v0.67x-7-hotfix2 Defeat Toast 3s + Hakikjin Range Sync
- Increased ally defeat and enemy retreat toast hold time to `3.0s` for single and queued exits.
- Synced 학익진 포격 valid markers and damage application through the same caster-range target helper.
- Preserved snapshot toast queue, unique skill cooldown/action flow, and full-auto progression.

### v0.67x-7-hotfix1 Defeat Toast Hold Duration 2s
- Increased ally defeat and enemy retreat toast hold time to `2.0s` for both single and queued sequential exits.
- Preserved the existing snapshot queue so cleanup, result checks, turn progression, and full-auto flow remain non-blocking.

### v0.67x-7 Defeat Retreat Toast Actual Apply
- Confirmed the existing retreat toast implementation was enemy-only and generalized it for ally/enemy battle exits.
- Snapshot portrait / name / side / fallback line before cleanup, then play a visible scene-authored toast with separate ally/enemy dialogue pools.
- Verified enemy single exit, ally single exit, mixed simultaneous queue, immediate untargetable cleanup, scene load, and full-auto victory path.

### v0.67x-7 Enemy Retreat Toast Actual Apply
- Confirmed an enemy retreat toast implementation already existed but was a single immediate toast under `BattleUI`, with no snapshot queue.
- Moved the toast to a dedicated scene-authored layer and switched defeat handling to snapshot queued playback before cleanup.
- Verified single enemy defeat, simultaneous two-enemy defeat queue, immediate untargetable cleanup, and full-auto victory path.

### v0.67x-6 Targeting UX + Buff Preview + Retreat Toast Polish
- Added short manual preview before buff unique skills auto-resolve, covering 정도전 and 권율 flows.
- Hid the floating ally command panel during basic attack / unique-skill target selection and restored it after cancel or resolve.
- Strengthened the separate gold/orange valid-target marker over persistent purple range cells.
- Added enemy retreat portrait toast MVP before dead-unit cleanup without blocking battle result or full-auto flow.
- Verified headless project load, scene load, targeting / buff / retreat smoke, full-auto result path, and `git diff --check`.

### v0.67x-5 Unique Skill Regression Fix Gate
- Restored formation-guide `TroopIconRect` nodes to readable `40 x 40` while keeping `UniqueSkillReadyIcon` at `64 x 64`.
- Unified unique skill readiness and auto/enemy decision gates around range-limited valid targets with no 이순신-only special case.
- Fixed 정도전 / 권율 buff unique skill manual resolve/reuse and kept 김유신 attack targeting on the same validation path.
- Limited 유비-style buff skills to in-range unbuffed allies and kept low-value cases falling back to movement/basic attack/wait.
- Split unique skill range overlay display into persistent purple range cells plus separate gold valid-target markers.
- Added short auto/enemy unique skill range preview before resolve.
- Confirmed no project code controls WASAPI/audio output devices.
- Verified headless project load, scene load, regression smoke, and full-auto result path.

## 2026-05-24

### v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance
- Restored formation-guide `TroopIconRect` nodes to readable `32 x 32` display while keeping `UniqueSkillReadyIcon` at `64 x 64`.
- Normalized unique skill range helpers so melee unique skills require close engagement and cannon AOE stays mid-range.
- Added high-value and fallback-value checks for enemy/auto unique skill decisions.
- Restored full-auto movement / approach / basic attack pressure instead of using every ready unique skill.
- Kept manual unique skill range/target UX, unique skill toast, large red damage numbers, camera shake, cooldown, and directional damage bonuses intact.
- Deferred detailed unique skill range balance, `SkillInfoPanel`, and tactics status/explanation UI.

### v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus
- Enlarged formation-guide `UniqueSkillReadyIcon` nodes to `64 x 64`.
- Added front / side / back directional damage helpers with `1.0 / 1.15 / 1.3` multipliers.
- Applied directional bonus to basic attacks, enemy hits, and single-target attack unique skills.
- Changed unique skill readiness from one-use flags to cooldown state.
- Added auto battle ally unique skill selection before normal attack / move / wait fallback.
- Added enemy AI unique skill selection on enemy turns and after movement rechecks.
- Kept manual unique skill range/target flow, backdrop cleanup, tooltip cleanup, damage numbers, and camera shake intact.
- Deferred `SkillInfoPanel` and unique skill range balance.

### v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix
- Removed the `is_visible` shadowing warning in the unique skill ready icon helper.
- Hid the unique skill toast black backdrop so transparent cutin edges remain visible.
- Enlarged formation-guide `UniqueSkillReadyIcon` nodes to `36 x 36`.
- Kept unique skill hover tooltip text suppressed while preserving the button label.
- Changed manual ally unique skill flow to button click -> range/target display -> valid target click -> resolve.
- Added purple skill range cells and gold/orange valid target cells via the existing overlay pool.
- Kept `SkillInfoPanel` deferred.

### v0.67x-1 Unique Skill Hover Cleanup + Ready Icon
- Removed duplicate hover tooltip text from `FloatingUniqueSkillButton` and kept the skill name only inside the button.
- Added `UniqueSkillReadyIcon` nodes to the formation guide cards and only light them for the currently usable active ally.
- Kept unique skill toast / damage number / camera shake / range flow unchanged.
- Deferred `SkillInfoPanel` to the next UX candidate instead of implementing it here.

### v0.67x Unique Skill MVP Per Hero Cutin
- Added current-roster unique skill registry entries for:
  - 이순신
  - 정도전
  - 권율
  - 김유신
  - 을지문덕
  - 관우
  - 장비
  - 하후돈
  - 유비
  - 제갈량
- Connected unique skill cutins under `assets/web_battle/skill_cutins/`.
- Added `UniqueSkillToastRoot` scene nodes for a caster-anchored ink toast.
- Kept the presentation timing at `2200ms`.
- Enabled `FloatingUniqueSkillButton` for active living ally units with available unique skill data.
- Added MVP effects, large red skill damage numbers, camera shake, battle mini-log entries, and action consumption.
- Deferred enemy / auto unique skill use.

### v0.67w Battle Screen Basic UX Stable Lock
- Locked the current MVP battle-screen UX baseline without adding new functionality.
- Verified:
  - `FormationSlotGuideLayer`
  - `AllyFormationGuidePanel`
  - `EnemyFormationGuidePanel`
  - lower-left `BattleMiniLogPanel`
  - `CommandBar` with `BottomCommandBarBackground`
  - `AutoBattleButton`
  - `EndTurnButton`
  - disabled `RetreatButton`
- Confirmed legacy `LeftPanel` / `RightPanel` remain hidden and `UnitCloseupPanel` remains hidden.
- Confirmed formation guide cards keep compact name / troop / troop-icon / troop-type display with no status text regression.
- Confirmed floating command panel, direct move-click, right-click rollback, post-move reopen, active ally pulse pivot lock, reinforcement arrival, and result toast path remain stable.

### v0.67v Bottom Command Bar Background Panel Apply
- Applied `bottom_command_bar_bg.png` as the scene-authored `CommandBar` background.
- Added `BottomCommandBarBackground` `TextureRect` behind the 3 bottom command `TextureButton`s.
- Hid the old black `CommandBar` fill with a transparent panel style override.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` paths and handlers unchanged.
- Kept the layout scene-authored with no runtime size/position forcing.

### v0.67u-3 Formation Guide Card Compact Info Polish
- Hid `UnitCloseupPanel` and kept it reserved for future popup reuse.
- Repacked each ally/enemy formation guide slot into portrait / name / troop / troop-icon / troop-type layout.
- Removed `행동중`, `출전`, `지원대기`, and round-wait status text from the cards.
- Added troop icon + troop type binding with hero/default visual-key fallback.
- Reduced guide-card font sizes and kept active/reserve distinction as style-only.
- Intended scope remained UI-only with no battle-logic change.

### v0.67u Formation Slot Guide Layout MVP
- Hid the large legacy `LeftPanel` / `RightPanel` battle info panels.
- Added `BattleMiniLogPanel` at the lower-left.
- Added `FormationSlotGuideLayer` with:
  - `AllyFormationGuidePanel`
  - `EnemyFormationGuidePanel`
- Added display-only guide slots for main `3` + reinforce `2` per side.
- Reused existing hero/slot/deployed state data without changing battle logic.

### v0.67t-hotfix Bottom Command TextureButton Scene Fix
- Converted `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` from `Button` to scene-authored `TextureButton`.
- Connected the 6 bottom command PNG assets directly in `Battle_Fullscreen_Test.tscn`.
- Removed the bottom-command runtime `StyleBoxTexture` apply path from the active bottom-bar flow.
- Preserved existing handlers.
- Preserved `RetreatButton` as a disabled placeholder.
- Restored bottom command image visibility in the Godot 2D editor.

### v0.67t Bottom Command Button PNG Apply QA
- Confirmed all 6 bottom command PNG files exist.
- Confirmed all 6 PNG files are `512x256` with `Format32bppArgb`.
### v0.70-13a Battle Intro Wide Hold Timing Polish
- Tuned battle intro timing after visible QA found the zoom entered gameplay too quickly.
- `BATTLE_INTRO_WIDE_HOLD_SEC` changed from `0.4` to `0.85`.
- `BATTLE_INTRO_ZOOM_SEC` changed from `1.0` to `1.15`.
- `BATTLE_INTRO_UI_FADE_SEC`, skip input, UI restore, input guard, and gameplay camera restore behavior were left unchanged.
- No battle logic, result/worldmap flow, cutin/result video assets, archer volley FX, or gunner shot FX changes were intended.
- Manual visual QA remains: confirm the wide-shot now feels appreciable and the zoom no longer feels rushed.

### v0.70-13 Battle Intro Camera Zoom Patch
- Added a battle-start camera intro in `scripts/battle_web_import_test.gd`.
- The intro captures the final gameplay camera state, moves `MainCamera` to a wider battlefield shot, holds briefly, then zooms back to the captured gameplay view.
- `BattleUI` is hidden during the intro and restored after completion or skip; battlefield background and units remain visible.
- Skip input is handled through mouse click, Space, Enter, numpad Enter, or Esc.
- Battle input, button commands, auto battle enable, and camera focus calls are guarded while the intro is playing.
- Verification performed during implementation: `git diff --check`, Godot project headless load, and `Battle_Fullscreen_Test.tscn` headless load passed.
- No battle logic, grid logic, worldmap flow, cutin/result video assets, archer volley FX, or gunner shot FX changes were intended.
- Manual visual QA remains: confirm wide-shot composition, smooth zoom, UI restore timing, skip behavior, and normal controls after skip/completion.

### v0.70-12a Battle Result Video Panel Size Polish
- Adjusted `VideoStreamPlayer_Result` so victory/defeat result videos no longer render full-screen.
- Added result-video panel sizing helpers in `scripts/battle_web_import_test.gd`; video is centered in a 16:9 panel while the dim backdrop remains full-screen.
- Kept the existing video-before-toast flow, fallback timer/load-failure path, and existing victory/defeat toast behavior.
- Included Godot-generated UID metadata for the two result OGV resources.
- No result payload/worldmap flow, special-skill cutin mapping, archer volley, or gunner shot behavior was intentionally changed.
- Manual visual QA remains: win/loss result video panel size, aspect ratio, video -> toast order, and result return flow.

- Applied bottom command PNG styles to `AutoBattleButton`, `EndTurnButton`, and `RetreatButton`.
- Preserved existing `Button` nodes and existing handlers.
- Preserved `RetreatButton` as a disabled placeholder.
- Cleared button text only when image style apply succeeded, so visual text overlap is removed while missing-file fallback remains safe.
- Expanded the scene-authored bottom `CommandBar` layout for `256x128` display buttons.

### v0.67s Bottom Command Button Actual Asset Integration
- Added `_try_load_texture_or_null()` for safe optional bottom-command PNG loading.
- Added `_apply_button_texture_style_if_available()` and kept `_try_apply_bottom_command_button_art()` as the button-key entry point.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` as existing `Button` nodes with existing handlers unchanged.
- Missing PNG files remain a safe fallback path with no load error and no intended behavior change.

### v0.67r Bottom Command Bar Art Asset Structure Prep
- Confirmed the bottom global command bar currently uses `Button` nodes:
  - `AutoBattleButton`
  - `EndTurnButton`
  - `RetreatButton`
- Confirmed existing pressed handlers are reused:
  - `AutoBattleButton` -> `_toggle_full_auto_battle`
  - `EndTurnButton` -> `_end_ally_turn_by_wait`
  - `RetreatButton` remains a disabled placeholder
- Added `assets/web_battle/ui/bottom_command/README.md`.
- Added optional runtime bottom-command art path mapping and safe apply helper.
- Missing PNG files now remain a safe no-op instead of a load dependency.
- No behavior change intended for direct move-click, floating panel flow, active ally pulse, or `5v5` battle flow.

### v0.67-docs Agent Docs Slimdown
- Created `agent/archive/v0.67-docs_agent_docs_slimdown/`.
- Preserved full pre-slimdown copies of:
  - `CURRENT_STATE.md`
  - `CHANGELOG.md`
  - `SESSION_LOG.md`
- Rewrote top-level `agent` docs into shorter operational documents centered on the current stable baseline `v0.67p-3-hotfix3 Active Ally Pulse Pivot Lock QA Stable`.
- Removed top-level priority confusion from older `v0.67k` baseline references while leaving archived history intact.

### Current stable reference
- `v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance`
- Stable `5v5` battle loop
- Stable formation guide + mini log + bottom command bar + floating command panel MVP screen composition
- Stable ally manual / auto / enemy unique skill MVP with caster-anchored cutin toast
- Stable directional damage bonus for front / side / back attacks
- Stable reinforcement / round / result toast flow
- Stable floating command panel, bottom command bar, direct move-click UX, rollback, post-move reopen, and active ally pivot-locked root pulse

## Archive
- Full older session history moved to:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
## v0.68b-12b-33D Defense Deployment Panel Parity
- Extended `PlayerAttackDeploymentPanel` with defense mode labels and confirm behavior.
- Rewired enemy invasion manual/auto defense buttons to open the deployment panel first.
- Added defense deployment payload construction from pending invasion event.
- Added defense deployment validation and confirm flow with commandLimit/source reserve clamp.
- Added selected defender roster support in enemy invasion BattleContext generation.
- Preserved existing attacker auto allocation, attacker/defender pre-decrement helper, result outcome payload, and woundedQueue result flow.
- Verification performed: `git diff --check`, Godot project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- F6 manual QA remains required for actual click flow and win/loss accounting.

## v0.68b-12b-32 CommandRank CommandLimit Allocation Parity
- Read SamWar_web command rank constants and allocation helpers from `constants.js` and `app_state.js`.
- Added Godot command rank helpers matching web values and governor override behavior.
- Added commandLimit metadata to deployment payloads and BattleContext hero payloads.
- Updated player attack deployment UI to show command label/limit and cap SpinBox max by commandLimit.
- Updated confirm validation to clamp allocations by commandLimit and source reserve.
- Replaced player attack defender and enemy invasion attacker/defender default even allocations with commandLimit allocation.
- Verification pending at this log point: full Godot headless scene loads and F6 manual QA.

## v0.68b-12b-28 Player Attack Deployment UX Polish
- Polished `PlayerAttackDeploymentPanel` layout and copy for F6 usability.
- Added troop summary, remaining garrison summary, supply enough/shortage text, and confirm blocking reason display.
- Added sortie confirmation feedback and clearer player attack result messages.
- Verification: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load passed.
- F6 manual QA could not be executed in this Codex session; remaining manual checks are panel open/size, hero selection, troop SpinBox, supply shortage blocking, battle transition, victory/defeat result, save/load, and enemy invasion regression.

## v0.68b-12b-27 Player Attack Deployment UI MVP
- Added `scripts/player_attack_deployment_panel.gd` as a compact runtime deployment panel.
- Rewired player attack button flow so attack opens deployment UI first, then confirms into the existing BattleContext handoff.
- Implemented deployable hero filtering, troop allocation validation, source-city reserve guard, and source-city supply preview/payment.
- Added `selected_attacker_hero_ids`, `attacker_troop_allocation`, `supply_cost`, and `supply_source_city_id` to `player_attack` context.
- Added source-city `resource_stock` runtime defaults and save/load persistence in city overrides.
- Verification performed by Codex: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. F6 manual deployment QA remains required.
