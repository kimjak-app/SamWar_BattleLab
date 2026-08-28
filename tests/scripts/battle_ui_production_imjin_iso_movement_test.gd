extends "res://tests/scripts/battle_ui_production_imjin_test.gd"

## ISO_MOVEMENT_EXPERIMENT_V1
##
## Imjin test-only presentation experiment.
## Combat rules remain on the inherited orthogonal logical grid (18x10,
## Manhattan range/path/facing). Only world projection, grid overlays and
## facing glyphs are changed so the battle reads as a 3/4 isometric board.

const IsoGridProjectionScript := preload("res://tests/scripts/battle_iso_grid_projection.gd")
const IsoRangeOverlayTileScript := preload("res://tests/scripts/battle_iso_range_overlay_tile.gd")
const IsoFacingArrowTileButtonScript := preload("res://tests/scripts/battle_iso_facing_arrow_tile_button.gd")

const ISO_MOVEMENT_EXPERIMENT_MARKER := "ISO_MOVEMENT_EXPERIMENT_V1"
const ISO_FACING_TILE_FILL := Color(1.0, 0.86, 0.42, 0.22)
const ISO_FACING_TILE_OUTLINE := Color(1.0, 0.92, 0.65, 0.62)
const ISO_FACING_TILE_HIGHLIGHT := Color(1.0, 0.98, 0.82, 0.28)

var _iso_grid_controller: BattleGridController = null


func _ready() -> void:
	_install_iso_grid_projection()
	super._ready()
	# Parent setup has now created all runtime states. Re-sync once so every
	# deployed unit, marker and facing indicator uses the projected cell center.
	_sync_demo_positions()
	_update_all_unit_visuals_from_state()
	_update_facing_indicators()
	set_meta("iso_movement_experiment", ISO_MOVEMENT_EXPERIMENT_MARKER)
	print("[ISO_MOVE_TEST] ", ISO_MOVEMENT_EXPERIMENT_MARKER, " active")


func _install_iso_grid_projection() -> void:
	var source_controller := battle_grid_controller
	if source_controller == null:
		push_error("[ISO_MOVE_TEST] BattleGridController missing")
		return

	var iso_controller := IsoGridProjectionScript.new()
	iso_controller.configure_from(source_controller)
	battle_grid_controller = iso_controller
	_iso_grid_controller = iso_controller


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
	# and render the same feedback as an isometric diamond instead.
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
	button.queue_redraw()


func _position_facing_arrow_panel_near_ally() -> void:
	# The inherited placement still uses logical neighbor cells. Because the
	# controller now projects those centers, the four buttons land on the four
	# diagonal 3/4-view directions automatically.
	super._position_facing_arrow_panel_near_ally()
	if face_up_arrow_button != null:
		face_up_arrow_button.text = "↗"
	if face_down_arrow_button != null:
		face_down_arrow_button.text = "↙"
	if face_left_arrow_button != null:
		face_left_arrow_button.text = "↖"
	if face_right_arrow_button != null:
		face_right_arrow_button.text = "↘"


func _get_facing_arrow_text(facing: String) -> String:
	# Keep the combat-facing contract (up/down/left/right) untouched. Only map
	# its on-screen indicator to the isometric axes used by the projected grid.
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
