extends SceneTree

## Queue 44: battle3d engine capture tool - the 20x20 terrain preview scene (Terrain20x20_Preview.tscn) as the engine
## draws it, shot from a fixed camera, so 록비서's 2.5D art can be compared with the real engine picture.
## Needs a window (a real renderer); a headless run prints a notice and exits with code 2.
##
##   godot --path . --script res://tools/battle3d_capture.gd -- --camera B --size 1920x1080 --border off \
##         --paint C:\dev\eastwar_art_local --out C:\dev\eastwar_art_local\captures
##
## Options (all optional):
##   --camera A|B        A = the preview's own start view (1), B = 록비서 camera B (default B)
##   --size WxH          window / image size (default 1920x1080)
##   --border on|off     the play-area border line (default on)
##   --paint <folder>    board_paint.png -> in-board painted ground, outer_paint.png -> outside ground (each if present).
##                       Keep this folder OUTSIDE the repository (the repo is public, the art is a draft).
##   --outer-size <m>    outside ground world size (default 220, the shader's own; 180 for the 2.5D art)
##   --units on|off      the four preview units (default on)
##   --trees on|off      forest trees (default on)
##   --out <folder>      output folder (default <repo>/../EASTWAR_battle3d_captures)
## Writes <out>/battle3d_cam<A|B>_<WxH>_<options>.png and a .json next to it (camera, size, options, Godot, commit).
## Game scenes are not touched: every change is made on this run's own preview instance.

const PREVIEW_SCENE := "res://scenes/battle3d/Terrain20x20_Preview.tscn"
const EXIT_NEEDS_WINDOW := 2
const EXIT_BAD_ARGS := 3
const HEADLESS_MESSAGE := "[BATTLE3D_CAPTURE] 화면이 있는 실행 필요: --headless 없이 실행하세요 (headless display has no renderer)."
const BOARD_PAINT_FILE := "board_paint.png"
const OUTER_PAINT_FILE := "outer_paint.png"
const SETTLE_FRAMES := 2

## 록비서 camera B: orthographic, yaw 0.32, horizontal distance 43, height 28, focus (27, 0, 5.5), size 42 (pitch ~33°).
## A = the preview's own start view (terrain_preview.gd: board centre, yaw 0.32, distance 43, height 40, size 60).
const CAMERAS := {
	"B": {"yaw": 0.32, "distance": 43.0, "height": 28.0, "focus": Vector3(27.0, 0.0, 5.5), "size": 42.0},
	"A": {"yaw": 0.32, "distance": 43.0, "height": 40.0, "focus": Vector3(30.0, 0.0, 30.0), "size": 60.0},
}
const DEFAULTS := {
	"camera": "B", "size": Vector2i(1920, 1080), "border": true, "paint": "", "outer_size": 220.0,
	"units": true, "trees": true, "out": "",
}


func _initialize() -> void:
	call_deferred("_run")


## Parses the user arguments (after `--`). Returns the option dictionary, with "error" set when something is wrong.
static func parse_args(args: PackedStringArray) -> Dictionary:
	var options := DEFAULTS.duplicate(true)
	var i := 0
	while i < args.size():
		var key := args[i]
		var value := args[i + 1] if i + 1 < args.size() else ""
		i += 2
		match key:
			"--camera":
				if not CAMERAS.has(value.to_upper()):
					options["error"] = "--camera must be A or B (%s)" % value
				options["camera"] = value.to_upper()
			"--size":
				var parts := value.to_lower().split("x")
				if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int() or int(parts[0]) < 64 or int(parts[1]) < 64:
					options["error"] = "--size must be WxH, e.g. 1920x1080 (%s)" % value
				else:
					options["size"] = Vector2i(int(parts[0]), int(parts[1]))
			"--border", "--units", "--trees":
				if not ["on", "off"].has(value.to_lower()):
					options["error"] = "%s must be on or off (%s)" % [key, value]
				options[key.substr(2)] = value.to_lower() == "on"
			"--paint":
				options["paint"] = value
			"--outer-size":
				if not value.is_valid_float() or float(value) <= 0.0:
					options["error"] = "--outer-size must be a positive number (%s)" % value
				else:
					options["outer_size"] = float(value)
			"--out":
				options["out"] = value
			_:
				options["error"] = "unknown option %s" % key
				i -= 1   # a flag without a value: re-read the next item as a key
	return options


## The camera transform for a camera id: position = focus + (sin(yaw) d, h, cos(yaw) d), looking at the focus.
static func camera_pose(camera_id: String) -> Dictionary:
	var c: Dictionary = CAMERAS[camera_id]
	var focus: Vector3 = c.focus
	var position := focus + Vector3(sin(float(c.yaw)) * float(c.distance), float(c.height), cos(float(c.yaw)) * float(c.distance))
	return {"position": position, "focus": focus, "size": float(c.size), "pitch_degrees": rad_to_deg(atan2(float(c.height), float(c.distance)))}


## Shader parameters for the options (what the run writes on its preview's terrain material).
static func shader_overrides(options: Dictionary) -> Dictionary:
	return {"show_border_line": bool(options.border), "outer_ground_world_size": float(options.outer_size)}


static func output_stem(options: Dictionary) -> String:
	var size: Vector2i = options.size
	var tags: Array[String] = ["border_%s" % ("on" if options.border else "off")]
	if not str(options.paint).is_empty():
		tags.append("paint")
	if not is_equal_approx(float(options.outer_size), 220.0):
		tags.append("outer%d" % int(options.outer_size))
	if not options.units:
		tags.append("nounits")
	if not options.trees:
		tags.append("notrees")
	return "battle3d_cam%s_%dx%d_%s" % [options.camera, size.x, size.y, "_".join(tags)]


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		print(HEADLESS_MESSAGE)
		quit(EXIT_NEEDS_WINDOW)
		return
	var options := parse_args(OS.get_cmdline_user_args())
	if options.has("error"):
		print("[BATTLE3D_CAPTURE] %s" % options.error)
		quit(EXIT_BAD_ARGS)
		return
	var size: Vector2i = options.size
	DisplayServer.window_set_size(size)
	root.size = size
	var preview: Node3D = (load(PREVIEW_SCENE) as PackedScene).instantiate()
	root.add_child(preview)
	await process_frame
	var field: Node = preview.get("field")
	var material: ShaderMaterial = field.get("shader_material")
	var applied := _apply_options(preview, field, material, options)
	var camera: Camera3D = preview.get("camera")
	var pose := camera_pose(str(options.camera))
	camera.size = float(pose.size)
	camera.position = pose.position
	camera.look_at(pose.focus)
	for i in SETTLE_FRAMES:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var out_dir := str(options.out)
	if out_dir.is_empty():
		out_dir = ProjectSettings.globalize_path("res://").path_join("../EASTWAR_battle3d_captures").simplify_path()
	DirAccess.make_dir_recursive_absolute(out_dir)
	var png_path := out_dir.path_join(output_stem(options) + ".png")
	var saved := image.save_png(png_path)
	var record := {
		"png": png_path,
		"camera": str(options.camera),
		"camera_values": CAMERAS[options.camera].duplicate(),
		"camera_position": [pose.position.x, pose.position.y, pose.position.z],
		"pitch_degrees": pose.pitch_degrees,
		"requested_size": [size.x, size.y],
		"image_size": [image.get_width(), image.get_height()],
		"options": applied,
		"godot": Engine.get_version_info().get("string", ""),
		"commit": _commit_hash(),
	}
	(record.camera_values as Dictionary)["focus"] = [pose.focus.x, pose.focus.y, pose.focus.z]
	var json_file := FileAccess.open(out_dir.path_join(output_stem(options) + ".json"), FileAccess.WRITE)
	if json_file != null:
		json_file.store_string(JSON.stringify(record, "  "))
		json_file.close()
	print("[BATTLE3D_CAPTURE] %s %s %s" % ["saved" if saved == OK else "save failed", png_path, str(record.image_size)])
	quit(0 if saved == OK else 1)


## Applies the options to this run's preview only. Returns what was actually applied (for the .json).
func _apply_options(preview: Node, field: Node, material: ShaderMaterial, options: Dictionary) -> Dictionary:
	var applied := {"border": bool(options.border), "outer_size": float(options.outer_size), "units": bool(options.units), "trees": bool(options.trees),
		"board_paint": "", "outer_paint": "", "overlay_text": false}
	for key in shader_overrides(options):
		material.set_shader_parameter(key, shader_overrides(options)[key])
	field.set("show_border_line", bool(options.border))
	field.set("outer_ground_world_size", float(options.outer_size))
	var paint_dir := str(options.paint)
	if not paint_dir.is_empty():
		var board_tex := _load_texture(paint_dir.path_join(BOARD_PAINT_FILE))
		if board_tex != null:
			material.set_shader_parameter("board_paint_tex", board_tex)
			material.set_shader_parameter("use_board_paint_tex", true)
			applied.board_paint = paint_dir.path_join(BOARD_PAINT_FILE)
		var outer_tex := _load_texture(paint_dir.path_join(OUTER_PAINT_FILE))
		if outer_tex != null:
			material.set_shader_parameter("outer_ground_tex", outer_tex)
			material.set_shader_parameter("use_outer_ground_tex", true)
			applied.outer_paint = paint_dir.path_join(OUTER_PAINT_FILE)
	if not bool(options.units):
		for view in (preview.get("views") as Dictionary).values():
			(view as Node3D).visible = false
	if not bool(options.trees):
		field.set("scatter_inner_trees", false)
		field.call("_scatter_symbolic_boundary_trees")
		var forest = field.get("forest_multimesh")
		if forest != null:
			forest.visible = false
	# the preview's help text panel is not part of the engine picture
	for child in preview.get_children():
		if child is CanvasLayer:
			(child as CanvasLayer).visible = false
	return applied


## A PNG from outside the repository, with mipmaps (the shader samples it with linear + mipmap filtering).
func _load_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.load_from_file(path)
	if image == null or image.is_empty():
		push_warning("[BATTLE3D_CAPTURE] cannot read %s" % path)
		return null
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


func _commit_hash() -> String:
	var output: Array = []
	var code := OS.execute("git", ["-C", ProjectSettings.globalize_path("res://"), "rev-parse", "HEAD"], output, true)
	return str(output[0]).strip_edges() if code == 0 and not output.is_empty() else "unknown"
