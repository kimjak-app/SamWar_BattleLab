extends RefCounted
# Unit3D lab connection: the new rigged soldiers (700 tris, Mixamo animations) for the 3D lab, as a separate
# presentation layer. Used only when the lab's `unit3d_models` switch is on (lab_presentation.gd); with it off,
# nothing here is loaded. Assembly and animation values come from the Unit3D test scenes (tests/scripts/unit3d_*.gd).
# Units: infantry 9 (3 x 3, 0.65 apart). Units of other types keep the old models.

const SOLDIER := {"ally": "res://assets/battle3d/base_soldier/soldier_anims_korea_blue.glb", "enemy": "res://assets/battle3d/base_soldier/soldier_anims_korea_red_test.glb"}
const SPEAR := {"ally": "res://assets/battle3d/weapons/weapon_spear_blue.glb", "enemy": "res://assets/battle3d/weapons/weapon_spear_red.glb"}
const SPEAR_SHORT_LIBRARY := "res://assets/battle3d/base_soldier/anim_attack_spear_short.glb" # AnimationLibrary (attack_spear_short)
const SPEAR_Q := Quaternion(0.3704, 0.9157, -0.0862, 0.1294) # weapons README v3, on WeaponSocket_R (one hand, fixed)
const SCALE := 1.2 # soldier size: the old models stand about 1.2 high, the new soldier 1.0 (final value: 김작)
const ANIM_SPEED := 1.0 # run / idle playback multiplier (the lab moves units at presentation_speed 8.0)
const INFANTRY_COUNT := 9
const SPACING := 0.65
const ATTACK := {"infantry": ["attack_spear_short", 2.17]} # animation, speed_scale (0.46 s)
const LOOPING := ["idle", "run"]

var materials: Dictionary = {} # GLB material -> its shared matte copy (roughness 1, metallic 0, specular 0)
var _attack_left: Dictionary = {} # soldier instance id -> seconds left in the attack animation
var _moving: Dictionary = {} # unit id -> last moving state sent to its soldiers

## True when this layer has a model for the unit (by its type before the lab's infantry/cavalry mapping).
func handles(u: Dictionary) -> bool:
	return kind_of(u) in ATTACK

func kind_of(u: Dictionary) -> String:
	return String(u.get("source_unit_type", u.unit_type))

## Builds the unit's soldiers under root and returns them (one node per soldier, as lab.soldiers[id] expects).
func spawn_soldiers(u: Dictionary, root: Node3D) -> Array:
	var kind := kind_of(u)
	var side := "ally" if u.side == "ally" else "enemy"
	var out: Array = []
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
	var player := player_of(soldier)
	var own := player.get_animation_library(&"")
	if not own.has_animation(&"attack_spear_short"):
		own.add_animation(&"attack_spear_short", (load(SPEAR_SHORT_LIBRARY) as AnimationLibrary).get_animation(&"attack_spear_short"))
	if kind == "infantry":
		var spear: Node3D = (load(SPEAR[side]) as PackedScene).instantiate()
		(soldier.find_child("WeaponSocket_R", true, false) as Node3D).add_child(spear)
		spear.quaternion = SPEAR_Q
	_matte(soldier)
	_loop(player, "idle")
	return soldier

## The soldier's own AnimationPlayer: the GLB root's direct child (never find_child: a horse also holds a rider's).
func player_of(soldier: Node) -> AnimationPlayer:
	return soldier.get_node("AnimationPlayer") as AnimationPlayer

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

## How many of the unit's n soldiers are shown: the lab's density rule with n in place of 6.
func visible_count(value: Dictionary, n: int) -> int:
	return clampi(ceili(float(n) * float(value.current_troops) / maxf(1.0, float(value.max_troops))), 0, n)

## Per frame: run while the unit's move is being played back, idle otherwise; attacks return to the loop.
func update(lab: Node, delta: float) -> void:
	for id in lab.soldiers:
		var root: Node3D = lab.views[id]
		if not root.has_meta("unit3d"): continue
		var moving: bool = lab.playback.has(id)
		var unit_changed: bool = _moving.get(id, false) != moving
		_moving[id] = moving
		for soldier in lab.soldiers[id]:
			var key: int = soldier.get_instance_id()
			var restart := unit_changed
			if _attack_left.has(key):
				_attack_left[key] -= delta
				if _attack_left[key] > 0.0: continue
				_attack_left.erase(key)
				restart = true
			if restart: _loop(player_of(soldier), "run" if moving else "idle")

## The attacker's soldiers play their basic attack once (engine attack_resolved / enemy_attack_resolved).
func attack(lab: Node, attacker_id: String) -> void:
	if not lab.views.has(attacker_id) or not lab.views[attacker_id].has_meta("unit3d"): return
	for soldier in lab.soldiers[attacker_id]:
		var kind: String = soldier.get_meta("unit3d_kind")
		if not ATTACK.has(kind): continue
		var player := player_of(soldier)
		player.play(ATTACK[kind][0])
		player.seek(0.0, true)
		player.speed_scale = ATTACK[kind][1]
		_attack_left[soldier.get_instance_id()] = player.current_animation_length / ATTACK[kind][1]
