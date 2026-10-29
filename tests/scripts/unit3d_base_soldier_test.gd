extends Node3D
# Unit3D A2: the common base soldier (blue + red test texture) with its 7 Mixamo animations, for a look with F6.
# Separate from the 3D lab and the ScenarioShell; nothing here is used by the engine. Not a CI test.
# Keys: 1 idle, 2 walk, 3 run, 4 attack_spear, 5 attack_bow, 6 attack_gun (attacks return to idle),
# 7 matte override on/off (roughness 1.0, specular 0, metallic 0 on a copy; the GLB material is untouched),
# Q/E turn the camera, the mouse wheel zooms.

const SOLDIERS := [
	["Blue", "res://assets/battle3d/base_soldier/soldier_anims_korea_blue.glb", Vector3(-1.2, 0, 0), PI * .5],
	["Red", "res://assets/battle3d/base_soldier/soldier_anims_korea_red_test.glb", Vector3(1.2, 0, 0), -PI * .5],
]
const KEYS := {KEY_1: "idle", KEY_2: "walk", KEY_3: "run", KEY_4: "attack_spear", KEY_5: "attack_bow", KEY_6: "attack_gun"}
const LOOPING := ["idle", "idle_alt", "walk", "run"]
# The lab camera (lab_presentation.gd _update_camera): orthographic, offset (sin(yaw)*43, 40, cos(yaw)*43), yaw 0.32.
const CAMERA_YAW := .32
const ZOOM_MIN := 1.5
const ZOOM_MAX := 42.0
const STICK_LENGTH := 1.3 # the temporary spear stand-in (not an asset)
const STICK_THICKNESS := .02

var camera := Camera3D.new()
var yaw := CAMERA_YAW
var zoom := 4.0
var focus := Vector3(0, .5, 0)
var soldiers: Array = [] # [{name, root, player, mesh, original, matte}]
var current := "idle"
var matte := false
var status: Label

func _ready() -> void:
	randomize()
	_build_world()
	for s in SOLDIERS: _spawn(s[0], s[1], s[2], s[3])
	_build_ui()
	_play_all("idle")

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
	add_child(sun)
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(12, 12)
	ground.mesh = plane
	ground.material_override = _flat(Color("6f7d55"))
	add_child(ground)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 200
	add_child(camera)
	_update_camera()

func _flat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = .85
	return m

func _box(size: Vector3, color: Color) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.material_override = _flat(color)
	return n

func _spawn(label: String, path: String, at: Vector3, facing: float) -> void:
	var root: Node3D = (load(path) as PackedScene).instantiate()
	root.name = label
	root.position = at
	root.rotation.y = facing # the model looks along its +Z; facing turns +Z toward the other soldier
	add_child(root)
	# the front arrow, in the model's own frame: +Z is where the model looks
	var arrow := Node3D.new()
	arrow.name = "FrontArrow"
	root.add_child(arrow)
	var shaft := _box(Vector3(.04, .01, .4), Color("ffd575"))
	shaft.position = Vector3(0, .01, .35)
	arrow.add_child(shaft)
	var tip := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(.16, .16, .01)
	tip.mesh = prism
	tip.material_override = _flat(Color("ffd575"))
	tip.rotation_degrees = Vector3(90, 0, 0)
	tip.position = Vector3(0, .01, .63)
	arrow.add_child(tip)
	for side in ["L", "R"]:
		var socket: Node3D = root.find_child("WeaponSocket_" + side, true, false)
		var marker := _box(Vector3(.04, .04, .04), Color("e04848") if side == "R" else Color("4878e0"))
		marker.name = "SocketMarker"
		socket.add_child(marker)
		if side == "R":
			var stick := MeshInstance3D.new()
			stick.name = "TempStick"
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = STICK_THICKNESS * .5
			cylinder.bottom_radius = STICK_THICKNESS * .5
			cylinder.height = STICK_LENGTH
			stick.mesh = cylinder
			stick.material_override = _flat(Color("7a5a36"))
			socket.add_child(stick) # along the socket's local Y, centred on the hand
	var player: AnimationPlayer = root.find_child("AnimationPlayer", true, false)
	player.animation_finished.connect(_on_finished.bind(player))
	var mesh: MeshInstance3D = root.find_child("BaseSoldier", true, false)
	var original: Material = mesh.mesh.surface_get_material(0)
	var copy := original.duplicate() as StandardMaterial3D
	copy.roughness = 1.0
	copy.metallic_specular = 0.0
	copy.metallic = 0.0
	soldiers.append({"name": label, "root": root, "player": player, "mesh": mesh, "original": original, "matte": copy})

func _play_all(anim: String) -> void:
	current = anim
	for s in soldiers:
		var player: AnimationPlayer = s.player
		player.play(anim)
		if anim in LOOPING:
			player.seek(randf() * player.current_animation_length, true)
			player.speed_scale = randf_range(.92, 1.08)
		else:
			player.seek(0.0, true)
			player.speed_scale = 1.0
	_update_status()

func _on_finished(anim: StringName, player: AnimationPlayer) -> void:
	if String(anim) in LOOPING: return
	player.play("idle")
	player.seek(randf() * player.current_animation_length, true)
	player.speed_scale = randf_range(.92, 1.08)
	if soldiers.all(func(s): return s.player.current_animation == "idle"):
		current = "idle"
		_update_status()

func _set_matte(on: bool) -> void:
	matte = on
	for s in soldiers:
		s.mesh.set_surface_override_material(0, s.matte if on else null)
	_update_status()

func _update_camera() -> void:
	camera.size = zoom
	camera.position = focus + Vector3(sin(yaw) * 43, 40, cos(yaw) * 43)
	camera.look_at(focus)

func _process(delta: float) -> void:
	var turn := float(Input.is_physical_key_pressed(KEY_Q)) - float(Input.is_physical_key_pressed(KEY_E))
	if turn != 0.0:
		yaw += delta * turn
		_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if KEYS.has(event.physical_keycode): _play_all(KEYS[event.physical_keycode])
		elif event.physical_keycode == KEY_7: _set_matte(not matte)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: zoom = maxf(ZOOM_MIN, zoom / 1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoom = minf(ZOOM_MAX, zoom * 1.15)
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
	status.text = "UNIT3D A2  /  BASE SOLDIER  (blue + red test)\n1 idle   2 walk   3 run   4 attack_spear   5 attack_bow   6 attack_gun\n7 matte override: %s   (roughness 1.0, specular 0)\nQ / E turn   wheel zoom\nnow: %s" % ["ON" if matte else "OFF (GLB material)", current]
