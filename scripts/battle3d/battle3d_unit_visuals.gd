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
const HORSE := "res://assets/battle3d/horse/warhorse.glb"
const RIDER_LIBRARY := "res://assets/battle3d/base_soldier/anim_cavalry_rider.glb" # AnimationLibrary (sit_cavalry, cav_thrust, ...)
const SPEAR_Q := Quaternion(0.3704, 0.9157, -0.0862, 0.1294) # weapons README v3, on WeaponSocket_R (one hand, fixed)
const BOW_Q := Quaternion(0.0973, 0.7935, 0.6005, -0.0160) # on WeaponSocket_L
const QUIVER_BONE := "mixamorig_Spine2"
const QUIVER_POSITION := Vector3(-0.030, -0.020, -0.145)
const QUIVER_Q := Quaternion(-0.0846, -0.0211, 0.2410, 0.9666)
const MUSKET_Q := { # on WeaponSocket_R, per animation
	"idle": Quaternion(0.4956, 0.3527, 0.1508, 0.7793), "idle_alt": Quaternion(0.4956, 0.3527, 0.1508, 0.7793),
	"walk": Quaternion(0.5600, 0.3742, 0.2963, 0.6772), "run": Quaternion(-0.0931, -0.3625, 0.4307, 0.8212),
	"attack_gun": Quaternion(0.7749, -0.2058, 0.5645, 0.1962)}
const MUSKET_SLERP := 0.1 # s, between animations (the attack takes its value at once)
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

var materials: Dictionary = {} # GLB material -> its shared matte copy (roughness 1, metallic 0, specular 0)
var fx: Node3D = null # the ranged effects node (one, under the lab root), made at the first ranged unit
var _attack_left: Dictionary = {} # soldier instance id -> seconds left in the attack animation
var _moving: Dictionary = {} # unit id -> last moving state sent to its soldiers
var _muskets: Dictionary = {} # soldier instance id -> {node, from, to, t}

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
				out.append(horseman)
		return out
	for row in 3:
		for col in 3:
			var soldier := _soldier(side, kind)
			root.add_child(soldier)
			soldier.position = Vector3((col - 1) * SPACING, 0, (row - 1) * SPACING)
			out.append(soldier)
	return out

func _soldier(side: String, kind: String) -> Node3D:
	var soldier: Node3D = (load(SOLDIER[side]) as PackedScene).instantiate()
	soldier.scale = Vector3.ONE * SCALE
	soldier.set_meta("unit3d_kind", kind)
	_add_library(player_of(soldier), SPEAR_SHORT_LIBRARY)
	var socket_r: Node3D = soldier.find_child("WeaponSocket_R", true, false)
	match kind:
		"infantry":
			_weapon(SPEAR[side], socket_r, SPEAR_Q)
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
	player.seek(randf() * player.current_animation_length, true)
	player.speed_scale = randf_range(.92, 1.08) * ANIM_SPEED
	_musket_to(player.get_parent(), anim, false)

## The gunner's musket follows the animation: 0.1 s slerp, or at once for the attack (D / B test scenes).
func _musket_to(soldier: Node, anim: String, snap: bool) -> void:
	var key: int = soldier.get_instance_id()
	if not _muskets.has(key) or not MUSKET_Q.has(anim): return
	var m: Dictionary = _muskets[key]
	m.from = (m.node as Node3D).quaternion
	m.to = MUSKET_Q[anim]
	m.t = 1.0 if snap else 0.0
	if snap: (m.node as Node3D).quaternion = m.to

## How many of the unit's n soldiers are shown: the lab's density rule with n in place of 6.
func visible_count(value: Dictionary, n: int) -> int:
	return clampi(ceili(float(n) * float(value.current_troops) / maxf(1.0, float(value.max_troops))), 0, n)

## Per frame: run while the unit's move is being played back, idle otherwise; attacks return to the loop.
func update(lab: Node, delta: float) -> void:
	for m in _muskets.values():
		if m.t < 1.0 and is_instance_valid(m.node):
			m.t = minf(1.0, m.t + delta / MUSKET_SLERP)
			(m.node as Node3D).quaternion = (m.from as Quaternion).slerp(m.to, m.t)
	for id in lab.soldiers:
		var root: Node3D = lab.views[id]
		if not root.has_meta("unit3d"): continue
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
			else: _loop(player_of(soldier), "run" if moving else "idle")

## The attacker's soldiers play their basic attack once (engine attack_resolved / enemy_attack_resolved). Archers and
## gunners shoot target_id's shown soldiers through the effects script (soldier i -> target soldier i % count).
func attack(lab: Node, attacker_id: String, target_id: String) -> void:
	if not lab.views.has(attacker_id) or not lab.views[attacker_id].has_meta("unit3d"): return
	var shooters: Array = []
	for soldier in lab.soldiers[attacker_id]:
		var kind: String = soldier.get_meta("unit3d_kind")
		if kind in RANGED:
			if soldier.visible: shooters.append(soldier)
			continue
		var player := attack_player_of(soldier)
		player.play(ATTACK[kind][0])
		player.seek(0.0, true)
		player.speed_scale = ATTACK[kind][1]
		_attack_left[soldier.get_instance_id()] = player.current_animation_length / ATTACK[kind][1]
	if shooters.is_empty() or fx == null or not lab.soldiers.has(target_id): return
	var shown: Array = lab.soldiers[target_id].filter(func(s): return s.visible)
	if shown.is_empty(): shown = lab.soldiers[target_id]
	var targets: Array = []
	for i in shooters.size(): targets.append(shown[i % shown.size()])
	if shooters[0].get_meta("unit3d_kind") == "archer": fx.fire_arrow_volley(shooters, targets)
	else: fx.fire_gun_volley(shooters, targets)

## The effects script started a soldier's attack: hold the loop until it ends; the musket takes the attack value now.
func _on_ranged_started(soldier: Node3D, anim: String) -> void:
	_attack_left[soldier.get_instance_id()] = (player_of(soldier).current_animation_length / ATTACK[soldier.get_meta("unit3d_kind")][1]) + 0.05
	_musket_to(soldier, anim, true)
