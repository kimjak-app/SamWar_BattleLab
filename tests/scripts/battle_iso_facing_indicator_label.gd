extends Label

## Test-only vector renderer for the persistent unit-facing indicator.
## The production label is retained for layout/visibility, but its Unicode glyph
## is cleared and the arrow is drawn along the actual projected iso basis.

const ISO_ARROW_COLOR := Color(1.0, 0.98, 0.90, 0.98)
const ISO_ARROW_SHADOW_COLOR := Color(0.03, 0.025, 0.02, 0.92)
const ISO_ARROW_WIDTH := 2.6
const ISO_ARROW_SHADOW_WIDTH := 4.8

var iso_pixel_direction := Vector2.ZERO


func set_iso_pixel_direction(pixel_direction: Vector2) -> void:
	iso_pixel_direction = pixel_direction.normalized()
	queue_redraw()


func _draw() -> void:
	if size.x <= 2.0 or size.y <= 2.0:
		return
	if iso_pixel_direction == Vector2.ZERO:
		return

	var center := size * 0.5
	var min_side := minf(size.x, size.y)
	var half_length := clampf(min_side * 0.42, 8.0, 15.0)
	var direction := iso_pixel_direction.normalized()
	var tail := center - (direction * half_length)
	var tip := center + (direction * half_length)
	var head_length := clampf(min_side * 0.26, 5.0, 9.0)
	var head_width := head_length * 0.56
	var head_base := tip - (direction * head_length)
	var perpendicular := Vector2(-direction.y, direction.x)
	var head_left := head_base + (perpendicular * head_width)
	var head_right := head_base - (perpendicular * head_width)

	# Under-stroke keeps the arrow readable over portraits, banners and terrain.
	draw_line(tail, tip, ISO_ARROW_SHADOW_COLOR, ISO_ARROW_SHADOW_WIDTH, true)
	draw_line(tip, head_left, ISO_ARROW_SHADOW_COLOR, ISO_ARROW_SHADOW_WIDTH, true)
	draw_line(tip, head_right, ISO_ARROW_SHADOW_COLOR, ISO_ARROW_SHADOW_WIDTH, true)
	draw_line(tail, tip, ISO_ARROW_COLOR, ISO_ARROW_WIDTH, true)
	draw_line(tip, head_left, ISO_ARROW_COLOR, ISO_ARROW_WIDTH, true)
	draw_line(tip, head_right, ISO_ARROW_COLOR, ISO_ARROW_WIDTH, true)
