extends "res://tests/scripts/battle_ui_production_imjin_test.gd"

## ISO_MOVEMENT_EXPERIMENT_V4
##
## Imjin test-only presentation experiment. Generic ISO render/projection modules
## now come from production ownership; scenario-only presentation policy remains here.
## Combat rules remain on the inherited orthogonal logical grid.

const IsoGridProjectionScript := preload("res://scripts/battle/presentation/iso/battle_iso_grid_projection.gd")
const IsoRangeOverlayTileScript := preload("res://scripts/battle/presentation/iso/battle_iso_range_overlay_tile.gd")
const IsoFacingArrowTileButtonScript := preload("res://scripts/battle/presentation/iso/battle_iso_facing_arrow_tile_button.gd")
const IsoFacingIndicatorLabelScript := preload("res://scripts/battle/presentation/iso/battle_iso_facing_indicator_label.gd")

const ISO_MOVEMENT_EXPERIMENT_MARKER := "ISO_MOVEMENT_EXPERIMENT_V4"
const ISO_FACING_TILE_FILL := Color(1.0, 0.86, 0.42, 0.22)
const ISO_FACING_TILE_OUTLINE := Color(1.0, 0.92, 0.65, 0.62)
const ISO_FACING_TILE_HIGHLIGHT := Color(1.0, 0.98, 0.82, 0.28)

var _iso_grid_controller: BattleGridController = null


func _ready() -> void:
	super._ready()
	_install_iso_grid_projection()
	_collect_move_range_cells()
	_apply_facing_arrow_panel_visual_style()
	_snap_deployed_units_to_iso_grid()
	_sync_primary_ally_runtime_cache_to_iso_grid()
	_sync_demo_positions()
	_update_all_unit_visuals_from_state()
	_update_facing_indicators()
	_disable_legacy_ally_ready_frames()
	set_meta("iso_movement_experiment", ISO_MOVEMENT_EXPERIMENT_MARKER)
	print("[ISO_MOVE_TEST] ", ISO_MOVEMENT_EXPERIMENT_MARKER, " active · ", battle_grid_controller.describe_grid())


func _play_enemy_ai_for_actor(enemy_actor_state: BattleUnitState) -> void:
	_hide_enemy_tactical_range_overlays()
	super._play_enemy_ai_for_actor(enemy_actor_state)


func _begin_auto_unique_skill_preview(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	if caster_state != null and caster_state.side == "enemy":
		is_demo_animating = true
		_hide_facing_selection_panel()
		_hide_enemy_tactical_range_overlays()
		var preview_timer := get_tree().create_timer(UNIQUE_SKILL_AUTO_PREVIEW_DURATION)
		preview_timer.timeout.connect(
			_finish_auto_unique_skill_preview.bind(caster_state, skill_data),
			CONNECT_ONE_SHOT
		)
		return
	super._begin_auto_unique_skill_preview(caster_state, skill_data)


func _hide_enemy_tactical_range_overlays() -> void:
	_hide_move_range_overlay()
	_hide_attack_range_overlay()
	_hide_unique_skill_range_overlay()
	_hide_strategy_range_overlay()


func _configure_ally_ready_frames() -> void:
	_disable_legacy_ally_ready_frames()


func _update_ally_ready_frames() -> void:
	_disable_legacy_ally_ready_frames()


func _start_ready_frame_pulse(frame: Control) -> void:
	if frame == null:
		return
	_stop_ready_frame_pulse(frame)
	frame.visible = false
	frame.modulate = Color(1.0, 1.0, 1.0, 0.0)


func _disable_legacy_ally_ready_frames() -> void:
	for frame in [
		ally_ready_frame,
		ally_support_ready_frame,
		ally_main_03_ready_frame,
		ally_reinforce_01_ready_frame,
		ally_reinforce_02_ready_frame,
	]:
		if frame == null:
			continue
		_stop_ready_frame_pulse(frame)
		frame.visible = false
		frame.modulate = Color(1.0, 1.0, 1.0, 0.0)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _play_active_ally_turn_pulse(_unit_state: BattleUnitState) -> void:
	_stop_active_ally_turn_pulse()


func _start_idle_breathing() -> void:
	_stop_idle_breathing()
	for unit_state in _get_all_unit_states_in_slot_order():
		if unit_state == null:
			continue
		var token := _get_visual_token_for_unit(unit_state)
		if token != null:
			token.scale = _get_visual_token_base_scale_for_unit(unit_state)


func _install_iso_grid_projection() -> void:
	var source_controller := battle_grid_controller
	if source_controller == null:
		push_error("[ISO_MOVE_TEST] BattleGridController missing")
		return

	var iso_controller := IsoGridProjectionScript.new()
	iso_controller.configure_from(source_controller)
	battle_grid_controller = iso_controller
	_iso_grid_controller = iso_controller


func _snap_deployed_units_to_iso_grid() -> void:
	for unit_state in _get_all_unit_states_in_slot_order():
		if unit_state == null:
			continue
		if not battle_grid_controller.is_in_bounds(unit_state.grid_cell):
			push_warning("[ISO_MOVE_TEST] skip out-of-bounds unit %s cell=%s" % [unit_state.display_name, unit_state.grid_cell])
			continue
		_sync_resumed_unit_markers_to_grid(unit_state)


func _sync_primary_ally_runtime_cache_to_iso_grid() -> void:
	if ally_unit_marker != null:
		current_ally_unit_position = ally_unit_marker.position
	if ally_portrait_marker != null:
		current_ally_portrait_position = ally_portrait_marker.position
	print("[ISO_MOVE_TEST] primary ally cache synced unit=", current_ally_unit_position, " portrait=", current_ally_portrait_position)


func _collect_move_range_cells() -> void:
	move_range_cells.clear()
	if move_range_overlay_layer == null:
		return

	for child in move_range_overlay_layer.get_children():
		if child is ColorRect:
			var cell := child as ColorRect
			cell.set_script(IsoRangeOverlayTileScript)
			move_range_cells.append(cell)
			cell.visible = false
			cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cell.modulate = Color(1.0, 1.0, 1.0, 0.0)
			cell.scale = Vector2.ONE


func _show_move_highlight_at_position(world_position: Vector2) -> void:
	if move_highlight == null:
		return
	var highlight_size := MOVE_HIGHLIGHT_SIZE
	if battle_grid_controller != null:
		var cell_size := battle_grid_controller.get_cell_size()
		if cell_size.x > 0.0 and cell_size.y > 0.0:
			highlight_size = cell_size

	var requested_fill := move_highlight.color
	move_highlight.position = world_position - (highlight_size * 0.5)
	move_highlight.size = highlight_size
	if move_highlight.get_script() != IsoRangeOverlayTileScript:
		move_highlight.set_script(IsoRangeOverlayTileScript)
	move_highlight.color = Color.TRANSPARENT
	var outline := Color(requested_fill.r, requested_fill.g, requested_fill.b, minf(0.92, requested_fill.a * 3.2 + 0.18))
	var highlight := Color(requested_fill.r, requested_fill.g, requested_fill.b, minf(0.42, requested_fill.a * 1.5))
	move_highlight.call("set_tile_style", requested_fill, outline, highlight)


func _apply_facing_arrow_button_style(button: Button) -> void:
	if button == null:
		return
	super._apply_facing_arrow_button_style(button)
	button.set_script(IsoFacingArrowTileButtonScript)
	button.call("set_tile_style", ISO_FACING_TILE_FILL, ISO_FACING_TILE_OUTLINE, ISO_FACING_TILE_HIGHLIGHT)
	button.text = ""
	button.queue_redraw()


func _position_facing_arrow_panel_near_ally() -> void:
	super._position_facing_arrow_panel_near_ally()
	_configure_iso_facing_arrow(face_up_arrow_button, Vector2(1.0, -1.0))
	_configure_iso_facing_arrow(face_down_arrow_button, Vector2(-1.0, 1.0))
	_configure_iso_facing_arrow(face_left_arrow_button, Vector2(-1.0, -1.0))
	_configure_iso_facing_arrow(face_right_arrow_button, Vector2(1.0, 1.0))


func _configure_iso_facing_arrow(button: Button, direction_sign: Vector2) -> void:
	if button == null:
		return
	if button.get_script() != IsoFacingArrowTileButtonScript:
		button.set_script(IsoFacingArrowTileButtonScript)
	button.text = ""
	if button.has_method("set_iso_arrow_direction"):
		button.call("set_iso_arrow_direction", direction_sign)
	button.queue_redraw()


func _refresh_facing_indicator_for_unit(unit_state: BattleUnitState) -> void:
	super._refresh_facing_indicator_for_unit(unit_state)
	if _iso_grid_controller == null or unit_state == null:
		return
	var facing_indicator := _get_facing_indicator_for_unit(unit_state)
	if facing_indicator == null:
		return
	if facing_indicator.get_script() != IsoFacingIndicatorLabelScript:
		facing_indicator.set_script(IsoFacingIndicatorLabelScript)
	facing_indicator.text = ""
	if facing_indicator.has_method("set_iso_pixel_direction"):
		facing_indicator.call("set_iso_pixel_direction", _get_iso_pixel_direction_for_facing(unit_state.facing))
	facing_indicator.queue_redraw()


func _get_iso_pixel_direction_for_facing(facing: String) -> Vector2:
	if _iso_grid_controller == null:
		return Vector2.ZERO
	var basis_x: Vector2 = _iso_grid_controller.get_iso_basis_x()
	var basis_y: Vector2 = _iso_grid_controller.get_iso_basis_y()
	match _normalize_facing(facing):
		FACING_UP:
			return -basis_y
		FACING_DOWN:
			return basis_y
		FACING_LEFT:
			return -basis_x
		FACING_RIGHT:
			return basis_x
		_:
			return basis_x


func _get_facing_arrow_text(facing: String) -> String:
	match _normalize_facing(facing):
		FACING_UP:
			return "↗"
		FACING_DOWN:
			return "↙"
		FACING_LEFT:
			return "↖"
		FACING_RIGHT:
			return "↘"
		_:
			return "↘"
