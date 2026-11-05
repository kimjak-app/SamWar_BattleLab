## EASTWAR WorldMap3D -> game layer: attaches the 3D map to an UNCHANGED worldmap_main.gd. T-WM3D-08: the production
## WorldMap.tscn holds this node as a CHILD of the WorldMap root (main_path ".."); WorldMap3D_Host_Test.tscn still adds a
## SIBLING one, which then stays idle (one host per main, the first to claim it wins). worldmap_main.gd is not edited; the
## host reads / sets main's private names through get / set / call, on purpose: if main renames them,
## test_worldmap3d_host.gd fails loudly. 2D stays exactly as before when the player chose 2D (WorldMap3DSettings) or the
## 3D files are missing (mobile export, C-track import with worldmap3d/ ignored): then no 3D layer is built at all.
class_name WorldMap3DHost
extends Node

const CameraControllerScript := preload("res://scripts/worldmap/map3d/worldmap_3d_camera_controller.gd")
const AdapterScript := preload("res://scripts/worldmap/map3d/worldmap_3d_adapter.gd")
const SYNC_INTERVAL := 0.25   # seconds between owner/troop syncs while 3D is on (the adapter skips unchanged cities)
const BATTLE_ENTRY_BLEND := 0.72   # = worldmap_main.gd _build_worldmap_battle_entry_focus lerp (test_worldmap3d_host.gd checks it)
const MAIN_BATTLE_META_CONST := "WORLDMAP_BATTLE_CONTEXT_META_KEY"   # main sets this Engine meta right before Battle_Main
const MAIN_HOST_META := "wm3d_host"   # main's meta -> the host that owns it (one host per main)

@export var main_path: NodePath = NodePath("../WorldMap")
@export var mem_probe_enabled := true   # T-WM3D-07: memory rows in user://wm3d_mem_log.csv (3D mode only)
@export var scene_path_3d := ""   # empty = WorldMap3DSettings.SCENE_3D (tests point it at a missing file: 2D fallback)
@export var start_in_3d := true   # false = never start in 3D (WorldMap3DSettings decides otherwise; toggle_map_view_3d() by code)

var main: Node = null
var adapter: WorldMap3DAdapter = null
var active := false
var idle := false         # true = another host already owns main (WorldMap3D_Host_Test.tscn's sibling host), or no main
var _sync_timer := 0.0
var _t_start_ms := 0


func _ready() -> void:
	_t_start_ms = Time.get_ticks_msec()
	var m := get_node_or_null(main_path)
	if m == null:
		idle = true
		push_warning("WorldMap3DHost: worldmap main not found at %s" % str(main_path))
		return
	var owner_host = m.get_meta(MAIN_HOST_META) if m.has_meta(MAIN_HOST_META) else null
	if owner_host != null and is_instance_valid(owner_host) and owner_host != self:
		idle = true
		print("[WorldMap3DHost] %s idle: %s already hosts the 3D map for %s" % [get_path(), owner_host.get_path(), m.get_path()])
		return
	m.set_meta(MAIN_HOST_META, self)
	main = m
	add_to_group(WorldMap3DSettings.HOST_GROUP)
	if not main.is_node_ready():   # child of main (WorldMap.tscn): main._ready builds its markers / 2D controller after us
		await main.ready
	main.tree_exiting.connect(_on_main_tree_exiting)
	if start_in_3d and WorldMap3DSettings.wants_3d():
		if not set_map_view_3d(true):
			print("[WorldMap3DHost] 3D map unavailable (%s) -> 2D world map" % _scene_3d())


func _scene_3d() -> String:
	return scene_path_3d if not scene_path_3d.is_empty() else WorldMap3DSettings.SCENE_3D


func _exit_tree() -> void:
	if main != null and is_instance_valid(main) and main.has_meta(MAIN_HOST_META) and main.get_meta(MAIN_HOST_META) == self:
		main.remove_meta(MAIN_HOST_META)


## Settings popup (WorldMap3DSettings changed): 2D / 3D now, and the 3D camera input scheme. Returns false when the
## switch was refused (battle-entry handoff running, 3D unavailable).
func apply_settings() -> bool:
	if main == null or idle:
		return false
	var ok := set_map_view_3d(WorldMap3DSettings.use_3d())
	_apply_camera_scheme()
	return ok


func _apply_camera_scheme() -> void:
	var s := WorldMap3DSettings.camera_scheme()
	var cam = adapter.get_camera() if adapter != null else null
	if cam != null and not s.is_empty() and cam.has_method("set_input_scheme"):
		cam.set_input_scheme(s)


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
	if main == null or idle:
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
			if not created.create_layer(main, _scene_3d()):
				created.queue_free()
				return false
			created.set_markers(main.get("_city_markers_by_id"))
			adapter = created
			_apply_camera_scheme()
			_sample_map_ready()
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
		controller.focus_converter = Callable(self, "_focus_for_battle_entry")
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


## T-WM3D-07: main's 2D battle-entry focus (72% from the attacking city to the target) -> the same 72% point between the
## two cities on the 3D map. Vector2.INF when it cannot be converted: the controller then skips the camera move and the
## battle starts at once (a failed camera move must never block the battle).
func _focus_for_battle_entry(pos2d: Vector2) -> Vector2:
	if adapter == null:
		return Vector2.INF
	return adapter.focus_for_blend_2d(pos2d, BATTLE_ENTRY_BLEND, Vector2.INF)


# ------------------------------------------------------------------ T-WM3D-07 memory probe
func _sample_map_ready() -> void:
	if not mem_probe_enabled:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	if active and is_inside_tree():
		var probe := WorldMap3DMemProbe.shared()
		var ms := float(Time.get_ticks_msec() - _t_start_ms)   # host start (scene load) -> 3D map shown
		probe.sample("map_ready", ms)
		probe.consume_pending_return("world_ready_after_return", ms)   # T-WM3D-08: back from a battle


## main leaves the tree: when it is leaving for a battle (main set its battle-context meta just before
## change_scene_to_file), sample while the 3D layer still exists, then 60 frames into Battle_Main (the probe outlives
## this host in Engine meta), and mark the return for T-WM3D-08's 3D world map.
func _on_main_tree_exiting() -> void:
	if not active or not mem_probe_enabled or main == null:
		return
	var key = main.get_script().get_script_constant_map().get(MAIN_BATTLE_META_CONST, "") if main.get_script() != null else ""
	if String(key).is_empty() or not Engine.has_meta(String(key)):
		return
	var probe := WorldMap3DMemProbe.shared()
	probe.sample("before_battle")
	probe.mark_pending_return()
	probe.sample_after_frames("battle_ready_plus_60f", 60)
