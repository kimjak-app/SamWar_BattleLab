extends SceneTree
# Block 8 (look pass 1+2): set_forest_cell_fade. With no faded cell the tree materials are TRANSPARENCY_DISABLED (as
# opaque as look pass 1); fading one forest cell switches them to a transparent mode and gives that cell's trees alpha
# 0.35 and no other tree; clearing it brings TRANSPARENCY_DISABLED back. The cell is the first forest cell of the play
# area read from terrain_types.json here. Instance colours and positions are kept only by a real renderer: a headless
# (dummy) renderer reads them as 0, so there the alpha part is reported as not checked and only the materials are.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const PLAY := Vector2i(18, 10)
const ALPHA := 0.35
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func modes(mesh: Mesh) -> Array:
	var out := []
	for s in range(mesh.get_surface_count()):
		var m := mesh.surface_get_material(s) as BaseMaterial3D
		out.append(m.transparency if m else -1)
	return out

func alphas(mm: MultiMesh, cell: Vector2i) -> Dictionary:
	# Split the instances by the cell their position falls in (3 m cells): this cell's alphas / every other alpha.
	var inside := []
	var others := []
	for i in range(mm.instance_count):
		var p: Vector3 = mm.get_instance_transform(i).origin
		var a := mm.get_instance_color(i).a
		if Vector2i(floori(p.x / 3.0), floori(p.z / 3.0)) == cell: inside.append(a)
		else: others.append(a)
	return {"inside":inside, "others":others}

func run() -> void:
	var cells: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json")).cells
	var cell := Vector2i(-1, -1)
	for y in range(PLAY.y):
		for x in range(PLAY.x):
			if cell.x < 0 and cells[y][x] == "forest": cell = Vector2i(x, y)
	expect(cell.x >= 0, "a forest cell in the play area (%s)" % cell)
	var field = Builder.new()
	field.setup_from_board(Board.new())
	root.add_child(field)
	await process_frame
	var trees := field.get_node_or_null("SymbolicBoundaryTrees") as MultiMeshInstance3D
	var mm: MultiMesh = trees.multimesh
	var mesh: Mesh = mm.mesh
	expect(mesh.get_surface_count() > 0 and modes(mesh).all(func(m): return m == BaseMaterial3D.TRANSPARENCY_DISABLED), "no fade: every tree material TRANSPARENCY_DISABLED (%s)" % str(modes(mesh)))
	expect(mm.use_colors, "the trees carry per-instance colours (the fade's alpha)")
	field.set_forest_cell_fade(cell, true)
	var faded := modes(mesh)
	expect(faded.all(func(m): return m != BaseMaterial3D.TRANSPARENCY_DISABLED and m >= 0), "one cell faded: the tree materials are transparent (%s)" % str(faded))
	var headless := DisplayServer.get_name() == "headless"
	var note := "headless: instance alpha not readable, materials only"
	if not headless:
		var a := alphas(mm, cell)
		expect(not a.inside.is_empty() and a.inside.all(func(x): return is_equal_approx(x, ALPHA)) and a.others.all(func(x): return is_equal_approx(x, 1.0)),
			"cell %s: its %d trees alpha %.2f, the other %d trees 1.0 (%s / %s)" % [cell, a.inside.size(), ALPHA, a.others.size(), str(a.inside), str(a.others.filter(func(x): return not is_equal_approx(x, 1.0)))])
		note = "alpha checked on %d + %d trees" % [a.inside.size(), a.others.size()]
	field.set_forest_cell_fade(cell, false)
	expect(modes(mesh).all(func(m): return m == BaseMaterial3D.TRANSPARENCY_DISABLED), "fade cleared: back to TRANSPARENCY_DISABLED (%s)" % str(modes(mesh)))
	if not headless:
		var b := alphas(mm, cell)
		expect((b.inside + b.others).all(func(x): return is_equal_approx(x, 1.0)), "fade cleared: every tree alpha 1.0")
	field.queue_free()
	await process_frame
	print("[LOOK12_FOREST_FADE] %s: %d checks, %d failures; cell %s; %s" % ["PASS" if failures == 0 else "FAIL", checks, failures, cell, note])
	quit(0 if failures == 0 else 1)
