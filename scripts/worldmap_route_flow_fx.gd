@tool
class_name WorldMapRouteFlowFx
extends Path2D

@export var arrow_count := 4
@export var arrow_speed := 55.0
@export var arrow_scale := Vector2(0.75, 0.75)
@export var arrow_color := Color(0.75, 0.90, 1.00, 0.85)

var _source_path: Path2D


func _ready() -> void:
	_source_path = _find_source_path()
	_refresh_source_curve()
	_refresh_arrow_visuals()


func _process(delta: float) -> void:
	_refresh_source_curve()
	_refresh_arrow_visuals()

	if Engine.is_editor_hint():
		return

	for child in get_children():
		var arrow_follow := child as PathFollow2D
		if arrow_follow == null:
			continue
		arrow_follow.progress += arrow_speed * delta


func _refresh_source_curve() -> void:
	if _source_path == null:
		_source_path = _find_source_path()
	if _source_path == null:
		return

	curve = _source_path.curve


func _refresh_arrow_visuals() -> void:
	var curve_length := 0.0
	if curve != null:
		curve_length = curve.get_baked_length()

	var arrow_index := 0
	for child in get_children():
		var arrow_follow := child as PathFollow2D
		if arrow_follow == null:
			continue

		arrow_follow.loop = true
		arrow_follow.rotates = true
		if curve_length > 0.0 and Engine.is_editor_hint():
			arrow_follow.progress = curve_length * float(arrow_index) / float(maxi(arrow_count, 1))

		var arrow_sprite := arrow_follow.get_node_or_null("ArrowSprite") as Polygon2D
		if arrow_sprite != null:
			arrow_sprite.scale = arrow_scale
			arrow_sprite.color = arrow_color

		arrow_index += 1


func _find_source_path() -> Path2D:
	var route_root := get_parent()
	if route_root == null:
		return null
	return route_root.get_node_or_null("Path2D") as Path2D
