class_name BattleIsoGridProjection
extends BattleGridController

## Test-only projection adapter. Logical coordinates, bounds, Manhattan distance
## and range queries are inherited unchanged from BattleGridController.
##
## Screen basis:
##   logical +X -> down/right
##   logical +Y -> down/left
## This makes the existing four-neighbor grid read as a 3/4 isometric board.

var _source_controller: BattleGridController = null


func configure_from(source_controller: BattleGridController) -> void:
	_source_controller = source_controller
	if _source_controller == null:
		return
	grid_width = maxi(_source_controller.grid_width, 1)
	grid_height = maxi(_source_controller.grid_height, 1)


func get_board_top_left() -> Vector2:
	if _source_controller != null:
		return _source_controller.get_board_top_left()
	return super.get_board_top_left()


func get_board_bottom_right() -> Vector2:
	if _source_controller != null:
		return _source_controller.get_board_bottom_right()
	return super.get_board_bottom_right()


func _get_iso_half_step() -> Vector2:
	var board_size := get_board_bottom_right() - get_board_top_left()
	var diagonal_span := float(maxi(grid_width + grid_height, 2))
	return Vector2(
		board_size.x / diagonal_span,
		board_size.y / diagonal_span
	)


func get_cell_size() -> Vector2:
	# Bounding box of one isometric diamond, not the logical orthogonal step.
	var half_step := _get_iso_half_step()
	return Vector2(half_step.x * 2.0, half_step.y * 2.0)


func get_iso_basis_x() -> Vector2:
	var half_step := _get_iso_half_step()
	return Vector2(half_step.x, half_step.y)


func get_iso_basis_y() -> Vector2:
	var half_step := _get_iso_half_step()
	return Vector2(-half_step.x, half_step.y)


func grid_to_world(cell: Vector2i) -> Vector2:
	var half_step := _get_iso_half_step()
	if is_zero_approx(half_step.x) or is_zero_approx(half_step.y):
		return get_board_top_left()

	# +grid_height shifts the left-most diamond so its left tip stays inside the
	# existing visual board. +1 on Y likewise leaves a half-tile top margin.
	return get_board_top_left() + Vector2(
		(float(cell.x - cell.y + grid_height)) * half_step.x,
		(float(cell.x + cell.y + 1)) * half_step.y
	)


func world_to_grid(world_pos: Vector2) -> Vector2i:
	var half_step := _get_iso_half_step()
	if is_zero_approx(half_step.x) or is_zero_approx(half_step.y):
		return Vector2i.ZERO

	var local_pos := world_pos - get_board_top_left()
	var difference_axis := (local_pos.x / half_step.x) - float(grid_height)
	var sum_axis := (local_pos.y / half_step.y) - 1.0
	var logical_x := (difference_axis + sum_axis) * 0.5
	var logical_y := (sum_axis - difference_axis) * 0.5

	# A diamond cell in screen space becomes an axis-aligned +/-0.5 square in
	# inverse logical space, so independent rounding gives stable diamond clicks.
	return Vector2i(roundi(logical_x), roundi(logical_y))


func describe_grid() -> String:
	return "BattleIsoGridProjection %dx%d top_left=%s bottom_right=%s diamond_size=%s basis_x=%s basis_y=%s" % [
		grid_width,
		grid_height,
		get_board_top_left(),
		get_board_bottom_right(),
		get_cell_size(),
		get_iso_basis_x(),
		get_iso_basis_y(),
	]
