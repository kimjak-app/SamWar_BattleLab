class_name HeroBattleDesignInvocation
extends RefCounted

const HeroBattleDesignAdapterScript := preload("res://scripts/battle/hero_battle_design_adapter.gd")


static func enrich_worldmap_hero_contract(hero_data: Dictionary) -> Dictionary:
	if hero_data.is_empty():
		return {}
	var enriched := HeroBattleDesignAdapterScript.build_battle_hero_contract(hero_data)
	if enriched.is_empty():
		return hero_data.duplicate(true)
	return enriched


static func has_design_contract(hero_data: Dictionary) -> bool:
	return (
		hero_data.has("design_stats")
		and hero_data.has("design_profile")
		and hero_data.has("design_unit_rule")
		and hero_data.has("design_primary_role_rule")
	)
