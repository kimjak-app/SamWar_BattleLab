extends SceneTree

# T-WM3D-03-4: WorldMap3DHost attaches the 3D map to an unchanged worldmap_main.gd. Opens the real WorldMap.tscn (2D,
# no host) and WorldMap3D_Host_Test.tscn (WorldMap + sibling WorldMap3DHost) the same way
# test_worldmap_to_battle_input_lifecycle.gd does.

const WORLDMAP_SCENE := preload("res://WorldMap.tscn")
const HOST_SCENE_PATH := "res://WorldMap3D_Host_Test.tscn"
const MEM_LOG_TEST := "user://wm3d_mem_log_host_test.csv"
const SETTINGS_TEST := "user://samwar_worldmap3d_host_test.cfg"

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# 1. WorldMap.tscn with the 2D setting stays 2D (T-WM3D-08: WorldMap.tscn has its own host; settings in a test file)
	WorldMap3DSettings.path = SETTINGS_TEST
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_TEST))
	WorldMap3DSettings.set_wants_3d(false)
	_expect(change_scene_to_packed(WORLDMAP_SCENE) == OK, "WorldMap scene transition starts")
	await process_frame
	await process_frame
	var main2d := current_scene
	_expect(main2d != null, "WorldMap scene loaded")
	_expect(main2d.find_child("WorldMap3DLayer", true, false) == null, "2D setting: no WorldMap3DLayer")
	_expect(not (main2d.get("_camera_controller") is WorldMap3DCameraController), "2D setting: 2D camera controller")
	WorldMap3DSettings.set_wants_3d(true)

	# 2. host scene starts in 3D (T-WM3D-07: the shared memory probe writes to a test file)
	WorldMap3DMemProbe.shared().log_path = MEM_LOG_TEST
	DirAccess.remove_absolute(ProjectSettings.globalize_path(MEM_LOG_TEST))
	_expect(change_scene_to_packed(load(HOST_SCENE_PATH)) == OK, "host scene transition starts")
	await process_frame
	await process_frame
	var main = current_scene.get_node_or_null("WorldMap") if current_scene != null else null
	var sibling = current_scene.get_node_or_null("WorldMap3DHost") if current_scene != null else null
	var host = main.get_node_or_null("WorldMap3DHost") if main != null else null   # T-WM3D-08: WorldMap.tscn's own host
	_expect(host is WorldMap3DHost and main != null, "host scene: WorldMap + its WorldMap3DHost")
	_expect(sibling is WorldMap3DHost and sibling.idle and sibling.adapter == null, "host scene: the sibling host stays idle (one host per main)")
	_expect(main != null and main.get_meta("wm3d_host", null) == host, "main's wm3d_host meta = WorldMap.tscn's host")
	if not (host is WorldMap3DHost) or main == null:
		_finish()
		return

	# main's private names the host depends on (until T-WM3D-08 moves this into main)
	_expect("_camera_controller" in main and main.get("_camera_controller") != null, "main has _camera_controller")
	_expect(main.has_method("_ensure_camera_controller"), "main has _ensure_camera_controller()")
	_expect(main.has_method("_get_city_hud_entry"), "main has _get_city_hud_entry()")
	_expect(main.get("_city_markers_by_id") is Dictionary, "main has _city_markers_by_id (Dictionary)")
	_expect(main.get("camera_debug_label") is Label, "main has camera_debug_label (Label)")

	var waited := 0
	while waited < 600 and (host.adapter == null or host.adapter.root3d == null or host.adapter.root3d.cities.is_empty()):
		await process_frame
		waited += 1
	for i in range(3):
		await process_frame
	var adapter: WorldMap3DAdapter = host.adapter
	_expect(host.main == main, "host.main is the WorldMap root")
	_expect(host.active, "3D start: host.active")
	_expect(adapter != null and adapter.is_active(), "3D start: adapter active")
	_expect(adapter != null and adapter.layer != null and adapter.layer.visible, "3D start: 3D layer visible")
	var world2d := main.get_node("WorldMapRoot") as CanvasItem
	_expect(world2d.visible == false, "3D start: $WorldMapRoot hidden")
	_expect(main.get("_camera_controller") is WorldMap3DCameraController, "3D start: 3D camera controller")
	_expect(main.get_node_or_null("WorldMapCameraController") == main.get("_camera_controller"), "3D start: the node named WorldMapCameraController is main's controller")
	if adapter == null or adapter.root3d == null:
		_finish()
		return
	var root3d = adapter.root3d

	# 3. 3D pick -> main selection
	root3d.city_selected.emit("hanseong", 1)
	_expect(main.get("selected_city_id") == "hanseong", "3D pick hanseong -> selected_city_id hanseong")
	root3d.city_selected.emit("pyeongyang", 1)
	_expect(main.get("selected_city_id") == "pyeongyang", "3D pick pyeongyang -> selected_city_id pyeongyang")
	root3d.city_selected.emit("", 0)
	_expect(main.get("selected_city_id") == "pyeongyang", "3D pick on empty ground: selection unchanged")

	# 4. owner + troops match for every city
	var markers: Dictionary = main.get("_city_markers_by_id")
	var bad := []
	for cid in markers.keys():
		var city_id := str(cid)
		var want_owner: String = host._city_owner(markers[cid])
		var want_troops := int((main.call("_get_city_hud_entry", city_id) as Dictionary).get("troops", 0))
		var city3d: Dictionary = root3d.cities.get(city_id, {})
		if str(city3d.get("owner", "")) != want_owner or int(city3d.get("troops", -1)) != want_troops:
			bad.append([city_id, city3d.get("owner", ""), want_owner, city3d.get("troops", -1), want_troops])
	_expect(markers.size() == 13, "13 city markers (%d)" % markers.size())
	_expect(bad.is_empty(), "every city: 3D owner and troops = game values %s" % str(bad))

	# 5. runtime changes follow (host syncs every SYNC_INTERVAL = 0.25 s)
	main.call("_set_city_runtime_troops", "hanseong", 777)
	main.call("_set_city_runtime_owner", "luoyang", "wei")
	await create_timer(0.5).timeout
	_expect(int(root3d.cities["hanseong"].get("troops", -1)) == 777, "troops 777 on hanseong reach the 3D map")
	_expect(str(root3d.cities["luoyang"].get("owner", "")) == "wei", "owner wei on luoyang reaches the 3D map")

	# 6. toggle 2D <-> 3D by code; F8 (Godot's editor stop key) is no longer a toggle key
	var old_controller = main.get("_camera_controller")
	_expect(host.toggle_map_view_3d(), "toggle returns true")
	var now_controller = main.get("_camera_controller")
	_expect(not host.active, "toggle: 3D off")
	_expect(world2d.visible == true, "toggle: $WorldMapRoot visible")
	_expect(adapter.layer.visible == false, "toggle: 3D layer hidden")
	_expect(now_controller != null and not (now_controller is WorldMap3DCameraController), "toggle: 2D camera controller")
	_expect(main.get_node_or_null("WorldMapCameraController") == now_controller and now_controller != old_controller, "toggle: the node named WorldMapCameraController is the new controller")
	old_controller = now_controller
	host.toggle_map_view_3d()
	now_controller = main.get("_camera_controller")
	_expect(host.active and adapter.layer.visible and world2d.visible == false, "toggle again: back to 3D")
	_expect(now_controller is WorldMap3DCameraController, "toggle again: 3D camera controller")
	_expect(main.get_node_or_null("WorldMapCameraController") == now_controller and now_controller != old_controller, "toggle again: the node named WorldMapCameraController is the new controller")
	await process_frame
	var f8 := InputEventKey.new()
	f8.keycode = KEY_F8
	f8.pressed = true
	root.push_input(f8)
	await process_frame
	_expect(host.active and world2d.visible == false, "F8: no toggle (still 3D, 2D root hidden)")
	root.push_input(f8)
	await process_frame
	_expect(host.active and world2d.visible == false, "F8 again: still 3D, 2D root hidden")

	# 7. T-WM3D-07: battle-entry camera handoff in 3D. main's own 72% focus (2D) -> host converter -> 3D 72% point
	var ctl3d = main.call("_ensure_camera_controller")
	_expect(ctl3d is WorldMap3DCameraController and ctl3d.skip_battle_entry_camera == false, "3D: controller does not skip the battle-entry camera")
	_expect(ctl3d.focus_converter.is_valid(), "3D: controller focus_converter is connected")
	var xz: Dictionary = root3d.marker_xz
	var worst := 0.0
	var pair_list := [["hanseong", "pyeongyang"], ["luoyang", "jianye"], ["chengdu", "jianye"], ["gyeongju", "kyoto"], ["sabi", "kyushu"], ["karakorum", "yecheng"]]
	for pr in pair_list:
		var focus: Dictionary = main.call("_build_worldmap_battle_entry_focus", pr[0], pr[1])
		var got3: Vector2 = host._focus_for_battle_entry(focus.get("position", Vector2.ZERO))
		worst = maxf(worst, got3.distance_to((xz[pr[0]] as Vector2).lerp(xz[pr[1]], WorldMap3DHost.BATTLE_ENTRY_BLEND)))
	_expect(worst <= 0.001, "main 72%% focus -> host converter = 3D 72%% point on %d pairs (worst %.6f km)" % [pair_list.size(), worst])
	_expect(not host._focus_for_battle_entry(Vector2(-99999, -99999)).is_finite(), "host converter: unknown 2D point -> INF")
	var calls := [0]
	main.call("_start_worldmap_battle_entry_camera_handoff", "hanseong", "pyeongyang", func() -> void: calls[0] += 1)
	var want_hp: Vector2 = (xz["hanseong"] as Vector2).lerp(xz["pyeongyang"], 0.72)
	_expect(calls[0] == 0 and ctl3d.is_battle_entry_handoff_in_progress(), "3D: handoff runs (continue not called yet)")
	_expect(adapter.get_camera()._target_goal.distance_to(want_hp) <= 0.001, "3D: camera goal = 3D 72%% point hanseong->pyeongyang")
	_expect(host.set_map_view_3d(false) == false and host.active, "3D: set_map_view_3d(false) refused during the handoff")
	main.call("_skip_worldmap_battle_entry_camera_handoff")
	_expect(calls[0] == 1 and not ctl3d.is_battle_entry_handoff_in_progress(), "3D: skip -> continue exactly once")
	await create_timer(1.0).timeout
	_expect(calls[0] == 1, "3D: still exactly once after the handoff time")

	# 7b. T-WM3D-07: memory probe wiring (log written to a test file, not the real user://wm3d_mem_log.csv)
	var probe := WorldMap3DMemProbe.shared()
	_expect(host.mem_probe_enabled and _has_label(probe.log_path, "map_ready"), "probe: map_ready row written at 3D start")
	_expect(main.tree_exiting.is_connected(host._on_main_tree_exiting), "probe: host listens to main.tree_exiting")
	Engine.set_meta("samwar_worldmap_battle_context", {"test": true})
	host._on_main_tree_exiting()
	Engine.remove_meta("samwar_worldmap_battle_context")
	_expect(_has_label(probe.log_path, "before_battle"), "probe: before_battle row written when main leaves for a battle")
	_expect(Engine.has_meta(WorldMap3DMemProbe.PENDING_RETURN_META), "probe: before_battle marks a pending return (08 reads it)")
	Engine.remove_meta(WorldMap3DMemProbe.PENDING_RETURN_META)

	# 8. missing 3D scene: covered by test_worldmap3d_adapter.gd ("create_layer(missing file) is false").

	# 9. T-WM3D-07: a real scene change for a battle (an empty stand-in scene for Battle_Main.tscn, which would need the
	# battle side). main sets its battle-context meta, then change_scene: before_battle is written while the 3D layer is
	# still in the tree, the host and main are freed with the scene, and the probe writes battle_ready_plus_60f 60 frames on.
	var layer_alive := [false]
	var layer_in_tree := [true]
	main.tree_exiting.connect(func() -> void:
		layer_alive[0] = is_instance_valid(adapter.layer) and is_instance_valid(adapter.root3d)
		layer_in_tree[0] = layer_alive[0] and adapter.layer.is_inside_tree(), CONNECT_ONE_SHOT)
	var before_rows := _count_label(probe.log_path, "before_battle")
	var stand_in := PackedScene.new()
	var stand_in_node := Node.new()
	stand_in_node.name = "BattleStandIn"
	stand_in.pack(stand_in_node)
	stand_in_node.free()
	Engine.set_meta("samwar_worldmap_battle_context", {"test": true})
	change_scene_to_packed(stand_in)
	for i in 30:
		await process_frame
	_expect(current_scene != null and current_scene.name == "BattleStandIn", "battle stand-in scene is current")
	_expect(not is_instance_valid(host) and not is_instance_valid(main), "host and main are freed with the world-map scene")
	_expect(layer_alive[0], "3D layer and 3D root not freed yet when main.tree_exiting fires")
	print("[WORLDMAP3D_HOST] note: at main.tree_exiting the 3D layer is_inside_tree = %s (children leave the tree first)" % str(layer_in_tree[0]))
	_expect(_count_label(probe.log_path, "before_battle") == before_rows + 1, "before_battle row written once by the real scene change")
	_expect(_count_label(probe.log_path, "battle_ready_plus_60f") == 0 and probe.is_waiting(), "battle_ready_plus_60f not yet at 30 frames")
	for i in 40:
		await process_frame
	_expect(_count_label(probe.log_path, "battle_ready_plus_60f") == 1, "battle_ready_plus_60f row written after 60 frames")
	_expect(FileAccess.get_file_as_string(probe.log_path).contains(",battle_ready_plus_60f,") and FileAccess.get_file_as_string(probe.log_path).strip_edges().ends_with(",BattleStandIn,"), "battle_ready_plus_60f row records the battle scene")
	Engine.remove_meta("samwar_worldmap_battle_context")
	if Engine.has_meta(WorldMap3DMemProbe.PENDING_RETURN_META):
		Engine.remove_meta(WorldMap3DMemProbe.PENDING_RETURN_META)
	_finish()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP3D_HOST_FAIL] %s" % label)


func _count_label(path: String, label: String) -> int:
	return FileAccess.get_file_as_string(path).count("," + label + ",") if FileAccess.file_exists(path) else 0


func _has_label(path: String, label: String) -> bool:
	return FileAccess.file_exists(path) and FileAccess.get_file_as_string(path).contains("," + label + ",")


func _finish() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(MEM_LOG_TEST))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_TEST))
	print("[WORLDMAP3D_HOST] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
