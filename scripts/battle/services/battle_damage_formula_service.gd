class_name BattleDamageFormulaService
extends RefCounted

const UnitTypeContractScript := preload("res://scripts/battle/unit_type_contract.gd")

const ATTACK_ANGLE_FRONT := "front"
const ATTACK_ANGLE_SIDE := "side"
const ATTACK_ANGLE_BACK := "back"
const FRONT_ATTACK_DAMAGE_MULTIPLIER := 1.0
const SIDE_ATTACK_DAMAGE_MULTIPLIER := 1.15
const BACK_ATTACK_DAMAGE_MULTIPLIER := 1.3
const STRATEGY_SHAKE_ATTACK_MULTIPLIER := 0.9
const STRATEGY_SHAKE_DEFENSE_DAMAGE_MULTIPLIER := 1.1
const DEFEND_DAMAGE_MULTIPLIER := 0.62
const STATUS_SHAKE := "shake"
const UNIT_TYPE_GUNNER := "gunner"


func get_attack_angle_damage_multiplier(angle_type: String) -> float:
	match angle_type:
		ATTACK_ANGLE_BACK:
			return BACK_ATTACK_DAMAGE_MULTIPLIER
		ATTACK_ANGLE_SIDE:
			return SIDE_ATTACK_DAMAGE_MULTIPLIER
		_:
			return FRONT_ATTACK_DAMAGE_MULTIPLIER


func calculate_pre_wounded_damage(base_damage: int, attacker_state: BattleUnitState, defender_state: BattleUnitState, angle_type: String) -> int:
	var damage_multiplier := get_attack_angle_damage_multiplier(angle_type)
	var unit_context := UnitTypeContractScript.get_damage_context(attacker_state.unit_type, defender_state.unit_type, angle_type) if attacker_state != null and defender_state != null else {}
	damage_multiplier *= float(unit_context.get("base_damage_modifier", 1.0))
	damage_multiplier *= 1.0 + float(unit_context.get("matchup_modifier", 0.0))
	damage_multiplier *= 1.0 + float(unit_context.get("side_or_rear_modifier", 0.0))
	damage_multiplier *= float(unit_context.get("received_damage_modifier", 1.0))
	if attacker_state != null and attacker_state.unit_type == UNIT_TYPE_GUNNER:
		if not attacker_state.has_moved:
			damage_multiplier *= 1.0 + UnitTypeContractScript.get_number(UNIT_TYPE_GUNNER, "prepared_fire_bonus")
		if attacker_state.has_status_effect("post_fire_penalty"):
			damage_multiplier *= 1.0 - float(attacker_state.get_status_magnitude("post_fire_penalty", 40)) / 100.0
	if attacker_state != null and attacker_state.has_status_effect(STATUS_SHAKE):
		damage_multiplier *= STRATEGY_SHAKE_ATTACK_MULTIPLIER
	if defender_state != null and defender_state.has_status_effect(STATUS_SHAKE):
		damage_multiplier *= STRATEGY_SHAKE_DEFENSE_DAMAGE_MULTIPLIER
	if defender_state != null and defender_state.is_defending:
		damage_multiplier *= DEFEND_DAMAGE_MULTIPLIER
	if attacker_state != null:
		if attacker_state.has_status_effect("attack_defense_up"):
			damage_multiplier *= 1.0 + float(attacker_state.get_status_magnitude("attack_defense_up", 10)) / 100.0
		if attacker_state.has_status_effect("attack_defense_down"):
			damage_multiplier *= 1.0 - float(attacker_state.get_status_magnitude("attack_defense_down", 10)) / 100.0
		if attacker_state.has_status_effect("counter_up"):
			damage_multiplier *= 1.0 + float(attacker_state.get_status_magnitude("counter_up", 15)) / 100.0
		if attacker_state.has_status_effect("flank_damage_up") and angle_type != ATTACK_ANGLE_FRONT:
			damage_multiplier *= 1.0 + float(attacker_state.get_status_magnitude("flank_damage_up", 15)) / 100.0
	if defender_state != null:
		if defender_state.has_status_effect("defense_up") or defender_state.has_status_effect("attack_defense_up"):
			damage_multiplier *= 1.0 - float(defender_state.get_status_magnitude("defense_up", defender_state.get_status_magnitude("attack_defense_up", 10))) / 100.0
		if defender_state.has_status_effect("defense_down") or defender_state.has_status_effect("attack_defense_down"):
			damage_multiplier *= 1.0 + float(defender_state.get_status_magnitude("defense_down", defender_state.get_status_magnitude("attack_defense_down", 10))) / 100.0
		if defender_state.has_status_effect("damage_reduction"):
			damage_multiplier *= 1.0 - float(defender_state.get_status_magnitude("damage_reduction", 12)) / 100.0
		if defender_state.has_status_effect("formation_break"):
			damage_multiplier *= 1.12
		if defender_state.has_status_effect("flank_damage_taken_up") and angle_type != ATTACK_ANGLE_FRONT:
			damage_multiplier *= 1.0 + float(defender_state.get_status_magnitude("flank_damage_taken_up", 15)) / 100.0
		if defender_state.has_status_effect("incoming_damage_down"):
			damage_multiplier *= 1.0 - float(defender_state.get_status_magnitude("incoming_damage_down", 12)) / 100.0
	var damage := maxi(1, int(round(float(base_damage) * damage_multiplier)))
	if attacker_state != null and attacker_state.unit_type == UNIT_TYPE_GUNNER:
		var armor_ignore := float(unit_context.get("armor_ignore_ratio", 0.0))
		var effective_defense := maxf(0.0, float(defender_state.defense) * (1.0 - armor_ignore))
		damage = maxi(1, int(round(float(damage) * (1.0 + maxf(0.0, float(defender_state.defense) - effective_defense) / 100.0))))
	return damage
