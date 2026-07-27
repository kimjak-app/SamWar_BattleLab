extends Node

const BATTLE_SCENE_PATH := "res://Battle_Land.tscn"
const HERO_ID_ALIASES := {
	"yi_sunsin": "yi_sun_sin",
	"gwon_yul": "kwon_yul",
	"gim_yusin": "kim_yu_sin",
}

var _integrated_scene_id := 0
var _battle_wait_frames := 0


func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene == null or scene.scene_file_path != BATTLE_SCENE_PATH:
		_integrated_scene_id = 0
		_battle_wait_frames = 0
		return
	var scene_id := scene.get_instance_id()
	if _integrated_scene_id == scene_id:
		return
	_battle_wait_frames += 1
	if _try_integrate_scene(scene):
		_integrated_scene_id = scene_id
		_battle_wait_frames = 0
	elif _battle_wait_frames >= 180:
		push_warning("[HERO_PROFILE_INTEGRATION] Battle scene found but no worldmap hero contracts were ready.")
		_integrated_scene_id = scene_id
		_battle_wait_frames = 0


func _try_integrate_scene(battle_root: Node) -> bool:
	if not HeroDesignDataRegistry.ensure_loaded():
		push_error("[HERO_PROFILE_INTEGRATION] %s" % HeroDesignDataRegistry.get_load_error())
		return true
	var registry_variant: Variant = battle_root.get("worldmap_context_hero_registry")
	if not registry_variant is Dictionary:
		return false
	var legacy_registry: Dictionary = registry_variant
	if legacy_registry.is_empty():
		return false

	var enriched_registry := {}
	var summary_by_hero := {}
	for registry_key_variant in legacy_registry.keys():
		var registry_key := String(registry_key_variant)
		var contract_variant: Variant = legacy_registry.get(registry_key, {})
		if not contract_variant is Dictionary:
			continue
		var legacy_contract: Dictionary = (contract_variant as Dictionary).duplicate(true)
		var source_hero_id := String(legacy_contract.get("hero_id", registry_key))
		var canonical_hero_id := _canonical_hero_id(source_hero_id)
		legacy_contract["hero_id"] = canonical_hero_id
		var enriched := HeroBattleDesignAdapter.build_battle_contract(legacy_contract)
		enriched["battle_context_hero_id"] = source_hero_id
		enriched_registry[registry_key] = enriched
		if HeroBattleDesignAdapter.has_valid_design_contract(enriched):
			summary_by_hero[canonical_hero_id] = _build_summary(enriched)

	battle_root.set("worldmap_context_hero_registry", enriched_registry)
	_enrich_unique_skill_registry(battle_root, summary_by_hero)
	_apply_profiles_to_unit_states(battle_root, summary_by_hero)
	battle_root.set_meta("hero_battle_profile_integration", summary_by_hero.duplicate(true))
	print("[HERO_PROFILE_INTEGRATION] applied=%d scene=%s" % [summary_by_hero.size(), BATTLE_SCENE_PATH])
	return true


func _enrich_unique_skill_registry(battle_root: Node, summary_by_hero: Dictionary) -> void:
	var skill_registry_variant: Variant = battle_root.get("worldmap_context_unique_skill_registry")
	if not skill_registry_variant is Dictionary:
		return
	var skill_registry: Dictionary = skill_registry_variant
	var enriched_skills := {}
	for key_variant in skill_registry.keys():
		var key := String(key_variant)
		var skill_variant: Variant = skill_registry.get(key, {})
		if not skill_variant is Dictionary:
			continue
		var skill: Dictionary = (skill_variant as Dictionary).duplicate(true)
		var canonical_hero_id := _canonical_hero_id(String(skill.get("hero_id", key)))
		var design_skill := HeroDesignDataRegistry.get_unique_skill_for_hero(canonical_hero_id)
		if not design_skill.is_empty():
			skill["design_unique_skill"] = design_skill
			skill["design_skill_inactive"] = true
		enriched_skills[key] = skill
	battle_root.set("worldmap_context_unique_skill_registry", enriched_skills)


func _apply_profiles_to_unit_states(battle_root: Node, summary_by_hero: Dictionary) -> void:
	var logged := {}
	for property_info_variant in battle_root.get_property_list():
		if not property_info_variant is Dictionary:
			continue
		var property_info: Dictionary = property_info_variant
		var property_name := String(property_info.get("name", ""))
		if property_name.is_empty():
			continue
		var value: Variant = battle_root.get(property_name)
		if not value is BattleUnitState:
			continue
		var unit_state: BattleUnitState = value
		var source_hero_id := _hero_id_from_unit_state(unit_state)
		var canonical_hero_id := _canonical_hero_id(source_hero_id)
		if canonical_hero_id.is_empty() or not summary_by_hero.has(canonical_hero_id):
			continue
		var summary: Dictionary = summary_by_hero.get(canonical_hero_id, {})
		unit_state.unit_type = String(summary.get("unit_type", unit_state.unit_type))
		unit_state.move_range = int(summary.get("move_range", unit_state.move_range))
		unit_state.attack_range = int(summary.get("attack_range", unit_state.attack_range))
		unit_state.status_effects["design_primary_role"] = String(summary.get("primary_role", ""))
		unit_state.status_effects["design_secondary_role"] = String(summary.get("secondary_role", ""))
		if not logged.has(canonical_hero_id):
			logged[canonical_hero_id] = true
			print("[HERO_PROFILE] hero=%s unit=%s role=%s move=%d range=%d" % [
				canonical_hero_id,
				unit_state.unit_type,
				String(summary.get("primary_role", "")),
				unit_state.move_range,
				unit_state.attack_range,
			])


func _build_summary(contract: Dictionary) -> Dictionary:
	var profile: Dictionary = contract.get("design_profile", {})
	var unit_rule: Dictionary = contract.get("design_unit_rule", {})
	return {
		"hero_id": String(profile.get("hero_id", contract.get("hero_id", ""))),
		"unit_type": String(profile.get("unit_type", "infantry")),
		"primary_role": String(profile.get("primary_role", "")),
		"secondary_role": String(profile.get("secondary_role", "")),
		"move_range": int(unit_rule.get("move_range", 0)),
		"attack_range": int(unit_rule.get("attack_range", 0)),
		"unique_skill_id": String(profile.get("unique_skill_id", "")),
	}


func _hero_id_from_unit_state(unit_state: BattleUnitState) -> String:
	var unit_id := unit_state.unit_id
	if unit_id.ends_with("_battle_unit"):
		return unit_id.trim_suffix("_battle_unit")
	return ""


func _canonical_hero_id(hero_id: String) -> String:
	return String(HERO_ID_ALIASES.get(hero_id, hero_id))
