# NEXT TASKS

## Current Stable Baseline
v0.66i Slot Tree QA Stable

## Priority 1
v0.67b Slot Registry Array Scaffold

Goal:
- Add slot-id list and slot metadata scaffold for the current stable slots.
- Register the current `4` slots in an array/registry form.
- Keep existing `2v2` battle behavior unchanged.

## Priority 2
v0.67 Slot Count Expansion Plan

Goal:
- Use the documented `7 + 3` final capacity and `3 + 2` MVP direction as the planning baseline.
- Keep the next implementation steps aligned with registry-first migration rather than direct slot-count expansion.

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
