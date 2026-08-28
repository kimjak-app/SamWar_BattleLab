extends "res://scripts/battle_facing_arrow_tile_button.gd"

## Isometric eight-point renderer for post-move facing selection buttons.
## The tile keeps the chamfered tactical-cell shape; the direction marker shares
## the slimmer unit-facing master asset, with size/tint reserved for interaction.

const ISO_CHAMFER_RATIO := 0.18
const FACING_SELECT_ARROW_TEXTURE: Texture2D = preload("res://assets/ui/battle/arrows/unit_facing_arrow.png")
const FACING_SELECT_ARROW_DRAW_SIZE := 64.0
const FACING_SELECT_ARROW_BASE_TINT := Color(1.0, 0.90, 0.56, 1.0)
const FACING_SELECT_ARROW_HOVER_TINT := Color(1.0, 0.96, 0.76, 1.0)
const FACING_SELECT_ARROW_PRESSED_TINT := Color(1.0, 0.99, 0.88, 1.0)
const FACING_SELECT_ARROW_SHADOW_COLOR := Color(0.0, 0.0, 0.0, 0.30)
const FACING_SELECT_ARROW_SHADOW_OFFSET := Vector2(1.8, 1.8)

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

	_draw_iso_arrow_texture()


func _draw_iso_arrow_texture() -> void:
	if iso_arrow_direction == Vector2.ZERO:
		return
	if FACING_SELECT_ARROW_TEXTURE == null:
		return

	var pixel_direction := Vector2(
		iso_arrow_direction.x * size.x,
		iso_arrow_direction.y * size.y
	).normalized()
	if pixel_direction == Vector2.ZERO:
		return

	var interaction_scale := 1.0
	var tint := FACING_SELECT_ARROW_BASE_TINT
	if button_pressed:
		interaction_scale = 1.08
		tint = FACING_SELECT_ARROW_PRESSED_TINT
	elif is_hovered():
		interaction_scale = 1.04
		tint = FACING_SELECT_ARROW_HOVER_TINT

	var center := size * 0.5
	var draw_extent := FACING_SELECT_ARROW_DRAW_SIZE * interaction_scale
	var draw_size := Vector2.ONE * draw_extent
	var draw_rect := Rect2(-draw_size * 0.5, draw_size)

	draw_set_transform(center + FACING_SELECT_ARROW_SHADOW_OFFSET, pixel_direction.angle(), Vector2.ONE)
	draw_texture_rect(
		FACING_SELECT_ARROW_TEXTURE,
		draw_rect,
		false,
		FACING_SELECT_ARROW_SHADOW_COLOR
	)

	draw_set_transform(center, pixel_direction.angle(), Vector2.ONE)
	draw_texture_rect(
		FACING_SELECT_ARROW_TEXTURE,
		draw_rect,
		false,
		tint
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
