extends "res://scripts/battle_facing_arrow_tile_button.gd"

## Isometric eight-point renderer for post-move facing selection buttons.
## The arrow is vector-drawn along the actual chamfered-diamond axis, avoiding
## the fixed 45-degree slant of Unicode diagonal arrow glyphs.

const ISO_CHAMFER_RATIO := 0.18
const ISO_ARROW_COLOR := Color(1.0, 0.96, 0.78, 0.98)
const ISO_ARROW_SHADOW_COLOR := Color(0.08, 0.06, 0.03, 0.78)
const ISO_ARROW_WIDTH := 3.0
const ISO_ARROW_SHADOW_WIDTH := 5.0

var iso_arrow_direction := Vector2.ZERO


func set_iso_arrow_direction(direction_sign: Vector2) -> void:
	iso_arrow_direction = direction_sign
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

	var points := _make_chamfered_diamond_points(size, ISO_CHAMFER_RATIO)
	var closed := points.duplicate()
	closed.append(points[0])

	draw_polygon(points, PackedColorArray([draw_fill]))
	draw_polyline(closed, draw_outline, outline_width, true)
	if tile_highlight_color.a > 0.0:
		draw_polyline(
			PackedVector2Array([points[7], points[0], points[1], points[2]]),
			tile_highlight_color,
			1.0,
			true
		)

	_draw_iso_arrow()


func _draw_iso_arrow() -> void:
	if iso_arrow_direction == Vector2.ZERO:
		return

	# Convert only the logical direction signs into pixel-space direction using
	# this button's actual width/height. This makes the arrow slope exactly match
	# the rendered isometric cell axis even if the cell aspect ratio changes.
	var pixel_direction := Vector2(
		iso_arrow_direction.x * size.x,
		iso_arrow_direction.y * size.y
	).normalized()
	if pixel_direction == Vector2.ZERO:
		return

	var center := size * 0.5
	var half_length := minf(size.x * 0.23, size.y * 0.40)
	var tail := center - (pixel_direction * half_length)
	var tip := center + (pixel_direction * half_length)
	var head_length := clampf(minf(size.x, size.y) * 0.18, 8.0, 16.0)
	var head_width := head_length * 0.58
	var head_base := tip - (pixel_direction * head_length)
	var perpendicular := Vector2(-pixel_direction.y, pixel_direction.x)
	var head_left := head_base + (perpendicular * head_width)
	var head_right := head_base - (perpendicular * head_width)

	# Dark under-stroke keeps the thin gold/ivory vector legible over bright sand.
	draw_line(tail, tip, ISO_ARROW_SHADOW_COLOR, ISO_ARROW_SHADOW_WIDTH, true)
	draw_line(tip, head_left, ISO_ARROW_SHADOW_COLOR, ISO_ARROW_SHADOW_WIDTH, true)
	draw_line(tip, head_right, ISO_ARROW_SHADOW_COLOR, ISO_ARROW_SHADOW_WIDTH, true)
	draw_line(tail, tip, ISO_ARROW_COLOR, ISO_ARROW_WIDTH, true)
	draw_line(tip, head_left, ISO_ARROW_COLOR, ISO_ARROW_WIDTH, true)
	draw_line(tip, head_right, ISO_ARROW_COLOR, ISO_ARROW_WIDTH, true)


func _make_chamfered_diamond_points(rect_size: Vector2, chamfer_ratio: float) -> PackedVector2Array:
	var ratio := clampf(chamfer_ratio, 0.04, 0.34)
	var top := Vector2(rect_size.x * 0.5, 0.0)
	var right := Vector2(rect_size.x, rect_size.y * 0.5)
	var bottom := Vector2(rect_size.x * 0.5, rect_size.y)
	var left := Vector2(0.0, rect_size.y * 0.5)
	return PackedVector2Array([
		top.lerp(left, ratio),
		top.lerp(right, ratio),
		right.lerp(top, ratio),
		right.lerp(bottom, ratio),
		bottom.lerp(right, ratio),
		bottom.lerp(left, ratio),
		left.lerp(bottom, ratio),
		left.lerp(top, ratio),
	])
