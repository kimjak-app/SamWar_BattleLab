extends RefCounted
# HUD block 4-3: where the lab camera's focus must go so that a unit sits in the middle of the screen area the HUD
# leaves free (the 2D _focus_camera_on_unit had no 3D port). Pure math on the lab camera and the shell's HUD
# rectangles; no engine access.

static func free_rect(view: Rect2, obstacles: Array) -> Rect2:
	# The largest axis-aligned rectangle of the view that no obstacle overlaps (candidate edges: the view's and the
	# obstacles' edges; an obstacle outside the view is ignored).
	var inside := []
	for r in obstacles:
		var clipped: Rect2 = (r as Rect2).intersection(view)
		if clipped.has_area(): inside.append(clipped)
	var xs := [view.position.x, view.end.x]
	var ys := [view.position.y, view.end.y]
	for r in inside:
		xs.append_array([r.position.x, r.end.x])
		ys.append_array([r.position.y, r.end.y])
	xs.sort()
	ys.sort()
	var best := Rect2()
	for i in range(xs.size()):
		for j in range(i + 1, xs.size()):
			if (xs[j] - xs[i]) * view.size.y <= best.get_area(): continue
			for k in range(ys.size()):
				for l in range(k + 1, ys.size()):
					var candidate := Rect2(xs[i], ys[k], xs[j] - xs[i], ys[l] - ys[k])
					if candidate.get_area() <= best.get_area(): continue
					if inside.all(func(o): return not (o as Rect2).intersects(candidate)): best = candidate
	return best

static func focus_for(camera: Camera3D, focus: Vector3, point: Vector3, target: Vector2, board_size: Vector2) -> Vector3:
	# The ground focus that projects `point` to the screen point `target`, clamped to the board (0..size on x and z).
	# The camera moves with the focus, so moving the focus by d moves a point's projection like moving the point by -d;
	# under the orthogonal lab camera this is linear: solve the 2x2 system once.
	var s := camera.unproject_position(point)
	var jx := camera.unproject_position(point - Vector3(1, 0, 0)) - s
	var jz := camera.unproject_position(point - Vector3(0, 0, 1)) - s
	var det := jx.x * jz.y - jx.y * jz.x
	if absf(det) < 0.000001: return focus
	var need := target - s
	var a := (need.x * jz.y - need.y * jz.x) / det
	var c := (jx.x * need.y - jx.y * need.x) / det
	var wanted := focus + Vector3(a, 0, c)
	return Vector3(clampf(wanted.x, 0.0, board_size.x), focus.y, clampf(wanted.z, 0.0, board_size.y))
