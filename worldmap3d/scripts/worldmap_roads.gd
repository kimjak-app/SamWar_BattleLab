## EASTWAR WorldMap3D v3 — road paths from rule-data links between MARKER display positions:
## A* over the terrain grid (avoids sea + steep slopes) + Chaikin smoothing. Drawn as ribbon meshes.
class_name WorldMapRoads
extends RefCounted

var paths: Array = []          # Array[PackedVector2Array] map km
var sea_paths: Array = []      # T-WM3D-06: Array[PackedVector2Array] map km, one per sea link (same order; skipped links missing)
var sea_links: Array = []      # the links that got a sea path (sea_paths[k] belongs to sea_links[k])

const SEA_MAX_M := 2.0         # a grid cell with height <= 2.0 m is sea (same rule as the land A* solids above)
const SEA_SEARCH_CELLS := 80   # nearest-sea-cell search radius around a city (cells, ~3.2 km each)
const OPEN_SEA_MIN_CELLS := 5000   # a sea region this large counts as open sea (EastAsia: ocean 782k cells, next 328)

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

## T-WM3D-06: sea routes. A* over sea cells only (the reverse of the land A*: land is solid). Each end is the city's
## nearest sea cell, joined to the city by a straight connector; only the sea part is Chaikin-smoothed, so every point
## except the two cities lies over sea. A link without a nearby sea cell or a sea path is skipped with an error.
## Result: sea_paths[k] = [city_a, sea cells..., city_b] for sea_links[k].
func build_sea_paths(geo: WorldMapGeo, city_xz: Dictionary, links: Array) -> void:
	sea_paths.clear()
	sea_links.clear()
	var astar := AStarGrid2D.new()
	astar.region = Rect2i(0, 0, geo.gw, geo.gh)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.update()
	for j in geo.gh:
		for i in geo.gw:
			if geo.grid_height_m(i, j) > SEA_MAX_M:
				astar.set_point_solid(Vector2i(i, j), true)
	for link in links:
		if not city_xz.has(link[0]) or not city_xz.has(link[1]):
			push_error("WorldMapRoads: sea route %s-%s: unknown city" % [link[0], link[1]])
			continue
		var a: Vector2 = city_xz[link[0]]
		var b: Vector2 = city_xz[link[1]]
		var sa := _nearest_sea_cell(geo, geo.xz_to_grid(a))
		var sb := _nearest_sea_cell(geo, geo.xz_to_grid(b))
		if sa.x < 0 or sb.x < 0:
			push_error("WorldMapRoads: sea route %s-%s: no sea cell within %d cells of a city" % [link[0], link[1], SEA_SEARCH_CELLS])
			continue
		var ids := astar.get_id_path(sa, sb)
		if ids.is_empty():
			push_error("WorldMapRoads: sea route %s-%s: no sea path" % [link[0], link[1]])
			continue
		var sea := PackedVector2Array()
		for id in ids:
			sea.append(geo.grid_to_xz(id.x, id.y))
		sea = _chaikin(_chaikin(_chaikin(_chaikin(sea))))
		var pts := PackedVector2Array()
		pts.append(a)
		pts.append_array(sea)
		pts.append(b)
		sea_paths.append(pts)
		sea_links.append(link)

## Nearest open-sea cell (Euclidean, in cells) to grid cell c, searching square rings outward; (-1, -1) if none.
## Open sea = a sea cell whose 4-connected sea region has at least OPEN_SEA_MIN_CELLS cells. Low inland cells
## (<= 2 m river / lagoon pockets of 1..328 cells on the EastAsia grid) are skipped: a path cannot start there.
func _nearest_sea_cell(geo: WorldMapGeo, c: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_d2 := INF
	var closed := {}                    # cells of sea pockets already found too small
	for r in SEA_SEARCH_CELLS + 1:
		if float(r * r) > best_d2:      # every cell on ring r is at least r away
			break
		var ring := []
		for dj in range(-r, r + 1):
			for di in range(-r, r + 1):
				if maxi(absi(di), absi(dj)) != r:
					continue
				var i := c.x + di
				var j := c.y + dj
				if i < 0 or j < 0 or i >= geo.gw or j >= geo.gh:
					continue
				var d2 := float(di * di + dj * dj)
				if d2 < best_d2 and geo.grid_height_m(i, j) <= SEA_MAX_M:
					ring.append([d2, Vector2i(i, j)])
		ring.sort_custom(func(x, y): return x[0] < y[0])
		for e in ring:
			if e[0] < best_d2 and not closed.has(e[1]) and _is_open_sea(geo, e[1], closed):
				best_d2 = e[0]
				best = e[1]
				break
	return best

## Bounded flood fill over sea cells from s: true once OPEN_SEA_MIN_CELLS cells are reached. A smaller pocket is added
## to `closed` so its other cells are not filled again.
func _is_open_sea(geo: WorldMapGeo, s: Vector2i, closed: Dictionary) -> bool:
	var seen := {s: true}
	var queue: Array[Vector2i] = [s]
	var head := 0
	while head < queue.size():
		if seen.size() >= OPEN_SEA_MIN_CELLS:
			return true
		var p: Vector2i = queue[head]
		head += 1
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + d
			if q.x < 0 or q.y < 0 or q.x >= geo.gw or q.y >= geo.gh or seen.has(q):
				continue
			if geo.grid_height_m(q.x, q.y) <= SEA_MAX_M:
				seen[q] = true
				queue.append(q)
	for k in seen:
		closed[k] = true
	return false

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
