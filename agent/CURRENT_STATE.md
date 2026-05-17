# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.64a Movement Command MVP

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
- marker target is interpreted as the nearest grid cell
- marker preview uses the current BattleGridController math
- valid targets use simple valid feedback
- invalid targets use simple invalid feedback
- MoveButton confirms a valid snapped move target
- confirmed movement updates BattleUnitState.grid_cell
- confirmed movement sets BattleUnitState.has_moved = true
- the same unit cannot move twice in the same ally turn

---

## Current Known Gaps
- Movement range visual overlay is not implemented yet.
- Advanced pathfinding is not implemented yet.
- Occupied-cell and collision rules are not implemented yet.
- Terrain cost/blocking rules are not implemented yet.
- Attack range validation is not implemented yet.

---

## Next Immediate Task
v0.64b Movement Range Visual Overlay

Goal:
- Show the active unit's movement range visually without replacing the current MoveTargetMarker validation and confirmation flow.
