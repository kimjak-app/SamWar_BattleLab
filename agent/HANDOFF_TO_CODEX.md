# HANDOFF TO CODEX

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
  - `v0.68b-12b-3b WorldMap Chancellor Policy Effect Web Parity`
- `v0.68b-12b-3b` goal:
  - Verify and refine chancellor policy effect copy/preview behavior against the web implementation.
  - Keep the cleaned `국가 창고` card row-only unless the task explicitly adds a separate preview area.
  - Do not add gameplay logic, movement, appointment execution, actual policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding changes, scene layout changes, or web repo edits.
- Next candidates:
  - `v0.68b-12b-3b WorldMap Chancellor Policy Effect Web Parity`
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
