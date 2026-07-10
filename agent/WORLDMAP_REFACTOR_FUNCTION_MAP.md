# WorldMap Refactor Function Map

## 1. Baseline
- v0.71-00 기준 커밋: `621be2a8c9eef7cf6575b2636aa89fa2564e7319` (`v0.70-99-hotfix2 Research Completion Effect Summary Fix`).
- 작업 시작 시 local HEAD: `621be2a8c9eef7cf6575b2636aa89fa2564e7319`.
- 작업 시작 시 `origin/main` HEAD: `621be2a8c9eef7cf6575b2636aa89fa2564e7319`.
- 작업 시작 시 working tree 상태: tracked files clean.
- 분석 대상: `scripts/worldmap_test.gd`.
- 보조 확인: `project.godot` main scene is `res://Battle_Singijeon_Test.tscn`; test scenes include `WorldMap_Test.tscn`, `Battle_Fullscreen_Test.tscn`, `Battle_WebImport_Test.tscn`, and `scenes/dev/video_theora_test.tscn`.
- v0.71-01 note: `project.godot` main scene was switched to the existing root scene `res://WorldMap_Test.tscn`; `scenes/WorldMap_Test.tscn` is absent and no scene files were moved or renamed.
- v0.71-02 note: Added `agent/SCENE_ENTRYPOINT_MAP.md`; no scene rename/move was performed, and root `res://WorldMap_Test.tscn` remains the v0.71 MVP entrypoint.
- v0.71-03 note: Added `scripts/worldmap/` destination folder skeletons and `agent/SCRIPTS_FOLDER_STRUCTURE_MAP.md`; no existing runtime `.gd` file was moved.
- v0.71-04 note: Re-extracted `scripts/worldmap_test.gd` function list at local HEAD `515676465f99c306095e25b7a206d45f96832f03`; function count remains `1109`. This pass links function groups to the `scripts/worldmap/` destination folders and does not move code.

## 2. Purpose
- This document is a code-backed function/domain map before physically splitting `scripts/worldmap_test.gd`.
- v0.71 refactoring is structural risk reduction, not a feature pass.
- `worldmap_test.gd` must not be split in v0.71-00.
- The map is intended to make `v0.71-01 MVP Main Scene Switch` and later helper extraction steps safer by identifying low-risk helpers and high-risk schema/runtime boundaries first.

## 3. Non-Goals
- No new feature.
- No save/load schema change.
- No BattleContext schema change.
- No pending invasion schema change.
- No battle formula change.
- No diplomacy/spy formula change.
- No enemy research.
- No AI research.
- No ship/siege persistent storage.
- No scene visual overhaul.
- No UI overhaul.
- No Domestic Tech expansion.

## 4. Function Group Map

Function extraction data was generated from:

```powershell
rg -n "^func |^static func " scripts/worldmap_test.gd
rg -n "^signal |^const |^var |^@onready" scripts/worldmap_test.gd
```

Current function count: `1109`.

Risk count:

| Risk | Count |
| --- | ---: |
| Low | 224 |
| Medium | 635 |
| High | 229 |
| Do Not Move Yet | 21 |

The table below maps all detected functions by domain using name prefix, nearby constants/state, call role, and line ranges. Large groups are intentionally represented as contiguous families because the file is a 23k-line God script; extraction should use this map plus a fresh `rg` pass immediately before moving code.

| Group | Function / Function Family | Lines | Current Role | Extraction Candidate | Risk | Notes |
| ----- | -------------------------- | ----: | ------------ | -------------------- | ---- | ----- |
| Scene / Runtime Orchestration | `_ready`, `_process`, `_input`, `_unhandled_input` | 1254-1392 | Scene boot, frame loop, pointer/keyboard input | No | Do Not Move Yet | Owns initial ordering and signal/setup calls. |
| Selection Panel / World UI | `_hide_retired_top_worldmap_hud` through `_move_hud_panel_to_screen_position` | 1393-1491 | HUD panel anchors and drag handling | Later wrapper only | Medium/High | Direct Control mutation and drag state. |
| Scene / Runtime Orchestration | `_refresh_world_rect_from_scene_tiles`, `_configure_camera`, `_handle_keyboard_pan`, `_apply_zoom`, `_clamp_camera_to_world`, `_get_tile_world_rect`, `_update_camera_debug_label`, `_format_vector2` | 1492-1605 | Camera/world rect helpers and debug display | Formatter/helper split after scene switch | Low/Medium/High | Camera mutation should remain in orchestrator first; `_format_vector2` is safe. |
| Scene / Runtime Orchestration | `_connect_city_markers`, `_on_city_marker_selected` | 1606-1637 | City marker signal wiring and selection entry | No | High | Selection state and UI refresh fan out. |
| Selection Panel / World UI | `_connect_city_info_panel_actions` through `_is_adjacent_city_pair` | 1638-1785 | City info actions, governor assignment, hero transfer, recruitment | No until city state boundary exists | Medium/High | Mutates city/hero runtime state and selection UI. |
| Debug / QA / Dev Tools | `_connect_world_hud_placeholders` | 1786-1799 | Placeholder button wiring | Later | High | Signal wiring. |
| Domestic Tech | `_ensure_domestic_tech_tree_button_mvp` | 1800-1823 | Opens Domestic Tech UI entry | Later | Medium | UI node creation, but domain-local. |
| Selection Panel / World UI | `_setup_unified_city_detail_diplomacy_panel` through `_set_city_detail_body_labels_visible` | 1824-2292 | Unified right panel/tab chrome, city detail resource cards | Split after formatter extraction | Medium/High | Direct UI mutation. |
| UI Formatter / Summary | `_make_city_detail_resource_card_style`, `_get_trade_control_mode_label`, `_get_trade_control_hint` | 2246-2413 | Styles and labels | Yes | Low | Good early UI helper targets if isolated from nodes. |
| Economy / City | `_ensure_trade_control_card` through manual trade panel/order/execution helpers | 2166-2959 | Manual/external trade UI, validation, delta calculation | Calculators only | Medium/High | Separate pure trade delta/cost helpers before UI or persistence. |
| Economy / City | `_apply_chancellor_auto_trade_for_world_turn` through `_apply_chancellor_external_import` | 2960-3290 | Chancellor auto trade turn application | No | High | Turn application and resource mutation. |
| Save / Load | `_get_default_trade_control_modes` through `_restore_trade_persistence_from_player_state` | 3291-3531 | Trade control normalization/persistence bridge | Normalize helpers only | Medium/High | Payload shape sensitive; do not move persistence bridges early. |
| Economy / City | Internal trade transfer panel helpers | 3532-3861 | Internal transfer UI, validation, application, summaries | Validators/formatters later | Medium/High | UI + city storage mutation mixed. |
| UI Formatter / Summary | `_format_internal_trade_transfer_amounts`, `_format_star_rating` | 3862-3884 | Text formatting | Yes | Low | Side-effect-free. |
| Diplomacy / Spy | `_show_unified_diplomacy_spy_content` through `_format_spy_action_hint` | 3885-5014 | Diplomacy/spy panel text and action card UI | Formatters first | Low/Medium/High | UI refresh and action validation are mixed. |
| Economy / City | Trade display and supply/city status formatter families | 5015-5675 | Route, trade, supply, loyalty, revolt, display text | Yes for formatters | Low/Medium | Most `_format_*` helpers are good extraction targets. |
| Defense / Battle | Troop move preview helpers | 5711-5781 | Troop movement preview and reason text | Later | Medium | Touches city troop assumptions. |
| Selection Panel / World UI | Left world controls/header/tax/help/save/pending invasion UI setup | 5801-6200 | Left panel and modal/card setup | No early | Medium/High | Node construction and signal wiring. |
| Scene / Runtime Orchestration | Runtime defaults, turn phase, enemy turn loop | 6353-7667 | State defaults and turn progression | No | Do Not Move Yet/High | Cross-cutting orchestration. |
| Defense / Battle | Enemy invasion planning and pending invasion display | 7668-8159 | Invasion event creation, eligibility, player attack entry | No | Do Not Move Yet/High | Pending invasion and battle entry payload risk. |
| Defense / Battle | Player attack and defense deployment payload/build/validation helpers | 8160-9050 | Deployment candidates, command limit, BattleContext support fields | No early | High/Do Not Move Yet | BattleContext and troop accounting sensitive. |
| Economy / City | Hero runtime placeholder/status and conscription/recruitment helpers | 9051-9951 | Hero/city runtime state, conscription, city tech display hook | Later with city model boundary | Medium/High | Runtime state mutation. |
| Domestic Tech | Tech definition and lookup helpers | 9952-10535 | City/national tech definitions, completed lookup wrappers | Yes for definitions/lookups | Low/Medium | Good extraction candidates after tests lock current IDs. |
| Domestic Tech | Economy/defense/battle/diplomacy/spy/naval/siege modifier helpers | 10536-11097 | Completed-tech based modifier/unlock calculation | Yes, staged by domain | Low/Medium | Keep PLAYER-only and same-city scope contracts. |
| Domestic Tech | Tech inspector, graph, tree UI, research action, cost, progress, completion queue/video/card | 11098-14380 | Domestic Tech UI and research lifecycle | Formatters first; queue later | Low/Medium/High/Do Not Move Yet | Presentation queue mutation and active research payload are high-risk. |
| Enemy Baseline / AI-lite | Enemy economy/defense/battle/naval/siege/diplomacy/spy baseline helpers | 4412-4729 plus 6768-6835 | Read-only enemy capability/resistance summaries | Yes for pure baseline helpers | Low/Medium | Must remain baseline only, not enemy research. |
| Enemy Baseline / AI-lite | Enemy faction personality/goal/pressure planning helpers | 6781-7254 and 14381-15180 | AI-lite strategic pressure selection | Later | Medium/High | Turn result and enemy action coupling. |
| Defense / Battle | Battle handoff, result handling, troop/city owner/wounded/capture helpers | 15181-17610 | BattleContext handoff and result application | No | High/Do Not Move Yet | Schema and result contract sensitive. |
| Diplomacy / Spy | Diplomacy relation/action/cooldown/alliance/support/tribute helpers | 17611-19195 | Diplomacy state, validation, mutation, result summaries | Pure formatters only first | Medium/High | Formula and relation schema sensitive. |
| Diplomacy / Spy | Spy validation, roll, detection, intel payload, public support/loyalty/revolt/wedge helpers | 19196-20568 | Spy action state, payload, rolls, effects | Pure formatters only first | Medium/High | Formula and spy payload sensitive. |
| Economy / City | Inter-faction trade, supply, public support, loyalty, upkeep, resource delta | 20569-21181 | Turn economy/city loops and resource mutation | No early | High | Gameplay formulas and city state. |
| UI Formatter / Summary | Domestic apply, trade, cooldown, tech progress, supply/revolt summaries | 21182-21590 | Turn result summary text | Yes | Low/Medium | Good extraction target after passing fixtures. |
| Save / Load | `_get_default_player_state`, `_serialize_worldmap_state`, `_apply_worldmap_state`, `_save_worldmap_state`, `_load_worldmap_state`, city/hero runtime serialization/apply | 21599-21987 | Save/load payload and runtime restore | No | Do Not Move Yet/High | Schema-sensitive. |
| Economy / City | City/hero runtime accessors, storage, warehouse, policy/tax/upkeep helpers | 22001-22525 | Runtime data access, storage display, policy preview | Formatters/getters first | Low/Medium/High | Distinguish read-only helper from mutation. |
| Selection Panel / World UI | Chancellor/governor assignment and selected city final UI callbacks | 22526-23096 | Assignment UI, tab callbacks, resize/collapse | No early | Medium/High | UI state and signal callbacks. |

## 5. Cross-Cutting State / Schema-Sensitive Functions

| Area | Functions / State | Why Risky | Movable in v0.71? | Required Protection Before Move |
| ---- | ----------------- | --------- | ----------------- | ------------------------------- |
| Save/load | `_serialize_worldmap_state`, `_apply_worldmap_state`, `_save_worldmap_state`, `_load_worldmap_state`, `_serialize_worldmap_city_runtime_state`, `_apply_worldmap_city_runtime_state`, `_serialize_worldmap_hero_runtime_state`, `_apply_worldmap_hero_runtime_state`, `_player_state`, `_city_runtime_states`, `_hero_runtime_states` | Save payload shape, defaulting, and old-save compatibility are mixed with runtime refresh. | No, not in early extraction. | Golden save payload sample, load/reset smoke test, schema diff checklist. |
| BattleContext | `_build_battle_context_from_pending_invasion`, `_build_player_attack_battle_context`, `_handoff_worldmap_battle_context_to_scene`, `WORLDMAP_BATTLE_CONTEXT_META_KEY` | Battle scene consumes keys by contract; wrong move can silently break battle startup/result. | No. | Contract doc, context fixture, headless battle scene load, one manual F6 attack/defense path. |
| Pending invasion | `_setup_pending_invasion_choice_ui`, `_show_pending_invasion_choice`, `_attach_enemy_invasion_event_to_enemy_turn_result`, `_clear_pending_invasion_choice`, `pending_invasion_event` payload in `_player_state` | UI choice, enemy turn result, and battle handoff share a mutable event. | No. | Pending event fixture, cancel/manual/auto defense path QA. |
| Active research payload | `_start_domestic_tech_research_mvp`, `_advance_*tech*_progress*`, `_complete_*tech*`, active keys `tech_id`, `started_turn`, `remaining_turns`, `duration_turns` | Existing lock requires payload schema unchanged. | Only read-only helpers. | Active research fixture and progress/complete smoke path. |
| Completed tech state | `_is_city_domestic_tech_completed_mvp`, `_is_national_domestic_tech_completed_mvp`, completion application helpers | PLAYER-only and same-city-only contracts are easy to leak. | Lookup wrappers can move after tests. | Same-city/national scope assertions. |
| City state | `_get_mutable_city_runtime_state`, `_get_city_storage`, `_set_city_storage`, loyalty/public support/troop functions | Resource, loyalty, owner, troop, storage, and stationed hero state are mixed. | Formatter/getter only first. | City state access boundary and before/after turn result diff. |
| Player/enemy state | `_player_state`, enemy faction seeds/goals/pressure helpers, relation state | Enemy must remain baseline/AI-lite, not research. | Pure enemy baseline read helpers only. | No enemy completed-tech storage grep gate. |
| Selection panel state | `selected_city_id`, `selected_city_marker`, `_selected_city_detail_tab`, `_unified_primary_tab`, `_selected_diplomacy_spy_tab` | UI refresh fan-out depends on current selection and tab state. | No early callbacks. | Scene load plus city click/manual F6 regression. |
| Presentation queue | `_domestic_tech_completion_presentation_queue`, `_show_next_domestic_tech_completion_presentation`, video/card close callbacks | Queue/video/card ordering is user-visible and recently fixed. | No early. | Completion video/card F6 QA and queue order test helper. |

## 6. Suggested v0.71 Extraction Order

| Step | Goal | Move Candidate Types | Forbidden | Verification Points | Entry Condition For Next |
| ---- | ---- | -------------------- | --------- | ------------------- | ------------------------ |
| v0.71-01 MVP Main Scene Switch | Establish MVP main scene direction without touching worldmap internals. | Project/scene entry config only if scoped. | Function moves, schema changes, gameplay changes. | `git diff --check`, project and scene headless load. | Main scene choice documented and loads. |
| v0.71-02 Test Name Cleanup | Remove confusing test naming at repo surface. | Names/aliases/docs only. | Behavior changes, scene visual edits. | Scene path references grep, headless load. | No broken scene path references. |
| v0.71-03 Scripts Folder Structure Split | Create folder layout for future helpers. | Empty/new helper directories or docs only. | Moving `worldmap_test.gd` functions. | `rg` path references, headless load. | Folder structure exists and is unused or safely referenced. |
| v0.71-04 WorldMap God File Function Group Map | Refresh this map after any path/name cleanup. | Documentation only. | Runtime changes. | Function count and risk count recorded. | Map matches current file. |
| v0.71-05 Domestic Tech Helper Extraction | Extract low-risk tech definition, lookup, modifier, formatter helpers. | Side-effect-free definitions, completed lookup wrappers, effect summary builders. | Active payload, completion queue/video/card mutation. | Tech graph opens, research start/progress/complete smoke, no schema diff. | PLAYER-only/same-city contracts verified. |
| v0.71-06 Economy / City Helper Extraction | Extract economy formatter and pure calculation helpers. | `_format_*`, cost/delta calculators, read-only storage summaries. | Turn application, `_apply_resource_delta`, save/load. | Turn summary text, city storage display, warehouse display. | Resource before/after unchanged. |
| v0.71-07 Defense / Battle Helper Extraction | Extract read-only battle/deployment formatters and command-limit helpers. | Command rank labels/limits, read-only candidate scoring only. | BattleContext creation, pending invasion, troop mutation. | Player attack/defense panel smoke, battle scene load. | Context keys unchanged. |
| v0.71-08 Diplomacy / Spy Helper Extraction | Extract labels/formatters and read-only chance wrappers only after formula guard. | UI labels, status formatting, result summary text. | Relation mutation, detection/success formulas, spy payload creation. | Diplomacy/spy panel smoke and formula grep diff. | Relation/payload schemas unchanged. |
| v0.71-09 Naval / Siege Helper Extraction | Extract unlock read-only helpers. | PLAYER unlock modifier read helpers, enemy baseline read helpers. | Ship/siege persistent state or production. | Attack eligibility summaries and no new storage keys. | Unlock summaries unchanged. |
| v0.71-10 UI Formatter / Summary Helper Extraction | Extract shared formatter module. | `_format_*`, `_get_*label`, summary builders. | Node creation, signal callbacks, selection mutation. | UI panel text smoke, scene load warnings. | Formatter output spot-checked. |
| v0.71-11 WorldMap Orchestrator Slim Pass | Replace local helper bodies with calls and reduce top-level clutter. | Wiring to extracted helpers. | Moving `_ready`, save/load, BattleContext, pending invasion. | Full headless project/scene load. | No new warnings or broken calls. |
| v0.71-12 Full Regression F6 QA | Manual/visual/gameplay regression lock. | QA docs only unless hotfix needed. | New features. | F6 worldmap, research complete video/card, attack/defense, diplomacy/spy, save/load spot checks. | No blocker found. |
| v0.71-13 Refactor Complete Lock | Lock v0.71 refactor route. | Agent docs. | Feature expansion. | Final headless and manual QA record. | Route closed. |

## 7. Recommended First Extraction Targets

High priority low-risk targets after v0.71-05:

| Priority | Candidate Type | Examples | Reason |
| -------- | -------------- | -------- | ------ |
| 1 | Side-effect-free formatter | `_format_vector2`, `_format_star_rating`, `_format_signed_int`, `_format_resource_costs`, `_format_city_storage_summary` | Easy to fixture and compare output. |
| 2 | Label/status lookup | `_format_region_label`, `_format_faction_label`, `_format_city_type`, `_get_resource_status_label`, `_format_enemy_city_baseline_grade_label_mvp` | Constant-like, low mutation risk. |
| 3 | Domestic Tech definitions/lookups | `_get_domestic_tech_categories_mvp`, `_get_domestic_tech_definition_mvp`, `_is_city_domestic_tech_completed_mvp`, `_is_national_domestic_tech_completed_mvp` | Clear domain boundary; must preserve PLAYER-only/same-city rules. |
| 4 | Domestic Tech modifier summaries | `_get_player_*_modifier_mvp`, `_format_*domestic_tech*summary*` | Good after completed lookup fixtures. |
| 5 | Enemy baseline read-only helpers | `_get_enemy_city_economy_baseline_mvp`, `_get_enemy_city_defense_baseline_mvp`, `_get_enemy_battle_baseline_modifier_mvp`, `_get_enemy_naval_baseline_mvp`, `_get_enemy_siege_baseline_mvp` | Side-effect-free; explicitly not enemy research. |
| 6 | Safe-set mapping helpers | Functions reading `DOMESTIC_TECH_*_SAFE_SET_MVP` constants | Data lookup only if no UI mutation. |

Do not move early:

| Candidate | Reason |
| --------- | ------ |
| `_ready` and setup chain | Ordering-sensitive scene boot. |
| Save/load functions | Schema-sensitive and old-save-sensitive. |
| Turn advance functions | Cross-domain mutation fan-out. |
| BattleContext creation/handoff | Battle scene contract-sensitive. |
| Pending invasion creation/choice/application | UI + turn + battle handoff state. |
| Selection state mutation callbacks | City panel, marker, and tab state coupled. |
| Direct UI node construction/mutation | Needs node ownership boundary first. |
| Signal wiring functions | Scene lifecycle and callback identity sensitive. |
| Domestic Tech completion presentation queue/video/card | Recently fixed user-facing sequence. |

## 8. Verification Plan

Minimum verification for every v0.71 step:

- `git diff --check`.
- Godot project headless load.
- `WorldMap_Test.tscn` headless load.
- `Battle_Fullscreen_Test.tscn` headless load.

Additional recommended checks:

- Check GDScript reload warnings from headless output.
- Check major scene load warnings from headless output.
- Record function count before/after each move.
- Record moved function count and source/destination files.
- Grep for forbidden additions: enemy research storage, AI research, ship/siege persistent storage, save schema keys, BattleContext keys, pending invasion keys.
- For formatter extraction, compare representative before/after text output manually or with a tiny fixture helper.
- For any helper touching completed tech, verify national PLAYER-only and city same-city-only behavior.

Manual F6 QA should be concentrated in `v0.71-12`, not repeated heavily after every small helper extraction unless a visible flow is touched.

## v0.71-04 Destination Folder Mapping

This pass connects the v0.71-00 function map to the v0.71-03 folder skeleton. It is documentation-only: no helper `.gd` file was created and no `worldmap_test.gd` function was moved.

Fresh extraction commands:

```powershell
rg -n "^func |^static func " scripts/worldmap_test.gd
rg -n "^signal |^const |^var |^@onready" scripts/worldmap_test.gd
```

Current totals remain unchanged:

| Metric | Count |
| ------ | ----: |
| Total functions | 1109 |
| Domestic Tech | 317 |
| Economy / City | 167 |
| Diplomacy / Spy | 151 |
| UI Formatter / Summary | 125 |
| Defense / Battle | 122 |
| Mixed / Unsafe | 69 |
| Selection Panel / World UI | 58 |
| Scene / Runtime Orchestration | 39 |
| Debug / QA / Dev Tools | 25 |
| Save / Load | 20 |
| Enemy Baseline / AI-lite | 12 |
| Naval / Siege | 4 |

No `worldmap_test.gd` section comments were added in v0.71-04. The file is already line-sensitive for the refactor map; adding broad comments would add line drift without improving extraction safety enough for this pass.

## Extraction Stage Summary

| Stage | Meaning | Count | First Target? |
| ----- | ------- | ----: | ------------- |
| Stage A | Side-effect-free formatter, summary, lookup, constants-like mapping, or safe-set helper. | 224 | Yes |
| Stage B | Mostly pure helper with read-only state dependency or careful call-site replacement needs. | 356 | Sometimes |
| Stage C | Later refactor candidate with UI node access, selection state, turn flow, action path, or moderate coupling. | 508 | No |
| Stage D | Do Not Move Yet: schema, BattleContext, pending invasion, active/completed mutation, `_ready`, signal wiring, turn orchestration, presentation queue, or state-heavy mutation. | 21 | No |

Stage counts are a v0.71-04 extraction-planning overlay on top of the existing risk map. They preserve the existing risk totals (`Low 224`, `Medium 635`, `High 229`, `Do Not Move Yet 21`) while making the next extraction order explicit.

## Group -> Folder Map

| Function Group | Future Folder | Safe First? | Notes |
| -------------- | ------------- | ----------- | ----- |
| Domestic Tech | `scripts/worldmap/domestic_tech/` | Yes, for Stage A/B lookup and display helpers only | Keep active research mutation, actual charge, completed-state mutation, and presentation queue locked. |
| Economy / City | `scripts/worldmap/economy_city/` | No, except pure formatters later | Resource display and summary helpers are candidates; turn income/resource mutation remains later. |
| Defense / Battle | `scripts/worldmap/defense_battle/` | No | Battle modifier summaries can move later; BattleContext creation and troop accounting stay locked. |
| Diplomacy / Spy | `scripts/worldmap/diplomacy_spy/` | No | UI labels and summaries can move after formula guards; relation and spy payload mutation stay locked. |
| Naval / Siege | `scripts/worldmap/naval_siege/` | No, except small unlock lookup helpers after Domestic Tech | Unlock summaries are candidates; no persistent ship/siege storage or production. |
| UI Formatter / Summary | `scripts/worldmap/ui_formatter/` | Yes, after domain-first Domestic Tech helpers | Pure `_format_*`, bullet, tooltip, and summary builders are the safest shared targets. |
| Save / Load | `scripts/worldmap/save_load/` | No | Schema-sensitive; do not move in early v0.71. |
| Selection Panel / World UI | `scripts/worldmap/selection_panel/` | No | Selected-city display formatters can move later; selection mutation and panel callbacks remain risky. |
| Debug / QA / Dev Tools | `scripts/worldmap/debug_qa/` | Sometimes | Side-effect-free QA summaries are candidates; debug mutation must be task-scoped. |
| Scene / Runtime Orchestration | `scripts/worldmap/orchestration/` | No | `_ready`, turn advance, signal wiring, and scene flow are Stage D/C. |
| Enemy Baseline / AI-lite | `scripts/worldmap/enemy_baseline/` | Later | Read-only baseline helpers are good candidates after Domestic Tech; no enemy research/storage. |
| Mixed / Unsafe | Split by ownership, or keep in `worldmap_test.gd` until clarified | No | Needs call graph and state boundary before movement. |
| Shared | `scripts/worldmap/shared/` | Sometimes | Only constants-like pure utility with clear ownership; avoid becoming a catch-all. |

## Function Family -> Destination Detail

| Function / Family | Current Lines | Group | Future Folder | Extraction Stage | Risk | Move Rule | Notes |
| ----------------- | ------------: | ----- | ------------- | ---------------- | ---- | --------- | ----- |
| Camera pure display helpers such as `_format_vector2` | 1602 | UI Formatter / Orchestration | `scripts/worldmap/ui_formatter/` or `shared/` | Stage A | Low | Pure helper candidate | Camera mutation stays in orchestration. |
| HUD drag and panel anchor helpers | 1393-1491 | Selection Panel / World UI | `scripts/worldmap/selection_panel/` | Stage C | Medium/High | Later only | Direct `Control` mutation and drag state. |
| City marker connect/select callbacks | 1606-1637 | Scene / Runtime Orchestration + Selection | `scripts/worldmap/orchestration/` | Stage D | High | Do not move yet | Signal wiring and selection refresh fan-out. |
| Trade label/preview formatters | 2396-2931, 5015-5675 | Economy / City + UI Formatter | `scripts/worldmap/economy_city/` or `ui_formatter/` | Stage A/B | Low/Medium | Pure formatters first | Trade execution and persistence stay locked. |
| Trade persistence normalizers | 3291-3516 | Save / Load + Economy / City | `scripts/worldmap/save_load/` | Stage C/D | Medium/High | Schema guard required | Payload shape and player-state mirror. |
| Diplomacy/spy UI labels and summaries | 3920-5014 | Diplomacy / Spy + UI Formatter | `scripts/worldmap/diplomacy_spy/` or `ui_formatter/` | Stage A/B/C | Low/Medium/High | Formatters before action logic | Action cards mutate nodes; formulas stay in place. |
| Enemy baseline read-only helpers | 4412-4729 | Enemy Baseline / AI-lite | `scripts/worldmap/enemy_baseline/` | Stage B | Low/Medium | Read-only only | Must remain baseline/resistance, not enemy research. |
| Pending invasion UI and payload | 5913-8159 | Defense / Battle + Orchestration | `scripts/worldmap/defense_battle/` | Stage D | High | Do not move yet | Pending event shape and defense choice flow. |
| Player attack/defense deployment helpers | 8160-9050 | Defense / Battle | `scripts/worldmap/defense_battle/` | Stage C/D | High | No early move | BattleContext and troop accounting sensitive. |
| Domestic Tech definition and identity lookups | 10173-10457 | Domestic Tech | `scripts/worldmap/domestic_tech/` | Stage A/B | Low/Medium | First batch candidate | No mutation except read-only completed wrappers. |
| Domestic Tech modifier and safe-set helpers | 10461-11274 | Domestic Tech by domain | `domestic_tech/`, then domain folders | Stage B | Low/Medium | Domain-staged extraction | Preserve PLAYER-only and same-city contracts. |
| Domestic Tech formatter/summary helpers | 11480-14579, 14768-14937 | Domestic Tech + UI Formatter | `domestic_tech/` or `ui_formatter/` | Stage A/B | Low/Medium | Good after first batch | Completion queue itself remains locked. |
| Domestic Tech graph/tree UI builders | 12115-14322 | Domestic Tech + Selection/UI | `scripts/worldmap/domestic_tech/` | Stage C | Medium/High | Later only | Direct node construction and selection styling. |
| Domestic Tech actual charge and research lifecycle | 12572-12747, 15519-15760 | Domestic Tech | `scripts/worldmap/domestic_tech/` | Stage D | High | Do not move yet | Active payload and actual charge locked. |
| Domestic Tech completion presentation queue/video/card | 14586-15124 | Domestic Tech + UI Formatter | `scripts/worldmap/domestic_tech/` | Stage D | High | Do not move yet | Recently fixed user-visible queue. |
| BattleContext handoff and result processing | 16991-17610 | Defense / Battle | `scripts/worldmap/defense_battle/` | Stage D | High | Do not move yet | Battle scene contract-sensitive. |
| Diplomacy/spy validation, rolls, mutation | 17611-20568 | Diplomacy / Spy | `scripts/worldmap/diplomacy_spy/` | Stage C/D | Medium/High | Formula guard required | Relation and spy payload schemas. |
| Turn economy/city mutation | 20569-21181, 17727-18038 | Economy / City + Orchestration | `scripts/worldmap/economy_city/` | Stage C/D | High | Later only | Resource/city state mutation. |
| Save/load runtime state | 21599-21987 | Save / Load | `scripts/worldmap/save_load/` | Stage D | High | Do not move yet | Save payload and old-save compatibility. |
| City/hero/storage pure display helpers | 22001-22525 | Economy / City + UI Formatter | `economy_city/` or `ui_formatter/` | Stage A/B/C | Low/Medium/High | Separate getter/formatter from mutation | Storage mutation remains locked. |
| Final selected city/chancellor callbacks | 22526-23096 | Selection Panel / World UI | `scripts/worldmap/selection_panel/` | Stage C | Medium/High | Later only | UI state and signal callbacks. |

## Recommended v0.71-05 First Extraction Batch

First batch should be small and Domestic-Tech-only. It should create a helper with pure identity/display/lookup functions, then replace call sites carefully while preserving current names or wrappers if needed.

| Function | Current Lines | Future Folder | Reason Safe | Exclusion Notes |
| -------- | ------------: | ------------- | ----------- | --------------- |
| `_get_domestic_tech_categories_mvp` | 10173 | `scripts/worldmap/domestic_tech/` | Constants-like category map. | Does not mutate state. |
| `_get_domestic_tech_duration_class_mvp` | 10317 | `scripts/worldmap/domestic_tech/` | Pure tier/rarity label helper. | No payload access. |
| `_get_domestic_tech_duration_turns_hint_mvp` | 10327 | `scripts/worldmap/domestic_tech/` | Pure duration hint helper. | Keep duration values unchanged. |
| `_get_domestic_tech_tier_duration_turns_mvp` | 10332 | `scripts/worldmap/domestic_tech/` | Pure tier duration lookup. | No active research mutation. |
| `_get_domestic_tech_scope_duration_turns_mvp` | 10346 | `scripts/worldmap/domestic_tech/` | Pure scope duration lookup. | No active research mutation. |
| `_get_domestic_tech_definition_mvp` | 10387 | `scripts/worldmap/domestic_tech/` | Read-only definition lookup. | Definition source should stay unchanged. |
| `_get_domestic_techs_by_scope_mvp` | 10395 | `scripts/worldmap/domestic_tech/` | Read-only filter helper. | No state mutation. |
| `_get_domestic_techs_by_category_mvp` | 10406 | `scripts/worldmap/domestic_tech/` | Read-only filter helper. | No state mutation. |
| `_get_domestic_techs_by_branch_mvp` | 10417 | `scripts/worldmap/domestic_tech/` | Read-only filter helper. | No state mutation. |
| `_is_domestic_city_tech_mvp` | 10428 | `scripts/worldmap/domestic_tech/` | Pure scope predicate. | No completed-state mutation. |
| `_is_domestic_national_tech_mvp` | 10432 | `scripts/worldmap/domestic_tech/` | Pure scope predicate. | No completed-state mutation. |
| `_is_city_domestic_tech_completed_mvp` | 10436 | `scripts/worldmap/domestic_tech/` | Read-only completed lookup wrapper. | Must preserve same-city PLAYER-only contract. |
| `_is_national_domestic_tech_completed_mvp` | 10446 | `scripts/worldmap/domestic_tech/` | Read-only completed lookup wrapper. | Must preserve PLAYER-only contract. |
| `_has_completed_national_domestic_tech_mvp` | 10453 | `scripts/worldmap/domestic_tech/` | Thin read-only alias. | Preserve return behavior. |
| `_has_completed_city_domestic_tech_mvp` | 10457 | `scripts/worldmap/domestic_tech/` | Thin read-only alias. | Preserve same-city behavior. |
| `_format_domestic_tech_percent_bonus_mvp` | 11480 | `scripts/worldmap/domestic_tech/` or `ui_formatter/` | Pure text formatter. | No node access. |
| `_get_unique_domestic_tech_source_ids_mvp` | 11484 | `scripts/worldmap/domestic_tech/` | Pure array normalization/dedup helper. | No schema mutation. |
| `_format_domestic_tech_source_display_mvp` | 11498 | `scripts/worldmap/domestic_tech/` or `ui_formatter/` | Pure source display formatter. | Calls display lookup only. |
| `_get_domestic_tech_icon_path_mvp` | 12088 | `scripts/worldmap/domestic_tech/` | Pure icon path lookup. | Do not change asset paths. |
| `_get_domestic_tech_ui64_icon_filename_mvp` | 12092 | `scripts/worldmap/domestic_tech/` | Pure filename lookup. | Do not touch assets/imports. |
| `_get_domestic_tech_resolved_icon_path_mvp` | 12096 | `scripts/worldmap/domestic_tech/` | Pure path resolver. | Do not change fallback policy. |
| `_is_domestic_tech_icon_missing_mvp` | 12107 | `scripts/worldmap/domestic_tech/` | Pure icon metadata check. | No filesystem writes. |
| `_get_domestic_tech_icon_fallback_label_mvp` | 12111 | `scripts/worldmap/domestic_tech/` | Pure fallback label helper. | No UI node mutation. |

Recommended batch count: `23`.

Why this batch is safe:

- It avoids research start/progress/complete mutation.
- It avoids actual charge validation/application.
- It avoids completion queue/video/card mutation.
- It avoids save/load, BattleContext, pending invasion, turn orchestration, and scene-node-heavy graph builders.
- The only state reads are completed-tech lookup wrappers, which are intentionally read-only and already part of the v0.70 completed-tech contract.

Verification for v0.71-05:

- `git diff --check`.
- Godot project headless load.
- `WorldMap_Test.tscn` headless load.
- `Battle_Fullscreen_Test.tscn` headless load.
- Grep for `national_domestic_tech_completed`, `city_domestic_tech_completed`, active research keys, and completion queue references to confirm no schema or queue movement happened.
- Domestic Tech tree smoke: definitions, icons, completed status, and source display must still resolve through the original call surface.

Excluded from first batch:

- `_start_domestic_tech_research_mvp`, `_advance_domestic_tech_research_for_world_turn_mvp`, `_complete_national_tech_research_mvp`, `_complete_city_tech_research_mvp`.
- `_build_domestic_tech_actual_charge_plan_mvp`, `_validate_domestic_tech_actual_charge_mvp`, `_apply_domestic_tech_actual_charge_mvp`.
- `_enqueue_domestic_tech_completion_presentations_mvp`, `_play_next_domestic_tech_completion_presentation`, `_show_domestic_tech_completion_card_mvp`.
- Domestic Tech graph/tree node builders and UI signal handlers.
- Save/load, BattleContext, pending invasion, turn advance, and scene signal wiring.

## v0.71-05 Domestic Tech Helper Extraction Result

- Extracted helper file:
  - `scripts/worldmap/domestic_tech/domestic_tech_helpers.gd`
- Extraction style:
  - Static `RefCounted` helper functions.
  - Existing `scripts/worldmap_test.gd` private function names were kept as wrappers to avoid broad call-site churn.

### Extracted Functions

| Function | Previous Location | New Location | Wrapper Kept? | Reason Safe |
|---|---|---|---|---|
| `_get_domestic_tech_duration_class_mvp` | `scripts/worldmap_test.gd` | `DomesticTechHelperLib.get_duration_class_mvp` | Yes | Pure tier/rarity label mapping. |
| `_get_domestic_tech_duration_turns_hint_mvp` | `scripts/worldmap_test.gd` | `DomesticTechHelperLib.get_duration_turns_hint_mvp` | Yes | Pure duration hint dictionary; no active research access. |
| `_get_domestic_tech_tier_duration_turns_mvp` | `scripts/worldmap_test.gd` | `DomesticTechHelperLib.get_tier_duration_turns_mvp` | Yes | Pure tier-to-turn lookup. |
| `_get_domestic_tech_scope_duration_turns_mvp` | `scripts/worldmap_test.gd` | `DomesticTechHelperLib.get_scope_duration_turns_mvp` | Yes | Pure scope/tier/rarity duration lookup; scope id is passed as data. |
| `_format_domestic_tech_percent_bonus_mvp` | `scripts/worldmap_test.gd` | `DomesticTechHelperLib.format_percent_bonus_mvp` | Yes | Pure text formatter with local signed-int formatting. |
| `_get_unique_domestic_tech_source_ids_mvp` | `scripts/worldmap_test.gd` | `DomesticTechHelperLib.get_unique_source_ids_mvp` | Yes | Pure array normalization and de-duplication. |
| `_get_domestic_tech_ui64_icon_filename_mvp` | `scripts/worldmap_test.gd` | `DomesticTechHelperLib.get_ui64_icon_filename_mvp` | Yes | Pure filename lookup; filename map is passed as data. |
| `_get_domestic_tech_resolved_icon_path_mvp` | `scripts/worldmap_test.gd` | `DomesticTechHelperLib.get_resolved_icon_path_mvp` | Yes | Read-only icon path resolution; asset/import files are untouched. |

### Deferred Domestic Tech Functions

| Function / Family | Reason Deferred | Stage |
|---|---|---|
| Research start/progress/complete lifecycle | Mutates active research and completed tech state. | Stage D |
| Actual charge validation/application | Cost/payment behavior and food group deduction order are locked. | Stage D |
| Completion queue, video, and card presentation | Runtime queue mutation and scene-node-heavy presentation flow. | Stage D |
| Completed tech lookup wrappers | Read-only, but PLAYER-only and same-city contracts should move after the first helper smoke pass. | Stage B |
| Definition/filter helpers | Read-only, but still close to definition construction and category maps. | Stage B |
| Source display formatter | Calls display-name lookup; defer until definition helpers have a stable boundary. | Stage B |
| Icon missing/fallback metadata helpers | Read definition payload; defer until definition lookup boundary is extracted. | Stage B |
| Tech graph/tree node builders and UI signal handlers | Scene-node-heavy UI layout and signal behavior. | Stage C/D |

### Safety Notes

- Active research mutation remains in `scripts/worldmap_test.gd`.
- Actual charge logic remains in `scripts/worldmap_test.gd`.
- Completion queue / video / card presentation mutation remains in `scripts/worldmap_test.gd`.
- Save/load, BattleContext, pending invasion, and turn orchestration remain untouched.

## v0.71-06 Economy / City Helper Extraction Result

- Extracted helper file:
  - `scripts/worldmap/economy_city/economy_city_helpers.gd`
- Extraction style:
  - Static `RefCounted` helper functions.
  - Existing `scripts/worldmap_test.gd` private function names were kept as wrappers to preserve call-site signatures and return shapes.

### Extracted Functions

| Function | Previous Location | New Location | Wrapper Kept? | Reason Safe |
|---|---|---|---|---|
| `_extract_resource_group` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.extract_resource_group` | Yes | Pure string/resource-name formatter. |
| `_format_internal_trade_lead_display` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.format_internal_trade_lead_display` | Yes | Pure display text helper. |
| `_format_internal_trade_policy_display` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.format_internal_trade_policy_display` | Yes | Pure display text helper. |
| `_format_external_trade_lead_display` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.format_external_trade_lead_display` | Yes | Pure display text helper. |
| `_format_external_trade_policy_display` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.format_external_trade_policy_display` | Yes | Pure display text helper. |
| `_format_supply_role_label` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.format_supply_role_label` | Yes | Pure supply role label lookup. |
| `_format_supply_status_label` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.format_supply_status_label` | Yes | Pure supply status label lookup. |
| `_get_trade_display_totals` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.get_trade_display_totals` | Yes | Read-only dictionary selector; no mutation. |
| `_format_trade_resource_totals_display` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.format_trade_resource_totals_display` | Yes | Pure resource total formatter; labels are passed as data. |
| `_get_city_storage_amount` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.get_city_storage_amount` | Yes | Pure clamped dictionary read. |
| `_get_city_storage_status_label` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.get_city_storage_status_label` | Yes | Pure storage threshold label lookup. |
| `_get_resource_status_label` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.get_resource_status_label` | Yes | Pure warehouse status label lookup; thresholds are passed as data. |
| `_format_resource_costs` | `scripts/worldmap_test.gd` | `EconomyCityHelpers.format_resource_costs` | Yes | Pure cost display formatter; labels are passed as data. |

### Deferred Economy / City Functions

| Function / Family | Reason Deferred | Stage |
|---|---|---|
| City state mutation and runtime roster mutation | Mutates `_city_runtime_states` / hero-city ownership state. | Stage D |
| Turn income calculation and application | Gameplay formula/order sensitive. | Stage C/D |
| Storage/resource mutation | Changes city or player resource stock. | Stage D |
| Save/load and trade persistence normalizers | Schema and persisted payload sensitive. | Stage C/D |
| Selection panel and city detail UI node updates | Scene-node-heavy UI behavior. | Stage C |
| Trade execution and auto trade application | Resource mutation and turn orchestration. | Stage C/D |

### Safety Notes

- City state mutation remains in `scripts/worldmap_test.gd`.
- Turn income mutation remains in `scripts/worldmap_test.gd`.
- Storage/resource mutation remains in `scripts/worldmap_test.gd`.
- Save/load, BattleContext, pending invasion, and turn orchestration remain untouched.
- No rollback was needed for v0.71-06.

## v0.71-07 Defense / Battle Helper Extraction Result

- Extracted helper file:
  - `scripts/worldmap/defense_battle/defense_battle_helpers.gd`
- Extraction style:
  - Static `RefCounted` helper functions.
  - Existing `scripts/worldmap_test.gd` private function names were kept as wrappers to preserve call-site signatures and return shapes.

### Extracted Functions

| Function | Previous Location | New Location | Wrapper Kept? | Reason Safe |
|---|---|---|---|---|
| `_format_troop_move_button_text` | `scripts/worldmap_test.gd` | `DefenseBattleHelpers.format_troop_move_button_text` | Yes | Pure button label formatter from a preview dictionary. |
| `_format_troop_move_reason` | `scripts/worldmap_test.gd` | `DefenseBattleHelpers.format_troop_move_reason` | Yes | Pure movement rejection reason formatter; no troop/state mutation. |
| `_limit_invasion_result_lines` | `scripts/worldmap_test.gd` | `DefenseBattleHelpers.limit_invasion_result_lines` | Yes | Pure non-empty line limiter for result display. |
| `_normalize_command_rank_mvp` | `scripts/worldmap_test.gd` | `DefenseBattleHelpers.normalize_command_rank_mvp` | Yes | Pure command rank normalization; rank limits/fallbacks are passed as data. |

### Deferred Defense / Battle Functions

| Function / Family | Reason Deferred | Stage |
|---|---|---|
| BattleContext generation | Builds the battle scene payload and schema-sensitive handoff. | Stage D |
| Pending invasion payload generation and choice UI | Pending invasion schema and scene-node-heavy UI ownership. | Stage D |
| Battle formula / stat calculation | Gameplay number and result sensitivity. | Stage D |
| Deployment validation and payload mutation | Attack/defense eligibility and payload shape sensitivity. | Stage D |
| Battle result application | Mutates city ownership, hero state, pending state, and result UI. | Stage D |
| City defense and troop mutation | Changes runtime city/battle resources. | Stage D |
| Save/load and turn orchestration | Schema and cross-domain turn flow sensitivity. | Stage D |

### Safety Notes

- BattleContext generation remains in `scripts/worldmap_test.gd`.
- Pending invasion payload generation remains in `scripts/worldmap_test.gd`.
- Battle formula / stat calculation remains in `scripts/worldmap_test.gd`.
- Deployment validation and payload mutation remain in `scripts/worldmap_test.gd`.
- Save/load and turn orchestration remain untouched.
- No rollback was needed for v0.71-07.

## v0.71-07a Remaining Domain Refactor Boundary Plan

### Why This Plan Exists

`Selection Panel / World UI`, `Scene / Runtime Orchestration`, `Debug / QA / Dev Tools`, `Save / Load`, `Enemy Baseline / AI-lite`, and `Mixed / Unsafe` together represent a large remaining portion of `scripts/worldmap_test.gd`.

These domains are not all intended to be extracted during v0.71. Some are intentionally locked because they own schema, scene lifecycle, runtime orchestration, or high-risk mixed state.

### Remaining Domain Handling Table

| Domain | Count | v0.71 Handling | Extraction Allowed? | Planned Stage | Lock Rule |
|---|---:|---|---|---|---|
| Selection Panel / World UI | 58 | Partial / formatter-only | Only pure formatter/summary helpers | v0.71-10 / v0.71-11 | Panel state mutation and node ownership stay in `worldmap_test.gd` by design. |
| Scene / Runtime Orchestration | 39 | Orchestrator slim only | No functional extraction in v0.71 | v0.71-11 | Scene lifecycle, `_ready`, signal wiring, turn advance, and queue orchestration stay locked. |
| Debug / QA / Dev Tools | 25 | Optional / future extraction | No extraction during v0.71-08 through v0.71-10 | v0.71-11 review or v0.72+ | Debug tools are not required for v0.71 extraction completion. |
| Save / Load | 20 | Keep in `worldmap_test.gd` by design | No | v0.72+ dedicated schema-protected task | Save/load schema-sensitive functions are out of extraction scope for v0.71. |
| Enemy Baseline / AI-lite | 12 | Optional read-only helper extraction later | No extraction during v0.71-08 through v0.71-10 | v0.71-11 review or v0.72+ | Enemy research remains out of scope; read-only helpers may stay in place. |
| Mixed / Unsafe | 69 | Defer | No broad extraction | v0.72+ | Mixed/unsafe functions are not required to be extracted for v0.71 Complete Lock. |

### Opportunistic Extraction Ban

Opportunistic extraction is forbidden during v0.71-08 through v0.71-10. Debug / QA, Enemy Baseline, and Mixed / Unsafe helpers may only be reconsidered during v0.71-11 or a later dedicated task, and must not be moved as part of Diplomacy / Spy, Naval / Siege, or UI Formatter extraction.

### v0.71-11 WorldMap Orchestrator Slim Scope

Allowed:
- Section/comment cleanup.
- Wrapper/call grouping review.
- Read-only helper call organization.
- Remaining high-risk lock list finalization.
- Documentation of why certain functions remain in `worldmap_test.gd`.
- Debug / QA and Enemy Baseline review only, without opportunistic extraction.

Not allowed:
- Save/load extraction.
- `_ready` extraction.
- Signal wiring extraction.
- Turn advance extraction.
- BattleContext extraction.
- Pending invasion extraction.
- Completion queue extraction.
- Selection panel node ownership extraction.
- Mixed/Unsafe broad extraction.
- Debug / QA opportunistic extraction.
- Enemy Baseline opportunistic extraction.

### v0.71-14 Complete Lock Meaning

v0.71 Refactor Complete Lock does not mean every `worldmap_test.gd` function was extracted. It means all approved low-risk extraction batches were completed or explicitly deferred, and high-risk schema/runtime orchestration functions remain locked in place by design.

## Do Not Move Yet Lock List

| Function | Reason | Related Schema/State | Earliest Possible Stage |
| -------- | ------ | -------------------- | ----------------------- |
| `_ready` | Scene boot order, initial setup, and cross-domain signal startup. | Scene tree and runtime startup state | Stage D |
| `_connect_city_markers` | Signal wiring and selected-city fan-out. | City marker signals, selected city state | Stage D |
| `_connect_world_hud_placeholders` | Signal wiring for HUD actions. | World HUD callbacks | Stage D |
| `_setup_pending_invasion_choice_ui` | Builds pending invasion choice UI and owns button wiring. | Pending invasion UI state | Stage D |
| `_build_battle_context_from_pending_invasion` | Creates BattleContext consumed by battle scene. | BattleContext schema, pending invasion payload | Stage D |
| `_build_player_attack_battle_context` | Creates player attack BattleContext and supply/troop metadata. | BattleContext schema, player attack payload | Stage D |
| `_serialize_worldmap_state` | Save payload root. | Save/load schema | Stage D |
| `_apply_worldmap_state` | Runtime restore and old-save compatibility. | Save/load schema, city/player/hero state | Stage D |
| `_save_worldmap_state` | Writes save payload. | Save file contract | Stage D |
| `_load_worldmap_state` | Loads and applies save payload. | Save file contract | Stage D |
| `_apply_domestic_tech_actual_charge_mvp` | Deducts start-time actual charge. | Actual charge logic, resources | Stage D |
| `_start_domestic_tech_research_mvp` | Mutates active research payload. | Active research schema | Stage D |
| `_advance_domestic_tech_research_for_world_turn_mvp` | Turn-based research orchestration. | Active research, completion events | Stage D |
| `_complete_national_tech_research_mvp` | Mutates completed national tech state. | Completed tech state | Stage D |
| `_complete_city_tech_research_mvp` | Mutates completed city tech state. | Completed tech state | Stage D |
| `_enqueue_domestic_tech_completion_presentations_mvp` | Mutates completion presentation queue. | Runtime presentation queue | Stage D |
| `_play_next_domestic_tech_completion_presentation` | Drives video/card sequence. | Runtime presentation queue/video state | Stage D |
| `_show_domestic_tech_completion_card_mvp` | Direct UI node mutation in completion flow. | Completion card nodes | Stage D |
| `_normalize_domestic_tech_state_mvp` | Normalizes active/completed tech state. | Active/completed tech schema | Stage D |
| `_mark_domestic_tech_completed_from_normalize_mvp` | Mutates completed-tech mirror during normalization. | Completed tech state | Stage D |
| `_apply_domestic_turn_mvp` | Cross-domain turn orchestration. | Economy, tech progress, diplomacy/spy cooldowns, summaries | Stage D |
| `_apply_resource_delta` | Mutates player resources. | Player resource state | Stage D |

## 9. v0.71-01 Entry Criteria

- `worldmap_test.gd` function map is written.
- High-risk and `Do Not Move Yet` functions are separated.
- Schema-sensitive areas are separated.
- Low-risk extraction candidates are identified.
- Required agent docs are updated to v0.71-00.
- Headless load verification passes.
- Local commit is completed.
