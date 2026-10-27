extends SceneTree
# Block 8 (look pass 1+2): every forest tree's top is at most 4.0 m above its base. The tree mesh's own vertices give its
# height; the instance scale is at most 1.15 (the order's bound). A headless (dummy) renderer keeps no MultiMesh
# transforms, so there the bound is mesh height x 1.15; with a real renderer every instance's own scale is used too.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const MAX_TOP := 4.0
const MAX_SCALE := 1.15
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func run() -> void:
	var field = Builder.new()
	field.setup_from_board(Board.new())
	root.add_child(field)
	await process_frame
	var trees := field.get_node_or_null("SymbolicBoundaryTrees") as MultiMeshInstance3D
	expect(trees != null and trees.multimesh != null and trees.multimesh.instance_count > 0, "forest trees exist")
	var low := INF
	var high := -INF
	var mesh: Mesh = trees.multimesh.mesh
	for s in range(mesh.get_surface_count()):
		for v in (mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX] as PackedVector3Array):
			low = minf(low, v.y)
			high = maxf(high, v.y)
	var height := high - maxf(low, 0.0)
	expect(low >= -0.001, "the tree mesh stands on its origin (lowest vertex %.3f)" % low)
	expect(height * MAX_SCALE <= MAX_TOP, "mesh height %.4f m x %.2f = %.4f m <= %.1f m" % [height, MAX_SCALE, height * MAX_SCALE, MAX_TOP])
	var headless := DisplayServer.get_name() == "headless"
	var worst := 0.0
	if not headless:
		var over := []
		for i in range(trees.multimesh.instance_count):
			var b: Basis = trees.multimesh.get_instance_transform(i).basis
			var top := (b * Vector3(0, high, 0)).y
			worst = maxf(worst, top)
			if top > MAX_TOP or b.get_scale().y > MAX_SCALE + 0.0001: over.append([i, top, b.get_scale().y])
		expect(over.is_empty(), "%d instances: top <= %.1f m, scale <= %.2f (over %s)" % [trees.multimesh.instance_count, MAX_TOP, MAX_SCALE, str(over.slice(0, 5))])
	var count: int = trees.multimesh.instance_count if trees and trees.multimesh else 0
	field.queue_free()
	await process_frame
	print("[LOOK12_TREE_HEIGHT] %s: %d checks, %d failures; trees %d, mesh height %.4f m, bound %.4f m, %s" % ["PASS" if failures == 0 else "FAIL", checks, failures,
		count, height, height * MAX_SCALE, "headless: per-instance check not possible" if headless else "worst instance top %.4f m" % worst])
	quit(0 if failures == 0 else 1)
