## EASTWAR WorldMap3D -> game layer (T-WM3D-08): the player's world-map display settings (2D / 3D map, 3D camera input
## scheme A / B). USER settings (user://samwar_worldmap3d.cfg), never part of a game save: the save file is written by
## worldmap_main.gd _serialize_worldmap_state(), which does not read this.
## Own file on purpose: GameAudio (user://samwar_audio.cfg) rewrites its whole file from a fresh ConfigFile on every save,
## so a section added there would be dropped.
class_name WorldMap3DSettings
extends RefCounted

const PATH_DEFAULT := "user://samwar_worldmap3d.cfg"
const SECTION := "worldmap"
const KEY_MAP_VIEW := "map_view"          # "3d" (default) | "2d"
const KEY_CAMERA_SCHEME := "camera_input_scheme"   # "" (map default, EastAsia map_config "A") | "A" | "B"
const SCENE_3D := "res://worldmap3d/scenes/worldmap3d_eastasia.tscn"   # = WorldMap3DAdapter.SCENE_PATH_DEFAULT
const HOST_GROUP := "wm3d_host"           # the host joins this group; the settings popup calls apply_settings() on it

static var path := PATH_DEFAULT           # tests point this at a temp file


## The 3D map files are present (not a mobile export / C-track import with worldmap3d/ ignored).
static func is_3d_available() -> bool:
	return ResourceLoader.exists(SCENE_3D)


static func wants_3d() -> bool:
	return str(_read(KEY_MAP_VIEW, "3d")) != "2d"


## True when the world map should open in 3D: the player did not choose 2D and the 3D files exist.
static func use_3d() -> bool:
	return wants_3d() and is_3d_available()


static func set_wants_3d(enabled: bool) -> bool:
	return _write(KEY_MAP_VIEW, "3d" if enabled else "2d")


## "A" / "B", or "" = keep the map's own default (map_config camera.input_scheme).
static func camera_scheme() -> String:
	var s := str(_read(KEY_CAMERA_SCHEME, "")).to_upper()
	return s if s == "A" or s == "B" else ""


static func set_camera_scheme(scheme: String) -> bool:
	var s := scheme.to_upper()
	return _write(KEY_CAMERA_SCHEME, s if s == "A" or s == "B" else "")


static func _read(key: String, def):
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return def
	return cfg.get_value(SECTION, key, def)


static func _write(key: String, value) -> bool:
	var cfg := ConfigFile.new()
	cfg.load(path)   # missing file = start empty; other keys are kept
	cfg.set_value(SECTION, key, value)
	var err := cfg.save(path)
	if err != OK:
		push_warning("WorldMap3DSettings: cannot save %s (%s)" % [path, error_string(err)])
		return false
	return true
