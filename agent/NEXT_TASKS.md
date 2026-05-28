# NEXT TASKS

## Current Stable Baseline
Behavior baseline: `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`

Docs/contract baseline: `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`

Latest UI patch: `v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix`

Latest camera/background patch: `v0.68a-3 Battlefield Large Background Apply + Camera Clamp`

Latest skill presentation patch: `v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion`

Latest worldmap foundation patch: `v0.68b-1 WorldMap Four-Tile Canvas Foundation`

Latest worldmap marker patch: `v0.68b-3 WorldMap City Castle Icon Apply`

Latest worldmap route patch: `v0.68b-4 WorldMap Route Layer Path2D MVP`

Latest worldmap route hotfix: `v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning`

Latest worldmap route FX patch: `v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP`

Latest worldmap selected city UI patch: `v0.68b-6 WorldMap Selected City Panel Web Parity MVP`

Latest worldmap marker hotfix: `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix`

Latest worldmap tile hotfix: `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix`

Latest worldmap manual layout patch: `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control`

Latest worldmap marker attachment hotfix: `v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix`

## Priority 1
`v0.68b-7 WorldMap City Position Manual QA Stable`

Goal:
- confirm and stabilize manual city marker placement / name attachment / selection ring behavior in the Godot 2D editor

## Priority 2
`v0.68c BattleContext Runtime Injection MVP`

Goal:
- inject prepared `BattleContext` data into battle startup while preserving the current stable `5v5` fallback path

## Priority 3
`v0.68d Hero/Army Deployment MVP`

Goal:
- implement first hero / region / city / army assignment data needed to produce roster candidates

## Priority 4
`v0.68b-5-hotfix1 Sea Route Visual Polish`

Goal:
- tune sea arrow speed, size, color, and overlap after 김작 F6 review without adding movement, trade, battle entry, or pathfinding logic

## Priority 5
`v0.69 Battlefield Variant Loader`

Goal:
- load battlefield map variants from `BattleContext.map_variant_id` without changing battle formulas or roster ownership

## Priority 6
`v0.69b Naval Battle Entry MVP`

Goal:
- create the first naval battle entry path from sea route / coastal encounter data through `BattleContext`

## Completed / Archived Context
- `v0.68b-6 WorldMap Selected City Panel Web Parity MVP` is complete.
- Ported the web selected-city HUD structure into `WorldMapUI/CityInfoPanel`.
- City marker clicks now update `selected_city_id`, maintain `selected_city_marker`, clear previous marker selection, show the selected marker's `SelectionRing`, and refresh panel metadata.
- The panel displays city name, id, region/owner, city type, neighbors, route type summary, MVP status text, and attack / hero-move placeholder buttons.
- Attack and hero-move placeholders do not create `BattleContext`, change scenes, move heroes/armies, or open domestic detail UI.
- Route lines and sea route arrow flow were preserved; sea arrow initial spacing moved into script to avoid scene-load `progress_ratio` errors.
- 김작 F6 should confirm city selection, selected marker readability, fixed panel placement, metadata text, placeholder buttons, pan/zoom click behavior, route/sea arrow continuity, and battle scene stability.
- `v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP` is complete.
- Added sea-only visual flow arrows to Gyeongju-Kyoto, Gyeongju-Osaka, Sabi-Kyushu, Sabi-Jianye, and Kyushu-Osaka.
- Each sea route has an `ArrowFlowRoot` Path2D with four `PathFollow2D` arrow markers and small pale blue Polygon2D arrow sprites.
- `scripts/worldmap_route_flow_fx.gd` references the route's scene-authored `Path2D.curve`; it does not regenerate curves from city positions.
- Arrow flow is one-way from `start_city_id` to `end_city_id` for this MVP.
- Land routes remain line-only. No movement, pathfinding, trade, battle entry, naval battle, or `BattleContext` behavior was added.
- 김작 F6 should confirm sea arrows flow naturally, wrap cleanly, read at a good speed, do not cover city markers/names, land routes have no arrows, pan/zoom keeps FX attached, city click info remains normal, and battle scenes are stable.
- `v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning` is complete.
- Land route visibility was strengthened by changing land `Line2D` width to `4.5` and color to `Color(0.86, 0.62, 0.32, 0.72)`.
- Sea route style was intentionally kept unchanged.
- `Path2D.curve` remains scene-authored; no route paths, city marker positions, route metadata, movement, battle entry, or `BattleContext` behavior changed.
- 김작 F6 should confirm land routes read clearly on earth-tone terrain without overpowering castle icons, sea route feel is unchanged, pan/zoom keeps routes attached, editable curves remain available, city click info remains normal, and battle scenes are stable.
- `v0.68b-4 WorldMap Route Layer Path2D MVP` is complete.
- Added route roots under `WorldMap_Test.tscn > WorldMapRoot > RouteLayer`, each with metadata, `Path2D`, and `Line2D`.
- Route meaning is code metadata while actual route shape is scene-authored `Path2D.curve`.
- Initial routes were seeded from current `CityMarker_*` positions based on web `neighbors` / `routeTypes`; land routes are muted earth-tone and sea routes are pale blue.
- Route clicking, army movement, pathfinding, battle entry, naval battle logic, and `BattleContext` runtime injection remain deferred.
- 김작 2D/F6 should confirm route node structure, editable curves, route line visibility during camera pan/zoom, land/sea visual separation, city marker readability, city click info panel behavior, and battle scene stability.
- Known issue retained: CityMarker root movement / name text attachment still needs manual confirmation and is not treated as a route-layer blocker.
- `v0.68b-3 WorldMap City Castle Icon Apply` is complete.
- City markers now use regional castle icon children: Korea, China, Japan, and Ordo.
- `CastleIcon`, Node2D `NameText`, and `ClickArea/CollisionShape2D` remain children of each `CityMarker_*` root, so editor root movement should move the full city bundle.
- 김작 2D/F6 should confirm icon mapping, icon/name overlap, root movement bundle behavior, click info panel, camera behavior, and battle scene stability.
- `v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix` is complete.
- Converted city `NameLabel` nodes from `Label` / `Control` to Node2D text nodes so marker root movement carries city names in the 2D editor.
- 김작 2D/F6 should confirm root movement now visibly moves city name text, marker dot, and click area together.
- `v0.68b-2-hotfix5 WorldMap City Marker Label Reparent Fix` is complete.
- All 13 `CityMarker_*` roots now use explicit local children named `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D`.
- `scripts/worldmap_city_marker.gd` reads those local children and does not assign separate world-space positions to `NameLabel`.
- City marker positions remain scene-authored source of truth, and moving a root marker should carry icon/dot, label, and click area together.
- 김작 2D/F6 should confirm root move attachment for Hanseong and the other 12 cities, click area movement, Ctrl+S persistence, and marker click info panel behavior.
- `v0.68b-2-hotfix4 WorldMap City Marker Root Attachment Fix` is complete.
- Added `ClickArea` / `CollisionShape2D` under every `CityMarker_*` root and kept icon/dot plus label as root children.
- Added marker click signal plumbing and a minimal `WorldMapUI/CityInfoLabel` update path while preserving marker metadata.
- City marker positions remain scene-authored source of truth, and moving a root marker should carry its icon, label, and click area together.
- 김작 2D/F6 should confirm root move attachment, click area alignment, info label update, Ctrl+S persistence, camera behavior, and battle scene stability.
- `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control` is complete.
- Runtime no longer auto-repositions the four worldmap Tile nodes during `_ready()`.
- Tile layout source of truth is now the scene-authored Tile node positions in `WorldMap_Test.tscn`.
- Camera clamp/world rect is calculated from the union of the current tile Sprite2D rects.
- City marker positions remain scene-authored source of truth and marker nodes/metadata were preserved.
- 김작 2D/F6 should confirm manual Tile move/save persistence, no runtime overwrite, camera clamp against the tile union rect, city marker presence, and battle scene stability.
- `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix` is complete.
- Corrected scene-authored tile positions so the Godot 2D editor shows the 4 worldmap tiles as one contiguous map.
- Re-seeded all 13 city markers to the corrected 1024x1024 four-tile combined rect while preserving `CityMarker_*`.`position` as the future source of truth.
- Kept camera pan/drag/zoom/clamp behavior, marker metadata, and empty future layers intact.
- 김작 2D/F6 should confirm seam-free tile display, city markers on the map, debug layer non-interference, camera behavior, fixed UI labels, and battle scene stability.
- `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix` is complete.
- Aligned `CityLayer`, `RouteLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` with `WorldMapTileLayer` under the same zero-offset `WorldMapRoot` coordinate basis.
- Scene-authored the four tile positions and re-seeded all 13 city markers against the 4-tile combined rect so markers sit on the map image in the Godot 2D editor.
- Preserved the rule that final city position source of truth is `CityMarker_*`.`position` in `WorldMap_Test.tscn`, not web `x` / `y`.
- 김작 F6 should confirm marker-on-map placement, editor move-and-save persistence, camera pan/zoom/clamp behavior, fixed UI labels, and no battle scene regression.
- `v0.68b-2 WorldMap City Marker Layer MVP` is complete.
- Added 13 scene-authored city marker nodes under `WorldMap_Test.tscn > WorldMapRoot > CityLayer`, based on `SamWar_web/data/cities.js`.
- Added `scripts/worldmap_city_marker.gd` with exported metadata for `city_id`, `display_name`, `region_id`, `owner_faction_id`, `neighbors`, `route_types`, and `web_seed_position`.
- Treated web `x` / `y` as initial seed/fallback only; final marker placement is the `CityMarker_*` root node position saved in the Godot scene.
- Kept city click, selection UI, route drawing, army movement, battle entry, and `BattleContext` creation deferred.
- 김작 F6 should confirm marker visibility/readability, editor move-and-save persistence, camera pan/zoom attachment, and absence of city click/battle entry behavior.
- `v0.68b-1 WorldMap Four-Tile Canvas Foundation` is complete.
- Added `WorldMap_Test.tscn` as a 2x2 four-tile visual worldmap canvas using the prepared `assets/worldmap/tiles/` PNGs.
- Added `scripts/worldmap_test.gd` for `WorldMapCamera` current setup, WASD/arrow pan, right/middle drag pan, optional wheel zoom, and viewport/zoom-aware clamp to the combined tile rect.
- Prepared empty `CityLayer`, `RouteLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer`; no city click, route graph, army movement, battle entry, or `BattleContext` creation was implemented.
- 김작 F6 should confirm tile attachment, camera movement/clamp, fixed UI labels, empty layer presence, and existing `Battle_Fullscreen_Test.tscn` stability.
- `v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion` is complete.
- Added root-level punch motion to the unique skill cut-in: alpha fade-in, `0.85 -> 1.12 -> 1.0` scale, minimal hold, then upward fade-out / shrink to `0.92`.
- Kept particles, glow shaders, and sound deferred for a later step.
- 고유특기 effect values, target selection, cooldowns, AI judgment, formulas, Camera2D policy, battlefield background, and status badge rules remain unchanged.
- 김작 F6 should confirm the cut-in pops in quickly, exits upward without lingering, does not accumulate scale/position offsets on later uses, and connects cleanly to battlefield FX.
- `v0.68a-4-hotfix4 Unique Skill Dynamic Impact Presentation` is complete.
- Reused existing unique skill cut-in nodes and added dynamic presentation behavior: ink flash, side-based slide-in, image scale punch, delayed skill-name pop, and fast slide/fade-out.
- Effect apply timing now includes the delayed-name enter window so battlefield damage/buff/FX and camera shake begin after the cut-in exit.
- 고유특기 effect values, target selection, cooldowns, AI judgment, formulas, Camera2D policy, battlefield background, and status badge rules remain unchanged.
- 김작 F6 should confirm the cut-in feels like an attack presentation rather than a large static toast, exits quickly, and connects directly to battlefield FX.
- `v0.68a-4-hotfix3 Unique Skill Cutin Fast Impact Timing` is complete.
- Unique skill cut-in timing now uses `0.10s` enter, `0.40s` hold, and `0.12s` exit for a short strong impact.
- The cut-in should no longer linger before returning to damage/buff/FX and camera shake.
- 김작 F6 should confirm the cut-in feels around `0.6s`, remains readable, and no longer interrupts battle tempo.
- `v0.68a-4-hotfix2 Unique Skill Cutin Toast Tempo Match` is complete.
- Unique skill cut-in timing now uses `0.14s` enter, `0.9s` hold, and `0.14s` exit, closer to turn-exchange toast tempo.
- The previous `1.5s` hold is no longer used because it felt too long in 김작 F6.
- 김작 F6 should confirm the cut-in is readable, not dragged out, returns quickly to battle effects, and keeps camera shake/focus stable.
- `v0.68a-4-hotfix2 Unique Skill Cutin Timing Trace` is complete.
- Added debug-gated `[UNIQUE_CUTIN]` timing logs for show, enter done, hold start/done, exit start, hide done, and effect apply.
- Timing trace logs remain available for diagnosing the cut-in sequence, but the `1.5s` hold target is superseded by the toast-tempo match timing.
- 김작 F6 should use the current `0.9s` hold tempo as the active confirmation target.
- `v0.68a-4-hotfix1 Unique Skill Cutin Hold + Shadow Warning Fix` is complete.
- Unique skill cut-in/toast hold is now `1.5s`, while enter/exit remain short.
- Removed `global_scale` / `position` local-variable shadowing warnings in `scripts/battle_web_import_test.gd`.
- 김작 F6 should confirm the cut-in no longer disappears too quickly, post-cutin damage/buff/FX still applies, camera shake returns to current focus, and GDScript warning output is clean.
- `v0.68a-4 Unique Skill Fullscreen Cut-In Presentation` is complete.
- Unique skill presentation now uses a screen-fixed wide cut-in through the existing `BattleUI/UniqueSkillToastRoot`.
- The cut-in scales with viewport size for the large battlefield / Camera2D focus era, while existing unique skill effect values, target rules, cooldowns, AI value gates, and registry data remain unchanged.
- 김작 F6 should confirm the fullscreen cut-in scale, UI overlap feel, short enter/hold/exit timing, post-cutin damage/buff/FX, camera focus/shake return, status badge fix6, and normal attack/strategy/defend flow.
- `v0.68a-3 Battlefield Large Background Apply + Camera Clamp` is complete.
- Applied `assets/web_battle/battlefield/battlefield_3200x1800_worldmap_test_01.png` to the scene-authored battlefield background.
- Preserved current separated unit deployment and logical grid structure; no deployment recenter was done.
- Camera clamp now prefers the large battlefield texture rect before falling back to logical board bounds.
- 김작 F6 QA should confirm the large background fills camera movement, no gray/empty area appears, overlays stay synced, and normal combat flow remains stable.
- `v0.68a-2-hotfix1 Camera-Bound Overlay Sync Fix` is complete.
- Changed camera-bound overlay refresh so facing indicators, post-move facing arrows, READY frames, floating command panel, and status badges are recalculated during/after Camera2D focus movement.
- `_world_to_battle_ui_position()` now derives screen UI coordinates from the current `MainCamera` position/zoom instead of relying only on possibly stale viewport canvas transform data.
- 김작 F6 QA should confirm first-screen indicators, post-move direction arrows, status badges, and camera shake remain synced to units.
- `v0.68a-2 Combat Focus Camera Follow` is complete.
- Added Camera2D focus helpers for world position, unit focus, combat-pair midpoint, unit focus anchor, and battlefield clamp.
- Focus timing now covers battle start, ally selection, ally move start/finish, ally attack, enemy move/attack, strategy, unique skill, and reinforcement arrival.
- Camera shake now returns to the current focus baseline instead of the original scene position during unique-skill presentation.
- 김작 F6 QA should confirm smooth combat focus, fixed CanvasLayer UI, status badge fix6 preservation, and no strange return after shake.
- `v0.68a-1 Camera2D World/UI Layer Foundation` is complete.
- Confirmed scene-authored `MainCamera` exists as `Camera2D` and configured it as current at runtime.
- Added MainCamera configure/reset helpers and preserved scene-authored camera position/zoom as the baseline for reset and existing camera shake.
- Kept UI CanvasLayer-based and split combat focus follow plus battlefield scale/recenter into later tasks.
- 김작 F6 visual QA remains for normal battle display, fixed UI, MainCamera current behavior, existing camera shake, status badge preservation, and stable battle loop.
- `v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix` is complete.
- Changed up/down-facing battlefield status badges from arrow top/bottom tail placement to the arrow's left edge snap.
- Final status badge placement is `→` left edge, `←` right edge, `↑` left edge, and `↓` left edge.
- Left/right-facing edge snap from `v0.68a-fix4` remains unchanged.
- Confusion fallback `◎N` remains.
- 김작 F6 visual QA remains for vertical side-edge snap, `0-4px` gap, no top/bottom vertical placement, body/face/flag overlap checks, and multi-status badge block alignment.
- `v0.68a-fix5 Vertical Facing Status Badge Arrow Tail Fix` is complete.
- Changed up/down-facing battlefield status badges from side/portrait-adjacent placement to arrow-tail placement.
- Up-facing badges now attach below the arrow bottom edge; down-facing badges attach above the arrow top edge.
- Left/right-facing edge snap from `v0.68a-fix4` remains unchanged.
- Confusion fallback `◎N` remains.
- 김작 F6 visual QA remains for all-facing arrow-tail placement, vertical body-overlap checks, confusion `◎N`, and multi-status badge block alignment.
- `v0.68a-fix4 Status Badge Edge Snap To Facing Arrow` is complete.
- Changed battlefield status badge placement from full facing-indicator width math to approximate facing-arrow visual edge snapping.
- Right-facing units snap the badge block's right edge to the arrow's left edge; left-facing units snap the badge block's left edge to the arrow's right edge.
- Up/down-facing units keep the body-center avoidance side rule while using the same arrow visual edge snap.
- Confusion fallback `◎N` remains.
- 김작 F6 visual QA remains for `0-4px` arrow-edge gap, same ally/enemy rule, up/down body-overlap avoidance, confusion `◎N`, and multi-status badge block alignment.
- `v0.68a-fix3 Status Icon Tighten + Confusion Fallback Restore` is complete.
- Tightened battlefield status badge placement further from a `6px` arrow gap to a `2px` arrow gap.
- Restored confusion battlefield badge display from numeric-only `N` to stable `◎N` fallback because the attempted blank-symbol display did not render reliably in Godot.
- Removed the unused `centered_badge_x` local variable warning.
- 김작 F6 visual QA remains for near-attached arrow placement, up/down body-overlap avoidance, confusion `◎N`, shake `⚠N`, first-run stability, and multi-icon horizontal alignment.
- `v0.68a-fix2 Status Icon Tight Arrow Anchor + Confusion Icon Patch` is complete.
- Tightened battlefield status badge placement to a `6px` arrow gap for horizontal facings.
- Changed up/down-facing badge placement to use the nearby arrow side that avoids the unit body center.
- Changed confusion battlefield badge display from `◎N` to turn count only, such as `N`.
- 김작 F6 visual QA remains for tight arrow attachment, up/down body-overlap avoidance, confusion `N`, shake `⚠N`, and multi-icon horizontal alignment.
- `v0.68a-fix1 Status Icon Anchor Consistency Patch` is complete.
- Unified battlefield status badge placement for ally, enemy, support, and reinforce units around the facing arrow's backside.
- Facing rules: right-facing badges left of arrow, left-facing badges right of arrow, up-facing badges below arrow, down-facing badges above arrow.
- Reduced arrow-to-badge separation to a tight `10px` anchor gap while preserving horizontal multi-icon layout.
- 김작 F6 visual QA remains for unit distance, arrow backside placement, face-line fit, and severe overlap checks.
- `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep` is complete.
- Added worldmap, hero data, army deployment, BattleContext, battle engine, and skill system contract docs.
- Defined the future data flow: worldmap / army encounter -> `BattleContext` -> battle engine consumes `BattleContext.roster`.
- Documented that battle type, terrain, region, and `map_variant_id` are decided before battle startup by worldmap / region rules.
- Recorded the next candidates: `v0.68b WorldMap Region Graph MVP`, `v0.68c BattleContext Runtime Injection MVP`, `v0.68d Hero/Army Deployment MVP`, `v0.69 Battlefield Variant Loader`, and `v0.69b Naval Battle Entry MVP`.
- No code, scene, script, or asset changes were made.
- `v0.67z-4 Agent Role Split Foundation` is complete.
- Added role-based agent docs for architecture, implementation, QA, runtime QA, visual QA, and workflow management.
- Kept `CODEX_WORKFLOW_RULES.md` as the canonical source for task classification, autonomous execution, approval handling, and verification depth.
- Kept the current stable baseline at `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`; no code, scene, or asset changes were made.
- `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch` is complete.
- Battlefield status badges now use the facing indicator line as their placement source instead of a fixed right-side offset.
- Left-facing units place badges to the right of the arrow, right-facing units place badges to the left, and up/down facings choose the near side of the arrow/portrait line.
- 김작 F6 visual QA remains: confirm status badges stay near the arrow for 좌→우 / 우→좌 units and do not fully overlap hero faces.
- `v0.67z-2 Deployment Anchor Source Unification` is complete.
- Runtime deployment markers now sync from scene-authored `Slot` / `UnitVisualRoot` anchors before state creation and marker-to-grid-cell sync.
- `UnitMarker` nodes remain in the scene as compatibility sync targets, while manual layout control should happen through the slot/root visual anchors.
- 김작 F6 visual QA remains: move `Slots/AllyReinforce01Slot` and confirm ROUND 2 김유신 spawn plus HP/troop/portrait/click/facing/status alignment.
- `v0.67z Unit Visual Attachment / Manual Layout Control Patch` is complete.
- Runtime start now syncs unit markers from scene-authored `UnitVisualRoot` global movement, allowing slot/root movement in the Godot 2D editor to become the shared visual anchor.
- Token, portrait, HP bar, troop label, shadow, move dust, click area, READY frame, facing indicator, and status badges now resolve through the slot-synced visual anchor.
- Click areas remain root-level `Area2D` nodes for compatibility, while READY/facing/status overlays remain UI/FX nodes positioned from the same anchor.
- `v0.67y-3 Web Defend Command + Formation Status Layout Guard` is complete.
- Manual defend now shows `◆ 방어!`, recovers `10%` of missing troops, displays green recovery text, and logs the recovery when applicable.
- Defending units show a short `◆ 방어` hit reaction when damaged.
- Formation-guide status text is compacted to a one-line summary with `외 N` overflow, and troop/status layout bounds are guarded against overlap.
- `v0.67y-2-hotfix1 Status Icon Readability Fix` is complete.
- Confusion unit badges now use `◎N` so turn counts never appear as bare numbers.
- Defense `◆` and attack-up `▲` use clearly separated blue / amber tones, and formation troop icons are enlarged to `56 x 56` with stronger troop-type text.
- `v0.67y-2 Web Defend Command Port + Status Icon Tone Polish` is complete.
- Floating panel's former move slot now resolves manual `방어`, while direct move-click remains the movement path.
- Defend stores `is_defending`, consumes the action, displays `◆ 방어 태세`, and reduces incoming damage through the existing directional damage helper.
- Status badge/text alpha was toned down; enemy/auto defense use remains deferred.
- `v0.67y-1-hotfix1 Unified Status Display + Toast Fade Polish` is complete.
- Strategy statuses and unique-skill buffs now share one status display formatter for unit badges and formation-guide status lines.
- Unique-skill attack / defense buffs display with `◆`, while confusion / shake keep icon-style unit badges and readable formation text.
- Defeat-retreat toast hide polish now uses a short `0.18s` fade with a subtle scale/position settle after hold.
- `v0.67y-1 Strategy Status UX + Result Sequence Fix` is complete.
- Defeat-retreat toasts now hold `1.2s` for the first exit and `1.0s` for queued follow-ups, with result toast display deferred until the exit queue finishes.
- Enlarged battlefield strategy status icons, added formation-guide status summaries, and enlarged troop icons to `52 x 52`.
- `동요` now applies a light 공/방 `-10%` effect through damage calculation, and strategy status turns decrease after the affected unit acts or skips.
- Enemy/auto strategy use remains deferred to `v0.67y-2 Strategy AI/Auto Expansion`.
- `v0.67y Web Strategy Port MVP` is complete.
- Enabled the floating `책략` command for eligible manual allies with intelligence-based range, success rate, and outcome tiers.
- Added cyan strategy range/target markers, success/failure resolve, mini-log entries, floating effects, and compact unit/formation `혼란` / `동요` status icons.
- `혼란` now skips affected ally/enemy actions; enemy/auto strategy use remains deferred to `v0.67y-2 Strategy AI/Auto Expansion`.
- `v0.67x-7-hotfix4 Defeat Toast Duration + Size Tune` is complete.
- Defeat-retreat toasts now hold for `1.5s`, keep elapsed logs, and use a smaller panel / portrait / text layout.
- `v0.67x-7-hotfix3 Defeat Toast Actual 3s Hold Fix` is complete.
- Defeat-retreat toast fade-out now starts only after the `3.0s` hold, with DEBUG elapsed logs for SHOW / HOLD_DONE / HIDE.
- `v0.67x-7-hotfix2 Defeat Toast 3s + Hakikjin Range Sync` is complete.
- Ally/enemy battle-exit toasts now hold for `3.0s`, and 학익진 표시/피해 대상 now share the same caster-range target helper.
- `v0.67x-7-hotfix1 Defeat Toast Hold Duration 2s` is complete.
- Ally defeat and enemy retreat toasts now hold for `2.0s`, including sequential queued exits, while the snapshot queue remains non-blocking.
- `v0.67x-7 Defeat Retreat Toast Actual Apply` is complete.
- Ally/enemy battle exits now snapshot portrait / name / side / fallback line before cleanup and play on the visible scene-authored toast layer.
- Ally and enemy toasts use separate dialogue pools, default `1.25s` hold, and `1.05s+` sequential queue playback for simultaneous exits.
- Dead units become untargetable immediately, and full-auto result flow remains stable with the defeat-retreat queue active.
- `v0.67x-7 Enemy Retreat Toast Actual Apply` is complete.
- Enemy defeat now snapshots portrait / name / retreat line before cleanup and plays on a dedicated visible toast layer.
- Simultaneous enemy defeats enqueue sequential retreat toasts while dead units become untargetable immediately.
- Full-auto result flow remains stable with retreat toast queue active.
- `v0.67x-6 Targeting UX + Buff Preview + Retreat Toast Polish` is complete.
- Manual buff unique skills now hide the floating command panel, show range / valid-target preview, then auto-resolve.
- Attack and unique-skill targeting modes hide the floating command panel and restore it after cancel or resolve.
- Valid target gold/orange markers were strengthened while preserving purple range cells.
- Enemy defeat now shows a short portrait retreat toast without blocking cleanup, result toasts, or full-auto flow.
- `v0.67x-5 Unique Skill Regression Fix Gate` is complete.
- Restored formation-guide troop icons to readable `40 x 40` while keeping `UniqueSkillReadyIcon` at `64 x 64`.
- Unified unique skill readiness and auto/enemy value checks around range-limited valid targets.
- Fixed buff unique skill manual resolve/reuse and limited buff effects to valid in-range, unbuffed allies.
- Added separate valid-target markers over purple unique skill range cells and short auto/enemy range previews.
- Confirmed WASAPI warning is external to project battle/audio logic.
- `v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance` is complete.
- Restored formation-guide troop icon readability while keeping the `UniqueSkillReadyIcon` at `64 x 64`.
- First-normalized unique skill ranges so melee skills require close range and AOE stays mid-range.
- Reduced enemy/auto unique skill overuse by requiring high-value or fallback-value conditions.
- Restored enemy movement / approach / basic attack pressure in full-auto flow.
- Kept directional damage bonus active with front `1.0`, side `1.15`, back `1.3`.
- Deferred detailed unique skill range balance, `SkillInfoPanel`, and tactics status/explanation UI.
- `v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus` is complete.
- Auto battle can use ally unique skills before normal attack/move/wait fallback.
- Enemy AI can use unique skills on enemy turns and after movement rechecks.
- Directional damage bonus is applied to basic attacks, enemy hits, and single-target attack unique skills.
- Directional multipliers are front `1.0`, side `1.15`, back `1.3`.
- Unique skill readiness now uses cooldown state instead of a one-use flag.
- Formation-guide `UniqueSkillReadyIcon` is enlarged to `64 x 64`.
- Deferred `SkillInfoPanel` and unique skill range balance to later passes.
- `v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix` is complete.
- Removed the `is_visible` parameter shadowing warning.
- Removed the black rectangular unique skill toast backdrop.
- Kept unique skill hover tooltip text suppressed while keeping button text visible.
- Enlarged the formation-guide unique skill ready icon to `36 x 36`.
- Changed ally manual unique skill flow to button click -> range/target display -> valid target click -> resolve.
- Kept `SkillInfoPanel` deferred as a later UX pass.
- `v0.67x-1 Unique Skill Hover Cleanup + Ready Icon` is complete.
- Removed duplicate hover tooltip text from `FloatingUniqueSkillButton`.
- Added a small formation-guide unique skill ready icon for the currently usable active ally only.
- Kept `SkillInfoPanel` deferred as the next UX candidate.
- No battle logic change intended.
- `v0.67x Unique Skill MVP Per Hero Cutin` is complete.
- Added `10` hero unique skill registry entries for the current test battle roster.
- Linked the `6` new cutin images and existing Yi Sunsin / Jeong Dojeon / Guan Yu / Zhang Fei cutins.
- Enabled ally manual unique skill use from the floating command panel.
- Added a world-anchored ink unique skill toast with `2200ms` timing, cutin image, and skill name text.
- Added large red unique skill damage numbers and short camera shake.
- Enemy / auto unique skill use is deferred to a future pass.
- `v0.67w Battle Screen Basic UX Stable Lock` is complete.
- Locked the current MVP battle-screen UX around:
  - ally formation guide `5` cards
  - enemy formation guide `5` cards
  - lower-left battle mini log
  - bottom command `TextureButton` bar + background panel
  - floating command panel
- Kept legacy large side panels hidden, kept `UnitCloseupPanel` hidden, and kept direct move-click / rollback / post-move reopen / active ally pulse stable.
- Bottom command bar background is considered good enough for MVP and can remain a later polish candidate.
- `v0.67v Bottom Command Bar Background Panel Apply` is complete.
- Applied `bottom_command_bar_bg.png` as the `CommandBar` scene background.
- Hid the old black `CommandBar` panel fill behind a transparent panel style.
- Preserved bottom command `TextureButton` handlers and scene-authored layout.
- `v0.67u-3 Formation Guide Card Compact Info Polish` is complete.
- Hid `UnitCloseupPanel` while keeping it reusable.
- Simplified formation cards and removed status text.
- Added troop icon + troop type label to each formation guide card.
- Reduced formation card font sizes for a tighter strategy UI read.
- Active/reserve distinction now relies on visual style instead of text.
- `v0.67u Formation Slot Guide Layout MVP` is complete.
- `BattleMiniLogPanel` is added.
- `FormationSlotGuideLayer` is added with ally/enemy guide panels.
- Only main `3` + reinforce `2` per side are shown.
- Guide UI is display-only with no click behavior.
- Battle logic is unchanged.
- `v0.67t-hotfix Bottom Command TextureButton Scene Fix` is complete.
- Converted `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` from `Button` to scene-authored `TextureButton`.
- Connected the 6 bottom command PNG assets directly in `Battle_Fullscreen_Test.tscn`.
- Preserved existing handlers.
- `RetreatButton` remains a disabled placeholder.
- `v0.67t Bottom Command Button PNG Apply QA` is complete.
- Applied all 6 bottom command PNG files to the bottom global command bar.
- `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` nodes were preserved.
- Existing handlers were unchanged.
- `RetreatButton` remains a disabled placeholder.
- Text overlay is removed only when button image style applies successfully.
- `v0.67s Bottom Command Button Actual Asset Integration` is complete.
- Added `_try_load_texture_or_null()`.
- Added `_apply_button_texture_style_if_available()`.
- Kept actual PNG loading optional and fallback-safe.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` handlers unchanged.
- `v0.67r Bottom Command Bar Art Asset Structure Prep` is complete.
- Prepared `assets/web_battle/ui/bottom_command/README.md`.
- Prepared optional button-art runtime mapping for `AutoBattleButton`, `EndTurnButton`, and `RetreatButton`.
- Actual PNG files are not required yet; missing files keep existing button behavior with no load error.
- `v0.67k-5 Enemy AI Multi-Target Engagement Reservation Fix` is completed history, not the current active priority.
- Enemy AI multi-target engagement improvement is part of the current stable battle baseline.
- Older detailed history is preserved in:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
