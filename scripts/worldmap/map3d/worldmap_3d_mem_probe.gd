## EASTWAR WorldMap3D -> game layer (T-WM3D-07): video / texture / buffer memory + object counts at the battle-entry
## moments, appended to user://wm3d_mem_log.csv. Measuring only: nothing here changes the game.
## One shared probe lives in Engine meta (no autoload) so it outlives the world-map scene: the 3D host is freed when
## Battle_Main.tscn opens, and sample_after_frames() keeps counting SceneTree.process_frame on the probe itself.
## Headless runs read 0 for the RENDER_* monitors (no rendering device).
class_name WorldMap3DMemProbe
extends RefCounted

const META_KEY := "wm3d_mem_probe"
const PENDING_RETURN_META := "wm3d_mem_pending_return"   # set before a battle; T-WM3D-08's 3D world map reads it on return
const LOG_PATH_DEFAULT := "user://wm3d_mem_log.csv"
const CSV_HEADER := "unix_time,label,video_mb,texture_mb,buffer_mb,object_count,object_resource_count,scene,build_ms"
## T-WM3D-08 added build_ms (map_ready / world_ready_after_return: host start -> 3D map shown; empty otherwise). A log
## with another header (07's 8 columns) is moved aside to <name>_old_<unix time>.csv once, so one file never mixes two layouts.
const MB := 1048576.0

var log_path := LOG_PATH_DEFAULT
var _wait_label := ""
var _wait_frames := 0


## The probe shared across scenes (created on first use, kept in Engine meta).
static func shared() -> WorldMap3DMemProbe:
	if Engine.has_meta(META_KEY):
		var p = Engine.get_meta(META_KEY)
		if p is WorldMap3DMemProbe:
			return p
	var probe := WorldMap3DMemProbe.new()
	Engine.set_meta(META_KEY, probe)
	# A script RefCounted still held by Engine meta when the engine shuts down is freed after GDScript is gone and
	# crashes the exit (signal 11, seen headless on 4.6.2). Drop it when the SceneTree's root leaves (quit), which
	# happens once at shutdown, never on change_scene.
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null:
		tree.root.tree_exiting.connect(func() -> void:
			if Engine.has_meta(META_KEY):
				Engine.remove_meta(META_KEY), CONNECT_ONE_SHOT)
	return probe


## Reads the monitors now, appends one CSV row and returns the values. build_ms < 0 = not a map build row.
func sample(label: String, build_ms := -1.0) -> Dictionary:
	var s := {
		"unix_time": Time.get_unix_time_from_system(),
		"label": label,
		"video_mb": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / MB,
		"texture_mb": Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / MB,
		"buffer_mb": Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / MB,
		"object_count": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"object_resource_count": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		"scene": _scene_name(),
		"build_ms": build_ms,
	}
	_append(s)
	return s


## Samples once after `frames` process frames, even if the current scene is replaced meanwhile.
## A new call replaces a pending one.
func sample_after_frames(label: String, frames: int) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	_wait_label = label
	_wait_frames = maxi(frames, 1)
	if not tree.process_frame.is_connected(_on_process_frame):
		tree.process_frame.connect(_on_process_frame)


func is_waiting() -> bool:
	return _wait_frames > 0


## Called at before_battle; the world map that comes back reads it with consume_pending_return() (T-WM3D-08).
func mark_pending_return() -> void:
	Engine.set_meta(PENDING_RETURN_META, true)


## True (and one "world_ready_after_return" row written) when a battle left a pending return; clears it.
func consume_pending_return(label := "world_ready_after_return", build_ms := -1.0) -> bool:
	if not Engine.has_meta(PENDING_RETURN_META):
		return false
	Engine.remove_meta(PENDING_RETURN_META)
	sample(label, build_ms)
	return true


func _on_process_frame() -> void:
	_wait_frames -= 1
	if _wait_frames > 0:
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null and tree.process_frame.is_connected(_on_process_frame):
		tree.process_frame.disconnect(_on_process_frame)
	sample(_wait_label)


func _scene_name() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.current_scene == null:
		return ""
	return String(tree.current_scene.name).replace(",", "_")


func _append(s: Dictionary) -> void:
	_rotate_if_other_layout()
	var exists := FileAccess.file_exists(log_path)
	var f := FileAccess.open(log_path, FileAccess.READ_WRITE if exists else FileAccess.WRITE)
	if f == null:
		push_warning("WorldMap3DMemProbe: cannot write %s (%s)" % [log_path, error_string(FileAccess.get_open_error())])
		return
	if exists:
		f.seek_end()
	else:
		f.store_line(CSV_HEADER)
	var ms: float = s.get("build_ms", -1.0)
	f.store_line("%.3f,%s,%.3f,%.3f,%.3f,%d,%d,%s,%s" % [s.unix_time, String(s.label).replace(",", "_"), s.video_mb, s.texture_mb,
			s.buffer_mb, s.object_count, s.object_resource_count, s.scene, ("%.0f" % ms) if ms >= 0.0 else ""])
	f.close()


func _rotate_if_other_layout() -> void:
	if not FileAccess.file_exists(log_path):
		return
	var f := FileAccess.open(log_path, FileAccess.READ)
	if f == null:
		return
	var first := f.get_line().strip_edges()
	f.close()
	if first == CSV_HEADER:
		return
	var old_path := "%s_old_%d.csv" % [log_path.get_basename(), int(Time.get_unix_time_from_system())]
	var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(log_path), ProjectSettings.globalize_path(old_path))
	if err != OK:
		push_warning("WorldMap3DMemProbe: %s has another layout and cannot be moved to %s (%s)" % [log_path, old_path, error_string(err)])
