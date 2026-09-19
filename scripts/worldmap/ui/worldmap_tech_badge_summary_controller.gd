class_name WorldMapTechBadgeSummaryController
extends Node

const LEFT_CONTENT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content"
const RIGHT_CONTENT_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content"
const GRID_COLUMNS := 7
const BADGE_SIZE := Vector2(34.0, 34.0)
const GOLD_COLOR := Color(0.94, 0.78, 0.46, 1.0)

@onready var world_map: Node = get_parent()

var _left_section: PanelContainer = null
var _right_section: PanelContainer = null
var _left_grid: GridContainer = null
var _right_grid: GridContainer = null


func _ready() -> void:
	call_deferred("_install")


func _install() -> void:
	if world_map == null:
		return
	var left_content := world_map.get_node_or_null(LEFT_CONTENT_PATH) as VBoxContainer
	var right_content := world_map.get_node_or_null(RIGHT_CONTENT_PATH) as VBoxContainer
	if left_content == null or right_content == null:
		return
	_left_section = _build_section("TechBadgeSection_Left", "국가 테크트리")
	_left_grid = _left_section.find_child("TechTreeGrid", true, false) as GridContainer
	left_content.add_child(_left_section)
	var turn_anchor := left_content.get_node_or_null("WildArmyEditButtonPlaceholder")
	if turn_anchor != null:
		left_content.move_child(_left_section, turn_anchor.get_index())

	_right_section = _build_section("TechBadgeSection_Right", "성 테크트리")
	_right_grid = _right_section.find_child("TechTreeGrid", true, false) as GridContainer
	right_content.add_child(_right_section)
	var garrison := right_content.get_node_or_null("GarrisonCard")
	if garrison != null:
		right_content.move_child(_right_section, mini(garrison.get_index() + 1, right_content.get_child_count() - 1))

	var city_layer := world_map.get_node_or_null("WorldMapRoot/CityLayer")
	if city_layer != null:
		var callback := Callable(self, "_on_city_selected")
		for child in city_layer.get_children():
			if child.has_signal("city_selected") and not child.is_connected("city_selected", callback):
				child.connect("city_selected", callback)

	_refresh()
	_request_layout()


func _build_section(section_name: String, title_text: String) -> PanelContainer:
	var section := PanelContainer.new()
	section.name = section_name
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.04, 0.052, 0.34)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.63, 0.47, 0.19, 0.92)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	section.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_bottom", 7)
	section.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	margin.add_child(content)

	var title := Label.new()
	title.text = title_text
	title.add_theme_color_override("font_color", GOLD_COLOR)
	title.add_theme_font_size_override("font_size", 13)
	content.add_child(title)

	var grid := GridContainer.new()
	grid.name = "TechTreeGrid"
	grid.columns = GRID_COLUMNS
	grid.custom_minimum_size = Vector2(0.0, BADGE_SIZE.y)
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	content.add_child(grid)
	return section


func refresh_from_runtime() -> void:
	_refresh()
	_request_layout()


func _refresh() -> void:
	_refresh_grid(_left_grid, _get_completed_national())
	var city_id := str(world_map.get("selected_city_id"))
	_refresh_grid(_right_grid, _get_completed_city(city_id))


func _refresh_grid(grid: GridContainer, completed: Dictionary) -> void:
	if grid == null:
		return
	for child in grid.get_children():
		child.queue_free()
	var ids: Array[String] = []
	for key in completed.keys():
		if bool(completed.get(key, false)):
			ids.append(str(key))
	ids.sort()
	for tech_id in ids:
		grid.add_child(_make_badge(tech_id))


func _make_badge(tech_id: String) -> Button:
	var badge := Button.new()
	badge.custom_minimum_size = BADGE_SIZE
	badge.flat = true
	badge.focus_mode = Control.FOCUS_NONE
	badge.expand_icon = true
	var definition: Dictionary = {}
	if world_map.has_method("_get_domestic_tech_definition_mvp"):
		var value = world_map.call("_get_domestic_tech_definition_mvp", tech_id)
		if value is Dictionary:
			definition = value
	badge.tooltip_text = str(definition.get("name", tech_id))
	var definition_icon := str(definition.get("icon_path", ""))
	var icon_path := ""
	if world_map.has_method("_get_domestic_tech_resolved_icon_path_mvp"):
		icon_path = str(world_map.call("_get_domestic_tech_resolved_icon_path_mvp", tech_id, definition_icon))
	if icon_path.is_empty():
		icon_path = definition_icon
	if not icon_path.is_empty():
		var icon := load(icon_path) as Texture2D
		if icon != null:
			badge.icon = icon
	return badge


func _get_completed_national() -> Dictionary:
	if world_map.has_method("_get_completed_national_domestic_tech_snapshot_mvp"):
		var value = world_map.call("_get_completed_national_domestic_tech_snapshot_mvp")
		if value is Dictionary:
			return value
	return {}


func _get_completed_city(city_id: String) -> Dictionary:
	if city_id.is_empty():
		return {}
	if world_map.has_method("_get_completed_city_domestic_tech_snapshot_mvp"):
		var value = world_map.call("_get_completed_city_domestic_tech_snapshot_mvp", city_id)
		if value is Dictionary:
			return value
	return {}


func _on_city_selected(_marker: Node) -> void:
	call_deferred("_refresh")
	call_deferred("_request_layout")


func _request_layout() -> void:
	var hud := world_map.get_node_or_null("HudPositionOwner")
	if hud != null and hud.has_method("request_layout_refresh"):
		hud.call_deferred("request_layout_refresh")
