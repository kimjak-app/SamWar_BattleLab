@tool
class_name WorldMapCityMarker
extends Node2D

signal city_selected(marker: WorldMapCityMarker)

@export var city_id: String = ""
@export var display_name: String = ""
@export var region_id: String = ""
@export var owner_faction_id: String = ""
@export var neighbors: Array[String] = []
@export var route_types: Dictionary = {}
@export var web_seed_position: Vector2 = Vector2.ZERO

@onready var castle_icon: Sprite2D = get_node_or_null("CastleIcon") as Sprite2D
@onready var selection_ring: Polygon2D = get_node_or_null("SelectionRing") as Polygon2D
@onready var city_dot: Polygon2D = _get_city_dot()
@onready var name_text: Node = _get_name_text()
@onready var click_area: Area2D = get_node_or_null("ClickArea") as Area2D

const BACKGROUND_REFRESH_TOOL := preload("res://scripts/worldmap/worldmap_background_refresh_tool.gd")

const CITY_CASTLE_ICON_TARGET_HEIGHT := 56.0
# Castle icon visuals are disabled for the functional marker phase.
const CASTLE_ICON_VISUALS_ENABLED := false
const FUNCTIONAL_CITY_DOT_VISIBLE := true
const CASTLE_ICON_KOREA := preload("res://assets/worldmap/city_icons/castle_korea.png")
const CASTLE_ICON_CHINA := preload("res://assets/worldmap/city_icons/castle_china.png")
const CASTLE_ICON_JAPAN := preload("res://assets/worldmap/city_icons/castle_japan.png")
const CASTLE_ICON_ORDO := preload("res://assets/worldmap/city_icons/castle_ordo.png")

const WORLD_MAP_REFRESH_POSITION_TOLERANCE := 1.5
const LEGACY_CITY_POSITIONS := {
	"luoyang": Vector2(785, 781),
	"yecheng": Vector2(896, 581),
	"chengdu": Vector2(479, 984),
	"jianye": Vector2(1046, 846),
	"karakorum": Vector2(1155, 261),
	"pyeongyang": Vector2(1353, 404),
	"hanseong": Vector2(1409, 529),
	"gyeongju": Vector2(1518, 658),
	"sabi": Vector2(1426, 695),
	"kyoto": Vector2(1798, 775),
	"osaka": Vector2(1746, 861),
	"kyushu": Vector2(1539, 951),
	"edo": Vector2(1903, 696),
}

# 2048x1456 world coordinates sampled from the approved Photoshop city-dot layout.
# These are seed positions only: once a marker is manually moved away from its legacy
# position, this tool will never overwrite the user's fine adjustment.
const REFRESH_CITY_POSITIONS := {
	"luoyang": Vector2(640, 745),
	"yecheng": Vector2(775, 579),
	"chengdu": Vector2(433, 931),
	"jianye": Vector2(931, 864),
	"karakorum": Vector2(978, 405),
	"pyeongyang": Vector2(1160, 572),
	"hanseong": Vector2(1212, 642),
	"gyeongju": Vector2(1285, 710),
	"sabi": Vector2(1210, 733),
	"kyoto": Vector2(1518, 855),
	"osaka": Vector2(1450, 924),
	"kyushu": Vector2(1273, 979),
	"edo": Vector2(1605, 797),
}

const OWNER_COLORS := {
	"player": Color(0.25, 0.62, 1.0, 1.0),
	"goguryeo": Color(0.35, 0.50, 0.95, 1.0),
	"baekje_faction": Color(0.88, 0.54, 0.28, 1.0),
	"silla": Color(0.90, 0.74, 0.24, 1.0),
	"chu": Color(0.80, 0.24, 0.22, 1.0),
	"wei": Color(0.46, 0.58, 0.72, 1.0),
	"shu": Color(0.18, 0.58, 0.32, 1.0),
	"wu": Color(0.28, 0.72, 0.76, 1.0),
	"oda": Color(0.58, 0.28, 0.84, 1.0),
	"toyotomi": Color(0.86, 0.48, 0.16, 1.0),
	"kyushu_faction": Color(0.64, 0.42, 0.28, 1.0),
	"tokugawa": Color(0.32, 0.72, 0.44, 1.0),
	"mongol_faction": Color(0.62, 0.52, 0.40, 1.0),
}


func _ready() -> void:
	_apply_worldmap_refresh_seed_position()
	_ensure_worldmap_refresh_background()
	_refresh_marker_visuals()
	_connect_click_area()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_apply_worldmap_refresh_seed_position()
		_ensure_worldmap_refresh_background()
		_refresh_marker_visuals()


func _apply_worldmap_refresh_seed_position() -> void:
	if not LEGACY_CITY_POSITIONS.has(city_id):
		return
	if not REFRESH_CITY_POSITIONS.has(city_id):
		return

	var legacy_position: Vector2 = LEGACY_CITY_POSITIONS[city_id]
	if position.distance_to(legacy_position) > WORLD_MAP_REFRESH_POSITION_TOLERANCE:
		return

	position = REFRESH_CITY_POSITIONS[city_id]


func _ensure_worldmap_refresh_background() -> void:
	# One marker is enough to keep the shared background configured in both editor and runtime.
	if city_id != "hanseong":
		return
	BACKGROUND_REFRESH_TOOL.ensure_background(self)


func _get_city_dot() -> Polygon2D:
	return get_node_or_null("CityDot") as Polygon2D


func _get_name_text() -> Node:
	var node := get_node_or_null("NameText")
	if node == null:
		node = get_node_or_null("NameLabel")
	return node


func _refresh_marker_visuals() -> void:
	if selection_ring != null:
		selection_ring.visible = false

	if castle_icon != null and CASTLE_ICON_VISUALS_ENABLED:
		_apply_castle_icon()
	elif castle_icon != null:
		castle_icon.visible = false

	if name_text != null:
		if name_text.has_method("set_label_text"):
			name_text.call("set_label_text", display_name)
		elif name_text is Label:
			(name_text as Label).text = display_name

	if city_dot != null:
		city_dot.color = OWNER_COLORS.get(owner_faction_id, Color(0.9, 0.9, 0.9, 1.0))
		city_dot.visible = FUNCTIONAL_CITY_DOT_VISIBLE


func _apply_castle_icon() -> void:
	var icon_texture := _get_castle_icon_texture()
	castle_icon.texture = icon_texture
	castle_icon.centered = true
	castle_icon.visible = true
	castle_icon.scale = _get_castle_icon_scale()


func _get_castle_icon_scale() -> Vector2:
	var icon_texture := _get_castle_icon_texture()
	if icon_texture != null and icon_texture.get_height() > 0:
		var icon_scale := CITY_CASTLE_ICON_TARGET_HEIGHT / float(icon_texture.get_height())
		return Vector2(icon_scale, icon_scale)
	return Vector2.ONE


func _get_castle_icon_texture() -> Texture2D:
	match city_id:
		"hanseong", "pyeongyang", "gyeongju", "sabi":
			return CASTLE_ICON_KOREA
		"luoyang", "yecheng", "chengdu", "jianye":
			return CASTLE_ICON_CHINA
		"kyoto", "osaka", "kyushu", "edo":
			return CASTLE_ICON_JAPAN
		"karakorum":
			return CASTLE_ICON_ORDO

	if region_id == "region.korean_peninsula":
		return CASTLE_ICON_KOREA
	if region_id == "region.china_mainland":
		return CASTLE_ICON_CHINA
	if region_id == "region.japanese_archipelago":
		return CASTLE_ICON_JAPAN
	if region_id == "region.northern_steppe" or owner_faction_id == "mongol_faction":
		return CASTLE_ICON_ORDO

	return CASTLE_ICON_CHINA


func _connect_click_area() -> void:
	if click_area == null:
		return
	if not click_area.input_event.is_connected(_on_click_area_input_event):
		click_area.input_event.connect(_on_click_area_input_event)


func _on_click_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT and mouse_button_event.pressed:
			city_selected.emit(self)
			get_viewport().set_input_as_handled()


func set_selected(is_selected: bool) -> void:
	if selection_ring != null:
		selection_ring.visible = is_selected

	if castle_icon != null:
		if CASTLE_ICON_VISUALS_ENABLED:
			var selected_scale := 1.0
			if is_selected:
				selected_scale = 1.08
			castle_icon.scale = _get_castle_icon_scale() * selected_scale
		else:
			castle_icon.visible = false

	if name_text is WorldMapCityNameLabel:
		var selected_color := Color(1.0, 0.92, 0.55, 1.0)
		var normal_color := Color(1.0, 1.0, 1.0, 1.0)
		var text_color := normal_color
		if is_selected:
			text_color = selected_color
		name_text.set("text_color", text_color)
