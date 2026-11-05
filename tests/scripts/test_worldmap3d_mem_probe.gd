extends SceneTree

# T-WM3D-07: WorldMap3DMemProbe — sample() keys / types, CSV header + rows, unwritable path (warning only), and the
# frame-count sample that must keep running across scene changes (the 3D host is freed when Battle_Main.tscn opens).
# Headless: the RENDER_* monitors read 0, so only "a number" is checked, not the value.

const LOG := "user://wm3d_mem_probe_test.csv"
const BAD_LOG := "user://wm3d_no_such_dir_for_test/x.csv"

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_remove(LOG)
	var probe := WorldMap3DMemProbe.new()
	probe.log_path = LOG

	# 1. sample(): keys and types
	var s: Dictionary = probe.sample("unit_a")
	for k in ["unix_time", "label", "video_mb", "texture_mb", "buffer_mb", "object_count", "object_resource_count", "scene"]:
		_expect(s.has(k), "sample has key %s" % k)
	_expect(s.get("label") == "unit_a", "sample label")
	for k in ["unix_time", "video_mb", "texture_mb", "buffer_mb"]:
		_expect(typeof(s.get(k)) == TYPE_FLOAT, "%s is a float" % k)
	for k in ["object_count", "object_resource_count"]:
		_expect(typeof(s.get(k)) == TYPE_INT and int(s.get(k)) > 0, "%s is a positive int" % k)
	_expect(typeof(s.get("scene")) == TYPE_STRING, "scene is a String")

	# 2. CSV: header once, one row per sample
	probe.sample("unit_b")
	var lines := _lines(LOG)
	_expect(lines.size() == 3, "CSV: header + 2 rows (%d lines)" % lines.size())
	_expect(lines.size() > 0 and lines[0] == WorldMap3DMemProbe.CSV_HEADER, "CSV: first line is the header")
	_expect(lines.size() == 3 and lines[1].split(",").size() == 9 and lines[2].split(",")[1] == "unit_b", "CSV: rows have 9 fields, label in field 2")
	_expect(lines.size() == 3 and lines[1].split(",")[2].is_valid_float(), "CSV: video_mb field is a number")

	# 2b. T-WM3D-08: build_ms column (map builds only) and a log with another layout is moved aside, not mixed
	probe.sample("unit_ms", 1234.4)
	lines = _lines(LOG)
	_expect(lines[lines.size() - 1].split(",")[8] == "1234" and lines[1].split(",")[8] == "", "CSV: build_ms written for a map row, empty otherwise")
	var f := FileAccess.open(LOG, FileAccess.WRITE)
	f.store_line("unix_time,label,video_mb,texture_mb,buffer_mb,object_count,object_resource_count,scene")
	f.store_line("1.000,old_row,0.000,0.000,0.000,1,1,X")
	f.close()
	probe.sample("unit_new_layout")
	lines = _lines(LOG)
	_expect(lines.size() == 2 and lines[0] == WorldMap3DMemProbe.CSV_HEADER and lines[1].split(",")[1] == "unit_new_layout", "old 8-column log moved aside: new file with the 9-column header")
	var moved := []
	for fn in DirAccess.get_files_at("user://"):
		if fn.begins_with("wm3d_mem_probe_test_old_") and fn.ends_with(".csv"):
			moved.append(fn)
	_expect(moved.size() == 1 and FileAccess.get_file_as_string("user://" + moved[0]).contains("old_row"), "old log kept as wm3d_mem_probe_test_old_<time>.csv")
	for fn in moved:
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + fn))

	# 3. unwritable path: no exception, still returns the sample
	var bad := WorldMap3DMemProbe.new()
	bad.log_path = BAD_LOG
	var sb: Dictionary = bad.sample("unit_bad")
	_expect(sb.get("label") == "unit_bad" and not FileAccess.file_exists(BAD_LOG), "unwritable path: sample returned, nothing written")

	# 4. shared() lives in Engine meta
	var shared := WorldMap3DMemProbe.shared()
	_expect(shared != null and shared == WorldMap3DMemProbe.shared() and Engine.get_meta(WorldMap3DMemProbe.META_KEY) == shared, "shared(): one probe kept in Engine meta")

	# 5. sample_after_frames survives scene changes (two empty scenes, like WorldMap -> Battle_Main)
	var scene_a := _empty_scene("SceneA")
	var scene_b := _empty_scene("SceneB")
	change_scene_to_packed(scene_a)
	await process_frame
	await process_frame
	probe.sample_after_frames("unit_after", 10)
	_expect(probe.is_waiting(), "sample_after_frames: waiting")
	change_scene_to_packed(scene_b)
	for i in 3:
		await process_frame
	_expect(current_scene != null and current_scene.name == "SceneB", "scene changed to SceneB")
	change_scene_to_packed(scene_a)
	for i in 12:
		await process_frame
	lines = _lines(LOG)
	var last := lines[lines.size() - 1].split(",") if lines.size() > 0 else PackedStringArray()
	_expect(last.size() == 9 and last[1] == "unit_after", "after 2 scene changes + 10 frames: unit_after row written")
	_expect(last.size() == 9 and last[7] == "SceneA", "unit_after row records the scene of the moment (SceneA)")
	_expect(not probe.is_waiting(), "sample_after_frames: done")
	_expect(Engine.get_meta(WorldMap3DMemProbe.META_KEY) == shared, "shared probe still in Engine meta after scene changes")
	for i in 12:
		await process_frame
	_expect(_lines(LOG).size() == lines.size(), "sample_after_frames writes once")

	# 6. pending return (08 interface)
	if Engine.has_meta(WorldMap3DMemProbe.PENDING_RETURN_META):
		Engine.remove_meta(WorldMap3DMemProbe.PENDING_RETURN_META)
	_expect(not probe.consume_pending_return(), "no pending return: consume is false")
	probe.mark_pending_return()
	_expect(Engine.has_meta(WorldMap3DMemProbe.PENDING_RETURN_META), "mark_pending_return sets the Engine meta")
	_expect(probe.consume_pending_return(), "consume_pending_return: true once")
	_expect(_lines(LOG)[_lines(LOG).size() - 1].split(",")[1] == "world_ready_after_return", "consume writes world_ready_after_return")
	_expect(not Engine.has_meta(WorldMap3DMemProbe.PENDING_RETURN_META) and not probe.consume_pending_return(), "consume clears the meta")

	_remove(LOG)
	_finish()


func _empty_scene(nm: String) -> PackedScene:
	var n := Node.new()
	n.name = nm
	var ps := PackedScene.new()
	ps.pack(n)
	n.free()
	return ps


func _lines(path: String) -> PackedStringArray:
	if not FileAccess.file_exists(path):
		return PackedStringArray()
	return FileAccess.get_file_as_string(path).strip_edges().split("\n")


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _expect(ok: bool, msg: String) -> void:
	_checks += 1
	if not ok:
		_failures.append(msg)
		push_error("[WM3D_MEM_PROBE] FAIL " + msg)


func _finish() -> void:
	print("[WM3D_MEM_PROBE] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(1 if not _failures.is_empty() else 0)
