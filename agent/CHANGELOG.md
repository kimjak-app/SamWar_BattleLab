# CHANGELOG

## v0.66c-1 UnitVisualSlot Usage Expansion - Safe Helpers

- Expanded `UnitVisualSlot` safe read-only helpers in `scripts/unit_visual_slot.gd`.
- Added:
  - `get_visual_group_nodes()`
  - `has_required_visual_nodes()`
  - `get_debug_summary()`
- Updated safe helper paths in `scripts/battle_web_import_test.gd`:
  - `_debug_print_unit_visual_root_slots()`
  - `_get_visual_group_nodes_for_unit()`
  - `_get_click_area_for_unit()`
  - `_get_facing_indicator_for_unit()`
- Kept these functions slot-first with existing direct-comparison fallback still present.
- Preserved:
  - `_get_ally_group_nodes()`
  - `_get_ally_support_group_nodes()`
  - `_get_enemy_group_nodes()`
  - `_get_enemy_support_group_nodes()`
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea parent structure
  - READY frame parent structure
  - FacingIndicator parent structure
  - auto battle logic
  - enemy AI flow
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.66b UnitVisualSlot Lookup Integration

- Integrated cache-first `UnitVisualSlot` lookup helpers into `scripts/battle_web_import_test.gd`.
- Added:
  - `_get_unit_visual_slot_for_slot_id()`
  - `_get_unit_visual_slot_for_state()`
  - `_has_unit_visual_slot_for_state()`
  - `_create_unit_visual_slot_from_dictionary()`
  - `_get_visual_slots_dictionary_fallback_for_slot_id()`
- Updated `_get_unit_visual_slots_for_state()` so it first bridges through `UnitVisualSlot` and then preserves existing direct dictionary fallback behavior.
- Updated `_get_visual_slots_for_slot_id()` so it first resolves a `UnitVisualSlot` and returns a legacy-compatible dictionary view when available.
- Updated `_rebuild_unit_visual_slot_refs()` so cache rebuild uses explicit dictionary fallback instead of recursively going through the public lookup wrapper.
- Added `to_visual_slots_dictionary()` to `scripts/unit_visual_slot.gd` and kept `to_dictionary()` as a compatibility alias.
- Expanded `_debug_print_unit_visual_root_slots()` to include minimal cache-state output:
  - cache presence
  - root
  - token
  - click area
  - ready frame
  - facing indicator
  - dictionary fallback presence
- Preserved:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea parent structure
  - READY frame parent structure
  - FacingIndicator parent structure
  - existing `_get_*_visual_slots()` dictionary functions
  - 2v2 manual battle loop
  - auto battle logic
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65k-2 Dust Source Isolation + Stale Dust Cleanup Hotfix

- Isolated battle dust further and reduced stale move-dust carryover in `scripts/battle_web_import_test.gd`.
- Large white dust recurrence was traced to:
  - stale `MoveDustSprite` visibility surviving into attack timing
  - battle dust density still being strong enough to resemble white cloud buildup across repeated turns
- Updated battle dust constants:
  - `BATTLE_DUST_ALPHA_MIN := 0.10`
  - `BATTLE_DUST_ALPHA_MAX := 0.22`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MIN := 0.30`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MAX := 0.48`
  - `BATTLE_DUST_DURATION_MIN := 0.10`
  - `BATTLE_DUST_DURATION_MAX := 0.18`
  - `BATTLE_DUST_TINT := Color(0.48, 0.38, 0.24, 1.0)`
  - `BATTLE_DUST_WORLD_Z_INDEX := 2`
- Disabled attack battle dust by turning `_spawn_attack_battle_dust_fx()` into a no-op.
- Kept only hit battle dust as the remaining battle-dust cue.
- Added `_hide_all_move_dust_sprites()` cleanup:
  - before ally attack demo start
  - before enemy basic attack start
  - after ally basic attack finish
- Battle dust still uses only battle-dust-specific constants and still `queue_free()`s at tween end.
- Existing movement dust helper functions were not modified.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - auto battle logic
  - `AutoBattleButton` runtime geometry
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65k-1 Battle Dust Layer + Density Hotfix

- Reduced battle dust density and lowered its render layer in `scripts/battle_web_import_test.gd`.
- Updated battle dust constants:
  - `BATTLE_DUST_ALPHA_MIN := 0.18`
  - `BATTLE_DUST_ALPHA_MAX := 0.32`
  - `BATTLE_DUST_ATTACK_ALPHA_MIN := 0.12`
  - `BATTLE_DUST_ATTACK_ALPHA_MAX := 0.22`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MIN := 0.45`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MAX := 0.65`
  - `BATTLE_DUST_ATTACK_SCALE_MULTIPLIER_MIN := 0.35`
  - `BATTLE_DUST_ATTACK_SCALE_MULTIPLIER_MAX := 0.5`
  - `BATTLE_DUST_DURATION_MIN := 0.14`
  - `BATTLE_DUST_DURATION_MAX := 0.26`
  - `BATTLE_DUST_TINT := Color(0.62, 0.50, 0.34, 1.0)`
- Battle dust now forces `z_as_relative = false` and uses lower world `z_index`.
- Attack dust now spawns weaker and lower near the attacker foot area.
- Hit dust now spawns lower near the target foot area and remains the main visible dust cue.
- Existing movement dust helper functions were not modified.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - auto battle logic
  - `AutoBattleButton` runtime geometry
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65k Battle Dust FX Profile Tuning

- Added battle-dust-only tuning to `scripts/battle_web_import_test.gd`.
- Added:
  - `BATTLE_DUST_ALPHA_MIN`
  - `BATTLE_DUST_ALPHA_MAX`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MIN`
  - `BATTLE_DUST_SCALE_MULTIPLIER_MAX`
  - `BATTLE_DUST_DURATION_MIN`
  - `BATTLE_DUST_DURATION_MAX`
  - `BATTLE_DUST_TINT`
  - `_spawn_attack_battle_dust_fx()`
  - `_spawn_hit_battle_dust_fx()`
  - `_spawn_battle_dust_fx()`
- Attack and hit dust now use a beige / dirt-tinted lower-opacity profile instead of bright white-looking dust.
- Battle dust now spawns lower on the unit footprint and behind slash / hit spark FX.
- Existing movement dust path was preserved.
- Existing attack slash / hit spark / damage number flow was preserved.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - auto battle loop logic
  - `AutoBattleButton` runtime geometry
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-5a Auto Battle Stop UX Hotfix

- Updated `_refresh_auto_battle_button_state()` so `AutoBattleButton` stays enabled while full auto battle is ON.
- Full auto ON state now forces button text to `자동중지` and leaves the button clickable during enemy/resolving phases.
- Updated `_toggle_full_auto_battle()` so a user button press during auto battle routes through `_stop_full_auto_battle("user stop")`.
- Kept stop behavior soft:
  - current action tween is not force-killed
  - current enemy AI action is not force-killed
  - deferred auto ticks return immediately once auto battle is OFF
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - `AutoBattleButton` position/offset/size at runtime
  - ClickArea code
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Did not add a direct `while` loop for auto battle flow.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-5 Full Auto Battle Loop Prototype

- Added full auto battle prototype state to `scripts/battle_web_import_test.gd`.
- Added:
  - `AUTO_BATTLE_MAX_STEPS`
  - `is_full_auto_battle_enabled`
  - `auto_battle_step_count`
  - `_toggle_full_auto_battle()`
  - `_set_full_auto_battle_enabled()`
  - `_tick_full_auto_battle_if_needed()`
  - `_stop_full_auto_battle()`
  - `_refresh_auto_battle_button_state()`
- `AutoBattleButton` now toggles full auto battle ON/OFF instead of firing a single one-action step directly.
- Full auto loop uses `call_deferred()` for step progression.
- Direct `while` loop was not added for auto battle flow.
- Added step-limit safety guard with `AUTO_BATTLE_MAX_STEPS`.
- Reused existing ally auto action path and existing enemy AI turn flow.
- Kept `AutoBattleButton` runtime behavior limited to text/disabled state updates only.
- Did not modify:
  - `AutoBattleButton` position/offset/size at runtime
  - ClickArea code
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-4 Auto Battle Button Hook

- Added `AutoBattleButton` under `BattleUI/CommandBar`.
- Adjusted `CommandBarLabel` text so the new button does not conflict with the static label text.
- Added `@onready` lookup for `AutoBattleButton` in `scripts/battle_web_import_test.gd`.
- Connected `auto_battle_button.pressed` to `_run_auto_action_for_active_ally_once()`.
- Added `AutoBattleButton` enable/disable handling in `_set_phase()`.
- Button scope is limited to one active ally auto action.
- Full auto battle loop is still not implemented.
- Preserved existing manual command buttons and their behavior.
- Did not modify ClickArea code.
- Did not modify:
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-3a Auto Move + Auto Facing Completion

- Extended ally auto action MVP to complete movement execution and post-move facing automatically.
- `_try_auto_move_for_active_ally()` now starts real ally movement through the existing `play_basic_move_demo()` path when a valid auto move cell exists.
- Added auto-action flow flags:
  - `is_auto_action_in_progress`
  - `should_auto_select_facing_after_move`
- Added:
  - `_clear_auto_action_flags()`
  - `_get_best_auto_facing_toward_nearest_enemy()`
  - `_select_auto_facing_after_move_for_active_ally()`
- `_finish_basic_move_demo()` now auto-completes facing only for auto-move flow.
- Manual post-move facing selection flow was preserved for non-auto movement.
- Auto facing points toward the nearest living enemy and preserves current facing if no enemy exists.
- Auto battle button still not connected.
- Full auto battle loop still not implemented.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-3 Ally Auto Battle One-Action MVP

- Added ally auto one-action MVP functions to `scripts/battle_web_import_test.gd`.
- Added:
  - `_run_auto_action_for_active_ally_once()`
  - `_try_auto_attack_for_active_ally()`
  - `_try_auto_move_for_active_ally()`
  - `_auto_wait_active_ally()`
- Auto attack MVP now resolves the best attackable target for the current active ally and starts the existing ally attack flow.
- Auto move MVP is intentionally limited to move target selection and validation only.
- Auto move execution and automatic facing completion were deferred to a follow-up step.
- Auto wait remains scaffold-level and is not connected to ally turn completion yet.
- Did not add an auto battle button.
- Did not add a full auto battle loop.
- Did not modify:
  - `Battle_Fullscreen_Test.tscn`
  - ClickArea code
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-2 Auto Battle Helper Functions Scaffold

- Added auto battle helper scaffold functions to `scripts/battle_web_import_test.gd`.
- Added:
  - `_get_available_auto_units_for_side()`
  - `_get_alive_auto_targets_for_side()`
  - `_can_auto_kill_target()`
  - `_score_auto_attack_target()`
  - `_find_best_auto_attack_target()`
  - `_find_best_auto_move_cell()`
  - `_debug_print_auto_battle_policy_snapshot()`
- Added internal auto helper support functions:
  - `_get_auto_damage_for_actor()`
  - `_get_auto_slot_priority()`
  - `_get_auto_move_path_for_actor()`
- Kept the new helpers disconnected from current battle execution flow.
- Did not modify:
  - `_play_enemy_ai_for_actor()`
  - `_get_enemy_ai_target_state_for_actor()`
  - current manual ally control flow
- Did not modify ClickArea code.
- Did not modify scene files.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65j-1 Auto Battle Action Policy Design

- Added `agent/AUTO_BATTLE_ACTION_POLICY.md`.
- Defined auto battle as a data-based action policy using:
  - `BattleUnitState`
  - `grid_cell`
  - `attack_range`
  - `hp`
  - `side`
  - `has_acted`
- Explicitly separated auto battle policy from click overlap and `ClickArea` logic.
- Documented the expected one-action auto battle flow:
  - actor selection
  - living enemy list
  - immediate attack check
  - target priority selection
  - movement destination selection
  - post-move attack or wait
  - action completion
- Documented draft target priority order:
  - killable target
  - currently attackable target
  - lower HP target
  - closer target
  - main slot priority
  - stable array order fallback
- Documented draft movement priority order:
  - move to attackable cell
  - reduce distance
  - avoid occupied cells
  - keep path clear
  - prefer better follow-up attack potential
  - wait if no useful move exists
- Documented reusable current implementation candidates from `battle_web_import_test.gd`.
- Did not modify code or scene files.

## v0.65i-3 READY/Facing UI Slot Registry Cleanup

- Kept `READY frame` nodes under `BattleUI`.
- Kept `FacingIndicator` nodes under `BattleUI`.
- Kept `ready_frame` / `facing_indicator` entries in:
  - `_get_ally_main_visual_slots()`
  - `_get_ally_support_visual_slots()`
  - `_get_enemy_main_visual_slots()`
  - `_get_enemy_support_visual_slots()`
- Added slot-based helper lookup for READY frame resolution.
- Switched READY frame refresh to resolve slot UI through slot lookup instead of direct node pairing.
- Added slot-based helper lookup for FacingIndicator resolution.
- Switched FacingIndicator refresh to resolve slot UI through slot lookup while preserving the existing per-slot position functions.
- Added shared visual-anchor helper with `slot_id` first dispatch and existing direct comparison fallback.
- Preserved:
  - `_position_ready_frame_for_unit()`
  - `_position_facing_indicator_for_ally()`
  - `_position_facing_indicator_for_ally_support()`
  - `_position_facing_indicator_for_enemy()`
  - `_position_facing_indicator_for_enemy_support()`
  - `_world_to_battle_ui_position()`
- Did not move any scene nodes.
- Did not modify ClickArea code.
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.

## v0.65h Slot-Based UnitVisual Architecture Design Stable

- Extended BattleUnitState with slot-based metadata.
- Added fields:
  - slot_id
  - nation
  - portrait_key
  - domain
  - footprint
  - move_fx_profile
  - attack_fx_profile
  - click_area_profile
  - visual_scale_profile
- Injected slot metadata into the four current demo units.
- Added slot_id-first UnitVisual slot lookup.
- Preserved direct unit_state comparison fallback.
- Confirmed visual_key values remain unchanged:
  - korea_archer
  - korea_gunner
  - china_cavalry
  - china_infantry
- Preserved current 2v2 battle loop, FX, UnitCloseupPanel, READY frame, HP 0 cleanup, active ally lock.
- Did not migrate ClickArea / READY frame / FacingIndicator.

## v0.65g Root Migration Stable QA Verified

- Added UnitVisualRoot Adapter Layer.
- Migrated Ally main visual nodes under AllyUnitVisualRoot.
- Migrated Ally support visual nodes under AllySupportUnitVisualRoot.
- Migrated Enemy main visual nodes under EnemyUnitVisualRoot.
- Migrated Enemy support visual nodes under EnemySupportUnitVisualRoot.
- Kept ClickArea / READY frame / FacingIndicator outside Root for safety.
- Kept UnitVisualTemplate nodes as layout offset references.
- Fixed ally portrait FACING_UP / FACING_DOWN offset issue.
- Fixed dead enemy main click priority blocking enemy support target selection.
- Verified 2v2 battle loop, FX, UnitCloseupPanel, HP 0 cleanup, active ally lock.
- Prepared direction for future slot-based UnitVisual architecture.

## v0.65e Unit Token Asset Normalize Apply Verified

- Normalized Korea/China/Japan infantry/archer/gunner/cavalry tokens to 256 baseline.
- Added country/type based visual_key mapping.
- Updated test units:
  - Yi Sun-sin = korea_archer
  - Jeong Do-jeon = korea_gunner
  - Guan Yu = china_cavalry
  - Zhang Fei = china_infantry
- Removed dependency on legacy 1024 China infantry for current test units.
- Preserved FX Pack 1, Round Toast, idle breathing, turn flow, active ally lock, and cleanup.
