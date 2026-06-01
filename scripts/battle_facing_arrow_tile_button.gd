class_name BattleFacingArrowTileButton
extends Button

var tile_fill_color := Color(0.28, 0.34, 0.45, 0.34)
var tile_outline_color := Color(0.58, 0.68, 0.84, 0.9)
var tile_highlight_color := Color(0.78, 0.86, 1.0, 0.38)
var corner_cut_ratio := 0.18
var outline_width := 2.0


func _ready() -> void:
	flat = true


func set_tile_style(fill_color: Color, outline_color: Color, highlight_color: Color) -> void:
	tile_fill_color = fill_color
	tile_outline_color = outline_color
	tile_highlight_color = highlight_color
	queue_redraw()


func _draw() -> void:
	if size.x <= 2.0 or size.y <= 2.0:
		return

	var draw_fill := tile_fill_color
	var draw_outline := tile_outline_color
	if button_pressed:
		draw_fill.a *= 1.35
		draw_outline.a = minf(draw_outline.a * 1.16, 1.0)
	elif is_hovered():
		draw_fill.a *= 1.18
		draw_outline.a = minf(draw_outline.a * 1.08, 1.0)

	var outer_points := _make_octagon_points(size, 1.0)
	var closed_outer := outer_points.duplicate()
	closed_outer.append(outer_points[0])
	draw_polygon(outer_points, PackedColorArray([draw_fill]))
	draw_polyline(closed_outer, draw_outline, outline_width, true)


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
