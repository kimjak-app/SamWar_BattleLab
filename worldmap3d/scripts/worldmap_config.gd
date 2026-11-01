## EASTWAR WorldMap3D v3 — map config (one JSON per map). Everything map-specific is read from here:
## size, coordinate transform, height scale, texture paths, region table, marker table, rivers, camera limits.
## Swapping the map = pointing WorldMap3DRoot.map_config_path at another config. No code/shader change.
class_name WorldMapConfig
extends RefCounted

var path: String
var raw: Dictionary
var map_id: String
var size_km: Vector2              # map rect: x in [-w/2, w/2] (east+), z in [-h/2, h/2] (south+), 1 unit = 1 km
var height_grid_path: String
var grid_size: Vector2i
var height_scale: float           # y = height_m * height_scale / 1000
var textures: Dictionary          # key -> res path
var coast_sdf_km := 8.0
var depth_max_m := 4000.0
var region_dist_max_km := 40.0
var regions_path: String
var markers_path: String
var rivers_path: String
var rule_data_path: String
var camera: Dictionary
var territory: Dictionary
var look: Dictionary

func load_file(p: String) -> bool:
	path = p
	var txt := FileAccess.get_file_as_string(p)
	if txt.is_empty():
		push_error("WorldMapConfig: cannot read " + p)
		return false
	raw = JSON.parse_string(txt)
	if raw == null:
		push_error("WorldMapConfig: bad JSON " + p)
		return false
	map_id = raw.get("map_id", "map")
	size_km = _v2(raw.size_km)
	var h: Dictionary = raw.height
	height_grid_path = _res(h.grid)
	grid_size = Vector2i(int(h.grid_size[0]), int(h.grid_size[1]))
	height_scale = float(h.height_scale)
	textures = {}
	for k in raw.textures:
		var v = raw.textures[k]
		if v is Array:                    # v2.2: tiled textures (albedo_tiles / normal_tiles)
			var arr := []
			for e in v:
				arr.append(_res(String(e)))
			textures[k] = arr
		else:
			textures[k] = _res(v)
	var enc: Dictionary = raw.get("encoding", {})
	coast_sdf_km = float(enc.get("coast_sdf_km", coast_sdf_km))
	depth_max_m = float(enc.get("depth_max_m", depth_max_m))
	region_dist_max_km = float(enc.get("region_dist_max_km", region_dist_max_km))
	regions_path = _res(raw.regions)
	markers_path = _res(raw.markers)
	rivers_path = _res(raw.get("rivers", ""))
	rule_data_path = _res(raw.get("rule_data", ""))
	camera = raw.get("camera", {})
	territory = raw.get("territory", {})
	look = raw.get("look", {})
	return true

## Paths in the config may be res:// absolute or relative to the config file's folder.
func _res(p: String) -> String:
	if p.is_empty() or p.begins_with("res://") or p.begins_with("user://"):
		return p
	return path.get_base_dir().path_join(p)

static func _v2(a) -> Vector2:
	return Vector2(float(a[0]), float(a[1]))

func cam(key: String, def):
	return camera.get(key, def)

## Active fill preset ("strong" / "medium" / "light") -> Dictionary
func fill_preset(name := "") -> Dictionary:
	var presets: Dictionary = territory.get("presets", {})
	var n: String = name if name != "" else territory.get("fill_preset", "light")
	return presets.get(n, {"fill_far": 0.50, "fill_near": 0.08, "band": 0.80})
