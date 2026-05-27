# HANDOFF TO CODEX

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
`v0.68b-2 WorldMap City Marker Layer MVP`

- Latest worldmap marker hotfix:
`v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix`

- Latest worldmap tile hotfix:
`v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix`

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
- The four prepared worldmap tiles are arranged as a 2x2 `WorldMapTileLayer` using `Sprite2D.centered = false` and texture-size-based placement.
- `WorldMapCamera` is a scene-authored `Camera2D` configured current at runtime with WASD/arrow pan, right/middle mouse drag pan, optional wheel zoom, and clamp against the combined tile rect.
- `WorldMapUI` is a CanvasLayer with screen-fixed title, camera debug, and input hint labels.
- `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` exist as empty Node2D layers for future work.
- `CityLayer` contains the first 13 scene-authored `CityMarker_*` nodes based on `SamWar_web/data/cities.js`.
- `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` share the same explicit zero-offset `WorldMapRoot` coordinate basis.
- The current 13 `CityMarker_*` positions have been re-seeded to the 4-tile combined rect so they sit on the map image in the 2D editor.
- After the tile seam fix, the 13 `CityMarker_*` positions are seeded against the corrected 1024x1024 editor-visible combined rect.
- Each city marker stores exported metadata for city id, display name, region id, owner faction id, neighbors, route types, and `web_seed_position`.
- Web `x` / `y` values are only initial seed/fallback placement data; final marker position source of truth is the `CityMarker_*` node position saved in `WorldMap_Test.tscn`.
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
- Next candidates:
  - `v0.68b-3 WorldMap Route Layer MVP`
  - `v0.68c BattleContext Runtime Injection MVP`
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
