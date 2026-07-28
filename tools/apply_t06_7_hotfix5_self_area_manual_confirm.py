#!/usr/bin/env python3
from pathlib import Path

path = Path('scripts/battle_web_import_test.gd')
raw = path.read_bytes()
newline = '\r\n' if b'\r\n' in raw else '\n'
text = raw.decode('utf-8').replace('\r\n', '\n')

old_auto = '''func _should_unique_skill_resolve_without_manual_target(skill_data: Dictionary) -> bool:
\treturn ["self", "self_area", "self_area_enemy", "enemy_adjacent"].has(String(skill_data.get("target_mode", "")))
'''
new_auto = '''func _should_unique_skill_resolve_without_manual_target(skill_data: Dictionary) -> bool:
\treturn ["self", "self_area_enemy", "enemy_adjacent"].has(String(skill_data.get("target_mode", "")))
'''
if old_auto not in text:
    raise SystemExit('auto resolve target-mode anchor not found')
text = text.replace(old_auto, new_auto, 1)

old_click = '''func _get_unique_skill_clicked_target_at_position(mouse_world_pos: Vector2) -> BattleUnitState:
\tif unique_skill_targeting_caster_state == null or unique_skill_targeting_skill_data.is_empty():
\t\treturn null
\tvar target_mode := String(unique_skill_targeting_skill_data.get("target_mode", ""))
\tvar clicked_target: BattleUnitState = null
\tif target_mode == "ally_area":
\t\tclicked_target = _get_clicked_ally_unit_at_position(mouse_world_pos)
\telse:
\t\tclicked_target = _get_clicked_enemy_unit_at_position(mouse_world_pos)
\tif _is_valid_unique_skill_target(unique_skill_targeting_caster_state, unique_skill_targeting_skill_data, clicked_target):
\t\treturn clicked_target
\treturn null
'''
new_click = '''func _get_unique_skill_clicked_target_at_position(mouse_world_pos: Vector2) -> BattleUnitState:
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
\treturn null
'''
if old_click not in text:
    raise SystemExit('clicked target resolver anchor not found')
text = text.replace(old_click, new_click, 1)

out = text if newline == '\n' else text.replace('\n', '\r\n')
path.write_bytes(out.encode('utf-8'))
print('T06-7-hotfix5 self-area manual confirm applied')
