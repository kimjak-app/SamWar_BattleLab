# CHANGELOG

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
