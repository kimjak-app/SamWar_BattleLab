# SLOT UI Attachment Audit

## Scope
- Baseline: `v0.65h Slot-Based UnitVisual Architecture Design Stable`
- Audit target:
  - `AllyUnitClickArea`
  - `AllySupportUnitClickArea`
  - `EnemyUnitClickArea`
  - `EnemySupportUnitClickArea`
  - `AllyReadyFrame`
  - `AllySupportReadyFrame`
  - `AllyFacingIndicator`
  - `AllySupportFacingIndicator`
  - `EnemyFacingIndicator`
  - `EnemySupportFacingIndicator`
- No scene or gameplay script changes were made in this audit step.

## Summary
- ClickArea 4개는 현재 `scene root` 직속 `Area2D` 구조 유지가 안전하다.
- READY frame 2개는 현재 `BattleUI` 아래 `Panel` 유지가 안전하다.
- FacingIndicator 4개는 현재 `BattleUI` 아래 `Label` 유지가 안전하다.
- `UnitVisualRoot`에는 실제 전투 비주얼만 유지하는 방향이 맞다.
- attachment는 parent 통합보다 `slot_id` 기반 연결 유지가 현재 구조와 가장 잘 맞는다.

## Current Node Matrix

| Node | Current parent | Type | Coordinate class | Current position update | Main dependencies | Root migration possible | Risk | Recommendation |
|---|---|---|---|---|---|---|---|---|
| `AllyUnitClickArea` | `.` | `Area2D` | `world / Node2D` | `_reset_unit_group_positions()`, `_apply_ally_group_offset()` | manual hit-test, `CollisionShape2D`, alive gating, scene-authored `ClickAreaSlot` offset | Conditional | Medium-High | Keep under scene root |
| `AllySupportUnitClickArea` | `.` | `Area2D` | `world / Node2D` | `_reset_unit_group_positions()`, `_apply_ally_target_group_offset()`, `_apply_selected_ally_group_offset()` | manual hit-test, `CollisionShape2D`, alive gating, scene-authored `ClickAreaSlot` offset | Conditional | Medium-High | Keep under scene root |
| `EnemyUnitClickArea` | `.` | `Area2D` | `world / Node2D` | `_reset_unit_group_positions()`, `_apply_enemy_group_offset()` | manual hit-test, `CollisionShape2D`, attack target selection, dead-main overlap policy | Conditional | Medium-High | Keep under scene root |
| `EnemySupportUnitClickArea` | `.` | `Area2D` | `world / Node2D` | `_reset_unit_group_positions()`, `_apply_enemy_support_group_offset()`, `_apply_enemy_target_group_offset()` | manual hit-test, `CollisionShape2D`, attack target selection, dead-main overlap policy | Conditional | Medium-High | Keep under scene root |
| `AllyReadyFrame` | `BattleUI` | `Panel` | `BattleUI / CanvasLayer` | `_update_ready_frame_for_unit()` -> `_position_ready_frame_for_unit()` | ally turn state, acted-state, active lock, tween pulse, `_world_to_battle_ui_position()` | Technically yes, structurally poor | High | Keep under `BattleUI` |
| `AllySupportReadyFrame` | `BattleUI` | `Panel` | `BattleUI / CanvasLayer` | `_update_ready_frame_for_unit()` -> `_position_ready_frame_for_unit()` | ally turn state, acted-state, active lock, tween pulse, `_world_to_battle_ui_position()` | Technically yes, structurally poor | High | Keep under `BattleUI` |
| `AllyFacingIndicator` | `BattleUI` | `Label` | `BattleUI / CanvasLayer` | `_update_facing_indicators()` -> `_position_facing_indicator_for_ally()` | facing text, alive visibility, scene-authored `FacingIndicatorSlot` offset, `_world_to_battle_ui_position()` | Technically yes, structurally poor | High | Keep under `BattleUI` |
| `AllySupportFacingIndicator` | `BattleUI` | `Label` | `BattleUI / CanvasLayer` | `_update_facing_indicators()` -> `_position_facing_indicator_for_ally_support()` | facing text, alive visibility, scene-authored `FacingIndicatorSlot` offset, `_world_to_battle_ui_position()` | Technically yes, structurally poor | High | Keep under `BattleUI` |
| `EnemyFacingIndicator` | `BattleUI` | `Label` | `BattleUI / CanvasLayer` | `_update_facing_indicators()` -> `_position_facing_indicator_for_enemy()` | facing text, alive visibility, scene-authored `FacingIndicatorSlot` offset, `_world_to_battle_ui_position()` | Technically yes, structurally poor | High | Keep under `BattleUI` |
| `EnemySupportFacingIndicator` | `BattleUI` | `Label` | `BattleUI / CanvasLayer` | `_update_facing_indicators()` -> `_position_facing_indicator_for_enemy_support()` | facing text, alive visibility, scene-authored `FacingIndicatorSlot` offset, `_world_to_battle_ui_position()` | Technically yes, structurally poor | High | Keep under `BattleUI` |

## Detailed Audit

### 1. ClickArea 4개

#### Current parent
- All 4 click areas are direct children of scene root `.`.

#### Node type / coordinate system
- Type: `Area2D`
- Coordinate class: `world / Node2D`

#### Current position update path
- Base reset:
  - `_reset_unit_group_positions()`
- Offset during movement / attack animation:
  - ally main: `_apply_ally_group_offset()`
  - ally support: `_apply_ally_target_group_offset()`, `_apply_selected_ally_group_offset()`
  - enemy main: `_apply_enemy_group_offset()`
  - enemy support: `_apply_enemy_support_group_offset()`, `_apply_enemy_target_group_offset()`
- Scene-authored offset capture:
  - `_capture_scene_authored_unit_layout_offsets()`
  - slot source: `ClickAreaSlot`

#### Click / input / display dependencies
- Input is not driven by `Area2D` signals.
- The script uses manual mouse hit-test functions:
  - `_is_click_inside_ally_click_area()`
  - `_is_click_inside_ally_support_click_area()`
  - `_is_click_inside_enemy_click_area()`
  - `_is_click_inside_enemy_support_click_area()`
- These functions depend on:
  - `Area2D.to_local(mouse_pos)`
  - each `CollisionShape2D.position`
  - shape type (`RectangleShape2D` / `CircleShape2D`)
- `_input(event)` uses these hit-tests directly for ally selection and enemy target selection.
- `_set_unit_click_area_enabled()` toggles `monitoring`, `monitorable`, `input_pickable` by alive state.
- Slot dictionaries already expose `click_area` and `click_shape`, so attachment is already logically slot-based even though parent is separate.

#### Root migration viability
- Possible only as a separate focused refactor.
- Current code assumes click areas can be positioned independently in world coordinates from root-level anchors.
- Moving under `UnitVisualRoot` would require:
  - re-validating all `to_local()` hit-test paths
  - re-checking collision shape local offsets
  - removing or rewriting repeated explicit `click_area.position = visual_anchor + layout_offset (+ offset)` patterns
  - validating overlap selection behavior for enemy main/support

#### Risk
- Medium-High
- Main risk is not simple parent replacement but hidden behavioral drift in click priority and hit geometry during animation offsets.
- Current dead-enemy-main overlap fix depends on exact click-test behavior staying stable.

#### Recommendation
- Keep the 4 ClickArea nodes as root-level `Area2D` for now.
- If tested later, handle as `v0.65i-2 ClickArea Root Migration Spike` only.

### 2. READY frame 2개

#### Current parent
- `AllyReadyFrame` and `AllySupportReadyFrame` are children of `BattleUI`.

#### Node type / coordinate system
- Type: `Panel`
- Coordinate class: `BattleUI / CanvasLayer`

#### Current position update path
- Style setup:
  - `_configure_ally_ready_frames()`
  - `_apply_ready_frame_style()`
- Visibility and pulse state:
  - `_update_ally_ready_frames()`
  - `_update_ready_frame_for_unit()`
  - `_start_ready_frame_pulse()`
  - `_stop_ready_frame_pulse()`
- Positioning:
  - `_position_ready_frame_for_unit()`
  - world anchor converted by `_world_to_battle_ui_position()`

#### Click / input / display dependencies
- Display-only UI.
- `mouse_filter = IGNORE`
- Depends on:
  - ally-side only logic
  - `current_phase`
  - `is_demo_animating`
  - active ally lock
  - acted-state bookkeeping
  - `battle_grid_controller.get_cell_size()`
  - tween-based pulse state

#### Root migration viability
- Technically possible because `Control` can exist under a non-`Control` canvas parent, but the structure becomes worse.
- Current behavior is explicitly screen-space UI attached to world anchors through viewport transform.
- Moving under `UnitVisualRoot` would mix combat-world root ownership with overlay UI concerns.

#### Risk
- High
- Major risk areas:
  - `CanvasLayer` separation loss
  - camera / viewport transform behavior changes
  - pulse/frame sizing and alignment drift
  - future HUD layering conflicts

#### Recommendation
- Keep READY frames under `BattleUI` as `Panel`.
- Do not move them under `UnitVisualRoot`.

### 3. FacingIndicator 4개

#### Current parent
- All 4 facing indicators are children of `BattleUI`.

#### Node type / coordinate system
- Type: `Label`
- Coordinate class: `BattleUI / CanvasLayer`

#### Current position update path
- Scene-authored offset capture:
  - `_capture_scene_authored_unit_layout_offsets()`
  - slot source: `FacingIndicatorSlot`
- Display text / visibility / position refresh:
  - `_update_facing_indicators()`
  - `_position_facing_indicator_for_ally()`
  - `_position_facing_indicator_for_ally_support()`
  - `_position_facing_indicator_for_enemy()`
  - `_position_facing_indicator_for_enemy_support()`
- Visibility gate:
  - `_set_facing_indicators_visible()`
- Coordinate bridge:
  - `_world_to_battle_ui_position()`

#### Click / input / display dependencies
- Display-only UI.
- Depends on:
  - `unit_state.facing`
  - `_get_facing_arrow_text()`
  - alive state
  - global `facing_indicators_should_be_visible`
  - per-slot layout offsets captured from template markers

#### Root migration viability
- Technically possible, but not a good structural fit.
- Current design intentionally keeps the indicator as `BattleUI` overlay while using world anchors as attachment points.
- Moving under `UnitVisualRoot` would couple text UI to world visual hierarchy and remove the current clean screen-space conversion point.

#### Risk
- High
- Main risk is mixed UI/world ownership causing alignment drift and harder maintenance when camera or overlay policy changes.

#### Recommendation
- Keep all 4 FacingIndicators under `BattleUI` as `Label`.
- Keep slot attachment through captured offset + world-to-UI conversion.

## Root Migration Decision

### What should stay in `UnitVisualRoot`
- Actual combat visuals only:
  - token
  - shadow
  - move dust
  - portrait badge
  - HP bar
  - troop label

### What should stay outside `UnitVisualRoot`
- ClickArea 4개: keep as root-level `Area2D`
- READY frame 2개: keep under `BattleUI`
- FacingIndicator 4개: keep under `BattleUI`

## Final Recommendation
1. Do not unify ClickArea / READY / FacingIndicator under one parent.
2. Keep `UnitVisualRoot` focused on actual battle visuals only.
3. Keep non-visual attachments connected by `slot_id`-based lookup and slot dictionaries.
4. Treat ClickArea migration, if attempted later, as an isolated spike with dedicated QA.
5. Treat READY/Facing cleanup as registry/attachment cleanup inside current parent categories, not as parent relocation.

## Recommended Next Steps
- `v0.65i-2 ClickArea Root Migration Spike`
- `v0.65i-3 READY/Facing UI Slot Registry Cleanup`
- `v0.65j Target Selection Policy for Overlapping Live Units`
