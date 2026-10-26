extends CanvasLayer
# HUD block 4-2: the 2D floating ally command panel (FloatingAllyCommandPanel,
# 176x214, five buttons) and the facing arrows (FacingArrowPanel, four buttons)
# copied as a 2D overlay above the 3D battlefield. It shows the state handed to
# it by the scenario shell (show_state) and reads nothing from the engine; its
# buttons call only the shell's callables (the lab's request_* and
# confirm_facing). The 2D rules are ported from battle_web_import_test.gd:
# panel and button styles (_configure_floating_ally_command_panel,
# _apply_floating_command_button_style), the twelve candidate positions, clamp
# and score (_choose/_get_.../_clamp/_score_floating_ally_command_panel_position
# and the FLOATING_COMMAND_PANEL_* constants), and the arrow tiles
# (_place_facing_arrow_button_on_cell, _apply_facing_arrow_button_style). Only
# the panel, its buttons and the arrows take the mouse.
const FacingTile := preload("res://scripts/battle3d/battle3d_facing_tile.gd") # block 4-3: the 2D tile colours on the projected diamond
const VIEWPORT_MARGIN := 12.0
const ANCHOR_GAP := 22.0
const GRID_AVOID_PADDING := 10.0
const DISTANCE_SCORE_WEIGHT := 8.0
const FAR_FALLBACK_SCORE := 1000000.0
const NEAR_CANDIDATE_COUNT := 8
const PANEL_SIZE := Vector2(176.0, 214.0)
const BUTTON_NAMES := ["FloatingBasicAttackButton", "FloatingUniqueSkillButton", "FloatingTacticsButton", "FloatingMoveButton", "FloatingWaitButton"]
const ARROW_NAMES := {"up":"FaceUpArrowButton", "down":"FaceDownArrowButton", "left":"FaceLeftArrowButton", "right":"FaceRightArrowButton"}
var on_attack: Callable
var on_skill: Callable
var on_strategy: Callable
var on_defend: Callable
var on_wait: Callable
var on_facing: Callable # (direction: String)
var panel: Panel
var arrows: Control
var shown: Dictionary = {"_": true} # last applied state; the nodes change only when it changes
var apply_count := 0
# Block 4-3: the panel background can be dragged; the dragged position holds for that ally turn only (turn_key from
# the shell), then the automatic placement comes back. Buttons keep their own clicks; the drag never reaches the world.
var dragging := false
var drag_offset := Vector2.ZERO
var drag_position := Vector2.INF
var drag_key := ""

func _ready() -> void:
	panel = get_node("FloatingAllyCommandPanel")
	arrows = get_node("FacingArrowPanel")
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.09, 0.1, 0.13, 1.0)
	panel_style.border_color = Color(0.84, 0.76, 0.54, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.gui_input.connect(_on_panel_input)
	var calls := [func(): on_attack.call(), func(): on_skill.call(), func(): on_strategy.call(), func(): on_defend.call(), func(): on_wait.call()]
	for index in BUTTON_NAMES.size():
		var button := button_at(index)
		_apply_button_style(button)
		button.pressed.connect(calls[index])
	arrows.visible = false
	arrows.mouse_filter = Control.MOUSE_FILTER_IGNORE # only the four arrow tiles take the mouse
	for direction in ARROW_NAMES:
		var arrow := arrow_for(direction)
		arrow.set_script(FacingTile)
		arrow = arrow_for(direction)
		_apply_arrow_style(arrow)
		arrow.pressed.connect(func(): on_facing.call(direction))

func button_at(index: int) -> Button:
	return panel.get_node(BUTTON_NAMES[index])

func arrow_for(direction: String) -> Button:
	return arrows.get_node(ARROW_NAMES[direction])

func panel_rect() -> Rect2:
	return panel.get_global_rect()

func show_state(state: Dictionary) -> void:
	# open, anchor (screen point of the unit), range_rects, buttons ([{text, disabled, tooltip}] x5),
	# facing_open, arrows ({direction: {text, center, size, valid}}).
	if state == shown: return
	shown = state.duplicate(true)
	apply_count += 1
	panel.visible = bool(state.get("open", false))
	if panel.visible:
		var buttons: Array = state.get("buttons", [])
		for index in BUTTON_NAMES.size():
			var value: Dictionary = buttons[index] if index < buttons.size() else {}
			var button := button_at(index)
			button.text = str(value.get("text", button.text))
			button.disabled = bool(value.get("disabled", true))
			button.tooltip_text = str(value.get("tooltip", ""))
		panel.size = PANEL_SIZE
		var key := str(state.get("turn_key", ""))
		if key != drag_key: drag_position = Vector2.INF # another ally turn or selection: back to the automatic placement
		panel.position = drag_position if drag_position != Vector2.INF else choose_position(state.get("anchor", Vector2.ZERO), PANEL_SIZE, state.get("range_rects", []))
	arrows.visible = bool(state.get("facing_open", false))
	if arrows.visible:
		arrows.position = Vector2.ZERO
		arrows.size = get_viewport().get_visible_rect().size
		var values: Dictionary = state.get("arrows", {})
		for direction in ARROW_NAMES:
			var value: Dictionary = values.get(direction, {})
			var arrow := arrow_for(direction)
			arrow.visible = bool(value.get("valid", false))
			arrow.disabled = not arrow.visible
			if not arrow.visible: continue
			arrow.text = "" # block 4-3: the tile draws the arrow along the screen direction (no grid glyph)
			arrow.set_tile(value.get("corners", PackedVector2Array()), value.get("direction", Vector2.RIGHT))

func _on_panel_input(event: InputEvent) -> void:
	# The panel's own background (between and around the buttons): press, move, release.
	# Positions are the events' own (local to the panel), so the grab point stays under the pointer.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		drag_offset = event.position
		panel.accept_event()
	elif event is InputEventMouseMotion and dragging:
		var viewport_size := get_viewport().get_visible_rect().size
		panel.position = clamp_position(panel.position + event.position - drag_offset, PANEL_SIZE, viewport_size)
		drag_position = panel.position
		drag_key = str(shown.get("turn_key", ""))
		panel.accept_event()

func choose_position(anchor: Vector2, panel_size: Vector2, cell_rects: Array) -> Vector2:
	# _choose_floating_ally_command_panel_position
	var viewport_size := get_viewport().get_visible_rect().size
	var candidates := candidate_positions(anchor, panel_size, viewport_size)
	var best_position := clamp_position(anchor + Vector2(52.0, -panel_size.y - ANCHOR_GAP), panel_size, viewport_size)
	var best_score := INF
	for index in range(candidates.size()):
		var clamped := clamp_position(candidates[index], panel_size, viewport_size)
		var score := score_position(clamped, panel_size, cell_rects, anchor, index >= NEAR_CANDIDATE_COUNT) + float(index) * 0.01
		if score < best_score:
			best_score = score
			best_position = clamped
	return best_position

static func candidate_positions(anchor: Vector2, panel_size: Vector2, viewport_size: Vector2) -> Array:
	# _get_floating_ally_command_panel_candidate_positions: eight near the unit, four screen corners.
	var gap := ANCHOR_GAP
	return [
		anchor + Vector2(gap, -panel_size.y * 0.5),
		anchor + Vector2(-panel_size.x - gap, -panel_size.y * 0.5),
		anchor + Vector2(-panel_size.x * 0.5, -panel_size.y - gap),
		anchor + Vector2(-panel_size.x * 0.5, gap),
		anchor + Vector2(gap, gap),
		anchor + Vector2(-panel_size.x - gap, gap),
		anchor + Vector2(gap, -panel_size.y - gap),
		anchor + Vector2(-panel_size.x - gap, -panel_size.y - gap),
		Vector2(viewport_size.x - panel_size.x - VIEWPORT_MARGIN, viewport_size.y - panel_size.y - VIEWPORT_MARGIN),
		Vector2(VIEWPORT_MARGIN, viewport_size.y - panel_size.y - VIEWPORT_MARGIN),
		Vector2(viewport_size.x - panel_size.x - VIEWPORT_MARGIN, VIEWPORT_MARGIN),
		Vector2(VIEWPORT_MARGIN, VIEWPORT_MARGIN),
	]

static func clamp_position(panel_position: Vector2, panel_size: Vector2, viewport_size: Vector2) -> Vector2:
	return Vector2(
		clampf(panel_position.x, VIEWPORT_MARGIN, maxf(VIEWPORT_MARGIN, viewport_size.x - panel_size.x - VIEWPORT_MARGIN)),
		clampf(panel_position.y, VIEWPORT_MARGIN, maxf(VIEWPORT_MARGIN, viewport_size.y - panel_size.y - VIEWPORT_MARGIN)))

static func score_position(panel_position: Vector2, panel_size: Vector2, cell_rects: Array, anchor: Vector2, is_far_fallback: bool) -> float:
	# _score_floating_ally_command_panel_position: overlap with the move-range cells + distance x 8 (+ 1e6 for a corner).
	var grown := Rect2(panel_position, panel_size).grow(GRID_AVOID_PADDING)
	var score := 0.0
	for cell_rect in cell_rects:
		var overlap := grown.intersection(cell_rect)
		if overlap.has_area(): score += overlap.get_area()
	score += (panel_position + panel_size * 0.5).distance_to(anchor) * DISTANCE_SCORE_WEIGHT
	if is_far_fallback: score += FAR_FALLBACK_SCORE
	return score

func _apply_button_style(button: Button) -> void:
	# _apply_floating_command_button_style
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_color_override("font_color", Color(0.97, 0.95, 0.9, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.72, 0.71, 0.68, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.99, 0.97, 0.94, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.94, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.98, 0.94, 1.0))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.16, 0.18, 0.23, 1.0)
	normal.border_color = Color(0.88, 0.8, 0.58, 1.0)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	var hover := normal.duplicate()
	hover.bg_color = Color(0.24, 0.27, 0.33, 1.0)
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.11, 0.12, 0.16, 1.0)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	disabled.border_color = Color(0.48, 0.48, 0.48, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)

func _apply_arrow_style(button: Button) -> void:
	# _apply_facing_arrow_button_style
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.flat = true
	for style_name in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78, 0.9))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.82, 0.95))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.98, 0.82, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.92, 0.82, 0.45, 0.6))
	button.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.0, 0.8))
	button.add_theme_constant_override("outline_size", 3)
	button.add_theme_font_size_override("font_size", 1) # block 4-3: the arrow is drawn (2D glyph size 36); no line height keeps the tile its cell size
