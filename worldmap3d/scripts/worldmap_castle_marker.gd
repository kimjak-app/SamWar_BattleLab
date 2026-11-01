## EASTWAR WorldMap3D — small procedural castle marker (placeholder until a modelled castle GLB exists).
## Size in km (map scale). grade 1..3 changes footprint and tiers. Faction colour tints the roof ridge flag.
class_name WorldMapCastleMarker
extends Node3D

var _flag_mat: StandardMaterial3D

static func _mat(c: Color, rough := 0.85) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	return m

func build(grade: int, faction_color: Color) -> void:
	var s := 0.9 + 0.35 * grade
	var stone := _mat(Color(0.70, 0.66, 0.58))
	var wall := _mat(Color(0.88, 0.84, 0.76))
	var roof := _mat(Color(0.20, 0.22, 0.26), 0.6)
	var wood := _mat(Color(0.55, 0.18, 0.12))
	# outer wall ring (4 low boxes)
	var ring := 1.6 * s
	for k in 4:
		var w := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(ring * 2.0, 0.28 * s, 0.16 * s)
		w.mesh = bm
		w.material_override = stone
		w.rotation.y = k * PI * 0.5
		w.position = Vector3(0, 0.14 * s, 0).rotated(Vector3.UP, k * PI * 0.5) + Vector3(0, 0, ring).rotated(Vector3.UP, k * PI * 0.5)
		add_child(w)
	# corner towers
	for k in 4:
		var t := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.22 * s
		cm.bottom_radius = 0.26 * s
		cm.height = 0.5 * s
		cm.radial_segments = 6
		t.mesh = cm
		t.material_override = stone
		t.position = Vector3(ring, 0.25 * s, ring).rotated(Vector3.UP, k * PI * 0.5)
		add_child(t)
	# keep: stone base + tiers + hip roofs
	var tiers := 1 + clampi(grade, 1, 3)
	var y := 0.0
	var base := MeshInstance3D.new()
	var bb := CylinderMesh.new()
	bb.top_radius = 0.85 * s
	bb.bottom_radius = 1.05 * s
	bb.height = 0.45 * s
	bb.radial_segments = 4
	base.mesh = bb
	base.material_override = stone
	base.rotation.y = PI * 0.25
	base.position.y = 0.225 * s
	add_child(base)
	y = 0.45 * s
	for t in tiers:
		var f := 1.0 - 0.22 * t
		var body := MeshInstance3D.new()
		var bm2 := BoxMesh.new()
		bm2.size = Vector3(0.95 * s * f, 0.32 * s, 0.75 * s * f)
		body.mesh = bm2
		body.material_override = wall if t > 0 else wood
		body.position.y = y + 0.16 * s
		add_child(body)
		var r := MeshInstance3D.new()
		var rm := CylinderMesh.new()
		rm.top_radius = 0.02
		rm.bottom_radius = 0.95 * s * f
		rm.height = 0.34 * s
		rm.radial_segments = 4
		r.mesh = rm
		r.material_override = roof
		r.rotation.y = PI * 0.25
		r.scale = Vector3(1.0, 1.0, 0.8)
		r.position.y = y + 0.32 * s + 0.17 * s
		add_child(r)
		y += 0.42 * s
	# faction pennant on top
	var pole := MeshInstance3D.new()
	var pm := CylinderMesh.new()
	pm.top_radius = 0.02 * s
	pm.bottom_radius = 0.02 * s
	pm.height = 0.7 * s
	pm.radial_segments = 4
	pole.mesh = pm
	pole.material_override = _mat(Color(0.3, 0.25, 0.2))
	pole.position.y = y + 0.35 * s
	add_child(pole)
	var flag := MeshInstance3D.new()
	var fm := BoxMesh.new()
	fm.size = Vector3(0.45 * s, 0.26 * s, 0.02)
	flag.mesh = fm
	_flag_mat = _mat(faction_color, 0.5)
	_flag_mat.emission_enabled = true
	_flag_mat.emission = faction_color * 0.4
	flag.material_override = _flag_mat
	flag.position = Vector3(0.23 * s, y + 0.55 * s, 0)
	add_child(flag)

func set_faction_color(c: Color) -> void:
	if _flag_mat:
		_flag_mat.albedo_color = c
		_flag_mat.emission = c * 0.4
