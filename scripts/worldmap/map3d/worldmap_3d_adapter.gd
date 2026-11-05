## EASTWAR WorldMap3D -> game layer: bridges the 2D game (WorldMapCityMarker nodes, which still carry all game logic)
## and the 3D map (WorldMap3DRoot). Not wired into any scene yet (T-WM3D-03-4 does that).
## The 3D root / camera are held in UNTYPED vars and the 3D scene is loaded by string path on purpose: this file lives
## under scripts/ (2D game, C-track CI, mobile export), which must not name classes or files from worldmap3d/.
class_name WorldMap3DAdapter
extends Node

signal city_pick_forwarded(city_id: String)

const SCENE_PATH_DEFAULT := "res://worldmap3d/scenes/worldmap3d_eastasia.tscn"
const LAYER_ORDER := -10   # behind the unchanged WorldMapUI HUD
const BLEND_MATCH_PX := 0.5   # T-WM3D-07 focus_for_blend_2d: max 2D distance (px) to accept a marker-pair blend

var root3d = null                      # WorldMap3DRoot (untyped, see header)
var layer: CanvasLayer = null
var markers_by_id: Dictionary = {}     # city_id -> WorldMapCityMarker (owned by main; 2D logic nodes stay alive)
var troops_provider: Callable = Callable()                       # (city_id: String) -> int ; set by main (03-4)
var faction_resolver: Callable = Callable()                      # (marker) -> String   ; empty = marker.owner_faction_id
var world_root_2d: CanvasItem = null   # the 2D map ($WorldMapRoot); hidden while 3D is active
var unmapped_owners: Array = []        # "city_id:faction_id" pairs the 3D map rejected (for tests / F6 report)
var _active := false
var _last_synced: Dictionary = {}   # city_id -> "faction|troops" last pushed to the 3D map
var _last_synced_ok: Dictionary = {}   # city_id -> whether the 3D map accepted that owner


## Builds the 3D layer (CanvasLayer -10 > SubViewportContainer > SubViewport > scene) under `parent`.
## Returns false (and builds nothing) when the 3D scene file is missing, e.g. in a mobile build.
func create_layer(parent: Node, scene_path: String = SCENE_PATH_DEFAULT) -> bool:
	if not ResourceLoader.exists(scene_path):
		return false
	var packed = load(scene_path)
	if packed == null or not (packed is PackedScene):
		return false
	layer = CanvasLayer.new()
	layer.name = "WorldMap3DLayer"
	layer.layer = LAYER_ORDER
	var container := SubViewportContainer.new()
	container.name = "WorldMap3DContainer"
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE   # main forwards input through the controller
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sub := SubViewport.new()
	sub.name = "WorldMap3DViewport"
	container.add_child(sub)
	layer.add_child(container)
	parent.add_child(layer)
	var inst = packed.instantiate()
	sub.add_child(inst)
	bind_root(inst)
	set_active(false)
	return true


## Binds an already-built 3D root (also used by tests with a fake root).
func bind_root(root) -> void:
	_last_synced.clear()
	_last_synced_ok.clear()
	if root3d != null and root3d.has_signal("city_selected") and root3d.city_selected.is_connected(_on_root_city_selected):
		root3d.city_selected.disconnect(_on_root_city_selected)
	root3d = root
	if root3d != null and root3d.has_signal("city_selected"):
		root3d.city_selected.connect(_on_root_city_selected)


func set_markers(markers: Dictionary) -> void:
	markers_by_id = markers


func get_camera():
	if root3d == null:
		return null
	return root3d.get("camera")


## 3D on = 3D layer visible + 2D map hidden (so its Area2D markers cannot also receive the click). Off = the reverse.
func set_active(value: bool) -> void:
	_active = value
	if value:
		_last_synced.clear()   # push every city once when the 3D map comes back
		_last_synced_ok.clear()
	if layer != null:
		layer.visible = value
	if world_root_2d != null:
		world_root_2d.visible = not value


func is_active() -> bool:
	return _active


## 3D pick -> the same signal a 2D click would have emitted, so main's _on_city_marker_selected runs unchanged.
## An empty city_id (click on empty ground) is ignored: what 2D does for that is decided in 03-4, not guessed here.
func _on_root_city_selected(city_id: String, _region_index: int) -> void:
	if not _active or city_id.is_empty():
		return
	var marker = markers_by_id.get(city_id)
	if marker == null or not is_instance_valid(marker):
		return
	city_pick_forwarded.emit(city_id)
	marker.city_selected.emit(marker)


## Pushes one city's owner (and troops, if a provider is set) from the 2D side into the 3D map.
## Returns true when the 3D map accepted the owner. Rejected pairs are recorded in unmapped_owners.
## A city whose owner and troops are unchanged since the last push is not pushed again (main syncs on every HUD refresh).
func sync_city(city_id: String) -> bool:
	if root3d == null:
		return false
	var marker = markers_by_id.get(city_id)
	if marker == null or not is_instance_valid(marker):
		return false
	var faction: String = str(marker.owner_faction_id)
	if faction_resolver.is_valid():
		faction = str(faction_resolver.call(marker))
	var troops := int(troops_provider.call(city_id)) if troops_provider.is_valid() else -1
	var synced_key := "%s|%d" % [faction, troops]
	if _last_synced.get(city_id, null) == synced_key:
		return bool(_last_synced_ok.get(city_id, false))
	var ok: bool = bool(root3d.set_city_owner(city_id, faction))
	if not ok:
		var key := "%s:%s" % [city_id, faction]
		if not unmapped_owners.has(key):
			unmapped_owners.append(key)
	if troops_provider.is_valid():
		root3d.set_city_troops(city_id, troops)
	_last_synced[city_id] = synced_key
	_last_synced_ok[city_id] = ok
	return ok


func sync_all() -> int:
	var accepted := 0
	for city_id in markers_by_id.keys():
		if sync_city(str(city_id)):
			accepted += 1
	return accepted


## 2D focus position (what main passes to start_battle_entry_handoff) -> 3D ground coordinate.
## Looks the city up by its marker position; returns `fallback` when no marker sits there or the 3D map lacks the city.
func focus_for_2d_position(pos2d: Vector2, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	for city_id in markers_by_id.keys():
		var marker = markers_by_id[city_id]
		if marker != null and is_instance_valid(marker) and marker.global_position.is_equal_approx(pos2d):
			return focus_for_city(str(city_id), fallback)
	return fallback


## T-WM3D-07: main's battle-entry focus is the point `t` (0.72) of the way from one 2D marker to another. Finds the
## ordered marker pair (a, b) whose 2D blend lies within BLEND_MATCH_PX of `pos2d` (closest wins) and returns the same
## blend of their 3D positions. Otherwise an exact marker position (focus_for_2d_position), else `fallback`.
## Pairs whose city is missing in the 3D map are skipped. 13 cities = 156 ordered pairs, cheap.
func focus_for_blend_2d(pos2d: Vector2, t: float = 0.72, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	var xz = root3d.get("marker_xz") if root3d != null else null
	if not (xz is Dictionary):
		return fallback
	var best_err := INF
	var best := Vector2.ZERO
	for a in markers_by_id.keys():
		var ma = markers_by_id[a]
		if ma == null or not is_instance_valid(ma) or not xz.has(str(a)):
			continue
		for b in markers_by_id.keys():
			if a == b:
				continue
			var mb = markers_by_id[b]
			if mb == null or not is_instance_valid(mb) or not xz.has(str(b)):
				continue
			var err: float = (ma.global_position as Vector2).lerp(mb.global_position, t).distance_to(pos2d)
			if err <= BLEND_MATCH_PX and err < best_err:
				best_err = err
				best = (xz[str(a)] as Vector2).lerp(xz[str(b)], t)
	if best_err < INF:
		return best
	return focus_for_2d_position(pos2d, fallback)


func focus_for_city(city_id: String, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	if root3d == null:
		return fallback
	var xz = root3d.get("marker_xz")
	if xz is Dictionary and xz.has(city_id):
		return xz[city_id]
	return fallback
