# P-1A | WorldMap 16:9 Production Promotion Audit

Date: 2026-09-19
Branch: `refactor/production-runtime-unification-20260919`
Baseline: `68790fb2d328c53f0cc1f1a4735f895c9a9ed421`
Plan revision: `PRU-20260919-1`

## 1. Executive finding

`WorldMap_16x9_Test.tscn` is no longer a narrow resolution test.

It is a composition host that instances the real `WorldMap.tscn` as `ProductionWorldMap` and then layers a substantial accepted presentation stack around it:

- 16:9 map geometry and camera baseline;
- newer background;
- approved city positions;
- compact HUD;
- turn-end compass;
- top navigation;
- territory overlay;
- city contextual action menu;
- action video/result presentation;
- turn summary;
- character speech;
- warehouse/resource presentation;
- garrison presentation;
- readability/refinement;
- several compatibility guards that suppress legacy presentation.

Therefore, continuing to treat `WorldMap_16x9_Test.tscn` as the main working scene would extend the production/test split.

**P-1B should make `WorldMap.tscn` itself the accepted 16:9 scene.**

## 2. Current canonical-production gap

The current `WorldMap.tscn` does not contain the following objects/assets that the 16:9 host adds or creates:

- `WorldMapTopNav`;
- `WorldMapActionPresentation`;
- `TurnEndCompass`;
- territory overlay;
- Design-2 background asset;
- 16:9 HUD position owner;
- turn-summary popup;
- character-speech popup;
- hover tooltip;
- compact garrison view;
- test-host approved 13-city position override.

The current WorldMap battle handoff remains:

```gdscript
const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"
```

That route must remain unchanged during P-1B and only switch in P-1D.

## 3. 16:9 host responsibility audit

| Current component | Current role | P-1 classification | Production decision |
|---|---|---|---|
| `worldmap_16x9_test_host.gd` | Master 16:9 composition baseline, city positions, label offsets, compact HUD, camera fit, compass creation | **PROMOTE BEHAVIOR / DO NOT COPY HOST** | Split accepted constants/layout into production scene/controllers; wrapper remains QA only |
| `worldmap_v2_background_test_controller.gd` | Replaces old W1 background with accepted Design-2 | **PROMOTE** | Make Design-2 the production background source; remove runtime "test wins later" override |
| `worldmap_territory_test_controller.gd` | Ownership territory shader overlay | **PROMOTE + RENAME** | Production `WorldMapTerritoryController` or equivalent, below routes/cities and above background |
| `worldmap_hud_position_test_controller.gd` | Sole position writer for accepted left/right HUD | **PROMOTE + RENAME** | Production HUD layout owner; preserve viewport clamp and user-position ownership |
| `WorldMapTopNav.tscn` + `worldmap_top_nav.gd` | Accepted top menu, tech-tree/system routing | **PROMOTE NEARLY AS-IS** | Instance directly in production WorldMap |
| `WorldMapActionPresentation.tscn` + controller | Diplomacy/trade/spy video + result presentation | **PROMOTE NEARLY AS-IS** | Instance directly in production scene and bind production signals |
| `worldmap_city_action_test_controller.gd` | Context menu for spy/diplomacy/trade/battle | **PROMOTE BEHAVIOR / REWRITE BOUNDARY** | Rename production controller; remove test-only video signal and legacy-button dependency where practical |
| `worldmap_turn_compass.gd` | Accepted turn-end compass and serialized turn request | **PROMOTE** | Persist compass in production scene rather than creating it from test host |
| `WorldMapTurnSummaryPopup.tscn` | Accepted turn summary presentation | **PROMOTE UI** | Production popup is suitable |
| `worldmap_turn_summary_test_bridge.gd` | Builds summary by scraping existing labels/log text | **REWRITE FOR PRODUCTION** | Keep presentation, replace test bridge with structured turn-summary producer/controller |
| `WorldMapCharacterSpeechPopup.tscn` | Accepted character response popup | **PROMOTE UI** | Production popup is suitable |
| `worldmap_character_speech_test_bridge.gd` | Detects admin assignment/policy changes and triggers speech | **PROMOTE BEHAVIOR / REWIRE** | Bind explicit production events/signals; do not retain polling/test bridge ownership |
| `WorldMapHoverTooltip.tscn` | Accepted hover help presentation | **PROMOTE UI** | Production scene/component is suitable |
| `worldmap_panel_refinement_test_controller.gd` | Stability/tax colors, tooltips, domestic metric row | **FOLD INTO PRODUCTION PRESENTATION** | Static style into scene/theme; dynamic formatting into HUD/presentation controller |
| `worldmap_warehouse_tabs_test_controller.gd` | Compact warehouse/resource tabs derived from legacy labels | **PROMOTE DESIGN / REWRITE DATA BINDING** | Persist accepted tab UI; bind structured resource data instead of parsing label text |
| `worldmap_garrison_compact_test_controller.gd` | 3-column compact garrison view mirrored from legacy list | **PROMOTE DESIGN / REWRITE DATA BINDING** | Persist compact grid and bind garrison data directly; remove hidden duplicate list dependency |
| `worldmap_readability_test_controller.gd` | Typography/portrait sizing/admin-role readability | **FOLD INTO SCENE/THEME** | Persist accepted sizes and typography; retain reusable role resolver only |
| `worldmap_tech_badge_test_controller.gd` | Static sample tech badges | **QA ONLY** | Do not promote sample data. Future production badges must use actual completed-tech state |
| `worldmap_left_panel_lock_guard.gd` | Re-hides legacy UI that production republishes | **TEMPORARY COMPATIBILITY — REMOVE** | Correct production visibility/layout instead of shipping a per-frame lock |
| `worldmap_stable_hud_mirror_controller.gd` | Duplicates dynamic labels/bars, hides original source forever | **TEMPORARY COMPATIBILITY — REMOVE** | Production HUD must render final values directly; do not ship mirror copies |
| `worldmap_turn_transition_late_guard.gd` | Pre-draw coordinator that repeatedly reasserts test presentation | **TEMPORARY COMPATIBILITY — REMOVE** | Replace with deterministic production refresh order/signals |
| `worldmap_16x9_editor_preview.gd` | Editor-only mirror of runtime test composition | **EDITOR/QA ONLY** | Keep only until production scene itself shows the accepted layout in editor, then retire |
| `WorldMap_16x9_Test.tscn` | Wrapper/composition host | **QA PARITY SCENE** | Keep temporarily as a comparison consumer; no longer primary development target after P-1B |

## 4. What is already production-quality enough to instance directly

The following are production-named, self-contained components and already target production interfaces rather than test-only game state:

### Top navigation

`WorldMapTopNav.tscn` / `worldmap_top_nav.gd`

- Builds the accepted top navigation.
- Calls the production tech-tree opener.
- Owns the system/audio popup.
- Can be instanced directly under a production CanvasLayer.

### WorldMap action presentation

`scenes/worldmap/ui/WorldMapActionPresentation.tscn`

`worldmap_action_presentation_controller.gd`

- Connects to `contextual_worldmap_action_presentation_requested`.
- Connects to `contextual_worldmap_action_resolved`.
- Calls `complete_contextual_worldmap_action` on the production WorldMap.
- Already separates presentation from strategic mutation.

These two should not stay test-host-only.

## 5. What must not be promoted as-is

### Stable HUD mirrors

The test composition currently creates duplicate labels/progress bars, hides the source controls forever, and synchronizes the duplicates.

That solved QA instability but is the wrong final architecture.

P-1B must make the visible production nodes themselves stable.

### Visibility/late guards

The left-panel lock and late pre-draw guard repeatedly fight production nodes that become visible again.

Shipping those guards would preserve a race rather than remove it.

### Data scraping

The current turn-summary and warehouse presentations derive structured UI by parsing existing label/log strings.

For production:

- turn summary should consume structured turn outcome data;
- resource tabs should consume resource state/model data;
- garrison compact view should consume hero/garrison data directly.

### Static tech samples

The tech-badge test controller contains hard-coded sample badges. It is visual QA only and must not become player state.

## 6. Accepted visual baseline to promote

The 16:9 host defines the currently accepted world-space baseline:

- world size: `2048 × 1152`;
- source background atlas: `4096 × 2304`;
- accepted Design-2 background: `worldmap_bg_v2_test.png`;
- city label Y offset: `16`;
- left compact HUD width: `320`;
- right compact HUD width: `308`;
- garrison compact height: approximately `96–142`, depending on final direct production layout;
- camera zoom bounds: `0.35–1.6`.

Approved 13-city positions currently supplied by the test host:

| City | Position |
|---|---:|
| Karakorum | (1029.5, 272.5) |
| Yecheng | (842.5, 499.0) |
| Pyeongyang | (1178.0, 342.0) |
| Hanseong | (1235.0, 424.5) |
| Luoyang | (765.0, 586.5) |
| Gyeongju | (1303.0, 488.5) |
| Sabi | (1236.0, 523.5) |
| Edo | (1602.5, 414.5) |
| Jianye | (955.0, 670.0) |
| Kyoto | (1543.5, 492.5) |
| Osaka | (1513.5, 567.0) |
| Chengdu | (408.5, 730.5) |
| Kyushu | (1397.5, 628.5) |

These positions and route refresh behavior should become production-owned in P-1B rather than being reapplied after `WorldMap.tscn` loads.

## 7. P-1B migration order

To minimize regressions, promote in this order.

### P-1B-1 | Visual world baseline

1. Design-2 background.
2. 2048×1152 world geometry.
3. approved city positions.
4. label offsets.
5. route refresh.
6. camera baseline.

Acceptance: opening `WorldMap.tscn` alone shows the same world geometry as the 16:9 host.

### P-1B-2 | Persistent production HUD layout

1. left/right compact panel geometry;
2. production HUD position owner;
3. accepted typography;
4. compact garrison direct view;
5. warehouse/resource tabs;
6. stability/domestic presentation.

Acceptance: no mirror/lock/late-guard controllers required to keep HUD stable.

### P-1B-3 | Production interaction/presentation components

1. TopNav;
2. TurnEndCompass;
3. contextual city action controller;
4. ActionPresentation;
5. hover tooltip;
6. character speech;
7. turn summary.

Acceptance: these work from `WorldMap.tscn` without a parent node named `WorldMap_16x9_Test` or `ProductionWorldMap`.

### P-1B-4 | Territory overlay

Promote and rename territory controller after the production city/background geometry is stable.

Acceptance: territory rendering is below route/city markers and updates from actual ownership state.

### P-1B-5 | Remove compatibility scaffolding

Remove production dependence on:

- `worldmap_left_panel_lock_guard.gd`;
- `worldmap_stable_hud_mirror_controller.gd`;
- `worldmap_turn_transition_late_guard.gd`;
- runtime use of `worldmap_16x9_editor_preview.gd`.

Keep `WorldMap_16x9_Test.tscn` only as a temporary parity/QA scene until visual and interaction parity is proven.

## 8. P-1B acceptance gate

P-1B is not complete until all of the following are true:

1. Opening/running `WorldMap.tscn` alone shows the accepted 16:9 background, cities, routes, camera and HUD.
2. Top navigation works from `WorldMap.tscn`.
3. Turn-end compass works and one full turn completes.
4. Left/right HUD does not require mirror or visibility-guard controllers.
5. City selection, compact garrison, resources and admin data refresh correctly.
6. Contextual spy/diplomacy/trade/battle menu works on enemy cities.
7. Action video/result presentation works.
8. Territory overlay matches current ownership.
9. No player-facing production feature depends on a path beginning with `../ProductionWorldMap`.
10. `WorldMap_16x9_Test.tscn` can be retained as QA but is no longer the primary player-facing scene.
11. WorldMap still routes to `Battle_Land.tscn` until P-1D.

## 9. P-1A result

P-1A recommends proceeding to **P-1B | WorldMap Canonicalization**.

The correct strategy is **promotion and cleanup**, not replacing `WorldMap.tscn` with the entire test host.
