extends RefCounted
# HUD block 4-4: the camera's edge scroll. The mouse within EDGE_PX pixels of a window edge pans the lab camera that
# way, in screen terms (x right, y down = the S key), at the WASD speed times EDGE_SPEED_SCALE; a corner pans both ways.
# Pure math; the lab decides when it is allowed (HUD under the mouse, focus, input locks, the option).
const EDGE_PX := 16 # the edge band, in pixels from each window edge
const EDGE_SPEED_SCALE := 1.0 # x the WASD pan speed

static func direction(mouse: Vector2, size: Vector2, edge_px: int = EDGE_PX) -> Vector2:
	# Pixel x is in the left band when x < edge_px and in the right band when x >= size.x - edge_px (the same width on
	# both sides); y likewise. Outside the window, or a band of 0, gives no direction.
	if edge_px <= 0 or mouse.x < 0.0 or mouse.y < 0.0 or mouse.x >= size.x or mouse.y >= size.y: return Vector2.ZERO
	var d := Vector2.ZERO
	if mouse.x < edge_px: d.x = -1.0
	elif mouse.x >= size.x - edge_px: d.x = 1.0
	if mouse.y < edge_px: d.y = -1.0
	elif mouse.y >= size.y - edge_px: d.y = 1.0
	return d
