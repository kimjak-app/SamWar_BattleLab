## EASTWAR WorldMap3D v3 — road paths from rule-data links between MARKER display positions:
## A* over the terrain grid (avoids sea + steep slopes) + Chaikin smoothing. Drawn as ribbon meshes.
class_name WorldMapRoads
extends RefCounted

var paths: Array = []          # Array[PackedVector2Array] map km

func build_paths(geo: WorldMapGeo, city_xz: Dictionary, links: Array) -> void:
	var astar := AStarGrid2D.new()
	astar.region = Rect2i(0, 0, geo.gw, geo.gh)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.update()
	var cell_m := geo.width_km / (geo.gw - 1) * 1000.0
	for j in geo.gh:
		for i in geo.gw:
			var h := geo.grid_height_m(i, j)
			if h <= 2.0:
				astar.set_point_solid(Vector2i(i, j), true)
				continue
			var s := maxf(absf(geo.grid_height_m(i + 1, j) - geo.grid_height_m(i - 1, j)),
					absf(geo.grid_height_m(i, j + 1) - geo.grid_height_m(i, j - 1))) / (2.0 * cell_m)
			astar.set_point_weight_scale(Vector2i(i, j), 1.0 + s * 60.0 + h / 500.0)
	paths.clear()
	for link in links:
		if not city_xz.has(link[0]) or not city_xz.has(link[1]):
			continue
		var a: Vector2 = city_xz[link[0]]
		var b: Vector2 = city_xz[link[1]]
		var ga := geo.xz_to_grid(a)
		var gb := geo.xz_to_grid(b)
		astar.set_point_solid(ga, false)
		astar.set_point_solid(gb, false)
		var ids := astar.get_id_path(ga, gb)
		var pts := PackedVector2Array()
		pts.append(a)
		for k in range(1, ids.size() - 1):
			pts.append(geo.grid_to_xz(ids[k].x, ids[k].y))
		pts.append(b)
		paths.append(_chaikin(_chaikin(_chaikin(_chaikin(pts)))))

func _chaikin(p: PackedVector2Array) -> PackedVector2Array:
	if p.size() < 3:
		return p
	var o := PackedVector2Array()
	o.append(p[0])
	for k in p.size() - 1:
		o.append(p[k].lerp(p[k + 1], 0.25))
		o.append(p[k].lerp(p[k + 1], 0.75))
	o.append(p[p.size() - 1])
	return o
