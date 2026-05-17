# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.64i-hotfix-4 Attack Range Debug + Enemy Range Gate

## Current Patch
v0.64j Unit Visual Footprint Calibration

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
- v0.64f-hotfix-3 Clean Move Target UX
- v0.64g Attack Target Selection
- v0.64h Turn Flow After Move
- v0.64i-hotfix-4 Attack Range Debug + Enemy Range Gate

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
- current demo values: Yi Sun-sin attack_range = 3, Guan Yu attack_range = 1

### MoveTargetMarker
MoveTargetMarker currently previews and confirms a snapped grid-cell target position.

Current behavior:
- marker target can be selected at runtime by left-clicking an in-bounds battlefield cell
- clicked world position is converted through BattleGridController.world_to_grid()
- marker target is interpreted as the selected or nearest grid cell
- marker preview uses the current BattleGridController math
- MoveHighlight size is synced to BattleGridController.get_cell_size() with a safe fixed-size fallback
- valid clicked movement targets use strong MoveHighlight feedback
- invalid, occupied, enemy-occupied, and out-of-range movement clicks are logged but do not show a red selected-target box
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
- after successful movement, the battle stays in ally turn so Yi Sun-sin can still attack
- MoveButton is disabled after movement through ally_has_moved, while BasicAttackButton remains available during ally turn
- after movement, if Guan Yu is within ally_unit_state.attack_range, ally turn remains active and AttackHighlight is shown
- after movement, if Guan Yu is outside ally_unit_state.attack_range, enemy reaction starts automatically and then returns to ally turn
- post-move range branch prints ally/enemy grid_cell, distance, and attack range once when movement finishes
- _start_idle_breathing() exists and is used only on the in-range ally-turn branch

### Unit Visual Footprint
Ally and enemy visual footprints are calibrated around their logical grid cell center.

Current behavior:
- BattleGridController cell size is about 62.86 x 55.0 from the current 14 x 8 board markers
- AllyUnitToken and EnemyUnitToken use matching scale 0.38
- formation tokens render at about 97 px wide, roughly 1.5 grid cells, instead of feeling like 2+ cells
- AllyPortraitBadge and EnemyPortraitBadge use matching scale 0.32
- portraits are pulled closer to formation anchors so they do not imply another occupied grid cell
- HP bars and troop labels use tighter offsets below the formation center
- shadows sit closer under the formation using SHADOW_OFFSET = Vector2(0.0, 34.0)
- AllyUnitClickArea and EnemyUnitClickArea use 108 x 112 RectangleShape2D hitboxes
- click hitboxes cover the visible unit/portrait while staying tighter for nearby movement cell clicks
- grid_cell logic, occupied-cell rules, movement validation, and attack range rules were not changed by the footprint calibration

### Attack Target Selection
Attack target selection is now available as a target-selection-only MVP.

Current behavior:
- EnemyUnitClickArea is an editor-visible Area2D hitbox over Guan Yu with a CollisionShape2D child
- EnemyUnitClickArea is checked manually from _input(), not through Area2D.input_event
- left-click handling order is ally hitbox, enemy hitbox, then battlefield movement target selection
- clicking Guan Yu selects enemy_unit_state as the attack target
- selected_attack_target_state and selected_attack_target_side track the selected enemy target
- clicking Guan Yu appends "관우 공격 대상 선택" to the battle log
- AttackHighlight appears over Guan Yu using the enemy grid cell and BattleGridController cell size
- selecting the ally, selecting a movement target, or starting/finishing movement clears the attack target and hides AttackHighlight
- BasicAttackButton still runs the existing basic attack demo
- BasicAttackButton routes through try_basic_attack() and uses selected_attack_target_state with an enemy_unit_state fallback
- try_basic_attack() blocks out-of-range attacks with "사거리 밖입니다"
- try_basic_attack() prints ally/target grid_cell, distance, and ally attack range once when the button is pressed
- after the attack demo finishes, enemy turn/reaction plays and then returns to ally turn
- enemy hit reaction during the attack uses a smoother recoil-and-return bounce without a long pause
- enemy reaction now makes Yi Sun-sin recoil, flash red, and lose demo HP/troops before returning smoothly
- enemy reaction checks Guan Yu's attack_range before damaging Yi Sun-sin
- out-of-range enemy reaction logs "관우 사거리 밖" and returns to ally turn without ally damage or hit bounce
- full attack range/unit type rule polish is not implemented yet
- new attack damage rules are not implemented yet

---

## Current Known Gaps
- Full grid visual sync is postponed to a later v0.64 patch.
- Advanced pathfinding is not implemented yet.
- Advanced collision rules are not implemented yet.
- Terrain cost/blocking rules are not implemented yet.
- Full attack range/unit type rules are not implemented yet.
- Attack range overlay is not implemented yet.
- Advanced attack confirm flow cleanup is not implemented yet.

---

## Next Immediate Task
v0.64k Melee/Range Feel QA

Goal:
- Verify that visual closeness, grid_cell distance, and attack range feedback now feel coherent.

Note:
- Grid visual sync remains postponed.
- v0.65 is not reached. The v0.64 series remains the Godot battle engine port-in-progress.
