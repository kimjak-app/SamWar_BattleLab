@tool
class_name WorldMapRoutePath
extends Node2D

@export var route_id: String = ""
@export var start_city_id: String = ""
@export var end_city_id: String = ""
@export_enum("land", "sea") var route_type: String = "land"

@onready var path_2d: Path2D = get_node_or_null("Path2D") as Path2D
@onready var line_2d: Line2D = get_node_or_null("Line2D") as Line2D

const LAND_ROUTE_WIDTH := 4.5
const SEA_ROUTE_WIDTH := 2.5
const LAND_ROUTE_COLOR := Color(0.86, 0.62, 0.32, 0.72)
const SEA_ROUTE_COLOR := Color(0.55, 0.82, 1.0, 0.48)
const ENDPOINT_EPSILON := 0.05


func _ready() -> void:
	_refresh_route_geometry()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_refresh_route_geometry()


func _refresh_route_geometry() -> void:
	_sync_curve_to_city_markers()
	_refresh_route_line()
	_sync_arrow_flow_curve()


func _sync_curve_to_city_markers() -> void:
	if path_2d == null or path_2d.curve == null:
		return
	if path_2d.curve.point_count < 2:
		return

	var start_marker := _find_city_marker(start_city_id)
	var end_marker := _find_city_marker(end_city_id)
	if start_marker == null or end_marker == null:
		return

	var last_index := path_2d.curve.point_count - 1
	var old_start := path_2d.curve.get_point_position(0)
	var old_end := path_2d.curve.get_point_position(last_index)
	var new_start := to_local(start_marker.global_position)
	var new_end := to_local(end_marker.global_position)
	var start_delta := new_start - old_start
	var end_delta := new_end - old_end

	if start_delta.length() <= ENDPOINT_EPSILON and end_delta.length() <= ENDPOINT_EPSILON:
		return

	# Preserve the existing route shape while moving its interior guide points with
	# a weighted blend of the start/end deltas. For the current 3-point routes the
	# middle point follows the average movement of both connected cities.
	for point_index in range(1, last_index):
		var blend := float(point_index) / float(last_index)
		var blended_delta := start_delta.lerp(end_delta, blend)
		var current_point := path_2d.curve.get_point_position(point_index)
		path_2d.curve.set_point_position(point_index, current_point + blended_delta)

	path_2d.curve.set_point_position(0, new_start)
	path_2d.curve.set_point_position(last_index, new_end)


func _find_city_marker(target_city_id: String) -> Node2D:
	if target_city_id.is_empty():
		return null

	var city_layer := get_node_or_null("../../CityLayer")
	if city_layer == null:
		return null

	for child in city_layer.get_children():
		if not child is Node2D:
			continue
		var child_city_id = child.get("city_id")
		if child_city_id != null and str(child_city_id) == target_city_id:
			return child as Node2D

	return null


func _refresh_route_line() -> void:
	if path_2d == null or line_2d == null:
		return
	if path_2d.curve == null:
		return

	var baked_points := path_2d.curve.get_baked_points()
	if baked_points.size() < 2:
		return

	# The line is a pure visual of the Path2D curve, so keep its local transform neutral.
	line_2d.position = Vector2.ZERO
	line_2d.rotation = 0.0
	line_2d.scale = Vector2.ONE
	line_2d.points = baked_points
	line_2d.width = _get_route_width()
	line_2d.default_color = _get_route_color()
	line_2d.z_index = 0


func _sync_arrow_flow_curve() -> void:
	if path_2d == null or path_2d.curve == null:
		return
	var arrow_flow_root := get_node_or_null("ArrowFlowRoot") as Path2D
	if arrow_flow_root != null and arrow_flow_root.curve != path_2d.curve:
		arrow_flow_root.curve = path_2d.curve


func _get_route_width() -> float:
	if route_type == "sea":
		return SEA_ROUTE_WIDTH
	return LAND_ROUTE_WIDTH


func _get_route_color() -> Color:
	if route_type == "sea":
		return SEA_ROUTE_COLOR
	return LAND_ROUTE_COLOR
