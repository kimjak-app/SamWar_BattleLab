extends Node3D
# Unit3D D: test scene for the ranged effects (tests/scripts/unit3d_ranged_fx.gd), for a look with F6.
# Separate from the 3D lab and the A2/B/C scenes; nothing here is used by the engine. Not a CI test.
# Zone 1 (z -4): 9 blue archers (x -5) shoot 9 red spearmen (x +5). Zone 2 (z +4): 9 blue gunners shoot 9 red spearmen.
# Keys: F archer volley, G gunner volley, R reset, H slow motion (time scale 0.25 <-> 1.0), M sound on/off,
# C camera size 14 -> 20 -> 42, wheel zoom, Q/E turn the camera.

const RangedFx := preload("res://tests/scripts/unit3d_ranged_fx.gd")
const SOLDIER := {"blue": "res://assets/battle3d/base_soldier/soldier_anims_korea_blue.glb", "red": "res://assets/battle3d/base_soldier/soldier_anims_korea_red_test.glb"}
const SPEAR_RED := "res://assets/battle3d/weapons/weapon_spear_red.glb"
const BOW_BLUE := "res://assets/battle3d/weapons/weapon_bow_blue.glb"
const QUIVER_BLUE := "res://assets/battle3d/weapons/weapon_quiver_blue.glb"
const MUSKET := "res://assets/battle3d/weapons/weapon_musket.glb"
# B attachment values (weapons README v3)
const SPEAR_Q := Quaternion(0.3704, 0.9157, -0.0862, 0.1294)
const BOW_Q := Quaternion(0.0973, 0.7935, 0.6005, -0.0160)
const QUIVER_BONE := "mixamorig_Spine2"
const QUIVER_POSITION := Vector3(-0.030, -0.020, -0.145)
const QUIVER_Q := Quaternion(-0.0846, -0.0211, 0.2410, 0.9666)
const MUSKET_Q := {
	"idle": Quaternion(0.4956, 0.3527, 0.1508, 0.7793), "idle_alt": Quaternion(0.4956, 0.3527, 0.1508, 0.7793),
	"walk": Quaternion(0.5600, 0.3742, 0.2963, 0.6772), "run": Quaternion(-0.0931, -0.3625, 0.4307, 0.8212),
	"attack_gun": Quaternion(0.7749, -0.2058, 0.5645, 0.1962)}
const MUSKET_SLERP_SECONDS := .1
const SPACING := 0.65
const ZONES := {"archers": -4.0, "gunners": 4.0} # z
const SIDE_X := {"blue": -5.0, "red": 5.0}
const SIDE_FACING := {"blue": PI * .5, "red": -PI * .5} # the model looks along +Z
const CAMERA_YAW := .32 # the lab camera: orthographic, offset (sin(yaw)*43, 40, cos(yaw)*43)
const CAMERA_SIZES := [14.0, 20.0, 42.0]

var fx: Node3D = RangedFx.new()
var camera := Camera3D.new()
var yaw := CAMERA_YAW
var zoom := 14.0
var focus := Vector3(0, .5, 0)
var archers: Array = []
var gunners: Array = []
var archer_targets: Array = []
var gunner_targets: Array = []
var soldiers: Array = [] # every soldier root
var muskets: Dictionary = {} # gunner root -> {node, from, to, t}
var materials: Dictionary = {} # GLB material -> its shared matte copy
var slow := false
var status: Label
var hud_time := 0.0

func _ready() -> void:
	randomize()
	_build_world()
	fx.name = "RangedFx"
	add_child(fx)
	fx.attack_started.connect(_on_attack_started)
	for i in 9:
		var at := Vector3(((i % 3) - 1) * SPACING, 0, (int(i / 3) - 1) * SPACING)
		archers.append(_spawn("blue", "archer", at + Vector3(SIDE_X.blue, 0, ZONES.archers)))
		archer_targets.append(_spawn("red", "spear", at + Vector3(SIDE_X.red, 0, ZONES.archers)))
		gunners.append(_spawn("blue", "gunner", at + Vector3(SIDE_X.blue, 0, ZONES.gunners)))
		gunner_targets.append(_spawn("red", "spear", at + Vector3(SIDE_X.red, 0, ZONES.gunners)))
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

func _weapon(path: String, parent: Node3D, position: Vector3, rotation: Quaternion) -> Node3D:
	var weapon: Node3D = (load(path) as PackedScene).instantiate()
	parent.add_child(weapon)
	weapon.position = position
	weapon.quaternion = rotation
	return weapon

func _spawn(side: String, kind: String, at: Vector3) -> Node3D:
	var root: Node3D = (load(SOLDIER[side]) as PackedScene).instantiate()
	root.name = "%s_%s_%d" % [side.capitalize(), kind.capitalize(), soldiers.size()]
	root.position = at
	root.rotation.y = SIDE_FACING[side]
	add_child(root)
	var socket_r: Node3D = root.find_child("WeaponSocket_R", true, false)
	var socket_l: Node3D = root.find_child("WeaponSocket_L", true, false)
	var skeleton: Skeleton3D = root.find_child("Skeleton3D", true, false)
	match kind:
		"spear": _weapon(SPEAR_RED, socket_r, Vector3.ZERO, SPEAR_Q)
		"archer":
			_weapon(BOW_BLUE, socket_l, Vector3.ZERO, BOW_Q)
			var back := BoneAttachment3D.new()
			back.name = "QuiverAttachment"
			skeleton.add_child(back)
			back.bone_name = QUIVER_BONE
			_weapon(QUIVER_BLUE, back, QUIVER_POSITION, QUIVER_Q)
		"gunner":
			var musket := _weapon(MUSKET, socket_r, Vector3.ZERO, MUSKET_Q.idle)
			muskets[root] = {"node": musket, "from": MUSKET_Q.idle, "to": MUSKET_Q.idle, "t": 1.0}
	_matte(root)
	var player: AnimationPlayer = root.find_child("AnimationPlayer", true, false)
	player.animation_finished.connect(_on_finished.bind(root))
	soldiers.append(root)
	return root

func _idle(root: Node3D) -> void:
	var player: AnimationPlayer = root.find_child("AnimationPlayer", true, false)
	player.play("idle")
	player.seek(randf() * player.current_animation_length, true)
	player.speed_scale = randf_range(.92, 1.08)
	_musket_to(root, "idle", false)

func _musket_to(root: Node3D, anim: String, snap: bool) -> void:
	if not muskets.has(root) or not MUSKET_Q.has(anim): return
	var m: Dictionary = muskets[root]
	m.from = (m.node as Node3D).quaternion
	m.to = MUSKET_Q[anim]
	m.t = 1.0 if snap else 0.0
	if snap: (m.node as Node3D).quaternion = m.to

## The effect script started an attack: the musket takes its attack_gun value at once, so f0's Muzzle is the fired one.
func _on_attack_started(soldier: Node3D, anim: String) -> void:
	_musket_to(soldier, anim, true)

func _on_finished(anim: StringName, root: Node3D) -> void:
	if String(anim).begins_with("attack"): _idle(root)

func reset() -> void:
	fx.stop_all()
	for root in soldiers: _idle(root)
	_set_slow(false)

func _set_slow(on: bool) -> void:
	slow = on
	Engine.time_scale = .25 if on else 1.0

func _update_camera() -> void:
	camera.size = zoom
	camera.position = focus + Vector3(sin(yaw) * 43, 40, cos(yaw) * 43)
	camera.look_at(focus)

func _process(delta: float) -> void:
	for m in muskets.values():
		if m.t < 1.0:
			m.t = minf(1.0, m.t + delta / MUSKET_SLERP_SECONDS)
			(m.node as Node3D).quaternion = (m.from as Quaternion).slerp(m.to, m.t)
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
			KEY_F: fx.fire_arrow_volley(archers, archer_targets)
			KEY_G: fx.fire_gun_volley(gunners, gunner_targets)
			KEY_R: reset()
			KEY_H: _set_slow(not slow)
			KEY_M: fx.sound_enabled = not fx.sound_enabled
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
	status.text = "UNIT3D D  /  RANGED FX   (back: 9 archers -> 9 spearmen   front: 9 gunners -> 9 spearmen)\nF archer volley   G gunner volley   R reset   H slow %s   M sound %s   C camera size %d   wheel zoom   Q/E turn\nFPS %d   effect nodes %d" % ["ON (x0.25)" if slow else "OFF", "ON" if fx.sound_enabled else "OFF", int(round(zoom)), Performance.get_monitor(Performance.TIME_FPS), fx.effect_count()]
