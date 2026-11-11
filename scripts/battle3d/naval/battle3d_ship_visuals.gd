extends RefCounted
# Queue 35: the ships of the naval 3D battle, as the lab's unit model layer (lab_presentation.gd `unit_visuals_script`).
# It answers the same calls as battle3d_unit_visuals.gd (handles, spawn_soldiers, visible_count, show_soldier, update,
# attack, hit), so the lab's code is unchanged: a unit is one ship (one "soldier" node in lab.soldiers[id]).
# - Model: the type rule's `model_path`, else assets/battle3d/naval/<unit_type>.glb, else a stand-in built here from
#   boxes (friendly stand-ins fly a blue flag, enemy ones a red one). A delivered model is fitted by its `Hull` node to
#   the type's ship_length (bow to -Z) and lowered so its `WaterLine` node lies on the sea.
# - A delivered model's sails and oars (reply 3): at rest the sails are furled and the oars still; while the ship moves
#   along its path the sails are open and the `Oar_Row` animation loops. Its sail cloth (`Sail_Mat`) is this ship's own
#   copy in the rule's `sail_color`.
# - Weapons come from the type's rule (data/battle3d/naval_unit_type_rules.json `weapons`), fired in order WEAPON_GAP
#   apart: "cannon" (battle3d_cannon_fx.gd), "arrow" and "gun" (the land battle's battle3d_ranged_fx.gd, unchanged:
#   its arrow from deck points, its gun volley from stand-in shooters on the deck).
# - A ship whose troops reach 0 heels over and sinks with smoke, then hides.
# Presentation only: nothing here reads or writes engine state, and its random numbers are its own.
const RangedFx := preload("res://scripts/battle3d/battle3d_ranged_fx.gd")
const CannonFx := preload("res://scripts/battle3d/naval/battle3d_cannon_fx.gd")
const MODEL_PATH := "res://assets/battle3d/naval/%s.glb"
const HULL_NODE := "Hull" # a delivered model's hull mesh: what its length, width and height are measured on
const WATERLINE_NODE := "WaterLine" # an empty node at the height the sea should meet the hull
const SAIL_MATERIAL := "Sail_Mat" # the sail cloth, the one material that takes the nation colour
const OAR_ANIMATION := "Oar_Row"
const GROUND_LIFT := 0.035 # m: the lab keeps a unit's model this far above its cell (lab_presentation.gd _ground_soldiers)
const SAIL_TIME := 0.25 # s to open or furl the sails
const SAIL_HIDDEN := 0.001 # a sail that is not shown is scaled to this, not hidden (the model's own convention)
const FACING_YAW := {"up": 0.0, "down": PI, "left": PI / 2, "right": -PI / 2} # bow to -Z (the lab's old-model table)
const TURN_RATE := 6.0 # 1/s: the bow turns toward its heading by 1 - exp(-TURN_RATE * delta) a frame
const WEAPON_GAP := 0.45 # s between a ship's weapons in one attack
const ARROW_STAGGER := 0.07 # s between the archers of one volley
const ROLL := deg_to_rad(2.0) # the swell: roll and pitch, each ship on its own phase
const PITCH := deg_to_rad(2.0)
const HEAVE := 0.03 # m
const ROCK := deg_to_rad(7.0) # a hit heels the ship away from the attacker, then it rights itself
const ROCK_TIME := 0.9
const SINK_TIME := 2.6
const SINK_DEPTH := 1.7 # m
const SINK_ROLL := deg_to_rad(38.0)
const SINK_PITCH := deg_to_rad(14.0)
const SINK_SMOKE_EVERY := 0.35
const FLAG_COLOR := {"ally": Color(0.16, 0.38, 0.78), "enemy": Color(0.78, 0.17, 0.14)}
const WOOD := {"ally": Color(0.47, 0.32, 0.19), "enemy": Color(0.24, 0.20, 0.18)}
const WIDTH_RATIO := {"turtle_ship": 0.42, "panokseon": 0.38, "atakebune": 0.40, "sekibune": 0.30}

var fx: Node3D = null # the land battle's ranged effects (arrows, guns), one node under the lab root
var cannon: Node3D = null # the cannon effects, one node under the lab root
var records: Array = [] # one entry per weapon of each attack: {attacker_id, target_id, unit_type, weapon, order}
var sink_records: Array = [] # unit ids, in the order their ships started to sink
var model_sources := {} # unit_id -> "glb" or "placeholder"
var _materials := {} # colour -> shared material
var _ships := {} # ship instance id -> {ship, body, kind, id, phase, guns_l, guns_r, guns_f, shooters, hit_points, gunners,
	# sails_open, sails_furled, oars (AnimationPlayer or null), sail (0 furled .. 1 open), moving}
var _queue: Array = [] # {t, call}: delayed shots, advanced by update
var _rocks := {} # ship instance id -> {t, side}
var _sinks := {} # ship instance id -> {t, smoke}
var _seen := {} # ship instance id -> true once the lab has set its visibility
var _yaw_target := {} # unit id -> heading
var _yaw_ready := {}
var _time := 0.0
var _rng := RandomNumberGenerator.new()

func _init() -> void:
	_rng.randomize()

func handles(u: Dictionary) -> bool:
	return UnitTypeContract.is_naval(kind_of(u))

func kind_of(u: Dictionary) -> String:
	return String(u.get("source_unit_type", u.unit_type))

func spawn_soldiers(u: Dictionary, root: Node3D) -> Array:
	var kind := kind_of(u)
	var side := "ally" if u.side == "ally" else "enemy"
	if fx == null:
		fx = RangedFx.new()
		fx.name = "RangedFx"
		root.get_parent().add_child(fx)
		cannon = CannonFx.new()
		cannon.name = "CannonFx"
		root.get_parent().add_child(cannon)
	var ship := Node3D.new()
	ship.name = "Ship"
	ship.set_meta("unit3d_kind", kind)
	var body := Node3D.new()
	body.name = "Body"
	ship.add_child(body)
	var rule := UnitTypeContract.get_rule(kind)
	var length := float(rule.get("ship_length", 2.4))
	var width := length * float(WIDTH_RATIO.get(kind, 0.36))
	var deck := 0.3
	var rig := {"sails_open": [], "sails_furled": [], "oars": null}
	var path := model_path(kind)
	if not path.is_empty():
		var model: Node3D = (load(path) as PackedScene).instantiate()
		body.add_child(model)
		var fitted := fit_model(model, length)
		width = fitted.x
		deck = fitted.y
		rig = _rig(model, String(rule.get("sail_color", "")))
		model_sources[u.unit_id] = "glb"
	else:
		deck = _placeholder(kind, side, body, length, width)
		_flag(body, side, length, deck)
		model_sources[u.unit_id] = "placeholder"
	# Gun ports: the model's own cannon sockets (the turtle ship: left, right and bow), else its Gun_L / Gun_R marks,
	# else points made here on the hull's sides.
	var port := "CannonSocket_" if body.find_child("CannonSocket_*", true, false) != null else "Gun_"
	var info := {"ship": ship, "body": body, "kind": kind, "id": String(u.unit_id), "phase": _rng.randf() * TAU,
		"guns_l": _marks(body, port + "L", [Vector3(-width * 0.5, deck * 0.7, -length * 0.22), Vector3(-width * 0.5, deck * 0.7, 0), Vector3(-width * 0.5, deck * 0.7, length * 0.22)]),
		"guns_r": _marks(body, port + "R", [Vector3(width * 0.5, deck * 0.7, -length * 0.22), Vector3(width * 0.5, deck * 0.7, 0), Vector3(width * 0.5, deck * 0.7, length * 0.22)]),
		"guns_f": body.find_children("CannonSocket_F*", "Node3D", true, false),
		"shooters": _marks(body, "Shooter_", [Vector3(-width * 0.25, deck, -length * 0.2), Vector3(width * 0.25, deck, -length * 0.2), Vector3(-width * 0.25, deck, length * 0.15), Vector3(width * 0.25, deck, length * 0.15)]),
		"hit_points": [], "gunners": [], "sails_open": rig.sails_open, "sails_furled": rig.sails_furled, "oars": rig.oars, "sail": 0.0, "moving": false}
	for mark in info.shooters:
		var point := Node3D.new() # where a shot at this ship lands (the ranged effects aim 0.7 m above a target node)
		point.name = "HitPoint"
		body.add_child(point)
		point.position = (mark as Node3D).position + Vector3(0, -0.45, 0)
		info.hit_points.append(point)
		if "gun" in UnitTypeContract.get_rule(kind).get("weapons", []): info.gunners.append(_gunner(mark))
	root.add_child(ship)
	_ships[ship.get_instance_id()] = info
	return [ship]

## One ship: shown while the unit has troops.
func visible_count(value: Dictionary, n: int) -> int:
	return n if int(value.current_troops) > 0 else 0

## The lab's per-frame visibility for the ship, after it put the ship on the water. Losing its troops, the ship leaves
## its unit root (which the lab hides at once), sinks for SINK_TIME where it was, then hides.
func show_soldier(ship: Node3D, want: bool) -> void:
	var key: int = ship.get_instance_id()
	if want or not _seen.has(key):
		_seen[key] = true
		_sinks.erase(key)
		ship.visible = want
		return
	if not _sinks.has(key):
		if not ship.visible: return
		_sinks[key] = {"t": 0.0, "smoke": 0.0}
		if _ships.has(key): sink_records.append(_ships[key].id)
		var root := ship.get_parent()
		if root != null and root.get_parent() != null: ship.reparent(root.get_parent(), true)
	var sink: Dictionary = _sinks[key]
	if sink.t >= SINK_TIME:
		_sinks.erase(key)
		ship.visible = false
		return
	var k: float = sink.t / SINK_TIME
	ship.position.y -= SINK_DEPTH * k * k

func update(lab: Node, delta: float) -> void:
	_time += delta
	for entry in _queue.duplicate():
		entry.t -= delta
		if entry.t <= 0.0:
			_queue.erase(entry)
			(entry.call as Callable).call()
	for key in _rocks.keys():
		_rocks[key].t += delta
		if _rocks[key].t >= ROCK_TIME: _rocks.erase(key)
	for key in _sinks.keys():
		var sink: Dictionary = _sinks[key]
		sink.t += delta
		sink.smoke -= delta
		if sink.smoke <= 0.0 and _ships.has(key) and is_instance_valid(_ships[key].ship):
			sink.smoke = SINK_SMOKE_EVERY
			cannon.smoke_at((_ships[key].ship as Node3D).global_position, _ships[key].id)
	for id in lab.soldiers:
		var root: Node3D = lab.views[id]
		if not root.has_meta("unit3d"): continue
		for ship in lab.soldiers[id]:
			var key: int = ship.get_instance_id()
			if not _ships.has(key): continue
			var info: Dictionary = _ships[key]
			if not _sinks.has(key):
				var yaw := _target_yaw(lab, id, root)
				if _yaw_ready.has(key): ship.rotation.y = lerp_angle(ship.rotation.y, yaw, 1.0 - exp(-TURN_RATE * delta))
				else:
					ship.rotation.y = yaw
					_yaw_ready[key] = true
			_sail(info, lab.playback.has(id) and not _sinks.has(key), delta)
			var body: Node3D = info.body
			var roll: float = sin(_time * 1.1 + info.phase) * ROLL
			var pitch: float = sin(_time * 0.8 + info.phase * 1.7) * PITCH
			if _rocks.has(key):
				var r: float = _rocks[key].t / ROCK_TIME
				roll += _rocks[key].side * ROCK * sin(r * PI) * (1.0 - r)
			if _sinks.has(key):
				var k: float = clampf(_sinks[key].t / SINK_TIME, 0.0, 1.0)
				roll += SINK_ROLL * k
				pitch += SINK_PITCH * k
			body.rotation = Vector3(pitch, 0, roll)
			body.position.y = sin(_time * 1.3 + info.phase * 0.6) * HEAVE

## The attacker fires its type's weapons at the target, in the rule's order (engine attack_resolved /
## enemy_attack_resolved).
func attack(lab: Node, attacker_id: String, target_id: String) -> void:
	var ship := ship_of(lab, attacker_id)
	var target := ship_of(lab, target_id)
	if ship == null or target == null: return
	var info: Dictionary = _ships[ship.get_instance_id()]
	var weapons: Array = UnitTypeContract.get_rule(info.kind).get("weapons", ["cannon"])
	for order in range(weapons.size()):
		records.append({"attacker_id": attacker_id, "target_id": target_id, "unit_type": info.kind, "weapon": String(weapons[order]), "order": order})
		_queue.append({"t": order * WEAPON_GAP, "call": _fire.bind(String(weapons[order]), ship, target, attacker_id, target_id)})

## The target heels away from the attacker and rights itself.
func hit(lab: Node, attacker_id: String, target_id: String) -> void:
	var ship := ship_of(lab, attacker_id)
	var target := ship_of(lab, target_id)
	if ship == null or target == null or lab.playback.has(target_id): return
	var away: Vector3 = target.global_position - ship.global_position
	_rocks[target.get_instance_id()] = {"t": 0.0, "side": -1.0 if away.dot(target.global_basis.x) >= 0.0 else 1.0}

## The ship's own record (model parts, sail and oar state), for checks. Empty when the unit has no ship.
func ship_info(lab: Node, unit_id: String) -> Dictionary:
	var ship := ship_of(lab, unit_id)
	return _ships[ship.get_instance_id()] if ship != null else {}

func ship_of(lab: Node, unit_id: String) -> Node3D:
	if not lab.soldiers.has(unit_id) or (lab.soldiers[unit_id] as Array).is_empty(): return null
	var ship = lab.soldiers[unit_id][0]
	return ship if is_instance_valid(ship) and _ships.has(ship.get_instance_id()) else null

func _fire(weapon: String, ship: Node3D, target: Node3D, attacker_id: String, target_id: String) -> void:
	if not is_instance_valid(ship) or not is_instance_valid(target): return
	var info: Dictionary = _ships[ship.get_instance_id()]
	var aim: Dictionary = _ships[target.get_instance_id()]
	match weapon:
		"cannon":
			# The side facing the target; the bow guns when the ship has them and the target is more ahead than abeam.
			var to_target: Vector3 = ship.global_basis.inverse() * (target.global_position - ship.global_position)
			var ports: Array = info.guns_r if to_target.x >= 0.0 else info.guns_l
			if not info.guns_f.is_empty() and -to_target.z > absf(to_target.x): ports = info.guns_f
			cannon.fire_broadside(ports.map(func(port): return (port as Node3D).global_position), target.global_position, attacker_id, target_id)
		"arrow":
			for index in range(info.shooters.size()):
				_queue.append({"t": index * ARROW_STAGGER, "call": _loose.bind(info.shooters[index], aim.hit_points[index % aim.hit_points.size()], index)})
		"gun":
			var points: Array = []
			for index in range(info.gunners.size()): points.append(aim.hit_points[index % aim.hit_points.size()])
			fx.fire_gun_volley(info.gunners, points)

func _loose(shooter: Node3D, point: Node3D, index: int) -> void:
	# One arrow of the land battle's own kind, from a deck point (no archer model plays the draw).
	if not is_instance_valid(shooter) or not is_instance_valid(point): return
	var back: Vector3 = shooter.global_position + Vector3(0, 0.25, 0)
	var chest: Vector3 = point.global_position + Vector3(0, 0.6, 0)
	var nock: Vector3 = back + ((chest - back).normalized() + Vector3.UP * 0.6).normalized() * 0.4
	fx.call("_spawn_arrow", back, nock, chest, {"index": index, "kind": "arrow", "from_ship": true})

func _target_yaw(lab: Node, id: String, root: Node3D) -> float:
	if lab.playback.has(id):
		var motion: Dictionary = lab.playback[id]
		var goal: Vector3 = lab.board.world(motion.path[motion.index])
		var travel := Vector2(goal.x - root.position.x, goal.z - root.position.z)
		if travel.length() >= .01: _yaw_target[id] = atan2(-travel.x, -travel.y)
	elif lab.display_values.has(id):
		_yaw_target[id] = FACING_YAW.get(lab.display_values[id].facing, 0.0)
	return _yaw_target.get(id, 0.0)

# ---- models ----

## The model file of a ship type: the rule's `model_path`, else the file named after the type, else "" (a stand-in).
static func model_path(kind: String) -> String:
	for path in [String(UnitTypeContract.get_rule(kind).get("model_path", "")), MODEL_PATH % kind]:
		if not path.is_empty() and ResourceLoader.exists(path): return path
	return ""

## Fits a delivered model to the ship length: lengthwise along Z (turned a quarter when it came sideways), centred on
## its own middle, scaled so its length is `length`. Measured on the model's `Hull` mesh when it has one (oars, masts
## and sails are left out), else on all of it. A model with a `WaterLine` node is lowered so that node lies on the sea.
## Returns (width, deck height) in metres.
static func fit_model(model: Node3D, length: float) -> Vector2:
	var hull := model.find_child(HULL_NODE, true, false) as MeshInstance3D
	var box := _fit_box(model, hull)
	if box.size.x > box.size.z:
		model.rotation.y = PI / 2
		box = _fit_box(model, hull)
	model.scale *= length / maxf(box.size.z, 0.001)
	box = _fit_box(model, hull)
	model.position -= Vector3(box.get_center().x, 0, box.get_center().z)
	var water := model.find_child(WATERLINE_NODE, true, false) as Node3D
	if water != null: model.position.y -= xform_in(water, model).origin.y + GROUND_LIFT
	box = _fit_box(model, hull)
	return Vector2(box.size.x, maxf(box.end.y * 0.6, 0.15))

static func _fit_box(model: Node3D, hull: MeshInstance3D) -> AABB:
	if hull == null or hull.mesh == null: return model_box(model, Transform3D())
	return xform_in(hull, model) * hull.mesh.get_aabb()

## `node`'s transform in the space `top` sits in (`top` is `node` or one of its parents; neither need be in the tree).
static func xform_in(node: Node3D, top: Node3D) -> Transform3D:
	var xform := Transform3D()
	var at: Node = node
	while at != null:
		if at is Node3D: xform = (at as Node3D).transform * xform
		if at == top: break
		at = at.get_parent()
	return xform

func _rig(model: Node3D, sail_color: String) -> Dictionary:
	# A delivered model's moving parts: its sails (open / furled pairs under each mast) and the player of its oar
	# animation. The sail cloth becomes this ship's own copy in `sail_color`; hull, masts and other ships keep theirs.
	var rig := {"sails_open": model.find_children("Sail_Open_*", "MeshInstance3D", true, false),
		"sails_furled": model.find_children("Sail_Furled_*", "MeshInstance3D", true, false), "oars": null}
	var cloth := {} # the model's sail material -> this ship's copy
	for sail in rig.sails_open + rig.sails_furled:
		for surface in range(sail.mesh.get_surface_count() if sail.mesh != null and Color.html_is_valid(sail_color) else 0):
			var material := sail.mesh.surface_get_material(surface) as BaseMaterial3D
			if material == null or material.resource_name != SAIL_MATERIAL: continue
			if not cloth.has(material):
				cloth[material] = material.duplicate()
				cloth[material].albedo_color = Color.html(sail_color)
			sail.set_surface_override_material(surface, cloth[material])
	for player in model.find_children("*", "AnimationPlayer", true, false):
		if not player.has_animation(OAR_ANIMATION): continue
		player.get_animation(OAR_ANIMATION).loop_mode = Animation.LOOP_LINEAR # imported without its loop flag
		rig.oars = player
	_set_sails(rig, 0.0) # the file comes with its sails open; a ship starts at rest
	return rig

func _sail(info: Dictionary, moving: bool, delta: float) -> void:
	# Moving along a path: sails open, oars rowing. At rest (or sinking): sails furled, oars still.
	if info.moving != moving:
		info.moving = moving
		if info.oars != null and is_instance_valid(info.oars):
			if moving: info.oars.play(OAR_ANIMATION)
			else: info.oars.stop()
	var want := 1.0 if moving else 0.0
	if is_equal_approx(info.sail, want): return
	info.sail = move_toward(info.sail, want, delta / SAIL_TIME)
	_set_sails(info, info.sail)

static func _set_sails(rig: Dictionary, open: float) -> void:
	for sail in rig.sails_open: sail.scale = Vector3.ONE * lerpf(SAIL_HIDDEN, 1.0, open)
	for sail in rig.sails_furled: sail.scale = Vector3.ONE * lerpf(1.0, SAIL_HIDDEN, open)

static func model_box(node: Node, parent: Transform3D) -> AABB:
	# The model's meshes in its parent's space (the node is not in the tree yet).
	var xform := parent * (node as Node3D).transform if node is Node3D else parent
	var box := AABB()
	var first := true
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		box = xform * (node as MeshInstance3D).mesh.get_aabb()
		first = false
	for child in node.get_children():
		var child_box := model_box(child, xform)
		if child_box.size == Vector3.ZERO: continue
		box = child_box if first else box.merge(child_box)
		first = false
	return box

func _marks(body: Node3D, prefix: String, fallback: Array) -> Array:
	# The model's own marker nodes (Gun_L1.., Gun_R1.., Shooter_1..) when it has them, else points made here.
	var found: Array = body.find_children(prefix + "*", "Node3D", true, false)
	if not found.is_empty(): return found
	for index in range(fallback.size()):
		var mark := Node3D.new()
		mark.name = "%s%d" % [prefix, index + 1]
		body.add_child(mark)
		mark.position = fallback[index]
		found.append(mark)
	return found

func _gunner(mark: Node3D) -> Node3D:
	# What battle3d_ranged_fx.gd's gun volley needs of a shooter: an AnimationPlayer with attack_gun, and a Muzzle node
	# under a BoneAttachment3D of a Skeleton3D (one bone at rest). No model: the shot's flash, tracer and smoke start at
	# the deck point.
	var gunner := Node3D.new()
	gunner.name = "Gunner"
	mark.add_child(gunner)
	var player := AnimationPlayer.new()
	var library := AnimationLibrary.new()
	var animation := Animation.new()
	animation.length = 0.3
	library.add_animation(&"attack_gun", animation)
	player.add_animation_library(&"", library)
	gunner.add_child(player)
	var skeleton := Skeleton3D.new()
	skeleton.add_bone("muzzle")
	gunner.add_child(skeleton)
	var attachment := BoneAttachment3D.new()
	skeleton.add_child(attachment)
	attachment.bone_name = "muzzle"
	var muzzle := Node3D.new()
	muzzle.name = "Muzzle"
	muzzle.position = Vector3(0, 0.3, 0)
	attachment.add_child(muzzle)
	return gunner

func _material(color: Color) -> StandardMaterial3D:
	if not _materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 1.0
		material.metallic_specular = 0.0
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_materials[color] = material
	return _materials[color]

func _part(parent: Node3D, mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = at
	part.material_override = _material(color)
	parent.add_child(part)
	return part

func _box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _part(parent, mesh, at, color)

func _pole(parent: Node3D, radius: float, height: float, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 6
	return _part(parent, mesh, at + Vector3(0, height * 0.5, 0), color)

func _roof(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := PrismMesh.new()
	mesh.size = size
	return _part(parent, mesh, at + Vector3(0, size.y * 0.5, 0), color)

func _hull(parent: Node3D, length: float, width: float, freeboard: float, color: Color) -> void:
	# A pointed bow (-Z), a square stern, narrower under the water.
	var half := length * 0.5
	var top := [Vector3(-width * 0.5, freeboard, half), Vector3(width * 0.5, freeboard, half), Vector3(width * 0.5, freeboard, -half * 0.45), Vector3(0, freeboard + 0.06, -half), Vector3(-width * 0.5, freeboard, -half * 0.45)]
	var bottom: Array = []
	for point in top: bottom.append(Vector3(point.x * 0.6, -0.25, point.z * 0.88))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(top.size()):
		var next := (index + 1) % top.size()
		for point in [top[index], top[next], bottom[index], top[next], bottom[next], bottom[index]]: st.add_vertex(point)
	for index in range(1, top.size() - 1):
		for point in [top[0], top[index + 1], top[index]]: st.add_vertex(point)
	st.generate_normals()
	_part(parent, st.commit(), Vector3.ZERO, color)

## The stand-in ship for a type with no delivered model. Returns its deck height.
func _placeholder(kind: String, side: String, body: Node3D, length: float, width: float) -> float:
	var wood: Color = WOOD[side]
	match kind:
		"turtle_ship": # low hull, a spiked shell over the deck, a dragon head, no sail
			_hull(body, length, width, 0.2, wood)
			var shell := SphereMesh.new()
			shell.radius = 0.5
			shell.height = 1.0
			shell.radial_segments = 12
			shell.rings = 6
			_part(body, shell, Vector3(0, 0.2, length * 0.03), Color(0.20, 0.27, 0.19)).scale = Vector3(width * 1.02, 0.62, length * 0.84)
			for z in [-0.25, 0.0, 0.25]:
				for x in [-0.22, 0.22]:
					var spike := CylinderMesh.new()
					spike.top_radius = 0.0
					spike.bottom_radius = 0.035
					spike.height = 0.14
					spike.radial_segments = 5
					_part(body, spike, Vector3(x * width, 0.47, z * length), Color(0.62, 0.62, 0.6))
			_box(body, Vector3(0.14, 0.14, 0.3), Vector3(0, 0.36, -length * 0.5 + 0.15), Color(0.72, 0.58, 0.22)).name = "DragonHead"
			_box(body, Vector3(0.05, 0.12, 0.05), Vector3(0, 0.48, -length * 0.5 + 0.2), Color(0.72, 0.58, 0.22))
			return 0.42
		"panokseon": # hull, a wider upper deck over it (two decks), a command tower, a bare mast
			_hull(body, length, width, 0.22, wood)
			_box(body, Vector3(width * 1.12, 0.2, length * 0.76), Vector3(0, 0.34, length * 0.04), wood.lightened(0.12))
			_box(body, Vector3(width * 1.18, 0.05, length * 0.8), Vector3(0, 0.46, length * 0.04), wood.darkened(0.3))
			_box(body, Vector3(width * 0.4, 0.24, width * 0.4), Vector3(0, 0.6, length * 0.14), wood.lightened(0.05))
			_roof(body, Vector3(width * 0.56, 0.14, width * 0.56), Vector3(0, 0.72, length * 0.14), Color(0.25, 0.25, 0.27))
			_pole(body, 0.025, 1.0, Vector3(0, 0.46, -length * 0.14), wood.darkened(0.2))
			return 0.5
		"atakebune": # a big hull under a walled castle, a keep on top
			_hull(body, length, width, 0.3, wood)
			_box(body, Vector3(width * 1.0, 0.36, length * 0.68), Vector3(0, 0.48, length * 0.03), Color(0.13, 0.12, 0.12))
			_box(body, Vector3(width * 1.02, 0.08, length * 0.7), Vector3(0, 0.62, length * 0.03), Color(0.86, 0.84, 0.78))
			_box(body, Vector3(width * 0.5, 0.26, length * 0.24), Vector3(0, 0.79, length * 0.08), Color(0.86, 0.84, 0.78))
			_roof(body, Vector3(width * 0.66, 0.18, length * 0.3), Vector3(0, 0.92, length * 0.08), Color(0.15, 0.15, 0.17))
			return 0.68
		_: # sekibune: a long low hull, a low cabin, one sail
			_hull(body, length, width, 0.18, wood)
			_box(body, Vector3(width * 0.8, 0.13, length * 0.5), Vector3(0, 0.24, length * 0.08), wood.darkened(0.25))
			_pole(body, 0.022, 1.15, Vector3(0, 0.18, -length * 0.08), wood.darkened(0.1))
			_box(body, Vector3(width * 1.5, 0.6, 0.02), Vector3(0, 0.95, -length * 0.08 - 0.03), Color(0.88, 0.85, 0.76)).name = "Sail"
			return 0.32

func _flag(body: Node3D, side: String, length: float, deck: float) -> void:
	var flag := body.find_child("Flag", true, false) as MeshInstance3D
	if flag == null:
		_pole(body, 0.015, 0.75, Vector3(0, deck, length * 0.44), Color(0.2, 0.17, 0.14)) # at the stern; the flag flies inboard
		flag = _box(body, Vector3(0.02, 0.2, 0.32), Vector3(0, deck + 0.63, length * 0.44 - 0.17), FLAG_COLOR[side])
		flag.name = "Flag"
	flag.material_override = _material(FLAG_COLOR[side])
