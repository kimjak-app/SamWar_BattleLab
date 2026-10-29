extends Node3D
# Unit3D C: load test, 90 infantry (5 units x 9 a side) with spears, for numbers. Separate from the 3D lab, the
# ScenarioShell and the A2/B scenes; nothing here is used by the engine. Not a CI test.
# Keys: 1 idle, 2 run, 3 pause (the pose stays), W spears on/off (the spear nodes are taken out of the tree, not hidden),
# H shadows on/off (the sun's shadow_enabled), C camera size 42 <-> 20, G soldiers 90 <-> 180, Q/E turn the camera.
# Run with `-- --autorun [--out=<csv path>]`: 25 conditions x 2 passes (3 s warm-up, 10 s measured each), CSV written, quit.

const SOLDIER := {"blue": "res://assets/battle3d/base_soldier/soldier_anims_korea_blue.glb", "red": "res://assets/battle3d/base_soldier/soldier_anims_korea_red_test.glb"}
const SPEAR := {"blue": "res://assets/battle3d/weapons/weapon_spear_blue.glb", "red": "res://assets/battle3d/weapons/weapon_spear_red.glb"}
const SPEAR_Q := Quaternion(0.3704, 0.9157, -0.0862, 0.1294) # weapons README v3, under WeaponSocket_R (one hand, fixed)
const UNITS_PER_SIDE := 5
const UNIT_SPACING := 3.0 # one cell, along z
const SOLDIER_SPACING := 0.65 # 3 x 3 per unit
const SIDE_X := {"blue": -4.0, "red": 4.0}
const SIDE_FACING := {"blue": PI * .5, "red": -PI * .5} # the model looks along +Z: blue turns to +X, red to -X
const EXTRA_X := {"blue": -2.5, "red": 2.5} # G: the second 90 stand one rank further out
# The lab camera (lab_presentation.gd _update_camera): orthographic, offset (sin(yaw)*43, 40, cos(yaw)*43), yaw 0.32.
const CAMERA_YAW := .32
const SIZES := [42.0, 20.0]
const WARMUP := 3.0
const MEASURE := 10.0

var camera := Camera3D.new()
var sun := DirectionalLight3D.new()
var yaw := CAMERA_YAW
var zoom := 42.0
var focus := Vector3.ZERO
var materials: Dictionary = {} # "body_blue", "body_red", "spear_blue", "spear_red" -> one shared matte StandardMaterial3D
var soldiers: Array = [] # {root, player, socket, spear, extra}
var weapons_on := true
var anim := "idle"
var count := 90
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

## One shared matte copy per kind (roughness 1, metallic 0, specular 0, the GLB texture), made from the first instance.
func _shared(key: String, mesh: MeshInstance3D) -> StandardMaterial3D:
	if not materials.has(key):
		var copy := mesh.mesh.surface_get_material(0).duplicate() as StandardMaterial3D
		copy.roughness = 1.0
		copy.metallic = 0.0
		copy.metallic_specular = 0.0
		materials[key] = copy
	return materials[key]

func _spawn_side_units(extra: bool) -> void:
	for side in ["blue", "red"]:
		for u in UNITS_PER_SIDE:
			var centre := Vector3(SIDE_X[side] + (EXTRA_X[side] if extra else 0.0), 0, (u - (UNITS_PER_SIDE - 1) * .5) * UNIT_SPACING)
			for row in 3:
				for col in 3:
					_spawn(side, centre + Vector3((col - 1) * SOLDIER_SPACING, 0, (row - 1) * SOLDIER_SPACING), extra)

func _spawn(side: String, at: Vector3, extra: bool) -> void:
	var root: Node3D = (load(SOLDIER[side]) as PackedScene).instantiate()
	root.position = at
	root.rotation.y = SIDE_FACING[side]
	add_child(root)
	var body: MeshInstance3D = root.find_child("BaseSoldier", true, false)
	body.set_surface_override_material(0, _shared("body_" + side, body))
	var socket: Node3D = root.find_child("WeaponSocket_R", true, false)
	var spear: Node3D = (load(SPEAR[side]) as PackedScene).instantiate()
	socket.add_child(spear)
	spear.quaternion = SPEAR_Q
	var shaft: MeshInstance3D = spear.find_child("Weapon_spear", true, false)
	shaft.set_surface_override_material(0, _shared("spear_" + side, shaft))
	if not weapons_on: socket.remove_child(spear)
	var player: AnimationPlayer = root.find_child("AnimationPlayer", true, false)
	soldiers.append({"root": root, "player": player, "socket": socket, "spear": spear, "extra": extra})

func _set_count(n: int) -> void:
	if n == count: return
	if n == 180:
		_spawn_side_units(true)
	else:
		for s in soldiers.filter(func(x): return x.extra):
			if not (s.spear as Node).is_inside_tree(): (s.spear as Node).free() # taken out by W, so not freed with the soldier
			(s.root as Node).queue_free()
		soldiers = soldiers.filter(func(x): return not x.extra)
	count = n
	_play_all(anim)

func _set_weapons(on: bool) -> void:
	weapons_on = on
	for s in soldiers:
		var spear: Node3D = s.spear
		if on and not spear.is_inside_tree():
			s.socket.add_child(spear)
		elif not on and spear.is_inside_tree():
			s.socket.remove_child(spear)

func _play_all(a: String) -> void:
	anim = a
	for s in soldiers:
		var player: AnimationPlayer = s.player
		player.play("run" if a == "pause" else a)
		player.seek(randf() * player.current_animation_length, true)
		player.speed_scale = randf_range(.92, 1.08)
		if a == "pause": player.pause()

func _update_camera() -> void:
	camera.size = zoom
	camera.position = focus + Vector3(sin(yaw) * 43, 40, cos(yaw) * 43)
	camera.look_at(focus)

## How many soldiers have both their feet and their head inside the viewport.
func on_screen() -> int:
	var rect := get_viewport().get_visible_rect()
	var n := 0
	for s in soldiers:
		var p: Vector3 = (s.root as Node3D).global_position
		if rect.has_point(camera.unproject_position(p)) and rect.has_point(camera.unproject_position(p + Vector3(0, 1, 0))): n += 1
	return n

func _unhandled_input(event: InputEvent) -> void:
	if autorun or not (event is InputEventKey and event.pressed and not event.echo): return
	match event.physical_keycode:
		KEY_1: _play_all("idle")
		KEY_2: _play_all("run")
		KEY_3: _play_all("pause")
		KEY_W: _set_weapons(not weapons_on)
		KEY_H: sun.shadow_enabled = not sun.shadow_enabled
		KEY_C:
			zoom = 20.0 if zoom == 42.0 else 42.0
			_update_camera()
		KEY_G: _set_count(180 if count == 90 else 90)

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
	return "soldiers %d  spears %s  shadows %s  animation %s  camera size %d" % [count, "ON" if weapons_on else "OFF", "ON" if sun.shadow_enabled else "OFF", anim, int(zoom)]

func _update_status() -> void:
	var fps := Performance.get_monitor(Performance.TIME_FPS)
	var draws := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	status.text = "UNIT3D C  /  LOAD TEST\n%s\nFPS %d   frame %.2f ms   draw calls %d   on screen %d/%d\n1 idle  2 run  3 pause   W spears  H shadows  C camera 42/20  G 90/180   Q/E turn" % [condition_text(), fps, 1000.0 / maxf(fps, 1.0), draws, on_screen(), soldiers.size()]

# ---- autorun ----

func _start_autorun() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	for rep in [1, 2]:
		for w in [true, false]:
			for sh in [true, false]:
				for a in ["idle", "run", "pause"]:
					for size in SIZES:
						plan.append({"pass": rep, "soldiers": 90, "weapons": w, "shadows": sh, "anim": a, "size": size})
		plan.append({"pass": rep, "soldiers": 180, "weapons": true, "shadows": true, "anim": "run", "size": 20.0})
	print("AUTORUN ", JSON.stringify(environment_info()))
	_next_condition()

func environment_info() -> Dictionary:
	var v := Engine.get_version_info()
	return {"godot": "%s (%s)" % [v.string, v.hash.substr(0, 9)], "rendering_method": RenderingServer.get_current_rendering_method(),
		"rendering_driver": RenderingServer.get_current_rendering_driver_name(), "adapter": RenderingServer.get_video_adapter_name(),
		"adapter_vendor": RenderingServer.get_video_adapter_vendor(), "adapter_api": RenderingServer.get_video_adapter_api_version(),
		"driver_info": OS.get_video_adapter_driver_info(), "cpu": OS.get_processor_name(), "cpu_threads": OS.get_processor_count(),
		"screen": DisplayServer.screen_get_size(), "window": DisplayServer.window_get_size(), "viewport": get_viewport().get_visible_rect().size,
		"vsync": DisplayServer.window_get_vsync_mode(), "max_fps": Engine.max_fps,
		"msaa_3d": ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d"),
		"screen_space_aa": ProjectSettings.get_setting("rendering/anti_aliasing/quality/screen_space_aa"),
		"taa": ProjectSettings.get_setting("rendering/anti_aliasing/quality/use_taa"),
		"scaling_3d_mode": ProjectSettings.get_setting("rendering/scaling_3d/mode"), "scaling_3d_scale": ProjectSettings.get_setting("rendering/scaling_3d/scale"),
		"directional_shadow_size": ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/size"),
		"directional_soft_shadow_quality": ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality"),
		"sun_shadow_mode": sun.directional_shadow_mode, "sun_max_distance": sun.directional_shadow_max_distance}

func _next_condition() -> void:
	step += 1
	if step >= plan.size():
		_write_csv()
		get_tree().quit(0)
		return
	var c: Dictionary = plan[step]
	_set_count(c.soldiers)
	_set_weapons(c.weapons)
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
	var mean := total / n
	var avg := func(i: int) -> float:
		var sum := 0.0
		for x in samples: sum += x[i]
		return sum / n
	return {"pass": c.pass, "soldiers": c.soldiers, "weapons": "on" if c.weapons else "off", "shadows": "on" if c.shadows else "off",
		"anim": c.anim, "camera_size": int(c.size), "frames": n, "avg_fps": snappedf(n / (total / 1000.0), .1),
		"avg_frame_ms": snappedf(mean, .001), "p95_ms": snappedf(sorted[int(ceil(.95 * n)) - 1], .001), "p99_ms": snappedf(sorted[int(ceil(.99 * n)) - 1], .001),
		"worst_ms": snappedf(sorted[-1], .001), "min_fps": snappedf(1000.0 / sorted[-1], .1),
		"draw_calls": snappedf(avg.call(1), .1), "objects": snappedf(avg.call(2), .1), "primitives": snappedf(avg.call(3), 1),
		"process_ms": snappedf(avg.call(4), .001), "static_mem_mb": snappedf(Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0, .1),
		"video_mem_mb": snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, .1), "on_screen": on_screen(), "total": soldiers.size()}

func _write_csv() -> void:
	if out_path.is_empty(): return
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	var keys: Array = rows[0].keys()
	f.store_line(",".join(keys))
	for r in rows: f.store_line(",".join(keys.map(func(k): return str(r[k]))))
	f.close()
	print("CSV ", out_path)
