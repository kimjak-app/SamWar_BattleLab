# CHANGELOG

## T08-2-hotfix1 Production HUD Recovery
- Removed the malformed ProductionHudRoot scene patch marker that caused cascading vanished-parent errors.
- Corrected production/legacy HUD visibility parity, empty placeholder visibility, roster shadowing warning, and focused scene/layout validation.

## T08-2 Production Battle HUD Skeleton
- Added the scene-authored production battle HUD hierarchy, normalized HUD state adapter, focused validator, and production refresh path.
- Preserved legacy battle surfaces and corrected the visible floating defend-command label.

## v0.70-98 Domestic Tech Complete Lock
- Declared the Domestic Tech first-pass route complete and locked.
- Summarized the v0.70-93 Economy / City, v0.70-94 Defense / Battle, v0.70-95 Diplomacy / Spy, v0.70-96 Naval / Siege, and v0.70-97 Full Gameplay F6 QA results.
- Added side-effect-free complete-lock summary flags to `scripts/worldmap_test.gd`.
- Documented that future Domestic Tech work is limited to bugfix, balance, UI display polish, or separately scoped second-pass systems.
- Separated future work from Domestic Tech into non-Domestic-Tech system tracks.
- Preserved save/load schema, active payload schema, actual charge logic, food deduction order, BattleContext schema, pending invasion schema, battle/diplomacy/spy formulas, naval/siege production absence, ship/siege count/storage absence, enemy research absence, scenes, assets, and imports.

## v0.70-97 Full Gameplay F6 QA
- Verified the full Domestic Tech gameplay effect route across v0.70-93 Economy / City, v0.70-94 Defense / Battle, v0.70-95 Diplomacy / Spy, and v0.70-96 Naval / Siege integrations.
- Added side-effect-free QA summary flags to `scripts/worldmap_test.gd`; no gameplay formula, schema, count, storage, scene, asset, or import behavior was changed.
- Recorded Research Flow, Economy / City, Defense / Battle, Diplomacy / Spy, Naval / Siege, Enemy Baseline / No Enemy Research, Preservation, and Godot Output QA results in the manual QA document.
- Confirmed no blocker was found and the next route step is `v0.70-98 Domestic Tech Complete Lock`.
- Preserved save/load schema, active payload schema, actual charge logic, food deduction order, BattleContext schema, pending invasion schema, battle/diplomacy/spy formulas, naval/siege production absence, ship/siege count/storage absence, enemy research absence, scenes, assets, and imports.

## v0.70-96 Naval / Siege Unlock Integration
- Added completed Domestic Tech naval unlock helpers for PLAYER same-city effects in `scripts/worldmap_test.gd`.
- Added completed Domestic Tech siege unlock helpers for PLAYER same-city city effects plus existing PLAYER national logistics/expedition/reform support.
- Connected player attack availability and deployment validation/preview to naval/siege unlock eligibility without adding ship/siege inventory or count mutation.
- Added naval/siege unlock summary lines to existing city detail and Domestic Tech inspector display flows.
- Added ENEMY naval/siege baseline helpers that are side-effect-free, masked by insufficient intel, and explicitly not enemy research.
- Updated the Domestic Tech integration map and agent handoff docs for the next `v0.70-97 Full Gameplay F6 QA` task.
- Preserved save/load schema, active payload schema, actual charge logic, food deduction order, BattleContext schema, pending invasion schema, battle/diplomacy/spy formulas, ship/siege count mutation absence, enemy research absence, scenes, assets, and imports.

## v0.70-95 Diplomacy / Spy Effect Integration
- Added completed Domestic Tech diplomacy/spy modifier helpers for PLAYER national effects in `scripts/worldmap_test.gd`.
- Connected diplomacy preview/apply, alliance acceptance, military support acceptance, and tribute relation gain to modifier-backed completed-tech lookup without changing relation schema.
- Connected spy success, detection, wedge success, and intel visibility preview/roll inputs to modifier-backed completed-tech lookup without changing spy payload schema.
- Added ENEMY diplomacy/spy baseline helpers that are side-effect-free, masked by insufficient intel where needed, and explicitly not enemy research.
- Updated the Domestic Tech integration map and agent handoff docs for the next `v0.70-96 Naval / Siege Unlock Integration` task.
- Preserved save/load schema, active payload schema, actual charge logic, food deduction order, BattleContext schema, pending invasion schema, battle formula after v0.70-94, naval/siege production absence, enemy research absence, scenes, assets, and imports.

## v0.70-94 Defense / Battle Effect Integration
- Added completed Domestic Tech defense/battle modifier helpers for PLAYER national and same-city PLAYER city effects in `scripts/worldmap_test.gd`.
- Connected selected city defense display and summary to the defense modifier helper contract.
- Connected PLAYER battle modifiers to existing hero roster attack/defense preparation without changing BattleContext schema, pending invasion schema, or troop counts.
- Added ENEMY city defense/battle baseline helpers that are side-effect-free, masked by insufficient intel, and explicitly not enemy research.
- Updated the Domestic Tech integration map and agent handoff docs for the next `v0.70-95 Diplomacy / Spy Effect Integration` task.
- Preserved save/load schema, active payload schema, actual charge logic, food deduction order, BattleContext schema, pending invasion schema, diplomacy/spy formulas, naval/siege production absence, enemy research absence, scenes, assets, and imports.

## v0.70-93 Economy / City Effect Integration
- Added completed Domestic Tech lookup wrapper helpers for PLAYER national and same-city PLAYER city effects in `scripts/worldmap_test.gd`.
- Added economy modifier helpers for PLAYER city and national Domestic Tech effects.
- Routed the existing turn income Domestic Tech bonus calculation through the new modifier helper contract while preserving the existing food/gold calculation shape.
- Added modifier-backed economy summary lines to the city detail resource tab and national warehouse summary.
- Added an ENEMY city economy baseline helper that is side-effect-free, masked by insufficient intel, and explicitly not enemy research.
- Updated the Domestic Tech integration map and agent handoff docs for the next `v0.70-94 Defense / Battle Effect Integration` task.
- Preserved save/load schema, active payload schema, actual charge logic, food deduction order, BattleContext schema, pending invasion schema, battle/diplomacy/spy formulas, naval/siege production absence, enemy research absence, scenes, assets, and imports.

## v0.70-92 Domestic Tech Gameplay Effect Integration Map
- Added `agent/DOMESTIC_TECH_GAMEPLAY_EFFECT_INTEGRATION_MAP.md` with code-backed hook maps for Economy/City, Defense/Battle, Diplomacy/Spy, and Naval/Siege Domestic Tech effect integration.
- Recorded current Domestic Tech state: research start/progress/completion and actual start-cost charge are implemented, but completed effects still need direct gameplay effect connections for final completion.
- Documented completed tech lookup contract for PLAYER national completed tech and same-city PLAYER city completed tech.
- Added integration priority table and locked the seven-step route from v0.70-92 through v0.70-98.
- Added side-effect-free `_get_domestic_tech_gameplay_effect_integration_map_summary_mvp()` to expose candidate hooks and preservation flags.
- Preserved actual charge logic, gold/food deduction, food order, active payload schema, save/load schema, UI behavior, BattleContext schema, pending invasion schema, formulas, enemy research/effect absence, naval/siege production absence, scenes, assets, and imports.

## v0.70-91 Labor Policy Save Schema Draft
- Extended `agent/DOMESTIC_TECH_LABOR_POLICY_RESOURCE_DESIGN.md` with the v0.70-91 save schema draft.
- Drafted future city labor storage as `labor_pool`, an accumulated city-state resource with cap and current-value-first persistence.
- Drafted future national policy storage as `policy_points`, an accumulated PLAYER national/player-state resource with cap and current-value-first persistence.
- Recorded storage candidates against current `player_state` / `worldmap_city_state` save structure, including the risk of mixing labor/policy into physical `resource_stock` buckets.
- Documented initial value, cap, old-save migration/defaulting, clamp validation, schema-version policy, UI relationship, and future actual-charge connection rules.
- Preserved runtime code, gameplay logic, UI behavior, save/load schema, migration code, active research payload schema, cost/duration/effect balance values, actual charge logic, gold/food deduction, paid cost state absence, cancel/refund absence, BattleContext, pending invasion schema, scenes, and assets/imports.

## v0.70-90 Labor Policy Resource Loop Design
- Extended `agent/DOMESTIC_TECH_LABOR_POLICY_RESOURCE_DESIGN.md` with the v0.70-90 labor/policy loop design.
- Defined labor as city-only accumulated resource with cap, future key `labor_pool`, generated from city capacity factors such as population/order/development/facilities/tech and reduced by unrest/war damage.
- Defined policy as national-only accumulated resource with cap, future key `policy_points`, generated from administration/politics/bureaucracy/stability/tech and reduced by corruption/unrest/overextension.
- Recorded usage boundaries: labor for city research/construction/repair/defense projects; policy for national research, law/tax/bureaucracy/diplomacy/spy/decree systems.
- Recorded UI direction, shortage meaning, save/load follow-up requirements, and the follow-up roadmap from save schema draft through F6 QA record.
- Preserved runtime code, gameplay logic, UI behavior, save/load schema, active research payload schema, cost/duration/effect balance values, actual charge logic, gold/food deduction, paid cost state absence, cancel/refund absence, BattleContext, pending invasion schema, scenes, and assets/imports.

## v0.70-89 Labor Policy Resource State Design
- Added `agent/DOMESTIC_TECH_LABOR_POLICY_RESOURCE_DESIGN.md`.
- Locked the v0.70-89 decision that Domestic Tech `labor` and `policy` remain display-only planned costs in the MVP.
- Recorded the future preferred resource ownership and naming: city-only `labor_pool` for labor and national-only `policy_points` for policy.
- Documented deferred implementation requirements for persistent keys, save/load migration, turn production/recovery, UI policy, old-save compatibility, actual charge validation extension, shortage messaging, and F6 manual QA.
- Updated WorldMap and Domestic Tech cost-design docs to preserve the actual charge scope as `gold + food group`, with city food group order `rice -> barley -> seafood`.
- Preserved runtime code, gameplay logic, UI behavior, save/load schema, active research payload schema, cost/duration/effect balance values, actual charge logic, gold/food deduction, paid cost state absence, cancel/refund absence, BattleContext, pending invasion schema, scenes, and assets/imports.

## v0.70-88 Domestic Tech Balance F6 Result Record
- Added the v0.70-88 Domestic Tech Balance F6 Result Record section to the top of `agent/DOMESTIC_TECH_MANUAL_QA.md`.
- Recorded the v0.70-86 balance integration result state as PASS-ready by document/code/headless verification, with Manual F6 follow-up required for actual click/tactile balance confirmation.
- Documented current result lines for Tier 1-3 cost feel, national/city cost-duration feel, Safe Set effect feel, progression feel, actual charge preservation, active payload compatibility, no formula connection, enemy research/effect absence, and Godot Output cleanliness.
- Updated agent docs and WorldMap lock guidance for the result-record scope.
- Preserved `scripts/worldmap_test.gd`, gameplay logic, UI behavior, cost/duration/effect balance values, actual charge logic, deduction amount/order, active payload schema, paid cost state absence, cancel/refund absence, BattleContext, pending invasion schema, scenes, and assets/imports.

## v0.70-87 Domestic Tech Balance F6 QA Record
- Added the v0.70-87 Domestic Tech Balance F6 QA Record section to the top of `agent/DOMESTIC_TECH_MANUAL_QA.md`.
- Documented F6 checks for cost balance, duration balance, Safe Set effect feel, progression feel, preservation locks, Godot Output cleanliness, and PASS / NEEDS FIX recording.
- Added side-effect-free QA-ready flags to Domestic Tech summary helpers in `scripts/worldmap_test.gd`.
- Updated agent docs so the next worker can record the F6 balance QA result after Kimjak tests the v0.70-86 balance integration.
- Preserved gameplay logic, UI behavior, cost/duration/effect balance values, actual charge logic, deduction amount/order, active payload schema, paid cost state absence, cancel/refund absence, BattleContext, pending invasion schema, scenes, and assets/imports.

## v0.70-86 Domestic Tech Balance Integration Pass
- Rebalanced Domestic Tech research cost planning in `scripts/worldmap_test.gd`: national tech now uses heavier gold-centered tier bands, and city tech uses selected-city gold + food bands with economy discounts and military/naval/siege/defense premiums.
- Rebalanced new-research duration by scope and tier: city tech is faster early, while national tech is a slightly longer national project.
- Tuned Safe Set effect values for economy, military/defense, national policy, naval/siege display, and diplomacy/spy display.
- Added balance integration summary flags and a v0.70-86 F6 manual QA section.
- Preserved actual charge logic, deduction order, active payload schema, paid cost state absence, cancel/refund absence, per-turn/completion charge absence, forbidden formula connections, enemy research/effect absence, BattleContext, pending invasion schema, scenes, and assets/imports.

## v0.70-85 Research Cost Affordability F6 UI QA Record
- Added the v0.70-85 Research Cost Affordability F6 UI QA Record section to `agent/DOMESTIC_TECH_MANUAL_QA.md`.
- Documented F6 checks for available/affordable wording, display-only removal, available button text, insufficient wording/button/start blocking/no partial deduction, researching/completed/locked state priority, national/city UI consistency, enemy/unknown no cost UI, and Godot Output cleanliness.
- Added a PASS / NEEDS FIX record template for the v0.70-84 affordability UI polish.
- Preserved gameplay logic, UI behavior, actual charge logic, deduction amount/order, active payload schema, paid cost state absence, cancel/refund absence, BattleContext, pending invasion schema, scenes, and assets/imports.

## v0.70-84 Research Cost Affordability UI Polish
- Updated Domestic Tech actual-charge UI wording in `scripts/worldmap_test.gd`: available/affordable cost copy now uses `필요 비용: ... · 시작 시 차감`.
- Added clearer insufficient-resource UI feedback with `자원이 부족해 연구를 시작할 수 없습니다.` and existing `부족: 금 N / 군량 N` details.
- Shortened action button labels for non-start states to `자원 부족`, `연구 중`, `완료`, and `조건 부족`.
- Added side-effect-free actual charge summary flags for UI wording and state-priority QA.
- Preserved actual charge logic, deduction amount/order, affordability validation logic, research start flow, active payload schema, paid cost state absence, cancel/refund absence, per-turn/completion charge absence, BattleContext, pending invasion schema, tech definitions, scenes, and assets/imports.

## v0.70-83 Domestic Tech Actual Charge F6 Result Record
- Recorded Kimjak's v0.70-82 Domestic Tech actual charge manual QA result as PASS in `agent/DOMESTIC_TECH_MANUAL_QA.md`.
- PASS coverage: National sufficient/insufficient gold, National no per-turn charge, National no completion charge, City sufficient gold/food, City insufficient gold, City insufficient food, City food deduction order, Other city unchanged, Existing active no retroactive charge, Active payload schema unchanged, Enemy/unknown no research/effect, and Godot Output clean.
- Preserved gameplay logic, research start flow, resource deduction logic, UI layout, scenes, save/load schema, active payload schema, paid cost state absence, cancel/refund absence, enemy research/effect absence, BattleContext, pending invasion schema, tech definitions, and assets/imports.

## v0.70-82 Domestic Tech Actual Charge Manual QA
- Added the v0.70-82 Domestic Tech actual charge F6 manual QA checklist to the top of `agent/DOMESTIC_TECH_MANUAL_QA.md`.
- Covered actual charge QA for National Tech, City Tech, existing active compatibility, no extra charge, preservation areas, Godot Output, and PASS / NEEDS FIX result recording.
- Added side-effect-free QA alias flags to `_get_domestic_tech_research_actual_charge_summary_mvp()` for start-time charge, no per-turn/completion charge, city food group order, national/city gold charge, city food group charge, labor/policy skipped, and partial deduction false.
- Preserved gameplay logic, research start flow, resource deduction logic, UI layout, scenes, save/load schema, active payload schema, paid cost state absence, cancel/refund absence, enemy research/effect absence, BattleContext, pending invasion schema, tech definitions, and assets/imports.

## v0.70-81 Domestic Tech Research Cost Actual Charge MVP
- Implemented Domestic Tech actual research cost charging at research start in `scripts/worldmap_test.gd`.
- Added actual charge plan, validation, application, shortage formatting, and QA summary helpers.
- National tech now charges implemented PLAYER national `gold`; city tech charges selected PLAYER city storage `gold` and food group.
- Food group uses `rice`, `barley`, and `seafood` with deduction order `rice -> barley -> seafood`; insufficient implemented resources block research start with no deduction and no active research creation.
- Updated UI wording from display-only expected cost to `필요 비용 ... · 시작 시 차감`, with shortage copy `부족: 금 N / 군량 N`.
- Updated `_get_domestic_tech_research_actual_charge_design_mvp()` to reflect implemented MVP state.
- Preserved no active payload schema change, no paid cost state, no retroactive charge, no per-turn charge, no completion charge, no cancel/refund, no enemy research/effect, no BattleContext or pending invasion schema change, no tech definition change, and no asset/import change.

## v0.70-80 Domestic Tech Research Cost Actual Charge Design Draft
- Built on `v0.70-79 Domestic Tech Actual F6 QA Result Record` (`4a939a49b33aedb6c0e309dba47cdcdd2f42d02e`).
- Added `agent/DOMESTIC_TECH_RESEARCH_COST_DESIGN.md` as the design draft for future Domestic Tech actual research cost charging.
- Fixed the recommended actual charge timing as one-time upfront charge on research start.
- Recorded out-of-scope timing and systems: per-turn charge, charge on completion, ongoing upkeep, cancel/refund, paid cost state, and retroactive charge for existing active research.
- Recorded planned affordability behavior for future implementation: check resource availability at research start, block only new starts if implemented resources are insufficient, report missing resources, and leave existing active research untouched.
- Recorded national/city resource scope design and the need to map display labels to real state keys before implementation, especially `군량` versus `rice`/`barley`/`seafood`.
- Added `_get_domestic_tech_research_actual_charge_design_mvp()` as a side-effect-free design helper with `design_draft_only = true`, `actual_charge_implemented = false`, and `gameplay_mutation = false`.
- Updated agent docs with v0.70-80 locks and v0.70-81 implementation candidates.
- Modified files: `agent/DOMESTIC_TECH_RESEARCH_COST_DESIGN.md`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual cost deduction, actual cost gating, actual affordability check, paid cost state, cancel/refund, active research payload schema changes, research slot changes, enemy research/effects, BattleContext changes, pending invasion schema changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-79 Domestic Tech Actual F6 QA Result Record
- Built on `v0.70-78 Domestic Tech Actual Manual QA Pass` (`702d6054f3ebab8f9754fa9283663c6ffb0de4cf`).
- Recorded the actual F6 QA result for Domestic Tech 1st-pass applied-state verification as `PASS`.
- Added the official result block to `agent/DOMESTIC_TECH_MANUAL_QA.md` with tester `김작`, date `2026-07-07`, result `PASS`, and base commit `702d6054f3ebab8f9754fa9283663c6ffb0de4cf`.
- Recorded user confirmation: "실제로 해봤어 잘됨".
- Confirmed at record scope that the early Grace Turns made testing possible, Domestic Tech Tree entry worked, national/city research flow could be checked, research progress/completion flow was normal, expected cost stayed display-only, no cost deduction/gating was observed, UI64/click/overlay flow was normal, and no new blocking issue was reported.
- Locked the PASS scope as Domestic Tech 1차 F6 QA PASS, not final balance completion.
- No gameplay mutation was made. No cost charge/gating, enemy research/effect, BattleContext change, pending invasion schema mutation, tech definition change, asset/icon/UI64/import change, battle/diplomacy/spy/market/city_intel/AI formula connection, or troop/ship/siege count mutation was added.
- Modified files: `agent/DOMESTIC_TECH_MANUAL_QA.md`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.

## v0.70-78 Domestic Tech Actual Manual QA Pass
- Built on `v0.70-76-hotfix1 Manual QA Grace Turns QA Polish` (`39c27de2e1fa074e522facaf5a147759a298ffb6`).
- Fixed `agent/DOMESTIC_TECH_MANUAL_QA.md` as the canonical Actual Manual QA Pass document for F6 Domestic Tech 1st-pass applied-state verification.
- Added explicit QA coverage for F6 pre-checks, turn 1-10 invasion grace, national research start/progress/completion, city research start/progress/completion, Safe Set effects, expected cost display-only, enemy/unknown no-display, UI64/click/overlay lifecycle, Godot Output warning cleanliness, and PASS / NEEDS FIX result recording.
- Added `_get_domestic_tech_actual_manual_qa_pass_mvp()` as a side-effect-free QA/debug helper with required QA flags and `gameplay_mutation = false`.
- Updated agent docs for the new version, preserved locks, and next candidates: `v0.70-78-hotfix1 Actual Manual QA Doc Polish` or `v0.70-79 Domestic Tech Actual F6 QA Fix Pass`.
- Modified files: `scripts/worldmap_test.gd`, `agent/DOMESTIC_TECH_MANUAL_QA.md`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual cost deduction, cost-based research blocking, affordability checks, paid-cost state, extra research slots, enemy research/effects, battle/diplomacy/spy/market/city_intel/AI formula changes, troop/ship/siege count mutation, BattleContext changes, pending invasion schema changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-76-hotfix1 Manual QA Grace Turns QA Polish
- Built on `v0.70-76 Domestic Tech Manual QA Grace Turns` (`ab8ed193016e31046dd1d722ccc911a9ddc7a000`).
- Clarified the manual QA grace boundary as 1-based turns 1-10 blocked and turn 11+ restored to existing invasion/pressure creation logic.
- Reconfirmed guard scope for new pending invasion creation, enemy pressure plan creation, and strategic pressure follow-up creation without changing turn progress, Domestic Tech research progress, income, or UI refresh.
- Expanded `_get_manual_qa_grace_summary_mvp()` with boundary, pending invasion creation, enemy pressure, strategic follow-up, existing pending invasion deletion, income, UI refresh, BattleContext, pending invasion schema, and enemy AI global-disable QA flags.
- Updated agent docs and the Domestic Tech manual QA document to state that existing pending invasions are not deleted or rewritten by the grace.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`, and `agent/DOMESTIC_TECH_MANUAL_QA.md`.
- Did not change BattleContext structure, pending invasion schema, existing pending invasion cleanup behavior, enemy AI globally, Domestic Tech research/effect/cost logic, cost display-only/no charge/no gating flags, Safe Sets, enemy tech/research/effects, tech definitions, assets, icon PNGs, UI64 PNGs, or `.import` files.

## v0.70-76 Domestic Tech Manual QA Grace Turns
- Built on local `v0.70-76 Domestic Tech Manual QA Scenario Pack` (`f259e56e9298bbfc067bd6647c3407144a03c6d2`) and the requested `v0.70-75-hotfix1 Cost Display QA Polish` baseline (`8a50087de9d1b4f720cb91d32255960e5a6df585`).
- Added `MANUAL_QA_NO_INVASION_GRACE_TURNS = 10` for Domestic Tech F6 manual QA.
- Added `_is_manual_qa_invasion_grace_turn_active_mvp()` and `_get_manual_qa_grace_summary_mvp()` as side-effect-free QA helpers.
- Blocked new enemy pending invasion creation, enemy pressure plan creation, and enemy strategic follow-up pressure creation during turns 1-10; turn 11 and later return to the existing logic.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`, and `agent/DOMESTIC_TECH_MANUAL_QA.md`.
- Did not change BattleContext structure, pending invasion schema, turn progress, Domestic Tech research/effect/cost logic, cost display-only/no charge/no gating flags, Safe Sets, enemy tech/research/effects, enemy AI globally, tech definitions, assets, icon PNGs, UI64 PNGs, or `.import` files.

## v0.70-76 Domestic Tech Manual QA Scenario Pack
- Built on `v0.70-75-hotfix1 Cost Display QA Polish` (`8a50087de9d1b4f720cb91d32255960e5a6df585`).
- Added `agent/DOMESTIC_TECH_MANUAL_QA.md` with followable F6 scenarios for national research start/progress/completion, city research start/progress/completion, completion refresh, same-city only, enemy/unknown/insufficient-intel no-display, Safe Set effects, cost display-only, no charge, no gating, UI64 icons, node click latency, overlay lifecycle, warning cleanliness, and result recording.
- Added `_get_domestic_tech_manual_qa_scenario_pack_mvp()` as a side-effect-free QA helper with scenario flags, Safe Set/UI check lists, and forbidden mutation counters fixed at 0.
- Updated agent docs to point the next worker at the manual QA pack and the next candidates.
- Modified files: `scripts/worldmap_test.gd`, `agent/DOMESTIC_TECH_MANUAL_QA.md`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement research cost deduction, cost-based gating, affordability checks, paid-cost state, reservation/refund/cancel flow, extra research slots, enemy research/effects, battle/diplomacy/spy/market/city_intel/AI formula changes, troop/ship/siege count mutation, BattleContext changes, pending invasion changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-75-hotfix1 Cost Display QA Polish
- Built on `v0.70-75 Research Cost Display Safe Set` (`8b29e26f0aa304fcd2ad39ae805e2d719fd81b0a`).
- Hardened `_format_domestic_tech_research_cost_display_mvp()` so negative or malformed planned resource values are clamped out of visible cost display.
- Preserved compact display-only wording as `예상 비용 ... · 표시 전용` and kept resource order/labels as `금`, `군량`, `노역`, and `정책`.
- Kept state-specific Domestic Tech inspector display unchanged in behavior: completed hides cost, researching prioritizes turns, available shows duration plus expected cost, and locked/blocked states avoid cost-shortage copy.
- Added `state_specific_cost_display = true` and explicit `cost_charged = false` to `_get_domestic_tech_research_cost_display_summary_mvp()`.
- Kept research balance summary aligned with display-only, no charge, no gating, no paid state, no affordability check, unchanged active/completion flow, and enemy research disabled.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual research cost application, cost-based research blocking, affordability checks, paid-cost state, reservation/refund/cancel flow, battle modifiers, diplomacy success modifiers, spy success modifiers, relation mutation, city_intel visibility changes, market/trade modifiers, AI behavior, enemy research/effects, troop/ship/siege count mutation, BattleContext changes, pending invasion changes, tech id/name/category/branch/prerequisite changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-75 Research Cost Display Safe Set
- Built on `v0.70-74-hotfix1 Cost & Research Balance QA Polish` (`1c96397956f164ef9bc41a3c7c0d5bcff0caf6e5`).
- Added `_format_domestic_tech_research_cost_display_mvp()` to unify Domestic Tech expected-cost display formatting.
- Kept national and city expected-cost display separated by scope and tier, with national gold-only values and city gold/food values.
- Standardized display order and labels for gold/food/labor/policy as `금` / `군량` / `노역` / `정책`; zero values are hidden and zero-cost output remains marked display-only.
- Tightened Domestic Tech inspector research lines by state: completed hides cost, researching prioritizes remaining/total turns, available shows duration plus expected cost, and locked/blocked states avoid cost-shortage copy.
- Added `_get_domestic_tech_research_cost_display_summary_mvp()` and aligned research balance summary flags for display-only, no charge, no start blocking, no paid state, and no affordability check.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual research cost application, cost-based research blocking, paid-cost state, reservation/refund/cancel flow, battle modifiers, diplomacy success modifiers, spy success modifiers, relation mutation, city_intel visibility changes, market/trade modifiers, AI behavior, enemy research/effects, troop/ship/siege count mutation, BattleContext changes, pending invasion changes, tech id/name/category/branch/prerequisite changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-74-hotfix1 Cost & Research Balance QA Polish
- Built on `v0.70-74 Domestic Tech Cost & Research Balance Planning` (`7793082118f6924349e534cc68b9376018421e1f`).
- Polished Domestic Tech inspector research display by state: completed hides expected cost, researching prioritizes remaining/total turns, available shows compact display-only expected cost, and locked/blocked states avoid cost-gating copy.
- Added cost safety flags for completion-time cost application and paid-state persistence to the cost plan and research balance summary helpers.
- Strengthened active research duration compatibility so missing/malformed stored duration cannot shorten an existing positive `remaining_turns` under the new tier fallback.
- Honored explicit positive `duration_turns` on a tech definition before using duration hint and tier fallback.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual research cost application, cost-based research blocking, paid-cost state, reservation/refund/cancel flow, battle modifiers, diplomacy success modifiers, spy success modifiers, relation mutation, city_intel visibility changes, market/trade modifiers, AI behavior, enemy research/effects, troop/ship/siege count mutation, BattleContext changes, pending invasion changes, tech id/name/category/branch/prerequisite changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-74 Domestic Tech Cost & Research Balance Planning
- Built on `v0.70-73-hotfix1 Domestic Tech Final Manual QA Polish` (`fd4e6599433904c706a2d6c46f6439f94b0bab90`).
- Added tier-based Domestic Tech duration planning for new research: Tier 1 = 2 turns, Tier 2 = 3, Tier 3 = 4, Tier 4 = 5, Tier 5 = 6.
- Preserved existing active research compatibility by keeping stored `duration_turns` values when they are above the new fallback and clamping `remaining_turns` within that stored duration.
- Added display-only research cost planning helper with planned national/city costs and all cost application/blocking flags set false.
- Updated Domestic Tech inspector display to show `연구 소요` plus `예상 비용 ... (표시 전용)` instead of presenting cost as an active requirement.
- Added `_get_domestic_tech_research_balance_summary_mvp()` for no-spam QA confirmation of duration rules, display-only cost planning, unchanged research flow, and enemy research disabled.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual research cost application, cost-based research blocking, paid-cost state, battle modifiers, diplomacy success modifiers, spy success modifiers, relation mutation, city_intel visibility changes, market/trade modifiers, AI behavior, enemy research/effects, troop/ship/siege count mutation, BattleContext changes, pending invasion changes, tech id/name/category/branch/prerequisite changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-73-hotfix1 Domestic Tech Final Manual QA Polish
- Built on `v0.70-73 Domestic Tech Full Effect Integration QA & Balance Pass` (`6c74bc5c9ddfdebb1aef7ebf63b60ec78fa94a9f`).
- Added a shared compact source-tech display helper with unique source names, empty-source hiding, and `외 N개` overflow.
- Hid zero-value economy turn summary entries and kept empty city spy/intel mapping from producing false city-detail sections.
- Reworded display-safe military/defense, national policy, naval/siege, and diplomacy/spy UI copy to preparation/base/readiness language.
- Added focused research-completion display refresh for left national panel, selected PLAYER city detail, and Domestic Tech inspector.
- Extended `_get_domestic_tech_full_effect_integration_summary_mvp()` with `empty_mapping_false_display = false`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement battle modifiers, diplomacy success modifiers, spy success modifiers, relation mutation, city_intel visibility changes, spy detection/action result changes, market/trade modifiers, enemy intel reveal, AI diplomacy/spy behavior, enemy tech effects, troop/ship/siege count mutation, BattleContext changes, pending invasion changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-73 Domestic Tech Full Effect Integration QA & Balance Pass
- Built on `v0.70-72-hotfix1 Diplomacy/Spy Display Effect QA Polish` (`38eb5fc9e9bf39a99358e7551ff8c566eaf98f04`).
- Added `_get_domestic_tech_full_effect_integration_summary_mvp()` as a one-stop QA dictionary for the first Domestic Tech Safe Set stack.
- Consolidated completed-only, researching no-effect, PLAYER-only, same-city-only, non-persistence, source uniqueness, tax-once, empty city spy/intel no-display, and forbidden mutation zero counters.
- Normalized economy, military/defense, and national policy `source_techs` before helper return to keep output consistent with naval/siege and diplomacy/spy helpers.
- Polished effect display section titles and kept zero values, empty mappings, and empty source sections hidden.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement battle modifiers, diplomacy success modifiers, spy success modifiers, relation mutation, city_intel visibility changes, spy detection/action result changes, market/trade modifiers, enemy intel reveal, AI diplomacy/spy behavior, enemy tech effects, troop/ship/siege count mutation, BattleContext changes, pending invasion changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-72-hotfix1 Diplomacy/Spy Display Effect QA Polish
- Built on `v0.70-72 Domestic Tech Diplomacy/Spy Display Safe Set` (`23b90f4cf0f27bd7d9123a9504f96f05ebd7a2b3`).
- Reconfirmed PLAYER completed national tech only diplomacy/spy display helper behavior with unique source techs, no researching/incomplete effects, and no persisted computed bonus state.
- Added explicit empty Safe Set guards to the city spy/intel helper and city spy/intel display formatter so the current empty city mapping produces no local effects and no false city-detail section.
- Extended QA summary helpers with city spy/intel source uniqueness, empty mapping status, and empty mapping no-display flags.
- Kept left national panel, Domestic Tech inspector, and selected PLAYER city detail aligned with helper output and preparation/readiness wording.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement diplomacy success modifiers, spy success modifiers, relation mutation, city_intel visibility changes, spy detection/action result changes, enemy intel reveal, AI diplomacy/spy behavior, enemy tech effects, BattleContext changes, pending invasion changes, market/trade formula changes, battle/troop/naval/siege formula changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-72 Domestic Tech Diplomacy/Spy Display Safe Set
- Built on `v0.70-71-hotfix1 Naval/Siege Display Effect QA Polish` (`4a0e2983781bd82e2053a6d6d2903c4d14e2d066`).
- Added a PLAYER completed national tech diplomacy/spy display helper that is side-effect free, ignores researching/incomplete tech, de-duplicates source techs, and never saves computed bonus state.
- Added Safe Set values for existing envoy, diplomacy system, tribute system/network, world diplomacy, centralization, bureaucracy, intelligence system/org, and inspection system ids.
- Added a PLAYER-city same-city city spy/intel helper with an empty current mapping because no city spy/intel tech definitions exist yet.
- Added left national panel and Domestic Tech inspector display for diplomacy/spy readiness and source tech names without actual success-rate wording.
- Extended QA summary helpers with diplomacy/spy display counters and `diplomacy_success_effects_applied = 0`, `spy_success_effects_applied = 0`, `relation_effects_applied = 0`, `city_intel_effects_applied = 0`, and `enemy_effects_applied = 0`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement diplomacy success modifiers, spy success modifiers, relation mutation, city_intel visibility changes, enemy intel reveal, spy action result changes, AI diplomacy/spy behavior, enemy tech effects, BattleContext changes, pending invasion changes, market/trade formula changes, battle/troop/naval/siege formula changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-71-hotfix1 Naval/Siege Display Effect QA Polish
- Built on `v0.70-71 Domestic Tech Naval/Siege Display Safe Set` (`2f3ddf3652f2527fd9c47d8f2bafaec6cd9e6771`).
- Strengthened the naval/siege display helper to use one normalized same-city completed tech map and completed `true` Safe Set ids only.
- Kept researching/incomplete/false/missing/malformed/other-city/enemy/non-player state from producing naval/siege display effects.
- Kept computed naval/siege bonus non-persistent and source tech ids unique in helper output, UI display, and QA summary checks.
- Polished naval/siege source display copy so city detail and Domestic Tech inspector sections remain distinguishable from economy/military source lines.
- Extended QA summary helpers with `researching_has_naval_siege_effect = false`, `display_safe_only = true`, and `source_techs_unique` while preserving `ship_count_effects_applied = 0`, `siege_weapon_count_effects_applied = 0`, `battle_effects_applied = 0`, and `enemy_effects_applied = 0`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual naval/siege battle modifiers, ship count changes, siege weapon count changes, troop stat/count changes, BattleContext changes, pending invasion changes, diplomacy/spy/market/trade effects, national policy expansion, AI research, enemy research/effect, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-71 Domestic Tech Naval/Siege Display Safe Set
- Built on `v0.70-70-hotfix1 National Policy Effect QA Polish` (`4bde6a04f54eafff883ea0a9044c4539b0936d17`).
- Added a PLAYER-city-only naval/siege display bonus helper based on completed city techs; no derived bonus state is saved.
- Added display Safe Set mapping for existing shipyard/naval/siege tech ids only.
- Added selected PLAYER city naval/siege preparation bonus/source display to city detail and Domestic Tech inspector.
- Added effect-status copy for naval/siege Safe Set techs without connecting to actual battle formulas.
- Extended QA summary helpers with naval/siege display counts, `ship_count_effects_applied = 0`, `siege_weapon_count_effects_applied = 0`, `battle_effects_applied = 0`, and `enemy_effects_applied = 0`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual naval/siege battle modifiers, ship count changes, siege weapon count changes, troop stat/count changes, BattleContext changes, pending invasion changes, diplomacy/spy/market/trade effects, national policy expansion, AI research, enemy research/effect, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-70-hotfix1 National Policy Effect QA Polish
- Built on `v0.70-70 Domestic Tech National Policy Effects Safe Set` (`51d8cbb41a5b14ee712bdccdaf291b8b1a6eeb32`).
- Strengthened national policy bonus derivation to use one normalized completed national tech map per helper call and apply only completed `true` Safe Set ids.
- Kept researching/incomplete national techs, malformed completed state, enemy state, and non-player state from producing policy effects.
- Removed duplicate display-time policy helper recomputation so left national panel and Domestic Tech inspector stay aligned with the same helper result.
- Kept source national tech display unique and compacted.
- Kept `tax_gold_percent` connected once to PLAYER city gold income, clamped national tax percent to non-negative, and preserved the existing final gold `0+` clamp.
- Extended QA summary helpers with `national_completed_only`, `researching_has_policy_effect = false`, `tax_gold_applied_once = true`, and `source_techs_unique` while preserving zero battle, troop stat/count, diplomacy, spy, market, and enemy counters.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement new national policy scope, enemy national effects, AI research, diplomacy/spy/market formula changes, battle formula changes, troop stat changes, troop count changes, BattleContext changes, pending invasion changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-70 Domestic Tech National Policy Effects Safe Set
- Built on `v0.70-69-hotfix1 Military/Defense Effect QA Polish` (`12cf490dea2703976a2b5550d58b3727fafe6798`).
- Added a PLAYER completed national tech policy helper that is side-effect free, ignores researching/incomplete tech, de-duplicates source techs, and never saves computed bonus state.
- Added Safe Set values for law reform, bureaucracy, centralization, tax reform, conscription, logistics system, population policy, foundation storage, and national monopoly.
- Connected `tax_gold_percent` minimally to PLAYER city gold income through the existing Domestic Tech economy path with final `0+` clamp.
- Kept admin, recruit, logistics, population, law/order, and storage values as display/preparation/QA effects.
- Added left national panel and Domestic Tech inspector display for active national policy bonus lines and source national tech names.
- Extended QA summary helpers with national policy counters and zero counters for battle, troop stat/count, diplomacy, spy, market, and enemy effects.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement enemy national effects, AI research, diplomacy/spy/market formula changes, battle formula changes, troop stat changes, troop count changes, BattleContext changes, pending invasion changes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-69-hotfix1 Military/Defense Effect QA Polish
- Built on `v0.70-69 Domestic Tech Military/Defense Effects Safe Set` (`ed7bb437b6408e227639a71b317a57868caf405a`).
- Reconfirmed military/defense bonus derivation as PLAYER-city-only, same-city-only, completed-city-tech-only, and non-persistent.
- Stabilized city defense display clamp/order as percent then flat bonus with final `0+` clamp.
- Kept city detail and Domestic Tech inspector military/defense display aligned with helper output and hidden for enemy/non-player cities.
- Extended QA summary helpers with `completed_city_tech_only`, `player_city_only`, `troop_stat_effects_applied = 0`, and `troop_count_effects_applied = 0` while preserving `battle_effects_applied = 0` and `enemy_effects_applied = 0`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement battle modifiers, troop stat changes, troop count changes, automatic recruitment, BattleContext changes, pending invasion changes, diplomacy/spy/market/trade effects, national policy numeric effects, AI research, enemy research/effect, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-69 Domestic Tech Military/Defense Effects Safe Set
- Built on `v0.70-68-hotfix1 Domestic Tech Economy Effect QA Polish` (`5eeda382054c52885420f60e934a2de6cd59fc22`).
- Added a PLAYER-city-only Domestic Tech military/defense bonus helper based on completed city techs; no derived bonus state is saved.
- Added Safe Set values for recruitment capacity display, infantry/archer/cavalry training display, and city defense display.
- Added selected PLAYER city military/defense bonus/source display to city detail and Domestic Tech inspector.
- Added a display-only city defense value helper for minimum city-detail connection without touching battle formulas.
- Extended internal QA summary helpers with city defense and training display counts while keeping `battle_effects_applied = 0` and `enemy_effects_applied = 0`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement battle modifiers, troop stat changes, troop count changes, automatic recruitment, BattleContext changes, pending invasion changes, diplomacy/spy/market/trade effects, national policy numeric effects, AI research, enemy research/effect, naval numeric effects, siege numeric effects, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-68-hotfix1 Domestic Tech Economy Effect QA Polish
- Built on `v0.70-68 Domestic Tech Numeric Effects Phase 1 - Economy Safe Set` (`1fc67e044fa02c56f8a00a7f680b3b734a88eae1`).
- Strengthened the Domestic Tech economy helper with explicit city-scope, agri/fish/commerce, PLAYER city, completed-only, and same-city guards.
- De-duplicated source tech ids so helper output, UI display, turn summary, and QA counts cannot show the same source twice.
- Kept economy bonus derived from completed tech state each time; no computed bonus state is saved.
- Consolidated food/gold numeric application through a non-negative clamp helper.
- Added a Domestic Tech economy bonus line to the domestic turn summary without storing structured computed bonus state.
- Extended QA summary helpers with agri/fish/commerce counts, `market_effects_applied = 0`, `same_city_only = true`, `researching_has_effect = false`, and `bonus_state_persisted = false`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement new economy categories, combat/troop/battle/diplomacy/spy/market effects, national policy numeric effects, resource payment, AI research, enemy research/effect, BattleContext changes, pending invasion changes, scenes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-68 Domestic Tech Numeric Effects Phase 1 - Economy Safe Set
- Built on `v0.70-67-hotfix1 Domestic Tech Effect Phase 1 QA Polish` (`8a9067339802bd28fecbdae810ab9ff8f7f69f91`).
- Added a PLAYER-city-only Domestic Tech economy bonus helper based on completed city techs; no derived bonus state is saved.
- Added agri/fish/commerce Safe Set mapping for small food, gold, and display-level supply bonuses.
- Hooked completed city tech food/gold bonuses into the existing player domestic income path with per-city ownership and completed-state guards.
- Added selected city economy bonus/source display to city detail and Domestic Tech inspector.
- Extended internal QA summary helpers with numeric economy effect counts and combat/diplomacy/spy/enemy effect counters fixed at 0.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement combat/troop/battle/diplomacy/spy/market effects, national policy numeric effects, resource payment, AI research, enemy research/effect, BattleContext changes, pending invasion changes, scenes, tech definition changes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-67-hotfix1 Domestic Tech Effect Phase 1 QA Polish
- Built on `v0.70-67 Domestic Tech Actual Effects Phase 1` (`4a4632b36f132fdae58f3fb98300a3128ba4bedf`).
- Stabilized required-national condition display around completed, researching, and incomplete states while preserving completed-only logic.
- Stabilized same-city city prerequisite display so researching city tech and other-city completions are not presented as fulfilled prerequisites.
- Polished unlock/enhance relation copy to use compact tech-name status lines and avoid actual numeric-effect wording.
- Polished `effect_stub` display copy into effect status/readiness, unlock status, and later-version numeric-effect deferral.
- Extended the internal no-spam Phase 1 summary helper with required-national checks, city prerequisite checks, `researching_treated_as_completed = false`, and `enemy_effects_applied = 0`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement resource payment, numeric Domestic Tech effects, resource/income/troop/battle/diplomacy/spy/market formula changes, AI research, enemy research/effect, BattleContext changes, pending invasion changes, scenes, assets, tech definition changes, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-67 Domestic Tech Actual Effects Phase 1
- Built on `v0.70-66-hotfix1 Domestic Tech Research QA & Completion Polish` (`c2f8d7d217c1b17cd9b9eefd67358cb5a6c1fd3a`).
- Added explicit completed-only required national tech helper coverage for city tech unlock checks.
- Preserved same-city completed city tech prerequisite behavior for follow-up city tech availability.
- Improved Domestic Tech inspector relation display so unlock/enhance links show completed-state statuses instead of generic relation suffixes.
- Reworked `effect_stub` inspector copy into effect description plus Phase 1 application-readiness status.
- Added an internal no-spam Phase 1 summary helper that reports completed counts, unlock-ready count, and `numeric_effects_applied = 0`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement resource payment, numeric Domestic Tech effects, resource/income/troop/battle/diplomacy/spy/market formula changes, AI research, enemy research/effect, BattleContext changes, pending invasion changes, scenes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-66-hotfix1 Domestic Tech Research QA & Completion Polish
- Built on `v0.70-66 Domestic Tech Research Progress & Completion MVP` (`1f9bb843ced5730483867ac546f4b208df0347b2`).
- Strengthened active research normalize for national and PLAYER city Domestic Tech Tree research.
- Normalized national and city completed state from missing/null/list-shaped data into Dictionary-shaped completed state where possible.
- Clamped research turn decrement to `remaining_turns = max(0, remaining_turns - 1)`.
- Added guards so already-completed active research clears without duplicate completion notifications.
- Synced per-city `city_tech.completed` mirror from `_player_state["city_domestic_tech_completed"]` while keeping city completed state separated.
- Preserved completed-only prerequisite recognition; active/researching techs are not treated as completed.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual Domestic Tech effects, resource payment, AI research, enemy research, formula changes, BattleContext changes, pending invasion changes, scenes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-66 Domestic Tech Research Progress & Completion MVP
- Built on `v0.70-65 Domestic Tech Research Start MVP` (`c27e46034684a0385f76bf3816f22a71c76eda2a` locally at task start, matching `origin/main`).
- Added PLAYER Domestic Tech Tree research progression during the existing world domestic turn apply flow.
- National active research now decrements `remaining_turns`, completes at 0 or below, records `_player_state["national_domestic_tech_completed"][tech_id] = true`, and clears the active national research slot.
- PLAYER city active research now decrements independently per city, completes at 0 or below, records that city's completed state, mirrors the completed id into that city's `city_tech.completed`, and clears only that city's active research.
- Completed Domestic Tech Tree techs are recognized by existing prerequisite and `required_national_techs` checks; active/researching techs are not treated as completed.
- Added completion summary messages for national and city research and refreshes the open tech overlay after completion.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement actual Domestic Tech effects, resource payment, AI research, enemy research, formula changes, BattleContext changes, pending invasion changes, scenes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-65 Domestic Tech Research Start MVP
- Built on `v0.70-64 Domestic Tech Research Readiness Layer` (`d442f1ee1d414a7cdb11e57d93ba46f625815b37`).
- Added national active research state under `_player_state["national_tech_research"]["active"]`, limited to one active national domestic tech.
- Added per-city active research state under `city_data["city_tech"]["research"]["active"]`, limited to one active city domestic tech per player city.
- Enabled the research action button only when the selected tech is available, player-scoped, and not blocked by existing active research.
- Added `researching` view state, node status/style, inspector copy, and remaining/total duration display.
- Stored `tech_id`, `started_turn`, `remaining_turns`, and `duration_turns` on research start.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement resource payment, turn countdown, research completion, completed-tech mutation, actual effects, AI research, formula changes, BattleContext changes, pending invasion changes, scenes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-64 Domestic Tech Research Readiness Layer
- Built on `v0.70-63-hotfix6 Domestic Tech Tree Final UI QA & Overlay Lifecycle Polish` (`53908b8a8e752ace989049e637dc9d7ef75d98db`).
- Reworked the Domestic Tech Tree detail inspector into a research-readiness display for selected techs.
- Added state-specific readiness copy for completed, available, locked, and special-locked techs.
- Added a visible disabled `연구 시작` action slot with no pressed signal and no research execution path.
- Improved display-only condition formatting for prerequisites, required national techs, city requirements, special requirements, governor/chancellor aptitudes, resource conditions, and hero flags.
- Added display-only national/city relation lines for unlocks, enhancements, required national techs, and enhanced-by national techs.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement research start/progress/completion, queues, resource payment, completed-tech mutation, actual effects, AI research, formula changes, BattleContext changes, pending invasion changes, scenes, assets, icon PNG changes, UI64 PNG changes, or `.import` changes.

## v0.70-63-hotfix6 Domestic Tech Tree Final UI QA & Overlay Lifecycle Polish
- Built on `v0.70-63-hotfix5 Domestic Tech Tree UI64 Icon Binding` (`77eb052f844251141d9181caf1f7fee55e586c57`).
- Audited the tech tree button creation, `pressed` signal binding, overlay open path, close button path, and ESC close path.
- Confirmed overlay reuse and child cleanup prevent duplicate overlay creation and repeated child accumulation.
- Confirmed hidden panel save/restore, modal top-layer, mouse/input consumption, and background input guard remain in place.
- Confirmed hotfix4 detail inspector latency fix remains: node click does not call full overlay/graph rebuild.
- Confirmed hotfix5 UI64 icon coverage remains complete for all current domestic definitions, with `etc/` unmapped and old typo filenames unused.
- Modified files: `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change runtime code, research behavior, actual effects, AI, formulas, BattleContext, pending invasion, scenes, assets, existing icon PNGs, UI64 PNGs, `.import` files, or thumbnail generation.

## v0.70-63-hotfix5 Domestic Tech Tree UI64 Icon Binding
- Built on `v0.70-63-hotfix4 Domestic Tech Tree Click Latency & Icon Readability Polish` plus the `assets/ui/tech_icons_ui64/` asset commit (`95752d17602514b334aa00d8f43f37dea4cff66d`).
- Added `DOMESTIC_TECH_UI64_ICON_ROOT` and an explicit tech_id to UI64 filename map for all current domestic city/national tech definitions.
- Added resolved icon path selection that checks UI64 first, existing definition `icon_path` second, and the existing `?` fallback last.
- Added path-based texture caching for Domestic Tech Tree icons.
- Covered prior missing/typo icon cases with UI64 files, including `agri_granary_zone`, `naval_panokseon`, `nation_national_monopoly`, and `nation_tribute_system`.
- Confirmed `assets/ui/tech_icons_ui64/etc/` is not mapped.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement research start/progress/completion, actual effects, AI research, formulas, BattleContext changes, pending invasion changes, scene changes, asset changes, existing `assets/ui/tech_icons` PNG changes, `.import` changes, or thumbnail generation.

## v0.70-63-hotfix4 Domestic Tech Tree Click Latency & Icon Readability Polish
- Built on `v0.70-63-hotfix3 Domestic Tech Tree Node Text Restore & Click Responsiveness Fix` (`dfc48edbcd3d69eb77d1d041ca5731f95b0b5785`).
- Removed the full tech tree overlay rebuild from compact node click selection.
- Added lightweight selected-node style updates using compact node root references keyed by selected city/tech.
- Kept detail inspector refresh immediate on click without recreating graphs, lines, nodes, or icon controls.
- Increased compact graph icon UI display to fixed integer `64px` and tuned `TextureRect` sizing/filter settings.
- Adjusted compact node size and graph spacing globally to keep title/status visible and avoid overlap after the icon increase.
- Did not implement research start/progress/completion, actual effects, AI research, formulas, BattleContext changes, pending invasion changes, scene changes, icon PNG changes, `.import` changes, or new thumbnail assets.

## v0.70-63-hotfix3 Domestic Tech Tree Node Text Restore & Click Responsiveness Fix
- Built on `v0.70-63-hotfix2 Domestic Tech Tree Global Graph Spacing & Node Size Polish` (`32f92d2559f1dbbcafa84ffe4bad62cb4c2379e4`).
- Restored compact graph node text visibility so each node shows icon or `?`, tech name, rarity `★` when present, and short state.
- Kept cost, effect, duration, prerequisite, national requirement, special condition, and lock reason details out of the node and in the detail inspector.
- Improved whole-card click responsiveness by keeping the compact node root as the input target and making child icon/text/layout controls ignore mouse input.
- Improved city graph overlap handling by reserving extra branch row height for same-tier stacks in the global graph layout helper.
- Removed developer-facing tech overlay copy and changed the title to `EASTWAR 테크트리`.
- Retuned compact graph icon display size through fixed integer UI sizing only.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement research start/progress/completion, actual effects, AI research, Enemy Strategic AI Phase 2, War Posture, BattleContext changes, pending invasion payload changes, income/resource/troop/battle/diplomacy/spy formula changes, scene changes, `assets/ui/tech_icons` PNG changes, or `.import` changes.

## v0.70-63-hotfix2 Domestic Tech Tree Global Graph Spacing & Node Size Polish
- Built on `v0.70-63-hotfix1 Compact Tech Node & Detail Inspector Polish` (`6b22491fcec45836271f14f5b837f64b09ca2f06`).
- Applied global national/city category section spacing for the fullscreen read-only Domestic Tech Tree graph.
- Increased category title/description to first branch row spacing, branch row vertical rhythm, and next-category separation without per-category hardcoding.
- Rebalanced compact graph nodes to one fixed smaller card size with tighter internal margins and less lower empty space.
- Increased compact graph icon display size through UI sizing only and kept `?` fallback inside the same icon area.
- Added display-only Korean branch label mappings for raw branch keys including `inspection`, `population`, `monopoly`, and `archer`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement research start/progress/completion, actual effects, AI research, Enemy Strategic AI Phase 2, War Posture, BattleContext changes, pending invasion payload changes, income/resource/troop/battle/diplomacy/spy formula changes, scene changes, `assets/ui/tech_icons` PNG changes, or `.import` changes.

## v0.70-63-hotfix1 Compact Tech Node & Detail Inspector Polish
- Built on `v0.70-63 Domestic Tech Tree Branch Graph UI MVP` (`ad1d8125a18e673fb6fb7853f817a37689d14e40`).
- Converted the Domestic Tech Tree branch graph from large full-info cards to compact read-only nodes.
- Compact nodes now show only icon or `?`, tech name, rarity `★`, and short completed/available/locked/special_locked state.
- Added a shared bottom detail inspector for selected tech details: name, scope, category/branch/tier, effect, cost, duration hint, state, prerequisites, national requirements, special requirements, and lock reasons.
- Added display-only node click selection and selected-node highlight. This is not research start and does not mutate tech progress or gameplay state.
- Preserved prerequisite `ColorRect` graph connection lines, left PLAYER national tree, right selected-player-city tree, enemy/insufficient-intel city hiding, icon fallback, locked weak styling, and v0.70-62-hotfix1 modal/top-layer behavior.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement research start/progress/completion, actual effects, AI research, Enemy Strategic AI Phase 2, War Posture, BattleContext changes, pending invasion payload changes, income/resource/troop/battle/diplomacy/spy formula changes, scene changes, `assets/ui/tech_icons` PNG changes, or `.import` changes.

## v0.70-63 Domestic Tech Tree Branch Graph UI MVP
- Built on `v0.70-62-hotfix1 Fullscreen Tech Tree Modal Fix` (`9c2e8304e4e874771c7750293fa31b27e558052e`).
- Replaced the fullscreen read-only domestic tech category card grid with a branch/tier graph canvas.
- Added branch row and tier column node layout, with same branch/tier nodes stacked vertically.
- Added prerequisite connection lines using runtime `ColorRect` line segments behind nodes.
- Added display-only graph line coloring for completed, available, locked, and special_locked paths.
- Preserved left PLAYER national tech scope, right selected-player-city tech scope, no-city guidance, enemy/insufficient-intel city hiding, icon loading with `?` fallback, locked `[잠김]` styling, and special lock text.
- Preserved v0.70-62-hotfix1 modal/top-layer behavior.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement research start/progress/completion, actual effects, AI research, Enemy Strategic AI Phase 2, War Posture, BattleContext changes, pending invasion payload changes, income/resource/troop/battle/diplomacy/spy formula changes, scene changes, `assets/ui/tech_icons` PNG changes, or `.import` changes.

## v0.70-62-hotfix1 Fullscreen Tech Tree Modal Fix
- Built on `v0.70-62 Domestic Tech Tree Fullscreen Read-Only UI MVP` (`3f2cff7ff32370ad947a74f66929f99c75854db9`).
- Promoted the fullscreen `tech_tree_overlay_mvp` to a top-layer modal with high z-index, `move_to_front()`, and mouse input stop behavior.
- Added open-time hide and close-time visible-state restore for overlapping worldmap floating/detail panels such as city info/detail, diplomacy/spy, trade order/transfer, help modal, and deployment UI.
- Added unhandled-input consumption while the tech tree overlay is open so background map/UI interactions do not pass through.
- Kept ESC and `닫기` close behavior.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement graph connection UI, research start/progress/completion, actual effects, Enemy Strategic AI Phase 2, War Posture, BattleContext changes, pending invasion payload changes, income/resource/troop/battle/diplomacy/spy formula changes, scene changes, `assets/ui/tech_icons` PNG changes, or `.import` changes.

## v0.70-62 Domestic Tech Tree Fullscreen Read-Only UI MVP
- Built on `v0.70-61 Domestic Tech Tree Confirmed Design Foundation MVP` (`208e32662b42bc14cb192af291153c7849c3674b`).
- Added a 월드맵 `테크트리` button and fullscreen read-only `tech_tree_overlay_mvp`.
- Added left PLAYER national tech tree rendering and right selected-player-city tech tree rendering from the v0.70-61 domestic tech definitions.
- Added icon loading with `?` fallback, compact cost/effect text, rarity `★`, completed/available/locked/special_locked state display, gray locked styling, `[잠김]` text, and special lock condition summaries.
- Hid enemy or insufficient-intel selected-city tech details behind Fog of War / `city_intel` policy copy.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement research start/progress/completion, actual effects, tech purchase/investment, AI research, Enemy Strategic AI Phase 2, War Posture, BattleContext changes, pending invasion payload changes, income/resource/troop/battle/diplomacy/spy formula changes, scene changes, `assets/ui/tech_icons` PNG changes, or `.import` changes.

## v0.70-61 Domestic Tech Tree Confirmed Design Foundation MVP
- Built on `테크트리 준비` (`78ab5e479511855f1f445c64eb57186bc93eb3b3`).
- Added Domestic Tech Tree Foundation MVP data from the confirmed city/national tech design scope without implementing UI, research buttons, research turn progression, or actual tech effects.
- Added domestic tech category, city/national definition, scope/category/branch query, definition lookup, prerequisite, national requirement, availability, icon, and fallback helper functions.
- Added `_player_state` normalization for city/national domestic tech completed/unlocked state so missing or malformed save data falls back safely.
- Mapped existing semantic icon files and kept missing icons as `?` fallback data.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan locks, pending invasion, BattleContext, market, alliance, wedge, player actions, `city_intel`, Fog of War, scenes, `assets/ui/tech_icons` PNG files, or `.import` files.

## v0.70-60 Enemy Pressure Balance Pass
- Built on `v0.70-59 Enemy Strategy Hint UX Polish` (`749179080e67a4d61dfa143761e4f5ed0e527404`).
- Audited pressure plan scoring across reinforcement target choice, strategic diplomacy, strategic spy pressure, and eligible invasion pair scoring.
- Reduced pressure plan city and pressure-type bonuses and added purpose caps so pressure remains a tie-breaker instead of dominating existing low-troop, frontline, personality, goal, and invasion guard scoring.
- Added invalid source/target city guards for pressure plan scoring bonus use.
- Prevented pressure plan invasion bonuses from reviving zero/negative base invasion pair scores.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change pressure plan generation, pressure plan direct effects, reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext, battle result handling, market, alliance, wedge, player actions, `city_intel`, Fog of War, scenes, assets, `.uid`, `.ogv`, or `assets/ui/tech_icons` PNG files.

## v0.70-59 Enemy Strategy Hint UX Polish
- Built on `v0.70-58 Enemy Pressure Plan QA Replay Pending SaveLoad Lock` (`ac3939e034c459457ea2f1dead8f4538d5b20d1a`).
- Polished enemy turn strategy hint UX without adding enemy AI behavior.
- Added safe compact formatter helpers for pressure plan hints, pending invasion hints, strategic action hints, duplicate hint-line prevention, and line clamping.
- Kept pressure plan display compact as `적 전략: 세력 · 목표` or `전략: 목표`, while hiding malformed/default/empty/raw-id/stale-turn payloads.
- Changed strategic action hint copy to abstract `적 전략 행동: 외교 압박` / `적 전략 행동: 첩보 압박`.
- Changed enemy turn hint/summary to compact action counts instead of per-city enemy troop deltas or internal goal/personality detail.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change pressure plan scoring, reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext, battle result handling, market, alliance, wedge, player actions, `city_intel`, Fog of War, scenes, assets, `.uid`, `.ogv`, or `assets/ui/tech_icons` PNG files.

## v0.70-58 Enemy Pressure Plan QA Replay Pending SaveLoad Lock
- Built on `내정테크아이콘` (`70a1e93cc8996f2109a2354c8a206ffe4479ec74`).
- Audited v0.70-57 pressure plan replay guard, pending invasion guard, pending BattleContext guard, save/load display normalization, compact summary/hint display, and scoring helper safety.
- Kept pressure plan as display/history plus scoring hint only with forced `effect = display_scoring_only`.
- Hardened pressure plan normalization so missing `turn_number` does not become the current turn, and scoring ignores normalized plans whose turn does not match the current world turn.
- Polished detailed pressure plan hint copy to `적 전략: 세력 · 목표`, reducing repeated `전략:` label noise.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext, battle result handling, market, alliance, wedge, player actions, `city_intel`, scenes, assets, `.uid`, `.ogv`, or `assets/ui/tech_icons` PNG files.

## v0.70-57 Enemy Strategic AI Phase 1 Target Pressure Planner
- Built on `v0.70-56-hotfix1 GDScript Reload Shadowing Warning Fix` (`602a199ebc19fd36d51a824b1a6941d4ce60197c`).
- Added a conservative max-one enemy pressure plan result for each world turn.
- Stored pressure plan display/history through `_player_state["last_enemy_pressure_plan_result"]` and `last_enemy_faction_turn_result.pressure_plan`.
- Added pressure plan candidate generation from non-player faction-owned source cities, strategic goal target/pressure data, personality profile, and frontline/adjacency context.
- Normalized pressure plan payloads to `effect = display_scoring_only`; malformed plans and PLAYER faction plans are discarded.
- Skipped new pressure plan creation during pending invasion, pending BattleContext, same-turn replay, invalid turn, or no-candidate cases.
- Added small pressure-plan scoring hints to reinforcement target scoring, diplomacy/spy strategic action scoring, and already eligible invasion pair scoring.
- Added compact `전략:` pressure-plan summary/hint display without exposing hidden enemy resources, chancellors, raw city intel, or national state.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, pending invasion payload, BattleContext, battle result handling, market, alliance, wedge, player actions, `city_intel`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-56-hotfix1 GDScript Reload Shadowing Warning Fix
- Built on `v0.70-56 Enemy Turn Manual F6 QA Fix Pass` (`e06c1744087167957eebc1e070bb6567646b6972`).
- Removed GDScript reload warnings without gameplay changes.
- Renamed local `seed` temporaries in enemy personality/strategic goal helper code to avoid colliding with Godot's built-in `seed()` function.
- Renamed the diplomacy result formatter target label local to remove the `target_label` block shadowing warning.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, and `agent/SESSION_LOG.md`.
- Did not change enemy turn logic, personality or goal seed values, invasion logic, BattleContext, battle result handling, market, alliance, wedge, player actions, balance values, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-56 Enemy Turn Manual F6 QA Fix Pass
- Built on `v0.70-55 Enemy Goal QA Strategy Hint Polish` (`e96bbd4a028ea8c743f5665e6fec5a6ee9f86fe0`).
- Audited the enemy turn chain across reinforcement, personality/goal scoring, strategic action, invasion roll, pending invasion, defense deployment, BattleContext handoff, battle result apply, save/load replay guard, and compact summary/hint display.
- Added a small pending battle context guard so turn end and enemy invasion roll cannot proceed while `_player_state["pending_battle_context"]` is already active.
- Confirmed strategic action remains max one per world turn and still skips during pending invasion or pending battle context.
- Confirmed reinforcement constants, invasion chance, invasion minimum attacker troops, pending invasion payload shape, BattleContext shape, result apply ownership safety, market/alliance/wedge/player action paths, and `city_intel` behavior remain unchanged.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not implement Enemy Strategic AI Phase 1, full enemy AI planner, pathfinding, multi-turn war plan, enemy economy simulation, enemy spy actual damage, enemy diplomacy alliance/trade simulation, PLAYER relation mutation, BattleContext changes, pending invasion payload changes, scene changes, asset changes, `.uid`, or `.ogv` changes.

## v0.70-55 Enemy Goal QA & Strategy Hint Polish
- Built on local `v0.70-54 Enemy Strategic Goal Seed MVP` (`617883d0fc71db1cdf9668e5c1148a98a5a04766`).
- Audited v0.70-54 strategic goal seeds for faction id coverage, existing target city ids, compact labels, pressure metadata, default fallback, PLAYER exclusion, malformed fallback, missing target filtering, and `1.00..1.15` weight clamp behavior.
- Confirmed the existing goal scoring bonuses remain conservative and limited to reinforcement target selection, strategic action type/target scoring, and eligible invasion pair scoring.
- Added a compact goal-label display helper so default/empty goals stay hidden and visible hints use `목표: ...` consistently.
- Polished enemy turn summary/hint output so reinforcement summaries do not repeat goal labels for every faction line while detailed strategic action/hint text can still show compact goal metadata.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change full enemy AI scope, scoring weights, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload, BattleContext, replay guards, enemy spy actual damage, enemy alliance/trade simulation, enemy economy simulation, market formulas, alliance, wedge, player actions, `city_intel`, `faction_chancellors`, scenes, assets, `.uid`, or `.ogv`.

## v0.70-54 Enemy Strategic Goal Seed MVP
- Built on `v0.70-53 Enemy Personality QA Balance Tuning Pass` (`1952388b5ac31a1fede63e9febc87f5bc9a559e9`).
- Added conservative `ENEMY_FACTION_STRATEGIC_GOAL_SEEDS` for current non-player factions with default fallback, compact goal label, target city ids, region hints, pressure type, and bounded `1.00..1.15` weight.
- Added goal helper guards for fallback, PLAYER exclusion, malformed seed fallback, target city existence filtering, pressure lookup, and weight clamp.
- Applied small goal bonuses to enemy reinforcement target scoring, strategic diplomacy/spy pressure selection scoring, and already eligible invasion pair scoring.
- Added compact `goal_id`, `goal_label`, and `goal_pressure` display metadata to reinforcement and strategic action payloads so summary/hint can show `목표:` without exposing hidden enemy state.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change full enemy AI scope, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload, BattleContext, replay guards, enemy spy actual damage, enemy alliance/trade simulation, enemy economy simulation, market formulas, alliance, wedge, player actions, `city_intel`, `faction_chancellors`, scenes, assets, `.uid`, or `.ogv`.

## v0.70-53 Enemy Personality QA & Balance Tuning Pass
- Built on `v0.70-52 Enemy Faction Personality Seed MVP` (`4ee00833ac7ea4f953ec6e006362ff51b361551f`).
- Audited personality seed coverage, default fallback, bounded weights, compact labels, reinforcement target scoring, strategic action type selection, eligible invasion pair scoring, summary/hint display, and replay/save-load guard boundaries.
- Added explicit `chu` default-balanced seed coverage.
- Changed `kyushu_faction` to a compact `계략` / `schemer_pressure` profile with a modest spy-pressure lean.
- Tuned spy-pressure selection scoring down slightly so diplomacy-biased profiles remain visible and strategic action type selection is less dominated by troop/frontline spy bonuses.
- Guarded invasion personality weighting so it applies only to positive eligible-pair scores, avoiding inverted behavior where sub-1.0 weights improve negative invasion scores.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change full enemy AI scope, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload, BattleContext, replay guards, enemy spy damage, enemy alliance/trade simulation, market formulas, alliance, wedge, player actions, `city_intel`, `faction_chancellors`, scenes, assets, `.uid`, or `.ogv`.

## v0.70-52 Enemy Faction Personality Seed MVP
- Built on `v0.70-51 Enemy Turn QA Pass Manual F6 Feedback Polish` (`682c1002bab46474d72c5ff2ca2d3c4ced977222`).
- Added conservative `ENEMY_FACTION_PERSONALITY_SEEDS` profiles for non-player factions with bounded weights and compact labels.
- Applied personality weights to enemy reinforcement target scoring so military/frontline or defensive profiles slightly influence which already-owned city is reinforced.
- Applied personality weights to strategic follow-up selection so diplomacy and spy-pressure candidates can be biased without exceeding one action per world turn.
- Applied personality weights to eligible invasion pair scoring after v0.70-49 owner, adjacency, missing-city, and weak-attacker guards pass.
- Added personality display metadata to reinforcement and strategic action summaries without exposing hidden enemy resources, chancellor details, city intel, or national state.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change full enemy AI scope, reinforcement amount formulas, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload, BattleContext, replay guards, enemy spy damage, enemy alliance/trade simulation, market formulas, alliance, wedge, player actions, `city_intel`, `faction_chancellors`, scenes, assets, `.uid`, or `.ogv`.

## v0.70-51 Enemy Turn QA Pass & Manual F6 Feedback Polish
- Built on `v0.70-50 Enemy Faction Diplomacy Spy Behavior Follow-up` (`7fa73bfe31efd76bebefc595768fc55a8d98e3b5`).
- Performed a QA pass over the enemy turn chain: reinforcement, strategic action, invasion roll, pending invasion, defense deployment, BattleContext handoff, battle result apply, and save/load replay guards.
- Added display/history normalization for enemy faction turn results so malformed or loaded `strategic_actions` payloads are clamped to at most one supported action.
- Normalized enemy diplomacy follow-up display payloads to non-player pairs only and enemy spy pressure payloads to `display_only`.
- Same-turn enemy replay guard, pending invasion skip, pending battle skip, invasion roll guard, pending invasion payload shape, BattleContext keys, and result apply flow were preserved.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, reinforcement balance, enemy spy damage, enemy alliance/trade simulation, market formulas, alliance, wedge, player spy/diplomacy actions, `city_intel`, `faction_chancellors`, scenes, assets, `.uid`, or `.ogv`.

## v0.70-50 Enemy Faction Diplomacy/Spy Behavior Follow-up
- Built on `v0.70-49 Enemy Invasion Defense Balance Polish` (`1d00fb4402033a88c0c7aeb87f94b48cb3120800`).
- Added a conservative enemy strategic follow-up lane to enemy faction turn results as `strategic_actions`, separate from reinforcement `actions`.
- Added `_player_state["last_enemy_strategic_action_result"]` as display/history state only.
- Kept `_player_state["last_enemy_faction_turn_processed_turn"]` as the same-turn replay guard; same-turn returns restore display/history and do not rerun strategic actions.
- Strategic follow-up is skipped while pending invasion or pending battle context exists and is capped at one action per world turn.
- Added non-player-only enemy diplomacy follow-up using existing faction relation score helpers with a conservative `±3` drift and no direct status/alliance/trade/cooldown mutation.
- Added display-only enemy spy pressure against player-owned cities adjacent to safe enemy-owned cities. It does not mutate player city stats/resources, `city_intel`, spy cooldowns, detection penalties, or relation state.
- Integrated one compact strategic line into enemy turn summary/hint copy while preserving v0.70-47 compact wording.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change v0.70-49 invasion guards, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext, player attack/defense deployment, battle result apply, Fog of War, `city_intel`, market formulas, alliance, wedge, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, or `.ogv`.

## v0.70-49 Enemy Invasion/Defense Balance Polish
- Built on `v0.70-47 WorldMap Strategic UX Final Polish` (`669da7976600db60b8a6283b1c9fb3f4d9078f70`). `v0.70-48 Enemy Faction Diplomacy/Spy Behavior Follow-up` remains deferred.
- Added conservative enemy invasion candidate eligibility guards for missing city data, marker/HUD owner mismatch, wrong owner scope, non-adjacent city pairs, and weak attacker cities.
- Added `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS = 160` as an invasion-start threshold, separate from result safety constants `INVASION_MIN_CITY_TROOPS`, `INVASION_MIN_OCCUPATION_TROOPS`, and `INVASION_MAX_REASONABLE_CITY_TROOPS`.
- Kept `ENEMY_INVASION_CHANCE = 0.45`; invasion frequency polish is handled through eligibility filtering rather than changing the global chance.
- Added small scoring/sorting for eligible invasion pairs so stronger attacker cities and plausible adjacent player targets are preferred without adding full enemy AI.
- Reused the same eligibility checks when creating pending invasion events and when validating pending invasion BattleContext readiness.
- Hardened enemy invasion result application so missing attacker/source city data is treated as unknown and does not mutate city ownership.
- Confirmed defense deployment keeps `source = defender city`, `target = attacker city`, command limit validation, selected defender hero validation, and deployable troop clamp.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change pending invasion payload shape, BattleContext key/shape, replay guards, Battle scene logic, player attack system shape, enemy diplomacy/spy/economy, market formulas, alliance, wedge, Fog of War, player chancellor scope, `faction_chancellors`, scenes, assets, `.uid`, or `.ogv`.

## v0.70-47 WorldMap Strategic UX Final Polish
- Built on `v0.70-46 Enemy Faction Turn Behavior QA Balance Polish` (`97046321ae51f7ea0fd6a726e7b6dc42f4742ab8`).
- Polished WorldMap strategic UX copy across the left status panel, right selected-city panel, unified city detail tabs, diplomacy/spy cards, trade hints, enemy turn summary, and pending invasion hints.
- Left World Status now displays turn number, calendar, and phase in one compact line while preserving PLAYER national/court scope.
- Right Selected City copy is clearer for player city defense/domestic info, enemy Fog of War revealed/locked fields, and pending invasion selected-city status.
- City Detail resource/internal trade/external trade text now better distinguishes resource potential, city storage, supply links, manual transfer, trade candidates, relation efficiency, and manual trade execution state.
- Diplomacy and spy action cards now use clearer `행동 가능` / `행동 불가` tooltips and hints without changing validation behavior.
- Enemy turn and pending invasion output now uses compact `이번 턴 적 행동`, `침공 대기`, and `외 N건` wording.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change formulas, chances, costs, cooldowns, validation gates, market prices, chancellor auto trade, alliance, wedge, spy/diplomacy effects, city-intel display-only save/load, enemy replay guard, pending invasion payload, BattleContext, scenes, assets, `.uid`, or `.ogv`.

## v0.70-46 Enemy Faction Turn Behavior QA & Balance Polish
- Built on `v0.70-45 Enemy Faction Turn Behavior MVP` (`964d8db3d61a2154e268ba1f905691f9ac493262`).
- Performed QA/balance polish for enemy turn replay guard, save/load replay safety, reinforcement balance, city owner safety, pending invasion continuity, and compact result display.
- Adjusted enemy reinforcement to `base +60`, `frontline +40`, `valid faction chancellor +20`, `max +120`.
- Balance reason: reduce long-run troop accumulation from the v0.70-45 `max +150` rule while preserving the visible enemy-turn movement.
- Added conservative owner validation so a city is skipped if marker owner and HUD/runtime owner both exist but disagree.
- Kept `_player_state["last_enemy_faction_turn_processed_turn"]` as the replay guard and preserved `_player_state["last_enemy_faction_turn_result"]` as display/history state only.
- Polished enemy turn summary/hint output to use `외 N건` for omitted actions.
- Preserved existing enemy invasion flow without changing `ENEMY_INVASION_CHANCE`, pending event payload, or BattleContext handoff.
- Verification passed: `git diff --check`, required enemy-turn/search verification, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change market price formulas, manual/chancellor trade pricing, alliance behavior, wedge behavior, Fog of War rules, spy/diplomacy formulas, player chancellor scope, `_player_state["faction_chancellors"]` structure, left/right panel scope, BattleContext, scenes, assets, `.uid`, or `.ogv`.

## v0.70-45 Enemy Faction Turn Behavior MVP
- Built on `v0.70-44 WorldMap Domestic/Turn Flow QA & Polish` (`cc977ad461a971819ba5be2a4d2a6d414aabe7a8`).
- Added conservative enemy faction turn behavior to the existing enemy phase in `scripts/worldmap_test.gd`.
- Added `_player_state["last_enemy_faction_turn_result"]` for compact enemy turn result display/history and `_player_state["last_enemy_faction_turn_processed_turn"]` as the same-turn replay guard.
- Enemy factions now select at most one owned city per turn, preferring frontline cities adjacent to player-owned cities, then the lowest-troop owned city.
- Enemy action scope is limited to city reinforcement: base `+80`, frontline `+40`, valid faction chancellor seed `+20`, clamped to `+150`.
- Existing enemy invasion event generation remains on the prior path. The new result payload records whether `_player_state["pending_invasion_event"]` was created, without changing `ENEMY_INVASION_CHANCE` or BattleContext handoff.
- Left World Status can show compact enemy turn summary lines while preserving PLAYER/nation scope and Fog of War boundaries.
- Save/load restores the enemy turn result and processed-turn guard as display/state only; it does not replay enemy reinforcement or rerun the same-turn enemy invasion roll.
- Renamed an existing chancellor internal auto-trade source local to keep the warning-cleanup `selected_city_id` search pattern clear.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change market price formulas, manual/chancellor trade pricing, alliance behavior, wedge behavior, Fog of War rules, spy/diplomacy formulas, player chancellor scope, left/right panel scope, BattleContext, scenes, assets, `.uid`, or `.ogv`.

## v0.70-44 WorldMap Domestic/Turn Flow QA & Polish
- Built on `v0.70-43 WorldMap Diplomacy Spy Intel Final QA Pass` (`aa7ba353a7eaec2bf38868b2110922d179ba1995`).
- Performed a code-level QA audit for player turn end, domestic processing, trade market state, chancellor auto trade, diplomacy cooldowns, trade agreement/alliance duration, spy cooldowns, revolt instigation duration, save/load replay safety, city intel display-only restore, pending invasion event flow, and chancellor/left-panel scope.
- Code change 없음 / domestic-turn flow QA + docs update.
- Confirmed `_player_state["last_domestic_apply_turn"]`, `_player_state["last_chancellor_auto_trade_turn"]`, turn-scoped trade market state, and save/load normalization already prevent same-turn replay of domestic, market, cooldown, alliance, spy, wedge, and city-intel effects.
- Updated agent documentation with QA results, preserved scope, verification status, next candidates, and the required manual F6 QA checklist.
- Modified files: `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change domestic formulas, market price formulas, chancellor auto trade formulas, diplomacy/alliance behavior, spy/wedge formulas, city intel behavior, chancellor candidate logic, `faction_chancellors`, left/right panel scope, BattleContext, Selected City Panel behavior, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-43 WorldMap Diplomacy/Spy/Intel Final QA Pass
- Built on `v0.70-42 Enemy Intel UI Polish / Fog of War` (`7e0d27b887c7cd5989efc2a18038665c7e99854b`).
- Performed a code-level QA audit for the v0.70-39 through v0.70-42 worldmap diplomacy/spy/intel stack.
- Audited trade market pricing, alliance proposal/duration, wedge/alienation, enemy city intel Fog of War, chancellor candidate scope, faction chancellor seed state, and left/right panel scope.
- Code change 없음: no runtime script edits were required.
- Updated agent documentation with QA results, preserved scope, verification status, and manual F6 QA checklist.
- Modified files: `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change trade formulas, alliance behavior, spy formulas/effects, wedge behavior, city intel behavior, chancellor candidate logic, `faction_chancellors`, left/right panel scope, BattleContext, Selected City Panel behavior, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-42 Enemy Intel UI Polish / Fog of War
- Built on `v0.70-41 Spy Action Polish / Alienation MVP` (`aae97d12676cea97c065a67f6366a9593e9e26ef`).
- Polished enemy selected-city Fog of War UI copy for information level, revealed fields, and locked fields.
- Added display levels for no/basic/military/resource/domestic/full intel states.
- Added revealed/locked summaries for troops estimate, troops, resources, public support, loyalty, governor, and tech fields.
- Updated right selected City Info enemy branch so payload-backed intel reveals values while malformed or payload-missing fields stay locked.
- Updated spy-tab known-info summary to match the right panel's intel level and revealed/locked wording.
- Kept `_player_state["city_intel"]` as display-only save/load state with no spy effect replay.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change spy formulas/effects, wedge logic, alliance proposal flow, market pricing, trade pricing, chancellor candidate scope, `faction_chancellors`, left/right panel scope, BattleContext, Selected City Panel behavior, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-41 Spy Action Polish / Alienation MVP
- Built on `v0.70-40 Diplomacy Action Polish / Alliance MVP` (`0f516a7473cadd371afa04f9b1352c3e9823d85a`).
- Added executable `이간질` to the spy action card with action id `wedge`.
- Added automatic non-player counterpart faction selection for the selected target faction.
- Reused existing spy validation and result patterns while adding cost, cooldown, success, detection, and alliance-break metadata for wedge results.
- Connected `SPY_WEDGE_COST`, `SPY_WEDGE_COOLDOWN_TURNS`, and `SPY_DETECTED_RELATION_PENALTY_WEDGE`.
- Successful wedge attempts lower target-counterpart relation score and can break allied status when the score falls below `ALLIANCE_ACCEPTANCE_THRESHOLD`.
- Detection applies the wedge relation penalty to PLAYER-target faction relations and can occur together with a successful wedge.
- Stored results in `_player_state["last_spy_wedge_result"]` for UI/display persistence.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change existing spy action formulas/effects, v0.70-40 alliance proposal flow, v0.70-39 market pricing, city intel visibility filtering, chancellor candidate scope, `faction_chancellors`, left/right panel scope, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-40 Diplomacy Action Polish / Alliance MVP
- Built on `v0.70-39 Trade Market / Price Variation MVP` (`84bbf9c5e12e3afff523d3e389043a7126dce732`).
- Added executable `동맹 제안` to the diplomacy action card with action id `alliance_proposal`.
- Reused existing alliance acceptance scoring and threshold helpers.
- Added validation for target faction, hostile/suspended relations, active alliances, diplomacy cooldown, and proposal resource costs.
- Added accepted/rejected alliance result payloads in `_player_state["last_alliance_proposal_result"]` and `_player_state["last_diplomacy_action_result"]`.
- Stored accepted alliance duration on faction relation entries and mirrored active alliances into `_player_state["alliances"]` for save/load fallback.
- Extended diplomacy turn advancement to decrement alliance duration and expire alliances back to neutral.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change v0.70-39 market price formulas/state, external trade pricing, existing diplomacy actions, spy formulas/effects, chancellor candidate scope, `faction_chancellors`, enemy city intel visibility filtering, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-39 Trade Market / Price Variation MVP
- Built on `v0.70-38-hotfix1 Chancellor Candidate Scope & Enemy Chancellor Seed` (`71c61f331a7185a1ebbb2d042b53d791dcb556a8`).
- Connected turn-scoped market prices to external trade pricing.
- Kept `MANUAL_TRADE_PREVIEW_PRICES` as base price authority and clamped market multipliers to `0.80..1.20`.
- Added `_player_state["trade_market_prices"]` and `_player_state["trade_market_turn"]` mirrors for save/load and same-turn stability.
- Updated manual external trade preview/execution and chancellor external auto trade to use market price plus existing relation efficiency.
- Updated formulas to `ceil(market_price * amount / efficiency)` for imports and `floor(market_price * amount * efficiency)` for exports.
- Added compact external trade UI copy for current market price and percentage movement.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change chancellor candidate scope, `faction_chancellors`, enemy city intel visibility filtering, spy/diplomacy formulas, target city storage rules, foreign stock, relation score mutation, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-38-hotfix1 Chancellor Candidate Scope & Enemy Chancellor Seed
- Built on `v0.70-38 Enemy City Intel Visibility Filter` (`6b61e1f045c461eeff5a53f5a4b77aae6cbada53`).
- Limited player chancellor candidates to the valid capital/Hanseong/player candidate city stationed hero roster.
- Kept Pyeongyang/foreign stationed player-side heroes out of the Hanseong chancellor candidate dropdown.
- Preserved current valid player chancellor assignment as national state without auto-dismissal when the hero is outside the candidate city.
- Added `_player_state["faction_chancellors"]` as non-player faction chancellor seed state.
- Seeded enemy faction chancellors from faction-owned city stationed heroes using chancellor aptitude and politics/intelligence/command fallback.
- Added save/load fallback normalization and reseeding for `faction_chancellors`.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change enemy domestic execution, enemy diplomacy/spy execution, enemy chancellor UI expansion, spy formulas/effects, diplomacy actions, trade pricing/efficiency, chancellor auto trade, enemy city intel visibility filtering, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-38 Enemy City Intel Visibility Filter
- Built on `v0.70-37-hotfix1 Left National Panel Scope Lock` (`f5b74da8c1d24ae6db4390562eb16a69018d1625`).
- Added an enemy-city intel visibility filter to the right selected City Info panel.
- Kept player-owned city display on the existing full-information path.
- Changed foreign/enemy city display so pre-intel details are locked behind `정탐 필요` / `추가 정탐 필요` copy.
- Added `_player_state["city_intel"]` as a display-only registry populated by successful `정탐` results.
- Connected successful spy info payloads to city intel fields for troops, resources, public support, loyalty, governor, and tech visibility.
- Updated spy-tab visibility/known-info summaries to use stored city intel instead of revealing hidden enemy details.
- Added save/load fallback normalization for `city_intel` without replaying spy effects.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change spy success/detection formulas, spy effect amounts, diplomacy actions, trade pricing/efficiency, chancellor auto trade, left national panel scope lock, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-37-hotfix1 Left National Panel Scope Lock
- Built on `v0.70-37 Spy Action MVP` (`3c0a03be6163230f029eadf464a7b4afee12e775`).
- Fixed left World Status panel scope leakage where selecting a foreign city could clear the national chancellor assignment.
- Stopped left-panel refresh from using selected-city stationed heroes to validate national `_player_state["chancellor_id"]`.
- Made chancellor sync national-safe: valid player-side chancellors are retained across foreign city selection, while missing/non-player invalid ids can still be cleared.
- Changed the chancellor assignment dropdown to use player-side national candidates and preserve the current valid player chancellor display.
- Kept the right City Detail, diplomacy/spy, and trade panels selected-city scoped.
- Restored spy action validation behavior for assigned national chancellors after selecting foreign cities, without changing spy formulas or effects.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change spy success/detection rates, diplomacy actions, trade pricing/efficiency, chancellor auto trade, save/load schema, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved the `v0.70-34-hotfix1` warning cleanup.

## v0.70-37 Spy Action MVP
- Built on `v0.70-36 Diplomacy Action MVP` (`b0f40e4ca4f9acac568a23b73652afc145a1eb66`).
- Added a runtime `SpyActionCard` to City Detail `외교·첩보 > 첩보` for selected foreign cities.
- Connected `정탐`, `민심 교란`, `성 충성도 교란`, and `반란 조장` buttons to validation-first execution.
- Reused existing spy can/roll/apply helpers and added action ids, target faction ids, success/failure, detection, cooldown, message, and relation penalty metadata to result payloads.
- Applied conservative relation score penalties on detection through the existing faction relation helper.
- Kept spy execution cost-free for this MVP while preserving the existing political chancellor and cooldown gates.
- Improved recent spy result display for info, public support disruption, loyalty disruption, revolt instigation, and detected results.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change `이간질`, faction alienation, spy unit/network systems, diplomacy actions, trade pricing/efficiency, manual trade, chancellor auto trade, target city storage, foreign faction stock, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved v0.70-36 diplomacy actions, v0.70-35 relation efficiency pricing, trade persistence, and the `v0.70-34-hotfix1` warning cleanup.

## v0.70-36 Diplomacy Action MVP
- Built on `v0.70-35 Trade Balance / Relation Efficiency Polish` (`f0d03010829b72a64479712fd97833a509e7bad6`).
- Added a runtime diplomacy action card to City Detail `외교·첩보 > 외교` for selected foreign cities.
- Connected `사절 파견`, `조공`, `교역 협정`, and `관계 회복` buttons to validation-first execution.
- Added national `resource_stock.gold` costs, relation score deltas, target-faction diplomacy action cooldowns, and recent diplomacy result payloads.
- Added 6-turn trade agreement state through the existing relation entry and reflected it in the existing trade efficiency multiplier path.
- Added save/load fallback for `_player_state["last_diplomacy_action_result"]`, `_player_state["diplomacy_action_cooldowns"]`, and `_player_state["trade_agreements"]`.
- Extended world-turn diplomacy cooldown advancement to decrement diplomacy action cooldowns and trade agreement duration.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change alliance proposal execution, military support request execution, spy actions, AI response/rolls, target city storage, foreign faction stock, external trade pricing, chancellor auto trade structure, manual trade panels, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv`.
- Preserved manual/internal trade, v0.70-35 relation efficiency pricing, trade persistence, and the `v0.70-34-hotfix1` warning cleanup.

## v0.70-35 Trade Balance / Relation Efficiency Polish
- Built on `v0.70-33 Chancellor Auto Trade Logic Connect` (`1cf079873163784da6620b5b3ecdf6cffdaa6e18`).
- Added relation-aware external trade pricing helpers for import cost, export gain, route efficiency, and shared delta calculation.
- Applied relation efficiency to manual external trade preview.
- Applied relation efficiency to manual external trade execution using the same helper as preview.
- Applied relation efficiency to chancellor external auto trade import/export and sorted valid candidates by higher efficiency.
- Recalculated pending manual order preview on normalize/load/refresh from current relation efficiency.
- Added UI copy for `효율 xN.NN` and applied pricing in external trade relation/preview/result summaries.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change target city storage, foreign faction stock, national `resource_stock`, relation scores, turn cost, random rolls, market price fluctuation, diplomacy/spy actions, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.
- Preserved manual internal transfer, chancellor internal redistribution, trade persistence, and the `v0.70-34-hotfix1` warning cleanup.

## v0.70-33 Chancellor Auto Trade Logic Connect
- Built on `v0.70-34-hotfix1 GDScript Shadowing Warning Cleanup` (`83cbf79c45bd66959cf0c0478c161ce275de6c47`).
- Filled the skipped `v0.70-33` follow-up after `v0.70-34` and `v0.70-34-hotfix1`.
- Connected `재상에게 일임` internal/external trade modes to player domestic-turn auto trade.
- Added internal chancellor auto trade that redistributes connected player-owned city storage from surplus sources to shortage targets.
- Added external chancellor auto trade that imports shortage resources or exports surplus resources by mutating source city storage only.
- Added policy/aptitude resource priority and cap handling for balanced, agriculture, commerce, trade, military, and diplomatic/economic/administrative aptitude.
- Added same-turn double apply guard and display-only result persistence via `_player_state["last_chancellor_auto_trade_result"]` / `_player_state["last_chancellor_auto_trade_turn"]`.
- Added recent chancellor auto trade summaries to internal/external trade tabs while preserving manual pending/execution summaries.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change external target city storage, foreign faction stock, national `resource_stock`, relation score, turn cost, random rolls, manual trade panels, internal transfer panel, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-34-hotfix1 GDScript Shadowing Warning Cleanup
- Built on `v0.70-34 Trade Persistence Polish` (`c7897b2b4572222991fcaefdc4da88323b3aafd8`).
- Renamed local `resource_label` variables in `scripts/worldmap_test.gd` trade panel row builders to avoid class-member shadowing.
- Renamed the diplomacy/spy local `selected_city_id` in `scripts/worldmap_test.gd` to avoid class-member shadowing.
- Renamed `_format_internal_trade_signed_transfer_amounts()` parameter `sign` to avoid the built-in function name collision.
- Renamed the local `loyalty_card` in `scripts/worldmap_city_info_panel.gd` to avoid class-member shadowing.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change functionality, UI layout, formulas, save/load structure, trade persistence, manual trade, internal transfer, external execution, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-34 Trade Persistence Polish
- Built on `v0.70-32 Trade Execution Connect MVP` (`5cd34251fbbf221607e8d6c149325623ddf9fe89`).
- Skipped `v0.70-33 Chancellor Auto Trade Logic Connect` by instruction; chancellor auto trade remains a follow-up.
- Added save/load persistence for internal/external trade control modes through `_player_state["trade_control_modes"]`.
- Added save/load persistence for pending external manual trade orders through `_player_state["manual_trade_orders"]`.
- Added load normalization for pending external manual orders, including allowed resources/actions, nonnegative amounts, source/target city checks, and preview recalculation.
- Added invalid pending manual order pruning with `[TRADE_SAVE_LOAD]` warnings.
- Persisted recent external manual execution result and recent internal manual transfer result as display-only player-state payloads without replaying effects on load.
- Confirmed/kept city `storage` persistence on the existing `worldmap_city_state` save/load path.
- Preserved old-save fallback: missing trade keys default to chancellor modes, no pending manual orders, and empty recent result payloads.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not save transient UI node/panel state and did not change chancellor auto trade, relation efficiency, price variation, target city storage, foreign faction stock, relation, turn, Selected City Panel, diplomacy/spy tabs, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-32 Trade Execution Connect MVP
- Built on `v0.70-31 Internal Trade Manual Transfer MVP` (`856f411a633ac2f7b12ccb3cfd66412e593c6ad8`).
- Added a runtime `ManualTradeExecutionButton` for City Detail `무역 > 타국무역` when a saved external manual trade order exists.
- Connected saved `v0.70-30` external manual orders to actual selected-city `storage` mutation.
- Import execution now subtracts city `storage.gold` and adds the imported resource to the selected source city.
- Export execution now subtracts the exported resource from selected city storage and adds city `storage.gold`.
- Reused `MANUAL_TRADE_PREVIEW_PRICES` so saved preview and execution result use the same fixed MVP prices.
- Added validation-first execution with no partial apply for invalid target, blocked relation, missing gold, missing export resource, invalid resource/action, negative amount, and empty actionable orders.
- Added recent external manual execution result display and failure message display in the `타국무역` tab.
- Successful execution clears the pending manual order; failed execution keeps it.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change target city storage, foreign faction stock, national `resource_stock`, relation scores, turn flow, chancellor auto trade, internal manual transfer logic, Selected City Panel, diplomacy/spy tabs, formulas, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-31 Internal Trade Manual Transfer MVP
- Built on `v0.70-30 Manual Trade Order Panel MVP` (`df761af4a658f98177b6a498efe5515fd2a1c634`).
- Added a runtime `InternalTradeTransferPanel` for City Detail `무역 > 자국무역` manual transfer.
- Connected internal-trade `수동 조정` to open the panel when the selected city has connected player-owned trade targets.
- Added connected player-owned target selection.
- Added amount inputs for `금전`, `쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, and `소금`.
- Capped each amount input by the source city's current city `storage`.
- Added source/target expected transfer preview and validation for empty, invalid, disconnected, foreign, same-city, and over-amount cases.
- `이송 적용` now actually moves amounts between source and target city storage and records the most recent internal manual transfer summary.
- Kept storage persistence on the existing city storage save/load path and did not add a large save/load schema change.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change national `resource_stock`, relation scores, turns, external trade execution, `v0.70-30` external Manual Trade Order Panel behavior, Selected City Panel, diplomacy/spy tabs, formulas, BattleContext, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-30 Manual Trade Order Panel MVP
- Built on `v0.70-29 WorldMap Trade Control Mode UI MVP` (`d55c76e3c5f8b6270a76812d32e7fe1fcc3b6102`).
- Added a runtime `ManualTradeOrderPanel` for City Detail `무역 > 타국무역` manual control.
- Connected external-trade `수동 조정` to open the panel when the selected city has foreign trade candidates.
- Added external candidate selection and relation/trade-availability/efficiency display.
- Added per-resource `안함 / 수입 / 수출` action selection and quantity input for rice, barley, seafood, wood, iron, horses, silk, and salt.
- Added preview-only fixed prices and expected gold/resource delta display.
- Added runtime manual-order storage and an external trade tab summary for saved manual commands.
- Kept `명령 저장` as a placeholder save only; no actual trade execution, gold/resource movement, city storage mutation, relation mutation, or turn consumption is performed.
- Kept internal trade manual transfer deferred to `Internal Trade Manual Transfer MVP`, chancellor auto trade deferred to `Chancellor Auto Trade Logic Connect`, and save/load persistence deferred to a later Trade Execution/Control persistence stage.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change Resource tab, diplomacy/spy tabs and the `v0.70-28-hotfix1` visibility rule, Selected City Panel, formulas, BattleContext, save/load schema, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-29 WorldMap Trade Control Mode UI MVP
- Built on `v0.70-28-hotfix1 Diplomacy Spy Subtab Visibility Fix` (`48fa66938563524cff7ec919904b8e25d90d909c`).
- Added a runtime trade-control card to City Detail `무역 > 자국무역` and `무역 > 타국무역`.
- Added `재상에게 일임` and `수동 조정` buttons with current selection display.
- Kept internal trade mode and external trade mode as separate runtime state slots, both defaulting to `chancellor`.
- Disabled `수동 조정` when no connected player-owned city exists for internal trade or no adjacent foreign trade candidate exists for external trade.
- Added placeholder guidance for manual trade order and future chancellor auto-trade behavior without executing either path.
- Removed the old duplicated `재상 위임 / 수동 조정` text from the legacy trade lead label path.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change actual trade execution, resource movement, gold purchase/sale, resource exchange, chancellor auto-trade logic, trade/relation formulas, turn handling, resource tab, diplomacy/spy tabs, Selected City Panel, BattleContext, save/load schema, `project.godot`, scenes, assets, `.uid`, or `.ogv` files.

## v0.70-28-hotfix1 Diplomacy Spy Subtab Visibility Fix
- Built on `v0.70-28 Diplomacy Spy Tab Structure Polish` (`fbc6a6e`).
- Fixed a City Detail `외교·첩보` subtab visibility regression.
- In diplomacy/spy primary mode, the reused `외교` and `첩보` buttons now explicitly set `visible = true`.
- The unused third subtab button remains hidden in diplomacy/spy mode.
- Confirmed the existing secondary-tab routing still maps `외교` to diplomacy content and `첩보` to spy content.
- Clarified visible action copy so diplomacy execution is deferred to Diplomacy Action MVP and spy execution is deferred to Spy Action MVP.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change actual diplomacy/spy execution, relation scores, spy success/failure rolls, resource spending, turn spending, resource tab, trade tabs, Selected City Panel, BattleContext, save/load schema, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-28 Diplomacy Spy Tab Structure Polish
- Built on `v0.70-27 Selected City Stability + Military Card Polish` (`6136aa2`).
- Reworked City Detail `외교·첩보 > 외교` around selected city owner, PLAYER relation status, relation score, trade availability, and diplomacy action candidates.
- Reworked City Detail `외교·첩보 > 첩보` around target city information level, known information scope, spy action candidates, and selected-city-related recent spy result.
- Localized relation status display and kept raw internal relation ids out of the visible diplomacy UI.
- Removed visible web-version/display-only/placeholder/Godot-facing copy from the City Detail diplomacy/spy render path.
- Removed public support details, city loyalty details, revolt-risk details, troop movement, recruitment, city storage, resource potential, trade details, supply adjustments, and military-card information from the diplomacy/spy tab display.
- Kept actual diplomacy and spy execution behavior as follow-up work; no new action execution, roll, resource spending, turn consumption, or relation mutation was connected.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change resource tab/cards, trade tabs, Selected City Panel, recruitment, troop movement, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-27 Selected City Stability + Military Card Polish
- Built on `v0.70-26 External Trade Tab Structure Polish` (`5021d47`).
- Reworked the right Selected City Panel loyalty area into a `성 안정도` card.
- Added a stability label to `성 충성도` using the displayed loyalty value.
- Added Selected City Panel revolt-risk display using the existing revolt-risk result path and Korean UI labels: `낮음`, `주의`, and `위험`.
- Grouped `병력`, `방어`, `치안 기준`, `병사 충원`, `징병`, `모병`, and the existing `모병 100` button into a runtime `군사` card.
- Preserved the existing recruitment signal/button behavior while moving the button into the military card.
- Modified files: `scripts/worldmap_city_info_panel.gd`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change City Detail resource/internal-trade/external-trade/diplomacy tabs, governor assignment/policy, garrison, hero movement, attack, help, formulas, troop movement, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-26 External Trade Tab Structure Polish
- Built on `v0.70-25 Internal Trade Tab Ownership Filter Polish`.
- Updated City Detail `무역 > 타국무역` so external trade candidates are foreign neighboring cities only.
- Excluded player-owned neighboring cities from external trade candidates.
- Added external trade candidate filtering helpers and display helpers for candidate city/faction, relation status, trade availability, relation-based efficiency, and future trade leadership.
- Added empty-state copy for no adjacent foreign trade candidates.
- Localized relation status display from internal ids to Korean UI labels.
- Kept recent trade results as only a short selected-city-related record summary and stopped exposing resource-total/route-detail blocks on the tab.
- Removed public support, city loyalty, loyalty drift, seasonal loyalty, revolt risk, troop movement, recruitment/conscription, military supply judgment, and supply-adjustment details from the external trade tab display.
- Kept `재상 위임 / 수동 조정` as a future trade-leadership information slot only; no real trade adjustment behavior was implemented.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change resource tab/storage cards, internal trade, diplomacy/spy, Selected City Panel, troop movement logic, recruitment logic, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-25 Internal Trade Tab Ownership Filter Polish
- Built on `v0.70-24a City Storage Gold Source Fix + Resource Card Polish`.
- Updated City Detail `무역 > 자국무역` so internal trade candidates are player-owned neighboring cities only.
- Hanseong-only ownership now shows an empty state instead of listing foreign neighboring cities as internal trade routes.
- Added empty-state copy with owned-city count and connected-player-city absence.
- Removed public support, loyalty drift, seasonal loyalty, revolt risk, manual troop movement, troop movement button text, recruitment, and conscription from the internal trade tab display.
- Localized supply role/status display from internal English ids to Korean UI labels.
- Hid supply adjustment loyalty/security details from the internal trade tab while preserving the internal calculation helpers.
- Kept `재상 위임 / 수동 조정` as a future trade-leadership information slot only; no real trade adjustment behavior was implemented.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change resource tab/storage cards, external trade, diplomacy/spy, Selected City Panel, troop movement logic, recruitment logic, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-24a City Storage Gold Source Fix + Resource Card Polish
- Built on `v0.70-24 City Storage Resource Tab MVP`.
- Removed the upper resource-tab economy display of `city_data.gold`.
- Renamed the upper economy block to `경제 잠재력` and limited it to population and commerce potential.
- Unified real city-held gold display under `성 창고`, sourced from `storage.gold`.
- Fixed the missing-storage fallback bug by checking whether the `storage` key exists before normalization.
- Preserved explicitly saved Dictionary storage, including all-zero storage, while using default storage for missing or non-Dictionary storage.
- Hanseong missing storage now correctly falls back to the current national warehouse/resource stock: gold 500, rice 300, barley 250, seafood 80, wood 100, iron 50, horses 30, silk 30, salt 50.
- Split `자원 잠재력` and `성 창고` into bordered runtime card wrappers and changed storage group formatting to summary/detail line pairs.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change national warehouse UI, national `resource_stock` calculations, trade, turn production, supply consumption, upkeep, recruitment, battle loot, BattleContext, resource seeds, domestic seeds, formulas, `project.godot`, assets, `.uid`, or `.ogv` files.

## v0.70-24 City Storage Resource Tab MVP
- Built on `v0.70-23-hotfix2 Full GDScript Ternary Compatibility Sweep` (`207a76e`).
- Added city runtime `storage` helpers in `scripts/worldmap_test.gd`.
- City storage uses the MVP structure `gold`, `rice`, `barley`, `seafood`, `wood`, `iron`, `horses`, `silk`, and `salt`.
- Hanseong default storage is initialized from the current national `resource_stock`: gold 500, rice 300, barley 250, seafood 80, wood 100, iron 50, horses 30, silk 30, salt 50.
- Other cities default to zero storage unless a runtime/loaded city payload provides explicit `storage`.
- City Detail `자원` tab now preserves the existing resource-potential star rows and adds a `성 창고` section below economy.
- `성 창고` displays gold, food total/detail, strategy total/detail, and specialty total/detail with simple `안정` / `주의` / `부족` status text.
- Save/load now includes `storage` in serialized city runtime payloads and restores safe defaults for older saves without the key.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change national warehouse UI, national `resource_stock`, turn production, trade movement, supply consumption, upkeep, recruitment, battle loot, BattleContext, formulas, `WorldMap_Test.tscn`, `project.godot`, or assets.

## v0.70-23-hotfix2 Full GDScript Ternary Compatibility Sweep
- Built on `v0.70-23-hotfix1 City Detail Drag + GDScript Reload Warning Fix` (`b8ca197`).
- Performed a full repo `.gd` ternary sweep with `rg " if .* else " --glob "*.gd"`.
- Converted type-risk ternaries to explicit `if/else` in `scripts/worldmap_city_info_panel.gd`, `scripts/player_attack_deployment_panel.gd`, `scripts/battle_web_import_test.gd`, `scripts/worldmap_city_marker.gd`, and recent City Detail chrome paths in `scripts/worldmap_test.gd`.
- Rechecked the `visible` parameter shadowing search; no matching function parameters remain.
- Remaining ternaries are only in `scripts/worldmap_test.gd` and are same-type scalar/value selections.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `scripts/player_attack_deployment_panel.gd`, `scripts/battle_web_import_test.gd`, `scripts/worldmap_city_marker.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change UI design, help copy, City Detail/trade/diplomacy/spy content, calculations, save/load, BattleContext, `project.godot`, or assets.

## v0.70-23-hotfix1 City Detail Drag + GDScript Reload Warning Fix
- Built on `v0.70-23 WorldMap City Detail Resource Tab Slim Polish` (`94b404b`).
- Added `city_detail_header_row` to CityDetailPanel drag handle registration so the expanded panel can be dragged from the visible top row.
- Preserved collapsed panel drag and click-only expand behavior through the existing `_collapsed_unified_panel_click_candidate` threshold flow.
- Did not register `CollapseButtonPlaceholder`, primary tab buttons, diplomacy/trade/resource tab buttons, or resource/trade secondary tab buttons directly as drag handles.
- Renamed the `_set_city_detail_body_labels_visible()` parameter from `visible` to `should_show` to remove the CanvasItem `visible` shadowing reload warning.
- Replaced type-unclear `Dictionary` ternaries in recently touched WorldMap scripts with explicit `Variant` extraction and `if` type checks.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change City Detail resource content, trade/diplomacy/spy structure, help copy, recruitment, formulas, battle scenes, BattleContext, save/load, `project.godot`, or assets.

## v0.70-23 WorldMap City Detail Resource Tab Slim Polish
- Built on `v0.70-22-hotfix1 GDScript Ternary Type Compatibility Fix` (`789c2de`).
- Slimmed the City Detail resource tab to city name, resource potential, and economy potential.
- Resource tab now shows `식량 자원`, `전략 자원`, `특산 자원`, and `경제` blocks, with gold placed under economy.
- Removed Selected City Panel duplication from the resource tab: type/faction, loyalty, troops, security baseline, defense, status, governor, and stationed hero count.
- Removed visible `CITY DETAIL / DIPLOMACY` / web-version display-only / no-domestic-turn placeholder copy from the City Detail resource path.
- Reorganized unified panel primary tabs to `도시 상세`, `외교·첩보`, `무역`, and `접기`.
- Moved `자국무역` / `타국무역` into the trade-family secondary tab flow without rewriting trade calculations.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change city data values, resource seeds, domestic formulas, governor/chancellor formulas, trade/diplomacy/spy calculations, battle scripts, BattleContext, save/load schema, `project.godot`, or assets.
- Tech tree UI remains a follow-up after this panel split. Help MVP, recruitment, governor, attack, and battle flows were preserved.

## v0.70-22-hotfix1 GDScript Ternary Type Compatibility Fix
- Built on `v0.70-22 WorldMap Implemented Help Modal MVP` (`720c0a9`).
- Replaced the newly added selected-city help-row anchor ternary with an explicit `Control` variable and `if/else` assignment.
- Fixed the Godot 4 reload risk: `Values of the ternary operator are not mutually compatible`.
- Modified files: `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, and `agent/SESSION_LOG.md`.
- Did not change help copy, UI layout intent, formulas, battle scenes, save/load, `project.godot`, or assets.

## v0.70-22 WorldMap Implemented Help Modal MVP
- Built on `v0.70-21 WorldMap Recruitment Loyalty-Based Connect` (`5d730bb`).
- Added five WorldMap help topics for 국가충성도, 성 충성도, 민심, 치안, and 주둔무장.
- Added small runtime help buttons near the left national loyalty gauge and right selected-city loyalty/domestic/garrison sections.
- Added one reusable `WorldMapHelpModal` under `WorldMapUI` with title, compact body copy, close button, and Esc close support.
- Help copy is based on currently implemented systems only and avoids formulas, multipliers, and unimplemented player actions.
- Documented 국가충성도 as tax/political chancellor/domestic stability management, 성 충성도 as tax/security/supply/political governor or chancellor/publicSupport stability, 민심 as tax/food/commerce/supply, 치안 as stationed troops/supply/minimum garrison, and 주둔무장 as governor candidates/battle deployment/city defense/command-limit usage.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change scenes, domestic formulas, tax formulas, governor/chancellor formulas, battle scripts, BattleContext, save/load schema, `project.godot`, or assets.

## v0.70-21 WorldMap Recruitment Loyalty-Based Connect
- Built on `v0.70-20a WorldMap Selected City Panel Layout Order Polish`.
- Changed recruitment amount limits from publicSupport-based to city loyalty-based: `<40` = 0, `40-59` = 100, `60-79` = 200, `80-89` = 300, `90+` = 500.
- Kept recruitment cost unchanged: gold = amount, food = floor(amount / 2), with food paid from national `resource_stock` in rice -> barley -> seafood order.
- Kept conscription as the automatic loyalty + `barracks` + `conscription_system` axis. `barracks` is still required, and `conscription_system` keeps the existing 1.10 effect.
- Connected the right Selected City Panel `병사 충원` section with concise conscription/recruitment status lines and a `모병 100` button.
- Added `recruitment_requested(city_id, amount)` from `WorldMapCityInfoPanel` and handled it in `worldmap_test.gd` through `_can_recruit_troops()` and `_recruit_troops()`.
- `last_recruitment_result` now records `loyalty` and `loyalty_limit`; publicSupport remains recorded for compatibility and future risk/fatigue systems, but it is not the recruitment limit basis.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Excluded population decrease, recruitment fatigue, loyalty/publicSupport loss after recruitment, revolt-risk changes, tech-tree UI, troop-type recruitment, recruitment amount selector UI, battle/BattleContext changes, ownership changes, hero movement changes, policy formula changes, large save/load rewrite, `project.godot`, and assets.

## v0.70-20a WorldMap Selected City Panel Layout Order Polish
- Built on `v0.70-20 WorldMap Selected City Governor Garrison & Hero Transfer Polish` (`0e5cd21717d1364a591a0abfaf42e732eb17550a`).
- Reordered the selected-city panel to city summary -> city state summary -> governor card -> garrison card -> hero transfer -> military summary -> recruit.
- Moved `민심 / 치안 / 상업 / 농업` directly under the city loyalty card as a compact one-line summary.
- Kept governor effect/policy display inside the governor card as `효과: ...` and `정책: ...`, matching the left chancellor card rhythm.
- Removed the duplicate lower governor policy hint path that could repeat `태수 정책: 효과: ...`.
- Wrapped `주둔 무장` hero portrait/name/stat rows in a card-style container.
- Moved `무장 이동` directly below the garrison card and preserved the existing inline hero-transfer UI.
- Hid the selected-city `내정` button; Domestic Panel work remains deferred.
- Moved `병력 / 방어 / 치안 기준` below garrison/transfer and placed the recruit area below that military summary. v0.70-21 supersedes it with connected `병사 충원`.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change governor assignment logic, governor policy save/load, hero transfer data movement, battle scripts, BattleContext, formulas, recruitment processing, `project.godot`, `.uid` / `.ogv` files, or assets.

## v0.70-20 WorldMap Selected City Governor Garrison & Hero Transfer Polish
- Built on `v0.70-19a Agent Docs Handoff & ChatCoach Role Lock` (`5b1d131d4ea8eaa2e2746e479a90c77837741304`).
- Added a visible `태수` title above the selected-city governor card while preserving `GovernorAssignOption` and `GovernorPolicyOption`.
- Replaced the plain selected-city garrison text display with dynamic `주둔 무장` rows showing portrait/placeholder, hero name, and short stat summary.
- Reused `WorldMapHeroPortraitHelper` for garrison portraits; no new image assets were added.
- Connected the existing `무장 이동` button to an inline hero transfer MVP with hero dropdown, adjacent player-city target dropdown, confirm, cancel, and empty-state messages.
- Transfer confirmation moves a hero from source `stationed_hero_ids` / `hero_ids` to target `stationed_hero_ids` / `hero_ids`, updates hero runtime city, refreshes UI, and clears source `governor_id` when the moved hero was governor.
- Existing save/load already persists city rosters and hero runtime city state, so no save schema expansion was required.
- Web reference checked: `openHeroTransfer`, `selectHeroTransferHero`, `selectHeroTransferTargetCity`, `confirmHeroTransfer`, `transferHeroToCity`, and related world-map transfer UI bindings.
- Modified files: `scripts/worldmap_city_info_panel.gd`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change `WorldMap_Test.tscn`, `project.godot`, battle scripts, BattleContext, combat/result accounting, domestic/trade/relation formulas, governor/chancellor policy formulas, `.uid` / `.ogv` files, or assets.

## v0.70-19a Agent Docs Handoff & ChatCoach Role Lock
- Built on `v0.70-19 WorldMap Selected City Governor Assignment & Policy Connect` at `4c671b0e7599ade817d1274768f04b879a757ca4`.
- Documentation-only handoff update; no code, scene, asset, script, `project.godot`, battle, or WorldMap runtime files changed.
- Recorded the current stable state after battle cinematic guards, movement-facing polish, left-panel polish, selected-city panel slim polish, and selected-city governor assignment/policy connection.
- Recorded the domestic-system philosophy: rich internal simulation, minimal decision-grade UI summaries, no full formula/multiplier exposure, and separate national chancellor policy versus city governor policy roles.
- Locked ChatCoach/Codex responsibilities: ChatCoach checks GitHub/git-accessible code/docs and defines evidence-based scope; Codex executes, modifies, verifies, and creates local commits.
- Recorded known safety cautions: keep Theora `.uid` / `.ogv` files, avoid `git clean`, never push, confirm `WorldMap_Test.tscn` serialization diffs, and avoid feature work from dirty state.
- Updated next candidate work to `v0.70-20`, `v0.70-21`, `v0.70-22`, and `v0.70-23`.
- Modified files: `agent/WORKFLOW_MANAGER.md`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.

## v0.70-19 WorldMap Selected City Governor Assignment & Policy Connect
- Built on requested `v0.70-18 WorldMap Selected City Panel Anchor & Summary Slim Polish` (`7f937fe`); actual pre-edit HEAD was clean `fd2eb4e 월드맵작업`, which changed only `WorldMap_Test.tscn`.
- Added `GovernorAssignOption` to the selected-city `GovernorCard`.
- Added `governor_assignment_requested(city_id, governor_id)` to `scripts/worldmap_city_info_panel.gd`.
- Populates governor candidates from the selected city's `stationed_hero_ids`, with `미임명` as the first entry.
- Connected governor assignment in `scripts/worldmap_test.gd` so the selected city's mutable runtime `governor_id` is updated and the selected-city/city-detail UI refreshes.
- Preserved the existing `GovernorPolicyOption` runtime path through `_city_policy_state[city_id]`.
- Saved/loaded city `governor_id`, city `governor_policy_id`, and top-level `city_policy_state`, with fallback compatibility for older saves.
- Replaced selected-city governor policy copy that exposed `재상 정책 수행`, `Godot에서는 표시 전용`, placeholder/no-effect text, or "No city stat or turn effect applied".
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change governor exclusivity, hero movement, stationed rosters, wounded/captured/dead governor rules, domestic/trade/relation formulas, turn-income/security calculations, city ownership/troop/resource calculations, battle scripts, `BattleContext`, `project.godot`, `.uid`/`.ogv` assets, or new assets.

## v0.70-18 WorldMap Selected City Panel Anchor & Summary Slim Polish
- Built on `v0.70-17b Restore Theora Test UID Files` (`9b8b186`) after the residual `WorldMap_Test.tscn` scene serialization diff was restored and the repo was clean.
- Added a selected-city panel startup anchor helper in `scripts/worldmap_test.gd` so `CityInfoPanel` starts at the shared top baseline and right-side 10px margin while remaining a `WorldMapUI` CanvasLayer child.
- Preserved existing selected-city panel drag movement through the city name handle.
- Updated `WorldMap_Test.tscn` initial `CityInfoPanel` offsets to the same right-side baseline and kept its existing size.
- Hid the `SELECTED CITY` eyebrow.
- Slimmed selected-city summary display to city name, `세력: ...`, `유형: ...`, and the loyalty card.
- Removed `표시 전용` from the selected-city loyalty label.
- Hid owner/region/nation duplication, population/gold/food row, resource list, city status sentence, and governor summary label.
- Kept governor card/dropdown, garrison list, military/domestic summary, policy hint, and attack/hero move/domestic/recruit controls.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, and `agent/WORLDMAP_RULES.md`.
- Did not change left panel content, city detail/diplomacy panels, city data, city click/battle entry, camera handoff, safe-zone camera, domestic/trade/relation formulas, governor internals, resource data, save/load, battle scripts, project settings, `.uid`/`.ogv` files, or assets.

## v0.70-17b Restore Theora Test UID Files
- Built on `v0.70-17a Repo Sanity Cleanup Before Selected City Panel Work` (`110f0e8`).
- Restored `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `assets/video_test/theora_safe/test_safe_q8_1920x.ogv.uid` from `HEAD~1`.
- The Theora test `.uid` files are retained for Godot resource UID reference stability.
- Preserved `assets/video_test/theora_safe/test_safe_q7_1280x.ogv` and `assets/video_test/theora_safe/test_safe_q8_1920x.ogv`.
- Left the existing `WorldMap_Test.tscn` working-tree change uncommitted. WorldMap_Test.tscn modified remains uncommitted.
- Modified files for the restore commit: the two `.uid` files plus `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, and `agent/SESSION_LOG.md`.
- Did not change scripts, battle scenes, `project.godot`, `.ogv` sources, or selected-city panel behavior.

## v0.70-17a Repo Sanity Cleanup Before Selected City Panel Work
- Built on the state after `v0.70-16 WorldMap Left Panel Chancellor Card Polish`; pre-cleanup HEAD was `91713d8 제거목적`.
- Confirmed HEAD `91713d8` added only the two Theora test Godot `.uid` artifacts.
- Removed `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `assets/video_test/theora_safe/test_safe_q8_1920x.ogv.uid` from tracking and disk with `git rm`.
- Preserved `assets/video_test/theora_safe/test_safe_q7_1280x.ogv` and `assets/video_test/theora_safe/test_safe_q8_1920x.ogv`; `git clean` was not used.
- Analyzed the existing `WorldMap_Test.tscn` working-tree diff and left it uncommitted. WorldMap_Test.tscn modified remains uncommitted.
- Modified files for the cleanup commit: the two `.uid` deletions plus `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, and `agent/SESSION_LOG.md`.
- Did not change `WorldMap_Test.tscn`, scripts, battle scenes, `project.godot`, `.ogv` sources, or selected-city panel behavior in this commit.

## v0.70-16 WorldMap Left Panel Chancellor Card Polish
- Built on `v0.70-15 WorldMap Left Panel Header & Tax Slim Polish` (`5dec9b2`).
- Analyzed latest git history before edits and confirmed the only pre-existing worktree noise was two untracked Godot `.uid` files, left untouched; pre-existing untracked Godot .uid files ignored.
- Reduced `WORLD_UI_LEFT_MARGIN` from `18.0` to `10.0` in `scripts/worldmap_test.gd` so the left panel X margin matches the current top margin.
- Updated `WorldMap_Test.tscn` so `LeftWorldStatusPanel` starts at left `10` / right `330`, preserving its width, height, top margin, content order, and CanvasLayer placement.
- Simplified the chancellor card unassigned state to `미임명` with `효과: 없음` and `정책: 보정 없음`.
- Removed assigned-state name repetition from `재상 임명: 이름` and from the effect text; the name appears once in the top summary and dropdown selection remains allowed.
- Changed chancellor effect/policy display to `효과: ...` / `정책: ...` while preserving existing calculation and dropdown state.
- Enlarged the chancellor portrait frame from `42 x 42` to `56 x 64`, enabled clipping, and changed the runtime portrait `TextureRect` to aspect-covered display.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Did not change `scripts/battle_web_import_test.gd`, `project.godot`, battle calculations, BattleContext, city data, city click/battle entry, camera handoff, domestic/trade/relation formulas, chancellor effect/policy calculations, tax internal calculations, save/load structure, warehouse polish, right/city-detail panel content, or assets.

## v0.70-15 WorldMap Left Panel Header & Tax Slim Polish
- Built on `v0.70-14a WorldMap Panel Top Margin Baseline Polish` (`502f1eb`).
- Analyzed latest git history before edits and confirmed the only pre-existing worktree noise was two untracked Godot `.uid` files, left untouched; pre-existing untracked Godot .uid files ignored.
- Reduced shared fixed-panel `WORLD_UI_TOP_MARGIN` from `16.0` to `10.0` in `scripts/worldmap_test.gd`.
- Updated `WorldMap_Test.tscn` so `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` start at top `10` while preserving current X positions, widths, heights, content order, and styles.
- Slimmed the left panel turn header to one visible runtime calendar/turn line such as `154년 봄 1턴`; `World Turn`, `제 N턴`, and phase/selected/base-city header labels remain as hidden nodes.
- Slimmed the tax card to national loyalty label/bar plus tax level label/slider; the duplicate tax bar, tax preview sentence, and public-order duplicate bar are hidden.
- Kept tax normalization, slider sync, loyalty/public-order state reads, turn-end use, save/load structure, and CanvasLayer camera independence intact.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Did not change `scripts/battle_web_import_test.gd`, `project.godot`, battle calculations, BattleContext, city data, city click/battle entry, domestic/trade/relation formulas, chancellor formulas, tax internal calculations, save/load structure, right/city-detail panel content, or assets.

## v0.70-14a WorldMap Panel Top Margin Baseline Polish
- Built on `v0.70-14 WorldMap Left Panel Anchor & World Turn Lock` (`ab91b34`).
- Analyzed latest git history before edits and confirmed the only pre-existing worktree noise was two untracked Godot `.ogv.uid` files, left untouched.
- Added `WORLD_UI_TOP_MARGIN = 16.0` and `WORLD_UI_LEFT_MARGIN = 18.0` in `scripts/worldmap_test.gd`.
- Updated `WorldMap_Test.tscn` so `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` all start at top `16` while preserving current X positions, widths, heights, content, and styles.
- Added `_lock_worldmap_fixed_panel_top_margin()` / `_lock_screen_panel_top_margin()` to reapply the common top baseline to the fixed WorldMap information panels at runtime.
- Hid the retired `WorldMapUI/TitleLabel` / `SamWar HUD MVP` debug label in the scene and runtime guard path to prevent overlap with the raised left panel.
- Confirmed the affected panels remain `WorldMapUI` CanvasLayer children and independent from `WorldMapCamera` pan/zoom.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Did not change `scripts/battle_web_import_test.gd`, `project.godot`, battle calculations, BattleContext, city data, city click/battle entry, domestic/trade/relation formulas, panel information structure, or assets.

## v0.70-14 WorldMap Left Panel Anchor & World Turn Lock
- Built on requested `v0.70-13d Battle Movement Facing Direction Polish`; actual pre-edit HEAD was `e53a9fb v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`.
- Analyzed latest git history before edits and confirmed existing untracked `.ogv.uid` files were pre-existing and left untouched.
- Stabilized `WorldMap_Test.tscn` `WorldMapUI/LeftWorldStatusPanel` as a top-left anchored screen UI panel at `(18, 56)` with size/minimum size `320 x 570`.
- Added `WorldTurnSeparator` after the top World Turn labels so the turn header reads as a fixed head area before the national/chancellor/warehouse/save sections.
- Added `_lock_left_world_status_panel_anchor()` in `scripts/worldmap_test.gd` to reapply top-left anchor, position, size, and minimum size at runtime.
- Added `_lock_world_turn_header_order()` to keep `World Turn`, turn number, calendar, phase/city line, and separator as the first children of the left panel content.
- Removed left panel drag registration while preserving right-side panel drag registration.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Did not change `scripts/battle_web_import_test.gd`, `project.godot`, battle calculations, BattleContext, city data, city click/battle entry, domestic/trade/relation formulas, right panel redesign, or assets.

## v0.70-14 WorldMap Battle Entry Camera Zoom Handoff
- Built on `v0.70-13d Battle Movement Facing Direction Polish` (`8991b9b51f91aead893df51f2ee07e1b532bed34`).
- Analyzed latest git history before edits: HEAD changed only battle movement-facing code in `scripts/battle_web_import_test.gd` plus agent docs; two untracked Godot `.ogv.uid` files already existed and were left untouched.
- Added a WorldMap camera handoff in `scripts/worldmap_test.gd` immediately before the existing battle scene transition.
- Split final battle transition into `_change_scene_to_battle_with_context()` so `Engine.set_meta("samwar_worldmap_battle_context", context)` and `change_scene_to_file("res://Battle_Fullscreen_Test.tscn")` remain the final boundary after the camera tween.
- Added `_get_worldmap_city_visual_position()` and `_build_worldmap_battle_entry_focus()` to resolve source/target city visual coordinates from existing city markers and focus toward the battle target.
- Added `_start_worldmap_battle_entry_camera_handoff()`, `_complete_worldmap_battle_entry_camera_handoff()`, and `_skip_worldmap_battle_entry_camera_handoff()` for one-shot pan/zoom/hold/skip lifecycle.
- Added `_worldmap_battle_entry_handoff_in_progress` duplicate-entry guard around player attack, defense choice, deployment confirmation, final handoff, and camera input while the handoff is active.
- Missing camera or city coordinates fall back immediately to the existing battle transition without generating fake ids or changing BattleContext keys.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Did not change `scripts/battle_web_import_test.gd`, scenes, assets, `project.godot`, combat formulas, battle intro/result video, BattleContext structure, ownership/troop/hero result application, domestic, trade, or relation logic.

## v0.70-13d Battle Movement Facing Direction Polish
- Built on the requested `v0.70-13b Battle Cinematic Lifecycle Guard Audit` code baseline; actual pre-edit HEAD was `0c91744 v0.70-13c Battle WorldMap Return Contract Prep`, which was docs-only.
- Fixed movement visual facing so ally and enemy path movement update left/right facing at each horizontal segment start.
- Added `_get_horizontal_facing_from_step()` and `_apply_unit_movement_facing()` in `scripts/battle_web_import_test.gd`.
- Vertical-only movement preserves the current facing instead of forcing up/down or a new left/right state.
- Reused existing token flip/texture logic through `_apply_unit_facing_visuals()` and `_apply_token_facing_visual()`.
- Reapplied the current movement offset after segment-facing updates so the token and hero portrait placement stay aligned during path movement.
- Preserved final post-move direction selection as the final facing owner; ally movement no longer immediately re-faces toward the enemy before direction selection.
- Modified files: `scripts/battle_web_import_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`.
- Did not change pathfinding, move range, move duration/speed, action/turn flow, combat calculations, attack/damage/result judgment, cutins, archer/gunner FX, BattleContext, WorldMap logic, scenes, assets, project settings, intro lifecycle, or result-video lifecycle.

## v0.70-13c Battle WorldMap Return Contract Prep
- Built on `v0.70-13b Battle Cinematic Lifecycle Guard Audit` (`f56903d`).
- Analyzed latest git history before edits: HEAD contained cinematic lifecycle guard changes in `scripts/battle_web_import_test.gd` plus agent docs; no WorldMap entry/return contract code changed in that baseline.
- Audited WorldMap -> Battle entry through `scripts/worldmap_test.gd`, including player attack deployment, enemy invasion defense deployment, BattleContext construction, and Engine meta handoff.
- Audited Battle internal context consumption and result payload generation in `scripts/battle_web_import_test.gd`.
- Audited Battle -> WorldMap return through `samwar_worldmap_battle_result`, `res://WorldMap_Test.tscn`, and existing result dispatch in `worldmap_test.gd`.
- Documented existing contract keys and missing/non-literal keys for the next camera handoff work.
- Documented v0.70-14 safe connection points: `_city_markers_by_id`, `world_map_camera`, camera clamp/zoom helpers, and `_handoff_battle_context_to_battle_scene()`.
- Modified files: `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Did not modify runtime scripts, scenes, assets, `project.godot`, combat calculations, battle result judgment, WorldMap city ownership, troop application, hero status application, or the battle return button flow.

## v0.70-13b Battle Cinematic Lifecycle Guard Audit
- Built on `v0.70-13a Battle Intro Wide Hold Timing Polish Stable` (`6f46bf1`).
- Analyzed latest git history before edits: HEAD only adjusted intro wide hold / zoom timing and agent docs; `493c8e8` introduced battle intro camera zoom lifecycle; `d2dbefa` and `76e0421` introduced/polished result video before result toasts.
- Added `battle_intro_camera_has_started` to prevent duplicate intro startup within one battle reset lifecycle.
- Unified intro natural finish and skip cleanup through `_complete_battle_intro_camera_zoom()`.
- Ensured intro cleanup restores gameplay camera position/zoom, restores `BattleUI`, clears tween references, and clears captured gameplay-camera state once.
- Hardened result video lifecycle cleanup so player stream, visibility, backdrop visibility, pending result state, and completion guard are reset in the correct paths.
- Guarded repeated same-state result video start while video playback is already pending so it does not fall through to a duplicate toast path.
- Modified files: `scripts/battle_web_import_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`.
- Did not change battle calculations, attack/damage/win-loss judgment, unique skill cutins, archer/gunner FX, BattleContext, WorldMap logic, scenes, assets, or project settings.

## v0.70-12 Battle Result Video Before Victory/Defeat Toast
- Added victory/defeat result source MP4s under `assets/video_source_test/result_dry_run/`.
- Encoded q8 1920x Theora result videos under `assets/ui/result/videos/`.
- Added `ResultOverlay/VideoStreamPlayer_Result` to `Battle_Fullscreen_Test.tscn`.
- Added result video constants and dedicated playback helpers in `scripts/battle_web_import_test.gd`.
- `_try_show_battle_result_toast_if_needed()` now first attempts `_play_battle_result_video_before_toast()` and only queues the existing result toast after the video finishes.
- Existing result toast UI/resources/text/timing are preserved through `_show_battle_result_toast_after_video()`.
- Added load-failure fallback to the existing toast and a `BATTLE_RESULT_VIDEO_FALLBACK_DURATION_SEC` timer guard if the video `finished` signal does not arrive.
- Did not change victory/defeat judgment, battle result payload, WorldMap result return logic, special-skill cutin mappings/assets, archer volley FX, or gunner shot FX.

## v0.70-11 Unit Type Attack Range Baseline
- Added `_get_default_attack_range_for_unit_type()` and `_get_default_attack_range_for_visual_key()` in `scripts/battle_web_import_test.gd`.
- Normal/basic attack range defaults are now explicit: infantry `1`, cavalry `1`, archer `3`, gunner `4`.
- Updated test battle unit creation to use the unit-type baseline helper instead of scattered literal `attack_range` values.
- Fixed the test battle gunner baseline so Jeong Do Jeon, Eulji Mundeok, and Zhuge Liang resolve to normal `attack_range = 4`.
- Preserved archer normal `attack_range = 3` for Yi Sunsin, Kim Yu-sin, and Liu Bei.
- Preserved melee normal `attack_range = 1` for infantry/cavalry units.
- Did not change unique skill range, strategy range, move range, damage, hit chance, troop loss, turn progression, archer/gunner FX, cutin assets/mappings, or WorldMap scripts.
- WorldMap context attack range data was inspected but not rewritten; explicit WorldMap ranges remain untouched by this test battle baseline patch.

## v0.70-10 Gunner Muzzle Flash + Tracer Impact Visual
- Added gunner-only normal/basic attack FX in `scripts/battle_web_import_test.gd`.
- Added `_play_gunner_shot_effect`, `_spawn_gunner_muzzle_flash`, `_spawn_gunner_tracer`, and `_spawn_gunner_impact_pop`.
- Added gunner timing constants including `GUNNER_MUZZLE_FLASH_DURATION`, `GUNNER_TRACER_DURATION`, `GUNNER_IMPACT_POP_BEGIN`, and `GUNNER_SMOKE_LINGER_DURATION`.
- Gunner eligibility uses existing unit type / visual-key resolution, covering `jeong_dojeon`, `eulji_mundeok`, and `zhuge_liang` when they resolve as gunners.
- Runtime gunner FX is generated with primitive `Polygon2D`, `Line2D`, and `Node2D` spark/smoke nodes; no new gunner asset files were added.
- The effect adds a short directional muzzle flash, fast thin tracer, compact impact spark, and small smoke fade on top of the existing attack FX flow.
- Preserved existing archer volley behavior and combat resolution; gunner and archer hooks are mutually exclusive.
- Did not change damage, hit chance, troop loss, turn progression, unique/special skill effects, cutin assets/mappings, or WorldMap logic.

## v0.70-9c Archer Curved Volley + Visual Completion Timing Guard
- Tuned archer-only normal/basic attack volley FX in `scripts/battle_web_import_test.gd`.
- Added `_play_arrow_projectile_effect`, `_spawn_arrow_projectile`, and `_spawn_arrow_impact_pin`.
- Added volley timing/impact constants including `ARROW_VOLLEY_VISUAL_COUNT` and `ARROW_IMPACT_POP_BEGIN`.
- Preserved the v0.70-9b readability baseline: `ARROW_VOLLEY_VISUAL_COUNT = 9`, `0.34`-`0.50` second travel, and `0.05`-`0.12` second launch stagger.
- Kept the slightly longer/brighter runtime `Line2D` arrow stroke for readability without adding assets.
- Added `ARROW_CURVE_OFFSET_MIN`, `ARROW_CURVE_OFFSET_MAX`, and `_get_arrow_curve_midpoint()` so arrows fly through a subtle curved midpoint instead of a perfectly straight line.
- Added `ARROW_VOLLEY_COMPLETION_PAD_SEC`, `_get_arrow_volley_blocking_duration()`, and `_get_arrow_volley_completion_extra_wait()` to keep archer basic-attack sequencing from advancing before the last arrow flight/impact completes.
- The sequencing guard does not block on the full pinned-arrow linger/fade.
- Archer eligibility uses existing unit type / visual-key resolution, covering `yi_sunsin`, `gim_yusin`, and `liu_bei` when they resolve as archers.
- Runtime arrows and impact pins are generated with `Line2D`; no new arrow asset files were added.
- Preserved existing slash/spark/dust FX and combat resolution while layering arrows on top for archer basic attacks only.
- Did not change damage, hit chance, troop loss, turn progression, unique/special skill effects, cutin assets/mappings, or WorldMap logic.

## v0.70-8b Yi Sun-sin + Eulji Mundeok Mirrored Cutin Layouts
- Mirrored only Yi Sunsin and Eulji Mundeok specialty cutin presentation configs.
- Yi Sunsin now places the portrait on the right and Hakikjin title image on the left.
- Eulji Mundeok now places the portrait on the right and Salsu Daechop title image on the left.
- Added `layout_mirror` handling so mirrored heroes enter from the right and their title image enters from the left while non-mirrored heroes keep existing motion.
- Preserved Kwon Yul, Jeong Do Jeon, and Kim Yu-sin hero-left/title-right layout values.
- Did not change q8 OGV assets, video mapping order, fallback chains, special-skill trigger logic, cutin assets, WorldMap logic, or battle command behavior.

## v0.70-8 Kim Yu-sin + Eulji Mundeok Special-Skill Cutin Integration
- Verified Kim Yu-sin and Eulji Mundeok source MP4s: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Verified new portrait/title PNG assets with alpha:
  - `kim_yu_sin_cutin.png`, `kim_yu_sin_samguktongil_title.png`
  - `eulji_mundeok_cutin.png`, `eulji_mundeok_salsudaecheop_title.png`
- Encoded q8 1920x Theora outputs:
  - `assets/ui/cutin/videos/kim_yu_sin_cutin_bg_theora_q8_1920x.ogv`, Theora 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `6365944` bytes.
  - `assets/ui/cutin/videos/eulji_mundeok_cutin_bg_theora_q8_1920x.ogv`, Theora 1920x1080, yuv420p, `30/1`, stream duration `N/A`, format duration `2.005333`, size `8318109` bytes.
- Added `gim_yusin` and `eulji_mundeok` to `SPECIALTY_SKILL_CUTIN_VIDEO_PATHS` and `SPECIALTY_SKILL_CUTIN_CONFIGS`.
- Wired each hero's portrait/title path into the existing specialty cutin presentation layer with conservative independent layout values.
- Preserved Yi Sunsin, Kwon Yul, and Jeong Do Jeon q8 mappings/configs/fallback chains.
- Did not add or modify any reinforcement-arrival cutin hook; trigger remains unique/special-skill activation through `_begin_unique_skill_sequence()`.
- Removed tracked Theora-safe frame-capture `.import` junk using limited pathspecs only.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and ResourceLoader checks for new and existing cutin resources.

## v0.70-7b Kim Yu-sin Tactical Cell Clickability Root-Cause Fix
- Strengthened floating command panel distance scoring so selected-unit-near candidates beat detached viewport-corner fallback positions unless the fallback is truly necessary.
- Fixed Kim Yu-sin move-cell clickability by trying valid highlighted move-cell clicks before ally unit selection during ally turn.
- Diagnosed the Kwon Yul-adjacent unreachable-feeling cell as likely ally click-area preemption of a valid highlighted move target; rendered move overlays already filter through `is_valid_move_target()`.
- Changed ally click selection to collect overlapping ally click areas and choose the closest unit, matching the safer enemy click selection pattern.
- Ignored disabled/non-pickable unit click areas in the manual hit test so hidden/reserve click areas cannot consume battlefield clicks.
- Did not change cutin assets, q8 Theora mappings, title PNGs, production video files, or WorldMap logic.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.

## v0.70-6b Jeong Do Jeon Source Replacement + q8 Theora Regeneration
- Verified the replaced Jeong Do Jeon source MP4 at `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4`.
- Source ffprobe: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Regenerated `assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv` from the new source using the q8 1920x Theora preset with Vorbis audio.
- Output ffprobe: Theora, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `7101765` bytes.
- Preserved the existing Jeong Do Jeon mapping/fallback chain; no script mapping change was needed.
- Preserved Yi Sunsin q8 OGV/mapping/timing, Kwon Yul q8 OGV/mapping, Jeong Do Jeon title PNG, and legacy fallback videos.
- Removed only the accidental tracked Godot `.import` frame-capture junk under `assets/video_test/theora_safe/` introduced by the source-replacement commit.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for the regenerated OGV/title PNG.

## v0.70-7a Tactical Panel Distance Clamp + Move Cell Clickability Fix
- Refined floating command panel placement so the panel remains attached to the selected unit when possible.
- Added distance-from-selected-unit scoring and a large viewport-corner fallback penalty to the existing tactical-cell overlap score.
- Added near diagonal panel candidate positions before screen-corner fallback positions.
- Fixed valid move-cell click priority during ally turn by trying valid grid movement before enemy unit click hit testing.
- Diagnosed the Xiahou Dun-adjacent click issue as likely enemy click-area preemption of a highlighted valid move cell, not a cutin or worldmap issue.
- Preserved existing command-panel target-selection hiding, direct move-click action flow, basic attack, unique skill, strategy, defend, and wait behavior.
- Did not change cutin assets, q8 Theora mappings, title PNGs, production cutin files, or WorldMap logic.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.

## v0.70-7 Tactical Command Panel Grid Overlap Avoidance
- Added grid-overlap avoidance for `BattleUI/FloatingAllyCommandPanel`.
- The floating command panel now scores several candidate positions around the active ally and safe viewport corners against visible tactical cell overlay rects.
- The panel is clamped inside the viewport and placed at the zero-overlap or least-overlap candidate.
- Added a shared tactical-selection hide helper that hides the panel and changes its panel mouse filter to `IGNORE`.
- Attack target select, unique-skill target select, and strategy target select now hide the floating panel while the user is expected to click grid/target elements.
- Attack and unique-skill cancel paths restore the command-panel request when returning to ally turn; strategy keeps its existing restore behavior through the same hide helper.
- Preserved existing command button wiring and combat behavior.
- Did not change cutin assets, q8 Theora mappings, title PNGs, Yi Sunsin timing, Kwon Yul / Jeong Do Jeon cutin mapping, or WorldMap logic.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.

## v0.70-6a Kwon Yul + Jeong Do Jeon q8 Theora Production Dry Runs
- Reconfirmed Kwon Yul and Jeong Do Jeon source MP4 specs before encoding: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Encoded `assets/ui/cutin/videos/kwon_yul_cutin_bg_theora_q8_1920x.ogv` with libtheora q8 at 1920x1080 / `30/1` / duration `2.000000`; output size is `9054001` bytes.
- Encoded `assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv` with libtheora q8 at 1920x1080 / `30/1` / duration `2.000000`; output size is `4472743` bytes.
- Added Godot `.uid` metadata for both new production dry-run OGVs and verified they load as `VideoStreamTheora`.
- Added Kwon Yul and Jeong Do Jeon q8 Theora paths as first candidates in their cutin video fallback chains.
- Preserved existing WebM fallbacks and added existing MP4 fallback paths after the q8 entries; no existing production video was overwritten or deleted.
- Wired Kwon Yul and Jeong Do Jeon title PNGs into the specialty cutin presentation layer.
- Added per-hero cutin config entries so portrait scale/position and title placement can be tuned independently for Yi Sunsin, Kwon Yul, and Jeong Do Jeon.
- Preserved Yi Sunsin q8 mapping, final timing, title animation, and fallback chain.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for q8 OGV/title resources.

## v0.70-6 Kwon Yul + Jeong Do Jeon Cutin Source Asset Intake
- Verified latest intake commit `c7173fb 컷인 관련`.
- Confirmed Kwon Yul source MP4 at `assets/video_source_test/production_dry_run/kwon_yul_cutin_source_02s.mp4`.
- Confirmed Jeong Do Jeon source MP4 at `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4`.
- ffprobe confirmed both source MP4s are h264, 1920x1080, yuv420p, `30000/1001` fps, and `2.002000s`.
- Confirmed title PNGs under `assets/ui/cutin/titles/` with snake_case hero/skill/title naming:
  - `kwon_yul_haengjudaecheop_title.png`
  - `jeong_do_jeon_gaehyeokryeong_title.png`
- Verified both title PNGs are `1133x639` RGBA/transparent images.
- Added required Godot `.import` metadata for both new title PNGs after Godot `--import`, and verified they load as `CompressedTexture2D`.
- Removed only the two untracked `assets/video_test/theora_safe/test_safe_q*_*.ogv.uid` files generated incidentally by import; no broad clean was run.
- Removed tracked `assets/video_test/theora_safe/` frame-capture `.import` junk with limited pathspecs while preserving the q7/q8 `.ogv` test outputs and `README.md`.
- Did not change production cutin mappings, Yi Sunsin q8 mapping/file, production video assets, battle logic, or WorldMap logic.

## v0.70-5e Yi Sun-sin Final Exit Snap Tuning
- Preserved the current Hakikjin readable-hold and large-burst behavior.
- Shortened Yi Sunsin's post-title linger by moving `SPECIALTY_SKILL_CUTIN_EXIT_START` from `2.55` to `1.18`.
- Reduced the final cutin fade/exit duration from `0.45` to `0.14` for a sharper snap-like finish.
- Reduced `SPECIALTY_SKILL_CUTIN_TOTAL_DURATION` from `3.0` to `1.38` so battle-flow continuation is not delayed by the old long tail.
- Changed the final Yi Sunsin exit drift to a quick left/down motion, ending at `Vector2(-86.0, 14.0)` from the hero base position.
- Preserved q8 Theora first-candidate path, existing fallback chain, title PNG asset path, and battle-flow continuation.
- Did not change Kwon Yul / Jeong Do Jeon mappings, production cutin assets, battle logic, or WorldMap logic.
- Verification passed: `git diff --check`, Godot headless project load, battle scene headless load, and direct ResourceLoader checks for Hakikjin PNG and q8 OGV.

## v0.70-5d Hakikjin Readable Hold + Large Burst Fade Tuning
- Kept Yi Sunsin portrait scale and vertical balance unchanged from v0.70-5c.
- Increased Hakikjin readable hold before the burst so the title does not disappear too quickly.
- Changed Hakikjin burst fade to enlarge dramatically to `2.25` while fading out.
- Added a `22px` upward drift during the burst fade.
- Hakikjin still exits before Yi Sunsin, keeping the cutin dynamic rather than turning the title into a long static label.
- Preserved q8 Theora first-candidate path, existing fallback chain, title PNG asset path, and battle-flow continuation.
- Did not change Kwon Yul / Jeong Do Jeon mappings, production cutin assets, battle logic, or WorldMap logic.
- Verification passed: `git diff --check`, Godot headless project load, battle scene headless load, and direct ResourceLoader checks for Hakikjin PNG and q8 OGV.

## v0.70-5c Yi Sun-sin Vertical Balance + Hakikjin Large Burst-Out Tuning
- Kept Yi Sunsin portrait scale approximately stable and nudged the oversized portrait downward by `28px` for better vertical balance.
- Increased Hakikjin title burst scale from the previous smaller burst to a much stronger large burst-out.
- Hakikjin now appears/readable, scales to `1.72`, then fades out while expanding to `1.90`.
- Added slight upward drift during the title fade burst.
- Preserved q8 Theora first-candidate path, existing fallback chain, title PNG asset path, and battle-flow continuation.
- Did not change Kwon Yul / Jeong Do Jeon mappings, production cutin assets, battle logic, or WorldMap logic.
- Verification passed: `git diff --check`, Godot headless project load, battle scene headless load, and direct ResourceLoader checks for Hakikjin PNG and q8 OGV.

## v0.70-5b Yi Sun-sin Dominance + Hakikjin Pop-and-Burst Tuning
- Increased Yi Sunsin portrait dominance beyond the v0.70-5a layout by enlarging the screen-relative portrait size and pushing it farther left.
- Kept the Hakikjin title PNG asset path unchanged.
- Reworked Hakikjin title animation from a static/settled hold into an impact burst: fast appearance, stronger scale-up, then fade-out while expanding.
- Preserved the q8 Theora first-candidate path and existing fallback chain.
- Did not change Kwon Yul / Jeong Do Jeon mappings, production cutin assets, battle logic, or WorldMap logic.
- Verification passed: `git diff --check`, Godot headless project load, battle scene headless load, and direct ResourceLoader checks for Hakikjin PNG and q8 OGV.

## v0.70-5a Yi Sun-sin Hero Scale + Skill Title Image Impact Tuning
- Integrated `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png` as the Hakikjin skill-title image and added the necessary Godot `.import` metadata.
- Removed the visible `이순신` hero-name label from the Yi Sunsin specialty cutin.
- Replaced the plain `학익진!` label node with a `TextureRect` title-image node.
- Increased Yi Sunsin portrait size and pushed the portrait further left/center-left so it overflows the cutin frame for stronger hero impact.
- Tightened hero entry motion into a faster left-to-right whoosh with overshoot/settle.
- Strengthened title-image entrance with a larger impact pop before settling into the hold.
- Preserved the q8 Theora first-candidate path, existing fallback chain, and post-cutin battle-flow continuation.
- Did not re-encode video assets, delete production cutin files, or change Kwon Yul / Jeong Do Jeon mappings.
- Verification passed: `git diff --check`, Godot headless project load, battle scene headless load, and direct ResourceLoader checks for the PNG title and q8 OGV.

## v0.70-5 Yi Sun-sin Cutin Cinematic Layout Polish
- Polished the Yi Sunsin specialty cutin presentation while preserving the working q8 Theora video path and existing fallback chain.
- Enlarged and repositioned the foreground Yi Sunsin portrait so the composition has stronger hero-splash presence over the moving OGV background.
- Reworked the thick yellow diagonal slash into a restrained steel-blue/sea-spray accent with softer opacity and less UI-like styling.
- Added dedicated scene label settings for the Yi Sunsin cutin hero name and skill name, making `이순신` secondary and `학익진!` the main impact text.
- Tuned runtime layout and animation timing: deeper background dim, hero slide/settle, staggered text reveal, accent motion, and a cleaner fade/drift exit.
- Preserved Yi Sunsin q8 Theora first-candidate mapping, 540p Theora / VP8 WebM / legacy OGV-WebM / MP4 fallbacks, and the existing post-cutin battle-flow continuation.
- Did not re-encode video assets, delete production cutin files, or change Kwon Yul / Jeong Do Jeon cutin mappings.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual visual QA remains required for final judgment of hero scale, typography taste, accent quality, cinematic feel, and battle-flow return in visible play.

## v0.70-4a Yi Sun-sin q8 Theora Manual QA Documentation
- Documented Kimjak's manual Godot battle-flow QA success for the Yi Sunsin q8 Theora production dry-run connected in commit `f3d53e0`.
- Confirmed by user report that the Yi Sunsin q8 cutin finally displays correctly in the actual battle flow.
- Recorded the manual visual result: clean playback, no black-screen lock, no obvious color corruption, and no obvious playback failure.
- Marked `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` as passing for the Yi Sunsin production dry-run candidate.
- Reconfirmed that the existing fallback chain remains preserved after q8: 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- No production assets, cutin scripts, battle logic, WorldMap logic, or video files were modified in this documentation pass.

## v0.70-4 Production Cutin Theora Dry Run - Yi Sun-sin q8
- Encoded the real tracked Yi Sun-sin 2-second source at `assets/video_source_test/production_dry_run/yi_sun_sin_cutin_source_02s.mp4` into a new production dry-run Theora asset.
- Source ffprobe: h264, 1920x1080, yuv420p, `30000/1001` fps, duration `2.002000`.
- Added `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` and Godot sidecar `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv.uid`.
- Output ffprobe: theora, 1920x1080, yuv420p, `30/1` fps, duration `2.000000`; file size `7580014` bytes.
- Updated only the Yi Sunsin cutin video candidate list so the new q8 1920x OGV is tried before the existing 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4 fallbacks.
- Preserved all existing production cutin files and did not modify Kwon Yul or Jeong Do Jeon cutin mapping.
- Godot headless project load and `Battle_Fullscreen_Test.tscn` load passed.
- Direct Godot resource verification passed: the new OGV exists, `ResourceLoader.exists` is true, `ResourceLoader.load` returns `VideoStreamTheora`, and direct `VideoStreamTheora.file` fallback accepts the same path.
- Headless verification cannot confirm visual color, black-screen behavior, finished signal timing, or real post-cutin battle-flow return; F6/manual visual QA remains required.

## v0.70-3 Portable FFmpeg Setup + Theora Safe Encode Execution
- Prepared repo-local portable FFmpeg under ignored `tools/ffmpeg/` without changing system PATH.
- Downloaded and extracted gyan.dev `ffmpeg-release-essentials.zip`, then copied `ffmpeg.exe` and `ffprobe.exe` into `tools/ffmpeg/bin/` for direct calls.
- Added `.gitignore` rules for local FFmpeg binaries/zip/extraction and Godot movie-maker diagnostic frame outputs.
- Encoded `assets/video_source_test/cutin_test_01.mp4` into test-only Theora outputs:
  - `assets/video_test/theora_safe/test_safe_q7_1280x.ogv`
  - `assets/video_test/theora_safe/test_safe_q8_1920x.ogv`
- Confirmed both outputs are Theora/yuv420p/30fps with Vorbis stereo audio by ffprobe.
- Verified `scenes/dev/video_theora_test.tscn` loads q7 and q8 as `VideoStreamTheora` and starts playback in Godot.
- Used Godot movie-maker with the normal Windows display driver to capture q7/q8 playback frames; both rendered non-black frames and normal source-like color.
- Updated `scripts/video_theora_test.gd` with command-line stream selection for repeatable q7/q8 diagnostics.
- Recommended q7 1280x as the final safe Theora preset for future production-candidate conversion.
- Did not modify production cutin assets, battle logic, WorldMap logic, or cutin activation logic.

## v0.70-2 Theora Safe Encoding Test + Godot Color Playback Verification
- Confirmed the current test source path: `assets/video_source_test/cutin_test_01.mp4`.
- Confirmed production cutin videos remain under `assets/ui/cutin/videos/` and were not overwritten or modified.
- Added `assets/video_test/theora_safe/README.md` to reserve the safe Theora test output folder and document expected `.ogv` filenames.
- Added `scenes/dev/video_theora_test.tscn`, an isolated dev-only Godot VideoStreamPlayer test scene.
- Added `scripts/video_theora_test.gd` with q7/q8/noaudio candidate switching, stream path logs, file/resource load logs, direct `VideoStreamTheora` fallback logs, `is_playing()` state logs, and `finished` signal logging.
- Did not modify battle logic, WorldMap logic, production cutin runtime selection, or production video assets.
- FFmpeg was not available in the current local environment, so the requested Theora q7/q8 `.ogv` outputs were not generated in this pass.
- Godot headless project and test-scene load verification passed; actual `.ogv` playback/color verification remains pending until output files are generated.

## v0.70-10A VideoStreamPlayer Debug Checkpoint Documentation
- Added a documentation-only checkpoint for the current Yi Sunsin VideoStreamPlayer investigation after `v0.70-10`.
- Recorded that the cutin layer, PNG portrait, hero/skill text, centered layout, 3-second exit, busy guard, fallback, and post-cutin unique-skill effect flow are intact.
- Recorded the current VideoStreamPlayer progress: Theora 540p OGV is recognized as `VideoStream` in the Godot editor after FileSystem selection, and a local `.ogv.uid` sidecar was generated.
- Recorded the current blocker: Theora 540p OGV playback shows rainbow/glitch-like corruption, shifting the active hypothesis to Theora encoding/decoding compatibility rather than missing file or layout/z-index/size.
- Documented why VideoStreamPlayer remains a must-solve pipeline for intro, specialty cutins, battle result videos, worldmap event cutscenes, opening, and ending.
- Added next-task handoff for `v0.70-11 Cutin Safe Theora Encoding Test`, including conservative 360p and q6/g64 540p ffmpeg candidate commands.
- Did not modify code, scene, or asset files.

## v0.70-10 VideoStreamTheora Direct Load Test
- Changed Yi Sunsin specialty cutin video selection to prioritize the new Godot-stability-first Theora 540p OGV before VP8 WebM, legacy OGV, snake_case WebM, and MP4.
- Added `SPECIALTY_SKILL_YI_SUNSIN_THEORA_540P_PATH` for the selected Theora asset path.
- Strengthened candidate/load diagnostics with `FileAccess.file_exists`, `ResourceLoader.exists`, load-null result, loaded class, `is VideoStream`, and failure-guess output.
- Added a Theora-only direct fallback path: when ResourceLoader does not produce a `VideoStream`, the code creates `VideoStreamTheora`, verifies and sets its `file` property, logs the result, and assigns it to the existing `VideoStreamPlayer_Cutin` when valid.
- Kept `VideoStreamPlayer_Cutin` reuse, stop/clear before assignment, play-from-start behavior, delayed state logs, and hide stop/clear behavior.
- Preserved `CUTIN_VIDEO_DEBUG_FORCE_TOP := false`, the centered cutin layout, PNG/text fallback, busy guard, 3-second pacing, and post-cutin unique-skill effect continuation.
- Did not change unique-skill effect/damage formulas, movement/attack 판정, AI, results, wounded/prisoner/death logic, battle overlay, camera, pop wave, direction-selection, or WorldMap UX/UI logic.

## v0.70-9 VideoStreamPlayer Cutin Debug Pass
- Added focused diagnostic logging for the Yi Sunsin specialty cutin VideoStreamPlayer pipeline.
- Logged video candidate `FileAccess`/`ResourceLoader`/`load()`/class/cast results and assigned stream state so VP8 WebM loading can be separated from player rendering issues.
- Logged `VideoStreamPlayer_Cutin` visibility, modulation, size, position, global position, z-index, parent state, draw-order indexes, and `is_playing()` at start, after `play()`, and after about `0.3s`.
- Added `CUTIN_VIDEO_DEBUG_FORCE_TOP := false` for local visual isolation without affecting normal play by default.
- Added `_debug_play_cutin_video_only()` as a manual QA helper for 3-second VideoStreamPlayer-only playback.
- Made cutin runtime z-index order explicit while preserving the existing scene child order: darken, video, slash, hero, text.
- Preserved the VP8 WebM-first candidate priority, central cutin banner/card layout, PNG/text fallback, busy guard, and post-cutin unique-skill effect continuation.
- Did not change unique-skill effect/damage formulas, movement/attack 판정, AI, results, wounded/prisoner/death logic, battle overlay, camera, pop wave, direction-selection, or WorldMap UX/UI logic.

## v0.70-8 Cutin VP8 WebM Video Connection
- Changed Yi Sunsin specialty cutin video selection to prioritize `vp8 webm > ogv > webm > mp4`.
- Moved `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm` to the first Yi Sunsin video candidate so the VP8 WebM 8M version is the final priority format.
- Kept OGV only as an unstable fallback and preserved existing WebM/MP4 fallback slots without deleting any assets.
- Kept `VideoStreamPlayer_Cutin` reuse and the existing start/hide stop/clear behavior so repeat activation restarts cleanly.
- Allowed failed video candidate loads to continue to later fallback candidates while preserving PNG/text fallback when no video can be loaded.
- Preserved the centered cutin banner/card layout from v0.70-6/v0.70-7.
- Did not change unique-skill effect/damage formulas, movement/attack 판정, AI, results, wounded/prisoner/death logic, battle overlay, camera, pop wave, direction-selection, or WorldMap UX/UI logic.

## v0.70-7 Cutin OGV Video Fallback
- Changed Yi Sunsin specialty cutin video selection to prioritize `ogv > webm > mp4`.
- Moved `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.ogv` to the first Yi Sunsin video candidate so it is selected before WebM/MP4 when present.
- Added explicit selected-candidate, selected-video, no-video, and selected-candidate load-failure logs for the specialty cutin video path.
- Kept `VideoStreamPlayer_Cutin` reuse and the existing start/hide stop/clear behavior so repeat activation restarts cleanly.
- Preserved PNG/text fallback when the selected OGV cannot load as a Godot `VideoStream`.
- Preserved the centered cutin banner/card layout from v0.70-6.
- Did not change unique-skill effect/damage formulas, movement/attack 판정, AI, results, wounded/prisoner/death logic, battle overlay, camera, pop wave, direction-selection, or WorldMap UX/UI logic.

## v0.70-6 Cutin WebM Video Connection + Center Layout Fix
- Changed Yi Sunsin specialty cutin video selection to prioritize WebM before OGV and MP4 fallback.
- Included the actual tracked repo WebM filename `Yi Sun Sin Cutin Bg.webm` in the candidate list while preserving the expected snake_case candidate path for future normalized assets.
- Added future candidate lists for Kwon Yul and Jeong Do Jeon WebM assets without connecting their activation flow.
- Reworked the cutin layout from side-biased slide placement into a centered banner/card composition.
- Changed cutin entry/exit to center-based scale/fade while preserving the 3-second presentation and existing post-cutin effect scheduling.
- Kept `VideoStreamPlayer_Cutin` reusable and cleared/stopped the stream on hide so repeat playback can start from the beginning.
- Preserved PNG/text fallback when no candidate video can be loaded.
- Did not change unique-skill effect/damage formulas, movement/attack 판정, AI, results, wounded/prisoner/death logic, battle overlay, camera, pop wave, direction-selection, or WorldMap UX/UI logic.

## v0.70-5 Specialty Skill Video Cutin MVP
- Added a reusable scene-authored `BattleUI/SkillCutinLayer` for specialty skill cutins.
- Connected ally Yi Sunsin unique skill to the new cutin MVP with darken layer, `VideoStreamPlayer`, slash accent, transparent PNG portrait, hero name, and skill name text.
- Used `res://assets/ui/cutin/portraits/yi_sun_sin_cutin.png` for the Yi Sunsin cutin portrait.
- Added mp4 path detection for `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4`; the file exists, but Godot VideoStream import/playback remains a follow-up risk if ResourceLoader cannot load mp4 directly.
- Delayed Yi Sunsin unique-skill effect application until the 3-second cutin finishes, then continued through the existing effect/finalize flow.
- Kept the old unique-skill toast as fallback for missing cutin nodes/assets and for all non-Yi-Sunsin heroes.
- Added a busy guard so specialty cutin requests do not overlap.
- Did not change unique-skill damage/effect formulas, movement/attack 판정, AI, results, wounded/prisoner/death logic, battle overlay, camera, pop wave, direction-selection, or WorldMap UX/UI logic.

## v0.70-4 Battle Overlay Rollback Shape + Palette Retune
- Preserved the successful v0.70-3 pop wave reveal and range overlay tween cleanup.
- Removed the v0.70-3 center-fade/internal band rendering that made overlay cells look like multiple stacked octagons.
- Restored range tiles to a simpler single-fill octagonal tactical shape closer to v0.70-2.
- Retuned movement range to a clearer blue tactical color instead of the muddy v0.70-3 steel-gray tone.
- Kept attack range, single-target, multi-target/unique-skill, and strategy overlays color-distinct with stronger restored role colors.
- Restored direction-selection arrow tile color to the original gold/yellow role family while keeping the octagonal button shape and pop reveal.
- Did not change camera zoom, default grid hiding, battle rules, movement/attack 판정, damage formulas, AI, results, wounded/prisoner/death logic, or WorldMap UX/UI logic.

## v0.70-3 Battle Overlay Palette + Pop Wave Polish
- Retuned the range overlay palette while keeping movement, attack, single-target, multi-target, and strategy displays visually distinct.
- Changed movement range away from bright sky blue toward a muted steel blue-gray tactical tone.
- Changed attack range toward a toned coral/rose red, single-target markers toward amber, multi-target/unique-skill range toward muted violet, and strategy toward subdued teal.
- Updated `scripts/battle_range_overlay_tile.gd` so tile interiors read as center-fade edge bands rather than a separate small inner octagon.
- Strengthened pop wave reveal with larger distance-based delay and stronger distance-sensitive scale overshoot.
- Added `scripts/battle_facing_arrow_tile_button.gd` and applied it to direction-selection arrow buttons so the four direction tiles share the same octagonal tactical design language.
- Preserved existing range cell pool, Button click paths, movement/attack calculations, and overlay tween cleanup.
- Did not change battle rules, movement/attack 판정, damage formulas, AI, results, wounded/prisoner/death logic, or WorldMap UX/UI logic.

## v0.70-2 Battle Overlay Shape + Wave Tuning
- Adjusted `Battle_Fullscreen_Test.tscn` `MainCamera` zoom from `0.88` to `0.84` for a wider battlefield view.
- Added `scripts/battle_range_overlay_tile.gd`, a lightweight `ColorRect` draw script for clipped-corner octagonal tactical tiles.
- Reused the existing `MoveRangeOverlayLayer` cell pool and attached the tile draw script at runtime instead of adding external assets or a new UI system.
- Changed movement/attack overlays from flat translucent rectangles to octagonal cells with low-alpha fill, softer inner fill, clear outline, and subtle inner highlight.
- Tuned movement styling toward blue and attack styling toward red/orange-red while keeping terrain visible beneath the overlay.
- Strengthened wave/stagger reveal to `0.04s` per grid distance with scale `0.86 -> 1.04 -> 1.0` and alpha fade-in.
- Kept overlay tween cleanup on hide paths so cancel, movement, attack, strategy, and unique-skill transitions do not leave ghost cells.
- Did not change battle rules, movement/attack 판정, damage formulas, AI, results, wounded/prisoner/death logic, or WorldMap UX/UI logic.

## v0.70-1 Battle Visual Detail Polish Start
- Hid the default logical grid guide in normal battle play while leaving the internal grid and debug flag intact.
- Set `Battle_Fullscreen_Test.tscn` `MainCamera` zoom to `0.88` so the battlefield art reads wider without changing the scene-authored camera position.
- Tuned movement and attack range overlay colors to stronger translucent blue/red cells with a small visual inset.
- Added distance-based wave/stagger overlay reveal from the active unit using short alpha/scale tweens.
- Added range overlay tween cleanup on hide paths so cancel, movement, attack, strategy, and unique-skill transitions do not leave ghost cells.
- Reused the existing scene-authored `MoveRangeOverlayLayer` cell pool; no external assets or new large UI system were added.
- Did not change battle rules, movement/attack 판정, damage formulas, AI, results, wounded/prisoner/death logic, or WorldMap UX/UI logic.

## v0.69-14A GDScript Reload Warning Cleanup Before v0.70
- Cleaned GDScript reload warnings in `scripts/worldmap_test.gd` before entering `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Renamed food-cost inner-block variables to avoid `before_amount` / `paid_amount` parent-block declaration warnings while preserving paid-cost payload values.
- Renamed tech definition factory parameters from `name` to `tech_name` to avoid `Node.name` shadowing warnings.
- Replaced the mixed-type spy tech payload ternary with an equivalent `if` branch to avoid the ternary compatibility warning.
- Renamed the unused seasonal-loyalty parameter to `_supply_states`.
- No strategic logic, formulas, balance values, save/load structure, battle, invasion, diplomacy, espionage, tech, trade, or resource behavior was intentionally changed.

## v0.69-14 EASTWAR Strategic Logic Final Checkpoint
- Added a documentation-only checkpoint closing the v0.69 EASTWAR strategic logic track.
- Recorded `v0.69-13 Espionage Action Foundation MVP` / commit `0565f2d5f0acfde609e9df9e96d8e3b25726196c` as the final v0.69 strategic logic baseline.
- Summarized completed v0.69 systems: publicSupport, seasonal loyalty, loyalty-based troop move loss, recruitment/conscription, revolt warning, national/city tech data, tech pipeline/effects, trade market price, diplomacy score/actions, and espionage actions.
- Documented that v0.69 verification is mostly helper/API/headless QA and that real F6 mouse-based UX verification moves to the v0.70 WorldMap final UI pass.
- Prepared handoff for `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- No code, UI, formula, save/load, battle, invasion, defense, diplomacy, espionage, revolt, tech, or trade logic changes were made.

## v0.69-13 Espionage Action Foundation MVP
- Added loyalty disruption, revolt instigation, and wedge driving spy action helpers to `scripts/worldmap_test.gd`.
- Added loyalty disruption cost/cooldown/detected penalty and aptitude-based effect table.
- Loyalty disruption success directly lowers target city loyalty in the MVP; detection cancels the effect and applies relation score `-40`.
- Added revolt instigation cost/cooldown/detected penalty and aptitude-based probability boost table.
- Revolt instigation success records a 3-turn `revolt_instigation` entry only. It does not trigger real revolt, owner change, or battle.
- Added `_advance_revolt_instigation_for_world_turn()` and connected it to the domestic turn pipeline for duration decrement/removal.
- Added wedge cost/cooldown and aptitude-based relation delta table.
- Wedge success lowers relation score between two allied non-player factions; detection penalizes player relations with both target factions by `-20` each.
- Added new result records for loyalty disruption, revolt instigation, revolt instigation tick, and wedge actions.
- Reused the existing shared `spy_cooldown` and forced-roll QA pattern from info gathering/publicSupport disruption.
- Did not implement assassination, real revolt, owner neutral conversion, suppression battle, declaration of war, status auto-conversion, alliance break, UI, battle changes, or save/load core rewrites.

## v0.69-12 Diplomacy Action Foundation MVP
- Added foundation diplomacy action helpers for alliance proposal, military support request, and trade agreement proposal.
- Added deterministic alliance acceptance chance and threshold. Accepted alliance changes relation status to `allied` and records `alliance_turns_remaining`.
- Alliance proposal deducts the provided resource package on attempt.
- Added military support request validation requiring `allied` status. The MVP records support acceptance/rejection only and never moves troops.
- Added military support rejection penalties: `-20` normally and `-40` on the third and later repeated rejection.
- Added trade agreement proposal requiring relation score `>= 50`, with MVP cost `gold 200 + silk 50`.
- Added trade agreement state fields and a separate Phase A trade route bonus `+0.15`; base relation status multipliers remain unchanged.
- Added result records: `last_alliance_proposal_result`, `last_military_support_result`, and `last_trade_agreement_result`.
- Did not implement declaration of war, actual military support movement, joint invasion, battle/invasion/defense changes, diplomacy UI, trade transaction execution, publicSupport/loyalty/tech/supply formula changes, or save/load core rewrites.

## v0.69-11B Espionage Public Support Disrupt MVP
- Added the first offensive espionage action MVP: publicSupport disruption.
- Added fixed cost `{"gold": 300}`, cooldown `8`, and detected relation penalty `-30`.
- Added political aptitude disruption amount helper: aptitude `5/4/3/2/1 -> 20/15/10/5/3`.
- Added validation, forced-roll result, and execution helpers for publicSupport disruption.
- Successful non-detected disruption lowers target city publicSupport and clamps it to `0..100`.
- Detected disruption cancels the publicSupport effect and applies relation score `-30`; status does not auto-convert and war is not declared.
- Reused shared `spy_cooldown`; primary political chancellor applies the existing cooldown `-2` bonus.
- Added `last_spy_public_support_disrupt_result`.
- Did not implement loyalty disruption, revolt instigation, alienation, assassination, real revolt, owner neutral conversion, espionage UI, battle changes, or save/load core rewrites.

## v0.69-11 Espionage Info Gathering MVP
- Added chancellor-driven spy information gathering helpers to `scripts/worldmap_test.gd`.
- Added `SPY_COOLDOWN_TURNS := 6`, `spy_cooldown`, `last_spy_result`, and `last_spy_cooldown_result`.
- Added political aptitude lookup, political-primary detection/cooldown bonus checks, success chance calculation, detection chance calculation, visibility level calculation, spy validation, roll, payload, execution, and cooldown helpers.
- Success chances are aptitude-based: `5/4/3/2/1 -> 80/65/50/35/20`.
- Payload visibility scales from estimated troops at aptitude `1` to troops/resources/publicSupport/loyalty/governor/tech at aptitude `5`.
- Detection is recorded only; no relation penalty, status change, war, revolt, or target-city mutation is applied.
- Connected spy cooldown decrement to the domestic world turn. No automatic spy action is run.
- Did not implement publicSupport disruption, loyalty disruption, revolt instigation, alienation, assassination, espionage UI, diplomacy status changes, battle changes, or save/load core rewrites.

## v0.69-10B Tribute Diplomacy Action MVP
- Added the first diplomacy action MVP: tribute sending.
- Added tribute constants: cooldown `5` turns, relation gain bounds `15..25`, and MVP base cost `gold 300` + `silk 100`.
- Added `_get_tribute_cost`, `_can_send_tribute`, `_calculate_tribute_relation_gain`, `_send_tribute`, and `_advance_diplomacy_cooldowns_for_world_turn`.
- Tribute relation gain is deterministic `+20` for MVP and uses the existing score clamp.
- Tribute uses separate `tribute_cooldown`; existing relation `cooldown` is preserved.
- Added `last_tribute_result` and `last_diplomacy_cooldown_result`.
- Kept status separate from score. Tribute does not auto-convert status to allied or hostile.
- Kept Phase A trade multiplier status-based and unchanged.
- Did not implement alliance proposal, trade agreement, declaration of war, espionage, revolt instigation, specialty trade execution, diplomacy UI, battle changes, or save/load core rewrites.

## v0.69-10 Diplomacy Relation Score MVP
- Added diplomacy relation score constants and helpers to `scripts/worldmap_test.gd`.
- `faction_relations` entries now normalize to `status`, `score`, and `cooldown` while preserving existing status/cooldown values.
- Added score adjustment and normalization result records: `last_diplomacy_relation_result` and `last_diplomacy_normalize_result`.
- Added score-derived `relation_band` values: `friendly`, `neutral`, and `hostile`.
- Kept `status` separate from `relation_band`; no automatic allied/hostile conversion was added.
- Kept Phase A trade multiplier status-based and unchanged. Trade routes now include `relation_score` and `relation_band` as display/debug fields only.
- Did not implement tribute, trade agreements, alliance proposal/acceptance, declaration of war, espionage, revolt instigation, specialty trade execution, diplomacy UI, battle changes, or save/load core rewrites.

## v0.69-9 Trade Deepening Data Market Price MVP
- Added trade market base price data for `rice`, `barley`, `seafood`, `salt`, `silk`, `iron`, `wood`, and `horse`; `gold` remains excluded as the pricing basis.
- Added deterministic season and situation multiplier helpers for market prices.
- Added `_calculate_trade_market_prices()` and `_update_trade_market_for_world_turn()`.
- Added `_player_state["last_trade_market_result"]` recording with per-resource price/trend details.
- Domestic turn summary now includes one compact market-price line.
- Existing Phase A inter-faction trade income remains unchanged and separate.
- Not implemented: manual trade, resource exchange, trade agreements, maritime trade, pirate loss, hero trade traits, random market volatility, and trade UI.

## v0.69-8B Tech Effect Application MVP
- Added first completed-tech effect consumers to `scripts/worldmap_test.gd`.
- Added `_apply_completed_tech_effects_for_world_turn`, national/city domestic-income multiplier helpers, and `applied_tech_effects` duplicate prevention state.
- Implemented `legal_reform` as a one-time national effect: all player-owned cities receive publicSupport `+5`, clamped to `0..100`.
- Implemented `tax_reform` as domestic gold income `x1.10`. Inter-faction trade income is not affected.
- Implemented `street_market` as city domestic gold income `x1.05`. Inter-faction trade income is not affected.
- Implemented `barracks` as the automatic conscription gate. Cities without completed `barracks` add `0` and record reason `barracks_required`.
- Implemented `conscription_system` as turnly automatic conscription add `x1.10`, capped by available conscription. Conscription capacity is unchanged.
- Recognized no-consumer effects for `national_foundation`, `improved_farming_tools`, and `fishing_village`.
- Did not implement all tech effects, battle effects, turtle ship/special units, diplomacy/espionage, real revolt, trade deepening/market prices, tech UI, auto tech selection, battle scene changes, or save/load core rewrites.

## v0.69-8 Tech Start Progress Pipeline MVP
- Implemented the national/city tech start and progress pipeline in `scripts/worldmap_test.gd`.
- Added `_get_tech_duration_turns(tier)` and definition-duration fallback handling.
- Added generic resource-cost helpers for shared tech cost checks and deduction, including `food` as the rice+barley+seafood pool.
- Changed `_start_national_tech(tech_id)` from a no-op skeleton into the MVP start flow: validation, cost deduction, duration setup, `in_progress` registration, and `last_tech_start_result`.
- Changed `_start_city_tech(city_id, tech_id)` into the equivalent city tech start flow.
- Added `_advance_national_tech_progress_for_world_turn()` and `_advance_city_tech_progress_for_world_turn()`.
- Tech completion now moves entries from `in_progress` to `completed` and records `effect_summary` plus `effect_applied: false`.
- Connected tech progress to the domestic turn pipeline after revolt warning, using the existing once-per-turn domestic apply guard to prevent duplicate decrement.
- Added minimal turn-summary completion text for completed national/city tech.
- Did not implement tech effects, UI, automatic tech selection, governor/chancellor auto progress, publicSupport/loyalty/recruitment/revolt/trade/supply/troop move formula changes, battle/invasion/defense changes, or save/load core rewrites.

## v0.69-7A National City Tech Data Consistency Audit
- Added `_validate_tech_data_consistency()` to `scripts/worldmap_test.gd` as a QA/debug-only tech data audit helper.
- Audited city `required_national_tech` references against national tech definitions.
- Added the documented national tech `logistics_system` / `병참 제도` to resolve the `dried_fish_supply_base` required national tech reference.
- Audited city tech `requires` and national tech `requires` references; no missing prerequisite IDs remain.
- Audited cost keys against the allowed resource keys and kept `food` as the MVP rice+barley+seafood pool key.
- Audited chancellor/governor aptitude type values against the allowed type list including `maritime`.
- Added empty `icon_path` and `image_path` fields to national tech definitions to match city tech image placeholder shape.
- Documented placeholder conditions that must not auto-pass: `chancellor_type_turns`, `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, `has_hero_yi_sunsin`, `has_city_tech_mint`, `has_silkroad_or_trade_port`, `neutral_faction_count`, and `allied_faction_count`.
- Did not implement national/city tech progress, completion, cost deduction, effect application, UI, publicSupport/loyalty/recruitment/revolt/trade/supply/troop move formula changes, battle/invasion/defense changes, or save/load core rewrites.

## v0.69-7 City Tech Tree Data MVP
- Added City Tech Tree Data MVP to `scripts/worldmap_test.gd`.
- Added `_get_city_tech_definitions()` for the MVP city tech branch spine across agriculture, commerce, fishery/coastal, military, and coastal/naval techs.
- Added `icon_path` and `image_path` fields to every city tech definition as empty-string placeholders for future tech UI image connection.
- Added `_ensure_city_tech_state(city_id)` and per-city `city_tech` state with `completed`, `in_progress`, and `available_cache`.
- Added city tech lookup helpers for completed ids, completed state, in-progress state, and single definition retrieval.
- Added `_get_city_governor_aptitude_type(city_id)` using existing governor and hero aptitude fields.
- Added `_check_city_tech_requirements`, `_can_pay_city_tech_cost`, and `_can_start_city_tech`.
- Added `_start_city_tech` as a no-op skeleton that returns `false`; actual start/cost deduction/progress/completion/effects remain deferred.
- Placeholder conditions deliberately fail with reasons for unsupported systems: governor type turns, food surplus turns, connected supply city count, and Yi Sun-sin hero presence.
- Food costs are checked against the existing rice+barley+seafood pool and are not deducted.
- City runtime save/load now minimally preserves `city_tech` state without rewriting the save/load core flow.
- Did not implement national tech progress/completion, city tech UI, governor auto tech selection, tech progress, tech completion, tech effects, battle/invasion/defense changes, save/load core rewrite, or changes to existing publicSupport/loyalty/recruitment/revolt/national tech/trade/supply/troop move formulas.

## v0.69-6 National Tech Tree Data MVP
- Added National Tech Tree Data MVP to `scripts/worldmap_test.gd`.
- Added `_get_national_tech_definitions()` for the MVP national tech branch spine across foundation, administrative, economic, military, diplomatic, and political branches.
- Added `_ensure_national_tech_state()` and `_player_state["national_tech"]` with `completed`, `in_progress`, and `available_cache`.
- Added national tech lookup helpers for completed ids, completed state, in-progress state, and single definition retrieval.
- Added `_get_current_chancellor_aptitude_type()` using the existing assigned chancellor hero data.
- Added `_check_national_tech_requirements`, `_can_pay_national_tech_cost`, and `_can_start_national_tech`.
- Added `_start_national_tech` as a no-op skeleton that returns `false`; actual start/cost deduction/progress/completion/effects remain deferred.
- Placeholder conditions deliberately fail with reasons for unsupported systems: chancellor type turns, allied faction count, neutral faction count, city mint tech, and silkroad/trade-port.
- Food costs are checked against the existing rice+barley+seafood pool and are not deducted.
- Did not implement city tech tree, UI, auto tech selection, tech progress, tech completion, tech effects, battle/invasion/defense changes, save/load core rewrite, or changes to existing publicSupport/loyalty/revolt/recruitment/trade/supply formulas.

## v0.69-5 Revolt Warning Foundation MVP
- Added revolt risk state constants: `REVOLT_RISK_STABLE`, `REVOLT_RISK_WARNING`, and `REVOLT_RISK_DANGER`.
- Added `_calculate_city_revolt_risk(city_id)` to calculate city revolt warning/danger from current publicSupport and loyalty.
- Added `_apply_revolt_warning_check_for_world_turn()` to scan player-owned cities and record `_player_state["last_revolt_warning_result"]`.
- Connected revolt warning after publicSupport drift, city loyalty drift, seasonal loyalty, and conscription in the domestic turn.
- Warning requires both publicSupport and loyalty `<= 40`; danger requires both publicSupport and loyalty `<= 30`.
- Added minimal City Detail and turn-summary text for revolt warning/danger counts and reasons.
- This is warning-only foundation logic. Did not implement actual revolt occurrence, neutral owner changes, suppression battles, espionage revolt agitation, map markers, or final UI.
- Did not modify publicSupport, seasonal loyalty, conscription/recruitment, troop move, P0-1/P0-2/Phase A/Phase B, battle scene, save/load core, tech tree, trade deepening, diplomacy, or espionage formulas/logic.

## v0.69-4 Recruitment Conscription Foundation MVP
- Added loyalty-based conscription helpers to `scripts/worldmap_test.gd`: `_get_conscription_capacity_by_loyalty`, `_get_city_conscription_available`, and `_apply_city_conscription_for_world_turn`.
- Automatic conscription now runs in the domestic turn after publicSupport drift, existing city loyalty drift, and seasonal loyalty from publicSupport, adding `min(available, 100)` troops to player-owned cities below capacity.
- Added initial paid recruitment helpers for amount limits, cost, validation, and execution. v0.70-21 later corrected the amount-limit axis to city loyalty.
- Added minimal recruitment resource helpers: `_can_pay_recruitment_cost` and `_apply_recruitment_cost`.
- Recruitment cost is `gold = amount` and `food = amount / 2`; MVP food payment deducts from national `resource_stock` in order `rice -> barley -> seafood`.
- Added `_player_state["last_conscription_result"]` and `_player_state["last_recruitment_result"]`.
- Added minimal City Detail internal/supply display for conscription capacity, available amount, automatic conscription estimate, recruitment limit, and sample cost.
- Kept publicSupport and loyalty as separate axes. v0.70-21 later clarified that recruitment amount limits use loyalty, while publicSupport remains future risk/fatigue data.
- Did not implement population decrease, recruitment fatigue, publicSupport/loyalty loss from recruitment, recruitment UI, revolt, tech trees, trade deepening, diplomacy/espionage, battle scene changes, save/load core rewrites, or large UI refactors.

## v0.69-3A Strategic Logic Checkpoint Documentation
- Added a documentation-only checkpoint for completed v0.69-1 through v0.69-3 strategic logic.
- Recorded `v0.69-1 Public Support MVP`, `v0.69-2 Seasonal Loyalty From Public Support MVP`, and `v0.69-3 Troop Move Loyalty Efficiency Final Patch` as complete.
- Locked the v0.69 strategic foundation chain at the documentation level: `publicSupport` -> seasonal `loyalty` -> troop movement loss.
- Recorded that current validation is headless/API-centered and that real F6 mouse-based UX verification is deferred to the June city information panel and WorldMap UX/UI redesign phase.
- Recorded that the current City Detail UI is a minimal temporary display/connection surface, not final UX.
- Recorded `v0.69-4 Recruitment/Conscription Foundation MVP` as the next implementation candidate while keeping UX verification tied to the later UI overhaul.
- Documentation only. Did not modify `scripts/worldmap_test.gd`, formulas, recruitment/conscription, revolt, tech trees, trade deepening, diplomacy/espionage, UI, or save/load.

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

# T06-7 Hero Unique Skills & Shared Momentum Playable Transaction

- Added side-shared momentum with start `3`, cap `10`, and successful basic-attack gain `+1`.
- Added data-driven `BattleSkillResolver` coverage for all 39 canonical skills through ten archetypes.
- Connected canonical skill definitions through `HeroRuntimeFactory` and `BattleUnitState`.
- Connected commit-only player skill use, per-hero cost UI, shared-pool UI, no-charge failure/cancel logs, and actual effect commands.
- Replaced AI legacy-effect scoring with resolver-plan scoring under identical momentum rules.
- Added persistent battle runtime snapshots and matching battle-ID restore/clear lifecycle.
- Added T06-7 runtime validator, all-39 resolver smoke, momentum transaction smoke, and snapshot roundtrip smoke.
- Final generated hero JSON was not edited.

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
## v0.70-13a Battle Intro Wide Hold Timing Polish
- Increased battle intro wide-shot hold from `0.4s` to `0.85s`.
- Increased battle intro zoom-in duration from `1.0s` to `1.15s`.
- Kept UI restore after zoom completion and kept skip behavior unchanged.
- No battle logic, result/worldmap flow, cutin/result video assets, archer volley FX, or gunner shot FX were changed.

## v0.70-13 Battle Intro Camera Zoom Patch
- Added battle-start intro camera presentation using the existing `MainCamera`.
- Captures the normal gameplay camera position/zoom, starts from a wider battlefield view, then tweens back to the captured gameplay camera state.
- Hides `BattleUI` during the intro and restores it after completion or skip.
- Added intro skip handling for mouse click, Space, Enter, numpad Enter, and Esc.
- Guarded battle input and command-button entry points while the intro camera is playing.
- No combat rules, grid visibility, battle result/worldmap flow, cutin/result video assets, archer volley FX, or gunner shot FX were changed.

## v0.70-12a Battle Result Video Panel Size Polish
- Changed battle result video playback from full-viewport video to a centered cinematic panel.
- Added viewport-ratio panel sizing constants for result videos and kept the dim backdrop full-screen.
- Preserved the existing result sequence: video playback, then the current victory/defeat toast.
- Preserved load-failure fallback to the existing result toast.
- No battle result payload, worldmap logic, special-skill cutin mappings, archer volley FX, or gunner shot FX were changed.

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

## T07 Five Unit-Type Battle Completion
- Added canonical five-type action/range and damage contexts, gunner runtime metadata, mounted-archer action-local snapshot fields, auto-battle parity, and central Korean unit-type labels.
- Automated validators and Godot headless parse/scene load passed; user F5 QA remains pending.

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
