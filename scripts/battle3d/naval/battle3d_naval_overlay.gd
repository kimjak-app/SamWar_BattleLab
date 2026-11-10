extends CanvasLayer
# Queue 35: the naval scene's additions on top of the 3D battle HUD, as one node under the lab.
# - The battle's title ("한산도 대첩") under the top HUD. No place names on the map.
# - Capture, in debug / editor runs only: F9 saves the screen as it is (HUD included), Shift+F9 saves it without any 2D
#   (HUD, markers, this title) by switching the window's 2D drawing off for the one captured frame. Files go to
#   C:\eastwar_tmp\naval\captures\hansando_<time>.png, or user://captures/ when that folder cannot be made.
# Reads nothing from the engine and changes nothing in the battle.
const CAPTURE_DIR := "C:/eastwar_tmp/naval/captures"
const FALLBACK_DIR := "user://captures"
const TITLE_GAP := 8.0 # px under the top HUD frame
var title := ""
var shell: Node = null
var title_label := Label.new()
var captures: Array[String] = [] # saved file paths, in order
# Reply 2: F8 (debug / editor runs) steps through the scenario's sea presets (`sea.presets`: a name and the values that
# differ from the base block); the name shows at the top left for PRESET_SECONDS.
const PRESET_SECONDS := 2.0
var sea := {}
var preset_index := 0
var preset_label := Label.new()
var preset_left := 0.0
var capturing := false

func _ready() -> void:
	layer = 5 # with the HUD layers (5-10), under the shell's panels
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color("f4e7c4"))
	title_label.add_theme_color_override("font_outline_color", Color("241c14"))
	title_label.add_theme_constant_override("outline_size", 8)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_label)
	preset_label.position = Vector2(24, 20)
	preset_label.add_theme_font_size_override("font_size", 24)
	preset_label.add_theme_color_override("font_color", Color("f4e7c4"))
	preset_label.add_theme_color_override("font_outline_color", Color("241c14"))
	preset_label.add_theme_constant_override("outline_size", 8)
	preset_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preset_label.visible = false
	add_child(preset_label)
	if not title.is_empty(): DisplayServer.window_set_title.call_deferred("EASTWAR | %s" % title)

func _process(delta: float) -> void:
	if preset_left > 0.0:
		preset_left -= delta
		preset_label.visible = preset_left > 0.0
	# Centred under the top HUD frame while the HUD is shown (the battle is running).
	var hud = shell.top_hud if shell != null and is_instance_valid(shell) else null
	title_label.visible = hud != null and hud.visible and not title.is_empty()
	if not title_label.visible: return
	var frame: Rect2 = hud.frame_rect()
	var size := title_label.get_minimum_size()
	title_label.position = Vector2(frame.get_center().x - size.x * 0.5, frame.end.y + TITLE_GAP)

func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or capturing: return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		get_viewport().set_input_as_handled()
		capture(event.shift_pressed)
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		get_viewport().set_input_as_handled()
		show_sea_preset(preset_index + 1)

func sea_presets() -> Array:
	var presets: Variant = sea.get("presets", [])
	return presets if presets is Array else []

## Applies preset `index` (wrapping) on top of the scenario's base sea values and shows its name. Returns the name.
func show_sea_preset(index: int) -> String:
	var presets := sea_presets()
	var builder := get_parent().find_child("Sea", true, false)
	if presets.is_empty() or builder == null: return ""
	preset_index = posmod(index, presets.size())
	var values := sea.duplicate(true)
	values.merge(presets[preset_index], true)
	builder.get_parent().apply_sea(values)
	preset_label.text = "바다 %d/%d · %s" % [preset_index + 1, presets.size(), String(presets[preset_index].get("name", ""))]
	preset_label.visible = true
	preset_left = PRESET_SECONDS
	return String(presets[preset_index].get("name", ""))

static func capture_dir() -> String:
	if DirAccess.make_dir_recursive_absolute(CAPTURE_DIR) == OK or DirAccess.dir_exists_absolute(CAPTURE_DIR): return CAPTURE_DIR
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FALLBACK_DIR))
	return FALLBACK_DIR

static func capture_path(dir: String, without_hud: bool, at: Dictionary, msec: int) -> String:
	return "%s/hansando_%04d%02d%02d_%02d%02d%02d_%03d%s.png" % [dir, at.year, at.month, at.day, at.hour, at.minute, at.second, msec % 1000, "_nohud" if without_hud else ""]

## Saves the window as a PNG and returns its path ("" when there is no picture to save, as in a headless run).
func capture(without_hud: bool) -> String:
	if DisplayServer.get_name() == "headless": return "" # nothing is drawn, and no drawn-frame signal comes
	capturing = true
	var viewport := get_viewport()
	if without_hud:
		RenderingServer.viewport_set_disable_2d(viewport.get_viewport_rid(), true)
		await RenderingServer.frame_post_draw # a frame drawn without 2D
	await RenderingServer.frame_post_draw
	var image: Image = viewport.get_texture().get_image()
	if without_hud: RenderingServer.viewport_set_disable_2d(viewport.get_viewport_rid(), false)
	capturing = false
	if image == null or image.is_empty(): return ""
	var path := capture_path(capture_dir(), without_hud, Time.get_datetime_dict_from_system(), Time.get_ticks_msec())
	if image.save_png(path) != OK: return ""
	captures.append(path)
	print("[NAVAL_CAPTURE] %s" % path)
	return path
