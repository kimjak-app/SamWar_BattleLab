extends SceneTree

# Queue 44: the battle3d engine capture tool (tools/battle3d_capture.gd) and the in-board painted ground uniforms.
# Only what runs without a window:
#  1. the shader's new uniforms default to off (use_board_paint_tex = false, board_paint_world_size = 60); a builder
#     without a paint texture writes use_board_paint_tex = false and leaves every existing default as before
#     (border on, outer ground 220, outer ground on); a builder given a paint texture and the switch passes both
#  2. argument parsing: camera B = 록비서's numbers exactly (yaw 0.32, distance 43, height 28, focus (27, 0, 5.5),
#     size 42, pitch ~33°); --border off -> show_border_line false; the other options and bad values
#  3. a headless run of the tool prints the "화면이 있는 실행 필요" notice and exits with code 2
# Queue 44b (guide + billboard props):
#  4. defaults are queue 44's: --guide off, no props.json = no node added (the builder's node count unchanged)
#  5. --guide: parsed as a flag, the four output names, the .json keys; a headless --guide run exits with code 2
#  6. coordinates: the board corners and both bridge ends, mapped to guide pixels, equal the shader UV formulas
#     (board: xz / 60; outer: (xz - play_center) / outer_size + 0.5) within 1 px; the bridge ends match the built bridge
#  7. props.json: 5 good entries -> 5 props whose VISIBLE foot sits on the terrain (0.05 m) - transparent rows under the
#     foot skipped, or "base_px" given by hand (채비서 108) - Y-fixed billboards with alpha cut;
#     a missing image and an entry outside the outer ground are skipped with one warning each

const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const Capture = preload("res://tools/battle3d_capture.gd")
const SHADER_PATH := "res://scripts/battle3d/eastwar_terrain_20x20.gdshader"
const Layers = preload("res://tools/battle3d_capture_layers.gd")
const PROPS_DIR := "user://battle3d_capture_props_test"

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_shader_defaults()
	_check_builder()
	_check_args()
	_check_headless_exit()
	_check_guide_and_props()
	_finish()


## 1. the uniforms as declared in the shader source (the defaults the material uses when nothing is set)
func _check_shader_defaults() -> void:
	var code := FileAccess.get_file_as_string(SHADER_PATH)
	_expect(code.contains("uniform bool use_board_paint_tex = false;"), "1. shader: use_board_paint_tex defaults to false")
	_expect(code.contains("uniform sampler2D board_paint_tex : source_color, filter_linear_mipmap, repeat_disable;"), "1. shader: board_paint_tex is colour, linear + mipmap, no repeat")
	_expect(code.contains("uniform float board_paint_world_size = 60.0;"), "1. shader: board_paint_world_size defaults to 60")
	_expect(code.contains("uniform float outer_ground_world_size = 220.0;") and code.contains("uniform bool show_border_line = true;"), "1. shader: outer ground 220 and border line on stay the defaults")
	_expect(code.contains("if (use_board_paint_tex) {"), "1. shader: the painted ground only runs behind the switch")
	var shader := load(SHADER_PATH) as Shader
	var names := []
	if shader != null:
		for uniform in shader.get_shader_uniform_list():
			names.append(str(uniform.get("name", "")))
	_expect(names.has("use_board_paint_tex") and names.has("board_paint_tex") and names.has("board_paint_world_size"), "1. shader compiles with the three new uniforms (%d uniforms)" % names.size())


func _check_builder() -> void:
	var plain = Builder.new()
	_expect(not bool(plain.use_board_paint_texture) and plain.board_paint_texture == null and is_equal_approx(float(plain.board_paint_world_size), 60.0), "1. builder: paint off, no texture, 60 m by default")
	plain.setup_from_board(Board.new())
	var material: ShaderMaterial = plain.shader_material
	_expect(material != null and material.get_shader_parameter("use_board_paint_tex") == false and material.get_shader_parameter("board_paint_tex") == null,
		"1. builder without a paint texture: use_board_paint_tex false, no board_paint_tex (%s)" % str(material.get_shader_parameter("use_board_paint_tex") if material != null else "no material"))
	_expect(material != null and material.get_shader_parameter("show_border_line") == true and is_equal_approx(float(material.get_shader_parameter("outer_ground_world_size")), 220.0)
		and material.get_shader_parameter("use_outer_ground_tex") == true, "1. builder: border on, outer ground 220 and on, as before")
	plain.free()
	# switch on but no texture: stays off (nothing to sample)
	var no_tex = Builder.new()
	no_tex.use_board_paint_texture = true
	no_tex.setup_from_board(Board.new())
	_expect(no_tex.shader_material.get_shader_parameter("use_board_paint_tex") == false, "1. builder: switch on without a texture stays off")
	no_tex.free()
	var painted = Builder.new()
	var image := Image.create(8, 8, false, Image.FORMAT_RGB8)
	image.fill(Color(0.5, 0.25, 0.1))
	var texture := ImageTexture.create_from_image(image)
	painted.use_board_paint_texture = true
	painted.board_paint_texture = texture
	painted.board_paint_world_size = 54.0
	painted.setup_from_board(Board.new())
	_expect(painted.shader_material.get_shader_parameter("use_board_paint_tex") == true and painted.shader_material.get_shader_parameter("board_paint_tex") == texture
		and is_equal_approx(float(painted.shader_material.get_shader_parameter("board_paint_world_size")), 54.0), "1. builder: switch + texture + size are passed to the shader")
	painted.free()


## 2. arguments and the camera numbers
func _check_args() -> void:
	var defaults: Dictionary = Capture.parse_args(PackedStringArray())
	_expect(not defaults.has("error") and defaults.camera == "B" and defaults.size == Vector2i(1920, 1080) and defaults.border == true and defaults.units == true
		and defaults.trees == true and str(defaults.paint).is_empty() and is_equal_approx(float(defaults.outer_size), 220.0), "2. no arguments: camera B, 1920x1080, border on, units / trees on, no paint, outer 220")
	var b: Dictionary = Capture.CAMERAS["B"]
	_expect(is_equal_approx(float(b.yaw), 0.32) and is_equal_approx(float(b.distance), 43.0) and is_equal_approx(float(b.height), 28.0) and b.focus == Vector3(27.0, 0.0, 5.5) and is_equal_approx(float(b.size), 42.0),
		"2. camera B = yaw 0.32, distance 43, height 28, focus (27, 0, 5.5), size 42")
	var pose: Dictionary = Capture.camera_pose("B")
	var want := Vector3(27.0 + sin(0.32) * 43.0, 28.0, 5.5 + cos(0.32) * 43.0)
	_expect((pose.position as Vector3).is_equal_approx(want) and absf(float(pose.pitch_degrees) - 33.07) < 0.05 and is_equal_approx(float(pose.size), 42.0),
		"2. camera B pose %s, pitch %.2f°" % [str(pose.position), float(pose.pitch_degrees)])
	var a: Dictionary = Capture.camera_pose("A")
	_expect((a.position as Vector3).is_equal_approx(Vector3(30.0 + sin(0.32) * 43.0, 40.0, 30.0 + cos(0.32) * 43.0)) and is_equal_approx(float(a.size), 60.0), "2. camera A = the preview's start view")
	var off: Dictionary = Capture.parse_args(PackedStringArray(["--camera", "B", "--size", "1920x1080", "--border", "off", "--paint", "C:/art", "--out", "C:/out"]))
	_expect(not off.has("error") and off.border == false and Capture.shader_overrides(off).show_border_line == false and off.paint == "C:/art" and off.out == "C:/out",
		"2. --border off -> show_border_line false; --paint / --out kept")
	var more: Dictionary = Capture.parse_args(PackedStringArray(["--camera", "a", "--size", "1280x720", "--units", "off", "--trees", "off", "--outer-size", "180"]))
	_expect(not more.has("error") and more.camera == "A" and more.size == Vector2i(1280, 720) and more.units == false and more.trees == false and is_equal_approx(float(more.outer_size), 180.0)
		and is_equal_approx(float(Capture.shader_overrides(more).outer_ground_world_size), 180.0), "2. camera A, 1280x720, units / trees off, outer 180")
	_expect(Capture.output_stem(off) == "battle3d_camB_1920x1080_border_off_paint" and Capture.output_stem(more) == "battle3d_camA_1280x720_border_on_outer180_nounits_notrees",
		"2. output names (%s, %s)" % [Capture.output_stem(off), Capture.output_stem(more)])
	for bad in [["--camera", "C"], ["--size", "big"], ["--border", "maybe"], ["--outer-size", "-5"], ["--wat", "1"]]:
		_expect(Capture.parse_args(PackedStringArray(bad)).has("error"), "2. bad argument rejected: %s" % " ".join(bad))


## 3. the tool run headless: notice + exit code 2
func _check_headless_exit() -> void:
	var output: Array = []
	var code := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tools/battle3d_capture.gd", "--", "--camera", "B"], output, true)
	var text := "\n".join(output)
	_expect(code == Capture.EXIT_NEEDS_WINDOW, "3. headless run exits with code 2 (got %d)" % code)
	# the Korean part can come back in the console code page on Windows; the English tail is ASCII everywhere
	_expect(text.contains("[BATTLE3D_CAPTURE]") and (text.contains("화면이 있는 실행 필요") or text.contains("headless display has no renderer")), "3. headless run prints the notice")


## 4-7: queue 44b
func _check_guide_and_props() -> void:
	var defaults: Dictionary = Capture.parse_args(PackedStringArray())
	_expect(defaults.guide == false, "4. --guide is off by default")
	var builder = Builder.new()
	builder.setup_from_board(Board.new())
	var before := _count_nodes(builder)
	var none: Dictionary = Layers.add_props(builder, "", Callable(builder, "sample_smooth_height_at_world"), 220.0, Layers.play_center(builder))
	var empty_dir: Dictionary = Layers.add_props(builder, ProjectSettings.globalize_path("user://"), Callable(builder, "sample_smooth_height_at_world"), 220.0, Layers.play_center(builder))
	_expect(int(none.count) == 0 and none.root == null and int(empty_dir.count) == 0 and empty_dir.root == null and _count_nodes(builder) == before,
		"4. no props.json: no node added (%d nodes before and after)" % before)
	# 5. --guide
	var guide: Dictionary = Capture.parse_args(PackedStringArray(["--guide", "--outer-size", "180", "--out", "C:/guide"]))
	_expect(not guide.has("error") and guide.guide == true and is_equal_approx(float(guide.outer_size), 180.0) and guide.out == "C:/guide", "5. --guide is a flag; --outer-size / --out still read after it")
	_expect(Capture.guide_files() == ["guide_board_60m.png", "guide_board_60m.json", "guide_outer.png", "guide_outer.json"], "5. guide output names %s" % str(Capture.guide_files()))
	var center: Vector2 = Layers.play_center(builder)
	var info_board: Dictionary = Layers.guide_info("board", 180.0, center)
	var info_outer: Dictionary = Layers.guide_info("outer", 180.0, center)
	var keys := ["kind", "origin_m", "size_m", "axes", "resolution", "shader_uv", "play_center_m", "legend"]
	_expect(keys.all(func(k): return info_board.has(k) and info_outer.has(k)), "5. guide .json keys %s" % str(keys))
	_expect(info_board.origin_m == [0.0, 0.0] and is_equal_approx(float(info_board.size_m), 60.0) and info_board.resolution == [2048, 2048]
		and info_outer.origin_m == [center.x - 90.0, center.y - 90.0] and is_equal_approx(float(info_outer.size_m), 180.0),
		"5. guide origins / sizes: board (0,0) 60 m, outer %s 180 m around the play centre %s" % [str(info_outer.origin_m), str(center)])
	var output: Array = []
	var code := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tools/battle3d_capture.gd", "--", "--guide"], output, true)
	_expect(code == Capture.EXIT_NEEDS_WINDOW, "5. headless --guide exits with code 2 (got %d)" % code)
	# 6. coordinates
	var res := 2048.0
	var worst := 0.0
	var points: Array = [Vector2(0, 0), Vector2(60, 0), Vector2(0, 60), Vector2(60, 60)]
	for ends in Layers.bridge_ends(builder):
		points.append(ends[0])
		points.append(ends[1])
	for point in points:
		var shader_board: Vector2 = (point / 60.0) * res                                   # board_paint_tex UV * res
		var shader_outer: Vector2 = ((point - center) / 180.0 + Vector2(0.5, 0.5)) * res   # outer_ground_tex UV * res
		worst = maxf(worst, Layers.board_pixel(point.x, point.y).distance_to(shader_board))
		worst = maxf(worst, Layers.outer_pixel(point.x, point.y, 180.0, center).distance_to(shader_outer))
	_expect(points.size() == 6 and worst <= 1.0, "6. corners + bridge ends: guide pixel = shader UV within 1 px (worst %.3f px, %d points)" % [worst, points.size()])
	_expect(Layers.board_pixel(60, 60) == Vector2(2048, 2048) and Layers.outer_pixel(center.x, center.y, 180.0, center) == Vector2(1024, 1024), "6. board corner (60,60) = pixel 2048; the play centre = outer pixel 1024")
	var bridge_root: Node = builder.get("bridges_root")
	var bridge: Node3D = bridge_root.get_child(0) if bridge_root != null and bridge_root.get_child_count() > 0 else null
	var ends0: Array = Layers.bridge_ends(builder)[0] if not Layers.bridge_ends(builder).is_empty() else []
	_expect(bridge != null and ends0.size() == 2 and absf((ends0[0] + ends0[1]).x * 0.5 - bridge.position.x) < 0.01 and absf(ends0[0].y - bridge.position.z) < 0.01,
		"6. the guide's bridge ends are the two ends of the built bridge (%s)" % str(bridge.position if bridge != null else "none"))
	# 7. props
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PROPS_DIR))
	var tree := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	tree.fill(Color(0.2, 0.5, 0.2, 1.0))
	tree.save_png(ProjectSettings.globalize_path(PROPS_DIR + "/tree_a.png"))
	var entries := [
		{"image": "tree_a.png", "x": 12.5, "z": 30.0, "height_m": 4.0, "anchor": "bottom", "shadow": true},
		{"image": "tree_a.png", "x": 40.0, "z": 8.0, "height_m": 3.0, "anchor": "bottom", "shadow": false},
		{"image": "tree_a.png", "x": 27.0, "z": 50.0, "height_m": 5.0, "anchor": "bottom", "shadow": true},
		{"image": "missing.png", "x": 10.0, "z": 10.0, "height_m": 3.0},
		{"image": "tree_a.png", "x": 500.0, "z": 10.0, "height_m": 3.0},
		# 채비서 108: a picture with 3 transparent rows under its foot, and a foot given by hand ("base_px")
		{"image": "tree_pad.png", "x": 20.0, "z": 20.0, "height_m": 4.0, "anchor": "bottom", "shadow": true},
		{"image": "tree_a.png", "x": 33.0, "z": 25.0, "height_m": 4.0, "anchor": "bottom", "base_px": 2},
	]
	var padded := Image.create(8, 10, false, Image.FORMAT_RGBA8)
	padded.fill(Color(0, 0, 0, 0))
	padded.fill_rect(Rect2i(0, 0, 8, 7), Color(0.2, 0.5, 0.2, 1.0))
	padded.set_pixel(3, 7, Color(0.2, 0.5, 0.2, 0.3))   # a faint pixel the alpha cut drops: not the foot
	padded.save_png(ProjectSettings.globalize_path(PROPS_DIR + "/tree_pad.png"))
	var want_foot := {"Prop_0": [8, 0], "Prop_1": [8, 0], "Prop_2": [8, 0], "Prop_5": [10, 3], "Prop_6": [8, 2]}   # [image height, foot rows]
	var file := FileAccess.open(PROPS_DIR + "/props.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(entries))
	file.close()
	var height_at := Callable(builder, "sample_smooth_height_at_world")
	var props: Dictionary = Layers.add_props(builder, ProjectSettings.globalize_path(PROPS_DIR), height_at, 180.0, center)
	var root3d: Node3D = props.root
	_expect(int(props.count) == 5 and root3d != null and root3d.get_child_count() == 5, "7. 5 good entries -> 5 props (%d)" % int(props.count))
	_expect((props.warnings as Array).size() == 2, "7. the missing image and the far entry are skipped with one warning each %s" % str(props.warnings))
	_expect(Layers.transparent_bottom_rows(padded) == 3 and Layers.transparent_bottom_rows(tree) == 0, "7. transparent rows under the foot: 3 (padded, faint pixel ignored), 0 (opaque)")
	var base_bad: Array = []
	if root3d != null:
		for prop in root3d.get_children():
			var sprite := prop.get_node("Picture") as Sprite3D
			var foot: Array = want_foot.get(prop.name, [0, 0])
			# the visible foot: the image's lower edge raised by the transparent / given rows
			var visible_foot: float = (prop as Node3D).position.y + sprite.position.y - sprite.pixel_size * float(foot[0]) * 0.5 + sprite.pixel_size * float(foot[1])
			var ground := float(height_at.call((prop as Node3D).position.x, (prop as Node3D).position.z))
			if absf(visible_foot - ground) > 0.05 or int(prop.get_meta("base_px", -1)) != int(foot[1]) or sprite.billboard != BaseMaterial3D.BILLBOARD_FIXED_Y or sprite.alpha_cut != SpriteBase3D.ALPHA_CUT_DISCARD:
				base_bad.append("%s foot %.3f ground %.3f rows %s" % [prop.name, visible_foot, ground, str(prop.get_meta("base_px", -1))])
		_expect(base_bad.is_empty(), "7. each picture's VISIBLE foot stands on the terrain (within 0.05 m; padded and base_px pictures too), Y-fixed billboard, alpha cut %s" % str(base_bad))
		_expect(root3d.get_node("Prop_0").has_node("GroundShadow") and not root3d.get_node("Prop_1").has_node("GroundShadow"), "7. shadow: true lays a ground shadow, false does not")
	builder.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROPS_DIR + "/props.json"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROPS_DIR + "/tree_a.png"))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PROPS_DIR + "/tree_pad.png"))


func _count_nodes(node: Node) -> int:
	var count := 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[BATTLE3D_CAPTURE_FAIL] %s" % label)


func _finish() -> void:
	print("[BATTLE3D_CAPTURE] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
