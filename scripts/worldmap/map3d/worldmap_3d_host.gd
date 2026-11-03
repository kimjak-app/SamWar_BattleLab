## EASTWAR WorldMap3D -> game layer: attaches the 3D map to an UNCHANGED worldmap_main.gd. This node is a SIBLING of the
## WorldMap root (see WorldMap3D_Host_Test.tscn); worldmap_main.gd itself is not edited (its bytes are pinned by the
## C-track validators until T-WM3D-08 re-pins them once). It reads / sets main's private names through get / set / call,
## on purpose: if main renames them, test_worldmap3d_host.gd fails loudly.
class_name WorldMap3DHost
extends Node

const CameraControllerScript := preload("res://scripts/worldmap/map3d/worldmap_3d_camera_controller.gd")
const AdapterScript := preload("res://scripts/worldmap/map3d/worldmap_3d_adapter.gd")
const SYNC_INTERVAL := 0.25   # seconds between owner/troop syncs while 3D is on (the adapter skips unchanged cities)

@export var main_path: NodePath = NodePath("../WorldMap")
@export var start_in_3d := true   # dev/test scene: starts on the 3D map. toggle by code only (`toggle_map_view_3d()`); the production switch is a settings screen at T-WM3D-08

var main: Node = null
var adapter: WorldMap3DAdapter = null
var active := false
var _sync_timer := 0.0


func _ready() -> void:
	main = get_node_or_null(main_path)
	if main == null:
		push_warning("WorldMap3DHost: worldmap main not found at %s" % str(main_path))
		return
	if start_in_3d:
		set_map_view_3d(true)


func _process(delta: float) -> void:
	if not active or adapter == null:
		return
	_sync_timer += delta
	if _sync_timer >= SYNC_INTERVAL:
		_sync_timer = 0.0
		adapter.sync_all()


func toggle_map_view_3d() -> bool:
	return set_map_view_3d(not active)


## Switches between the 2D world map and the 3D map. Returns false (and changes nothing) when main is missing, a
## battle-entry camera handoff is running, or the 3D scene is unavailable (mobile build / C-track import without worldmap3d/).
func set_map_view_3d(enable: bool) -> bool:
	if main == null:
		return false
	if enable == active:
		return true
	var old = main.get("_camera_controller")
	if old != null and old.is_battle_entry_handoff_in_progress():
		return false
	if enable:
		if adapter == null:
			var created := AdapterScript.new() as WorldMap3DAdapter
			created.name = "WorldMap3DAdapter"
			add_child(created)
			created.world_root_2d = main.get_node_or_null("WorldMapRoot") as CanvasItem
			created.troops_provider = Callable(self, "_city_troops")
			created.faction_resolver = Callable(self, "_city_owner")
			if not created.create_layer(main):
				created.queue_free()
				return false
			created.set_markers(main.get("_city_markers_by_id"))
			adapter = created
		adapter.set_active(true)
		active = true
		adapter.sync_all()
	else:
		if adapter != null:
			adapter.set_active(false)
		active = false
	_replace_camera_controller(old)
	return true


func _replace_camera_controller(old) -> void:
	if old != null:
		old.name = "WorldMapCameraController_replaced"   # queue_free is deferred; free the node name for the new one
		old.queue_free()
	main.set("_camera_controller", null)
	if active:
		var controller = CameraControllerScript.new()
		controller.name = "WorldMapCameraController"
		main.add_child(controller)
		controller.configure_3d(adapter.get_camera(), main.get("camera_debug_label"), main)
		controller.skip_battle_entry_camera = true   # the 3D handoff comes with T-WM3D-07
		main.set("_camera_controller", controller)
	else:
		main.call("_ensure_camera_controller")   # main builds its own 2D controller, exactly as at startup


func _city_troops(city_id: String) -> int:
	var entry: Dictionary = main.call("_get_city_hud_entry", city_id)
	return int(entry.get("troops", 0))


func _city_owner(marker) -> String:
	var entry: Dictionary = main.call("_get_city_hud_entry", str(marker.city_id))
	var owner_id := str(entry.get("owner_faction_id", entry.get("owner", entry.get("nation", ""))))
	return owner_id if not owner_id.is_empty() else str(marker.owner_faction_id)
