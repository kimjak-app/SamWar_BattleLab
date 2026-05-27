# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
Behavior baseline: `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`

Docs/contract baseline: `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`

Latest UI patch: `v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix`

Latest camera/background patch: `v0.68a-3 Battlefield Large Background Apply + Camera Clamp`

Latest skill presentation patch: `v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion`

Latest worldmap foundation patch: `v0.68b-1 WorldMap Four-Tile Canvas Foundation`

Latest worldmap marker patch: `v0.68b-2 WorldMap City Marker Layer MVP`

Latest worldmap marker hotfix: `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix`

Latest worldmap tile hotfix: `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix`

Latest worldmap manual layout patch: `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control`

Latest worldmap marker attachment hotfix: `v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix`

## Current Implementation Step
- `v0.68b-1 WorldMap Four-Tile Canvas Foundation`
- `v0.68b-2 WorldMap City Marker Layer MVP`
- `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix`
- `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix`
- `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control`
- `v0.68b-2-hotfix4 WorldMap City Marker Root Attachment Fix`
- `v0.68b-2-hotfix5 WorldMap City Marker Label Reparent Fix`
- `v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix`
- `v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion`
- `v0.68a-2-hotfix1 Camera-Bound Overlay Sync Fix`
- `v0.68a-2 Combat Focus Camera Follow`
- `v0.68a-1 Camera2D World/UI Layer Foundation`
- `v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix`
- `v0.68a-fix5 Vertical Facing Status Badge Arrow Tail Fix`
- `v0.68a-fix4 Status Badge Edge Snap To Facing Arrow`
- `v0.68a-fix3 Status Icon Tighten + Confusion Fallback Restore`
- `v0.68a-fix2 Status Icon Tight Arrow Anchor + Confusion Icon Patch`
- `v0.68a-fix1 Status Icon Anchor Consistency Patch`
- `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`
- `v0.67z-4 Agent Role Split Foundation`
- `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`
- `v0.67z-2 Deployment Anchor Source Unification`
- `v0.67z Unit Visual Attachment / Manual Layout Control Patch`
- `v0.67y-3 Web Defend Command + Formation Status Layout Guard`
- `v0.67y-2-hotfix1 Status Icon Readability Fix`
- `v0.67y-2 Web Defend Command Port + Status Icon Tone Polish`
- `v0.67y-1-hotfix1 Unified Status Display + Toast Fade Polish`
- `v0.67y-1 Strategy Status UX + Result Sequence Fix`
- `v0.67y Web Strategy Port MVP`
- `v0.67x-7-hotfix4 Defeat Toast Duration + Size Tune`
- `v0.67x-7-hotfix3 Defeat Toast Actual 3s Hold Fix`
- `v0.67x-7-hotfix2 Defeat Toast 3s + Hakikjin Range Sync`
- `v0.67x-7-hotfix1 Defeat Toast Hold Duration 2s`
- `v0.67x-7 Defeat Retreat Toast Actual Apply`
- `v0.67x-7 Enemy Retreat Toast Actual Apply`
- `v0.67x-6 Targeting UX + Buff Preview + Retreat Toast Polish`
- `v0.67x-5 Unique Skill Regression Fix Gate`
- `v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance`
- `v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus`
- `v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix`
- `v0.67x-1 Unique Skill Hover Cleanup + Ready Icon`
- `v0.67x Unique Skill MVP Per Hero Cutin`
- `v0.67w Battle Screen Basic UX Stable Lock`
- `v0.67v Bottom Command Bar Background Panel Apply`
- `v0.67u-3 Formation Guide Card Compact Info Polish`
- `v0.67u Formation Slot Guide Layout MVP`
- Legacy large `LeftPanel` / `RightPanel` info panels are now deprecated/hidden.
- `BattleMiniLogPanel` and left/right formation slot guide panels are added.
- Formation guide is display-only and limited to main `3` + reinforce `2` per side.
- Existing bottom command handlers are reused with no intended behavior change.

## Stable Summary
- `WorldMap_Test.tscn` now exists as the first worldmap visual canvas foundation.
- `WorldMap_Test.tscn` now has editor-visible seam-free four-tile placement: A1 `(0, 0)`, A2 `(512, 0)`, B1 `(0, 512)`, and B2 `(512, 512)`.
- Tile node positions are now scene-authored source of truth. Runtime no longer forces A1/A2/B1/B2 positions during `_ready()`.
- Camera clamp `_world_rect` is calculated from the union of the current tile Sprite2D world rects.
- The prepared four worldmap tiles are arranged as a 2x2 Sprite2D canvas with `centered = false`: A1/NW at `(0, 0)`, A2/NE at `(tile_width, 0)`, B1/SW at `(0, tile_height)`, and B2/SE at `(tile_width, tile_height)`.
- `WorldMapCamera` is scene-authored and runtime-configured as the current Camera2D for large-map pan, drag, optional wheel zoom, and viewport/zoom-aware clamp against the combined tile rect.
- `WorldMapUI` is CanvasLayer-based and intended to remain screen-fixed during camera movement.
- `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` exist as empty future worldmap layers only.
- `CityLayer` now contains 13 scene-authored `CityMarker_*` nodes for Luoyang, Yecheng, Chengdu, Jianye, Karakorum, Pyeongyang, Hanseong, Gyeongju, Sabi, Kyoto, Osaka, Kyushu, and Edo.
- Each `CityMarker_*` root owns its icon/dot, name label, and click area/collision children so moving the root in the Godot 2D editor moves the whole city marker bundle.
- Each `CityMarker_*` root now uses the explicit child structure `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D`; runtime refreshes label text/color by local child reference and does not place `NameLabel` in world coordinates.
- `NameLabel` is now a `Node2D` text node instead of a `Label` / `Control` node, so it follows `CityMarker_*` root movement in the 2D editor.
- `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` now share the same explicit zero-offset `WorldMapRoot` coordinate basis.
- The 13 city markers were re-seeded into the 4-tile combined rect so they sit over the worldmap image in the 2D editor instead of below it.
- The 13 city markers were re-seeded again against the corrected 1024x1024 editor-visible combined rect after the tile seam fix.
- `scripts/worldmap_city_marker.gd` stores exported marker metadata from `SamWar_web/data/cities.js` and keeps simple label/color visuals on each marker.
- Web city `x` / `y` coordinates are preserved only as initial `web_seed_position`; final city marker placement is the `CityMarker_*` node position in `WorldMap_Test.tscn`.
- City marker positions remain scene-authored source of truth after the manual tile layout control patch.
- City marker click now updates a minimal screen-fixed `WorldMapUI/CityInfoLabel` from marker metadata.
- City clicking, city data, route graph, army movement, battle entry, and `BattleContext` runtime injection remain unimplemented.
- Worldmap / hero / army / BattleContext / battle engine / skill contract docs now define the future system boundaries for larger hero scale and worldmap battle launch.
- The battle engine is documented as a `BattleContext.roster` consumer and must not choose heroes directly.
- Worldmap / army systems are documented as owners of encounter creation, battle type, terrain, region, and `map_variant_id` selection.
- Current implementation remains battle-engine-centric MVP, but future architecture is worldmap -> battle_context -> battle_engine.
- Role-based agent docs are complete.
- Worldmap / hero-scale prep contract docs are complete.
- Role-based agent docs now split architecture, implementation, QA, runtime QA, visual QA, and workflow manager responsibilities without changing code, scenes, or assets.
- Battlefield status badges now use a tighter facing-arrow anchor rule for ally, enemy, support, and reinforce units, with up/down facings placed beside the arrow to avoid body-center overlap.
- Battlefield status badges are tightened further toward the facing arrow with a `2px` arrow gap.
- Battlefield status badge placement now computes an approximate facing-arrow visual rect and snaps the badge block edge to the arrow edge, avoiding the oversized facing indicator Control width.
- Vertical-facing battlefield status badges now use the arrow's left edge instead of top/bottom tail placement, avoiding the body/flag interior while staying edge-snapped.
- Confusion battlefield badges now use the stable `◎N` fallback again because the attempted blank-symbol display did not render reliably in Godot.
- `MainCamera` is scene-authored and runtime-configured as the current Camera2D.
- Camera reset and unique-skill camera shake now share the stored scene-authored MainCamera position/zoom baseline.
- Combat focus camera now follows battle start, ally selection, move completion, attack pairs, enemy attacks, strategy/unique skill moments, and reinforcement arrival without changing battle formulas.
- Camera-bound CanvasLayer overlays now refresh from current Camera2D position during/after focus movement so facing indicators, facing arrow panel, READY frames, floating command panel, and status badges do not keep stale screen positions.
- `Battle_Fullscreen_Test.tscn` now uses `assets/web_battle/battlefield/battlefield_3200x1800_worldmap_test_01.png` as the large battlefield background at 1:1 scale.
- Camera focus clamp now prefers the visual battlefield texture rect so Camera2D can move inside the enlarged 3200x1800 field without exposing gray/empty area.
- Core UI remains CanvasLayer-based and intended to stay screen-fixed while Camera2D controls the battle world view.
- Current battle target is stable `5v5`.
- `5v5` battle loop stable.
- Enemy AI multi-target engagement improved and treated as stable.
- Victory / defeat toast stable.
- Reinforcement toast stable.
- Bottom global command bar exists.
- Bottom command bar art-prep folder/README exists.
- Bottom command buttons now render as scene-authored image buttons in the editor and runtime.
- `bottom_command_bar_bg.png` is now applied as the scene-authored `CommandBar` background.
- Old black `CommandBar` panel fill is hidden behind a transparent panel style.
- Bottom command bar background is considered MVP-sufficient and future tuning is polish-only.
- `UnitCloseupPanel` is now hidden/reserved for later popup reuse.
- Formation guide cards now use compact name / troop / troop-icon / troop-type layout.
- Formation guide status text is removed and active/reserve distinction is style-only.
- Current battle-screen MVP UX is locked around formation guides + mini log + bottom command bar + floating command panel.
- Floating `책략` command is enabled for eligible ally units with intelligence-based range, success rate, and outcome tiers.
- Manual 책략 uses cyan range cells and cyan valid-target markers, then applies `혼란` or `동요` status on success.
- `혼란` skips the affected unit's action, and status turns now decrease after the affected unit acts or skips.
- `동요` applies a light attack/defense penalty through the shared directional damage helper.
- Unit markers and formation guide status labels now use one shared status display formatter for strategy statuses and unique-skill buffs.
- Confusion unit badges now include a non-numeric icon fallback (`◎N`) instead of showing a bare turn number.
- Defense / defense-buff status uses steel-blue `◆`, while attack-up uses amber `▲` on unit badges and formation status text.
- Unique-skill attack / defense buffs show distinct `▲` / `◆` unit badges and readable formation-guide status text.
- Floating command panel now uses the former move slot as a manual `방어` command; direct move-click remains the movement path.
- Manual defend sets `is_defending`, consumes the unit action, shows `◆ 방어!`, immediately recovers `10%` of missing troops, and reduces incoming directional-helper damage while active.
- Defending units show a short `◆ 방어` reaction when hit.
- Formation guide status text now uses one-line compact summaries with `외 N` overflow guarding.
- Status badge/text alpha is toned down for a less harsh battle-screen read.
- Last-unit defeat/retreat toasts now finish before victory/defeat result toast display.
- Enemy/auto 책략 use is deferred to `v0.67y-2 Strategy AI/Auto Expansion`.
- Current battle's `10` heroes now have `hero_id`-based unique skill registry entries.
- Ally manual unique skill use is enabled from the floating command panel.
- Floating unique skill button hover no longer shows duplicate tooltip text over the button.
- Formation guide cards now show an enlarged unique-skill-ready icon only for the currently usable active ally.
- Unique skill button now enters range/target selection first; the skill resolves only after a valid target click.
- Unique skill range uses purple cells and valid targets use gold/orange cells.
- Unique skill toast no longer shows the old black rectangular backdrop.
- Unique skill presentation now uses a screen-fixed wide fullscreen cut-in on `BattleUI/UniqueSkillToastRoot`, with the existing cutin image enlarged to roughly `96%` viewport width and `52%` viewport height.
- Unique skill cut-in presentation now uses a short dynamic impact sequence: screen ink flash, side-based slide-in, root scale punch, delayed skill-name pop, short hold, and fast slide/fade-out.
- Unique skill cut-in root now adds punch motion with alpha fade-in, root scale `0.85 -> 1.12 -> 1.0`, minimal `0.08s` hold, and upward fade-out / shrink to `0.92`; particles, glow shaders, and sound remain deferred.
- Unique skill cut-in timing is built from `0.14s` enter, `0.04s` skill-name delay, `0.06s` punch settle, `0.08s` hold, and `0.15s` exit, with effect apply tied to the full cut-in exit so battlefield damage/buff/FX and camera shake follow immediately after.
- Unique skill cut-in timing debug logs are enabled through `UNIQUE_SKILL_CUTIN_TIMING_DEBUG`, reporting SHOW_START, ENTER_DONE, HOLD_START, HOLD_DONE, EXIT_START, HIDE_DONE, and EFFECT_APPLY elapsed times.
- Unique skill cut-in tween sequencing uses explicit enter-parallel, hold interval, and exit-parallel groups; the `1.5s` hold is no longer used for the current tempo.
- `global_scale` and `position` local-variable shadowing warnings in `scripts/battle_web_import_test.gd` were removed with meaningful variable names.
- Unique skill effect values, target rules, cooldown rules, AI value gates, and registry data are unchanged.
- Unique skill damage uses larger red damage numbers and short camera shake.
- Auto battle can now use available ally unique skills before normal attack/move/wait fallback.
- Enemy AI can now use available unique skills on enemy turns and after movement rechecks.
- Unique skill range overreach is first-normalized so melee skills require close engagement and AOE stays mid-range.
- Enemy/auto unique skill priority now requires high-value or fallback-value conditions instead of using skills just because they are ready.
- Enemy movement / approach / basic attack pressure is restored in full-auto flow.
- Unique skill cooldown state is cooldown-based instead of one-use flag based.
- Directional damage bonus is applied to basic attacks, enemy counter/basic hits, and single-target attack unique skills.
- Directional multipliers follow the web baseline: front `1.0`, side `1.15`, back `1.3`.
- Formation guide unique-skill-ready icon display size is now `64 x 64`.
- Formation guide troop icons are kept within-card at `46 x 46` display with stronger troop-type text while the `UniqueSkillReadyIcon` remains `64 x 64`.
- Deployment marker anchoring now syncs from scene-authored `Slot` / `UnitVisualRoot` movement before demo state creation and marker-to-grid-cell sync, so moving a slot/root in the Godot 2D editor changes the actual runtime deployment source as well as token, portrait, HP bar, troop label, shadow, move dust, click area, READY frame, facing indicator, and status badges.
- `UnitMarker` and `PortraitMarker` nodes are retained as compatibility runtime sync targets; they are not the manual layout source of truth for the active `5v5` visual slots.
- Click areas remain scene-level `Area2D` nodes for compatibility, but their runtime positions are now applied from the `UnitVisualSlot` registry with root-relative global positioning.
- READY frames, facing indicators, and status badges remain UI/FX layer overlays, but they resolve from the same slot-synced visual anchor instead of independent fixed placement.
- Battlefield status badges now position from the facing indicator line using tight arrow adjacency: right-facing units place badges left, left-facing units place badges right, and up/down-facing units place badges on the nearby arrow side that keeps them out of the unit body center.
- Unique skill readiness, target collection, manual resolve, and auto/enemy value gates now share range-limited valid target checks.
- Ally buff unique skills resolve immediately after range preview and only affect valid in-range, unbuffed allies.
- Manual buff unique skills now show a short range / valid target preview before auto-resolving.
- Unique skill range overlay keeps purple range cells visible and adds a separate gold target marker on valid target cells.
- Valid-target markers are enlarged and strengthened for clearer gold/orange read over purple range cells.
- Floating ally command panel hides during attack / unique-skill target selection and restores after cancel / resolve.
- Auto/enemy unique skill use shows a short visual range preview before resolving.
- Defeated ally/enemy units now snapshot portrait / name / side / fallback line before cleanup and show a visible defeat-retreat toast on a dedicated scene-authored layer.
- Ally and enemy battle-exit toasts use separate fallback dialogue pools, with `1.2s` first display and `1.0s` queued follow-up display.
- Defeat-retreat toast fade-out is chained after the configured hold instead of running in parallel with the hold interval.
- Defeat-retreat toast panel, portrait, name, and dialogue text are reduced to a less intrusive mid-size presentation.
- Multiple unit defeats in one cleanup enqueue defeat-retreat toasts sequentially without blocking dead-unit cleanup, targeting exclusion, result toasts, or full-auto flow.
- 이순신 학익진 포격 now uses the same caster-range target helper for valid markers and actual damage targets.
- WASAPI output-device warnings are treated as external Godot/Windows audio warnings because the project does not control audio devices directly.
- `SkillInfoPanel` is deferred as a later UX candidate.
- Detailed unique skill range / radius balance remains a later pass.
- Floating command panel exists.
- Direct move-click UX stable.
- Floating panel stays hidden at ally turn start and opens on active ally click.
- Movement + facing complete 후 floating panel auto-reopen.
- Active ally pulse = unified root pulse, pivot locked, around `1.5x`.
- Hero identity registry path remains stable.
- Reinforcement / round / result toast queue remains stable.
- `GDScript` warning count expected `0`.
- `5v5` full auto result path reachable.

## Current Battle Shape
- Per side:
  - `3 main`
  - `2 reinforce`
- Round flow:
  - `ROUND 1 = 3v3`
  - `ROUND 2 = 4v4`
  - `ROUND 3 = 5v5`
- Actor / target parity is expected to remain stable through the full `5v5` path.

## Core Files
- `WorldMap_Test.tscn`
- `scripts/worldmap_test.gd`
- `scripts/worldmap_city_marker.gd`
- `Battle_Fullscreen_Test.tscn`
- `scripts/battle_web_import_test.gd`
- `scripts/battle_unit_state.gd`
- `scripts/unit_visual_slot.gd`

## Contract Docs
- `agent/WORLDMAP_RULES.md`
- `agent/HERO_DATA_CONTRACT.md`
- `agent/ARMY_DEPLOYMENT_RULES.md`
- `agent/BATTLE_CONTEXT_CONTRACT.md`
- `agent/BATTLE_ENGINE_RULES.md`
- `agent/SKILL_SYSTEM_RULES.md`

## Verified Stable Areas
- Enemy AI can advance and re-route in multi-target states instead of defaulting to passive idle.
- Victory / defeat result path is reachable in accelerated full auto.
- Reinforcement arrival toast triggers on rounds `2` and `3`.
- Bottom command bar currently centers on:
  - `자동전투`
  - `턴 종료`
  - `후퇴` placeholder
- Floating command panel currently provides:
  - `기본 공격`
  - `고유특기`
  - `책략` placeholder
  - `방어`
  - `대기`
- Right-click rollback remains part of the movement/facing flow.

## Do Not Break
- Damage / move / attack formulas.
- Hero identity registry.
- Reinforcement deploy timing.
- Reinforcement / round / result toast queue.
- Direct move-click.
- Right-click rollback.
- Floating panel click-to-open behavior.
- Post-move panel reopen.
- Active ally pulse pivot lock.
- Current `5v5` actor / target parity.

## Current Next Direction
1. `v0.68b-3 WorldMap Route Layer MVP`
2. `v0.68c BattleContext Runtime Injection MVP`
3. `v0.68d Hero/Army Deployment MVP`
4. `v0.68d Hero/Army Deployment MVP`
5. `v0.69 Battlefield Variant Loader`
6. `v0.69b Naval Battle Entry MVP`

## Known / Deferred
- 김작 F6 visual QA should confirm `v0.68b-1` worldmap canvas: 4 tiles appear as one map without visible gap/overlap, tile boundaries do not show obvious seams, Camera2D pan is smooth, camera clamp avoids excessive gray outside area, UI labels remain screen-fixed, `CityLayer` / `RouteLayer` / `ArmyLayer` / `EffectLayer` exist in the scene tree, and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 F6 visual QA should confirm `v0.68b-2` city markers: all 13 `CityMarker_*` nodes are visible under `CityLayer`, marker labels/colors are readable enough for MVP placement, moving a marker in the Godot 2D editor and saving preserves that scene-authored position at runtime, camera pan/zoom does not detach markers from the map, and no city click/battle entry behavior exists yet.
- 김작 F6 visual QA should confirm `v0.68b-2-hotfix1`: in the 2D editor, all 13 city markers sit on top of the 4-tile worldmap image, no marker is scattered in the lower gray area, `CityLayer` and `WorldMapTileLayer` share the same coordinate space, moving a marker and saving preserves runtime position, camera pan/zoom/clamp still works, UI labels stay screen-fixed, and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix2`: 4 tiles are contiguous in the 2D editor with no horizontal row gap or vertical column gap, all 13 city markers sit on the map image, debug layers do not obstruct city placement, camera pan/drag/zoom/clamp still works, UI labels stay screen-fixed, and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix3`: the four Tile nodes can be selected and moved in the 2D editor, Ctrl+S preserves the tile layout, F6 does not overwrite Tile positions, camera clamp follows the current tile union rect, all 13 city markers remain present, and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix4`: moving `CityMarker_Hanseong` root moves icon/dot, name label, and click area together; all other `CityMarker_*` roots behave the same; Ctrl+S preserves positions; clicking a marker updates the info label; camera pan/zoom/clamp remains normal; and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix5`: moving `CityMarker_Hanseong` root moves `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D` together; all 13 city marker roots use the same child structure; Ctrl+S preserves positions; marker click info panel remains normal.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix6`: moving each `CityMarker_*` root now moves the Node2D `NameLabel` text visibly with the marker dot and click area; Ctrl+S and F6 preserve the moved bundle.
- Codex Godot headless verification for `v0.68b-2-hotfix6` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` scene load and GDScript warning cleanliness.
- Codex Godot headless verification for `v0.68b-2-hotfix5` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` scene load and GDScript warning cleanliness.
- Codex Godot headless verification for `v0.68b-2-hotfix4` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` scene load and GDScript warning cleanliness.
- Codex Godot headless verification for `v0.68b-2-hotfix3` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` scene load and GDScript warning cleanliness.
- Codex Godot headless verification for `v0.68b-2-hotfix2` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` scene load and GDScript warning cleanliness.
- Codex Godot headless verification for `v0.68b-2-hotfix1` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` scene load and GDScript warning cleanliness.
- Codex Godot headless verification for `v0.68b-2` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` scene load and GDScript warning cleanliness.
- Codex Godot headless verification for `v0.68b-1` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` project/scene load and GDScript warning cleanliness.
- 김작 F6 visual QA should confirm left-facing and right-facing units keep status badges near the facing arrow, with up/down facings still close to the portrait/arrow line and not fully overlapping the face.
- 김작 F6 visual QA should confirm ally/enemy/support/reinforce status badges all follow the same arrow-backside rule, stay close to the unit, and avoid severe face/arrow overlap.
- 김작 F6 visual QA should confirm `v0.68a-fix6` status badge blocks follow final edge placement: `→` left, `←` right, `↑` left, `↓` left, with confusion `◎N`, shake `⚠N`, and multi-icon badges horizontally aligned.
- Codex Godot headless verification for `v0.67z-3` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm the scene load path.
- Codex Godot headless verification for `v0.68a-fix1` was also blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm the status badge placement path.
- Codex Godot headless verification for `v0.68a-fix2` was also blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm tight status badge placement and confusion `N` display.
- Codex Godot headless verification for `v0.68a-fix3` was also blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm near-attached status badge placement, confusion `◎N` display, and first-run stability.
- Codex Godot headless verification for `v0.68a-fix4` was also blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm arrow-edge badge snapping and `0-4px` visual gap.
- Codex Godot headless verification for `v0.68a-fix5` was also blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm vertical arrow-tail status badge placement.
- Codex Godot headless verification for `v0.68a-fix6` was also blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm vertical left-edge status badge placement.
- Codex Godot headless verification for `v0.68a-1` was also blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm MainCamera current behavior, fixed UI layers, camera shake, and the stable battle loop.
- 김작 F6 visual QA should confirm `v0.68a-2` combat focus: battle start and ally selection center naturally, move/attack/enemy attack/strategy/unique skill/reinforcement moments stay visible, UI remains screen-fixed, status badge fix6 remains intact, and camera shake returns to the current focus position.
- 김작 F6 visual QA should confirm `v0.68a-2-hotfix1` overlay sync: first-screen facing indicators sit on units, post-move FacingArrowPanel appears around the active unit, camera movement does not leave stale overlay positions, status badge fix6 remains intact, and camera shake does not desync overlays.
- 김작 F6 visual QA should confirm `v0.68a-3` large battlefield: first screen shows the new large background instead of gray area, camera follow/shake stays within the background, existing separated deployment remains, overlays stay synced, and status badge fix6 remains intact.
- 김작 F6 visual QA should confirm `v0.68a-4` unique skill fullscreen cut-in: cut-in strongly fills the screen on the 3200x1800 battlefield, appears above the battlefield/UI without breaking panels/buttons, enter/hold/exit does not feel slow, existing damage/buff/FX applies after the cut-in, camera focus does not jump, camera shake returns to the current focus, status badge fix6 remains intact, and normal attack/strategy/defend flow remains stable.
- 김작 F6 visual QA should confirm `v0.68a-4-hotfix1`: unique skill cut-in/toast holds for about `1.5s`, no longer disappears too quickly, enter/exit still feel short, post-cutin damage/buff/FX applies normally, camera shake returns to current focus, and GDScript no longer reports `global_scale` / `position` shadowing warnings.
- `v0.68a-4-hotfix2` timing trace logs remain available for diagnosis, but the `1.5s` hold check is superseded by the toast-tempo match timing.
- 김작 F6 visual QA should confirm `v0.68a-4-hotfix2` tempo match: unique skill cut-in feels close to the turn-exchange toast tempo, does not disappear before the skill can be read, no longer drags like the `1.5s` hold, enter/exit stay snappy, post-cutin effects still apply normally, camera shake returns to current focus, and GDScript warning output is clean.
- 김작 F6 visual QA should confirm `v0.68a-4-hotfix3`: unique skill cut-in hits strongly but does not linger, total feel is around `0.6s`, skill name / general image read is still clear, post-cutin damage/buff/FX follows naturally, battle tempo is not interrupted, and GDScript warning output is clean.
- 김작 F6 visual QA should confirm `v0.68a-4-hotfix4`: unique skill cut-in is no longer static, slide-in is forceful, scale punch makes the image feel like it hits the screen, the short ink flash is visible, skill-name pop reads, cut-in exits quickly into damage/buff/FX/camera shake, Camera2D focus does not jump, status badge fix6 stays intact, and normal attack/strategy/defend flow remains stable.
- 김작 F6 visual QA should confirm `v0.68a-4-hotfix6`: cut-in pops from `0.85` scale into an overshoot punch, settles quickly, does not linger like a buffer pause, exits upward while shrinking/fading, next unique skill has no accumulated scale/position offset, and existing damage/buff/FX/camera shake plus UI/status-badge behavior remain stable.
- 김작 F6 visual QA still needs to confirm that moving `Slots/AllyReinforce01Slot` or its `AllyReinforce01UnitVisualRoot` changes 김유신's ROUND 2 spawn position and keeps HP/troop/portrait/click/facing/status alignment natural.
- Detailed unique skill range balance can still be revisited after more skill data is final.
- `SkillInfoPanel` remains deferred until unique skill text/effect wording is stable.
- Tactics explanations and status icons belong to the Web Strategy Port MVP track.

## Archive
- Full historical copies preserved at:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
