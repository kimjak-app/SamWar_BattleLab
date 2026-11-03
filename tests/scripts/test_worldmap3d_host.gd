extends SceneTree

# T-WM3D-03-4: WorldMap3DHost attaches the 3D map to an unchanged worldmap_main.gd. Opens the real WorldMap.tscn (2D,
# no host) and WorldMap3D_Host_Test.tscn (WorldMap + sibling WorldMap3DHost) the same way
# test_worldmap_to_battle_input_lifecycle.gd does.

const WORLDMAP_SCENE := preload("res://WorldMap.tscn")
const HOST_SCENE_PATH := "res://WorldMap3D_Host_Test.tscn"

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# 1. WorldMap.tscn alone (no host) stays 2D
	_expect(change_scene_to_packed(WORLDMAP_SCENE) == OK, "WorldMap scene transition starts")
	await process_frame
	await process_frame
	var main2d := current_scene
	_expect(main2d != null, "WorldMap scene loaded")
	_expect(main2d.find_child("WorldMap3DLayer", true, false) == null, "no host: no WorldMap3DLayer")
	_expect(not (main2d.get("_camera_controller") is WorldMap3DCameraController), "no host: 2D camera controller")

	# 2. host scene starts in 3D
	_expect(change_scene_to_packed(load(HOST_SCENE_PATH)) == OK, "host scene transition starts")
	await process_frame
	await process_frame
	var host = current_scene.get_node_or_null("WorldMap3DHost") if current_scene != null else null
	var main = current_scene.get_node_or_null("WorldMap") if current_scene != null else null
	_expect(host is WorldMap3DHost and main != null, "host scene: WorldMap + WorldMap3DHost")
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

	# 7. battle-entry camera handoff is skipped in 3D (main unchanged; the 3D controller skips it)
	var calls := [0]
	main.call("_start_worldmap_battle_entry_camera_handoff", "hanseong", "pyeongyang", func() -> void: calls[0] += 1)
	_expect(calls[0] == 1, "3D: battle-entry handoff calls continue once at once (%d)" % calls[0])
	_expect(not main.call("_ensure_camera_controller").is_battle_entry_handoff_in_progress(), "3D: no handoff in progress")

	# 8. missing 3D scene: covered by test_worldmap3d_adapter.gd ("create_layer(missing file) is false").

	# 9. cleanup
	current_scene.queue_free()
	await process_frame
	_finish()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP3D_HOST_FAIL] %s" % label)


func _finish() -> void:
	print("[WORLDMAP3D_HOST] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
