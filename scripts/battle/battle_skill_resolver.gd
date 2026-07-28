class_name BattleSkillResolver
extends RefCounted

const RESOLVER_VERSION := 1
const VALID_ARCHETYPES := [
	"damage_single",
	"damage_line",
	"damage_area",
	"buff_self",
	"buff_team_area",
	"debuff_single",
	"debuff_area",
	"control_area",
	"restore_dispel",
	"movement_charge",
]
const ARCHETYPE_BY_EFFECT_TYPE := {
	"aoe_damage_debuff": "damage_area",
	"team_buff": "buff_team_area",
	"guard_aura": "buff_team_area",
	"line_damage": "damage_line",
	"team_mobility_buff": "buff_team_area",
	"trap_aoe": "damage_area",
	"single_debuff": "debuff_single",
	"ally_focus_buff": "buff_team_area",
	"charge_line": "damage_line",
	"naval_team_buff": "buff_team_area",
	"aoe_debuff": "debuff_area",
	"rally_restore": "restore_dispel",
	"adjacent_aoe": "damage_area",
	"skill_cost_debuff": "debuff_single",
	"team_command": "buff_team_area",
	"charge_damage": "damage_single",
	"team_support": "buff_team_area",
	"single_burst": "damage_single",
	"prediction_debuff": "debuff_single",
	"control_field": "control_area",
	"fear_aoe": "debuff_area",
	"team_morale": "buff_team_area",
	"splash_charge": "damage_single",
	"fire_aoe": "damage_area",
	"flank_debuff_attack": "damage_single",
	"gunner_volley": "damage_line",
	"stance_team_buff": "buff_team_area",
	"team_action_buff": "buff_team_area",
	"charge_aoe": "damage_area",
	"retreat_counter": "movement_charge",
	"team_logistics": "buff_team_area",
	"team_guard": "buff_team_area",
	"command_debuff": "debuff_single",
	"mounted_team_buff": "buff_team_area",
	"encirclement_debuff": "debuff_area",
	"single_ranged_damage": "damage_single",
}
const SELF_TARGET_MODES := ["self", "self_area", "self_area_enemy", "enemy_adjacent"]
const ALLY_TARGET_MODES := ["ally_area"]
const ENEMY_TARGET_MODES := [
	"single_enemy",
	"enemy_area",
	"enemy_line",
]


static func normalize_skill(raw_skill: Dictionary) -> Dictionary:
	var skill := raw_skill.duplicate(true)
	var effect_type := String(skill.get("effect_type", ""))
	var archetype := String(ARCHETYPE_BY_EFFECT_TYPE.get(effect_type, ""))
	skill["resolver_version"] = RESOLVER_VERSION
	skill["archetype"] = archetype
	skill["name"] = String(skill.get("display_name", skill.get("name", "고유기")))
	skill["toast_text"] = "%s!" % String(skill["name"])
	skill["consumes_action"] = int(skill.get("action_cost", 1)) > 0
	skill["cooldown_turns"] = maxi(int(skill.get("cooldown_turns", 0)), 0)
	skill["range"] = maxi(int(skill.get("range", 0)), 0)
	skill["radius"] = maxi(int(skill.get("radius", 0)), 0)
	skill["duration_turns"] = maxi(int(skill.get("duration_turns", 0)), 0)
	skill["momentum_cost"] = maxi(int(skill.get("momentum_cost", 0)), 0)
	return skill


static func validate_skill(raw_skill: Dictionary) -> Dictionary:
	var skill := normalize_skill(raw_skill)
	if String(skill.get("skill_id", "")).is_empty():
		return _failure("missing_skill_id")
	if String(skill.get("hero_id", "")).is_empty():
		return _failure("missing_hero_id")
	if not VALID_ARCHETYPES.has(String(skill.get("archetype", ""))):
		return _failure("unsupported_effect_type")
	if not SELF_TARGET_MODES.has(String(skill.get("target_mode", ""))) \
			and not ALLY_TARGET_MODES.has(String(skill.get("target_mode", ""))) \
			and not ENEMY_TARGET_MODES.has(String(skill.get("target_mode", ""))):
		return _failure("unsupported_target_mode")
	var momentum_cost := int(skill.get("momentum_cost", 0))
	if momentum_cost < 1 or momentum_cost > 4:
		return _failure("invalid_momentum_cost")
	return {"ok": true, "skill": skill}


static func get_valid_primary_targets(
	caster: BattleUnitState,
	raw_skill: Dictionary,
	units: Array[BattleUnitState]
) -> Array[BattleUnitState]:
	var result: Array[BattleUnitState] = []
	if caster == null or not caster.is_alive():
		return result
	var validation := validate_skill(raw_skill)
	if not bool(validation.get("ok", false)):
		return result
	var skill: Dictionary = validation.get("skill", {})
	var target_mode := String(skill.get("target_mode", ""))
	if SELF_TARGET_MODES.has(target_mode):
		result.append(caster)
		return result
	var skill_range := int(skill.get("range", 0))
	for unit in units:
		if unit == null or not unit.is_alive():
			continue
		if ALLY_TARGET_MODES.has(target_mode) and unit.side != caster.side:
			continue
		if ENEMY_TARGET_MODES.has(target_mode) and unit.side == caster.side:
			continue
		if _distance(caster, unit) > skill_range:
			continue
		result.append(unit)
	return result


static func build_plan(
	caster: BattleUnitState,
	raw_skill: Dictionary,
	units: Array[BattleUnitState],
	selected_target: BattleUnitState,
	available_momentum: int,
	battle_type: String = "land"
) -> Dictionary:
	if caster == null or not caster.is_alive():
		return _failure("invalid_caster")
	var validation := validate_skill(raw_skill)
	if not bool(validation.get("ok", false)):
		return validation
	var skill: Dictionary = validation.get("skill", {})
	var cost := maxi(int(raw_skill.get("effective_momentum_cost", skill.get("momentum_cost", 0))), 0)
	if available_momentum < cost:
		return _failure("insufficient_momentum")
	var valid_primary_targets := get_valid_primary_targets(caster, skill, units)
	if valid_primary_targets.is_empty():
		return _failure("no_valid_target")
	var target_mode := String(skill.get("target_mode", ""))
	var primary_target := selected_target
	if SELF_TARGET_MODES.has(target_mode):
		primary_target = caster
	if primary_target == null or not valid_primary_targets.has(primary_target):
		return _failure("invalid_target")
	var affected := _resolve_affected_targets(caster, skill, units, primary_target, battle_type)
	if affected.is_empty():
		return _failure("no_affected_target")
	var commands := _build_commands(caster, skill, affected, primary_target)
	if commands.is_empty():
		return _failure("empty_effect_plan")
	var target_ids: Array[String] = []
	for unit in affected:
		target_ids.append(unit.unit_id)
	return {
		"ok": true,
		"resolver_version": RESOLVER_VERSION,
		"skill_id": String(skill.get("skill_id", "")),
		"skill_name": String(skill.get("name", "")),
		"hero_id": String(skill.get("hero_id", "")),
		"caster_unit_id": caster.unit_id,
		"caster_side": caster.side,
		"archetype": String(skill.get("archetype", "")),
		"effect_type": String(skill.get("effect_type", "")),
		"momentum_cost": cost,
		"target_unit_ids": target_ids,
		"commands": commands,
	}


static func score_plan(plan: Dictionary, units_by_id: Dictionary) -> int:
	if not bool(plan.get("ok", false)):
		return -1000000
	var score := 0
	for command_variant in plan.get("commands", []):
		if not command_variant is Dictionary:
			continue
		var command: Dictionary = command_variant
		var command_type := String(command.get("type", ""))
		var amount := int(command.get("amount", 0))
		match command_type:
			"damage":
				score += amount * 4
				var target: BattleUnitState = units_by_id.get(String(command.get("target_unit_id", "")), null)
				if target != null and amount >= target.current_hp:
					score += 180
			"heal":
				score += amount * 2
			"status":
				score += 45 + int(command.get("turns", 0)) * 10
			"cleanse":
				score += 55
			"momentum":
				score += amount * 75
			"move":
				score += 35
	score -= int(plan.get("momentum_cost", 0)) * 30
	return score


static func _resolve_affected_targets(
	caster: BattleUnitState,
	skill: Dictionary,
	units: Array[BattleUnitState],
	primary_target: BattleUnitState,
	battle_type: String
) -> Array[BattleUnitState]:
	var result: Array[BattleUnitState] = []
	var target_mode := String(skill.get("target_mode", ""))
	var radius := int(skill.get("radius", 0))
	if battle_type != "naval" and String(skill.get("effect_type", "")) == "aoe_damage_debuff":
		radius = mini(radius, 2)
	if target_mode == "self":
		result.append(caster)
	elif target_mode == "single_enemy":
		result.append(primary_target)
	elif target_mode == "enemy_line":
		for unit in units:
			if unit != null and unit.is_alive() and unit.side != caster.side \
					and _is_on_line(caster.grid_cell, primary_target.grid_cell, unit.grid_cell) \
					and _distance(caster, unit) <= int(skill.get("range", 0)):
				result.append(unit)
	elif target_mode == "enemy_adjacent":
		for unit in units:
			if unit != null and unit.is_alive() and unit.side != caster.side \
					and _distance(caster, unit) <= maxi(radius, 1):
				result.append(unit)
	elif target_mode == "self_area_enemy":
		for unit in units:
			if unit != null and unit.is_alive() and unit.side != caster.side \
					and _distance(caster, unit) <= radius:
				result.append(unit)
	elif target_mode == "self_area":
		for unit in units:
			if unit != null and unit.is_alive() and unit.side == caster.side \
					and _distance(caster, unit) <= radius:
				result.append(unit)
	elif target_mode == "ally_area":
		for unit in units:
			if unit != null and unit.is_alive() and unit.side == caster.side \
					and _distance(primary_target, unit) <= radius:
				result.append(unit)
	elif target_mode == "enemy_area":
		for unit in units:
			if unit != null and unit.is_alive() and unit.side != caster.side \
					and _distance(primary_target, unit) <= radius:
				result.append(unit)
	return result


static func _build_commands(
	caster: BattleUnitState,
	skill: Dictionary,
	affected: Array[BattleUnitState],
	primary_target: BattleUnitState
) -> Array[Dictionary]:
	var commands: Array[Dictionary] = []
	var archetype := String(skill.get("archetype", ""))
	var effect_type := String(skill.get("effect_type", ""))
	var turns := maxi(int(skill.get("duration_turns", 0)), 1)
	var power := maxi(int(skill.get("power", 0)), 0)
	var damage := maxi(1, int(round(float(power) * 0.42 + float(caster.martial) * 0.12)))
	var status_amount := clampi(int(round(float(maxi(power, 40)) * 0.16)), 8, 20)
	match archetype:
		"damage_single", "damage_line", "damage_area":
			for target in affected:
				var target_damage := damage
				if archetype == "damage_area" and target != primary_target:
					target_damage = maxi(1, int(round(float(damage) * 0.72)))
				commands.append(_command("damage", target.unit_id, target_damage, 0, ""))
			_append_damage_secondary_commands(commands, effect_type, affected, turns, status_amount)
		"buff_self", "buff_team_area":
			for target in affected:
				commands.append(_command("status", target.unit_id, status_amount, turns, _buff_status_for_effect(effect_type)))
			if _grants_momentum(effect_type):
				commands.append(_command("momentum", caster.side, 1, 0, "skill_gain"))
		"debuff_single", "debuff_area", "control_area":
			for target in affected:
				commands.append(_command("status", target.unit_id, status_amount, turns, _debuff_status_for_effect(effect_type)))
			if _drains_momentum(effect_type):
				commands.append(_command("momentum", _opposing_side(caster.side), -1, 0, "skill_drain"))
		"restore_dispel":
			for target in affected:
				commands.append(_command("heal", target.unit_id, maxi(8, caster.intelligence / 4), 0, ""))
				commands.append(_command("cleanse", target.unit_id, 1, 0, "negative"))
				commands.append(_command("status", target.unit_id, 10, turns, "defense_up"))
		"movement_charge":
			commands.append(_command("move", caster.unit_id, 1, turns, "retreat"))
			commands.append(_command("status", caster.unit_id, 20, turns, "counter_up"))
	return commands


static func _append_damage_secondary_commands(
	commands: Array[Dictionary],
	effect_type: String,
	affected: Array[BattleUnitState],
	turns: int,
	status_amount: int
) -> void:
	var status_id := ""
	if ["aoe_damage_debuff", "trap_aoe", "flank_debuff_attack"].has(effect_type):
		status_id = "defense_down"
	elif effect_type == "fire_aoe":
		status_id = "burn"
	elif ["charge_damage", "charge_line", "charge_aoe", "splash_charge"].has(effect_type):
		status_id = "formation_break"
	elif effect_type == "single_ranged_damage":
		status_id = "movement_down"
	if status_id.is_empty():
		return
	for target in affected:
		commands.append(_command("status", target.unit_id, status_amount, turns, status_id))


static func _buff_status_for_effect(effect_type: String) -> String:
	if ["guard_aura", "team_guard", "team_morale"].has(effect_type):
		return "damage_reduction"
	if ["team_mobility_buff", "team_logistics", "mounted_team_buff"].has(effect_type):
		return "mobility_up"
	if effect_type == "team_support":
		return "defense_up"
	return "attack_defense_up"


static func _debuff_status_for_effect(effect_type: String) -> String:
	if effect_type == "skill_cost_debuff":
		return "skill_cost_up"
	if ["prediction_debuff", "control_field"].has(effect_type):
		return "action_lock"
	if effect_type == "fear_aoe":
		return "fear"
	if effect_type == "encirclement_debuff":
		return "defense_down"
	return "attack_defense_down"


static func _grants_momentum(effect_type: String) -> bool:
	return [
		"team_buff",
		"ally_focus_buff",
		"team_support",
		"team_morale",
	].has(effect_type)


static func _drains_momentum(effect_type: String) -> bool:
	return [
		"aoe_debuff",
		"skill_cost_debuff",
		"prediction_debuff",
		"command_debuff",
	].has(effect_type)


static func _command(
	command_type: String,
	target_id: String,
	amount: int,
	turns: int,
	status_id: String
) -> Dictionary:
	return {
		"type": command_type,
		"target_unit_id": target_id,
		"amount": amount,
		"turns": turns,
		"status_id": status_id,
	}


static func _distance(a: BattleUnitState, b: BattleUnitState) -> int:
	return absi(a.grid_cell.x - b.grid_cell.x) + absi(a.grid_cell.y - b.grid_cell.y)


static func _is_on_line(origin: Vector2i, primary: Vector2i, candidate: Vector2i) -> bool:
	var delta := primary - origin
	if absi(delta.x) >= absi(delta.y):
		return candidate.y == origin.y and signi(candidate.x - origin.x) == signi(delta.x)
	return candidate.x == origin.x and signi(candidate.y - origin.y) == signi(delta.y)


static func _opposing_side(side: String) -> String:
	return "enemy" if side == "ally" else "ally"


static func _failure(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}
