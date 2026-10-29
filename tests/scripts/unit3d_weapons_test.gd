extends Node3D
# Unit3D B: the base soldier with the separate weapons (spear, bow + quiver, musket), for a look with F6.
# Separate from the 3D lab, the ScenarioShell and the A2 scene; nothing here is used by the engine. Not a CI test.
# Attachment values are the weapons README (v3) values, unchanged. Soldier GLBs are not modified.
# Keys: 1 idle, 2 walk, 3 run, 4 attack (spearman attack_spear_short x2.17, archer attack_bow, gunner attack_gun;
# attacks return to idle), 5 reference points (Tip, ArrowNock, Muzzle) on/off, 7 matte override on/off (on at start:
# roughness 1.0, specular 0, metallic 0 on copies; the GLB materials are untouched). Q/E turn the camera, wheel zooms.

const SOLDIER := {"blue": "res://assets/battle3d/base_soldier/soldier_anims_korea_blue.glb", "red": "res://assets/battle3d/base_soldier/soldier_anims_korea_red_test.glb"}
const SPEAR := {"blue": "res://assets/battle3d/weapons/weapon_spear_blue.glb", "red": "res://assets/battle3d/weapons/weapon_spear_red.glb"}
const BOW := {"blue": "res://assets/battle3d/weapons/weapon_bow_blue.glb", "red": "res://assets/battle3d/weapons/weapon_bow_red.glb"}
const QUIVER := {"blue": "res://assets/battle3d/weapons/weapon_quiver_blue.glb", "red": "res://assets/battle3d/weapons/weapon_quiver_red.glb"}
const MUSKET := "res://assets/battle3d/weapons/weapon_musket.glb"
const SPEAR_SHORT_LIBRARY := "res://assets/battle3d/base_soldier/anim_attack_spear_short.glb" # imported as an AnimationLibrary
const SPEAR_Q := Quaternion(0.3704, 0.9157, -0.0862, 0.1294) # under WeaponSocket_R
const BOW_Q := Quaternion(0.0973, 0.7935, 0.6005, -0.0160) # under WeaponSocket_L
const QUIVER_BONE := "mixamorig_Spine2" # README: mixamorig:Spine2 (Godot imports ':' as '_')
const QUIVER_POSITION := Vector3(-0.030, -0.020, -0.145)
const QUIVER_Q := Quaternion(-0.0846, -0.0211, 0.2410, 0.9666)
const MUSKET_Q := { # under WeaponSocket_R, per animation
	"idle": Quaternion(0.4956, 0.3527, 0.1508, 0.7793), "idle_alt": Quaternion(0.4956, 0.3527, 0.1508, 0.7793),
	"walk": Quaternion(0.5600, 0.3742, 0.2963, 0.6772), "run": Quaternion(-0.0931, -0.3625, 0.4307, 0.8212),
	"attack_gun": Quaternion(0.7749, -0.2058, 0.5645, 0.1962)}
const MUSKET_SLERP_SECONDS := .1
const ATTACK := {"spear": ["attack_spear_short", 2.17], "bow": ["attack_bow", 1.0], "gun": ["attack_gun", 1.0]}
const KEYS := {KEY_1: "idle", KEY_2: "walk", KEY_3: "run", KEY_4: "attack"}
const LOOPING := ["idle", "idle_alt", "walk", "run"]
const COLUMNS := {"spear": -1.8, "bow": 0.0, "gun": 1.8} # x; rows: blue z -1.0, red z +1.0, all facing +Z (the camera side)
const ROWS := {"blue": -1.0, "red": 1.0}
# The lab camera (lab_presentation.gd _update_camera): orthographic, offset (sin(yaw)*43, 40, cos(yaw)*43), yaw 0.32.
const CAMERA_YAW := .32
const ZOOM_MIN := 1.5
const ZOOM_MAX := 42.0

var camera := Camera3D.new()
var yaw := CAMERA_YAW
var zoom := 6.0
var focus := Vector3(0, .5, 0)
var soldiers: Array = [] # {name, kind, side, root, player, skeleton, socket_r, socket_l, spear, musket, musket_from, musket_to, musket_t, attack_left}
var surfaces: Array = [] # [MeshInstance3D, surface index, original material, matte copy]
var markers: Array[Node3D] = []
var current := "idle"
var matte := true # 김작 18:13: matte is the default
var markers_on := false
var status: Label

func _ready() -> void:
	randomize()
	_build_world()
	var library: AnimationLibrary = load(SPEAR_SHORT_LIBRARY)
	for kind in COLUMNS:
		for side in ROWS:
			_spawn(kind, side, Vector3(COLUMNS[kind], 0, ROWS[side]), library)
	_build_ui()
	_set_matte(true)
	_set_markers(false)
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
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("6f7d55")
	m.roughness = .85
	ground.material_override = m
	add_child(ground)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 200
	add_child(camera)
	_update_camera()

func _weapon(path: String, parent: Node3D, position: Vector3, rotation: Quaternion) -> Node3D:
	var weapon: Node3D = (load(path) as PackedScene).instantiate()
	parent.add_child(weapon)
	weapon.position = position
	weapon.quaternion = rotation
	_collect_surfaces(weapon)
	return weapon

func _collect_surfaces(n: Node) -> void:
	if n is MeshInstance3D:
		for i in n.mesh.get_surface_count():
			var original: Material = n.mesh.surface_get_material(i)
			var copy := original.duplicate() as StandardMaterial3D
			copy.roughness = 1.0
			copy.metallic_specular = 0.0
			copy.metallic = 0.0
			surfaces.append([n, i, original, copy])
	for c in n.get_children(): _collect_surfaces(c)

func _marker(parent: Node, point: String) -> void:
	var node: Node3D = parent.find_child(point, true, false)
	var ball := MeshInstance3D.new()
	ball.name = "Marker"
	var sphere := SphereMesh.new()
	sphere.radius = .02
	sphere.height = .04
	ball.mesh = sphere
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("ff3df0")
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.no_depth_test = true # seen through the body, so the point is never hidden
	ball.material_override = m
	node.add_child(ball)
	markers.append(ball)

func _spawn(kind: String, side: String, at: Vector3, library: AnimationLibrary) -> void:
	var root: Node3D = (load(SOLDIER[side]) as PackedScene).instantiate()
	root.name = "%s_%s" % [kind.capitalize(), side.capitalize()]
	root.position = at # rotation 0: the model looks along +Z
	add_child(root)
	_collect_surfaces(root)
	var skeleton: Skeleton3D = root.find_child("Skeleton3D", true, false)
	var socket_r: Node3D = root.find_child("WeaponSocket_R", true, false)
	var socket_l: Node3D = root.find_child("WeaponSocket_L", true, false)
	var player: AnimationPlayer = root.find_child("AnimationPlayer", true, false)
	# attack_spear_short shares the soldier's track paths (Armature/Skeleton3D); it joins the default library so its
	# name stays "attack_spear_short" (the README two-hand rule tests begins_with("attack_spear")).
	var own := player.get_animation_library(&"")
	if not own.has_animation(&"attack_spear_short"):
		own.add_animation(&"attack_spear_short", library.get_animation(&"attack_spear_short"))
	var s := {"name": root.name, "kind": kind, "side": side, "root": root, "player": player, "skeleton": skeleton,
		"socket_r": socket_r, "socket_l": socket_l, "spear": null, "musket": null, "attack_left": 0.0}
	match kind:
		"spear":
			s.spear = _weapon(SPEAR[side], socket_r, Vector3.ZERO, SPEAR_Q)
			_marker(s.spear, "Tip")
			skeleton.skeleton_updated.connect(_aim_spear.bind(s))
		"bow":
			var bow := _weapon(BOW[side], socket_l, Vector3.ZERO, BOW_Q)
			_marker(bow, "ArrowNock")
			var back := BoneAttachment3D.new()
			back.name = "QuiverAttachment"
			skeleton.add_child(back)
			back.bone_name = QUIVER_BONE
			_weapon(QUIVER[side], back, QUIVER_POSITION, QUIVER_Q)
		"gun":
			s.musket = _weapon(MUSKET, socket_r, Vector3.ZERO, MUSKET_Q.idle)
			s.musket_from = MUSKET_Q.idle
			s.musket_to = MUSKET_Q.idle
			s.musket_t = 1.0
			_marker(s.musket, "Muzzle")
	soldiers.append(s)

## README two-hand rule: during attack_spear*, the spear (+Y = tip) stays on the right-hand socket and aims at the
## left-hand socket; otherwise it keeps the README attachment value. Runs right after the skeleton pose is updated.
func _aim_spear(s: Dictionary) -> void:
	var spear: Node3D = s.spear
	var player: AnimationPlayer = s.player
	if not String(player.current_animation).begins_with("attack_spear"):
		spear.quaternion = SPEAR_Q
		return
	var skeleton: Skeleton3D = s.skeleton
	var right := _socket_global(skeleton, "mixamorig_RightHand", s.socket_r)
	var left := _socket_global(skeleton, "mixamorig_LeftHand", s.socket_l)
	var aim := left.origin - right.origin
	if aim.length() < .001: return
	var rest := right.basis * Basis(SPEAR_Q) # the held orientation, then turned the least way so +Y points at the left hand
	var turn := Quaternion(rest.y.normalized(), aim.normalized())
	# set in the socket's frame from this frame's pose (the socket node itself may still hold last frame's transform)
	spear.transform = right.affine_inverse() * Transform3D(Basis(turn) * rest, right.origin)

func _socket_global(skeleton: Skeleton3D, bone: String, socket: Node3D) -> Transform3D:
	return skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(bone)) * socket.transform

func _play(s: Dictionary, anim: String) -> void:
	var player: AnimationPlayer = s.player
	var speed := 1.0
	if anim == "attack":
		anim = ATTACK[s.kind][0]
		speed = ATTACK[s.kind][1]
	player.play(anim)
	if anim in LOOPING:
		player.seek(randf() * player.current_animation_length, true)
		player.speed_scale = randf_range(.92, 1.08)
		s.attack_left = 0.0
	else:
		player.seek(0.0, true)
		player.speed_scale = speed
		s.attack_left = player.current_animation_length / speed # one pass (attack_spear_short loops, so it is timed)
	if s.musket and MUSKET_Q.has(anim):
		s.musket_from = (s.musket as Node3D).quaternion
		s.musket_to = MUSKET_Q[anim]
		s.musket_t = 0.0

func _play_all(anim: String) -> void:
	current = anim
	for s in soldiers: _play(s, anim)
	_update_status()

func _process(delta: float) -> void:
	var back_to_idle := false
	for s in soldiers:
		if s.attack_left > 0.0:
			s.attack_left -= delta
			if s.attack_left <= 0.0:
				_play(s, "idle")
				back_to_idle = true
		if s.musket and s.musket_t < 1.0:
			s.musket_t = minf(1.0, s.musket_t + delta / MUSKET_SLERP_SECONDS)
			(s.musket as Node3D).quaternion = (s.musket_from as Quaternion).slerp(s.musket_to, s.musket_t)
	if back_to_idle and soldiers.all(func(x): return x.attack_left <= 0.0):
		current = "idle"
		_update_status()
	var turn := float(Input.is_physical_key_pressed(KEY_Q)) - float(Input.is_physical_key_pressed(KEY_E))
	if turn != 0.0:
		yaw += delta * turn
		_update_camera()

func _set_matte(on: bool) -> void:
	matte = on
	for entry in surfaces:
		(entry[0] as MeshInstance3D).set_surface_override_material(entry[1], entry[3] if on else null)
	_update_status()

func _set_markers(on: bool) -> void:
	markers_on = on
	for m in markers: m.visible = on
	_update_status()

func _update_camera() -> void:
	camera.size = zoom
	camera.position = focus + Vector3(sin(yaw) * 43, 40, cos(yaw) * 43)
	camera.look_at(focus)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if KEYS.has(event.physical_keycode): _play_all(KEYS[event.physical_keycode])
		elif event.physical_keycode == KEY_5: _set_markers(not markers_on)
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
	status.text = "UNIT3D B  /  WEAPONS  (left: spear  middle: bow + quiver  right: musket;  back row blue, front row red test)\n1 idle   2 walk   3 run   4 attack (spear_short x2.17 / bow / gun)\n5 reference points (Tip, ArrowNock, Muzzle): %s\n7 matte override: %s   (roughness 1.0, specular 0)\nQ / E turn   wheel zoom\nnow: %s" % ["ON" if markers_on else "OFF", "ON" if matte else "OFF (GLB materials)", current]
