extends "res://scripts/battle_range_overlay_tile.gd"

## Isometric chamfered-diamond renderer for test-only battle grid overlays.
## The four diamond tips are trimmed into short edges, preserving the original
## battle UI's octagonal tactical-cell language while keeping the 3/4 projection.

const ISO_CHAMFER_RATIO := 0.18


func _draw() -> void:
	if size.x <= 2.0 or size.y <= 2.0:
		return

	var points := _make_chamfered_diamond_points(size, ISO_CHAMFER_RATIO)
	var closed := points.duplicate()
	closed.append(points[0])

	draw_polygon(points, PackedColorArray([tile_fill_color]))
	draw_polyline(closed, tile_outline_color, outline_width, true)

	# Highlight only the upper-facing edges so the overlay still reads as a flat
	# surface on the battlefield rather than a floating HUD plate.
	if tile_highlight_color.a > 0.0:
		draw_polyline(
			PackedVector2Array([points[7], points[0], points[1], points[2]]),
			tile_highlight_color,
			1.0,
			true
		)


func _make_chamfered_diamond_points(rect_size: Vector2, chamfer_ratio: float) -> PackedVector2Array:
	var ratio := clampf(chamfer_ratio, 0.04, 0.34)
	var top := Vector2(rect_size.x * 0.5, 0.0)
	var right := Vector2(rect_size.x, rect_size.y * 0.5)
	var bottom := Vector2(rect_size.x * 0.5, rect_size.y)
	var left := Vector2(0.0, rect_size.y * 0.5)

	# Two points replace each original diamond tip -> eight vertices total.
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
