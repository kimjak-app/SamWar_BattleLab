extends SceneTree

# T-WM3D-08: the production WorldMap.tscn carries the 3D map (WorldMap3DHost as a child of the WorldMap root).
# 1. 3D setting: host built, adapter has 13 cities, 3D camera controller, 2D $WorldMapRoot hidden, HUD still there.
# 2. 2D setting: no 3D layer, $WorldMapRoot visible, main's own 2D controller.
# 3. 3D files missing (host.scene_path_3d -> missing file): 2D fallback, no error.
# 4. Battle return path (no real battle): pending return + a battle-result snapshot with a changed owner -> reload
#    WorldMap.tscn -> 3D layer rebuilt, 3D owner = the returned owner, world_ready_after_return row with build_ms.
# 5. User settings: own file, survive a "restart" (fresh read), camera scheme applied, never in the game save data.
# Settings / memory log use test files (never the player's user://samwar_worldmap3d.cfg / wm3d_mem_log.csv).

const WORLDMAP := "res://WorldMap.tscn"
const SETTINGS_TEST := "user://samwar_worldmap3d_prod_test.cfg"
const MEM_LOG_TEST := "user://wm3d_mem_log_prod_test.csv"
const RESULT_META := "samwar_worldmap_battle_result"   # worldmap_main.gd WORLDMAP_BATTLE_RESULT_META_KEY

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	WorldMap3DSettings.path = SETTINGS_TEST
	_remove(SETTINGS_TEST)
	WorldMap3DMemProbe.shared().log_path = MEM_LOG_TEST
	_remove(MEM_LOG_TEST)
	var packed := load(WORLDMAP) as PackedScene

	# 1. 3D (default setting: no file)
	_expect(WorldMap3DSettings.wants_3d() and WorldMap3DSettings.camera_scheme() == "", "no settings file: 3D, map-default camera scheme")
	var main = await _open(packed)
	var host = main.get_node_or_null("WorldMap3DHost")
	_expect(host is WorldMap3DHost and not host.idle, "WorldMap.tscn: its WorldMap3DHost owns main")
	_expect(host != null and host.active and host.adapter != null and host.adapter.root3d != null, "3D setting: 3D map active")
	if host == null or host.adapter == null or host.adapter.root3d == null:
		_finish()
		return
	_expect((host.adapter.markers_by_id as Dictionary).size() == 13 and (host.adapter.root3d.cities as Dictionary).size() == 13, "adapter: 13 cities")
	_expect(main.get("_camera_controller") is WorldMap3DCameraController, "3D: main's controller is the 3D one")
	_expect((main.get_node("WorldMapRoot") as CanvasItem).visible == false, "3D: $WorldMapRoot hidden")
	_expect(main.get_node_or_null("WorldMapUI") != null and main.get_node_or_null("TopNavCanvas") != null, "3D: HUD nodes (WorldMapUI, TopNavCanvas) present")
	_expect(_count_label("map_ready") == 1 and _last_build_ms("map_ready") > 0, "map_ready row with build_ms (%s ms)" % str(_last_build_ms("map_ready")))
	var cam = host.adapter.get_camera()
	var default_scheme: String = cam.input_scheme

	# 5a. settings: camera scheme B applied at once through apply_settings() (the popup calls the host group)
	_expect(WorldMap3DSettings.set_camera_scheme("B"), "set_camera_scheme(B) saved")
	call_group(WorldMap3DSettings.HOST_GROUP, "apply_settings")
	_expect(cam.input_scheme == "B", "apply_settings: 3D camera scheme B (map default was %s)" % default_scheme)
	# 5b. 2D at once through apply_settings()
	WorldMap3DSettings.set_wants_3d(false)
	call_group(WorldMap3DSettings.HOST_GROUP, "apply_settings")
	_expect(not host.active and (main.get_node("WorldMapRoot") as CanvasItem).visible and not (main.get("_camera_controller") is WorldMap3DCameraController), "apply_settings: switched to 2D now")
	WorldMap3DSettings.set_wants_3d(true)
	call_group(WorldMap3DSettings.HOST_GROUP, "apply_settings")
	_expect(host.active and main.get("_camera_controller") is WorldMap3DCameraController, "apply_settings: back to 3D")
	# 5c. never in the game save data
	var save_text := JSON.stringify(main.call("_serialize_worldmap_state"))
	_expect(not save_text.contains("map_view") and not save_text.contains("camera_input_scheme") and not save_text.contains("samwar_worldmap3d"), "game save data has no world-map display settings")
	# 5d. "restart": a fresh ConfigFile read sees the saved values; the user file is its own
	var cfg := ConfigFile.new()
	_expect(cfg.load(SETTINGS_TEST) == OK and str(cfg.get_value("worldmap", "map_view", "")) == "3d" and str(cfg.get_value("worldmap", "camera_input_scheme", "")) == "B", "settings file holds map_view=3d, camera_input_scheme=B")
	_expect(WorldMap3DSettings.PATH_DEFAULT != "user://samwar_audio.cfg" and WorldMap3DSettings.PATH_DEFAULT != "user://worldmap_left_panel_state.json", "settings file is neither the audio settings nor the game save")

	# 4. battle return path: the owner of luoyang changes in the returned snapshot
	var owner_before := str((main.call("_get_city_hud_entry", "luoyang") as Dictionary).get("owner_faction_id", ""))
	var new_owner := "wei" if owner_before != "wei" else "chu"
	main.call("_set_city_runtime_owner", "luoyang", new_owner)
	var snapshot: Dictionary = main.call("_serialize_worldmap_state")
	main.call("_set_city_runtime_owner", "luoyang", owner_before)
	Engine.set_meta(RESULT_META, {"result_id": "wm3d-08-return-test", "worldmap_state_snapshot": snapshot})
	WorldMap3DMemProbe.shared().mark_pending_return()
	main = await _open(packed)   # what result_return_destination = "res://WorldMap.tscn" does after a battle
	host = main.get_node_or_null("WorldMap3DHost")
	_expect(host != null and host.active and host.adapter != null and host.adapter.root3d != null, "after return: 3D map rebuilt")
	if host != null and host.adapter != null and host.adapter.root3d != null:
		var hud_owner := str((main.call("_get_city_hud_entry", "luoyang") as Dictionary).get("owner_faction_id", ""))
		var owner3d := str((host.adapter.root3d.cities["luoyang"] as Dictionary).get("owner", ""))
		_expect(hud_owner == new_owner, "after return: main applied the returned owner (%s, expected %s)" % [hud_owner, new_owner])
		_expect(owner3d == hud_owner, "after return: 3D owner of luoyang = game owner (%s / %s)" % [owner3d, hud_owner])
		_expect((host.adapter.get_camera()).input_scheme == "B", "after return: saved camera scheme B applied at build")
	_expect(not Engine.has_meta(RESULT_META), "battle result consumed by main")
	_expect(_count_label("world_ready_after_return") == 1 and _last_build_ms("world_ready_after_return") > 0, "world_ready_after_return row with build_ms (%s ms)" % str(_last_build_ms("world_ready_after_return")))
	_expect(not Engine.has_meta(WorldMap3DMemProbe.PENDING_RETURN_META), "pending return consumed")

	# 2. 2D setting at load: the host builds nothing
	WorldMap3DSettings.set_wants_3d(false)
	main = await _open(packed)
	host = main.get_node_or_null("WorldMap3DHost")
	_expect(host != null and not host.active and host.adapter == null, "2D setting: host builds no 3D map")
	_expect(main.find_child("WorldMap3DLayer", true, false) == null, "2D setting: no WorldMap3DLayer")
	_expect((main.get_node("WorldMapRoot") as CanvasItem).visible, "2D setting: $WorldMapRoot visible")
	_expect(main.get("_camera_controller") != null and not (main.get("_camera_controller") is WorldMap3DCameraController), "2D setting: main's own 2D controller")
	WorldMap3DSettings.set_wants_3d(true)

	# 3. 3D files missing: 2D fallback
	current_scene.queue_free()
	await process_frame
	var inst := packed.instantiate()
	(inst.get_node("WorldMap3DHost") as WorldMap3DHost).scene_path_3d = "res://worldmap3d/scenes/__missing_for_test__.tscn"
	get_root().add_child(inst)
	current_scene = inst
	for i in 4:
		await process_frame
	host = inst.get_node("WorldMap3DHost")
	_expect(not host.active and host.adapter == null and inst.find_child("WorldMap3DLayer", true, false) == null, "3D missing: no 3D map, no layer")
	_expect((inst.get_node("WorldMapRoot") as CanvasItem).visible and not (inst.get("_camera_controller") is WorldMap3DCameraController), "3D missing: 2D world map and 2D controller")
	inst.queue_free()
	await process_frame

	_finish()


## change_scene_to_packed and wait until the 3D map (if any) is built.
func _open(packed: PackedScene) -> Node:
	change_scene_to_packed(packed)
	await process_frame
	await process_frame
	var main := current_scene
	var host = main.get_node_or_null("WorldMap3DHost") if main != null else null
	var waited := 0
	while waited < 600 and host != null and WorldMap3DSettings.use_3d() and (host.adapter == null or host.adapter.root3d == null or host.adapter.root3d.cities.is_empty()):
		await process_frame
		waited += 1
	for i in 4:
		await process_frame
	return main


func _rows() -> PackedStringArray:
	return FileAccess.get_file_as_string(MEM_LOG_TEST).strip_edges().split("\n") if FileAccess.file_exists(MEM_LOG_TEST) else PackedStringArray()


func _count_label(label: String) -> int:
	var n := 0
	for r in _rows():
		if r.split(",").size() > 1 and r.split(",")[1] == label:
			n += 1
	return n


func _last_build_ms(label: String) -> float:
	var v := -1.0
	for r in _rows():
		var c := r.split(",")
		if c.size() == 9 and c[1] == label and c[8].is_valid_float():
			v = float(c[8])
	return v


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _expect(ok: bool, msg: String) -> void:
	_checks += 1
	if not ok:
		_failures.append(msg)
		push_error("[WM3D_PRODUCTION] FAIL " + msg)


func _finish() -> void:
	_remove(SETTINGS_TEST)
	_remove(MEM_LOG_TEST)
	print("[WM3D_PRODUCTION] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(1 if not _failures.is_empty() else 0)
