extends Node3D
# Unit3D lab connection: ranged attack effects (arrows, musket flash / tracer / impact / smoke) for the 3D lab.
# Copied from the Unit3D D test (tests/scripts/unit3d_ranged_fx.gd, kept as it is); the only change is that the sound
# starts off (SOUND_ENABLED), because the 2D engine running inside the lab can already play the same sounds.
# Self-contained: it gets the soldier and target nodes as arguments and finds the player, skeleton, hand bone, bow
# (ArrowNock) and musket (Muzzle) inside each soldier, so it can later move to scripts/battle3d/ unchanged.
# Shapes are code-made meshes + Tweens (as the 2D effects are Line2D/Polygon2D + Tweens); no asset is added.
# Timings are the 2D values (scripts/battle_web_import_test.gd); 2D pixels become metres with the 2D cell
# (106.67 x 108 px) = the 3D cell (3.0 m).
# Unlike 2D (one shot per unit), every gunner fires its own shot (김작 21:03).

signal attack_started(soldier: Node3D, animation: String) # the scene sets per-animation weapon values (musket) here

const PX := 3.0 / 107.33 # metres per 2D pixel
const ARROW_RELEASE_SECONDS := 32.0 / 30.0 # attack_bow f32
const STAGGER_MIN := 0.05 # 2D ARROW_STAGGER_MIN_SEC / MAX: soldier i starts i * randf_range(min, max) after the volley
const STAGGER_MAX := 0.12
const ARROW_TRAVEL_MIN := 0.34 # 2D ARROW_TRAVEL_*_SEC
const ARROW_TRAVEL_MAX := 0.50
const ARROW_SCATTER_MIN := 10.0 * PX # 2D ARROW_TARGET_OFFSET_MIN / MAX (a square of +-MAX, pushed out to MIN)
const ARROW_SCATTER_MAX := 22.0 * PX
const ARROW_CURVE_MIN := 12.0 * PX # 2D ARROW_CURVE_OFFSET_*: the rise of the curve's middle (+- 45 % of it sideways)
const ARROW_CURVE_MAX := 28.0 * PX
const ARROW_PIN_LINGER_MIN := 0.35 # 2D ARROW_PIN_LINGER_*_SEC
const ARROW_PIN_LINGER_MAX := 0.60
const ARROW_PIN_POP := 0.05 # 2D: the pin grows for 0.05 s, lingers, then fades for 0.14 s
const ARROW_PIN_FADE := 0.14
const ARROW_PIN_TILT := 0.16 # rad, 2D pin rotation +- 0.16
const ARROW_EMBED := 0.08 # the tip ends this far past the impact point
const SHAFT_LENGTH := 0.45
const SHAFT_RADIUS := 0.008
const TIP_LENGTH := 0.05
const ARROW_LENGTH := SHAFT_LENGTH + TIP_LENGTH
const CHEST_HEIGHT := 0.7 # aim point above the target's feet
const MUZZLE_FLASH := 0.07 # 2D GUNNER_MUZZLE_FLASH_DURATION
const TRACER := 0.07 # 2D GUNNER_TRACER_DURATION
const IMPACT := 0.16 # 2D GUNNER_IMPACT_DURATION
const SMOKE := 0.34 # 2D GUNNER_SMOKE_LINGER_DURATION
const GUN_SCATTER := 10.0 * PX # 2D GUNNER_IMPACT_SCATTER (+- on each axis)
const SMOKE_RISE := 0.15 # m
# Sound: the 2D bus and way (GameAudio: bus SamWarSFX, -4 dB, pitch 1.0). Arrows: once per volley (2D).
# Gunshots: once per shot, at most GUNSHOT_MAX_VOICES at a time (the rest are skipped). Values to be tuned by ear.
const SFX_BUS := "SamWarSFX"
const ARROW_VOLUME_DB := -4.0
const GUNSHOT_VOLUME_DB := -4.0
const GUNSHOT_MAX_VOICES := 4
const ARROW_SOUND := preload("res://assets/audio/sfx/arrow.wav")
const GUNSHOT_SOUND := preload("res://assets/audio/sfx/gunshot.wav")
const GLOW_SHADER := "shader_type spatial;\nrender_mode unshaded, %s, depth_draw_never, cull_disabled, shadows_disabled;\nuniform vec4 tint : source_color;\ninstance uniform float alpha = 1.0;\nvoid fragment() {\n\tALBEDO = tint.rgb;\n\tALPHA = tint.a * alpha;\n}\n"

const SOUND_ENABLED := false # 3D sound for these effects (the 2D engine in the lab may already play arrow / gunshot)
var sound_enabled := SOUND_ENABLED
var records: Array = [] # one entry per arrow / shot, for checks (cleared by stop_all)
var effects := Node3D.new() # every effect node lives under here
var _tweens: Array[Tween] = []
var _pending: Dictionary = {} # soldier -> the release check connected to its skeleton
var _arrow_voice := AudioStreamPlayer.new()
var _gun_voices: Array[AudioStreamPlayer] = []
var _shaft_mesh := CylinderMesh.new()
var _tip_mesh := CylinderMesh.new()
var _fletch_mesh := QuadMesh.new()
var _sphere_mesh := SphereMesh.new()
var _tracer_mesh := CylinderMesh.new()
var _shaft_mat := StandardMaterial3D.new()
var _tip_mat := StandardMaterial3D.new()
var _fletch_mat := StandardMaterial3D.new()
var _flash_mat := ShaderMaterial.new()
var _tracer_mat := ShaderMaterial.new()
var _impact_mat := ShaderMaterial.new()
var _smoke_mat := ShaderMaterial.new()

func _ready() -> void:
	effects.name = "Effects"
	add_child(effects)
	var bus := SFX_BUS if AudioServer.get_bus_index(SFX_BUS) >= 0 else "Master"
	_arrow_voice.stream = ARROW_SOUND
	_arrow_voice.volume_db = ARROW_VOLUME_DB
	_arrow_voice.bus = bus
	add_child(_arrow_voice)
	for i in GUNSHOT_MAX_VOICES:
		var voice := AudioStreamPlayer.new()
		voice.stream = GUNSHOT_SOUND
		voice.volume_db = GUNSHOT_VOLUME_DB
		voice.bus = bus
		add_child(voice)
		_gun_voices.append(voice)
	_shaft_mesh.top_radius = SHAFT_RADIUS
	_shaft_mesh.bottom_radius = SHAFT_RADIUS
	_shaft_mesh.height = SHAFT_LENGTH
	_shaft_mesh.radial_segments = 6
	_shaft_mesh.rings = 1
	_tip_mesh.top_radius = 0.0
	_tip_mesh.bottom_radius = SHAFT_RADIUS * 2.0
	_tip_mesh.height = TIP_LENGTH
	_tip_mesh.radial_segments = 6
	_tip_mesh.rings = 1
	_fletch_mesh.size = Vector2(0.035, 0.09)
	_sphere_mesh.radius = 1.0
	_sphere_mesh.height = 2.0
	_sphere_mesh.radial_segments = 12
	_sphere_mesh.rings = 6
	_tracer_mesh.top_radius = 0.012
	_tracer_mesh.bottom_radius = 0.012
	_tracer_mesh.height = 1.0
	_tracer_mesh.radial_segments = 4
	_tracer_mesh.rings = 1
	for m in [[_shaft_mat, Color("6b4a2b")], [_tip_mat, Color("8c8f94")], [_fletch_mat, Color("ece4d2")]]:
		m[0].albedo_color = m[1]
		m[0].roughness = 1.0
		m[0].metallic_specular = 0.0
	_fletch_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_glow(_flash_mat, "blend_add", Color(1.0, 0.73, 0.25, 0.95))
	_glow(_tracer_mat, "blend_add", Color(1.0, 0.88, 0.44, 0.82))
	_glow(_impact_mat, "blend_add", Color(1.0, 0.78, 0.34, 0.9))
	_glow(_smoke_mat, "blend_mix", Color(0.62, 0.58, 0.52, 0.42))

func _glow(material: ShaderMaterial, blend: String, tint: Color) -> void:
	var shader := Shader.new()
	shader.code = GLOW_SHADER % blend
	material.shader = shader
	material.set_shader_parameter("tint", tint)

# ---- public ----

## Archer i shoots target i. Each archer starts attack_bow i * (0.05..0.12) s after the call; its arrow leaves at f32.
func fire_arrow_volley(archers: Array, targets: Array) -> void:
	var volley := {"sound": false}
	for i in mini(archers.size(), targets.size()):
		_after(float(i) * randf_range(STAGGER_MIN, STAGGER_MAX), _start_archer.bind(archers[i], targets[i], volley, i))

## Gunner i shoots target i, each at its own attack_gun f0, started i * (0.05..0.12) s after the call.
func fire_gun_volley(gunners: Array, targets: Array) -> void:
	for i in mini(gunners.size(), targets.size()):
		_after(float(i) * randf_range(STAGGER_MIN, STAGGER_MAX), _start_gunner.bind(gunners[i], targets[i], i))

## Stops every pending shot and removes every effect node.
func stop_all() -> void:
	for t in _tweens:
		if t.is_valid(): t.kill()
	_tweens.clear()
	for soldier in _pending:
		if is_instance_valid(soldier):
			var skeleton := _find(soldier, "Skeleton3D") as Skeleton3D
			if skeleton.skeleton_updated.is_connected(_pending[soldier]): skeleton.skeleton_updated.disconnect(_pending[soldier])
	_pending.clear()
	for n in effects.get_children(): n.free()
	records.clear()

func effect_count() -> int:
	return effects.get_child_count()

# ---- arrows ----

func _start_archer(archer: Node3D, target: Node3D, volley: Dictionary, index: int) -> void:
	var player := _find(archer, "AnimationPlayer") as AnimationPlayer
	var skeleton := _find(archer, "Skeleton3D") as Skeleton3D
	player.play("attack_bow")
	player.seek(0.0, true)
	player.speed_scale = 1.0
	attack_started.emit(archer, "attack_bow")
	if _pending.has(archer) and skeleton.skeleton_updated.is_connected(_pending[archer]):
		skeleton.skeleton_updated.disconnect(_pending[archer])
	var check := _check_release.bind(archer, target, volley, index, Time.get_ticks_usec())
	_pending[archer] = check
	skeleton.skeleton_updated.connect(check)

## Runs right after the archer's pose is updated; releases the arrow on the first pose at or past f32.
func _check_release(archer: Node3D, target: Node3D, volley: Dictionary, index: int, started_usec: int) -> void:
	var player := _find(archer, "AnimationPlayer") as AnimationPlayer
	var skeleton := _find(archer, "Skeleton3D") as Skeleton3D
	var playing := player.assigned_animation == "attack_bow"
	if playing and player.current_animation_position < ARROW_RELEASE_SECONDS and player.is_playing(): return
	skeleton.skeleton_updated.disconnect(_pending[archer])
	_pending.erase(archer)
	if not playing or not is_instance_valid(target): return
	var hand := skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("mixamorig_RightHand")).origin
	var nock := _fresh_global(_find(archer, "ArrowNock") as Node3D).origin
	_spawn_arrow(hand, nock, target.global_position + Vector3(0, CHEST_HEIGHT, 0), {"index": index, "kind": "arrow",
		"anim_position": player.current_animation_position, "frame_delta": get_process_delta_time(), "started_usec": started_usec, "released_usec": Time.get_ticks_usec(), "hand": hand, "nock": nock})
	if sound_enabled and not volley.sound:
		volley.sound = true
		_arrow_voice.play()

func _spawn_arrow(back: Vector3, nock: Vector3, chest: Vector3, record: Dictionary) -> void:
	var arrow := Node3D.new()
	arrow.name = "Arrow"
	effects.add_child(arrow)
	_part(arrow, _shaft_mesh, _shaft_mat, Vector3(0, 0, -SHAFT_LENGTH * .5))
	_part(arrow, _tip_mesh, _tip_mat, Vector3(0, 0, -SHAFT_LENGTH - TIP_LENGTH * .5))
	var fletch := MeshInstance3D.new()
	fletch.mesh = _fletch_mesh
	fletch.material_override = _fletch_mat
	fletch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fletch.rotation = Vector3(-PI * .5, 0, 0) # the quad's height along the shaft
	fletch.position = Vector3(0, 0, -0.06)
	arrow.add_child(fletch)
	var start_dir := (nock - back).normalized()
	arrow.global_transform = Transform3D(_facing(start_dir), back)
	# the impact point: the chest point plus the 2D scatter, in the plane across the flight
	var flight := (chest - back).normalized()
	var side := flight.cross(Vector3.UP).normalized()
	var up := side.cross(flight).normalized()
	var offset := side * randf_range(-ARROW_SCATTER_MAX, ARROW_SCATTER_MAX) + up * randf_range(-ARROW_SCATTER_MAX, ARROW_SCATTER_MAX)
	if offset.length() < ARROW_SCATTER_MIN: offset = (offset.normalized() if offset.length() > .001 else side) * ARROW_SCATTER_MIN
	var impact := chest + offset
	# the curve: a quadratic Bezier whose middle rises by the 2D curve amount (and moves +-45 % of it sideways)
	var rise := randf_range(ARROW_CURVE_MIN, ARROW_CURVE_MAX)
	var control := back.lerp(impact, .5) + Vector3.UP * rise * 2.0 + side * randf_range(-rise * .45, rise * .45) * 2.0
	var end_dir := (impact - control).normalized()
	var end := impact - end_dir * (ARROW_LENGTH - ARROW_EMBED) # where the back end stops, so the tip is just past the impact point
	control = back.lerp(end, .5) + (control - back.lerp(impact, .5))
	var travel := randf_range(ARROW_TRAVEL_MIN, ARROW_TRAVEL_MAX)
	record.merge({"start_dir": start_dir, "first_tangent": (control - back).normalized(), "chest": chest, "impact": impact, "travel": travel})
	records.append(record)
	var tween := _tween()
	tween.tween_method(_fly.bind(arrow, back, control, end), 0.0, 1.0, travel)
	tween.tween_callback(_pin.bind(arrow, record))

func _part(parent: Node3D, mesh: Mesh, material: Material, at: Vector3) -> void:
	var n := MeshInstance3D.new()
	n.mesh = mesh
	n.material_override = material
	n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.rotation = Vector3(-PI * .5, 0, 0) # the cylinder's +Y becomes the arrow's forward (-Z)
	n.position = at
	parent.add_child(n)

func _fly(t: float, arrow: Node3D, p0: Vector3, p1: Vector3, p2: Vector3) -> void:
	var u := 1.0 - t
	var position := u * u * p0 + 2.0 * u * t * p1 + t * t * p2
	var tangent := 2.0 * u * (p1 - p0) + 2.0 * t * (p2 - p1)
	arrow.global_transform = Transform3D(_facing(tangent.normalized()), position)

func _pin(arrow: Node3D, record: Dictionary) -> void:
	var b := arrow.global_transform.basis
	arrow.global_transform.basis = b.rotated(b.x.normalized(), randf_range(-ARROW_PIN_TILT, ARROW_PIN_TILT)) # tip still at the target
	record["tip_end"] = arrow.global_transform * Vector3(0, 0, -ARROW_LENGTH)
	var tween := _tween()
	tween.tween_property(arrow, "scale", Vector3.ONE * 1.1, ARROW_PIN_POP)
	tween.tween_interval(randf_range(ARROW_PIN_LINGER_MIN, ARROW_PIN_LINGER_MAX))
	tween.tween_property(arrow, "scale", Vector3.ONE * .001, ARROW_PIN_FADE) # shared materials: the fade is a shrink
	tween.tween_callback(arrow.queue_free)

# ---- musket ----

func _start_gunner(gunner: Node3D, target: Node3D, index: int) -> void:
	var player := _find(gunner, "AnimationPlayer") as AnimationPlayer
	var skeleton := _find(gunner, "Skeleton3D") as Skeleton3D
	var started := Time.get_ticks_usec()
	player.play("attack_gun")
	player.seek(0.0, true) # f0, applied now
	player.speed_scale = 1.0
	attack_started.emit(gunner, "attack_gun")
	skeleton.force_update_all_bone_transforms()
	var muzzle_node := _find(gunner, "Muzzle") as Node3D
	var muzzle := _fresh_global(muzzle_node).origin # this frame's f0 pose (the node itself may still hold last frame's)
	if not is_instance_valid(target): return
	var chest := target.global_position + Vector3(0, CHEST_HEIGHT, 0)
	var impact := chest + Vector3(randf_range(-GUN_SCATTER, GUN_SCATTER), randf_range(-GUN_SCATTER, GUN_SCATTER), randf_range(-GUN_SCATTER, GUN_SCATTER))
	records.append({"index": index, "kind": "shot", "anim_position": player.current_animation_position, "started_usec": started,
		"fired_usec": Time.get_ticks_usec(), "muzzle": muzzle, "chest": chest, "impact": impact})
	var flash := _glow_node(_flash_mat, muzzle, 0.12 * .65)
	var ft := _tween().set_parallel(true)
	ft.tween_property(flash, "scale", Vector3.ONE * 0.12 * 1.25, MUZZLE_FLASH).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	ft.tween_method(_alpha.bind(flash), 1.0, 0.0, MUZZLE_FLASH).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	ft.chain().tween_callback(flash.queue_free)
	var tracer := _glow_node(_tracer_mat, muzzle.lerp(impact, .5), 1.0)
	tracer.mesh = _tracer_mesh
	var along := impact - muzzle
	tracer.global_transform = Transform3D(_along_y(along), muzzle.lerp(impact, .5))
	var tt := _tween()
	tt.tween_method(_alpha.bind(tracer), 1.0, 0.0, TRACER).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tt.tween_callback(tracer.queue_free)
	var pop := _glow_node(_impact_mat, impact, 0.06)
	var it := _tween().set_parallel(true)
	it.tween_property(pop, "scale", Vector3.ONE * 0.06 * 1.18, IMPACT).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	it.tween_method(_alpha.bind(pop), 1.0, 0.0, IMPACT).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	it.chain().tween_callback(pop.queue_free)
	var smoke := _glow_node(_smoke_mat, muzzle, 0.1)
	var st := _tween().set_parallel(true)
	st.tween_property(smoke, "scale", Vector3.ONE * 0.1 * 1.35, SMOKE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	st.tween_property(smoke, "position:y", smoke.position.y + SMOKE_RISE, SMOKE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	st.tween_method(_alpha.bind(smoke), 1.0, 0.0, SMOKE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	st.chain().tween_callback(smoke.queue_free)
	if sound_enabled:
		for voice in _gun_voices:
			if not voice.playing:
				voice.play()
				break

func _glow_node(material: Material, at: Vector3, size: float) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = _sphere_mesh
	n.material_override = material
	n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	effects.add_child(n)
	n.global_position = at
	n.scale = Vector3.ONE * size
	return n

func _alpha(value: float, node: GeometryInstance3D) -> void:
	node.set_instance_shader_parameter("alpha", value)

# ---- helpers ----

func _after(delay: float, callback: Callable) -> void:
	if delay <= 0.0:
		callback.call()
		return
	var t := _tween()
	t.tween_interval(delay)
	t.tween_callback(callback)

func _tween() -> Tween:
	_tweens = _tweens.filter(func(t): return t.is_valid())
	var t := create_tween()
	_tweens.append(t)
	return t

func _find(soldier: Node, type_or_name: String) -> Node:
	if type_or_name in ["AnimationPlayer", "Skeleton3D"]:
		return _first_of_class(soldier, type_or_name)
	return soldier.find_child(type_or_name, true, false)

func _first_of_class(n: Node, cls: String) -> Node:
	if n.is_class(cls): return n
	for c in n.get_children():
		var r := _first_of_class(c, cls)
		if r: return r
	return null

## A node's global transform from this frame's bone pose: up to its BoneAttachment3D, then the skeleton's pose.
func _fresh_global(node: Node3D) -> Transform3D:
	var local := Transform3D()
	var n: Node = node
	while n != null and not (n is BoneAttachment3D):
		local = (n as Node3D).transform * local
		n = n.get_parent()
	if n == null: return node.global_transform
	var attach := n as BoneAttachment3D
	var skeleton := attach.get_parent() as Skeleton3D
	return skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone(attach.bone_name)) * local

func _facing(direction: Vector3) -> Basis:
	var up := Vector3.UP if absf(direction.dot(Vector3.UP)) < .99 else Vector3.FORWARD
	return Basis.looking_at(direction, up) # -Z along the direction

func _along_y(v: Vector3) -> Basis:
	var y := v.normalized()
	var x := y.cross(Vector3.UP if absf(y.dot(Vector3.UP)) < .99 else Vector3.FORWARD).normalized()
	var z := x.cross(y)
	return Basis(x, y * v.length(), z)
