extends SceneTree

# PERF3: bake the EastAsia 3D map's road / sea-route A* cells into worldmap3d/maps/eastasia/baked_paths.json.
# Run after changing the height grid, markers.json, the rule data's roads / sea_routes or the A* rules:
#   godot --headless --path . --script res://tools/bake_worldmap3d_paths.gd
# The inputs come from the real map root (worldmap3d_root.gd _ready, roads off) and the cells from WorldMapRoads'
# own live A* (bake_dict), so nothing here re-implements the routing.

const SCENE_3D := "res://worldmap3d/scenes/worldmap3d_eastasia.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var map_root = (load(SCENE_3D) as PackedScene).instantiate()
	map_root.set("show_roads", false)
	map_root.set("show_rivers", false)
	map_root.set("show_markers", false)
	map_root.set("show_region_labels", false)
	get_root().add_child(map_root)
	await process_frame
	var roads = map_root.get("roads")
	var out_path: String = String(roads.get("baked_file"))
	if out_path == "":
		push_error("bake: the map root did not set a baked file path for this map")
		quit(1)
		return
	var rules: Dictionary = map_root.get("rules")
	var t := Time.get_ticks_msec()
	var d: Dictionary = roads.bake_dict(map_root.get("geo"), map_root.get("marker_xz"), rules.roads, rules.get("sea_routes", []))
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		push_error("bake: cannot write %s" % out_path)
		quit(1)
		return
	f.store_string(WorldMapRoads.bake_text(d))
	f.close()
	var cells := 0
	for section in ["roads", "sea_routes"]:
		for row in d[section]:
			cells += (row.cells as Array).size()
	print("[BAKE_PATHS] wrote %s: %d roads, %d sea routes, %d cells, key %s (%d ms)" % [
		out_path, (d.roads as Array).size(), (d.sea_routes as Array).size(), cells, d.key, Time.get_ticks_msec() - t])
	map_root.queue_free()
	await process_frame
	quit(0)
