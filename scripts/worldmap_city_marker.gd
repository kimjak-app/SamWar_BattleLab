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

@onready var city_dot: Polygon2D = _get_city_dot()
@onready var name_label: Node = get_node_or_null("NameLabel")
@onready var click_area: Area2D = get_node_or_null("ClickArea") as Area2D

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
	_refresh_marker_visuals()
	_connect_click_area()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_refresh_marker_visuals()


func _get_city_dot() -> Polygon2D:
	return get_node_or_null("CityDot") as Polygon2D


func _refresh_marker_visuals() -> void:
	if name_label != null:
		if name_label.has_method("set_label_text"):
			name_label.call("set_label_text", display_name)
		elif name_label is Label:
			(name_label as Label).text = display_name

	if city_dot != null:
		city_dot.color = OWNER_COLORS.get(owner_faction_id, Color(0.9, 0.9, 0.9, 1.0))


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
