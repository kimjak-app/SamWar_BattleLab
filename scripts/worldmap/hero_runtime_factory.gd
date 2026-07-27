class_name HeroRuntimeFactory
extends RefCounted

const RUNTIME_SCHEMA_VERSION := 1
const LOYALTY_SCHEMA_VERSION := 1
const ALLOWED_UNIT_TYPES := {
	"infantry": true,
	"cavalry": true,
	"archer": true,
	"gunner": true,
	"mounted_archer": true,
}


static func build_runtime_hero(identity: Dictionary, saved_state: Dictionary = {}) -> Dictionary:
	var result := identity.duplicate(true)
	var hero_id := String(result.get("hero_id", result.get("id", "")))
	if hero_id.is_empty():
		return _error_result(result, "missing hero_id")
	if not HeroDesignDataRegistry.ensure_loaded():
		return _error_result(result, HeroDesignDataRegistry.get_load_error())

	var base := HeroDesignDataRegistry.get_base_stats(hero_id)
	var profile := HeroDesignDataRegistry.get_battle_profile(hero_id)
	if base.is_empty() or profile.is_empty():
		return _error_result(result, "missing design data for hero_id: %s" % hero_id)

	var stats_variant: Variant = base.get("stats", {})
	if not stats_variant is Dictionary:
		return _error_result(result, "invalid stats for hero_id: %s" % hero_id)
	var stats: Dictionary = stats_variant
	var unit_type := String(profile.get("unit_type", ""))
	if not ALLOWED_UNIT_TYPES.has(unit_type):
		return _error_result(result, "invalid unit_type for hero_id %s: %s" % [hero_id, unit_type])

	result["id"] = hero_id
	result["hero_id"] = hero_id
	result["display_name"] = String(base.get("display_name", result.get("display_name", result.get("name", hero_id))))
	result["name"] = String(result.get("name", result.get("display_name", hero_id)))

	var leadership := int(stats.get("leadership", 0))
	var martial := int(stats.get("martial", 0))
	result["leadership"] = leadership
	result["command"] = leadership
	result["martial"] = martial
	result["war"] = martial
	result["intelligence"] = int(stats.get("intelligence", 0))
	result["politics"] = int(stats.get("politics", 0))

	var initial_loyalty := HeroDesignDataRegistry.get_initial_loyalty(hero_id, 80)
	var current_loyalty := initial_loyalty
	if not saved_state.is_empty() and saved_state.has("loyalty"):
		current_loyalty = clampi(int(saved_state.get("loyalty", initial_loyalty)), 0, 100)
	elif result.has("runtime_loyalty"):
		current_loyalty = clampi(int(result.get("runtime_loyalty", initial_loyalty)), 0, 100)
	result["initial_loyalty"] = initial_loyalty
	result["loyalty"] = current_loyalty

	result["unit_type"] = unit_type
	result["visual_key"] = unit_type
	result["primary_role"] = String(profile.get("primary_role", ""))
	result["secondary_role"] = String(profile.get("secondary_role", ""))
	result["design_unique_skill_id"] = String(profile.get("unique_skill_id", ""))
	if not result.has("unique_skill_id"):
		result["unique_skill_id"] = result["design_unique_skill_id"]

	var unit_rule := HeroDesignDataRegistry.get_unit_type_rule(unit_type)
	if unit_rule.is_empty():
		return _error_result(result, "missing unit rule for hero_id %s: %s" % [hero_id, unit_type])
	result["move_range"] = int(unit_rule.get("move_range", result.get("move_range", 0)))
	result["mobility"] = int(result["move_range"])
	result["attack_range"] = int(unit_rule.get("attack_range", result.get("attack_range", 0)))

	_apply_saved_mutable_state(result, saved_state)
	result["runtime_schema_version"] = RUNTIME_SCHEMA_VERSION
	result["loyalty_schema_version"] = LOYALTY_SCHEMA_VERSION
	result.erase("runtime_factory_error")
	return result


static func build_runtime_registry(identity_registry: Dictionary, saved_registry: Dictionary = {}) -> Dictionary:
	var result := {}
	for key_variant in identity_registry.keys():
		var key := String(key_variant)
		var identity_variant: Variant = identity_registry.get(key, {})
		if not identity_variant is Dictionary:
			continue
		var identity: Dictionary = identity_variant
		var hero_id := String(identity.get("hero_id", identity.get("id", key)))
		var saved_variant: Variant = saved_registry.get(hero_id, saved_registry.get(key, {}))
		var saved_state: Dictionary = saved_variant if saved_variant is Dictionary else {}
		var runtime_hero := build_runtime_hero(identity, saved_state)
		result[key] = runtime_hero
	return result


static func build_battle_unit_payload(runtime_hero: Dictionary, overrides: Dictionary = {}) -> Dictionary:
	var result := runtime_hero.duplicate(true)
	for key_variant in overrides.keys():
		result[key_variant] = overrides.get(key_variant)
	var hero_id := String(result.get("hero_id", result.get("id", "")))
	if hero_id.is_empty():
		return _error_result(result, "battle payload missing hero_id")
	var unit_type := String(result.get("unit_type", ""))
	if not ALLOWED_UNIT_TYPES.has(unit_type):
		return _error_result(result, "battle payload invalid unit_type: %s" % unit_type)
	result["visual_key"] = unit_type
	result["hero_name"] = String(result.get("display_name", result.get("name", hero_id)))
	return result


static func format_stat_line(runtime_hero: Dictionary) -> String:
	return "지휘 %d / 무 %d / 지 %d / 정 %d / 충 %d" % [
		int(runtime_hero.get("leadership", runtime_hero.get("command", 0))),
		int(runtime_hero.get("martial", runtime_hero.get("war", 0))),
		int(runtime_hero.get("intelligence", 0)),
		int(runtime_hero.get("politics", 0)),
		int(runtime_hero.get("loyalty", runtime_hero.get("initial_loyalty", 0))),
	]


static func is_valid_runtime_hero(hero: Dictionary) -> bool:
	return int(hero.get("runtime_schema_version", 0)) == RUNTIME_SCHEMA_VERSION \
		and not hero.has("runtime_factory_error") \
		and ALLOWED_UNIT_TYPES.has(String(hero.get("unit_type", ""))) \
		and String(hero.get("hero_id", "")) != ""


static func _apply_saved_mutable_state(result: Dictionary, saved_state: Dictionary) -> void:
	if saved_state.is_empty():
		return
	var mutable_keys := [
		"troops",
		"troop_count",
		"current_troops",
		"max_troops",
		"current_hp",
		"max_hp",
		"status",
		"injury_state",
		"assigned_city_id",
		"city_id",
		"location_city_id",
		"faction_id",
		"force_id",
		"side",
		"nation",
	]
	for key in mutable_keys:
		if saved_state.has(key):
			result[key] = saved_state.get(key)


static func _error_result(result: Dictionary, message: String) -> Dictionary:
	result["runtime_factory_error"] = message
	return result
