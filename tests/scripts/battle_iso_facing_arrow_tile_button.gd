extends "res://scripts/battle_facing_arrow_tile_button.gd"

## Isometric diamond renderer for the post-move facing selection buttons.


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

	var top := Vector2(size.x * 0.5, 0.0)
	var right := Vector2(size.x, size.y * 0.5)
	var bottom := Vector2(size.x * 0.5, size.y)
	var left := Vector2(0.0, size.y * 0.5)
	var diamond := PackedVector2Array([top, right, bottom, left])
	var closed := PackedVector2Array([top, right, bottom, left, top])

	draw_polygon(diamond, PackedColorArray([draw_fill]))
	draw_polyline(closed, draw_outline, outline_width, true)
	if tile_highlight_color.a > 0.0:
		draw_polyline(PackedVector2Array([left, top, right]), tile_highlight_color, 1.0, true)
