extends SceneTree
# Block 7 test 5: triangle budgets of the built board (default settings), counted from the meshes' own arrays:
# Terrain <= 28,800; the out-of-bounds background (OutOfBoundsVista) <= 7,488; trees <= 16,000 in all and <= 200 each.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const TERRAIN_MAX := 28800
const BACKGROUND_MAX := 7488
const TREES_MAX := 16000
const TREE_MAX := 200
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func triangles(mesh: Mesh) -> int:
	var total := 0
	for s in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(s)
		var indices = arrays[Mesh.ARRAY_INDEX]
		total += (indices.size() if indices != null and indices.size() > 0 else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	return total

func run() -> void:
	var field = Builder.new()
	field.setup_from_board(Board.new())
	root.add_child(field)
	await process_frame
	var terrain := field.get_node_or_null("Terrain") as MeshInstance3D
	var vista := field.get_node_or_null("OutOfBoundsVista") as MeshInstance3D
	var trees := field.get_node_or_null("SymbolicBoundaryTrees") as MultiMeshInstance3D
	expect(terrain != null and vista != null and trees != null and trees.multimesh != null, "Terrain, OutOfBoundsVista and SymbolicBoundaryTrees exist")
	var counts := {}
	if terrain != null:
		counts["Terrain"] = triangles(terrain.mesh)
		expect(counts.Terrain > 0 and counts.Terrain <= TERRAIN_MAX, "Terrain %d <= %d triangles" % [counts.Terrain, TERRAIN_MAX])
	if vista != null:
		counts["OutOfBoundsVista"] = triangles(vista.mesh)
		expect(counts.OutOfBoundsVista > 0 and counts.OutOfBoundsVista <= BACKGROUND_MAX, "background %d <= %d triangles" % [counts.OutOfBoundsVista, BACKGROUND_MAX])
	if trees != null and trees.multimesh != null:
		var per_tree := triangles(trees.multimesh.mesh)
		counts["tree"] = per_tree
		counts["trees"] = per_tree * trees.multimesh.instance_count
		counts["tree_instances"] = trees.multimesh.instance_count
		expect(per_tree > 0 and per_tree <= TREE_MAX, "one tree %d <= %d triangles" % [per_tree, TREE_MAX])
		expect(counts.trees <= TREES_MAX, "trees %d x %d = %d <= %d triangles" % [trees.multimesh.instance_count, per_tree, counts.trees, TREES_MAX])
	# Everything else, reported for the record (no budget given): ford, water, bridges (off by default).
	for name in ["Ford", "RiverWaterPlane"]:
		var n := field.get_node_or_null(name) as MeshInstance3D
		if n != null: counts[name] = triangles(n.mesh)
	var bridge_tris := 0
	var bridges := field.get_node_or_null("WoodenLogBridges")
	if bridges != null:
		for m in bridges.find_children("*", "MeshInstance3D", true, false): bridge_tris += triangles((m as MeshInstance3D).mesh)
	counts["WoodenLogBridges"] = bridge_tris
	field.queue_free()
	await process_frame
	print("[BLOCK7_TRIANGLES] %s: %d checks, %d failures; %s" % ["PASS" if failures == 0 else "FAIL", checks, failures, counts])
	quit(0 if failures == 0 else 1)
