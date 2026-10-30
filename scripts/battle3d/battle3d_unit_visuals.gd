extends RefCounted
# Unit3D lab connection: the new rigged soldiers (700 tris, Mixamo animations) for the 3D lab, as a separate
# presentation layer. Used only when the lab's `unit3d_models` switch is on (lab_presentation.gd); with it off,
# nothing here is loaded. Assembly and animation values come from the Unit3D test scenes (tests/scripts/unit3d_*.gd).
# Units: infantry, archer, gunner 9 (3 x 3, 0.65 apart); cavalry 6 (3 rows 0.9 apart x 2 files 1.3 apart, warhorse +
# rider). Archers and gunners shoot with battle3d_ranged_fx.gd. Units of other types keep the old models.

const RangedFx := preload("res://scripts/battle3d/battle3d_ranged_fx.gd")
const SOLDIER := {"ally": "res://assets/battle3d/base_soldier/soldier_anims_korea_blue.glb", "enemy": "res://assets/battle3d/base_soldier/soldier_anims_korea_red_test.glb"}
const SPEAR := {"ally": "res://assets/battle3d/weapons/weapon_spear_blue.glb", "enemy": "res://assets/battle3d/weapons/weapon_spear_red.glb"}
const BOW := {"ally": "res://assets/battle3d/weapons/weapon_bow_blue.glb", "enemy": "res://assets/battle3d/weapons/weapon_bow_red.glb"}
const QUIVER := {"ally": "res://assets/battle3d/weapons/weapon_quiver_blue.glb", "enemy": "res://assets/battle3d/weapons/weapon_quiver_red.glb"}
const MUSKET := "res://assets/battle3d/weapons/weapon_musket.glb"
const SPEAR_SHORT_LIBRARY := "res://assets/battle3d/base_soldier/anim_attack_spear_short.glb" # AnimationLibrary (attack_spear_short)
const RUN_CARRY_LIBRARY := "res://assets/battle3d/base_soldier/anim_run_carry_v2.glb" # AnimationLibrary (run_carry, looped by its import)
const CARRY := ["infantry", "gunner"] # these run with run_carry (weapon raised); the others run with run
const HORSE := "res://assets/battle3d/horse/warhorse.glb"
const RIDER_LIBRARY := "res://assets/battle3d/base_soldier/anim_cavalry_rider.glb" # AnimationLibrary (sit_cavalry, cav_thrust, ...)
const SPEAR_Q := Quaternion(0.3704, 0.9157, -0.0862, 0.1294) # weapons README v3, on WeaponSocket_R (one hand)
const SPEAR_RUN_Q  := Quaternion(0.7762, 0.0214, -0.3109, 0.5481)  # WeaponSocket_R, position (0,0,0)
const MUSKET_RUN_Q := Quaternion(0.7687, 0.4027, 0.3290, 0.3724)   # WeaponSocket_R, position (0,0,0)
const BOW_Q := Quaternion(0.0973, 0.7935, 0.6005, -0.0160) # on WeaponSocket_L
const QUIVER_BONE := "mixamorig_Spine2"
const QUIVER_POSITION := Vector3(-0.030, -0.020, -0.145)
const QUIVER_Q := Quaternion(-0.0846, -0.0211, 0.2410, 0.9666)
const MUSKET_Q := { # on WeaponSocket_R, per animation
	"idle": Quaternion(0.4956, 0.3527, 0.1508, 0.7793), "idle_alt": Quaternion(0.4956, 0.3527, 0.1508, 0.7793),
	"walk": Quaternion(0.5600, 0.3742, 0.2963, 0.6772), "run": Quaternion(-0.0931, -0.3625, 0.4307, 0.8212),
	"attack_gun": Quaternion(0.7749, -0.2058, 0.5645, 0.1962), "run_carry": MUSKET_RUN_Q}
const MUSKET_SLERP := 0.1 # s, between animations (the attack takes its value at once); the spear too
const CAVALRY_SPEAR_Q := Quaternion(0.3114, 0.9195, 0.1201, 0.2078) # handoff README, on the rider's WeaponSocket_R, held at +Y 0.20
const CAVALRY_SPEAR_GRIP := Vector3(0, -0.20, 0)
const RIDER_OFFSET := Vector3(0, -0.358, 0) # rider root under the horse's Saddle, no rotation
const SCALE := 1.2 # soldier (and horse) size: the old models stand about 1.2 high, the new soldier 1.0 (final value: 김작)
const ANIM_SPEED := 1.0 # run / idle playback multiplier for soldiers and horses (the lab moves units at presentation_speed 8.0)
const SPACING := 0.65 # foot units, 3 x 3
const CAVALRY_ROWS := [-0.9, 0.0, 0.9] # z
const CAVALRY_FILES := [-0.65, 0.65] # x (1.3 apart)
const ATTACK := {"infantry": ["attack_spear_short", 2.17], "cavalry": ["cav_thrust", 2.17], "archer": ["attack_bow", 1.0], "gunner": ["attack_gun", 1.0]} # animation, speed_scale
const RANGED := ["archer", "gunner"] # their attack is started by the effects script, soldier by soldier
const HIT_PUSH := 0.15 # m: a hit pushes the target's shown soldiers this far away from the attacker, then back
const HIT_OUT := 0.06 # s, pushed out
const HIT_BACK := 0.14 # s, back home
const HIT_STAGGER := 0.05 # s: each soldier starts 0..this after the hit
const SINK_TIME := 0.3 # s: a soldier the troop count no longer shows sinks into the ground, then hides
const SINK_DEPTH := 1.2 # m, used when no model height can be read (1.0 m soldier x SCALE); else the height + SINK_EXTRA
const SINK_EXTRA := 0.05 # m below the read height, so nothing stays above the ground
const TURN_RATE := 14.0 # 1/s: soldiers turn toward the unit's target yaw by 1 - exp(-TURN_RATE * delta) a frame
const FACING_YAW := {"up": 0.0, "down": PI, "left": PI / 2, "right": -PI / 2} # the lab's table (_sync_views), old-model yaw

var materials: Dictionary = {} # GLB material -> its shared matte copy (roughness 1, metallic 0, specular 0)
var fx: Node3D = null # the ranged effects node (one, under the lab root), made at the first ranged unit
var _attack_left: Dictionary = {} # soldier instance id -> seconds left in the attack animation
var _moving: Dictionary = {} # unit id -> last moving state sent to its soldiers
var _muskets: Dictionary = {} # soldier instance id -> {node, from, to, t}
var _spears: Dictionary = {} # spearman instance id -> {node, from, to, t}
var _rng := RandomNumberGenerator.new() # own stream: the engine judges with the global one, which this never touches
var _home: Dictionary = {} # soldier instance id -> its spawn position under the unit root
var _hits: Dictionary = {} # soldier instance id -> {soldier, dir (unit-root local, HIT_PUSH long), t (s; < 0: stagger left)}
var _sinks: Dictionary = {} # soldier instance id -> {soldier, t (s), depth (m)}
var _seen: Dictionary = {} # soldier instance id -> true once the lab has set its visibility (the first set never sinks)
var _heights: Dictionary = {} # kind -> model height above its root (m), read at the first sink
var _yaw_target: Dictionary = {} # unit id -> the yaw its soldiers turn to (kept while a move has no length left)
var _yaw_ready: Dictionary = {} # soldier instance id -> true once it has a yaw (the first one is set, not turned to)

func _init() -> void:
	_rng.randomize()

## True when this layer has a model for the unit (by its type before the lab's infantry/cavalry mapping).
func handles(u: Dictionary) -> bool:
	return kind_of(u) in ATTACK

func kind_of(u: Dictionary) -> String:
	return String(u.get("source_unit_type", u.unit_type))

## Builds the unit's soldiers under root and returns them (one node per soldier, or per horse + rider, as
## lab.soldiers[id] expects).
func spawn_soldiers(u: Dictionary, root: Node3D) -> Array:
	var kind := kind_of(u)
	var side := "ally" if u.side == "ally" else "enemy"
	var out: Array = []
	if kind in RANGED and fx == null:
		fx = RangedFx.new()
		fx.name = "RangedFx"
		root.get_parent().add_child(fx) # the lab root; effects go under its Effects child
		fx.attack_started.connect(_on_ranged_started)
	if kind == "cavalry":
		for z in CAVALRY_ROWS:
			for x in CAVALRY_FILES:
				var horseman := _horseman(side)
				root.add_child(horseman)
				horseman.position = Vector3(x, 0, z)
				_home[horseman.get_instance_id()] = horseman.position
				out.append(horseman)
		return out
	for row in 3:
		for col in 3:
			var soldier := _soldier(side, kind)
			root.add_child(soldier)
			soldier.position = Vector3((col - 1) * SPACING, 0, (row - 1) * SPACING)
			_home[soldier.get_instance_id()] = soldier.position
			out.append(soldier)
	return out

func _soldier(side: String, kind: String) -> Node3D:
	var soldier: Node3D = (load(SOLDIER[side]) as PackedScene).instantiate()
	soldier.scale = Vector3.ONE * SCALE
	soldier.set_meta("unit3d_kind", kind)
	_add_library(player_of(soldier), SPEAR_SHORT_LIBRARY)
	if kind in CARRY: _add_library(player_of(soldier), RUN_CARRY_LIBRARY)
	var socket_r: Node3D = soldier.find_child("WeaponSocket_R", true, false)
	match kind:
		"infantry":
			var spear := _weapon(SPEAR[side], socket_r, SPEAR_Q)
			_spears[soldier.get_instance_id()] = {"node": spear, "from": SPEAR_Q, "to": SPEAR_Q, "t": 1.0}
		"archer":
			_weapon(BOW[side], soldier.find_child("WeaponSocket_L", true, false), BOW_Q)
			var back := BoneAttachment3D.new()
			back.name = "QuiverAttachment"
			soldier.find_child("Skeleton3D", true, false).add_child(back)
			back.bone_name = QUIVER_BONE
			var quiver := _weapon(QUIVER[side], back, QUIVER_Q)
			quiver.position = QUIVER_POSITION
		"gunner":
			var musket := _weapon(MUSKET, socket_r, MUSKET_Q.idle)
			_muskets[soldier.get_instance_id()] = {"node": musket, "from": MUSKET_Q.idle, "to": MUSKET_Q.idle, "t": 1.0}
	_matte(soldier)
	_loop(player_of(soldier), "idle")
	return soldier

func _weapon(path: String, parent: Node, rotation: Quaternion) -> Node3D:
	var weapon: Node3D = (load(path) as PackedScene).instantiate()
	parent.add_child(weapon)
	weapon.quaternion = rotation
	return weapon

## One cavalryman: the warhorse with the rider under its Saddle. The horse root is the node in lab.soldiers[id].
func _horseman(side: String) -> Node3D:
	var horse: Node3D = (load(HORSE) as PackedScene).instantiate()
	horse.scale = Vector3.ONE * SCALE
	horse.set_meta("unit3d_kind", "cavalry")
	var rider: Node3D = (load(SOLDIER[side]) as PackedScene).instantiate()
	rider.name = "Rider"
	(horse.find_child("Saddle", true, false) as Node3D).add_child(rider)
	rider.position = RIDER_OFFSET
	var spear: Node3D = (load(SPEAR[side]) as PackedScene).instantiate()
	(rider.find_child("WeaponSocket_R", true, false) as Node3D).add_child(spear)
	spear.transform = Transform3D(Basis(CAVALRY_SPEAR_Q), CAVALRY_SPEAR_Q * CAVALRY_SPEAR_GRIP)
	var rider_player := player_of(rider)
	_add_library(rider_player, RIDER_LIBRARY)
	# the rider plays rider animations only; deterministic so its untracked bones (Hips, toes) stay at rest
	rider_player.deterministic = true
	horse.set_meta("unit3d_rider", rider)
	_matte(horse)
	_loop(player_of(horse), "idle")
	_loop(rider_player, "sit_cavalry")
	return horse

func _add_library(player: AnimationPlayer, path: String) -> void:
	var own := player.get_animation_library(&"")
	var library: AnimationLibrary = load(path)
	for a in library.get_animation_list():
		if not own.has_animation(a): own.add_animation(a, library.get_animation(a))

## A GLB root's own AnimationPlayer: its direct child (never find_child: a horse also holds the rider's).
func player_of(node: Node) -> AnimationPlayer:
	return node.get_node("AnimationPlayer") as AnimationPlayer

## The player that plays the attack: the soldier's own, or the rider's for a horseman.
func attack_player_of(node: Node) -> AnimationPlayer:
	return player_of(node.get_meta("unit3d_rider")) if node.has_meta("unit3d_rider") else player_of(node)

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

func _loop(player: AnimationPlayer, anim: String) -> void:
	player.play(anim)
	player.seek(_rng.randf() * player.current_animation_length, true)
	player.speed_scale = _rng.randf_range(.92, 1.08) * ANIM_SPEED
	_musket_to(player.get_parent(), anim, false)
	_spear_to(player.get_parent(), anim, false)

## The gunner's musket follows the animation: 0.1 s slerp, or at once for the attack (D / B test scenes).
func _musket_to(soldier: Node, anim: String, snap: bool) -> void:
	var key: int = soldier.get_instance_id()
	if not _muskets.has(key) or not MUSKET_Q.has(anim): return
	var m: Dictionary = _muskets[key]
	m.from = (m.node as Node3D).quaternion
	m.to = MUSKET_Q[anim]
	m.t = 1.0 if snap else 0.0
	if snap: (m.node as Node3D).quaternion = m.to

## The spearman's spear, as the musket: SPEAR_RUN_Q in run_carry, SPEAR_Q in anything else (at once for the attack).
func _spear_to(soldier: Node, anim: String, snap: bool) -> void:
	var key: int = soldier.get_instance_id()
	if not _spears.has(key): return
	var m: Dictionary = _spears[key]
	m.from = (m.node as Node3D).quaternion
	m.to = SPEAR_RUN_Q if anim == "run_carry" else SPEAR_Q
	m.t = 1.0 if snap else 0.0
	if snap: (m.node as Node3D).quaternion = m.to

## How many of the unit's n soldiers are shown: the lab's density rule with n in place of 6.
func visible_count(value: Dictionary, n: int) -> int:
	return clampi(ceili(float(n) * float(value.current_troops) / maxf(1.0, float(value.max_troops))), 0, n)

## Per frame: run (run_carry for CARRY) while the unit's move is being played back, idle otherwise; attacks return to
## the loop.
func update(lab: Node, delta: float) -> void:
	for m in _muskets.values() + _spears.values():
		if m.t < 1.0 and is_instance_valid(m.node):
			m.t = minf(1.0, m.t + delta / MUSKET_SLERP)
			(m.node as Node3D).quaternion = (m.from as Quaternion).slerp(m.to, m.t)
	for key in _hits.keys(): # x / z only: the lab sets the unit root and the soldiers' height, never their x / z
		var h: Dictionary = _hits[key]
		if not is_instance_valid(h.soldier):
			_hits.erase(key)
			continue
		h.t += delta
		var k := 0.0
		if h.t >= HIT_OUT + HIT_BACK: _hits.erase(key)
		elif h.t > HIT_OUT: k = 1.0 - (h.t - HIT_OUT) / HIT_BACK
		elif h.t > 0.0: k = h.t / HIT_OUT
		var home: Vector3 = _home[key]
		h.soldier.position.x = home.x + h.dir.x * k
		h.soldier.position.z = home.z + h.dir.z * k
	for key in _sinks.keys():
		if is_instance_valid(_sinks[key].soldier): _sinks[key].t += delta
		else: _sinks.erase(key)
	for id in lab.soldiers:
		var root: Node3D = lab.views[id]
		if not root.has_meta("unit3d"): continue
		var yaw := _target_yaw(lab, id, root)
		var turn := 1.0 - exp(-TURN_RATE * delta)
		for soldier in lab.soldiers[id]: # rotation only: position, visibility and animation stay as they are
			if _yaw_ready.has(soldier.get_instance_id()): soldier.rotation.y = lerp_angle(soldier.rotation.y, yaw, turn)
			else:
				soldier.rotation.y = yaw
				_yaw_ready[soldier.get_instance_id()] = true
		var moving: bool = lab.playback.has(id)
		var unit_changed: bool = _moving.get(id, false) != moving
		_moving[id] = moving
		for soldier in lab.soldiers[id]:
			var horseman: bool = soldier.has_meta("unit3d_rider")
			if horseman and unit_changed: _loop(player_of(soldier), "run" if moving else "idle") # the horse moves; the rider sits
			var key: int = soldier.get_instance_id()
			var restart := unit_changed and not horseman
			if _attack_left.has(key):
				_attack_left[key] -= delta
				if _attack_left[key] > 0.0: continue
				_attack_left.erase(key)
				restart = true
			if not restart: continue
			if horseman: _loop(attack_player_of(soldier), "sit_cavalry")
			elif not moving: _loop(player_of(soldier), "idle")
			else: _loop(player_of(soldier), "run_carry" if soldier.get_meta("unit3d_kind") in CARRY else "run")

## The attacker's soldiers play their basic attack once (engine attack_resolved / enemy_attack_resolved). Archers and
## gunners shoot target_id's shown soldiers through the effects script (soldier i -> target soldier i % count).
func attack(lab: Node, attacker_id: String, target_id: String) -> void:
	if not lab.views.has(attacker_id) or not lab.views[attacker_id].has_meta("unit3d"): return
	var shooters: Array = []
	for soldier in lab.soldiers[attacker_id]:
		var kind: String = soldier.get_meta("unit3d_kind")
		if kind in RANGED:
			if soldier.visible and not _sinks.has(soldier.get_instance_id()): shooters.append(soldier)
			continue
		var player := attack_player_of(soldier)
		player.play(ATTACK[kind][0])
		player.seek(0.0, true)
		player.speed_scale = ATTACK[kind][1]
		_spear_to(soldier, ATTACK[kind][0], true)
		_attack_left[soldier.get_instance_id()] = player.current_animation_length / ATTACK[kind][1]
	if shooters.is_empty() or fx == null or not lab.soldiers.has(target_id): return
	var shown: Array = lab.soldiers[target_id].filter(func(s): return s.visible and not _sinks.has(s.get_instance_id()))
	if shown.is_empty(): shown = lab.soldiers[target_id]
	var targets: Array = []
	for i in shooters.size(): targets.append(shown[i % shown.size()])
	if shooters[0].get_meta("unit3d_kind") == "archer": fx.fire_arrow_volley(shooters, targets)
	else: fx.fire_gun_volley(shooters, targets)

## The effects script started a soldier's attack: hold the loop until it ends; the musket takes the attack value now.
func _on_ranged_started(soldier: Node3D, anim: String) -> void:
	_attack_left[soldier.get_instance_id()] = (player_of(soldier).current_animation_length / ATTACK[soldier.get_meta("unit3d_kind")][1]) + 0.05
	_musket_to(soldier, anim, true)

## The target's shown soldiers are pushed HIT_PUSH away from the attacker and come back (engine attack_resolved /
## enemy_attack_resolved, next to attack). A unit whose move is being played back is left where it is.
func hit(lab: Node, attacker_id: String, target_id: String) -> void:
	if not lab.views.has(target_id) or not lab.views[target_id].has_meta("unit3d") or not lab.views.has(attacker_id): return
	if lab.playback.has(target_id): return
	var root: Node3D = lab.views[target_id]
	var away: Vector3 = root.global_position - (lab.views[attacker_id] as Node3D).global_position
	away.y = 0.0
	if away.length() < .001: return
	var dir: Vector3 = root.global_transform.basis.inverse() * (away.normalized() * HIT_PUSH)
	for soldier in lab.soldiers[target_id]:
		var key: int = soldier.get_instance_id()
		if soldier.visible and not _sinks.has(key): _hits[key] = {"soldier": soldier, "dir": dir, "t": -_rng.randf_range(0.0, HIT_STAGGER)}

## The lab's per-frame visibility for a new-model soldier (want = index < shown), after it grounded the soldier. One the
## count drops sinks SINK_TIME into the ground (still visible), then hides at its own height; one the count brings back
## shows at once. The first set (spawn) never sinks. visible_count is not involved: the shown count stays the lab's.
func show_soldier(soldier: Node3D, want: bool) -> void:
	var key: int = soldier.get_instance_id()
	if want or not _seen.has(key):
		_seen[key] = true
		_sinks.erase(key)
		soldier.visible = want
		return
	if not _sinks.has(key):
		if not soldier.visible: return
		_sinks[key] = {"soldier": soldier, "t": 0.0, "depth": _sink_depth(soldier)}
	var sink: Dictionary = _sinks[key]
	if sink.t >= SINK_TIME:
		_sinks.erase(key)
		soldier.visible = false # its height: the lab grounded it again this frame
		return
	soldier.position.y -= sink.depth * sink.t / SINK_TIME

func _sink_depth(soldier: Node3D) -> float:
	var kind: String = soldier.get_meta("unit3d_kind")
	if not _heights.has(kind):
		var top := 0.0 # the highest mesh point above the root (rest-pose boxes, weapons included)
		for mesh in soldier.find_children("*", "MeshInstance3D", true, false):
			top = maxf(top, ((mesh as MeshInstance3D).global_transform * (mesh as MeshInstance3D).get_aabb()).end.y - soldier.global_position.y)
		_heights[kind] = top
	return _heights[kind] + SINK_EXTRA if _heights[kind] > 0.0 else SINK_DEPTH

## The yaw a unit's soldiers turn to (the new models look along +Z, so + PI on the lab's yaw): while the lab plays
## its move back, the travel toward the path's next cell (atan2(-dx, -dz), as lab_presentation's mock move); else the
## engine's facing. A move with under 0.01 m left keeps the last target.
func _target_yaw(lab: Node, id: String, root: Node3D) -> float:
	if lab.playback.has(id):
		var motion: Dictionary = lab.playback[id]
		var goal: Vector3 = lab.board.world(motion.path[motion.index])
		var travel := Vector2(goal.x - root.position.x, goal.z - root.position.z)
		if travel.length() >= .01: _yaw_target[id] = atan2(-travel.x, -travel.y) + PI
	elif lab.display_values.has(id):
		_yaw_target[id] = FACING_YAW.get(lab.display_values[id].facing, 0.0) + PI
	return _yaw_target.get(id, PI)
