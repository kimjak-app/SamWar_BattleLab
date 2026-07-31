class_name UnitTypeContract
extends RefCounted

const CANONICAL_UNIT_TYPES := [
	"infantry",
	"cavalry",
	"archer",
	"gunner",
	"mounted_archer",
]


static func is_supported(unit_type: String) -> bool:
	return CANONICAL_UNIT_TYPES.has(unit_type)


static func get_rule(unit_type: String) -> Dictionary:
	if not is_supported(unit_type):
		return {}
	return HeroDesignDataRegistry.get_unit_type_rule(unit_type)


static func get_display_name(unit_type: String, fallback: String = "") -> String:
	return String(get_rule(unit_type).get("display_name", fallback))


static func get_move_range(unit_type: String) -> int:
	return maxi(0, int(get_rule(unit_type).get("move_range", 0)))


static func get_minimum_attack_range(unit_type: String) -> int:
	return maxi(0, int(get_rule(unit_type).get("minimum_attack_range", 1)))


static func get_maximum_attack_range(unit_type: String) -> int:
	var rule := get_rule(unit_type)
	return maxi(get_minimum_attack_range(unit_type), int(rule.get("maximum_attack_range", rule.get("attack_range", 0))))


static func get_counterattack_min_range(unit_type: String) -> int:
	return maxi(0, int(get_rule(unit_type).get("counterattack_min_range", 0)))


static func get_counterattack_max_range(unit_type: String) -> int:
	return maxi(0, int(get_rule(unit_type).get("counterattack_max_range", 0)))


static func can_attack_after_move(unit_type: String) -> bool:
	return bool(get_rule(unit_type).get("can_attack_after_move", true))


static func can_move_after_attack(unit_type: String) -> bool:
	return bool(get_rule(unit_type).get("can_move_after_attack", false))


static func get_post_attack_move_limit(unit_type: String) -> int:
	return maxi(0, int(get_rule(unit_type).get("post_attack_move_limit", 0)))


static func get_number(unit_type: String, key: String, fallback: float = 0.0) -> float:
	return float(get_rule(unit_type).get(key, fallback))


static func get_string(unit_type: String, key: String, fallback: String = "") -> String:
	return String(get_rule(unit_type).get(key, fallback))


static func is_attack_distance_valid(unit_type: String, distance: int) -> bool:
	return distance >= get_minimum_attack_range(unit_type) and distance <= get_maximum_attack_range(unit_type)


static func is_counterattack_distance_valid(unit_type: String, distance: int) -> bool:
	var minimum_range := get_counterattack_min_range(unit_type)
	var maximum_range := get_counterattack_max_range(unit_type)
	return maximum_range > 0 and distance >= minimum_range and distance <= maximum_range


static func can_target_at_distance(unit_type: String, distance: int) -> bool:
	return is_attack_distance_valid(unit_type, distance)


static func can_counterattack_at_distance(unit_type: String, distance: int) -> bool:
	return is_counterattack_distance_valid(unit_type, distance)


static func can_unit_attack(unit_type: String, has_moved: bool, has_acted: bool, distance: int) -> bool:
	return not has_acted and (not has_moved or can_attack_after_move(unit_type)) and can_target_at_distance(unit_type, distance)


static func get_damage_context(attacker_type: String, defender_type: String, attack_angle: String = "front") -> Dictionary:
	var attacker := get_rule(attacker_type)
	var defender := get_rule(defender_type)
	var matchup := 0.0
	if attacker_type == "infantry" and defender_type == "cavalry": matchup = 0.08
	elif attacker_type == "cavalry" and defender_type in ["archer", "gunner"]: matchup = 0.10
	elif attacker_type == "archer" and defender_type == "infantry": matchup = 0.08
	elif attacker_type == "gunner" and defender_type == "infantry": matchup = 0.10
	return {"attacker_unit_type": attacker_type, "defender_unit_type": defender_type, "base_damage_modifier": float(attacker.get("base_damage_modifier", 1.0)), "received_damage_modifier": float(defender.get("received_damage_modifier", 1.0)), "matchup_modifier": matchup, "armor_ignore_ratio": float(attacker.get("armor_ignore_ratio", 0.0)), "side_or_rear_modifier": float(attacker.get("side_attack_modifier", 0.0)) if attack_angle == "side" else float(attacker.get("rear_attack_modifier", 0.0)) if attack_angle == "back" else 0.0}
