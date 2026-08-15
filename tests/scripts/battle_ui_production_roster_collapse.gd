extends Node

## Test-scene production presentation bridge.
## Keeps roster collapse/portrait-only presentation and owns the temporary
## top-right global action button presentation until the HUD is promoted out
## of the production test scene.

const SLOT_NAMES := ["Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"]
const TRANSITION_DURATION := 0.30
const PORTRAIT_SIZE := Vector2(72.0, 72.0)
const PORTRAIT_STEP := 78.0
const PORTRAIT_TOP := 250.0

const TOP_ACTION_BUTTON_SIZE := Vector2(86.0, 86.0)
const TOP_ACTION_BUTTON_GAP := 18.0
const TOP_ACTION_BUTTON_Y := 12.0
const TOP_ACTION_HOVER_SCALE := Vector2(1.07, 1.07)
const TOP_ACTION_PRESS_SCALE := Vector2(0.94, 0.94)
const TOP_ACTION_NORMAL_SCALE := Vector2.ONE
const TOP_ACTION_TWEEN_DURATION := 0.11
const TOP_ACTION_AUTO_TEXTURE := preload("res://assets/ui/battle/top_actions/auto_battle_button.png")
const TOP_ACTION_END_TURN_TEXTURE := preload("res://assets/ui/battle/top_actions/end_turn_button.png")
const TOP_ACTION_RETREAT_TEXTURE := preload("res://assets/ui/battle/top_actions/retreat_button.png")

var _controller: Node
var _hud_root: Control
var _collapsed := {"Ally": false, "Enemy": false}
var _transitioning := {"Ally": false, "Enemy": false}
var _tweens: Dictionary = {}
var _overlays: Dictionary = {}
var _portrait_items: Dictionary = {}
var _expanded_banner_positions: Dictionary = {}
var _expanded_roster_modulates: Dictionary = {}
var _top_action_tweens: Dictionary = {}


func _ready() -> void:
	_controller = get_parent()
	_hud_root = _controller.get_node_or_null("BattleUI/ProductionHudRoot") as Control
	if _controller == null or _hud_root == null:
		return
	for side_name in ["Ally", "Enemy"]:
		_setup_side(side_name)
	_setup_top_action_buttons()
	set_process(true)


func _exit_tree() -> void:
	for tween in _tweens.values():
		if tween is Tween and (tween as Tween).is_valid():
			(tween as Tween).kill()
	for tween in _top_action_tweens.values():
		if tween is Tween and (tween as Tween).is_valid():
			(tween as Tween).kill()


func _process(_delta: float) -> void:
	for side_name in ["Ally", "Enemy"]:
		if bool(_collapsed.get(side_name, false)) and not bool(_transitioning.get(side_name, false)):
			_refresh_portrait_overlay(side_name)
			# The production roster bridge may restore individual card visibility after
			# a unit selection or stat refresh. Keeping its common parent hidden makes
			# that refresh harmless while this presentation mode is active.
			_apply_roster_display_mode(side_name)


func _setup_top_action_buttons() -> void:
	var command_bar := _controller.get_node_or_null("BattleUI/CommandBar") as Control
	if command_bar == null:
		return
	var buttons: Array[TextureButton] = []
	var auto_button := command_bar.get_node_or_null("AutoBattleButton") as TextureButton
	var end_turn_button := command_bar.get_node_or_null("EndTurnButton") as TextureButton
	var retreat_button := command_bar.get_node_or_null("RetreatButton") as TextureButton
	if auto_button != null:
		_configure_top_action_button(auto_button, TOP_ACTION_AUTO_TEXTURE, 0)
		buttons.append(auto_button)
	if end_turn_button != null:
		_configure_top_action_button(end_turn_button, TOP_ACTION_END_TURN_TEXTURE, 1)
		buttons.append(end_turn_button)
	if retreat_button != null:
		retreat_button.disabled = false
		_configure_top_action_button(retreat_button, TOP_ACTION_RETREAT_TEXTURE, 2)
		if not retreat_button.pressed.is_connected(_on_top_action_retreat_pressed):
			retreat_button.pressed.connect(_on_top_action_retreat_pressed)
		buttons.append(retreat_button)
	for button in buttons:
		button.move_to_front()


func _configure_top_action_button(button: TextureButton, texture: Texture2D, index: int) -> void:
	var start_x := 118.0
	button.position = Vector2(start_x + float(index) * (TOP_ACTION_BUTTON_SIZE.x + TOP_ACTION_BUTTON_GAP), TOP_ACTION_BUTTON_Y)
	button.size = TOP_ACTION_BUTTON_SIZE
	button.pivot_offset = TOP_ACTION_BUTTON_SIZE * 0.5
	button.scale = TOP_ACTION_NORMAL_SCALE
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.texture_normal = texture
	button.texture_hover = texture
	button.texture_pressed = texture
	button.texture_disabled = texture
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if not button.mouse_entered.is_connected(_on_top_action_mouse_entered.bind(button)):
		button.mouse_entered.connect(_on_top_action_mouse_entered.bind(button))
	if not button.mouse_exited.is_connected(_on_top_action_mouse_exited.bind(button)):
		button.mouse_exited.connect(_on_top_action_mouse_exited.bind(button))
	if not button.button_down.is_connected(_on_top_action_button_down.bind(button)):
		button.button_down.connect(_on_top_action_button_down.bind(button))
	if not button.button_up.is_connected(_on_top_action_button_up.bind(button)):
		button.button_up.connect(_on_top_action_button_up.bind(button))


func _on_top_action_mouse_entered(button: TextureButton) -> void:
	if button == null or button.disabled:
		return
	_tween_top_action_scale(button, TOP_ACTION_HOVER_SCALE)


func _on_top_action_mouse_exited(button: TextureButton) -> void:
	if button == null:
		return
	_tween_top_action_scale(button, TOP_ACTION_NORMAL_SCALE)


func _on_top_action_button_down(button: TextureButton) -> void:
	if button == null or button.disabled:
		return
	_tween_top_action_scale(button, TOP_ACTION_PRESS_SCALE, 0.07)


func _on_top_action_button_up(button: TextureButton) -> void:
	if button == null or button.disabled:
		return
	var target_scale := TOP_ACTION_HOVER_SCALE if button.is_hovered() else TOP_ACTION_NORMAL_SCALE
	_tween_top_action_scale(button, target_scale, 0.09)


func _tween_top_action_scale(button: TextureButton, target_scale: Vector2, duration := TOP_ACTION_TWEEN_DURATION) -> void:
	var key := button.get_instance_id()
	var previous := _top_action_tweens.get(key, null) as Tween
	if previous != null and previous.is_valid():
		previous.kill()
	var tween := create_tween()
	_top_action_tweens[key] = tween
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)


func _on_top_action_retreat_pressed() -> void:
	if _controller == null:
		return
	if bool(_controller.get("is_demo_animating")):
		return
	if bool(_controller.get("is_battle_result_video_playing")):
		return
	if _controller.has_method("_stop_full_auto_battle"):
		_controller.call("_stop_full_auto_battle", "player retreat")
	_controller.set("battle_result_reason", "retreat")
	_controller.set("forced_battle_result_state", "defeat")
	if _controller.has_method("_append_battle_log"):
		_controller.call("_append_battle_log", "아군이 전장에서 후퇴합니다.")
	if _controller.has_method("_try_show_battle_result_toast_if_needed"):
		_controller.call("_try_show_battle_result_toast_if_needed")
	if _controller.has_method("_refresh_worldmap_result_return_button"):
		_controller.call("_refresh_worldmap_result_return_button")


func _setup_side(side_name: String) -> void:
	var banner := _get_banner(side_name)
	if banner != null:
		_expanded_banner_positions[side_name] = banner.position
		banner.mouse_filter = Control.MOUSE_FILTER_STOP
		banner.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		banner.gui_input.connect(_on_banner_gui_input.bind(side_name))
	var overlay := Control.new()
	overlay.name = "%sRosterPortraitOnlyLayer" % side_name
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = false
	_hud_root.add_child(overlay)
	_overlays[side_name] = overlay
	var items: Array = []
	for index in SLOT_NAMES.size():
		var border := Panel.new()
		border.name = "%sPortraitBorder%02d" % [side_name, index + 1]
		border.position = _collapsed_portrait_position(side_name, index) - Vector2(2.0, 2.0)
		border.size = PORTRAIT_SIZE + Vector2(4.0, 4.0)
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		border.visible = false
		overlay.add_child(border)
		var portrait := TextureRect.new()
		portrait.name = "%sPortraitOnly%02d" % [side_name, index + 1]
		portrait.position = _collapsed_portrait_position(side_name, index)
		portrait.size = PORTRAIT_SIZE
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_STOP if side_name == "Ally" else Control.MOUSE_FILTER_IGNORE
		if side_name == "Ally":
			portrait.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			portrait.gui_input.connect(_on_ally_portrait_gui_input.bind(index))
		overlay.add_child(portrait)
		items.append({"border": border, "portrait": portrait})
	_portrait_items[side_name] = items


func _on_banner_gui_input(event: InputEvent, side_name: String) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	if bool(_transitioning.get(side_name, false)):
		return
	_set_collapsed(side_name, not bool(_collapsed.get(side_name, false)))
	get_viewport().set_input_as_handled()


func _on_ally_portrait_gui_input(event: InputEvent, index: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	var unit: Variant = _get_unit_for_side_index("Ally", index)
	if unit != null and _controller != null:
		_controller.call("_select_ally_unit", unit, true, true, false)
	get_viewport().set_input_as_handled()


func _set_collapsed(side_name: String, should_collapse: bool) -> void:
	if _controller == null:
		return
	_transitioning[side_name] = true
	var tween := create_tween()
	_tweens[side_name] = tween
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	if should_collapse:
		_begin_collapse(side_name, tween)
	else:
		_begin_expand(side_name, tween)


func _begin_collapse(side_name: String, tween: Tween) -> void:
	var overlay := _overlays.get(side_name, null) as Control
	var roster := _get_roster(side_name)
	if overlay == null or roster == null:
		_transitioning[side_name] = false
		return
	_expanded_roster_modulates[side_name] = roster.modulate
	_refresh_portrait_overlay(side_name)
	overlay.visible = true
	overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	tween.parallel().tween_property(roster, "modulate:a", 0.0, TRANSITION_DURATION)
	tween.parallel().tween_property(overlay, "modulate:a", 1.0, TRANSITION_DURATION)
	var banner := _get_banner(side_name)
	if banner != null:
		tween.parallel().tween_property(banner, "position", _collapsed_banner_position(side_name), TRANSITION_DURATION)
	tween.tween_callback(_finish_collapse.bind(side_name))


func _finish_collapse(side_name: String) -> void:
	if not is_inside_tree():
		return
	_collapsed[side_name] = true
	_transitioning[side_name] = false
	_apply_roster_display_mode(side_name)


func _begin_expand(side_name: String, tween: Tween) -> void:
	var roster := _get_roster(side_name)
	if roster != null:
		roster.visible = true
		var base_color: Color = _expanded_roster_modulates.get(side_name, Color.WHITE)
		roster.modulate = Color(base_color.r, base_color.g, base_color.b, 0.0)
		tween.parallel().tween_property(roster, "modulate:a", base_color.a, TRANSITION_DURATION)
	var overlay := _overlays.get(side_name, null) as Control
	if overlay != null:
		tween.parallel().tween_property(overlay, "modulate:a", 0.0, TRANSITION_DURATION)
	var banner := _get_banner(side_name)
	if banner != null:
		var expanded_position: Vector2 = _expanded_banner_positions.get(side_name, banner.position)
		tween.parallel().tween_property(banner, "position", expanded_position, TRANSITION_DURATION)
	tween.tween_callback(_finish_expand.bind(side_name))


func _finish_expand(side_name: String) -> void:
	if not is_inside_tree():
		return
	_collapsed[side_name] = false
	_transitioning[side_name] = false
	_apply_roster_display_mode(side_name)


func _apply_roster_display_mode(side_name: String, animated := false) -> void:
	# Persistent banners are ProductionHudRoot siblings, never roster children.
	# This is intentionally idempotent so any roster refresh can reapply it.
	var roster := _get_roster(side_name)
	var overlay := _overlays.get(side_name, null) as Control
	var banner := _get_banner(side_name)
	if roster == null or overlay == null:
		return
	var is_collapsed := bool(_collapsed.get(side_name, false))
	if not animated:
		if is_collapsed:
			roster.visible = false
			roster.modulate = _expanded_roster_modulates.get(side_name, Color.WHITE)
			overlay.visible = true
			overlay.modulate = Color.WHITE
			_refresh_portrait_overlay(side_name)
		else:
			roster.visible = true
			roster.modulate = _expanded_roster_modulates.get(side_name, Color.WHITE)
			overlay.visible = false
			overlay.modulate = Color.WHITE
	if banner != null:
		banner.visible = true


func _refresh_portrait_overlay(side_name: String) -> void:
	var items: Array = _portrait_items.get(side_name, [])
	for index in items.size():
		var item: Dictionary = items[index]
		var source_slot := _get_slot(side_name, index)
		var portrait := item.get("portrait", null) as TextureRect
		var border := item.get("border", null) as Panel
		var unit: Variant = _get_unit_for_side_index(side_name, index)
		# Source cards become hidden as a group in portrait-only mode. Their
		# texture is still refreshed by the production bridge, so card visibility
		# must never decide whether the independent portrait is shown.
		var should_show := source_slot != null and unit != null
		if portrait != null:
			portrait.visible = should_show
			if should_show:
				var source_portrait := source_slot.get_node_or_null("Portrait") as TextureRect
				portrait.texture = source_portrait.texture if source_portrait != null else null
				portrait.modulate = _portrait_status_modulate(unit)
		if border != null:
			border.visible = should_show and (unit == _get_current_actor() or (side_name == "Enemy" and unit == _get_next_enemy_actor_preview()))
			if border.visible:
				_apply_existing_actor_border(border, source_slot)


func _get_current_actor() -> Variant:
	if _controller != null and _controller.has_method("_get_production_roster_current_actor"):
		return _controller.call("_get_production_roster_current_actor")
	return null


func _get_next_enemy_actor_preview() -> Variant:
	if _controller != null and _controller.has_method("_get_production_roster_next_enemy_actor"):
		return _controller.call("_get_production_roster_next_enemy_actor")
	return null


func _apply_existing_actor_border(border: Panel, source_slot: Control) -> void:
	var source_style := source_slot.get_theme_stylebox(&"panel")
	if source_style != null:
		border.add_theme_stylebox_override(&"panel", source_style)
		return
	var fallback := StyleBoxFlat.new()
	fallback.set_corner_radius_all(6)
	fallback.bg_color = Color(0.26, 0.2, 0.08, 0.96)
	fallback.border_color = Color(1.0, 0.86, 0.46, 0.98)
	fallback.set_border_width_all(2)
	border.add_theme_stylebox_override(&"panel", fallback)


func _portrait_status_modulate(unit: Variant) -> Color:
	if unit == null:
		return Color.WHITE
	var is_alive := bool(unit.call("is_alive")) if unit.has_method("is_alive") else true
	var is_deployed := bool(_controller.call("_is_unit_state_deployed_by_capacity_slot", unit))
	if not is_alive or not is_deployed:
		return Color(0.62, 0.62, 0.62, 0.72)
	return Color.WHITE


func _get_detail_nodes(side_name: String) -> Array[Control]:
	var roster := _get_roster(side_name)
	if roster == null:
		return []
	var nodes: Array[Control] = []
	var frame := roster.get_node_or_null("RosterFrameFull") as Control
	var header := roster.get_node_or_null("RosterHeader") as Control
	if frame != null:
		nodes.append(frame)
	if header != null:
		nodes.append(header)
	for slot_name in SLOT_NAMES:
		var slot := roster.get_node_or_null(slot_name) as Control
		if slot != null:
			nodes.append(slot)
	return nodes


func _get_roster(side_name: String) -> Panel:
	return _hud_root.get_node_or_null("%sRosterHud" % side_name) as Panel


func _get_banner(side_name: String) -> TextureRect:
	return _hud_root.get_node_or_null("%sRosterSideBanner" % side_name) as TextureRect


func _get_slot(side_name: String, index: int) -> Control:
	var roster := _get_roster(side_name)
	if roster == null or index < 0 or index >= SLOT_NAMES.size():
		return null
	return roster.get_node_or_null(SLOT_NAMES[index]) as Control


func _get_unit_for_side_index(side_name: String, index: int) -> Variant:
	if _controller == null or not _controller.has_method("_get_all_unit_states_in_slot_order"):
		return null
	var units: Array = []
	for unit in _controller.call("_get_all_unit_states_in_slot_order"):
		if str(unit.side).capitalize() == side_name:
			units.append(unit)
	return units[index] if index >= 0 and index < units.size() else null


func _collapsed_portrait_position(side_name: String, index: int) -> Vector2:
	var x := 8.0 if side_name == "Ally" else 1840.0
	return Vector2(x, PORTRAIT_TOP + PORTRAIT_STEP * index)


func _collapsed_banner_position(side_name: String) -> Vector2:
	return Vector2(4.0, 115.0) if side_name == "Ally" else Vector2(1856.0, 115.0)
