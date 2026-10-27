extends Button
# HUD block 4-3: one facing arrow of the 3D command panel. The tile is the neighbour cell's projected diamond (its
# four ground corners as the lab camera sees them, x0.96) in the 2D tile colours (battle_facing_arrow_tile_button.gd
# with the colours of _apply_facing_arrow_button_style); the arrow points along the screen vector from the unit's cell
# to that cell, so it stays true when the camera turns. Clicks count only inside the diamond (_has_point).
const FILL := Color(1.0, 0.86, 0.42, 0.22)
const OUTLINE := Color(1.0, 0.92, 0.65, 0.62)
const HIGHLIGHT := Color(1.0, 0.98, 0.82, 0.28)
const ARROW := Color(1.0, 0.96, 0.78, 0.9)
const ARROW_OUTLINE := Color(0.1, 0.07, 0.0, 0.8)
var corners := PackedVector2Array() # local diamond
var direction := Vector2.RIGHT # screen direction the arrow points (unit length)

func set_tile(screen_corners: PackedVector2Array, screen_direction: Vector2) -> void:
	# Place the button on the diamond's bounding box and keep the corners local to it.
	var box := Rect2(screen_corners[0], Vector2.ZERO)
	for p in screen_corners: box = box.expand(p)
	custom_minimum_size = Vector2.ZERO
	position = box.position
	size = box.size
	var local := PackedVector2Array()
	for p in screen_corners: local.append(p - box.position)
	corners = local
	direction = screen_direction.normalized()
	queue_redraw()

func _has_point(point: Vector2) -> bool:
	return corners.size() == 4 and Geometry2D.is_point_in_polygon(point, corners)

func _draw() -> void:
	if corners.size() != 4: return
	var fill := FILL
	var outline := OUTLINE
	if button_pressed or is_hovered():
		fill.a *= 1.35
		outline.a = minf(outline.a * 1.16, 1.0)
	draw_colored_polygon(corners, fill)
	draw_polyline(corners + PackedVector2Array([corners[0]]), outline, 2.0, true)
	var centre := (corners[0] + corners[1] + corners[2] + corners[3]) * 0.25
	var reach := minf(size.x, size.y) * 0.32
	var side := Vector2(-direction.y, direction.x)
	var tip := centre + direction * reach
	var head := PackedVector2Array([tip, tip - direction * reach * 0.75 + side * reach * 0.55, tip - direction * reach * 0.75 - side * reach * 0.55])
	var tail := centre - direction * reach
	draw_line(tail, tip - direction * reach * 0.6, ARROW_OUTLINE, maxf(reach * 0.36, 3.0) + 3.0, true)
	draw_colored_polygon(PackedVector2Array([head[0] + direction * 1.5, head[1] + (head[1] - tip).normalized() * 1.5, head[2] + (head[2] - tip).normalized() * 1.5]), ARROW_OUTLINE)
	draw_line(tail, tip - direction * reach * 0.6, ARROW, maxf(reach * 0.36, 3.0), true)
	draw_colored_polygon(head, ARROW)
	draw_line(corners[0].lerp(corners[1], 0.2), corners[0].lerp(corners[3], 0.2), HIGHLIGHT, 2.0, true)
