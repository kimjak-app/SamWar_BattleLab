extends "res://tests/scripts/battle_ui_production_imjin_test.gd"

## ISO_MOVEMENT_EXPERIMENT_V4
##
## Imjin test-only presentation experiment.
## Combat rules remain on the inherited orthogonal logical grid (18x10,
## Manhattan range/path/facing). Parent initialization MUST run on that original
## controller first so authored deployment markers become the same logical cells
## as the production Imjin test. Only after state initialization do we swap the
## screen projection to a 3/4 isometric board.

const IsoGridProjectionScript := preload("res://tests/scripts/battle_iso_grid_projection.gd")
const IsoRangeOverlayTileScript := preload("res://tests/scripts/battle_iso_range_overlay_tile.gd")
const IsoFacingArrowTileButtonScript := preload("res://tests/scripts/battle_iso_facing_arrow_tile_button.gd")
const IsoFacingIndicatorLabelScript := preload("res://tests/scripts/battle_iso_facing_indicator_label.gd")

const ISO_MOVEMENT_EXPERIMENT_MARKER := "ISO_MOVEMENT_EXPERIMENT_V4"
const ISO_FACING_TILE_FILL := Color(1.0, 0.86, 0.42, 0.22)
const ISO_FACING_TILE_OUTLINE := Color(1.0, 0.92, 0.65, 0.62)
const ISO_FACING_TILE_HIGHLIGHT := Color(1.0, 0.98, 0.82, 0.28)

# Test-only frame pacing pass. The inherited production controller intentionally
# refreshes several HUD/world surfaces every frame. Test2 adds another 20 Hz
# resync loop, so the same visual state can be rebuilt multiple times per frame.
# These guards keep responsiveness while avoiding redundant work on a static
# camera. Combat rules, action timing and animation tweens are unchanged.
const PERF_READY_FRAME_REFRESH_MS := 50
const PERF_FLOATING_PANEL_REFRESH_MS := 34
const PERF_STATUS_ICON_REFRESH_MS := 50
const PERF_STATIC_WORLD_OVERLAY_REFRESH_MS := 100
const CUTIN_PREWARM_POLL_MS := 200

var _iso_grid_controller: BattleGridController = null
var _perf_last_ready_frame_refresh_ms := -100000
var _perf_last_floating_panel_refresh_ms := -100000
var _perf_last_status_icon_refresh_ms := -100000
var _perf_last_world_overlay_refresh_ms := -100000
var _cutin_prewarm_last_poll_ms := -100000
var _cutin_prewarm_pending: Dictionary = {}
var _cutin_prewarm_resources: Dictionary = {}


func _ready() -> void:
	# IMPORTANT: let the production Imjin test derive its logical grid cells from
	# the authored scene markers using the original orthogonal controller first.
	super._ready()

	_install_iso_grid_projection()
	_collect_move_range_cells()
	_apply_facing_arrow_panel_visual_style()
	_snap_deployed_units_to_iso_grid()
	_sync_primary_ally_runtime_cache_to_iso_grid()
	_sync_demo_positions()
	_update_all_unit_visuals_from_state()
	_update_facing_indicators()
	_request_imjin_cutin_prewarm()
	set_meta("iso_movement_experiment", ISO_MOVEMENT_EXPERIMENT_MARKER)
	print("[ISO_MOVE_TEST] ", ISO_MOVEMENT_EXPERIMENT_MARKER, " active · ", battle_grid_controller.describe_grid())


func _process(delta: float) -> void:
	super._process(delta)
	_poll_imjin_cutin_prewarm()


func _update_ally_ready_frames() -> void:
	var now_ms := Time.get_ticks_msec()
	if now_ms - _perf_last_ready_frame_refresh_ms < PERF_READY_FRAME_REFRESH_MS:
		return
	_perf_last_ready_frame_refresh_ms = now_ms
	super._update_ally_ready_frames()


func _refresh_floating_ally_command_panel() -> void:
	# Keep command-panel tracking fully smooth while the combat camera is moving;
	# otherwise 30 Hz is more than enough for a stationary tactical panel.
	if combat_camera_tween != null:
		super._refresh_floating_ally_command_panel()
		return
	var now_ms := Time.get_ticks_msec()
	if now_ms - _perf_last_floating_panel_refresh_ms < PERF_FLOATING_PANEL_REFRESH_MS:
		return
	_perf_last_floating_panel_refresh_ms = now_ms
	super._refresh_floating_ally_command_panel()


func _refresh_strategy_status_icon_labels() -> void:
	if combat_camera_tween != null:
		super._refresh_strategy_status_icon_labels()
		return
	var now_ms := Time.get_ticks_msec()
	if now_ms - _perf_last_status_icon_refresh_ms < PERF_STATUS_ICON_REFRESH_MS:
		return
	_perf_last_status_icon_refresh_ms = now_ms
	super._refresh_strategy_status_icon_labels()


func _refresh_camera_bound_world_overlays() -> void:
	# Camera tweening needs frame-perfect overlay tracking. Once the camera is
	# static, Test2's 20 Hz backup resync is redundant with event-driven refreshes,
	# so cap the fallback at 10 Hz instead of rebuilding every 50 ms.
	if combat_camera_tween != null:
		super._refresh_camera_bound_world_overlays()
		return
	var now_ms := Time.get_ticks_msec()
	if now_ms - _perf_last_world_overlay_refresh_ms < PERF_STATIC_WORLD_OVERLAY_REFRESH_MS:
		return
	_perf_last_world_overlay_refresh_ms = now_ms
	super._refresh_camera_bound_world_overlays()


func _cutin_trace(_message: String) -> void:
	# The production trace is useful during cut-in authoring, but the ISO battle
	# performance test does not need console traffic for every routing step.
	pass


func _debug_print_combat_distance(_context: String) -> void:
	# Distance tracing is diagnostic-only and can create editor-console bursts
	# during auto/enemy turns. Keep it silent in the frame-pacing experiment.
	pass


func _request_imjin_cutin_prewarm() -> void:
	_cutin_prewarm_pending.clear()
	_cutin_prewarm_resources.clear()

	var roster_heroes: Dictionary = {}
	for hero_variant in IMJIN_TEST_BATTLE_ROSTER.values():
		var canonical_hero_id := KoreaMvpHeroCutinRegistryScript.canonicalize_hero_id(String(hero_variant))
		if not canonical_hero_id.is_empty():
			roster_heroes[canonical_hero_id] = true

	for entry in KoreaMvpHeroCutinRegistryScript.load_all_entries():
		if not bool(entry.get("enabled", false)):
			continue
		var entry_hero_id := KoreaMvpHeroCutinRegistryScript.canonicalize_hero_id(String(entry.get("hero_id", "")))
		if not roster_heroes.has(entry_hero_id):
			continue
		_request_cutin_resource_prewarm(String(entry.get("video_path", "")))
		_request_cutin_resource_prewarm(String(entry.get("skill_title_texture_path", "")))


func _request_cutin_resource_prewarm(path: String) -> void:
	if path.is_empty() or _cutin_prewarm_pending.has(path) or _cutin_prewarm_resources.has(path):
		return
	if not ResourceLoader.exists(path):
		return
	var request_error := ResourceLoader.load_threaded_request(path)
	if request_error == OK:
		_cutin_prewarm_pending[path] = true


func _poll_imjin_cutin_prewarm() -> void:
	if _cutin_prewarm_pending.is_empty():
		return
	var now_ms := Time.get_ticks_msec()
	if now_ms - _cutin_prewarm_last_poll_ms < CUTIN_PREWARM_POLL_MS:
		return
	_cutin_prewarm_last_poll_ms = now_ms

	var completed_paths: Array[String] = []
	for path_variant in _cutin_prewarm_pending.keys():
		var path := String(path_variant)
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_resource := ResourceLoader.load_threaded_get(path)
			if loaded_resource != null:
				_cutin_prewarm_resources[path] = loaded_resource
			completed_paths.append(path)
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			completed_paths.append(path)

	for path in completed_paths:
		_cutin_prewarm_pending.erase(path)


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
	# Logical cells were already established by the production test. Reposition
	# only their visual markers onto the corresponding isometric cell centers.
	for unit_state in _get_all_unit_states_in_slot_order():
		if unit_state == null:
			continue
		if not battle_grid_controller.is_in_bounds(unit_state.grid_cell):
			push_warning("[ISO_MOVE_TEST] skip out-of-bounds unit %s cell=%s" % [unit_state.display_name, unit_state.grid_cell])
			continue
		_sync_resumed_unit_markers_to_grid(unit_state)


func _sync_primary_ally_runtime_cache_to_iso_grid() -> void:
	# ally_main_01 (Yi Sun-sin in the Imjin test) is special in the inherited
	# battle controller: its visual base anchor reads these cached positions.
	# After snapping the marker to the iso cell, refresh the cache before
	# _sync_demo_positions() rebuilds the visual group or the model and overlay
	# separate again.
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

	# Base feedback writes the desired valid/invalid tint into ColorRect.color
	# immediately before this call. Preserve it, then clear the rectangular fill
	# and render the same feedback as an isometric chamfered diamond instead.
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
	# The inherited placement still uses logical neighbor cells. Because the
	# controller now projects those centers, the four buttons land on the four
	# diagonal 3/4-view directions automatically. Draw the arrows ourselves so
	# their slope matches the actual iso cell axes instead of Unicode 45-degree
	# glyphs.
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
	# Let production logic keep ownership of visibility, positioning and toast
	# suppression. Once the iso controller exists, replace only the glyph drawing
	# with a vector arrow using the exact same projected basis as movement.
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
	# Fallback used only before the iso projection is installed. Runtime unit
	# indicators are texture-drawn by _refresh_facing_indicator_for_unit().
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
