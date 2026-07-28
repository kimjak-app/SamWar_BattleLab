#!/usr/bin/env python3
from pathlib import Path
import re

path = Path('scripts/battle_web_import_test.gd')
raw = path.read_bytes()
newline = '\r\n' if b'\r\n' in raw else '\n'
text = raw.decode('utf-8').replace('\r\n', '\n')

# 1. Self-area skills must never auto-resolve for the player.
text, count = re.subn(
    r'func _should_unique_skill_resolve_without_manual_target\(skill_data: Dictionary\) -> bool:\n\treturn \[[^\n]*\]\.has\(String\(skill_data\.get\("target_mode", ""\)\)\)',
    'func _should_unique_skill_resolve_without_manual_target(skill_data: Dictionary) -> bool:\n\treturn ["self", "self_area_enemy", "enemy_adjacent"].has(String(skill_data.get("target_mode", "")))',
    text,
    count=1,
)
if count != 1:
    raise SystemExit('auto-resolve function not patched')

# 2. Display the actual self-centered effect radius.
range_pattern = re.compile(
    r'func _get_unique_skill_range_cells\(caster_state: BattleUnitState, skill_data: Dictionary\) -> Array\[Vector2i\]:\n.*?(?=\n\nfunc _get_unique_skill_valid_targets)',
    re.S,
)
range_replacement = '''func _get_unique_skill_range_cells(caster_state: BattleUnitState, skill_data: Dictionary) -> Array[Vector2i]:
\tvar cells: Array[Vector2i] = []
\tif caster_state == null or battle_grid_controller == null:
\t\treturn cells
\tvar display_range := _get_unique_skill_range(caster_state, skill_data)
\tvar target_mode := String(skill_data.get("target_mode", ""))
\tif ["self_area", "self_area_enemy", "enemy_adjacent"].has(target_mode):
\t\tdisplay_range = maxi(int(skill_data.get("radius", 0)), 0)
\tfor cell in battle_grid_controller.get_tiles_in_range(caster_state.grid_cell, display_range):
\t\tif battle_grid_controller.is_in_bounds(cell):
\t\t\tcells.append(cell)
\treturn cells'''
text, count = range_pattern.subn(range_replacement, text, count=1)
if count != 1:
    raise SystemExit('range-cell function not patched')

# 3. For player confirmation, every living ally inside the caster-centered radius is clickable.
target_pattern = re.compile(
    r'func _get_unique_skill_valid_targets\(caster_state: BattleUnitState, skill_data: Dictionary\) -> Array\[BattleUnitState\]:\n.*?(?=\n\nfunc _is_valid_unique_skill_target)',
    re.S,
)
target_replacement = '''func _get_unique_skill_valid_targets(caster_state: BattleUnitState, skill_data: Dictionary) -> Array[BattleUnitState]:
\tif caster_state == null or skill_data.is_empty():
\t\treturn []
\tvar target_mode := String(skill_data.get("target_mode", ""))
\tif target_mode == "self_area":
\t\tvar result: Array[BattleUnitState] = []
\t\tvar radius := maxi(int(skill_data.get("radius", 0)), 0)
\t\tfor unit_state in _get_all_alive_unit_states_from_adapter():
\t\t\tif unit_state == null or unit_state.side != caster_state.side:
\t\t\t\tcontinue
\t\t\tif get_unit_grid_distance(caster_state, unit_state) <= radius:
\t\t\t\tresult.append(unit_state)
\t\treturn result
\treturn BattleSkillResolverScript.get_valid_primary_targets(
\t\tcaster_state,
\t\tskill_data,
\t\t_get_all_alive_unit_states_from_adapter()
\t)'''
text, count = target_pattern.subn(target_replacement, text, count=1)
if count != 1:
    raise SystemExit('valid-target function not patched')

# 4. Self-area clicks must use ally hit detection.
click_pattern = re.compile(
    r'func _get_unique_skill_clicked_target_at_position\(mouse_world_pos: Vector2\) -> BattleUnitState:\n.*?(?=\n\nfunc _try_use_unique_skill_on_target)',
    re.S,
)
click_replacement = '''func _get_unique_skill_clicked_target_at_position(mouse_world_pos: Vector2) -> BattleUnitState:
\tif unique_skill_targeting_caster_state == null or unique_skill_targeting_skill_data.is_empty():
\t\treturn null
\tvar target_mode := String(unique_skill_targeting_skill_data.get("target_mode", ""))
\tvar clicked_target: BattleUnitState = null
\tif target_mode == "ally_area" or target_mode == "self_area":
\t\tclicked_target = _get_clicked_ally_unit_at_position(mouse_world_pos)
\telse:
\t\tclicked_target = _get_clicked_enemy_unit_at_position(mouse_world_pos)
\tif _is_valid_unique_skill_target(unique_skill_targeting_caster_state, unique_skill_targeting_skill_data, clicked_target):
\t\treturn clicked_target
\treturn null'''
text, count = click_pattern.subn(click_replacement, text, count=1)
if count != 1:
    raise SystemExit('clicked-target function not patched')

out = text if newline == '\n' else text.replace('\n', '\r\n')
path.write_bytes(out.encode('utf-8'))
print('T06-7-hotfix6 self-area ally confirmation applied')
