extends SceneTree
# HUD block 4-4 test 1: the edge scroll's direction (battle3d_edge_scroll.gd direction(), a pure function), against a
# table written here by hand: a 16-pixel band on every edge (pixels 0-15 from the left/top edge, the last 16 pixels on the
# right/bottom), 8 directions, the 4 corners, the inside (none), the band's boundary at 15 / 16 / 17 pixels from each
# edge, outside the window (none) and a band of 0 (none). Screen axes: x right, y down.
const EdgeScroll = preload("res://scripts/battle3d/battle3d_edge_scroll.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func run() -> void:
	expect(EdgeScroll.EDGE_PX == 16 and EdgeScroll.EDGE_SPEED_SCALE == 1.0, "constants EDGE_PX 16, EDGE_SPEED_SCALE 1.0 (got %s, %s)" % [EdgeScroll.EDGE_PX, EdgeScroll.EDGE_SPEED_SCALE])
	for size in [Vector2(1280, 800), Vector2(1920, 1080)]:
		var w: float = size.x
		var hh: float = size.y
		var cx: float = w * 0.5
		var cy: float = hh * 0.5
		# [mouse, expected]
		var table := [
			[Vector2(cx, cy), Vector2(0, 0)],
			[Vector2(0, cy), Vector2(-1, 0)], [Vector2(w - 1, cy), Vector2(1, 0)], [Vector2(cx, 0), Vector2(0, -1)], [Vector2(cx, hh - 1), Vector2(0, 1)],
			[Vector2(0, 0), Vector2(-1, -1)], [Vector2(w - 1, 0), Vector2(1, -1)], [Vector2(0, hh - 1), Vector2(-1, 1)], [Vector2(w - 1, hh - 1), Vector2(1, 1)],
			[Vector2(5, 300), Vector2(-1, 0)], [Vector2(w - 6, 300), Vector2(1, 0)], [Vector2(300, 5), Vector2(0, -1)], [Vector2(300, hh - 6), Vector2(0, 1)],
			# 15 / 16 / 17 pixels from each edge (pixel distance: x from the left, w - 1 - x from the right)
			[Vector2(15, cy), Vector2(-1, 0)], [Vector2(16, cy), Vector2(0, 0)], [Vector2(17, cy), Vector2(0, 0)],
			[Vector2(w - 1 - 15, cy), Vector2(1, 0)], [Vector2(w - 1 - 16, cy), Vector2(0, 0)], [Vector2(w - 1 - 17, cy), Vector2(0, 0)],
			[Vector2(cx, 15), Vector2(0, -1)], [Vector2(cx, 16), Vector2(0, 0)], [Vector2(cx, 17), Vector2(0, 0)],
			[Vector2(cx, hh - 1 - 15), Vector2(0, 1)], [Vector2(cx, hh - 1 - 16), Vector2(0, 0)], [Vector2(cx, hh - 1 - 17), Vector2(0, 0)],
			[Vector2(15, 15), Vector2(-1, -1)], [Vector2(16, 15), Vector2(0, -1)], [Vector2(15, 16), Vector2(-1, 0)], [Vector2(16, 16), Vector2(0, 0)],
			# outside the window
			[Vector2(-1, cy), Vector2(0, 0)], [Vector2(w, cy), Vector2(0, 0)], [Vector2(cx, -1), Vector2(0, 0)], [Vector2(cx, hh), Vector2(0, 0)], [Vector2(-1, -1), Vector2(0, 0)],
		]
		var wrong := []
		for row in table:
			var got: Vector2 = EdgeScroll.direction(row[0], size)
			if got != row[1]: wrong.append([row[0], row[1], got])
		expect(wrong.is_empty(), "%s: %d table rows (mouse, expected, got) wrong %s" % [size, table.size(), str(wrong)])
		expect(EdgeScroll.direction(Vector2(0, 0), size, 0) == Vector2.ZERO and EdgeScroll.direction(Vector2(w - 1, cy), size, 0) == Vector2.ZERO, "%s: a band of 0 never scrolls" % size)
		expect(EdgeScroll.direction(Vector2(31, cy), size, 32) == Vector2(-1, 0) and EdgeScroll.direction(Vector2(32, cy), size, 32) == Vector2.ZERO, "%s: the band width is the argument (32 px)" % size)
	print("[EDGE_DIRECTION] %s: %d checks, %d failures" % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)
