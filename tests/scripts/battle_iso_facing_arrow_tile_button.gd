extends "res://scripts/battle_facing_arrow_tile_button.gd"

## Isometric eight-point renderer for post-move facing selection buttons.
## Direction artwork is pre-rotated in Photoshop, so runtime only chooses the
## correct texture. No texture rotation is performed here.

const ISO_CHAMFER_RATIO := 0.18
const FACING_SELECT_ARROW_NE: Texture2D = preload("res://assets/ui/battle/arrows/facing_select_ne.png")
const FACING_SELECT_ARROW_SE: Texture2D = preload("res://assets/ui/battle/arrows/facing_select_se.png")
const FACING_SELECT_ARROW_SW: Texture2D = preload("res://assets/ui/battle/arrows/facing_select_sw.png")
const FACING_SELECT_ARROW_NW: Texture2D = preload("res://assets/ui/battle/arrows/facing_select_nw.png")
const FACING_SELECT_ARROW_DRAW_SIZE := 64.0
const FACING_SELECT_ARROW_BASE_ALPHA := 0.58
const FACING_SELECT_ARROW_HOVER_ALPHA := 0.78
const FACING_SELECT_ARROW_PRESSED_ALPHA := 0.92

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

	var arrow_texture := _get_facing_select_texture(iso_arrow_direction)
	if arrow_texture == null:
		return

	var interaction_scale := 1.0
	var interaction_alpha := FACING_SELECT_ARROW_BASE_ALPHA
	if button_pressed:
		interaction_scale = 1.08
		interaction_alpha = FACING_SELECT_ARROW_PRESSED_ALPHA
	elif is_hovered():
		interaction_scale = 1.04
		interaction_alpha = FACING_SELECT_ARROW_HOVER_ALPHA

	var center := size * 0.5
	var draw_extent := FACING_SELECT_ARROW_DRAW_SIZE * interaction_scale
	var draw_size := Vector2.ONE * draw_extent
	var arrow_rect := Rect2(center - (draw_size * 0.5), draw_size)

	# Artwork already contains the exact isometric angle. Draw it directly without
	# draw_set_transform/rotation so Photoshop-authored edges stay crisp.
	draw_texture_rect(
		arrow_texture,
		arrow_rect,
		false,
		Color(1.0, 1.0, 1.0, interaction_alpha)
	)


func _get_facing_select_texture(direction_sign: Vector2) -> Texture2D:
	# Photoshop-authored assets now match their filenames directly.
	if direction_sign.x > 0.0 and direction_sign.y < 0.0:
		return FACING_SELECT_ARROW_NE
	if direction_sign.x > 0.0 and direction_sign.y > 0.0:
		return FACING_SELECT_ARROW_SE
	if direction_sign.x < 0.0 and direction_sign.y > 0.0:
		return FACING_SELECT_ARROW_SW
	if direction_sign.x < 0.0 and direction_sign.y < 0.0:
		return FACING_SELECT_ARROW_NW
	return null


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
