# SESSION LOG

## 2026-05-29

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
