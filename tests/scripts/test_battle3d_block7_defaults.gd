extends SceneTree
# Block 7 test 6 (expectations changed in block 8, look pass 1+2): the board's defaults, on a fresh builder and on the
# board the game builds (the scenario shell's lab): show_bridges = false, mountain_height_scale = 0.5, and the forest
# trees: scatter_inner_trees = true, forest_trees_outside_play = false, scatter_boundary_trees = false (no clusters off
# the board). The ground nodes are named Terrain and Ford (lab_presentation.gd _add_ground_collision and
# battle3d_grid_projection.gd attach_surface_collisions look them up by those names); no bridge with the defaults.
# Tree count: this test counts the forest cells of the 18x10 play area in terrain_types.json itself (expected 24) and
# expects 1 to 3 trees per cell (김작's density decision), i.e. 24..72; controls: forest trees outside the play area on
# -> more trees, boundary clusters on -> more trees, both tree kinds off -> none.
# The game lab also gets the painted outer ground texture (block 8 item 2-2) with mipmaps.
const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const PLAY := Vector2i(18, 10)
const OUTER := "res://assets/terrain_textures_pack/outer_ground_B20.png"
var h
var forest_cells := 0
var default_count := -1

func _initialize() -> void:
	run.call_deferred()

func tree_count(settings: Dictionary) -> int:
	var b = Builder.new()
	for key in settings: b.set(key, settings[key])
	b.setup_from_board(Board.new())
	var n: int = b.forest_multimesh.multimesh.instance_count if b.forest_multimesh != null and b.forest_multimesh.multimesh != null else 0
	b.free()
	return n

func check_field(field, label: String) -> void:
	h.expect(field.show_bridges == false, "%s: show_bridges false (got %s)" % [label, field.show_bridges])
	h.expect(field.scatter_inner_trees == true, "%s: scatter_inner_trees true (got %s)" % [label, field.scatter_inner_trees])
	h.expect(field.forest_trees_outside_play == false, "%s: forest_trees_outside_play false (got %s)" % [label, field.forest_trees_outside_play])
	h.expect(field.scatter_boundary_trees == false, "%s: scatter_boundary_trees false (got %s)" % [label, field.scatter_boundary_trees])
	h.expect(is_equal_approx(field.mountain_height_scale, 0.5), "%s: mountain_height_scale 0.5 (got %s)" % [label, field.mountain_height_scale])
	var terrain = field.get_node_or_null("Terrain")
	var ford = field.get_node_or_null("Ford")
	h.expect(terrain is MeshInstance3D and ford is MeshInstance3D, "%s: MeshInstance3D children named Terrain and Ford (%s, %s)" % [label, terrain, ford])
	var bridges = field.get_node_or_null("WoodenLogBridges")
	h.expect(bridges != null and bridges.find_children("*", "MeshInstance3D", true, false).is_empty(), "%s: no bridge mesh with show_bridges off" % label)
	# A headless (dummy) renderer does not keep MultiMesh transforms, so trees are compared by count.
	var trees = field.get_node_or_null("SymbolicBoundaryTrees")
	var n: int = trees.multimesh.instance_count if trees != null and trees.multimesh != null else -1
	h.expect(n == default_count and n >= forest_cells and n <= forest_cells * 3, "%s: %d trees, 1-3 per play-area forest cell (%d cells -> %d..%d)" % [label, n, forest_cells, forest_cells, forest_cells * 3])

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	var cells: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json")).cells
	for y in range(PLAY.y):
		for x in range(PLAY.x):
			if cells[y][x] == "forest": forest_cells += 1
	h.expect(forest_cells == 24, "terrain_types.json: 24 forest cells in the 18x10 play area (got %d)" % forest_cells)
	default_count = tree_count({})
	var outside := tree_count({"forest_trees_outside_play":true})
	var clusters := tree_count({"scatter_boundary_trees":true})
	var none := tree_count({"scatter_inner_trees":false, "scatter_boundary_trees":false})
	var explicit := tree_count({"scatter_inner_trees":true, "forest_trees_outside_play":false, "scatter_boundary_trees":false})
	h.expect(default_count == explicit and outside > default_count and clusters > default_count and none == 0,
		"tree counts: default %d = explicit defaults %d; outside-play forest on %d > default; boundary clusters on %d > default (default has none); all off %d" % [default_count, explicit, outside, clusters, none])
	var fresh = Builder.new()
	h.expect(fresh.show_bridges == false and fresh.scatter_inner_trees == true and fresh.forest_trees_outside_play == false and fresh.scatter_boundary_trees == false and fresh.mountain_height_scale == 0.5,
		"the builder's declared defaults before building")
	h.expect(fresh.forest_trees_per_cell_min == 1 and fresh.forest_trees_per_cell_max == 3, "density 1-3 per cell (got %d-%d)" % [fresh.forest_trees_per_cell_min, fresh.forest_trees_per_cell_max])
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
		var tex = built[0].outer_ground_texture
		var import_text := FileAccess.get_file_as_string(OUTER + ".import") # a headless renderer keeps no image to ask
		h.expect(tex != null and tex.resource_path == OUTER and import_text.contains("mipmaps/generate=true"), "the game lab's outer ground is %s, imported with mipmaps (got %s)" % [OUTER, tex.resource_path if tex else null])
	await h.close_shell(self)
	print("[BLOCK7_DEFAULTS] checks=", h.checks, " failures=", h.failures, " forest cells=", forest_cells, " trees=", default_count)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
