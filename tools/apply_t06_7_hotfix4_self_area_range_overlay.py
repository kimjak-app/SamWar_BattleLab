#!/usr/bin/env python3
from pathlib import Path

path = Path('scripts/battle_web_import_test.gd')
raw = path.read_bytes()
newline = '\r\n' if b'\r\n' in raw else '\n'
text = raw.decode('utf-8').replace('\r\n', '\n')

old = '''func _get_unique_skill_range_cells(caster_state: BattleUnitState, skill_data: Dictionary) -> Array[Vector2i]:
\tvar cells: Array[Vector2i] = []
\tif caster_state == null or battle_grid_controller == null:
\t\treturn cells
\tvar skill_range := _get_unique_skill_range(caster_state, skill_data)
\tfor cell in battle_grid_controller.get_tiles_in_range(caster_state.grid_cell, skill_range):
\t\tif battle_grid_controller.is_in_bounds(cell):
\t\t\tcells.append(cell)
\treturn cells
'''

new = '''func _get_unique_skill_range_cells(caster_state: BattleUnitState, skill_data: Dictionary) -> Array[Vector2i]:
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
\treturn cells
'''

if old not in text:
    raise SystemExit('unique skill range cell function anchor not found')
text = text.replace(old, new, 1)

out = text if newline == '\n' else text.replace('\n', '\r\n')
path.write_bytes(out.encode('utf-8'))
print('T06-7-hotfix4 self-area range overlay applied')
