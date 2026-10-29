extends Node3D
# Unit3D F: load test, 60 cavalry (5 units x 6 a side) with spears, for numbers. Separate from the 3D lab, the
# ScenarioShell and the other unit3d scenes (Unit3D_LoadTest is the 90-infantry one); not used by the engine; not a CI test.
# Keys: 1 idle (horse idle + rider sit_cavalry), 2 run (horse run in place + sit_cavalry), 3 pause (the run pose stays),
# H shadows on/off, C camera size 42 <-> 20, G cavalry 60 <-> 120, Q/E turn the camera.
# Run with `-- --autorun [--out=<csv path>]`: 12 + 1 conditions x 2 passes (3 s warm-up, 10 s measured each), CSV, quit.

const HORSE := "res://assets/battle3d/horse/warhorse.glb"
const RIDER_LIBRARY := "res://assets/battle3d/base_soldier/anim_cavalry_rider.glb" # AnimationLibrary
const SOLDIER := {"blue": "res://assets/battle3d/base_soldier/soldier_anims_korea_blue.glb", "red": "res://assets/battle3d/base_soldier/soldier_anims_korea_red_test.glb"}
const SPEAR := {"blue": "res://assets/battle3d/weapons/weapon_spear_blue.glb", "red": "res://assets/battle3d/weapons/weapon_spear_red.glb"}
const RIDER_OFFSET := Vector3(0, -0.358, 0) # soldier root under Saddle
const SPEAR_Q := Quaternion(0.3114, 0.9195, 0.1201, 0.2078) # cavalry spear on WeaponSocket_R (fixed)
const SPEAR_GRIP := Vector3(0, -0.20, 0)
const UNITS_PER_SIDE := 5
const UNIT_SPACING := 3.0 # one cell, along z
const ROWS_Z := [-0.9, 0.0, 0.9] # a unit: 3 rows along z x 2 along x (as the cavalry test scene)
const COLS_X := [-0.65, 0.65]
const SIDE_X := {"blue": -6.0, "red": 6.0}
const SIDE_FACING := {"blue": PI * .5, "red": -PI * .5} # horse and rider look along +Z
const EXTRA_X := {"blue": -3.0, "red": 3.0} # G: the second 60 stand one rank further out
const CAMERA_YAW := .32 # the lab camera: orthographic, offset (sin(yaw)*43, 40, cos(yaw)*43)
const SIZES := [42.0, 20.0]
const WARMUP := 3.0
const MEASURE := 10.0

var camera := Camera3D.new()
var sun := DirectionalLight3D.new()
var yaw := CAMERA_YAW
var zoom := 42.0
var focus := Vector3.ZERO
var library: AnimationLibrary
var materials: Dictionary = {} # GLB material -> its shared matte copy (horse 1, soldier 2, spear 2)
var cavalry: Array = [] # {horse, horse_player, rider_player, extra}
var anim := "idle"
var count := 60
var status: Label
var hud_time := 0.0
# autorun
var autorun := false
var out_path := ""
var plan: Array = []
var step := -1
var phase := ""
var phase_left := 0.0
var samples: Array = []
var rows: Array = []
var last_usec := 0

func _ready() -> void:
	randomize()
	for arg in OS.get_cmdline_user_args():
		if arg == "--autorun": autorun = true
		elif arg.begins_with("--out="): out_path = arg.substr(6)
	library = load(RIDER_LIBRARY)
	_build_world()
	_spawn_side_units(false)
	_build_ui()
	_play_all("idle")
	if autorun: _start_autorun()

func _build_world() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("8d897a")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("c7d8e4")
	env.environment.ambient_light_energy = .35
	env.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(env)
	# the lab sun (lab_presentation.gd)
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_energy = .8
	sun.shadow_enabled = true
	sun.shadow_bias = .08
	sun.shadow_normal_bias = 1.2
	sun.directional_shadow_max_distance = 100
	add_child(sun)
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 60)
	ground.mesh = plane
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("6f7d55")
	m.roughness = .85
	ground.material_override = m
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ground)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 200
	add_child(camera)
	_update_camera()

func _matte(n: Node) -> void:
	if n is MeshInstance3D:
		for i in n.mesh.get_surface_count():
			var original: Material = n.mesh.surface_get_material(i)
			if not materials.has(original):
				var copy := original.duplicate() as StandardMaterial3D
				copy.roughness = 1.0
				copy.metallic = 0.0
				copy.metallic_specular = 0.0
				materials[original] = copy
			n.set_surface_override_material(i, materials[original])
	for c in n.get_children(): _matte(c)

func _spawn_side_units(extra: bool) -> void:
	for side in ["blue", "red"]:
		for u in UNITS_PER_SIDE:
			var centre := Vector3(SIDE_X[side] + (EXTRA_X[side] if extra else 0.0), 0, (u - (UNITS_PER_SIDE - 1) * .5) * UNIT_SPACING)
			for z in ROWS_Z:
				for x in COLS_X:
					_spawn(side, centre + Vector3(x, 0, z), extra)

func _spawn(side: String, at: Vector3, extra: bool) -> void:
	var horse: Node3D = (load(HORSE) as PackedScene).instantiate()
	horse.position = at
	horse.rotation.y = SIDE_FACING[side]
	add_child(horse)
	var horse_player: AnimationPlayer = horse.get_node("AnimationPlayer") # the horse's own (find_child would reach the rider's)
	var saddle: Node3D = horse.find_child("Saddle", true, false)
	var rider: Node3D = (load(SOLDIER[side]) as PackedScene).instantiate()
	saddle.add_child(rider)
	rider.position = RIDER_OFFSET
	var spear: Node3D = (load(SPEAR[side]) as PackedScene).instantiate()
	(rider.find_child("WeaponSocket_R", true, false) as Node3D).add_child(spear)
	spear.transform = Transform3D(Basis(SPEAR_Q), SPEAR_Q * SPEAR_GRIP)
	_matte(horse)
	var rider_player: AnimationPlayer = rider.find_child("AnimationPlayer", true, false)
	var own := rider_player.get_animation_library(&"")
	for a in library.get_animation_list():
		if not own.has_animation(a): own.add_animation(a, library.get_animation(a))
	cavalry.append({"horse": horse, "horse_player": horse_player, "rider_player": rider_player, "extra": extra})

func _set_count(n: int) -> void:
	if n == count: return
	if n == 120:
		_spawn_side_units(true)
	else:
		for c in cavalry.filter(func(x): return x.extra): (c.horse as Node).queue_free()
		cavalry = cavalry.filter(func(x): return not x.extra)
	count = n
	_play_all(anim)

func _loop(player: AnimationPlayer, a: String) -> void:
	player.play(a)
	player.seek(randf() * player.current_animation_length, true)
	player.speed_scale = randf_range(.92, 1.08)

func _play_all(a: String) -> void:
	anim = a
	for c in cavalry:
		_loop(c.horse_player, "idle" if a == "idle" else "run")
		_loop(c.rider_player, "sit_cavalry")
		if a == "pause":
			c.horse_player.pause()
			c.rider_player.pause()

func _update_camera() -> void:
	camera.size = zoom
	camera.position = focus + Vector3(sin(yaw) * 43, 40, cos(yaw) * 43)
	camera.look_at(focus)

## How many cavalrymen have the horse's feet and the rider's head height (+1.4) inside the viewport.
func on_screen() -> int:
	var rect := get_viewport().get_visible_rect()
	var n := 0
	for c in cavalry:
		var p: Vector3 = (c.horse as Node3D).global_position
		if rect.has_point(camera.unproject_position(p)) and rect.has_point(camera.unproject_position(p + Vector3(0, 1.4, 0))): n += 1
	return n

func _unhandled_input(event: InputEvent) -> void:
	if autorun or not (event is InputEventKey and event.pressed and not event.echo): return
	match event.physical_keycode:
		KEY_1: _play_all("idle")
		KEY_2: _play_all("run")
		KEY_3: _play_all("pause")
		KEY_H: sun.shadow_enabled = not sun.shadow_enabled
		KEY_C:
			zoom = 20.0 if zoom == 42.0 else 42.0
			_update_camera()
		KEY_G: _set_count(120 if count == 60 else 60)

func _process(delta: float) -> void:
	if autorun:
		_autorun_frame()
		return
	var turn := float(Input.is_physical_key_pressed(KEY_Q)) - float(Input.is_physical_key_pressed(KEY_E))
	if turn != 0.0:
		yaw += delta * turn
		_update_camera()
	hud_time -= delta
	if hud_time <= 0.0:
		hud_time = .25
		_update_status()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	status = Label.new()
	status.position = Vector2(22, 20)
	status.add_theme_font_size_override("font_size", 22)
	status.add_theme_color_override("font_shadow_color", Color(0, 0, 0, .8))
	layer.add_child(status)
	status.visible = not autorun # the autorun measures without the HUD

func condition_text() -> String:
	return "cavalry %d  shadows %s  animation %s  camera size %d" % [count, "ON" if sun.shadow_enabled else "OFF", anim, int(zoom)]

func _update_status() -> void:
	var fps := Performance.get_monitor(Performance.TIME_FPS)
	var draws := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	status.text = "UNIT3D F  /  CAVALRY LOAD TEST\n%s\nFPS %d   frame %.2f ms   draw calls %d   on screen %d/%d\n1 idle  2 run  3 pause   H shadows  C camera 42/20  G 60/120   Q/E turn" % [condition_text(), fps, 1000.0 / maxf(fps, 1.0), draws, on_screen(), cavalry.size()]

# ---- autorun ----

func _start_autorun() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	for rep in [1, 2]:
		for sh in [true, false]:
			for a in ["idle", "run", "pause"]:
				for size in SIZES:
					plan.append({"pass": rep, "cavalry": 60, "shadows": sh, "anim": a, "size": size})
		plan.append({"pass": rep, "cavalry": 120, "shadows": true, "anim": "run", "size": 20.0})
	print("AUTORUN ", JSON.stringify(environment_info()))
	_next_condition()

func environment_info() -> Dictionary:
	var v := Engine.get_version_info()
	return {"godot": "%s (%s)" % [v.string, v.hash.substr(0, 9)], "rendering_method": RenderingServer.get_current_rendering_method(),
		"rendering_driver": RenderingServer.get_current_rendering_driver_name(), "adapter": RenderingServer.get_video_adapter_name(),
		"adapter_api": RenderingServer.get_video_adapter_api_version(), "driver_info": OS.get_video_adapter_driver_info(),
		"cpu": OS.get_processor_name(), "cpu_threads": OS.get_processor_count(), "screen": DisplayServer.screen_get_size(),
		"window": DisplayServer.window_get_size(), "viewport": get_viewport().get_visible_rect().size,
		"vsync": DisplayServer.window_get_vsync_mode(), "max_fps": Engine.max_fps,
		"msaa_3d": ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d"),
		"screen_space_aa": ProjectSettings.get_setting("rendering/anti_aliasing/quality/screen_space_aa"),
		"taa": ProjectSettings.get_setting("rendering/anti_aliasing/quality/use_taa"),
		"scaling_3d_mode": ProjectSettings.get_setting("rendering/scaling_3d/mode"), "scaling_3d_scale": ProjectSettings.get_setting("rendering/scaling_3d/scale"),
		"directional_shadow_size": ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/size"),
		"directional_soft_shadow_quality": ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality"),
		"sun_shadow_mode": sun.directional_shadow_mode, "sun_max_distance": sun.directional_shadow_max_distance, "materials": materials.size()}

func _next_condition() -> void:
	step += 1
	if step >= plan.size():
		_write_csv()
		get_tree().quit(0)
		return
	var c: Dictionary = plan[step]
	_set_count(c.cavalry)
	sun.shadow_enabled = c.shadows
	zoom = c.size
	_update_camera()
	_play_all(c.anim)
	phase = "warmup"
	phase_left = WARMUP
	samples.clear()

func _autorun_frame() -> void:
	var now := Time.get_ticks_usec()
	var frame_ms := (now - last_usec) / 1000.0 if last_usec > 0 else 0.0
	last_usec = now
	if step < 0 or step >= plan.size(): return
	if phase == "warmup":
		phase_left -= frame_ms / 1000.0
		if phase_left <= 0.0:
			phase = "measure"
			phase_left = MEASURE
		return
	samples.append([frame_ms, RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0])
	phase_left -= frame_ms / 1000.0
	if phase_left <= 0.0:
		rows.append(_summarise(plan[step]))
		print("ROW ", JSON.stringify(rows[-1]))
		_next_condition()

func _summarise(c: Dictionary) -> Dictionary:
	var times: Array = samples.map(func(x): return x[0])
	var sorted := times.duplicate()
	sorted.sort()
	var n := sorted.size()
	var total := 0.0
	for t in times: total += t
	var avg := func(i: int) -> float:
		var sum := 0.0
		for x in samples: sum += x[i]
		return sum / n
	return {"pass": c.pass, "cavalry": c.cavalry, "shadows": "on" if c.shadows else "off", "anim": c.anim, "camera_size": int(c.size),
		"frames": n, "avg_fps": snappedf(n / (total / 1000.0), .1), "avg_frame_ms": snappedf(total / n, .001),
		"p95_ms": snappedf(sorted[int(ceil(.95 * n)) - 1], .001), "p99_ms": snappedf(sorted[int(ceil(.99 * n)) - 1], .001),
		"worst_ms": snappedf(sorted[-1], .001), "min_fps": snappedf(1000.0 / sorted[-1], .1),
		"draw_calls": snappedf(avg.call(1), .1), "objects": snappedf(avg.call(2), .1), "primitives": snappedf(avg.call(3), 1),
		"process_ms": snappedf(avg.call(4), .001), "static_mem_mb": snappedf(Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0, .1),
		"video_mem_mb": snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, .1), "on_screen": on_screen(), "total": cavalry.size()}

func _write_csv() -> void:
	if out_path.is_empty(): return
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	var keys: Array = rows[0].keys()
	f.store_line(",".join(keys))
	for r in rows: f.store_line(",".join(keys.map(func(k): return str(r[k]))))
	f.close()
	print("CSV ", out_path)
