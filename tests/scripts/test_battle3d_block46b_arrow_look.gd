extends SceneTree
# HUD block 4-6b test 3: the facing arrow's look, on the scenario shell's lab. Built by the lab's own _facing_arrow for
# each style and side, measured from the meshes' vertices here:
#   - the fill is at least 0.75 m long and 0.95 m wide; its centre 1.0 m out in front once placed;
#   - style 0: an outline under the fill (bigger both ways, lower), cream fill f4e7c4 and dark outline 241c14;
#     style 1: an outer dark outline, a white outline and a side-coloured fill (ally 5aa8ff, enemy ff6a50);
#     style 2: the fill alone; every layer drawn on top (no depth test, transparent pass) while ARROW_ON_TOP;
#   - the units' own arrows are the default style (0).
# Whether soldiers hide an arrow (four facings, the three disc colours) is judged on the comparison sheet in evidence
# (a headless run draws nothing).
var h

func _initialize() -> void:
	run.call_deferred()

func extent(mesh_node: MeshInstance3D) -> AABB:
	var verts: PackedVector3Array = mesh_node.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var box := AABB(verts[0], Vector3.ZERO)
	for v in verts: box = box.expand(v)
	return box

func layers(arrow: Node3D) -> Dictionary:
	var out := {}
	for child in arrow.get_children(): out[str(child.name)] = child # String keys (node names are StringNames)
	return out

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(30): await process_frame
	var report := {}
	# Style 0 (default).
	var a0: Node3D = lab._facing_arrow("ally", 0)
	var l0 := layers(a0)
	h.expect(l0.keys() == ["Outline", "Fill"], "style 0: outline then fill (%s)" % str(l0.keys()))
	var fill := extent(l0.Fill)
	report["fill"] = [fill.size.z, fill.size.x]
	h.expect(fill.size.z >= 0.75 and fill.size.x >= 0.95, "fill %.2f m long, %.2f m wide (at least 0.75 x 0.95)" % [fill.size.z, fill.size.x])
	var outline = extent(l0.Outline) if l0.has("Outline") else null
	h.expect(outline != null and outline.size.x > fill.size.x and outline.size.z > fill.size.z and outline.position.y < fill.position.y, "outline bigger and under the fill (%s vs fill %s)" % [outline, fill])
	h.expect(l0.has("Outline") and l0.Fill.material_override.albedo_color.is_equal_approx(Color("f4e7c4")) and l0.Outline.material_override.albedo_color.is_equal_approx(Color("241c14")), "style 0 colours: cream fill, dark outline")
	# Style 1 per side, style 2.
	var a1a: Node3D = lab._facing_arrow("ally", 1)
	var a1e: Node3D = lab._facing_arrow("enemy", 1)
	var l1a := layers(a1a)
	h.expect(l1a.keys() == ["OuterOutline", "Outline", "Fill"] and l1a.Outline.material_override.albedo_color.is_equal_approx(Color.WHITE) and l1a.Fill.material_override.albedo_color.is_equal_approx(Color("5aa8ff")) and layers(a1e).Fill.material_override.albedo_color.is_equal_approx(Color("ff6a50")),
		"style 1: outer dark, white outline, ally 5aa8ff / enemy ff6a50 fill (%s)" % str(l1a.keys()))
	var a2: Node3D = lab._facing_arrow("enemy", 2)
	h.expect(layers(a2).keys() == ["Fill"] and layers(a2).Fill.material_override.albedo_color.is_equal_approx(Color("f4e7c4")), "style 2: the cream fill alone (%s)" % str(layers(a2).keys()))
	var on_top := []
	for arrow in [a0, a1a, a1e, a2]:
		for child in arrow.get_children():
			var mat: BaseMaterial3D = child.material_override
			on_top.append(mat.no_depth_test and mat.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA)
	h.expect(lab.ARROW_ON_TOP and on_top.all(func(x): return x), "every layer drawn on top (%d layers)" % on_top.size())
	for arrow in [a0, a1a, a1e, a2]: arrow.free()
	# The units' own arrows: default style, centre 1.0 m out.
	var own := []
	for unit in b.all_battle_unit_states:
		for child in lab.views[unit.unit_id].get_children():
			if child.has_meta("facing_arrow"):
				own.append([unit.unit_id, layers(child).keys() == ["Outline", "Fill"], is_equal_approx(Vector2(child.position.x, child.position.z).length(), 1.0)])
	h.expect(lab.ARROW_STYLE == 0 and own.size() == b.all_battle_unit_states.size() and own.all(func(r): return r[1] and r[2]), "units' arrows: style 0, centre 1.0 m out %s" % str(own.filter(func(r): return not (r[1] and r[2]))))
	await h.close_shell(self)
	print("[BLOCK46B_ARROW] checks=", h.checks, " failures=", h.failures, " fill length/width ", report.fill)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
