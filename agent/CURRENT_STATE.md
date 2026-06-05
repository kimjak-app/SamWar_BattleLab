# CURRENT STATE

## v0.70-15 WorldMap Left Panel Header & Tax Slim Polish
- Baseline: `v0.70-14a WorldMap Panel Top Margin Baseline Polish` at HEAD `502f1eb`.
- Current HEAD analysis summary: `502f1eb` changed `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and six agent docs for the fixed-panel top-margin baseline. `git status --short` showed only two pre-existing untracked Godot `.uid` files under `assets/video_test/theora_safe/`; pre-existing untracked Godot .uid files ignored.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Left panel header slim:
  - `CalendarLabel` is the only visible top turn line and displays the existing runtime calendar string such as `154년 봄 1턴`.
  - `World Turn`, `제 N턴`, and phase/selected/base-city header labels remain as nodes but are hidden/text-cleared where safe.
- Tax section slim:
  - Kept `국가충성도 N · 상태`, one loyalty bar, `세금 수준 N · 설명`, and the existing tax slider.
  - Hid the tax level duplicate bar, long tax preview label, and public-order duplicate bar while preserving tax level normalization, slider value sync, loyalty/public-order reads, and turn/save logic.
- Common top margin: `WORLD_UI_TOP_MARGIN` changed from `16.0` to `10.0`; left, selected-city, city-detail, and diplomacy/spy panels keep their X positions, widths, heights, and CanvasLayer camera independence.
- Preserved scope: no `scripts/battle_web_import_test.gd`, `project.godot`, battle calculations, BattleContext, city data, city click/battle entry, domestic/trade/relation formula, chancellor formula, tax internal calculation, save/load structure, or asset changes.
- Verification result: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, and docs string check passed before commit. Manual F6 QA remains recommended for visible left-panel density and top alignment.
- Next candidate work:
  1. `v0.70-16 WorldMap Left Panel Chancellor Card Polish`
  2. `v0.70-17 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-18 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-19 WorldMap Battle Entry Camera Zoom Handoff`

## v0.70-14a WorldMap Panel Top Margin Baseline Polish
- Baseline: `v0.70-14 WorldMap Left Panel Anchor & World Turn Lock` at HEAD `ab91b34`.
- Current HEAD analysis summary: `ab91b34` changed `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, and six agent docs for the left-panel anchor / World Turn lock. Two pre-existing untracked Godot `.ogv.uid` files under `assets/video_test/theora_safe/` remain untouched.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Panel Y position analysis before patch:
  - `LeftWorldStatusPanel`: top `56`, left `18`, size `320 x 570`.
  - `CityInfoPanel` / `SELECTED CITY`: top `96`, left `824`, width `308`.
  - `CityDetailPanel` / `CITY DETAIL`: top `96`, left `572`, width `240`.
  - `DiplomacySpyPanel`: top `96`, left `340`, width `220`.
  - `TitleLabel` / `SamWar HUD MVP`: top `18`, which would overlap the raised left panel.
- Common top margin baseline:
  - Added `WORLD_UI_TOP_MARGIN = 16.0` and `WORLD_UI_LEFT_MARGIN = 18.0` in `scripts/worldmap_test.gd`.
  - Scene offsets now place the left panel, selected-city panel, city-detail panel, and diplomacy/spy panel at top `16` while preserving each X position, width, and height.
  - `_lock_worldmap_fixed_panel_top_margin()` reapplies top-left screen anchors and the shared top margin at runtime for the fixed HUD panels.
- Debug label handling: `WorldMapUI/TitleLabel` is hidden in the scene and again in `_hide_retired_top_worldmap_hud()`; the node is not deleted.
- Camera independence: all affected panels remain direct `WorldMapUI` `CanvasLayer` children, so `WorldMapCamera` pan/zoom and battle-entry handoff motion do not move or scale them.
- Preserved scope: no `scripts/battle_web_import_test.gd`, `project.godot`, battle calculation, BattleContext, city data, city click/battle entry, domestic/trade/relation formula, panel content, or asset changes.
- Verification result: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, `Battle_Fullscreen_Test.tscn` headless load, and docs string check passed before commit. Manual F6 QA remains recommended for visible top alignment.
- Next candidate work:
  1. `v0.70-15 WorldMap Left Panel Visual Hierarchy Polish`
  2. `v0.70-16 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-17 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-18 WorldMap Battle Entry Camera Zoom Handoff`

## v0.70-14 WorldMap Left Panel Anchor & World Turn Lock
- Baseline requested: `v0.70-13d Battle Movement Facing Direction Polish` at `8991b9b51f91aead893df51f2ee07e1b532bed34`; actual pre-edit HEAD was `e53a9fb v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`, which is preserved and not reverted.
- Current HEAD analysis summary: actual HEAD `e53a9fb` changed `scripts/worldmap_test.gd` plus six agent docs for the battle-entry camera handoff. Two untracked Godot `.ogv.uid` files existed before this patch and were left untouched.
- Modified files: `WorldMap_Test.tscn`, `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- Left panel structure analysis:
  - `LeftWorldStatusPanel` is a `PanelContainer` under `WorldMapUI`, and `WorldMapUI` is a root `CanvasLayer`, so the panel is already screen-space UI and independent from `WorldMapCamera`.
  - The panel content is `MarginContainer/Content` as a `VBoxContainer`; the first labels are `EyebrowLabel` (`World Turn`), `TurnLabel`, `CalendarLabel`, and `NationLabel`.
  - Below that, the existing order continues through national gauges/tax preview, chancellor, warehouse/save management runtime cards, and status hints.
- World Turn lock:
  - `WorldTurnSeparator` was added directly after `NationLabel` to make the top turn area read as a stable header section without converting the whole panel to a scroll redesign.
  - `_lock_world_turn_header_order()` keeps `EyebrowLabel`, `TurnLabel`, `CalendarLabel`, `NationLabel`, and `WorldTurnSeparator` at the top even after runtime UI cards are inserted below.
- Anchor/position stabilization:
  - Scene offsets now explicitly anchor `LeftWorldStatusPanel` top-left at `(18, 56)` with size/minimum size `320 x 570`.
  - `_lock_left_world_status_panel_anchor()` reapplies the same top-left preset, position, size, and minimum size at runtime.
  - Left panel drag registration was removed; right-side draggable panels keep their existing drag behavior.
- Verification result: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load passed before docs commit.
- Preserved scope: no `scripts/battle_web_import_test.gd`, `project.godot`, battle calculation, BattleContext, city data, city click/battle entry, domestic/trade/relation formula, right panel redesign, or asset changes.
- Next candidate work:
  1. `v0.70-15 WorldMap Left Panel Visual Hierarchy Polish`
  2. `v0.70-16 WorldMap Left Panel Resource Warehouse Polish`
  3. `v0.70-17 WorldMap City Detail Panel Right Side Polish`
  4. `v0.70-18 WorldMap Battle Entry Camera Zoom Handoff`

## v0.70-14 WorldMap Battle Entry Camera Zoom Handoff
- Baseline: `v0.70-13d Battle Movement Facing Direction Polish` at HEAD `8991b9b51f91aead893df51f2ee07e1b532bed34`.
- Current HEAD analysis summary: HEAD `8991b9b` modified `scripts/battle_web_import_test.gd` plus five agent docs for movement-facing polish only. Two untracked Godot `.ogv.uid` files existed before this patch and were left untouched.
- Modified files: `scripts/worldmap_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`.
- WorldMap battle entry flow:
  - Player attack still builds/validates deployment, applies existing troop/supply pre-decrement, stores pending battle context, then calls `_handoff_battle_context_to_battle_scene()`.
  - Enemy invasion defense still builds pending invasion deployment, applies existing attacker/defender troop pre-decrement, stores pending battle context, then calls the same handoff.
  - The final `Engine.set_meta("samwar_worldmap_battle_context", context)` and `change_scene_to_file("res://Battle_Fullscreen_Test.tscn")` moved into `_change_scene_to_battle_with_context()` so camera handoff can run immediately before that unchanged final transition.
- Source/target city lookup:
  - `_get_worldmap_city_visual_position()` reads `_city_markers_by_id[city_id].global_position` first.
  - It falls back only to existing city data position-style fields if marker lookup is unavailable; missing coordinates return `null` and immediately skip animation.
  - `_build_worldmap_battle_entry_focus()` uses source/target when both exist and focuses toward the target with a simple `lerp(0.72)`; target-only and source-only fallback remain supported.
- Camera handoff helper structure:
  - `_start_worldmap_battle_entry_camera_handoff()` sets a one-shot in-progress guard, clamps the target focus against the existing world rect, tweens `world_map_camera.position` and `zoom`, holds briefly, then calls the existing transition callable.
  - `_complete_worldmap_battle_entry_camera_handoff()` is the single natural-finish and skip completion path.
  - `_skip_worldmap_battle_entry_camera_handoff()` supports left-click, Space, Enter, keypad Enter, and Esc during handoff only.
- Guard/fallback:
  - `_worldmap_battle_entry_handoff_in_progress` blocks repeated player attack, defense button, deployment confirmation, camera pan/zoom input, and duplicate final handoff while the tween is active.
  - If camera, callable, focus, or city coordinates are unavailable, the code calls the existing battle transition immediately without creating default city ids.
- Verification result: `git diff --check`, Godot headless project load, `WorldMap_Test.tscn` headless load, and `Battle_Fullscreen_Test.tscn` headless load are the validation set for this patch; visible F6 QA is still recommended for camera feel and repeated-click behavior.
- Preserved scope: no `scripts/battle_web_import_test.gd`, scene, asset, `project.godot`, battle calculation, BattleContext key, ownership, troop-result, hero-status, domestic, trade, or relation logic changes.
- Next candidate work:
  1. `v0.70-15 WorldMap Battle Entry Camera Handoff Timing Polish`
  2. `v0.70-16 WorldMap City Click UX Polish`
  3. `v0.70-17 WorldMap Domestic UX Detail Polish`

## v0.70-13d Battle Movement Facing Direction Polish
- Baseline requested: `v0.70-13b Battle Cinematic Lifecycle Guard Audit` at `f56903d5c265e7443e68387e01886d28cda8cf5a`; actual working HEAD before this patch was `0c91744 v0.70-13c Battle WorldMap Return Contract Prep`, which only added agent contract docs on top of that baseline.
- Problem summary: movement paths were valid, but unit token facing could keep its previous left/right visual during a later horizontal segment, making the unit appear to backstep after vertical-then-horizontal movement.
- Modified files: `scripts/battle_web_import_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`.
- Segment facing correction:
  - Ally and enemy path tween loops now run `_apply_unit_movement_facing()` immediately before each segment tween starts.
  - `_get_horizontal_facing_from_step()` returns `right` when `to_cell.x > from_cell.x`, `left` when `to_cell.x < from_cell.x`, and otherwise preserves the fallback facing for pure vertical movement.
  - Pure up/down movement does not force a new facing; the last facing remains until a horizontal segment appears.
- Unit/hero visual sync:
  - Existing token facing visuals remain the single flip/texture path through `_apply_unit_facing_visuals()` and `_apply_token_facing_visual()`.
  - Hero `PortraitBadge` remains unflipped per Godot facing rule, but its facing-aware offset is recomputed through `_apply_group_offset_for_unit()` using the same unit facing.
- Final facing:
  - Ally movement finish now preserves the last movement-facing state instead of immediately re-facing toward the enemy.
  - Existing post-move direction selection still overwrites the visual facing when the player or auto flow chooses a final direction.
- Verification result: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load are the expected validation set; visible F6 QA is still recommended for movement feel.
- Next candidate work:
  1. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  2. `v0.70-15 WorldMap City Click UX Polish`
  3. `v0.70-16 WorldMap Domestic UX Detail Polish`

## v0.70-13c Battle WorldMap Return Contract Prep
- Baseline: `v0.70-13b Battle Cinematic Lifecycle Guard Audit` at HEAD `f56903d5c265e7443e68387e01886d28cda8cf5a`.
- Git commit analysis summary: HEAD `f56903d` changed only `scripts/battle_web_import_test.gd` and five agent docs for cinematic lifecycle guards. No WorldMap script, scene, `project.godot`, battle calculation, or battle-result contract file changed in the baseline commit.
- Modified files: agent docs only (`agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`, `agent/WORLDMAP_RULES.md`).
- WorldMap -> Battle entry contract:
  - `scripts/worldmap_test.gd` uses `Engine.set_meta("samwar_worldmap_battle_context", context)` then `change_scene_to_file("res://Battle_Fullscreen_Test.tscn")`.
  - Player attack context is built through `_start_player_attack_battle()`, `_confirm_player_attack_deployment()`, and `_build_player_attack_battle_context()` with `source: "player_attack"` and `type: "attack"`.
  - Enemy invasion defense context is built from pending invasion event data through deployment confirmation and `_build_battle_context_from_pending_invasion()` with `source: "enemy_invasion"` and `type: "defense"`.
- Battle internal context contract:
  - `scripts/battle_web_import_test.gd` consumes `samwar_worldmap_battle_context` in `_read_worldmap_battle_context_handoff()`, removes the meta immediately, applies rosters, and keeps `worldmap_battle_context` for return payload generation.
  - Battle result state remains `victory` / `defeat` from `_get_battle_result_state()` only; this audit did not change result judgment.
- Battle -> WorldMap return contract:
  - `_return_to_worldmap_with_result()` builds a payload through `_build_worldmap_battle_result_payload()`, stores it as `Engine` meta `samwar_worldmap_battle_result`, then returns to `res://WorldMap_Test.tscn`.
  - `worldmap_test.gd` consumes the result once in `_consume_worldmap_battle_result_if_any()`, removes the meta, and dispatches to existing player-attack or invasion result application.
- Existing contract keys: `source`, `type`, `mode`, `attacker_city_id`, `defender_city_id`, `attacker_owner`, `defender_owner`, `attacker_hero_ids`, `defender_hero_ids`, `attacker_heroes`, `defender_heroes`, `attacker_troop_allocation`, `defender_troop_allocation`, `attacker_total_allocated_troops`, `defender_total_allocated_troops`, side-specific `*_source_city_id`, side-specific `*_source_city_troops_before/after`, `result`, `winner`, `player_troop_outcome`, and `enemy_troop_outcome`.
- Missing or non-literal contract keys: `battle_mode`, `battle_type`, generic `source_city_id`, generic `target_city_id`, explicit `attacker_faction_id` / `defender_faction_id`, generic `deployed_troops` / `assigned_troops`, generic `source_city_remaining_troops`, generic `target_city_garrison`, `loser_side`, `captured` hero list, explicit `worldmap_return_scene` payload key, structured `return_context` / `pending_worldmap_result`, and explicit `result_applied` flag.
- v0.70-14 safe connection points: use `_city_markers_by_id`, `world_map_camera`, `_configure_camera()`, `_apply_zoom()`, `_clamp_camera_to_world()`, and the final `_handoff_battle_context_to_battle_scene()` call after preserving the existing Engine meta timing.
- Verification result: docs-only diff, `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, `WorldMap_Test.tscn` headless load, and string check for `v0.70-13c Battle WorldMap Return Contract Prep` are the expected validation set.
- Next candidate work:
  1. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  2. `v0.70-15 WorldMap City Click UX Polish`
  3. `v0.70-16 WorldMap Domestic UX Detail Polish`

## v0.70-13b Battle Cinematic Lifecycle Guard Audit
- Baseline: `v0.70-13a Battle Intro Wide Hold Timing Polish Stable` at HEAD `6f46bf1`.
- Git commit analysis summary: HEAD `6f46bf1` only tuned intro timing in `scripts/battle_web_import_test.gd` (`BATTLE_INTRO_WIDE_HOLD_SEC 0.4 -> 0.85`, `BATTLE_INTRO_ZOOM_SEC 1.0 -> 1.15`) plus agent docs; the broader intro implementation came from `493c8e8`, and result video panel flow came from `d2dbefa` / `76e0421`.
- Modified files: `scripts/battle_web_import_test.gd`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`.
- Lifecycle guard reinforcement:
  - Battle intro now has a per-reset `battle_intro_camera_has_started` guard so duplicate start calls do not create a second tween or re-hide UI.
  - Natural finish and skip finish now share `_complete_battle_intro_camera_zoom()`, so camera restore, UI restore, tween cleanup, and gameplay-camera-state cleanup run through one path.
  - Repeated skip input is idempotent because the shared completion path exits once intro playback/state is already cleared.
  - Result video cleanup now explicitly clears the video stream, player visibility, backdrop visibility, pending result state, and completion guard when hiding outside the normal completion path.
  - Repeated result video start calls for the same pending result now report already handled instead of falling through to duplicate toast fallback.
- Verification result: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load passed; manual F6 QA is still needed for visible intro/video feel.
- Next candidate work:
  1. `v0.70-13c Battle WorldMap Return Contract Prep`
  2. `v0.70-14 WorldMap Battle Entry Camera Zoom Handoff`
  3. `v0.70-15 WorldMap Domestic UX Detail Polish`

## v0.70-12 Battle Result Video Before Victory/Defeat Toast
- Added battle result presentation videos before the existing victory/defeat result toast flow.
- Source MP4s:
  - `assets/video_source_test/result_dry_run/victory_result_source_04s.mp4`: h264, 1920x1080, yuv420p, `30000/1001`, duration `4.004000`.
  - `assets/video_source_test/result_dry_run/defeat_result_source_04s.mp4`: h264, 1920x1080, yuv420p, `30000/1001`, duration `4.004000`.
- Generated q8 Theora outputs:
  - `assets/ui/result/videos/victory_result_theora_q8_1920x.ogv`: Theora, 1920x1080, yuv420p, `30/1`, duration `4.000000`, size `13550758` bytes.
  - `assets/ui/result/videos/defeat_result_theora_q8_1920x.ogv`: Theora, 1920x1080, yuv420p, `30/1`, duration `4.000000`, size `8176454` bytes.
- `Battle_Fullscreen_Test.tscn` now has a dedicated `ResultOverlay/VideoStreamPlayer_Result` node for result videos.
- `scripts/battle_web_import_test.gd` now attempts to play the victory/defeat result video after result finalization and before queuing the existing result toast.
- Existing victory/defeat toast textures, text, duration, and scale behavior are preserved; only the start point is delayed until video completion.
- Result video load failure falls back immediately to the existing result toast, and a duration-based fallback timer prevents a missing `finished` signal from blocking the toast.
- Battle result judgment, WorldMap result payload/return flow, cutin mappings/assets, archer volley FX, and gunner shot FX were not changed.
- Remaining QA: visible battle QA should confirm victory and defeat videos play before the corresponding result toast and that WorldMap return/result flow still behaves as before.

## v0.70-11 Unit Type Attack Range Baseline
- Added a normal/basic attack range baseline for the test battle in `scripts/battle_web_import_test.gd`.
- Unit type defaults are now explicit:
  - infantry: `attack_range = 1`
  - cavalry: `attack_range = 1`
  - archer: `attack_range = 3`
  - gunner: `attack_range = 4`
- Test battle unit creation now uses `_get_default_attack_range_for_unit_type()` instead of scattered literal range values.
- Affected test battle ranges:
  - Jeong Do Jeon / `jeong_dojeon` / `korea_gunner`: `4`
  - Eulji Mundeok / `eulji_mundeok` / `korea_gunner`: `4`
  - Zhuge Liang / `zhuge_liang` / `china_gunner`: `4`
  - Yi Sunsin / Kim Yu-sin / Liu Bei archer units: `3`
  - Kwon Yul / Guan Yu / Zhang Fei / Xiahou Dun melee units: `1`
- This is normal/basic attack range data only; unique skill range, strategy range, move range, damage, hit, troop, turn progression, FX, cutin mappings, and WorldMap files were not changed.
- WorldMap context data was inspected but not rewritten; explicit WorldMap hero ranges remain outside this test battle baseline patch.
- Remaining QA: visible battle QA should confirm gunner attack overlays show 4-cell normal attack range, archers show 3-cell range, melee units remain adjacent-only, and special skill/strategy ranges remain unchanged.

## v0.70-10 Gunner Muzzle Flash + Tracer Impact Visual
- Added a visual-only gunner normal/basic attack FX path in `scripts/battle_web_import_test.gd`.
- Current gunner units are resolved from unit type / visual key data: `jeong_dojeon` (`korea_gunner`), `eulji_mundeok` (`korea_gunner`), and `zhuge_liang` (`china_gunner`).
- Gunner attacks now call `_play_gunner_shot_effect()` from the same ally/enemy basic attack visual hook family as archer volleys, but through a separate `_is_gunner_unit()` predicate.
- New runtime primitive functions: `_spawn_gunner_muzzle_flash`, `_spawn_gunner_tracer`, and `_spawn_gunner_impact_pop`.
- No gunner bullet, muzzle flash, tracer, or smoke asset was created; the effect uses runtime `Polygon2D`, `Line2D`, and `Node2D` primitives under the battle FX layer.
- The effect shows a short directional muzzle flash, fast thin tracer, target spark impact, and small smoke fade.
- Gunner visual blocking is intentionally short (`GUNNER_VISUAL_BLOCKING_DURATION = 0.18`) and the existing basic-attack motion already covers it; smoke fade remains non-blocking.
- The hook is limited to gunner normal/basic attacks and does not run from unique/special skills, strategy, cutins, damage calculation, turn progression, or WorldMap return logic.
- No cutin assets, q8 Theora mappings, title PNGs, or WorldMap files were changed.
- Remaining QA: visible battle QA should confirm Jeong Do Jeon / Eulji Mundeok / Zhuge Liang basic attacks show a sharp muzzle flash, tracer, impact, and smoke, while archers/non-gunners and special skills do not.

## v0.70-9c Archer Curved Volley + Visual Completion Timing Guard
- Tuned the visual-only archer basic-attack volley in `scripts/battle_web_import_test.gd` for natural motion and action sequencing.
- Normal/basic attacks by archer units now spawn `ARROW_VOLLEY_VISUAL_COUNT = 9` small runtime `Line2D` arrows with wider staggered launches, slower travel, target-side scatter, and brief impact pins.
- Current archer units are resolved from unit type / visual key data: `yi_sunsin` (`korea_archer`), `gim_yusin` (`korea_archer`), and `liu_bei` (`china_archer`).
- New functions: `_play_arrow_projectile_effect`, `_spawn_arrow_projectile`, and `_spawn_arrow_impact_pin`.
- Arrow projectiles now use `_get_arrow_curve_midpoint()` with subtle `ARROW_CURVE_OFFSET_MIN` / `ARROW_CURVE_OFFSET_MAX` arc offsets instead of perfectly straight source-to-target travel.
- Archer basic attacks now use `_get_arrow_volley_blocking_duration()` / `_get_arrow_volley_completion_extra_wait()` so the next action waits until the last arrow flight and immediate impact have completed.
- Pin fade remains non-blocking; only flight plus initial impact is guarded to preserve battle rhythm.
- No arrow image/SVG/PNG asset was created; the effect is generated at runtime under the existing battle FX layer.
- Arrow timing now uses a `0.05`-`0.12` second launch stagger and `0.34`-`0.50` second travel window so arrows read more like arrows than fast gunner shots.
- The hook is limited to ally/enemy normal basic attack paths and does not run from unique/special skills, strategy, cutins, cannon AOE, charge skills, damage calculation, turn progression, or WorldMap return logic.
- No cutin assets, q8 Theora mappings, title PNGs, or WorldMap files were changed.
- Remaining QA: visible battle QA should confirm Yi Sunsin / Kim Yu-sin / Liu Bei basic attacks show a heavier, slower, subtly curved arrow stream, and that the next unit does not start moving before the arrows land.

## v0.70-8b Yi Sun-sin + Eulji Mundeok Mirrored Cutin Layout
- Built on `e69dd46 을지문덕,김유신까지 컷인 완성`.
- Mirrored only Yi Sunsin and Eulji Mundeok specialty cutin composition in `scripts/battle_web_import_test.gd`.
- Yi Sunsin now uses hero portrait on the right and Hakikjin title image on the left.
- Eulji Mundeok now uses hero portrait on the right and Salsu Daechop title image on the left.
- The mirrored heroes also use mirrored portrait enter/settle/exit offsets and mirrored title enter offset so motion direction matches the new composition.
- Kwon Yul, Jeong Do Jeon, and Kim Yu-sin layout config remains hero-left/title-right.
- No q8 OGV paths, fallback chains, special-skill trigger logic, cutin assets, or WorldMap logic were changed.
- Remaining QA: visible battle QA should trigger Yi Sunsin and Eulji Mundeok unique skills and confirm right-side hero, left-side title, readable composition, normal battle-flow return, and unchanged Kwon Yul / Jeong Do Jeon / Kim Yu-sin layouts.

## v0.70-8 Kim Yu-sin + Eulji Mundeok Special-Skill Cutin Integration
- Scope correction: Kim Yu-sin and Eulji Mundeok were integrated into the existing unique/special-skill cinematic cutin system only; no reinforcement-arrival cutin hook was added.
- Verified newly supplied source assets:
  - `assets/video_source_test/production_dry_run/kim_yu_sin_cutin_source_02s.mp4`: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
  - `assets/video_source_test/production_dry_run/eulji_mundeok_cutin_source_02s.mp4`: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Verified portrait/title PNGs:
  - `assets/ui/cutin/portraits/kim_yu_sin_cutin.png` (`1672x941`, RGBA/transparent).
  - `assets/ui/cutin/titles/kim_yu_sin_samguktongil_title.png` (`1133x639`, RGBA/transparent).
  - `assets/ui/cutin/portraits/eulji_mundeok_cutin.png` (`1672x941`, RGBA/transparent).
  - `assets/ui/cutin/titles/eulji_mundeok_salsudaecheop_title.png` (`1133x639`, RGBA/transparent).
- Encoded new q8 1920x Theora special-skill cutin outputs:
  - `assets/ui/cutin/videos/kim_yu_sin_cutin_bg_theora_q8_1920x.ogv`: Theora, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `6365944` bytes.
  - `assets/ui/cutin/videos/eulji_mundeok_cutin_bg_theora_q8_1920x.ogv`: Theora, 1920x1080, yuv420p, `30/1`, stream duration `N/A`, format duration `2.005333`, size `8318109` bytes.
- Added Godot import metadata for the new portrait/title PNGs and OGV `.uid` metadata for both q8 Theora outputs.
- `scripts/battle_web_import_test.gd` now adds first-candidate q8 video paths and per-hero cutin presentation configs for `gim_yusin` and `eulji_mundeok`.
- Existing Yi Sunsin, Kwon Yul, and Jeong Do Jeon q8 paths/configs/fallback chains were preserved.
- Kim Yu-sin and Eulji Mundeok have q8 primary paths only; no older legacy fallback video existed in `assets/ui/cutin/videos/` for those heroes.
- Removed tracked `assets/video_test/theora_safe/` frame-capture `.import` junk again with limited pathspecs only; preserved the real q7/q8 test `.ogv` outputs and `README.md`.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for the two new OGVs, four PNGs, plus existing Yi/Kwon/Jeong q8 OGVs.
- Remaining QA: visible battle QA should trigger Kim Yu-sin and Eulji Mundeok unique skills and confirm q8 video, portrait/title, non-black playback, skill effect continuation, and battle-flow return.

## v0.70-7b Kim Yu-sin Tactical Cell Clickability Root-Cause Fix
- Built on `19afc67 Replace Jeong Do Jeon q8 cutin video source`.
- Diagnosed the recurring Kim Yu-sin visible-QA issue as two tactical input problems in `scripts/battle_web_import_test.gd`, not a cutin/video problem.
- Command panel placement still had too much room to choose detached viewport-corner fallback positions; distance scoring was strengthened and corner fallback penalty was raised so nearby selected-unit candidates remain preferred.
- Move-cell clickability root cause: during ally turn, ally unit click hit testing ran before valid highlighted move-cell handling. A reachable empty cell near/below Kwon Yul could be inside Kwon Yul's click area and therefore select Kwon Yul instead of moving Kim Yu-sin.
- Ally-turn input now tries valid highlighted move-cell clicks before ally unit selection. Occupied ally cells remain invalid move targets, so clicking an actual ally unit still selects that ally after the move check fails.
- Ally click selection now resolves overlapping ally click areas by closest unit rather than first alive ally order.
- Disabled/non-pickable unit click areas are ignored by the manual click-area hit test, preventing hidden/reserve click areas from consuming battlefield clicks.
- No cutin video assets, q8 Theora mappings, title PNGs, production cutin files, or WorldMap logic were changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Remaining QA: visible battle QA should select Kim Yu-sin, confirm the command panel stays attached near the selected unit, and confirm the highlighted cell below/near Kwon Yul moves Kim Yu-sin if it is shown as reachable.

## v0.70-6b Jeong Do Jeon Source Replacement + q8 Theora Regeneration
- Built on `5c9b8cc 정도전 고유특기 영상 교체`, which replaced `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4`.
- New Jeong Do Jeon source ffprobe: `codec_name=h264`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30000/1001`, `duration=2.002000`.
- Regenerated only `assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv` from the new source with the q8 1920x Theora preset.
- Regenerated output ffprobe: `codec_name=theora`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.000000`, size `7101765` bytes.
- Jeong Do Jeon mapping remains unchanged: `res://assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv` is still the first candidate, with existing WebM/MP4 fallbacks preserved.
- Yi Sunsin q8 OGV/mapping/timing, Kwon Yul q8 OGV/mapping, and Jeong Do Jeon title PNG were not modified.
- Removed only accidental tracked Godot import junk under `assets/video_test/theora_safe/` from the source-replacement commit; preserved the actual q7/q8 test `.ogv` files and `README.md`.
- Verification passed: source ffprobe, output ffprobe, `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for Jeong Do Jeon q8 OGV/title PNG.
- Remaining QA: visible battle-flow QA should confirm the new Jeong Do Jeon video displays, no black screen appears, the 개혁령 title appears, and battle flow returns after the cutin.

## v0.70-7a Tactical Panel Distance Clamp + Move Cell Clickability Fix
- Built on `694065a Prevent battle command panel from blocking tactical cells`.
- Fixed the Kim Yu-sin visible-QA issue where the floating command panel could jump to a detached lower-right safe corner after overlap avoidance.
- `scripts/battle_web_import_test.gd` now scores command-panel candidates by tactical-cell overlap plus distance from the selected unit, and applies a large penalty to viewport-corner fallback positions.
- Added near diagonal panel candidates so the panel has more attached positions before considering screen-corner fallbacks.
- Diagnosed the Xiahou Dun-adjacent move-cell click issue as an input priority problem: a valid highlighted move cell could be preempted by an enemy unit click area before the grid move target handler ran.
- Added a valid move-cell click path before enemy hit testing during ally turn, so visibly reachable cells remain clickable even if an enemy click area overlaps the same screen region.
- Existing command behavior is preserved: basic attack, unique skill, strategy, defend, wait, target-selection hiding, and direct move-click still use the same action paths.
- No cutin video assets, q8 Theora mappings, title PNGs, production cutin files, or WorldMap logic were changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Remaining QA: visible battle QA should select Kim Yu-sin and confirm the panel stays near the unit; then click the highlighted move cell below/near Xiahou Dun and confirm it moves if highlighted as reachable.

## v0.70-7 Tactical Command Panel Grid Overlap Avoidance
- Identified battle UX bug: `BattleUI/FloatingAllyCommandPanel` could sit over visible move/attack/target cells and consume mouse input before the grid click reached tactical selection.
- Added automatic floating command panel placement scoring in `scripts/battle_web_import_test.gd`.
- The panel now evaluates candidate positions around the selected ally and screen corners, clamps them inside the viewport, and chooses the position with the least overlap against visible tactical cell overlay rects.
- Added tactical target-selection suppression: attack target select, unique-skill target select, and strategy target select hide the floating command panel and switch its panel mouse filter to `IGNORE` while grid/unit targeting is active.
- Right-click cancel paths for attack and unique-skill target selection restore the command panel request when returning to ally command selection; strategy cancel already restores it and now uses the same hide helper.
- Existing command buttons and combat rules are preserved: basic attack, unique skill, strategy, defend, and wait behavior are unchanged.
- No cutin OGV assets, title PNGs, q8 mappings, Yi Sunsin timing, Kwon Yul / Jeong Do Jeon mappings, or WorldMap logic were changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Remaining QA: visible battle QA should confirm the panel avoids reachable cells when a unit is selected, hides during attack/strategy/unique target selection, and no longer blocks clicks on cells that used to be covered.

## v0.70-6a Kwon Yul + Jeong Do Jeon q8 Theora Production Dry Runs
- Built on clean checkpoint `46f60c0 Remove Theora safe import junk after cutin asset intake`.
- Reconfirmed source MP4s before encoding:
  - `assets/video_source_test/production_dry_run/kwon_yul_cutin_source_02s.mp4`: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
  - `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4`: h264, 1920x1080, yuv420p, `30000/1001`, duration `2.002000`.
- Added q8 1920x Theora production dry-run outputs without overwriting existing production videos:
  - `assets/ui/cutin/videos/kwon_yul_cutin_bg_theora_q8_1920x.ogv` (`theora`, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `9054001` bytes).
  - `assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv` (`theora`, 1920x1080, yuv420p, `30/1`, duration `2.000000`, size `4472743` bytes).
- Godot import metadata is present for both new OGVs, and direct ResourceLoader checks load them as `VideoStreamTheora`.
- Kwon Yul and Jeong Do Jeon cutin video chains now try their q8 Theora files first, then preserve existing WebM fallbacks and include existing MP4 fallback paths.
- Yi Sunsin q8 path, final timing, title animation, and fallback chain were preserved.
- Kwon Yul title image is wired to `assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png`; Jeong Do Jeon title image is wired to `assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png`.
- Added per-hero cutin presentation config entries so Kwon Yul, Jeong Do Jeon, and Yi Sunsin can keep independent portrait scale/position and title placement values.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader checks for Kwon Yul / Jeong Do Jeon q8 OGVs plus title PNGs.
- Remaining QA: visible battle-flow QA should confirm Kwon Yul and Jeong Do Jeon video/title playback, non-black display, per-hero layout suitability, and battle-flow return.

## v0.70-6 Kwon Yul + Jeong Do Jeon Cutin Source Asset Intake
- Inspected latest asset intake commit `c7173fb 컷인 관련`.
- Commit `c7173fb` added the expected source MP4 files:
  - `assets/video_source_test/production_dry_run/kwon_yul_cutin_source_02s.mp4`
  - `assets/video_source_test/production_dry_run/jeong_do_jeon_cutin_source_02s.mp4`
- Kwon Yul source ffprobe: `codec_name=h264`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30000/1001`, `duration=2.002000`.
- Jeong Do Jeon source ffprobe: `codec_name=h264`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30000/1001`, `duration=2.002000`.
- Verified title PNG assets:
  - `assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png` (`1133x639`, RGBA/transparent)
  - `assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png` (`1133x639`, RGBA/transparent)
- Added the required Godot texture import metadata for both new title PNGs so they load as `CompressedTexture2D`.
- Godot `--import` also generated test OGV `.uid` files under `assets/video_test/theora_safe/`; those were removed specifically and were not tracked.
- Removed tracked Theora safe frame-capture Godot import junk under `assets/video_test/theora_safe/` using limited `git rm` patterns only; preserved `README.md`, `test_safe_q7_1280x.ogv`, and `test_safe_q8_1920x.ogv`.
- No production cutin mapping, Yi Sunsin q8 mapping/file, Kwon Yul / Jeong Do Jeon mapping, production video asset, battle logic, or WorldMap logic was changed.
- Next candidates: Kwon Yul q8 Theora production dry run, Jeong Do Jeon q8 Theora production dry run, then per-hero cinematic cutin layout tuning.

## v0.70-5e Yi Sun-sin Final Exit Snap Tuning
- Built on `fbe1219 Tune Hakikjin hold timing and large burst fade`.
- Preserved the current Hakikjin-first exit structure: Hakikjin still appears, holds/readably bursts, and disappears before Yi Sunsin exits.
- Shortened the post-title Yi Sunsin linger by moving the full cutin exit start from `2.55s` to `1.18s`, leaving roughly `0.18s` after Hakikjin's burst fade completes.
- Reduced the final full-cutin exit duration from `0.45s` to `0.14s` for a sharper snap-like finish.
- Reduced `SPECIALTY_SKILL_CUTIN_TOTAL_DURATION` from `3.0s` to `1.38s` so the unique-skill effect continuation and battle-flow rhythm no longer wait behind an invisible long tail.
- Added a subtle fast left/down hero drift during the final fade, changing the final Yi Sunsin exit motion to `Vector2(-86.0, 14.0)`.
- q8 Theora playback remains first in the Yi Sunsin video candidate chain, and all existing fallbacks remain preserved.
- No Kwon Yul / Jeong Do Jeon mapping, production cutin asset, battle logic, or WorldMap logic was changed.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader verification for Hakikjin PNG and q8 OGV.
- Remaining QA: visible F6/manual battle QA should confirm Hakikjin still exits before Yi Sunsin, Yi Sunsin no longer lingers too long, the final cutin disappears sharply, and battle rhythm feels better.

## v0.70-5d Hakikjin Readable Hold + Large Burst Fade Tuning
- Built on `1134d80 Increase Hakikjin burst scale and tune Yi Sun-sin balance`.
- Kept Yi Sunsin portrait scale and vertical balance unchanged from v0.70-5c; no additional portrait scale or position change was made.
- Hakikjin title image remains `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Increased the Hakikjin readable hold before burst by delaying the burst until after a short readable window.
- Changed Hakikjin burst behavior to readable base appearance, then dramatic enlargement to `2.25` while fading out and drifting upward by `22px`.
- Hakikjin still exits before Yi Sunsin and before the full cutin exit, preserving the dynamic logo-burst direction rather than a static caption.
- q8 Theora playback remains first in the Yi Sunsin video candidate chain, and all existing fallbacks remain preserved.
- No Kwon Yul / Jeong Do Jeon mapping, production cutin asset, battle logic, or WorldMap logic was changed.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader verification for Hakikjin PNG and q8 OGV.
- Remaining QA: visible F6/manual battle QA should confirm Hakikjin stays readable longer before bursting, grows very large while disappearing, Yi Sunsin remains well positioned, the cutin feels more satisfying, and battle-flow return still works.

## v0.70-5c Yi Sun-sin Vertical Balance + Hakikjin Large Burst-Out Tuning
- Built on `7bdaefd Increase Yi Sun-sin dominance and animate Hakikjin burst`.
- Kept Yi Sunsin portrait scale approximately as-is and applied only a small vertical balance adjustment, moving the oversized portrait down by `28px`.
- Hakikjin title image remains `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Strengthened Hakikjin exit behavior from a mild burst to a large burst-enlarge fade: readable base appearance, rapid scale-up to `1.72`, then fade while expanding to `1.90`.
- Added a slight upward drift during the Hakikjin fade burst so the logo feels like it dissipates outward rather than simply shrinking or sitting.
- q8 Theora playback remains first in the Yi Sunsin video candidate chain, and all existing fallbacks remain preserved.
- No Kwon Yul / Jeong Do Jeon mapping, production cutin asset, battle logic, or WorldMap logic was changed.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader verification for Hakikjin PNG and q8 OGV.
- Remaining QA: visible F6/manual battle QA should confirm Yi Sunsin top/bottom balance, Hakikjin now grows dramatically while disappearing, the cutin feels more impactful, and battle-flow return still works.

## v0.70-5b Yi Sun-sin Dominance + Hakikjin Pop-and-Burst Tuning
- Built on `09e92ba Integrate Hakikjin title image and tune Yi Sun-sin cutin impact`.
- Increased Yi Sunsin portrait dominance again: the foreground portrait now uses a larger screen-relative layout and is pushed farther left with more panel overflow.
- Hakikjin title image remains `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Changed Hakikjin title motion from a settled/static hold into a short impact burst: appear, expand strongly, then fade out while continuing to enlarge.
- The target feeling is now `나타난다 -> 확 커진다 -> 사라진다`, so the title reads as a strike-impact skill logo rather than a persistent label.
- q8 Theora playback remains first in the Yi Sunsin video candidate chain, and the existing fallback chain remains preserved.
- No Kwon Yul / Jeong Do Jeon mapping, production cutin asset, battle logic, or WorldMap logic was changed.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader verification for Hakikjin PNG and q8 OGV.
- Remaining QA: visible F6/manual battle QA should confirm Yi Sunsin is dominant enough, Hakikjin appears/expands/disappears dynamically, the composition feels more forceful, and battle-flow return still works.

## v0.70-5a Yi Sun-sin Hero Scale + Skill Title Image Impact Tuning
- Built on `c810da9` plus the tracked title asset upload at `6264171`.
- Integrated the transparent PNG skill-title image `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png` for Hakikjin and added its Godot import metadata `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png.import`.
- Removed the visible `이순신` hero-name text from the specialty cutin presentation.
- Replaced the plain `학익진!` label with `BattleUI/SkillCutinLayer/Control_Text/TextureRect_SkillTitle`, loaded from `res://assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- Increased the Yi Sunsin foreground portrait scale significantly from the v0.70-5 layout and moved it further left/center-left so it overflows the cutin panel for stronger hero-splash impact.
- Strengthened motion timing: faster left-to-right hero whoosh, overshoot/settle, and a stronger title-image pop sequence before hold/exit.
- q8 Theora playback remains first in the Yi Sunsin video candidate chain, and the existing 540p Theora / VP8 WebM / legacy OGV-WebM / MP4 fallbacks remain preserved.
- No q8 OGV re-encode, no production cutin deletion, and no Kwon Yul / Jeong Do Jeon mapping change was made.
- Verification passed: `git diff --check`, Godot headless project load, `Battle_Fullscreen_Test.tscn` headless load, and direct ResourceLoader verification for the title PNG as `CompressedTexture2D` and q8 OGV as `VideoStreamTheora`.
- Remaining QA: visible F6/manual battle QA should confirm the hero is now large enough, `이순신` text is gone, the Hakikjin title image feels impactful, composition feels premium, and battle-flow return still works.

## v0.70-5 Yi Sun-sin Cutin Cinematic Layout Polish
- Yi Sunsin q8 Theora playback remains the active production dry-run baseline through `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`; the existing fallback chain remains preserved.
- Identified the current presentation problem: the cutin read as a flat portrait pasted over video, the thick yellow diagonal bar felt cheap, and the hero/skill typography lacked impact.
- Polished the Yi Sunsin specialty cutin presentation layer into a more cinematic layered composition: battle dim overlay, moving q8 OGV background, larger foreground Yi Sunsin portrait, restrained accent FX, and stronger typography.
- The Yi Sunsin foreground portrait is now staged larger and more dominant on the left/center-left, closer to the old high-impact Guan Yu toast scale while keeping the living Theora background.
- Reworked the former yellow slash into a thin steel-blue/sea-spray accent with softer opacity and entrance timing instead of a thick gold bar.
- Typography now treats `이순신` as a secondary hero-name title and `학익진!` as the main impact text, using cooler hero-name color, warm ivory/gold skill text, stronger outline, and shadow for readability over motion.
- Entrance timing now staggers dim/video, hero slide/settle, text reveal, and accent motion; exit fades and slightly drifts the presentation before returning to the existing battle flow.
- Scope was limited to `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and agent documentation. No video asset was re-encoded and no Kwon Yul / Jeong Do Jeon cutin mapping was changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load.
- Remaining QA: headless checks cannot judge cinematic feel, text taste, or frame-level visual composition. Kimjak should run F6/manual battle QA and check hero scale/presence, text quality, removal of the tacky yellow slash, overall cinematic feel, and battle-flow return.
- Future extension path: once the Yi Sunsin polished layout is visually accepted, reuse the same q8 Theora pipeline and layered presentation direction for Kwon Yul / Jeong Do Jeon without changing their mappings prematurely.

## v0.70-4a Yi Sun-sin q8 Theora Manual QA Documentation
- Manual Godot battle-flow QA passed for the Yi Sunsin q8 Theora production dry-run baseline from commit `f3d53e0`.
- User confirmed the q8 cutin finally displays correctly in the actual Godot battle flow: "드디어 제대로 뜸! 깔끔하게 떠^^".
- Visual playback is clean, with no observed black-screen lock, no obvious color corruption, and no obvious playback failure.
- `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` is accepted as the Yi Sunsin production dry-run candidate.
- Existing fallback chain remains preserved: q8 1920x Theora first, then 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4.
- Remaining QA candidates: lock the Yi Sunsin q8 dry-run checkpoint, expand the q8 Theora pipeline to Kwon Yul / Jeong Do Jeon, add focused QA for post-cutin unique-skill effect continuation and battle-flow return, and document q8 file-size/runtime-performance criteria if needed.

## v0.70-4 Production Cutin Theora Dry Run - Yi Sun-sin q8
- Encoded the tracked real Yi Sun-sin dry-run source `assets/video_source_test/production_dry_run/yi_sun_sin_cutin_source_02s.mp4` into a separate production dry-run Theora asset.
- Source ffprobe: `codec_name=h264`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30000/1001`, `duration=2.002000`.
- Generated output: `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` (`7580014` bytes), with Godot sidecar `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv.uid`.
- Output ffprobe: `codec_name=theora`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.000000`.
- Yi Sunsin specialty cutin video candidate order now tries `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` first, then the existing 540p Theora, VP8 WebM, legacy OGV/WebM, and MP4 fallbacks.
- Existing production cutin assets were preserved: `yi_sun_sin_cutin_bg.mp4`, `yi_sun_sin_cutin_bg_vp8.webm`, `yi_sun_sin_cutin_bg_theora_540p.ogv`, `yi_sun_sin_cutin_bg_theora_540p.ogv.uid`, `kwon_yul_cutin_bg.mp4`, and `jeong_do_jeon_cutin_bg.mp4`.
- Godot verification passed for headless project load, `Battle_Fullscreen_Test.tscn` load, and direct resource verification: the new OGV has `file_exists=true`, `resource_exists=true`, loads as `VideoStreamTheora`, and the direct `VideoStreamTheora.file` fallback accepts the path.
- Headless verification does not visually inspect frame color, black-screen behavior, finished signal timing, or post-cutin battle-flow return. Kimjak F6/manual visual QA remains required for those checks.

## v0.70-3 Portable FFmpeg Setup + Theora Safe Encode Execution
- Completed repo-local portable FFmpeg setup under ignored `tools/ffmpeg/`.
- Downloaded `ffmpeg-release-essentials.zip` from gyan.dev into `tools/ffmpeg/`, extracted it locally, and copied `ffmpeg.exe` / `ffprobe.exe` to `tools/ffmpeg/bin/`.
- FFmpeg path used: `tools/ffmpeg/bin/ffmpeg.exe`; FFprobe path used: `tools/ffmpeg/bin/ffprobe.exe`.
- FFmpeg version: `8.1.1-essentials_build-www.gyan.dev`, with `libtheora` and `libvorbis` enabled.
- Added `.gitignore` entries so the portable FFmpeg zip/binaries and Godot movie-maker diagnostic frames are local dependencies/artifacts, not commit targets.
- Encoded test-only outputs from `assets/video_source_test/cutin_test_01.mp4`:
  - `assets/video_test/theora_safe/test_safe_q7_1280x.ogv` (`3426729` bytes)
  - `assets/video_test/theora_safe/test_safe_q8_1920x.ogv` (`7295937` bytes)
- Both encodes succeeded with audio; no noaudio fallback was needed.
- ffprobe q7: `codec_name=theora`, `width=1280`, `height=720`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.166667`; audio `codec_name=vorbis`, `sample_rate=48000`, `channels=2`, `duration=2.154667`.
- ffprobe q8: `codec_name=theora`, `width=1920`, `height=1080`, `pix_fmt=yuv420p`, `avg_frame_rate=30/1`, `duration=2.166667`; audio `codec_name=vorbis`, `sample_rate=48000`, `channels=2`, `duration=2.154667`.
- Godot headless test scene load confirmed both q7 and q8 load through `ResourceLoader` as `VideoStreamTheora` and reach `is_playing=true`.
- Godot Windows display-driver movie-maker verification confirmed q7 and q8 both render 75 frames, emit `finished signal`, and do not stick on black.
- Visual color check from representative Godot-captured frames: q7 and q8 keep the source's muted brown/gray war-scene tone. No rainbow corruption, red/blue/green channel swap, severe washout, oversaturation, crushed contrast, or black-frame lock was observed.
- Recommended final safe Theora preset: q7 1280x (`fps=30,scale=1280:-2:flags=lanczos,format=yuv420p`, `libtheora -q:v 7 -g 60`, `libvorbis -q:a 4`) because it satisfies Godot load/play/color and is less than half the q8 file size.
- Production cutin assets, battle logic, WorldMap logic, and cutin activation logic were not modified.

## v0.70-2 Theora Safe Encoding Test + Godot Color Playback Verification
- Started the safe Theora test from the non-production source `assets/video_source_test/cutin_test_01.mp4`.
- Confirmed existing production cutin video files remain separate under `assets/ui/cutin/videos/`; this pass did not overwrite or modify production cutin assets.
- Added test output folder `assets/video_test/theora_safe/` with a README documenting expected `.ogv` outputs.
- FFmpeg was not available in the current shell PATH and no repo-local `ffmpeg.exe` / `ffprobe.exe` was found, so the requested q7/q8 Theora `.ogv` files were not generated in this Codex pass.
- Added independent Godot test scene `scenes/dev/video_theora_test.tscn` and script `scripts/video_theora_test.gd`.
- The test scene uses `VideoStreamPlayer`, `expand = true`, autoload/play-on-ready behavior, an `OptionButton` to switch q7/q8/noaudio candidates, and logs stream path, file existence, ResourceLoader result, direct `VideoStreamTheora` fallback, `is_playing()`, and `finished`.
- Verification passed: `git diff --check`, Godot headless project load, and Godot headless load of `scenes/dev/video_theora_test.tscn`.
- Current Godot test result: the scene opens and reports the expected missing q7 output path without crashing. Actual `.ogv` import/resource load, non-black frame playback, and color correctness could not be verified because FFmpeg output files do not exist yet.
- Recommendation is not final yet. Once FFmpeg is available, test q7 1280x first as the safer candidate, then q8 1920x for quality/performance comparison.
- Remaining risk: Theora color corruption cannot be resolved until real q7/q8 outputs are generated and visually checked in Godot.

## v0.70-10A VideoStreamPlayer Debug Checkpoint Documentation
- Completed a documentation-only checkpoint after `v0.70-10 VideoStreamTheora Direct Load Test` at commit `22c519f8654600229000e3f833a39867a23a769a`.
- Current cutin system state: the Yi Sunsin specialty cutin layer displays normally, the PNG hero portrait and hero/skill text display normally, the centered cutin layout is applied, the 3-second cutin timeline still exits into the existing unique-skill effect flow, and the busy guard / PNG-text fallback structure remains intact.
- VideoStreamPlayer progress: earlier WebM/MP4 candidates were visible to `FileAccess` but did not load as Godot `VideoStream` resources (`load_null=true`, `is_video_stream=false`). After selecting `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv` in the Godot editor FileSystem, the Inspector showed it as a `VideoStream`, and `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv.uid` was generated locally.
- Current problem: the Theora 540p OGV appears to reach the Godot video resource/playback path, but playback shows rainbow/glitch-like corrupted color/frame output. The issue is now judged to be Theora encoding/decoding compatibility rather than missing file, z-index, layout, size, or fallback flow.
- Confirmed current experiment assets: `assets/ui/cutin/portraits/yi_sun_sin_cutin.png`, `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv`, and local `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv.uid`. The current experiment baseline is Theora OGV; previous VP8 WebM/MP4/legacy OGV entries remain historical/fallback context.
- Conclusion: VideoStreamPlayer or an equivalent video pipeline remains a must-solve foundation for game intro video, specialty cutins, victory/defeat videos, worldmap event cutscenes, opening, and ending. Image sequences remain a last-resort workaround, not the next preferred path.
- Recommended next task: `v0.70-11 Cutin Safe Theora Encoding Test`.
- Suggested next encoding candidates:
  - `ffmpeg -y -i "assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4" -t 3 -vf "scale=640:360:flags=lanczos,fps=24,format=yuv420p" -pix_fmt yuv420p -c:v libtheora -q:v 5 -g 48 -an "assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_360p_safe.ogv"`
  - `ffmpeg -y -i "assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4" -t 3 -vf "scale=960:540,fps=24,format=yuv420p" -pix_fmt yuv420p -c:v libtheora -q:v 6 -g 64 -an "assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p_q6_g64.ogv"`
- Next chat reading order: `agent/WORKFLOW_MANAGER.md`, `agent/CODEX_WORKFLOW_RULES.md`, `agent/GODOT_RULES.md`, `agent/CURRENT_STATE.md`, `agent/NEXT_TASKS.md`, `agent/HANDOFF_TO_CODEX.md`, `agent/CHANGELOG.md`, `agent/SESSION_LOG.md`.
- This pass changed documentation only. No code, scene, or asset file was intentionally modified.

## v0.70-10 VideoStreamTheora Direct Load Test
- Completed the Yi Sunsin specialty cutin VideoStreamTheora direct-load diagnostic pass.
- Yi Sunsin specialty cutin video selection now prioritizes `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv` first, then VP8 WebM, legacy OGV, snake_case WebM, and MP4.
- Confirmed local asset state: `yi_sun_sin_cutin.png`, `yi_sun_sin_cutin_bg_theora_540p.ogv`, `yi_sun_sin_cutin_bg_vp8.webm`, and `yi_sun_sin_cutin_bg.mp4` exist; `yi_sun_sin_cutin_bg.ogv` and `yi_sun_sin_cutin_bg.webm` are absent.
- Candidate diagnostics now log path, `FileAccess.file_exists`, `ResourceLoader.exists`, load-null result, loaded class, `is VideoStream`, and a failure-guess field for each candidate.
- Theora 540p OGV now gets a direct fallback attempt when `ResourceLoader.load()` does not produce a `VideoStream`: `VideoStreamTheora.new()` is created, its `file` property is checked and set dynamically, and the result is logged before assigning to `VideoStreamPlayer_Cutin`.
- `VideoStreamPlayer_Cutin` reuse, start stop/clear, stream assignment logging, `is_playing`, size, z-index, parent/draw-order diagnostics, delayed `0.3s` state log, and hide stop/clear behavior are preserved.
- `CUTIN_VIDEO_DEBUG_FORCE_TOP := false` remains committed as false for optional local visual isolation.
- The centered cutin banner/card layout, Yi Sunsin PNG/text fallback, busy guard, 3-second cutin timing, and post-cutin unique-skill effect continuation were preserved.
- Unique-skill effect logic, damage, 판정, AI, result, wounded/prisoner/death, battle overlay, camera, pop wave, direction-selection, and WorldMap UX logic were not intentionally changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. No GDScript warning/error output was observed in those headless checks.
- Headless scene load does not auto-trigger the Yi Sunsin cutin, so actual ResourceLoader results, direct Theora result, `is_playing`, and frame visibility still require Kimjak F6/manual helper verification.
- No tracked `.ogv.uid`, `.ogv.import`, or other video sidecar for `yi_sun_sin_cutin_bg_theora_540p.ogv` was observed after Codex verification.
- 김작 F6 manual QA should confirm the selected candidate is `_theora_540p.ogv`, candidate logs include `failure_guess`, direct Theora logs appear if ResourceLoader fails, stream class is non-null when assignment succeeds, `is_playing()` becomes true, video is visible, debug force-top isolates rendering if needed, PNG/text fallback remains intact, the cutin exits after 3 seconds, and the skill effect continues after cutin exit.
- Next candidates:
  - `v0.70-11 VideoStreamPlayer Final Fix or Alternative Pipeline Decision`
  - `v0.70-12 Specialty Skill Cutin Visual Polish`
  - `v0.70-13 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-14 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-9 VideoStreamPlayer Cutin Debug Pass
- Completed the first SamWar practical VideoStreamPlayer pipeline diagnostic pass for the Yi Sunsin specialty cutin.
- Added focused cutin video diagnostics in `scripts/battle_web_import_test.gd`: candidate path, `ResourceLoader.exists`, `load()` null/class result, `VideoStream` cast result, assigned stream class, `VideoStreamPlayer_Cutin.is_playing()`, visible/modulate/self_modulate, size, position/global_position, z-index, parent state, and draw-order indexes.
- The diagnostic logs run at cutin start before assignment, immediately after `play()`, and again after about `0.3s`; they do not log every frame.
- Added `CUTIN_VIDEO_DEBUG_FORCE_TOP := false`. When locally changed to `true`, it enlarges/raises `VideoStreamPlayer_Cutin` above the cutin layer for visual isolation; the committed default remains `false`.
- Added `_debug_play_cutin_video_only()` as a manual QA helper that can play only the selected cutin video for 3 seconds without automatically running in normal play.
- Preserved the current priority `vp8 webm > ogv > webm > mp4`; current local asset check still finds `yi_sun_sin_cutin_bg_vp8.webm` and `yi_sun_sin_cutin_bg.mp4`, while the requested OGV and snake_case non-VP8 WebM fallbacks are absent.
- The scene-authored child order already matched the desired stack: `ColorRect_Darken`, `VideoStreamPlayer_Cutin`, `TextureRect_Slash`, `TextureRect_Hero`, `Control_Text`. Runtime z-index is now made explicit in the same order.
- The central cutin banner/card layout, Yi Sunsin PNG/text fallback, busy guard, and 3-second cutin flow were preserved.
- Unique-skill effect logic, damage, 판정, AI, result, wounded/prisoner/death, battle overlay, camera, pop wave, direction-selection, and WorldMap UX logic were not intentionally changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. No GDScript warning/error output was observed in those headless checks.
- No tracked `.webm.uid`, `.webm.import`, or other video sidecar was generated for `yi_sun_sin_cutin_bg_vp8.webm` during Codex verification.
- Remaining risk: Codex headless scene load does not auto-trigger the Yi Sunsin cutin, so actual frame visibility and the new `[SPECIALTY_CUTIN_VIDEO_*]` runtime logs still require Kimjak F6/manual helper verification.
- 김작 F6 manual QA should confirm `_vp8.webm` is selected, stream class is non-null, player size is non-zero, `is_playing()` becomes true, the video is visible, debug force-top isolates rendering if needed, PNG/text fallback remains intact, and the skill effect continues after cutin exit.
- Next candidates:
  - `v0.70-10 Specialty Skill Cutin Visual Polish`
  - `v0.70-11 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-12 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-8 Cutin VP8 WebM Video Connection
- Completed the Yi Sunsin cutin VP8 WebM connection pass.
- Yi Sunsin specialty cutin video selection now prioritizes `vp8 webm > ogv > webm > mp4`, with `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm` first.
- The final priority use format is the FFmpeg-converted VP8 WebM 8M version. OGV remains only as an unstable fallback and was not deleted.
- The existing `VideoStreamPlayer_Cutin` node is still reused. Cutin start stops/clears the previous stream, selects the first existing loadable candidate, and starts playback from the beginning when load succeeds. Cutin hide still stops and clears the stream.
- If VP8 WebM or any fallback video cannot load as a Godot `VideoStream`, the cutin logs the failed candidate and keeps the PNG + hero name + skill name presentation instead of breaking the flow.
- The centered cutin banner/card layout from v0.70-6/v0.70-7 was not changed.
- Unique-skill effect logic, damage, 판정, AI, result, wounded/prisoner/death, battle overlay, camera, pop wave, direction-selection, and WorldMap UX logic were not intentionally changed.
- Asset check: `assets/ui/cutin/portraits/yi_sun_sin_cutin.png`, `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm`, and `assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4` are present. The requested OGV and snake_case non-VP8 WebM fallback files are not present in the current tracked asset list.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. No GDScript warning/error output or WebM stream/import warning was observed in those headless checks.
- No tracked `.webm.uid`, `.webm.import`, or other video sidecar was generated for `yi_sun_sin_cutin_bg_vp8.webm` during Codex verification.
- Remaining risk: Codex headless can confirm project/scene load and candidate order, but actual VP8 WebM frame visibility, image quality, and playback smoothness still require Kimjak F6 visual QA.
- 김작 F6 manual QA should confirm VP8 WebM visibility, image quality, centered banner layout, PNG/text fallback, 3-second pacing, post-cutin effect continuation, no soft lock, and normal auto/turn flow.
- Next candidates:
  - `v0.70-9 Specialty Skill Cutin Visual Polish`
  - `v0.70-10 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-11 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-7 Cutin OGV Video Fallback
- Completed the Yi Sunsin cutin OGV video fallback pass.
- Yi Sunsin specialty cutin video selection now prioritizes `ogv > webm > mp4`, with `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.ogv` first.
- The existing `VideoStreamPlayer_Cutin` node is still reused. Cutin start stops/clears the previous stream, selects the first existing candidate, attempts to load it, and starts playback from the beginning when load succeeds. Cutin hide still stops and clears the stream.
- If the selected OGV exists but cannot load as a Godot `VideoStream`, the cutin logs the load failure and keeps the PNG + hero name + skill name presentation instead of breaking the flow.
- The centered cutin banner/card layout from v0.70-6 was not changed.
- Unique-skill effect logic, damage, 판정, AI, result, wounded/prisoner/death, battle overlay, camera, pop wave, direction-selection, and WorldMap UX logic were not intentionally changed.
- Remaining risk: Codex headless can confirm project/scene load and selected-candidate logging structure, but real OGV frame visibility still requires Kimjak F6 visual QA.
- 김작 F6 manual QA should confirm OGV video visibility, centered banner layout, PNG/text fallback, 3-second pacing, post-cutin effect continuation, no soft lock, and normal auto/turn flow.
- Next candidates:
  - `v0.70-8 Specialty Skill Cutin Visual Polish`
  - `v0.70-9 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-10 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-6 Cutin WebM Video Connection + Center Layout Fix
- Completed the Yi Sunsin cutin WebM connection and center-layout fix pass.
- Yi Sunsin specialty cutin now uses a video candidate priority list: snake_case WebM, actual repo WebM (`Yi Sun Sin Cutin Bg.webm`), OGV, then MP4 fallback.
- Existing `VideoStreamPlayer_Cutin` is reused; cutin start stops/clears the previous stream, assigns the first loadable candidate, and starts playback from the beginning. Cutin hide stops and clears the stream.
- The cutin presentation no longer slides in from one side. It uses a centered banner/card layout with center-based scale/fade entry and exit.
- Yi Sunsin portrait size remains close to the v0.70-5 feel, but the portrait, hero name, and skill name are arranged around the centered cutin banner instead of reading as left-heavy.
- Kwon Yul and Jeong Do Jeon WebM assets are present as `Kwon Yul Cutin Bg.webm` and `Jeong Do Jeon Cutin Bg.webm`; they are not connected to activation yet.
- Godot headless did not generate tracked `.import` files for the WebM assets. If runtime VideoStream loading still fails in F6, a Godot-supported imported video format/path may still be needed, but PNG/text fallback remains intact.
- Unique-skill effect logic, damage, 판정, AI, result, wounded/prisoner/death, battle overlay, camera, pop wave, direction-selection, and WorldMap UX logic were not intentionally changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load with clean warning/error output.
- 김작 F6 manual QA remains required for actual WebM visibility, centered banner feel, portrait/text composition, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.
- Next candidates:
  - `v0.70-7 Specialty Skill Cutin Visual Polish`
  - `v0.70-8 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-9 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-5 Specialty Skill Video Cutin MVP
- Completed the first specialty-skill video cutin MVP for ally `yi_sunsin`.
- Added a reusable scene-authored `BattleUI/SkillCutinLayer` with darken layer, `VideoStreamPlayer`, slash accent, transparent PNG hero portrait, hero name label, skill name label, and an `AnimationPlayer` placeholder for future editor-authored polish.
- Ally Yi Sunsin unique skill now attempts the new 3-second cutin first and delays existing unique-skill effect application until the cutin finishes.
- Yi Sunsin cutin uses `res://assets/ui/cutin/portraits/yi_sun_sin_cutin.png` for the transparent PNG portrait and checks `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4` for the video background.
- The mp4 asset exists in the repo, but no Godot-imported VideoStream metadata was found during this pass. Runtime code detects this and keeps the cutin flow alive with the darken/portrait/text presentation; `ogv` or `webm` conversion may still be needed for actual video playback.
- If the Yi Sunsin cutin layer or portrait cannot be loaded, the existing unique-skill toast fallback path remains in use. Non-Yi-Sunsin heroes continue to use the existing toast/cutin flow.
- Busy guard prevents a second specialty cutin from overlapping an active one.
- Existing unique-skill effect, damage, buff/debuff, AI, result, wounded/prisoner/death, battle overlay, camera, pop wave, direction-selection, and WorldMap UX logic were not intentionally changed.
- Verification passed: Godot headless project load and `Battle_Fullscreen_Test.tscn` headless load. GDScript warning/error output was clean after fixing one enum typo and one full-rect size warning.
- 김작 F6 manual QA remains required for actual mp4 playback, cutin impact, 3-second length, portrait placement, skill-name readability, post-cutin effect continuation, fallback behavior, and battle-flow feel.
- Next candidates:
  - `v0.70-6 Specialty Skill Cutin Visual Polish`
  - `v0.70-7 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-8 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-4 Battle Overlay Rollback Shape + Palette Retune
- Completed the fourth v0.70 battle overlay polish task.
- Preserved the v0.70-3 pop wave/stagger reveal: range cells still appear from the active unit outward with distance-based delay and scale overshoot.
- Removed the v0.70-3 multi-layer internal octagon/center-fade band rendering from range overlay tiles and restored a simpler single-fill octagonal tactical tile structure closer to v0.70-2.
- Retuned movement range from the muddy steel-gray v0.70-3 tone to a clearer blue tactical palette while avoiding bright sky-blue/mint.
- Attack range, single-target, multi-target/unique-skill, and strategy overlays remain color-distinct with restored stronger role colors.
- Direction-selection arrow buttons keep the octagonal tile shape and pop reveal, but their role color is restored to the original gold/yellow direction-selection family instead of matching movement tiles.
- Camera zoom remains unchanged at `0.84`; default logical grid remains hidden.
- No battle rules, movement/attack 판정, damage formula, AI, result, wounded, prisoner, death, or WorldMap UX logic was intentionally changed.
- Verification passed: Godot headless project load and `Battle_Fullscreen_Test.tscn` headless load. GDScript warning/error output was clean in headless load.
- 김작 F6 manual QA remains required for pop wave retention, removal of stacked internal octagons, v0.70-2-like simple tile shape, movement blue taste, role-color separation, direction-selection color restoration, and click feel.
- Next candidates:
  - `v0.70-5 Battle Overlay Fine Color Tuning`
  - `v0.70-6 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-3 Battle Overlay Palette + Pop Wave Polish
- Completed the third v0.70 battle overlay polish task.
- Movement, attack, single-target, and multi-target overlay colors remain distinct, but the palette is now more muted and tactical: movement uses steel blue-gray, attack uses coral/rose red, single-target uses toned amber, multi-target uses muted violet, and strategy remains subdued teal.
- `scripts/battle_range_overlay_tile.gd` now favors center-fade style edge bands instead of a distinct small inner octagon, keeping the outline clear while letting terrain show through the center.
- Pop wave reveal is stronger: range cells start smaller at distance-sensitive scale, pop up to a stronger overshoot, then settle to `1.0`, with `0.06s` delay per grid distance.
- Direction selection arrow buttons now use the same octagonal tactical tile design language through `scripts/battle_facing_arrow_tile_button.gd`, with matching fill/outline/highlight and a short pop reveal.
- Current Camera2D zoom remains unchanged from v0.70-2 at `0.84`; default logical grid remains hidden.
- No battle rules, movement/attack 판정, damage formula, AI, result, wounded, prisoner, death, or WorldMap UX logic was intentionally changed.
- Verification passed: Godot headless project load and `Battle_Fullscreen_Test.tscn` headless load. GDScript warning/error output was clean in headless load.
- 김작 F6 manual QA remains required for palette taste, center-fade readability, terrain visibility, pop wave timing, direction tile unification, and click feel.
- Next candidates:
  - `v0.70-4 Battle Overlay Fine Color Tuning`
  - `v0.70-5 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-2 Battle Overlay Shape + Wave Tuning
- Completed the second v0.70 battle visual detail polish task.
- `Battle_Fullscreen_Test.tscn` `MainCamera` default zoom is now `0.84`, showing more battlefield scenery than the v0.70-1 `0.88` baseline.
- Movement/attack range overlays now render as clipped-corner octagonal tactical tiles through `scripts/battle_range_overlay_tile.gd`, while continuing to reuse the existing `MoveRangeOverlayLayer` cell pool.
- Overlay tiles now draw a low-alpha fill, softer inner fill, clear outline, and subtle inner highlight so terrain remains visible while the tactical area reads more clearly.
- Wave/stagger reveal is stronger: distance delay is `0.04s` per grid step, cells start at `0.86` scale, pop to `1.04`, then settle to `1.0`.
- Default logical grid remains hidden; internal grid coordinates, movement/attack range calculation, click conversion, and all battle rules remain unchanged.
- No damage formula, movement/attack 판정, AI, result, wounded, prisoner, death, or WorldMap UX logic was intentionally changed.
- Verification passed: `git diff --check`, Godot headless project load, and `Battle_Fullscreen_Test.tscn` headless load. GDScript warning/error output was clean in headless load.
- 김작 F6 manual QA remains required for zoom `0.84` feel, unit size, octagonal tile readability, outline strength, fill alpha, terrain visibility, wave timing, and click feel.
- Next candidates:
  - `v0.70-3 Battle Overlay Visual Fine Tuning`
  - `v0.70-4 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-1 Battle Visual Detail Polish Start
- Completed the first v0.70 detail-polish task on the battle engine visual layer.
- Default battle logical grid display is now hidden for normal play; the internal grid coordinate, cell calculation, movement range, attack range, and click conversion logic remain unchanged.
- `Battle_Fullscreen_Test.tscn` `MainCamera` default zoom is set to `0.88`, showing roughly 10-15% more battlefield art while preserving the scene-authored camera position.
- Movement and attack range overlays now use stronger translucent blue/red cells with a small inset so they read less like a full debug grid.
- Range overlays now appear with a quick unit-centered wave/stagger alpha and scale tween, and overlay hide paths kill outstanding tweens to avoid ghost cells.
- No battle rules, damage formula, movement/attack 판정, AI, result, wounded, prisoner, or death logic was intentionally changed.
- v0.70 detail polish has started from battle-engine visuals; WorldMap final UX/UI work is deferred to a later task.
- Verification passed: Godot headless project load and `Battle_Fullscreen_Test.tscn` headless load. F6 manual visual QA remains required for camera feel, overlay taste, wave timing, and click feel.
- Next candidates:
  - `v0.70-2 Battle Overlay Visual Tuning`
  - `v0.70-3 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.69-14A GDScript Reload Warning Cleanup Before v0.70
- Completed a warning-cleanup pass before entering `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Cleaned `scripts/worldmap_test.gd` GDScript reload warnings for duplicate local variable declarations, `Node.name` parameter shadowing, one mixed-type ternary, and an intentionally unused seasonal-loyalty parameter.
- No strategic logic, formulas, balance values, save/load structure, battle, invasion, diplomacy, espionage, tech, trade, or resource behavior was intentionally changed.
- Remaining work is `v0.70-1 WorldMap Final UX/UI Information Architecture`.

## v0.69-14 EASTWAR Strategic Logic Final Checkpoint
- v0.69 strategic logic implementation is closed at baseline:
  - `v0.69-13 Espionage Action Foundation MVP`
  - Commit: `0565f2d5f0acfde609e9df9e96d8e3b25726196c`
- Completed v0.69 core logic:
  1. `publicSupport` 민심
  2. seasonal loyalty 민심 기반 계절 충성도
  3. troop move loyalty efficiency 충성도 기반 병력 이동 손실
  4. recruitment/conscription 징병/모병
  5. revolt warning 반란 경고
  6. national tech data 국가 테크 데이터
  7. city tech data 도시 테크 데이터
  8. tech start/progress/effect 테크 착수/진행/일부 효과
  9. trade market price 무역 시세
  10. diplomacy relation score 외교 관계 점수
  11. tribute diplomacy 조공
  12. alliance proposal / military support request / trade agreement 외교 액션 foundation
  13. espionage info gathering 첩보 정보수집
  14. public support disrupt / loyalty disrupt / revolt instigation / wedge 첩보 액션 foundation
- Most v0.69 logic has been verified through helper/API/headless QA rather than final mouse-driven play UX.
- Real F6 mouse-based UX verification is deferred to `v0.70` WorldMap final UI work and should be performed feature by feature during the UI pass.
- Current City Detail / WorldMap UI remains a temporary display and minimal connection layer, not the final information architecture.
- Next baseline direction: `v0.70-1 WorldMap Final UX/UI Information Architecture`.

## v0.69-13 Espionage Action Foundation MVP
- Implemented the espionage action foundation finish pass in `scripts/worldmap_test.gd`.
- Added three chancellor-driven spy actions using the existing info gathering/publicSupport disruption structure: loyalty disruption, revolt instigation, and wedge driving.
- Loyalty disruption directly lowers target city loyalty in the MVP. Effect by political aptitude: `5 -> 10`, `4 -> 7`, `3 -> 5`, `2 -> 3`, `1 -> 1`.
- Loyalty disruption cost is `gold 500 + silk 50`; base cooldown is `10`, or `8` for a primary political chancellor. Detection cancels the effect and applies relation score `-40`.
- Revolt instigation requires target publicSupport `<= 50` and loyalty `<= 40`. Success records `_player_state["revolt_instigation"][city_id]` with `turns_remaining = 3` and aptitude-based probability boost. It does not trigger real revolt.
- Revolt instigation cost is `gold 800 + silk 100`; base cooldown is `15`, or `13` for a primary political chancellor. Detection cancels the record and applies relation score `-60`.
- Wedge driving requires two non-player factions that currently have `allied` status. Success lowers only their relation score; allied status is not auto-broken.
- Wedge cost is `gold 600 + silk 150`; base cooldown is `12`, or `10` for a primary political chancellor. Detection applies relation score `-20` to player-vs-each-target and does not affect the two targets.
- Added result records: `last_spy_loyalty_disrupt_result`, `last_spy_revolt_instigation_result`, `last_revolt_instigation_tick_result`, and `last_spy_wedge_result`.
- The existing shared `spy_cooldown` remains the common cooldown for information gathering, publicSupport disruption, loyalty disruption, revolt instigation, and wedge driving.
- Not implemented: assassination, actual revolt occurrence, owner neutral conversion, suppression battle, declaration of war, automatic hostile conversion, alliance break, or espionage UI.
- `GUIDE_v0.69_12_13_to_v0.70.md` was not present in the repo, so implementation followed the explicit v0.69-13 task scope.
- v0.69 espionage action foundation is now broad enough to transition toward `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Verification passed: `rg` for new helpers/result fields, temporary QA runner, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally.
- Remaining risks: all actions are helper/API-only without UI; revolt instigation is a stored boost only; spy action balance and final F6 UX validation remain pending.

## v0.69-12 Diplomacy Action Foundation MVP
- Implemented the first diplomacy action foundation after tribute in `scripts/worldmap_test.gd`.
- Added helper/API actions only: `_propose_alliance(target_faction_id, resource_package, duration_turns)`, `_request_military_support(target_faction_id)`, and `_propose_trade_agreement(target_faction_id)`.
- `GUIDE_v0.69_12_13_to_v0.70.md` was not present in the repo, so implementation followed the explicit v0.69-12 task scope and verification requirements.
- Alliance proposal uses deterministic MVP acceptance chance: relation score + package bonus, clamped to `0..95`, accepted at `>= 70`. Proposal package is paid when the proposal is attempted.
- Successful alliance sets relation `status = allied`, records `alliance_turns_remaining`, and does not declare war or move troops.
- Military support requests require `allied` status. The MVP records acceptance/rejection only; it does not move troops or create joint invasion.
- Military support rejection applies relation score `-20`; the third and later repeated rejection applies `-40`.
- Trade agreement requires relation score `>= 50`, costs `gold 200 + silk 50`, records `trade_agreement_turns_remaining = 20`, and adds Phase A trade route bonus `+0.15` through a separate trade-agreement bonus field.
- Existing publicSupport, loyalty, tech, supply, espionage, troop movement, battle, invasion, and defense formulas were not intentionally changed.
- No diplomacy UI, war declaration, actual military support movement, joint invasion, or trade transaction execution was implemented.
- Verification passed: `rg` for new helpers/result fields, temporary QA runner, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load.
- Remaining risks: acceptance formulas are deterministic MVP policy pending balance; alliance/trade agreement duration is recorded but not yet expired by a turn pipeline; no player-facing diplomacy action UI exists.

## v0.69-11B Espionage Public Support Disrupt MVP
- Implemented the first offensive espionage action MVP, publicSupport disruption, in `scripts/worldmap_test.gd`.
- This task implements only publicSupport disruption. Loyalty disruption, revolt instigation, alienation, assassination, and real revolt remain unimplemented.
- Added fixed MVP cost: `SPY_PUBLIC_SUPPORT_DISRUPT_COST = {"gold": 300}`.
- Added disruption amount by political aptitude: `5 -> 20`, `4 -> 15`, `3 -> 10`, `2 -> 5`, `1 -> 3`.
- Added helpers: `_get_spy_public_support_disrupt_amount`, `_get_spy_public_support_disrupt_cost`, `_can_disrupt_city_public_support`, `_roll_spy_public_support_disrupt_result`, and `_disrupt_city_public_support`.
- Disruption uses the existing shared `spy_cooldown`. Base cooldown is `8`; primary political chancellor applies the existing `-2` cooldown bonus, making it `6`.
- If disruption succeeds and is not detected, target city publicSupport decreases by the aptitude-based amount, clamped to `0..100`.
- If detected, the effect is canceled, target publicSupport is unchanged, and relation score changes by `-30` through `_adjust_faction_relation_score(..., "spy_public_support_disrupt_detected")`.
- Detection does not auto-convert status to hostile, does not declare war, does not trigger revolt, and does not change owner.
- Added `_player_state["last_spy_public_support_disrupt_result"]`.
- Verification passed: `rg` for new helpers/result field, temporary QA runner, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally.
- QA runner confirmed no-chancellor/no-political/own-city/resource/iron-wall blocks, effect amount table, success without detection publicSupport decrease, failure without detection no change, detection cancels effect and applies relation `-30`, no automatic hostile status, cooldown set/decrement, save/load preservation, and no unintended loyalty/troop/tech mutation.
- Next candidates: `v0.69-11C Espionage Detection Penalty Audit` or `v0.69-10C Alliance War Status Foundation MVP`.
- Remaining risks: no player-facing espionage action UI exists; detection penalty is limited to score only; repeated disruption balance needs later tuning; final F6 espionage UX validation remains deferred.

## v0.69-11 Espionage Info Gathering MVP
- Implemented the first Espionage Info Gathering MVP in `scripts/worldmap_test.gd`.
- Espionage subject is the current chancellor. No chancellor means spy info gathering is unavailable.
- Political aptitude is read from the existing chancellor hero data. Political primary/secondary aptitude enables spy info gathering; primary political type gets the MVP cooldown bonus.
- Success chance by political aptitude: aptitude `5 -> 80`, `4 -> 65`, `3 -> 50`, `2 -> 35`, `1 -> 20`.
- Information visibility by aptitude: `5` reveals troops/resources/publicSupport/loyalty/governor/tech, `4` reveals troops/resources/publicSupport/loyalty, `3` reveals troops/resources, `2` reveals troops, and `1` reveals deterministic estimated troops.
- Added detection chance calculation from target city security/public order and loyalty. Political primary chancellor reduces detection chance by `10`.
- `_gather_spy_info()` supports forced rolls for deterministic QA, records success/failure/detected state, and creates payload only on success.
- Detection is recorded only. No relation penalty, status change, war, revolt, or target-city mutation is applied in this MVP.
- Added `spy_cooldown` and `_advance_spy_cooldown_for_world_turn()`. Base cooldown is `6`; primary political chancellor cooldown is `4`.
- Added result records: `_player_state["last_spy_result"]` and `_player_state["last_spy_cooldown_result"]`.
- Not implemented: publicSupport disruption, loyalty disruption, revolt instigation, alienation, assassination, espionage UI, war declaration, alliance/trade agreement, or battle/invasion/defense changes.
- Verification passed: `rg` for spy helpers/result fields, temporary QA runner, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally.
- QA runner confirmed no-chancellor/no-political/own-city blocks, success chance table, visibility table, enemy-city availability, forced success/failure/detection, payload fields, cooldown `4/6`, cooldown decrement, save/load preservation, and no target city/relation/resource/tech mutation.
- Next candidates: `v0.69-11B Espionage Public Support Disrupt MVP` or `v0.69-10C Alliance War Status Foundation MVP`.
- Remaining risks: random live execution is helper-only without UI; detection has no gameplay penalty yet; target tech/national data remains limited by existing data structures; final F6 espionage UX validation remains deferred.

## v0.69-10B Tribute Diplomacy Action MVP
- Implemented the first diplomacy action MVP, tribute, in `scripts/worldmap_test.gd`.
- Tribute is API/helper only. No diplomacy UI, button, alliance proposal, trade agreement, declaration of war, espionage, revolt instigation, or specialty trade execution was added.
- Tribute cost MVP is deterministic: `gold 300` + `silk 100`.
- Tribute relation gain MVP is deterministic `+20`, clamped through the existing relation score `0..100` rules.
- Tribute can target neutral/allied factions and is rejected for invalid/self targets, hostile status, suspended status, active tribute cooldown, or insufficient resources.
- Tribute sets a separate `tribute_cooldown` field to `5` turns. The existing relation `cooldown` field is preserved and not reused, avoiding Phase A trade/suspended-status conflict.
- Added helpers: `_get_tribute_cost`, `_can_send_tribute`, `_calculate_tribute_relation_gain`, `_send_tribute`, and `_advance_diplomacy_cooldowns_for_world_turn`.
- Added result records: `_player_state["last_tribute_result"]` and `_player_state["last_diplomacy_cooldown_result"]`.
- Domestic world turn now decreases `tribute_cooldown` once per turn after relation normalization.
- Status still does not auto-convert to allied or hostile from score changes. Phase A trade multiplier remains status-based and unchanged.
- Verification passed: `rg` for tribute helpers/result fields, temporary QA runner, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally.
- QA runner confirmed neutral allowed, hostile/suspended/self/resource shortage rejected, cost subtraction, score `+20`, score clamp to `100`, no status auto-allied, `tribute_cooldown` set/decremented/reset behavior, save/load preservation, Phase A trade income invariance, and no unintended publicSupport/loyalty/troop/tech mutation.
- Next candidates: `v0.69-10C Alliance War Status Foundation MVP` or `v0.69-11 Espionage Info Gathering MVP`.
- Remaining risks: tribute has no player-facing UI; gain/cost are fixed MVP values; no AI/diplomacy response exists; final F6 diplomacy UX validation remains deferred.

## v0.69-10 Diplomacy Relation Score MVP
- Implemented the first Diplomacy Relation Score MVP in `scripts/worldmap_test.gd`.
- `faction_relations` now supports score-based relationship data while preserving existing status behavior: each normalized relation entry has `status`, `score`, and `cooldown`.
- Added score bounds and default: `DIPLOMACY_SCORE_MIN = 0`, `DIPLOMACY_SCORE_MAX = 100`, `DIPLOMACY_DEFAULT_SCORE = 50`.
- Added relation helpers: `_ensure_faction_relation_entry`, `_get_faction_relation_entry`, `_get_faction_relation_score`, `_get_faction_relation_band`, `_adjust_faction_relation_score`, and `_normalize_faction_relations_for_world_state`.
- `relation_band` is separate from `status`: score `>=70` is `friendly`, `31..69` is `neutral`, and `<=30` is `hostile`.
- Allied/hostile status does not change automatically from score. `allied`, `hostile`, and `suspended` statuses are preserved until future explicit diplomacy actions.
- Phase A inter-faction trade still uses status-based multipliers only. Score/band are added to trade route output for display/debug context and do not affect income.
- Domestic world turn normalizes known faction pairs once before Phase A trade calculation; this only creates/patches relation entries and does not auto-adjust scores.
- Added result records: `_player_state["last_diplomacy_relation_result"]` and `_player_state["last_diplomacy_normalize_result"]`.
- Not implemented: tribute, trade agreements, alliance proposal/acceptance, declaration of war, espionage, revolt instigation, specialty trade execution, or diplomacy UI.
- Verification passed: `rg` for diplomacy helpers/result fields, temporary QA runner, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally.
- QA runner confirmed default score patching, status/cooldown preservation, new neutral score entries, score clamp `0..100`, band thresholds, no automatic status conversion, Phase A trade income unchanged by score, route score/band fields, save/load score preservation, and no resource/publicSupport/loyalty/troop/tech mutation.
- Next candidates: `v0.69-10B Tribute Diplomacy Action MVP` or `v0.69-11 Espionage Info Gathering MVP`.
- Remaining risks: score has no player-facing action consumer yet; normalization currently initializes all known city-owner faction pairs; final diplomacy UI/F6 UX validation remains deferred.

## v0.69-9 Trade Deepening Data Market Price MVP
- Implemented the first Trade Deepening Data + Market Price MVP in `scripts/worldmap_test.gd`.
- Added deterministic market price helpers for resource base prices, display names, seasonal multipliers, situation multipliers, and market trend classification.
- Market price resources are `rice`, `barley`, `seafood`, `salt`, `silk`, `iron`, `wood`, and `horse`; `gold` is excluded because it is the pricing basis.
- Seasonal prices use the existing 40-turn calendar: turns `1..10` spring, `11..20` summer, `21..30` autumn, `31..40` winter, and turn `41` wraps to spring.
- Situation context is future-proof only: `war_state`, `famine`, `abundant_harvest`, `supply_isolated_count`, and `alliance_recently_signed`. No event system, war system, diplomacy, or alliance implementation was added.
- `_update_trade_market_for_world_turn()` records `_player_state["last_trade_market_result"]` with `turn`, `season`, `season_label`, `context`, and per-resource `prices` entries containing `name`, `base_price`, `season_multiplier`, `situation_multiplier`, `price`, and `trend`.
- The domestic turn pipeline updates the market once after tech progress/effect handling and before the summary is finalized. This lets the existing supply isolation result feed `supply_isolated_count`.
- Turn summary now includes one compact market line such as `시세: 쌀 60G → / 소금 114G ↑ / 비단 125G →`.
- Existing Phase A inter-faction trade income remains separate and unchanged. Market prices do not apply resources, do not execute trades, and do not alter faction relations.
- Not implemented: manual trade, resource exchange execution, trade agreements, maritime trade, pirate loss, hero trade traits, random price volatility, trade UI, and additional tech effects.
- Verification passed: `rg` for new market helpers/result field, temporary QA runner, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally.
- QA runner confirmed base prices, seasonal wrap, war/famine/abundant/isolated/alliance multipliers, deterministic prices, no `resource_stock` mutation, no inter-faction trade result mutation, and `last_trade_market_result` recording.
- Next candidates: `v0.69-9B Specialty Trade Data MVP` or `v0.69-10 Diplomacy Relation Score MVP`.
- Remaining risks: the market is calculation-only and has no transaction consumer yet; situation context mostly defaults false until future event/diplomacy systems exist; final F6 trade UX validation remains for later UI work.

## v0.69-8B Tech Effect Application MVP
- Implemented the first Tech Effect Application MVP in `scripts/worldmap_test.gd`.
- Effects apply only from completed techs. In-progress techs still have no effect.
- Added completed-tech effect helpers and `_apply_completed_tech_effects_for_world_turn()`.
- One-time effect implemented: `legal_reform` applies publicSupport `+5` to all player-owned cities once, clamped to `0..100`, with duplicate prevention through `_player_state["applied_tech_effects"]["national"]["legal_reform"]`.
- Continuous national effect implemented: `tax_reform` applies domestic gold income `x1.10`. This applies only to domestic gold income, not inter-faction trade income.
- Continuous city effect implemented: `street_market` applies that city's domestic gold income `x1.05`. This applies only to domestic gold income, not inter-faction trade income.
- Conscription tech effects implemented: `barracks` gates automatic conscription by city; cities without completed `barracks` record added `0` and reason `barracks_required`. `conscription_system` applies turnly automatic conscription add `x1.10`, capped by available conscription. Capacity is unchanged.
- Recognized but no consumer yet: `national_foundation`, `improved_farming_tools`, and `fishing_village`.
- Completed effect results include `last_tech_effect_result`; recognized no-consumer effects are recorded without changing values.
- No battle effects, turtle ship, special unit, diplomacy/espionage, real revolt, trade deepening, tech UI, or auto tech selection was implemented.
- Verification passed: `rg` checks for effect helpers/result fields, temporary QA runner, scoped diff review, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally after 134 seconds.
- QA runner confirmed legal_reform one-time publicSupport +5 and duplicate prevention, applied_tech_effects save/load preservation, tax_reform domestic gold x1.10 without trade change, street_market city domestic gold x1.05, combined multiplier, barracks conscription gate, conscription_system +10% add with available cap, no-consumer recognition, and no unintended loyalty/troop/resource mutation.
- Next candidates: `v0.69-9 Trade Deepening MVP` or a focused follow-up for additional tech effects.
- Remaining risks: tech UI/selection still does not exist; many tech effects remain unimplemented; barracks gating changes automatic conscription balance and needs later gameplay review; no final F6 UX validation exists.

## v0.69-8 Tech Start Progress Pipeline MVP
- Implemented Tech Start/Progress Pipeline MVP in `scripts/worldmap_test.gd`.
- National and city tech can now start, deduct cost, enter `in_progress`, decrement `remaining_turns` once per domestic world turn, and move to `completed` when `remaining_turns <= 0`.
- Added `_get_tech_duration_turns(tier)` with MVP duration defaults: basic `4`, mid `9`, advanced `18`, capstone `28`, rare `30`. Definition `duration_turns` overrides this if present.
- Added generic resource cost helpers `_can_pay_generic_resource_cost(cost)` and `_apply_generic_resource_cost(cost)`. `food` is handled as the existing rice+barley+seafood pool and deducted in order `rice -> barley -> seafood`.
- `_start_national_tech(tech_id)` now performs the MVP start flow: requirement/cost check, cost deduction, duration setup, `national_tech.in_progress` registration, and `last_tech_start_result` recording.
- `_start_city_tech(city_id, tech_id)` now performs the same MVP start flow for per-city `city_tech.in_progress`.
- Added `_advance_national_tech_progress_for_world_turn()` and `_advance_city_tech_progress_for_world_turn()`.
- Completed entries include `effect_summary` and `effect_applied: false`. No tech effect is applied yet.
- Domestic turn pipeline now advances tech progress after publicSupport drift, city loyalty drift, seasonal loyalty, conscription, and revolt warning. This keeps tech progress once-per-domestic-turn under the existing `last_domestic_apply_turn` duplicate guard.
- Turn summary/status includes minimal completion text only when a national or city tech completes.
- Not implemented: tech effect application, UI, auto tech selection, governor/chancellor auto progress, or final UX.
- Verification passed: `rg` for new/changed helpers and result fields, temporary QA runner, scoped diff review, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally after 134 seconds.
- QA runner confirmed national/city tech start, cost deduction, `in_progress` registration, duration/remaining turns, progress decrement, completed migration, in-progress removal, completed restart block, food cost order, cost shortage block, placeholder-condition block, no publicSupport/loyalty/troop mutation from tech progress helpers, no effect application, and no duplicate domestic-turn decrement.
- Next candidates: `v0.69-8B Tech Effect Application MVP` or `v0.69-9 Trade Deepening MVP`.
- Remaining risks: effects are still only recorded as pending; no UI exists to choose/start tech; `connected_supply_city_count`, duration tuning, and maritime data linkage remain future work.

## v0.69-7A National City Tech Data Consistency Audit
- Completed National/City Tech Data Consistency Audit in `scripts/worldmap_test.gd`.
- Added `_validate_tech_data_consistency()` as a QA/debug helper only. It checks definitions and returns missing refs, invalid cost keys, invalid aptitude types, missing image fields, and placeholder conditions without mutating player state, resources, troops, publicSupport, or loyalty.
- Required national tech cross-check: `mint -> unified_currency`, `armored_infantry -> military_reform`, and `turtle_ship -> military_reform` were valid. `dried_fish_supply_base -> logistics_system` was missing and was corrected by adding the documented national tech `logistics_system` / `병참 제도`.
- City tech `requires` cross-check: all city prerequisite IDs now resolve inside `_get_city_tech_definitions()`.
- National tech `requires` cross-check: all national prerequisite IDs now resolve inside `_get_national_tech_definitions()`.
- Cost key audit passed against `gold`, `food`, `rice`, `barley`, `seafood`, `silk`, `iron`, `wood`, `salt`, and `horse`. `food` remains an MVP food-pool key checked as rice+barley+seafood.
- Aptitude type audit passed for `administrative`, `economic`, `militaryAdmin`, `diplomatic`, `political`, and `maritime`; empty strings remain allowed.
- National tech definitions now include empty `icon_path` and `image_path` fields, matching city tech definitions. No image loading or UI was added.
- Placeholder conditions remain blocking/not auto-passed: `chancellor_type_turns`, `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, `has_hero_yi_sunsin`, `has_city_tech_mint`, `has_silkroad_or_trade_port`, `neutral_faction_count`, and `allied_faction_count`.
- Not implemented: national/city tech progress, completion, cost deduction, effect application, UI, or governor auto-selection.
- Verification passed: `rg` for audit helper, temporary QA runner, scoped diff review, `git diff --check`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. Godot `--check-only` timed out locally after 134 seconds.
- Next candidate: `v0.69-8 Tech Start/Progress Pipeline MVP`.
- Remaining risks: `connected_supply_city_count` is now shared as a placeholder condition for both `logistics_system` and `dried_fish_supply_base`; maritime governor type is allowed but not currently backed by a dedicated hero data source unless future data adds it; no research lifecycle or final F6 UX validation exists yet.

## v0.69-7 City Tech Tree Data MVP
- Implemented City Tech Tree Data MVP in `scripts/worldmap_test.gd`.
- This pass is data/state/check helpers only. It does not start city tech, deduct costs, progress turns, complete techs, apply effects, add UI, or run governor auto-selection.
- Added `_get_city_tech_definitions()` with the MVP branch spine for agriculture, commerce, fishery/coastal, military, and coastal/naval techs.
- Each city tech definition includes `icon_path` and `image_path` placeholders as empty strings for later tech UI image connection. No `load()` or UI display was added.
- Added per-city `city_tech` runtime state with `completed`, `in_progress`, and `available_cache`, normalized by `_ensure_city_tech_state(city_id)`.
- Added lookup helpers: `_get_completed_city_tech_ids`, `_is_city_tech_completed`, `_is_city_tech_in_progress`, and `_get_city_tech_definition`.
- Added `_get_city_governor_aptitude_type(city_id)` using the existing city governor id and existing hero aptitude fields. No new hero/governor data model was created.
- Added `_check_city_tech_requirements(city_id, tech_id)` for city prerequisites, required national tech, required governor type, agriculture/commerce/fishery rating, population, loyalty, and coastal checks.
- Added `_can_pay_city_tech_cost(city_id, tech_id)` using current `resource_stock`; `food` cost is checked as the existing rice+barley+seafood pool and is not deducted.
- Added `_can_start_city_tech(city_id, tech_id)` to combine completed/in-progress, requirement, and cost checks.
- `_start_city_tech(city_id, tech_id)` is intentionally a no-op skeleton that records the last start check and returns `false`; actual start/cost/progress/complete/effect application is deferred.
- Minimal save/load preservation was added for the `city_tech` field in city runtime state. Save/load core flow was not rewritten.
- Placeholder conditions are not auto-passed. They return missing conditions: `governor_type_turns_not_tracked`, `food_surplus_turns_not_supported_yet`, `connected_supply_city_count_not_supported_yet`, and `has_hero_yi_sunsin_not_supported_yet`.
- Not implemented: national tech progress/completion, city tech start/progress/completion, cost deduction, tech effects, city tech UI, governor auto tech selection, or final UX.
- PublicSupport, loyalty, recruitment/conscription, revolt, national tech formulas, trade, supply, troop movement, battle/invasion/defense, and save/load core formulas/logic were not changed.
- Verification passed: `rg` checks for city tech helpers/state, scoped diff review confirming no large UI/battle/save-load/core formula changes, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary QA runner. Godot `--check-only` timed out locally after 134 seconds.
- QA runner confirmed required definitions, icon/image placeholders, prerequisite blocking, national tech unlock blocking, governor mismatch blocking, coastal true/false checks, loyalty true/false checks, placeholder blocking, cost shortage reporting, completed/in-progress blocking, and no resource/troop/publicSupport/loyalty mutation from check helpers.
- Next candidates: `v0.69-8 Tech Start/Progress Pipeline MVP` or `v0.69-6B National Tech Start/Progress MVP`.
- Remaining risks: placeholder conditions block several advanced techs; maritime governor type has no dedicated data source in current hero data unless a hero explicitly carries that type; no research lifecycle, effect application, UI, or final F6 UX validation exists yet.

## v0.69-6 National Tech Tree Data MVP
- Implemented National Tech Tree Data MVP in `scripts/worldmap_test.gd`.
- This pass is data/state/check helpers only. It does not start tech research, deduct costs, progress turns, complete techs, apply effects, or add UI.
- Added `_get_national_tech_definitions()` with the MVP branch spine for foundation, administrative, economic, military, diplomatic, and political national techs.
- Added national tech state under `_player_state["national_tech"]` with `completed`, `in_progress`, and `available_cache`, initialized by `_ensure_national_tech_state()`.
- Added lookup helpers: `_get_completed_national_tech_ids`, `_is_national_tech_completed`, `_is_national_tech_in_progress`, and `_get_national_tech_definition`.
- Added `_get_current_chancellor_aptitude_type()` using the existing assigned chancellor hero's primary chancellor type. No new chancellor system was created.
- Added `_check_national_tech_requirements(tech_id)` for prerequisite, required chancellor type, owned city count, governor-assigned city count, national loyalty, average loyalty, and average commerce checks.
- Added `_can_pay_national_tech_cost(tech_id)` using current `resource_stock`; `food` cost is checked as the existing rice+barley+seafood pool and is not deducted.
- Added `_can_start_national_tech(tech_id)` to combine completed/in-progress, requirement, and cost checks.
- `_start_national_tech(tech_id)` is intentionally a no-op skeleton that records the last start check and returns `false`; actual start/cost/progress/complete/effect application is deferred.
- Placeholder conditions are not auto-passed. They return missing conditions: `chancellor_type_turns_not_tracked`, `allied_faction_count_not_supported_yet`, `neutral_faction_count_not_supported_yet`, `has_city_tech_mint_not_supported_yet`, and `has_silkroad_or_trade_port_not_supported_yet`.
- Not implemented: city tech tree, national tech start/progress/completion, cost deduction, effects, UI, auto tech selection, or final UX.
- PublicSupport, loyalty, revolt, recruitment/conscription, troop movement, trade, supply, battle/invasion/defense, and save/load core formulas/logic were not changed.
- Verification passed: `rg` checks for national tech helpers/state, scoped diff review confirming no UI/battle/save-load/core formula changes, `battle_web_import_test.gd` unchanged review, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary QA runner. Godot `--check-only` timed out locally after 134 seconds.
- QA runner confirmed definitions, national_foundation availability, prerequisite blocking, chancellor type mismatch, owned city count, national loyalty, average loyalty, average commerce, placeholder blocking, cost shortage reporting, completed/in-progress blocking, and no player_state/resource/troop mutation from check helpers.
- Superseded by `v0.69-7`: City Tech Tree Data MVP is complete.
- Next candidates: `v0.69-8 Tech Start/Progress Pipeline MVP` or `v0.69-6B National Tech Start/Progress MVP`.
- Remaining risks: chancellor type duration, faction counts, city mint tech, and silkroad/trade-port checks are placeholders; no research lifecycle or effect application exists yet; UI/F6 validation is deferred.

## v0.69-5 Revolt Warning Foundation MVP
- Implemented revolt warning foundation logic in `scripts/worldmap_test.gd`.
- Revolt warning uses the combined `publicSupport + loyalty` condition only.
- Risk states are locked to three levels: `stable`, `warning`, and `danger`.
- Warning threshold: `publicSupport <= 40` and `loyalty <= 40`.
- Danger threshold: `publicSupport <= 30` and `loyalty <= 30`.
- Added `_calculate_city_revolt_risk(city_id)` to read current city publicSupport and loyalty and return risk flags plus reasons.
- Added `_apply_revolt_warning_check_for_world_turn()` to scan player-owned cities, aggregate `warning_count` and `danger_count`, and record `_player_state["last_revolt_warning_result"]`.
- Domestic turn order is now: publicSupport drift, existing city loyalty drift, seasonal loyalty from publicSupport, conscription, then revolt warning check. This lets revolt warning read the latest publicSupport and loyalty values.
- City Detail internal/supply area shows minimal revolt risk text with current publicSupport, loyalty, and reasons. Turn summary includes revolt warning/danger counts.
- This MVP is calculation/recording/display only. It does not trigger revolts, does not change city owner to neutral, does not create suppression battles, and does not modify troops.
- Espionage-driven revolt agitation is not implemented. Map warning markers, icons, colors, and final UI are deferred.
- PublicSupport, seasonal loyalty, conscription/recruitment, troop movement, P0-1/P0-2/Phase A/Phase B, battle, and save/load formulas/cores were not changed.
- Current validation remains headless/API-centered. Real F6 mouse-based UX verification is deferred to the June City Detail/WorldMap UI overhaul.
- Verification passed: `rg` checks for revolt helpers/constants/result field, scoped diff review confirming no owner/neutral/save-load/core formula changes, `battle_web_import_test.gd` unchanged review, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary QA runner. Godot `--check-only` timed out locally after 134 seconds.
- QA runner confirmed stable/warning/danger thresholds, low-only cases do not escalate to warning/danger, result recording, warning/danger counts, no publicSupport/loyalty/troop/owner mutation, and turn summary danger text.
- Remaining risks: this is warning-only; actual revolt occurrence, neutralization, suppression battle flow, espionage agitation, map markers, and final UX remain future work.

## v0.69-4 Recruitment/Conscription Foundation MVP
- Implemented recruitment/conscription foundation logic in `scripts/worldmap_test.gd`.
- Conscription is loyalty-based: `_get_conscription_capacity_by_loyalty(city_id)` calculates the city conscription capacity from current city `loyalty` / `cityLoyalty`, and `_get_city_conscription_available(city_id)` subtracts current stationed troops from that capacity.
- Automatic conscription is a slow free growth MVP: `_apply_city_conscription_for_world_turn()` runs for player-owned cities in the domestic turn after publicSupport drift, existing city loyalty drift, and seasonal loyalty from publicSupport, then adds `min(available, 100)` troops through `_set_city_runtime_troops`.
- Conscription directly changes only city troops. It does not reduce population and does not directly change `publicSupport` or `loyalty`.
- Recruitment is publicSupport-based: `_get_recruitment_limit_by_public_support(city_id)` sets one-time recruitment limits from current city `publicSupport`.
- Recruitment is an immediate paid growth MVP: `_recruit_troops(city_id, amount)` validates ownership, 100-troop amount units, publicSupport limit, peacetime state, and resource affordability, then increases city troops and pays resources.
- Recruitment cost is `gold = amount` and `food = amount / 2`, matching the 100 troops -> gold 100 + food 50 rule.
- MVP food pool payment is national `resource_stock` deduction in this order: `rice -> barley -> seafood`. No new food resource model or resource_stock structure was introduced.
- Recruitment directly changes only troops and national resources. It does not reduce population, does not directly change `publicSupport`, does not directly change `loyalty`, and does not implement recruitment fatigue/publicSupport decline.
- City Detail internal/supply tab now shows minimal text for conscription capacity, available conscription, expected automatic conscription, recruitment limit, and sample recruitment cost. This is temporary display only, not final UX.
- Current validation remains headless/API-centered. Real F6 mouse-based UX verification for these displays is deferred to the June City Detail/WorldMap UI overhaul.
- Not implemented: population decrease, recruitment fatigue, publicSupport loss from recruitment, recruitment button/panel, revolt, tech trees, trade deepening, diplomacy/espionage, battle scene changes, save/load core rewrite, or large UI refactor.
- Verification passed: `rg` checks for all new helpers/result fields, scoped diff review confirming publicSupport/seasonal loyalty/troop move/P0-2 formulas were not modified, `battle_web_import_test.gd` unchanged review, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary QA runner. Godot `--check-only` timed out locally after 134 seconds.
- QA runner confirmed loyalty capacity thresholds, available capacity clamp at current troops, automatic conscription `min(available, 100)`, no direct publicSupport/loyalty changes from conscription, save/load troop preservation, publicSupport recruitment limits, recruitment cost, resource shortage rejection, successful recruitment troop/resource changes, no direct publicSupport/loyalty changes from recruitment, no automatic recruitment during conscription, and last result recording.
- Remaining risks: recruitment has no player-facing execution UI yet; national food-pool deduction is MVP-level; no population/fatigue effects exist yet; final manual UX verification is deferred to the June UI pass.

## v0.69-3A Strategic Logic Checkpoint Documentation
- Documentation-only checkpoint for the completed v0.69-1 through v0.69-3 strategic logic foundation.
- Completed strategic logic chain:
  - `v0.69-1 Public Support MVP`
  - `v0.69-2 Seasonal Loyalty From Public Support MVP`
  - `v0.69-3 Troop Move Loyalty Efficiency Final Patch`
- The core v0.69 foundation is now locked at the logic level: city `publicSupport` affects seasonal city `loyalty`, and current city `loyalty` drives troop movement loss.
- This establishes the intended EASTWAR chain: livelihood/domestic stability -> seasonal military will -> military-operation efficiency.
- Current verification is headless/API-centered. Real F6 mouse-based UX verification is intentionally deferred until the June city information panel and WorldMap UX/UI redesign phase.
- Current City Detail UI remains a minimal display and temporary connection surface for the v0.69 logic. It is not final UX.
- Starting in June, feature-by-feature manual verification should run alongside the city information panel and WorldMap UX/UI overhaul.
- Superseded by `v0.69-4`: recruitment/conscription foundation is now implemented. UX validation for the v0.69-1 through v0.69-4 systems should be revisited during the later UI redesign.
- No code, formulas, UI, recruitment, revolt, tech tree, trade deepening, diplomacy, espionage, or save/load work was done in this checkpoint.
- Remaining risks: headless/API QA validates the strategic logic path, but mouse flow, visual clarity, Korean copy fit, and final player-facing comprehension remain open until the June UI verification pass.

## v0.69-3 Troop Move Loyalty Efficiency Final Patch
- Implemented the final loyalty-based troop movement loss formula in `scripts/worldmap_test.gd`.
- C1 manual movement no longer preserves total troop count. The old total-preservation movement was an MVP validation structure and is replaced in v0.69-3.
- Final formula: `commanded_amount` departs from the source city, `arrived_amount = floor(commanded_amount * from_loyalty / 100.0)`, and `lost_amount = commanded_amount - arrived_amount`.
- Source city troops decrease by `departed_amount`; destination city troops increase only by `arrived_amount`. `lost_amount` is recorded as desertion/straggler loss during movement.
- Movement loss uses the source city's current `loyalty` / `cityLoyalty` via the existing city loyalty helper. `publicSupport` is not used directly; it only matters later through already-seasonalized loyalty.
- `_can_move_troops` remains commanded-amount based, including the minimum source-garrison check against `from_troops - commanded_amount`.
- `_player_state["last_troop_move_result"]` now records `commanded_amount`, `departed_amount`, `arrived_amount`, `lost_amount`, `from_loyalty`, source/destination post-move troops, and turn information while keeping `amount` for compatibility.
- C2 chancellor rebalance approval still delegates to `_move_troops`, so approved C2 movement receives the same loyalty loss formula without separate execution logic.
- City Detail movement preview and success status now show commanded, expected/actual arrived troops, and lost troops with minimal display changes.
- Not changed: Phase A/B/P0-1/P0-2 formulas, publicSupport formula, seasonal loyalty formula, recruitment/conscription, revolt, tech trees, trade deepening, diplomacy/espionage, battle scene logic, battle/invasion/defense logic, save/load core structure, or large UI.
- Verification passed: `rg` checks for troop movement fields/helpers, `_can_move_troops` commanded-amount review, `_apply_troop_rebalance_suggestion` delegation review, scoped diff review confirming `battle_web_import_test.gd` and publicSupport/seasonal/P0-2 formulas were not changed, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary QA runner. Godot `--check-only` timed out locally after 134 seconds.
- QA runner confirmed loyalty `100/90/50/20` with 100 commanded troops produces arrivals `100/90/50/20` and losses `0/10/50/80`, minimum-garrison validation still uses commanded amount, save/load preserves post-move troops, player attack BattleContext reads the destination troops after movement, C2 approval applies the same loss formula, and `last_troop_move_result` records commanded/arrived/lost/from_loyalty.
- Remaining risks: the current movement UI remains intentionally minimal and still lacks explicit target/amount controls; manual F6 visual QA is recommended for final Korean copy and button/status readability.

## v0.69-2 Seasonal Loyalty From Public Support MVP
- Implemented seasonal city loyalty adjustment from city `publicSupport` in `scripts/worldmap_test.gd`.
- v0.69 structure is now represented at MVP level: `publicSupport` changes every domestic turn, while the new seasonal loyalty bridge applies only on seasonal turns.
- Seasonal turn helper added: `_is_seasonal_loyalty_turn(turn_number)`, using the MVP rule `turn_number % 10 == 0` because the WorldMap calendar uses 10 turns per season and domestic apply runs before `_advance_world_turn_mvp()`.
- Added `_calculate_loyalty_delta_from_public_support(public_support)` with the locked MVP thresholds: `90+ => +2`, `80+ => +1`, `60..79 => -1`, `40..59 => -2`, `0..39 => -3`.
- Added `_apply_seasonal_loyalty_from_public_support(turn_number, supply_states)` and `_player_state["last_seasonal_loyalty_result"]`.
- Domestic turn order is now: publicSupport drift, existing P0-2 city loyalty drift, then seasonal loyalty from publicSupport if the turn is seasonal. P0-2 city loyalty drift remains active and was not replaced.
- City Detail internal/supply tab shows the latest seasonal loyalty status, and turn summary shows seasonal loyalty only when it applies.
- Not implemented: payroll/gold surplus loyalty, equipment surplus loyalty, recruitment/conscription, troop-move loyalty efficiency, revolt, tech trees, trade deepening, diplomacy/espionage, combat/invasion/defense changes, save/load core rewrites, or large UI refactors.
- Verification passed: `rg` function/field checks, diff review confirming publicSupport calculation formula and P0-2 loyalty drift were not removed/replaced, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary QA runner for non-seasonal skip, seasonal apply, `95/+2`, `85/+1`, `70/-1`, `50/-2`, `30/-3`, loyalty clamp, publicSupport unchanged by seasonal loyalty, save/load city loyalty preservation, and `last_seasonal_loyalty_result`. Godot `--check-only` timed out locally after 129 seconds.
- Remaining risks: seasonal bridge currently uses publicSupport only; payroll/equipment/supply seasonal loyalty modifiers are deliberately deferred to later v0.69 passes; visual display is minimal.

## v0.69-1 Public Support MVP
- Implemented city-level `publicSupport` MVP in `scripts/worldmap_test.gd` as the first EASTWAR strategic simulation foundation system.
- `publicSupport` is stored per city in `_city_runtime_states` with default `70`, clamped to `0..100`, and preserved through the existing city runtime save/load payload via the minimal `publicSupport` field.
- Added `publicSupport` helpers: `_get_city_public_support`, `_set_city_public_support`, `_calculate_city_public_support_delta`, and `_apply_city_public_support_drift_for_world_turn`.
- Public support delta is calculated separately from loyalty using tax, food, commerce, and Phase B supply isolation inputs, then clamped to `-7..+3`.
- Domestic turn now applies public support drift after income/upkeep/trade resource application and before existing national/city loyalty drift. `last_public_support_result` records per-city before/after/delta/reasons.
- City Detail internal/supply tab and the domestic turn summary now show minimal public support status and recent delta.
- Public support and loyalty remain separate axes. Existing `loyalty` / `cityLoyalty` fields and P0-2 city loyalty drift were not replaced or deleted.
- Superseded by `v0.69-2`: publicSupport is now seasonally reflected into loyalty on 10-turn seasonal boundaries.
- Not implemented: recruitment/conscription, troop-move loyalty efficiency, revolt, tech trees, trade deepening, diplomacy/espionage, battle/invasion/defense changes, save/load core rewrite, or large UI refactor.
- Verification passed: `rg` function/field checks, scoped loyalty diff review, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless QA runner for default 70, stable rise, high-tax drop, isolated `supply_delta -2`, `+3/-7` clamps, save/load preservation, loyalty non-interference, and `last_public_support_result`. Godot `--check-only` timed out locally after 130 seconds.
- Remaining risks: food/commerce surplus detection is MVP-level and uses current national `resource_stock` plus recent domestic/trade result fallbacks rather than a full city-level economy model; display is minimal and should receive later UX polish after v0.69 core systems.

## v0.69-0 EASTWAR Strategic Simulation Foundation Roadmap Lock
- Documentation-only roadmap lock. No code, scene, UI, battle, invasion, defense, save/load, troop movement, loyalty formula, public support, tech tree, trade deepening, diplomacy, espionage, or revolt implementation was done.
- The five official confirmed design documents in `agent/` were compared against the latest `_incoming_confirmed_designs/` inputs and replaced with the incoming confirmed versions. `_incoming_confirmed_designs/` remains an input staging folder and is not a commit target.
- v0.68b is closed as the web MVP port plus first-pass domestic logic baseline.
- v0.68b 계열은 웹 MVP 이식 및 내정 1차 로직 완료 기준선이다.
- Latest stable baseline:
  - `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions`
  - Commit: `aec588b`
- Completed first-pass domestic logic in the v0.68b baseline:
  - Governor income effects.
  - 태수 수입 효과.
  - City-level loyalty drift.
  - 도시별 충성도 드리프트.
  - Inter-faction trade income.
  - 세력간 무역 수입.
  - Trade tuning.
  - 무역 튜닝.
  - Supply connectivity bonus.
  - 보급 연결성 보너스.
  - City Detail display.
  - City Detail 표시.
  - Manual troop movement C1.
  - 수동 병력 이동 C1.
  - Chancellor troop rebalance suggestions C2.
  - 재상 병력 재배분 제안 C2.
- v0.69 begins the EASTWAR Strategic Simulation Foundation stage.
- v0.69부터는 EASTWAR Strategic Simulation Foundation 단계로 진입한다.
- v0.69 top-level principles:
  - `publicSupport` = livelihood and domestic stability.
  - 민심 `publicSupport` = 먹고 살기 / 내정 안정.
  - `loyalty` = voluntary military service will and military operation reliability.
  - 충성도 `loyalty` = 자발적 참군 의지 / 군사 운영.
  - `security` = public order pressure that affects both public support and loyalty.
  - 치안 `security` = 민심과 충성도 모두에 영향.
- Final UX/UI work is deferred until after the core v0.69 strategic systems are implemented.
- 최종 UX/UI는 v0.69 핵심 전략 시스템 구현 후 진행한다.
- Confirmed design documents added under `agent/`:
  - `CONFIRMED_LOYALTY_PUBLICSUPPORT_DESIGN.md`
  - `CONFIRMED_NATIONAL_TECHTREE_DESIGN.md`
  - `CONFIRMED_CITY_TECHTREE_DESIGN.md`
  - `CONFIRMED_TRADE_SYSTEM_DESIGN.md`
  - `CONFIRMED_DIPLOMACY_ESPIONAGE_REVOLT.md`

## v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions
- Implemented Phase C C2 in `scripts/worldmap_test.gd` as pure chancellor troop-rebalance suggestion calculation only. No UI, suggestion cards, automatic execution, resource movement, battle changes, save/load core changes, or calculation rewrites were added.
- `HANDOFF_P2C2_REBALANCE_SUGGESTIONS.md` was not present at repo root or under `agent/`, so the explicit task text was used as the implementation source. `ROLE_TARGET_GARRISON_RATIO` was also absent and was added as the minimal target-garrison ratio table needed by the requested formula.
- Added `_calculate_troop_rebalance_suggestions()`: it reads `_calculate_all_city_supply_states()`, uses `owned_city_ids`, treats `hub/rear` as suppliers and `frontline` as demand, sorts shortage/surplus per the task rule, validates every candidate through `_can_move_troops`, stores `_player_state["last_troop_rebalance_suggestions"]`, and returns the suggestions array.
- Added `_apply_troop_rebalance_suggestion(suggestion)`: it extracts `from`, `to`, and `amount`, then delegates movement to C1 `_move_troops`. C2 does not call `_set_city_runtime_troops` and does not directly set troop values.
- Not changed: C1 `_can_move_troops` / `_move_troops` validation formulas, P0-1, P0-2, Phase A trade, Phase B supply connectivity, battle/invasion/defense logic, `battle_web_import_test.gd`, and save/load core structure.
- QA confirmed start state with only Hanseong owned returns 0 suggestions; a crafted multi-city scenario produced a Hanseong -> Gyeongju suggestion; all suggestions passed `_can_move_troops`; suggestion calculation preserved world troop total and per-city troops; applying a suggestion moved through `_move_troops` and preserved total troops; save/load preserved moved troops through the existing C1 path.
- Remaining risks: C2 has no UI surface yet; target-garrison ratios are first-pass constants because no existing `ROLE_TARGET_GARRISON_RATIO` was found; QA is headless/API-driven, so future UI approval flow still needs manual F6 validation.
- Next task candidates: `City Panel Rebuild / Chancellor Suggestion UI` or `Troop Move UI from/to/amount Control Polish`.

## v0.68b-13-6C1 Troop Move Manual MVP
- Implemented Phase C C1 only in `scripts/worldmap_test.gd`: manual city-to-city troop movement between player-owned cities. C2 chancellor suggestions and automatic redistribution were not implemented.
- Precheck result: no new lock flag was needed. Existing runtime gates are reused: `_enemy_turn_mvp_pending`, `_player_state.pending_invasion_event`, `_player_state.pending_battle_context`, `Engine` battle context meta, and `turn_phase == player` for management-phase movement.
- Added `TROOP_MOVE_MIN_GARRISON_RATIO := 0.6`, `_is_supply_path_between`, `_get_city_min_garrison`, `_is_peacetime_for_troop_move`, `_can_move_troops`, `_move_troops`, and small display/preview helpers.
- Reused existing player ownership and troop helpers: `_is_city_owned_by_player_mvp`, `_get_city_troops_for_battle_context`, `_set_city_runtime_troops`, `_get_city_security_required_troops`, marker neighbors, and existing runtime city state.
- `_can_move_troops` rejects invalid amount, non-player ownership, same city, non-peacetime, missing all-player supply path, and moves that would drop the source city below `security_required_troops * 0.6`.
- `_move_troops` only runs after validation, writes through `_set_city_runtime_troops(from, from - amount)` and `_set_city_runtime_troops(to, to + amount)`, and records `_player_state["last_troop_move_result"]`.
- Minimal UI uses the existing City Detail internal/supply tab and existing action button: selected city is the source, the first connected player-owned city in `owned_city_ids` is the target, and the move amount is capped at 100 and the source city's movable surplus above minimum garrison.
- QA confirmed troop total preservation, min-garrison rejection, no-supply-path rejection, pending-invasion peacetime rejection, save/load troop preservation, and moved troops feeding player attack BattleContext input.
- Not changed: C2 suggestions, resource_stock, P0-1, P0-2, Phase A trade, Phase B supply calculations, battle scene logic, battle formulas, save/load core structure, and battle/invasion/defense logic.
- Remaining risks: UI is intentionally minimal and lacks explicit from/to/amount controls; manual F6 mouse QA is still recommended; save payload still persists full `_player_state`, including the new last move summary.
- Next task candidate: `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions`.

## v0.68b-13-5A City Info Display Spacing Micro Polish
- Applied a micro polish pass to `scripts/worldmap_test.gd` display formatting only.
- Only 13-5 display helper output was changed: section titles were added, long supply/trade/loyalty strings were split across lines, and empty-state wording was normalized to recent-result messages.
- Route display now uses the existing `routes` array order with `slice(0, 3)` only, then shows the remaining count as `외 N개`; the original routes array is not mutated and no sorting, prioritization, or value-based filtering was added.
- Calculation logic, result structures, and actual resource/loyalty/upkeep/troop values were not changed. P0-1, P0-2, Phase A, Phase B, battle/invasion/defense, save/load, and Phase C remain untouched.
- Verification passed: scoped diff review, route slice/original-array mutation check, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless display-spacing QA runner. Godot `--check-only` timed out locally after 124 seconds.
- Remaining risks: no manual visual F6 mouse QA yet; section-title glyph rendering should be checked in the target font; Phase C is still not implemented.
- Next task candidate: `v0.68b-13-6 Phase C Internal Troop Rebalance MVP`.

## v0.68b-13-5 City Info Trade Supply Loyalty Display Polish
- Implemented display-only polish in `scripts/worldmap_test.gd`; no P0-1 governor income, P0-2 city loyalty drift, Phase A trade, Phase B supply, resource, loyalty, upkeep, battle, invasion, defense, or save/load core calculation logic was changed.
- City Detail internal/trade tab now displays existing supply result fields for the selected city: `role`, supplied/isolated state, `income_multiplier`, `loyalty_delta`, and `security_delta`.
- City Detail internal/trade tab also displays the latest city loyalty drift result for the selected city using existing `reasons[]` and delta fields: tax, security, economy, military, supply, supply_security, and control. If no result exists, it shows that there is no recent turn result.
- City Detail external/trade tab now displays the latest `_player_state["last_inter_faction_trade_result"]`: route count, applied trade totals when available with player totals as fallback, and up to three routes that include the selected city.
- Turn result/status summary now includes display-only summaries for trade income, supply hub/supplied-frontline/isolated counts, and city loyalty drift changed-city/large-drop counts.
- Added formatting helpers only; they build strings from existing result/state dictionaries and do not mutate resources, loyalty, upkeep, trade totals, supply classification, or result payload structure.
- Verification passed: `rg` helper/tab checks, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless display QA runner. Godot `--check-only` timed out locally after 125 seconds.
- Remaining risks: QA was headless rather than visual mouse-driven F6; selected-city supply display calls the existing supply state calculation and may refresh `last_supply_state_result` as an inspection summary; long route/drift strings may need later UI spacing polish.
- Next task candidates: `v0.68b-13-6 Phase C Internal Troop Rebalance MVP` or `Supply/Trade UI Polish 추가`.

## v0.68b-13-4A Supply Connectivity F6 QA Closeout
- Phase B supply connectivity was QA-closed against `WorldMap_Test.tscn` on 2026-05-30 with no gameplay code changes.
- Start-state QA passed: F6 WorldMap headless scene load succeeds; Hanseong resolves as the supply hub; with only Hanseong owned, `supplied_frontline_count = 0`, `isolated_count = 0`, and Hanseong role is `hub`.
- Actual turn progression passed through `_on_ally_turn_end_pressed()` / `_finish_enemy_turn_mvp()`: world turn advanced, domestic result was recorded, Phase A trade result remained present, and Hanseong city loyalty drift applied normally.
- Multi-city QA passed by setting Pyeongyang, Gyeongju, and Sabi to player-owned: Hanseong remained the highest-population hub, all three adjacent border cities classified as `frontline`, each had a friendly route back to hub, and `supplied_frontline_count = 3`.
- Supplied-frontline bonuses passed: income multiplier `x1.10`, loyalty drift supply `+1`, security `+1`, calculated gold income increased versus no-supply baseline, hero upkeep discount reduced upkeep, and `SUPPLY_UPKEEP_DISCOUNT_FLOOR = 0.85` held under an exaggerated count.
- Isolated QA passed by setting Kyoto to player-owned while Hanseong remained hub: Kyoto classified as disconnected `frontline`, `supplied = false`, `isolated = true`, income multiplier `x0.80`, loyalty drift supply `-2`, security `-1`, and no isolated upkeep surcharge was applied, which is expected for this MVP.
- Save/load QA passed with a caveat: loaded `_player_state` can still carry a stale `last_supply_state_result` because full `_player_state` is persisted, but the next `_calculate_all_city_supply_states()` recalculates from loaded ownership and marker neighbors and overwrites the stale summary. Treat `last_supply_state_result` as runtime inspection output, not authoritative save data.
- Regression checks passed lightly: Phase A inter-faction trade income still applied after load, city loyalty/runtime city state serialized and loaded, `faction_relations` remained in the save payload, player attack BattleContext still built, and enemy invasion/defense event creation still worked.
- Remaining risks: QA was headless/API-driven rather than mouse-driven visual F6 QA; save files may contain stale `last_supply_state_result` until a supply recalculation/domestic turn runs; no supply UI exists; isolated upkeep surcharge, resource movement, Phase C troop redistribution, and battle/invasion/defense supply effects remain out of scope.
- Next task candidates: `v0.68b-13-5 Phase C Internal Troop Rebalance MVP` or `City Info Supply State Display Polish`.

## v0.68b-13-4 Phase B Supply Connectivity Bonus MVP
- Implemented Phase B as a connectivity-gated supply bonus system in `scripts/worldmap_test.gd`; this is not a city-by-city warehouse or resource movement pipeline.
- Added supply constants for income bonus/penalty, loyalty bonus/penalty, security bonus/penalty, and supplied-frontline upkeep discount with a floor.
- Added supply hub and connectivity helpers: `_get_player_supply_hub_id`, `_is_city_supply_connected`, `_calculate_city_supply_state`, and `_calculate_all_city_supply_states`.
- Player supply hub is the owned city with the largest `population`; current starting state should pick Hanseong because it is the only owned city and has population 50000.
- `_apply_domestic_turn_mvp` calculates `supply_states` once at the start of the domestic turn and shares that result with domestic income, hero upkeep, and city loyalty drift.
- Income effects are multiplied only for frontline cities: supplied frontline `x1.10`, isolated frontline `x0.80`, rear/hub no change. Existing P0-1 governor effects are preserved and multiplied rather than replaced.
- City loyalty drift now accepts a supply state: supplied frontline adds loyalty `+1` and security `+1`; isolated frontline adds loyalty `-2` and security `-1`; final P0-2 clamp remains `-3..+3`.
- Hero upkeep now receives a supplied-frontline discount: `max(0.85, 1.0 - 0.03 * supplied_frontline_count)`. Isolated-frontline upkeep surcharge is intentionally not implemented in this MVP.
- `_player_state["last_supply_state_result"]` stores `{hub_id, supplied_frontline_count, isolated_count, city_states}`. Supply state is recalculated each turn from owners/owned cities/neighbors and is not a separate save/load field.
- Phase C troop redistribution, city-specific warehouses, city-to-city resource movement, Phase A trade formula changes, battle/invasion/defense changes, and save/load core rewrites were not implemented.
- `worldmap_test_FULL.gd` is treated as an untracked source integration file and is not part of this commit.
- Verification: `rg`, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and Godot `--check-only` passed. F6 manual QA remains for connected/isolation scenarios and save/load recalculation behavior.

## v0.68b-13-3 Final Merged WorldMap Domestic Trade Loyalty QA
- Applied `worldmap_test_FULL.gd` into `scripts/worldmap_test.gd`.
- The integrated file keeps P0-1 governor income effects, P0-2 city loyalty drift, Phase A inter-faction trade income, and trade tuning C values.
- Trade tuning C is present: `TRADE_GLOBAL_DAMPENER := 0.5` and `TRADE_FOOD_FACTOR := 1.5`.
- `_apply_domestic_turn_mvp` order was checked: income calculation, upkeep calculation/application, Phase A trade income application, national loyalty update, then P0-2 city loyalty drift.
- Diff review showed only trade tuning C changes against the previous HEAD: dampener constant, food factor constant, route multiplier dampening, and food-resource factor replacement. No battle/invasion/defense diff was present.
- Static route verification: Hanseong neighbors are Pyeongyang, Gyeongju, and Sabi; tuned gold routes calculate as 12 + 14 + 14 = 40.
- Headless verification passed for project load and `WorldMap_Test.tscn` load. `--check-only` timed out locally.
- F6 manual QA was not executed in this environment; city loyalty save/load, `faction_relations` save/load, visual trade income display, and light battle/invasion/defense entry checks remain manual.
- Phase B supply connectivity was not implemented. Next task: `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP`.

## v0.68b-13-2 City Loyalty Drift Patch Acceptance QA
- P0-2 city loyalty drift was missing and is now minimally wired into `scripts/worldmap_test.gd`.
- Added `CITY_LOYALTY_DRIFT_MIN := -3`, `CITY_LOYALTY_DRIFT_MAX := 3`, and `STATIONED_HERO_SECURITY_WEIGHT := 1.0`.
- Added city loyalty drift application at the end of `_apply_domestic_turn_mvp`, after national loyalty update. Existing Phase A trade code was already present in this branch and was not newly implemented by this patch.
- Added `_apply_city_loyalty_drift_for_world_turn`, `_calculate_city_loyalty_drift`, `_get_city_security_required_troops`, and `_governor_has_aptitude`.
- P0-1 `city_loyalty_loss_multiplier` is now consumed by city tax loyalty drift through `_adjust_loyalty_delta`; political governor/chancellor fallback effects can soften city tax loyalty loss.
- `recruitable_troops_bonus` remains unconnected and is still not consumed by loyalty, recruitment, or military systems.
- City loyalty is written through `_get_mutable_city_runtime_state` into `_city_runtime_states`, with `loyalty` and `cityLoyalty` minimally included in city runtime save/load payloads.
- Phase A trade implementation, Phase B internal supply network, Phase C troop redistribution, battle/invasion/defense, governor income formulas, and save/load core structure were not rewritten.
- Merge/order caution for future Phase A work: `_apply_domestic_turn_mvp` should preserve the intended order of P0-1 governor income, Phase A trade income if present, hero upkeep, national loyalty, then P0-2 city loyalty drift.
- Verification: `rg`, `git diff --check`, Godot headless project load, and `WorldMap_Test.tscn` headless load passed. Godot `--check-only` timed out locally.

## v0.68b-13-2A Inter-Faction Trade Income MVP
- Phase A only: added inter-faction trade income to the WorldMap domestic turn pipeline in `scripts/worldmap_test.gd`.
- The MVP reuses city marker neighbors, `_get_city_hud_entry(...)`, `resource_seed`, and `_apply_resource_delta(...)`; it does not add trade setup UI or diplomacy manipulation UI.
- Added flat `_player_state["faction_relations"]` support with sorted `a|b` relation keys. Missing relation keys fall back to `neutral`, and same-faction pairs are not eligible for inter-faction trade.
- Added `last_inter_faction_trade_result` with structure: `turn`, `route_count`, `player_totals`, `routes`, and `applied_player_totals`.
- Active routes are generated only from player-owned cities to adjacent other-faction cities. `neutral` and `allied` can trade; `hostile` and `suspended` cannot.
- Phase B internal supply network is not implemented. Phase C troop redistribution is not implemented. P0-2 city loyalty/recruitment consumers are not connected.
- Save/load uses existing full `_player_state` persistence, so `faction_relations` and `last_inter_faction_trade_result` require no separate save/load path.
- Verification: `rg`, `git diff --check`, Godot headless project load, and `WorldMap_Test.tscn` headless load passed. Godot `--check-only` timed out locally.

## v0.68b-13-1 Governor Income Effect Patch Acceptance QA
- Reviewed `scripts/worldmap_test.gd` for the existing P0-1 governor income patch gates; the required governor income constants/functions/signature/pass-through were missing and were added only in the domestic income calculation area.
- Added city-level governor domestic effects with `GOVERNOR_PRIMARY_RATE := 0.025` and `GOVERNOR_SECONDARY_RATE := 0.0125`, then passed `city_effects` into `_calculate_city_domestic_income(...)` before existing chancellor policy/national multipliers.
- The patch mirrors the web city-effect scope for income multipliers and keeps `city_loyalty_loss_multiplier` / `recruitable_troops_bonus` in the effect dictionary for future consumers; Godot currently has no consumer for those two fields, which is expected.
- No battle, invasion, defense, save/load, deployment, scene, or broad refactor work was done.
- Verification: `rg` found all requested patch strings; Godot `--headless --path . --quit` and `WorldMap_Test.tscn --quit` passed. `--check-only` did not terminate before the local timeout, so it is recorded as inconclusive.
- F6 manual QA remains recommended for the UI path. Static Hanseong calculation note: current Hanseong player governor candidates mostly affect loyalty/recruitment or very small resource multipliers, so visible turn-end income deltas may round to no displayed resource change unless policy/economic inputs create a larger multiplier.

## v0.68b-12b-31 Player/Defense Troop Accounting Parity Fix
- Player attack now pre-decrements the enemy defender city by `defender_total_allocated_troops` before battle handoff, in addition to the existing player source city decrement.
- Enemy invasion defense BattleContext now carries attacker/defender troop allocations, total allocated troops, source city ids, and pre-decrement before/after metadata for both sides.
- Battle result payloads now include `player_troop_outcome` / `enemy_troop_outcome` for both player attack and enemy invasion defense, using the same allocated-troop HP-ratio survivor formula.
- Defense victory now returns player survivors/wounded to the defended city and enemy wounded to the attacker city woundedQueue; defense defeat now occupies the city with enemy survivors/wounded and routes player wounded to the nearest player-owned neighbor if available.
- WoundedQueue save/load and turn recovery remain wired from 29A. F6 QA is still required for player attack defender pre-decrement, defense win/loss accounting, queue persistence, and recovery.
- Still deferred: commandRank/commandLimit clamp, defense deployment UI, captured city hero recruit/conversion, prisoner soldier systems, troop-count combat scaling, and siege formulas.

## v0.68b-12b-30 Invasion Attack Web Parity Gap Audit
- Docs-only audit created `agent/INVASION_ATTACK_WEB_PARITY_GAP_AUDIT.md` comparing SamWar_web attack/defense/result/woundedQueue/save-load/UI flows against current Godot.
- P0 gaps confirmed: player attack defender garrison pre-decrement, enemy invasion defense troop allocation/result parity, defense woundedQueue/retreat-city handling, and F6/save-load QA for troop woundedQueue recovery.
- P1 gaps confirmed: commandRank/commandLimit allocation clamp, player attack allocation F6 QA, and defense deployment UI/default allocation follow-up.
- Deferred by design: hero recruit/faction conversion on captured cities, prisoner soldier handling, troop-count combat scaling, and siege-specific formulas.

## v0.68b-12b-29A Web-Parity Troop Allocation Wounded Queue Import
- Player attack deployment confirmation now immediately subtracts the selected sortie troops from the source city garrison and records before/after troop counts in the `player_attack` BattleContext.
- BattleContext preserves per-hero `attacker_troop_allocation`, total allocated troops, source city id, and defender allocation metadata; battle units now carry `allocated_troops` / `initial_allocated_troops` without scaling HP or combat power by troop count.
- Battle return payload now calculates player/enemy troop outcomes from allocated troops and remaining HP ratio: victory keeps HP-ratio survivors, wounds 30% of losses, and marks the rest dead; defeat forces survivors to 0, wounds 50% of allocated troops, and marks the rest dead.
- Player attack victory puts survivor troops in the occupied target city and queues wounded troops there for 3 WorldMap turns; player attack defeat keeps the target owner and queues player wounded troops back at the source city.
- City runtime save/load now preserves troop `woundedQueue` entries, and WorldMap turn advance recovers completed queue entries into city garrison troops.
- Hero wounded/captured/dead runtime state remains separate from troop woundedQueue; captured/dead exclusion and wounded hero battle penalties remain unchanged.
- Still deferred: troop-count combat scaling, in-battle supply effects, defender pre-battle garrison decrement parity, troop types, siege formulas, prisoner soldiers, loot, and hero recruit/faction conversion.

## v0.68b-12b-28 Player Attack Deployment UX Polish
- Player attack deployment panel now uses a wider 560px layout with viewport clamp, stronger title/source-target header, separated source/target/troop/resource summary, scrollable hero rows, and persistent confirm/cancel controls.
- Deployment UI now shows total assigned troops, remaining garrison troops, and per-resource supply lines with `충분` / `부족` text.
- Disabled/blocked deployment reasons now appear near the confirm button: no hero selected, zero troop assignment, source-city garrison reserve violation, troop overflow, or food/gold/salt shortage.
- Confirm feedback now logs and displays the source city, target city, assigned troops, and food/gold/salt consumption before battle handoff.
- Player attack result copy is strengthened: victory says the target was occupied by the source city's expeditionary force; defeat says the expeditionary force retreated/was beaten back.
- Codex verification: headless project, WorldMap scene, Battle scene, and `git diff --check` passed. F6 manual click QA remains required for panel sizing, SpinBox feel, battle transition, victory/defeat, and save/load.

## v0.68b-12b-26 Player City Attack MVP Import
- Player attack MVP is now connected from the WorldMap selected city panel: enemy cities with a directly adjacent player city can expose the `공격` button.
- Attack source city selection follows the web MVP rule: use the current valid player origin city if it neighbors the target, otherwise use the first player-owned target neighbor.
- Player attack creates a WorldMap BattleContext with `source: player_attack` and `type: attack`, then reuses the existing Battle_Fullscreen_Test handoff.
- Battle scene context mapping now treats player attack attacker roster as ally-side and target defender roster as enemy-side; enemy-invasion defense mapping remains unchanged.
- Player attack results no longer fall through the enemy-invasion unknown path: player victory occupies the target city for `player`, while player defeat preserves the target owner.
- Existing casualty, result-card, hero status placeholder, captured/dead exclusion, wounded battle penalty/recovery, and save/load runtime persistence flows are reused.
- Still deferred: deployment selection UI, troop allocation UI, sea/route-type attacks, 2-hop attacks, marching/supply cost, siege presentation, AI counterattack, and enemy hero recruitment.

## v0.68b-12b-26 Wounded Hero Recovery Turn MVP
- Hero runtime state now includes `wounded_turns_remaining`.
- New wounded placeholder applications assign `DEFAULT_WOUNDED_RECOVERY_TURNS = 3`; captured/dead/normal states keep recovery turns at `0`.
- Wound recovery advances once per WorldMap strategy turn in `_advance_world_turn_mvp()`, not during battle turns.
- Each WorldMap turn reduces wounded turns by 1; at `0`, the hero returns to `status: normal`, `wounded: false`, and the v25 battle penalty no longer applies.
- WorldMap city info, battle formation panels, and post-battle result summaries can show `[부상 N턴]`.
- Save/load persists `wounded_turns_remaining`; older wounded saves without the field are normalized to the 3-turn MVP default.
- Still deferred: treatment buildings, recovery items, ability-based recovery duration, prisoner release/recruit/execute, and death handling.

## v0.68b-12b-25 Wounded Hero Battle Penalty MVP
- Wounded heroes remain battle-eligible and keep `[부상]` display markers in WorldMap/Battle roster surfaces.
- Battle damage now applies MVP wounded penalties in the battle scene: basic attack damage `75%`, wounded defender incoming damage `120%` as a defense-performance penalty, and unique-skill numeric effects `70%`.
- Unique skill toast/name presentation remains unchanged; only numeric damage/buff/defense/splash values are reduced.
- Captured/dead battle exclusion from v24 remains intact.
- Save/load uses the existing `worldmap_hero_state` status persistence; no new save fields were added.
- Still deferred: wound recovery, treatment UI, prisoner movement/recruit/execute/release, death handling, and stat-based refined wound balance.

## v0.68b-12b-24 Captured Hero Battle Exclusion MVP
- Captured heroes are now excluded when WorldMap invasion BattleContext rosters are built; `captured == true`, `status == "captured"`, or `dead == true` keeps the hero out of attacker/defender/support battle rosters.
- Captured heroes remain in city `stationed_hero_ids` / `hero_ids` and continue to display `[포로]` in WorldMap city information; this is battle-entry exclusion only.
- Wounded heroes remain battle-eligible in this MVP.
- Battle scene context slot assignment has a defensive captured/dead guard, so an invalid context hero is deactivated instead of entering the battlefield or formation panel.
- Save/load continues to persist hero status through `worldmap_hero_state`; loaded captured state is honored by the next BattleContext build.
- Still deferred: prisoner holding/movement, recruit/execute/release, wound recovery, wounded combat penalties, and real death handling.

## v0.68b-12b-23 Hero State Visual Marker / Roster Status Badge MVP
- Added hero state badge helpers for runtime/display paths: `dead` shows `[사망]`, `captured` shows `[포로]`, `wounded` shows `[부상]`, and normal heroes show no badge.
- WorldMap city hero display now receives merged runtime hero state, so the right selected-city stationed hero list and governor labels can show wound/capture badges after save/load.
- Battle formation/roster panels now preserve context hero status fields from BattleContext and append badges to displayed names.
- Post-battle result card hero-state summary now uses the same name-with-state marker style.
- Captured heroes are still not removed from city rosters or excluded from battle in this MVP; `dead` remains display-safe but unused by gameplay.
- Still deferred: captured hero battle exclusion, prisoner movement/holding UI, wound recovery turns, death handling, and status-based stat penalties.

## v0.68b-12b-22 Hero Wound/Capture Placeholder MVP
- Invasion battle results now apply a deterministic hero status placeholder to the losing side only.
- MVP rule: the first eligible losing-side hero becomes `wounded`; the second eligible losing-side hero becomes `captured`; already captured/dead or missing heroes are skipped.
- `dead` remains unused and is kept false for this MVP.
- Captured heroes are not removed from `stationed_hero_ids` / `hero_ids`; no prison, movement, recruitment, execution, or recovery systems were added.
- Hero status changes use `_hero_runtime_states` only and continue through `worldmap_hero_state` save/load.
- Post-battle result card now includes a compact hero status summary line.

## v0.68b-12b-21 Post-Battle Result Panel Polish MVP
- WorldMap return after an invasion battle now builds a display-only post-battle result summary and shows it in a compact left-HUD result card.
- The summary separates defender win, attacker win/city fall, retreat, and unknown result copy.
- The result card highlights ownership change/retention, defender city troop change, attacker source-city troop change, and occupation troops when present.
- The result summary is immediate guidance only and is not saved/restored; owner/troop persistence remains handled by the v19/v20 runtime state save/load path.
- Still deferred: prisoner/wound/death display, resource loot display, detailed combat statistics, and a full result report UI.

## v0.68b-12b-20 Invasion Casualty Formula + Hero State MVP
- Invasion result application now uses an MVP casualty calculation instead of the previous minimal troop-rate apply.
- Defense victory keeps city ownership, reduces defender city troops by a bounded MVP loss rate, and heavily reduces attacker source-city troops.
- Defense defeat transfers ownership, reduces defender troops, and applies a bounded occupation troop value from surviving attacker troops while reducing the attacker source city.
- Troop values are normalized as integers and clamped to nonnegative bounded values; the current casualty rates are temporary and not final balance.
- Hero runtime save/load now includes future status fields: `status`, `wounded`, `captured`, and `dead`, defaulting to `normal` / `false` for existing save data.
- Still deferred: actual wound/capture/death rolls, hero removal/holding movement, resource looting, strategic AI recalculation, and multi-invasion queues.

## v0.68b-12b-19 WorldMap Battle Result Save/Load Persistence MVP
- WorldMap save payload now includes battle-result runtime overrides for city owner/nation/owner_faction_id, city troops, city stationed hero ids, and hero current city ids.
- Load now restores seed data first, then applies `worldmap_city_state` / `worldmap_hero_state` into mutable runtime state and refreshes city markers/UI from the merged state.
- Pending invasion event/context is still cleared on save/load so resolved invasion choices do not reappear after reload.
- The implementation preserves read-only seed boundaries: `CITY_HUD_DATA` and `HERO_DATA` remain seed sources, while `_city_runtime_states` and `_hero_runtime_states` carry persistence overrides.
- Deferred: hero wounds/capture/death, resource looting, precise casualty calculation, AI strategy recalculation, and multi-invasion queues.

## v0.68b-12b-18c Reinforcement Toast + Auto Battle Final Stop Hotfix
- Reinforcement arrival toast now requires at least one actually deployed arriving unit; empty/inactive WorldMap context support slots no longer trigger the turn-3 reinforcement toast.
- Root cause: the reinforcement-01 arrival path used only the round condition and called the toast after deploy attempts, even when no active support unit was deployed.
- Battle result final-stop guards were strengthened across enemy turn/action callbacks, move/attack finish callbacks, round start, toast queue/playback, and reinforcement deployment checks.
- After victory/defeat finalization, non-result toasts are cleared or blocked, full auto is stopped, and deferred turn/auto/reinforcement callbacks return early.
- Remaining QA: live F6 should confirm no support toast when support is absent, sample battle still shows support toast when real support arrives, and auto battle stops immediately at result.

## v0.68b-12b-18b Roster Panel Source + Auto Battle End Hotfix
- Formation/roster side panels now follow the same WorldMap context roster source as battlefield slots; empty or inactive context slots are hidden instead of displaying sample `TEST_BATTLE_ROSTER` heroes.
- Confirmed panel leak source: panel refresh read the existing capacity-slot `unit_state` first, and `_get_hero_id_for_unit_state()` could still resolve sample fallback heroes such as 김유신/을지문덕/유비/제갈량.
- Auto battle now stops when victory/defeat is finalized, and phase/auto tick entry points block additional post-result turn advancement.
- Remaining QA: live F6 enemy-invasion should confirm empty support panel cells stay hidden, panels match actual deployed/context heroes, no extra auto turns occur after result, and worldmap return remains stable.

## v0.68b-12b-18a Reinforcement Fallback Leak + Toast Facing Layer Hotfix
- Battle-side root cause fixed: the 유비/제갈량 leak came from `TEST_BATTLE_ROSTER` fallback in WorldMap context slot fill, not from the WorldMap 1-hop/2-hop reinforcement filter.
- `enemy_invasion` / WorldMap context battles now deactivate empty context slots instead of filling them from the sample roster; direct sample battle fallback remains available outside invasion context.
- `RoundToastRoot` now has an explicit high `z_index`, and battle/unique-skill toasts temporarily hide facing indicators until playback ends.
- Remaining QA: live F6 사비/백제 invasion should confirm no `liu_bei` / `zhuge_liang` support leak, toast arrows stay hidden, and arrows restore afterward.

## Project
SamWar_BattleLab

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

Latest worldmap functional marker patch: `v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch`

Latest worldmap HUD structure patch: `v0.68b-8 WorldMap Web HUD Panel Structure Import MVP`

Latest worldmap HUD visual patch: `v0.68b-8 WorldMap Web HUD Visual Parity MVP`

Latest worldmap HUD data patch: `v0.68b-9 WorldMap HUD Data Binding MVP`

Latest worldmap domestic web parity patch: `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`

Latest worldmap draggable HUD patch: `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`

Latest worldmap unified panel patch: `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`

Latest worldmap unified panel UX patch: `v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch`

Latest worldmap left HUD content patch: `v0.68b-12b Left World HUD Web Content Parity`

Latest worldmap seed data audit patch: `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit`

Latest session handoff docs patch: `v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat`

Latest worldmap seed import patch: `v0.68b-12b-1 WorldMap Hero City Seed Data Import`

Latest worldmap left panel binding QA patch: `v0.68b-12b-2 WorldMap Left Panel Seed Binding QA`

Latest worldmap left panel controls patch: `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP`

Latest worldmap left panel policy/warehouse patch: `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP`

Latest worldmap warehouse UI cleanup patch: `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup`

Latest worldmap turn/save patch: `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP`

Latest worldmap turn cycle patch: `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`

Latest worldmap domestic apply patch: `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`

Latest worldmap domestic apply QA patch: `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`

Latest worldmap enemy invasion audit patch: `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit`

Latest worldmap right city panel cleanup patch: `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup`

Latest worldmap hero portrait binding patch: `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP`

Latest worldmap BattleContext bridge patch: `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`

Latest worldmap battle scene handoff patch: `v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`

Latest battle roster context patch: `v0.68b-12b-13 Battle Roster Context Apply MVP`

Latest worldmap battle result return patch: `v0.68b-12b-14 WorldMap Battle Result Return MVP`

Latest worldmap invasion result apply patch: `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`

Latest worldmap invasion result hotfix: `v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix`

Latest worldmap hero battle contract patch: `v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP`

Latest worldmap hero placement data patch: `v0.68b-12b-16b Hero Placement Data Patch`

Latest hero portrait import metadata audit: `v0.68b-12b-16c Hero Portrait Import Metadata Audit`

Latest actual hero portrait binding patch: `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`

Latest battlefield portrait/skill hotfix: `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`

Latest invasion reinforcement source patch: `v0.68b-12b-18 Invasion Reinforcement Source Rule MVP`

Latest worldmap unified panel hotfix: `v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard`

Latest warning cleanup hotfix: `v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup`

Latest worldmap marker hotfix: `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix`

Latest worldmap tile hotfix: `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix`

Latest worldmap manual layout patch: `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control`

Latest worldmap marker attachment hotfix: `v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix`

## Current Implementation Step
- `v0.68b-1 WorldMap Four-Tile Canvas Foundation`
- `v0.68b-2 WorldMap City Marker Layer MVP`
- `v0.68b-3 WorldMap City Castle Icon Apply`
- `v0.68b-4 WorldMap Route Layer Path2D MVP`
- `v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning`
- `v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP`
- `v0.68b-6 WorldMap Selected City Panel Web Parity MVP`
- `v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch`
- `v0.68b-8 WorldMap Web HUD Panel Structure Import MVP`
- `v0.68b-8 WorldMap Web HUD Visual Parity MVP`
- `v0.68b-9 WorldMap HUD Data Binding MVP`
- `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`
- `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`
- `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`
- `v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch`
- `v0.68b-12b Left World HUD Web Content Parity`
- `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit`
- `v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat`
- `v0.68b-12b-1 WorldMap Hero City Seed Data Import`
- `v0.68b-12b-2 WorldMap Left Panel Seed Binding QA`
- `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP`
- `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP`
- `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup`
- `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP`
- `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`
- `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`
- `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`
- `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit`
- `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`
- `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP`
- `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup`
- `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP`
- `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`
- `v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`
- `v0.68b-12b-13 Battle Roster Context Apply MVP`
- `v0.68b-12b-14 WorldMap Battle Result Return MVP`
- `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`
- `v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix`
- `v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP`
- `v0.68b-12b-16b Hero Placement Data Patch`
- `v0.68b-12b-16c Hero Portrait Import Metadata Audit`
- `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`
- `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`
- `v0.68b-12b-18 Invasion Reinforcement Source Rule MVP`
- `v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard`
- `v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup`
- `v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup`
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
- `v0.68b-12b-18` adds invasion reinforcement source rules for WorldMap-launched defense battles. Main attacker/defender rosters come from each source city's stationed heroes first.
- Reinforcements are restricted to same-faction or explicit-ally cities within MVP adjacency: 1-hop first, then 2-hop only. Distant city heroes are no longer force-filled from the global/sample roster.
- Empty WorldMap context slots are deactivated in the battle scene instead of using sample `TEST_BATTLE_ROSTER` heroes; sample fallback remains only for direct sample battles or crash-guard empty/broken context sides.
- Static 평양 -> 한성 validation excludes 성도 from the 2-hop candidate set, so 유비/제갈량 are not eligible as ordinary support heroes.
- Save/Load, hero wounds/capture, hero movement, resource looting, precise strategic AI, and city ownership result behavior remain unchanged/deferred.
- `WorldMap_Test.tscn` now exists as the first worldmap visual canvas foundation.
- `WorldMap_Test.tscn` now has editor-visible seam-free four-tile placement: A1 `(0, 0)`, A2 `(512, 0)`, B1 `(0, 512)`, and B2 `(512, 512)`.
- Tile node positions are now scene-authored source of truth. Runtime no longer forces A1/A2/B1/B2 positions during `_ready()`.
- Camera clamp `_world_rect` is calculated from the union of the current tile Sprite2D world rects.
- The prepared four worldmap tiles are arranged as a 2x2 Sprite2D canvas with `centered = false`: A1/NW at `(0, 0)`, A2/NE at `(tile_width, 0)`, B1/SW at `(0, tile_height)`, and B2/SE at `(tile_width, tile_height)`.
- `WorldMapCamera` is scene-authored and runtime-configured as the current Camera2D for large-map pan, drag, optional wheel zoom, and viewport/zoom-aware clamp against the combined tile rect.
- `WorldMapUI` is CanvasLayer-based and intended to remain screen-fixed during camera movement.
- `WorldMapUI` now includes a screen-fixed `CityInfoPanel` MVP based on the web selected city HUD structure.
- `v0.68b-8` expands `WorldMapUI` toward the web HUD layout: left `LeftWorldStatusPanel`, upper-right `DiplomacySpyPanel`, right `CityDetailPanel`, and expanded `CityInfoPanel` / selected-city summary.
- The new HUD panels are placeholder-only and screen-fixed. City clicks refresh both `CityDetailPanel` and `CityInfoPanel`.
- `v0.68b-8 WorldMap Web HUD Visual Parity MVP` tunes the Godot HUD closer to the web CSS look: dark navy translucent panels, thin gold borders, gold eyebrow headings, dense text, inner cards, tab buttons, red action buttons, progress-bar placeholders, and a centered `SamWar Web` title banner.
- The right HUD is arranged in a web-like fixed multi-panel layout with Diplomacy/Spy, City Detail, and Selected City columns. It remains placeholder-only and does not add real systems.
- `v0.68b-9 WorldMap HUD Data Binding MVP` adds local display dictionaries for player state, hero data, chancellor policies, governor policies, and selected-city HUD data.
- The left World Turn panel now displays mock-bound turn/calendar/phase, national bars, chancellor portrait slot, chancellor name/stats, chancellor policy selection, resources, supply, logistics, and trade copy.
- Chancellor policy selection updates local HUD state and description copy only; it does not apply resources, loyalty, upkeep, turn, or domestic effects.
- Selected City now displays governor portrait slot, governor name/stats, governor policy selection, city loyalty, stationed hero chips, and city military/trade copy from local HUD data.
- Governor policy selection updates the selected city's local UI policy state only; it does not change city resources, loyalty, troops, recruitment, turn processing, hero transfer, or army state.
- `CityDetailPanel` now shows selected-city resource, loyalty/policy, military, trade, rating, governor, and stationed hero count data at MVP display scope.
- `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP` realigns the Godot HUD data/UI text with actual `SamWar_web` sources instead of arbitrary domestic UI expansion.
- `CityDetailPanel` now follows the web `resource_ui.js` tab structure: `자원`, `자국무역`, and `타국무역`, with display-only tab switching and web section names such as `식량 자원`, `전략 자원`, `특산 자원`, `무역/보급 정보`, `군사 보급 판단`, `내부 병력 재배치`, and `대외 무역 / 세력 관계`.
- Chancellor policy options now follow the web constants: `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`.
- Governor policy options now follow the web constants: `재상 정책 수행`, `농업 중심`, `상업 중심`, and `군사 중심`.
- City HUD seed data now prioritizes web `data/cities.js`, `data/heroes.js`, and `data/battle_rosters.js` for governor IDs, city loyalty/resource summaries, military summaries, and stationed hero rosters.
- Selected City copy now follows the web `selected_city_ui.js` structure more closely, including `주둔 무장`, `군대 상태`, `공격`, `무장 이동`, and `병사 모집` placeholder wording.
- `v0.68b-11` hides the retired top `SamWar Web` banner and the `도시 HUD 위치 이동 · Godot MVP fixed` dragbar at runtime.
- Godot intentionally improves on the web grouped HUD drag UX: `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` can be dragged independently from title/header labels only.
- HUD panel drag is runtime-only, screen-space, clamped to keep a visible portion on-screen, and does not write user config, localStorage, save files, or project settings.
- Buttons, tabs, and chancellor/governor policy `OptionButton` controls remain outside the drag handles and keep placeholder/display-only behavior.
- `v0.68b-12` consolidates the former separate `CityDetailPanel` and `DiplomacySpyPanel` surfaces into one `CityDetailPanel`-backed unified panel.
- Unified panel primary tabs are `도시 상세` and `외교·첩보`; city-detail secondary tabs remain `자원`, `자국무역`, and `타국무역`, while diplomacy/spy secondary tabs are `외교` and `첩보`.
- The standalone `DiplomacySpyPanel` is hidden at runtime and no longer occupies its own HUD space.
- The unified panel now has a real collapse/expand state with a compact `도시 상세 열기` header; expanded/collapsed position remains runtime-only.
- `CityInfoPanel` remains separate and independently draggable from the unified panel.
- `v0.68b-12b` tightens the left main world HUD against the actual web `renderWorldHud()`, `renderChancellorCard()`, `renderChancellorPolicyControl()`, and resource/trade copy.
- `v0.68b-12b-pre Codex Auto Work Header Rule Documentation` established that future SamWar_BattleLab task prompts must start with `[SamWar_BattleLab 자동 작업 권한 헤더]` before the task name or goal.
- `v0.68b-12b Left World HUD Web Content Parity` was handled as a web-source investigation and targeted parity pass. The work checked the actual left HUD render functions and resource/trade copy, then kept the Godot change display-only rather than expanding into real domestic systems.
- `LeftWorldStatusPanel` now uses web-source runtime copy for `World Turn`, turn/calendar/owner, `국가충성도`, `세금 수준`, `재상`, `재상 임명`, `재상 정책`, `보유 자원`, `국가 창고`, `내부 보급망`, `내부 병력 재배치`, `대외 무역`, income/policy/tax summary, wild-army edit, and save/load/reset.
- The chancellor card keeps a portrait initial fallback but now shows web chancellor type lines such as `주: 정치형 4` and `보조: 행정형 3`; policy options remain the web constants and update display text only.
- `v0.68b-12b` remains display-only. It does not apply turn, resource, tax, loyalty, upkeep, policy, save/load/reset, domestic, diplomacy/spy, battle, hero transfer, army movement, route, pathfinding, sea arrow, or AI behavior.
- `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit` completed the data-source investigation for the next seed import task without changing code, scenes, or web files.
- Web `heroes.js` is an array structure. Relevant fields for Godot seed alignment include `id`, `name`, `factionId`, `side`, `role`, `stats`, `portraitImage`, `battlefieldPortraitImage`, and `chancellorProfile`.
- Web `cities.js` contains city seed fields including `id`, `name`, `region`, `ownerFactionId`, `neighbors`, `routeTypes`, `governorHeroId`, `cityLoyalty`, `resources`, `military`, `domestic`, and `yields`.
- Web `battle_rosters.js` `cityDefenderRosters` is the key source for city stationed hero seed data.
- Web chancellor initial value comes from `app_state.createInitialDomesticPolicy()` and is `chancellorHeroId: null`.
- Web chancellor candidates from `getEligibleChancellorHeroes()` are all active player-side heroes where `hero.side === playerFactionId`.
- Web governor candidates are heroes in the selected city's `stationedHeroes` where `hero.side === playerFactionId` and `hero.locationCityId === selectedCity.id`.
- Current Godot worldmap seed data is centered in `scripts/worldmap_test.gd` through `HERO_DATA`, `CITY_HUD_DATA`, `CHANCELLOR_POLICY_DATA`, `GOVERNOR_POLICY_DATA`, and `_player_state`.
- Current Godot `_player_state.chancellor_id` now uses the web-parity empty baseline, so the left HUD should show `재상 미임명` and no chancellor effect until appointment logic is implemented in a future dedicated task.
- Current Godot data is display-only string seed data, not the full web source numeric/stat object model.
- `v0.68b-12b-0.5` updates handoff docs only so the next chat can start from `v0.68b-12b-1 WorldMap Hero City Seed Data Import`.
- `v0.68b-12b-1 WorldMap Hero City Seed Data Import` aligns `scripts/worldmap_test.gd` seed dictionaries against local read-only web sources `SamWar_web/data/heroes.js`, `SamWar_web/data/cities.js`, and `SamWar_web/data/battle_rosters.js`.
- `HERO_DATA` now keeps existing Godot HUD compatibility keys while adding web identity/faction/side/role/command/stat/portrait/skill/chancellor-profile seed fields, including inactive reserve `lu_bu`.
- `CITY_HUD_DATA` now keeps existing display strings while adding web city identity, owner/nation/region/type, population, gold/food/troop/public-order/commerce/agriculture/defense numeric seed fields, `hero_ids`, and nested resource/domestic/yield seed dictionaries.
- `CITY_HUD_DATA.stationed_hero_ids` remains aligned with web `cityDefenderRosters`, and `governor_id` remains aligned with web `cities.js` `governorHeroId`; Hanseong stays governor-unassigned because the web city seed has no `governorHeroId`.
- `_player_state` now records player faction, selected/origin/ruler city, owned city/hero seed lists, resource stock, and uses an empty `chancellor_id` to match the web initial `chancellorHeroId: null` baseline.
- The seed import did not add hero movement, governor/chancellor appointment execution, policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding changes, scene layout changes, or castle icon changes.
- `v0.68b-12b-2 WorldMap Left Panel Seed Binding QA` stabilizes existing `LeftWorldStatusPanel` display binding against the imported `_player_state`, `CITY_HUD_DATA`, and `HERO_DATA` seed dictionaries.
- The left panel now refreshes when a city marker is selected, records the selected city id in `_player_state`, formats selected/origin city names, selected city owner/region/governor/stationed heroes, owned city/hero lists, resource stock, and no-chancellor default fallback text without exposing raw empty ids.
- `v0.68b-12b-2` remains display-only and did not add movement, appointment execution, policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, scene layout changes, route/pathfinding changes, or castle icon changes.
- `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP` upgrades the left HUD controls toward the actual web `renderWorldHud()` behavior for national loyalty, tax level, and chancellor assignment.
- The left national gauge card now has a tax slider bound to `_player_state.tax_level`; it updates visible tax value/status and web-like income/loyalty preview text only, without applying turn income, resource changes, or permanent loyalty deltas.
- National loyalty now displays a seed-backed label/status/progress bar from `_player_state.national_loyalty`.
- Chancellor assignment now uses `ChancellorAssignmentOption`: `미임명` is always first, and candidates come from the selected city's `CITY_HUD_DATA.stationed_hero_ids` resolved through `HERO_DATA`.
- Selecting a chancellor updates only `_player_state.chancellor_id` for UI display and previews imported chancellor-profile effect text; it does not run appointment execution or policy/resource effects.
- The chancellor portrait area falls back to `?` when no portrait texture exists, so missing portrait assets do not break the card.
- The active scene modified for this patch is root `WorldMap_Test.tscn`; the requested `scenes/WorldMap_Test.tscn` path is absent in this repo.
- `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP` remains left-panel UI/data-binding scope only and did not add turn simulation, resource mutation, loyalty application, policy effect execution, movement, appointment system behavior, `BattleContext`, battle transition, route/pathfinding changes, castle icon changes, or web repo edits.
- `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP` extends the same left-panel parity scope with a functional `재상 정책` dropdown, web-aligned policy labels/descriptions/effect multipliers, and `_player_state.chancellor_policy_id` state binding.
- `CHANCELLOR_POLICY_DATA` now mirrors the web `CHANCELLOR_POLICY_EFFECTS` preview fields for agriculture, commerce, trade, and military policies. The policy dropdown refreshes effect text and preview lines but does not mutate current resources or apply turn effects.
- `국가 창고` is now the authoritative visible resource section in the left panel. The old duplicate `보유 자원: ...` line is retired, while warehouse rows read `_player_state.resource_stock` and show current amount, capacity, and status labels for rice, barley, seafood, wood, iron, horses, silk, salt, and gold.
- Warehouse support previews now show hero upkeep, soldier upkeep, and salt preservation estimates using web constants from `js\constants.js` / `js\core\domestic_income.js`; all remain display-only and non-simulating.
- `v0.68b-12b-3` modified `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and agent docs. The requested `scenes/WorldMap_Test.tscn` path remains absent in this repo.
- `v0.68b-12b-3` did not add hero movement, governor/chancellor appointment execution beyond UI state, full end-turn simulation, actual resource/loyalty mutation, `BattleContext`, battle transition, route/pathfinding changes, castle icon changes, or repo-outside web edits.
- `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup` narrows the visible `국가 창고` section into a boxed runtime `WarehouseCard` UI.
- The visible warehouse card now shows only the 9 resource rows (`쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, `소금`, `금전`) with current/max values and status labels sourced from `_player_state.resource_stock`, `WAREHOUSE_CAPACITY`, and `_get_resource_status_label()`.
- Internal preview lines such as `영웅 유지비`, `병사 유지비 preview`, `보존 소금`, and `유지비 정상` are hidden from the visible warehouse card for this patch; helper data remains available internally for later policy-effect work.
- `v0.68b-12b-3a` remains UI cleanup only and did not add upkeep/resource production, resource mutation, turn simulation, appointment execution, movement, `BattleContext`, battle transition, route/pathfinding changes, or broader HUD redesign.
- `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP` cleans the bottom of `LeftWorldStatusPanel`: remaining visible internal/debug lines below `국가 창고` are hidden, the old `야군 편집` button is replaced with `아군 턴 종료`, and a web-like `저장 관리` title plus `저장` / `불러오기` / `초기화` row is shown.
- `아군 턴 종료` now changes `_player_state.turn_phase` from `player` to `enemy`, updates `current_phase_label` to `적군 턴`, refreshes the left panel, and enters `_run_enemy_turn_mvp()` as a future-safe hook only.
- `_run_enemy_turn_mvp()` intentionally does not run enemy invasion, AI, city ownership changes, hero movement, `BattleContext`, battle transition, resource ticks, or turn advancement back to the player; that return cycle is deferred.
- Save management now persists the current worldmap/player HUD state to `user://worldmap_left_panel_state.json`, loads it back with clean fallback messages, and resets `_player_state` to the startup seed baseline without writing runtime saves into the repo.
- `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP` closes the minimal turn loop: `아군 턴 종료` enters enemy phase, `_run_enemy_turn_mvp()` shows a short placeholder state, `_finish_enemy_turn_mvp()` returns to player phase, and `_advance_world_turn_mvp()` increments the turn exactly once per completed cycle.
- Turn/date labels now mirror the web `world_calendar.js` MVP rule: start year `154`, four seasons in order `봄/여름/가을/겨울`, `10` turns per season, `40` turns per year, displayed as `N년 계절 M턴`.
- Enemy turn pending state disables the turn-end button during the short placeholder and is cancelled on load/reset so duplicate timers do not stack; loading an enemy-phase save resumes the placeholder return path.
- Save/load/reset now preserve and restore `turn_phase`, `turn_number`, calendar labels, selected city, resources, tax, loyalty, chancellor id, and chancellor policy through the existing `_player_state` serialization.
- `v0.68b-12b-5` remains turn-cycle MVP scope only. It does not add enemy invasion, enemy target selection, enemy hero movement, city ownership changes, resource production ticks, domestic turn application, `BattleContext`, battle transition, route/pathfinding changes, or broad AI simulation.
- `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP` applies the first controlled player-side domestic result exactly once when the enemy-turn placeholder finishes and the loop returns to the next player turn.
- The Godot domestic apply path mirrors the narrow web `domestic_income.js` / `app_state.endWorldTurn()` subset: owned city seasonal income, population/commerce tax gold, chancellor policy income multipliers, active chancellor national gold/loyalty/upkeep multipliers, hero upkeep deduction, tax loyalty impact, warehouse capacity clamp, and a concise status summary.
- Tax slider and chancellor policy dropdown remain preview controls until turn completion; UI refresh, save, load, reset, and control changes do not apply resources or loyalty.
- Save/load/reset now serialize the domestic-updated `_player_state.resource_stock`, `national_loyalty`, tax, chancellor id, chancellor policy, phase, turn number, and calendar labels under save version `v0.68b-12b-6`.
- `v0.68b-12b-6` still does not implement enemy invasion, enemy AI, enemy target selection, enemy movement, city ownership changes, governor appointment execution, soldier upkeep application, salt consumption, internal supply/troop rebalance, `BattleContext`, battle transition, or route/pathfinding changes.
- `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check` stabilizes the visible domestic apply loop by recording `_player_state.last_domestic_apply_turn`, so a stale or duplicate same-turn callback cannot apply resources/loyalty twice.
- Save metadata now records `v0.68b-12b-7`, while save/load/reset continue to persist and restore the same `_player_state` fields; reset returns `last_domestic_apply_turn` to the seed baseline and cancels pending enemy/domestic timers.
- `v0.68b-12b-7` is QA/stabilization only. It does not add enemy invasion, enemy AI, target selection, hero movement, city ownership changes, governor appointment execution, new domestic systems, `BattleContext`, battle transition, or route/pathfinding changes.
- `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit` is complete as a docs-only audit. It inspected the web enemy turn, invasion candidate, BattleChoice/BattleContext, battle result, UI, and save/load source flow without changing Godot code or scenes.
- Web enemy invasion is triggered inside `app_state.endWorldTurn()` after player-side turn systems. It rolls `world_rules.rollEnemyInvasion()` with `ENEMY_INVASION_CHANCE = 0.45`; candidates are enemy-owned cities adjacent through `neighbors` to player-owned cities.
- Web target selection is random among eligible adjacent enemy->player city pairs. No troop threshold, route type, diplomacy/peace check, city strength priority, cooldown, or multiple enemy world actions were found in the audited selection path.
- Web invasion creates a defense `pendingBattleChoice` with `battleContext: { type: "defense", attackerCityId, defenderCityId }`; manual/auto defense then starts battle through `startBattle()`. City ownership changes only after defense battle retreat/return, not when the invasion event is created.
- Web save/load normalizes to `mode: "world"`, clears `pendingBattleChoice`, `pendingHeroDeployment`, `pendingHeroTransfer`, `battle`, and `pendingEnemyTurnResult`, and forces `world.turnOwner` back to `player`; pending invasion/battle is not resumed after load.
- Current Godot has the enemy-turn placeholder hook, domestic turn loop, enemy invasion event model, pending battle choice UI, runtime BattleContext bridge, and pending-event/context save/load clearing policy. It still lacks battle scene handoff, defense deployment bridge, ownership/result apply, and resolved world ownership persistence. See `agent/ENEMY_INVASION_AUDIT.md`.
- Combat/world-simulation HUD actions remain mostly placeholder-only. Battle entry, broader domestic simulation, recruitment, diplomacy/spy execution, hero/army movement, route click, pathfinding, and enemy strategic AI remain unimplemented.
- `RouteLayer` now contains scene-authored route roots for the first web-neighbor route graph MVP; `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` remain future worldmap layers.
- Each route root owns exported route metadata plus a child `Path2D` and `Line2D`.
- Route connection meaning is code metadata; the actual route curve is the scene-authored `Path2D.curve` source of truth.
- Initial route curves are seeded from current `CityMarker_*` root positions but runtime must not regenerate or overwrite existing route curves.
- `Line2D` visualizes baked `Path2D` points only, with muted earth-tone land routes and pale blue sea routes below the city markers.
- `v0.68b-4-hotfix1` increases only land route readability: land route width is `4.5` and land color is `Color(0.86, 0.62, 0.32, 0.72)`, while sea route style remains unchanged.
- `v0.68b-5` adds sea-only arrow flow FX to Gyeongju-Kyoto, Gyeongju-Osaka, Sabi-Kyushu, Sabi-Jianye, and Kyushu-Osaka.
- Each sea route has an `ArrowFlowRoot` Path2D that references the route's scene-authored `Path2D.curve` plus four `PathFollow2D` arrow markers.
- Sea route arrow flow is visual-only and moves one-way from `start_city_id` to `end_city_id`; land routes remain line-only.
- `CityLayer` now contains 13 scene-authored `CityMarker_*` nodes for Luoyang, Yecheng, Chengdu, Jianye, Karakorum, Pyeongyang, Hanseong, Gyeongju, Sabi, Kyoto, Osaka, Kyushu, and Edo.
- Castle icon visuals are currently disabled for the functional marker phase. `CastleIcon` nodes and asset references remain in the scene but are hidden through `visible = false` and the `CASTLE_ICON_VISUALS_ENABLED` runtime flag.
- The lightweight colored `CityDot` is visible again as the current functional city marker while city labels, click areas, selection rings, and metadata remain attached to each `CityMarker_*` root.
- Each `CityMarker_*` root owns its icon/dot, name label, and click area/collision children so moving the root in the Godot 2D editor moves the whole city marker bundle.
- Each `CityMarker_*` root owns `CastleIcon`, Node2D `NameText`, and `ClickArea/CollisionShape2D`, so moving the root carries the castle, name, and click area together.
- Each `CityMarker_*` root now uses the explicit child structure `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D`; runtime refreshes label text/color by local child reference and does not place `NameLabel` in world coordinates.
- `NameLabel` is now a `Node2D` text node instead of a `Label` / `Control` node, so it follows `CityMarker_*` root movement in the 2D editor.
- `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` now share the same explicit zero-offset `WorldMapRoot` coordinate basis.
- The 13 city markers were re-seeded into the 4-tile combined rect so they sit over the worldmap image in the 2D editor instead of below it.
- The 13 city markers were re-seeded again against the corrected 1024x1024 editor-visible combined rect after the tile seam fix.
- `scripts/worldmap_city_marker.gd` stores exported marker metadata from `SamWar_web/data/cities.js` and keeps simple label/color visuals on each marker.
- Web city `x` / `y` coordinates are preserved only as initial `web_seed_position`; final city marker placement is the `CityMarker_*` node position in `WorldMap_Test.tscn`.
- City marker positions remain scene-authored source of truth after the manual tile layout control patch.
- City marker click now updates `selected_city_id`, stores `selected_city_marker`, clears the previous marker selection, shows the selected marker's `SelectionRing`, and refreshes `WorldMapUI/CityInfoPanel`.
- `CityInfoPanel` displays city name, city id, region/owner, city type, neighbors, route type summary, MVP status text, and attack / hero-move placeholder buttons.
- `CityInfoPanel` now also includes a short description, garrison placeholder, military information placeholder, hint text, and attack / hero-move / domestic placeholder buttons.
- `CityInfoPanel` now visually includes web-style selected-city details: loyalty progress placeholder, governor placeholder, selected-hero chips placeholder, military state placeholder, and recruit placeholder button.
- `CityDetailPanel` displays selected city name, city type, region/owner, resource/security/military/commerce placeholders, and city status. If no city is selected, it prompts the user to select a city.
- `CityDetailPanel` now visually includes resource / internal trade / external trade tab placeholders and city rating placeholder copy.
- Attack and hero-move buttons are placeholders only and do not create `BattleContext`, transition to battle, move heroes, move armies, or open domestic detail UI.
- Attack, hero-move, domestic, wild-army edit, diplomacy, and spy buttons are placeholder-only and only print debug output or update hint labels.
- City clicking remains a selected-city UI MVP; route clicking, army movement, battle entry, pathfinding, and `BattleContext` runtime injection remain unimplemented.
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
Latest worldmap enemy invasion event patch: `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`

Latest worldmap enemy invasion choice UI patch: `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP`

Latest worldmap BattleContext bridge patch: `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`

Latest worldmap battle scene handoff patch: `v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`

Latest worldmap invasion result apply patch: `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`

Latest worldmap invasion result hotfix: `v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix`

Latest worldmap hero battle contract patch: `v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP`

Latest worldmap hero placement data patch: `v0.68b-12b-16b Hero Placement Data Patch`

Latest hero portrait import metadata audit: `v0.68b-12b-16c Hero Portrait Import Metadata Audit`

Latest actual hero portrait binding patch: `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`

Latest battlefield portrait/skill hotfix: `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`

Current stable baseline: `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`

Baseline commit: local HEAD after `v0.68b-12b-17a`

Latest hotfix notes:
- `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix` restores battlefield portrait badge scale to the previous engine baseline: old `128x128` battlefield portraits used scene scale `0.32`, so 512-source portraits now target about `41px` on the battlefield instead of `128px`.
- The 512 single `portrait_path` source remains; no 128 replacement files or `portrait_128_path` / `portrait_512_path` fields were added.
- WorldMap context skill names now treat `장수명 전법` only as a fallback. If context skill data is missing or fallback-generated, the existing sample unique-skill registry supplies the actual skill name and cutin path where available, preserving the old toast frame/asset path.
- `yi_sunsin` now displays `학익진`; `eulji_mundeok` keeps `살수대첩 매복`; confirmed v0.68b-12b-16b heroes keep 유비 `인의의 깃발`, 권율 `행주대첩 항전`, 척준경 `검왕돌파`, 여포 `무쌍난무`, and 하후돈 `발검돌파`.
- Dedicated skill/cutin images are still optional; missing assets use the common skill fallback icon. Full cutin presentation, save/load expansion, capture/wounds/death, and hero movement remain unimplemented.
- `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP` binds WorldMap BattleContext `portrait_path` data into battle UI portraits before sample HERO_REGISTRY fallbacks can override it.
- Battle portrait Sprite2D slots now load the single 512-source `portrait_path` and scale it to the existing 128 portrait slot target; no `portrait_128_path` / `portrait_512_path` split was added.
- Missing portrait files resolve to a named common unknown portrait fallback instead of a specific sample hero face.
- Unique skill lookup now prefers WorldMap context skill data, so context `skill_name` values such as 유비 `인의의 깃발`, 권율 `행주대첩 항전`, 척준경 `검왕돌파`, 여포 `무쌍난무`, and 하후돈 `발검돌파` drive the toast name when those heroes are in the battle roster.
- Dedicated skill toast/cutin assets are still optional; missing assets use a common skill fallback icon. Full cutin presentation, save/load expansion, capture/wounds/death, and hero movement remain unimplemented.
- `v0.68b-12b-16c Hero Portrait Import Metadata Audit` confirmed this repo already tracks Godot `.png.import` files, including the current `assets/heroes/portraits/**` portrait imports, despite `.gitignore` also ignoring the generated `.import/` cache directory.
- No untracked or ignored `assets/heroes/portraits` `.import` files remained in the working tree, so no import metadata files were deleted or newly added in this audit.
- Next implementation task is `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`.
- `v0.68b-12b-16b Hero Placement Data Patch` adds/strengthens 유비, 권율, 척준경, 여포, and 하후돈 as battle-ready WorldMap heroes.
- City placement now has 유비 in 성도, 권율 in 한성, 척준경 in 평양, 여포 in 낙양, and 하후돈 in 업성; 척준경 is no longer stationed in 한성.
- Confirmed skill names: 유비 `인의의 깃발`, 권율 `행주대첩 항전`, 척준경 `검왕돌파`, 여포 `무쌍난무`, 하후돈 `발검돌파`.
- The 512 single `portrait_path` plus separate `cutin_path` contract remains; save/load, capture/wounds, hero movement, exact balance, and cutin presentation remain deferred.
- `v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP` prepares actual city heroes for BattleContext.
- WorldMap BattleContext now includes `attacker_heroes` and `defender_heroes` enriched from `HERO_DATA` and city `stationed_hero_ids`.
- Every included actual hero gets combat fields plus required unique-skill fields in the runtime handoff copy.
- Portrait contract is one 512-source `portrait_path`; 128 battle slots should downscale from that source. `cutin_path` is separate for skill/cutin imagery.
- Existing 128 folders remain; actual image binding and asset import are deferred to `v0.68b-12b-17` or `16a`.
- Battle scene registers context hero/skill runtime data before roster assignment and preserves the sample roster fallback.
- Save/load expansion for hero battle data is still not implemented.
- `v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix` fixes the F6 crash where invasion-result troop apply wrote into a read-only city Dictionary.
- Cause: `CITY_HUD_DATA` is seed/static data and may be read-only; previous result apply assigned `troops`, `owner`, and `nation` directly into that seed dictionary.
- Runtime owner/troop changes now use mutable `_city_runtime_states` entries created via `duplicate(true)`, and the right panel receives a merged seed + runtime city data map.
- `_apply_attacker_win_invasion_result()` unused attacker city parameter is renamed `_attacker_city_name`.
- Verification passed: `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: live F6 manual invasion return path still needs exact click-through confirmation.
- `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP` applies returned enemy-invasion defense results at bounded runtime scope.
- Result payload handling now accepts result/winner/is_player_win variants plus attacker/defender owner and troop fields.
- Defense victory preserves city ownership, clears pending invasion/context, refreshes UI, and applies minimal nonnegative troop reductions where current/payload troop data exists.
- Defense defeat transfers the target city to the attacker owner through existing `owner` / `nation` city fields and marker `owner_faction_id`, updates `_player_state.owned_city_ids`, applies safe occupation troops, and refreshes right panel/marker/world HUD.
- Retreat/cancel/aborted/unknown results clear pending state safely and do not change ownership.
- Deferred: hero capture, hero movement, resource loss, detailed casualty formulas, save/load persistence expansion for resolved city ownership, AI strategy recalculation, and multi-invasion queues.
- Verification passed: patch strings, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: full interactive F6 should still verify manual victory/defeat/retreat return behavior.
- `v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup` fixes the Godot `owner` local-variable shadow warning in `scripts/battle_web_import_test.gd`.
- Warning cause: `_apply_worldmap_context_side_roster()` used local `owner` for WorldMap context owner metadata, shadowing `Node.owner`.
- The local is now `city_owner_id`; metadata/output keys remain unchanged, so gameplay and ownership behavior are preserved.
- Verification passed: repo-local GDScript `var owner` search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 console warning cleanliness still needs 김작 confirmation across live UI interaction paths.
- `v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup` fixes Godot integer division reload warnings in the WorldMap calendar helpers.
- Warning cause: `scripts/worldmap_test.gd` used ambiguous integer `/` expressions for year and season-index calculation.
- Calendar behavior is preserved: start year `154`, seasons `봄 / 여름 / 가을 / 겨울`, `10` turns per season, and `40` turns per year.
- Verification passed: patch strings, calendar constants, ambiguous calendar division cleanup, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 console warning cleanliness still needs 김작 confirmation across live UI interaction paths.
- `v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard` fixes the F6 runtime error where `_refresh_unified_panel_chrome()` assigned `.visible` on a nil unified panel chrome node.
- `scripts/worldmap_test.gd` now guards runtime-created primary tab buttons and scene tab controls before `.visible` / `.modulate` writes, with a concise one-time warning if a chrome node is missing.
- No gameplay behavior, battle result apply, city ownership, troop/resource mutation, invasion flow, turn logic, domestic apply, or save/load behavior changed.

Current Godot state:
- `scripts/worldmap_test.gd` now rolls a web-parity enemy invasion event during the existing enemy-turn placeholder.
- The MVP uses `ENEMY_INVASION_CHANCE = 0.45`, attacker candidates from enemy-owned scene city markers, and defender candidates from neighboring player-owned markers.
- On success, `_player_state.pending_invasion_event` records a display-only defense event with `attacker_city_id`, `defender_city_id`, source, and turn number.
- The left world panel shows a concise Korean invasion status, selects the defender city for visibility, and displays a web-like `PendingInvasionChoiceCard`.
- The choice card shows `적군 침공 발생`, attacker/defender city lines, `방어전을 준비하십시오.`, and `수동 방어` / `자동 방어` buttons.
- The defense buttons now validate the pending invasion event, create runtime `_player_state.pending_battle_context`, hand off a deep copy through Godot `Engine` metadata, and transition to `Battle_Fullscreen_Test.tscn`.
- Pending battle context includes defense type/source/mode, attacker/defender ids and names, turn numbers, owner ids, troops, stationed hero ids, and governor ids from existing marker/HUD seed data.
- `scripts/battle_web_import_test.gd` reads the handoff context once, clears the metadata, stores local `worldmap_battle_context`, and logs the manual/auto mode plus attacker/defender city names.
- `scripts/battle_web_import_test.gd` now returns battle result payload owner/troop fields for WorldMap result application.
- `scripts/worldmap_test.gd` consumes returned invasion results, applies defense victory/defeat/retreat/unknown branches, clears pending state, and refreshes city marker/right panel/world HUD.
- Runtime city owner/troop result changes are stored in `_city_runtime_states` instead of mutating read-only seed dictionaries.
- Actual city hero battle contract data is now carried in `attacker_heroes` / `defender_heroes` for future battle UI/image binding.
- `아군 턴 종료` is disabled/blocked while a pending invasion event exists so enemy events cannot stack before the choice flow is handled.
- Save/load/reset clear pending invasion and pending battle context state; runtime saves do not persist either runtime choice object, and load normalizes enemy-phase saves back to player turn.
- Runtime defense defeat can change city ownership and target-city troops for the current session; save/load persistence for resolved city state remains deferred.
- No hero movement/capture, resource loss, enemy AI, pathfinding, cooldown, diplomacy rule, defense deployment UI, auto battle resolution, or detailed casualty formula was added.
- User-reported F6 runtime visual check for the current baseline is working normally, and the pending invasion choice UI displays adequately for the current MVP.
- Active worldmap scene is the root-level `WorldMap_Test.tscn`; `scenes/WorldMap_Test.tscn` may not exist in this repo.
- Runtime save path is `user://worldmap_left_panel_state.json`.
- `agent/LOCAL_ENV.md` and `.godot/` remain ignored local files and should not be committed.

Completed WorldMap session flow:
1. `v0.68b-12b-1 WorldMap Hero City Seed Data Import`
2. `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP`
3. `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP`
4. `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup`
5. `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP`
6. `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`
7. `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`
8. `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`
9. `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit`
10. `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`
11. `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP`
12. `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup`
13. `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP`
14. `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`
15. `v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`
16. `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`

Current implemented systems:
- Web hero/city/battle roster seed data imported into Godot worldmap seed structures.
- Left panel web-parity controls for national loyalty, tax slider, chancellor assignment, chancellor policy, policy effect text, and national warehouse card.
- Turn system with `아군 턴 종료`, enemy placeholder, return to next ally turn, turn number/calendar advancement.
- Calendar rule: start year `154`, seasons `봄 / 여름 / 가을 / 겨울`, `10` turns per season, `40` turns per year.
- Save/load/reset via `user://worldmap_left_panel_state.json`.
- Domestic apply runs once per full turn cycle and covers tax income, loyalty change, chancellor policy effects, warehouse resource updates, and duplicate apply guard.
- Enemy invasion MVP covers 45% invasion roll during enemy turn, enemy-owned attacker city, neighboring player-owned defender city, pending event, defender city auto-selection, pending choice card, manual/auto defense placeholder buttons, and turn-end blocking while pending.
- `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup` is complete.
- The right `CityInfoPanel` now uses existing `_player_state`, `CITY_HUD_DATA`, `HERO_DATA`, city marker data, and pending invasion state for clean selected-city display.
- Selected cities show name, owner/nation/region, population, gold, food, resource ratings, troops, defense, public support/order, commerce, agriculture, governor/taesu, and stationed hero names without raw id-first display or dictionary/debug text.
- No selected city shows `선택 도시 없음` and `월드맵에서 도시를 선택하십시오.`; empty governor and garrison states show `태수 없음` and `주둔 장수 없음`.
- If the selected city is the pending invasion defender, the right panel shows `침공 대상 도시 · 방어전 준비 중`; if it is the attacker, it shows `침공 출발 도시`.
- Modified files: `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, root `WorldMap_Test.tscn`, and agent docs.
- Web source files inspected: `world_map_ui.js`, `world_hud_ui.js`, `ui_render.js`, `selected_city_ui.js`, `app_state.js`, `world_rules.js`, `data/cities.js`, and `data/heroes.js`.
- Verification passed: patch strings present, right-panel display strings present, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- Remaining risk: visual fit still needs Kimjak F6 confirmation because the panel content is denser than before.
- `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP` is complete.
- Added `scripts/worldmap_hero_portrait_helper.gd` as the shared portrait lookup/apply path for current and future WorldMap UI.
- Portrait lookup uses existing `HERO_DATA` portrait fields such as `portrait_image`, maps legacy `assets/portraits/...` seed paths to existing `assets/web_battle/portraits/...` files, and includes compact compatibility paths for known available portrait assets.
- Updated the left chancellor card and right taesu/governor card so valid portraits display as textures and missing/failed portraits keep the dark `?` fallback.
- Stationed hero list remains text-only in this MVP to preserve the compact right-panel layout; the shared helper is ready for later pending invasion/defense UI use.
- Asset folders inspected: `assets/web_battle/portraits`, `assets/web_battle/portraits_battlefield`, and repo-local asset listings.
- Verification passed: patch strings/helper bindings present, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge` is complete.
- Manual and auto defense buttons now create runtime-only pending battle context data from `_player_state.pending_invasion_event`.
- Validation requires a defense event, known attacker/defender cities, enemy-owned attacker, and player-owned defender; invalid inputs fail safely with a Korean status message and no scene transition.
- The context is excluded from save serialization and cleared on load/reset along with pending invasion event state, matching the web save/load policy.
- `v0.68b-12b-13 Battle Roster Context Apply MVP` is complete.
- `Battle_Fullscreen_Test.tscn` still launches directly with the existing demo roster when no WorldMap context metadata exists.
- When WorldMap handoff context exists, `scripts/battle_web_import_test.gd` adapts the existing ally/enemy capacity slots from defender/attacker governor and stationed hero ids where those ids resolve to the current battle hero registry; unknown or missing heroes fall back per-slot to `TEST_BATTLE_ROSTER`.
- The battle scene logs `월드맵 방어전 편성 적용` and keeps city names/mode visible through the handoff log path.
- City troop counts remain context metadata for now; combat HP/troop scaling is deferred to avoid a balance rewrite.
- `v0.68b-12b-14 WorldMap Battle Result Return MVP` is complete.
- Battle result return uses runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_result`; no save file, repo runtime file, autoload, or project setting was added.
- WorldMap-launched battles show a runtime `월드맵으로 돌아가기` button after victory/defeat, build a defense result payload, and transition back to root `WorldMap_Test.tscn`.
- WorldMap consumes and clears the result metadata on startup, shows a defense success/failure status, clears pending invasion event and pending battle context, and refreshes HUD panels.
- `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP` is complete.
- Returned defense battle payloads now include attacker/defender owner ids, starting troop counts, and deployed survivor troop totals.
- WorldMap result apply preserves ownership on defense victory, transfers the target city to the attacker owner on defense defeat, applies safe nonnegative troop changes, clears pending invasion/context, and refreshes marker/right panel/world HUD.
- Retreat/cancel/aborted/unknown results are safe no-ownership-change branches.
- Resource loss, wounded handling, hero movement/capture, detailed casualty calculation, AI recalculation, multi-invasion queues, and save/load persistence expansion remain deferred.
- Selected battle scene: `Battle_Fullscreen_Test.tscn`, using `scripts/battle_web_import_test.gd`.
- Handoff strategy: runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_context`; no autoload, save file, project setting, or repo runtime file was added.
- Manual/auto defense now transitions to the battle scene after context preparation. The battle scene preserves direct standalone test launch by falling back to the existing demo setup when context is absent.
- Verification passed: patch strings, handoff/intake paths, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and direct `Battle_Fullscreen_Test.tscn` headless load.

Explicitly deferred systems:
- Defense hero deployment UI.
- Auto defense resolution.
- Save/load persistence expansion for resolved city ownership/troop state.
- Resource loss from battle.
## v0.70-13a Battle Intro Wide Hold Timing Polish
- Battle intro wide-shot hold was increased so the battlefield background is readable before zoom-in begins.
- Zoom-in duration was slightly increased to make the camera move feel less abrupt.
- Skip behavior, UI restore timing, input guard, and gameplay camera restoration remain unchanged.
- No battle logic, turn flow, result/worldmap flow, cutin/result video assets, archer FX, or gunner FX changes are intended.
- Manual QA should confirm the intro now gives enough time to appreciate the battlefield without feeling slow.

## v0.70-13 Battle Intro Camera Zoom Patch
- Battle start now plays a visual-only intro camera sequence: wide battlefield shot first, then smooth zoom into the normal gameplay camera position/zoom.
- `MainCamera` final gameplay state is captured before the intro and restored after completion or skip.
- `BattleUI` is hidden during the intro and restored after the zoom, keeping the battlefield and units visible.
- Skip input is supported during the intro through mouse click, Space, Enter, numpad Enter, or Esc.
- Battle input and command buttons are guarded while the intro camera is playing.
- No battle logic, grid logic, cutin/result video assets, archer FX, gunner FX, battle result payload, or worldmap logic changes are intended.
- Manual QA should confirm the wide-shot feel, zoom duration, UI restore, skip behavior, and normal battle controls after the intro.

## v0.70-12a Battle Result Video Panel Size Polish
- Battle result videos now display as a centered cinematic panel instead of filling the entire viewport.
- The result video player keeps a full-screen dim backdrop, but the video itself is constrained to a centered 16:9 panel sized from the viewport.
- Existing flow is preserved: result video -> existing victory/defeat toast -> existing result/worldmap return handling.
- Result video load failure fallback still shows the existing toast immediately.
- No battle result payload, worldmap logic, special-skill cutin mapping, archer FX, or gunner FX changes are intended.
- Manual visual QA should confirm victory and defeat result videos are no longer full-screen, keep their aspect ratio, and still hand off to the existing toast/result flow.

- Detailed casualty calculation beyond the current minimal troop apply.
- Hero capture and hero city movement.
- Enemy strategic AI and enemy multi-action turn.
- Internal supply network, troop redistribution, trade cooldown.
- Soldier upkeep / salt consumption if still deferred.
- Full governor appointment execution.

Next direction:
1. `v0.68b-12b-16 WorldMap Invasion Result Persistence / QA Follow-up`
2. `v0.68b-12b-4 WorldMap City Detail Governor / Stationed Hero Web Parity MVP`
3. `v0.68b-12c Selected City Panel Web Content Parity`
4. `v0.68b-12d City Detail Panel Web Content Parity`
5. `v0.68b-12e Diplomacy Spy Panel Web Content Parity`
6. `v0.68c BattleContext Runtime Injection MVP`

## Known / Deferred
- v0.68b-12b-33D Defense Deployment Panel Parity: enemy invasion defense no longer jumps directly into battle from the defense buttons. Manual/auto defense opens the shared deployment panel in defense mode, showing defender city heroes, wounded badges, commandLimit, and per-hero troop SpinBox allocation. Captured/dead heroes remain excluded, wounded heroes remain selectable, and defense confirm validates at least one selected hero, positive troops, commandLimit clamp, and defender-city reserve. Confirm writes `selected_defender_hero_ids`, selected `defender_troop_allocation`, and `defender_total_allocated_troops` into the enemy_invasion defense BattleContext before existing attacker/defender pre-decrement and woundedQueue result flows. Cancel keeps the pending invasion event. F6 UX polish remains separate.
- v0.68b-12b-32 CommandRank CommandLimit Allocation Parity: Godot now mirrors the web command rank constants (`governor` 10000 / `general` 8000 / `lieutenant` 6000 / `officer` 5000, labels 태수/장군/부장/군관). City governors are treated as governor rank for allocation. Player attack deployment rows show command limit, SpinBox max is capped by command limit and source deployable troops, confirm validation re-clamps allocations, and player attack defender plus enemy invasion attacker/defender default allocations now use commandLimit distribution. Troop accounting, woundedQueue, hero wounded penalty, and captured/dead exclusion are intended unchanged. F6 manual QA remains needed for UI display and real attack/defense regression.
- v0.68b-12b-27 Player Attack Deployment UI MVP: player attack now opens a deployment panel before battle handoff. The MVP lists deployable source-city heroes, excludes captured/dead heroes, keeps wounded heroes selectable with state badges, requires at least one selected hero and troop assignment, enforces `source city troops - 1` max deployment, previews supply cost as food/rice `troops`, gold `ceil(troops * 0.2)`, salt `ceil(troops * 0.1)`, pays cost from the source city's runtime `resource_stock`, stores source-city supply stock in city save/load overrides, and adds `selected_attacker_hero_ids`, `attacker_troop_allocation`, `supply_cost`, and `supply_source_city_id` to `player_attack` BattleContext. Excluded: hero selection polish, troop type UI, sea/2-hop attacks, in-battle supply effects, plunder/loss recovery, siege UI, and manual support selection.
- 김작 F6 visual QA should confirm `v0.68b-12b Left World HUD Web Content Parity`: left main HUD section order is close to the web left HUD; turn/date/phase display follows web wording; chancellor card resembles the web structure; chancellor policy list/copy matches the web constants; selecting a policy updates explanation only and does not change actual values; national resources, warehouse, supply, troop rebalance, logistics/upkeep, and external trade summaries use web-like copy; button wording follows the web; placeholder feel is reduced; bottom empty space is acceptable; unified panel and Selected City panel structure remain intact; drag/collapse works; city clicks still refresh panels; route lines and sea arrow flow are normal; castle icon visuals stay hidden; existing battle scenes are not broken.
- 김작 F6 visual QA should confirm `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`: CityDetailPanel and DiplomacySpyPanel appear as one unified panel; primary tabs `도시 상세` / `외교·첩보` are visible; city-detail mode shows `자원` / `자국무역` / `타국무역`; diplomacy/spy mode shows `외교` / `첩보`; tab clicks switch only visible content; collapse makes the panel compact and reopenable; the unified panel and SelectedCityPanel drag independently; panel dragging does not pan the worldmap camera; city clicks still refresh unified and selected-city content; buttons do not execute real systems; route lines and sea arrow flow remain normal; castle icon visuals remain disabled; existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`: Godot panel structure resembles the actual web HUD source, City Detail tabs/text/buttons follow `resource_ui.js`, Selected City follows `selected_city_ui.js`, chancellor/governor policy options follow web constants, web city/governor/hero roster data is reflected where available, City Detail tab clicks switch displayed content only, policy selection changes description only, buttons do not change resources/turns/battle/movement, city clicks update Selected City and City Detail together, castle icon visuals remain disabled, route lines and sea route arrow flow remain normal, HUD remains fixed during pan/zoom, and existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-9 WorldMap HUD Data Binding MVP`: left panel shows chancellor portrait slot, name, stats, current policy, and resources; chancellor policy selection changes the description without applying actual effects; city click updates Selected City and City Detail together; selected city shows governor portrait slot, name, stats, policy, city loyalty, and stationed hero chips; governor policy selection changes the description without changing actual city data; CityDetail shows resource/military/trade/rating/governor/stationed hero count data; all buttons remain placeholder-only; castle icon visuals remain disabled; route lines and sea route arrow flow remain normal; HUD remains fixed during pan/zoom; existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-8 WorldMap Web HUD Visual Parity MVP`: the left World Turn panel resembles the web version, upper-right Diplomacy/Spy panel is visible, right City Detail panel is visible, right Selected City panel visually resembles the web version, panel color/border/title/button style reads close to the web HUD, city clicks update Selected City and City Detail, buttons do not execute real behavior, panels remain screen-fixed during pan/zoom, panels do not excessively cover the map, castle icon visuals remain disabled, route lines and sea arrow flow remain normal, and existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-8`: left World Turn/국력/자원 panel is visible, upper-right Diplomacy/Spy panel is visible, right City Detail panel is visible, right Selected City panel is visible, city clicks update City Detail and Selected City together, panels stay screen-fixed during camera pan/zoom, panels do not excessively cover the map, attack/hero-move/domestic buttons do not execute real behavior, castle icon visuals remain disabled, route lines and sea route arrow flow remain normal, and existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-6a`: castle icons are not visible on the worldmap, city name labels remain visible, simple functional city markers remain visible, city clicking still selects cities, selected cities show `SelectionRing`, `CityInfoPanel` displays normally, route lines and sea route arrow flow remain normal, pan/zoom does not break city clicking, and existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-6`: city markers can be clicked to select a city, the selected city is visually distinguished by its marker-local selection ring, `CityInfoPanel` stays fixed on screen, the panel shows city name/id/region/owner/type/neighbors/routeTypes, attack and hero-move placeholders are visible and do not launch real behavior, pan/zoom does not break city clicking, route lines and sea arrow flow remain normal, city clicking does not break routes or UI, and existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-1` worldmap canvas: 4 tiles appear as one map without visible gap/overlap, tile boundaries do not show obvious seams, Camera2D pan is smooth, camera clamp avoids excessive gray outside area, UI labels remain screen-fixed, `CityLayer` / `RouteLayer` / `ArmyLayer` / `EffectLayer` exist in the scene tree, and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 F6 visual QA should confirm `v0.68b-2` city markers: all 13 `CityMarker_*` nodes are visible under `CityLayer`, marker labels/colors are readable enough for MVP placement, moving a marker in the Godot 2D editor and saving preserves that scene-authored position at runtime, camera pan/zoom does not detach markers from the map, and no city click/battle entry behavior exists yet.
- 김작 F6 visual QA should confirm `v0.68b-2-hotfix1`: in the 2D editor, all 13 city markers sit on top of the 4-tile worldmap image, no marker is scattered in the lower gray area, `CityLayer` and `WorldMapTileLayer` share the same coordinate space, moving a marker and saving preserves runtime position, camera pan/zoom/clamp still works, UI labels stay screen-fixed, and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix2`: 4 tiles are contiguous in the 2D editor with no horizontal row gap or vertical column gap, all 13 city markers sit on the map image, debug layers do not obstruct city placement, camera pan/drag/zoom/clamp still works, UI labels stay screen-fixed, and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix3`: the four Tile nodes can be selected and moved in the 2D editor, Ctrl+S preserves the tile layout, F6 does not overwrite Tile positions, camera clamp follows the current tile union rect, all 13 city markers remain present, and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix4`: moving `CityMarker_Hanseong` root moves icon/dot, name label, and click area together; all other `CityMarker_*` roots behave the same; Ctrl+S preserves positions; clicking a marker updates the info label; camera pan/zoom/clamp remains normal; and `Battle_Fullscreen_Test.tscn` remains stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix5`: moving `CityMarker_Hanseong` root moves `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D` together; all 13 city marker roots use the same child structure; Ctrl+S preserves positions; marker click info panel remains normal.
- 김작 2D/F6 visual QA should confirm `v0.68b-2-hotfix6`: moving each `CityMarker_*` root now moves the Node2D `NameLabel` text visibly with the marker dot and click area; Ctrl+S and F6 preserve the moved bundle.
- 김작 2D/F6 visual QA should confirm `v0.68b-3`: all 13 cities show castle icons instead of dots; Korea/China/Japan/Ordo icon mapping is correct; moving a `CityMarker_*` root moves `CastleIcon`, `NameText`, and `ClickArea`; city click info panel, camera pan/zoom/clamp, and the battle scene remain stable.
- 김작 2D/F6 visual QA should confirm `v0.68b-4`: `RouteLayer` contains route roots with `Path2D` and `Line2D`, `Path2D.curve` points can be directly adjusted in the 2D editor, land/sea routes are visually distinct without covering city markers, F6 shows route lines attached to the worldmap during pan/zoom, city click info panel still works, and existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-4-hotfix1`: land routes are clearly more visible than before, do not disappear into mountain/plain earth tones, do not overpower city castle icons, sea route style still feels unchanged, pan/zoom keeps routes attached, `Path2D` curve editability remains intact, city click info panel still works, and existing battle scenes remain stable.
- 김작 F6 visual QA should confirm `v0.68b-5`: sea route arrows are visible on the five sea routes, move naturally along `Path2D` curves, wrap from route end to start, move at a readable speed, do not overpower city names/icons, land routes have no arrows, pan/zoom keeps arrows attached to the map, city click info panel still works, and existing battle scenes remain stable.
- Known issue retained for route-layer follow-up context: moving a `CityMarker_*` root may still require manual confirmation that all name text follows perfectly; this was not changed in `v0.68b-4`.
- Codex Godot headless verification for `v0.68b-3` was blocked by the tool sandbox `windows sandbox: spawn setup refresh` error; 김작 local F6/headless QA should confirm `WorldMap_Test.tscn` scene load and GDScript warning cleanliness.
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
