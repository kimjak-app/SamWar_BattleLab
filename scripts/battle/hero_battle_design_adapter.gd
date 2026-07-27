class_name HeroBattleDesignAdapter
extends RefCounted

const DESIGN_VERSION := 1

static func build_battle_contract(legacy_hero: Dictionary) -> Dictionary:
	var result := legacy_hero.duplicate(true)
	var hero_id := String(result.get("hero_id", result.get("id", "")))
	if hero_id.is_empty():
		result["design_adapter_error"] = "missing hero_id"
		return result

	if not HeroDesignDataRegistry.ensure_loaded():
		result["design_adapter_error"] = HeroDesignDataRegistry.get_load_error()
		return result

	var base_stats := HeroDesignDataRegistry.get_base_stats(hero_id)
	var profile := HeroDesignDataRegistry.get_battle_profile(hero_id)
	if base_stats.is_empty() or profile.is_empty():
		result["design_adapter_error"] = "missing design data for hero_id: %s" % hero_id
		return result

	var unit_type := String(profile.get("unit_type", ""))
	var primary_role := String(profile.get("primary_role", ""))
	var secondary_role := String(profile.get("secondary_role", ""))
	var skill_id := String(profile.get("unique_skill_id", ""))

	var unit_rule := HeroDesignDataRegistry.get_unit_type_rule(unit_type)
	var primary_role_rule := HeroDesignDataRegistry.get_battle_role_rule(primary_role)
	var unique_skill := HeroDesignDataRegistry.get_unique_skill(skill_id)
	if unit_rule.is_empty() or primary_role_rule.is_empty() or unique_skill.is_empty():
		result["design_adapter_error"] = "incomplete linked design data for hero_id: %s" % hero_id
		return result

	result["design_contract_version"] = DESIGN_VERSION
	result["design_stats"] = base_stats.get("stats", {}).duplicate(true)
	result["design_battle_multipliers"] = base_stats.get("battle_multipliers", {}).duplicate(true)
	result["design_profile"] = profile.duplicate(true)
	result["design_unit_rule"] = unit_rule.duplicate(true)
	result["design_primary_role_rule"] = primary_role_rule.duplicate(true)
	result["design_secondary_role"] = secondary_role
	result["design_unique_skill"] = unique_skill.duplicate(true)
	result.erase("design_adapter_error")
	return result

static func build_roster_contracts(legacy_heroes: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for hero_variant in legacy_heroes:
		if not hero_variant is Dictionary:
			continue
		result.append(build_battle_contract(hero_variant))
	return result

static func has_valid_design_contract(hero_contract: Dictionary) -> bool:
	return int(hero_contract.get("design_contract_version", 0)) == DESIGN_VERSION \
		and not hero_contract.has("design_adapter_error") \
		and hero_contract.get("design_stats", {}) is Dictionary \
		and hero_contract.get("design_profile", {}) is Dictionary \
		and hero_contract.get("design_unit_rule", {}) is Dictionary \
		and hero_contract.get("design_primary_role_rule", {}) is Dictionary \
		and hero_contract.get("design_unique_skill", {}) is Dictionary
