extends SceneTree

const ReservationStateServiceScript := preload("res://scripts/battle/services/battle_enemy_ai_reservation_state_service.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_direct_reservation_semantics()
	_test_clear_semantics()
	await _test_controller_wrapper_parity()
	print("[BATTLE_ENEMY_AI_RESERVATION_STATE_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_direct_reservation_semantics() -> void:
	var service := ReservationStateServiceScript.new()
	var actor_a_cell := Vector2i(2, 2)
	var actor_b_cell := Vector2i(8, 8)
	var destination := Vector2i(3, 2)
	var final_cell := Vector2i(4, 2)

	_expect(not service.is_destination_reserved_for_other_actor(destination, actor_a_cell, "enemy_main"), "empty destination state is available")
	_expect(not service.is_engagement_reserved_for_other_actor(final_cell, actor_a_cell, "enemy_main"), "empty engagement state is available")

	service.reserve_decision_plan(actor_a_cell, "enemy_main", {
		"destination": destination,
		"final_cell": final_cell,
	})
	_expect(not service.is_destination_reserved_for_other_actor(destination, actor_a_cell, "enemy_main"), "actor may reuse own destination reservation")
	_expect(service.is_destination_reserved_for_other_actor(destination, actor_b_cell, "enemy_support"), "other actor sees destination reservation")
	_expect(not service.is_engagement_reserved_for_other_actor(final_cell, actor_a_cell, "enemy_main"), "actor may reuse own engagement reservation")
	_expect(service.is_engagement_reserved_for_other_actor(final_cell, actor_b_cell, "enemy_support"), "other actor sees engagement reservation")

	var own_cell_service := ReservationStateServiceScript.new()
	own_cell_service.reserve_decision_plan(actor_a_cell, "enemy_main", {
		"destination": actor_a_cell,
		"final_cell": actor_a_cell,
	})
	_expect(not own_cell_service.is_destination_reserved_for_other_actor(actor_a_cell, actor_b_cell, "enemy_support"), "actor current cell is not stored as destination reservation")
	_expect(not own_cell_service.is_engagement_reserved_for_other_actor(actor_a_cell, actor_b_cell, "enemy_support"), "actor current cell is not stored as engagement reservation")

	var default_final_service := ReservationStateServiceScript.new()
	default_final_service.reserve_decision_plan(actor_a_cell, "enemy_main", {
		"destination": destination,
	})
	_expect(default_final_service.is_destination_reserved_for_other_actor(destination, actor_b_cell, "enemy_support"), "destination reservation is stored")
	_expect(default_final_service.is_engagement_reserved_for_other_actor(destination, actor_b_cell, "enemy_support"), "final cell defaults to destination")

	var empty_slot_service := ReservationStateServiceScript.new()
	empty_slot_service.reserve_decision_plan(actor_a_cell, "", {
		"destination": destination,
	})
	_expect(not empty_slot_service.is_destination_reserved_for_other_actor(destination, actor_a_cell, ""), "empty actor slot id keeps same-actor semantics")
	_expect(empty_slot_service.is_destination_reserved_for_other_actor(destination, actor_b_cell, "enemy_support"), "empty stored slot remains reserved for non-empty other actor")


func _test_clear_semantics() -> void:
	var service := ReservationStateServiceScript.new()
	var actor_cell := Vector2i(1, 1)
	var other_cell := Vector2i(9, 9)
	var destination := Vector2i(2, 1)
	var final_cell := Vector2i(3, 1)
	service.reserve_decision_plan(actor_cell, "enemy_main", {
		"destination": destination,
		"final_cell": final_cell,
	})
	_expect(service.is_destination_reserved_for_other_actor(destination, other_cell, "enemy_support"), "destination reservation exists before clear")
	_expect(service.is_engagement_reserved_for_other_actor(final_cell, other_cell, "enemy_support"), "engagement reservation exists before clear")
	service.clear_turn_reservations()
	_expect(not service.is_destination_reserved_for_other_actor(destination, other_cell, "enemy_support"), "clear removes destination reservations")
	_expect(not service.is_engagement_reserved_for_other_actor(final_cell, other_cell, "enemy_support"), "clear removes engagement reservations")


func _test_controller_wrapper_parity() -> void:
	var packed := load("res://scenes/battle/Battle_Main.tscn") as PackedScene
	_expect(packed != null, "Battle_Main loads for enemy AI reservation wrapper parity")
	if packed == null:
		return
	var controller := packed.instantiate()
	root.add_child(controller)
	await process_frame
	var enemies: Array[BattleUnitState] = controller.call("_get_alive_enemy_units")
	_expect(not enemies.is_empty(), "Battle_Main fixture provides an alive enemy")
	if enemies.is_empty():
		controller.free()
		await _finish_fixture_audio()
		await process_frame
		return

	var actor := enemies[0]
	var actor_slot_id := str(controller.call("_get_capacity_slot_id_for_unit_state", actor))
	var destination := actor.grid_cell + Vector2i(1, 0)
	var final_cell := actor.grid_cell + Vector2i(2, 0)
	controller.call("_clear_enemy_ai_turn_reservations")
	_expect(not bool(controller.call("_is_enemy_ai_destination_cell_reserved_for_other_actor", destination, actor)), "controller wrapper starts clear")
	controller.call("_reserve_enemy_ai_decision_plan_for_actor", actor, {
		"destination": destination,
		"final_cell": final_cell,
	})

	var service = controller.get("enemy_ai_reservation_state_service")
	_expect(service != null, "controller owns reservation state service")
	if service != null:
		_expect(not bool(service.is_destination_reserved_for_other_actor(destination, actor.grid_cell, actor_slot_id)), "controller reserve wrapper keeps actor slot identity")
		_expect(bool(service.is_destination_reserved_for_other_actor(destination, actor.grid_cell + Vector2i(5, 5), "other-slot")), "controller reserve wrapper stores destination")
		_expect(bool(service.is_engagement_reserved_for_other_actor(final_cell, actor.grid_cell + Vector2i(5, 5), "other-slot")), "controller reserve wrapper stores final engagement cell")

	_expect(not bool(controller.call("_is_enemy_ai_destination_cell_reserved_for_other_actor", destination, actor)), "controller own reservation is not blocked")
	_expect(not bool(controller.call("_is_enemy_ai_destination_cell_reserved_for_other_actor", actor.grid_cell, actor)), "controller current cell exemption remains")

	controller.call("_reset_enemy_action_locks_for_new_round")
	if service != null:
		_expect(not bool(service.is_destination_reserved_for_other_actor(destination, actor.grid_cell + Vector2i(5, 5), "other-slot")), "enemy action-lock reset clears destination reservations")
		_expect(not bool(service.is_engagement_reserved_for_other_actor(final_cell, actor.grid_cell + Vector2i(5, 5), "other-slot")), "enemy action-lock reset clears engagement reservations")

	controller.free()
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


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("[BATTLE_ENEMY_AI_RESERVATION_STATE_SERVICE_FAIL] %s" % label)
