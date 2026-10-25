extends Node
# HUD block 5: the 2D hero cut-in (HeroCutinOverlay with the shared
# hero_cutin_presentation.tscn, layer 9: above the HUD, under the shell's
# result panel), the battle toasts (RoundToastRoot: round, reinforcement and
# result; layer 8), the unique-skill still toast for a skill without a cut-in
# video (UniqueSkillToastRoot) and the ending video (the 2D result video plate)
# on the 3D shell. It plays what the scenario shell hands it and reads nothing
# from the engine. The 2D rules ported from battle_web_import_test.gd: the cut-in
# call (configure / set_playback_speed / play_cutin, _play_committed_hero_cutin),
# the toast queue, priorities and timings (_enqueue_battle_toast,
# _play_next_battle_toast, _show_battle_toast; non-result toasts dropped once the
# battle has a result), the still toast (_show_unique_skill_toast_over_unit) and
# the video plate (_get_battle_result_video_panel_rect, 4.35 s fallback).
# Toast and still-toast sounds are not played again: the engine inside the lab
# already plays them through GameAudio.
const VICTORY_TOAST_TEXTURE := preload("res://assets/web_battle/ui/results/battle_result_victory.png")
const DEFEAT_TOAST_TEXTURE := preload("res://assets/web_battle/ui/results/battle_result_defeat.png")
const REINFORCEMENT_TOAST_TEXTURE := preload("res://assets/web_battle/ui/reinforcement/reinforcement_arrival_toast_01.png")
const VICTORY_VIDEO_PATH := "res://assets/ui/result/videos/victory_result_theora_q8_1920x.ogv"
const DEFEAT_VIDEO_PATH := "res://assets/ui/result/videos/defeat_result_theora_q8_1920x.ogv"
const VIDEO_FALLBACK_SEC := 4.35
const VIDEO_WIDTH_RATIO := 0.88
const VIDEO_HEIGHT_RATIO := 9.0 / 16.0
const VIDEO_MAX_HEIGHT_RATIO := 0.60
const VIDEO_DIM_ALPHA := 0.64
const RESULT_SCALE := 1.18
const RESULT_HOLD_EXTRA := 2.0
const SKILL_ENTER := 0.14
const SKILL_HOLD := 0.08
const SKILL_EXIT := 0.15
const SKILL_FLASH := 0.08
const SKILL_FLASH_COLOR := Color(0.02, 0.0, 0.0, 0.66)
const SKILL_SLIDE_IN := 0.42
const SKILL_SLIDE_OUT := 0.24
const SKILL_START_SCALE := 0.85
const SKILL_PUNCH_SCALE := 1.12
const SKILL_EXIT_SCALE := 0.92
const SKILL_EXIT_UP := Vector2(0.0, -30.0)
const SKILL_PUNCH_IN := 0.08
const SKILL_PUNCH_SETTLE := 0.06
const SKILL_NAME_DELAY := 0.04
const SKILL_NAME_POP := 1.12
const SKILL_NAME_START := Vector2(0.0, 18.0)
const SKILL_WIDTH_RATIO := 0.96
const SKILL_HEIGHT_RATIO := 0.52
const SKILL_MAX_HEIGHT_RATIO := 0.58
const SKILL_MIN_HEIGHT := 320.0
const SKILL_INSET := 24.0
const SKILL_NAME_HEIGHT := 96.0
const SKILL_NAME_BOTTOM := 22.0
var cutin_overlay: CanvasLayer
var presentation # HeroCutinPresentation
var round_root: Control
var round_image: TextureRect
var round_label: Label
var round_root_scale: Vector2
var round_label_scale: Vector2
var round_default_texture: Texture2D
var skill_root: Control
var skill_burst: ColorRect
var skill_image: TextureRect
var skill_label: Label
var ending_layer: CanvasLayer
var ending_dim: ColorRect
var ending_video: VideoStreamPlayer
var on_ending_done: Callable
var cutin_playing := false
var cutin_tween_done := false
var cutin_started_msec := 0
var result_finalized := false # non-result toasts are dropped once the battle has a result (2D)
var pending_toasts: Array = []
var toast_playing := false
var toast_tween: Tween
var skill_tween: Tween
var ending_playing := false
var ending_state := ""
# Records for tests and the report: what was played, in order.
var cutins_played: Array = [] # {hero_id, skill_id, video, title, speed}
var toasts_played: Array = [] # {tag, text}
var still_toasts_played: Array = [] # {text, image}
var endings_played: Array = [] # {state, path, source}

func _ready() -> void:
	cutin_overlay = get_node("HeroCutinOverlay")
	presentation = get_node("HeroCutinOverlay/HeroCutinViewport/HeroCutinPresentation")
	presentation.cutin_finished.connect(func(): cutin_tween_done = true)
	cutin_overlay.visible = false
	round_root = get_node("ToastLayer/RoundToastRoot")
	round_image = round_root.get_node("RoundToastImage")
	round_label = round_root.get_node("RoundToastLabel")
	round_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_root.visible = false
	round_root_scale = round_root.scale
	round_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_default_texture = round_image.texture
	round_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_label_scale = round_label.scale
	round_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_set_shader_progress(0.0)
	skill_root = get_node("ToastLayer/UniqueSkillToastRoot")
	skill_burst = skill_root.get_node("UniqueSkillInkBurst")
	skill_image = skill_root.get_node("UniqueSkillCutinImage")
	skill_label = skill_root.get_node("UniqueSkillNameLabel")
	for c in [skill_root, skill_burst, skill_image, skill_label]: (c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	skill_root.visible = false
	ending_layer = CanvasLayer.new()
	ending_layer.name = "EndingVideoLayer"
	ending_layer.layer = 9
	add_child(ending_layer)
	ending_dim = ColorRect.new()
	ending_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ending_layer.add_child(ending_dim)
	ending_video = VideoStreamPlayer.new()
	ending_video.expand = true
	ending_video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ending_video.finished.connect(func(): _complete_ending("finished_signal"))
	ending_layer.add_child(ending_video)
	ending_layer.visible = false

func reset() -> void:
	# A new battle: nothing left over from the last one.
	end_cutin()
	pending_toasts.clear()
	if is_instance_valid(toast_tween): toast_tween.kill()
	if is_instance_valid(skill_tween): skill_tween.kill()
	toast_playing = false
	round_root.visible = false
	skill_root.visible = false
	result_finalized = false
	ending_playing = false
	ending_video.stop()
	ending_layer.visible = false
	cutins_played.clear()
	toasts_played.clear()
	still_toasts_played.clear()
	endings_played.clear()

# --- hero cut-in -----------------------------------------------------------

func play_cutin(entry: Dictionary, speed: float) -> bool:
	# speed: the shared scene's playback speed; the shell passes 1 / Engine.time_scale so the 4.01 s schedule (a
	# scaled-time tween) lasts 4.01 real seconds at every lab speed (김작 decision 3).
	# The 2D _play_committed_hero_cutin: load the video and title picture, configure, play. False when either fails.
	var video := ResourceLoader.load(str(entry.get("video_path", ""))) as VideoStream
	var title := ResourceLoader.load(str(entry.get("skill_title_texture_path", ""))) as Texture2D
	if video == null or title == null: return false
	cutin_overlay.visible = true
	presentation.configure(str(entry.get("hero_name", "")), str(entry.get("dialogue", "")), video, title,
		Vector2(float(entry.get("dialogue_offset_x", 0.0)), 0.0), Vector2(float(entry.get("hero_name_offset_x", 0.0)), 0.0))
	presentation.set_playback_speed(speed)
	presentation.play_cutin()
	cutin_playing = true
	cutin_tween_done = false
	cutin_started_msec = Time.get_ticks_msec()
	cutins_played.append({"hero_id":entry.get("hero_id", ""), "skill_id":entry.get("skill_id", ""), "video":entry.get("video_path", ""), "title":entry.get("skill_title_texture_path", ""), "speed":speed})
	return true

func end_cutin() -> void:
	if cutin_playing: presentation.stop_cutin()
	cutin_playing = false
	cutin_tween_done = false
	cutin_overlay.visible = false

func cutin_seconds() -> float:
	return (Time.get_ticks_msec() - cutin_started_msec) / 1000.0

# --- unique-skill still toast (no cut-in video) -----------------------------

func show_still_toast(texture: Texture2D, text: String, enemy: bool) -> void:
	# The 2D _show_unique_skill_toast_over_unit with its full-screen layout and timings.
	if is_instance_valid(skill_tween): skill_tween.kill()
	var viewport_size := get_viewport().get_visible_rect().size
	var width := viewport_size.x * SKILL_WIDTH_RATIO
	var height := clampf(viewport_size.y * SKILL_HEIGHT_RATIO, minf(SKILL_MIN_HEIGHT, viewport_size.y * SKILL_MAX_HEIGHT_RATIO), viewport_size.y * SKILL_MAX_HEIGHT_RATIO)
	var rect := Rect2(Vector2((viewport_size.x - width) * 0.5, (viewport_size.y - height) * 0.48), Vector2(width, height))
	var direction := -1.0 if enemy else 1.0
	var enter := rect.position - Vector2(viewport_size.x * SKILL_SLIDE_IN * direction, 0.0)
	var exit := rect.position + Vector2(viewport_size.x * SKILL_SLIDE_OUT * direction, 0.0)
	var name_position := Vector2(rect.position.x + SKILL_INSET, rect.position.y + rect.size.y - SKILL_NAME_HEIGHT - SKILL_NAME_BOTTOM)
	skill_root.position = Vector2.ZERO
	skill_root.size = viewport_size
	skill_root.pivot_offset = viewport_size * 0.5
	skill_burst.position = Vector2.ZERO
	skill_burst.size = viewport_size
	skill_image.size = rect.size
	skill_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	skill_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	skill_label.size = Vector2(rect.size.x - SKILL_INSET * 2.0, SKILL_NAME_HEIGHT)
	skill_root.visible = true
	skill_root.modulate = Color(1.0, 1.0, 1.0, 0.0)
	skill_root.scale = Vector2.ONE * SKILL_START_SCALE
	skill_burst.visible = true
	skill_burst.color = SKILL_FLASH_COLOR
	skill_burst.modulate = Color.WHITE
	skill_image.texture = texture
	skill_image.modulate = Color(1.0, 1.0, 1.0, 0.0)
	skill_image.position = enter
	skill_image.pivot_offset = rect.size * 0.5
	skill_label.text = text
	skill_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	skill_label.position = name_position + SKILL_NAME_START
	skill_label.scale = Vector2.ONE * SKILL_NAME_POP
	skill_label.pivot_offset = skill_label.size * 0.5
	still_toasts_played.append({"text":text, "image":texture.resource_path if texture else ""})
	skill_tween = create_tween()
	skill_tween.tween_property(skill_root, "modulate:a", 1.0, SKILL_PUNCH_IN).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	skill_tween.parallel().tween_property(skill_root, "scale", Vector2.ONE * SKILL_PUNCH_SCALE, SKILL_PUNCH_IN).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	skill_tween.parallel().tween_property(skill_burst, "modulate:a", 0.0, SKILL_FLASH).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	skill_tween.parallel().tween_property(skill_image, "position", rect.position, SKILL_ENTER).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	skill_tween.parallel().tween_property(skill_image, "modulate:a", 1.0, SKILL_ENTER).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	skill_tween.parallel().tween_property(skill_label, "position", name_position, SKILL_ENTER).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(SKILL_NAME_DELAY)
	skill_tween.parallel().tween_property(skill_label, "modulate:a", 1.0, SKILL_ENTER).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(SKILL_NAME_DELAY)
	skill_tween.parallel().tween_property(skill_label, "scale", Vector2.ONE, SKILL_ENTER).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(SKILL_NAME_DELAY)
	skill_tween.chain().tween_property(skill_root, "scale", Vector2.ONE, SKILL_PUNCH_SETTLE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	skill_tween.chain().tween_interval(SKILL_HOLD)
	skill_tween.tween_property(skill_root, "modulate:a", 0.0, SKILL_EXIT).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	skill_tween.parallel().tween_property(skill_root, "position", SKILL_EXIT_UP, SKILL_EXIT).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	skill_tween.parallel().tween_property(skill_root, "scale", Vector2.ONE * SKILL_EXIT_SCALE, SKILL_EXIT).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	skill_tween.parallel().tween_property(skill_image, "position", exit, SKILL_EXIT).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	skill_tween.parallel().tween_property(skill_image, "modulate:a", 0.0, SKILL_EXIT).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	skill_tween.parallel().tween_property(skill_label, "modulate:a", 0.0, SKILL_EXIT).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	skill_tween.parallel().tween_property(skill_label, "position", name_position + Vector2(0.0, -16.0), SKILL_EXIT).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	skill_tween.chain().tween_callback(func():
		skill_root.visible = false
		skill_burst.visible = false
		skill_image.texture = null)

# --- battle toasts ----------------------------------------------------------

func toast_round(round_number: int) -> void:
	enqueue_toast(round_default_texture, "BATTLE %d" % round_number, 1.15, 0, "round_start")

func toast_reinforcement() -> void:
	enqueue_toast(REINFORCEMENT_TOAST_TEXTURE, "지원군 도착!", 0.82, 100, "reinforcement_arrival")

func toast_end(victory: bool) -> void:
	enqueue_toast(VICTORY_TOAST_TEXTURE if victory else DEFEAT_TOAST_TEXTURE, "승리!" if victory else "패배", 1.1 + RESULT_HOLD_EXTRA, 200,
		"result_victory" if victory else "result_defeat", RESULT_SCALE)

func enqueue_toast(texture: Texture2D, text: String, hold: float, priority := 0, tag := "generic", scale_multiplier := 1.0) -> void:
	# _enqueue_battle_toast: a higher priority goes before lower ones; non-result toasts are dropped after the result.
	if result_finalized and not tag.begins_with("result_"): return
	var entry := {"texture":texture, "text":text, "hold":hold, "priority":priority, "tag":tag, "scale":scale_multiplier}
	var index := pending_toasts.size()
	for i in range(pending_toasts.size()):
		if priority > int(pending_toasts[i].priority):
			index = i
			break
	pending_toasts.insert(index, entry)
	_play_next_toast.call_deferred()

func _play_next_toast() -> void:
	if toast_playing or pending_toasts.is_empty(): return
	var entry: Dictionary = pending_toasts.pop_front()
	if result_finalized and not str(entry.tag).begins_with("result_"):
		_play_next_toast.call_deferred()
		return
	toasts_played.append({"tag":entry.tag, "text":entry.text})
	_show_toast(entry.texture, entry.text, entry.hold, maxf(entry.scale, 0.01))

func _show_toast(texture: Texture2D, text: String, hold: float, scale_multiplier: float) -> void:
	# _show_battle_toast: ink spread in 0.42 s, settle 0.12 s, hold, out 0.32 s.
	if is_instance_valid(toast_tween): toast_tween.kill()
	round_label.text = text
	round_label.visible = true
	round_label.modulate.a = 0.0
	round_label.scale = round_label_scale * 0.9 * scale_multiplier
	round_image.visible = true
	round_image.modulate = Color.WHITE
	round_image.texture = texture if texture != null else round_default_texture
	_set_shader_progress(0.0)
	round_root.visible = true
	round_root.modulate = Color(1.0, 1.0, 1.0, 0.0)
	round_root.scale = round_root_scale * 0.86 * scale_multiplier
	toast_playing = true
	toast_tween = create_tween()
	toast_tween.set_parallel(true)
	toast_tween.tween_method(_set_shader_progress, 0.0, 1.0, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	toast_tween.tween_property(round_root, "modulate:a", 1.0, 0.42)
	toast_tween.tween_property(round_root, "scale", round_root_scale * 1.06 * scale_multiplier, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	toast_tween.tween_property(round_label, "modulate:a", 1.0, 0.28).set_delay(0.05)
	toast_tween.tween_property(round_label, "scale", round_label_scale * scale_multiplier, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.05)
	toast_tween.set_parallel(false)
	toast_tween.chain().tween_property(round_root, "scale", round_root_scale * scale_multiplier, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	toast_tween.tween_interval(hold)
	toast_tween.set_parallel(true)
	toast_tween.tween_property(round_root, "modulate:a", 0.0, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	toast_tween.tween_property(round_root, "scale", round_root_scale * 1.12 * scale_multiplier, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	toast_tween.chain().tween_callback(_finish_toast)

func _finish_toast() -> void:
	round_root.visible = false
	round_root.modulate = Color.WHITE
	round_root.scale = round_root_scale
	round_label.modulate = Color.WHITE
	round_label.scale = round_label_scale
	round_image.texture = round_default_texture
	_set_shader_progress(0.0)
	toast_playing = false
	_play_next_toast.call_deferred()

func _set_shader_progress(progress: float) -> void:
	var material := round_image.material as ShaderMaterial
	if material != null and material.shader != null: material.set_shader_parameter("progress", progress)

# --- ending video -----------------------------------------------------------

func play_ending(state: String) -> bool:
	# The 2D result video plate (88% wide, 16:9, at most 60% high, dimmed backdrop); finished signal or 4.35 s fallback.
	var path := VICTORY_VIDEO_PATH if state == "victory" else (DEFEAT_VIDEO_PATH if state == "defeat" else "")
	var stream := ResourceLoader.load(path) as VideoStream if path != "" else null
	if stream == null: return false
	var viewport_size := get_viewport().get_visible_rect().size
	var max_height := viewport_size.y * VIDEO_MAX_HEIGHT_RATIO
	var width := minf(viewport_size.x * VIDEO_WIDTH_RATIO, maxf(0.0, viewport_size.x - 48.0))
	var height := width * VIDEO_HEIGHT_RATIO
	if height > max_height:
		height = max_height
		width = height / VIDEO_HEIGHT_RATIO
	ending_dim.position = Vector2.ZERO
	ending_dim.size = viewport_size
	ending_dim.color = Color(0.0196078, 0.0392157, 0.0588235, VIDEO_DIM_ALPHA)
	ending_video.stream = stream
	ending_video.size = Vector2(width, height)
	ending_video.position = (viewport_size - ending_video.size) * 0.5
	ending_layer.visible = true
	ending_playing = true
	ending_state = state
	endings_played.append({"state":state, "path":path, "source":""})
	ending_video.play()
	get_tree().create_timer(VIDEO_FALLBACK_SEC).timeout.connect(func(): if ending_state == state: _complete_ending("fallback_timer"))
	return true

func _complete_ending(source: String) -> void:
	if not ending_playing: return
	ending_playing = false
	ending_video.stop()
	ending_layer.visible = false
	endings_played[-1].source = source
	if on_ending_done.is_valid(): on_ending_done.call(ending_state)
