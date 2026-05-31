# SESSION LOG

## 2026-06-01

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
- Added publicSupport-based recruitment limit, cost, validation, and execution helpers.
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
