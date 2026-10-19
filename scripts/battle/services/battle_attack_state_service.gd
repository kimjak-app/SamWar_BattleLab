class_name BattleAttackStateService
extends RefCounted

const UnitTypeContract = preload("res://scripts/battle/unit_type_contract.gd")

# Called at the existing damage write, after the controller computes the formula.
# No validation policy, presentation, scheduling, or action consumption here.
func apply_attack_damage(attacker: BattleUnitState, target: BattleUnitState, damage: int, angle: String) -> Dictionary:
	var troops_before := target.current_troops
	var defending := target.is_defending
	var applied := target.apply_damage(damage)
	return {"damage_applied":applied, "fields":{
		"attacker_id":attacker.unit_id, "target_id":target.unit_id,
		"angle_type":angle, "damage_requested":damage, "damage_applied":applied,
		"troops_before":troops_before, "troops_after":target.current_troops,
		"target_defending":defending, "killed":not target.is_alive()}}

# Split around the original gunner log calls to preserve write/log ordering.
func commit_attack_metadata(attacker: BattleUnitState) -> void:
	attacker.attacked_this_turn = true
	attacker.last_action = {
		"type": "attack",
		"origin_cell": [attacker.grid_cell.x, attacker.grid_cell.y],
		"destination_cell": [attacker.grid_cell.x, attacker.grid_cell.y],
		"moved_distance": int(attacker.last_action.get("moved_distance", 0)),
	}

func apply_post_fire_penalty(attacker: BattleUnitState) -> void:
	attacker.apply_status_effect("post_fire_penalty", 1, 40)

func commit_post_attack_movement(attacker: BattleUnitState) -> void:
	if UnitTypeContract.can_move_after_attack(attacker.unit_type):
		attacker.post_attack_move_available = true
		attacker.remaining_post_attack_move = UnitTypeContract.get_post_attack_move_limit(attacker.unit_type)
