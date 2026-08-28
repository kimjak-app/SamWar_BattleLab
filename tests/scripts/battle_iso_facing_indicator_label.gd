extends Label

## Test-only texture renderer for the persistent unit-facing indicator.
## The production label still owns layout/visibility; the glyph is cleared and
## the finalized unit-facing PNG rotates along the exact projected iso basis.

const UNIT_FACING_ARROW_TEXTURE: Texture2D = preload("res://assets/ui/battle/arrows/unit_facing_arrow.png")
const UNIT_FACING_ARROW_DRAW_SIZE := 52.0
const UNIT_FACING_ARROW_ALPHA := 1.0

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
	var arrow_rect := Rect2(-draw_size * 0.5, draw_size)

	# The finalized art already includes its own dark rim/shadow, so draw it once
	# at full fidelity instead of stacking another runtime shadow underneath it.
	draw_set_transform(center, direction.angle(), Vector2.ONE)
	draw_texture_rect(
		UNIT_FACING_ARROW_TEXTURE,
		arrow_rect,
		false,
		Color(1.0, 1.0, 1.0, UNIT_FACING_ARROW_ALPHA)
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
