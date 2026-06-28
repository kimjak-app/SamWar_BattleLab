# HANDOFF TO CODEX

## v0.70-67 Domestic Tech Actual Effects Phase 1 Handoff
- Baseline: `v0.70-66-hotfix1 Domestic Tech Research QA & Completion Polish` (`c2f8d7d217c1b17cd9b9eefd67358cb5a6c1fd3a`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is the first Domestic Tech actual-effects slice, limited to unlock/condition/display behavior only.
- Required national tech checks now route through an explicit completed-only helper. `_player_state["national_domestic_tech_completed"]` is the source of truth; active/researching national tech is not unlock credit.
- City prerequisites still use `_player_state["city_domestic_tech_completed"]` by city id, so completed city tech only unlocks follow-up tech in the same city.
- Inspector relation display now reports unlock/enhance status from completed state: research needed for incomplete national tech, and 해금됨/해금 가능/조건 충족/강화 조건 충족 for completed national relations.
- City tech inspector lines show required national and enhanced-by national tech completion status without exposing enemy-city detail.
- `effect_stub` remains display-only. Completed techs show application readiness; incomplete techs show research-needed readiness; all numeric effect application is deferred.
- Added `_get_domestic_tech_effect_phase1_summary_mvp()` for internal QA only; it reports `numeric_effects_applied = 0` and performs no gameplay mutation.
- Explicitly unchanged: resource payment, resource/income/troop/battle/diplomacy/spy/market formulas, AI research, enemy research/effect, enemy city tech exposure, BattleContext, pending invasion, scenes, assets, icon PNGs, UI64 PNGs, and `.import` files.
- UI64 priority, node-click latency guard, overlay lifecycle, active/completed normalize, research start/progress/completion, and enemy/insufficient-intel safety remain locked.
- Next candidate: `v0.70-67-hotfix1 Domestic Tech Effect Phase 1 QA Polish` or `v0.70-68 Domestic Tech Numeric Effects Phase 1 - Economy Safe Set`.
- Manual F6 QA remains required for national-to-city unlock, same-city city prerequisite only, relation display, effect display, no resource/troop/battle/diplomacy/spy/market mutation, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## v0.70-66-hotfix1 Domestic Tech Research QA & Completion Polish Handoff
- Baseline: `v0.70-66 Domestic Tech Research Progress & Completion MVP` (`1f9bb843ced5730483867ac546f4b208df0347b2`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is a QA/polish hotfix for Domestic Tech research state only. It is not actual tech effect application.
- Active research normalize now treats missing, empty, malformed, already-completed, and 0/negative `remaining_turns` active state safely.
- Completed state normalize accepts missing/null and list-shaped legacy data where possible, producing Dictionary-shaped national and per-city completed state.
- Turn advancement clamps `remaining_turns` to 0 and completion clears active state.
- Duplicate completion guards prevent repeated player-facing messages if an already completed tech remains in active state.
- City completed source of truth remains `_player_state["city_domestic_tech_completed"]`; city runtime `city_tech.completed` is a mirror synced per city.
- Completed techs count for prerequisites and `required_national_techs`; active/researching techs still do not count as completed.
- Explicitly unchanged: resource payment, actual effects, effect stubs, AI research, enemy research, income/resource/troop/battle/diplomacy/spy/market formulas, enemy pressure plan, pending invasion, BattleContext, scenes, assets, icon PNGs, UI64 PNGs, and `.import` files.
- UI64 priority, node-click latency guard, overlay lifecycle, and enemy/insufficient-intel safety remain locked.
- Next candidate: `v0.70-67 Domestic Tech Actual Effects Phase 1`, starting with the safest display/unlock effect slice.
- Manual F6 QA remains required for national/city progress, completion display, duplicate notification absence, city-specific completed separation, save/load, follow-up tech availability, no resource/effect mutation, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## v0.70-66 Domestic Tech Research Progress & Completion MVP Handoff
- Baseline: `v0.70-65 Domestic Tech Research Start MVP` (`c27e46034684a0385f76bf3816f22a71c76eda2a` locally at task start, matching `origin/main`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass implements Domestic Tech Tree research progress and completion state only. It is not actual tech effect application.
- World domestic turn apply now calls `_advance_domestic_tech_research_for_world_turn_mvp()`.
- National research:
  - Active state remains `_player_state["national_tech_research"]["active"]`.
  - Each completed player turn decrements `remaining_turns`.
  - Completion writes `_player_state["national_domestic_tech_completed"][tech_id] = true` and clears the active national slot.
- City research:
  - Active state remains `city_data["city_tech"]["research"]["active"]`.
  - Only PLAYER-owned city active research advances.
  - Completion writes the matching city entry in `_player_state["city_domestic_tech_completed"]`, mirrors that tech id into that city's `city_tech.completed`, and clears only that city's active slot.
- Existing prerequisite helpers continue to use completed state only. `DOMESTIC_TECH_VIEW_RESEARCHING` and active research are not prerequisite credit.
- Completion is surfaced through domestic turn summary messages; an open tech overlay refreshes after completion, while node-click still avoids full graph rebuild.
- Explicitly unchanged: resource payment, resource mutation from Domestic Tech Tree research, actual effects, effect stubs, AI research, enemy research, income/resource/troop/battle/diplomacy/spy/market formulas, enemy pressure plan, pending invasion, BattleContext, scenes, assets, icon PNGs, UI64 PNGs, and `.import` files.
- Hotfix4 node click latency remains locked; completion refresh is allowed only because turn state changed.
- Hotfix5 UI64 binding remains locked: UI64 mapped icon first, existing `icon_path` fallback second, `?` fallback last; `assets/ui/tech_icons_ui64/etc/` remains archival and unmapped.
- Enemy/insufficient-intel safety remains locked: left panel is PLAYER national tech only, and right city tech detail/research only applies to selected PLAYER cities.
- Next candidate: `v0.70-67 Domestic Tech Actual Effects Phase 1`, or `v0.70-66-hotfix1 Research Progress QA Polish`.
- Manual F6 QA remains required for national/city progress, completion display, active clear, follow-up tech availability, no resource/effect mutation, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## v0.70-65 Domestic Tech Research Start MVP Handoff
- Baseline: `v0.70-64 Domestic Tech Research Readiness Layer` (`d442f1ee1d414a7cdb11e57d93ba46f625815b37`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass implements research start MVP only: pressing an enabled research button stores active research state and refreshes UI. It is not research turn progression, not research completion, and not actual effect application.
- National research state is `_player_state["national_tech_research"]["active"]`, limited to one active national domestic tech.
- City research state is `city_data["city_tech"]["research"]["active"]`, limited to one active city domestic tech per player city.
- Active research stores `tech_id`, `started_turn`, `remaining_turns`, and `duration_turns`. The MVP does not decrease `remaining_turns`.
- `DOMESTIC_TECH_VIEW_RESEARCHING` is a display state only. It must not count as completed for prerequisites, unlocks, effects, or completion checks.
- The research action button may connect `pressed` only when `_can_start_domestic_tech_research_mvp()` returns `ok = true`; blocked/completed/researching states keep the button disabled.
- Explicitly unchanged: resource payment, resource mutation, completed tech mutation, effect application, AI research, turn processing, income/resource/troop/battle/diplomacy/spy/market formulas, enemy pressure plan, pending invasion, BattleContext, scenes, assets, icon PNGs, UI64 PNGs, and `.import` files.
- Hotfix4 node click latency remains locked: node click must not rebuild the full graph. Research button press may refresh the overlay because state changed.
- Hotfix5 UI64 binding remains locked: UI64 mapped icon first, existing `icon_path` fallback second, `?` fallback last; `assets/ui/tech_icons_ui64/etc/` remains archival and unmapped.
- Enemy/insufficient-intel safety remains locked: left panel is PLAYER national tech only, and right city tech detail/research start only applies to selected PLAYER cities.
- Next candidate: `v0.70-66 Domestic Tech Research Progress & Completion MVP`; actual effect application should remain deferred.
- Manual F6 QA remains required for national/city research start, duplicate research blocking, researching display, no resource/completed mutation, enemy-city safety, icon visibility, click latency, overlay lifecycle, and warning cleanliness.

## v0.70-64 Domestic Tech Research Readiness Layer Handoff
- Baseline: `v0.70-63-hotfix6 Domestic Tech Tree Final UI QA & Overlay Lifecycle Polish` (`53908b8a8e752ace989049e637dc9d7ef75d98db`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass prepares the Domestic Tech Tree detail inspector for the future research system. It is not research start, not research queueing, not research progress, not research completion, and not actual effect application.
- Detail inspector now shows selected tech name, scope/category/branch/tier, rarity, current state, effect, cost, build/research time hint, condition status, readiness copy, and display-only national/city relation lines.
- Research readiness copy maps node state to inspector state: completed -> `완료됨`, available -> `준비 가능`, locked -> `조건 부족`, and special_locked -> `특수 조건 필요`.
- The research action slot is visible but disabled. `DomesticTechResearchActionButtonMVP` must stay `disabled = true` and must not connect `pressed` to research, queue, resource payment, completion, or effect code.
- Condition/relationship formatting is display-only. Do not rename data ids, save keys, prerequisite ids, category ids, branch ids, costs, durations, or effect stubs for copy polish.
- Hotfix4 node click latency remains locked: compact node click updates selected ids, refreshes the inspector immediately, consumes input, and restyles previous/current compact nodes without rebuilding graphs.
- Hotfix5 UI64 binding remains locked: UI64 mapped icon first, existing `icon_path` fallback second, `?` fallback last; `assets/ui/tech_icons_ui64/etc/` remains archival and unmapped.
- Enemy/insufficient-intel safety remains locked: left panel is PLAYER national tech only, and right city tech detail only renders for selected PLAYER cities.
- Explicitly unchanged: research state mutation, resource mutation, city/national completed tech mutation, actual effects, AI research, income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, `city_intel`, Fog of War, scenes, assets, icon PNGs, UI64 PNGs, `.import` files, and thumbnail generation.
- Next candidate: `v0.70-65 Domestic Tech Research Start MVP`; actual effect application should remain deferred.
- Manual F6 QA remains required for available/locked/special-locked/completed readiness display, disabled action slot, no mutation, relation display, icon visibility, click latency, overlay lifecycle, enemy-city safety, and warning cleanliness.

## v0.70-63-hotfix6 Domestic Tech Tree Final UI QA & Overlay Lifecycle Polish Handoff
- Baseline: `v0.70-63-hotfix5 Domestic Tech Tree UI64 Icon Binding` (`77eb052f844251141d9181caf1f7fee55e586c57`).
- Runtime file audited: `scripts/worldmap_test.gd`.
- No runtime code change was required in this pass. This pass documents final Domestic Tech Tree UI QA and overlay lifecycle confirmation.
- Button lifecycle remains: `_ensure_domestic_tech_tree_button_mvp()` creates one `DomesticTechTreeButtonMVP`, sets text to `테크트리`, and connects `pressed` to `_open_domestic_tech_tree_overlay_mvp()`.
- Overlay lifecycle remains: `_ensure_domestic_tech_tree_overlay_mvp()` creates one top-layer `tech_tree_overlay_mvp`, `_refresh_domestic_tech_tree_overlay_mvp()` clears content children before rebuild, and repeated opens reuse the overlay.
- Close lifecycle remains: `닫기` calls `_close_domestic_tech_tree_overlay_mvp()`, ESC is handled in `_unhandled_input()`, saved panels restore through `_restore_worldmap_panels_after_tech_tree_mvp()`, and hidden state is cleared after restore.
- Hotfix4 node click latency remains locked: node click must only update selected ids, refresh the detail inspector, consume input, and restyle previous/current compact node cards.
- Hotfix5 UI64 binding remains locked: UI64 mapped icon first, existing `icon_path` fallback second, `?` fallback last; `assets/ui/tech_icons_ui64/etc/` remains archival and unmapped.
- Enemy/insufficient-intel safety remains locked: left panel is PLAYER national tech only, and right city detail only renders for selected PLAYER cities.
- Explicitly unchanged: research start/progress/completion, actual effects, AI research, income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, `city_intel`, Fog of War, scenes, assets, icon PNGs, `.import` files, and thumbnail generation.
- Manual F6 QA remains required for repeated button open, close/ESC/reopen, panel restore, UI64 icon visibility, detail inspector latency, enemy-city safety, scroll/layout, overlay top-layer behavior, no gameplay mutation, and warning cleanliness.

## v0.70-63-hotfix5 Domestic Tech Tree UI64 Icon Binding Handoff
- Baseline: `v0.70-63-hotfix4 Domestic Tech Tree Click Latency & Icon Readability Polish` plus the `assets/ui/tech_icons_ui64/` asset commit (`95752d17602514b334aa00d8f43f37dea4cff66d`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass binds the fullscreen read-only Domestic Tech Tree graph to the UI-only `64x64` tech icon set. It is not a research start button, not research turn progression, not research completion, and not actual effect application.
- Icon resolution order is locked as UI64 mapped file first, existing definition `icon_path` second, and the existing `?` fallback last.
- The UI64 map covers all current domestic city and national tech definitions. Prior `?` cases such as pasture/ranch/warhorse, fishing/salt, merchant/trade/silk road, archer/cavalry/naval/defense branches, and national administration/economy/military/diplomacy branches should now display icons when the mapped UI64 file exists.
- Existing definition ids, prerequisite ids, categories, branches, tiers, costs, durations, effect stubs, save keys, completion/unlock state, and gameplay formulas must not be renamed or changed for icon binding.
- `assets/ui/tech_icons_ui64/etc/` is archival and must not be auto-bound unless a future explicit tech definition task authorizes it.
- Texture loading should remain path-cached. Node click selection must stay lightweight from hotfix4: update selected ids, refresh the detail inspector immediately, and update only previous/current compact node styles without rebuilding graphs or reloading all textures.
- Left panel remains PLAYER national tech tree only. Right panel remains selected-city tech tree only. Non-player or insufficient-intel selected-city tech detail remains hidden by Fog of War / `city_intel` policy.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, scenes, assets, icon PNGs, `.import` files, and thumbnail generation.
- Manual F6 QA remains required for UI64 icon visibility, old `?` replacement, icon clarity, detail inspector latency, selected highlight, graph overlap, overlay top-layer behavior, no gameplay mutation, and warning cleanliness.

## v0.70-63-hotfix4 Domestic Tech Tree Click Latency & Icon Readability Polish Handoff
- Baseline: `v0.70-63-hotfix3 Domestic Tech Tree Node Text Restore & Click Responsiveness Fix` (`dfc48edbcd3d69eb77d1d041ca5731f95b0b5785`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass fixes node click latency and icon readability for the fullscreen read-only Domestic Tech Tree graph. It is not a research start button, not research turn progression, not research completion, and not actual effect application.
- Node click selection must stay lightweight: update selected tech id/city id, refresh the detail inspector immediately, and update only previous/current compact node card styles.
- Node click must not call the full overlay/tree graph rebuild path, recreate category graphs, recreate lines/nodes, or reload all icon textures.
- Compact node roots are tracked by selection key for highlight updates. Child icon/text/layout controls should continue to ignore mouse input so the root card remains the whole-card click target.
- Compact icons use fixed integer `64px` UI display sizing and `TextureRect` sizing/filter settings only. Do not create thumbnail icons or modify/reimport `assets/ui/tech_icons` PNG or `.import` files.
- Node title/status and rarity `★` must remain visible after icon sizing changes. Graph spacing must remain global, with no per-category/per-branch/per-tech offset exceptions.
- Left panel remains PLAYER national tech tree only. Right panel remains selected-city tech tree only. Non-player or insufficient-intel selected-city tech detail remains hidden by Fog of War / `city_intel` policy.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, scenes, assets, icon PNGs, `.import` files, and new thumbnail assets.
- Manual F6 QA remains required for immediate inspector update, fast repeated node click response, selected highlight response, icon readability, node title/status visibility, city graph overlap, overlay top-layer behavior, no gameplay mutation, and warning cleanliness.

## v0.70-63-hotfix3 Domestic Tech Tree Node Text Restore & Click Responsiveness Fix Handoff
- Baseline: `v0.70-63-hotfix2 Domestic Tech Tree Global Graph Spacing & Node Size Polish` (`32f92d2559f1dbbcafa84ffe4bad62cb4c2379e4`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is a regression recovery and visual cleanup hotfix for the fullscreen read-only Domestic Tech Tree graph. It is not a research start button, not research turn progression, not research completion, and not actual effect application.
- Compact graph nodes must show icon or `?`, tech name, rarity `★` when present, and short completed/available/locked/special_locked state. Cost/effect/duration/prerequisite/national/special/lock details remain detail-inspector-only.
- The compact node root card is the click target. Child icon/text/layout controls should not intercept node clicks. Node click remains display-only selection and must refresh selected highlight plus detail inspector without mutating gameplay.
- Branch graph layout must reserve vertical space for same-branch/same-tier stacks before placing the next branch. Do not add per-category, per-branch, or per-tech y-offset exceptions.
- Overlay copy is intentionally compact: `EASTWAR 테크트리`, `국가 테크트리`, `도시 테크트리`, selected-city copy, and safe no-city/enemy/insufficient-intel guidance only.
- Icon readability is improved by UI display sizing only. Do not modify, rename, move, delete, add, or reimport `assets/ui/tech_icons` PNG or `.import` files.
- The overlay/modal behavior from v0.70-62-hotfix1 remains locked: high z-index, `move_to_front()`, `Control.MOUSE_FILTER_STOP`, open-time floating panel hide, close-time visible-state restore, background input consume, and ESC/닫기 close.
- Left panel remains PLAYER national tech tree only. Right panel remains selected-city tech tree only. Non-player or insufficient-intel selected-city tech detail remains hidden by Fog of War / `city_intel` policy.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, scenes, assets, icon PNGs, and `.import` files.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Manual F6 QA remains required for node title/status visibility, whole-card click, detail inspector response, city military graph overlap, icon readability, copy cleanup, overlay top-layer behavior, no gameplay mutation, and warning cleanliness.

## v0.70-63-hotfix2 Domestic Tech Tree Global Graph Spacing & Node Size Polish Handoff
- Baseline: `v0.70-63-hotfix1 Compact Tech Node & Detail Inspector Polish` (`6b22491fcec45836271f14f5b837f64b09ca2f06`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is a global graph readability and compact-node presentation hotfix. It is not a research start button, not research turn progression, not research completion, and not actual effect application.
- National and city category sections share one graph spacing rule. Do not add category-specific spacing exceptions for `국가 경제`, `농업`, `어업`, or similar visual cases.
- Compact graph nodes remain fixed-size display-only nodes. Nodes show only icon or `?`, tech name, rarity `★`, and short completed/available/locked/special_locked state.
- Cost, effect copy, duration hint, prerequisite requirements, national tech requirements, special lock conditions, and lock reasons remain in the bottom detail inspector only.
- Branch labels must be UI-localized through `_format_domestic_tech_branch_label_mvp()` only. Data keys, tech ids, prerequisite ids, save keys, and definitions must not be renamed for display polish.
- Icon readability is improved by UI display sizing only. Do not modify, rename, move, or delete `assets/ui/tech_icons` PNG or `.import` files.
- Node clicks remain display-only selection for the detail inspector and selected-node highlight. They must not mutate completion, progress, resources, troops, diplomacy, spy, market, pending invasion, or BattleContext.
- The overlay/modal behavior from v0.70-62-hotfix1 remains locked: high z-index, `move_to_front()`, `Control.MOUSE_FILTER_STOP`, open-time floating panel hide, close-time visible-state restore, background input consume, and ESC/닫기 close.
- Left panel remains PLAYER national tech tree only. Right panel remains selected-city tech tree only. Non-player or insufficient-intel selected-city tech detail remains hidden by Fog of War / `city_intel` policy.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, scenes, assets, icon PNGs, and `.import` files.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Manual F6 QA remains required for category spacing across all national/city categories, node size consistency, icon readability, detail inspector behavior, overlay top-layer behavior, no gameplay mutation, and warning cleanliness.

## v0.70-63-hotfix1 Compact Tech Node & Detail Inspector Polish Handoff
- Baseline: `v0.70-63 Domestic Tech Tree Branch Graph UI MVP` (`ad1d8125a18e673fb6fb7853f817a37689d14e40`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is a graph readability hotfix. It is not a research start button, not research turn progression, not research completion, and not actual effect application.
- Large graph cards are replaced by compact nodes. Nodes show only icon or `?`, tech name, rarity `★`, and a short completed/available/locked/special_locked state.
- Cost, effect copy, duration hint, prerequisite requirements, national tech requirements, special lock conditions, and lock reasons now belong in the bottom detail inspector.
- Node clicks are display-only selection for the detail inspector and selected-node highlight. They must not mutate completion, progress, resources, troops, diplomacy, spy, market, pending invasion, or BattleContext.
- Prerequisite `ColorRect` connection lines remain visible behind compact nodes. Locked nodes and locked paths remain gray/weak; missing icons continue to use `?` fallback.
- The overlay/modal behavior from v0.70-62-hotfix1 remains locked: high z-index, `move_to_front()`, `Control.MOUSE_FILTER_STOP`, open-time floating panel hide, close-time visible-state restore, background input consume, and ESC/닫기 close.
- Left panel remains PLAYER national tech tree only. Right panel remains selected-city tech tree only. Non-player or insufficient-intel selected-city tech detail remains hidden by Fog of War / `city_intel` policy.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, scenes, assets, icon PNGs, and `.import` files.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Manual F6 QA remains required for the v0.70-63-hotfix1 checklist.

## v0.70-63 Domestic Tech Tree Branch Graph UI MVP Handoff
- Baseline: `v0.70-62-hotfix1 Fullscreen Tech Tree Modal Fix` (`9c2e8304e4e874771c7750293fa31b27e558052e`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass upgrades the existing read-only Domestic Tech Tree overlay from card-grid display to branch/tier graph display. It is not a research start button, not research turn progression, not research completion, and not actual effect application.
- The overlay/modal behavior from v0.70-62-hotfix1 remains locked: high z-index, `move_to_front()`, `Control.MOUSE_FILTER_STOP`, open-time floating panel hide, close-time visible-state restore, background input consume, and ESC/닫기 close.
- Left panel remains PLAYER national tech tree only. Right panel remains selected-city tech tree only. Non-player or insufficient-intel selected-city tech detail remains hidden by Fog of War / `city_intel` policy.
- Category sections now create a graph canvas. Nodes are positioned by branch row and tier column; same branch/tier nodes stack vertically.
- Prerequisite relations inside the same category graph draw `ColorRect` line segments behind nodes. Missing prerequisite definitions are skipped safely.
- Line colors are display-only: completed paths bright gold, available paths muted gold, locked/special_locked paths weak gray/brown. They must not mutate tech completion, progress, resources, troops, diplomacy, spy, market, pending invasion, or BattleContext.
- Node content remains the v0.70-62 content: icon or `?` fallback, name, rarity, tier/branch, cost, effect copy, state label, `[잠김]`, and compact lock reasons.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, scenes, assets, icon PNGs, and `.import` files.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Manual F6 QA remains required for the v0.70-63 checklist.

## v0.70-62-hotfix1 Fullscreen Tech Tree Modal Fix Handoff
- Baseline: `v0.70-62 Domestic Tech Tree Fullscreen Read-Only UI MVP` (`3f2cff7ff32370ad947a74f66929f99c75854db9`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is a modal/top-layer hotfix for the existing read-only Domestic Tech Tree UI. It is not graph connection UI, not a research start button, not research turn progression, not research completion, and not actual effect application.
- `tech_tree_overlay_mvp` remains under `WorldMapUI`, but must open as the top-layer modal with high z-index, `move_to_front()`, and `Control.MOUSE_FILTER_STOP`.
- When opening the tech tree, overlapping worldmap floating/detail panels are hidden after recording their current `visible` states. When closing, only those recorded states are restored; do not blindly show all panels.
- Background map/UI input must not pass through while the overlay is open. ESC and `닫기` close the overlay only.
- Left panel remains PLAYER national tech tree only. Right panel remains selected-city tech tree only. Non-player or insufficient-intel selected-city tech detail remains hidden by Fog of War / `city_intel` policy.
- The v0.70-62 read-only node content remains unchanged: icon or `?` fallback, locked gray / `[잠김]`, completed/available/locked/special_locked display-only state, and text-only special lock conditions.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, scenes, assets, icon PNGs, and `.import` files.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Manual F6 QA remains required for the v0.70-62-hotfix1 checklist.

## v0.70-62 Domestic Tech Tree Fullscreen Read-Only UI MVP Handoff
- Baseline: `v0.70-61 Domestic Tech Tree Confirmed Design Foundation MVP` (`208e32662b42bc14cb192af291153c7849c3674b`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass adds a read-only fullscreen Domestic Tech Tree UI MVP. It is not a research start button, not research turn progression, not research completion, not actual income/resource/troop/battle/diplomacy/spy effect application, and not domestic balance implementation.
- Entry is the 월드맵 `테크트리` button. The overlay is `tech_tree_overlay_mvp` under `WorldMapUI` and closes through `닫기` or ESC.
- Left panel is PLAYER national tech tree only, using `left_player_national_panel` / national domestic definitions from v0.70-61. Do not display enemy national/court tech state here.
- Right panel is selected-city tech tree only, using `right_city_detail_panel` / city domestic definitions from v0.70-61. No selected city shows guidance. Non-player or insufficient-intel city tech detail stays hidden behind Fog of War / `city_intel` policy copy.
- Tech nodes display icon path when loadable, otherwise `?` fallback through `_get_domestic_tech_icon_fallback_label_mvp()`. Missing icons are valid data and must not remove nodes.
- Completed / available / locked / special_locked are UI view states only. Locked nodes use gray styling plus `[잠김]`; special lock conditions are displayed as text only.
- `city_domestic_tech_completed`, `city_domestic_tech_unlocked`, `national_domestic_tech_completed`, and `national_domestic_tech_unlocked` normalization remains v0.70-61 behavior. UI helpers must not write completion/progress/effect state.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, left PLAYER scope, right selected-city scope, scenes, assets, icon PNGs, and `.import` files.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Manual F6 QA remains required for the v0.70-62 checklist.

## v0.70-61 Domestic Tech Tree Confirmed Design Foundation MVP Handoff
- Baseline: `테크트리 준비` (`78ab5e479511855f1f445c64eb57186bc93eb3b3`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is Domestic Tech Tree Foundation only. It is not tech tree UI, not a research button, not research turn progression, not actual income/resource/troop/battle/diplomacy/spy effect application, and not domestic balance implementation.
- City techs are intended for the future right selected-city detail panel. National techs are intended for the future left PLAYER national/court panel. Do not expose enemy city tech detail outside Fog of War and `city_intel` policy.
- Foundation data includes tech definition, category, branch, rarity, prerequisite, national unlock/enhance relation, special lock metadata, governor aptitude, chancellor-directed national progress mode, cost, duration hints, disabled `effect_stub`, icon path, and fallback label data.
- Domestic tech state keys are normalized only for crash safety: `city_domestic_tech_completed`, `city_domestic_tech_unlocked`, `national_domestic_tech_completed`, and `national_domestic_tech_unlocked`. Unknown tech ids and malformed payloads are discarded by helpers.
- `effect_stub.enabled` must remain false until an explicitly authorized effect implementation pass. Save/load normalization must not replay effects.
- Icon mapping rules: use only existing semantic matches; missing icons get empty `icon_path`, `icon_missing = true`, and `icon_fallback_label = "?"`. Do not modify, rename, or delete `assets/ui/tech_icons` PNG or `.import` files.
- Known icon mismatch: `agri_granary_zone` maps to existing `tech_agri_granary_zon.png`; `mil_heavy_infantry` remains missing because the existing heavy cavalry icon is different; `tech_naval_grand_shipyard.png` remains unused because no confirmed 대형조선소 tech is added in this MVP.
- Explicitly unchanged: income/resource/troop/battle/diplomacy/spy formulas, enemy pressure plan, pending invasion, BattleContext, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, left PLAYER scope, right selected-city scope, scenes, assets, icon PNGs, and `.import` files.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Manual F6 QA remains required for the v0.70-61 checklist.

## v0.70-60 Enemy Pressure Balance Pass Handoff
- Baseline: `v0.70-59 Enemy Strategy Hint UX Polish` (`749179080e67a4d61dfa143761e4f5ed0e527404`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is pressure plan balance polish only. It is not a new enemy AI pass, not War Posture, not Strategy Memory, not Invasion Intent Preview, not Player Counter-Strategy, and not authorization for pathfinding, economy simulation, spy damage, or alliance/trade simulation.
- Pressure plan remains display/history plus scoring hint only. It still forces `effect = display_scoring_only` and does not apply direct effects.
- Balance rules:
  - Pressure plan bonuses must stay tie-breaker sized and must not overpower low-troop recovery, frontline priority, personality/goal scoring, invasion eligibility, or existing strategic action max-one behavior.
  - Scoring bonus use must ignore malformed, stale-turn, PLAYER, invalid source city, and invalid target city pressure plan payloads.
  - Pressure plan invasion bonus must not make a zero or negative base pair score viable.
- Hint display remains locked from v0.70-59: compact `적 전략: 세력 · 목표`, no repeated `전략:` / `목표:` noise, no raw IDs, no internal effect strings, and no score/bonus values in UI text.
- Explicitly unchanged: reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, strategic action max-one clamp, pending invasion payload shape, BattleContext shape, battle result apply, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, left PLAYER scope, right selected-city scope, scenes, assets, `.uid`, `.ogv`, and `assets/ui/tech_icons` PNG files.
- Save/load must not duplicate hint lines or replay pressure plan effects/scoring. v0.70-58 turn-number mismatch scoring lock remains active.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Verification passed: `git diff --check`, tech icon no-touch check, guard keyword search, warning-cleanup regression searches, internal id exposure risk search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual F6 QA still required for the v0.70-60 checklist.

## v0.70-59 Enemy Strategy Hint UX Polish Handoff
- Baseline: `v0.70-58 Enemy Pressure Plan QA Replay Pending SaveLoad Lock` (`ac3939e034c459457ea2f1dead8f4538d5b20d1a`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is enemy strategy hint UX polish only. It is not a new enemy AI pass, not War Posture, not Strategy Memory, not Invasion Intent Preview, not Player Counter-Strategy, and not authorization for pathfinding, economy simulation, spy damage, or alliance/trade simulation.
- Pressure plan remains display/history plus scoring hint only. It still forces `effect = display_scoring_only` and does not apply direct effects.
- Hint display rules:
  - Pressure plan displays compactly as `적 전략: 세력 · 목표` or short `전략: 목표`.
  - Default, empty, malformed, raw-id, PLAYER, or stale-turn pressure plan payloads should not be shown as current hints.
  - Hidden enemy data, raw IDs, internal effect strings, scores, and scoring bonuses must not appear in UI text.
  - Pending invasion hint keeps source → target as `침공 대기: 공격 도시 → 방어 도시`.
  - Strategic action hint uses abstract copy such as `적 전략 행동: 외교 압박` or `적 전략 행동: 첩보 압박`.
- Explicitly unchanged: pressure plan scoring, reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, strategic action max-one clamp, pending invasion payload shape, BattleContext shape, battle result apply, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, left PLAYER scope, right selected-city scope, scenes, assets, `.uid`, `.ogv`, and `assets/ui/tech_icons` PNG files.
- Save/load must not duplicate hint lines or replay pressure plan effects/scoring. v0.70-58 turn-number mismatch scoring lock remains active.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Verification passed: `git diff --check`, tech icon no-touch check, guard keyword search, warning-cleanup regression searches, internal id exposure risk search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual F6 QA still required for the v0.70-59 checklist.

## v0.70-58 Enemy Pressure Plan QA Replay Pending SaveLoad Lock Handoff
- Baseline: `내정테크아이콘` (`70a1e93cc8996f2109a2354c8a206ffe4479ec74`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is a pressure plan QA/fix pass over v0.70-57. It is not a new enemy AI pass, not Enemy Strategic AI Phase 2, not a full planner, and not authorization for pathfinding, economy simulation, spy damage, or alliance/trade simulation.
- Pressure plan remains display/history plus scoring hint only. Valid plans use `type = enemy_pressure_plan` and forced `effect = display_scoring_only`; direct effects remain forbidden.
- New pressure plan creation remains max one per world turn and skips during pending invasion, pending BattleContext, enemy turn replay guard, invalid turn, and no-candidate cases.
- Save/load and malformed payload safety:
  - Missing `turn_number` no longer normalizes to the current turn.
  - Pressure plan scoring only uses a normalized plan when its `turn_number` exactly matches the current world turn.
  - Saved pressure plan state remains display/history only and must not replay effects.
- Summary/hint display remains compact. Detailed hint copy now uses `적 전략: 세력 · 목표` instead of repeating the `전략:` label.
- Explicitly unchanged: reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, strategic action max-one clamp, pending invasion payload shape, BattleContext shape, battle result apply, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, left PLAYER scope, right selected-city scope, scenes, assets, `.uid`, `.ogv`, and `assets/ui/tech_icons` PNG files.
- Keep warning cleanup intact: do not reintroduce exact local `seed` variables, `target_label` block shadowing, local `resource_label`, local `selected_city_id`, `sign` parameter, or local `loyalty_card` shadowing.
- Verification passed: `git diff --check`, tech icon no-touch check, guard keyword search, warning-cleanup regression searches, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual F6 QA still required for the v0.70-58 checklist.

## v0.70-57 Enemy Strategic AI Phase 1 Target Pressure Planner Handoff
- Baseline: `v0.70-56-hotfix1 GDScript Reload Shadowing Warning Fix` (`602a199ebc19fd36d51a824b1a6941d4ce60197c`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is Enemy Strategic AI Phase 1 pressure plan MVP only. It is not full enemy AI, not a multi-turn planner, and not authorization for pathfinding, economy simulation, spy damage, or alliance/trade simulation.
- Pressure plan state:
  - `_player_state["last_enemy_pressure_plan_result"]` mirrors the current display/history plan.
  - `last_enemy_faction_turn_result.pressure_plan` stores at most one normalized plan.
  - Valid plans use `type = enemy_pressure_plan` and `effect = display_scoring_only`.
- Pressure plan creation skips during pending invasion, pending BattleContext, same-turn replay, invalid turn, and no-candidate cases.
- Pressure plan candidates use non-player faction-owned source cities, goal target/frontline adjacency, normalized goal/personality pressure type, and conservative scoring.
- Pressure plan influence is limited to small optional scoring tie-breakers for reinforcement target choice, diplomacy/spy strategic action selection, and already eligible invasion pair scoring.
- Summary/hint may show compact `전략: ...` text; default/empty/malformed plans are hidden or discarded and hidden enemy resources, chancellors, raw city intel, or national state are not exposed.
- Explicitly unchanged: reinforcement constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, strategic action max-one clamp, pending invasion payload shape, BattleContext shape, battle result apply, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, left PLAYER scope, right selected-city scope, scenes, assets, `.uid`, and `.ogv`.
- Keep v0.70-56-hotfix1 warning cleanup intact: do not reintroduce exact local `seed` variables or `target_label` block shadowing.
- Verification passed: `git diff --check`, guard keyword search, warning-cleanup regression searches, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual F6 QA still required for the v0.70-57 checklist.

## v0.70-56-hotfix1 GDScript Reload Shadowing Warning Fix Handoff
- Baseline: `v0.70-56 Enemy Turn Manual F6 QA Fix Pass` (`e06c1744087167957eebc1e070bb6567646b6972`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This hotfix is a gameplay-free GDScript reload warning cleanup only.
- Removed the `seed` built-in function name collision warning by renaming local personality/goal seed temporaries to `personality_seed` and `goal_seed`.
- Removed the `target_label` block shadowing warning in `_format_last_diplomacy_action_result_for_ui()` by using one `diplomacy_target_label` local.
- Explicitly unchanged: enemy turn flow, personality seed values, strategic goal seed values, reinforcement balance, invasion chance/min attacker guard, pending invasion payload, BattleContext shape, battle result apply, market, alliance, wedge, player spy/diplomacy actions, `city_intel`, Fog of War, left PLAYER scope, right selected-city scope, scenes, assets, `.uid`, and `.ogv`.
- Verification passed: `git diff --check`, warning keyword searches for `seed` and `target_label`, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual F6 QA still required to confirm the editor Output no longer prints the two reload warnings.

## v0.70-56 Enemy Turn Manual F6 QA Fix Pass Handoff
- Baseline: `v0.70-55 Enemy Goal QA Strategy Hint Polish` (`e96bbd4a028ea8c743f5665e6fec5a6ee9f86fe0`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is an enemy turn manual F6 QA/fix pass. It is not a new feature pass and does not implement `Enemy Strategic AI Phase 1`.
- QA scope covered reinforcement, strategic action, personality/goal scoring/display, invasion roll, pending invasion, defense deployment, BattleContext handoff, battle result apply, save/load replay guard, and compact summary/hint display.
- Small runtime fix:
  - `_on_ally_turn_end_pressed()` now blocks turn end if `_player_state["pending_battle_context"]` is active.
  - `_roll_enemy_invasion_event_mvp()` now skips if pending battle context exists, matching the existing pending invasion skip.
- Explicitly unchanged: reinforcement amount constants, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext shape, defense source/target semantics, command/deployable clamp, player attack path, battle result ownership rules, left PLAYER panel scope, right selected-city scope, Fog of War, `city_intel`, market, alliance, wedge, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scenes, assets, `.uid`, and `.ogv`.
- Enemy spy pressure remains display/history only and must not mutate player city stats, resources, troops, publicSupport, loyalty, or `city_intel`.
- Enemy diplomacy remains non-player-pair-only score drift and must not directly change PLAYER relations, alliance state, trade agreements, cooldowns, resources, chancellor state, or national stock.
- Enemy full AI, enemy spy actual damage, enemy diplomacy alliance/trade simulation, enemy economy simulation, pathfinding, and multi-turn war planning remain forbidden.
- Verification passed: `git diff --check`, required guard keyword search, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Battle scene emitted existing debug output only.
- Manual F6 QA still required for the v0.70-56 checklist.

## v0.70-55 Enemy Goal QA & Strategy Hint Polish Handoff
- Baseline: local `v0.70-54 Enemy Strategic Goal Seed MVP` (`617883d0fc71db1cdf9668e5c1148a98a5a04766`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is QA and strategy hint polish over v0.70-54. It is not a new enemy AI pass, not a planner, and not authorization for pathfinding, economy simulation, spy damage, or alliance/trade simulation.
- Strategic goal remains target/pressure/weight seed metadata with conservative scoring bonuses only. PLAYER and unknown/malformed factions must still fall back safely.
- QA confirmed the current non-player goal seed coverage matches the active faction ids and current target city ids exist in the worldmap metadata.
- Runtime polish:
  - Default/empty goals no longer produce visible goal hint noise.
  - Strategic action and detailed enemy hint copy use compact `목표: ...` display text.
  - Reinforcement one-line summary avoids repeated goal labels across multiple faction action lines.
- Goal influence remains limited to reinforcement target scoring, strategic action type/target scoring, and already eligible invasion pair scoring.
- Enemy spy pressure remains display/history only and does not mutate player city stats, resources, troops, publicSupport, loyalty, or `city_intel`.
- Enemy diplomacy remains non-player-pair-only score drift and does not directly change PLAYER relations, alliance state, trade agreements, cooldowns, resources, chancellor state, or national stock.
- Explicitly unchanged: `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, `_player_state["last_enemy_strategic_action_result"]`, `strategic_actions` max-one semantics, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext handoff, reinforcement amount constants, defense deployment, battle result apply, player attack path, left PLAYER panel scope, right selected-city scope, Fog of War, `city_intel`, market, alliance, wedge, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scenes, assets, `.uid`, and `.ogv`.
- Verification passed: `git diff --check`, required guard keyword search, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Battle scene emitted existing debug output only.
- Manual F6 QA still required for the v0.70-55 checklist.

## v0.70-54 Enemy Strategic Goal Seed MVP Handoff
- Baseline: `v0.70-53 Enemy Personality QA Balance Tuning Pass` (`1952388b5ac31a1fede63e9febc87f5bc9a559e9`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass adds conservative faction strategic goal seeds. It is not full enemy AI, not a war planner, and not authorization for pathfinding, economy, spy damage, or alliance/trade simulation.
- `ENEMY_FACTION_STRATEGIC_GOAL_SEEDS` defines goal id, compact label, existing target city ids, region hints, pressure, and bounded weight. Unknown factions and PLAYER fall back to default/empty behavior; PLAYER does not receive goal scoring.
- Goal influence is limited to:
  - small reinforcement target scoring bonuses for preferred/adjacent target cities and pressure-aligned low-troop/frontline cases,
  - small diplomacy or spy-pressure strategic follow-up scoring bonuses,
  - small eligible invasion pair scoring bonuses after v0.70-49 guards pass,
  - compact `목표:` display metadata in enemy turn summary/hint.
- Enemy spy pressure remains display/history only and does not mutate player city stats, resources, troops, publicSupport, loyalty, or `city_intel`.
- Enemy diplomacy remains non-player-pair-only score drift and does not directly change PLAYER relations, alliance state, trade agreements, cooldowns, resources, chancellor state, or national stock.
- Explicitly unchanged: `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, `_player_state["last_enemy_strategic_action_result"]`, `strategic_actions` max-one semantics, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext handoff, reinforcement amount constants, defense deployment, battle result apply, player attack path, left PLAYER panel scope, right selected-city scope, Fog of War, `city_intel`, market, alliance, wedge, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scenes, assets, `.uid`, and `.ogv`.
- Verification passed: `git diff --check`, required guard keyword search, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Battle scene emitted existing debug output only.
- Manual F6 QA still required for the v0.70-54 checklist.

## v0.70-53 Enemy Personality QA & Balance Tuning Pass Handoff
- Baseline: `v0.70-52 Enemy Faction Personality Seed MVP` (`4ee00833ac7ea4f953ec6e006362ff51b361551f`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is a QA/tuning pass for v0.70-52 personality seeds. It is not full enemy AI.
- Personality remains bounded and limited to reinforcement target scoring, strategic action type selection, eligible invasion pair scoring, and compact display metadata.
- Seed coverage now includes an explicit `chu` default-balanced entry in addition to the v0.70-52 requested non-player factions.
- `kyushu_faction` now uses a compact `계략` / `schemer_pressure` profile to make the spy-pressure lane visible without adding real spy damage or new systems.
- Spy-pressure candidate scoring was reduced slightly so default spy candidates do not overpower diplomacy candidates through troop/frontline bonuses.
- Invasion personality weighting now only multiplies positive eligible-pair scores, preventing sub-1.0 defensive/diplomatic weights from making negative invasion pair scores less bad.
- Explicitly unchanged: `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, `_player_state["last_enemy_strategic_action_result"]`, `strategic_actions` max-one semantics, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext handoff, reinforcement amount constants, defense deployment, battle result apply, player attack path, left PLAYER panel scope, right selected-city scope, Fog of War, `city_intel`, market, alliance, wedge, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scenes, assets, `.uid`, and `.ogv`.
- Verification passed: `git diff --check`, required guard keyword search, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Battle scene emitted existing debug output only.
- Manual F6 QA still required for the v0.70-53 checklist.

## v0.70-52 Enemy Faction Personality Seed MVP Handoff
- Baseline: `v0.70-51 Enemy Turn QA Pass Manual F6 Feedback Polish` (`682c1002bab46474d72c5ff2ca2d3c4ced977222`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass adds conservative faction personality seeds. It is not full enemy AI.
- `ENEMY_FACTION_PERSONALITY_SEEDS` defines bounded non-player profiles with compact labels and weights. Unknown factions fall back to `default_balanced`; PLAYER is excluded.
- Personality influence is limited to:
  - reinforcement target scoring among already safe enemy-owned cities,
  - diplomacy vs spy-pressure strategic action candidate scoring,
  - eligible invasion pair scoring after v0.70-49 guards pass,
  - compact display metadata in enemy turn summary/hint.
- Reinforcement amount constants and chancellor/frontline bonus formulas are unchanged.
- Strategic follow-up remains capped to at most one action per world turn and still skips while pending invasion or pending battle context exists.
- Enemy spy pressure remains display/history only and does not mutate player city stats, resources, troops, publicSupport, loyalty, or `city_intel`.
- Enemy diplomacy remains non-player-pair-only score drift and does not directly change PLAYER relations, alliance state, trade agreements, cooldowns, resources, chancellor state, or national stock.
- Invasion chance and readiness are unchanged: `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, and BattleContext handoff remain stable.
- Explicitly unchanged: `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]`, `_player_state["last_enemy_strategic_action_result"]`, `strategic_actions` max-one semantics, defense deployment, battle result apply, player attack path, left PLAYER panel scope, right selected-city scope, Fog of War, `city_intel`, market, alliance, wedge, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scenes, assets, `.uid`, and `.ogv`.
- Verification passed: `git diff --check`, required guard keyword search, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Battle scene emitted existing debug output only.
- Manual F6 QA still required for the v0.70-52 checklist.

## v0.70-51 Enemy Turn QA Pass Handoff
- Baseline: `v0.70-50 Enemy Faction Diplomacy Spy Behavior Follow-up` (`7fa73bfe31efd76bebefc595768fc55a8d98e3b5`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is an enemy turn chain QA pass, not a new feature pass and not full enemy AI.
- QA scope covered reinforcement, strategic action, invasion roll, pending invasion, defense deployment, BattleContext handoff, battle result apply, and save/load replay guard.
- `_player_state["last_enemy_faction_turn_processed_turn"]` remains the same-turn guard. Same-turn re-entry returns normalized display/history payload only.
- `_player_state["last_enemy_faction_turn_result"]` is now normalized for display/history on runtime defaults and same-turn restore.
- `strategic_actions` is clamped to at most one valid supported action. Unknown or malformed strategic payloads are discarded.
- `_player_state["last_enemy_strategic_action_result"]` is derived from the normalized `strategic_actions` array and remains display/history only.
- Enemy diplomacy display normalization rejects PLAYER-involved pairs. Enemy spy pressure normalization forces `effect = "display_only"`.
- Explicitly unchanged: reinforcement balance, `ENEMY_INVASION_CHANCE`, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext key/shape, defense source/target semantics, command/deployable clamp, invasion result ownership handling, player attack result path, left PLAYER panel scope, right selected-city scope, Fog of War, `city_intel`, market, alliance, wedge, player spy/diplomacy actions, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scenes, assets, `.uid`, and `.ogv`.
- Verification passed: `git diff --check`, required guard keyword search, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Battle scene emitted existing debug output only.
- Manual F6 QA still required for the v0.70-51 checklist.

## v0.70-50 Enemy Faction Diplomacy/Spy Behavior Follow-up Handoff
- Baseline: `v0.70-49 Enemy Invasion Defense Balance Polish` (`1d00fb4402033a88c0c7aeb87f94b48cb3120800`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is a conservative enemy faction diplomacy/spy follow-up, not full enemy AI.
- Enemy faction turn result now has `strategic_actions` for at most one follow-up action per world turn. The existing `actions` array remains reinforcement-focused.
- Replay semantics are unchanged: `_player_state["last_enemy_faction_turn_processed_turn"]` remains the same-turn guard and `_player_state["last_enemy_faction_turn_result"]` remains display/history state. Save/load may restore result payloads but must not replay strategic effects.
- `_player_state["last_enemy_strategic_action_result"]` is display/history state only.
- Strategic follow-up is skipped when `_player_state["pending_invasion_event"]` or `_player_state["pending_battle_context"]` exists.
- Enemy diplomacy follow-up:
  - Eligible pairs are non-player factions only.
  - Uses existing faction relation score helpers.
  - Applies only a conservative score drift of `±3`.
  - Does not directly change PLAYER relations, relation status, alliance turns, trade agreements, cooldowns, resources, chancellor state, or national stock.
- Enemy spy pressure follow-up:
  - Eligible targets are player-owned cities adjacent to safe enemy-owned cities.
  - Result is display/history only.
  - It must not mutate player city publicSupport, loyalty, troops, resources, `city_intel`, spy cooldowns, detection penalties, or relation state.
- Enemy turn summary/hint may include one compact strategic line (`적 외교` or `적 첩보`) while preserving v0.70-47 compact `이번 턴 적 행동` / `침공 대기` / `외 N건` style.
- Explicitly unchanged: v0.70-49 invasion eligibility guards, `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS`, `ENEMY_INVASION_CHANCE`, `enemy_invasion_roll_turn`, pending invasion payload shape, BattleContext key/shape, player attack/defense deployment, battle result apply, left PLAYER panel scope, right selected-city scope, enemy Fog of War, `city_intel`, market prices, alliance behavior, wedge behavior, player chancellor candidate scope, `_player_state["faction_chancellors"]`, scenes, assets, `.uid`, and `.ogv`.
- Verification passed: `git diff --check`, required guard keyword search, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Battle scene emitted existing debug output only.
- Manual F6 QA still required for the v0.70-50 checklist.

## v0.70-49 Enemy Invasion/Defense Balance Polish Handoff
- Baseline: `v0.70-47 WorldMap Strategic UX Final Polish` (`669da7976600db60b8a6283b1c9fb3f4d9078f70`). `v0.70-48 Enemy Faction Diplomacy/Spy Behavior Follow-up` was intentionally deferred.
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is invasion/defense balance guard and QA polish, not a full enemy AI or enemy diplomacy/spy/economy system.
- Enemy invasion roll chance remains `ENEMY_INVASION_CHANCE = 0.45`; same-turn roll guard `enemy_invasion_roll_turn` and enemy faction replay guard remain intact.
- New invasion-start threshold: `ENEMY_INVASION_MIN_ATTACKER_CITY_TROOPS = 160`. This is separate from `INVASION_MIN_CITY_TROOPS`, `INVASION_MIN_OCCUPATION_TROOPS`, and `INVASION_MAX_REASONABLE_CITY_TROOPS`, which still govern result/occupation/clamp behavior.
- Candidate generation now routes through `_is_enemy_invasion_pair_eligible_mvp()` and `_score_enemy_invasion_pair_mvp()`.
  - Eligibility excludes missing city data, marker/HUD owner mismatch, non-enemy attackers, non-player defenders, non-adjacent pairs, and attacker cities below the invasion-start threshold.
  - Scoring only sorts already eligible pairs; it does not simulate strategy, diplomacy, economy, or multi-turn planning.
- Pending invasion event payload shape is unchanged: `type`, `attacker_city_id`, `defender_city_id`, `source`, and `turn_number` are still the event keys.
- Defense deployment remains `source_city_id = defender city` and `target_city_id = attacker city`. Existing selected defender hero validation, captured/dead exclusion through availability helpers, command limit, and deployable troop clamp remain authoritative.
- Enemy invasion result application now treats missing attacker/source city data as unknown and avoids ownership mutation; pending invasion/runtime battle state is still cleared through the existing cleanup path.
- Explicitly unchanged: BattleContext key/shape, Battle scene combat logic, player attack system shape, hero death/capture system scope, left PLAYER panel scope, right selected-city scope, Fog of War, `city_intel`, market pricing, alliance proposal, wedge, `_player_state["faction_chancellors"]`, scenes, assets, `.uid`, and `.ogv`.
- Verification passed: `git diff --check`, required guard keyword search, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Scene loads emitted existing debug output only.
- Manual F6 QA still required for the v0.70-49 checklist: invasion eligibility/frequency, no duplicate pending event, weak attacker exclusion, adjacent player targets, defense source/target UI, command/deployable clamp, BattleContext handoff, defender/attacker win handling, retreat/unknown safety, save/load replay guards, v0.70-47 scope locks, and warning cleanliness.
- Next candidate:
  1. `v0.70-48 Enemy Faction Diplomacy/Spy Behavior Follow-up`

## v0.70-47 WorldMap Strategic UX Final Polish Handoff
- Baseline: `v0.70-46 Enemy Faction Turn Behavior QA Balance Polish` (`97046321ae51f7ea0fd6a726e7b6dc42f4742ab8`).
- Runtime files touched: `scripts/worldmap_test.gd` and `scripts/worldmap_city_info_panel.gd`.
- This pass is final strategic UX copy polish, not a new system.
- Left World Status remains PLAYER/nation/court scope. Foreign city selection must not switch the left panel into a foreign national panel or clear player chancellor state.
- Right Selected City remains selected-city scope. Player-owned cities keep the full-information path; enemy/foreign cities keep Fog of War and reveal only payload-backed `city_intel` fields.
- Unified City Detail copy was tightened for resources, city storage, internal trade, external trade, manual trade orders, diplomacy action status/tooltips, spy visibility, known intel, and spy action status/tooltips.
- Enemy turn and pending invasion summaries use compact wording (`이번 턴 적 행동`, `침공 대기`, `외 N건`) without changing replay guards, reinforcement behavior, invasion chance, pending event shape, or BattleContext handoff.
- Explicitly unchanged: `_player_state["last_enemy_faction_turn_processed_turn"]`, `_player_state["last_enemy_faction_turn_result"]` semantics, `ENEMY_INVASION_CHANCE`, `pending_invasion_event` shape, `WORLDMAP_BATTLE_CONTEXT_META_KEY`, `city_intel`, `SPY_ACTION_WEDGE`, `DIPLOMACY_ACTION_ALLIANCE_PROPOSAL`, `MANUAL_TRADE_PREVIEW_PRICES`, `_get_trade_market_price()`, `_player_state["faction_chancellors"]`, formulas, costs, chances, cooldowns, validation gates, scenes, assets, `.uid`, and `.ogv`.
- Preserve warning-cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` shadowing.
- Verification is recorded in the completion report for this session.
- Next candidates:
  1. `v0.70-48 Enemy Faction Diplomacy/Spy Behavior Follow-up`
  2. `v0.70-49 Enemy Invasion/Defense Balance Polish`

## v0.70-46 Enemy Faction Turn Behavior QA & Balance Polish Handoff
- Baseline: `v0.70-45 Enemy Faction Turn Behavior MVP` (`964d8db3d61a2154e268ba1f905691f9ac493262`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- This pass is QA/balance polish over v0.70-45 enemy faction turn behavior, not a full enemy AI expansion.
- Reinforcement numbers are now `+60` base, `+40` frontline, `+20` valid enemy faction chancellor seed, max `+120`.
- Balance reason: keep the visible enemy-turn movement from v0.70-45 while reducing per-turn accumulation pressure when several non-player factions reinforce every world turn.
- Replay guard remains `_player_state["last_enemy_faction_turn_processed_turn"]`. Same-turn re-entry now skips both reinforcement and same-turn enemy invasion roll for an already processed `turn_number`.
- `_player_state["last_enemy_faction_turn_result"]` remains display/history state only and is safe to restore from save/load without replaying effects.
- City ownership guard now skips enemy turn target selection if both city marker owner and HUD/runtime owner exist but disagree.
- Summary/hint output remains compact and may show `외 N건` when action lines are omitted.
- Pending invasion continuity preserved: `ENEMY_INVASION_CHANCE`, pending event shape, and BattleContext handoff were not changed.
- Verification passed: `git diff --check`, required enemy-turn/search verification, warning-cleanup regression search, project headless load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load. Battle scene emitted existing debug logs only.
- Explicitly unchanged: market formulas, manual/chancellor trade pricing, alliance proposal/duration/cooldown, wedge/alienation, enemy intel Fog of War display rules, spy success/detection formulas, diplomacy costs/effects, player chancellor candidate scope, `_player_state["faction_chancellors"]` structure, left/right panel scope, BattleContext, scenes, assets, `.uid`, and `.ogv`.
- Manual F6 QA still required for enemy phase progression, compact result log, once-per-turn reinforcement, `+120` clamp, frontline priority, no player direct mutation, replay guards, pending invasion continuity/no duplication, Fog of War, wedge, alliance, market pricing, Hanseong chancellor scope, foreign-city left panel scope, and warning cleanliness.
- Next candidates:
  1. `v0.70-47 WorldMap Strategic UX Final Polish`
  2. `v0.70-48 Enemy Faction Diplomacy/Spy Behavior Follow-up`
  3. `v0.70-49 Enemy Invasion/Defense Balance Polish`

## v0.70-45 Enemy Faction Turn Behavior MVP Handoff
- Baseline: `v0.70-44 WorldMap Domestic/Turn Flow QA & Polish` (`cc977ad461a971819ba5be2a4d2a6d414aabe7a8`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- Enemy phase now calls `_process_enemy_faction_turn_mvp()` before the existing `_roll_enemy_invasion_event_mvp()` path.
- New state keys:
  1. `_player_state["last_enemy_faction_turn_result"]`: display/history payload for the latest enemy faction turn.
  2. `_player_state["last_enemy_faction_turn_processed_turn"]`: authoritative same-turn guard for enemy faction actions.
- Enemy faction selection excludes PLAYER, empty/unknown factions, and factions without owned cities.
- Each enemy faction can perform at most one action. City selection prefers a faction-owned city adjacent to a player-owned city, otherwise the faction-owned city with the lowest troops.
- Reinforcement is intentionally conservative: `+80` base, `+40` frontline, `+20` valid enemy faction chancellor seed bonus, max `+150`.
- `_player_state["faction_chancellors"]` structure is unchanged and is used only for the small reinforcement bonus plus result metadata.
- Existing pending invasion behavior is preserved: `ENEMY_INVASION_CHANCE`, pending event payload, and BattleContext handoff were not changed. The enemy turn result only records whether the existing roll created a pending invasion event.
- Save/load persists the result payload and processed-turn guard through `_player_state`; load restores display/history only and does not replay reinforcement or rerun the same-turn enemy invasion roll.
- Left World Status remains player/nation scoped. Enemy turn text is limited to action summaries and invasion hint, not hidden enemy resources or national panel data.
- Explicitly unchanged: market formulas, manual/chancellor trade pricing, alliance proposal/duration/cooldown, wedge/alienation, enemy intel Fog of War display rules, spy success/detection formulas, diplomacy costs/effects, player chancellor candidate scope, left/right panel scope, BattleContext, scenes, assets, `.uid`, and `.ogv`.
- Manual F6 QA still required for enemy phase progression, enemy result log, conservative enemy troop increase, no player direct mutation, same-turn replay guard, pending invasion continuity/no duplication, save/load replay guard, Fog of War, wedge, alliance, market pricing, Hanseong chancellor scope, foreign-city left panel scope, and warning cleanliness.
- Next candidates:
  1. `v0.70-46 WorldMap Strategic UX Final Polish`
  2. `v0.70-47 Enemy Faction Diplomacy/Spy Behavior Follow-up`
  3. `v0.70-48 Enemy Invasion/Defense Balance Polish`

## v0.70-44 WorldMap Domestic/Turn Flow QA & Polish Handoff
- Baseline: `v0.70-43 WorldMap Diplomacy Spy Intel Final QA Pass` (`aa7ba353a7eaec2bf38868b2110922d179ba1995`).
- Runtime files touched: none.
- Code change 없음 / domestic-turn flow QA + docs update.
- Audited player turn end, enemy phase placeholder/delay, turn_number/calendar/phase labels, pending invasion event flow, domestic apply guard, trade market state, chancellor auto trade guard, diplomacy cooldowns, trade agreement duration, alliance duration, spy cooldown, revolt instigation duration, city intel display-only state, left national panel scope, and player chancellor candidate scope.
- Domestic apply audit confirmed `_player_state["domestic_apply_pending"]` is cleared after enemy-turn finish and `_player_state["last_domestic_apply_turn"]` blocks same-turn reapplication.
- Save/load audit confirmed pending enemy/invasion runtime state is cleared, player phase is restored, `domestic_apply_pending` is cleared, and result/history payloads are restored as state/display only.
- Market audit confirmed `_ensure_trade_market_for_current_turn()` keeps same-turn prices stable and only generates a new market for a new `turn_number` or missing state.
- Chancellor auto trade audit confirmed `_player_state["last_chancellor_auto_trade_turn"]` blocks same-turn automatic trade replay and saved result payloads do not reapply storage/resource deltas.
- Diplomacy/alliance audit confirmed cooldowns, trade agreements, and alliances decrement in `_advance_diplomacy_cooldowns_for_world_turn()` and keep trade agreement and alliance duration fields separate.
- Spy audit confirmed spy cooldown and `revolt_instigation` tick once per world turn, while `last_spy_wedge_result` is display/history only.
- City intel audit confirmed `_player_state["city_intel"]` is normalized for display restore only and failed spy results do not open intel.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Manual F6 QA still required for turn label progression, same-turn domestic/market/auto-trade replay guards, cooldown/duration ticks, save/load display-only restore, pending invasion continuity, left panel player scope, Hanseong chancellor candidate scope, and Godot Output warning cleanliness.
- Next candidates:
  1. `v0.70-45 Enemy Faction Turn Behavior MVP`
  2. `v0.70-46 WorldMap Strategic UX Final Polish`
  3. `v0.70-47 Enemy Faction Diplomacy/Spy Behavior Follow-up`

## v0.70-43 WorldMap Diplomacy/Spy/Intel Final QA Pass Handoff
- Baseline: `v0.70-42 Enemy Intel UI Polish / Fog of War` (`7e0d27b887c7cd5989efc2a18038665c7e99854b`).
- Runtime files touched: none.
- Code change 없음: QA audit and docs update only.
- Audited market pricing, alliance proposal/duration, wedge/alienation, city intel Fog of War, chancellor candidate scope, faction chancellor seed state, and left/right panel scope.
- Market audit confirmed external trade pricing still uses turn-scoped market prices through `_get_trade_market_price()` and shared import/export helpers.
- Alliance audit confirmed `alliance_proposal` validation-first behavior, relation-entry `alliance_turns_remaining`, mirror state, expiry-to-neutral, and trade-agreement separation.
- Wedge audit confirmed selected-foreign-city scope, non-player counterpart selection, validation failure no-op behavior, rolled attempt cost/cooldown, target-counterpart relation mutation, and PLAYER-target detection penalty.
- Intel audit confirmed `_player_state["city_intel"]` remains display-only, failed `정탐` does not open intel, and right panel / spy tab use payload-backed revealed/locked field display.
- Chancellor audit confirmed candidate heroes remain sourced from the player candidate city roster, `_player_state["faction_chancellors"]` remains seed state, and selected foreign cities do not clear national chancellor assignment.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-44 WorldMap Domestic/Turn Flow QA & Polish`
  2. `v0.70-45 Enemy Faction Turn Behavior MVP`
  3. `v0.70-46 WorldMap Strategic UX Final Polish`

## v0.70-42 Enemy Intel UI Polish / Fog of War Handoff
- Baseline: `v0.70-41 Spy Action Polish / Alienation MVP` (`aae97d12676cea97c065a67f6366a9593e9e26ef`).
- Runtime files touched: `scripts/worldmap_test.gd` and `scripts/worldmap_city_info_panel.gd`.
- Enemy selected-city display now formats a clear Fog of War summary: `정보 수준`, `공개 정보`, and `잠김 정보`.
- Intel level labels are `미확인`, `기초 정탐`, `군사 정탐`, `군사/자원 정탐`, `내정 정탐`, and `상세 정탐`.
- Revealed/locked field labels cover `troops_estimated`, `troops`, `resources`, `publicSupport`, `loyalty`, `governor`, and `tech`.
- Display helpers only treat a field as revealed when the stored city-intel field has matching payload data; otherwise that field remains locked.
- Player-owned city display continues to use the original full-information path.
- Enemy city garrison and advanced detail remain locked until future dedicated intel fields exist; current polish is copy/visibility only.
- Spy-tab known-info summaries now use the same level/revealed/locked wording as the right selected city panel.
- `_player_state["city_intel"]` remains display-only save/load state. Loading must never replay spy cost, effect, relation, detection, wedge, or alliance-break logic.
- Explicitly unchanged: spy success/detection formulas, existing spy action effects, `wedge` logic, alliance proposal/duration/cooldown, trade market pricing, manual/chancellor trade pricing, player chancellor candidate scope, `_player_state["faction_chancellors"]`, left national panel scope, right selected-city scope, BattleContext, Selected City Panel behavior, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidate:
  1. `v0.70-43 WorldMap Domestic/Intel Final QA Pass`

## v0.70-41 Spy Action Polish / Alienation MVP Handoff
- Baseline: `v0.70-40 Diplomacy Action Polish / Alliance MVP` (`0f516a7473cadd371afa04f9b1352c3e9823d85a`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- Added spy action id `wedge` with label `이간질`.
- The existing spy runtime card now includes an `이간질` button for selected foreign cities.
- Validation reuses foreign-target, national chancellor, political aptitude, spy cooldown, and iron-wall gates, then adds counterpart-faction selection and resource-cost checks.
- Counterpart selection excludes PLAYER and self-pairs, prioritizing allied relations, score 60+ relations, active alliance/trade-agreement metadata, then highest relation score.
- Wedge attempts use `SPY_WEDGE_COST` (`gold 600`, `silk 150`) and `SPY_WEDGE_COOLDOWN_TURNS`; validation failures do not spend resources or mutate state.
- Success lowers the target-counterpart relation score by a conservative political aptitude delta and may clear allied status if the resulting score falls below `ALLIANCE_ACCEPTANCE_THRESHOLD`.
- Detection applies `SPY_DETECTED_RELATION_PENALTY_WEDGE` to PLAYER-target faction relations through the existing relation helper; success and detection can both apply.
- Recent wedge results are stored in `_player_state["last_spy_wedge_result"]` and displayed in spy recent-result and turn-summary copy.
- Save/load uses existing `_player_state` persistence; loading restores display/cooldown/relation state only and must not replay cost, relation, detection, or alliance-break effects.
- Explicitly unchanged: existing four spy action formulas/effects, v0.70-40 alliance proposal flow, v0.70-39 market price formulas/state, enemy city intel visibility filter, player chancellor candidate scope, `_player_state["faction_chancellors"]`, left national panel scope lock, right selected-city scope, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidate:
  1. `v0.70-42 Enemy Intel UI Polish / Fog of War`

## v0.70-40 Diplomacy Action Polish / Alliance MVP Handoff
- Baseline: `v0.70-39 Trade Market / Price Variation MVP` (`84bbf9c5e12e3afff523d3e389043a7126dce732`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- Added diplomacy action id `alliance_proposal` with label `동맹 제안`.
- The action uses proposal cost `gold 200` / `silk 50`, cooldown `4`, and alliance duration `8` turns.
- Validation blocks player/empty targets, hostile or suspended relations, already active alliances, active target diplomacy cooldown, and missing resources.
- Acceptance uses the existing `_calculate_alliance_acceptance_chance()` score and `ALLIANCE_ACCEPTANCE_THRESHOLD`.
- Accepted proposals set the relation entry to `status = allied`, store `alliance_turns_remaining`, and record proposal metadata.
- Rejected proposals keep relation status unchanged, spend the proposal package, apply cooldown, and store `reason = rejected`.
- Active alliances are mirrored from relation entries into `_player_state["alliances"]`; load normalization can restore that mirror without replaying costs/effects.
- `_advance_diplomacy_cooldowns_for_world_turn()` decrements alliance turns and returns expired alliances to `neutral`, without changing trade agreement state.
- Recent alliance outcomes are written to both `_player_state["last_alliance_proposal_result"]` and `_player_state["last_diplomacy_action_result"]` for UI display.
- Explicitly unchanged: v0.70-39 market price formulas/state, manual/chancellor external trade price helpers, existing four diplomacy actions, spy formulas/effects, player chancellor candidate scope, `_player_state["faction_chancellors"]`, left national panel scope lock, enemy city intel visibility filter, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-41 Spy Action Polish / Alienation MVP`
  2. `v0.70-42 Enemy Intel UI Polish / Fog of War`

## v0.70-39 Trade Market / Price Variation MVP Handoff
- Baseline: `v0.70-38-hotfix1 Chancellor Candidate Scope & Enemy Chancellor Seed` (`71c61f331a7185a1ebbb2d042b53d791dcb556a8`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- `MANUAL_TRADE_PREVIEW_PRICES` remains the base price authority.
- `_calculate_trade_market_prices()` now produces external-trade-compatible resource keys, including `horses`, and clamps the market multiplier to `0.80..1.20`.
- Market state is normalized through `_normalize_trade_market_result()` and mirrored to `_player_state["trade_market_prices"]` / `_player_state["trade_market_turn"]`.
- `_ensure_trade_market_for_current_turn()` keeps same-turn market state stable across preview/execution/save/load and generates a new state only when the current turn lacks one.
- `_calculate_trade_import_cost()` and `_calculate_trade_export_gain()` now use `_get_trade_market_price(resource_id)`.
- Pricing formulas:
  - Import: `ceil(market_price * amount / efficiency)`.
  - Export: `floor(market_price * amount * efficiency)`.
- Manual external trade preview/execution and chancellor external auto trade share those helpers, so relation efficiency remains layered over the same market price.
- External trade UI relation/preview text includes a compact market price summary such as `시장가: 쌀 3 (+10%) / ...`.
- Explicitly unchanged: left national panel scope, player chancellor candidate scope, `_player_state["faction_chancellors"]`, enemy city intel visibility filter, spy formulas/effects, diplomacy actions, target city storage rules, foreign faction stock, relation score mutation, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-40 Diplomacy Action Polish / Alliance MVP`
  2. `v0.70-41 Spy Action Polish / Alienation MVP`
  3. `v0.70-42 Enemy Intel UI Polish / Fog of War`

## v0.70-38-hotfix1 Chancellor Candidate Scope & Enemy Chancellor Seed Handoff
- Baseline: `v0.70-38 Enemy City Intel Visibility Filter` (`6b61e1f045c461eeff5a53f5a4b77aae6cbada53`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- `_get_player_chancellor_candidate_city_id()` resolves the national candidate source city from valid `capital_city_id`, then `hanseong`, then first valid player-owned city.
- `_get_player_chancellor_candidate_hero_ids()` now reads only that city `stationed_hero_ids` / `hero_ids` and validates player-side, alive/uncaptured, aptitude-bearing heroes.
- This prevents Pyeongyang/foreign stationed player-side heroes such as `cheok_jun_gyeong` from appearing as Hanseong chancellor candidates.
- `_sync_chancellor_assignment_for_selected_city()` remains national-safe from `v0.70-37-hotfix1`; valid current player chancellors are not cleared by selected-city stationing mismatch.
- `_populate_chancellor_assignment_dropdown()` can keep a valid current chancellor visible as `(현재 임명)` if the current assignment is outside the current candidate city, without making foreign-stationed heroes regular candidates.
- `_player_state["faction_chancellors"]` is added as non-player faction chancellor seed state and normalized during defaults, restore, and save sync.
- Enemy faction chancellors are selected from faction-owned city stationed heroes by chancellor aptitude score, with politics/intelligence/command fallback if needed.
- Explicitly unchanged: enemy domestic execution, enemy diplomacy/spy execution, enemy chancellor UI expansion, player chancellor auto-dismissal, spy formulas/effects, diplomacy actions, trade pricing/efficiency, chancellor auto trade, `v0.70-38` enemy city intel visibility filter, BattleContext, Selected City Panel, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-39 Trade Market / Price Variation MVP`
  2. `v0.70-40 Diplomacy Action Polish / Alliance MVP`
  3. `v0.70-41 Spy Action Polish / Alienation MVP`
  4. `v0.70-42 Enemy Intel UI Polish / Fog of War`

## v0.70-38 Enemy City Intel Visibility Filter Handoff
- Baseline: `v0.70-37-hotfix1 Left National Panel Scope Lock` (`f5b74da8c1d24ae6db4390562eb16a69018d1625`).
- Runtime files touched: `scripts/worldmap_test.gd` and `scripts/worldmap_city_info_panel.gd`.
- `WorldMapCityInfoPanel` now receives `set_player_faction_id()` and `set_enemy_city_intel()` context from `worldmap_test.gd`.
- `show_city()` preserves the original full display for player-owned cities and branches foreign/enemy cities into `_show_enemy_city_with_intel_filter()`.
- Enemy city no-intel display intentionally locks detailed fields with `정탐 필요` / `추가 정탐 필요`; attack availability still follows the existing attack-state path.
- Enemy intel fields currently supported by the panel are `troops_estimated`, `troops`, `resources`, `publicSupport`, `loyalty`, `governor`, and `tech`.
- Successful `gather_info` / `정탐` records `_player_state["city_intel"][target_city_id]` through `_record_city_intel_from_spy_result()`.
- `_normalize_city_intel_registry()` prunes malformed/unknown city ids and keeps intel display-only for save/load.
- Spy-tab visibility and known-info summaries now read `_player_state["city_intel"]` so hidden city details are not exposed before intel exists.
- Explicitly unchanged: spy success/detection formulas, spy effect amounts, diplomacy actions, trade pricing/efficiency, chancellor auto trade, left national panel scope lock, BattleContext, player-owned city display behavior, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-39 Trade Market / Price Variation MVP`
  2. `v0.70-40 Diplomacy Action Polish / Alliance MVP`
  3. `v0.70-41 Spy Action Polish / Alienation MVP`
  4. `v0.70-42 Enemy Intel UI Polish / Fog of War`

## v0.70-37-hotfix1 Left National Panel Scope Lock Handoff
- Baseline: `v0.70-37 Spy Action MVP` (`3c0a03be6163230f029eadf464a7b4afee12e775`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- The bug was caused by left-panel chancellor refresh using selected-city data: selecting a foreign city made `_sync_chancellor_assignment_for_selected_city()` clear `_player_state["chancellor_id"]` when the assigned national chancellor was not stationed in that foreign city.
- `_refresh_left_world_status_panel()` no longer passes selected-city data into national chancellor sync/dropdown refresh.
- `_sync_chancellor_assignment_for_selected_city()` is now national-safe: it keeps a valid player-side chancellor assignment and only clears missing/non-player invalid ids.
- `_populate_chancellor_assignment_dropdown()` now lists player-side national chancellor candidates instead of the selected city's stationed heroes, and it preserves display of the current valid player chancellor.
- Left panel scope: player/nation state only for loyalty, tax, national warehouse, chancellor, policy, save controls, and ally turn ending.
- Right panel scope remains selected-city based for city detail, diplomacy/spy targets, and trade targets.
- Spy action validation is unchanged but now sees the retained national chancellor after selecting a foreign city.
- Explicitly unchanged: spy success/detection formulas, spy effects, diplomacy actions, trade pricing/efficiency, chancellor auto trade, save/load schema, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-38 Chancellor Auto Trade QA / Polish`
  2. `v0.70-39 Trade Market / Price Variation MVP`
  3. `v0.70-40 Diplomacy Action Polish / Alliance MVP`
  4. `v0.70-41 Spy Action Polish / Alienation MVP`

## v0.70-37 Spy Action MVP Handoff
- Baseline: `v0.70-36 Diplomacy Action MVP` (`b0f40e4ca4f9acac568a23b73652afc145a1eb66`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- City Detail `외교·첩보 > 첩보` now creates and refreshes a runtime `SpyActionCard` for selected foreign cities.
- Action buttons are connected for:
  - `gather_info` / `정탐`: reveals info through the existing spy info roll/payload path, cooldown 1.
  - `public_support_disrupt` / `민심 교란`: lowers target city public support on successful undetected execution, cooldown 2.
  - `loyalty_disrupt` / `성 충성도 교란`: lowers target city loyalty on successful undetected execution, cooldown 2.
  - `revolt_instigate` / `반란 조장`: records existing `revolt_instigation` boost on successful undetected execution, cooldown 2.
- Validation blocks empty/player targets, missing chancellor, missing political aptitude, active spy cooldown, iron-wall targets, and revolt prerequisites.
- This MVP intentionally does not charge separate spy gold/resource costs; existing cost constants remain for future polish but the connected MVP actions store empty cost payloads.
- Detection applies conservative relation penalties through `_adjust_faction_relation_score()` and records `relation_penalty`, `before_score`, and `after_score`.
- Successful/failure payloads are stored in the existing `_player_state` keys: `last_spy_result`, `last_spy_public_support_disrupt_result`, `last_spy_loyalty_disrupt_result`, and `last_spy_revolt_instigation_result`.
- `_player_state["spy_cooldown"]` and `_player_state["revolt_instigation"]` continue to use the existing save/load path; load is display/state restoration only and does not replay effects.
- Explicitly unchanged: `이간질`, faction-to-faction alienation, spy units/networks, diplomacy action behavior, trade pricing/efficiency, manual trade, chancellor auto trade, target city storage, foreign faction stock, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-38 Chancellor Auto Trade QA / Polish`
  2. `v0.70-39 Trade Market / Price Variation MVP`
  3. `v0.70-40 Diplomacy Action Polish / Alliance MVP`
  4. `v0.70-41 Spy Action Polish / Alienation MVP`

## v0.70-36 Diplomacy Action MVP Handoff
- Baseline: `v0.70-35 Trade Balance / Relation Efficiency Polish` (`f0d03010829b72a64479712fd97833a509e7bad6`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- City Detail `외교·첩보 > 외교` now creates and refreshes a runtime `DiplomacyActionCard` for selected foreign cities.
- Action buttons are connected for:
  - `envoy` / `사절 파견`: gold 30, relation +5, cooldown 1.
  - `tribute` / `조공`: gold 100, relation +12, cooldown 2.
  - `trade_agreement` / `교역 협정`: gold 80, relation +4, 6-turn agreement, cooldown 2.
  - `restore_relations` / `관계 회복`: gold 120, relation +18, cooldown 3, hostile/suspended only.
- Validation blocks empty/player targets, active cooldown, insufficient gold, trade agreement under score 45, trade agreement in hostile/suspended status, and restore outside hostile/suspended status.
- Successful action payloads are stored in `_player_state["last_diplomacy_action_result"]`; failures store display-only failure results without spending resources, changing relation, setting cooldown, or adding agreements.
- Diplomacy action cooldowns are stored on the relation entry as `diplomacy_action_cooldown` and mirrored to `_player_state["diplomacy_action_cooldowns"]`.
- Trade agreements reuse the existing relation entry fields `trade_agreement_active`, `trade_agreement_turns_remaining`, and `trade_agreement_bonus`, with mirror state in `_player_state["trade_agreements"]`.
- `_advance_diplomacy_cooldowns_for_world_turn()` now decrements legacy tribute cooldowns, diplomacy action cooldowns, and active trade agreement duration, then resyncs mirror state.
- Save/load fallback normalizes the new player-state keys and does not replay action effects.
- Explicitly unchanged: alliance proposal execution, military support request execution, war declarations, AI response/rolls, spy action execution, target city storage, foreign faction stock, external trade pricing, chancellor auto trade structure, manual trade panels, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-37 Spy Action MVP`
  2. `v0.70-38 Chancellor Auto Trade QA / Polish`
  3. `v0.70-39 Trade Market / Price Variation MVP`
  4. `v0.70-40 Diplomacy Action Polish / Alliance MVP`

## v0.70-35 Trade Balance / Relation Efficiency Polish Handoff
- Baseline: `v0.70-33 Chancellor Auto Trade Logic Connect` (`1cf079873163784da6620b5b3ecdf6cffdaa6e18`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- Added relation-aware external trade helpers:
  - `_get_trade_efficiency_for_cities(source_city_id, target_city_id)`
  - `_calculate_trade_import_cost(resource_id, amount, efficiency)`
  - `_calculate_trade_export_gain(resource_id, amount, efficiency)`
  - `_calculate_external_trade_delta(order)`
- Efficiency comes from the existing faction relation/trade agreement display multiplier and is clamped before pricing.
- Import cost formula: `ceil(base_price * amount / efficiency)`.
- Export gain formula: `floor(base_price * amount * efficiency)`.
- Manual external preview now includes source/target city ids and uses `_calculate_external_trade_delta()`.
- Manual external execution validation uses relation-aware import cost for gold checks and the same delta helper for applied results.
- Manual order saving records recalculated preview and efficiency metadata; hostile/suspended relations are blocked before saving/execution.
- Pending manual order normalization recalculates preview from current source/target relation efficiency on load/refresh.
- Chancellor external auto trade now uses relation-aware import/export pricing and sorts valid external candidates by higher efficiency first.
- Result summaries can display `효율 xN.NN 적용`.
- Explicitly unchanged: external target city storage, foreign faction stock, national `resource_stock`, relation score mutation, turn cost, random rolls, market price fluctuation, diplomacy actions, spy actions, Selected City Panel, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Preserve the `v0.70-34-hotfix1` warning cleanup names: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-36 Diplomacy Action MVP`
  2. `v0.70-37 Spy Action MVP`
  3. `v0.70-38 Chancellor Auto Trade QA / Polish`
  4. `v0.70-39 Trade Market / Price Variation MVP`

## v0.70-33 Chancellor Auto Trade Logic Connect Handoff
- Baseline: `v0.70-34-hotfix1 GDScript Shadowing Warning Cleanup` (`83cbf79c45bd66959cf0c0478c161ce275de6c47`).
- Numbering note: this was the skipped `v0.70-33` candidate, implemented after `v0.70-34` and `v0.70-34-hotfix1`.
- Runtime file touched: `scripts/worldmap_test.gd`.
- Added chancellor auto trade constants for storage targets, surplus buffers, internal/external caps, and turn-level internal movement cap.
- `_apply_domestic_turn_mvp()` now calls `_apply_chancellor_auto_trade_for_world_turn(turn_number)` after existing domestic/trade market processing and before result recording.
- Preconditions: player city exists, chancellor id is assigned, hero data is valid/player-side, and at least one of internal/external trade modes is `chancellor`.
- Same-turn guard uses `_player_state["last_chancellor_auto_trade_turn"]`; no-op and applied results are stored in `_player_state["last_chancellor_auto_trade_result"]`.
- Internal auto trade:
  - Runs only when `CITY_DETAIL_TAB_INTERNAL_TRADE` mode is `chancellor`.
  - Uses `_get_internal_trade_connected_player_city_ids()`.
  - Moves only connected player-owned city storage from surplus source to deficit target.
  - Sorts target demand by largest deficit and keeps source above target minimum plus buffer.
- External auto trade:
  - Runs only when `CITY_DETAIL_TAB_EXTERNAL_TRADE` mode is `chancellor`.
  - Uses `_get_external_trade_candidate_city_ids()` plus `_can_trade_between_factions()`.
  - Mutates source city storage only, reusing `MANUAL_TRADE_PREVIEW_PRICES`.
  - Does not mutate target city storage or foreign faction stock.
- Policy/aptitude hooks:
  - `balanced`, `agriculture`, `commerce`, `trade`, and `military` each use different resource priorities.
  - `diplomatic`, `economic`, or `administrative` chancellor aptitude modestly raises caps.
  - `trade` policy raises external cap.
- UI display:
  - Internal/external trade tabs read the last auto result.
  - Chancellor mode favors auto result display.
  - Pending external manual orders and manual execution summaries are preserved.
- Persistence:
  - Existing trade persistence sync/restore normalizes `last_chancellor_auto_trade_result` and `last_chancellor_auto_trade_turn`.
  - Load restores display-only payloads and does not replay storage effects.
- Explicitly unchanged: target city storage for external trade, foreign faction stock, national `resource_stock`, relation mutation, turn cost, random success/failure roll, manual trade panel, internal transfer panel, Selected City Panel, diplomacy/spy action behavior, BattleContext, `project.godot`, scenes, assets, `.uid`, and `.ogv`.
- Keep the `v0.70-34-hotfix1` warning cleanup names intact: no local `resource_label`, no local `selected_city_id`, no `sign` parameter, and no local `loyalty_card` reintroduction.
- Next candidates:
  1. `v0.70-35 Trade Balance / Relation Efficiency Polish`
  2. `v0.70-36 Diplomacy Action MVP`
  3. `v0.70-37 Spy Action MVP`
  4. `v0.70-38 Chancellor Auto Trade QA / Polish`

## v0.70-34-hotfix1 GDScript Shadowing Warning Cleanup Handoff
- Baseline: `v0.70-34 Trade Persistence Polish` (`c7897b2b4572222991fcaefdc4da88323b3aafd8`).
- Runtime files touched: `scripts/worldmap_test.gd` and `scripts/worldmap_city_info_panel.gd`.
- Cleanup only:
  - WorldMap local `resource_label` names in manual/external trade row construction were renamed.
  - WorldMap local `selected_city_id` in diplomacy/spy content rendering was renamed.
  - WorldMap `_format_internal_trade_signed_transfer_amounts()` parameter `sign` was renamed.
  - Selected City Panel local `loyalty_card` in `_apply_selected_city_layout_order()` was renamed.
- The class members `@onready var resource_label`, `var selected_city_id`, and `@onready var loyalty_card` remain valid and were not removed.
- Explicitly unchanged: trade persistence, pending manual orders, internal transfer, external manual execution, UI behavior/layout, formulas, save/load structure, diplomacy/spy behavior, Selected City Panel behavior, BattleContext, `project.godot`, scenes, and assets.
- Next candidates:
  1. `v0.70-33 Chancellor Auto Trade Logic Connect`
  2. `v0.70-35 Trade Balance / Relation Efficiency Polish`
  3. `v0.70-36 Diplomacy Action MVP`
  4. `v0.70-37 Spy Action MVP`

## v0.70-34 Trade Persistence Polish Handoff
- Baseline: `v0.70-32 Trade Execution Connect MVP` (`5cd34251fbbf221607e8d6c149325623ddf9fe89`).
- `v0.70-33 Chancellor Auto Trade Logic Connect` was intentionally skipped and remains a follow-up.
- Runtime file touched: `scripts/worldmap_test.gd`.
- Added trade persistence normalize/sync/restore helpers around the existing `_player_state` save path.
- `_sync_trade_persistence_to_player_state()` runs before `_serialize_worldmap_state()` duplicates `_player_state`.
- `_restore_trade_persistence_from_player_state()` runs after initialization, reset, and worldmap load restore.
- Persisted keys:
  - `_player_state["trade_control_modes"]`
  - `_player_state["manual_trade_orders"]`
  - `_player_state["last_external_manual_trade_execution_result"]`
  - `_player_state["last_internal_trade_transfer_result"]`
- Trade control modes are normalized to the two known tabs: `internal-trade` and `external-trade`, each falling back to `chancellor` on missing or invalid values.
- Pending external manual orders are normalized by source/target city id, player-owned source, allowed resources, `import/export` action, nonnegative amount, and recalculated preview.
- Invalid pending orders are pruned and logged with `[TRADE_SAVE_LOAD] dropped invalid manual trade order...`.
- Recent external execution and internal transfer results are display-only payloads. Load never replays trade execution or internal transfer effects.
- City `storage` persistence continues through the existing `worldmap_city_state` path and `_normalize_city_storage()`; no large save schema rewrite was introduced.
- Explicitly unchanged: UI node/panel transient state persistence, chancellor automatic trade, relation efficiency pricing, price variation, target city storage mutation, foreign faction stock, relation mutation, turn cost, Selected City Panel, diplomacy/spy content and visibility hotfix, BattleContext, `project.godot`, scenes, and assets.
- Next candidates:
  1. `v0.70-33 Chancellor Auto Trade Logic Connect`
  2. `v0.70-35 Trade Balance / Relation Efficiency Polish`
  3. `v0.70-36 Diplomacy Action MVP`
  4. `v0.70-37 Spy Action MVP`

## v0.70-32 Trade Execution Connect MVP Handoff
- Baseline: `v0.70-31 Internal Trade Manual Transfer MVP` (`856f411a633ac2f7b12ccb3cfd66412e593c6ad8`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- City Detail `무역 > 타국무역` now creates a runtime `ManualTradeExecutionButton` under the City Detail content.
- The execution button is visible only when:
  1. the unified panel is on `무역 > 타국무역`,
  2. a selected player-owned source city exists,
  3. at least one external candidate is still valid,
  4. `_manual_trade_orders[source_city_id]` exists.
- Execution reuses the saved order payload from `v0.70-30`: `source_city_id`, `target_city_id`, `trade_type`, `mode`, `orders`, and `preview`.
- Execution prices reuse `MANUAL_TRADE_PREVIEW_PRICES`; relation efficiency is still display-only and is not multiplied into actual execution.
- Import execution mutates selected source city storage only: `gold -= price * amount`, `resource += amount`.
- Export execution mutates selected source city storage only: `resource -= amount`, `gold += price * amount`.
- `_validate_external_manual_trade_execution()` runs before mutation and blocks missing/invalid order, non-player source, invalid/expired target, same/empty faction, blocked trade relation, invalid resources/actions, negative amounts, empty actionable order, gold shortage, and export resource shortage.
- `_execute_external_manual_trade_order()` applies all deltas only after validation, records `_player_state["last_external_manual_trade_execution_result"]`, clears the pending order on success, and keeps the pending order on failure.
- The external trade tab now displays saved-order execution pending copy, recent successful execution copy, or failure copy.
- Explicitly unchanged: target city storage, foreign faction stock, national `resource_stock`, relation scores, turn flow, internal transfer logic, chancellor automatic trade, formulas, Selected City Panel, diplomacy/spy content and visibility hotfix, BattleContext, `project.godot`, scenes, and assets.
- Next candidates:
  1. `v0.70-33 Chancellor Auto Trade Logic Connect`
  2. `v0.70-34 Trade Persistence Polish`
  3. `v0.70-35 Trade Balance / Relation Efficiency Polish`
  4. `v0.70-36 Diplomacy Action MVP`

## v0.70-31 Internal Trade Manual Transfer MVP Handoff
- Baseline: `v0.70-30 Manual Trade Order Panel MVP` (`df761af4a658f98177b6a498efe5515fd2a1c634`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- City Detail `무역 > 자국무역` now creates a runtime `InternalTradeTransferPanel` under `WorldMapUI`.
- Internal-trade `수동 조정` opens the panel only when the selected source city is player-owned and has at least one connected player-owned city.
- Target candidates come from `_get_internal_trade_connected_player_city_ids()` and remain player-owned only.
- The panel provides:
  - source city display,
  - connected player-owned target `OptionButton`,
  - per-resource amount `SpinBox`,
  - source/target preview,
  - `이송 적용` and `취소`.
- Transfer resources are `gold`, `rice`, `barley`, `seafood`, `wood`, `iron`, `horses`, `silk`, and `salt`, displayed as `금전`, `쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, and `소금`.
- Each SpinBox max is the source city's current city `storage` amount.
- Confirm path validates source/target ownership, source != target, connected player-owned target, nonzero amounts, allowed resource ids, and source storage availability.
- Successful transfer subtracts from source city storage and adds to target city storage through existing city runtime storage state, records `_player_state["last_internal_trade_transfer_result"]`, and refreshes City Detail/left HUD bindings.
- Existing city storage save/load remains the persistence path. No new large schema was added.
- Explicitly unchanged: national `resource_stock`, external trade purchase/sale execution, external manual order panel behavior, relation mutation, turn consumption, formulas, troop movement, Selected City Panel, diplomacy/spy content and visibility hotfix, BattleContext, `project.godot`, scenes, and assets.
- Next candidates:
  1. `v0.70-32 Trade Execution Connect MVP`
  2. `v0.70-33 Chancellor Auto Trade Logic Connect`
  3. `v0.70-34 Trade Persistence Polish`
  4. `v0.70-35 Diplomacy Action MVP`

## v0.70-30 Manual Trade Order Panel MVP Handoff
- Baseline: `v0.70-29 WorldMap Trade Control Mode UI MVP` (`d55c76e3c5f8b6270a76812d32e7fe1fcc3b6102`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- City Detail `무역 > 타국무역` now creates a runtime `ManualTradeOrderPanel` under `WorldMapUI`.
- The external trade `수동 조정` button opens the panel only when the selected city is player-owned and has at least one external trade candidate.
- The panel provides:
  - source city display,
  - external candidate `OptionButton`,
  - relation/trade-availability/efficiency display,
  - per-resource action `OptionButton` for `안함 / 수입 / 수출`,
  - per-resource integer amount `SpinBox`,
  - preview text,
  - `명령 저장` and `취소`.
- Manual trade resources are `rice`, `barley`, `seafood`, `wood`, `iron`, `horses`, `silk`, and `salt`, displayed as `쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, and `소금`.
- Preview-only prices live in `MANUAL_TRADE_PREVIEW_PRICES`; they are not final balance formulas and do not execute transactions.
- `수입` previews resource increase and gold decrease; `수출` previews resource decrease and gold increase. Relation efficiency is displayed only and is not applied to the MVP preview.
- Confirmed orders are stored in runtime `_manual_trade_orders[source_city_id]` with `source_city_id`, `target_city_id`, `trade_type`, `mode`, `orders`, and `preview`.
- External trade tab displays a saved manual-order summary when present; otherwise it shows that no manual order is saved.
- Explicitly unchanged: actual `resource_stock` mutation, city `storage` mutation, relation mutation, turn consumption, trade execution, save/load schema, internal trade manual transfer, chancellor auto trade, Resource tab, diplomacy/spy content and visibility hotfix, Selected City Panel, formulas, BattleContext, `project.godot`, scenes, and assets.
- Next candidates:
  1. `v0.70-31 Internal Trade Manual Transfer MVP`
  2. `v0.70-32 Trade Execution Connect MVP`
  3. `v0.70-33 Chancellor Auto Trade Logic Connect`
  4. `v0.70-34 Diplomacy Action MVP`

## v0.70-29 WorldMap Trade Control Mode UI MVP Handoff
- Baseline: `v0.70-28-hotfix1 Diplomacy Spy Subtab Visibility Fix` (`48fa66938563524cff7ec919904b8e25d90d909c`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- City Detail `무역 > 자국무역` and `무역 > 타국무역` now create and update a runtime `TradeControlCard`.
- Added runtime nodes: `TradeControlCard`, `TradeControlTitleLabel`, `TradeControlStatusLabel`, `TradeControlButtonRow`, `TradeAutoButton`, `TradeManualButton`, and `TradeControlHintLabel`.
- Added trade-control modes: `chancellor` and `manual`.
- Internal and external trade modes are separate runtime slots in `_trade_control_modes`, both defaulting to `chancellor`.
- `수동 조정` is disabled when there are no valid targets: no connected player-owned city for internal trade, or no adjacent foreign trade candidate for external trade.
- Selecting `재상에게 일임` or `수동 조정` refreshes the current City Detail trade tab immediately and does not execute trade.
- Existing text-format helpers no longer duplicate the old `재상 위임 / 수동 조정` line; the button card owns trade-leadership display.
- Persistence remains deferred: save/load handling for trade-control mode should be considered in a later Trade Control Connect task.
- Explicitly unchanged: actual internal/external trade execution, resource movement, gold purchase/sale, resource exchange, chancellor auto-trade logic, trade/relation formulas, turn handling, resource tab, diplomacy/spy tabs and the hotfix visibility rule, Selected City Panel, BattleContext, save/load schema, `project.godot`, scenes, and assets.
- Next candidates:
  1. `v0.70-30 Manual Trade Order Panel MVP`
  2. `v0.70-31 Internal Trade Manual Transfer MVP`
  3. `v0.70-32 Chancellor Auto Trade Logic Connect`
  4. `v0.70-33 Diplomacy Action MVP`

## v0.70-28-hotfix1 Diplomacy Spy Subtab Visibility Fix Handoff
- Baseline: `v0.70-28 Diplomacy Spy Tab Structure Polish` (`fbc6a6e`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- Root cause: `_refresh_unified_panel_chrome()` renamed the reused resource/internal tab buttons to `외교` and `첩보` in diplomacy/spy mode, but did not force their `visible` state back to `true`.
- Fix: diplomacy/spy primary mode now explicitly sets:
  - `city_detail_resource_tab_button_placeholder.visible = true` for `외교`.
  - `city_detail_internal_trade_tab_button_placeholder.visible = true` for `첩보`.
  - `city_detail_external_trade_tab_button_placeholder.visible = false`.
- Existing `_on_unified_secondary_tab_pressed()` routing remains valid: tab index 0 selects `DIPLOMACY_SPY_TAB_DIPLOMACY`, and tab index 1 selects `DIPLOMACY_SPY_TAB_SPY`.
- Diplomacy/spy action copy now explicitly points execution to Diplomacy Action MVP / Spy Action MVP.
- Explicitly unchanged: diplomacy/spy execution, relation mutation, spy rolls, resource spending, turn consumption, resource/trade tabs, Selected City Panel, formulas, battle/BattleContext, save/load schema, `project.godot`, and assets.
- Next candidates:
  1. `v0.70-29 City Tech Tree UI Entry`
  2. `v0.70-30 Trade Control MVP`
  3. `v0.70-31 Diplomacy Action MVP`
  4. `v0.70-32 Spy Action MVP`

## v0.70-28 Diplomacy Spy Tab Structure Polish Handoff
- Baseline: `v0.70-27 Selected City Stability + Military Card Polish` (`6136aa2`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- City Detail `외교·첩보 > 외교` now displays selected city ownership, PLAYER relation status, relation score, trade availability, and diplomacy action candidates.
- City Detail `외교·첩보 > 첩보` now displays target city information level, known information scope, spy action candidates, and recent spy result only when it relates to the selected city.
- Raw relation ids are translated to Korean UI labels; same-faction/player-owned cities are shown as `자국 도시`.
- Spy action candidate status uses side-effect-free check helpers such as `_can_gather_spy_info()` and `_can_disrupt_city_public_support()`; it does not roll, spend resources, change turns, or execute spy actions.
- Removed visible developer copy from this City Detail render path: web-version, display-only, placeholder-style, and Godot-facing wording.
- The diplomacy/spy tab does not display public support details, city loyalty details, revolt-risk details, troop movement, recruitment, city storage, resource potential, trade details, supply adjustments, or military-card content.
- Explicitly unchanged: resource tab/storage cards, internal/external trade, Selected City Panel stability/military cards, governor/garrison/hero movement/attack/help flows, recruitment, troop movement, formulas, battle/BattleContext, save/load schema, `project.godot`, and assets.
- Next candidates:
  1. `v0.70-29 City Tech Tree UI Entry`
  2. `v0.70-30 Trade Control MVP`
  3. `v0.70-31 Diplomacy Action MVP`
  4. `v0.70-32 Spy Action MVP`

## v0.70-27 Selected City Stability + Military Card Polish Handoff
- Baseline: `v0.70-26 External Trade Tab Structure Polish` (`5021d47`).
- Runtime files touched: `scripts/worldmap_city_info_panel.gd` and `scripts/worldmap_test.gd`.
- The right Selected City Panel now uses the existing loyalty card as a `성 안정도` area.
- Loyalty display now includes a simple stability label derived from the displayed city loyalty: 70+ `안정`, 50-69 `주의`, below 50 `위험`.
- Revolt risk display is supplied through `set_revolt_risk_summaries()` from the existing WorldMap revolt-risk calculation path and shown as `반란 위험 낮음/주의/위험`.
- Military information is grouped in a runtime `군사` card that contains the existing military summary, recruitment section, and `모병 100` button.
- The `recruitment_requested(city_id, 100)` signal path is preserved; only the parent container of the existing button changed.
- Governor assignment/policy controls, garrison card, hero movement panel, attack button, help buttons, Selected City Panel drag, and City Detail resource/internal-trade/external-trade/diplomacy tabs were preserved.
- Explicitly unchanged: revolt-risk formula, recruitment/conscription formulas, public support/loyalty formulas, troop movement logic, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, and assets.
- Next candidates:
  1. `v0.70-28 Diplomacy Spy Tab Structure Polish`
  2. `v0.70-29 City Tech Tree UI Entry`
  3. `v0.70-30 Trade Control MVP`
  4. `v0.70-31 Selected City Hero Movement Polish`

## v0.70-26 External Trade Tab Structure Polish Handoff
- Baseline: `v0.70-25 Internal Trade Tab Ownership Filter Polish`.
- Runtime file touched: `scripts/worldmap_test.gd`.
- `무역 > 타국무역` now filters external trade candidates to neighboring cities that are not player-owned and have a valid owner/faction.
- Player-owned neighboring cities are excluded from the external trade candidate list, so captured cities move out of `타국무역` and remain available to `자국무역`.
- The tab now displays external trade candidates, localized relation status, trade availability, relation-based trade efficiency, and a future trade-leadership slot.
- Empty state is shown when there are no adjacent foreign trade candidates; recent trade-result details are not forced into that state.
- Relation status is shown in Korean UI labels while internal ids remain unchanged.
- Removed from external trade tab display: public support, city loyalty, loyalty drift, seasonal loyalty, revolt risk, troop movement, recruitment/conscription, military supply judgment, and supply-adjustment details.
- `재상 위임 / 수동 조정` is only a future trade-leadership slot; no automatic or manual trade adjustment behavior was implemented.
- Explicitly unchanged: resource tab/storage cards, internal trade, diplomacy/spy, Selected City Panel, troop movement logic, recruitment logic, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, and assets.
- Next candidates:
  1. `v0.70-27 Selected City Stability + Military Card Polish`
  2. `v0.70-28 Diplomacy Spy Tab Structure Polish`
  3. `v0.70-29 City Tech Tree UI Entry`
  4. `v0.70-30 Trade Control MVP`

## v0.70-25 Internal Trade Tab Ownership Filter Polish Handoff
- Baseline: `v0.70-24a City Storage Gold Source Fix + Resource Card Polish`.
- Runtime file touched: `scripts/worldmap_test.gd`.
- `무역 > 자국무역` now filters internal trade candidates to neighboring cities owned by the player.
- If the selected city is not player-owned or has no connected player-owned neighboring city, the tab shows an empty state with owned-city count and `연결 아군 성: 없음`.
- Hanseong-only ownership no longer displays foreign neighboring cities as internal trade routes.
- Removed from internal trade tab display: public support, loyalty drift, seasonal loyalty, revolt risk, manual troop movement, troop movement button text, recruitment, and conscription.
- Supply role/status is shown in Korean UI labels while internal values remain unchanged.
- Supply adjustment details such as loyalty/security deltas remain internal and are not shown in this tab.
- `재상 위임 / 수동 조정` is only a future trade-leadership slot; no automatic or manual trade adjustment behavior was implemented.
- Explicitly unchanged: resource tab/storage cards, external trade, diplomacy/spy, Selected City Panel, troop movement logic, recruitment logic, revolt/public support/loyalty formulas, supply/trade formulas, battle/BattleContext, save/load schema, `project.godot`, and assets.
- Next candidates:
  1. `v0.70-26 External Trade Tab Structure Polish`
  2. `v0.70-27 Selected City Stability + Military Card Polish`
  3. `v0.70-28 Diplomacy Spy Tab Structure Polish`
  4. `v0.70-29 City Tech Tree UI Entry`

## v0.70-24a City Storage Gold Source Fix + Resource Card Polish Handoff
- Baseline: `v0.70-24 City Storage Resource Tab MVP`.
- Runtime file touched: `scripts/worldmap_test.gd`.
- The City Detail resource tab now treats `storage.gold` as the only displayed source for real city-held gold.
- The upper economy block no longer reads `city_data.gold`; it is labeled `경제 잠재력` and shows only population and commerce potential.
- The storage fallback bug was fixed:
  - Missing `storage` key or non-Dictionary storage uses `_build_default_city_storage()`.
  - Explicit Dictionary storage, including all-zero saved storage, is normalized and preserved.
  - Hanseong missing storage falls back to current national `resource_stock`.
- Hanseong default storage expected display: `금전 500`, food total 630, strategy total 180, specialty total 80.
- `성 창고` formatting now separates summary lines from detail lines for food, strategy, and specialty groups.
- `자원 잠재력` and `성 창고` are visually split with runtime `PanelContainer` card wrappers. The scene file does not need a structural rewrite for this helper.
- Existing tab buttons, collapse button, drag handles, save/load city runtime storage persistence, national warehouse, trade, turn production, battle, BattleContext, formulas, `project.godot`, and assets are unchanged.
- Next candidates:
  1. `v0.70-25 WorldMap Trade Tab Structure Polish`
  2. `v0.70-26 WorldMap Diplomacy Spy Tab Structure Polish`
  3. `v0.70-27 City Tech Tree UI Entry`

## v0.70-24 City Storage Resource Tab MVP Handoff
- Baseline: `v0.70-23-hotfix2 Full GDScript Ternary Compatibility Sweep` (`207a76e`).
- Runtime file touched: `scripts/worldmap_test.gd`.
- City Detail resource tab now keeps existing star rows as resource potential and adds `성 창고` below the economy block for current city-held storage.
- Storage structure:
  - `storage.gold`
  - `storage.rice`
  - `storage.barley`
  - `storage.seafood`
  - `storage.wood`
  - `storage.iron`
  - `storage.horses`
  - `storage.silk`
  - `storage.salt`
- Hanseong default storage is copied from the current national `resource_stock`: gold 500, rice 300, barley 250, seafood 80, wood 100, iron 50, horses 30, silk 30, salt 50.
- Other cities default to zero storage unless explicit runtime/loaded `storage` exists. This is intentional MVP behavior to avoid inventing balance.
- Save/load now serializes and applies `storage` inside `worldmap_city_state`; older saves without `storage` get safe default storage on load.
- The UI summary groups storage as food (`rice`, `barley`, `seafood`), strategy (`wood`, `iron`, `horses`), and specialty (`silk`, `salt`) with simple 300/100 thresholds for `안정` / `주의` / `부족`.
- Explicitly unchanged: national warehouse UI, national `resource_stock`, turn production, trade movement, supply consumption, recruitment, upkeep, battle loot, BattleContext, formulas, `WorldMap_Test.tscn`, `project.godot`, and assets.
- Manual F6 QA should confirm Hanseong resource tab storage display, save/load persistence, expanded/collapsed drag, collapse/expand, tab switching, help, Selected City Panel, attack/governor/recruitment buttons, and clean Godot Output.
- Next candidates:
  1. `v0.70-24a City Storage Save Load QA / Polish`
  2. `v0.70-25 WorldMap Trade Tab Structure Polish`
  3. `v0.70-26 WorldMap Diplomacy Spy Tab Structure Polish`
  4. `v0.70-27 City Tech Tree UI Entry`

## v0.70-23-hotfix2 Full GDScript Ternary Compatibility Sweep Handoff
- Baseline: `v0.70-23-hotfix1 City Detail Drag + GDScript Reload Warning Fix` (`b8ca197`).
- Runtime files touched: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `scripts/player_attack_deployment_panel.gd`, `scripts/battle_web_import_test.gd`, and `scripts/worldmap_city_marker.gd`.
- The sweep used `rg " if .* else " --glob "*.gd"` across the repo, not a `Dictionary`-only search.
- Converted:
  - `worldmap_city_info_panel.gd`: attack hint text and selected-city layout anchor/index/label ternaries.
  - `player_attack_deployment_panel.gd`: defense/attack text, Color, SpinBox, warning, summary, action label, and supply status ternaries.
  - `battle_web_import_test.gd`: WorldMap battle context labels/sides, result payload labels/sides, troop survivor/wounded calculations, cutin Vector2 selections, debug parent strings, roster panel source/reason, and allocation fallback.
  - `worldmap_city_marker.gd`: selected scale and selected text color.
  - `worldmap_test.gd`: recent unified City Detail chrome/tab Color selections, resource-group return, neighbor display-name fallback, supply-state label, and unified secondary-tab selection.
- Remaining `rg " if .* else " --glob "*.gd"` hits are all in `scripts/worldmap_test.gd`; they are same-type scalar/value choices and were left to avoid unnecessary large behavioral churn.
- Headless project, WorldMap scene, and Battle scene loads were clean for the reported ternary reload message in this environment.
- If the Godot editor continues to display the old ternary warning after this patch while headless remains clean, restart the editor before assuming a new code issue; this handoff does not authorize deleting repo-external editor cache files.

## v0.70-23-hotfix1 City Detail Drag + GDScript Reload Warning Fix Handoff
- Baseline: `v0.70-23 WorldMap City Detail Resource Tab Slim Polish` (`94b404b`).
- Runtime files touched: `scripts/worldmap_test.gd` and `scripts/worldmap_city_info_panel.gd`.
- CityDetailPanel drag root cause: the registered handles were `city_detail_eyebrow_label` and `city_detail_heading_label`; both are hidden in the expanded unified panel, leaving only the collapsed heading path usable.
- Fix: `_setup_independent_hud_panel_drag()` now registers `city_detail_header_row` as an additional handle, so the visible expanded top row can start panel drag.
- Buttons were not registered directly as handles: `CollapseButtonPlaceholder`, `도시 상세`, `외교·첩보`, `무역`, `자원`, `자국무역`, and `타국무역` keep their button click paths.
- The existing collapsed click-to-expand flow remains in `_input()` / `_on_hud_drag_handle_gui_input()` with `_collapsed_unified_panel_click_candidate` and the existing drag threshold.
- Reload warning cleanup:
  - `_set_city_detail_body_labels_visible(visible: bool)` is now `_set_city_detail_body_labels_visible(should_show: bool)`.
  - Type-unclear `Dictionary` ternaries in the recently touched WorldMap scripts were rewritten as explicit `Variant` extraction plus `if raw is Dictionary` checks.
- Explicitly unchanged: City Detail resource tab content, trade/diplomacy/spy structure, help copy, recruitment, governor/attack flows, formulas, battle scenes, BattleContext, save/load schema, `project.godot`, and assets.
- Manual F6 QA should confirm expanded drag, collapsed drag, collapsed click-only expand, collapse button, primary/secondary tabs, resource tab display, Selected City Panel drag, help buttons, attack/governor/recruit buttons, and clean Godot Output for the two reload messages.

## v0.70-23 WorldMap City Detail Resource Tab Slim Polish Handoff
- Baseline: `v0.70-22-hotfix1 GDScript Ternary Type Compatibility Fix` (`789c2de`).
- Runtime/scene files touched: `scripts/worldmap_test.gd` and `WorldMap_Test.tscn`.
- City Detail resource view now acts as a deep-view panel for city resource/economy potential rather than repeating the Selected City Panel.
- Resource tab content:
  - City name at the top.
  - `식량 자원`: rice/barley/seafood star potential.
  - `전략 자원`: wood/iron/horse star potential.
  - `특산 자원`: silk/salt star potential.
  - `경제`: population stars, commerce stars, and gold.
- Removed duplicate resource-tab display of city type, faction/region, city loyalty, troops, security baseline, defense, status, governor, and stationed hero count.
- Unified panel primary tabs are now `도시 상세`, `외교·첩보`, `무역`, and `접기`; `자국무역` / `타국무역` are handled as trade-family secondary tabs.
- Existing diplomacy/spy content, selected-city help modal, recruitment, governor assignment/policy, attack, save/load, battle entry, BattleContext, and formulas were preserved.
- Tech tree UI remains deferred. The next natural follow-up is city tech-tree UI work after this city detail / diplomacy-spy / trade panel split.
- Manual F6 QA should confirm Hanseong resource tab display, colored category labels, no duplicate Selected City info, trade tab switching, diplomacy/spy switching, and retained help/recruit/governor/attack behavior.

## v0.70-22-hotfix1 GDScript Ternary Type Compatibility Fix Handoff
- Baseline: `v0.70-22 WorldMap Implemented Help Modal MVP` (`720c0a9`).
- Runtime file touched: `scripts/worldmap_city_info_panel.gd`.
- The hotfix only changes the selected-city help-row layout anchor from a ternary to an explicit `Control` variable plus `if/else`.
- Cause: the ternary mixed `_domestic_help_row` (`HBoxContainer`) and `military_state_label` (`Label`) as alternate values, which can trip Godot 4 GDScript compatibility checks.
- Help modal topics, copy, button placement intent, formulas, battle scenes, save/load, `project.godot`, and assets are unchanged.

## v0.70-22 WorldMap Implemented Help Modal MVP Handoff
- Baseline: `v0.70-21 WorldMap Recruitment Loyalty-Based Connect` (`5d730bb`).
- Runtime files touched: `scripts/worldmap_test.gd` and `scripts/worldmap_city_info_panel.gd`.
- Scene file was not edited; help buttons/modal are runtime UI additions.
- `WorldMapCityInfoPanel` now emits `help_requested(topic_id)` for right-panel topics and keeps existing attack, governor assignment, hero transfer, and recruitment signals.
- `worldmap_test.gd` owns the common `WorldMapHelpModal` under `WorldMapUI`, connects help requests, updates title/body by topic, and closes via the modal button or Esc.
- Help topics:
  - 국가충성도: tax burden, political chancellor mitigation, stable domestic operation.
  - 성 충성도: tax, security, supply, political governor/chancellor support, publicSupport stability.
  - 민심: tax, food, commerce, supply.
  - 치안: stationed troops, supply, minimum garrison, invasion/battle readiness.
  - 주둔무장: governor candidates, battle deployment, city defense, governor command-limit contribution.
- Help copy is based on current code paths only and does not expose formulas or multipliers.
- No player-facing hero personal loyalty increase action was confirmed, so no such method is described.
- Manual F6 QA should click all five help buttons, close the modal, switch cities, drag panels, and verify attack/governor/policy/transfer/recruitment/save/load buttons still behave as before.

## v0.70-21 WorldMap Recruitment Loyalty-Based Connect Handoff
- Baseline: `v0.70-20a WorldMap Selected City Panel Layout Order Polish`.
- Runtime files touched: `scripts/worldmap_test.gd` and `scripts/worldmap_city_info_panel.gd`.
- Scene file touched only to rename the initial `RecruitButtonPlaceholder` text away from the old recruit placeholder wording.
- Recruitment rule:
  - 모병 기준을 publicSupport에서 city loyalty 기반으로 바로잡았다.
  - Loyalty thresholds: `<40` = 0, `40-59` = 100, `60-79` = 200, `80-89` = 300, `90+` = 500.
  - `_can_recruit_troops(city_id, amount)` uses the loyalty-based limit, while preserving ownership, amount, peacetime, and resource checks.
  - `last_recruitment_result` records `publicSupport` for compatibility, but also records `loyalty` and `loyalty_limit`; publicSupport is not the amount-limit axis.
- Conscription rule:
  - 징병은 loyalty + `barracks` + `conscription_system` automatic reinforcement axis.
  - `barracks` remains required for automatic city conscription.
  - `conscription_system` keeps the existing 1.10 turn-add effect.
- Selected City Panel:
  - The right panel now shows `병사 충원`.
  - It displays one concise conscription line and one concise recruitment line without exposing formulas or multipliers.
  - The button emits `recruitment_requested(city_id, 100)` and worldmap handles validation/payment/troop increase/refresh.
- publicSupport direction:
  - publicSupport is retained for future fatigue, dissatisfaction, and revolt-risk work.
  - This patch does not apply recruitment fatigue, publicSupport loss, loyalty loss, population loss, or revolt-risk changes.
- Manual F6 QA should confirm Hanseong selection, conscription text, `모병 100` click, troop +100, national gold -100, food -50 from rice/barley/seafood order, result hint, city switching refresh, peacetime blocking, and existing attack/governor/transfer behavior.

## v0.70-20a WorldMap Selected City Panel Layout Order Polish Handoff
- Baseline: `v0.70-20 WorldMap Selected City Governor Garrison & Hero Transfer Polish` (`0e5cd21717d1364a591a0abfaf42e732eb17550a`).
- Runtime file touched: `scripts/worldmap_city_info_panel.gd`.
- Scene file touched only for selected-city panel metadata serialization (`WorldMap_Test.tscn` / `GovernorAssignOption` unique id); no broad scene layout redesign was made.
- Selected-city visible order:
  1. City name.
  2. `세력`.
  3. `유형`.
  4. `성 충성도`.
  5. `민심 / 치안 / 상업 / 농업`.
  6. `태수` card.
  7. `주둔 무장` card.
  8. `무장 이동` button and inline transfer UI.
  9. `병력 / 방어 / 치안 기준`.
  10. Recruitment area; v0.70-21 supersedes this with `병사 충원`.
- Governor card:
  - Keeps existing `GovernorAssignOption` and `GovernorPolicyOption` connections.
  - Shows effect/policy inside the governor card as `효과: ...` and `정책: ...`.
  - The lower duplicated `태수 정책: 효과: ...` hint path is hidden.
- Garrison card:
  - Runtime `GarrisonCard` wraps the existing `주둔 무장` title plus portrait/name/stat rows.
  - Portraits continue to reuse `WorldMapHeroPortraitHelper`.
- Action layout:
  - `무장 이동` moved directly below the garrison card and keeps the v0.70-20 inline transfer behavior.
  - Selected-city `내정` button is hidden for now; City Detail / Domestic work remains deferred.
  - A recruit placeholder was placed below the military summary; v0.70-21 supersedes it with connected `병사 충원`.
- Explicitly preserved: governor assignment logic, governor policy save/load, hero transfer data movement, battle scripts, BattleContext, domestic/chancellor/governor formulas, recruit logic, `project.godot`, `.uid` / `.ogv`, and assets.
- Manual F6 QA should confirm the visual order, garrison card boundary, hidden domestic button, no duplicate governor policy hint, and retained governor dropdown / policy dropdown / transfer UI behavior.
- Next candidate work:
  1. `v0.70-21 WorldMap City Detail Panel Right Side Polish`
  2. `v0.70-22 WorldMap Battle Entry Camera Zoom Handoff`
  3. `v0.70-23 Governor Assignment Exclusivity & Hero State Rules`

## v0.70-20 WorldMap Selected City Governor Garrison & Hero Transfer Polish Handoff
- Baseline: `v0.70-19a Agent Docs Handoff & ChatCoach Role Lock` (`5b1d131d4ea8eaa2e2746e479a90c77837741304`).
- Runtime files touched: `scripts/worldmap_city_info_panel.gd` and `scripts/worldmap_test.gd`.
- Scene file was not edited; selected-city UI additions are created from the panel script and reuse existing scene nodes where possible.
- Governor section:
  - `GovernorLabel` is now the visible `태수` title above the existing governor card.
  - `GovernorAssignOption` and `GovernorPolicyOption` remain the existing assignment/policy controls.
- Garrison section:
  - `SelectedHeroChipLabel` now reads `주둔 무장`.
  - The old plain `GarrisonLabel` is hidden and replaced at runtime by `GarrisonList`.
  - Each garrison row shows a portrait/placeholder, hero name with existing state badge, and short stats.
  - Portraits reuse `WorldMapHeroPortraitHelper`; no new assets were added.
- Hero transfer:
  - `HeroMoveButtonPlaceholder` now opens/closes an inline `HeroTransferPanel`.
  - Panel fields: `이동할 무장`, `이동 대상`, `이동 확정`, and `취소`.
  - Empty states: `이동 가능한 아군 성이 없습니다.` and `이동 가능한 주둔 무장이 없습니다.`
  - Panel emits `hero_transfer_confirmed(source_city_id, hero_id, target_city_id)`.
  - `worldmap_test.gd` handles the signal, validates adjacent player-owned target cities, moves `stationed_hero_ids` / `hero_ids`, updates hero runtime city, clears source `governor_id` when the moved hero was governor, refreshes selected-city UI, and reports `무장이 이동했습니다.`
- Web reference files checked:
  - `C:\dev\SamWar_web\js\core\app_state.js`: `openHeroTransfer`, `selectHeroTransferHero`, `selectHeroTransferTargetCity`, `confirmHeroTransfer`.
  - `C:\dev\SamWar_web\js\core\world_rules.js`: `transferHeroToCity`.
  - `C:\dev\SamWar_web\js\ui\world_map_ui.js`: transfer data-attribute event binding.
  - `C:\dev\SamWar_web\js\ui\hero_transfer_ui.js`: transfer modal layout.
  - `C:\dev\SamWar_web\js\ui\selected_city_ui.js`: selected-city transfer button placement.
- Existing persistence already serializes city `stationed_hero_ids` / `hero_ids` and hero runtime city state, so no save schema expansion was required.
- Explicitly excluded: global governor exclusivity, wounded/captured/dead release rules, hero-state redesign, domestic/trade/relation formulas, battle scripts, BattleContext, `project.godot`, assets, and `.uid` / `.ogv` changes.
- Manual F6 QA should confirm visible `태수` title, garrison portrait rows, transfer empty states, transfer success between adjacent player cities, governor clearing when moved, panel drag, city switching, attack button, and battle entry.
- Next candidate work:
  1. `v0.70-21 WorldMap City Detail Panel Right Side Polish`
  2. `v0.70-22 WorldMap Battle Entry Camera Zoom Handoff`
  3. `v0.70-23 Governor Assignment Exclusivity & Hero State Rules`

## v0.70-19a Agent Docs Handoff & ChatCoach Role Lock Handoff
- Stable baseline for the next session: `v0.70-19 WorldMap Selected City Governor Assignment & Policy Connect` at `4c671b0e7599ade817d1274768f04b879a757ca4`.
- This handoff is documentation-only. It must not imply code, scene, asset, `project.godot`, battle, `WorldMap_Test.tscn`, or script changes.
- Recent completed work to carry forward:
  1. `v0.70-13b Battle Cinematic Lifecycle Guard Audit`: battle intro/result-video lifecycle cleanup, UI restore, skip guard, and camera restore stability.
  2. `v0.70-13d Battle Movement Facing Direction Polish`: movement segment facing updates for unit/hero visuals.
  3. `v0.70-14` / `14a` / `15` / `16`: left WorldMap panel fixed anchor, World Turn slim header, tax slim UI, chancellor duplicate-copy cleanup, larger chancellor portrait, warehouse/turn/save structure preserved.
  4. `v0.70-18`: selected-city panel right-side startup anchor, drag retained, `SELECTED CITY` hidden, basic city summary slimmed, resource/status/governor summary duplication hidden.
  5. `v0.70-19`: `GovernorAssignOption` added; candidates are selected-city `stationed_hero_ids` plus `미임명`; assignment updates runtime `governor_id`; `GovernorPolicyOption` remains connected; `governor_id`, `governor_policy_id`, and `city_policy_state` persist through save/load; visible developer/placeholder policy copy removed.
- Domestic-system philosophy:
  - 삼국워 내정 시스템은 내부적으로 복잡하게 돌아가야 한다.
  - UI는 최소한의 핵심 정보만 보여준다.
  - 플레이어에게 모든 수치/계산식을 노출하지 않는다.
  - Information panels should show decision summaries; actual calculations stay internal and stable.
  - Chancellor policy is national operating direction, income/upkeep, and nation-level adjustment.
  - Governor policy is selected-city operating direction, city yield, recruitment, and loyalty-flow adjustment.
  - Show policy name plus effect summary; keep detailed multipliers internal.
- ChatCoach role lock:
  - 채코치는 단순 지시문 생성기가 아니다.
  - 채코치는 먼저 GitHub/깃에서 접근 가능한 실제 코드와 문서를 직접 확인한다.
  - 내부 구현과 연결되는 작업은 감으로 지시하지 않는다.
  - ChatCoach should directly check related files, functions, variables, and save structures; judge implementation connectivity; separate safe and risky scope; then write Codex execution instructions.
  - Codex는 실행/수정/검증/로컬 커밋 담당이다.
  - ChatCoach owns design judgment, code-evidence review, and scope definition.
  - Before handing off "Codex should analyze", ChatCoach should inspect GitHub-accessible code/docs where possible.
  - Local-only commits, dirty state, or files absent from GitHub are judged from Codex/user reports.
  - The user should minimize direct PowerShell/Git/Godot operation and continue by pasting Codex reports.
- Known cautions:
  - Do not delete `.uid` / `.ogv`; Theora test `.uid` files are kept for Godot resource stability.
  - Do not use `git clean`; do not push; local commits only.
  - If `WorldMap_Test.tscn` serialization diffs appear, verify intent before proceeding.
  - Do not start feature work from a dirty worktree.
  - Keep battle scene, WorldMap scene, scripts/assets/project settings, and agent-doc scopes separate.
- New chat start summary:
  - Start from `v0.70-19` at `4c671b0e7599ade817d1274768f04b879a757ca4`.
  - Current goal: continue WorldMap left/right panel detail polish.
  - Completed: left-panel World Turn/tax/chancellor/warehouse polish; right-panel city summary/governor assignment/governor policy connection.
  - Recommended first task: `v0.70-20 WorldMap Selected City Panel Troop Stats Polish`.
  - Principle: ChatCoach checks code/docs first for connected implementation work; Codex executes, verifies, and commits.
- Next candidate work:
  1. `v0.70-20 WorldMap Selected City Panel Troop Stats Polish`
  2. `v0.70-21 WorldMap City Detail Panel Right Side Polish`
  3. `v0.70-22 WorldMap Battle Entry Camera Zoom Handoff`
  4. `v0.70-23 Governor Assignment Exclusivity & Hero State Rules`

## v0.70-19 WorldMap Selected City Governor Assignment & Policy Connect Handoff
- Baseline requested: `v0.70-18 WorldMap Selected City Panel Anchor & Summary Slim Polish` (`7f937fe`). Actual pre-edit HEAD was `fd2eb4e 월드맵작업`, a clean local commit modifying only `WorldMap_Test.tscn`; it was preserved.
- Required git analysis was performed before editing:
  - `git status --short`: clean.
  - Recent log confirmed `fd2eb4e` on top of `7f937fe`.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD changed only `WorldMap_Test.tscn`.
- Runtime/scene files touched: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and `scripts/worldmap_city_info_panel.gd`.
- Governor assignment:
  - Added `GovernorAssignOption` under `WorldMapUI/CityInfoPanel/.../GovernorCard/.../Content`.
  - `WorldMapCityInfoPanel` now exposes `governor_assignment_requested(city_id, governor_id)`.
  - Candidate list is `미임명` plus the selected city's `stationed_hero_ids`.
  - `worldmap_test.gd` handles the signal and updates the mutable city runtime `governor_id`; it does not move heroes or mutate `stationed_hero_ids`.
- Governor policy:
  - Existing `GovernorPolicyOption` still updates `_city_policy_state[city_id]`.
  - `GOVERNOR_POLICY_DATA` copy was changed to player-facing wording, so selected-city UI no longer shows `재상 정책 수행`, `Godot에서는 표시 전용`, placeholder/no-effect copy, or "No city stat or turn effect applied".
- Persistence:
  - City runtime save now includes `governor_id` and `governor_policy_id`.
  - Top-level `city_policy_state` is saved and loaded.
  - Older saves fall back to seed `governor_id` / `governor_policy_id` when these keys are missing.
- Explicitly excluded: governor exclusivity, hero movement, wounded/captured/dead governor release, domestic/trade/relation formula changes, turn-income/security redesign, city ownership/troop/resource calculations, battle scripts, and `project.godot`.
- Verification passed: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, and docs marker check. Manual F6 QA remains recommended for dropdown interaction and save/load.

## v0.70-18 WorldMap Selected City Panel Anchor & Summary Slim Polish Handoff
- Baseline: `v0.70-17b Restore Theora Test UID Files` (`9b8b186`) after `WorldMap_Test.tscn` residual serialization diff was restored and the repo was clean.
- Required git analysis was performed before editing:
  - `git status --short`: clean.
  - Recent log confirmed `9b8b186 v0.70-17b`, `110f0e8 v0.70-17a`, `91713d8`, and `4535a3f v0.70-16`.
  - HEAD changed files were five agent docs plus the two restored Theora `.uid` files.
- Runtime/scene files touched: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and `scripts/worldmap_city_info_panel.gd`.
- Selected-city panel structure:
  - `CityInfoPanel` is a direct `WorldMapUI` CanvasLayer child, so it remains independent from `WorldMapCamera` pan/zoom.
  - Drag registration remains in `_setup_independent_hud_panel_drag()` and still registers the selected-city panel through `CityNameLabel`; the hidden eyebrow is no longer a visible drag handle.
- Implementation:
  - Added `SELECTED_CITY_INFO_PANEL_SIZE = Vector2(308.0, 542.0)`.
  - Replaced the generic top-margin lock for `CityInfoPanel` with `_lock_selected_city_info_panel_anchor()`, which anchors the panel at the shared top margin and right-side margin on startup.
  - Scene initial offsets now place `CityInfoPanel` at right margin `10` for the current viewport baseline.
  - Hid the `SELECTED CITY` eyebrow.
  - Reduced visible top summary to city name, `세력: ...`, `유형: ...`, and the loyalty card.
  - Removed `표시 전용` from selected-city loyalty copy.
  - Hid owner/region/nation duplication, population/gold/food, resource list, city status sentence, and governor summary label while preserving the governor card/dropdown and lower panel controls.
- Preserved scope: no left panel, city detail/diplomacy redesign, city data, city click, battle entry, camera handoff, safe-zone camera, domestic/trade/relation formulas, governor internals, resource data, save/load, battle scripts, project settings, `.uid`/`.ogv` assets, or new assets changed.
- Manual F6 QA remains recommended for right-side placement, drag behavior, repeated city selection refresh, hidden duplicate rows, and retained governor/action controls.

## v0.70-17b Restore Theora Test UID Files Handoff
- Baseline: `v0.70-17a Repo Sanity Cleanup Before Selected City Panel Work` (`110f0e8` before this restore).
- Required git analysis was performed before restore:
  - `git status --short`: `WorldMap_Test.tscn` was tracked modified.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD deleted only the two Theora test `.uid` files plus agent cleanup docs from v0.70-17a.
- Restore:
  - Restored `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `assets/video_test/theora_safe/test_safe_q8_1920x.ogv.uid` from `HEAD~1`.
  - The `.uid` files are kept for Godot resource UID reference stability.
  - Preserved `test_safe_q7_1280x.ogv` and `test_safe_q8_1920x.ogv`.
- Important carryover: `WorldMap_Test.tscn modified remains uncommitted`. It was intentionally not staged, committed, or discarded in this restore.
- No scripts, `project.godot`, `.ogv` sources, battle scenes, or selected-city panel logic were changed.
- Next selected-city-panel task should first decide how to handle the existing `WorldMap_Test.tscn` diff before making new scene edits.

## v0.70-17a Repo Sanity Cleanup Before Selected City Panel Work Handoff
- Baseline: after `v0.70-16 WorldMap Left Panel Chancellor Card Polish`; pre-cleanup HEAD was `91713d8 제거목적`.
- Required git analysis was performed before cleanup:
  - `git status --short`: `WorldMap_Test.tscn` was tracked modified.
  - `git show --stat HEAD` / `git show --name-only HEAD`: HEAD added only `assets/video_test/theora_safe/test_safe_q7_1280x.ogv.uid` and `assets/video_test/theora_safe/test_safe_q8_1920x.ogv.uid`.
  - `git diff -- WorldMap_Test.tscn`: current scene diff is left-panel scene serialization/property ordering plus newline string serialization, not right selected-city work.
- Cleanup:
  - Removed the two incorrectly tracked Theora test `.uid` files with `git rm`.
  - Preserved `test_safe_q7_1280x.ogv` and `test_safe_q8_1920x.ogv`.
  - Did not use `git clean`.
- Important carryover: `WorldMap_Test.tscn modified remains uncommitted`. It was analyzed only and intentionally not staged or committed in this cleanup.
- No scripts, `project.godot`, `.ogv` sources, battle scenes, or selected-city panel logic were changed.
- Next selected-city-panel task should first decide how to handle the existing `WorldMap_Test.tscn` diff before making new scene edits.

## v0.70-16 WorldMap Left Panel Chancellor Card Polish Handoff
- Baseline: `v0.70-15 WorldMap Left Panel Header & Tax Slim Polish` (`5dec9b2` before this patch).
- Required git analysis was performed before editing:
  - `git status --short`: two pre-existing untracked Godot `.uid` files under `assets/video_test/theora_safe/`; pre-existing untracked Godot .uid files ignored.
  - Recent log confirmed `5dec9b2 v0.70-15`, `502f1eb v0.70-14a`, `ab91b34 v0.70-14 Left Panel Anchor`, and `e53a9fb v0.70-14 Battle Entry Camera Handoff`.
  - HEAD changed files were `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and six agent docs for the header/tax slim patch.
- Runtime/scene files touched: `WorldMap_Test.tscn` and `scripts/worldmap_test.gd`.
- Implementation:
  - Reduced only the left panel X baseline from `WORLD_UI_LEFT_MARGIN = 18.0` to `10.0`; the panel remains `320 x 570` at top `10`.
  - Scene `LeftWorldStatusPanel` offsets now use left `10`, right `330`; right-side panels were not moved.
  - Chancellor card unassigned state shows `미임명` and `효과: 없음` / `정책: 보정 없음` without repeated unassigned copy.
  - Assigned state shows the name once in `ChancellorNameLabel`, keeps primary/secondary aptitude lines, and removes `재상 임명: 이름`.
  - `_get_chancellor_effect_text()` now returns only effect tags, so the effect line no longer repeats the chancellor name.
  - Policy description line no longer repeats the policy name already visible in the dropdown.
  - Chancellor portrait frame is now `56 x 64`, clips content, and the runtime `TextureRect` uses aspect-covered display.
- Preserved scope: no `scripts/battle_web_import_test.gd`, `project.godot`, city data, city click, battle entry, camera handoff, domestic/trade/relation formulas, chancellor effect/policy calculations, tax calculations, save/load structure, BattleContext, battle scenes, assets, warehouse polish, or right/city-detail panel content changes.
- Verification: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, and docs marker check passed.
- Manual F6 QA should confirm left margin feel, chancellor unassigned/assigned copy, portrait crop, dropdown behavior, and no warehouse/right-panel drift.
- Next candidate work:
  1. `v0.70-17 WorldMap Left Panel Resource Warehouse Polish`
  2. `v0.70-18 WorldMap City Detail Panel Right Side Polish`
  3. `v0.70-19 WorldMap Battle Entry Camera Zoom Handoff`
  4. `v0.70-20 WorldMap Left Panel Save Button Polish`

## v0.70-15 WorldMap Left Panel Header & Tax Slim Polish Handoff
- Baseline: `v0.70-14a WorldMap Panel Top Margin Baseline Polish` (`502f1eb` before this patch).
- Required git analysis was performed before editing:
  - `git status --short`: two pre-existing untracked Godot `.uid` files under `assets/video_test/theora_safe/`; pre-existing untracked Godot .uid files ignored.
  - Recent log confirmed `502f1eb v0.70-14a`, `ab91b34 v0.70-14 Left Panel Anchor`, `e53a9fb v0.70-14 Battle Entry Camera Handoff`, and `8991b9b v0.70-13d`.
  - HEAD changed files were `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and six agent docs for the common top-margin baseline.
- Runtime/scene files touched: `WorldMap_Test.tscn` and `scripts/worldmap_test.gd`.
- Implementation:
  - Reduced the shared fixed-panel top baseline from `WORLD_UI_TOP_MARGIN = 16.0` to `10.0`; scene offsets for `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` match that baseline while preserving X/width/height.
  - Added slim setup helpers for the left header/tax card.
  - Left header now visually shows only the runtime calendar/turn line such as `154년 봄 1턴`.
  - `EyebrowLabel`, `TurnLabel`, and `NationLabel` remain in the scene but are hidden; this preserves existing node paths.
  - Kept national loyalty label/bar and tax label/slider; hid the tax duplicate bar, tax preview label, and public-order duplicate bar.
- Camera independence: affected panels remain `WorldMapUI` CanvasLayer children and are still locked by the fixed-panel top-margin runtime guard.
- Preserved scope: no `scripts/battle_web_import_test.gd`, `project.godot`, city data, city click, battle entry, domestic/trade/relation formulas, chancellor formulas, tax calculations, save/load structure, BattleContext, battle scenes, assets, or right/city-detail panel content changes.
- Verification: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, and docs marker check passed.
- Manual F6 QA should confirm one-line left header, removed preview/duplicate bars, tax slider stability, top baseline alignment, and unchanged pan/zoom independence.
- Next candidate work:
  1. `v0.70-16 WorldMap Left Panel Chancellor Card Polish`
  2. `v0.70-17 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-18 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-19 WorldMap Battle Entry Camera Zoom Handoff`

## v0.70-14a WorldMap Panel Top Margin Baseline Polish Handoff
- Baseline: `v0.70-14 WorldMap Left Panel Anchor & World Turn Lock` (`ab91b34` before this patch).
- Required git analysis was performed before editing:
  - `git status --short`: two pre-existing untracked Godot `.ogv.uid` files under `assets/video_test/theora_safe/`.
  - Recent log confirmed `ab91b34 v0.70-14 WorldMap Left Panel Anchor & World Turn Lock`, `e53a9fb v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`, and `8991b9b v0.70-13d`.
  - HEAD changed files were `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and six agent docs for the left-panel anchor patch.
- Runtime/scene files touched: `WorldMap_Test.tscn` and `scripts/worldmap_test.gd`.
- Panel position findings:
  - `LeftWorldStatusPanel` was top `56`.
  - `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` were top `96`.
  - The retired `TitleLabel` / `SamWar HUD MVP` was top `18` and would overlap after raising the left panel.
- Implementation:
  - Added `WORLD_UI_TOP_MARGIN = 16.0` and `WORLD_UI_LEFT_MARGIN = 18.0`.
  - Moved `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` to top `16` in the scene while preserving their current X, width, and height.
  - Added `_lock_worldmap_fixed_panel_top_margin()` and `_lock_screen_panel_top_margin()` so the same top baseline is reapplied at runtime.
  - Hid `WorldMapUI/TitleLabel` in the scene and in `_hide_retired_top_worldmap_hud()`; the node remains available for future debug use.
- Camera independence: all affected panels remain under `WorldMapUI` CanvasLayer and are not moved under the world/camera node tree.
- Preserved scope: no `scripts/battle_web_import_test.gd`, `project.godot`, city data, city click, battle entry, domestic/trade/relation formulas, BattleContext, battle scenes, assets, or panel content changes.
- Manual F6 QA should confirm top baseline alignment, no debug label overlap, panel independence during pan/zoom/drag, and unchanged left/right panel content.
- Next candidate work:
  1. `v0.70-15 WorldMap Left Panel Visual Hierarchy Polish`
  2. `v0.70-16 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-17 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-18 WorldMap Battle Entry Camera Zoom Handoff`

## v0.70-14 WorldMap Left Panel Anchor & World Turn Lock Handoff
- Baseline requested: `v0.70-13d Battle Movement Facing Direction Polish` (`8991b9b51f91aead893df51f2ee07e1b532bed34`). Actual pre-edit HEAD was `e53a9fb v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`; this previous local commit was preserved.
- Required git analysis was performed before editing:
  - `git status --short`: two pre-existing untracked Godot `.ogv.uid` files under `assets/video_test/theora_safe/`.
  - Recent log showed `e53a9fb`, `8991b9b`, `0c91744`, `f56903d`, and prior battle cinematic/result-video commits.
  - HEAD changed files: `scripts/worldmap_test.gd` plus six agent docs for the camera handoff patch.
- Runtime/scene files touched: `WorldMap_Test.tscn` and `scripts/worldmap_test.gd`.
- Left panel structure:
  - `WorldMap_Test.tscn` has `WorldMapUI` as a `CanvasLayer`.
  - `LeftWorldStatusPanel` is a direct `PanelContainer` child of `WorldMapUI`, with `MarginContainer/Content` as its `VBoxContainer`.
  - World Turn labels are the first content children: `EyebrowLabel`, `TurnLabel`, `CalendarLabel`, `NationLabel`.
- Implementation:
  - Scene now explicitly anchors `LeftWorldStatusPanel` top-left and uses `(18, 56)` / `320 x 570`.
  - Added `WorldTurnSeparator` after `NationLabel`.
  - `_lock_left_world_status_panel_anchor()` reapplies top-left anchor/position/size/min-size at runtime.
  - `_lock_world_turn_header_order()` keeps the World Turn labels and separator as the first content block.
  - `_setup_independent_hud_panel_drag()` no longer registers the left panel as draggable, while right-side panel drag behavior is unchanged.
- Preserved scope: no `scripts/battle_web_import_test.gd`, `project.godot`, combat logic, BattleContext, city data, city click, battle entry, domestic/trade/relation formulas, right panel redesign, or assets were changed.
- Manual F6 QA should confirm fixed top-left panel, World Turn header feel, no movement under pan/zoom/drag, no lost turn/save/load/reset/chancellor/warehouse controls, and no right panel regression.
- Next candidate work:
  1. `v0.70-15 WorldMap Left Panel Visual Hierarchy Polish`
  2. `v0.70-16 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-17 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-18 WorldMap Battle Entry Camera Zoom Handoff`

## v0.70-14 WorldMap Battle Entry Camera Zoom Handoff Handoff
- Baseline: `v0.70-13d Battle Movement Facing Direction Polish` (`8991b9b51f91aead893df51f2ee07e1b532bed34` before this patch).
- Required git analysis was performed before editing:
  - `git status --short`: two pre-existing untracked Godot `.ogv.uid` files under `assets/video_test/theora_safe/`.
  - Recent log confirmed `8991b9b v0.70-13d`, `0c91744 v0.70-13c`, `f56903d v0.70-13b`, and prior battle cinematic/result-video commits.
  - HEAD changed files: `scripts/battle_web_import_test.gd` plus five agent docs for v0.70-13d movement-facing polish.
- Runtime code touched only `scripts/worldmap_test.gd`.
- WorldMap battle entry flow:
  - Player attack: target city attack action -> deployment panel -> `_confirm_player_attack_deployment()` -> existing context build and troop/supply pre-decrement -> `_handoff_battle_context_to_battle_scene()`.
  - Enemy invasion defense: pending invasion defense panel -> defense deployment -> `_confirm_defense_deployment()` -> existing context build and attacker/defender troop pre-decrement -> same handoff.
  - Final transition remains `Engine.set_meta("samwar_worldmap_battle_context", context)` plus `change_scene_to_file("res://Battle_Fullscreen_Test.tscn")`, now isolated in `_change_scene_to_battle_with_context()`.
- Camera handoff implementation:
  - `_get_worldmap_city_visual_position()` uses scene-authored city marker global positions first.
  - `_build_worldmap_battle_entry_focus()` focuses between source and target, weighted toward target.
  - `_start_worldmap_battle_entry_camera_handoff()` tweens `WorldMapCamera` position and zoom, clamps focus to the existing world rect, then calls the preserved transition callable.
  - `_complete_worldmap_battle_entry_camera_handoff()` is shared by natural finish and skip.
  - `_skip_worldmap_battle_entry_camera_handoff()` supports click/Space/Enter/Esc while the handoff guard is active.
- Guard/fallback:
  - `_worldmap_battle_entry_handoff_in_progress` blocks duplicate attack start, defense choice, deployment confirmation, final handoff, keyboard pan, drag pan, and wheel zoom while active.
  - Missing camera, focus, or city coordinates fall back immediately to the existing transition. No default city ids or new BattleContext keys are generated.
- Preserved scope: no changes to `scripts/battle_web_import_test.gd`, scenes, assets, `project.godot`, combat calculations, battle intro/result video, BattleContext contract keys, WorldMap ownership/troop/hero-state application, domestic/trade/relationship systems, or result return flow.
- Manual F6 QA should confirm player attack and enemy invasion defense handoff feel, source/target focus, skip behavior, repeated-click guard, battle scene load, and existing v0.70-13 battle intro.
- Next candidate work:
  1. `v0.70-15 WorldMap Battle Entry Camera Handoff Timing Polish`
  2. `v0.70-16 WorldMap City Click UX Polish`
  3. `v0.70-17 WorldMap Domestic UX Detail Polish`

## v0.70-13d Battle Movement Facing Direction Polish Handoff
- Baseline requested: `v0.70-13b Battle Cinematic Lifecycle Guard Audit` (`f56903d5c265e7443e68387e01886d28cda8cf5a`). Actual pre-edit HEAD was `0c91744 v0.70-13c Battle WorldMap Return Contract Prep`, a docs-only contract audit on top of that baseline.
- Required git analysis was performed before editing:
  - `git status --short`: clean.
  - Recent log showed `0c91744` on top of `f56903d`, `6f46bf1`, `493c8e8`, and result-video commits.
  - HEAD changed only agent docs for v0.70-13c; the target battle movement code still came from the v0.70-13b code baseline.
- Runtime code touched only `scripts/battle_web_import_test.gd`.
- Root cause: movement tween loops used path offsets correctly but did not update `unit_state.facing` per segment, and ally movement finish immediately called `_refresh_ally_facing_toward_enemy_if_not_manual()`, which could erase the last movement-facing visual before direction selection.
- Implementation:
  - Added `_get_horizontal_facing_from_step()` and `_apply_unit_movement_facing()`.
  - Inserted a `tween_callback()` before each ally and enemy segment tween.
  - Horizontal segments update `FACING_RIGHT` / `FACING_LEFT`; vertical-only segments keep the current facing.
  - The helper reapplies existing facing visuals and reapplies the current movement offset so portrait placement and token flip stay synchronized without snapping the moving group.
  - Ally move finish now calls `_apply_unit_facing_visuals()` instead of auto-facing toward the enemy.
- Preserved scope: no pathfinding, move range, move timing, action/turn flow, attack/damage/result judgment, cutin, archer volley, gunner FX, BattleContext, WorldMap, scene, asset, result video, or battle intro lifecycle changes.
- Manual F6 QA should confirm right move, left move, vertical-only move, vertical-then-left, vertical-then-right, lower vertical-then-horizontal turns, final direction selection, and token/portrait alignment.
- Next candidate work:
  1. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  2. `v0.70-15 WorldMap City Click UX Polish`
  3. `v0.70-16 WorldMap Domestic UX Detail Polish`

## v0.70-13c Battle WorldMap Return Contract Prep Handoff
- Baseline: `v0.70-13b Battle Cinematic Lifecycle Guard Audit` (`f56903d5c265e7443e68387e01886d28cda8cf5a` before this patch).
- Required git analysis was performed before editing:
  - `git status --short`: clean.
  - Recent log confirmed HEAD `f56903d` followed `6f46bf1`, `493c8e8`, `76e0421`, and `d2dbefa`.
  - HEAD changed files: `scripts/battle_web_import_test.gd` plus five agent docs.
  - HEAD core script delta was cinematic lifecycle guard only; no WorldMap script, scene, `project.godot`, combat formula, or battle-result application code changed in that commit.
- Runtime code was not modified in this patch.
- WorldMap -> Battle flow:
  - Player attack starts from target-city attack UI, resolves a player-owned adjacent source city, opens deployment, builds context in `_build_player_attack_battle_context()`, and hands it off through `_handoff_battle_context_to_battle_scene()`.
  - Enemy invasion defense starts from `_create_pending_invasion_event_mvp()`, opens manual/auto defense deployment, builds context in `_build_battle_context_from_pending_invasion()`, and uses the same handoff.
  - Handoff key/path: `samwar_worldmap_battle_context` and `res://Battle_Fullscreen_Test.tscn`.
- Battle internal flow:
  - `_read_worldmap_battle_context_handoff()` consumes/removes `samwar_worldmap_battle_context`.
  - `_setup_worldmap_context_battle_roster()` maps attacker/defender rosters into battle slots.
  - `_get_battle_result_state()` currently produces only `victory`, `defeat`, or empty string.
  - Result video/toast flow remains before the existing WorldMap return button refresh.
- Battle -> WorldMap flow:
  - `_return_to_worldmap_with_result()` builds `_build_worldmap_battle_result_payload()`, writes `samwar_worldmap_battle_result`, and changes to `res://WorldMap_Test.tscn`.
  - `_consume_worldmap_battle_result_if_any()` removes the meta once and dispatches through `_apply_returned_battle_result_mvp()`.
  - Existing result application functions already mutate runtime city/troop/hero state; v0.70-13c only documents that contract and does not change behavior.
- Existing contract keys: `source`, `type`, `mode`, `attacker_city_id`, `defender_city_id`, `attacker_owner`, `defender_owner`, `attacker_hero_ids`, `defender_hero_ids`, `attacker_heroes`, `defender_heroes`, `attacker_troop_allocation`, `defender_troop_allocation`, `attacker_total_allocated_troops`, `defender_total_allocated_troops`, `attacker_source_city_id`, `defender_source_city_id`, side-specific source troop before/after keys, `result`, `winner`, `player_troop_outcome`, and `enemy_troop_outcome`.
- Missing or non-literal keys: `battle_mode`, `battle_type`, generic `source_city_id`, generic `target_city_id`, explicit faction-id keys, generic deployed/assigned troop keys, generic source-city remaining troop key, generic target garrison key, `loser_side`, captured hero list, payload-level `worldmap_return_scene`, structured `return_context`, `pending_worldmap_result`, and explicit `result_applied`.
- v0.70-14 should use `_city_markers_by_id` and `world_map_camera` for camera prep, then preserve `_handoff_battle_context_to_battle_scene()` as the final transition/meta boundary.
- Next candidate work:
  1. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  2. `v0.70-15 WorldMap City Click UX Polish`
  3. `v0.70-16 WorldMap Domestic UX Detail Polish`

## v0.70-13b Battle Cinematic Lifecycle Guard Audit Handoff
- Baseline: `v0.70-13a Battle Intro Wide Hold Timing Polish Stable` (`6f46bf1` before this patch).
- Required git analysis was performed before editing:
  - `git status --short`: clean.
  - Recent log: `6f46bf1` intro timing polish, `493c8e8` intro camera zoom patch, `76e0421` result panel size polish, `d2dbefa` result video before toasts.
  - HEAD changed files: agent docs plus `scripts/battle_web_import_test.gd`.
  - HEAD script delta only changed `BATTLE_INTRO_WIDE_HOLD_SEC` and `BATTLE_INTRO_ZOOM_SEC`.
- Runtime code touched only `scripts/battle_web_import_test.gd`.
- Battle intro guard notes:
  - `battle_intro_camera_has_started` prevents duplicate intro starts in one reset/battle lifecycle.
  - `_finish_battle_intro_camera_zoom()` and `_skip_battle_intro_camera_zoom()` now route through `_complete_battle_intro_camera_zoom()`.
  - The shared completion path kills the tween when needed, restores gameplay camera position/zoom, restores `BattleUI`, clears gameplay-camera-state capture, and ignores repeated completion/skip calls.
- Result video guard notes:
  - `_hide_battle_result_video_overlay()` now explicitly clears/hides the video stream/player and result backdrop.
  - Normal video completion preserves the completion guard while it queues the existing toast; external hide/reset paths clear the guard for the next battle.
  - `_play_battle_result_video_before_toast()` treats same-state repeated calls while a video is pending as already handled, avoiding duplicate toast fallback.
- Preserved scope: no combat formula, attack/damage/victory judgment, unique skill cutin, archer volley, gunner FX, BattleContext, WorldMap city/domestic/trade/relationship, scene, asset, or project setting changes.
- Verification in this session passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. Manual F6 QA remains useful for visible timing and result video playback.
- Next candidate work:
  1. `v0.70-13c Battle WorldMap Return Contract Prep`
  2. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  3. `v0.70-15 WorldMap Domestic UX Detail Polish`

## v0.70-12 Battle Result Video Before Victory/Defeat Toast Handoff
- Current patch is battle result presentation only.
- Result source MP4s:
  1. `assets/video_source_test/result_dry_run/victory_result_source_04s.mp4`
  2. `assets/video_source_test/result_dry_run/defeat_result_source_04s.mp4`
- Generated q8 result OGVs:
  1. `res://assets/ui/result/videos/victory_result_theora_q8_1920x.ogv`
  2. `res://assets/ui/result/videos/defeat_result_theora_q8_1920x.ogv`
- `Battle_Fullscreen_Test.tscn` contains `ResultOverlay/VideoStreamPlayer_Result`.
- `scripts/battle_web_import_test.gd` now uses `_play_battle_result_video_before_toast()` from `_try_show_battle_result_toast_if_needed()`.
- Existing victory/defeat toast display is preserved through `_show_battle_result_toast_after_video()` and happens only after video completion or fallback.
- Result video load failure falls back immediately to the existing toast; `BATTLE_RESULT_VIDEO_FALLBACK_DURATION_SEC` prevents a missing finish signal from blocking result presentation.
- Battle result judgment, WorldMap result payload/return, cutin mappings/assets, archer volley FX, and gunner shot FX were not changed.
- Next visible QA should verify victory and defeat paths independently: result video first, then existing toast, then normal WorldMap result/return behavior.

## v0.70-11 Unit Type Attack Range Baseline Handoff
- Current patch is battle test data/baseline only in `scripts/battle_web_import_test.gd`.
- Added `_get_default_attack_range_for_unit_type()` and `_get_default_attack_range_for_visual_key()`.
- Test battle normal/basic attack range baseline:
  1. Infantry: `1`.
  2. Cavalry: `1`.
  3. Archer: `3`.
  4. Gunner: `4`.
- Jeong Do Jeon, Eulji Mundeok, and Zhuge Liang now use the gunner baseline of `4`, so gunner normal attack range is no longer shorter than archer range in the test battle.
- Yi Sunsin, Kim Yu-sin, and Liu Bei remain archer baseline `3`; melee infantry/cavalry remain `1`.
- Unique skill ranges, strategy ranges, move ranges, archer volley FX, gunner shot FX, cutin assets/mappings, damage/hit/troop/turn logic, and WorldMap scripts were not changed.
- WorldMap context source data was inspected but left untouched; this patch does not rewrite explicit WorldMap hero attack ranges.
- Next visible QA should check normal attack range overlays by unit type and confirm special skill/strategy ranges still behave as before.

## v0.70-10 Gunner Muzzle Flash + Tracer Impact Visual Handoff
- Current patch is battle visual FX only in `scripts/battle_web_import_test.gd`.
- Gunner normal/basic attacks now call `_play_gunner_shot_effect()` from the ally and enemy basic-attack animation paths only.
- `_is_gunner_unit()` resolves gunner eligibility through normalized `unit_type`, visual key inference, and hero default visual key fallback.
- Runtime gunner FX uses `Polygon2D`, `Line2D`, and small `Node2D` primitive spark/smoke nodes; no PNG/SVG/sprite gunner asset was created.
- Added constants including `GUNNER_MUZZLE_FLASH_DURATION`, `GUNNER_TRACER_DURATION`, `GUNNER_IMPACT_POP_BEGIN`, and `GUNNER_SMOKE_LINGER_DURATION`.
- Added `_spawn_gunner_muzzle_flash()`, `_spawn_gunner_tracer()`, and `_spawn_gunner_impact_pop()`.
- Current gunner units expected to trigger the effect are `jeong_dojeon`, `eulji_mundeok`, and `zhuge_liang`.
- The effect is intentionally much faster than archer arrows: short muzzle flash, near-instant tracer fade, compact target spark, and small non-blocking smoke fade.
- Unique/special skills, strategy, cutin playback, q8 Theora mappings/assets, damage/hit/troop/turn logic, and WorldMap flow were not changed.
- Next visible QA should check gunner basic attacks for a sharp "탕" feel and spot-check archer/non-gunner basic attacks plus unique skills for absence of gunner FX.

## v0.70-9c Archer Curved Volley + Visual Completion Timing Guard Handoff
- Current patch is battle visual FX tuning and animation sequencing only in `scripts/battle_web_import_test.gd`.
- Archer normal/basic attacks now call `_play_arrow_projectile_effect()` from the ally and enemy basic-attack animation paths only.
- `_is_archer_unit()` resolves archer eligibility through normalized `unit_type`, visual key inference, and hero default visual key fallback.
- Runtime arrows use `Line2D`; no PNG/SVG/sprite arrow asset was created.
- Added constants including `ARROW_VOLLEY_VISUAL_COUNT` and `ARROW_IMPACT_POP_BEGIN`.
- Added `_spawn_arrow_projectile()` for staggered source-to-target travel and `_spawn_arrow_impact_pin()` for short pinned impact feedback.
- Readability tuning changed volley density from 5 to 9 arrows, widened launch stagger to `0.05`-`0.12` seconds, and slowed travel to `0.34`-`0.50` seconds.
- Projectile line length/contrast were slightly increased while keeping arrows small enough not to cover units.
- Projectiles now use `_get_arrow_curve_midpoint()` with `ARROW_CURVE_OFFSET_MIN` / `ARROW_CURVE_OFFSET_MAX` so the flight reads as a subtle arrow arc rather than a straight tracer.
- Archer basic attacks now add an archer-only sequencing wait using `_get_arrow_volley_blocking_duration()` and `_get_arrow_volley_completion_extra_wait()`.
- The wait covers latest launch delay + max travel + `ARROW_VOLLEY_COMPLETION_PAD_SEC`, but does not wait for the full pin linger/fade.
- Current archer units expected to trigger the volley are `yi_sunsin`, `gim_yusin`, and `liu_bei`.
- Unique/special skills, strategy, cutin playback, q8 Theora mappings/assets, damage/hit/troop/turn logic, and WorldMap flow were not changed.
- Next visible QA should check archer basic attacks for a heavier, slower, subtly curved arrow stream and confirm the next action does not begin before arrow impact; also spot-check non-archer basic attacks plus unique skills for absence of the arrow volley.

## v0.70-8b Yi Sunsin + Eulji Mundeok Mirrored Cutin Layout Handoff
- Current patch is layout-direction only in `scripts/battle_web_import_test.gd`.
- Yi Sunsin config now sets `layout_mirror: true`, places the oversized portrait from the right side, and moves the Hakikjin title image to the left.
- Eulji Mundeok config now sets `layout_mirror: true`, places the portrait from the right side, and moves the Salsu Daechop title image to the left.
- `_show_specialty_skill_video_cutin()` mirrors portrait enter/settle/exit offsets and title enter offset only when `layout_mirror` is true.
- `_layout_specialty_skill_cutin()` keeps the old left-overflow path by default and uses `hero_right_overflow` only for mirrored configs.
- Kwon Yul, Jeong Do Jeon, and Kim Yu-sin remain on the existing hero-left/title-right config values.
- No video path mapping, fallback chain, special-skill trigger, production asset, or WorldMap logic was changed.
- Next visible QA should check Yi Sunsin and Eulji Mundeok right-hero/left-title composition, then spot-check Kwon Yul / Jeong Do Jeon / Kim Yu-sin for unchanged layout.

## v0.70-8 Kim Yu-sin + Eulji Mundeok Special-Skill Cutin Handoff
- Kim Yu-sin and Eulji Mundeok are now integrated into the existing specialty unique-skill cutin system in `scripts/battle_web_import_test.gd`.
- Scope is explicitly unique/special-skill activation only; no reinforcement-arrival cutin hook was added.
- New source MP4s:
  1. `assets/video_source_test/production_dry_run/kim_yu_sin_cutin_source_02s.mp4`
  2. `assets/video_source_test/production_dry_run/eulji_mundeok_cutin_source_02s.mp4`
- Both sources ffprobe as h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- New q8 Theora runtime assets:
  1. `res://assets/ui/cutin/videos/kim_yu_sin_cutin_bg_theora_q8_1920x.ogv`
  2. `res://assets/ui/cutin/videos/eulji_mundeok_cutin_bg_theora_q8_1920x.ogv`
- Output ffprobe:
  1. Kim Yu-sin: Theora, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `6365944` bytes.
  2. Eulji Mundeok: Theora, 1920x1080, yuv420p, `30/1`, stream duration `N/A`, format duration `2.005333`, size `8318109` bytes.
- Portrait/title paths:
  1. `res://assets/ui/cutin/portraits/kim_yu_sin_cutin.png`
  2. `res://assets/ui/cutin/titles/kim_yu_sin_samguktongil_title.png`
  3. `res://assets/ui/cutin/portraits/eulji_mundeok_cutin.png`
  4. `res://assets/ui/cutin/titles/eulji_mundeok_salsudaecheop_title.png`
- `SPECIALTY_SKILL_CUTIN_VIDEO_PATHS` and `SPECIALTY_SKILL_CUTIN_CONFIGS` now include `gim_yusin` and `eulji_mundeok`.
- No older Kim Yu-sin / Eulji Mundeok fallback video files were present, so their q8 OGVs are currently primary-only candidates.
- Existing Yi Sunsin, Kwon Yul, and Jeong Do Jeon q8 mappings/configs/fallbacks were preserved.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and ResourceLoader checks for all new cutin resources plus existing Yi/Kwon/Jeong q8 OGVs.
- Next visible QA should trigger Kim Yu-sin and Eulji Mundeok unique skills, verify no reinforcement-arrival trigger, confirm non-black playback/title/portrait display, and confirm battle-flow return.

## v0.70-7b Kim Yu-sin Tactical Cell Clickability Handoff
- Current patch is battle tactical UX/input only in `scripts/battle_web_import_test.gd`.
- Root cause diagnosis: with Kim Yu-sin selected, a highlighted empty move cell near/below Kwon Yul could fall inside Kwon Yul's ally click area. Ally selection ran before valid grid movement, so the click selected Kwon Yul instead of moving Kim Yu-sin.
- Ally-turn input now attempts `_try_handle_valid_move_cell_click()` before `_get_clicked_ally_unit_at_position()`.
- This preserves normal ally selection because occupied ally cells are still rejected by `is_valid_move_target()` before selection runs.
- Floating command panel scoring now has a stronger selected-unit distance penalty and a much larger corner fallback penalty, reducing lower-left/lower-right detached panel placement.
- Ally click hit testing now mirrors the enemy-side approach by choosing the closest hit candidate when ally click areas overlap.
- Disabled/non-pickable click areas are ignored by manual unit click hit testing, which helps avoid hidden/reserve visual roots consuming battlefield clicks.
- Verification completed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- No cutin OGV assets, title PNGs, q8 mappings, production video files, or WorldMap logic were modified.
- Next visible QA should check Kim Yu-sin panel placement, the Kwon Yul-adjacent highlighted move cell, command buttons, and battle-flow stability.

## v0.70-6b Jeong Do Jeon q8 Source Replacement Handoff
- Current task starts after `5c9b8cc 정도전 고유특기 영상 교체`, where the Jeong Do Jeon source MP4 was replaced.
- Verified source path:
  `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4`
- Source ffprobe: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Regenerated runtime q8 Theora path:
  `assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv`
- Output ffprobe: Theora, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `7101765` bytes.
- Jeong Do Jeon mapping remains unchanged in `scripts/battle_web_import_test.gd`: the q8 OGV remains first, followed by existing WebM/MP4 fallbacks.
- Jeong Do Jeon title remains `res://assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png`.
- Yi Sunsin and Kwon Yul q8 mappings/assets were not touched.
- The source-replacement commit had tracked `assets/video_test/theora_safe/` frame-capture `.import` junk; this pass removes only those tracked junk files and preserves the real q7/q8 test OGVs plus `README.md`.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks showing Jeong Do Jeon q8 OGV loads as `VideoStreamTheora` and title PNG loads as `CompressedTexture2D`.
- Next visible QA should confirm the new Jeong Do Jeon video appears in battle, no black screen occurs, the 개혁령 title appears, and battle flow returns.

## v0.70-7a Tactical Panel Distance + Move Cell Clickability Handoff
- Current task refines the v0.70-7 floating command panel overlap fix in `scripts/battle_web_import_test.gd`.
- Command panel placement now keeps the selected unit as the spatial anchor:
  - overlap against visible tactical cells is still the primary blocker check
  - distance from the selected unit is now part of the score
  - viewport-corner fallback candidates carry a large penalty
  - near diagonal candidates were added before fallback corners
- This should prevent the Kim Yu-sin case where the panel avoided cells by jumping too far to the lower-right and feeling detached from the action context.
- Move-cell clickability diagnosis: the highlighted cell below/near Xiahou Dun was likely a valid move target whose click was intercepted by the enemy unit click area because enemy hit testing ran before grid move-target handling.
- Ally-turn input now tries a valid move-cell click before enemy hit testing. Occupied/enemy cells remain invalid move targets, so normal enemy attack selection still works when clicking actual enemy targets.
- Existing target-selection panel hiding from v0.70-7 remains intact.
- No cutin OGV assets, title PNGs, q8 mappings, or WorldMap logic were modified.
- Verification completed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Next visible QA should check Kim Yu-sin panel attachment, the Xiahou Dun-adjacent highlighted move cell, command button behavior, and battle-flow stability.

## v0.70-7 Tactical Command Panel Grid Overlap Handoff
- Current task fixed floating command panel click blocking in `scripts/battle_web_import_test.gd`.
- `FloatingAllyCommandPanel` now places itself with candidate scoring instead of a single fixed offset:
  - selected unit right
  - selected unit left
  - above
  - below
  - safe viewport corners
- The scoring compares the panel rect against visible tactical overlay cell rects and chooses the least-overlapping in-viewport position.
- Explicit target-selection modes hide the panel:
  - `PHASE_ATTACK_SELECT`
  - `PHASE_STRATEGY_SELECT`
  - `PHASE_UNIQUE_SKILL_TARGET_SELECT`
- The hide helper also sets the panel mouse filter to `IGNORE`; display refresh restores normal `STOP` filtering before showing the panel again.
- Attack/unique/strategy command button behavior is otherwise unchanged, and right-click cancel returns to ally command selection with the panel request restored.
- No cutin OGV assets, title PNGs, q8 mappings, or WorldMap logic were modified.
- Verification completed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Next visible QA should check unit selection near reachable hexes, panel avoidance, target-mode hiding, clicking cells that were previously covered, and normal command button behavior.

## v0.70-6a Kwon Yul + Jeong Do Jeon q8 Theora Dry Run Handoff
- New production dry-run OGVs:
  1. `assets/ui/cutin/videos/kwon_yul_cutin_bg_theora_q8_1920x.ogv`
  2. `assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv`
- Kwon Yul OGV ffprobe: `codec_name=theora`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.000000`, size `9054001` bytes.
- Jeong Do Jeon OGV ffprobe: `codec_name=theora`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.000000`, size `4472743` bytes.
- Runtime mapping first candidates:
  1. Kwon Yul: `res://assets/ui/cutin/videos/kwon_yul_cutin_bg_theora_q8_1920x.ogv`
  2. Jeong Do Jeon: `res://assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv`
- Existing Kwon Yul / Jeong Do Jeon WebM fallbacks remain after q8, and existing MP4 fallback paths are available after those.
- Yi Sunsin q8 mapping, fallback chain, timing, title animation, and video asset were not changed.
- Title PNGs are wired through per-hero config:
  1. Kwon Yul: `res://assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png`
  2. Jeong Do Jeon: `res://assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png`
- `SPECIALTY_SKILL_CUTIN_CONFIGS` now carries per-hero portrait/title layout values so Kwon Yul and Jeong Do Jeon can be tuned independently from Yi Sunsin.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for q8 OGVs/title PNGs.
- Next visible QA should check Kwon Yul and Jeong Do Jeon q8 playback, title appearance, no black-screen/color failure, battle-flow return, and whether their initial independent layout defaults need hero-specific polish.

## v0.70-6 Kwon Yul + Jeong Do Jeon Cutin Asset Intake Handoff
- Latest inspected intake commit: `c7173fb 컷인 관련`.
- Ready source MP4s:
  1. `assets/video_source_test/production_dry_run/kwon_yul_cutin_source_02s.mp4`
  2. `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4`
- Both source MP4s ffprobe as h264, 1920x1080, yuv420p, `30000/1001` fps, duration `2.002000`.
- Ready title PNGs:
  1. `assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png`
  2. `assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png`
- Both title PNGs are `1133x639` RGBA/transparent and now have matching Godot `.import` metadata.
- Direct Godot ResourceLoader verification passes for both title PNGs as `CompressedTexture2D`.
- The source MP4s are source/ffmpeg inputs, not Godot runtime resources; verify them with ffprobe and encode separate Theora outputs before mapping.
- Tracked Theora safe frame-capture `.import` junk has been removed; the actual q7/q8 `.ogv` test outputs and `README.md` remain tracked.
- No production mapping was connected for Kwon Yul or Jeong Do Jeon in this intake pass.
- Yi Sunsin q8 Theora baseline and fallback chain were not changed.
- Next recommended task: encode and connect Kwon Yul q8 Theora dry-run first, then repeat for Jeong Do Jeon, preserving existing production files and adding fallbacks one hero at a time.

## v0.70-5e Yi Sun-sin Final Exit Snap Handoff
- Current Yi Sunsin cutin keeps the v0.70-5d Hakikjin title behavior unchanged: readable hold, large burst to `2.25`, fade-out, and upward drift.
- Hakikjin still exits before Yi Sunsin, preserving the current dynamic title-first disappearance structure.
- Final tail timing is now much shorter: `SPECIALTY_SKILL_CUTIN_EXIT_START := 1.18`, `SPECIALTY_SKILL_CUTIN_EXIT_DURATION := 0.14`, and `SPECIALTY_SKILL_CUTIN_TOTAL_DURATION := 1.38`.
- The intended timing is Hakikjin burst completes around `1.00s`, Yi Sunsin lingers roughly `0.18s`, then the whole cutin snaps out quickly.
- Final Yi Sunsin drift is a subtle fast left/down motion to `hero_base_position + Vector2(-86.0, 14.0)` during the `0.14s` exit fade.
- q8 Theora remains the first Yi Sunsin video candidate:
  `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`.
- Existing fallbacks remain preserved after q8: 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Kwon Yul / Jeong Do Jeon mappings were not changed.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for Hakikjin PNG and q8 OGV.
- Next visible QA should check only: Hakikjin still exits first, Yi Sunsin tail is no longer too long, the final disappearance feels sharp, and battle rhythm resumes better.

## v0.70-5d Hakikjin Readable Hold + Large Burst Fade Handoff
- Current Yi Sunsin cutin keeps the v0.70-5c portrait scale and balance unchanged.
- Yi Sunsin portrait layout remains `viewport_size.x * 0.86`, `viewport_size.y * 1.42`, left overflow `size.x * 0.28`, and `+28px` vertical balance offset.
- Hakikjin title image still uses `res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Hakikjin title timing now includes a readable hold before burst: `SPECIALTY_SKILL_CUTIN_TEXT_READABLE_HOLD := 0.34`.
- Hakikjin burst duration is `0.34`, scales to `2.25`, fades to alpha `0.0`, and drifts upward by `22px`.
- Hakikjin still disappears before Yi Sunsin exits, preserving the dynamic logo-burst rhythm.
- q8 Theora remains the first Yi Sunsin video candidate:
  `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`.
- Existing fallbacks remain preserved after q8: 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Kwon Yul / Jeong Do Jeon mappings were not changed.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for Hakikjin PNG and q8 OGV.
- Next visible QA should check only: Hakikjin readable hold, large fade burst, Yi Sunsin positioning, overall satisfaction, and battle-flow return.

## v0.70-5c Yi Sun-sin Balance + Hakikjin Large Burst Handoff
- Current Yi Sunsin cutin keeps the large portrait scale from v0.70-5b but nudges the portrait down by `28px` for vertical balance.
- Yi Sunsin portrait layout remains `viewport_size.x * 0.86`, `viewport_size.y * 1.42`, with left overflow at `size.x * 0.28`.
- Hakikjin title image still uses `res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Hakikjin burst is now intentionally large: visible base, scale to `1.72`, then fade while expanding to `1.90` with an `18px` upward drift.
- q8 Theora remains the first Yi Sunsin video candidate:
  `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`.
- Existing fallbacks remain preserved after q8: 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Kwon Yul / Jeong Do Jeon mappings were not changed.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for Hakikjin PNG and q8 OGV.
- Next visible QA should check only: Yi Sunsin top/bottom balance, Hakikjin large burst-out, overall impact, and battle-flow return.

## v0.70-5b Yi Sun-sin Dominance + Hakikjin Burst Handoff
- Current Yi Sunsin cutin presentation has been tuned for stronger dominance and a more dynamic Hakikjin title burst.
- Yi Sunsin portrait is intentionally very large: `viewport_size.x * 0.86`, `viewport_size.y * 1.42`, with left overflow at `size.x * 0.28`.
- Hero entry starts farther off-left with `SPECIALTY_SKILL_CUTIN_HERO_ENTER_OFFSET := Vector2(-390.0, 16.0)` and keeps the whoosh/settle behavior.
- Hakikjin title image still uses `res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Hakikjin title animation now appears quickly, scales up to `1.26`, then fades out while expanding to `1.34`; it should no longer sit statically.
- q8 Theora remains the first Yi Sunsin video candidate:
  `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`.
- Existing fallbacks remain preserved after q8: 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Kwon Yul / Jeong Do Jeon mappings were not changed.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for Hakikjin PNG and q8 OGV.
- Next visible QA should check only: Yi Sunsin dominance, Hakikjin appears/expands/disappears, composition dynamism, and battle-flow return.

## v0.70-5a Yi Sun-sin Hero Scale + Skill Title Image Impact Handoff
- Current Yi Sunsin presentation now uses image-based Hakikjin title art: `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Required import metadata is present at `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png.import`.
- The old visible `이순신` name label has been removed from the cutin scene, and the old plain `학익진!` label has been replaced by `TextureRect_SkillTitle`.
- Runtime path: `scripts/battle_web_import_test.gd` loads `res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png` into the title TextureRect before playing the cutin.
- Yi Sunsin portrait layout is intentionally oversized and pushed left/center-left so it overflows the panel for stronger hero-cutin impact.
- Motion has been tuned toward a faster hero whoosh plus overshoot/settle, followed by a stronger title-image pop.
- q8 Theora playback remains first in the Yi Sunsin video candidate chain:
  `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`.
- Existing fallbacks remain preserved after q8: 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Kwon Yul / Jeong Do Jeon cutin mappings were not changed.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for the title PNG and q8 OGV.
- Next visual QA should focus only on whether the hero is large enough, `이순신` text is gone, the Hakikjin title image has enough impact, composition feels premium, and battle-flow return still works.

## v0.70-5 Yi Sun-sin Cutin Cinematic Layout Polish Handoff
- Yi Sunsin q8 Theora playback remains the stable dry-run baseline and still uses `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` first.
- Existing Yi Sunsin fallback chain remains preserved after q8: 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Presentation polish has been applied to the existing specialty cutin layer in `Battle_Fullscreen_Test.tscn` and `scripts/battle_web_import_test.gd`.
- Main visual changes: larger left/center-left Yi Sunsin foreground portrait, stronger `이순신` and `학익진!` typography, deeper dim, restrained steel-blue/sea-spray accent replacing the old yellow slash, and staggered entrance/exit animation.
- The improvement is currently applied through the shared Yi Sunsin specialty cutin presentation path; it is suitable as a reference for future Kwon Yul / Jeong Do Jeon cutins, but their mappings were not changed in this pass.
- No video assets were re-encoded and no production cutin files were deleted or overwritten.
- Verification completed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Manual visual QA remains the next decisive step. In F6/battle flow, check hero scale/presence, `학익진!` readability and impact, absence of the old tacky yellow slash, overall cinematic/naval feel, clean cutin exit, and battle-flow return.
- If the visual pass is accepted, next work can either lock this as the Yi Sunsin cinematic baseline or extend the q8 Theora/layered cutin pipeline to Kwon Yul and Jeong Do Jeon one hero at a time.

## v0.70-4a Yi Sun-sin q8 Theora Manual QA Handoff
- Latest confirmed working cutin-video baseline: `f3d53e0 Add Yi Sun-sin q8 Theora production cutin dry run`.
- Yi Sunsin q8 dry-run asset: `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`.
- Kimjak manually verified the actual Godot battle flow and confirmed the q8 Yi Sunsin cutin displays correctly.
- User QA summary: "드디어 제대로 뜸! 깔끔하게 떠^^".
- Manual visual result: clean playback, no black-screen lock, no obvious color corruption, and q8 1920x Theora quality acceptable for production dry-run.
- Current Yi Sunsin candidate chain remains q8 1920x Theora first, then 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Next work can treat Yi Sunsin q8 as the stable dry-run checkpoint and either expand the pipeline to Kwon Yul / Jeong Do Jeon or run deeper QA around cutin exit, unique-skill effect continuation, battle-flow return, and runtime performance/file-size criteria.

## v0.70-4 Production Cutin Theora Dry Run - Yi Sun-sin q8 Handoff
- The real Yi Sun-sin dry-run source is tracked at `assets/video_source_test/production_dry_run/yi_sun_sin_cutin_source_02s.mp4`.
- Source ffprobe: h264, 1920x1080, yuv420p, `30000/1001` fps, duration `2.002000`.
- New production dry-run output: `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`, with Godot sidecar `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv.uid`.
- Output ffprobe: theora, 1920x1080, yuv420p, `30/1` fps, duration `2.000000`, size `7580014` bytes.
- `scripts/battle_web_import_test.gd` now tries the q8 1920x OGV first for `yi_sunsin` only:
  1. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`
  2. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv`
  3. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm`
  4. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.ogv`
  5. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.webm`
  6. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4`
- Existing production cutin files were preserved and remain available as fallbacks. Kwon Yul and Jeong Do Jeon cutin mappings were not changed.
- Verification completed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct Godot resource verification for the new OGV as `VideoStreamTheora`.
- Codex headless did not auto-trigger the Yi Sunsin cutin. Kimjak F6/manual QA remains required for selected q8 OGV logs, visible non-black playback, color correctness, finished/exit behavior, post-cutin unique-skill effect, and normal battle-flow return.

## v0.70-3 Portable FFmpeg + Theora Safe Encode Handoff
- `v0.70-3 Portable FFmpeg Setup + Theora Safe Encode Execution` is complete.
- FFmpeg is available repo-locally at `tools/ffmpeg/bin/ffmpeg.exe`; ffprobe is at `tools/ffmpeg/bin/ffprobe.exe`.
- FFmpeg version used: `8.1.1-essentials_build-www.gyan.dev`.
- `tools/ffmpeg/` is ignored and should not be committed because the zip and binaries are large local dependencies.
- Test source: `assets/video_source_test/cutin_test_01.mp4`.
- Generated committed test outputs:
  - `assets/video_test/theora_safe/test_safe_q7_1280x.ogv` (`3426729` bytes)
  - `assets/video_test/theora_safe/test_safe_q8_1920x.ogv` (`7295937` bytes)
- Actual q7 command:
  - `.\tools\ffmpeg\bin\ffmpeg.exe -y -i "assets/video_source_test/cutin_test_01.mp4" -vf "fps=30,scale=1280:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 7 -g 60 -c:a libvorbis -q:a 4 "assets/video_test/theora_safe/test_safe_q7_1280x.ogv"`
- Actual q8 command:
  - `.\tools\ffmpeg\bin\ffmpeg.exe -y -i "assets/video_source_test/cutin_test_01.mp4" -vf "fps=30,scale=1920:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 8 -g 60 -c:a libvorbis -q:a 4 "assets/video_test/theora_safe/test_safe_q8_1920x.ogv"`
- No noaudio fallback was needed.
- ffprobe q7: Theora, 1280x720, yuv420p, 30/1 fps, duration `2.166667`; Vorbis stereo 48000Hz audio.
- ffprobe q8: Theora, 1920x1080, yuv420p, 30/1 fps, duration `2.166667`; Vorbis stereo 48000Hz audio.
- Godot verification:
  - q7 and q8 both load as `VideoStreamTheora` through `ResourceLoader`.
  - q7 and q8 both reach `is_playing=true` in `scenes/dev/video_theora_test.tscn`.
  - q7 and q8 both emitted `finished signal` during Windows display-driver movie-maker capture.
  - Captured frames were non-black and source-like in color; no rainbow corruption or obvious RGB channel swap was observed.
- Recommended safe preset: q7 1280x. It meets load/play/color requirements and is much smaller/lighter than q8.
- Next work should use the q7 preset on a production-candidate source into a separate proposed/test output first. Do not overwrite production cutin assets without explicit instruction.

## v0.70-2 Theora Safe Encoding Test Handoff
- Scope was limited to test-only video source/output, a dev test scene, and docs. Battle logic, WorldMap logic, and production cutin assets were not changed.
- Source file for the current test: `assets/video_source_test/cutin_test_01.mp4`.
- Test output folder: `assets/video_test/theora_safe/`.
- Expected output filenames:
  1. `assets/video_test/theora_safe/test_safe_q7_1280x.ogv`
  2. `assets/video_test/theora_safe/test_safe_q8_1920x.ogv`
  3. `assets/video_test/theora_safe/test_safe_q7_1280x_noaudio.ogv` only if audio encode fails and `-an` fallback is needed
- FFmpeg status: not available in PATH, and no repo-local `ffmpeg.exe` / `ffprobe.exe` was found. No `.ogv` outputs were created by Codex in this pass.
- Godot test scene: `scenes/dev/video_theora_test.tscn`.
- Test script: `scripts/video_theora_test.gd`.
- The scene uses `VideoStreamPlayer` with `expand = true`, starts loading on `_ready()`, and allows quick switching through q7/q8/noaudio candidates via the dropdown or left/right UI actions.
- Verification completed: `git diff --check`, Godot headless project load, and Godot headless load of `scenes/dev/video_theora_test.tscn`.
- Verification not completed: actual q7/q8 `.ogv` load, non-black frame playback, and color correctness. These require FFmpeg output files.
- Next agent should run the requested FFmpeg commands once FFmpeg is available, then visually test q7 and q8 in the dev scene before recommending any production replacement.

## v0.70-10A VideoStreamPlayer Debug Checkpoint Handoff
- `v0.70-10A VideoStreamPlayer Debug Checkpoint Documentation` is complete. This was documentation-only; no code, scene, or asset file was intentionally modified.
- Baseline commit before this documentation pass: `22c519f8654600229000e3f833a39867a23a769a` (`v0.70-10 VideoStreamTheora Direct Load Test`).
- Current cutin system status:
  - Yi Sunsin specialty cutin layer displays normally.
  - PNG hero portrait, hero name, and unique-skill name text display normally.
  - The centered cutin layout remains applied.
  - The 3-second timeline exits into the existing unique-skill effect flow.
  - Busy guard and PNG/text fallback remain intact.
- VideoStreamPlayer diagnostic status:
  - Earlier WebM/MP4 paths were found by `FileAccess`, but ResourceLoader did not produce a valid `VideoStream` (`load_null=true`, `is_video_stream=false`).
  - Selecting `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv` in the Godot editor FileSystem caused the Inspector to show it as `VideoStream`.
  - A local `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv.uid` sidecar was generated.
- Current diagnosis:
  - The problem is no longer primarily missing file, layout, z-index, size, or fallback flow.
  - The Theora 540p OGV appears to reach playback, but visible output is rainbow/glitch-like corruption.
  - Active hypothesis: Theora encoding/decoding compatibility issue.
- Confirmed experiment assets:
  - `assets/ui/cutin/portraits/yi_sun_sin_cutin.png`
  - `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv`
  - `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv.uid` locally generated by Godot
- Direction:
  - Continue diagnosing VideoStreamPlayer. It is foundational for intro video, specialty cutins, battle victory/defeat videos, worldmap event cutscenes, opening, and ending.
  - Treat image sequence playback as a last-resort workaround only.
- Recommended next task: `v0.70-11 Cutin Safe Theora Encoding Test`.
- Candidate command for conservative 360p Theora:
  - `ffmpeg -y -i "assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4" -t 3 -vf "scale=640:360:flags=lanczos,fps=24,format=yuv420p" -pix_fmt yuv420p -c:v libtheora -q:v 5 -g 48 -an "assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_360p_safe.ogv"`
- Candidate command for 540p q6/g64 retry:
  - `ffmpeg -y -i "assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4" -t 3 -vf "scale=960:540,fps=24,format=yuv420p" -pix_fmt yuv420p -c:v libtheora -q:v 6 -g 64 -an "assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p_q6_g64.ogv"`
- Next chat reading order:
  1. `agent/WORKFLOW_MANAGER.md`
  2. `agent/CODEX_WORKFLOW_RULES.md`
  3. `agent/GODOT_RULES.md`
  4. `agent/CURRENT_STATE.md`
  5. `agent/NEXT_TASKS.md`
  6. `agent/HANDOFF_TO_CODEX.md`
  7. `agent/CHANGELOG.md`
  8. `agent/SESSION_LOG.md`

## v0.70-10 VideoStreamTheora Direct Load Test Handoff
- `v0.70-10 VideoStreamTheora Direct Load Test` is complete for ally `yi_sunsin` only.
- Yi Sunsin video candidate priority is now:
  1. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv`
  2. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm`
  3. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.ogv`
  4. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.webm`
  5. `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4`
- Theora 540p OGV is selected first when present, and selected-candidate logs should show `_theora_540p.ogv`.
- Candidate diagnostics log `FileAccess.file_exists`, `ResourceLoader.exists`, load-null result, loaded resource class, `is VideoStream`, and a concise failure guess.
- If the Theora 540p OGV does not load as a `VideoStream` through `ResourceLoader.load()`, the code attempts `VideoStreamTheora.new()`, verifies the dynamic `file` property, sets it to the OGV path, logs the direct result, and assigns it to `VideoStreamPlayer_Cutin` when possible.
- If both ResourceLoader and direct Theora creation fail, the cutin remains PNG/text fallback and does not block the existing unique-skill effect flow.
- `VideoStreamPlayer_Cutin` is still the existing scene node. It is stopped and cleared before assignment, played from the beginning after successful stream assignment, and stopped/cleared on cutin hide.
- `CUTIN_VIDEO_DEBUG_FORCE_TOP` remains committed as `false`; set it locally to `true` only for manual visual isolation.
- The centered v0.70-6/v0.70-9 cutin layout, Yi Sunsin PNG/text fallback, busy guard, and 3-second pacing were preserved.
- No unique-skill 판정/effect/damage, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load with no GDScript warning/error output observed.
- Current asset state: Theora 540p OGV, VP8 WebM, MP4, and PNG are present; legacy `yi_sun_sin_cutin_bg.ogv` and `yi_sun_sin_cutin_bg.webm` are absent. No tracked Theora `.uid` or `.import` sidecar was observed after headless verification.
- Kimjak F6/manual QA should check console logs for selected `_theora_540p.ogv`, ResourceLoader results, direct Theora results if ResourceLoader fails, non-null stream class, `is_playing() == true`, actual video visibility, debug force-top behavior if needed, PNG/text fallback, 3-second exit, and post-cutin effect continuation.
- Next candidates:
  - `v0.70-11 VideoStreamPlayer Final Fix or Alternative Pipeline Decision`
  - `v0.70-12 Specialty Skill Cutin Visual Polish`
  - `v0.70-13 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-14 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-9 VideoStreamPlayer Cutin Debug Pass Handoff
- `v0.70-9 VideoStreamPlayer Cutin Debug Pass` is complete for ally `yi_sunsin` only.
- This is the first practical SamWar VideoStreamPlayer pipeline diagnostic pass for future intro, event cutscene, battle cutin, and result-video needs.
- `scripts/battle_web_import_test.gd` now logs cutin video candidate path, `ResourceLoader.exists`, `load()` null/class result, `VideoStream` cast result, assigned stream class, `VideoStreamPlayer_Cutin.is_playing()`, visible/modulate/self_modulate, size, position/global_position, z-index, parent state, and draw-order indexes.
- Logs are intentionally limited to cutin start before assignment, immediately after `play()`, and about `0.3s` later.
- `CUTIN_VIDEO_DEBUG_FORCE_TOP` exists and is committed as `false`. Set it locally to `true` only for visual isolation; it enlarges/raises `VideoStreamPlayer_Cutin` to check whether the video itself can render.
- `_debug_play_cutin_video_only()` is available as a manual QA helper for a 3-second VideoStreamPlayer-only playback test. It is not auto-run in normal play.
- Video candidate priority remains `yi_sun_sin_cutin_bg_vp8.webm`, `yi_sun_sin_cutin_bg.ogv`, `yi_sun_sin_cutin_bg.webm`, then `yi_sun_sin_cutin_bg.mp4`.
- Current local asset check: VP8 WebM and MP4 are present; requested OGV and snake_case non-VP8 WebM fallbacks are absent. No tracked video `.uid` or `.import` sidecar was generated.
- The scene child order already matches the intended stack: `ColorRect_Darken`, `VideoStreamPlayer_Cutin`, `TextureRect_Slash`, `TextureRect_Hero`, `Control_Text`. Runtime z-index is now made explicit in that order.
- The centered cutin banner/card layout, PNG/text fallback, busy guard, and post-cutin unique-skill effect continuation were preserved.
- No unique-skill 판정, effect, damage, buff/debuff, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load with no GDScript warning/error output observed.
- Kimjak F6/manual QA should check console logs for selected `_vp8.webm`, non-null stream class, non-zero player size, `is_playing() == true`, visible video, debug force-top behavior if the normal layer still does not show video, PNG/text fallback, and effect continuation after cutin exit.
- Next candidates:
  - `v0.70-10 Specialty Skill Cutin Visual Polish`
  - `v0.70-11 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-12 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-8 Cutin VP8 WebM Video Connection Handoff
- `v0.70-8 Cutin VP8 WebM Video Connection` is complete for ally `yi_sunsin` only.
- `scripts/battle_web_import_test.gd` now selects Yi Sunsin cutin video candidates in priority order: `yi_sun_sin_cutin_bg_vp8.webm`, `yi_sun_sin_cutin_bg.ogv`, `yi_sun_sin_cutin_bg.webm`, then `yi_sun_sin_cutin_bg.mp4`.
- The final priority use format is the FFmpeg-converted VP8 WebM 8M version at `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm`; OGV remains only as an unstable fallback.
- The selected existing candidate is logged with `[SPECIALTY_CUTIN] selected_video_candidate=...`; successful load logs `selected_video=...`; candidate load failure logs `selected_video_load_failed=... fallback=png_text`.
- Video load failure now continues to later fallback candidates instead of ending immediately on the first existing but unloadable file. If no candidate can be loaded, the existing PNG/text cutin remains intact.
- The existing `VideoStreamPlayer_Cutin` node is reused and still stopped/cleared on start and hide, so repeat activation should restart from the beginning.
- The centered cutin banner/card layout from v0.70-6/v0.70-7 remains unchanged.
- Current asset check: the PNG, VP8 WebM, and MP4 files are present; the requested OGV and snake_case non-VP8 WebM fallback files are not present in tracked assets in this local state.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. No GDScript warning/error output or WebM stream/import warning was observed in those headless checks.
- No tracked `.webm.uid`, `.webm.import`, or other video sidecar was generated for `yi_sun_sin_cutin_bg_vp8.webm` during Codex verification.
- No unique-skill 판정, effect, damage, buff/debuff, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- 김작 F6 QA should confirm VP8 WebM visibility, image quality, centered banner/card composition, portrait/text fallback, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.
- Next candidates:
  - `v0.70-9 Specialty Skill Cutin Visual Polish`
  - `v0.70-10 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-11 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-7 Cutin OGV Video Fallback Handoff
- `v0.70-7 Cutin OGV Video Fallback` is complete for ally `yi_sunsin` only.
- `scripts/battle_web_import_test.gd` now selects Yi Sunsin cutin video candidates in priority order: `yi_sun_sin_cutin_bg.ogv`, `yi_sun_sin_cutin_bg.webm`, legacy spaced WebM compatibility candidate, then `yi_sun_sin_cutin_bg.mp4`.
- The selected existing candidate is logged with `[SPECIALTY_CUTIN] selected_video_candidate=...`; successful load logs `selected_video=...`; selected-candidate load failure logs `selected_video_load_failed=... fallback=png_text`.
- OGV existence now wins over WebM/MP4. If the OGV exists but cannot load as a Godot `VideoStream`, the video layer remains safe and the existing PNG/text cutin continues.
- The existing `VideoStreamPlayer_Cutin` node is reused and still stopped/cleared on start and hide, so repeat activation should restart from the beginning.
- The centered cutin banner/card layout from v0.70-6 remains unchanged.
- No unique-skill 판정, effect, damage, buff/debuff, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- 김작 F6 QA should confirm OGV visibility, centered banner/card composition, portrait/text fallback, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.
- Next candidates:
  - `v0.70-8 Specialty Skill Cutin Visual Polish`
  - `v0.70-9 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-10 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-6 Cutin WebM Video Connection + Center Layout Fix Handoff
- `v0.70-6 Cutin WebM Video Connection + Center Layout Fix` is complete for ally `yi_sunsin` only.
- `scripts/battle_web_import_test.gd` now selects Yi Sunsin cutin video candidates in priority order: `yi_sun_sin_cutin_bg.webm`, actual repo file `Yi Sun Sin Cutin Bg.webm`, `yi_sun_sin_cutin_bg.ogv`, then `yi_sun_sin_cutin_bg.mp4`.
- The cutin video stream is stopped/cleared before assignment and stopped/cleared again on hide, so repeat activation should start from the beginning when a loadable stream is available.
- `BattleUI/SkillCutinLayer` remains scene-authored and reusable. `VideoStreamPlayer_Cutin` was changed to a free-positioned centered banner area so code can size it without full-anchor warnings.
- The Yi Sunsin cutin layout is now centered: the video/card rect is centered, the portrait is placed inside the central composition, hero/skill text is center-aligned, and the animation uses center scale/fade instead of lateral slide.
- Kwon Yul and Jeong Do Jeon WebM assets are present in repo as `Kwon Yul Cutin Bg.webm` and `Jeong Do Jeon Cutin Bg.webm`. Their activation wiring remains deferred.
- Godot headless load did not create tracked `.import` files for WebM assets. If F6 still does not display video, the remaining risk is Godot runtime WebM import/playback support; fallback PNG/text cutin still runs.
- No unique-skill 판정, effect, damage, buff/debuff, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm WebM visibility, centered banner/card composition, portrait/text placement, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.
- Next candidates:
  - `v0.70-7 Specialty Skill Cutin Visual Polish`
  - `v0.70-8 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-9 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-5 Specialty Skill Video Cutin MVP Handoff
- `v0.70-5 Specialty Skill Video Cutin MVP` is complete for ally `yi_sunsin` only.
- `Battle_Fullscreen_Test.tscn` now has a reusable scene-authored `BattleUI/SkillCutinLayer` with `ColorRect_Darken`, `VideoStreamPlayer_Cutin`, `TextureRect_Slash`, `TextureRect_Hero`, `Control_Text/Label_HeroName`, `Control_Text/Label_SkillName`, and `AnimationPlayer_Cutin`.
- `scripts/battle_web_import_test.gd` routes ally Yi Sunsin unique-skill presentation through the new 3-second specialty cutin and schedules the existing unique-skill effect after the cutin duration.
- The effect path remains the existing `_apply_unique_skill_effect_if_valid` / `_apply_unique_skill_effect` flow; only presentation timing changes for Yi Sunsin.
- The transparent portrait asset is `res://assets/ui/cutin/portraits/yi_sun_sin_cutin.png`.
- The mp4 asset path is `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4`. The file exists, but no imported Godot VideoStream metadata was found, so runtime code logs and continues with portrait/text cutin if ResourceLoader cannot load the mp4. `ogv` or `webm` remains a likely follow-up for real video playback.
- Non-Yi-Sunsin heroes continue to use the existing unique-skill toast/cutin flow. If the Yi Sunsin layer or portrait is missing, the old toast fallback is used.
- A busy guard prevents overlapping specialty cutins.
- No battle rules, movement/attack 판정, damage formulas, buff/debuff effects, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm actual mp4 playback or fallback behavior, cutin impact, 3-second pacing, portrait placement, text readability, effect continuation after cutin, no soft lock, and normal battle flow.
- Next candidates:
  - `v0.70-6 Specialty Skill Cutin Visual Polish`
  - `v0.70-7 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-8 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-4 Battle Overlay Rollback Shape + Palette Retune Handoff
- `v0.70-4 Battle Overlay Rollback Shape + Palette Retune` is complete in `scripts/battle_web_import_test.gd`, `scripts/battle_range_overlay_tile.gd`, and `scripts/battle_facing_arrow_tile_button.gd`.
- Camera zoom remains unchanged at the v0.70-2/v0.70-3 value `Vector2(0.84, 0.84)`; this pass did not touch camera framing.
- Default play still hides the logical grid guide; `SHOW_LOGICAL_GRID_14X8_GUIDE` remains `false`.
- The successful v0.70-3 pop wave reveal is preserved, including distance-based delay, smaller starting scale, stronger overshoot, settle scale, tween cleanup, and quick cancel behavior.
- The v0.70-3 center-fade/internal band rendering was removed from range overlays so cells read as one clean octagonal tile rather than stacked inner octagons.
- Movement range was retuned to a clearer blue tactical color. Attack range, single-target, multi-target/unique-skill, and strategy overlays remain visually distinct.
- Direction-selection arrow buttons keep the octagonal tile draw script and short pop reveal, but their color is restored to the gold/yellow direction-selection role instead of movement blue.
- No battle rules, move/attack 판정, damage formulas, AI, results, woundedQueue, prisoner/death, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm pop wave retention, no stacked internal octagons, v0.70-2-like simple octagonal tile shape, better movement blue, role-color separation, restored direction-selection color, and click feel.
- Next candidates:
  - `v0.70-5 Battle Overlay Fine Color Tuning`
  - `v0.70-6 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-3 Battle Overlay Palette + Pop Wave Polish Handoff
- `v0.70-3 Battle Overlay Palette + Pop Wave Polish` is complete in `scripts/battle_web_import_test.gd`, `scripts/battle_range_overlay_tile.gd`, and `scripts/battle_facing_arrow_tile_button.gd`.
- Camera zoom remains at the v0.70-2 value `Vector2(0.84, 0.84)`; this pass did not further adjust camera framing.
- Default play still hides the logical grid guide; `SHOW_LOGICAL_GRID_14X8_GUIDE` remains `false`.
- Overlay colors remain type-distinct but are now toned down: movement steel blue-gray, attack coral/rose red, single-target toned amber, multi-target muted violet, and strategy subdued teal.
- Range tile rendering now uses edge-band center-fade instead of a clear small inner octagon, keeping a visible tactical outline while allowing terrain to show through the tile center.
- Pop wave reveal is stronger than v0.70-2: delay is `0.06s` per grid distance, cells start smaller, overshoot more strongly, and settle back to `1.0`.
- Direction selection arrow buttons now get a matching octagonal tile draw script and a short pop reveal, while preserving the existing Button click paths.
- No battle rules, move/attack 판정, damage formulas, AI, results, woundedQueue, prisoner/death, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm distinct-but-cohesive palette, reduced sky-blue/casual feel, center-fade interior, terrain visibility, visible unit-centered pop wave, near/far pop strength, direction tile unification, and click feel.
- Next candidates:
  - `v0.70-4 Battle Overlay Fine Color Tuning`
  - `v0.70-5 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-2 Battle Overlay Shape + Wave Tuning Handoff
- `v0.70-2 Battle Overlay Shape + Wave Tuning` is complete in `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and `scripts/battle_range_overlay_tile.gd`.
- `MainCamera` default zoom is now `Vector2(0.84, 0.84)`. The camera position remains scene-authored.
- Default play still hides the logical grid guide; `SHOW_LOGICAL_GRID_14X8_GUIDE` remains `false` for normal play and available as a future debug flag.
- Range overlays still use the existing `MoveRangeOverlayLayer` ColorRect pool. Each cell now receives a lightweight `BattleRangeOverlayTile` draw script at runtime.
- The tile draw script renders clipped-corner octagonal cells with low-alpha fill, softer inner fill, clear outline, and subtle inner highlight. No external assets were added.
- Movement tiles use blue styling; attack tiles use red/orange-red styling. Unique skill and strategy overlays share the same tactical tile renderer for consistency.
- Wave/stagger reveal is now stronger: `0.04s` delay per Manhattan distance, scale `0.86 -> 1.04 -> 1.0`, and alpha `0 -> 1`.
- Existing overlay hide paths still kill active range tweens before hiding cells, so quick cancel/selection changes should not leave delayed ghost overlays.
- No battle rules, move/attack 판정, damage formulas, AI, results, woundedQueue, prisoner/death, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm zoom `0.84` feel, background visibility, unit size, octagonal tile read, outline strength, alpha/terrain visibility, wave direction/timing, direct move click, attack click, right-click cancel, floating command panel, and turn/auto flow.
- Next candidates:
  - `v0.70-3 Battle Overlay Visual Fine Tuning`
  - `v0.70-4 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-1 Battle Visual Detail Polish Start Handoff
- `v0.70-1 Battle Visual Detail Polish Start` is complete in `Battle_Fullscreen_Test.tscn` and `scripts/battle_web_import_test.gd`.
- Default play no longer shows the logical grid guide. The debug flag `SHOW_LOGICAL_GRID_14X8_GUIDE` remains available for future development use.
- `MainCamera` default zoom is `Vector2(0.88, 0.88)`, preserving the scene-authored camera position while showing more of the 3200x1800 battlefield art.
- Movement and attack overlays continue to reuse the existing `MoveRangeOverlayLayer` cell pool; movement is blue, attack is red, and cells are inset from full-cell bounds.
- Overlay presentation now animates from the selected/casting unit outward using short distance-based staggered alpha/scale tweens.
- Overlay hide paths clear active range tweens before hiding cells, preventing stale/ghost overlay nodes after cancel, movement, attack, strategy, or skill transitions.
- No battle rules, move/attack 판정, damage formulas, AI, results, woundedQueue, prisoner/death, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed. Manual F6 QA remains for camera feel, background readability, unit size, overlay visual taste, wave timing, right-click cancel, direct move click, attack click, floating command panel, and turn/auto flow.
- Next candidates:
  - `v0.70-2 Battle Overlay Visual Tuning`
  - `v0.70-3 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.69-14A GDScript Reload Warning Cleanup Handoff
- `v0.69-14A GDScript Reload Warning Cleanup Before v0.70` is complete in `scripts/worldmap_test.gd`.
- This pass only cleaned Godot GDScript reload warnings before `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- No strategic logic, formulas, balance values, save/load structure, battle, invasion, diplomacy, espionage, tech, trade, or resource behavior was intentionally changed.
- The next task remains `v0.70-1 WorldMap Final UX/UI Information Architecture`.

## v0.69-14 EASTWAR Strategic Logic Final Checkpoint Handoff
- Start any new chat/session from this baseline unless the user explicitly provides a newer commit:
  - `v0.69-13 Espionage Action Foundation MVP`
  - Commit: `0565f2d5f0acfde609e9df9e96d8e3b25726196c`
- v0.69 strategic simulation logic is now considered complete enough for the next phase.
- The next task should be `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- v0.70 should begin with information structure and UX/UI design, not additional strategic logic.
- The first priority is to decide how the v0.69 systems should be exposed, grouped, summarized, and operated in the WorldMap UI.
- During UI work, if behavior looks wrong, first isolate whether it is a display/state-binding issue or an actual v0.69 logic bug.
- Modify v0.69 logic only when F6 manual validation identifies a clear bug; keep those fixes minimal and scoped.
- Existing City Detail / WorldMap UI is temporary and should not be treated as final UX.
- High-risk systems still deferred beyond UI foundation: real revolt, neutral owner conversion, suppression battle, assassination, actual allied military support troop movement, and joint invasion.

## v0.69-13 Espionage Action Foundation Handoff
- `v0.69-13 Espionage Action Foundation MVP` is implemented in `scripts/worldmap_test.gd`.
- The requested guide file `GUIDE_v0.69_12_13_to_v0.70.md` was not found in the repo; implementation followed the explicit v0.69-13 task requirements.
- Added helper/API actions: `_disrupt_city_loyalty`, `_instigate_revolt`, and `_drive_wedge`, with matching validation and forced-roll helpers for QA.
- Loyalty disruption directly lowers city loyalty for this MVP. It does not create pending seasonal loyalty penalties.
- Revolt instigation records `_player_state["revolt_instigation"][city_id]` for 3 turns with a `probability_boost`; it does not cause revolt, neutralization, battle, or owner changes.
- Wedge driving lowers relation score between two allied non-player factions only. It does not auto-break alliance status.
- Detection penalties change relation scores only: loyalty disruption `-40`, revolt instigation `-60`, wedge detection `-20` against each target faction from the player.
- All spy actions reuse shared `spy_cooldown`. The existing primary political chancellor cooldown `-2` policy is applied to new actions.
- Not implemented: assassination, real revolt, suppression battle, war declaration, automatic hostile conversion, alliance break, espionage UI, battle/invasion/defense changes, or save/load core rewrites.
- v0.69 is ready to pivot toward `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Remaining risks: action values are MVP balance; all actions are API-only; revolt boost has no real revolt consumer yet.

## v0.69-12 Diplomacy Action Foundation Handoff
- `v0.69-12 Diplomacy Action Foundation MVP` is implemented in `scripts/worldmap_test.gd`.
- The requested guide file `GUIDE_v0.69_12_13_to_v0.70.md` was not found in the repo; implementation followed the explicit v0.69-12 task requirements.
- Added API/helper actions: `_propose_alliance`, `_request_military_support`, and `_propose_trade_agreement`.
- Alliance proposal is deterministic for MVP QA: acceptance chance is relation score + resource-package bonus, clamped to `0..95`; accepted at `>= 70`.
- Alliance proposal pays the provided resource package on attempt. On success it sets relation `status` to `allied` and records `alliance_turns_remaining`.
- Military support requires `allied`; success/failure is recorded only. Do not infer troop movement, joint invasion, battle support, or defense support from this helper.
- Military support rejection applies relation score `-20`; third and later repeated rejection applies `-40`.
- Trade agreement requires relation score `>= 50`, costs `gold 200 + silk 50`, records a 20-turn agreement, and adds `+0.15` to Phase A route relation multiplier via `_get_trade_agreement_bonus_multiplier`.
- Phase A base status multipliers remain unchanged. The trade agreement bonus is additive and separate from `RELATION_TRADE_MULTIPLIER`.
- Not implemented: war declaration, actual military support troop transfer, joint invasion, alliance/trade duration expiry, diplomacy UI, trade transaction execution, or save/load core rewrites.
- Remaining risks: deterministic diplomacy acceptance needs balance review; recorded durations currently do not tick down; final F6 diplomacy UX remains future work.

## v0.69-11B Espionage Public Support Disrupt Handoff
- `v0.69-11B Espionage Public Support Disrupt MVP` is implemented in `scripts/worldmap_test.gd`.
- This is the first offensive espionage action and only affects target city publicSupport.
- Cost is fixed: `gold 300`.
- Effect amount by political aptitude: `5 -> 20`, `4 -> 15`, `3 -> 10`, `2 -> 5`, `1 -> 3`.
- The action uses shared `spy_cooldown`: base `8`, primary political chancellor `6`.
- If detected, effect is canceled and relation score receives `-30` with reason `spy_public_support_disrupt_detected`.
- Detection does not auto-change relation status, declare war, trigger revolt, or change city owner.
- Do not add loyalty disruption, revolt instigation, alienation, assassination, or real revolt unless a future task explicitly scopes it.
- Not implemented: espionage UI, diplomacy status conversion, war declaration, battle/invasion/defense changes, or save/load core rewrites.
- Next candidates: `v0.69-11C Espionage Detection Penalty Audit` or `v0.69-10C Alliance War Status Foundation MVP`.
- Remaining risks: no UI trigger exists; detection penalty only changes score; disruption balance needs later review.

## v0.69-11 Espionage Info Gathering Handoff
- `v0.69-11 Espionage Info Gathering MVP` is implemented in `scripts/worldmap_test.gd`.
- Espionage subject is the current chancellor. If no chancellor is assigned, info gathering is unavailable.
- Political aptitude is read from existing chancellor hero data. Primary political type gives detection `-10` and cooldown `-2`.
- Success chance table: aptitude `5 -> 80`, `4 -> 65`, `3 -> 50`, `2 -> 35`, `1 -> 20`.
- Visibility table: aptitude `5` shows troops/resources/publicSupport/loyalty/governor/tech; `4` shows troops/resources/publicSupport/loyalty; `3` shows troops/resources; `2` shows troops; `1` shows deterministic troop estimate.
- `_roll_spy_info_result()` supports forced rolls for deterministic tests. `_gather_spy_info()` records result and payload.
- Detection is recorded only. Do not add relation penalties, status changes, war, or revolt effects unless explicitly scoped.
- Spy cooldown is `_player_state["spy_cooldown"]`: base `6`, primary political chancellor `4`.
- Not implemented: publicSupport disruption, loyalty disruption, revolt instigation, alienation, assassination, espionage UI, alliance/trade agreement, or war declaration.
- Next candidates: `v0.69-11B Espionage Public Support Disrupt MVP` or `v0.69-10C Alliance War Status Foundation MVP`.
- Remaining risks: no player-facing espionage trigger exists; detection penalty is deferred; target national/city tech visibility is constrained by existing data structures.

## v0.69-10B Tribute Diplomacy Action Handoff
- `v0.69-10B Tribute Diplomacy Action MVP` is implemented in `scripts/worldmap_test.gd`.
- Tribute is the first diplomacy action and is currently helper/API only.
- Cost is fixed for MVP: `gold 300` + `silk 100`.
- Relation gain is fixed for MVP: deterministic `+20`, clamped by existing score bounds.
- Tribute rejects invalid/self targets, `hostile`, `suspended`, active `tribute_cooldown`, and insufficient resources.
- Tribute uses separate `tribute_cooldown`, not the existing relation `cooldown`; this avoids collision with Phase A trade/suspended-status behavior.
- Domestic turn decreases `tribute_cooldown` once per world turn through `_advance_diplomacy_cooldowns_for_world_turn()`.
- Status must not auto-convert to allied or hostile from tribute score changes.
- Phase A trade remains status-based. Do not make score or tribute affect trade income without a scoped future task.
- Not implemented: alliance proposal, trade agreement, declaration of war, espionage, revolt instigation, specialty trade execution, AI response, or diplomacy UI.
- Next candidates: `v0.69-10C Alliance War Status Foundation MVP` or `v0.69-11 Espionage Info Gathering MVP`.
- Remaining risks: no player-facing trigger exists; fixed cost/gain need balance review; no diplomatic response/AI behavior exists.

## v0.69-10 Diplomacy Relation Score Handoff
- `v0.69-10 Diplomacy Relation Score MVP` is implemented in `scripts/worldmap_test.gd`.
- `faction_relations` entries now normalize to `{"status": String, "score": int, "cooldown": int}`.
- Score is clamped to `0..100`; missing scores default to `50`.
- `relation_band` is derived from score only: `friendly >=70`, `neutral 31..69`, `hostile <=30`.
- `status` and `relation_band` are separate. Do not auto-convert `friendly` to `allied` or `hostile` band to `hostile` status without a scoped diplomacy-action task.
- Phase A trade remains status-based. `RELATION_TRADE_MULTIPLIER` and the trade income formula should remain unchanged unless explicitly scoped.
- Trade routes may carry `relation_score` and `relation_band` as display/debug fields; they must not affect income.
- Current result fields: `_player_state["last_diplomacy_relation_result"]` and `_player_state["last_diplomacy_normalize_result"]`.
- Not implemented: tribute, trade agreements, alliance proposal/acceptance, declaration of war, espionage, revolt instigation, specialty trade execution, or diplomacy UI.
- Next candidates: `v0.69-10B Tribute Diplomacy Action MVP` or `v0.69-11 Espionage Info Gathering MVP`.
- Remaining risks: relation score has no gameplay action consumer yet; normalization initializes all known city-owner faction pairs; final F6 diplomacy UX remains future work.

## v0.69-9 Trade Market Price Handoff
- `v0.69-9 Trade Deepening Data Market Price MVP` is implemented in `scripts/worldmap_test.gd`.
- This is a data/calculation/recording layer only. It must remain separate from existing Phase A inter-faction trade income.
- New market result field: `_player_state["last_trade_market_result"]`.
- Result structure includes `turn`, `season`, `season_label`, `context`, and `prices`; each price entry includes `name`, `base_price`, `season_multiplier`, `situation_multiplier`, `price`, and `trend`.
- Current market context defaults: `war_state=false`, `famine=false`, `abundant_harvest=false`, `alliance_recently_signed=false`; `supply_isolated_count` is pulled from the current/last supply result when available.
- The calculation is deterministic. Do not add random price volatility until a focused follow-up.
- Existing Phase A trade income and `last_inter_faction_trade_result` are not replaced and should not be reshaped by market-price work.
- Not implemented: manual trade, resource exchange execution, trade agreements, diplomacy, maritime trade, pirate losses, hero trade traits, and trade UI.
- Next candidates: `v0.69-9B Specialty Trade Data MVP` or `v0.69-10 Diplomacy Relation Score MVP`.
- Remaining risks: market prices have no transaction consumer yet; situation context depends on future event/diplomacy systems; F6/manual UX validation is deferred to later UI work.

## v0.69-8B Tech Effect Application Handoff
- `v0.69-8B Tech Effect Application MVP` is implemented in `scripts/worldmap_test.gd`.
- Effects apply from completed tech only. In-progress tech has no effect.
- One-time effect: `legal_reform` applies publicSupport `+5` to all player-owned cities once. Duplicate prevention is stored in `_player_state["applied_tech_effects"]["national"]["legal_reform"]`.
- Continuous income effects: `tax_reform` gives domestic gold income `x1.10`; `street_market` gives city domestic gold income `x1.05`. These do not affect inter-faction trade income.
- Conscription effects: completed city `barracks` is now required for automatic conscription. Completed national `conscription_system` changes only turnly automatic conscription add by `x1.10`, capped by available amount. Capacity is unchanged.
- Recognized but no consumer yet: `national_foundation`, `improved_farming_tools`, and `fishing_village`.
- `last_tech_effect_result` records applied effects and no-consumer recognized effects.
- Do not assume battle/special-unit/diplomacy/revolt/trade-deepening effects exist. Those are not implemented.
- No tech UI or auto tech selection exists yet.
- Next candidate is `v0.69-9 Trade Deepening MVP`.
- Remaining risks: barracks gating changes automatic conscription balance; most tech effects are still pending; no final F6 UX validation exists.

## v0.69-8 Tech Start Progress Pipeline Handoff
- `v0.69-8 Tech Start Progress Pipeline MVP` is implemented in `scripts/worldmap_test.gd`.
- National and city tech can now start, pay costs, enter `in_progress`, advance by domestic world turns, and migrate to `completed`.
- Use `_start_national_tech(tech_id)` and `_start_city_tech(city_id, tech_id)` for starting tech. Both require `_can_start_*` to pass and deduct cost on success.
- Use `_advance_national_tech_progress_for_world_turn()` and `_advance_city_tech_progress_for_world_turn()` for per-turn progress. The domestic turn pipeline already calls both after revolt warning.
- `_get_tech_duration_turns(tier)` provides MVP defaults: basic `4`, mid `9`, advanced `18`, capstone `28`, rare `30`. Definition `duration_turns` overrides this if added later.
- Generic cost helpers support `food` as rice+barley+seafood pool, deducted in order `rice -> barley -> seafood`.
- Completed entries include `effect_summary` and `effect_applied: false`.
- Do not assume effects exist. No national/city tech effect is applied yet.
- No UI or automatic tech selection exists. Start calls are helper/API only until a later UI/task explicitly wires player choices.
- Existing publicSupport, loyalty, recruitment, revolt, trade, supply, troop movement, battle, invasion, defense, and save/load core behavior must remain untouched unless explicitly scoped.
- Superseded by `v0.69-8B`: first Tech Effect Application MVP is implemented.
- Remaining risks: no player-facing selection UI, no effect application, no automatic selection, and several placeholder conditions still block advanced techs.

## v0.69-7A Tech Data Consistency Audit Handoff
- `v0.69-7A National City Tech Data Consistency Audit` is complete in `scripts/worldmap_test.gd`.
- `_validate_tech_data_consistency()` audits national/city tech definitions only. It must remain QA/debug-only unless a future task explicitly scopes runtime use.
- The audit checks `required_national_tech`, city and national `requires`, allowed cost keys, allowed aptitude/governor/chancellor types, `icon_path` / `image_path`, and placeholder condition keys.
- `logistics_system` / `병참 제도` now exists as a national tech so `dried_fish_supply_base` no longer points to a missing national tech ID.
- National tech definitions now include `icon_path` and `image_path` as empty-string placeholders. Do not load images or add UI unless explicitly scoped.
- Placeholder conditions still block and must not be auto-passed: `chancellor_type_turns`, `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, `has_hero_yi_sunsin`, `has_city_tech_mint`, `has_silkroad_or_trade_port`, `neutral_faction_count`, and `allied_faction_count`.
- `food` is still an MVP cost key for the rice+barley+seafood food pool. No cost deduction exists in this audit.
- Superseded by `v0.69-8`: Tech Start/Progress Pipeline MVP is implemented.
- Remaining risks: `connected_supply_city_count` needs a real source later; `maritime` is an allowed type but no dedicated hero data source is wired yet; no tech lifecycle, effects, UI, or final F6 UX validation exists.

## v0.69-7 City Tech Tree Data Handoff
- `v0.69-7 City Tech Tree Data MVP` is implemented in `scripts/worldmap_test.gd`.
- Scope is data/state/check helpers only. No UI, start, cost deduction, turn progress, completion, effect application, or governor auto-selection exists yet.
- City tech definitions are returned by `_get_city_tech_definitions()`.
- Definition records include `icon_path` and `image_path` as empty-string placeholders for later tech UI image connection. Do not load images or add UI in follow-up logic tasks unless explicitly scoped.
- Per-city state is `city_tech = {"completed": {}, "in_progress": {}, "available_cache": {}}`, normalized by `_ensure_city_tech_state(city_id)`.
- Use `_check_city_tech_requirements(city_id, tech_id)`, `_can_pay_city_tech_cost(city_id, tech_id)`, and `_can_start_city_tech(city_id, tech_id)` for validation.
- `_start_city_tech(city_id, tech_id)` is intentionally a no-op skeleton returning `false`; it only records `last_city_tech_start_check`.
- Food cost is checked as the existing rice+barley+seafood pool. No cost is deducted in this MVP.
- City tech and national tech are separate. Advanced city tech may require completed national tech through `required_national_tech`.
- Placeholder conditions must not pass automatically: `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, and `has_hero_yi_sunsin`.
- Maritime governor requirements currently fail unless a future hero/runtime entry explicitly provides `maritime`; no new hero data model was added.
- Superseded by `v0.69-7A`: National/City tech data consistency audit is complete.
- Next candidate is `v0.69-8 Tech Start/Progress Pipeline MVP`.
- Remaining risks: placeholder conditions block advanced branch techs until supporting systems exist; no research lifecycle, effect application, UI, or final F6 UX validation exists yet.

## v0.69-6 National Tech Tree Data Handoff
- `v0.69-6 National Tech Tree Data MVP` is implemented in `scripts/worldmap_test.gd`.
- Scope is data/state/check helpers only. No UI, start, cost deduction, turn progress, completion, or effect application exists yet.
- National tech definitions are returned by `_get_national_tech_definitions()`.
- Player state is `_player_state["national_tech"] = {"completed": {}, "in_progress": {}, "available_cache": {}}`, normalized by `_ensure_national_tech_state()`.
- Use `_check_national_tech_requirements(tech_id)`, `_can_pay_national_tech_cost(tech_id)`, and `_can_start_national_tech(tech_id)` for validation.
- `_start_national_tech(tech_id)` is intentionally a no-op skeleton returning `false`; it only records `last_national_tech_start_check`.
- Food cost is checked as the existing rice+barley+seafood pool. No cost is deducted in this MVP.
- Placeholder conditions must not pass automatically: `chancellor_type_turns`, `allied_faction_count`, `neutral_faction_count`, `has_city_tech_mint`, and `has_silkroad_or_trade_port`.
- Superseded by `v0.69-7`: City Tech Tree Data MVP is implemented. Keep national tech and city tech separate.
- Next candidates are `v0.69-8 Tech Start/Progress Pipeline MVP` or `v0.69-6B National Tech Start/Progress MVP`.
- Remaining risks: placeholder conditions block later branch techs until supporting systems exist; no research lifecycle, effect application, or UI exists yet.

## v0.69-5 Revolt Warning Handoff
- `v0.69-5 Revolt Warning Foundation MVP` is implemented in `scripts/worldmap_test.gd`.
- Revolt warning is a read-only calculation over current city `publicSupport` and `loyalty`.
- Risk states are exactly `stable`, `warning`, and `danger`.
- `warning` means both publicSupport and loyalty are `<= 40`.
- `danger` means both publicSupport and loyalty are `<= 30`.
- `_calculate_city_revolt_risk(city_id)` returns the per-city risk payload. `_apply_revolt_warning_check_for_world_turn()` scans player-owned cities and records `last_revolt_warning_result`.
- Domestic turn runs revolt warning after publicSupport drift, city loyalty drift, seasonal loyalty, and conscription so the check reads current values.
- This MVP does not trigger revolts, does not change owner to neutral, does not create suppression battles, and does not integrate espionage revolt agitation.
- Map markers, icon/color UX, and final UI are deferred to later UI work. Current City Detail text is temporary minimal display.
- PublicSupport, loyalty, conscription/recruitment, troop movement, P0-1/P0-2/Phase A/Phase B, battle, and save/load formulas/cores must remain untouched unless a future task explicitly scopes them.
- Superseded by `v0.69-6`: National Tech Tree Data MVP is implemented.
- Remaining risks: warning-only foundation, no actual event lifecycle, no espionage integration, no map warning UI, and no final F6 UX validation yet.

## v0.69-4 Recruitment/Conscription Handoff
- `v0.69-4 Recruitment/Conscription Foundation MVP` is implemented in `scripts/worldmap_test.gd`.
- Conscription is loyalty-based. Use `_get_conscription_capacity_by_loyalty(city_id)` and `_get_city_conscription_available(city_id)` for capacity/available calculations.
- Automatic conscription is slow and free: `_apply_city_conscription_for_world_turn()` runs after publicSupport drift, existing city loyalty drift, and seasonal loyalty from publicSupport in the domestic turn, then adds `min(available, 100)` troops.
- Conscription does not reduce population and does not directly change publicSupport or loyalty.
- Recruitment amount limits are superseded by v0.70-21 and now use city loyalty. Use `_get_recruitment_limit_by_loyalty(city_id)`, `_calculate_recruitment_cost(amount)`, `_can_recruit_troops(city_id, amount)`, and `_recruit_troops(city_id, amount)`.
- Recruitment is immediate and paid, but currently helper/API only. Do not assume a final UI exists.
- Recruitment cost is `gold = amount` and `food = amount / 2`; MVP food payment uses national `resource_stock` in order `rice -> barley -> seafood`.
- Recruitment does not reduce population, does not directly change publicSupport or loyalty, and does not implement fatigue/publicSupport decline yet.
- Current City Detail output is a temporary minimal display. Real F6 mouse-based UX verification belongs with the June City Detail/WorldMap UI overhaul.
- Superseded by `v0.69-5`: revolt warning foundation is implemented.
- Remaining risks: no explicit recruitment UI, MVP national food-pool payment, no population/fatigue effects, and no final UX validation yet.

## v0.69-3A Strategic Logic Checkpoint Handoff
- `v0.69-3A Strategic Logic Checkpoint Documentation` is documentation-only. No code or formulas were changed.
- v0.69-1 through v0.69-3 are complete as the first strategic logic foundation block:
  - `publicSupport` changes through domestic stability.
  - `publicSupport` affects city `loyalty` on seasonal turns.
  - Current city `loyalty` controls troop movement loss.
- Treat the strategic chain `publicSupport -> seasonal loyalty -> troop movement efficiency/loss` as the locked v0.69 foundation unless a later task explicitly reopens balance.
- Current validation coverage is headless/API-oriented. Do not treat the temporary City Detail surfaces as final UX validation.
- Real F6 mouse-based UX verification should be performed during the June city information panel and WorldMap UX/UI redesign phase.
- Current City Detail UI is a minimal temporary display/connection surface. Avoid polishing it as final UI before the planned redesign.
- Superseded by `v0.69-4`: recruitment/conscription foundation is implemented. Manual UX verification for v0.69-1 through v0.69-4 should still be revisited alongside the later UI overhaul.

## v0.69-3 Troop Move Loyalty Efficiency Handoff
- `v0.69-3 Troop Move Loyalty Efficiency Final Patch` is implemented in `scripts/worldmap_test.gd`.
- C1 manual troop movement now uses the final source-city loyalty efficiency formula instead of total preservation.
- Movement formula is locked: all `commanded_amount` troops depart, `arrived_amount = floor(commanded_amount * from_loyalty / 100.0)` arrive, and `lost_amount` is recorded as movement loss.
- `_can_move_troops` still validates against the commanded amount, including the minimum source-garrison guard.
- `last_troop_move_result` records commanded/departed/arrived/lost/from_loyalty plus source/destination after values; `amount` remains for compatibility.
- C2 approval still goes through `_apply_troop_rebalance_suggestion()` -> `_move_troops()`, so C2 receives the same loyalty-based loss automatically. Do not add C2 automatic execution or a separate direct-write path.
- `publicSupport` is not a direct troop movement input. Movement uses current city loyalty, which may already include seasonal publicSupport effects from v0.69-2.
- Superseded by `v0.69-4`: recruitment/conscription foundation is implemented.
- Remaining risks: minimal movement UI still lacks explicit target/amount controls, and manual F6 visual QA remains useful for display copy.

## v0.69-2 Seasonal Loyalty Handoff
- `v0.69-2 Seasonal Loyalty From Public Support MVP` is implemented in `scripts/worldmap_test.gd`.
- Public support remains a separate fast-changing domestic stability axis; loyalty remains the slower military-operation axis.
- Seasonal loyalty bridge applies only on `turn_number % 10 == 0`, matching the current 10-turn season calendar and current domestic-apply-before-turn-advance flow.
- Current domestic turn order: publicSupport drift -> existing P0-2 city loyalty drift -> seasonal loyalty from publicSupport.
- Existing P0-2 city loyalty drift was not removed, replaced, or merged into publicSupport.
- Seasonal publicSupport thresholds are locked for this MVP: `90+ +2`, `80+ +1`, `60..79 -1`, `40..59 -2`, `0..39 -3`.
- Payroll/gold surplus and equipment surplus loyalty factors are not implemented yet; leave them for a later focused pass.
- Superseded by v0.69-3 for the next military-operation consumer of current loyalty.
- Remaining risks: minimal UI display only; seasonal bridge is publicSupport-only and does not yet include payroll/equipment/supply seasonal modifiers beyond the existing P0-2/supply systems.

## v0.69-1 Public Support MVP Handoff
- `v0.69-1 Public Support MVP` is implemented in `scripts/worldmap_test.gd`.
- `publicSupport` is a separate city runtime value from existing `loyalty` / `cityLoyalty`. Do not merge, rename, or replace loyalty with public support.
- Existing P0-2 city loyalty drift remains active and separate. This v0.69-1 note is superseded by v0.69-2, where publicSupport is seasonally reflected into loyalty.
- `publicSupport` defaults to `70`, clamps `0..100`, saves/loads through the existing city runtime payload, and records turn output in `_player_state["last_public_support_result"]`.
- Domestic turn order now applies public support drift after income/upkeep/trade resource application and before national/city loyalty drift. This is intentionally non-coupled for v0.69-1.
- Next task after v0.69-2 should be `v0.69-3 Troop Move Loyalty Efficiency Final Patch`.
- Remaining risks: the MVP food/commerce checks use current `resource_stock` plus recent domestic/trade result fallback, not a complete city-level economy model; UI display is minimal.

## v0.69-0 Roadmap Handoff
- `v0.69` is not a simple feature-addition track. It is the start of the EASTWAR strategic simulation foundation.
- Build beyond the existing web-version MVP depth. The v0.68b baseline is closed at `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions` / commit `aec588b`.
- Public support, loyalty, and security are the central axes for national operation, troops, revolt pressure, tech progression, diplomacy, and espionage.
- Do not build final UI first. Implement the v0.69 strategic logic foundations first, then perform final WorldMap UX/UI information architecture in `v0.70-1`.
- `_incoming_confirmed_designs/` is a temporary input staging folder and is not a commit target.
- The current official `agent/CONFIRMED_*` documents have been replaced with the latest incoming confirmed designs for v0.69.
- Confirmed design documents now live in `agent/`:
  - `CONFIRMED_LOYALTY_PUBLICSUPPORT_DESIGN.md`
  - `CONFIRMED_NATIONAL_TECHTREE_DESIGN.md`
  - `CONFIRMED_CITY_TECHTREE_DESIGN.md`
  - `CONFIRMED_TRADE_SYSTEM_DESIGN.md`
  - `CONFIRMED_DIPLOMACY_ESPIONAGE_REVOLT.md`
- Next implementation order:
  1. `v0.69-1 Public Support MVP`
  2. `v0.69-2 Seasonal Loyalty From Public Support MVP`
  3. `v0.69-3 Troop Move Loyalty Efficiency Final Patch`
  4. `v0.69-4 Recruitment/Conscription Foundation MVP`
  5. `v0.69-5 Revolt Warning Foundation MVP`
  6. `v0.69-6 National Tech Tree Data MVP`
  7. `v0.69-7 City Tech Tree Data MVP` - complete
  8. `v0.69-8 Trade Deepening MVP`
  9. `v0.69-9 Diplomacy/Espionage Foundation MVP`
  10. `v0.70-1 WorldMap Final UX/UI Information Architecture`

## Latest Patch Note
- `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions` implements Phase C C2 as pure suggestion calculation only.
- No UI, suggestion cards, automatic redistribution, direct troop writes, resource changes, battle changes, save/load core rewrites, or C1 validation formula changes were implemented.
- `HANDOFF_P2C2_REBALANCE_SUGGESTIONS.md` was not found in the repo; implementation followed the explicit task text. `ROLE_TARGET_GARRISON_RATIO` was absent and was added minimally for the requested target-garrison formula.
- Added `_calculate_troop_rebalance_suggestions()`: reads existing Phase B supply states, builds `hub/rear` surplus suppliers and `frontline` shortage demands, processes larger shortages first and larger surplus suppliers first, validates candidates with `_can_move_troops`, stores `last_troop_rebalance_suggestions`, and returns the array.
- Added `_apply_troop_rebalance_suggestion(suggestion)`: extracts `from`, `to`, and `amount`, then delegates to C1 `_move_troops`. C2 does not call `_set_city_runtime_troops`.
- QA confirmed start-state 0 suggestions, crafted multi-city suggestion generation, all suggestions passing `_can_move_troops`, suggestion calculation preserving world and per-city troops, apply preserving total troops through `_move_troops`, and save/load preserving moved troops.
- Remaining risks: no approval UI yet; first-pass target-garrison ratios should be balance-reviewed; future UI flow needs F6 manual QA.
- Next candidates: `City Panel Rebuild / Chancellor Suggestion UI` or `Troop Move UI from/to/amount Control Polish`.

## Previous Patch Note
- `v0.68b-13-6C1 Troop Move Manual MVP` implements Phase C C1 only: manual troop movement between player-owned cities.
- C2 chancellor suggestions and automatic troop redistribution were not implemented.
- Precheck: existing state was sufficient for movement locking. Reused `_enemy_turn_mvp_pending`, pending invasion event, pending battle context, `Engine` battle context meta, and `turn_phase == player`; no new lock flag was added.
- Added `TROOP_MOVE_MIN_GARRISON_RATIO := 0.6` and C1 helpers for supply-path validation, minimum garrison, peacetime gate, validation, movement, total troop audit, and minimal UI preview.
- Movement rule: `_can_move_troops` must pass; `_move_troops` then writes source and destination only with `_set_city_runtime_troops(from, from - amount)` and `_set_city_runtime_troops(to, to + amount)`.
- The manual UI is intentionally minimal: City Detail internal/supply tab uses the selected city as source, first connected player-owned city in existing `owned_city_ids` as target, and up to 100 movable surplus troops as amount.
- QA runner confirmed total troop preservation, minimum garrison rejection, no supply path rejection, pending invasion rejection, save/load troop preservation, and player attack BattleContext reading the moved troops.
- Not changed: resource_stock, P0-1, P0-2, Phase A trade, Phase B supply calculations, battle scene logic, battle troop formulas, battle/invasion/defense logic, and save/load core structure.
- Remaining risks: minimal UI lacks explicit target/amount controls; F6 visual/manual QA is recommended; last move summary is persisted through existing full `_player_state`.
- Next candidate: `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions`.

## Previous Patch Note
- `v0.68b-13-5A City Info Display Spacing Micro Polish` is a display-formatting-only follow-up to 13-5.
- It only changes 13-5 helper output strings: adds section titles, line breaks, and normalized empty-state copy for trade/supply/loyalty display text.
- Route display now uses the existing routes array in current order with `slice(0, 3)` and an `외 N개` suffix for remaining routes. It does not sort, prioritize, filter by value, or mutate the original routes array.
- No calculation logic, result structure, real resource/loyalty/upkeep/troop values, P0-1, P0-2, Phase A, Phase B, Phase C, battle/invasion/defense, or save/load code was changed.
- Verification passed for scoped diff review, route slice/original-array mutation QA, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless display-spacing QA runner. Godot `--check-only` timed out locally after 124 seconds.
- Remaining risks: manual visual F6 mouse QA is still needed for actual label spacing/font rendering; Phase C remains unimplemented.
- Next candidate: `v0.68b-13-6 Phase C Internal Troop Rebalance MVP`.

## Previous Patch Note
- `v0.68b-13-5 City Info Trade Supply Loyalty Display Polish` fills existing City Detail internal/external trade tab cases and turn result text with existing result/state data only.
- This is display-only. It does not change P0-1 governor income, P0-2 city loyalty drift, Phase A trade, Phase B supply connectivity, resources, loyalty, upkeep, result schemas, Phase C troop redistribution, battle/invasion/defense, or save/load core logic.
- Internal/supply tab display source: `_calculate_all_city_supply_states().city_states[city_id]`, using existing `role`, `supplied`, `isolated`, `income_multiplier`, `loyalty_delta`, and `security_delta`.
- Internal/supply tab loyalty display source: `_player_state["last_city_loyalty_drift_result"]`, using existing selected-city `reasons[]` and tax/security/economy/military/supply/supply_security/control delta fields.
- External trade tab display source: `_player_state["last_inter_faction_trade_result"]`, using `route_count`, `applied_player_totals` with `player_totals` fallback, and `routes` filtered to the selected city.
- Turn result/status text now includes trade income summary, supply hub/supplied-frontline/isolated summary, and city loyalty drift changed-city/large-drop summary.
- Added formatting helpers only: trade result summary, supply state summary, city loyalty drift summary, selected-city supply display, selected-city drift display, and selected-city route display.
- Verification passed for `rg`, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless display QA runner. `--check-only` timed out locally after 125 seconds.
- Remaining risks: no manual visual F6 mouse QA yet; long detail text may need later spacing polish; supply tab display refreshes the runtime supply summary because it uses the existing supply calculation helper.
- Next candidates: `v0.68b-13-6 Phase C Internal Troop Rebalance MVP` or additional `Supply/Trade UI Polish`.

## Previous Patch Note
- `v0.68b-13-4A Supply Connectivity F6 QA Closeout` completed Phase B supply connectivity QA/documentation with no gameplay code changes.
- QA used `WorldMap_Test.tscn` plus a temporary headless runner, then removed the runner before commit.
- Starting state passed: Hanseong is the supply hub; with only Hanseong owned, there are no supplied frontlines and no isolated cities; turn end advances and records domestic/trade results.
- Connected scenario passed: Pyeongyang, Gyeongju, and Sabi as player-owned cities classify as supplied frontlines with paths back to Hanseong.
- Bonus checks passed: supplied frontline income `x1.10`, loyalty `+1`, security `+1`, supplied-frontline hero upkeep discount, and the `0.85` discount floor.
- Isolated scenario passed: Kyoto as a player-owned disconnected city classifies as isolated frontline with income `x0.80`, loyalty `-2`, and security `-1`; no isolated upkeep surcharge is expected in this MVP.
- Save/load behavior: loaded `_player_state` may contain a stale `last_supply_state_result`, but the next supply calculation recomputes from owner/owned-city/neighbor topology and overwrites it. Do not treat the loaded summary as authoritative.
- Light regressions passed for Phase A trade, city loyalty/runtime save-load, `faction_relations` persistence shape, player attack BattleContext build, and enemy invasion/defense event creation.
- Remaining risks: headless/API QA only, no visual supply-state UI, possible stale loaded runtime summary before recalculation, no Phase C troop redistribution, and no battle/invasion/defense supply effects.
- Next candidates: `v0.68b-13-5 Phase C Internal Troop Rebalance MVP` or `City Info Supply State Display Polish`.

## Previous Patch Note
- `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP` implements the redesigned Phase B as connectivity-gated domestic modifiers, not as resource movement.
- The national single-warehouse model remains intact. No city-level warehouse split, city-to-city transfer logic, or Phase C troop redistribution was added.
- Supply helpers in `scripts/worldmap_test.gd`: `_get_player_supply_hub_id`, `_is_city_supply_connected`, `_calculate_city_supply_state`, and `_calculate_all_city_supply_states`.
- `_apply_domestic_turn_mvp` calculates `supply_states` once, then passes the same result into domestic income, hero upkeep, and city loyalty drift.
- Frontline supplied cities receive income `x1.10`, loyalty `+1`, security `+1`; isolated frontline cities receive income `x0.80`, loyalty `-2`, security `-1`; hub/rear cities receive no bonus.
- Hero upkeep discount uses `max(0.85, 1.0 - 0.03 * supplied_frontline_count)`. Isolated-frontline upkeep surcharge is deferred as a remaining risk.
- `last_supply_state_result` is stored with `hub_id`, `supplied_frontline_count`, `isolated_count`, and `city_states`. It is recalculated each turn and is not a save/load payload extension.
- `worldmap_test_FULL.gd` is treated as an untracked source integration file and is not part of this commit.
- Verification passed for `rg`, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and Godot `--check-only`.
- F6 manual QA remains for multi-city frontline/rear classification, connected and isolated cases, save/load recalculation, and visual/domestic summary sanity.

## Latest Patch Note
- `v0.68b-13-3 Final Merged WorldMap Domestic Trade Loyalty QA` applied `worldmap_test_FULL.gd` to `scripts/worldmap_test.gd`.
- The final merged WorldMap file contains P0-1 governor income effects, P0-2 city loyalty drift, Phase A inter-faction trade income, and trade tuning C.
- Trade tuning C values are confirmed in code: `TRADE_GLOBAL_DAMPENER := 0.5` and `TRADE_FOOD_FACTOR := 1.5`.
- `_apply_domestic_turn_mvp` preserves the integrated order: income, upkeep, Phase A trade, national loyalty, then city loyalty drift.
- Diff review against previous HEAD showed only trade tuning C changes and no battle/invasion/defense code changes.
- Static route check confirms Hanseong routes to Pyeongyang, Gyeongju, and Sabi, with tuned gold income totaling +40.
- Headless project and WorldMap scene loads pass; `--check-only` times out locally.
- F6 manual QA is still needed for visual trade income display, city loyalty save/load, `faction_relations` save/load, governor income sanity, and light battle/invasion/defense entry regression.
- Phase B supply connectivity was not implemented. Next task: `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP`.

## Previous Patch Note
- `v0.68b-13-2 City Loyalty Drift Patch Acceptance QA` applies the P0-2 city loyalty drift patch to `scripts/worldmap_test.gd`.
- The patch adds the requested constants and four helpers: `_apply_city_loyalty_drift_for_world_turn`, `_calculate_city_loyalty_drift`, `_get_city_security_required_troops`, and `_governor_has_aptitude`.
- `_apply_domestic_turn_mvp` now applies city loyalty drift after national loyalty update and stores details in `last_city_loyalty_drift_result` / `last_domestic_apply_result.city_loyalty_drift_result`.
- P0-1 `city_loyalty_loss_multiplier` is now consumed by city tax loyalty drift via `_adjust_loyalty_delta`.
- `recruitable_troops_bonus` is still not connected to recruitment, security bonuses, or any consumer.
- City loyalty is stored through `_get_mutable_city_runtime_state` / `_city_runtime_states`; `loyalty` and `cityLoyalty` are included in the existing city runtime save/load payload without rewriting save/load core structure.
- Phase A trade was not implemented in this task. This branch already contains Phase A from `v0.68b-13-2A`; future merges should keep the intended turn order: P0-1 governor income, Phase A trade income if present, hero upkeep, national loyalty, then P0-2 city loyalty drift.
- Verification passed for `rg`, `git diff --check`, Godot headless project load, and `WorldMap_Test.tscn` headless load. `--check-only` timed out locally.

## Previous Patch Note
- `v0.68b-13-2A Inter-Faction Trade Income MVP` implements Phase A only.
- WorldMap domestic turn processing now calculates adjacent inter-faction trade routes from player-owned cities and applies player trade income through `_apply_resource_delta(...)`.
- Relations are stored lazily in `_player_state["faction_relations"]` using sorted `a|b` keys; absent relation keys fall back to `neutral`.
- `last_inter_faction_trade_result` is saved in `_player_state` with `turn`, `route_count`, `player_totals`, `routes`, and `applied_player_totals`.
- `neutral` and `allied` trade; `hostile` and `suspended` do not. Same-faction city pairs are excluded.
- No Phase B internal supply network, Phase C troop redistribution, diplomacy manipulation UI, trade setting UI, battle/invasion/defense changes, or P0-2 loyalty/recruitment connection was added.
- Verification passed for `rg`, `git diff --check`, Godot headless project load, and `WorldMap_Test.tscn` headless load. `--check-only` timed out locally.

## Previous Patch Note
- `v0.68b-13-1 Governor Income Effect Patch Acceptance QA` reviewed and accepted the P0-1 governor income patch in `scripts/worldmap_test.gd`.
- The requested gates were missing, so only the narrow domestic-income patch points were added: governor rates, city effect calculation, governor type/policy effect helpers, city-income `city_effects` parameter, and player-income pass-through.
- Governor city effects now apply before the existing chancellor policy and national multipliers. No battle, invasion, defense, save/load, or scene logic was changed.
- `city_loyalty_loss_multiplier` and `recruitable_troops_bonus` are intentionally retained in the effect dictionary without current Godot consumers.
- Verified with `rg`, Godot headless project load, and `WorldMap_Test.tscn` headless load. `--check-only` timed out locally, so treat that specific check as inconclusive.
- F6 follow-up should compare Hanseong turn-end income before/after governor assignment and again after save/load; current Hanseong candidate effects may round to no visible income-number change at default values.

## Previous Patch Note
- `v0.68b-12b-31 Player/Defense Troop Accounting Parity Fix` closes the P0 troop-accounting gaps from the web parity audit.
- Player attack now subtracts defender allocated troops from the target city before battle, and preserves defender before/after metadata in the BattleContext/result payload.
- Enemy invasion defense now builds and pre-decrements both attacker and defender troop allocations before battle handoff.
- Battle result payload now includes player/enemy troop outcomes for defense battles as well as attack battles.
- Defense victory/defeat now apply survivor/wounded/dead results through city garrison and troop woundedQueue rules, including nearest-player-neighbor wounded retreat on defense defeat.
- Manual F6 QA remains required for queue persistence/recovery and win/loss city accounting.

## Previous Patch Note
- `v0.68b-12b-30 Invasion Attack Web Parity Gap Audit` is a docs-only audit comparing SamWar_web and Godot invasion/attack parity.
- New document: `agent/INVASION_ATTACK_WEB_PARITY_GAP_AUDIT.md`.
- Confirmed P0: player attack defender garrison pre-decrement is missing; defense battle troop allocation/result parity is missing; defense woundedQueue/nearest-player retreat-city handling is missing; woundedQueue F6/save-load QA remains required.
- Confirmed P1: commandRank/commandLimit allocation clamp is missing in Godot deployment UI, and defense deployment UI/default allocation needs follow-up.
- Deferred: captured city hero recruit/conversion, prisoner soldier systems, troop-count combat scaling, in-battle supply effects, and siege-specific formulas.

## Previous Patch Note
- `v0.68b-12b-29A Web-Parity Troop Allocation Wounded Queue Import` ports the web troop allocation and wounded soldier queue rules into the Godot player attack path.
- Deployment confirmation subtracts allocated sortie troops from the player source city before battle handoff and records source before/after troop values in the BattleContext.
- Battle units now carry `allocated_troops` and `initial_allocated_troops`; these fields drive result accounting but do not scale HP, attack, defense, unit size, or animation.
- Player attack result payloads include player/enemy troop outcomes. Victory uses HP-ratio survivors plus 30% wounded losses; defeat has 0 survivors and 50% wounded allocated troops.
- Victory transfers player survivors to the occupied target city and queues wounded troops there; defeat queues player wounded troops at the source city while the target owner remains unchanged.
- City `woundedQueue` persists through save/load and recovers into garrison troops on WorldMap strategy turn advance after 3 turns.
- Deferred: defender pre-battle garrison decrement parity, troop-count combat effects, in-battle supply effects, troop types, siege math, loot, and prisoner soldier systems.

## Previous Patch Note
- `v0.68b-12b-26 Player City Attack MVP Import` ports the web player city attack flow into the Godot WorldMap MVP.
- The selected-city `공격` button now emits an attack request and WorldMap enables it only for enemy cities with a directly adjacent player-owned city and no pending invasion/turn conflict.
- Player attack BattleContext uses `source: player_attack`, `type: attack`, source city as attacker, target city as defender, and the existing city-roster/support helper with captured/dead exclusion.
- Battle_Fullscreen_Test now maps player attack attacker roster to ally slots and defender roster to enemy slots; enemy-invasion defense context mapping is unchanged.
- Player attack result handling applies player victory as target-city occupation and player defeat as owner retention, reusing casualty, result card, hero status, and save/load persistence paths.
- Deferred: deployment selection, troop allocation, sea/route-type attacks, 2-hop attacks, marching/supply, siege UI, AI counterattack, and enemy hero recruitment.

## Previous Patch Note
- `v0.68b-12b-26 Wounded Hero Recovery Turn MVP` adds `wounded_turns_remaining` to hero runtime state.
- New wounded placeholders start at 3 WorldMap strategy turns; captured/dead/normal heroes keep the counter at `0`.
- Recovery ticks only from `_advance_world_turn_mvp()`, so battle rounds and auto-battle turns do not heal wounds.
- UI state markers now show `[부상 N턴]`; when the counter reaches `0`, status returns to `normal`, the badge disappears, and v25 battle penalties stop applying.
- Save/load now includes `wounded_turns_remaining`, with older wounded saves normalized to the 3-turn MVP default.
- Deferred: treatment buildings/items, ability-based recovery duration, prisoner release/recruit/execute, and death handling.

## Previous Patch Note
- `v0.68b-12b-25 Wounded Hero Battle Penalty MVP` keeps wounded heroes battle-eligible but weakens their combat output.
- Wounded penalty MVP values are attack damage `75%`, defense as incoming damage `120%`, and unique-skill numeric effects `70%`.
- Unique-skill damage, splash, attack buff, and defense buff amounts use the skill penalty; the toast/name presentation is unchanged.
- The battle scene reads wounded state from preserved context hero status fields; save/load continues through existing `worldmap_hero_state`.
- Captured/dead exclusion from v24 remains intact, while wounded heroes are intentionally not excluded.
- Deferred: wound recovery, treatment UI, prisoner movement/recruit/execute/release, real death handling, and refined ability-based wound balance.

## Previous Patch Note
- `v0.68b-12b-24 Captured Hero Battle Exclusion MVP` keeps captured heroes in WorldMap city rosters but excludes them from future invasion BattleContext rosters.
- The exclusion guard treats `captured == true`, `status == "captured"`, and safety `dead == true` as ineligible for battle; wounded heroes remain eligible.
- Support/reinforcement candidate picks use the same guard, so captured heroes are skipped instead of becoming reinforcements.
- The battle scene also rejects captured/dead WorldMap context heroes before slot assignment and deactivates the slot as a defensive guard.
- Save/load does not need a new payload shape; loaded `worldmap_hero_state` status fields continue to drive the exclusion.
- Deferred: prisoner movement/holding, recruit/execute/release, wound recovery, wounded penalties, and actual death processing.

## Previous Patch Note
- `v0.68b-12b-23 Hero State Visual Marker Roster Badge MVP` makes placeholder hero state visible in key roster surfaces.
- Runtime/display helpers append `[부상]`, `[포로]`, or `[사망]` with priority `dead` -> `captured` -> `wounded`; normal heroes have no marker.
- WorldMap selected-city hero lists receive merged `_hero_runtime_states`, and battle formation panels preserve context status fields from BattleContext.
- Post-battle result card hero status lines use the same marker style.
- Captured heroes are still not removed from rosters or excluded from battle; `dead` is display-safe but not applied by gameplay.
- Deferred: captured hero battle exclusion, prisoner movement/holding UI, wound recovery, death, and status stat penalties.

## Previous Patch Note
- `v0.68b-12b-22 Hero Wound Capture Placeholder MVP` applies a deterministic losing-side hero status placeholder after invasion battle results.
- MVP rule: first eligible losing-side hero is marked `wounded`, second eligible losing-side hero is marked `captured`, and `dead` remains unused.
- Captured heroes are not removed from city rosters and no prison/movement/recruit/execution/recovery flow is implemented.
- Status changes are stored in `_hero_runtime_states`, continue through `worldmap_hero_state` save/load, and are summarized in the post-battle result card.
- Deferred: actual capture movement, prison UI, recruitment/execution, wound recovery turns, death, stat-based rolls, and detailed prisoner panels.

## Previous Patch Note
- `v0.68b-12b-21 Post Battle Result Panel Polish MVP` adds an immediate WorldMap post-battle result summary card.
- Invasion result return now builds a display-only summary for defender win, attacker win/city fall, retreat, and unknown paths.
- The card lists ownership change/retention, defender city troop change, attacker source-city troop change, and occupation troops when present.
- The summary is not part of save/load persistence; actual owner/troop state remains in runtime city overrides from the previous patches.
- Deferred result report items remain out of scope: prisoner/wound/death display, resource loot display, detailed combat statistics, and a full report UI.

## Previous Patch Note
- `v0.68b-12b-20 Invasion Casualty Formula Hero State MVP` adds bounded MVP casualty application and hero status persistence fields.
- Defense victory keeps ownership while applying clamped defender city losses and heavier attacker source-city losses; defense defeat transfers ownership and applies occupation troops from attacker survivors/fallbacks.
- Troop math is intentionally temporary balance and clamps values to safe nonnegative bounds.
- `worldmap_hero_state` now stores `status`, `wounded`, `captured`, and `dead`, defaulting missing fields to `normal` / `false`.
- Deferred systems remain out of scope: actual wound/capture/death rolls, hero holding/movement after capture, resource looting, precise battle-power casualty math, AI strategy recalculation, and multi-invasion queues.

## Previous Patch Note
- `v0.68b-12b-19 WorldMap Battle Result Save/Load Persistence MVP` persists invasion-result worldmap runtime state.
- Save data now carries `worldmap_city_state` for city owner/nation/owner_faction_id, troops, and stationed hero ids, plus `worldmap_hero_state` for hero current city ids.
- Load starts from seed city/hero data and applies runtime overrides into `_city_runtime_states` / `_hero_runtime_states`, then refreshes city marker ownership and worldmap UI.
- Pending invasion event/context remains cleared in save/load so completed invasion choices do not reappear after reload.
- Deferred systems remain out of scope: hero wounds/capture/death, resource looting, precise casualty, AI strategy recalculation, and multi-invasion queues.

## Previous Patch Note
- `v0.68b-12b-18c Reinforcement Toast Auto Battle Final Stop Hotfix` closes the support-toast and post-result auto-turn leak left after 18b.
- Confirmed source: reinforcement toast was tied to round/deploy attempt flow, not to a nonempty actual arriving unit list, so no-support WorldMap context battles could still show the arrival toast.
- Reinforcement arrival now records successful deployed units and skips toast/log copy when the list is empty; inactive context slots are not arrival candidates.
- Result-finalized guards now block non-result toast enqueue/playback, enemy callbacks, move/attack finish callbacks, round start, auto action, and reinforcement deployment checks.
- Next QA should F6-check no turn-3 support toast when support is absent, sample battle support toast when real sample support arrives, immediate auto stop after result, and worldmap return.

## Previous Patch Note
- `v0.68b-12b-18b Roster Panel Source Auto Battle End Hotfix` closes the remaining formation-panel sample roster leak after the 18a battlefield-slot fix.
- Confirmed source: `_refresh_formation_slot_guide_for_entry()` could resolve hero identity through capacity-slot `unit_state` before checking WorldMap context-empty metadata, so hidden support slots could still show sample 김유신/을지문덕/유비/제갈량 in the side panels.
- WorldMap context panels now hide empty/inactive context slots and do not call `TEST_BATTLE_ROSTER` fallback; direct `Battle_Fullscreen_Test.tscn` sample fallback remains intact.
- Auto battle now stops at finalized victory/defeat, and deferred phase/auto tick paths have battle-end guards to prevent extra turns after result.
- Next QA should F6-check 백제/사비 invasion panel roster, no sample support cells, result-stop timing for auto battle, and worldmap return.

## Previous Patch Note
- `v0.68b-12b-18a Reinforcement Fallback Leak + Toast Facing Layer Hotfix` blocks sample `TEST_BATTLE_ROSTER` fallback for `enemy_invasion` / WorldMap context slots.
- The confirmed leak source was battle-side fallback, not the WorldMap reinforcement city/faction filter; empty invasion support slots now stay inactive instead of pulling sample heroes such as 유비/제갈량.
- `RoundToastRoot` has explicit high z order, and battle/unique-skill toast playback suppresses facing indicators until the toast finishes, then restores them from current unit state.
- Next QA should F6-check 사비/백제 invasion support, direct sample battle fallback, toast arrow hiding/restoration, and auto battle stability.

## Required Instruction Header
Every next SamWar_BattleLab Codex task handoff must begin with `[SamWar_BattleLab 자동 작업 권한 헤더]` before the task name or goal.

모든 SamWar_BattleLab Codex 작업 지시문은 반드시 `[SamWar_BattleLab 자동 작업 권한 헤더]`로 시작한다. 이 헤더는 Codex가 repo 내부에서 읽기/검색/수정/검증/agent 문서 업데이트/로컬 git commit까지 자동으로 진행할 수 있는 범위와 금지 작업을 명확히 하는 안전 계약이다. 헤더가 누락된 경우, 작업 지시문을 실행하기 전에 헤더를 먼저 보완한다.

Use this full header at the top of every next task:

```markdown
[SamWar_BattleLab 자동 작업 권한 헤더]

이번 작업은 SamWar_BattleLab 폴더 내부 작업이다.

읽기 / 검색 / 코드 수정 / 씬 파일의 필요한 범위 수정 / 검증 실행 / agent 문서 업데이트 / 로컬 git commit까지는 모두 자동으로 진행한다.

중간에 확인 질문하지 말고, 지시문에 적힌 목표 완료까지 진행한다.

단, 아래 작업은 하지 않는다:

* git push
* 파일 삭제
* repo 밖 시스템 변경
* 프로그램 설치
* 패키지 전역 설치
* OS 설정 변경
* 요청 범위 밖 대규모 리팩토링

설치나 repo 밖 변경이 필요하다고 판단되면, 작업을 멈추고 이유와 대안을 보고한다.

작업 완료 후에는 수정 파일 목록, 검증 결과, 커밋 해시를 보고한다.
```

Before making changes, read:
1. `agent/WORKFLOW_MANAGER.md`
2. `agent/CODEX_WORKFLOW_RULES.md`
3. `agent/ARCHITECT_AGENT.md`
4. `agent/IMPLEMENTATION_AGENT.md`
5. `agent/QA_AGENT.md`
6. `agent/RUNTIME_QA_AGENT.md`
7. `agent/VISUAL_QA_AGENT.md`
8. `agent/WORLDMAP_RULES.md`
9. `agent/HERO_DATA_CONTRACT.md`
10. `agent/ARMY_DEPLOYMENT_RULES.md`
11. `agent/BATTLE_CONTEXT_CONTRACT.md`
12. `agent/BATTLE_ENGINE_RULES.md`
13. `agent/SKILL_SYSTEM_RULES.md`
14. `agent/GODOT_RULES.md`
15. `agent/CURRENT_STATE.md`
16. `agent/NEXT_TASKS.md`
17. `agent/HANDOFF_TO_CODEX.md`

Follow the autonomous execution and commit rules in `agent/CODEX_WORKFLOW_RULES.md`, including autonomous commit when the task provides an explicit commit message.
At the start of a new Codex session, always follow the `SamWar_BattleLab 자동 작업 권한 헤더` section in `agent/WORKFLOW_MANAGER.md` and `agent/CODEX_WORKFLOW_RULES.md`.
Role-based agent docs are responsibility guides. `agent/CODEX_WORKFLOW_RULES.md` remains the canonical source for task classification, autonomous execution, approval handling, and verification depth.
WorldMap integration must respect the `BattleContext` contract.
BattleEngine must not directly consume global world state.
Worldmap is not implemented yet, but the worldmap -> battle_context -> battle_engine contract direction is selected.

## Local Godot Execution Path
- Godot 실행파일은 설치형이 아닐 수 있으며 PATH에 없을 수 있다.
- Codex는 Godot 검증 전 `agent/LOCAL_ENV.md`가 존재하는지 확인한다.
- `agent/LOCAL_ENV.md`가 있으면 그 안의 Godot 실행 경로를 우선 사용한다.
- PATH의 `godot`, `godot4`, `godot_console`, `godot4_console` 명령이 실패해도, LOCAL_ENV.md의 exe 경로가 있으면 그 경로로 headless 검증을 시도한다.
- `agent/LOCAL_ENV.md`는 김작 로컬 PC 전용 파일이며 git commit 대상이 아니다.

## Stable Baseline
Current stable baseline is:

`v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`

Latest docs/workflow baseline:

`v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`

Latest UI patch:

`v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix`

Latest camera foundation:

`v0.68a-1 Camera2D World/UI Layer Foundation`

- Latest camera focus patch:
`v0.68a-2 Combat Focus Camera Follow`

- Latest camera overlay hotfix:
`v0.68a-2-hotfix1 Camera-Bound Overlay Sync Fix`

- Latest battlefield visual patch:
`v0.68a-3 Battlefield Large Background Apply + Camera Clamp`

- Latest skill presentation patch:
`v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion`

- Latest worldmap foundation patch:
`v0.68b-1 WorldMap Four-Tile Canvas Foundation`

- Latest worldmap marker patch:
`v0.68b-3 WorldMap City Castle Icon Apply`

- Latest worldmap route patch:
`v0.68b-4 WorldMap Route Layer Path2D MVP`

- Latest worldmap route hotfix:
`v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning`

- Latest worldmap route FX patch:
`v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP`

- Latest worldmap selected city UI patch:
`v0.68b-6 WorldMap Selected City Panel Web Parity MVP`

- Latest worldmap functional marker patch:
`v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch`

- Latest worldmap HUD structure patch:
`v0.68b-8 WorldMap Web HUD Panel Structure Import MVP`

- Latest worldmap HUD visual patch:
`v0.68b-8 WorldMap Web HUD Visual Parity MVP`

- Latest worldmap HUD data patch:
`v0.68b-9 WorldMap HUD Data Binding MVP`

- Latest worldmap domestic web parity patch:
`v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`

- Latest worldmap draggable HUD patch:
`v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`

- Latest worldmap unified panel patch:
`v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`

- Latest worldmap unified panel UX patch:
`v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch`

- Latest worldmap left HUD content patch:
`v0.68b-12b Left World HUD Web Content Parity`

- Latest worldmap seed data audit patch:
`v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit`

- Latest session handoff docs patch:
`v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat`

- Latest worldmap seed import patch:
`v0.68b-12b-1 WorldMap Hero City Seed Data Import`

- Latest worldmap left panel binding QA patch:
`v0.68b-12b-2 WorldMap Left Panel Seed Binding QA`

- Latest worldmap left panel controls patch:
`v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP`

- Latest worldmap left panel policy/warehouse patch:
`v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP`

- Latest worldmap warehouse UI cleanup patch:
`v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup`

- Latest worldmap turn/save patch:
`v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP`

- Latest worldmap turn cycle patch:
`v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`

- Latest worldmap domestic apply patch:
`v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`

- Latest worldmap domestic apply QA patch:
`v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`

- Latest worldmap enemy invasion audit patch:
`v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit`

- Latest worldmap enemy invasion event patch:
`v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`

- Latest worldmap enemy invasion choice UI patch:
`v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP`

- Latest worldmap right city panel cleanup patch:
`v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup`

- Latest worldmap hero portrait binding patch:
`v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP`

- Latest worldmap BattleContext bridge patch:
`v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`

- Latest worldmap battle scene handoff patch:
`v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`

- Latest battle roster context patch:
`v0.68b-12b-13 Battle Roster Context Apply MVP`

- Latest worldmap battle result return patch:
`v0.68b-12b-14 WorldMap Battle Result Return MVP`

- Latest worldmap invasion result apply patch:
`v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`

- Latest worldmap invasion result hotfix:
`v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix`

- Latest worldmap hero battle contract patch:
`v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP`

- Latest worldmap hero placement data patch:
`v0.68b-12b-16b Hero Placement Data Patch`

- Latest hero portrait import metadata audit:
`v0.68b-12b-16c Hero Portrait Import Metadata Audit`

- Latest actual hero portrait binding patch:
`v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`

- Latest battlefield portrait/skill hotfix:
`v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`

- Latest invasion reinforcement source patch:
`v0.68b-12b-18 Invasion Reinforcement Source Rule MVP`

- Latest warning cleanup hotfix:
`v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup`

- Latest session handoff docs patch:
`v0.68b-12b-10.5 Session Handoff Docs Update Before Stop`

- Latest worldmap marker hotfix:
`v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix`

- Latest worldmap tile hotfix:
`v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix`

- Latest worldmap manual layout patch:
`v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control`

- Latest worldmap marker attachment hotfix:
`v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix`

## Core Scene And Scripts
- Worldmap foundation scene: `WorldMap_Test.tscn`
- Worldmap foundation script: `scripts/worldmap_test.gd`
- Worldmap city marker script: `scripts/worldmap_city_marker.gd`
- Core scene: `Battle_Fullscreen_Test.tscn`
- Core scripts:
  - `scripts/battle_web_import_test.gd`
  - `scripts/battle_unit_state.gd`
  - `scripts/unit_visual_slot.gd`

Do not modify casually:
- `Battle_Fullscreen_Test.tscn`

## Current Verified State
- `v0.68b-12b-18 Invasion Reinforcement Source Rule MVP` is complete. WorldMap-launched invasion battles now build attacker/defender rosters from the source city stationed heroes first and add support only from same-faction or explicit-ally cities within direct/2-hop MVP adjacency.
- Distant heroes are no longer force-filled into support slots. Empty context slots are deactivated in the battle scene instead of falling back to sample `TEST_BATTLE_ROSTER` heroes; direct sample battle fallback remains intact.
- 평양 -> 한성 static QA excludes 성도 from the 2-hop candidate set, so 유비/제갈량 are not eligible as ordinary support heroes.
- Save/Load, hero wounds/capture, hero movement, resource looting, precise strategic AI, and city ownership result behavior remain deferred.
- `WorldMap_Test.tscn` is the first worldmap visual canvas foundation.
- `WorldMap_Test.tscn` now stores editor-visible four-tile positions as A1 `(0, 0)`, A2 `(512, 0)`, B1 `(0, 512)`, and B2 `(512, 512)` so the Godot 2D editor can be used for manual city placement.
- The four Tile node positions are now the scene-authored source of truth; runtime does not overwrite Tile positions during `_ready()`.
- `scripts/worldmap_test.gd` computes camera clamp/world rect from the union of the current Tile Sprite2D world rects.
- The four prepared worldmap tiles are arranged as a 2x2 `WorldMapTileLayer` using `Sprite2D.centered = false` and texture-size-based placement.
- `WorldMapCamera` is a scene-authored `Camera2D` configured current at runtime with WASD/arrow pan, right/middle mouse drag pan, optional wheel zoom, and clamp against the combined tile rect.
- `WorldMapUI` is a CanvasLayer with screen-fixed title, camera debug, and input hint labels.
- `v0.68b-8` expands `WorldMapUI` with web-like HUD structure at MVP scope: `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and expanded `CityInfoPanel`.
- City clicks refresh both `CityDetailPanel` and `CityInfoPanel` while preserving `selected_city_id`, `selected_city_marker`, and marker-local `SelectionRing`.
- The HUD buttons are placeholder-only: attack, hero movement, domestic, wild army edit, diplomacy, and spy actions only print debug output or update hint labels.
- `v0.68b-8 WorldMap Web HUD Visual Parity MVP` further tunes the HUD to the actual web CSS look: dark navy translucent panels, thin gold borders, gold/beige headings, dense text, inner cards, tab buttons, red action buttons, progress-bar placeholders, and a centered `SamWar Web` title banner.
- The right HUD uses a fixed multi-column visual layout for Diplomacy/Spy, City Detail, and Selected City. This is a visual parity MVP only and must remain decoupled from real domestic, diplomacy, spy, battle, and army behavior.
- `v0.68b-9 WorldMap HUD Data Binding MVP` adds local display-only HUD data binding on top of the visual HUD: player turn/status data, chancellor portrait/name/stats/policy, governor portrait/name/stats/policy, city loyalty, stationed hero chips, and CityDetail resource/military/trade/rating/governor summaries.
- Chancellor and governor policy `OptionButton` controls update local UI state and explanatory text only. They must not be treated as real domestic policy execution, resource mutation, turn processing, recruitment, hero transfer, or army movement.
- `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP` realigns the current Godot HUD to actual `SamWar_web` source structures. `CityDetailPanel` follows `resource_ui.js` tabs (`자원`, `자국무역`, `타국무역`) with display-only tab switching; `CityInfoPanel` follows `selected_city_ui.js` wording more closely; chancellor/governor policy options follow `constants.js`; city/garrison/governor seed data prioritizes `data/cities.js`, `data/heroes.js`, and `data/battle_rosters.js`.
- The v0.68b-10 tab/policy interactions remain local UI state only. They must not mutate resources, city stats, turns, save/load data, BattleContext, battle scenes, hero transfer, army movement, route logic, or AI.
- `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP` hides the retired top `SamWar Web` banner and old `도시 HUD 위치 이동 · Godot MVP fixed` dragbar at runtime.
- Unlike the web grouped `city-hud-stack` drag flow, Godot panels now move independently: `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` drag only from title/header labels, with no persistence.
- Panel drag should not be expanded into save/load, user config, project settings, domestic execution, battle entry, `BattleContext`, hero/army movement, route logic, or AI.
- `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP` consolidates the former separate City Detail and Diplomacy/Spy HUD surfaces into one `CityDetailPanel`-backed unified panel.
- Unified panel primary tabs are `도시 상세` and `외교·첩보`; secondary tabs are `자원` / `자국무역` / `타국무역` in city-detail mode and `외교` / `첩보` in diplomacy/spy mode.
- The standalone `DiplomacySpyPanel` is hidden at runtime. Keep diplomacy/spy behavior display-only until a dedicated feature task.
- The unified panel has runtime-only collapse/expand; no position/config persistence should be inferred from it.
- `v0.68b-12b Left World HUD Web Content Parity` realigns only the left main `LeftWorldStatusPanel` runtime copy against the actual web `renderWorldHud()`, `renderChancellorCard()`, `renderChancellorPolicyControl()`, and resource/trade summary wording.
- `v0.68b-12b-pre Codex Auto Work Header Rule Documentation` established the required `[SamWar_BattleLab 자동 작업 권한 헤더]` prompt header rule for future tasks.
- `v0.68b-12b` was a left HUD web content parity attempt/investigation flow: inspect actual web left HUD and resource/trade sources, adjust Godot display copy only, and keep all domestic/resource/turn/save behavior non-executing.
- The left HUD now displays web-like `World Turn`, turn/calendar/owner, `국가충성도`, `세금 수준`, chancellor portrait fallback/name/type lines, `재상 임명`, `재상 정책`, `보유 자원`, `국가 창고`, `내부 보급망`, `내부 병력 재배치`, `대외 무역`, and save/load/reset button copy.
- This is still display-only: chancellor policy selection updates explanation/hint text but must not apply policy effects, mutate resources, process turns, save/load/reset, run domestic/diplomacy/spy, move heroes/armies, create `BattleContext`, alter routes/sea arrows, or start battle.
- `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit` completed the source-data audit for the next Godot seed import task without modifying code, scenes, assets, or repo-outside web files.
- Web `heroes.js` is an array structure; the next import should align Godot `HERO_DATA` with `id`, `name`, `factionId`, `side`, `role`, `stats`, `portraitImage`, `battlefieldPortraitImage`, and `chancellorProfile`.
- Web `cities.js` carries `id`, `name`, `region`, `ownerFactionId`, `neighbors`, `routeTypes`, `governorHeroId`, `cityLoyalty`, `resources`, `military`, `domestic`, and `yields`; the next import should preserve these as current display seed data where possible.
- Web `battle_rosters.js` `cityDefenderRosters` is the key source for each city's stationed hero seed data and should map into `CITY_HUD_DATA.stationed_hero_ids`.
- Web `app_state.createInitialDomesticPolicy()` initializes `chancellorHeroId: null`; web `getEligibleChancellorHeroes()` considers active heroes where `hero.side === playerFactionId`; web governor candidates are selected-city stationed player-side heroes with `hero.locationCityId === selectedCity.id`.
- Godot current seed ownership remains in `scripts/worldmap_test.gd`: `HERO_DATA`, `CITY_HUD_DATA`, `CHANCELLOR_POLICY_DATA`, `GOVERNOR_POLICY_DATA`, and `_player_state`.
- Godot current `_player_state.chancellor_id` now uses an empty value for web parity with `chancellorHeroId: null`; the left HUD should display `재상 미임명` and no chancellor effect until a future appointment task.
- Godot current worldmap seed data is display-only string-oriented data, not the full web numeric/stat object model.
- `v0.68b-12b-1 WorldMap Hero City Seed Data Import` is complete and updates only `scripts/worldmap_test.gd` seed data plus agent docs.
- Web sources used were local read-only `SamWar_web/data/heroes.js`, `SamWar_web/data/cities.js`, and `SamWar_web/data/battle_rosters.js`, with constants/app-state references for faction IDs, resource keys, selected city, initial resources, and web no-chancellor default.
- `HERO_DATA` preserves existing HUD compatibility keys while adding web identity/faction/side/role/command/stat/portrait/skill/chancellor-profile seed fields.
- `CITY_HUD_DATA` preserves existing display strings while adding city identity, owner/nation/region/type, population/gold/food/troop/public-order/commerce/agriculture/defense numeric seeds, `hero_ids`, and nested resource/domestic/yield seed dictionaries.
- `_player_state` now includes player faction, selected/origin/ruler city, owned city/hero seed lists, resource stock, and an empty `chancellor_id` to match web `chancellorHeroId: null`.
- The import remains data-only. It did not add movement, appointment execution, policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding changes, scene layout changes, castle icon changes, or web repo edits.
- `v0.68b-12b-2 WorldMap Left Panel Seed Binding QA` is complete and updates only `scripts/worldmap_test.gd` display binding plus agent docs.
- The existing `LeftWorldStatusPanel` now reads imported `_player_state`, `CITY_HUD_DATA`, and `HERO_DATA` seeds for selected/origin city, selected city owner/region/governor/stationed heroes, owned city list, owned hero list, resource stock, and no-chancellor fallback.
- City marker selection now updates `_player_state.selected_city_id` and refreshes the left panel so the current selected city seed is shown without adding movement or appointment behavior.
- The patch added fallback-only display helpers for unknown city/hero ids, empty governor/chancellor states, empty stationed heroes, empty owned heroes, and resource stock formatting.
- This remains display-only. It did not add movement, appointment execution, policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding changes, scene layout changes, castle icon changes, or web repo edits.
- `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP` is complete and updates `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and agent docs.
- Web parity references inspected were local read-only `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, and `js\ui\world_hud_ui.js`.
- The requested `scenes/WorldMap_Test.tscn` path is absent; the active worldmap scene remains root `WorldMap_Test.tscn`.
- The left panel now has seed-backed national loyalty label/status/progress and a tax slider bound to `_player_state.tax_level`.
- Tax changes update visible value/status and web-like income/loyalty preview text only; they do not apply turn income, resources, or permanent loyalty deltas.
- Chancellor assignment now uses selected-city stationed heroes from `CITY_HUD_DATA.stationed_hero_ids` resolved through `HERO_DATA`, with `미임명` as the first dropdown option.
- Chancellor selection updates `_player_state.chancellor_id` only for left-panel UI state and previews imported chancellor-profile effect text; missing portraits fall back to `?`.
- This remains left-panel UI/data-binding scope only. It did not add turn simulation, resource mutation, loyalty application, policy effect execution, movement, appointment system behavior, `BattleContext`, battle transition, route/pathfinding changes, castle icon changes, or web repo edits.
- `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP` is complete and updates `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and agent docs.
- Web parity references inspected were local read-only `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\resource_ui.js`.
- The left panel now has a functional `재상 정책` dropdown backed by `_player_state.chancellor_policy_id` with web options `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`.
- Policy effect text and preview lines now use structured local metadata aligned with web `CHANCELLOR_POLICY_EFFECTS`, including resource multipliers, hero upkeep preview, soldier upkeep preview, and salt preservation preview. Current resource stock is not changed by policy selection.
- The old duplicate visible `보유 자원: ...` summary is retired. `국가 창고` is the authoritative left-panel resource display and reads `_player_state.resource_stock` for current amount, capacity, and status rows.
- This remains left-panel UI/data-binding scope only. It did not add movement, appointment execution beyond UI state, policy effect application to resources, full end-turn simulation, `BattleContext`, battle transition, route/pathfinding changes, castle icon changes, or web repo edits.
- `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup` is complete and updates `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and agent docs.
- The visible `국가 창고` section now uses a boxed runtime `WarehouseCard` instead of the previous plain multiline `SupplyLabel` output.
- The card shows only 9 resource rows (`쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, `소금`, `금전`) with current/max values and status labels bound from `_player_state.resource_stock`, `WAREHOUSE_CAPACITY`, and `_get_resource_status_label()`.
- Internal maintenance/preview lines are hidden from the visible warehouse card: `영웅 유지비`, `병사 유지비 preview`, `보존 소금`, `유지비 정상`, and related explanation lines.
- This remains a narrow UI cleanup. It did not add upkeep/resource production, resource mutation, turn simulation, appointment execution, movement, `BattleContext`, battle transition, route/pathfinding changes, or broader HUD redesign.
- `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP` is complete and updates `scripts/worldmap_test.gd` plus agent docs only.
- The left panel bottom now hides remaining internal/debug lines below `국가 창고`, replaces `야군 편집` with `아군 턴 종료`, and shows web-like `저장 관리` controls.
- `아군 턴 종료` changes `_player_state.turn_phase` from `player` to `enemy`, updates the visible phase label to `적군 턴`, refreshes the left panel, and calls `_run_enemy_turn_mvp()` as a hook only.
- `_run_enemy_turn_mvp()` is intentionally non-simulating: no enemy invasion, AI, city ownership changes, hero movement, `BattleContext`, battle transition, resource ticks, or player-turn return is implemented yet.
- Save/load/reset now persists runtime worldmap/player HUD state to `user://worldmap_left_panel_state.json`, restores it with clean fallback messages, and resets to the startup seed baseline without using repo files for runtime saves.
- `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP` is complete and updates `scripts/worldmap_test.gd` plus agent docs only.
- Web turn-cycle references inspected were local read-only `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\ui\world_hud_ui.js`, `js\ui\world_map_ui.js`, `js\main.js`, `js\core\world_calendar.js`, and `js\constants.js`.
- The current Godot turn loop is now `아군 턴 -> 적군 턴 -> 다음 아군 턴`: `_run_enemy_turn_mvp()` starts a short placeholder timer, `_finish_enemy_turn_mvp()` returns to player phase, and `_advance_world_turn_mvp()` increments `turn_number` once per completed cycle.
- Calendar display follows the web calendar MVP rule: start year `154`, season order `봄/여름/가을/겨울`, `10` turns per season, `40` turns per year.
- Enemy-turn pending state disables the turn-end button during the placeholder and is cancelled on load/reset so duplicate timers do not stack. Save/load/reset preserve phase and turn/calendar state through `_player_state`; loading an enemy-phase save resumes the placeholder return path.
- The turn-cycle patch did not add enemy invasion, target selection, hero movement, city ownership changes, domestic/resource turn application, `BattleContext`, battle transition, route/pathfinding changes, or broad AI simulation.
- `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP` is complete and updates `scripts/worldmap_test.gd` plus agent docs only.
- Web domestic references inspected were local read-only `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\core\world_calendar.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\world_map_ui.js`.
- Domestic apply now runs exactly once at the completed full-cycle boundary: `아군 턴 종료 -> 적군 턴 placeholder -> 다음 아군 턴`.
- The applied MVP subset covers owned-city seasonal income, population/commerce tax gold, tax loyalty delta, chancellor policy income multipliers, active chancellor national modifiers, player hero upkeep deduction, resource stock capacity clamp, warehouse refresh, loyalty refresh, and concise result status text.
- Tax slider and chancellor policy dropdown remain preview controls until the turn cycle applies them; save/load/reset and UI refresh do not apply domestic changes.
- Save/load/reset preserve domestic-updated resources, national loyalty, tax level, chancellor id, chancellor policy, turn phase, turn number, and calendar labels through `_player_state`; runtime saves still use `user://worldmap_left_panel_state.json`.
- The patch did not add enemy invasion, full enemy AI, enemy target selection, enemy hero movement, city ownership changes, governor appointment execution, soldier upkeep application, salt consumption, internal supply/troop rebalance, `BattleContext`, battle transition, route/pathfinding changes, or repo-outside web edits.
- `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check` is complete and updates `scripts/worldmap_test.gd` plus agent docs only.
- The QA stabilization adds `_player_state.last_domestic_apply_turn` and a same-turn guard in `_apply_domestic_turn_mvp()` so resources and loyalty cannot be applied twice by a stale or duplicate callback for the same turn.
- Save metadata now records `v0.68b-12b-7`; save/load/reset continue to preserve domestic-updated resources, national loyalty, tax level, chancellor id/policy, turn phase, turn number, calendar labels, pending state, and the last applied turn guard.
- The visible left panel still keeps tax/policy/chancellor changes preview-only until full turn completion, refreshes warehouse/loyalty/status after apply, and keeps internal debug/warehouse lines hidden.
- `v0.68b-12b-7` did not add enemy invasion, enemy AI, target selection, hero movement, city ownership changes, governor execution, new domestic systems, `BattleContext`, battle transition, route/pathfinding changes, or broad simulation.
- `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit` is complete as a docs-only audit. It created `agent/ENEMY_INVASION_AUDIT.md` and did not modify Godot gameplay code or the root `WorldMap_Test.tscn`.
- Web enemy invasion is rolled in `js/core/app_state.js` `endWorldTurn()` after player-side turn systems using `world_rules.rollEnemyInvasion()` and `ENEMY_INVASION_CHANCE = 0.45`.
- Web invasion candidates are enemy-owned cities whose `neighbors` include player-owned cities. Selection is random among eligible adjacent pairs; no route type, troop threshold, diplomacy/peace check, city strength priority, cooldown, or multi-action enemy world turn was found.
- A successful web invasion creates a defense `pendingBattleChoice` with `battleContext: { type: "defense", attackerCityId, defenderCityId }`; battle starts only after manual/auto defense choice, and city ownership changes only after defense battle retreat/return.
- Web save/load clears pending invasion/battle state and returns to normalized player-turn world mode.
- Godot gap: current `scripts/worldmap_test.gd` has only the enemy-turn placeholder hook. It still needs an invasion event model, pending battle-choice UI, BattleContext bridge, battle return/result ownership apply, and explicit pending-event save/load policy.
- `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP` is complete in `scripts/worldmap_test.gd`; the root `WorldMap_Test.tscn` was inspected but not modified.
- Godot now rolls `ENEMY_INVASION_CHANCE = 0.45` once per enemy placeholder phase, builds candidate pairs from enemy-owned scene city markers whose `neighbors` include player-owned markers, and stores a display-only `_player_state.pending_invasion_event`.
- The event records `type: defense`, `attacker_city_id`, `defender_city_id`, source, and turn number; it selects the defender city and shows `적군 침공 발생: ... · 방어전 준비 필요` in the left world status area.
- Pending invasion events are excluded from runtime save data and cleared on load/reset; enemy-phase saves load back to player turn, matching the web save/load normalization found in `save_load.js`.
- `v0.68b-12b-9` intentionally did not create `BattleContext`, transition to battle, change city ownership, move heroes/troops, resolve battle, add pathfinding, add cooldown/diplomacy checks, or implement enemy AI.
- `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP` is complete in `scripts/worldmap_test.gd`; the root `WorldMap_Test.tscn` was inspected but not modified.
- Godot now creates a runtime `PendingInvasionChoiceCard` in the left world status panel when `_player_state.pending_invasion_event` exists.
- The card shows web-like defense choice copy: `Enemy Invasion`, `적군 침공 발생`, attacker/defender city lines, `방어전을 준비하십시오.`, and `수동 방어` / `자동 방어` buttons.
- The two defense buttons now create runtime-only battle prep data: they validate `_player_state.pending_invasion_event`, write `_player_state.pending_battle_context`, update status text, and keep the pending event intact. They do not start battle, auto-resolve, change ownership, or deduct troops.
- `아군 턴 종료` is disabled/blocked while the pending event exists so enemy invasion events do not stack before the choice flow is handled.
- `v0.68b-12b-10.5 Session Handoff Docs Update Before Stop` is a docs-only wrap-up. No gameplay code or scene file should be inferred as changed by this handoff.
- `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup` is complete.
- The right `CityInfoPanel` now displays selected city name, owner/nation/region, population, gold, food, resource ratings, troops, defense, public support/order, commerce, agriculture, taesu/governor, and stationed hero names from existing seed data.
- The no-selection fallback is clean (`선택 도시 없음`, `월드맵에서 도시를 선택하십시오.`), and the panel avoids raw ids as primary display, raw nulls, dictionary dumps, and old visible placeholder blocks.
- Pending invasion display is still read-only: defender city shows `침공 대상 도시 · 방어전 준비 중`; attacker city shows `침공 출발 도시`.
- Modified files were `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, root `WorldMap_Test.tscn`, and agent docs.
- Web references inspected were `world_map_ui.js`, `world_hud_ui.js`, `ui_render.js`, `selected_city_ui.js`, `app_state.js`, `world_rules.js`, `data/cities.js`, and `data/heroes.js`.
- Verification passed: patch strings present, right-panel display strings present, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP` is complete.
- Added shared portrait helper `scripts/worldmap_hero_portrait_helper.gd`; it reads existing `portrait_image`/portrait path fields, maps legacy `assets/portraits/...` seed paths to `assets/web_battle/portraits/...`, applies compact compatibility paths for known available assets, and safely falls back to `?`.
- The left chancellor card and right taesu/governor card now create runtime `TextureRect` nodes inside the existing portrait boxes. Valid portraits hide the `?` fallback; missing or failed loads clear the texture and show `?`.
- Stationed hero list remains text-only in this MVP to avoid crowding the cleaned right panel, but future pending invasion/defense UI can reuse the shared helper.
- Asset folders inspected: `assets/web_battle/portraits`, `assets/web_battle/portraits_battlefield`, and worldmap/battle asset listings.
- Verification passed: helper/patch strings present, chancellor/governor bindings present, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge` is complete.
- Manual/auto defense context creation includes defense type/source/mode, attacker/defender city ids and names, turn numbers, owner ids, troop totals, stationed hero ids, and governor ids from existing marker/HUD seed data.
- Validation fails safely for missing event, non-defense type, unknown city ids, non-enemy attacker, or non-player defender; failed validation clears only the runtime pending battle context.
- Runtime save policy follows the web audit: pending invasion event and pending battle context are excluded from save serialization and cleared on load/reset normalization.
- `v0.68b-12b-14 WorldMap Battle Result Return MVP` is complete.
- Battle result return uses runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_result`; no save file, repo runtime file, autoload, or project setting was added.
- WorldMap-launched battles show a runtime `월드맵으로 돌아가기` button after victory/defeat, build a defense result payload, and transition back to root `WorldMap_Test.tscn`.
- Result payload fields: source, type, mode, result, winner, attacker/defender city ids and names, and turn number.
- WorldMap consumes and clears the result metadata on startup, shows a Korean defense success/failure status, clears pending invasion event and pending battle context, hides the pending choice card, and refreshes HUD panels.
- Direct `Battle_Fullscreen_Test.tscn` launch remains preserved because no WorldMap context keeps the return button hidden and the demo setup unchanged.
- Final ownership, troop/resource, wounded, hero movement/capture, and persistence apply remain deferred to the next task.
- `v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard` is complete.
- Cause: `_refresh_unified_panel_chrome()` assumed unified panel chrome nodes and runtime-created primary tab buttons were always non-null before `.visible` writes.
- Fix summary: `scripts/worldmap_test.gd` guards unified panel chrome `.visible` / `.modulate` writes and warns once if a chrome node is missing.
- `WorldMap_Test.tscn` was inspected but not modified for this hotfix.
- `v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup` is complete.
- Cause: WorldMap calendar helpers used ambiguous integer `/` expressions for `zero_based_turn / 40` and `(zero_based_turn % 40) / 10`, which triggered Godot reload warnings.
- Fix summary: `scripts/worldmap_test.gd` uses explicit `floori(float(... ) / float(...))` for the intended integer calendar divisions.
- Behavior preservation: calendar output rules remain start year `154`, seasons `봄 / 여름 / 가을 / 겨울`, `10` turns per season, and `40` turns per year; no gameplay, battle, invasion, turn-cycle, domestic, save/load, panel layout, or portrait behavior changed.
- Verification passed: patch strings, calendar constants, touched-file integer division scan, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 console warning cleanliness should still be confirmed during live UI interaction.
- `v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup` is complete.
- Cause: `scripts/battle_web_import_test.gd` used local variable `owner` in `_apply_worldmap_context_side_roster()`, shadowing the base `Node.owner` property.
- Fix summary: renamed the local to `city_owner_id` and updated only local references.
- Behavior preservation: `"source_owner"` metadata and summary `"owner"` output still receive the same WorldMap context value; no gameplay, ownership, battle transition, turn/domestic, or save/load behavior changed.
- Verification passed: repo-local GDScript `var owner` search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 console warning cleanliness should still be confirmed during live UI interaction.
- Verification passed: patch strings, guarded visible assignments, forbidden-scope search, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- `v0.68b-12b-13 Battle Roster Context Apply MVP` is complete.
- `Battle_Fullscreen_Test.tscn` remains the selected battle scene.
- Handoff strategy is still runtime-only through Godot `Engine` metadata key `samwar_worldmap_battle_context`; the battle scene reads it once and direct scene launch keeps the demo setup.
- WorldMap context roster behavior: defender governor/stationed hero ids map onto ally slots, attacker governor/stationed hero ids map onto enemy slots, and current battle-registry-compatible ids replace demo identities where safe.
- Fallback behavior: empty hero arrays, unknown hero ids, missing governor ids, and direct battle launch all keep the existing `TEST_BATTLE_ROSTER` slot identities.
- City troop/garrison values are not applied to combat HP yet; troop scaling remains deferred.
- Selected battle scene is `Battle_Fullscreen_Test.tscn`, using `scripts/battle_web_import_test.gd`.
- Handoff uses runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_context`; the battle scene reads and clears it at startup, then logs mode and attacker/defender city names while preserving the existing demo battle setup.
- Direct `Battle_Fullscreen_Test.tscn` launch without WorldMap context remains supported and logs `No WorldMap battle context; using test battle setup`.
- Current stable baseline for the next session is `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`.
- `v0.68b-12b-17a` restores battlefield portrait badge scale to the old engine baseline: 128px battlefield portraits at scene scale `0.32`, so 512-source `portrait_path` textures display at roughly `41px` on battlefield badges.
- Skill display now treats `장수명 전법` as fallback-only. WorldMap context skill entries reuse existing sample skill names/cutin paths when context data only contains generated fallback names, preserving the old toast frame/animation path where assets exist.
- `v0.68b-12b-17` binds WorldMap BattleContext `portrait_path` into battle UI portraits, scales the single 512-source portrait into the existing 128 Sprite2D portrait slots, and prefers WorldMap context `skill_name` for unique-skill toast text.
- Missing hero portraits use the named common unknown portrait fallback, and missing skill toast/cutin images use a common skill fallback icon. Full cutin presentation, save/load, capture/wounds/death, hero movement, and resource looting remain deferred.
- `v0.68b-12b-16c` confirmed the repo already tracks Godot `.png.import` files, including `assets/heroes/portraits/**`, while `.gitignore` ignores the generated `.import/` cache directory. No untracked portrait `.import` files remained, so none were deleted or newly added.
- `v0.68b-12b-16b` adds/strengthens 유비, 권율, 척준경, 여포, and 하후돈 in WorldMap `HERO_DATA`, with confirmed unique skill names and explicit `portrait_path` / `cutin_path` contracts.
- Placement is now 성도: 유비, 한성: 권율, 평양: 척준경, 낙양: 여포, 업성: 하후돈. 척준경 is no longer stationed in 한성.
- `v0.68b-12b-16` adds actual city hero battle-data copies to WorldMap BattleContext via `attacker_heroes` / `defender_heroes`, with required combat fields and unique-skill fields for every included hero.
- Portrait contract is one 512-source `portrait_path`; 128 battle slots should scale that same source. Cutin/effect images are separate `cutin_path` fields. Existing 128 folders remain and were not deleted.
- Battle scene registers WorldMap context hero/skill data into runtime registries, and still falls back to `TEST_BATTLE_ROSTER` when data is missing or unsupported.
- `v0.68b-12b-15-hotfix1` fixes the read-only city Dictionary crash on F6 manual invasion battle return. Runtime owner/troop changes now duplicate seed/current city state into `_city_runtime_states`, mutate only that runtime copy, and rebind the right panel from merged seed + runtime data.
- `v0.68b-12b-15` result apply is complete: WorldMap consumes returned enemy-invasion defense payloads, preserves ownership on defense victory, transfers the target city to the attacker owner on defense defeat, applies safe nonnegative troop changes, clears pending invasion/context, and refreshes marker/right panel/world HUD.
- Battle result payloads now include attacker/defender owner ids, starting troop counts, and deployed survivor troop totals.
- Retreat/cancel/aborted/unknown results clear pending state safely and do not change ownership.
- User-reported F6 runtime visual check is working normally, and the pending invasion choice UI is good enough for the current MVP.
- Active worldmap scene is root-level `WorldMap_Test.tscn`; `scenes/WorldMap_Test.tscn` may not exist.
- Runtime save path is `user://worldmap_left_panel_state.json`.
- `agent/LOCAL_ENV.md` and `.godot/` are ignored local files and must not be committed.
- Pending invasion event and pending battle context are not persisted on save/load; load/reset clear both following the web audit policy. The scene handoff context is also runtime-only and not saved to `user://`.
- Defense deployment, auto defense resolution, resource battle loss, detailed casualties, hero capture, hero city movement, save/load persistence expansion for resolved city state, enemy strategic AI, enemy multi-action turns, internal supply network, troop redistribution, trade cooldown, soldier upkeep/salt consumption, and full governor appointment execution are still deferred.

## Current WorldMap MVP Systems
- Web hero/city/battle roster seed data imported into Godot.
- Left panel web-parity HUD controls: national loyalty, tax slider, chancellor assignment, chancellor policy, policy effect text, and national warehouse card.
- Turn system: ally turn end button, enemy placeholder, return to next ally turn, turn number/calendar advancement.
- Calendar rule: start year `154`, seasons `봄 / 여름 / 가을 / 겨울`, `10` turns per season, `40` turns per year.
- Save/load/reset via `user://worldmap_left_panel_state.json`.
- Domestic apply once per full turn cycle: tax income, loyalty change, chancellor policy effects, warehouse resource updates, duplicate apply guard.
- Enemy invasion MVP: 45% roll during enemy turn, enemy-owned attacker, neighboring player-owned defender, pending event, defender city auto-selection, pending choice card, manual/auto battle context creation, and ally turn-end blocked while pending.
- BattleContext bridge MVP: `_player_state.pending_battle_context` is runtime-only and stores defense source/mode, attacker/defender ids and names, turn numbers, owners, troops, stationed hero ids, and governor ids for future handoff.
- Battle scene handoff MVP: manual/auto defense stores the full context payload in runtime-only `Engine` metadata and transitions to `Battle_Fullscreen_Test.tscn`; the battle controller consumes the context if present and otherwise keeps the standalone test battle path.
- Invasion result apply MVP: returned defense result payloads are interpreted safely, defense wins keep target ownership, defense losses transfer target ownership to the attacker and set safe occupation troops, and retreat/unknown outcomes never change ownership.
- Hero battle contract MVP: BattleContext now carries actual city hero battle copies and unique-skill contract data while preserving current direct sample battle fallback.
- Right selected-city panel cleanup: selected city name, owner/nation/region, population/resources/economy/military values, taesu, stationed hero list, and pending invasion defender/attacker labels are now readable in the right `CityInfoPanel`.
- Hero portrait binding MVP: the chancellor card and right taesu/governor card use `WorldMapHeroPortraitHelper` to show existing portrait assets where available and keep the stable dark `?` fallback where missing.
- `RouteLayer` contains the first scene-authored route graph MVP: each route root owns route metadata, a `Path2D`, and a `Line2D`.
- Route connection meaning is controlled by exported metadata on `scripts/worldmap_route_path.gd`.
- Actual route shape is controlled by each scene-authored `Path2D.curve`; runtime must not regenerate or overwrite existing route curves.
- `Line2D` visualizes baked `Path2D` points. Land routes use muted earth tones and sea routes use pale blue tones.
- After `v0.68b-4-hotfix1`, land route `Line2D` style is width `4.5` with `Color(0.86, 0.62, 0.32, 0.72)` for better readability on earth-tone terrain; sea route style remains unchanged.
- `v0.68b-5` adds sea-only arrow flow FX through `ArrowFlowRoot` Path2D nodes and four `PathFollow2D` arrow markers per sea route.
- Sea arrow flow references each route's scene-authored `Path2D.curve`, moves one-way from `start_city_id` to `end_city_id`, and remains visual-only.
- Land routes remain line-only with no arrow flow.
- `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` remain the other prepared worldmap layers.
- `CityLayer` contains the first 13 scene-authored `CityMarker_*` nodes based on `SamWar_web/data/cities.js`.
- Each `CityMarker_*` root contains its marker body, name label, and click area/collision shape so root movement carries the whole city marker bundle.
- `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` share the same explicit zero-offset `WorldMapRoot` coordinate basis.
- The current 13 `CityMarker_*` positions have been re-seeded to the 4-tile combined rect so they sit on the map image in the 2D editor.
- After the tile seam fix, the 13 `CityMarker_*` positions are seeded against the corrected 1024x1024 editor-visible combined rect.
- Each city marker stores exported metadata for city id, display name, region id, owner faction id, neighbors, route types, and `web_seed_position`.
- Web `x` / `y` values are only initial seed/fallback placement data; final marker position source of truth is the `CityMarker_*` node position saved in `WorldMap_Test.tscn`.
- City marker positions remain scene-authored source of truth after manual tile layout control.
- City marker click updates `selected_city_id`, keeps `selected_city_marker`, clears the previous marker selection, shows the selected marker's `SelectionRing`, and refreshes `WorldMapUI/CityInfoPanel` from marker metadata.
- `CityInfoPanel` is a reduced Godot port of the web `renderSelectedCityPanel()` shape and displays city name, id, region/owner, type, neighbors, route type summary, MVP status text, and attack / hero-move placeholder buttons.
- `CityInfoPanel` now also displays a selected-city description, garrison placeholder, military placeholder, hint text, and an added domestic placeholder button.
- `CityInfoPanel` now visually includes loyalty progress, governor placeholder, selected-hero chips placeholder, military state placeholder, and recruit placeholder button.
- Castle icon visuals are currently disabled for the functional marker phase. `CastleIcon` nodes and castle icon asset references remain in `WorldMap_Test.tscn`, but they are hidden and controlled by `CASTLE_ICON_VISUALS_ENABLED := false`.
- The visible city marker is currently the lightweight colored `CityDot`; `NameText`, `ClickArea`, `SelectionRing`, selected city state, and `CityInfoPanel` remain active.
- Attack and hero-move placeholders do not create `BattleContext`, change scenes, move heroes/armies, or open domestic detail UI.
- Route click, army movement, pathfinding, battle entry, and `BattleContext` runtime injection remain unimplemented.
- `scripts/worldmap_city_marker.gd` may update marker label/color visuals but must not overwrite marker root positions from web data at runtime.
- City click, city data, route graph, army movement, battle entry, and `BattleContext` runtime injection remain unimplemented.
- Current MVP battle target is stable `5v5`.
- Round flow is stable:
  - `ROUND 1 = 3v3`
  - `ROUND 2 = 4v4`
  - `ROUND 3 = 5v5`
- Enemy AI multi-target engagement is improved and considered stable.
- Hero identity registry is applied by `hero_id`.
- Reinforcement arrival toast is stable.
- Victory / defeat result toast is stable.
- Reinforcement / round / result toast queue is stable.
- Bottom global command bar exists.
- Bottom command bar art-prep structure now exists under `assets/web_battle/ui/bottom_command/`.
- Bottom command buttons are now scene-authored `TextureButton` nodes with the 6 PNG assets connected directly in `Battle_Fullscreen_Test.tscn`.
- `bottom_command_bar_bg.png` is now applied as the scene-authored `CommandBar` background.
- The old black `CommandBar` panel fill is hidden via transparent panel styling.
- Bottom command bar background is treated as MVP-complete and not a blocker for the current baseline.
- 2D editor visibility for the bottom command buttons is restored.
- Legacy large `LeftPanel` / `RightPanel` info panels are hidden/deprecated.
- `BattleMiniLogPanel` and `FormationSlotGuideLayer` are now part of the battle UI.
- Formation slot guide shows only main `3` + reinforce `2` per side and is display-only.
- `UnitCloseupPanel` is hidden and reserved for future popup reuse.
- Formation guide cards now show portrait + name + troop count + troop icon + troop type.
- Formation guide status text is removed; active/reserve distinction is style-based.
- Current locked MVP battle-screen UX is:
  - left ally formation guide `5` cards
  - right enemy formation guide `5` cards
  - lower-left mini log
  - bottom command bar with `3` ink buttons + background panel
  - floating command panel over the battlefield interaction flow
- Floating command panel exists and remains click-to-open.
- Direct move-click UX remains stable.
- Post-move floating panel auto-reopen remains stable.
- Active ally pulse uses the unified root pulse with pivot lock at around `1.5x`.
- `5v5` full auto result path is reachable.
- Headless project / scene launch are expected to remain `0` errors and `GDScript` warnings are expected to remain `0`.
- `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` are now `TextureButton` nodes with existing handlers reused.
- Existing handlers remain reused.
- `RetreatButton` remains a disabled placeholder.
- Current test battle `10` heroes have `hero_id`-based unique skill registry entries.
- Ally manual unique skill use is enabled through `FloatingUniqueSkillButton`.
- Floating unique skill hover tooltip text is intentionally suppressed; button text remains the visible label.
- Formation guide cards include an enlarged `64 x 64` `UniqueSkillReadyIcon` for the currently usable active ally only.
- Deployment markers now sync from scene-authored `Slot` / `UnitVisualRoot` anchors at runtime start and before demo state creation, so moving a unit slot/root in the Godot 2D editor changes the actual deployment marker/grid-cell source as well as the visual group.
- `UnitMarker` nodes are retained as compatibility runtime sync targets and should not be deleted casually.
- Token, portrait, HP bar, troop label, shadow, move dust, click area, READY frame, facing indicator, and status badges are treated as one root-relative visual attachment set through the `UnitVisualSlot` registry.
- Click areas remain scene-level `Area2D` nodes for compatibility, and READY/facing/status overlays remain UI/FX layer nodes, but all are positioned from the slot-synced visual anchor.
- Battlefield status badges now snap badge edge to facing-arrow visual edge instead of using the full facing indicator Control width.
- Vertical-facing battlefield status badges now use left-side arrow edge snap: up-facing and down-facing badges both sit tightly to the arrow's left edge.
- Confusion battlefield badges use the stable `◎N` fallback because the attempted blank-symbol display did not render reliably in Godot.
- `MainCamera` is scene-authored `Camera2D`, configured as current at runtime, and reset to its scene-authored position/zoom before battle reset paths.
- Camera2D controls battle world view only; `BattleUI`, `EnemyRetreatToastLayer`, `CutinOverlay`, and `ResultOverlay` remain CanvasLayer-based screen UI.
- Combat focus camera follows battle start, ally selection, move resolution, combat pair midpoints, strategy/unique skill presentation, enemy attacks, and reinforcement arrival while preserving CanvasLayer UI.
- Unique-skill camera shake uses the current focus baseline so it returns to the focused combat view instead of the original scene center.
- Camera-bound overlays are refreshed during/after Camera2D focus movement, and world-to-UI conversion is based on current `MainCamera` position/zoom so facing indicators and the post-move FacingArrowPanel do not keep stale positions.
- `Battle_Fullscreen_Test.tscn` uses the 3200x1800 worldmap-test battlefield background at `assets/web_battle/battlefield/battlefield_3200x1800_worldmap_test_01.png`.
- Camera clamp prefers the visible battlefield texture rect before falling back to logical board bounds, while current unit deployment remains intentionally unrecentered.
- Ally manual unique skill use now requires range/target selection before resolution.
- Unique skill range overlays are purple and valid target cells are gold/orange.
- Unique skill presentation uses the existing `BattleUI/UniqueSkillToastRoot` as a screen-fixed wide fullscreen cut-in, independent from Camera2D movement/zoom.
- Unique skill cut-in uses the existing skill cutin image enlarged to roughly `96%` viewport width and `52%` viewport height, with large skill-name text over the lower banner.
- Unique skill cut-in now plays as a dynamic impact presentation: short ink flash, side-based slide-in, root scale punch, delayed skill-name pop, short hold, and fast slide/fade-out.
- Unique skill cut-in root now adds punch motion: alpha fade-in, scale `0.85 -> 1.12 -> 1.0`, minimal `0.08s` hold, then upward fade-out / shrink to `0.92`.
- Particles, glow shaders, and sound are intentionally deferred and are not part of this cut-in punch step.
- Unique skill cut-in timing uses `0.14s` enter, `0.04s` skill-name delay, `0.06s` punch settle, `0.08s` hold, and `0.15s` exit; actual damage/buff/FX and camera shake begin after the cut-in exits.
- `UNIQUE_SKILL_CUTIN_TIMING_DEBUG` enables `[UNIQUE_CUTIN]` console logs for SHOW_START, ENTER_DONE, HOLD_START, HOLD_DONE, EXIT_START, HIDE_DONE, and EFFECT_APPLY elapsed times.
- The fullscreen cut-in tween uses explicit enter-parallel, hold interval, and exit-parallel sequencing; the previous `1.5s` hold is no longer used.
- The former `global_scale` / `position` local variables in `scripts/battle_web_import_test.gd` were renamed to avoid Node2D property shadowing warnings.
- Unique skill effect values, target selection, cooldowns, registry data, and AI value gates are unchanged.
- Unique skills have MVP effects for `cannon_aoe`, `ally_attack_buff`, `self_defense_single`, and `single_damage_adjacent_shake`.
- Unique skill damage numbers are larger red labels and unique skills trigger short camera shake.
- Auto battle can use available ally unique skills before falling back to basic attack / movement / wait.
- Enemy AI can use available unique skills on enemy turns and after movement rechecks.
- Unique skill ranges are first-normalized: melee skills require close engagement and AOE remains mid-range.
- Enemy/auto unique skill selection now checks high-value or fallback-value conditions instead of using every ready skill.
- Enemy movement, approach, and basic attack pressure are restored in full-auto flow.
- Unique skill readiness is cooldown-state based; old one-use gating is removed.
- Directional damage bonus is active for basic attacks, enemy hits, and single-target attack unique skills.
- Directional multipliers are front `1.0`, side `1.15`, back `1.3`.
- Formation guide troop icons are readable again while `UniqueSkillReadyIcon` remains `64 x 64`.
- `SkillInfoPanel` remains deferred and is not implemented in the current scene.
- Detailed unique skill range balance remains deferred.

## Recommended Next Task
- Current stable behavior baseline: `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`
- Current docs/contract baseline: `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`
- Immediate next task:
  - `v0.68b-12b-17b Hero Portrait Battle F6 QA Follow-up`
- `v0.68b-12b-17b` goal:
  - F6-check WorldMap invasion manual defense into battle and confirm actual city-roster portraits/skill names display as intended.
  - Keep existing 128 folders, no bulk image deletion or migration, and no battle formula changes.
- Next candidates:
  - `v0.68b-12b-17b Hero Portrait Battle F6 QA Follow-up`
  - `v0.68b-12b-16a WorldMap Hero Battle Data F6 QA Follow-up`
  - `v0.68b-12b-4 WorldMap City Detail Governor / Stationed Hero Web Parity MVP`
  - `v0.68b-12c Selected City Panel Web Content Parity`
  - `v0.68b-12d City Detail Panel Web Content Parity`
  - `v0.68b-12e Diplomacy Spy Panel Web Content Parity`
  - `v0.68b-13 Hero Portrait Asset Naming Contract`
  - `v0.68b-14 Hero Portrait Asset Apply MVP`
  - `v0.68c BattleContext Runtime Injection MVP`
  - `v0.68d Hero/Army Deployment MVP`
- 김작 F6 visual QA remains for `v0.68b-12b Left World HUD Web Content Parity`: confirm left HUD section order resembles the web left HUD, turn/date/phase wording is web-like, chancellor card and policy UI match web labels/descriptions, policy selection only updates explanation, resource/warehouse/supply/troop-rebalance/external-trade summaries use web copy, button text matches web save/load/reset and wild-army edit wording, placeholder feel is reduced, bottom blank space is acceptable, other panels remain intact, independent drag/collapse still works, Selected City remains separate, city-click refresh still works, route/sea arrow flow is normal, castle icon visuals remain hidden, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`: confirm CityDetailPanel and DiplomacySpyPanel appear as one unified panel, primary tabs `도시 상세` / `외교·첩보` are visible, city-detail mode shows `자원` / `자국무역` / `타국무역`, diplomacy/spy mode shows `외교` / `첩보`, tab clicks switch only display content, collapse reduces the panel to a compact reopenable header, the unified panel and CityInfoPanel drag independently, panel dragging does not pan the camera, city clicks still update unified and selected-city content, buttons do not execute real systems, castle icons stay hidden, route lines / sea arrow flow remain normal, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`: confirm the `SamWar Web` banner and `도시 HUD 위치 이동 · Godot MVP fixed` bar are gone, `CityDetailPanel`, `CityInfoPanel`, and `DiplomacySpyPanel` drag independently, other panels do not follow, drag starts only from header labels, buttons/tabs/OptionButtons still click normally, panel dragging does not pan the camera, pan/zoom keeps HUD screen-fixed, city clicks still update Selected City and City Detail, resource/trade tabs and policy UI remain, castle icons stay hidden, route lines / sea arrow flow remain normal, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`: confirm Godot panel structure resembles the actual web HUD source, City Detail tabs/text/buttons follow `resource_ui.js`, Selected City follows `selected_city_ui.js`, chancellor/governor policies follow web constants, web city/governor/hero roster data is reflected where available, tab clicks only switch display, policy selection only changes descriptions, all buttons remain placeholder-only, city clicks update Selected City and City Detail together, castle icons remain hidden, route/sea arrow flow remains normal, HUD stays fixed during pan/zoom, and battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-9 WorldMap HUD Data Binding MVP`: confirm left chancellor portrait/name/stats/policy/resource display, chancellor policy description updates without real effects, city clicks update Selected City and City Detail, selected city governor portrait/name/stats/policy displays, governor policy description updates without real city changes, stationed hero chips display, CityDetail resource/military/trade/rating/governor/stationed hero count updates, all buttons remain placeholder-only, castle icons stay hidden, route lines / sea arrow flow remain normal, HUD stays screen-fixed during pan/zoom, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-8 WorldMap Web HUD Visual Parity MVP`: confirm the left World Turn panel resembles the web version, upper-right Diplomacy/Spy panel is visible, right City Detail panel is visible, Selected City panel visually resembles the web version, panel colors/borders/titles/buttons are close to the web HUD, city clicks update Selected City and City Detail, buttons do not execute real systems, panels stay screen-fixed during pan/zoom, panel coverage is acceptable, castle icon visuals remain disabled, route lines / sea arrow flow remain normal, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-8`: confirm left World Turn/국력/자원 panel, upper-right Diplomacy/Spy panel, right City Detail panel, right Selected City panel, city-click updates for City Detail and Selected City together, screen-fixed HUD behavior during pan/zoom, non-obstructive panel coverage, placeholder-only attack/hero-move/domestic buttons, castle icon visuals still disabled, route line / sea arrow flow continuity, and existing battle scene stability.
- 김작 F6 visual QA remains for `v0.68b-6a`: confirm castle icons are not visible, city name labels and simple functional markers remain visible, city clicks still select cities, selected markers show `SelectionRing`, `CityInfoPanel` appears normally, route lines and sea arrow flow remain normal, pan/zoom keeps city clicking normal, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-6`: confirm city marker click selection, selected marker ring readability, fixed `CityInfoPanel` placement, city name/id/region/owner/type/neighbors/routeTypes text, attack / hero-move placeholder visibility, pan/zoom click behavior, route line and sea arrow flow continuity, city click/UI non-regression, and existing battle scene stability.
- 김작 F6 visual QA remains for `v0.68b-5`: confirm sea route arrows are visible, follow `Path2D` curves naturally, wrap from route end to start, move at a readable speed, do not cover city names/icons, land routes have no arrows, pan/zoom keeps arrows attached to the map, city click info panel remains normal, and existing battle scenes are stable.
- 김작 F6 visual QA remains for `v0.68b-4-hotfix1`: confirm land routes are clearly more visible than before, do not disappear into mountain/plain earth tones, do not overpower city castle icons, sea route style still feels unchanged, pan/zoom keeps routes attached, `Path2D` curve editability remains intact, city click info panel still works, and existing battle scenes remain stable.
- 김작 2D/F6 visual QA remains for `v0.68b-4`: confirm `RouteLayer` route roots have `Path2D` and `Line2D`, route curves are editable in the 2D editor, route lines roughly connect city markers, land/sea routes are visually distinct without covering city markers, camera pan/zoom keeps route lines attached to the map, city click info panel remains normal, and existing battle scenes are stable.
- Known issue retained: CityMarker root movement / name text attachment still needs manual confirmation and was not changed by the route-layer MVP.
- 김작 2D/F6 visual QA remains for `v0.68b-3`: confirm all 13 cities show castle icons instead of dots, Korea/China/Japan/Ordo icon mapping is correct, `CityMarker_*` root movement carries `CastleIcon`, `NameText`, and `ClickArea/CollisionShape2D`, city names do not severely overlap icons, marker click info panel remains normal, camera pan/zoom/clamp remains normal, and the battle scene is stable.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix6`: move `CityMarker_Hanseong` root and confirm the Node2D `NameLabel` text visibly moves with `CityDot` and `ClickArea/CollisionShape2D`; repeat spot checks on other city markers; save with Ctrl+S and confirm F6 preserves the bundle.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix5`: move `CityMarker_Hanseong` root and confirm `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D` move together; repeat spot checks on the other 12 cities; Ctrl+S persistence; marker click info panel; camera pan/zoom/clamp; and battle scene stability.
- Codex Godot headless verification for `v0.68b-2-hotfix5` may be blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output if needed.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix4`: move `CityMarker_Hanseong` root and confirm marker body, name label, and click area move together; check all other city marker roots; Ctrl+S persistence; marker click info label; camera pan/zoom/clamp; and battle scene stability.
- Codex Godot headless verification for `v0.68b-2-hotfix4` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix3`: select/move the four Tile nodes in the 2D editor, Ctrl+S, confirm F6 preserves the saved layout, camera clamp follows the current tile union rect, all 13 city markers remain present, and the battle scene is not broken.
## v0.70-13a Handoff
- Battle intro timing was polished after QA feedback that gameplay zoom started too quickly.
- Current values:
  - `BATTLE_INTRO_WIDE_HOLD_SEC = 0.85`
  - `BATTLE_INTRO_ZOOM_SEC = 1.15`
  - `BATTLE_INTRO_UI_FADE_SEC = 0.25` unchanged
- Skip behavior, UI restore timing, input guard, and gameplay camera restoration are unchanged from v0.70-13.
- No battle logic, result/worldmap flow, cutin/result video assets, archer volley FX, or gunner shot FX should be considered changed.
- Manual QA: confirm the wide shot is appreciable without dragging, zoom-in feels less rushed, UI appears after zoom, and skip remains immediate.

## v0.70-13 Handoff
- Battle start now has a visual-only intro camera zoom sequence.
- Implementation is in `scripts/battle_web_import_test.gd`:
  - `_capture_battle_gameplay_camera_state()` stores normal gameplay camera position/zoom.
  - `_play_battle_intro_camera_zoom()` starts from a wider battlefield shot and tweens back to gameplay.
  - `_skip_battle_intro_camera_zoom()` immediately restores gameplay camera/UI.
  - `_set_battle_intro_ui_visible()` hides/restores `BattleUI`.
- Skip input during the intro: mouse click, Space, Enter, numpad Enter, or Esc.
- Input/button guards prevent move/attack/strategy/unique skill/wait/auto actions while the intro is playing.
- No grid logic, combat logic, battle result/worldmap flow, cutin/result video assets, archer volley FX, or gunner shot FX should be considered changed.
- Manual visual QA: check wide battlefield readability, zoom landing position, UI restore, skip behavior, and normal battle controls after intro completion/skip.

## v0.70-12a Handoff
- Battle result videos now use a centered cinematic panel instead of full-screen playback.
- Implementation is in `scripts/battle_web_import_test.gd`: `_get_battle_result_video_panel_rect()` computes a centered 16:9 rect and `_prepare_battle_result_video_panel()` applies it before playback.
- `Battle_Fullscreen_Test.tscn` has the result video node default rect set to the same panel footprint; runtime still recalculates from viewport size.
- Victory/defeat result flow remains: result video -> existing result toast -> existing return/result handling.
- Result video load failure and fallback timer still route to the existing toast.
- No cutin mappings/assets, archer/gunner FX, battle result payload, or worldmap logic should be considered changed.
- Manual visual QA: confirm victory and defeat videos appear as a central panel, keep readable aspect, do not duplicate toasts, and preserve result/worldmap flow.

- Codex Godot headless verification for `v0.68b-2-hotfix3` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix2`: confirm 4 tiles attach as one map in the 2D editor, no gray band appears between rows, no left/right seam gap appears, all 13 city markers sit on the map, debug rects do not block placement, camera pan/zoom/clamp remains normal, UI labels stay fixed, and the battle scene is not broken.
- Codex Godot headless verification for `v0.68b-2-hotfix2` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 F6 visual QA remains for `v0.68b-2-hotfix1`: confirm all 13 city markers sit on top of the 4-tile map image in the 2D editor, no marker is in the lower gray area, `CityLayer` and `WorldMapTileLayer` share coordinates, editor move-and-save persists marker positions, camera pan/zoom/clamp remains normal, UI labels stay fixed, and the battle scene is not broken.
- Codex Godot headless verification for `v0.68b-2-hotfix1` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 F6 visual QA remains for `v0.68b-2`: confirm all 13 city markers are visible under `CityLayer`, marker labels/colors are readable enough for MVP placement, editor move-and-save persists marker positions, camera pan/zoom keeps markers attached to the map, and no city click/battle entry behavior exists yet.
- Codex Godot headless verification for `v0.68b-2` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 F6 visual QA remains for `v0.68b-1`: confirm `WorldMap_Test.tscn` shows all 4 tiles as one map without visible gap/overlap/seam, Camera2D pans smoothly, clamp avoids excessive gray outside area, UI labels stay screen-fixed, future layers exist in the scene tree, and existing `Battle_Fullscreen_Test.tscn` is not broken.
- Codex Godot headless verification for `v0.68b-1` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 F6 visual QA remains before treating layout feel as final: move `Slots/AllyReinforce01Slot` and confirm ROUND 2 김유신 spawn plus HP/troop/portrait/click/facing/status alignment.
- 김작 F6 visual QA also remains for status badge placement: confirm `→` badges sit left of arrow, `←` badges sit right, `↑` and `↓` badges sit tightly on the arrow's left edge, confusion remains `◎N`, and multi-status groups attach as one badge block.
- 김작 F6 visual QA remains for Camera2D foundation: confirm F6 shows the normal battle screen, fixed UI panels/toasts stay screen-anchored, `MainCamera` is current, existing camera shake still works, and the battle loop remains stable.
- 김작 F6 visual QA remains for combat focus: confirm battle start, ally selection, move completion, attack midpoint, enemy attack midpoint, strategy/unique skill, and reinforcement arrival are visible; UI stays fixed; status badge fix6 remains intact; and camera shake returns to the current focus.
- 김작 F6 visual QA remains for overlay sync: confirm first-screen facing indicators sit on units, post-move direction arrows appear around the active unit after camera focus, no overlay stays in a stale gray/off-unit area, and camera shake does not desync overlays.
- 김작 F6 visual QA remains for the large battlefield: confirm the new background is visible without gray/empty areas during camera follow/shake, current separated starting positions are preserved, and direction/status/UI overlays remain synced.
- 김작 F6 visual QA remains for fullscreen unique skill cut-ins: confirm the cut-in strongly fills the screen on the 3200x1800 battlefield, UI panels/buttons are not broken, timing is not sluggish, existing damage/buff/FX happens after cut-in exit, camera focus does not jump, camera shake returns to the current focus, status badge fix6 remains intact, and normal attack/strategy/defend flow remains stable.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix1`: confirm the cut-in/toast holds for about `1.5s`, does not vanish too quickly, enter/exit remain short, post-cutin effects still apply, camera shake returns to current focus, and GDScript warning output no longer includes `global_scale` / `position` shadowing.
- `v0.68a-4-hotfix2` timing trace logs remain available for diagnosis, but the `1.5s` hold check is superseded by the toast-tempo match timing.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix2` tempo match: confirm the cut-in feels close to turn-exchange toast tempo, is still readable, no longer lingers like the `1.5s` hold, enter/exit remain snappy, post-cutin effects still apply, camera shake returns to current focus, and GDScript warnings stay clean.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix3`: confirm the cut-in hits strongly without lingering, total feel is around `0.6s`, skill name / general image remains momentarily clear, post-cutin effects apply naturally, battle tempo is not interrupted, and GDScript warnings stay clean.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix4`: confirm the cut-in does not look like a static large toast, slide-in feels forceful, scale punch is visible, ink flash is brief, skill-name pop reads, cut-in exits quickly into battlefield damage/buff/FX/camera shake, Camera2D does not jump, status badge fix6 remains intact, and normal attack/strategy/defend flow remains stable.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix6`: confirm the cut-in pops from small scale into a fast overshoot punch, exits upward while shrinking/fading, does not linger or feel like buffering, has no scale/position accumulation on repeated unique skills, and preserves UI, status badge fix6, damage/buff/FX, camera shake, and normal attack/strategy/defend flow.

## Important Direction
- Keep the current battle screen interaction baseline stable before new UX/art expansion.
- Enemy AI multi-target engagement is completed stable functionality, not an open known-issue track.
- Scene portrait textures are not the final identity source of truth.
- `capacity_slot_id -> assigned_hero_id -> HERO_REGISTRY` remains the intended identity path.
- Worldmap integration should build on the current stable `5v5` roster/battle contract path.
- The battle engine must not choose heroes directly; it should consume future `BattleContext.roster`.
- Worldmap / army systems own encounter creation, battle type, terrain, region, and `map_variant_id` selection.
- BattleEngine must not directly consume global world state.
- Contract docs for this direction live in `agent/WORLDMAP_RULES.md`, `agent/HERO_DATA_CONTRACT.md`, `agent/ARMY_DEPLOYMENT_RULES.md`, `agent/BATTLE_CONTEXT_CONTRACT.md`, `agent/BATTLE_ENGINE_RULES.md`, and `agent/SKILL_SYSTEM_RULES.md`.

## Do Not Break
Canonical regression guard details are also tracked in `agent/QA_AGENT.md`.

- Damage / move / attack formulas.
- Hero identity registry behavior.
- Reinforcement deploy timing.
- Reinforcement / round / result toast queue.
- Direct move-click.
- Right-click rollback / cancel behavior.
- Floating panel click-to-open behavior.
- Post-move panel reopen.
- Active ally pulse pivot lock.
- Current `5v5` actor / target parity.
## v0.68b-12b-28 Handoff
- Deployment UX polish is in `scripts/player_attack_deployment_panel.gd` and player_attack feedback copy is in `scripts/worldmap_test.gd`.
- Panel now shows source/target, source troops, max deployable troops, total assigned troops, remaining garrison, and supply enough/shortage lines.
- Confirm is blocked with visible reason for no selected hero, zero troops, source reserve violation, troop overflow, and food/gold/salt shortage.
- Confirm feedback logs `[PLAYER_ATTACK_DEPLOY]` and sets WorldMap status with assigned troop and supply consumption.
- Player attack result summary now uses clearer occupation/failure copy; owner/troop logic is unchanged.
- F6 manual QA was not performed by Codex in this environment; verify panel size/position, SpinBox input, supply shortage states, sortie transition, victory/defeat result, save/load, and enemy invasion regression.

## v0.68b-12b-32 Handoff
- CommandRank/commandLimit parity is implemented in `scripts/worldmap_test.gd` and surfaced in `scripts/player_attack_deployment_panel.gd`.
- Web constants are mirrored: `governor=10000`, `general=8000`, `lieutenant=6000`, `officer=5000`; unknown rank falls back to officer, and legacy `captain` maps to `lieutenant`.
- A city governor receives governor command rank for allocation without changing hero data.
- Player attack deployment rows now show command label/limit, and SpinBox max is capped by `min(command_limit, source_city_troops - 1)`.
- Confirm validation clamps allocation by command limit and remaining source garrison before source troop pre-decrement.
- Enemy invasion defense default allocation and player attack defender allocation now use commandLimit distribution; the old even allocation helper remains as fallback.
- F6 manual QA remains required for visible command-limit display, over-limit input blocking, player attack win/loss troop accounting, enemy invasion defense win/loss, and woundedQueue save/load/recovery.

## v0.68b-12b-33D Handoff
- `PlayerAttackDeploymentPanel` is now shared by player attack and enemy invasion defense through `deployment_type`.
- Manual/auto defense buttons call `_open_defense_deployment_panel_from_pending_invasion()` instead of immediate battle handoff.
- Defense mode panel title/copy changes to 방어 준비 / 방어 확정 and suppresses extra supply-cost validation.
- Defense confirm path is `_confirm_defense_deployment()` -> `_build_battle_context_from_pending_invasion(..., selected_defender_hero_ids, allocation)` -> existing attacker/defender pre-decrement -> battle handoff.
- BattleContext now carries `selected_defender_hero_ids`, selected `defender_troop_allocation`, `defender_total_allocated_troops`, and existing before/after pre-decrement metadata.
- Cancel only closes the panel/status and keeps `pending_invasion_event`.
- F6 QA still needed: invasion popup -> defense panel open, defender selection/allocation, commandLimit clamp, battle transition, defense victory/defeat accounting, woundedQueue recovery, and player attack regression.

## v0.68b-12b-27 Handoff
- Player attack no longer jumps directly into `Battle_Fullscreen_Test.tscn`; `_start_player_attack_battle()` opens `PlayerAttackDeploymentPanel`.
- New script: `scripts/player_attack_deployment_panel.gd`.
- Confirm path: panel `deployment_confirmed` -> `_confirm_player_attack_deployment()` -> source-city supply validation/payment -> `_build_player_attack_battle_context(..., selected_hero_ids, allocation, supply_cost)` -> existing battle handoff.
- BattleContext now carries `selected_attacker_hero_ids`, `attacker_troop_allocation`, `supply_cost`, and `supply_source_city_id`.
- Source-city supply stock is runtime city state `resource_stock`; missing food/rice, gold, or salt is defaulted only for the source city when opening deployment. Save/load persists this field in `worldmap_city_state`.
- Manual QA still needed for F6 click flow, UI sizing, insufficient resource blocking, post-deployment win/loss result, and save/load after source-city supply payment.
