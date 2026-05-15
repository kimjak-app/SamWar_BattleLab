extends Node2D

const ENEMY_MAX_HP := 100
const DAMAGE_PER_HIT := 30
const FLIGHT_DURATION := 0.9
const EXPLOSION_DURATION := 0.35
const SHAKE_DURATION := 0.2
const SHAKE_STRENGTH := 10.0
const EXPLOSION_OFFSET := Vector2(0.0, 118.0)

var enemy_hp := ENEMY_MAX_HP
var projectile_active := false
var projectile_time := 0.0
var projectile_start := Vector2.ZERO
var projectile_end := Vector2.ZERO
var projectile_control := Vector2.ZERO

var explosion_active := false
var explosion_time := 0.0
var shake_time := 0.0
var rng := RandomNumberGenerator.new()

@onready var ally_formation: Sprite2D = $AllyFormation
@onready var enemy_formation: Sprite2D = $EnemyFormation
@onready var projectile: AnimatedSprite2D = $SingijeonProjectile
@onready var explosion: AnimatedSprite2D = $SingijeonExplosion
@onready var projectile_trail: Line2D = $ProjectileTrail
@onready var main_camera: Camera2D = $MainCamera
@onready var projectile_start_marker: Marker2D = $ProjectileStartMarker
@onready var projectile_control_marker: Marker2D = $ProjectileControlMarker
@onready var projectile_end_marker: Marker2D = $ProjectileEndMarker
@onready var enemy_hp_label: Label = $UILayer/EnemyHPLabel
@onready var instruction_label: Label = $UILayer/InstructionLabel
@onready var explosion_base_scale: Vector2 = explosion.scale


func _ready() -> void:
	rng.randomize()
	projectile.visible = false
	explosion.visible = false
	projectile_trail.visible = false
	projectile.rotation = 0.0
	main_camera.make_current()
	_update_enemy_hp_label()
	instruction_label.text = "Press SPACE to fire Singijeon"


func _process(delta: float) -> void:
	if projectile_active:
		_update_projectile(delta)

	if explosion_active:
		_update_explosion(delta)

	_update_camera_shake(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_launch_singijeon()


func _launch_singijeon() -> void:
	if projectile_active:
		return

	projectile_active = true
	projectile_time = 0.0
	projectile_start = projectile_start_marker.global_position
	projectile_end = projectile_end_marker.global_position
	projectile_control = projectile_control_marker.global_position
	projectile.position = projectile_start
	projectile.frame = 0
	projectile.visible = true
	projectile.play("fly")

	projectile_trail.clear_points()
	projectile_trail.add_point(projectile_start)
	projectile_trail.add_point(projectile_start)
	projectile_trail.visible = true

	print("Singijeon launch: from ", projectile_start, " to ", projectile_end)


func _update_projectile(delta: float) -> void:
	projectile_time += delta
	var t: float = minf(projectile_time / FLIGHT_DURATION, 1.0)
	projectile.position = _quadratic_bezier(projectile_start, projectile_control, projectile_end, t)
	projectile.rotation = projectile.position.angle_to_point(projectile_end)
	projectile_trail.set_point_position(0, projectile_start)
	projectile_trail.set_point_position(1, projectile.position)

	if t >= 1.0:
		projectile_active = false
		projectile.stop()
		projectile.visible = false
		projectile_trail.visible = false
		_on_projectile_impact()


func _quadratic_bezier(start: Vector2, control: Vector2, finish: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return u * u * start + 2.0 * u * t * control + t * t * finish


func _on_projectile_impact() -> void:
	explosion_active = true
	explosion_time = 0.0
	explosion.position = projectile_end + EXPLOSION_OFFSET
	explosion.scale = explosion_base_scale
	explosion.visible = true
	explosion.modulate = Color(1.0, 1.0, 1.0, 1.0)
	explosion.frame = 0
	explosion.play("impact")

	shake_time = SHAKE_DURATION
	enemy_hp = max(enemy_hp - DAMAGE_PER_HIT, 0)
	_update_enemy_hp_label()

	print("Singijeon impact at ", projectile_end)
	print("Enemy takes ", DAMAGE_PER_HIT, " damage. Remaining HP: ", enemy_hp)


func _update_explosion(delta: float) -> void:
	explosion_time += delta
	var progress: float = clampf(explosion_time / EXPLOSION_DURATION, 0.0, 1.0)
	explosion.scale = explosion_base_scale * lerpf(1.0, 1.4, progress)
	explosion.modulate = Color(1.0, 1.0, 1.0, lerpf(1.0, 0.0, progress))

	if explosion_time >= EXPLOSION_DURATION:
		explosion_active = false
		explosion.stop()
		explosion.visible = false


func _update_camera_shake(delta: float) -> void:
	if shake_time > 0.0:
		shake_time = max(shake_time - delta, 0.0)
		main_camera.offset = Vector2(
			rng.randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH),
			rng.randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH)
		)
	else:
		main_camera.offset = main_camera.offset.lerp(Vector2.ZERO, minf(delta * 20.0, 1.0))


func _update_enemy_hp_label() -> void:
	enemy_hp_label.text = "Enemy HP: %d / %d" % [enemy_hp, ENEMY_MAX_HP]
