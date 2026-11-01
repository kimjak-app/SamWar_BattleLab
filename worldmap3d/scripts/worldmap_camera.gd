## EASTWAR WorldMap3D v3 — strategy camera. Limits come from the map config (`camera` block): v3 near limit
## defaults to 120 km (v2: 70 km) so the textures are never magnified past what they hold.
## zoom 0 = far (whole peninsula, near top-down), zoom 1 = near (low oblique like Shinsei).
## Mouse wheel = zoom (smooth; height, pitch and FOV follow one curve); drags per input scheme (v2.2, below),
## WASD/arrows = pan. Target is clamped to `pan_bounds` (world km).
## v2.1 (EA): `fill_clamp` — zoom-out and pan are limited so the ground footprint of the WHOLE screen (all 4 corners
## and edge midpoints, at the current yaw/pitch/FOV/aspect) always stays inside the map rectangle: the screen is
## always filled with map at every zoom, pan and rotation. Rays that would go past `clamp_horizon_mul` x distance
## (oblique near views looking at the horizon) are capped there; beyond it the fog + edge mist take over.
## v2.2 input schemes (map_config camera.input_scheme "A" | "B", runtime set_input_scheme / toggle_input_scheme):
##   common: left click = select (signal select_requested), wheel = zoom, WASD/arrows = pan, Q/E = rotate (free rotation)
##   A: middle drag = pan, right drag = rotate        B: middle drag = pan, right drag = pan (rotate only with Q/E)
## external_input_block = true (or a focused LineEdit/TextEdit) -> WASD/arrows/QE are ignored (mouse still works).
## fill_clamp stays active under any rotation.
class_name WorldMap3DCamera
extends Camera3D

@export var far_distance := 1300.0
@export var near_distance := 120.0
@export var far_pitch_deg := -84.0
@export var near_pitch_deg := -23.0
@export var far_fov := 38.0
@export var near_fov := 50.0
@export var zoom_step := 0.07
@export var smoothing := 7.0
@export var pan_bounds := Rect2(-260, -560, 560, 1090)

var target := Vector2.ZERO
var zoom := 0.0
var zoom_goal := 0.0
var yaw := 0.0
var yaw_goal := 0.0
var ground_height: Callable          # func(Vector2) -> float
var env_ref: Environment
var sun: DirectionalLight3D
var _ground_y := 0.0
var _drag := 0
var _target_goal := Vector2.ZERO
var fog_density_near := 0.8
var manual := false                 # tools: freeze input/smoothing (set_view still works)
var fill_clamp := false             # v2.1: keep the screen footprint inside the map rect (see header)
var map_half := Vector2(2775.0, 1850.0)
var clamp_margin_km := 0.0          # >0 keeps the screen edge this far inside the map edge
var clamp_horizon_mul := 3.0
var zoom_min := 0.0                 # current lower zoom limit (from fill_clamp), read-only for tools
var input_scheme := "A"             # v2.2: "A" | "B" (see header)
var external_input_block := false   # v2.2: set true while a UI text field has focus (also auto-detected)
var _click_from := Vector2.ZERO
signal select_requested(screen_pos: Vector2)
signal input_scheme_changed(scheme: String)

func configure(c: WorldMapConfig) -> void:
	far_distance = float(c.cam("far_distance_km", far_distance))
	near_distance = float(c.cam("near_distance_km", near_distance))
	far_pitch_deg = float(c.cam("far_pitch_deg", far_pitch_deg))
	near_pitch_deg = float(c.cam("near_pitch_deg", near_pitch_deg))
	far_fov = float(c.cam("far_fov", far_fov))
	near_fov = float(c.cam("near_fov", near_fov))
	fog_density_near = float(c.cam("fog_density_near", fog_density_near))
	var pb = c.cam("pan_bounds_km", null)
	if pb != null:
		pan_bounds = Rect2(pb[0], pb[1], pb[2], pb[3])
	fill_clamp = bool(c.cam("fill_screen_clamp", false))
	clamp_margin_km = float(c.cam("clamp_margin_km", 0.0))
	clamp_horizon_mul = float(c.cam("clamp_horizon_mul", 3.0))
	map_half = c.size_km * 0.5
	set_input_scheme(String(c.cam("input_scheme", "A")))

func set_input_scheme(s: String) -> void:
	input_scheme = "B" if s.to_upper() == "B" else "A"
	_drag = 0
	input_scheme_changed.emit(input_scheme)

func toggle_input_scheme() -> void:
	set_input_scheme("A" if input_scheme == "B" else "B")

func input_scheme_text() -> String:
	if input_scheme == "B":
		return "입력 B: Q/E 회전 · 가운데/오른쪽 드래그 이동 · 휠 줌 · WASD 이동 · 좌클릭 선택"
	return "입력 A: Q/E·오른쪽 드래그 회전 · 가운데 드래그 이동 · 휠 줌 · WASD 이동 · 좌클릭 선택"

func keys_blocked() -> bool:
	if external_input_block:
		return true
	if is_inside_tree():
		var f := get_viewport().gui_get_focus_owner()
		if f is LineEdit or f is TextEdit:
			return true
	return false

## ground footprint (sea-level plane) of 8 screen points, relative to the camera target, for zoom z / yaw yw.
func footprint(z: float, yw: float, aspect: float) -> PackedVector2Array:
	var t := smoothstep(0.2, 1.0, z)
	var pitch := deg_to_rad(lerpf(far_pitch_deg, near_pitch_deg, t))
	var fv := lerpf(far_fov, near_fov, t)
	var dist := far_distance * pow(near_distance / far_distance, z)
	var off := (Vector3(0, sin(-pitch), cos(pitch)) * dist).rotated(Vector3.UP, yw)
	var cam := off + Vector3(0, _ground_y * t, 0)
	var fwd := -off.normalized()
	var right := fwd.cross(Vector3.UP).normalized()
	var up := right.cross(fwd)
	var th := tan(deg_to_rad(fv) * 0.5)
	var tw := th * aspect
	var cap := dist * clamp_horizon_mul
	var out := PackedVector2Array()
	for uv: Vector2 in [Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0)]:
		var d := (fwd + right * uv.x * tw + up * uv.y * th).normalized()
		var s := cap
		if d.y < -1e-5:
			s = minf(cam.y / -d.y, cap)
		var p := cam + d * s
		out.append(Vector2(p.x, p.z))
	return out

func _fp_fits(z: float, yw: float, aspect: float, half: Vector2) -> bool:
	var fp := footprint(z, yw, aspect)
	var mn := fp[0]; var mx := fp[0]
	for q in fp:
		mn = mn.min(q); mx = mx.max(q)
	return (mx.x - mn.x) <= 2.0 * half.x and (mx.y - mn.y) <= 2.0 * half.y

## clamp a target so the footprint stays inside the map; returns the clamped target
func _clamp_target(tg: Vector2, z: float, yw: float, aspect: float, half: Vector2) -> Vector2:
	var fp := footprint(z, yw, aspect)
	var mn := fp[0]; var mx := fp[0]
	for q in fp:
		mn = mn.min(q); mx = mx.max(q)
	var lo := -half - mn
	var hi := half - mx
	var r := tg
	r.x = (lo.x + hi.x) * 0.5 if lo.x > hi.x else clampf(r.x, lo.x, hi.x)
	r.y = (lo.y + hi.y) * 0.5 if lo.y > hi.y else clampf(r.y, lo.y, hi.y)
	return r

func _update_fill_clamp() -> void:
	var vs := get_viewport().get_visible_rect().size if is_inside_tree() else Vector2(1920, 1080)
	var aspect := vs.x / maxf(vs.y, 1.0)
	var half := map_half - Vector2(clamp_margin_km, clamp_margin_km)
	if _fp_fits(0.0, yaw, aspect, half):
		zoom_min = 0.0
	else:
		var a := 0.0; var b := 1.0
		for i in 22:
			var m := (a + b) * 0.5
			if _fp_fits(m, yaw, aspect, half): b = m
			else: a = m
		zoom_min = b
	zoom = maxf(zoom, zoom_min)
	zoom_goal = maxf(zoom_goal, zoom_min)
	target = _clamp_target(target, zoom, yaw, aspect, half)
	_target_goal = _clamp_target(_target_goal, maxf(zoom_goal, zoom_min), yaw, aspect, half)

func set_view(xz: Vector2, z: float, yaw_deg := 0.0, immediate := true) -> void:
	_target_goal = xz
	zoom_goal = clampf(z, 0.0, 1.0)
	yaw_goal = deg_to_rad(yaw_deg)
	if immediate:
		target = xz
		zoom = zoom_goal
		yaw = yaw_goal
		if ground_height.is_valid():
			_ground_y = ground_height.call(target)
	_apply()

func current_distance() -> float:
	return far_distance * pow(near_distance / far_distance, zoom)

func _unhandled_input(e: InputEvent) -> void:
	if manual:
		return
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP and e.pressed:
			zoom_goal = clampf(zoom_goal + zoom_step, 0.0, 1.0)
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed:
			zoom_goal = clampf(zoom_goal - zoom_step, 0.0, 1.0)
		elif e.button_index == MOUSE_BUTTON_LEFT:
			# v2.2: left = select (a click, not a drag)
			if e.pressed:
				_click_from = e.position
			elif e.position.distance_to(_click_from) < 6.0:
				select_requested.emit(e.position)
		elif e.button_index == MOUSE_BUTTON_MIDDLE:
			_drag = 1 if e.pressed else 0
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			_drag = (2 if input_scheme == "A" else 1) if e.pressed else 0
	elif e is InputEventMouseMotion and _drag != 0:
		if _drag == 1:
			var k := current_distance() * 2.0 * tan(deg_to_rad(fov) * 0.5) / get_viewport().get_visible_rect().size.y
			var d := Vector2(-e.relative.x, -e.relative.y / maxf(sin(-rotation.x), 0.35)) * k
			_target_goal += d.rotated(-yaw)
			target = _target_goal
		else:
			yaw_goal -= e.relative.x * 0.005

func _process(dt: float) -> void:
	if manual:
		return
	var pan := Vector2.ZERO
	if not keys_blocked():
		pan = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
		if Input.is_physical_key_pressed(KEY_A): pan.x -= 1
		if Input.is_physical_key_pressed(KEY_D): pan.x += 1
		if Input.is_physical_key_pressed(KEY_W): pan.y -= 1
		if Input.is_physical_key_pressed(KEY_S): pan.y += 1
		if Input.is_physical_key_pressed(KEY_Q): yaw_goal += dt * 1.2
		if Input.is_physical_key_pressed(KEY_E): yaw_goal -= dt * 1.2
	_target_goal += pan.rotated(-yaw) * current_distance() * 0.9 * dt
	var a := 1.0 - exp(-smoothing * dt)
	zoom = lerpf(zoom, zoom_goal, a)
	yaw = lerp_angle(yaw, yaw_goal, a)
	target = target.lerp(_target_goal, a)
	_apply(a)

func _apply(a := 1.0) -> void:
	if fill_clamp:
		_update_fill_clamp()
	else:
		target.x = clampf(target.x, pan_bounds.position.x, pan_bounds.end.x)
		target.y = clampf(target.y, pan_bounds.position.y, pan_bounds.end.y)
		_target_goal = _target_goal.clamp(pan_bounds.position, pan_bounds.end)
	var t := smoothstep(0.2, 1.0, zoom)
	var pitch := deg_to_rad(lerpf(far_pitch_deg, near_pitch_deg, t))
	fov = lerpf(far_fov, near_fov, t)
	var dist := current_distance()
	if ground_height.is_valid():
		_ground_y = lerpf(_ground_y, ground_height.call(target) * t, a)
	var focus := Vector3(target.x, _ground_y, target.y)
	var off := Vector3(0, sin(-pitch), cos(pitch)) * dist
	off = off.rotated(Vector3.UP, yaw)
	global_position = focus + off
	look_at(focus, Vector3.UP)
	near = clampf(dist * 0.004, 0.05, 4.0)
	far = 30000.0
	if env_ref:
		env_ref.fog_mode = Environment.FOG_MODE_DEPTH
		env_ref.fog_density = lerpf(0.0, fog_density_near, t)
		env_ref.fog_depth_begin = dist * 1.6
		env_ref.fog_depth_end = dist * 11.0
		env_ref.fog_depth_curve = 1.6
	if sun:
		sun.directional_shadow_max_distance = dist * 3.0
