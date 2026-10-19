extends Node3D
# Pilot-only comparison scene. Does not touch the real Lab or engine code.
# Camera numbers copy lab_presentation.gd (orthographic, yaw 0.32, offset 43/40/43, zoom 60).
const TYPES := ["infantry", "archer", "gunner", "cavalry", "mounted_archer"]
const OLD := {"infantry": "ally_infantry", "cavalry": "ally_cavalry"}
var out_path := ""
var zoom := 60.0
var yaw := 0.32

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="): out_path = a.substr(6)
		if a.begins_with("--zoom="): zoom = float(a.substr(7))
	var f: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/pilot/formations.json"))["units"]
	var env := WorldEnvironment.new(); env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR; env.environment.background_color = Color("18232e")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("c7d8e4"); env.environment.ambient_light_energy = .35
	env.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(env)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-55, -30, 0); sun.light_energy = .8; add_child(sun)
	var ground := MeshInstance3D.new(); var pm := PlaneMesh.new(); pm.size = Vector2(60, 24); ground.mesh = pm
	var gm := StandardMaterial3D.new(); gm.albedo_color = Color("5c6b46"); gm.roughness = .9; ground.material_override = gm
	ground.position = Vector3(15, 0, 3); add_child(ground)
	for i in TYPES.size():
		var t: String = TYPES[i]
		var root := Node3D.new(); root.position = Vector3(i * 6.0, 0, 0); add_child(root)
		_disc(root, Color("286496"))
		var model: PackedScene = load("res://assets/battle3d/pilot/unit_%s.glb" % t)
		for s in f[t]["soldiers"]:
			var n: Node3D = model.instantiate(); root.add_child(n)
			n.position = Vector3(s["x"], 0, -s["y"]); n.rotation.y = s["yaw_rel"]; n.scale = Vector3.ONE * s["scale"]
		_label(root, "%s (%d)" % [t, f[t]["count"]])
		# Existing Lab squads (2x3 old models) in the row behind, same spacing, for size comparison.
		if OLD.has(t):
			var old := Node3D.new(); old.position = Vector3(i * 6.0, 0, 7.0); add_child(old)
			_disc(old, Color("286496"))
			var om: PackedScene = load("res://assets/battle3d/%s.glb" % OLD[t])
			for row in 2:
				for col in 3:
					var so: Node3D = om.instantiate(); old.add_child(so)
					so.position = Vector3((col - 1) * .65, 0, (row - .5) * (.95 if t == "cavalry" else .7))
			_label(old, "OLD " + t)
	var focus := Vector3(12, 0, 3.5)
	var cam := Camera3D.new(); cam.projection = Camera3D.PROJECTION_ORTHOGONAL; cam.size = zoom; cam.far = 200
	add_child(cam)
	cam.position = focus + Vector3(sin(yaw) * 43, 40, cos(yaw) * 43); cam.look_at(focus, Vector3.UP)
	if out_path != "":
		await get_tree().create_timer(1.0).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(out_path)
		get_tree().quit()

func _disc(p: Node3D, c: Color) -> void:
	var m := MeshInstance3D.new(); var cy := CylinderMesh.new(); cy.top_radius = 1.6; cy.bottom_radius = 1.6; cy.height = .04; m.mesh = cy
	var mat := StandardMaterial3D.new(); mat.albedo_color = c; m.material_override = mat; m.position.y = .02; p.add_child(m)

func _label(p: Node3D, txt: String) -> void:
	var l := Label3D.new(); l.text = txt; l.font_size = 48; l.pixel_size = .009; l.position = Vector3(0, 2.8, 0)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED; l.no_depth_test = true; p.add_child(l)
