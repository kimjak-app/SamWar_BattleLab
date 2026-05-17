# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.64e Occupied Cell Blocking

## Current Patch
v0.64f-hotfix-3 Clean Move Target UX

## Current Goal
Port and rebuild the SamWar battle engine in Godot 4 using an editor-friendly workflow.

This project is not a full copy-paste port of the legacy/web engine. It selectively ports battle math, rules, state flow, and presentation intent into a native Godot 4 structure.

---

## Core Philosophy
- Code controls behavior.
- Scene controls layout and visual placement.
- Battle_WebImport_Test.tscn manual layout remains the source of truth.
- Important battlefield nodes must remain visible, selectable, and draggable in the Godot 2D editor.
- Do not create major battlefield/layout nodes at runtime.
- Do not copy the old legacy Godot/web engine wholesale; selectively port only the needed math and logic.

---

## Completed Milestones

### v0.60 Series
- v0.60a battle assets sync pipeline
- v0.60g web battle screen Godot import/layout checkpoint

### v0.61 Series
- v0.61a basic attack demo
- v0.61b unit visual group movement
- v0.61c direction/facing + troop number display
- v0.61d shadow + idle breathing
- v0.61e-hotfix hidden debug highlight + cleaned HP bar

### v0.62 Series
- v0.62a turn phase demo
- v0.62b enemy basic defense action demo

### v0.63 Series
- v0.63a BattleGridController
- v0.63b BattleUnitState
- v0.63c UnitState grid_cell binding
- v0.63d MoveTargetMarker grid snap preview

### v0.64 Series
- v0.64a Movement Command MVP
- v0.64b Runtime Move Target Selection
- v0.64c MoveHighlight Cell Size Sync
- v0.64d Active Unit Selection
- v0.64e Occupied Cell Blocking
- v0.64f Movement Range Overlay

---

## Current Key Scene
- Battle_WebImport_Test.tscn

---

## Current Key Scripts
- scripts/battle_grid_controller.gd
- scripts/battle_unit_state.gd
- scripts attached to Battle_WebImport_Test.tscn and MoveTargetMarker workflow

---

## Current System State

### BattleGridController
The project now has a Godot-side grid controller for tactical battle logic.

Current supported concepts:
- board bounds
- grid width/height
- top-left and bottom-right board markers
- cell size calculation
- grid-to-world conversion
- world-to-grid conversion
- in-bounds check
- Manhattan distance
- tiles-in-range calculation

### BattleUnitState
The project now has a battle unit state object.

Current supported concepts:
- unit identity
- side
- hero name
- HP/troop values
- attack/defense
- move range
- attack range
- grid_cell
- facing
- has_acted / has_moved flags

### MoveTargetMarker
MoveTargetMarker currently previews and confirms a snapped grid-cell target position.

Current behavior:
- marker target can be selected at runtime by left-clicking an in-bounds battlefield cell
- clicked world position is converted through BattleGridController.world_to_grid()
- marker target is interpreted as the selected or nearest grid cell
- marker preview uses the current BattleGridController math
- MoveHighlight size is synced to BattleGridController.get_cell_size() with a safe fixed-size fallback
- valid targets use simple valid feedback
- invalid targets use simple invalid feedback
- ally-occupied and enemy-occupied cells are invalid move targets
- MoveButton confirms a valid snapped move target
- confirmed movement updates BattleUnitState.grid_cell
- confirmed movement sets BattleUnitState.has_moved = true
- the same unit cannot move twice in the same ally turn

### Active Unit Selection
Active unit selection is now available as a single-ally MVP.

Current behavior:
- clicking inside the editor-visible AllyUnitClickArea hitbox over the ally unit selects it as the active unit
- AllyUnitClickArea is used as a manual hitbox reference checked early from _input(), not through Area2D.input_event
- left-click ally selection and battlefield move target selection are unified in _input()
- _unhandled_input() ignores left mouse clicks to prevent duplicate handling
- selected ally feedback is shown through the battle log
- movement validation uses active_unit_state for origin, range, and has_moved checks
- AllyUnitClickArea follows the ally unit when _reset_unit_group_positions() syncs unit visuals
- movement visuals still use the ally visual group because generic multi-unit movement is not implemented yet

### MoveRangeOverlayLayer
Move range overlay is implemented with a prebuilt editor-visible ColorRect pool.

Current behavior:
- MoveRangeOverlayLayer contains MoveRangeCell_00 through MoveRangeCell_111
- cells are collected once into a script-side pool
- selecting the active ally shows currently valid movable cells in faint blue
- overlay uses BattleGridController.get_tiles_in_range() and is_valid_move_target()
- origin, occupied ally cell, occupied enemy cell, out-of-range cells, and post-move cells are not shown as movable
- overlay double-checks board bounds before showing each pooled cell
- overlay applies a small visual inset check before showing each pooled cell so range cells do not spill into the battlefield margin
- overlay is hidden while resolving movement/attack and after the active unit has moved
- MoveHighlight is gated by has_selected_move_target and appears only after the player clicks a movement target cell
- invalid, occupied, enemy-occupied, and out-of-range movement clicks do not show a red selected-target box
- selecting the ally clears the selected movement target and leaves only the faint movement range overlay visible
- starting confirmed movement immediately clears the selected-target MoveHighlight before the tween begins
- successful movement clears has_selected_move_target, hides MoveHighlight, and hides the range overlay
- successful movement logs "이순신 이동 완료"

---

## Current Known Gaps
- Full grid visual sync is postponed to a later v0.64 patch.
- Advanced pathfinding is not implemented yet.
- Advanced collision rules are not implemented yet.
- Terrain cost/blocking rules are not implemented yet.
- Attack range validation is not implemented yet.

---

## Next Immediate Task
v0.64g Attack Target Selection

Goal:
- Allow selecting an enemy target separately from movement target selection.

Note:
- Grid visual sync remains postponed.
- v0.65 is not reached. The v0.64 series remains the Godot battle engine port-in-progress.
