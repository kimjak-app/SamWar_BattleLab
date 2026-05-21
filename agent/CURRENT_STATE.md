# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.66c-2 Ready/Facing/Click Slot Helper Expansion Stable

## Main Scene
`Battle_Fullscreen_Test.tscn`

Attached scripts:
- `scripts/battle_web_import_test.gd`
- `scripts/battle_unit_state.gd`
- `scripts/unit_visual_slot.gd`

This is the current stable 2v2 Godot battle verification scene.

## Engine / Layout Baseline
- Godot 4 based SamWar battle engine port and visual experiment.
- 1920x1080 fullscreen battle board on `Battle_Fullscreen_Test.tscn`.
- 18x10 logical grid maintained.
- Scene controls layout.
- Code controls behavior.

## Current Battle Setup
- Ally: 이순신, 정도전
- Enemy: 관우, 장비

Current visual test assignment:
- 이순신 = `korea_archer`
- 정도전 = `korea_gunner`
- 관우 = `china_cavalry`
- 장비 = `china_infantry`

## Current Battle Flow
1. One ally actor acts.
2. One enemy AI actor acts.
3. Next available ally actor acts.
4. Next enemy AI actor acts.
5. New round starts.

Verified principle:
아군 1부대 행동 -> 적 1부대 AI 행동 -> 다음 아군 1부대 행동.

## Current Working Features
- 2v2 battle loop works.
- BATTLE 1 / BATTLE 2 Round Toast works.
- Basic Battle FX Pack 1 works:
  - move dust
  - attack slash
  - hit spark
  - damage number
- Move dust appears only during movement.
- Idle breathing works.
- READY frame works.
- UnitCloseupPanel works.
- Active ally lock works.
- Right-click move rollback works.
- Right-click attack cancel works.
- HP 0 cleanup works.
- Headless scene launch has been kept at 0 errors.

## v0.66a UnitVisualSlot Scaffold State
- Added `scripts/unit_visual_slot.gd`.
- `UnitVisualSlot` is a `RefCounted` reference adapter only.
- Prepared cached slot references for:
  - `ally_main`
  - `ally_support`
  - `enemy_main`
  - `enemy_support`
- Existing `_get_*_visual_slots()` dictionary functions were preserved.
- No scene-tree migration was done.
- ClickArea / READY frame / FacingIndicator parent structure was preserved.
- Existing 2v2 manual battle loop and full auto battle flow were preserved.

## v0.66b UnitVisualSlot Lookup Integration State
- Added cache-first lookup helpers for `UnitVisualSlot` references.
- `UnitVisualSlot` lookup now uses:
  - `unit_state.slot_id` first
  - direct `unit_state` comparison fallback second
  - dictionary-backed slot adapter fallback when cache entry is missing
- Existing dictionary-returning functions were preserved:
  - `_get_ally_main_visual_slots()`
  - `_get_ally_support_visual_slots()`
  - `_get_enemy_main_visual_slots()`
  - `_get_enemy_support_visual_slots()`
  - `_get_visual_slots_for_slot_id()`
  - `_get_unit_visual_slots_for_state()`
- Dictionary-returning lookups now safely bridge through `UnitVisualSlot.to_visual_slots_dictionary()` when a slot adapter is available.
- Added `to_visual_slots_dictionary()` to keep legacy key names stable:
  - `root`
  - `token`
  - `shadow`
  - `portrait`
  - `hp_bar`
  - `troop_label`
  - `move_dust`
  - `click_area`
  - `click_shape`
  - `ready_frame`
  - `facing_indicator`
- Slot cache rebuild still prepares the 4 current combat slots only.
- No combat formula, turn flow, AI order, auto battle logic, or scene tree structure was intentionally changed.
- `Battle_Fullscreen_Test.tscn` remained unmodified.
- ClickArea / READY frame / FacingIndicator parent structure remained unchanged.

## v0.66c-1 UnitVisualSlot Usage Expansion - Safe Helpers State
- Expanded `UnitVisualSlot` with safe read-only helpers:
  - `get_visual_group_nodes()`
  - `has_required_visual_nodes()`
  - `get_debug_summary()`
- Kept `UnitVisualSlot` as a `RefCounted` reference adapter only.
- Expanded slot-first usage only in safe helper paths:
  - `_debug_print_unit_visual_root_slots()`
  - `_get_visual_group_nodes_for_unit()`
  - `_get_click_area_for_unit()`
  - `_get_facing_indicator_for_unit()`
- Existing direct comparison fallback remains in those helpers when slot lookup is unavailable.
- Existing group node functions remain preserved:
  - `_get_ally_group_nodes()`
  - `_get_ally_support_group_nodes()`
  - `_get_enemy_group_nodes()`
  - `_get_enemy_support_group_nodes()`
- Cleanup and visibility flow still uses the same public helpers:
  - `_cleanup_dead_units()`
  - `_set_unit_visual_group_visible()`
  - `_set_unit_click_area_enabled()`
- No combat formula, turn flow, enemy AI flow, auto battle logic, or scene structure was intentionally changed.
- `Battle_Fullscreen_Test.tscn` remained unmodified.
- ClickArea / READY frame / FacingIndicator parent structure remained unchanged.

## v0.66c-2 Ready/Facing/Click Slot Helper Expansion State
- Expanded `UnitVisualSlot` with slot-first UI / click getters:
  - `get_click_area()`
  - `get_click_shape()`
  - `get_ready_frame()`
  - `get_facing_indicator()`
  - `has_click_nodes()`
  - `has_ui_overlay_nodes()`
- Added `_get_click_shape_for_unit()` in `scripts/battle_web_import_test.gd`.
- Expanded slot-first helper usage for:
  - `_get_ready_frame_for_unit()`
  - `_update_ally_ready_frames()`
  - `_get_facing_indicator_for_unit()`
  - `_update_facing_indicators()`
  - `_set_facing_indicators_visible()`
  - `_get_click_area_for_unit()`
- Added `_get_all_unit_states_in_slot_order()` for UI / visibility helper iteration only.
- Existing direct comparison fallback remains for READY / Facing / Click helpers when slot lookup is unavailable.
- Existing world-to-`BattleUI` coordinate flow remains unchanged.
- Existing per-slot facing-indicator position functions remain preserved.
- ClickArea remains under scene root.
- READY frame and FacingIndicator remain under `BattleUI`.
- No combat formula, turn flow, enemy AI, auto battle, or battle-dust logic was intentionally changed.
- `Battle_Fullscreen_Test.tscn` remained unmodified.

## v0.65g Completed Structure
- UnitVisualRoot Adapter Layer is in place.
- Ally main visual nodes are under `AllySide/AllyUnitVisualRoot`.
- Ally support visual nodes are under `AllySide/AllySupportUnitVisualRoot`.
- Enemy main visual nodes are under `EnemySide/EnemyUnitVisualRoot`.
- Enemy support visual nodes are under `EnemySide/EnemySupportUnitVisualRoot`.
- Actual visual nodes for all 4 combat slots are now grouped under their UnitVisualRoot.
- ClickArea / READY frame / FacingIndicator / UnitVisualTemplate nodes remain separate for safety.
- UnitVisualTemplate nodes remain as layout offset references.

## v0.65g Fixes
- Ally portrait `FACING_UP` / `FACING_DOWN` offset issue fixed.
- Dead enemy main click priority issue fixed.
- After Guan Yu dies, Yi Sun-sin and Jeong Do-jeon can attack living Zhang Fei.
- Enemy support AI remained valid after enemy main death.

## v0.65h Slot Metadata State
- `BattleUnitState` now includes slot-based metadata:
  - `slot_id`
  - `nation`
  - `portrait_key`
  - `domain`
  - `footprint`
  - `move_fx_profile`
  - `attack_fx_profile`
  - `click_area_profile`
  - `visual_scale_profile`
- Current demo units carry slot metadata:
  - Yi Sun-sin = `ally_main` / `korea` / `land` / `1x1` / `arrow`
  - Jeong Do-jeon = `ally_support` / `korea` / `land` / `1x1` / `gun`
  - Guan Yu = `enemy_main` / `china` / `land` / `1x1` / `slash`
  - Zhang Fei = `enemy_support` / `china` / `land` / `1x1` / `slash`
- Unit visual slot lookup now prioritizes `unit_state.slot_id`.
- Existing direct `unit_state` comparison fallback remains.
- No combat formula, turn flow, AI order, or visual node movement changed in v0.65h.

## v0.65i-3 READY/Facing UI Slot Registry State
- `READY frame` and `FacingIndicator` remain under `BattleUI`.
- No `BattleUI` node migration was done.
- No `UnitVisualRoot` parent change was done.
- Existing visual slot dictionaries still include:
  - `ready_frame`
  - `facing_indicator`
- READY frame refresh now resolves slot UI through slot-based visual slot lookup.
- FacingIndicator refresh now resolves slot UI through slot-based visual slot lookup.
- Existing direct `unit_state` comparison fallback remains for anchor/position dispatch safety.
- `_position_ready_frame_for_unit()` flow is preserved.
- `_position_facing_indicator_for_ally*()` / `_position_facing_indicator_for_enemy*()` flows are preserved.
- `_world_to_battle_ui_position()` based UI coordinate conversion is preserved.
- ClickArea code path was not modified in v0.65i-3.
- No combat formula, turn flow, AI order, or HP cleanup behavior was intentionally changed.

## v0.65j-1 Auto Battle Policy State
- Added `agent/AUTO_BATTLE_ACTION_POLICY.md`.
- This step defines a data-based auto action policy only.
- No auto battle button was added.
- No combat script logic was changed.
- No scene node was changed.
- Auto battle direction is defined around:
  - actionable unit selection
  - living enemy list construction
  - in-range attack check
  - target priority scoring
  - movement destination scoring
  - move-then-attack or wait decision
- Auto battle is explicitly defined to use battle data and grid rules, not `ClickArea`.
- Existing reusable function candidates are documented for later implementation scaffolding.

## v0.65j-2 Auto Battle Helper Scaffold State
- Added auto battle helper scaffold functions to `scripts/battle_web_import_test.gd`.
- Added side-based actionable unit helper.
- Added side-based living target helper.
- Added demo-damage-based kill-check helper.
- Added score-based auto attack target helper.
- Added best auto attack target helper.
- Added best auto move cell scaffold helper.
- Added optional auto policy debug snapshot helper.
- Existing enemy AI flow was not rewired to use these helpers yet.
- Existing ally manual flow was not rewired to use these helpers yet.
- `_play_enemy_ai_for_actor()` flow was preserved.
- `_get_enemy_ai_target_state_for_actor()` flow was preserved.
- No auto battle button was added.
- No scene node was changed.
- No ClickArea code was changed.

## v0.65j-3 Ally Auto Battle One-Action MVP State
- Added `_run_auto_action_for_active_ally_once()`.
- Added `_try_auto_attack_for_active_ally()`.
- Added `_try_auto_move_for_active_ally()`.
- Added `_auto_wait_active_ally()`.
- Auto attack can now resolve a best in-range target and start the existing ally attack flow.
- Auto move is currently limited to move-candidate selection only.
- Auto move does not execute actual movement yet in this step.
- Auto facing completion after move is not implemented in this step.
- Auto wait is scaffold-level only and is not wired to end the ally turn.
- Auto battle button is still not connected.
- Full auto battle loop is still not implemented.
- Existing manual battle flow was preserved.
- Existing enemy AI flow was preserved.
- ClickArea code was not modified.
- No scene node was changed.

## v0.65j-3a Auto Move + Auto Facing State
- Auto move now reuses the existing `play_basic_move_demo()` execution path.
- Auto move sets a move target and starts real ally movement when a valid best move cell exists.
- Added auto-action flags to distinguish auto move/facing from manual move/facing flow.
- Auto move now auto-completes post-move facing instead of stopping at `PHASE_FACING_SELECT`.
- Auto facing chooses the nearest living enemy direction using existing facing constants.
- If no living enemy exists, current facing is preserved.
- Manual post-move facing UX remains in place for non-auto movement.
- Auto battle button is still not connected.
- Full auto battle loop is still not implemented.
- Existing enemy AI flow was preserved.
- ClickArea code was not modified.
- No scene node was changed.

## v0.65j-4 Auto Battle Button State
- Added `AutoBattleButton` under `BattleUI/CommandBar`.
- Added `@onready` lookup for `AutoBattleButton`.
- Connected `auto_battle_button.pressed` to `_run_auto_action_for_active_ally_once()`.
- Auto battle button currently triggers one active ally auto action only.
- Full auto battle loop is still not implemented.
- Existing manual buttons remain in place:
  - `BasicAttackButton`
  - `MoveButton`
  - `WaitButton`
  - `EndTurnButton`
- Auto battle button enable/disable state is now tied to ally-command availability inside `_set_phase()`.
- Existing enemy AI flow was preserved.
- ClickArea code was not modified.
- Scene change was limited to the `CommandBar` button addition and label text cleanup.

## v0.65j-5 Full Auto Battle Loop Prototype State
- Added full auto battle prototype flags:
  - `is_full_auto_battle_enabled`
  - `auto_battle_step_count`
  - `AUTO_BATTLE_MAX_STEPS`
- `AutoBattleButton` now toggles full auto battle ON/OFF.
- Auto battle loop is driven through deferred single-step execution, not direct blocking iteration.
- Current trigger path uses `call_deferred("_tick_full_auto_battle_if_needed")` after ally-turn phase restoration.
- Full auto battle reuses:
  - existing ally one-action auto logic
  - existing enemy AI turn flow
  - existing move/attack/facing execution paths
- Auto battle loop currently advances one step at a time and stops on safety conditions.
- Step limit guard is in place.
- Auto battle button text switches between `자동전투` and `자동중지`.
- Auto battle button position/offset/size is not changed by runtime code.
- Existing manual buttons remain in place.
- Existing enemy AI flow was preserved.
- ClickArea code was not modified.

## v0.65j-5a Auto Battle Stop UX Hotfix State
- `AutoBattleButton` remains clickable while full auto battle is ON.
- Full auto ON state now forces:
  - `auto_battle_button.disabled = false`
  - `auto_battle_button.text = "자동중지"`
- Full auto OFF state still follows existing ally-command availability for button enable/disable.
- User stop now routes through `_stop_full_auto_battle("user stop")`.
- Stop behavior is soft stop only:
  - current move/attack/enemy AI action is not force-killed
  - already-running tween/AI flow is allowed to finish
  - deferred auto tick returns immediately after stop because `is_full_auto_battle_enabled` is false
- Runtime code still does not touch `AutoBattleButton` position/offset/size.
- Existing manual buttons remain in place.
- Existing enemy AI flow was preserved.
- ClickArea code was not modified.

## v0.65k Battle Dust FX Profile Tuning State
- Movement dust flow remains unchanged.
- `_show_move_dust_for_unit()`, `_fade_out_move_dust_for_unit()`, `_hide_all_move_dust_sprites()`, and `_apply_move_dust_template_to_sprite()` remain on the original movement-only path.
- Added separate battle-dust FX tuning for attack and hit moments only.
- Battle dust now reuses the existing move-dust textures as source art, but not the move-dust template profile.
- Battle dust profile is now tuned around:
  - opacity `0.45 ~ 0.6`
  - beige / dirt tint
  - lower foot-level placement
  - scale `0.75 ~ 0.85`
  - duration `0.25 ~ 0.45`
- Attack dust now spawns between attacker and target at a lower position.
- Hit dust now spawns near the target foot area at a lower position.
- Battle dust `z_index` stays behind slash / hit spark FX.
- Existing attack slash / hit spark / damage number flow was preserved.
- Existing auto battle logic was preserved.
- `Battle_Fullscreen_Test.tscn` was not modified.
- ClickArea code was not modified.

## v0.65k-1 Battle Dust Layer + Density Hotfix State
- Movement dust flow remains unchanged.
- Movement dust helper functions remain unmodified:
  - `_show_move_dust_for_unit()`
  - `_fade_out_move_dust_for_unit()`
  - `_hide_all_move_dust_sprites()`
  - `_apply_move_dust_template_to_sprite()`
- Battle dust now forces `z_as_relative = false` and uses a much lower world `z_index`.
- Battle dust now sits below slash / hit spark / damage FX and closer to foot-level.
- Hit dust remains the primary visible battle dust.
- Attack dust remains present but with reduced density:
  - lower alpha
  - smaller scale
  - lower foot-level placement near the attacker
- Battle dust profile is now tuned around:
  - hit opacity `0.18 ~ 0.32`
  - attack opacity `0.12 ~ 0.22`
  - dirt tint `Color(0.62, 0.50, 0.34, 1.0)`
  - hit scale `0.45 ~ 0.65`
  - attack scale `0.35 ~ 0.5`
  - duration `0.14 ~ 0.26`
- `Battle_Fullscreen_Test.tscn` was not modified.
- Existing auto battle logic was preserved.
- ClickArea code was not modified.

## v0.65k-2 Dust Source Isolation + Stale Dust Cleanup Hotfix State
- Large white dust could recur through two paths:
  - stale `MoveDustSprite` visibility surviving from movement into later attack / counterattack timing
  - battle-dust FX still reusing the move-dust texture source with density high enough to read as a white cloud after repeated turns
- Movement dust helper functions remain unchanged:
  - `_show_move_dust_for_unit()`
  - `_fade_out_move_dust_for_unit()`
  - `_hide_all_move_dust_sprites()`
  - `_apply_move_dust_template_to_sprite()`
- Stale move dust is now explicitly cleared:
  - before ally attack demo starts
  - before enemy basic attack starts
  - after ally basic attack finishes
- Attack battle dust is now disabled.
- Hit battle dust remains as the only battle-dust cue.
- Battle dust now uses only battle-dust constants for:
  - alpha
  - scale
  - duration
  - tint
- Battle dust now tags spawned nodes as `BattleDustFX` and still `queue_free()`s them at tween end.
- Hit battle dust profile is now tuned around:
  - opacity `0.10 ~ 0.22`
  - dirt tint `Color(0.48, 0.38, 0.24, 1.0)`
  - scale `0.30 ~ 0.48`
  - duration `0.10 ~ 0.18`
  - lower world `z_index`
- `Battle_Fullscreen_Test.tscn` was not modified.
- Existing auto battle logic was preserved.
- ClickArea code was not modified.

## Unit Token Asset State
- Korea / China / Japan infantry / archer / gunner / cavalry token assets are normalized around the 256 baseline.
- Country/type folder structure is used.
- `visual_key -> texture path` lookup is maintained.
- UnitCloseupPanel uses the same visual_key based troop token lookup.
- Zhang Fei no longer uses the legacy 1024 China infantry token in the current test setup.
- Guan Yu and Zhang Fei are normalized against the same 256 baseline.

## Structural Notes
- The 4 UnitVisualRoot nodes are current combat slot roots, not fixed hero-specific roots.
- Future units such as Mongol troops, naval units, geobukseon, panokseon, tower ships, and siege weapons should be represented through data such as `visual_key`, `unit_type`, `domain`, and `footprint`.
- ClickArea / READY / FacingIndicator are not inside UnitVisualRoot yet.
- ClickArea uses collision/input coordinates and should only be migrated in a separate focused step.
- READY frame and FacingIndicator are UI/CanvasLayer concerns and should be evaluated separately from world visual roots.
- READY frame and FacingIndicator slot attachment is now cleaned up around slot-based visual slot lookup while staying under `BattleUI`.
- UnitVisualTemplate nodes are still used as scene-authored layout offset references.

## Debug Notes
- `_debug_print_unit_visual_root_slots()` currently remains and prints one startup slot check.
- `[ATTACK_CLICK]` print currently remains and prints only during attack target clicks.
- `ALLY PORTRAIT OFFSET DEBUG` function may exist, but its reset-time call is removed.
- Debug cleanup is a future cleanup task, not part of the verified v0.65g behavior.

## QA Notes
- Headless project launch exit code 0 confirmed after v0.65i-3.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65i-3.
- Full interactive QA items such as movement, attack, facing selection, and overlap targeting still require in-editor/manual verification.
- v0.65j-1 is a documentation-only step, so no new runtime QA was required.
- Headless project launch exit code 0 confirmed after v0.65j-2.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65j-2.
- Headless project launch exit code 0 confirmed after v0.65j-3.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65j-3.
- Headless project launch exit code 0 confirmed after v0.65j-3a.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65j-3a.
- Headless project launch exit code 0 confirmed after v0.65j-4.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65j-4.
- Headless project launch exit code 0 confirmed after v0.65j-5.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65j-5.
- Headless project launch exit code 0 confirmed after v0.65j-5a.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65j-5a.
- Headless project launch exit code 0 confirmed after v0.65k.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65k.
- Headless project launch exit code 0 confirmed after v0.65k-1.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65k-1.
- Headless project launch exit code 0 confirmed after v0.65k-2.
- Headless `res://Battle_Fullscreen_Test.tscn` launch exit code 0 confirmed after v0.65k-2.

## Guardrails
- Do not modify `Battle_WebImport_Test.tscn`.
- Do not change `attack_range`.
- Do not change `move_range`.
- Do not change `distance formula`.
- Do not change movement range cell calculation.
- Do not change facing selection logic.
- Do not change basic attack judgement.
- Do not change damage formula.
- Do not change enemy AI order.
- Do not change active ally lock.
- Do not change HP 0 cleanup.
- Do not break BATTLE Round Toast.
- Do not break Basic Battle FX Pack 1.
- Do not break UnitCloseupPanel.
- Do not break ally portrait up/down fix.
- Do not break dead enemy click priority fix.
- Preserve right-click move rollback.
- Preserve right-click attack cancel.
