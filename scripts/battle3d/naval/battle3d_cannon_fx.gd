extends Node3D
# Queue 35: cannon effects for the naval 3D battle (presentation only; the engine has already judged the attack).
# One shot: a muzzle flash and smoke at the gun port, a ball on an arc, then either a hit (flash + dark smoke on the
# target) or a miss (a splash of drops, rings and foam next to it). Also the smoke of a sinking ship. Its own random stream, like
# battle3d_ranged_fx.gd: the engine's global one is never touched.
const STAGGER := 0.09 # s between the guns of one broadside
const FLASH := 0.16
const MUZZLE_SMOKE := 0.9
const BALL_TRAVEL_MIN := 0.45
const BALL_TRAVEL_MAX := 0.7
const ARC_PER_METRE := 0.14 # the arc's rise per metre of range
const MISS_RATE := 0.3 # shots that fall in the water (looks only)
const MISS_OFFSET_MIN := 0.9
const MISS_OFFSET_MAX := 1.5
const SPLASH := 1.5 # s: the whole splash, to the last foam
const COLUMN_DROPS := 28
const CROWN_DROPS := 16
const RING_COUNT := 2
const RING_SECONDS := 1.0
const HIT_FLASH := 0.16
const HIT_SMOKE := 1.0
const HIT_HEIGHT := 0.45 # m above the target's waterline

var records: Array = [] # one entry per ball / smoke, for checks (cleared by stop_all)
var effects := Node3D.new()
var _tweens: Array[Tween] = []
var _rng := RandomNumberGenerator.new()
var _sphere := SphereMesh.new()
var _drop_mesh := QuadMesh.new()
var _flat_mesh := PlaneMesh.new()
var _drop_material := StandardMaterial3D.new()
var _drop_scale := Curve.new()
var _drop_fade := Gradient.new()
var _dot_texture: GradientTexture2D
var _ring_texture: GradientTexture2D

func _init() -> void:
	_rng.randomize()

func _ready() -> void:
	effects.name = "Effects"
	add_child(effects)
	_sphere.radius = 0.5
	_sphere.height = 1.0
	_sphere.radial_segments = 10
	_sphere.rings = 5
	_dot_texture = _radial([[0.0, 1.0], [0.45, 0.8], [1.0, 0.0]])
	_ring_texture = _radial([[0.0, 0.0], [0.62, 0.0], [0.8, 1.0], [0.92, 0.6], [1.0, 0.0]])
	_drop_mesh.size = Vector2.ONE
	_flat_mesh.size = Vector2.ONE
	_drop_material.albedo_texture = _dot_texture
	_drop_material.albedo_color = Color(0.94, 0.98, 1.0, 0.95)
	_drop_material.vertex_color_use_as_albedo = true
	_drop_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_drop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_drop_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_drop_material.billboard_keep_scale = true
	_drop_scale.add_point(Vector2(0.0, 0.7))
	_drop_scale.add_point(Vector2(0.35, 1.0))
	_drop_scale.add_point(Vector2(1.0, 0.45))
	_drop_fade.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	_drop_fade.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.85), Color(1, 1, 1, 0)])

## One broadside: gun i fires at the target (a world point at the target's waterline) i * STAGGER seconds after the call.
func fire_broadside(muzzles: Array, target: Vector3, shooter_id := "", target_id := "") -> void:
	for index in range(muzzles.size()):
		_after(index * STAGGER, _fire.bind(muzzles[index], target, index, shooter_id, target_id))

func _fire(muzzle: Vector3, target: Vector3, index: int, shooter_id: String, target_id: String) -> void:
	var miss := _rng.randf() < MISS_RATE
	var impact := target + Vector3(0, HIT_HEIGHT, 0) + Vector3(_rng.randf_range(-0.5, 0.5), _rng.randf_range(-0.15, 0.25), _rng.randf_range(-0.5, 0.5))
	if miss:
		var turn := _rng.randf() * TAU
		impact = target + Vector3(cos(turn), 0, sin(turn)) * _rng.randf_range(MISS_OFFSET_MIN, MISS_OFFSET_MAX)
		impact.y = 0.0
	var travel := _rng.randf_range(BALL_TRAVEL_MIN, BALL_TRAVEL_MAX)
	records.append({"kind":"cannon", "index":index, "shooter_id":shooter_id, "target_id":target_id, "muzzle":muzzle, "impact":impact, "miss":miss, "travel":travel})
	_puff(muzzle, 0.3, 0.95, Color(1.0, 0.82, 0.45), FLASH, 0.0, true)
	_puff(muzzle, 0.35, 1.15, Color(0.8, 0.8, 0.78, 0.85), MUZZLE_SMOKE, 0.6, false)
	var ball := _node(_sphere, Color(0.08, 0.08, 0.09), false)
	ball.scale = Vector3.ONE * 0.2
	ball.global_position = muzzle
	var rise := muzzle.distance_to(impact) * ARC_PER_METRE
	var tween := _tween()
	tween.tween_method(_fly.bind(ball, muzzle, muzzle.lerp(impact, 0.5) + Vector3.UP * rise * 2.0, impact), 0.0, 1.0, travel)
	tween.tween_callback(_land.bind(ball, impact, miss))

func _fly(t: float, ball: Node3D, p0: Vector3, p1: Vector3, p2: Vector3) -> void:
	if is_instance_valid(ball): ball.global_position = p0.lerp(p1, t).lerp(p1.lerp(p2, t), t)

func _land(ball: Node3D, impact: Vector3, miss: bool) -> void:
	if is_instance_valid(ball): ball.queue_free()
	if miss:
		_splash(impact)
		return
	_puff(impact, 0.3, 1.0, Color(1.0, 0.7, 0.35), HIT_FLASH, 0.0, true)
	_puff(impact, 0.35, 1.2, Color(0.2, 0.19, 0.18, 0.8), HIT_SMOKE, 0.8, false)

## A ball falling into the sea (reply 2): a column of drops and mist that shoots up and falls back, a crown of small
## drops thrown outward, foam rings spreading on the surface, and a patch of foam that lingers. About 1.5 s in all.
func _splash(impact: Vector3) -> void:
	var at := Vector3(impact.x, 0.03, impact.z)
	records.append({"kind":"splash", "impact":at, "column":COLUMN_DROPS, "crown":CROWN_DROPS, "rings":RING_COUNT, "seconds":SPLASH})
	_drops(at, COLUMN_DROPS, 0.75, 10.0, 4.6, 5.9, 0.16, 0.05) # up to about 1.2-1.8 m, thick below, scattered above
	_drops(at, CROWN_DROPS, 0.6, 58.0, 2.0, 3.3, 0.08, 0.16)
	for index in range(RING_COUNT):
		var ring := _flat(_ring_texture, at + Vector3(0, 0.01 * index, 0), 0.5)
		ring.material_override.albedo_color.a = 0.0
		var ring_tween := _tween()
		ring_tween.tween_interval(0.08 + index * 0.22)
		ring_tween.tween_property(ring.material_override, "albedo_color:a", 0.85, 0.05)
		ring_tween.set_parallel(true)
		ring_tween.tween_property(ring, "scale", Vector3.ONE * (2.6 - index * 0.5), RING_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		ring_tween.tween_property(ring.material_override, "albedo_color:a", 0.0, RING_SECONDS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		ring_tween.chain().tween_callback(ring.queue_free)
	var foam := _flat(_dot_texture, at, 0.7)
	foam.material_override.albedo_color.a = 0.0
	var foam_tween := _tween()
	foam_tween.tween_property(foam.material_override, "albedo_color:a", 0.5, 0.2)
	foam_tween.set_parallel(true)
	foam_tween.tween_property(foam, "scale", Vector3.ONE * 1.5, SPLASH).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	foam_tween.tween_property(foam.material_override, "albedo_color:a", 0.0, SPLASH - 0.2).set_delay(0.2)
	foam_tween.chain().tween_callback(foam.queue_free)

func _drops(at: Vector3, amount: int, lifetime: float, spread: float, speed_min: float, speed_max: float, size: float, radius: float) -> void:
	# One burst of white drops (soft billboard dots) thrown up and pulled back down by gravity; freed when it is over.
	var drops := CPUParticles3D.new()
	drops.one_shot = true
	drops.emitting = false
	drops.amount = amount
	drops.lifetime = lifetime
	drops.explosiveness = 0.88
	drops.randomness = 0.3
	drops.local_coords = false
	drops.mesh = _drop_mesh
	drops.material_override = _drop_material
	drops.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	drops.emission_sphere_radius = radius
	drops.direction = Vector3.UP
	drops.spread = spread
	drops.initial_velocity_min = speed_min
	drops.initial_velocity_max = speed_max
	drops.gravity = Vector3(0, -12.5, 0)
	drops.scale_amount_min = size * 0.6
	drops.scale_amount_max = size * 1.5
	drops.scale_amount_curve = _drop_scale
	drops.color_ramp = _drop_fade
	drops.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	effects.add_child(drops)
	drops.global_position = at
	drops.restart()
	_after(lifetime + 0.25, drops.queue_free)

func _flat(texture: Texture2D, at: Vector3, size: float) -> MeshInstance3D:
	# A thin white picture lying on the water (a foam ring or a foam patch).
	var node := MeshInstance3D.new()
	node.mesh = _flat_mesh
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.albedo_color = Color(0.93, 0.97, 0.98, 1.0)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	node.material_override = material
	effects.add_child(node)
	node.global_position = at
	node.scale = Vector3.ONE * size
	return node

static func _radial(stops: Array) -> GradientTexture2D:
	# A round white picture whose opacity follows `stops` ([offset from the centre, alpha], ...).
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array(stops.map(func(stop): return stop[0]))
	gradient.colors = PackedColorArray(stops.map(func(stop): return Color(1, 1, 1, stop[1])))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 64
	texture.height = 64
	return texture

## Smoke over a sinking ship (the ship visuals call this a few times while it goes down).
func smoke_at(point: Vector3, unit_id := "") -> void:
	records.append({"kind":"sink_smoke", "unit_id":unit_id, "point":point})
	_puff(point + Vector3(_rng.randf_range(-0.4, 0.4), 0.3, _rng.randf_range(-0.4, 0.4)), 0.35, 1.1, Color(0.17, 0.16, 0.16, 0.8), 1.4, 1.4, false)

func stop_all() -> void:
	for tween in _tweens:
		if tween.is_valid(): tween.kill()
	_tweens.clear()
	for node in effects.get_children(): node.free()
	records.clear()

func effect_count() -> int:
	return effects.get_child_count()

func _puff(at: Vector3, from_size: float, to_size: float, color: Color, seconds: float, rise: float, glow: bool) -> void:
	var puff := _node(_sphere, color, glow)
	puff.global_position = at
	puff.scale = Vector3.ONE * from_size
	var tween := _tween().set_parallel(true)
	tween.tween_property(puff, "scale", Vector3.ONE * to_size, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(puff, "position:y", puff.position.y + rise, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(puff.material_override, "albedo_color:a", 0.0, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(puff.queue_free)

func _node(mesh: Mesh, color: Color, glow: bool) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if glow else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	material.roughness = 1.0
	node.material_override = material
	effects.add_child(node)
	return node

func _after(delay: float, callback: Callable) -> void:
	if delay <= 0.0:
		callback.call()
		return
	var tween := _tween()
	tween.tween_interval(delay)
	tween.tween_callback(callback)

func _tween() -> Tween:
	_tweens = _tweens.filter(func(t): return t.is_valid())
	var tween := create_tween()
	_tweens.append(tween)
	return tween
