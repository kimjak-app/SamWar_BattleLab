# WORLDMAP RULES

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
