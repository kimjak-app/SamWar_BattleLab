extends SceneTree

# PERF3: baked road / sea-route A* cells (worldmap3d/maps/eastasia/baked_paths.json, WorldMapRoads.baked_file).
# a. match: the real EastAsia scene routes from the baked file; its 13 road + 5 sea cell lists equal the live A*
#    (length and every cell), and the final smoothed paths / sea_links equal the live build exactly
# b. stale: one city moved by one grid cell, or one link removed -> the key differs -> live A* with a warning,
#    and the result equals a live build of the same changed inputs
# c. missing: a baked file path that does not exist -> live A* with a warning, same result as live
# d. fresh: baking the current inputs again gives exactly the committed baked_paths.json (forgotten re-bake -> red)
# The existing road expectations (test_worldmap3d_roads) are untouched.

const SCENE_3D := "res://worldmap3d/scenes/worldmap3d_eastasia.tscn"
const BAKED := "res://worldmap3d/maps/eastasia/baked_paths.json"
const MISSING := "res://worldmap3d/maps/eastasia/__no_baked_paths__.json"

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var map_root = (load(SCENE_3D) as PackedScene).instantiate()
	get_root().add_child(map_root)          # _ready() builds the whole map synchronously
	await process_frame
	var roads = map_root.get("roads")
	var geo: WorldMapGeo = map_root.get("geo")
	var marker_xz: Dictionary = map_root.get("marker_xz")
	var rules: Dictionary = map_root.get("rules")
	var road_links: Array = rules.roads
	var sea_links_in: Array = rules.get("sea_routes", [])
	_expect(roads != null and String(roads.baked_file) == BAKED, "the EastAsia root points WorldMapRoads at %s" % BAKED)
	_expect(roads.last_road_source == "baked" and roads.last_sea_source == "baked", "the real scene used the baked cells (roads %s, sea %s)" % [roads.last_road_source, roads.last_sea_source])
	_expect(roads.road_cells.size() == 13 and roads.sea_cells.size() == 5, "baked: 13 road + 5 sea cell lists (%d, %d)" % [roads.road_cells.size(), roads.sea_cells.size()])

	# a. live build of the same inputs
	var live := WorldMapRoads.new()
	var t := Time.get_ticks_msec()
	live.build_paths(geo, marker_xz, road_links)
	live.build_sea_paths(geo, marker_xz, sea_links_in)
	print("[BAKED_PATHS] live A* + smoothing %d ms" % (Time.get_ticks_msec() - t))
	_expect(live.last_road_source == "live" and live.last_sea_source == "live", "a fresh WorldMapRoads without baked_file routes live")
	_same_cells("a roads", roads.road_cells, live.road_cells)
	_same_cells("a sea", roads.sea_cells, live.sea_cells)
	_same_paths("a", roads, live)

	# d. the committed file == a fresh bake of the current inputs
	var fresh: Dictionary = live.bake_dict(geo, marker_xz, road_links, sea_links_in)
	var committed = JSON.parse_string(FileAccess.get_file_as_string(BAKED))
	_expect(committed is Dictionary, "baked_paths.json parses")
	if committed is Dictionary:
		var reparsed: Dictionary = JSON.parse_string(WorldMapRoads.bake_text(fresh))   # same number types as the file
		for k in ["version", "key", "roads_key", "sea_routes_key"]:
			_expect(committed.get(k) == reparsed[k], "d: committed %s == fresh bake (%s)" % [k, str(fresh[k]).left(16)])
		_expect(committed.get("roads") == reparsed.roads, "d: committed road cells == fresh bake")
		_expect(committed.get("sea_routes") == reparsed.sea_routes, "d: committed sea cells == fresh bake")
		_expect(FileAccess.get_file_as_string(BAKED) == WorldMapRoads.bake_text(fresh), "d: committed file text == fresh bake text")

	# b. stale: one linked city moved by one grid cell
	var moved := marker_xz.duplicate()
	var cid: String = road_links[0][0]
	var cell_km := geo.width_km / (geo.gw - 1)
	moved[cid] = (moved[cid] as Vector2) + Vector2(cell_km, 0.0)
	_expect(geo.xz_to_grid(moved[cid]) != geo.xz_to_grid(marker_xz[cid]), "b: %s moved to another grid cell" % cid)
	await _stale_case("b moved %s" % cid, geo, moved, road_links, sea_links_in, BAKED, "stale")
	# b. stale: one road link and one sea link removed
	await _stale_case("b link removed", geo, marker_xz, road_links.slice(1), sea_links_in.slice(1), BAKED, "stale")
	# c. missing file
	await _stale_case("c missing", geo, marker_xz, road_links, sea_links_in, MISSING, "missing")

	map_root.queue_free()
	await process_frame
	_finish()


## Routes with baked_file set and changed inputs (or a missing file): must fall back to live with a warning and
## equal a plain live build of the same inputs.
func _stale_case(tag: String, geo: WorldMapGeo, city_xz: Dictionary, links: Array, sea: Array, path: String, why: String) -> void:
	var r := WorldMapRoads.new()
	r.baked_file = path
	r.build_paths(geo, city_xz, links)
	_expect(r.last_road_source == "live" and r.last_warning.contains(why), "%s: roads fall back live (%s)" % [tag, r.last_warning])
	r.last_warning = ""
	r.build_sea_paths(geo, city_xz, sea)
	_expect(r.last_sea_source == "live" and r.last_warning.contains(why), "%s: sea routes fall back live (%s)" % [tag, r.last_warning])
	var ref := WorldMapRoads.new()
	ref.build_paths(geo, city_xz, links)
	ref.build_sea_paths(geo, city_xz, sea)
	_same_cells("%s roads" % tag, r.road_cells, ref.road_cells)
	_same_cells("%s sea" % tag, r.sea_cells, ref.sea_cells)
	_same_paths(tag, r, ref)
	await process_frame


func _same_cells(tag: String, got: Array, want: Array) -> void:
	_expect(got.size() == want.size(), "%s: %d entries == %d" % [tag, got.size(), want.size()])
	var cells := 0
	for n in mini(got.size(), want.size()):
		var g: Dictionary = got[n]
		var w: Dictionary = want[n]
		var gc: Array = g.cells
		var wc: Array = w.cells
		var same: bool = g.link == w.link and String(g.get("status", "")) == String(w.get("status", "")) and gc.size() == wc.size()
		if same:
			for k in gc.size():
				if gc[k] != wc[k] or not gc[k] is Vector2i:
					same = false
					break
		cells += gc.size()
		_expect(same, "%s %s-%s: %d cells equal (live %d)" % [tag, w.link[0], w.link[1], gc.size(), wc.size()])
	print("[BAKED_PATHS] %s: %d cells compared" % [tag, cells])


func _same_paths(tag: String, got, want) -> void:
	_expect(got.paths.size() == want.paths.size() and got.sea_paths.size() == want.sea_paths.size(), "%s: path counts equal (%d/%d, %d/%d)" % [tag, got.paths.size(), want.paths.size(), got.sea_paths.size(), want.sea_paths.size()])
	var same := true
	for n in mini(got.paths.size(), want.paths.size()):
		same = same and got.paths[n] == want.paths[n]
	for n in mini(got.sea_paths.size(), want.sea_paths.size()):
		same = same and got.sea_paths[n] == want.sea_paths[n]
	_expect(same and got.sea_links == want.sea_links, "%s: smoothed paths, sea paths and sea_links identical" % tag)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("[PASS] %s" % label)
	else:
		_failures.append(label)
		push_error("[FAIL] %s" % label)


func _finish() -> void:
	print("[BAKED_PATHS] checks=%d failures=%d" % [_checks, _failures.size()])
	for failure in _failures:
		print("  FAIL: %s" % failure)
	quit(0 if _failures.is_empty() and _checks > 0 else 1)
