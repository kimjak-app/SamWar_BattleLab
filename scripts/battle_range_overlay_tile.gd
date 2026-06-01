class_name BattleRangeOverlayTile
extends ColorRect

var tile_fill_color := Color(0.16, 0.62, 1.0, 0.16)
var tile_outline_color := Color(0.46, 0.86, 1.0, 0.82)
var tile_highlight_color := Color(0.78, 0.96, 1.0, 0.34)
var corner_cut_ratio := 0.18
var outline_width := 2.0


func _ready() -> void:
	color = Color.TRANSPARENT
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_tile_style(fill_color: Color, outline_color: Color, highlight_color: Color) -> void:
	tile_fill_color = fill_color
	tile_outline_color = outline_color
	tile_highlight_color = highlight_color
	color = Color.TRANSPARENT
	queue_redraw()


func _draw() -> void:
	if size.x <= 2.0 or size.y <= 2.0:
		return

	var outer_points := _make_octagon_points(size, 1.0)
	var closed_outer := outer_points.duplicate()
	closed_outer.append(outer_points[0])

	draw_polygon(outer_points, PackedColorArray([tile_fill_color]))
	draw_polyline(closed_outer, tile_outline_color, outline_width, true)


func _make_octagon_points(rect_size: Vector2, point_scale: float) -> PackedVector2Array:
	var cut := minf(rect_size.x, rect_size.y) * corner_cut_ratio
	var points := PackedVector2Array([
		Vector2(cut, 0.0),
		Vector2(rect_size.x - cut, 0.0),
		Vector2(rect_size.x, cut),
		Vector2(rect_size.x, rect_size.y - cut),
		Vector2(rect_size.x - cut, rect_size.y),
		Vector2(cut, rect_size.y),
		Vector2(0.0, rect_size.y - cut),
		Vector2(0.0, cut),
	])
	if is_equal_approx(point_scale, 1.0):
		return points

	var center := rect_size * 0.5
	var scaled_points := PackedVector2Array()
	for point in points:
		scaled_points.append(center + ((point - center) * point_scale))
	return scaled_points
