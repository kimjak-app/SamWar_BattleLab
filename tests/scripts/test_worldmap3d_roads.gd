extends SceneTree

# T-WM3D-06: one road network for 2D and 3D (18 roads = 13 land + 5 sea).
# 1. WorldMap.tscn Route nodes (start/end/route_type) == rule_data_eastasia.json roads (land) + sea_routes (sea).
# 2. WorldMap.tscn CityMarker neighbors (undirected pairs) == the same 18 pairs.
# 3. The real 3D scene (worldmap3d_eastasia.tscn) builds 13 land paths + 5 sea paths with ribbon triangles.
# 4. Sea paths stay on sea cells (grid height <= 2.0 m); land paths stay on land cells (> 2.0 m).
# Also prints each path's length and its ratio to the straight line (report only, no check).

const WORLDMAP_TSCN := "res://WorldMap.tscn"
const SCENE_3D := "res://worldmap3d/scenes/worldmap3d_eastasia.tscn"
const RULES := "res://worldmap3d/maps/eastasia/rule_data_eastasia.json"
const SEA_MAX_M := 2.0           # WorldMapRoads: a grid cell with height <= 2.0 m is sea
# Land paths: points closer than this to either end city are not checked (the end city cell itself is opened in the A*
# grid even when it is a low coastal cell, and Chaikin smoothing blends the first/last cells; 3 cells ~ 9.6 km).
const LAND_END_TOL_CELLS := 3.0

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := _parse_worldmap_tscn()
	var routes2d: Dictionary = scene.routes          # "a|b" -> "land"/"sea"
	var neighbor_pairs: Dictionary = scene.neighbors # "a|b" -> true
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	var routes3d := {}
	for r in rules.roads:
		routes3d[_key(r[0], r[1])] = "land"
	for r in rules.sea_routes:
		routes3d[_key(r[0], r[1])] = "sea"

	# 1. pairs and types
	_expect(routes2d.size() == 18, "2D Route nodes == 18 (got %d)" % routes2d.size())
	_expect(rules.roads.size() == 13 and rules.sea_routes.size() == 5, "3D rule data: 13 roads + 5 sea routes")
	_expect(routes3d.size() == routes2d.size(), "2D route count == 3D route count (%d vs %d)" % [routes2d.size(), routes3d.size()])
	for k in routes3d:
		_expect(routes2d.has(k), "2D has route %s" % k)
		if routes2d.has(k):
			_expect(routes2d[k] == routes3d[k], "route %s type 2D %s == 3D %s" % [k, routes2d[k], routes3d[k]])
	for k in routes2d:
		_expect(routes3d.has(k), "3D has route %s" % k)

	# 2. neighbors == routes
	_expect(scene.marker_count == 13, "13 CityMarker nodes (got %d)" % scene.marker_count)
	for k in neighbor_pairs:
		_expect(routes2d.has(k), "neighbors %s has a 2D Route node" % k)
	for k in routes2d:
		_expect(neighbor_pairs.has(k), "2D Route %s is a neighbors pair" % k)

	# 3. the real 3D scene
	var root = (load(SCENE_3D) as PackedScene).instantiate()
	get_root().add_child(root)          # _ready() builds the whole map synchronously
	await process_frame
	var roads = root.get("roads")
	var geo = root.get("geo")
	var stats: Dictionary = root.get("stats")
	var land_paths: Array = roads.get("paths") if roads != null else []
	var sea_v = roads.get("sea_paths") if roads != null else null
	var sea_paths: Array = sea_v if sea_v is Array else []
	_expect(bool(root.get("show_roads")), "3D scene: show_roads on")
	_expect(land_paths.size() == 13, "3D land paths == 13 (got %d)" % land_paths.size())
	_expect(sea_paths.size() == 5, "3D sea paths == 5 (got %d)" % sea_paths.size())
	_expect(int(stats.get("road_tris", 0)) > 0, "stats.road_tris > 0 (%d)" % int(stats.get("road_tris", 0)))
	_expect(int(stats.get("sea_route_tris", 0)) > 0, "stats.sea_route_tris > 0 (%d)" % int(stats.get("sea_route_tris", 0)))
	_expect(int(stats.get("road_count", -1)) == 13, "stats.road_count == 13")
	_expect(int(stats.get("sea_route_count", -1)) == 5, "stats.sea_route_count == 5")
	_expect(root.get_node_or_null("Roads") != null, "Roads ribbon node exists")
	_expect(root.get_node_or_null("SeaRoutes") != null, "SeaRoutes ribbon node exists")

	# 4. sea paths on sea cells, land paths on land cells; length report
	var marker_xz: Dictionary = root.get("marker_xz")
	var cell_km: float = geo.width_km / (geo.gw - 1)
	for i in land_paths.size():
		var link: Array = rules.roads[i]
		var p: PackedVector2Array = land_paths[i]
		var bad := 0
		for q in p:
			if q.distance_to(p[0]) < LAND_END_TOL_CELLS * cell_km or q.distance_to(p[p.size() - 1]) < LAND_END_TOL_CELLS * cell_km:
				continue
			var g: Vector2i = geo.xz_to_grid(q)
			if geo.grid_height_m(g.x, g.y) <= SEA_MAX_M:
				bad += 1
		_expect(p.size() > 2 and bad == 0, "land %s-%s: %d points, %d on sea cells" % [link[0], link[1], p.size(), bad])
		_report("land", link, p, marker_xz)
	var sea_links: Array = roads.get("sea_links") if roads != null and roads.get("sea_links") is Array else []
	for i in sea_paths.size():
		var link: Array = sea_links[i] if i < sea_links.size() else ["?", "?"]
		var p: PackedVector2Array = sea_paths[i]
		var bad := 0
		# p[0] / p[last] are the cities; p[1] / p[last-1] are their nearest sea cells (straight connector between them)
		for k in range(1, p.size() - 1):
			var g: Vector2i = geo.xz_to_grid(p[k])
			if geo.grid_height_m(g.x, g.y) > SEA_MAX_M:
				bad += 1
		_expect(p.size() > 3 and bad == 0, "sea %s-%s: %d points, %d on land cells" % [link[0], link[1], p.size(), bad])
		_report("sea", link, p, marker_xz)
	root.queue_free()
	await process_frame
	_finish()


func _report(kind: String, link: Array, p: PackedVector2Array, marker_xz: Dictionary) -> void:
	var length := 0.0
	for k in p.size() - 1:
		length += p[k].distance_to(p[k + 1])
	var straight: float = (marker_xz[link[0]] as Vector2).distance_to(marker_xz[link[1]])
	var ratio := length / maxf(straight, 0.001)
	print("[WM3D_ROADS] path %s %s-%s length_km=%.0f straight_km=%.0f ratio=%.2f%s" % [
		kind, link[0], link[1], length, straight, ratio, " (>1.6)" if ratio > 1.6 else ""])


## WorldMap.tscn as text: Route nodes under WorldMapRoot/RouteLayer and CityMarker nodes under WorldMapRoot/CityLayer.
func _parse_worldmap_tscn() -> Dictionary:
	var routes := {}
	var neighbors := {}
	var marker_count := 0
	var kind := ""
	var cur := {}
	var lines := FileAccess.get_file_as_string(WORLDMAP_TSCN).split("\n")
	lines.append("[end]")
	for line in lines:
		if line.begins_with("["):
			if kind == "route":
				routes[_key(cur.get("start", ""), cur.get("end", ""))] = cur.get("type", "land")
			elif kind == "marker":
				marker_count += 1
				for n in cur.get("neighbors", []):
					neighbors[_key(cur.get("city", ""), n)] = true
			kind = ""
			cur = {}
			if line.begins_with("[node name=\"Route_") and line.contains("parent=\"WorldMapRoot/RouteLayer\""):
				kind = "route"
			elif line.begins_with("[node name=\"CityMarker_") and line.contains("parent=\"WorldMapRoot/CityLayer\""):
				kind = "marker"
			continue
		if kind == "":
			continue
		if line.begins_with("start_city_id = "):
			cur.start = _str_value(line)
		elif line.begins_with("end_city_id = "):
			cur.end = _str_value(line)
		elif line.begins_with("route_type = "):
			cur.type = _str_value(line)
		elif line.begins_with("city_id = "):
			cur.city = _str_value(line)
		elif line.begins_with("neighbors = "):
			var arr := []
			var re := RegEx.new()
			re.compile("\"([a-z_]+)\"")
			for m in re.search_all(line):
				arr.append(m.get_string(1))
			cur.neighbors = arr
	return {"routes": routes, "neighbors": neighbors, "marker_count": marker_count}


func _str_value(line: String) -> String:
	return line.get_slice("\"", 1)


func _key(a: String, b: String) -> String:
	return a + "|" + b if a < b else b + "|" + a


func _expect(ok: bool, msg: String) -> void:
	_checks += 1
	if not ok:
		_failures.append(msg)
		push_error("[WM3D_ROADS] FAIL " + msg)


func _finish() -> void:
	print("[WM3D_ROADS] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(1 if not _failures.is_empty() else 0)
