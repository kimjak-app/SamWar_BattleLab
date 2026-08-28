extends "res://scripts/battle_range_overlay_tile.gd"

## Isometric diamond renderer for test-only battle grid overlays.


func _draw() -> void:
	if size.x <= 2.0 or size.y <= 2.0:
		return

	var top := Vector2(size.x * 0.5, 0.0)
	var right := Vector2(size.x, size.y * 0.5)
	var bottom := Vector2(size.x * 0.5, size.y)
	var left := Vector2(0.0, size.y * 0.5)
	var diamond := PackedVector2Array([top, right, bottom, left])
	var closed := PackedVector2Array([top, right, bottom, left, top])

	draw_polygon(diamond, PackedColorArray([tile_fill_color]))
	draw_polyline(closed, tile_outline_color, outline_width, true)

	# A restrained highlight on the two upper edges helps the cell read as a
	# surface lying on the battlefield instead of a flat HUD rectangle.
	if tile_highlight_color.a > 0.0:
		draw_polyline(PackedVector2Array([left, top, right]), tile_highlight_color, 1.0, true)
