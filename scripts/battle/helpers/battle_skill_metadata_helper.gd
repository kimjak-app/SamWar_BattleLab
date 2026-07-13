class_name BattleSkillMetadataHelper
extends RefCounted


static func get_specialty_skill_cutin_config(configs: Dictionary, hero_id: String, fallback_hero_id: String) -> Dictionary:
	return configs.get(hero_id, configs.get(fallback_hero_id, {}))


static func get_specialty_skill_cutin_config_float(config: Dictionary, key: String, fallback: float) -> float:
	return float(config.get(key, fallback))
