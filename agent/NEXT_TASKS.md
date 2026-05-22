# NEXT TASKS

## Current Stable Baseline
v0.67k-1-hotfix Reinforcement Toast Sequence Fix

## Priority 1
5v5 Battle Sustain QA

Gate:
- v0.67k confirmed:
  - MVP battle target is fixed to `5v5`
  - reinforce01 / reinforce02 deployment ladder is stable at `3v3 -> 4v4 -> 5v5`
  - deployed alive count moves `6 -> 8 -> 10`
  - actor / target counts move `3/3 -> 4/4 -> 5/5`
  - battle-slot hero identity now resolves from `hero_id` registry rather than scene portrait texture
  - `10` current battle slots validate hero name / battlefield portrait / closeup lookup scaffold at startup
  - round `2` / round `3` reinforcement arrival toast is now sequenced ahead of the round-start `BATTLE n` toast on the shared toast root

Goal:
- Continue manual/editor sustain QA on the fixed MVP `5v5` battle shape.
- Verify auto battle remains visually stable with round-start toast and reinforcement-arrival toast overlap cases.

## Priority 2
Reinforcement Toast QA

Goal:
- Verify reinforcement arrival toast readability, duration, and overlap timing in editor.
- Confirm toast does not visually overstay or obscure control feedback.

## Priority 3
Auto Battle QA

Goal:
- Verify full auto ON/OFF behavior in editor with emphasis on stop responsiveness.
- Confirm soft stop behavior during ally action, enemy action, and resolving states.
- Confirm manual command buttons remain stable after auto battle stop.
- Verify battle-dust readability during attack / hit moments.

Notes:
- Auto battle prototype, stop hotfix, battle-dust tuning, dust density hotfix, and dust source isolation hotfix are now in place.

## Completed
v0.67k-1-hotfix Reinforcement Toast Sequence Fix

Completed items:
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Diagnosed the reinforcement-toast invisibility issue as same-root / same-tween overwrite by the round-start toast.
- Added queued toast playback on top of the shared `RoundToastRoot`.
- Added:
  - `_enqueue_battle_toast()`
  - `_play_next_battle_toast()`
  - `_finish_battle_toast_playback()`
- Added runtime toast queue/playback state:
  - `pending_battle_toasts`
  - `is_battle_toast_playing`
  - `active_battle_toast_tag`
- Cleared stale toast queue/tween state during `reset_demo_state()`.
- Reinforcement arrival toast now queues ahead of the round-start `BATTLE n` toast on rounds `2` and `3`.
- Headless smoke confirms:
  - round `2` = `reinforcement_arrival -> BATTLE 2`
  - round `3` = `reinforcement_arrival -> BATTLE 3`
- Kept reinforce deploy conditions, actor/target flow, auto battle, and enemy AI unchanged.

## Completed
v0.67k-1 Reinforcement Arrival Toast MVP

Completed items:
- Reused the existing `RoundToastRoot` structure for reinforcement arrival toast.
- Added runtime reinforcement toast image path:
  - `res://assets/web_battle/ui/reinforcement/reinforcement_arrival_toast_01.png`
- Added runtime reinforcement toast text:
  - `지원군 도착!`
- Added round `2` reinforce01-pair deploy toast trigger.
- Added round `3` reinforce02-pair deploy toast trigger.
- Confirmed headless smoke logs for:
  - round `2`
  - round `3`
- Confirmed `5v5` actor/target counts remain stable after the toast addition.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Headless project launch exit code `0`.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## Completed
v0.67k Battle Hero Identity Source of Truth Scaffold

Completed items:
- Added runtime `HERO_REGISTRY` for the current `10` battle heroes.
- Added `TEST_BATTLE_ROSTER` as the temporary slot-to-hero battle contract.
- Routed `assigned_hero_id` through `capacity_slot_metadata_registry`.
- Added runtime application of:
  - `display_name`
  - battlefield portrait badge texture
  - closeup portrait texture lookup
  from `hero_id`.
- Added startup identity validation logging for all current battle slots.
- Confirmed startup identity validation reports `IDENTITY_OK` for the current `10` slots.
- Kept `Battle_Fullscreen_Test.tscn` unchanged in this step.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Headless project launch exit code `0`.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## Completed
v0.67k Auto Battle Step Limit 5v5 Sustain Fix

Completed items:
- Replaced the old fixed auto-battle step cap `40` with deployed-unit-count-based dynamic budgeting.
- Added:
  - `AUTO_BATTLE_MIN_MAX_STEPS = 80`
  - `AUTO_BATTLE_STEP_BUDGET_PER_DEPLOYED_UNIT = 16`
  - `AUTO_BATTLE_ABSOLUTE_MAX_STEPS = 200`
  - `_get_auto_battle_max_steps()`
- Clarified the stop log when the safety cap is reached.
- Confirmed computed budgets:
  - alive `6` -> `96`
  - alive `8` -> `128`
  - alive `10` -> `160`
- Confirmed round `3` actor candidates ally/enemy = `5/5`.
- Confirmed round `3` target candidates ally/enemy = `5/5`.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Headless project launch exit code `0`.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## Completed
v0.67j-5 MVP 5v5 QA Stable

Completed items:
- Revalidated the current MVP battle shape as `5v5` with no code, scene, or asset changes.
- Fixed the stable baseline target to:
  - `3` main + `2` city-origin reinforce per side
- Confirmed round progression:
  - round `1` = `3v3`
  - round `2` = `4v4`
  - round `3` = `5v5`
- Confirmed deployed alive count = `6 -> 8 -> 10`.
- Confirmed round `3` actor candidates ally/enemy = `5/5`.
- Confirmed round `3` target candidates ally/enemy = `5/5`.
- Confirmed reinforce01 / reinforce02 visual display, HP bar, troop label, click, and target behavior are normal on the current prototype.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Headless project launch exit code `0`.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## Completed
v0.67j-4 Reinforce02 City-Origin Entry Prototype

Completed items:
- Added real reinforce02 scene/runtime scaffold for both sides.
- Added:
  - `ally_reinforce_02_unit_state`
  - `enemy_reinforce_02_unit_state`
- Added city-origin mock contract metadata for reinforce02:
  - `entry_rule = city_reinforcement`
  - `source_city_id`
  - `dispatch_type`
  - `assigned_hero_id`
  - `assigned_unit_id`
  - `arrival_round = 3`
- Kept reinforce01 round `2` deployment logic unchanged.
- Added reinforce02 round `3` city-origin arrival trigger.
- Confirmed counts:
  - battle start alive deployed = `6`
  - round `2` alive deployed = `8`
  - round `3` alive deployed = `10`
  - round `3` actor candidates ally/enemy = `5/5`
  - round `3` target candidates ally/enemy = `5/5`
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Headless project launch exit code `0`.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## Completed
v0.67j-3 City Reinforcement Contract Scaffold

Completed items:
- Reframed reinforcement semantics from temporary round-spawn prototype to future city-origin battle entry contract.
- Confirmed `capacity_slot_metadata_registry` is dictionary-backed and can accept future metadata keys by setter path.
- Confirmed current default reinforce scaffold already contains:
  - `entry_rule`
  - `source_city_id`
  - `assigned_unit_id`
- Defined required future contract keys:
  - `source_city_id`
  - `dispatch_type`
  - `assigned_hero_id`
  - `assigned_unit_id`
  - `arrival_round`
  - `entry_rule = city_reinforcement`
- Documented reinforce01 round `2` deployment as temporary test trigger only.
- Documented reinforce02 as the next city-origin entry prototype, not a simple round `3` spawn copy.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.

## Completed
v0.67j-2 Reinforce01 QA Stable

Completed items:
- Revalidated the current reinforce01 round-`2` entry prototype with no code or scene changes.
- Confirmed battle start:
  - alive deployed count = `6`
  - actor candidates ally/enemy = `3/3`
  - target candidates ally/enemy = `3/3`
  - `ally_reinforce_01` / `enemy_reinforce_01` = hidden, `deployed=false`
- Confirmed round `2` post-deploy:
  - alive deployed count = `8`
  - actor candidates ally/enemy = `4/4`
  - target candidates ally/enemy = `4/4`
  - `ally_reinforce_01` / `enemy_reinforce_01` = visible, `deployed=true`
- Confirmed reinforce02 remains empty-container scaffold only and undeployed.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Headless project launch exit code `0`.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code `0`.

## Completed
v0.67g MVP 3 Main + 2 Reinforce Layout Plan

Completed items:
- Added `agent/MVP_3_MAIN_2_REINFORCE_LAYOUT_PLAN.md`.
- Documented MVP `3` main + `2` reinforce slot structure and current `2v2` mapping bridge.
- Documented main-slot placement, reinforce entry-lane concepts, naming options, expansion risks, and roadmap.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.

## Completed
v0.67h MVP 5-Slot Scene Scaffold

Completed items:
- Added 6 empty `Node2D` scene slot containers under `Slots`:
  - `AllyMain03Slot`
  - `AllyReinforce01Slot`
  - `AllyReinforce02Slot`
  - `EnemyMain03Slot`
  - `EnemyReinforce01Slot`
  - `EnemyReinforce02Slot`
- Kept the existing 4-slot visual-root structure unchanged.
- Added `@onready` references for the new empty slot containers in `scripts/battle_web_import_test.gd`.
- Added `CAPACITY_SLOT_ID_TO_SCENE_SLOT_PATH` as metadata scaffold only.
- Added one-time startup slot-container existence snapshot.
- Did not add new `BattleUnitState`.
- Did not add new `UnitVisualRoot`, `ClickArea`, `ReadyFrame`, or `FacingIndicator`.
- Did not register the new empty slot containers into the `UnitVisualSlot` runtime cache.
- Kept current battle execution, actor/target results, auto battle flow, and enemy AI flow unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## Completed
v0.67i-1 MVP 5-Slot Battle Prototype - Main03 Activation Spike

Completed items:
- Added real `main_03` visual/runtime scaffold for both sides:
  - `AllyMain03UnitVisualRoot`
  - `EnemyMain03UnitVisualRoot`
  - root-level click areas
  - root-level markers / portrait markers
  - `BattleUI` facing indicators
  - `BattleUI` ally ready frame
- Added:
  - `ally_main_03_unit_state`
  - `enemy_main_03_unit_state`
- Expanded adapter/runtime state lists and visual cache to `3v3`.
- Kept reinforce slots undeployed and uninstantiated.
- Kept current auto-battle scoring unchanged.
- Kept current enemy AI target-selection policy unchanged.
- Kept current HP/troop/layer/facing hotfix behavior unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## Completed
v0.67i-2 MVP 3v3 QA Stable

Completed items:
- Revalidated current `3v3` main-slot baseline without changing code or scene files.
- Confirmed:
  - ally count = `3`
  - enemy count = `3`
  - all count = `6`
  - actor candidates ally/enemy = `3/3`
  - target candidates ally/enemy = `3/3`
  - all alive deployed count = `6`
  - auto target parity OK = `true`
  - enemy AI target parity OK = `true`
  - enemy actor order parity OK = `true`
- Confirmed reinforce remains scaffold-only and undeployed.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/battle_web_import_test.gd` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## Completed
v0.67c-hotfix7 Enemy Portrait Facing Offset Restore

Completed items:
- Added `_get_enemy_portrait_offset_for_facing()` in `scripts/battle_web_import_test.gd`.
- Switched enemy main/support group base portrait placement to use the enemy vertical-offset helper.
- Restored enemy `FACING_UP` / `FACING_DOWN` portrait placement to the stable scene-authored fallback offset so portraits stay near the flag instead of dropping toward the body center.
- Kept ally portrait offset handling unchanged.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept HP bar, troop label, layer profile, auto battle, enemy AI, and facing-indicator timing unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## Completed
v0.67f-hotfix Enemy Facing Indicator Hide During Move

Completed items:
- Added `_hide_facing_indicator_for_unit()` in `scripts/battle_web_import_test.gd`.
- Hid the moving enemy actor's `FacingIndicator` at enemy move start so the old-position arrow does not linger during tween movement.
- Kept move-finish indicator restore on the existing `_update_facing_indicators()` path so the arrow reappears at the final position.
- Kept ally move / facing-selection UX unchanged.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept auto-battle policy and enemy AI actor/target selection unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## Completed
v0.67f Deployed/Active Slot Filtering

Completed items:
- Tightened active/deployed slot filtering in shared battle-participation helpers.
- Added `_is_unit_state_available_for_battle_slot()` and routed alive/actor/target adapter helpers through it.
- Clarified future reinforce exclusion policy for actor/target/occupied paths until deployed.
- Added one-time startup deployed/active filter snapshot.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept current battle execution, occupied-cell blocking, auto battle flow, and enemy AI actor order unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## Completed
v0.67e Actor/Target List Adapter Migration

Completed items:
- Added adapter-backed actor-candidate and target-candidate helpers.
- Switched auto-battle actor/target candidate reads to adapter-first with fallback.
- Switched enemy AI target-candidate read to adapter-first with fallback while preserving the same selection rule.
- Added one-time startup actor/target parity snapshot for counts and parity flags.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept current battle execution, auto battle flow, and enemy AI actor order unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## Completed
v0.67d 2v2 on Scalable Slot Framework

Completed items:
- Added adapter-first alive/deployed helper reads on top of the existing `BattleUnitState` list adapter.
- Kept legacy fixed-state helper bodies as fallback.
- Switched alive ally / enemy / all and enemy-target list helpers to adapter-first with fallback.
- Added one-time startup parity snapshot for adapter counts, fallback counts, active/deployed slot ids, and parity status.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept `scripts/unit_visual_slot.gd` unchanged.
- Kept current battle execution, enemy AI order, and auto battle flow unchanged.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## Completed
v0.67c BattleUnitState List Adapter

Completed items:
- Added ally/enemy/all `BattleUnitState` list adapters and state dictionaries in `scripts/battle_web_import_test.gd`.
- Added rebuild and lookup helpers for legacy-slot and capacity-slot state access.
- Rebuilt adapter references immediately after demo-state creation.
- Added one-time adapter debug snapshot with counts and mapping keys.
- Kept battle execution, enemy AI, auto battle, cleanup, and scene structure unchanged.
- Headless project launch and headless scene launch remained 0 errors.

## Completed
v0.67c-hotfix6 Unit Visual Layer Above HP Bar

Completed items:
- Added a runtime unit-visual layer profile with:
  - shadow `5`
  - hp bar `8`
  - token `12`
  - portrait `13`
  - troop label `20`
- Applied the layer profile at the end of each per-unit visual refresh path.
- Kept positions and scales unchanged.
- Kept HP bar alpha at `0.8` and troop label alpha at `1.0`.

## Completed
v0.67c-hotfix5 Keep HP Bar Alpha 80 Percent

Completed items:
- Set `HP_BAR_RUNTIME_ALPHA := 0.8`.
- Added HP bar alpha-only helpers and reapplied HP alpha after group modulate and per-unit visual refresh paths.
- Kept troop label alpha at `1.0`.
- Kept HP/troop position, scene layout, battle flow, enemy AI, auto battle, and battle dust unchanged.

## Completed
v0.67c-hotfix4 Restore HP Bar Alpha Only

Completed items:
- Added `HP_BAR_RUNTIME_ALPHA := 0.35` in `scripts/battle_web_import_test.gd`.
- Applied reduced alpha to HP bars only.
- Kept troop label alpha at `1.0`.
- Kept HP/troop position, battle flow, enemy AI, auto battle, battle dust, and scene layout unchanged.

## Completed
v0.67c-hotfix3 Restore HP/Troop Scene Layout After Slot Migration

Completed items:
- Confirmed HP/troop runtime values were valid and isolated the remaining issue to scene layout / draw order rather than missing refs.
- Restored HP/troop scene draw order by raising all 8 HP/troop nodes above the battlefield after slot migration.
- Removed runtime HP/troop position overwrites from the helper and limited runtime restore to value, text, visible, alpha, and z-index.
- Expanded startup HP/troop runtime summary to include token/hp/troop local-global position, z-index, and size data.
- Kept `2v2` battle execution, enemy AI, auto battle, battle dust, and `UnitCloseupPanel` behavior unchanged.

## Completed
v0.67c-hotfix2 Remove Remaining GDScript Warnings + Restore Runtime HP/Troop Visibility

Completed items:
- Removed remaining parent-block local redeclaration warnings in `_input()` and `_get_visual_group_nodes_for_unit()`.
- Replaced remaining mixed / typed ternary warning candidates in helper and debug paths with explicit branches.
- Added startup HP/troop runtime visibility summary with ref, visible, alpha, global position, size, text, and value data.
- Restored live-unit HP bar / troop label runtime state directly during per-unit visual refresh.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept current `2v2` battle execution, enemy AI, auto battle, battle dust, and `UnitCloseupPanel` behavior unchanged.

## Completed
v0.67c-hotfix State Adapter Warning Fix + HP/TroopLabel Restore

Completed items:
- Renamed local enemy click-hit variables to remove parent-block shadowing warnings.
- Replaced adapter helper ternary / implicit typed fallback return paths with explicit local typed result branches.
- Removed unsafe ally-default fallback from unit visual / click / anchor lookups when a unit-state mapping is missing.
- Reasserted HP bar and troop label visibility for live unit states during visual refresh.
- Added one-time startup visual-binding debug summary for the current 4 live units.
- Kept `Battle_Fullscreen_Test.tscn` unchanged.
- Kept current `2v2` battle execution, enemy AI, auto battle, battle dust, and `UnitCloseupPanel` behavior unchanged.

## Previously Completed
v0.67b Slot Registry Array Scaffold

Completed items:
- Added slot-registry scaffold constants and metadata helpers in `scripts/battle_web_import_test.gd`.
- Added full `20`-slot capacity-id scaffold without creating scene nodes or unit states.
- Added legacy `2v2` to capacity-slot mapping for the current `4` active slots.
- Added one-time capacity-registry debug snapshot at scene startup.
- Kept battle execution, enemy AI, auto battle, cleanup, and scene structure unchanged.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.67a Scalable Battle Slot Capacity Plan

Completed items:
- Added `agent/SCALABLE_BATTLE_SLOT_CAPACITY_PLAN.md`.
- Defined final target capacity as `7` main + `3` reinforce per side.
- Defined MVP target capacity as `3` main + `2` reinforce per side.
- Recommended mapping the current `2v2` support units to `main_02` rather than reinforcement slots.
- Documented slot metadata, registry direction, array-based state direction, deployment pipeline, formation guidance, risks, and QA.
- Kept code and scene files unchanged.

## Previously Completed
v0.66i Slot Tree QA Stable

Completed items:
- Revalidated the full 4-slot scene tree under `Slots`.
- Confirmed all 4 actual visual roots remain under their slot nodes.
- Confirmed all 4 ClickAreas remain under scene root.
- Confirmed ally READY frames and all FacingIndicators remain under `BattleUI`.
- Confirmed all 4 `UnitVisualSlot` cache entries report valid references at headless scene launch.
- Confirmed existing dictionary fallback helpers remain present.
- Kept code and scene files unchanged.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66h EnemySupportSlot Migration Stable

Completed items:
- Added `Slots/EnemySupportSlot` to `Battle_Fullscreen_Test.tscn`.
- Moved only `EnemySupportUnitVisualRoot` and its actual visual children under `EnemySupportSlot`.
- Kept ClickArea / FacingIndicator unmoved.
- Kept `AllyMainSlot` / `AllySupportSlot` / `EnemyMainSlot` structures intact.
- Updated enemy-support visual node paths in `scripts/battle_web_import_test.gd`.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66g EnemyMainSlot Migration Stable

Completed items:
- Added `Slots/EnemyMainSlot` to `Battle_Fullscreen_Test.tscn`.
- Moved only `EnemyUnitVisualRoot` and its actual visual children under `EnemyMainSlot`.
- Kept ClickArea / FacingIndicator unmoved.
- Kept `AllyMainSlot` / `AllySupportSlot` structures intact.
- Kept `enemy_support` scene paths unchanged.
- Updated enemy-main visual node paths in `scripts/battle_web_import_test.gd`.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66f AllySupportSlot Migration Stable

Completed items:
- Added `Slots/AllySupportSlot` to `Battle_Fullscreen_Test.tscn`.
- Moved only `AllySupportUnitVisualRoot` and its actual visual children under `AllySupportSlot`.
- Kept ClickArea / READY frame / FacingIndicator unmoved.
- Kept `AllyMainSlot` structure intact.
- Kept `enemy_main` and `enemy_support` scene paths unchanged.
- Updated ally-support visual node paths in `scripts/battle_web_import_test.gd`.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66e AllyMainSlot Migration Spike Stable

Completed items:
- Added `Slots/AllyMainSlot` to `Battle_Fullscreen_Test.tscn`.
- Moved only `AllyUnitVisualRoot` and its actual visual children under `AllyMainSlot`.
- Kept ClickArea / READY frame / FacingIndicator unmoved.
- Kept `ally_support`, `enemy_main`, and `enemy_support` scene paths unchanged.
- Updated ally-main visual node paths in `scripts/battle_web_import_test.gd`.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66d Scene Slot Tree Migration Plan

Completed items:
- Added `agent/SCENE_SLOT_TREE_MIGRATION_PLAN.md`.
- Documented current structure, target C-style structure, migration principles, risks, and QA.
- Explicitly separated Visual / World Interaction / UI Overlay migration concerns.
- Kept code and scene files unchanged.

## Previously Completed
v0.66c-3 Slot-Based Cleanup / Visibility QA Stable

Completed items:
- Rechecked cleanup / visibility helper paths around dead-unit handling and overlay visibility.
- Added narrow slot-backed visibility and click-enable helpers to `UnitVisualSlot`.
- Added null-guard hardening for slot-based getter helpers.
- Kept `Battle_Fullscreen_Test.tscn` unmodified.
- Kept ClickArea / READY frame / FacingIndicator parent structure unmodified.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66c-2 Ready/Facing/Click Slot Helper Expansion Stable

Completed items:
- Expanded `UnitVisualSlot` with slot-first UI / click getter helpers.
- Added slot-first click-shape helper in `scripts/battle_web_import_test.gd`.
- Updated READY / Facing / Click helper lookups to prefer `UnitVisualSlot` references.
- Added `_get_all_unit_states_in_slot_order()` for UI / visibility helper iteration only.
- Kept `Battle_Fullscreen_Test.tscn` unmodified.
- Kept ClickArea / READY frame / FacingIndicator parent structure unmodified.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66c-1 UnitVisualSlot Usage Expansion - Safe Helpers Stable

Completed items:
- Added safe read-only helper methods to `UnitVisualSlot`.
- Expanded slot-first usage into debug / visibility / cleanup getter paths only.
- Preserved existing group node functions and direct fallback behavior.
- Kept `Battle_Fullscreen_Test.tscn` unmodified.
- Kept ClickArea / READY frame / FacingIndicator parent structure unmodified.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66b UnitVisualSlot Lookup Integration Stable

Completed items:
- Added cache-first `UnitVisualSlot` lookup helpers with safe fallback ordering.
- Preserved all existing `_get_*_visual_slots()` dictionary functions.
- Added dictionary bridge support through `UnitVisualSlot.to_visual_slots_dictionary()`.
- Kept the 4-slot cache limited to:
  - `ally_main`
  - `ally_support`
  - `enemy_main`
  - `enemy_support`
- Kept `Battle_Fullscreen_Test.tscn` unmodified.
- Kept ClickArea code and parent structure unmodified.
- Kept READY frame / FacingIndicator parent structure unmodified.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.66a UnitVisualSlot Scaffold Stable

Completed items:
- Added `scripts/unit_visual_slot.gd`.
- Added `UnitVisualSlot` as a `RefCounted` reference adapter.
- Added 4-slot cache preparation in `scripts/battle_web_import_test.gd`.
- Preserved existing dictionary slot functions.
- Kept scene tree structure unchanged.
- Headless project launch remained 0 errors.

## Previously Completed
v0.65k-2 Dust Source Isolation + Stale Dust Cleanup Hotfix

Completed items:
- Kept movement dust helper functions unchanged.
- Disabled attack battle dust and kept only hit battle dust.
- Lowered hit battle dust opacity, scale, duration, and world layer again.
- Added stale move-dust cleanup before attack start and after ally attack finish.
- Kept `Battle_Fullscreen_Test.tscn` unmodified.
- Kept ClickArea code unmodified.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.65k-1 Battle Dust Layer + Density Hotfix

Completed items:
- Kept movement dust logic untouched.
- Lowered battle dust world layer with `z_as_relative = false`.
- Reduced battle dust opacity, scale, and duration.
- Reduced attack-dust density separately from hit-dust density.
- Lowered attack / hit dust spawn positions toward foot-level.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify ClickArea code.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.65k Battle Dust FX Profile Tuning

Completed items:
- Kept movement dust logic and movement dust visuals unchanged.
- Added separate battle-dust FX tuning for attack and hit moments only.
- Reused existing dust textures without reusing the movement-dust template profile.
- Lowered battle dust opacity and added beige / dirt tint.
- Kept battle dust lower on the unit footprint and behind slash / hit spark FX.
- Preserved attack slash / hit spark / damage number flow.
- Did not modify `Battle_Fullscreen_Test.tscn`.
- Did not modify ClickArea code.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.65j-5a Auto Battle Stop UX Hotfix

Completed items:
- Kept `AutoBattleButton` clickable while full auto battle is ON.
- Kept runtime button control limited to text and disabled state only.
- Routed user stop through `_stop_full_auto_battle("user stop")`.
- Preserved soft stop behavior so current action is not force-killed.
- Kept deferred auto ticks harmless after stop through existing top-level enabled guard.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.65j-5 Full Auto Battle Loop Prototype

Completed items:
- Added ON/OFF full auto battle prototype state.
- Added deferred single-step auto battle ticking.
- Added loop safety guard with `AUTO_BATTLE_MAX_STEPS`.
- Reused existing ally auto one-action flow and existing enemy AI flow.
- Added full auto stop conditions and toggle helpers.
- Preserved manual command buttons and manual control paths.
- Headless project launch and headless scene launch remained 0 errors.

## Previously Completed
v0.65j-4 Auto Battle Button Hook

Completed items:
- Added `AutoBattleButton` to `BattleUI/CommandBar`.
- Connected button press to `_run_auto_action_for_active_ally_once()`.
- Added auto-battle button enabled/disabled control to `_set_phase()`.
- Kept the button scoped to one active ally auto action only.
- Kept the full auto battle loop unimplemented.
- Preserved existing manual command buttons.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65j-3a Auto Move + Auto Facing Completion

Completed items:
- Extended `_try_auto_move_for_active_ally()` to start actual movement through the existing move demo path.
- Added auto-action flags for auto move/facing flow separation.
- Added nearest-enemy auto facing selection after move.
- Auto move no longer stops at facing-select wait state during auto flow.
- Preserved manual move + facing UX for non-auto flow.
- Kept the implementation disconnected from any auto battle button.
- Kept the implementation disconnected from any full auto loop.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65j-3 Ally Auto Battle One-Action MVP

Completed items:
- Added `_run_auto_action_for_active_ally_once()`.
- Added `_try_auto_attack_for_active_ally()`.
- Added `_try_auto_move_for_active_ally()`.
- Added `_auto_wait_active_ally()`.
- Connected auto attack MVP to the existing ally basic attack flow.
- Kept auto move at candidate-selection-only level for safety.
- Kept auto wait at scaffold level.
- Kept the new MVP disconnected from any button or full auto loop.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65j-2 Auto Battle Helper Functions Scaffold

Completed items:
- Added auto battle helper scaffold functions to `scripts/battle_web_import_test.gd`.
- Added actionable-unit and living-target side helpers.
- Added demo-damage-based auto kill helper.
- Added score-based auto attack target helper.
- Added best auto attack target helper.
- Added best auto move cell scaffold helper.
- Added optional auto policy debug snapshot helper.
- Kept helper functions disconnected from existing battle execution flow.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65j-1 Auto Battle Action Policy Design

Completed items:
- Added `agent/AUTO_BATTLE_ACTION_POLICY.md`.
- Defined shared auto action purpose and core flow.
- Defined draft target priority policy.
- Defined draft movement destination priority policy.
- Documented current reusable function candidates for future implementation.
- Kept this step documentation-only with no code/scene changes.

## Earlier Completed
v0.65i-3 READY/Facing UI Slot Registry Cleanup

Completed items:
- Kept `AllyReadyFrame` / `AllySupportReadyFrame` under `BattleUI`.
- Kept all 4 `FacingIndicator` labels under `BattleUI`.
- Preserved `ready_frame` / `facing_indicator` entries in the slot visual dictionaries.
- Connected READY/Facing refresh through slot-based visual slot lookup helpers.
- Preserved `_position_ready_frame_for_unit()` flow.
- Preserved `_position_facing_indicator_for_*()` flows.
- Preserved `_world_to_battle_ui_position()` UI conversion flow.
- Did not modify ClickArea code path.
- Headless project launch and headless scene launch remained 0 errors.

## Earlier Completed
v0.65h Slot-Based UnitVisual Architecture Design

Completed items:
- `BattleUnitState` has slot-based metadata.
- Four demo units carry slot metadata.
- UnitVisual slot lookup prioritizes `unit_state.slot_id`.
- Direct `unit_state` comparison fallback remains.
- No ClickArea / READY / FacingIndicator migration was done.
- No combat formula, turn flow, AI order, or visual node movement changed.

## Priority 4
Debug cleanup

Review and decide whether to remove:
- `_debug_print_unit_visual_root_slots()`
- `[ATTACK_CLICK]` print
- `_debug_print_ally_portrait_offsets()` if no longer needed

## Priority 5
v0.65i-2 ClickArea Root Migration Spike

Goal:
- Test whether ClickArea can move closer to slot-root ownership without breaking collision/input coordinates.
- Keep this isolated from auto battle and from combat logic changes.

## Ongoing QA Checklist
- Battle starts with BATTLE 1 toast.
- 2v2 loop remains stable.
- Active ally lock remains stable.
- Move dust appears only during movement.
- Attack slash / hit spark / damage number remain stable.
- UnitCloseupPanel remains stable.
- READY frame remains stable.
- HP 0 cleanup remains stable.
- Ally portrait up/down positions remain stable.
- Guan Yu death does not block Zhang Fei target selection.
- Headless launch remains 0 errors.
