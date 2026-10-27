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
# HUD block 4-6b: the selected unit's marker is kept clear: the shell hands its two parts' screen rects (face chip +
# badges, bar + number) over with the state ("avoid_rects") and choose_position moves off them to the best clear near
# candidate (below).
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
var avoid_rects := [] # block 4-6b: the selected unit's marker parts, from the last state
var hud_rects := [] # block 4-6c: the HUD's rects (rosters, actor panel, log, top HUD, top commands), from the last state
var reach_rect := Rect2() # block 4-6d: the selected unit and its marker together on screen, from the last state
var reach_enabled := true # block 4-6d: the candidates around reach_rect (off only in the tests' controls)
var chosen_step := 0 # block 4-6d: which step of choose_position placed the panel last (1-5, see there), for reports
var round_hud := false # block 4-6d: step 3 went round a HUD panel (reach_position), for reports

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
		avoid_rects = state.get("avoid_rects", [])
		hud_rects = state.get("hud_rects", [])
		reach_rect = state.get("reach_rect", Rect2())
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
	var best_index := -1
	var clear_position := Vector2.INF # block 4-6b: the best near candidate clear of the selected unit's marker
	var clear_score := INF
	var free_near := Vector2.INF # block 4-6c: the best near candidate clear of the marker and the HUD
	var free_near_score := INF
	var free_corner := Vector2.INF # block 4-6c: the best corner candidate clear of both
	var free_corner_score := INF
	for index in range(candidates.size()):
		var clamped := clamp_position(candidates[index], panel_size, viewport_size)
		var score := score_position(clamped, panel_size, cell_rects, anchor, index >= NEAR_CANDIDATE_COUNT) + float(index) * 0.01
		if score < best_score:
			best_score = score
			best_position = clamped
			best_index = index
		var rect := Rect2(clamped, panel_size)
		var marker_free := not covers(rect, avoid_rects)
		var both_free := marker_free and not covers(rect, hud_rects)
		if index < NEAR_CANDIDATE_COUNT and score < clear_score and marker_free:
			clear_score = score
			clear_position = clamped
		if both_free and index < NEAR_CANDIDATE_COUNT and score < free_near_score:
			free_near_score = score
			free_near = clamped
		if both_free and index >= NEAR_CANDIDATE_COUNT and score < free_corner_score:
			free_corner_score = score
			free_corner = clamped
	# Block 4-6c, in order (the 2D score unchanged, filters on top): 1. the 2D rule's choice when it is clear of the
	# selected unit's marker and the HUD; 2. the best near candidate clear of both; 3. block 4-6d: the best candidate
	# around the unit and its marker together (reach_rect) clear of both, worked out only here; 4. the best corner clear
	# of both (the panel may go far from the unit); 5. block 4-6b: the best near candidate clear of the marker alone, else
	# the 2D choice.
	var best_rect := Rect2(best_position, panel_size)
	chosen_step = 1
	if not covers(best_rect, avoid_rects) and not covers(best_rect, hud_rects): return best_position
	chosen_step = 2
	if free_near != Vector2.INF: return free_near
	chosen_step = 3
	var free_reach := reach_position(anchor, panel_size, cell_rects, viewport_size)
	if free_reach != Vector2.INF: return free_reach
	chosen_step = 4
	if free_corner != Vector2.INF: return free_corner
	chosen_step = 5
	if best_index < NEAR_CANDIDATE_COUNT and covers(best_rect, avoid_rects) and clear_position != Vector2.INF:
		return clear_position
	return best_position

func reach_position(anchor: Vector2, panel_size: Vector2, cell_rects: Array, viewport_size: Vector2) -> Vector2:
	# Block 4-6d: the best (2D score) candidate around reach_rect, kept on screen, clear of the marker and the HUD. When
	# none is clear (the unit stands under or beside a HUD panel), the same around reach_rect merged with each HUD rect in
	# the way (overlapping reach_rect or one of its candidates): the panel goes round that HUD panel, beside the unit.
	# INF when there is none.
	round_hud = false
	if not reach_enabled or not reach_rect.has_area(): return Vector2.INF
	var best := _best_around(reach_rect, anchor, panel_size, cell_rects, viewport_size)
	if best != Vector2.INF: return best
	var tried := reach_candidates(reach_rect, panel_size).map(func(p): return Rect2(clamp_position(p, panel_size, viewport_size), panel_size))
	tried.append(reach_rect)
	var best_score := INF
	for r in hud_rects:
		if not tried.any(func(t): return t.intersects(r)): continue
		var around := _best_around(reach_rect.merge(r), anchor, panel_size, cell_rects, viewport_size)
		if around == Vector2.INF: continue
		var score := score_position(around, panel_size, cell_rects, anchor, false)
		if score < best_score:
			best_score = score
			best = around
	round_hud = best != Vector2.INF
	return best

func _best_around(area: Rect2, anchor: Vector2, panel_size: Vector2, cell_rects: Array, viewport_size: Vector2) -> Vector2:
	var best := Vector2.INF
	var best_score := INF
	var candidates := reach_candidates(area, panel_size)
	for index in range(candidates.size()):
		var clamped := clamp_position(candidates[index], panel_size, viewport_size)
		var rect := Rect2(clamped, panel_size)
		if covers(rect, avoid_rects) or covers(rect, hud_rects): continue
		var score := score_position(clamped, panel_size, cell_rects, anchor, false) + float(index) * 0.01
		if score < best_score:
			best_score = score
			best = clamped
	return best

static func reach_candidates(area: Rect2, panel_size: Vector2) -> Array:
	# Block 4-6d: right and left (centred vertically), above and below (centred horizontally), then the four diagonals,
	# ANCHOR_GAP off the outer edge of the unit and its marker.
	var gap := ANCHOR_GAP
	var middle := area.get_center()
	var left := area.position.x - panel_size.x - gap
	var right := area.end.x + gap
	var above := area.position.y - panel_size.y - gap
	var below := area.end.y + gap
	return [
		Vector2(right, middle.y - panel_size.y * 0.5),
		Vector2(left, middle.y - panel_size.y * 0.5),
		Vector2(middle.x - panel_size.x * 0.5, above),
		Vector2(middle.x - panel_size.x * 0.5, below),
		Vector2(right, above),
		Vector2(left, above),
		Vector2(right, below),
		Vector2(left, below),
	]

static func covers(panel_rect: Rect2, rects: Array) -> bool:
	# Block 4-6b: the panel rect overlaps any of these rects.
	return rects.any(func(r): return panel_rect.intersects(r))

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
