extends SceneTree

# Queue 41: the city action menu follows the city's 3D screen position (WorldMap3D track: the 3D map is really built).
#  1. 3D view on, 평양 click -> menu open, its centre within 160 px of 평양's projected castle position
#  2. camera pans -> the menu moves with the city
#  3. the city behind the camera -> the menu closes
#  4. the projection helper gives null for an unknown city and when 3D is off

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const CityActionController := preload("res://scripts/worldmap/ui/worldmap_city_action_controller.gd")
const CITY := "pyeongyang"

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1920, 1080)
	root.get_node("/root/GameSession").call("request_new_game", "player")
	change_scene_to_file(WORLDMAP_SCENE_PATH)
	for i in 8:
		await process_frame
	var main := current_scene
	var host := main.get_node_or_null("WorldMap3DHost") if main != null else null
	var adapter: Object = host.get("adapter") if host != null else null
	var camera: Camera3D = adapter.call("get_camera") if adapter != null else null
	_expect(host != null and bool(host.get("active")) and camera != null, "3D view active with a camera")
	if camera == null:
		_finish()
		return
	var controller := _find_by_script(main, CityActionController)
	var marker = (main.get("_city_markers_by_id") as Dictionary).get(CITY)
	adapter.get("root3d").call("focus_city", CITY, 0.5)
	for i in 3:
		await process_frame
	marker.city_selected.emit(marker)
	for i in 3:
		await process_frame
	var panel: Control = controller.get("_panel")
	var projected: Variant = adapter.call("city_screen_position", CITY)
	_expect(panel.visible and projected is Vector2, "1. menu open, 평양 on screen (%s)" % str(projected))
	if projected is Vector2:
		_expect((panel.position + panel.size * 0.5).distance_to(projected) < 160.0, "1. menu centre %s near 평양 %s" % [str(panel.position + panel.size * 0.5), str(projected)])
	# 2. pan: the menu follows
	var before_centre := panel.position + panel.size * 0.5
	camera.global_position += camera.global_transform.basis.x * 80.0
	for i in 3:
		await process_frame
	var moved: Variant = adapter.call("city_screen_position", CITY)
	if moved is Vector2 and panel.visible:
		_expect((panel.position + panel.size * 0.5).distance_to(moved) < 160.0 and (panel.position + panel.size * 0.5) != before_centre, "2. the menu moved with the city (%s -> %s)" % [str(before_centre), str(panel.position + panel.size * 0.5)])
	else:
		_expect(not panel.visible, "2. city left the view -> menu closed")
	# 3. behind the camera (the camera script owns its pose, so move the city's castle behind it instead)
	marker.city_selected.emit(marker)
	for i in 2:
		await process_frame
	var castle := (adapter.get("root3d").get("markers") as Dictionary)[CITY] as Node3D
	var castle_at := castle.global_position
	castle.global_position = camera.global_position + camera.global_transform.basis.z * 50.0  # +Z = behind a Camera3D
	for i in 2:
		await process_frame
	var behind: Variant = adapter.call("city_screen_position", CITY)
	_expect(behind == null and not panel.visible, "3. city behind the camera -> null, menu closed (%s)" % str(behind))
	castle.global_position = castle_at
	# 4. helper edge cases
	_expect(adapter.call("city_screen_position", "no_such_city") == null, "4. unknown city -> null")
	host.call("set_map_view_3d", false)
	await process_frame
	_expect(adapter.call("city_screen_position", CITY) == null, "4. 3D off -> null")
	_finish()


func _find_by_script(node: Node, script: Script) -> Node:
	if node.get_script() == script:
		return node
	for child in node.get_children():
		var found := _find_by_script(child, script)
		if found != null:
			return found
	return null


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[WM3D_HUD_MENU] FAIL " + message)


func _finish() -> void:
	print("[WM3D_HUD_MENU] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
