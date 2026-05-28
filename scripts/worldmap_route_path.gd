@tool
class_name WorldMapRoutePath
extends Node2D

@export var route_id: String = ""
@export var start_city_id: String = ""
@export var end_city_id: String = ""
@export_enum("land", "sea") var route_type: String = "land"

@onready var path_2d: Path2D = get_node_or_null("Path2D") as Path2D
@onready var line_2d: Line2D = get_node_or_null("Line2D") as Line2D


func _ready() -> void:
	_refresh_route_line()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_refresh_route_line()


func _refresh_route_line() -> void:
	if path_2d == null or line_2d == null:
		return
	if path_2d.curve == null:
		return

	var baked_points := path_2d.curve.get_baked_points()
	if baked_points.size() < 2:
		return

	line_2d.points = baked_points
	line_2d.width = 2.5
	line_2d.default_color = _get_route_color()
	line_2d.z_index = 0


func _get_route_color() -> Color:
	if route_type == "sea":
		return Color(0.55, 0.82, 1.0, 0.48)
	return Color(0.72, 0.50, 0.25, 0.44)
