extends Node3D
# Unit3D F: cavalry (warhorse + spear rider) test scene, for a look with F6.
# Separate from the 3D lab and the A2-E scenes; nothing here is used by the engine. Not a CI test.
# One cavalryman: the soldier sits under the horse's Saddle at (0, -0.358, 0), no rotation; the spear is on the
# rider's WeaponSocket_R with one fixed value (handoff README). Two units: blue 6 (x -6, facing +X), red 6 (x +6, -X).
# Keys: 1 idle, 2 walk, 3 run (the units move; back to the start after 8 m), T thrust (all), R reset,
# H slow motion (x0.25), U cav_thrust <-> cav_thrust_upright, C camera size 14 -> 20 -> 42, wheel zoom, Q/E turn.

const HORSE := "res://assets/battle3d/horse/warhorse.glb"
const RIDER_LIBRARY := "res://assets/battle3d/base_soldier/anim_cavalry_rider.glb" # AnimationLibrary
const SOLDIER := {"blue": "res://assets/battle3d/base_soldier/soldier_anims_korea_blue.glb", "red": "res://assets/battle3d/base_soldier/soldier_anims_korea_red_test.glb"}
const SPEAR := {"blue": "res://assets/battle3d/weapons/weapon_spear_blue.glb", "red": "res://assets/battle3d/weapons/weapon_spear_red.glb"}
const RIDER_OFFSET := Vector3(0, -0.358, 0) # soldier root under Saddle
const SPEAR_Q := Quaternion(0.3114, 0.9195, 0.1201, 0.2078) # cavalry spear on WeaponSocket_R, held at spear +Y 0.20
const SPEAR_GRIP := Vector3(0, -0.20, 0)
const THRUST_SPEED := 2.17 # cav_thrust 1.0 s -> 0.46 s
const STAGGER_MIN := 0.05
const STAGGER_MAX := 0.12
const MOVE_SPEED := {"walk": 0.30, "run": 2.0} # m/s, from the hooves (horse speed_scale 1.0)
const MOVE_LIMIT := 8.0
const ROWS_Z := [-0.9, 0.0, 0.9] # 3 rows along z
const COLS_X := [-0.65, 0.65] # 2 columns along x (1.3 apart)
const SIDE_X := {"blue": -6.0, "red": 6.0}
const SIDE_FACING := {"blue": PI * .5, "red": -PI * .5} # horse and rider look along +Z
const CAMERA_YAW := .32 # the lab camera: orthographic, offset (sin(yaw)*43, 40, cos(yaw)*43)
const CAMERA_SIZES := [14.0, 20.0, 42.0]

var camera := Camera3D.new()
var yaw := CAMERA_YAW
var zoom := 14.0
var focus := Vector3(0, .5, 0)
var materials: Dictionary = {} # GLB material -> its shared matte copy
var units: Dictionary = {} # side -> Node3D holding 6 cavalrymen
var cavalry: Array = [] # {side, index, horse, saddle, rider, horse_player, rider_player, spear}
var motion := "idle"
var thrust := "cav_thrust"
var travelled := 0.0
var slow := false
var status: Label
var hud_time := 0.0

func _ready() -> void:
	randomize()
	_build_world()
	var library: AnimationLibrary = load(RIDER_LIBRARY)
	for side in ["blue", "red"]:
		var unit := Node3D.new()
		unit.name = side.capitalize() + "Unit"
		unit.position = Vector3(SIDE_X[side], 0, 0)
		add_child(unit)
		units[side] = unit
		var i := 0
		for z in ROWS_Z:
			for x in COLS_X:
				cavalry.append(_spawn(side, i, unit, Vector3(x, 0, z), library))
				i += 1
	_build_ui()
	reset()

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
	var sun := DirectionalLight3D.new()
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

func _spawn(side: String, index: int, unit: Node3D, at: Vector3, library: AnimationLibrary) -> Dictionary:
	var horse: Node3D = (load(HORSE) as PackedScene).instantiate()
	horse.name = "%s_Cavalry_%d" % [side.capitalize(), index]
	horse.position = at
	horse.rotation.y = SIDE_FACING[side]
	unit.add_child(horse)
	var horse_player: AnimationPlayer = horse.get_node("AnimationPlayer") # the horse's own (find_child would reach the rider's)
	var saddle: Node3D = horse.find_child("Saddle", true, false)
	var rider: Node3D = (load(SOLDIER[side]) as PackedScene).instantiate()
	rider.name = "Rider"
	saddle.add_child(rider)
	rider.position = RIDER_OFFSET
	var socket: Node3D = rider.find_child("WeaponSocket_R", true, false)
	var spear: Node3D = (load(SPEAR[side]) as PackedScene).instantiate()
	socket.add_child(spear)
	spear.transform = Transform3D(Basis(SPEAR_Q), SPEAR_Q * SPEAR_GRIP)
	_matte(horse) # the horse, the rider and the spear
	var rider_player: AnimationPlayer = rider.find_child("AnimationPlayer", true, false)
	var own := rider_player.get_animation_library(&"")
	for a in library.get_animation_list():
		if not own.has_animation(a): own.add_animation(a, library.get_animation(a))
	rider_player.animation_finished.connect(_on_rider_finished.bind(rider_player))
	return {"side": side, "index": index, "horse": horse, "saddle": saddle, "rider": rider, "horse_player": horse_player,
		"rider_player": rider_player, "spear": spear}

func _loop(player: AnimationPlayer, anim: String, random_speed: bool) -> void:
	player.play(anim)
	player.seek(randf() * player.current_animation_length, true)
	player.speed_scale = randf_range(.92, 1.08) if random_speed else 1.0

func set_motion(m: String) -> void:
	motion = m
	for c in cavalry:
		_loop(c.horse_player, m, m == "idle") # walk / run keep speed_scale 1.0 so the hooves match the travel speed
		if not String(c.rider_player.current_animation).begins_with("cav_thrust"): _loop(c.rider_player, "sit_cavalry", true)
	if m == "idle": _place_units(0.0)
	_update_status()

func thrust_all() -> void:
	for c in cavalry:
		var t := create_tween()
		t.tween_interval(float(c.index) * randf_range(STAGGER_MIN, STAGGER_MAX))
		t.tween_callback(_thrust.bind(c.rider_player))

func _thrust(player: AnimationPlayer) -> void:
	player.play(thrust)
	player.seek(0.0, true)
	player.speed_scale = THRUST_SPEED

func _on_rider_finished(anim: StringName, player: AnimationPlayer) -> void:
	if String(anim).begins_with("cav_thrust"): _loop(player, "sit_cavalry", true)

func reset() -> void:
	for t in get_tree().get_processed_tweens(): t.kill()
	_set_slow(false)
	for c in cavalry: _loop(c.rider_player, "sit_cavalry", true)
	set_motion("idle")

func _set_slow(on: bool) -> void:
	slow = on
	Engine.time_scale = .25 if on else 1.0

func _place_units(distance: float) -> void:
	travelled = distance
	for side in units:
		var unit: Node3D = units[side]
		unit.position = Vector3(SIDE_X[side] + (distance if side == "blue" else -distance), 0, 0) # forward: blue +X, red -X

func _update_camera() -> void:
	camera.size = zoom
	camera.position = focus + Vector3(sin(yaw) * 43, 40, cos(yaw) * 43)
	camera.look_at(focus)

func _process(delta: float) -> void:
	if MOVE_SPEED.has(motion):
		var d: float = travelled + MOVE_SPEED[motion] * delta
		_place_units(d if d <= MOVE_LIMIT else 0.0)
	var turn := float(Input.is_physical_key_pressed(KEY_Q)) - float(Input.is_physical_key_pressed(KEY_E))
	if turn != 0.0:
		yaw += delta * turn / Engine.time_scale
		_update_camera()
	hud_time -= delta / Engine.time_scale
	if hud_time <= 0.0:
		hud_time = .25
		_update_status()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1: set_motion("idle")
			KEY_2: set_motion("walk")
			KEY_3: set_motion("run")
			KEY_T: thrust_all()
			KEY_R: reset()
			KEY_H: _set_slow(not slow)
			KEY_U: thrust = "cav_thrust_upright" if thrust == "cav_thrust" else "cav_thrust"
			KEY_C:
				zoom = CAMERA_SIZES[(CAMERA_SIZES.find(zoom) + 1) % CAMERA_SIZES.size()] if zoom in CAMERA_SIZES else CAMERA_SIZES[0]
				_update_camera()
			_: return
		_update_status()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: zoom = maxf(4.0, zoom / 1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoom = minf(42.0, zoom * 1.15)
		else: return
		_update_camera()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	status = Label.new()
	status.position = Vector2(22, 20)
	status.add_theme_font_size_override("font_size", 22)
	status.add_theme_color_override("font_shadow_color", Color(0, 0, 0, .8))
	layer.add_child(status)

func _update_status() -> void:
	if status == null: return
	status.text = "UNIT3D F  /  CAVALRY   (blue 6, red 6; warhorse + spear rider, matte)\n1 idle   2 walk   3 run   T thrust   U %s   R reset   H slow %s   C camera size %d   wheel zoom   Q/E turn\nhorse: %s   moved %.1f m   FPS %d" % [thrust, "ON (x0.25)" if slow else "OFF", int(round(zoom)), motion, travelled, Performance.get_monitor(Performance.TIME_FPS)]
