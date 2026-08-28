extends Label

## Test-only texture renderer for the persistent unit-facing indicator.
## The production label still owns layout/visibility; the glyph is cleared and a
## polished arrow texture is rotated along the exact projected isometric basis.

const UNIT_FACING_ARROW_TEXTURE: Texture2D = preload("res://assets/ui/battle/arrows/unit_facing_arrow.png")
const UNIT_FACING_ARROW_DRAW_SIZE := 46.0
const UNIT_FACING_ARROW_ALPHA := 0.98

var iso_pixel_direction := Vector2.ZERO


func set_iso_pixel_direction(pixel_direction: Vector2) -> void:
	iso_pixel_direction = pixel_direction.normalized()
	queue_redraw()


func _draw() -> void:
	if size.x <= 2.0 or size.y <= 2.0:
		return
	if iso_pixel_direction == Vector2.ZERO:
		return
	if UNIT_FACING_ARROW_TEXTURE == null:
		return

	var center := size * 0.5
	var direction := iso_pixel_direction.normalized()
	var draw_size := Vector2.ONE * UNIT_FACING_ARROW_DRAW_SIZE
	var draw_rect := Rect2(-draw_size * 0.5, draw_size)

	draw_set_transform(center, direction.angle(), Vector2.ONE)
	draw_texture_rect(
		UNIT_FACING_ARROW_TEXTURE,
		draw_rect,
		false,
		Color(1.0, 1.0, 1.0, UNIT_FACING_ARROW_ALPHA)
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
