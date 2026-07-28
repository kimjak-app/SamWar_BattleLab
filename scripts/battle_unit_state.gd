class_name BattleUnitState
extends RefCounted

const HeroRuntimeFactoryScript := preload("res://scripts/worldmap/hero_runtime_factory.gd")
const HeroDefinitionRegistryScript := preload("res://scripts/worldmap/hero_definition_registry.gd")
const HERO_ID_ALIASES := {
	"yi_sunsin": "yi_sun_sin",
	"gwon_yul": "kwon_yul",
	"gim_yusin": "kim_yu_sin",
}

var _is_setting_up := false
var unit_id: String = "":
	set(value):
		unit_id = value
		if not _is_setting_up:
			_rebuild_authority_for_runtime_unit_id(value)
var display_name: String = ""
var side: String = ""
var slot_id: String = ""
var hero_name: String = ""
var nation: String = ""
var unit_type: String = "infantry"
var visual_key: String = ""
var portrait_key: String = ""
var domain: String = "land"
var footprint: String = "1x1"
var move_fx_profile: String = "dust"
var attack_fx_profile: String = "slash"
var click_area_profile: String = "standard_1x1"
var visual_scale_profile: String = "standard_256"
var current_hp: int = 0
var max_hp: int = 0
var current_troops: int = 0
var max_troops: int = 0
var allocated_troops: int = 0
var initial_allocated_troops: int = 0
var attack: int = 0
var defense: int = 0
var intelligence: int = 0
var martial: int = 0
var move_range: int = 0
var attack_range: int = 0
var unique_skill_id: String = ""
var unique_skill_definition: Dictionary = {}
var grid_cell: Vector2i = Vector2i.ZERO
var facing: String = "right"
var has_acted: bool = false
var has_moved: bool = false
var is_defending: bool = false
var last_action: Dictionary = {}
var status_effects: Dictionary = {}


func setup(data: Dictionary) -> void:
	_is_setting_up = true
	var authoritative_data := _build_authoritative_payload(data)
	unit_id = String(authoritative_data.get("unit_id", ""))
	display_name = String(authoritative_data.get("display_name", ""))
	side = String(authoritative_data.get("side", ""))
	slot_id = String(authoritative_data.get("slot_id", ""))
	hero_name = String(authoritative_data.get("hero_name", display_name))
	nation = String(authoritative_data.get("nation", ""))
	unit_type = String(authoritative_data.get("unit_type", "infantry"))
	visual_key = String(authoritative_data.get("visual_key", unit_type))
	if visual_key != unit_type:
		visual_key = unit_type
	portrait_key = String(authoritative_data.get("portrait_key", hero_name))
	domain = String(authoritative_data.get("domain", "land"))
	footprint = String(authoritative_data.get("footprint", "1x1"))
	move_fx_profile = String(authoritative_data.get("move_fx_profile", "dust"))
	attack_fx_profile = String(authoritative_data.get("attack_fx_profile", "slash"))
	click_area_profile = String(authoritative_data.get("click_area_profile", "standard_1x1"))
	visual_scale_profile = String(authoritative_data.get("visual_scale_profile", "standard_256"))
	current_hp = int(authoritative_data.get("current_hp", 0))
	max_hp = int(authoritative_data.get("max_hp", current_hp))
	current_troops = int(authoritative_data.get("current_troops", current_hp))
	max_troops = int(authoritative_data.get("max_troops", max_hp))
	allocated_troops = maxi(0, int(authoritative_data.get("allocated_troops", authoritative_data.get("troops", current_troops))))
	initial_allocated_troops = maxi(0, int(authoritative_data.get("initial_allocated_troops", allocated_troops)))
	attack = int(authoritative_data.get("attack", 0))
	defense = int(authoritative_data.get("defense", 0))
	intelligence = int(authoritative_data.get("intelligence", 0))
	martial = int(authoritative_data.get("martial", authoritative_data.get("war", attack)))
	move_range = int(authoritative_data.get("move_range", 0))
	attack_range = int(authoritative_data.get("attack_range", 0))
	unique_skill_id = String(authoritative_data.get("design_unique_skill_id", authoritative_data.get("unique_skill_id", "")))
	var raw_unique_skill: Variant = authoritative_data.get("design_unique_skill", {})
	unique_skill_definition = (raw_unique_skill as Dictionary).duplicate(true) if raw_unique_skill is Dictionary else {}
	grid_cell = authoritative_data.get("grid_cell", Vector2i.ZERO)
	facing = String(authoritative_data.get("facing", "right"))
	has_acted = bool(authoritative_data.get("has_acted", false))
	has_moved = bool(authoritative_data.get("has_moved", false))
	is_defending = bool(authoritative_data.get("is_defending", false))
	var raw_last_action = authoritative_data.get("last_action", {})
	if raw_last_action is Dictionary:
		last_action = (raw_last_action as Dictionary).duplicate(true)
	else:
		last_action = {}
	var raw_status_effects = authoritative_data.get("status_effects", {})
	if raw_status_effects is Dictionary:
		status_effects = (raw_status_effects as Dictionary).duplicate(true)
	else:
		status_effects = {}
	_is_setting_up = false


static func create(data: Dictionary) -> BattleUnitState:
	var state := BattleUnitState.new()
	state.setup(data)
	return state


static func _build_authoritative_payload(data: Dictionary) -> Dictionary:
	var hero_id := _resolve_hero_id(data)
	if hero_id.is_empty():
		return data.duplicate(true)
	var runtime_registry: Dictionary = HeroDefinitionRegistryScript.HERO_DATA
	if not runtime_registry.has(hero_id):
		return data.duplicate(true)
	var runtime_variant: Variant = runtime_registry.get(hero_id, {})
	if not runtime_variant is Dictionary:
		return data.duplicate(true)
	var runtime_hero: Dictionary = runtime_variant
	var payload := HeroRuntimeFactoryScript.build_battle_unit_payload(runtime_hero, data)
	if not HeroRuntimeFactoryScript.is_valid_runtime_hero(payload):
		push_error("[BATTLE_UNIT_AUTHORITY] Failed to build authoritative payload for %s: %s" % [
			hero_id,
			String(payload.get("runtime_factory_error", "unknown error")),
		])
		return data.duplicate(true)
	payload["hero_id"] = hero_id
	payload["unit_type"] = String(payload.get("unit_type", "infantry"))
	payload["visual_key"] = payload["unit_type"]
	return payload


func _rebuild_authority_for_runtime_unit_id(value: String) -> void:
	var hero_id := value
	if hero_id.ends_with("_battle_unit"):
		hero_id = hero_id.trim_suffix("_battle_unit")
	hero_id = _canonical_hero_id(hero_id)
	if hero_id.is_empty() or not HeroDefinitionRegistryScript.HERO_DATA.has(hero_id):
		return
	var payload := _build_authoritative_payload({
		"hero_id": hero_id,
		"unit_id": value,
		"side": side,
		"slot_id": slot_id,
		"current_hp": current_hp,
		"max_hp": max_hp,
		"current_troops": current_troops,
		"max_troops": max_troops,
		"allocated_troops": allocated_troops,
		"initial_allocated_troops": initial_allocated_troops,
		"grid_cell": grid_cell,
		"facing": facing,
		"has_acted": has_acted,
		"has_moved": has_moved,
		"is_defending": is_defending,
		"last_action": last_action,
		"status_effects": status_effects,
	})
	if not HeroRuntimeFactoryScript.is_valid_runtime_hero(payload):
		return
	display_name = String(payload.get("display_name", display_name))
	hero_name = String(payload.get("hero_name", display_name))
	nation = String(payload.get("nation", nation))
	unit_type = String(payload.get("unit_type", unit_type))
	visual_key = unit_type
	portrait_key = String(payload.get("portrait_key", hero_name))
	domain = String(payload.get("domain", domain))
	footprint = String(payload.get("footprint", footprint))
	move_fx_profile = String(payload.get("move_fx_profile", move_fx_profile))
	attack_fx_profile = String(payload.get("attack_fx_profile", attack_fx_profile))
	click_area_profile = String(payload.get("click_area_profile", click_area_profile))
	visual_scale_profile = String(payload.get("visual_scale_profile", visual_scale_profile))
	attack = int(payload.get("attack", attack))
	defense = int(payload.get("defense", defense))
	intelligence = int(payload.get("intelligence", intelligence))
	martial = int(payload.get("martial", payload.get("war", martial)))
	move_range = int(payload.get("move_range", move_range))
	attack_range = int(payload.get("attack_range", attack_range))
	unique_skill_id = String(payload.get("design_unique_skill_id", payload.get("unique_skill_id", unique_skill_id)))
	var raw_unique_skill: Variant = payload.get("design_unique_skill", unique_skill_definition)
	if raw_unique_skill is Dictionary:
		unique_skill_definition = (raw_unique_skill as Dictionary).duplicate(true)


static func _resolve_hero_id(data: Dictionary) -> String:
	var direct_candidates := [
		String(data.get("hero_id", "")),
		String(data.get("design_hero_id", "")),
	]
	var unit_id_candidate := String(data.get("unit_id", ""))
	if unit_id_candidate.ends_with("_battle_unit"):
		direct_candidates.append(unit_id_candidate.trim_suffix("_battle_unit"))
	for candidate_variant in direct_candidates:
		var candidate := _canonical_hero_id(String(candidate_variant))
		if not candidate.is_empty() and HeroDefinitionRegistryScript.HERO_DATA.has(candidate):
			return candidate
	var display_candidates := [
		String(data.get("hero_name", "")).strip_edges(),
		String(data.get("display_name", "")).strip_edges(),
		String(data.get("name", "")).strip_edges(),
	]
	for key_variant in HeroDefinitionRegistryScript.HERO_DATA.keys():
		var registry_hero_id := String(key_variant)
		var hero_variant: Variant = HeroDefinitionRegistryScript.HERO_DATA.get(registry_hero_id, {})
		if not hero_variant is Dictionary:
			continue
		var hero: Dictionary = hero_variant
		var registered_names := [
			String(hero.get("display_name", "")).strip_edges(),
			String(hero.get("name", "")).strip_edges(),
		]
		for display_candidate_variant in display_candidates:
			var display_candidate := String(display_candidate_variant)
			if not display_candidate.is_empty() and registered_names.has(display_candidate):
				return registry_hero_id
	return ""


static func _canonical_hero_id(hero_id: String) -> String:
	return String(HERO_ID_ALIASES.get(hero_id, hero_id))


func is_alive() -> bool:
	return current_hp > 0 and current_troops > 0


func apply_damage(amount: int) -> int:
	var damage: int = maxi(0, amount)
	var applied: int = mini(damage, current_hp)
	current_hp = maxi(0, current_hp - damage)
	current_troops = maxi(0, current_troops - damage)
	return applied


func heal(amount: int) -> int:
	var healing: int = maxi(0, amount)
	var previous_hp: int = current_hp
	current_hp = mini(max_hp, current_hp + healing)
	current_troops = mini(max_troops, current_troops + healing)
	return current_hp - previous_hp


func reset_action_flags() -> void:
	has_acted = false
	has_moved = false
	is_defending = false
	last_action = {}


func get_status_turns(effect_id: String) -> int:
	var raw_value: Variant = status_effects.get(effect_id, 0)
	if raw_value is Dictionary:
		return maxi(int((raw_value as Dictionary).get("turns", 0)), 0)
	return maxi(int(raw_value), 0)


func has_status_effect(effect_id: String) -> bool:
	return get_status_turns(effect_id) > 0


func get_status_magnitude(effect_id: String, fallback: int = 0) -> int:
	var raw_value: Variant = status_effects.get(effect_id, {})
	if raw_value is Dictionary:
		return int((raw_value as Dictionary).get("magnitude", fallback))
	return fallback


func apply_status_effect(effect_id: String, turns: int, magnitude: int = 0) -> void:
	var normalized_turns := maxi(turns, 0)
	if normalized_turns <= 0:
		status_effects.erase(effect_id)
		return
	status_effects[effect_id] = {
		"turns": maxi(get_status_turns(effect_id), normalized_turns),
		"magnitude": magnitude,
	}


func tick_status_effects() -> void:
	var expired_effects: Array[String] = []
	for effect_key in status_effects.keys():
		var effect_id := String(effect_key)
		var raw_value: Variant = status_effects.get(effect_id, 0)
		var remaining_turns := 0
		if raw_value is Dictionary:
			remaining_turns = maxi(int((raw_value as Dictionary).get("turns", 0)) - 1, 0)
		else:
			remaining_turns = maxi(int(raw_value) - 1, 0)
		if remaining_turns <= 0:
			expired_effects.append(effect_id)
		else:
			if raw_value is Dictionary:
				var updated: Dictionary = (raw_value as Dictionary).duplicate(true)
				updated["turns"] = remaining_turns
				status_effects[effect_id] = updated
			else:
				status_effects[effect_id] = remaining_turns
	for effect_id in expired_effects:
		status_effects.erase(effect_id)


func set_grid_cell(cell: Vector2i) -> void:
	grid_cell = cell


func get_troop_label_text() -> String:
	return "%d / %d" % [current_troops, current_troops]


func serialize_battle_runtime() -> Dictionary:
	return {
		"unit_id": unit_id,
		"current_hp": current_hp,
		"max_hp": max_hp,
		"current_troops": current_troops,
		"max_troops": max_troops,
		"grid_cell": [grid_cell.x, grid_cell.y],
		"facing": facing,
		"has_acted": has_acted,
		"has_moved": has_moved,
		"is_defending": is_defending,
		"last_action": last_action.duplicate(true),
		"status_effects": status_effects.duplicate(true),
	}


func restore_battle_runtime(snapshot: Dictionary) -> bool:
	if String(snapshot.get("unit_id", "")) != unit_id:
		return false
	current_hp = clampi(int(snapshot.get("current_hp", current_hp)), 0, maxi(max_hp, 0))
	current_troops = clampi(int(snapshot.get("current_troops", current_troops)), 0, maxi(max_troops, 0))
	var grid_variant: Variant = snapshot.get("grid_cell", [])
	if grid_variant is Array and (grid_variant as Array).size() == 2:
		var grid_array: Array = grid_variant
		grid_cell = Vector2i(int(grid_array[0]), int(grid_array[1]))
	facing = String(snapshot.get("facing", facing))
	has_acted = bool(snapshot.get("has_acted", has_acted))
	has_moved = bool(snapshot.get("has_moved", has_moved))
	is_defending = bool(snapshot.get("is_defending", is_defending))
	var action_variant: Variant = snapshot.get("last_action", {})
	last_action = (action_variant as Dictionary).duplicate(true) if action_variant is Dictionary else {}
	var effects_variant: Variant = snapshot.get("status_effects", {})
	status_effects = (effects_variant as Dictionary).duplicate(true) if effects_variant is Dictionary else {}
	return true
