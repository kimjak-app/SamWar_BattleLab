## EASTWAR WorldMap3D v3 — performance benchmark (target: GTX 1660 class, 1080p, Forward+).
## godot --path . --rendering-method forward_plus --resolution 1920x1080 res://tools/perf_bench.tscn -- [--seconds=30]
##   [--warmup=3] [--out=bench_out] [--config=res://.../map_config.json] [--fill=medium] [--static]
##   v2.2: [--empty] = BASELINE run: same window/renderer, an empty 3D scene (camera + light + sky) only, no map.
##         Writes <out>/bench_empty_<stamp>.csv. Map VRAM = map-scene vram_* minus this baseline (engine/driver/window).
## 5 zoom levels (0, 0.25, 0.5, 0.75, 1.0); each runs `seconds` after `warmup`; the camera slowly orbits/pans so
## the GPU sees changing views (--static = fixed camera). V-Sync off, no FPS cap.
## Output: <out>/bench_summary_<stamp>.csv (one row per zoom), <out>/bench_frames_<stamp>.csv (every frame),
##         <out>/bench_info_<stamp>.txt (GPU, driver, renderer, resolution, build stats).
extends Node

var seconds := 30.0
var warmup := 3.0
var out_dir := "bench_out"
var config_path := ""
var fill := ""
var static_cam := false
var empty_scene := false
var levels := [
	{"name": "z0_far", "zoom": 0.0, "xz": Vector2(65.8, -27.7)},
	{"name": "z1", "zoom": 0.25, "xz": Vector2(40.0, 40.0)},
	{"name": "z2_mid", "zoom": 0.5, "xz": Vector2(26.3, 88.8)},
	{"name": "z3", "zoom": 0.75, "xz": Vector2(10.0, 150.0)},
	{"name": "z4_near", "zoom": 1.0, "xz": Vector2(60.0, 150.0)},
]
var root: WorldMap3DRoot

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--seconds="):
			seconds = float(a.substr(10))
		elif a.begins_with("--warmup="):
			warmup = float(a.substr(9))
		elif a.begins_with("--out="):
			out_dir = a.substr(6)
		elif a.begins_with("--config="):
			config_path = a.substr(9)
		elif a.begins_with("--fill="):
			fill = a.substr(7)
		elif a == "--static":
			static_cam = true
		elif a == "--empty":
			empty_scene = true
	if not out_dir.is_absolute_path():
		out_dir = ProjectSettings.globalize_path("res://").path_join(out_dir)
	DirAccess.make_dir_recursive_absolute(out_dir)
	# keep Godot from importing the CSVs as translation files
	if not FileAccess.file_exists(out_dir.path_join(".gdignore")):
		FileAccess.open(out_dir.path_join(".gdignore"), FileAccess.WRITE).close()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	if empty_scene:
		await _run_empty()
		return
	var t0 := Time.get_ticks_usec()
	root = load("res://worldmap3d/scenes/worldmap3d_eastasia.tscn").instantiate()
	if config_path != "":
		root.map_config_path = config_path
	if fill != "":
		root.fill_preset = fill
	add_child(root)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var first_frame_ms := (Time.get_ticks_usec() - t0) / 1000.0
	root.camera.manual = true
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")
	var vp_size := get_viewport().get_visible_rect().size
	var info := PackedStringArray([
		"godot=" + Engine.get_version_info().string,
		"renderer=" + RenderingServer.get_current_rendering_method(),
		"adapter=" + RenderingServer.get_video_adapter_name(),
		"vendor=" + RenderingServer.get_video_adapter_vendor(),
		"api_version=" + RenderingServer.get_video_adapter_api_version(),
		"os=" + OS.get_name() + " " + OS.get_version(),
		"cpu=" + OS.get_processor_name(),
		"viewport=%dx%d" % [vp_size.x, vp_size.y],
		"window=%s" % DisplayServer.window_get_size(),
		"map=" + str(root.stats.get("map_id", "")),
		"build_ms=%.1f" % root.stats.get("build_ms", 0.0),
		"first_frame_ms=%.1f" % first_frame_ms,
		"terrain_tiles=%d (LOD0 tris below; LODs picked per tile by Godot)" % root.stats.get("terrain_tiles", 0),
		"terrain_tris=%d road_tris=%d river_tris=%d" % [root.stats.get("terrain_tris", 0), root.stats.get("road_tris", 0), root.stats.get("river_tris", 0)],
		"seconds_per_level=%.1f warmup=%.1f static=%s" % [seconds, warmup, static_cam],
		"vram_after_build_mb total=%.1f texture=%.1f buffer=%.1f" % [Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
			Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0, Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1048576.0],
	])
	var fi := FileAccess.open(out_dir.path_join("bench_info_%s.txt" % stamp), FileAccess.WRITE)
	fi.store_string("\n".join(info) + "\n")
	fi.close()
	print("[bench] ", " | ".join(info))
	var fs := FileAccess.open(out_dir.path_join("bench_summary_%s.csv" % stamp), FileAccess.WRITE)
	fs.store_line("level,zoom,camera_distance_km,frames,seconds,avg_fps,low1pct_fps,p99_frame_ms,max_frame_ms,avg_frame_ms,vram_total_mb,vram_texture_mb,vram_buffer_mb,draw_calls,primitives,objects")
	var ff := FileAccess.open(out_dir.path_join("bench_frames_%s.csv" % stamp), FileAccess.WRITE)
	ff.store_line("level,frame,frame_ms")
	# EA v2: maps with views_km use their own 7 levels (whole map -> Korea minimum zoom)
	var vk: Dictionary = root.cfg.raw.get("views_km", {})
	var ea := not vk.is_empty()
	if ea:
		var st = root.cfg.cam("start_km", [0, 0])
		levels = [
			{"name": "z0_far_whole_map", "zoom": 0.0, "xz": Vector2(st[0], st[1])},
			{"name": "z1_ncp", "zoom": 0.25, "xz": Vector2(vk.north_china_plain[0], vk.north_china_plain[1])},
			{"name": "z2_mid_korea", "zoom": 0.5, "xz": Vector2(vk.korea[0], vk.korea[1])},
			{"name": "z2_mid_yangtze", "zoom": 0.5, "xz": Vector2(vk.yangtze[0], vk.yangtze[1])},
			{"name": "z3_japan_alps", "zoom": 0.75, "xz": Vector2(vk.japan_alps[0], vk.japan_alps[1])},
			{"name": "z3_himalaya", "zoom": 0.75, "xz": Vector2(vk.himalaya[0], vk.himalaya[1])},
			{"name": "z4_near_korea", "zoom": 1.0, "xz": Vector2(vk.v3_min[0], vk.v3_min[1])},
		]
	for L in levels:
		var xz: Vector2 = L.xz
		if config_path != "" and not ea:
			xz = Vector2.ZERO
		root.camera.set_view(xz, L.zoom, 0.0, true)
		root.update_zoom_params()
		# warmup (shader compile, streaming)
		var tw := Time.get_ticks_usec()
		while (Time.get_ticks_usec() - tw) < warmup * 1e6:
			await get_tree().process_frame
		var times := PackedFloat32Array()
		var t_start := Time.get_ticks_usec()
		var t_prev := t_start
		var dc := 0.0
		var prim := 0.0
		var obj := 0.0
		while (Time.get_ticks_usec() - t_start) < seconds * 1e6:
			if not static_cam:
				var t := (Time.get_ticks_usec() - t_start) / 1e6
				var orbit := Vector2(cos(t * 0.21), sin(t * 0.17)) * (root.camera.current_distance() * 0.06 if ea else lerpf(60.0, 15.0, L.zoom))
				root.camera.set_view(xz + orbit, L.zoom, sin(t * 0.13) * 25.0, true)
			await get_tree().process_frame
			var now := Time.get_ticks_usec()
			var ms := (now - t_prev) / 1000.0
			t_prev = now
			times.append(ms)
			ff.store_line("%s,%d,%.3f" % [L.name, times.size(), ms])
			dc += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
			prim += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
			obj += Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		var n := times.size()
		var total_s := (t_prev - t_start) / 1e6
		var sorted := times.duplicate()
		sorted.sort()
		var k := maxi(1, int(ceil(n * 0.01)))
		var worst := 0.0
		for i in k:
			worst += sorted[n - 1 - i]
		worst /= k
		var p99: float = sorted[clampi(int(floor(n * 0.99)), 0, n - 1)]
		var row := "%s,%.2f,%.1f,%d,%.2f,%.1f,%.1f,%.2f,%.2f,%.2f,%.1f,%.1f,%.1f,%.0f,%.0f,%.0f" % [
			L.name, L.zoom, root.camera.current_distance(), n, total_s, n / total_s, 1000.0 / worst, p99, sorted[n - 1],
			total_s * 1000.0 / n,
			Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
			Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0,
			Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1048576.0,
			dc / n, prim / n, obj / n]
		fs.store_line(row)
		fs.flush()
		print("[bench] ", row)
	fs.close()
	ff.close()
	print("[bench] done -> ", out_dir)
	get_tree().quit()

## v2.2 baseline: empty 3D scene (Camera3D + DirectionalLight3D + procedural sky, same viewport) -> VRAM the engine,
## window swapchain and render targets use without the map. Run it in the same Godot/driver/resolution as the map bench.
func _run_empty() -> void:
	var n3 := Node3D.new()
	var cam := Camera3D.new()
	cam.position = Vector3(0, 10, 10)
	n3.add_child(cam)
	var sun := DirectionalLight3D.new()
	sun.shadow_enabled = true
	n3.add_child(sun)
	var we := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	we.environment = env
	n3.add_child(we)
	add_child(n3)
	cam.current = true
	cam.look_at(Vector3.ZERO)
	var tw := Time.get_ticks_usec()
	while (Time.get_ticks_usec() - tw) < maxf(warmup, 3.0) * 1e6:
		await get_tree().process_frame
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")
	var f := FileAccess.open(out_dir.path_join("bench_empty_%s.csv" % stamp), FileAccess.WRITE)
	f.store_line("scene,godot,renderer,adapter,viewport,vram_total_mb,vram_texture_mb,vram_buffer_mb")
	var vp := get_viewport().get_visible_rect().size
	var row := "empty_3d,%s,%s,%s,%dx%d,%.1f,%.1f,%.1f" % [Engine.get_version_info().string, RenderingServer.get_current_rendering_method(),
		RenderingServer.get_video_adapter_name().replace(",", " "), vp.x, vp.y,
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1048576.0]
	f.store_line(row)
	f.close()
	print("[bench] empty baseline ", row)
	get_tree().quit()
