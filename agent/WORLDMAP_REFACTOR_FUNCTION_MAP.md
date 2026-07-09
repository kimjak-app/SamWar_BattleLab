# WorldMap Refactor Function Map

## 1. Baseline
- v0.71-00 기준 커밋: `621be2a8c9eef7cf6575b2636aa89fa2564e7319` (`v0.70-99-hotfix2 Research Completion Effect Summary Fix`).
- 작업 시작 시 local HEAD: `621be2a8c9eef7cf6575b2636aa89fa2564e7319`.
- 작업 시작 시 `origin/main` HEAD: `621be2a8c9eef7cf6575b2636aa89fa2564e7319`.
- 작업 시작 시 working tree 상태: tracked files clean.
- 분석 대상: `scripts/worldmap_test.gd`.
- 보조 확인: `project.godot` main scene is `res://Battle_Singijeon_Test.tscn`; test scenes include `WorldMap_Test.tscn`, `Battle_Fullscreen_Test.tscn`, `Battle_WebImport_Test.tscn`, and `scenes/dev/video_theora_test.tscn`.
- v0.71-01 note: `project.godot` main scene was switched to the existing root scene `res://WorldMap_Test.tscn`; `scenes/WorldMap_Test.tscn` is absent and no scene files were moved or renamed.

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

## 9. v0.71-01 Entry Criteria

- `worldmap_test.gd` function map is written.
- High-risk and `Do Not Move Yet` functions are separated.
- Schema-sensitive areas are separated.
- Low-risk extraction candidates are identified.
- Required agent docs are updated to v0.71-00.
- Headless load verification passes.
- Local commit is completed.
