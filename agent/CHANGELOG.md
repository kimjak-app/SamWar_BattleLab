# CHANGELOG

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
