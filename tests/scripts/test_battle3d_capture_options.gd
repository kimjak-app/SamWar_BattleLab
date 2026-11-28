extends SceneTree

# Queue 44: the battle3d engine capture tool (tools/battle3d_capture.gd) and the in-board painted ground uniforms.
# Only what runs without a window:
#  1. the shader's new uniforms default to off (use_board_paint_tex = false, board_paint_world_size = 60); a builder
#     without a paint texture writes use_board_paint_tex = false and leaves every existing default as before
#     (border on, outer ground 220, outer ground on); a builder given a paint texture and the switch passes both
#  2. argument parsing: camera B = 록비서's numbers exactly (yaw 0.32, distance 43, height 28, focus (27, 0, 5.5),
#     size 42, pitch ~33°); --border off -> show_border_line false; the other options and bad values
#  3. a headless run of the tool prints the "화면이 있는 실행 필요" notice and exits with code 2

const Board = preload("res://scripts/battle3d/lab_heightfield.gd")
const Builder = preload("res://scripts/battle3d/terrain_board_builder.gd")
const Capture = preload("res://tools/battle3d_capture.gd")
const SHADER_PATH := "res://scripts/battle3d/eastwar_terrain_20x20.gdshader"

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_shader_defaults()
	_check_builder()
	_check_args()
	_check_headless_exit()
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


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[BATTLE3D_CAPTURE_FAIL] %s" % label)


func _finish() -> void:
	print("[BATTLE3D_CAPTURE] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
