extends Node3D
# Queue 35: cannon effects for the naval 3D battle (presentation only; the engine has already judged the attack).
# One shot: a muzzle flash and smoke at the gun port, a ball on an arc, then either a hit (flash + dark smoke on the
# target) or a miss (a water column next to it). Also the smoke of a sinking ship. Its own random stream, like
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
const SPLASH := 0.7
const HIT_FLASH := 0.16
const HIT_SMOKE := 1.0
const HIT_HEIGHT := 0.45 # m above the target's waterline

var records: Array = [] # one entry per ball / smoke, for checks (cleared by stop_all)
var effects := Node3D.new()
var _tweens: Array[Tween] = []
var _rng := RandomNumberGenerator.new()
var _sphere := SphereMesh.new()
var _column := CylinderMesh.new()

func _init() -> void:
	_rng.randomize()

func _ready() -> void:
	effects.name = "Effects"
	add_child(effects)
	_sphere.radius = 0.5
	_sphere.height = 1.0
	_sphere.radial_segments = 10
	_sphere.rings = 5
	_column.top_radius = 0.1
	_column.bottom_radius = 0.28
	_column.height = 1.0
	_column.radial_segments = 8

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
		var column := _node(_column, Color(0.86, 0.93, 0.96, 0.9), false)
		column.global_position = impact
		column.scale = Vector3(0.6, 0.05, 0.6)
		var tween := _tween()
		tween.tween_method(_column_shape.bind(column, impact), 0.0, 1.0, SPLASH)
		tween.tween_callback(column.queue_free)
		_puff(impact + Vector3(0, 0.05, 0), 0.3, 0.9, Color(0.9, 0.95, 0.97, 0.7), SPLASH * 0.8, 0.1, false)
		return
	_puff(impact, 0.3, 1.0, Color(1.0, 0.7, 0.35), HIT_FLASH, 0.0, true)
	_puff(impact, 0.35, 1.2, Color(0.2, 0.19, 0.18, 0.8), HIT_SMOKE, 0.8, false)

func _column_shape(t: float, column: MeshInstance3D, impact: Vector3) -> void:
	# Up fast, down slow; fades at the end.
	if not is_instance_valid(column): return
	var height := sin(minf(t * 1.6, 1.0) * PI * 0.5) * (1.0 - smoothstep(0.55, 1.0, t)) * 2.2 + 0.05
	column.scale = Vector3(1.0 + t * 0.6, height, 1.0 + t * 0.6)
	column.global_position = impact + Vector3(0, height * 0.5, 0)
	(column.material_override as StandardMaterial3D).albedo_color.a = 0.9 * (1.0 - smoothstep(0.6, 1.0, t))

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
