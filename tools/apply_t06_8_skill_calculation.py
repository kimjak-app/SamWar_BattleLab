#!/usr/bin/env python3
from pathlib import Path
import re

resolver_path=Path('scripts/battle/battle_skill_resolver.gd')
runtime_path=Path('scripts/battle_web_import_test.gd')

text=resolver_path.read_text(encoding='utf-8')
text=text.replace('var commands := _build_commands(caster, skill, affected, primary_target)', 'var commands := _build_commands(caster, skill, affected, primary_target, units, battle_type)', 1)
old='''\telif target_mode == "enemy_area":
\t\tfor unit in units:
\t\t\tif unit != null and unit.is_alive() and unit.side != caster.side \\
\t\t\t\t\tand _distance(primary_target, unit) <= radius:
\t\t\t\tresult.append(unit)
\treturn result
'''
new='''\telif target_mode == "enemy_area":
\t\tfor unit in units:
\t\t\tif unit != null and unit.is_alive() and unit.side != caster.side \\
\t\t\t\t\tand _distance(primary_target, unit) <= radius:
\t\t\t\tresult.append(unit)
\tif String(skill.get("effect_type", "")) == "splash_charge":
\t\tfor unit in units:
\t\t\tif unit != null and unit.is_alive() and unit.side != caster.side \\
\t\t\t\t\tand _distance(primary_target, unit) <= maxi(radius, 1) and not result.has(unit):
\t\t\t\tresult.append(unit)
\treturn result
'''
if old not in text: raise SystemExit('affected anchor missing')
text=text.replace(old,new,1)
pattern=re.compile(r'static func _build_commands\(.*?\n\nstatic func _has_positive_damage_command', re.S)
replacement=r'''static func _build_commands(
\tcaster: BattleUnitState,
\tskill: Dictionary,
\taffected: Array[BattleUnitState],
\tprimary_target: BattleUnitState,
\tunits: Array[BattleUnitState],
\tbattle_type: String
) -> Array[Dictionary]:
\tvar commands: Array[Dictionary] = []
\tvar archetype := String(skill.get("archetype", ""))
\tvar effect_type := String(skill.get("effect_type", ""))
\tvar hero_id := String(skill.get("hero_id", ""))
\tvar turns := maxi(int(skill.get("duration_turns", 0)), 1)
\tvar power := maxi(int(skill.get("power", 0)), 0)
\tvar damage := maxi(1, int(round(float(power) * 0.42 + float(caster.martial) * 0.12)))
\tif effect_type in ["charge_line", "charge_damage", "charge_aoe"]:
\t\tdamage += maxi(0, _distance(caster, primary_target) - 1) * 4
\tvar status_amount := clampi(int(round(float(maxi(power, 40)) * 0.16)), 8, 20)
\tmatch archetype:
\t\t"damage_single", "damage_line", "damage_area":
\t\t\tfor target in affected:
\t\t\t\tvar target_damage := damage
\t\t\t\tif (archetype == "damage_area" or effect_type == "splash_charge") and target != primary_target:
\t\t\t\t\ttarget_damage = maxi(1, int(round(float(damage) * (0.50 if effect_type == "splash_charge" else 0.72))))
\t\t\t\tvar damage_flag := ""
\t\t\t\tif effect_type == "gunner_volley": damage_flag = "ignore_defense"
\t\t\t\tif hero_id == "cheok_jun_gyeong": damage_flag = "advance_on_kill"
\t\t\t\tcommands.append(_command("damage", target.unit_id, target_damage, 0, damage_flag))
\t\t\tif effect_type == "single_burst" and primary_target != null:
\t\t\t\tcommands.append(_command("damage", primary_target.unit_id, maxi(1, int(round(float(damage) * 0.50))), 0, "deterministic_followup"))
\t\t\t_append_damage_secondary_commands(commands, effect_type, affected, turns, status_amount)
\t\t"buff_self", "buff_team_area":
\t\t\tfor target in affected:
\t\t\t\t_append_buff_commands(commands, effect_type, target, turns, status_amount, caster)
\t\t\tif _grants_momentum(effect_type):
\t\t\t\tcommands.append(_command("momentum", caster.side, 1, 0, "skill_gain"))
\t\t"debuff_single", "debuff_area", "control_area":
\t\t\tfor target in affected:
\t\t\t\t_append_debuff_commands(commands, effect_type, target, turns, status_amount)
\t\t\tif effect_type == "aoe_debuff" and not affected.is_empty():
\t\t\t\tvar delayed := affected[0]
\t\t\t\tfor candidate in affected:
\t\t\t\t\tif candidate.current_hp < delayed.current_hp: delayed = candidate
\t\t\t\tcommands.append(_command("status", delayed.unit_id, 1, 1, "action_lock"))
\t\t\tif effect_type == "control_field":
\t\t\t\tvar radius := int(skill.get("radius", 0))
\t\t\t\tfor unit in units:
\t\t\t\t\tif unit != null and unit.is_alive() and unit.side == caster.side and _distance(primary_target, unit) <= radius:
\t\t\t\t\t\tcommands.append(_command("status", unit.unit_id, 12, turns, "defense_up"))
\t\t\tif _drains_momentum(effect_type):
\t\t\t\tcommands.append(_command("momentum", _opposing_side(caster.side), -1, 0, "skill_drain"))
\t\t"restore_dispel":
\t\t\tfor target in affected:
\t\t\t\tcommands.append(_command("heal", target.unit_id, maxi(8, caster.intelligence / 4), 0, ""))
\t\t\t\tcommands.append(_command("cleanse", target.unit_id, 1, 0, "negative"))
\t\t\t\tcommands.append(_command("status", target.unit_id, 10, turns, "defense_up"))
\t\t"movement_charge":
\t\t\tcommands.append(_command("move", caster.unit_id, 1, turns, "retreat"))
\t\t\tcommands.append(_command("status", caster.unit_id, 20, turns, "counter_up"))
\tif battle_type != "naval" and effect_type == "naval_team_buff":
\t\tfor command in commands:
\t\t\tif String(command.get("type", "")) == "status": command["amount"] = maxi(6, int(command.get("amount", 10)) - 4)
\tif _has_positive_damage_command(commands):
\t\tcommands.append(_command("momentum", _opposing_side(caster.side), -2, 0, "unique_skill_hit"))
\treturn commands


static func _append_buff_commands(commands: Array[Dictionary], effect_type: String, target: BattleUnitState, turns: int, amount: int, caster: BattleUnitState) -> void:
\tvar scaled := amount
\tif effect_type == "guard_aura" and target == caster and String(caster.hero_id) == "gyebaek": scaled = int(round(float(amount) * 1.5))
\tmatch effect_type:
\t\t"guard_aura":
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "damage_reduction"))
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "counter_up"))
\t\t"team_mobility_buff", "mounted_team_buff":
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "mobility_up"))
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "flank_damage_up"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "momentum_gain_up"))
\t\t"team_command", "team_action_buff":
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "attack_defense_up"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "mobility_up"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "momentum_gain_up"))
\t\t\tif effect_type == "team_action_buff": commands.append(_command("status", target.unit_id, scaled, turns, "siege_attack_up"))
\t\t"team_logistics":
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "mobility_up"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "momentum_gain_up"))
\t\t"team_guard":
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "damage_reduction"))
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "status_resist"))
\t\t"team_morale":
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "damage_reduction"))
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "rout_resist"))
\t\t"team_support": commands.append(_command("status", target.unit_id, scaled, turns, "defense_up"))
\t\t"stance_team_buff":
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "attack_defense_up"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "mobility_up"))
\t\t"naval_team_buff":
\t\t\tcommands.append(_command("status", target.unit_id, scaled, turns, "attack_defense_up"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "momentum_gain_up"))
\t\t_: commands.append(_command("status", target.unit_id, scaled, turns, "attack_defense_up"))


static func _append_debuff_commands(commands: Array[Dictionary], effect_type: String, target: BattleUnitState, turns: int, amount: int) -> void:
\tmatch effect_type:
\t\t"single_debuff":
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "attack_defense_down"))
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "accuracy_down"))
\t\t"aoe_debuff":
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "attack_defense_down"))
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "accuracy_down"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "momentum_gain_down"))
\t\t"prediction_debuff":
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "attack_defense_down"))
\t\t\tcommands.append(_command("status", target.unit_id, 2, turns, "movement_down"))
\t\t"control_field":
\t\t\tcommands.append(_command("status", target.unit_id, 2, turns, "movement_down"))
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "accuracy_down"))
\t\t"fear_aoe":
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "attack_defense_down"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "movement_down"))
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "fear"))
\t\t"encirclement_debuff":
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "defense_down"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "movement_down"))
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "flank_damage_taken_up"))
\t\t"command_debuff":
\t\t\tcommands.append(_command("status", target.unit_id, amount, turns, "attack_defense_down"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "momentum_gain_down"))
\t\t_: commands.append(_command("status", target.unit_id, amount, turns, _debuff_status_for_effect(effect_type)))


static func _has_positive_damage_command'''
text,count=pattern.subn(replacement,text,count=1)
if count!=1: raise SystemExit('build commands block missing')
text=text.replace('''\tif ["aoe_damage_debuff", "trap_aoe", "flank_debuff_attack"].has(effect_type):
\t\tstatus_id = "defense_down"''','''\tif effect_type == "aoe_damage_debuff":
\t\tfor target in affected:
\t\t\tcommands.append(_command("status", target.unit_id, status_amount, turns, "accuracy_down"))
\t\t\tcommands.append(_command("status", target.unit_id, 1, turns, "movement_down"))
\t\treturn
\tif effect_type == "trap_aoe":
\t\tfor target in affected:
\t\t\tcommands.append(_command("status", target.unit_id, 2, turns, "movement_down"))
\t\t\tcommands.append(_command("status", target.unit_id, status_amount, turns, "formation_break"))
\t\treturn
\tif effect_type == "flank_debuff_attack":
\t\tstatus_id = "defense_down"''',1)
resolver_path.write_text(text,encoding='utf-8')

r=runtime_path.read_text(encoding='utf-8')
old='''\t\t\t"damage":
\t\t\t\tif target_state == null or not target_state.is_alive():
\t\t\t\t\tcontinue
\t\t\t\tvar adjusted_damage := _apply_wounded_incoming_damage_penalty(target_state, amount)
\t\t\t\tvar applied := target_state.apply_damage(adjusted_damage)
\t\t\t\tif applied <= 0:
\t\t\t\t\tcontinue
\t\t\t\tdamage_hits += 1
'''
new='''\t\t\t"damage":
\t\t\t\tif target_state == null or not target_state.is_alive():
\t\t\t\t\tcontinue
\t\t\t\tvar damage_flag := String(command.get("status_id", ""))
\t\t\t\tvar adjusted_damage := amount if damage_flag == "ignore_defense" else _get_directional_attack_damage(amount, caster_state, target_state, false, false)
\t\t\t\tvar was_alive := target_state.is_alive()
\t\t\t\tvar applied := target_state.apply_damage(adjusted_damage)
\t\t\t\tif applied <= 0:
\t\t\t\t\tcontinue
\t\t\t\tif damage_flag == "advance_on_kill" and was_alive and not target_state.is_alive():
\t\t\t\t\t_apply_resolver_advance_toward_target(caster_state, target_state)
\t\t\t\tdamage_hits += 1
'''
if old not in r: raise SystemExit('runtime damage anchor missing')
r=r.replace(old,new,1)
old='''\t\t\t\tvar status_turns := int(command.get("turns", 1))
\t\t\t\tif target_state == caster_state:
\t\t\t\t\tstatus_turns += 1
\t\t\t\ttarget_state.apply_status_effect(status_id, status_turns, amount)'''
new='''\t\t\t\tvar status_turns := int(command.get("turns", 1))
\t\t\t\tif target_state == caster_state:
\t\t\t\t\tstatus_turns += 1
\t\t\t\tif target_state.has_status_effect("status_resist") and target_state.side != caster_state.side:
\t\t\t\t\tstatus_turns = maxi(0, status_turns - 1)
\t\t\t\tif status_turns <= 0:
\t\t\t\t\tcontinue
\t\t\t\ttarget_state.apply_status_effect(status_id, status_turns, amount)'''
if old not in r: raise SystemExit('status anchor missing')
r=r.replace(old,new,1)
anchor='func _apply_resolver_retreat_move(unit_state: BattleUnitState, distance: int) -> void:'
helper='''func _apply_resolver_advance_toward_target(caster_state: BattleUnitState, defeated_state: BattleUnitState) -> void:
\tif caster_state == null or defeated_state == null or battle_grid_controller == null:
\t\treturn
\tvar delta := defeated_state.grid_cell - caster_state.grid_cell
\tvar step := Vector2i(signi(delta.x), 0) if absi(delta.x) >= absi(delta.y) else Vector2i(0, signi(delta.y))
\tvar destination := caster_state.grid_cell + step
\tif battle_grid_controller.is_in_bounds(destination) and _is_valid_destination_for_unit(destination, caster_state, true):
\t\tcaster_state.set_grid_cell(destination)


'''+anchor
if anchor not in r: raise SystemExit('retreat anchor missing')
r=r.replace(anchor,helper,1)
anchor='''\t\tif attacker_state.has_status_effect("counter_up"):
\t\t\tdamage_multiplier *= 1.0 + float(attacker_state.get_status_magnitude("counter_up", 15)) / 100.0'''
if anchor not in r: raise SystemExit('attacker multiplier anchor missing')
r=r.replace(anchor,anchor+'''\n\t\tif attacker_state.has_status_effect("flank_damage_up") and angle_type != ATTACK_ANGLE_FRONT:
\t\t\tdamage_multiplier *= 1.0 + float(attacker_state.get_status_magnitude("flank_damage_up", 15)) / 100.0''',1)
anchor='''\t\tif defender_state.has_status_effect("formation_break"):
\t\t\tdamage_multiplier *= 1.12'''
if anchor not in r: raise SystemExit('defender multiplier anchor missing')
r=r.replace(anchor,anchor+'''\n\t\tif defender_state.has_status_effect("flank_damage_taken_up") and angle_type != ATTACK_ANGLE_FRONT:
\t\t\tdamage_multiplier *= 1.0 + float(defender_state.get_status_magnitude("flank_damage_taken_up", 15)) / 100.0
\t\tif defender_state.has_status_effect("incoming_damage_down"):
\t\t\tdamage_multiplier *= 1.0 - float(defender_state.get_status_magnitude("incoming_damage_down", 12)) / 100.0''',1)
r=r.replace('''\tif unit_state.has_status_effect("mobility_up"):
\t\tmove_range += 1
\tif unit_state.has_status_effect("movement_down"):
\t\tmove_range -= 1''','''\tif unit_state.has_status_effect("mobility_up"):
\t\tmove_range += maxi(1, unit_state.get_status_magnitude("mobility_up", 1))
\tif unit_state.has_status_effect("movement_down"):
\t\tmove_range -= maxi(1, unit_state.get_status_magnitude("movement_down", 1))''',1)
r=r.replace('''\t\t"attack_defense_down",
\t\t"defense_down",
\t\t"movement_down",''','''\t\t"attack_defense_down",
\t\t"defense_down",
\t\t"accuracy_down",
\t\t"movement_down",
\t\t"momentum_gain_down",
\t\t"flank_damage_taken_up",''',1)
runtime_path.write_text(r,encoding='utf-8')
print('T06-8 calculation implementation applied')
