#!/usr/bin/env python3
from pathlib import Path

path = Path('scripts/battle_web_import_test.gd')
raw = path.read_bytes()
newline = '\r\n' if b'\r\n' in raw else '\n'
text = raw.decode('utf-8').replace('\r\n', '\n')

old = '''\tvar range_cells := _get_unique_skill_range_cells(caster_state, skill_data)\n\tvar display_cells: Array[Vector2i] = []\n\tfor range_cell in _get_unique_skill_range_cells(caster_state, skill_data):\n\t\tif not display_cells.has(range_cell):\n\t\t\tdisplay_cells.append(range_cell)\n\tdisplay_cells = _get_cells_wave_order(display_cells, caster_state.grid_cell, _get_unique_skill_range(caster_state, skill_data))\n'''

new = '''\tvar range_cells := _get_unique_skill_range_cells(caster_state, skill_data)\n\tvar display_cells: Array[Vector2i] = []\n\tfor range_cell in range_cells:\n\t\tif not display_cells.has(range_cell):\n\t\t\tdisplay_cells.append(range_cell)\n\tvar display_wave_range := _get_unique_skill_range(caster_state, skill_data)\n\tvar target_mode := String(skill_data.get("target_mode", ""))\n\tif ["self_area", "self_area_enemy", "enemy_adjacent"].has(target_mode):\n\t\tdisplay_wave_range = maxi(int(skill_data.get("radius", 0)), 0)\n\tdisplay_cells = _get_cells_wave_order(display_cells, caster_state.grid_cell, display_wave_range)\n'''

if old not in text:
    raise SystemExit('unique skill overlay wave-order anchor not found')
text = text.replace(old, new, 1)
out = text if newline == '\n' else text.replace('\n', '\r\n')
path.write_bytes(out.encode('utf-8'))
print('T06-7-hotfix7 full self-area overlay applied')
