extends SceneTree

const MovementQueryServiceScript := preload("res://scripts/battle/services/battle_movement_query_service.gd")

var _checks := 0
var _failures := 0
var _service := MovementQueryServiceScript.new()
var _grid := BattleGridController.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_grid.grid_width = 6
	_grid.grid_height = 5
	_test_deterministic_paths_and_limits()
	_test_occupancy_and_breakthrough()
	_test_reachable_paths()
	_test_effective_range_and_distance()
	await _test_controller_wrapper_parity()
	_grid.free()
	print("[BATTLE_MOVEMENT_QUERY_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_deterministic_paths_and_limits() -> void:
	var mover := _unit("mover", Vector2i(1, 1), 5)
	var empty_units: Array[BattleUnitState] = [mover]
	_expect_path(
		_service.find_move_path(Vector2i(1, 1), Vector2i(3, 1), mover, 5, _grid, empty_units, false),
		[Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
		"empty grid uses exact direction-ordered path"
	)

	var blocker := _unit("blocker", Vector2i(2, 1), 1)
	var blocked_units: Array[BattleUnitState] = [mover, blocker]
	_expect_path(
		_service.find_move_path(Vector2i(1, 1), Vector2i(3, 1), mover, 5, _grid, blocked_units, false),
		[Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(3, 1)],
		"blocker uses exact deterministic detour"
	)
	_expect(_service.find_move_path(Vector2i(1, 1), Vector2i(3, 1), mover, 1, _grid, empty_units, false).is_empty(), "max-step overflow is rejected")


func _test_occupancy_and_breakthrough() -> void:
	var mover := _unit("mover", Vector2i(1, 1), 5)
	var blocker := _unit("blocker", Vector2i(2, 1), 1)
	var units: Array[BattleUnitState] = [mover, blocker]
	_expect(not _service.is_valid_destination_for_unit(blocker.grid_cell, mover, _grid, units, false), "occupied destination is rejected")
	_expect(_service.is_cell_occupied_except(blocker.grid_cell, units, mover, false), "other unit blocks occupancy")
	_expect(not _service.is_cell_occupied_except(mover.grid_cell, units, mover, false), "mover excludes itself from occupancy")
	_expect_path(
		_service.find_move_path(Vector2i(1, 1), Vector2i(3, 1), mover, 5, _grid, units, true),
		[Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
		"breakthrough ignores occupied blockers"
	)


func _test_reachable_paths() -> void:
	var mover := _unit("mover", Vector2i(1, 1), 2)
	var blocker := _unit("blocker", Vector2i(2, 1), 1)
	var units: Array[BattleUnitState] = [mover, blocker]
	var reachable := _service.get_reachable_paths(mover.grid_cell, mover, 2, _grid, units, false)
	_expect(not reachable.has(blocker.grid_cell), "reachable paths exclude blocked destinations")
	for cell_variant in reachable.keys():
		var cell: Vector2i = cell_variant
		var path: Array = reachable[cell]
		_expect(path.size() - 1 <= 2, "reachable path %s stays within move range" % cell)


func _test_effective_range_and_distance() -> void:
	var mover := _unit("mover", Vector2i(1, 1), 3)
	mover.status_effects = {"mobility_up": 1}
	_expect(_service.get_effective_move_range(mover) == 4, "mobility_up adds one")
	mover.status_effects = {"movement_down": 1}
	_expect(_service.get_effective_move_range(mover) == 2, "movement_down subtracts one")
	mover.move_range = 0
	_expect(_service.get_effective_move_range(mover) == 0, "effective range clamps below zero")
	var target := _unit("target", Vector2i(4, 3), 1)
	_expect(_service.get_unit_grid_distance(mover, target) == 5, "Manhattan distance matches controller contract")
	_expect(_service.get_unit_grid_distance(null, target) == 9999, "null Manhattan sentinel is preserved")


func _test_controller_wrapper_parity() -> void:
	var packed := load("res://scenes/battle/Battle_Main.tscn") as PackedScene
	_expect(packed != null, "Battle_Main loads for wrapper parity")
	if packed == null:
		return
	var battle := packed.instantiate()
	root.add_child(battle)
	await process_frame
	var grid := battle.get("battle_grid_controller") as BattleGridController
	var ally := battle.get("active_unit_state") as BattleUnitState
	var enemy := battle.get("enemy_unit_state") as BattleUnitState
	var alive_units := _typed_units(battle.call("_get_all_alive_unit_states"))
	_expect(grid != null and ally != null and enemy != null, "representative controller actors are ready")
	if grid != null and ally != null and enemy != null:
		_expect(battle.call("_get_effective_move_range", ally) == _service.get_effective_move_range(ally), "ally effective-range wrapper parity")
		_expect(battle.call("_get_occupied_cells_except", ally) == _service.get_occupied_cells_except(alive_units, ally, false), "ally occupancy wrapper parity")
		var ally_target := _first_reachable_destination(ally, grid, alive_units)
		if ally_target != ally.grid_cell:
			var ally_service_path := _service.find_move_path(ally.grid_cell, ally_target, ally, _service.get_effective_move_range(ally), grid, alive_units, false)
			_expect_path(battle.call("_find_ally_move_path", ally.grid_cell, ally_target), ally_service_path, "ally path wrapper parity")
		else:
			_expect(false, "ally fixture has a reachable destination")

		var enemy_paths := _service.get_reachable_paths(enemy.grid_cell, enemy, _service.get_effective_move_range(enemy), grid, alive_units, false)
		_expect(battle.call("_get_enemy_reachable_paths_for_actor", enemy, enemy.grid_cell) == enemy_paths, "enemy reachable-path wrapper parity")
		var enemy_target := _first_dictionary_destination(enemy_paths, enemy.grid_cell)
		if enemy_target != enemy.grid_cell:
			var enemy_service_path: Array[Vector2i] = enemy_paths[enemy_target]
			_expect_path(battle.call("_find_enemy_path_to_destination_for_actor", enemy, enemy.grid_cell, enemy_target, enemy_service_path.size() - 1), enemy_service_path, "enemy path wrapper parity")
		else:
			_expect(false, "enemy fixture has a reachable destination")
		_expect(battle.call("get_unit_grid_distance", ally, enemy) == _service.get_unit_grid_distance(ally, enemy), "controller Manhattan wrapper parity")
	battle.free()
	await _finish_fixture_audio()
	await process_frame


func _finish_fixture_audio() -> void:
	var game_audio := root.get_node_or_null("GameAudio")
	if game_audio == null:
		return
	for child in game_audio.get_children():
		var voice := child as AudioStreamPlayer
		if voice != null:
			if voice.playing:
				await voice.finished
			voice.stop()
			voice.stream = null


func _first_reachable_destination(mover: BattleUnitState, grid: BattleGridController, alive_units: Array[BattleUnitState]) -> Vector2i:
	var paths := _service.get_reachable_paths(mover.grid_cell, mover, _service.get_effective_move_range(mover), grid, alive_units, false)
	return _first_dictionary_destination(paths, mover.grid_cell)


func _first_dictionary_destination(paths: Dictionary, start_cell: Vector2i) -> Vector2i:
	for cell_variant in paths.keys():
		var cell: Vector2i = cell_variant
		if cell != start_cell:
			return cell
	return start_cell


func _typed_units(raw_units: Array) -> Array[BattleUnitState]:
	var result: Array[BattleUnitState] = []
	for raw_unit in raw_units:
		var unit_state := raw_unit as BattleUnitState
		if unit_state != null:
			result.append(unit_state)
	return result


func _unit(display_name: String, cell: Vector2i, move_range: int) -> BattleUnitState:
	var unit := BattleUnitState.new()
	unit.display_name = display_name
	unit.grid_cell = cell
	unit.move_range = move_range
	unit.current_hp = 100
	unit.max_hp = 100
	unit.current_troops = 100
	unit.max_troops = 100
	return unit


func _expect_path(actual: Array, expected: Array, label: String) -> void:
	_expect(actual == expected, "%s expected=%s actual=%s" % [label, expected, actual])


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[BATTLE_MOVEMENT_QUERY_SERVICE_FAIL] %s" % label)
