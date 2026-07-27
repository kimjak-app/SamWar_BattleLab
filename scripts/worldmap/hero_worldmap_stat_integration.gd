extends Node

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const LOYALTY_SCHEMA_VERSION := 1
const UI_REFRESH_INTERVAL := 0.20
const UNIT_TYPE_LABELS := {
	"infantry": "보병",
	"cavalry": "기병",
	"archer": "궁병",
	"gunner": "총병",
	"mounted_archer": "궁기병",
	"support": "지원",
}
const RECOGNIZED_UNIT_LABELS := ["보병", "기병", "궁병", "총병", "궁기병", "지원"]

var _elapsed := 0.0
var _last_scene_id := 0
var _stats_line_regex := RegEx.new()
var _hero_id_by_display_name: Dictionary = {}
var _valid_hero_ids: Dictionary = {}


func _ready() -> void:
	_stats_line_regex.compile("(?:지휘\\s*\\d+\\s*/\\s*)?정\\s*\\d+\\s*/\\s*무\\s*\\d+\\s*/\\s*지\\s*\\d+\\s*/\\s*충\\s*(\\d+)|지휘\\s*\\d+\\s*/\\s*무\\s*\\d+\\s*/\\s*지\\s*\\d+\\s*/\\s*정\\s*\\d+\\s*/\\s*충\\s*(\\d+)")
	_build_hero_indexes()
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


func _build_hero_indexes() -> void:
	_hero_id_by_display_name.clear()
	_valid_hero_ids.clear()
	if not HeroDesignDataRegistry.ensure_loaded():
		push_error("[HERO_WORLDMAP_STATS] %s" % HeroDesignDataRegistry.get_load_error())
		return
	for hero_id in HeroDesignDataRegistry.get_all_hero_ids():
		_valid_hero_ids[hero_id] = true
		var base := HeroDesignDataRegistry.get_base_stats(hero_id)
		var display_name := String(base.get("display_name", ""))
		if not display_name.is_empty():
			_hero_id_by_display_name[display_name] = hero_id
	print("[HERO_WORLDMAP_STATS] definition data ready=%d" % _valid_hero_ids.size())


func _apply_runtime_stat_migration(root: Node) -> void:
	var migrated_count := 0
	migrated_count += _migrate_node_tree(root)
	print("[HERO_WORLDMAP_STATS] runtime migration heroes=%d" % migrated_count)


func _migrate_node_tree(node: Node) -> int:
	if node == null:
		return 0
	var migrated_count := 0
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
		var source_value: Variant = node.get(property_name)
		var migration := _build_migrated_value(source_value, 0)
		migrated_count += int(migration.get("count", 0))
		if bool(migration.get("changed", false)):
			node.set(property_name, migration.get("value"))
	for child in node.get_children():
		if child is Node:
			migrated_count += _migrate_node_tree(child)
	return migrated_count


func _build_migrated_value(value: Variant, depth: int) -> Dictionary:
	if depth > 8:
		return {"value": value, "changed": false, "count": 0}
	if value is Dictionary:
		var source: Dictionary = value
		var copy := source.duplicate(false)
		var changed := false
		var count := 0
		for key_variant in source.keys():
			var nested := _build_migrated_value(source.get(key_variant), depth + 1)
			if bool(nested.get("changed", false)):
				copy[key_variant] = nested.get("value")
				changed = true
			count += int(nested.get("count", 0))
		var hero_changed := _apply_hero_migration_to_copy(copy)
		if hero_changed:
			changed = true
			count += 1
		return {"value": copy if changed else value, "changed": changed, "count": count}
	if value is Array:
		var source_array: Array = value
		var copy_array := source_array.duplicate(false)
		var changed := false
		var count := 0
		for index in source_array.size():
			var nested := _build_migrated_value(source_array[index], depth + 1)
			if bool(nested.get("changed", false)):
				copy_array[index] = nested.get("value")
				changed = true
			count += int(nested.get("count", 0))
		return {"value": copy_array if changed else value, "changed": changed, "count": count}
	return {"value": value, "changed": false, "count": 0}


func _apply_hero_migration_to_copy(hero: Dictionary) -> bool:
	var hero_id := String(hero.get("hero_id", hero.get("id", "")))
	if hero_id.is_empty() or not _valid_hero_ids.has(hero_id):
		return false
	var base := HeroDesignDataRegistry.get_base_stats(hero_id)
	var stats_variant: Variant = base.get("stats", {})
	if not stats_variant is Dictionary:
		return false
	var stats: Dictionary = stats_variant
	var current_loyalty := clampi(int(hero.get("loyalty", HeroDesignDataRegistry.get_initial_loyalty(hero_id, 80))), 0, 100)
	var leadership := int(stats.get("leadership", hero.get("leadership", hero.get("command", 0))))
	var martial := int(stats.get("martial", hero.get("martial", hero.get("war", 0))))
	hero["leadership"] = leadership
	hero["command"] = leadership
	hero["martial"] = martial
	hero["war"] = martial
	hero["intelligence"] = int(stats.get("intelligence", hero.get("intelligence", 0)))
	hero["politics"] = int(stats.get("politics", hero.get("politics", 0)))
	hero["initial_loyalty"] = HeroDesignDataRegistry.get_initial_loyalty(hero_id, current_loyalty)
	hero["loyalty"] = current_loyalty
	hero["loyalty_schema_version"] = LOYALTY_SCHEMA_VERSION
	hero["design_stat_schema_version"] = 1
	var profile := HeroDesignDataRegistry.get_battle_profile(hero_id)
	if not profile.is_empty():
		hero["unit_type"] = String(profile.get("unit_type", hero.get("unit_type", "infantry")))
		hero["primary_role"] = String(profile.get("primary_role", ""))
		hero["secondary_role"] = String(profile.get("secondary_role", ""))
		hero["design_profile_schema_version"] = 1
	return true


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
	var text := label.text.strip_edges()
	if text.is_empty():
		return
	var hero_id := _resolve_hero_id_from_node_context(label)
	if hero_id.is_empty():
		return
	if text.contains("충"):
		var matched := _stats_line_regex.search(text)
		if matched != null:
			_apply_stat_label(label, text, matched, hero_id)
			return
	if RECOGNIZED_UNIT_LABELS.has(text):
		_apply_unit_type_label(label, hero_id)


func _apply_stat_label(label: Label, text: String, matched: RegExMatch, hero_id: String) -> void:
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


func _apply_unit_type_label(label: Label, hero_id: String) -> void:
	var profile := HeroDesignDataRegistry.get_battle_profile(hero_id)
	if profile.is_empty():
		return
	var unit_type := String(profile.get("unit_type", ""))
	var display_label := String(UNIT_TYPE_LABELS.get(unit_type, ""))
	if not display_label.is_empty():
		label.text = display_label


func _resolve_hero_id_from_node_context(node: Node) -> String:
	if node is Label:
		var direct_id := _resolve_hero_id_from_text((node as Label).text)
		if not direct_id.is_empty():
			return direct_id
	var current: Node = node.get_parent()
	var depth := 0
	while current != null and depth < 6:
		var found := _collect_unique_hero_ids(current)
		if found.size() == 1:
			return String(found[0])
		current = current.get_parent()
		depth += 1
	return ""


func _collect_unique_hero_ids(root: Node) -> Array[String]:
	var result: Array[String] = []
	var seen: Dictionary = {}
	for label in _collect_labels(root):
		var hero_id := _resolve_hero_id_from_text(label.text)
		if hero_id.is_empty() or seen.has(hero_id):
			continue
		seen[hero_id] = true
		result.append(hero_id)
	return result


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
