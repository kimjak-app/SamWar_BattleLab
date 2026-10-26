extends SceneTree
# Block 7 test 6: the board's defaults, on a fresh builder and on the board the game builds (the scenario shell's lab):
# show_bridges = false, scatter_inner_trees = false, mountain_height_scale = 0.5; the ground nodes are named Terrain and
# Ford (lab_presentation.gd _add_ground_collision and battle3d_grid_projection.gd attach_surface_collisions look them up
# by those names); with the defaults there is no bridge and no tree on the board (0..60 m).
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
var h

func _initialize() -> void:
	run.call_deferred()

func check_field(field, label: String) -> void:
	h.expect(field.show_bridges == false, "%s: show_bridges false (got %s)" % [label, field.show_bridges])
	h.expect(field.scatter_inner_trees == false, "%s: scatter_inner_trees false (got %s)" % [label, field.scatter_inner_trees])
	h.expect(is_equal_approx(field.mountain_height_scale, 0.5), "%s: mountain_height_scale 0.5 (got %s)" % [label, field.mountain_height_scale])
	var terrain = field.get_node_or_null("Terrain")
	var ford = field.get_node_or_null("Ford")
	h.expect(terrain is MeshInstance3D and ford is MeshInstance3D, "%s: MeshInstance3D children named Terrain and Ford (%s, %s)" % [label, terrain, ford])
	var bridges = field.get_node_or_null("WoodenLogBridges")
	h.expect(bridges != null and bridges.find_children("*", "MeshInstance3D", true, false).is_empty(), "%s: no bridge mesh with show_bridges off" % label)
	# Trees: a headless (dummy) renderer does not keep MultiMesh transforms, so the count is compared instead. With the
	# defaults the trees are the boundary clusters only: the same count as a builder with inner trees explicitly off and
	# boundary trees on, and none at all with boundary trees off (the clusters sit outside 0..60 m:
	# terrain_board_builder.gd _scatter_symbolic_boundary_trees, x <= -1.8 or x >= 61.8).
	var trees = field.get_node_or_null("SymbolicBoundaryTrees")
	h.expect(trees != null and trees.multimesh != null and trees.multimesh.instance_count == boundary_only, "%s: %d trees = the boundary clusters only (%d)" % [label, trees.multimesh.instance_count if trees and trees.multimesh else -1, boundary_only])

var boundary_only := -1

func tree_count(inner: bool, boundary: bool) -> int:
	var b = Builder.new()
	b.scatter_inner_trees = inner
	b.scatter_boundary_trees = boundary
	b.setup_from_board(Board.new())
	var n: int = b.forest_multimesh.multimesh.instance_count
	b.free()
	return n

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	boundary_only = tree_count(false, true)
	var none := tree_count(false, false)
	var with_inner := tree_count(true, true)
	h.expect(boundary_only > 0 and none == 0 and with_inner > boundary_only, "tree counts: boundary only %d, none %d, with inner trees %d (control)" % [boundary_only, none, with_inner])
	var fresh = Builder.new()
	h.expect(fresh.show_bridges == false and fresh.scatter_inner_trees == false and fresh.mountain_height_scale == 0.5, "the builder's declared defaults before building")
	fresh.setup_from_board(Board.new())
	check_field(fresh, "fresh builder")
	fresh.free()
	await h.open_shell(self)
	await h.press_scenario(self, "default")
	var built: Array = h.lab.find_children("*", "Node3D", false, false).filter(func(n): return n.get_script() == Builder)
	h.expect(built.size() == 1, "the game's lab builds exactly one board (got %d)" % built.size())
	if built.size() == 1:
		check_field(built[0], "game lab")
		var collided := []
		for name in ["Terrain", "Ford"]:
			var n = built[0].get_node_or_null(name)
			if n != null and not n.find_children("*", "StaticBody3D", false, false).is_empty(): collided.append(name)
		h.expect(collided == ["Terrain", "Ford"], "the game lab gives Terrain and Ford ground collision (got %s)" % str(collided))
	await h.close_shell(self)
	print("[BLOCK7_DEFAULTS] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
