extends SceneTree

const ActionLockStateServiceScript := preload("res://scripts/battle/services/battle_action_lock_state_service.gd")
const BattleRuntimeSnapshotScript := preload("res://scripts/battle/battle_runtime_snapshot.gd")
const BattleMomentumStateScript := preload("res://scripts/battle/battle_momentum_state.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_query_and_registration_semantics()
	_test_registry_lifecycle_and_snapshot_isolation()
	_test_ordered_aggregate_queries()
	_test_runtime_snapshot_compatibility()
	await _test_controller_wrapper_parity()
	print("[BATTLE_ACTION_LOCK_STATE_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_query_and_registration_semantics() -> void:
	var service := ActionLockStateServiceScript.new()
	var ally := _unit("ally-a", "ally")
	var enemy := _unit("enemy-a", "enemy")
	_expect(service.has_unit_acted(null, "ally"), "null query is treated as acted")
	_expect(not service.has_unit_acted(enemy, "ally"), "wrong-side query is false")
	var idless := _unit("", "ally")
	_expect(not service.has_unit_acted(idless, "ally"), "empty id falls back to false unit flag")
	idless.has_acted = true
	_expect(service.has_unit_acted(idless, "ally"), "empty id falls back to true unit flag")
	var rejected: Dictionary = service.register_unit_acted(idless, "ally")
	_expect(not bool(rejected.get("accepted", true)), "empty-id registration is rejected")
	var first_ally: Dictionary = service.register_unit_acted(ally, "ally")
	_expect(bool(first_ally.get("accepted", false)), "first ally registration is accepted")
	_expect(not bool(first_ally.get("was_already_acted", true)), "first ally registration is new")
	var second_ally: Dictionary = service.register_unit_acted(ally, "ally")
	_expect(bool(second_ally.get("accepted", false)), "second ally registration is accepted")
	_expect(bool(second_ally.get("was_already_acted", false)), "second ally registration reports acted")
	var first_enemy: Dictionary = service.register_unit_acted(enemy, "enemy")
	_expect(bool(first_enemy.get("accepted", false)), "first enemy registration is accepted")
	_expect(not bool(first_enemy.get("was_already_acted", true)), "first enemy registration is new")
	var second_enemy: Dictionary = service.register_unit_acted(enemy, "enemy")
	_expect(bool(second_enemy.get("was_already_acted", false)), "second enemy registration reports acted")
	_expect(not service.has_unit_acted(ally, "enemy"), "registries remain side-aware")


func _test_registry_lifecycle_and_snapshot_isolation() -> void:
	var service := ActionLockStateServiceScript.new()
	var shared_ally := _unit("shared", "ally")
	var shared_enemy := _unit("shared", "enemy")
	var ally_two := _unit("ally-two", "ally")
	service.register_unit_acted(shared_ally, "ally")
	service.register_unit_acted(shared_enemy, "enemy")
	service.register_unit_acted(ally_two, "ally")
	service.clear_side("ally")
	_expect(not service.has_unit_acted(shared_ally, "ally"), "clear ally removes ally registry")
	_expect(service.has_unit_acted(shared_enemy, "enemy"), "clear ally preserves enemy registry")
	service.register_unit_acted(shared_ally, "ally")
	service.clear_side("enemy")
	_expect(service.has_unit_acted(shared_ally, "ally"), "clear enemy preserves ally registry")
	_expect(not service.has_unit_acted(shared_enemy, "enemy"), "clear enemy removes enemy registry")
	service.register_unit_acted(shared_enemy, "enemy")
	service.erase_unit_id("shared")
	_expect(not service.has_unit_acted(shared_ally, "ally"), "erase removes id from ally registry")
	_expect(not service.has_unit_acted(shared_enemy, "enemy"), "erase removes id from enemy registry")
	service.restore_acted_ids("ally", {"ally-two": {"nested": true}})
	var exported := service.export_acted_ids("ally")
	(exported["ally-two"] as Dictionary)["nested"] = false
	_expect(bool((service.export_acted_ids("ally")["ally-two"] as Dictionary).get("nested", false)), "export returns a deep copy")
	var restore_source := {"shared": {"nested": true}}
	service.restore_acted_ids("enemy", restore_source)
	(restore_source["shared"] as Dictionary)["nested"] = false
	_expect(bool((service.export_acted_ids("enemy")["shared"] as Dictionary).get("nested", false)), "restore deep-copies Dictionary input")
	service.restore_acted_ids("enemy", "not-a-dictionary")
	_expect(service.export_acted_ids("enemy").is_empty(), "non-Dictionary restore clears registry")
	var snapshot_extra := {
		"acted_ally_unit_ids": service.export_acted_ids("ally"),
		"acted_enemy_unit_ids": {"enemy-roundtrip": true},
	}
	service.clear_side("ally")
	service.restore_acted_ids("ally", snapshot_extra.get("acted_ally_unit_ids", {}))
	service.restore_acted_ids("enemy", snapshot_extra.get("acted_enemy_unit_ids", {}))
	_expect(snapshot_extra.has("acted_ally_unit_ids"), "resume snapshot retains ally acted key")
	_expect(snapshot_extra.has("acted_enemy_unit_ids"), "resume snapshot retains enemy acted key")
	_expect(service.export_acted_ids("ally").has("ally-two"), "ally snapshot values round-trip")
	_expect(service.export_acted_ids("enemy").has("enemy-roundtrip"), "enemy snapshot values round-trip")


func _test_ordered_aggregate_queries() -> void:
	var service := ActionLockStateServiceScript.new()
	var first := _unit("ally-first", "ally")
	var second := _unit("ally-second", "ally")
	var third := _unit("ally-third", "ally")
	var ordered: Array[BattleUnitState] = [first, second, third]
	service.register_unit_acted(first, "ally")
	_expect(service.first_unacted(ordered, "ally") == second, "first-unacted preserves supplied order")
	_expect(service.count_unacted(ordered, "ally") == 2, "count-unacted matches registry state")
	_expect(not service.are_all_acted(ordered, "ally"), "all-acted is false while units remain")
	service.register_unit_acted(second, "ally")
	service.register_unit_acted(third, "ally")
	_expect(service.count_unacted(ordered, "ally") == 0, "count-unacted reaches zero")
	_expect(service.are_all_acted(ordered, "ally"), "all-acted is true when all supplied units acted")
	_expect(service.first_unacted(ordered, "ally") == null, "first-unacted returns null when exhausted")


func _test_runtime_snapshot_compatibility() -> void:
	var service := ActionLockStateServiceScript.new()
	var ally := _unit("snapshot-ally", "ally")
	var enemy := _unit("snapshot-enemy", "enemy")
	ally.has_acted = true
	ally.has_moved = true
	service.register_unit_acted(ally, "ally")
	service.register_unit_acted(enemy, "enemy")
	var units: Array[BattleUnitState] = [ally, enemy]
	var momentum := BattleMomentumStateScript.new()
	var snapshot := BattleRuntimeSnapshotScript.capture(
		"b1e-snapshot",
		3,
		"enemy_turn",
		units,
		momentum,
		{
			"acted_ally_unit_ids": service.export_acted_ids("ally"),
			"acted_enemy_unit_ids": service.export_acted_ids("enemy"),
		}
	)
	ally.has_acted = false
	ally.has_moved = false
	service.clear_side("ally")
	service.clear_side("enemy")
	var restored: Dictionary = BattleRuntimeSnapshotScript.restore(snapshot, "b1e-snapshot", units, momentum)
	_expect(bool(restored.get("ok", false)), "BattleRuntimeSnapshot accepts B-1E acted extra state")
	_expect(ally.has_acted and ally.has_moved, "runtime restore still owns unit action flags")
	var extra: Dictionary = restored.get("extra_state", {})
	service.restore_acted_ids("ally", extra.get("acted_ally_unit_ids", {}))
	service.restore_acted_ids("enemy", extra.get("acted_enemy_unit_ids", {}))
	_expect(service.has_unit_acted(ally, "ally"), "ally acted registry restores after runtime flags")
	_expect(service.has_unit_acted(enemy, "enemy"), "enemy acted registry restores after runtime flags")
	_expect(int(snapshot.get("schema_version", 0)) == 1, "runtime snapshot schema version remains compatible")


func _test_controller_wrapper_parity() -> void:
	var packed := load("res://scenes/battle/Battle_Main.tscn") as PackedScene
	_expect(packed != null, "Battle_Main loads for action-lock wrapper parity")
	if packed == null:
		return
	var controller := packed.instantiate()
	root.add_child(controller)
	await process_frame
	var allies: Array[BattleUnitState] = controller.call("_get_alive_ally_units")
	var enemies: Array[BattleUnitState] = controller.call("_get_alive_enemy_units")
	_expect(not allies.is_empty(), "Battle_Main fixture provides an alive ally")
	_expect(not enemies.is_empty(), "Battle_Main fixture provides an alive enemy")
	if allies.is_empty() or enemies.is_empty():
		controller.free()
		await _finish_fixture_audio()
		await process_frame
		return
	controller.call("_reset_ally_action_locks_for_new_round")
	controller.call("_reset_enemy_action_locks_for_new_round")
	var ally := allies[0]
	var enemy := enemies[0]
	controller.set("active_unit_state", ally)
	controller.set("ally_has_moved", false)
	ally.status_effects = {"shake": 2}
	controller.call("_mark_ally_unit_acted", ally)
	_expect(ally.has_acted and ally.has_moved, "ally wrapper retains action flag mutations")
	_expect(bool(controller.get("ally_has_moved")), "ally wrapper retains active-unit mirror")
	_expect(ally.get_status_turns("shake") == 1, "ally wrapper consumes status on first completion")
	_expect(bool(controller.call("_has_ally_unit_acted", ally)), "ally wrapper query sees service registration")
	controller.call("_mark_ally_unit_acted", ally)
	_expect(ally.get_status_turns("shake") == 1, "repeated ally completion does not consume status twice")
	ally.is_defending = true
	ally.attacked_this_turn = true
	ally.last_action = {"type": "test"}
	controller.call("_reset_ally_action_locks_for_new_round")
	_expect(not ally.has_acted and not ally.has_moved, "ally reset preserves reset_action_flags")
	_expect(not ally.is_defending and not ally.attacked_this_turn and ally.last_action.is_empty(), "ally reset preserves broader action flag reset")
	_expect(not bool(controller.get("ally_has_moved")), "ally reset clears controller mirror")
	_expect(not bool(controller.call("_has_ally_unit_acted", ally)), "ally reset clears service registry")
	enemy.status_effects = {"shake": 2}
	controller.call("_mark_enemy_unit_acted", enemy)
	_expect(enemy.has_acted and enemy.has_moved, "enemy wrapper retains action flag mutations")
	_expect(enemy.get_status_turns("shake") == 1, "enemy wrapper consumes status on first completion")
	controller.call("_mark_enemy_unit_acted", enemy)
	_expect(enemy.get_status_turns("shake") == 1, "repeated enemy completion does not consume status twice")
	var destination_reservations: Dictionary = controller.get("enemy_ai_reserved_destination_cells")
	var engagement_reservations: Dictionary = controller.get("enemy_ai_reserved_engagement_cells")
	destination_reservations[Vector2i(1, 1)] = "test"
	engagement_reservations[Vector2i(2, 2)] = "test"
	enemy.is_defending = true
	controller.call("_reset_enemy_action_locks_for_new_round")
	_expect(not enemy.has_acted and not enemy.has_moved and not enemy.is_defending, "enemy reset preserves reset_action_flags")
	_expect(destination_reservations.is_empty() and engagement_reservations.is_empty(), "enemy reset still clears AI reservations")
	_expect(not bool(controller.call("_has_enemy_unit_acted", enemy)), "enemy reset clears service registry")
	_expect(controller.call("_get_first_available_ally_unit") == allies[0], "ally first-available wrapper preserves order")
	_expect(controller.call("_get_next_available_enemy_ai_actor") == enemies[0], "enemy next-actor wrapper preserves slot order")
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


func _unit(unit_id: String, side: String) -> BattleUnitState:
	var unit := BattleUnitState.new()
	unit.unit_id = unit_id
	unit.display_name = unit_id
	unit.side = side
	unit.current_hp = 100
	unit.max_hp = 100
	unit.current_troops = 100
	unit.max_troops = 100
	return unit


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("[BATTLE_ACTION_LOCK_STATE_SERVICE_FAIL] %s" % label)
