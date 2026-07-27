extends Node

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const LOYALTY_SCHEMA_VERSION := 1
const UI_REFRESH_INTERVAL := 0.20

var _elapsed := 0.0
var _last_scene_id := 0
var _stats_line_regex := RegEx.new()
var _hero_id_by_display_name: Dictionary = {}


func _ready() -> void:
	_stats_line_regex.compile("(?:지휘\\s*\\d+\\s*/\\s*)?정\\s*\\d+\\s*/\\s*무\\s*\\d+\\s*/\\s*지\\s*\\d+\\s*/\\s*충\\s*(\\d+)|지휘\\s*\\d+\\s*/\\s*무\\s*\\d+\\s*/\\s*지\\s*\\d+\\s*/\\s*정\\s*\\d+\\s*/\\s*충\\s*(\\d+)")
	_seed_definition_registry()
	_build_display_name_index()
	set_process(true)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < UI_REFRESH_INTERVAL:
		return
	_elapsed = 0.0
	var scene := get_tree().current_scene
	if scene == null or scene.scene_file_path != WORLDMAP_SCENE_PATH:
		_last_scene_id = 0
		return
	var scene_id := scene.get_instance_id()
	if _last_scene_id != scene_id:
		_apply_runtime_stat_migration(scene)
		_last_scene_id = scene_id
	_refresh_worldmap_hero_labels(scene)


func _seed_definition_registry() -> void:
	if not HeroDesignDataRegistry.ensure_loaded():
		push_error("[HERO_WORLDMAP_STATS] %s" % HeroDesignDataRegistry.get_load_error())
		return
	for hero_id in HeroDesignDataRegistry.get_all_hero_ids():
		if not HeroDefinitionRegistry.HERO_DATA.has(hero_id):
			continue
		var definition_variant: Variant = HeroDefinitionRegistry.HERO_DATA.get(hero_id, {})
		if not definition_variant is Dictionary:
			continue
		var definition: Dictionary = definition_variant
		_apply_fixed_stats(definition, hero_id)
		var initial_loyalty := HeroDesignDataRegistry.get_initial_loyalty(hero_id, int(definition.get("loyalty", 80)))
		definition["initial_loyalty"] = initial_loyalty
		definition["loyalty"] = initial_loyalty
		definition["loyalty_schema_version"] = LOYALTY_SCHEMA_VERSION
	print("[HERO_WORLDMAP_STATS] seeded definitions=%d" % HeroDesignDataRegistry.get_all_hero_ids().size())


func _build_display_name_index() -> void:
	_hero_id_by_display_name.clear()
	for hero_id in HeroDesignDataRegistry.get_all_hero_ids():
		var base := HeroDesignDataRegistry.get_base_stats(hero_id)
		var display_name := String(base.get("display_name", ""))
		if not display_name.is_empty():
			_hero_id_by_display_name[display_name] = hero_id


func _apply_runtime_stat_migration(root: Node) -> void:
	var visited: Dictionary = {}
	_migrate_node_tree(root, visited)
	print("[HERO_WORLDMAP_STATS] runtime fixed-stat migration complete")


func _migrate_node_tree(node: Node, visited: Dictionary) -> void:
	if node == null:
		return
	for property_info_variant in node.get_property_list():
		if not property_info_variant is Dictionary:
			continue
		var property_info: Dictionary = property_info_variant
		var usage := int(property_info.get("usage", 0))
		if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		var property_name := String(property_info.get("name", ""))
		if property_name.is_empty():
			continue
		_migrate_variant(node.get(property_name), visited, 0)
	for child in node.get_children():
		if child is Node:
			_migrate_node_tree(child, visited)


func _migrate_variant(value: Variant, visited: Dictionary, depth: int) -> void:
	if depth > 8:
		return
	if value is Dictionary:
		var dictionary: Dictionary = value
		var instance_key := dictionary.hash()
		if visited.has(instance_key):
			return
		visited[instance_key] = true
		_migrate_hero_dictionary(dictionary)
		for nested_value in dictionary.values():
			_migrate_variant(nested_value, visited, depth + 1)
	elif value is Array:
		for nested_value in value:
			_migrate_variant(nested_value, visited, depth + 1)


func _migrate_hero_dictionary(hero: Dictionary) -> void:
	var hero_id := String(hero.get("hero_id", hero.get("id", "")))
	if hero_id.is_empty() or not HeroDesignDataRegistry.get_all_hero_ids().has(hero_id):
		return
	_apply_fixed_stats(hero, hero_id)
	var current_loyalty := clampi(int(hero.get("loyalty", HeroDesignDataRegistry.get_initial_loyalty(hero_id, 80))), 0, 100)
	hero["initial_loyalty"] = HeroDesignDataRegistry.get_initial_loyalty(hero_id, current_loyalty)
	hero["loyalty"] = current_loyalty
	hero["loyalty_schema_version"] = LOYALTY_SCHEMA_VERSION


func _apply_fixed_stats(hero: Dictionary, hero_id: String) -> void:
	var base := HeroDesignDataRegistry.get_base_stats(hero_id)
	var stats_variant: Variant = base.get("stats", {})
	if not stats_variant is Dictionary:
		return
	var stats: Dictionary = stats_variant
	var leadership := int(stats.get("leadership", hero.get("leadership", hero.get("command", 0))))
	var martial := int(stats.get("martial", hero.get("war", 0)))
	var intelligence := int(stats.get("intelligence", hero.get("intelligence", 0)))
	var politics := int(stats.get("politics", hero.get("politics", 0)))
	hero["leadership"] = leadership
	hero["command"] = leadership
	hero["martial"] = martial
	hero["war"] = martial
	hero["intelligence"] = intelligence
	hero["politics"] = politics
	hero["design_stat_schema_version"] = 1


func _refresh_worldmap_hero_labels(root: Node) -> void:
	for label in _collect_labels(root):
		_refresh_hero_label(label)


func _collect_labels(root: Node) -> Array[Label]:
	var result: Array[Label] = []
	if root is Label:
		result.append(root as Label)
	for child in root.get_children():
		if child is Node:
			result.append_array(_collect_labels(child))
	return result


func _refresh_hero_label(label: Label) -> void:
	var text := label.text
	if text.is_empty() or not text.contains("충"):
		return
	var matched := _stats_line_regex.search(text)
	if matched == null:
		return
	var hero_id := _resolve_hero_id_from_text(text)
	if hero_id.is_empty():
		return
	var base := HeroDesignDataRegistry.get_base_stats(hero_id)
	var stats_variant: Variant = base.get("stats", {})
	if not stats_variant is Dictionary:
		return
	var stats: Dictionary = stats_variant
	var loyalty := _extract_current_loyalty(matched, hero_id)
	var replacement := "지휘 %d / 무 %d / 지 %d / 정 %d / 충 %d" % [
		int(stats.get("leadership", 0)),
		int(stats.get("martial", 0)),
		int(stats.get("intelligence", 0)),
		int(stats.get("politics", 0)),
		loyalty,
	]
	label.text = text.substr(0, matched.get_start()) + replacement + text.substr(matched.get_end())


func _resolve_hero_id_from_text(text: String) -> String:
	for display_name_variant in _hero_id_by_display_name.keys():
		var display_name := String(display_name_variant)
		if text.contains(display_name):
			return String(_hero_id_by_display_name.get(display_name, ""))
	return ""


func _extract_current_loyalty(matched: RegExMatch, hero_id: String) -> int:
	for group_index in [1, 2]:
		var value := matched.get_string(group_index)
		if not value.is_empty():
			return clampi(int(value), 0, 100)
	return HeroDesignDataRegistry.get_initial_loyalty(hero_id, 80)
