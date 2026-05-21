# SESSION LOG

## 2026-05-21

Starting baseline:
- v0.65i-1 Slot UI Attachment Audit complete

Goal:
- v0.65i-3 READY/Facing UI Slot Registry Cleanup

Completed:
- Kept `AllyReadyFrame` / `AllySupportReadyFrame` under `BattleUI`.
- Kept `AllyFacingIndicator` / `AllySupportFacingIndicator` / `EnemyFacingIndicator` / `EnemySupportFacingIndicator` under `BattleUI`.
- Preserved `ready_frame` / `facing_indicator` entries in the slot visual dictionaries.
- Added `_get_ready_frame_for_unit()`.
- Converted `_update_ally_ready_frames()` to resolve READY frame through slot-based lookup.
- Added `_get_visual_anchor_position_for_unit()` with `slot_id` first dispatch and direct comparison fallback.
- Converted `_position_ready_frame_for_unit()` to use shared per-unit anchor lookup.
- Converted `_get_facing_indicator_for_unit()` to resolve through slot-based visual slot lookup.
- Added `_refresh_facing_indicator_for_unit()` and `_position_facing_indicator_for_unit()` as slot-aware dispatch helpers.
- Converted `_update_facing_indicators()` to use slot-aware refresh.
- Preserved existing `_position_facing_indicator_for_*()` functions.
- Did not modify ClickArea code path.
- Did not move any scene nodes.

QA:
- Headless project launch exit code 0.
- Headless `Battle_Fullscreen_Test.tscn` launch exit code 0.
- Startup slot debug print still shows all 4 slot roots active.
- F6/manual interaction QA not available in this environment.

Remaining tasks:
- v0.65i-2 ClickArea Root Migration Spike
- Target selection policy for overlapping living units
- Debug cleanup for root slot and attack click logs

## 2026-05-20

Starting baseline:
- v0.65e Unit Token Asset Normalize Apply Verified

Goal:
- UnitVisual Single Slot / Root Refactor.

Completed:
- v0.65g-2 UnitVisualRoot Adapter Layer.
- v0.65g-3 Ally Main Visual Nodes Root Migration.
- v0.65g-4 Ally Support Visual Nodes Root Migration.
- v0.65g-5 Enemy Main Visual Nodes Root Migration.
- v0.65g-5a-0 Ally Portrait Offset Diagnosis.
- v0.65g-5a-1 Ally Portrait Up/Down Offset Fix.
- v0.65g-6 Enemy Support Visual Nodes Root Migration.
- v0.65g-6a Dead Enemy Main Click Priority Fix.
- v0.65h-1 Extend BattleUnitState slot metadata.
- v0.65h-2 Inject demo unit slot metadata.
- v0.65h-3 Add slot_id visual slot lookup.
- v0.65h-4 QA and docs update.

Kimjak F6 confirmation:
- Ally Root migration normal.
- Ally portrait up/down fix normal.
- Guan Yu death no longer blocks Zhang Fei target selection.
- Yi Sun-sin and Jeong Do-jeon can both attack Zhang Fei after Guan Yu dies.

Current stable candidate:
- v0.65h Slot-Based UnitVisual Architecture Design Stable

QA:
- `Battle_Fullscreen_Test.tscn` headless launch exit code 0.
- UnitVisualRoot debug slot all true.
- `visual_key` values preserved.
- Existing direct comparison fallback preserved.
- No scene/node migration in v0.65h.
- F6 not available in this environment.

Remaining tasks:
- v0.65i ClickArea / READY / FacingIndicator Integration Review.
- Target selection policy for overlapping living units.
- Debug cleanup for root slot and attack click logs.
