extends SceneTree

const CooldownStateServiceScript := preload("res://scripts/battle/services/battle_unique_skill_cooldown_state_service.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_direct_state_semantics()
	_test_snapshot_isolation()
	await _test_controller_wrapper_parity()
	print("[BATTLE_UNIQUE_SKILL_COOLDOWN_STATE_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_direct_state_semantics() -> void:
	var service := CooldownStateServiceScript.new()
	_expect(service.get_remaining("") == 0, "empty key query returns zero")
	_expect(service.get_remaining("hero-a") == 0, "missing key query returns zero")
	service.set_remaining("", 5)
	_expect(service.export_state().is_empty(), "empty key set is ignored")
	service.set_remaining("hero-a", -3)
	_expect(service.get_remaining("hero-a") == 0, "negative cooldown clamps to zero")
	service.set_remaining("hero-a", 3)
	service.set_remaining("hero-b", 2)
	_expect(service.get_remaining("hero-a") == 3, "positive cooldown is stored")
	var keys: Array[String] = ["hero-a", "hero-a", "", "hero-b"]
	service.tick_keys(keys)
	_expect(service.get_remaining("hero-a") == 2, "duplicate hero key ticks once")
	_expect(service.get_remaining("hero-b") == 1, "second hero key ticks once")
	var second_tick_keys: Array[String] = ["hero-a", "hero-b"]
	service.tick_keys(second_tick_keys)
	_expect(service.get_remaining("hero-a") == 1, "cooldown continues decrementing")
	_expect(service.get_remaining("hero-b") == 0, "cooldown reaches zero")
	var zero_tick_keys: Array[String] = ["hero-b"]
	service.tick_keys(zero_tick_keys)
	_expect(service.get_remaining("hero-b") == 0, "zero cooldown remains zero")
	service.clear()
	_expect(service.export_state().is_empty(), "clear removes all cooldown state")


func _test_snapshot_isolation() -> void:
	var service := CooldownStateServiceScript.new()
	service.restore_state({"hero-a": {"nested": 2}, "hero-b": 4})
	var exported := service.export_state()
	(exported["hero-a"] as Dictionary)["nested"] = 0
	_expect(int((service.export_state()["hero-a"] as Dictionary).get("nested", 0)) == 2, "export returns deep copy")
	var source := {"hero-c": {"nested": 3}}
	service.restore_state(source)
	(source["hero-c"] as Dictionary)["nested"] = 0
	_expect(int((service.export_state()["hero-c"] as Dictionary).get("nested", 0)) == 3, "restore deep-copies dictionary input")
	service.restore_state("invalid")
	_expect(service.export_state().is_empty(), "non-dictionary restore clears state")


func _test_controller_wrapper_parity() -> void:
	var packed := load("res://scenes/battle/Battle_Main.tscn") as PackedScene
	_expect(packed != null, "Battle_Main loads for cooldown wrapper parity")
	if packed == null:
		return
	var controller := packed.instantiate()
	root.add_child(controller)
	await process_frame

	var allies: Array[BattleUnitState] = controller.call("_get_alive_ally_units")
	_expect(not allies.is_empty(), "Battle_Main fixture provides an alive ally")
	if allies.is_empty():
		controller.free()
		await _finish_fixture_audio()
		await process_frame
		return

	var unit_state := allies[0]
	var cooldown_key := str(controller.call("_get_unique_skill_cooldown_key", unit_state))
	_expect(not cooldown_key.is_empty(), "fixture ally resolves a cooldown key")
	var service = controller.get("unique_skill_cooldown_state_service")
	_expect(service != null, "controller owns cooldown state service")
	if service != null and not cooldown_key.is_empty():
		controller.call("_set_unique_skill_cooldown", unit_state, 3)
		_expect(int(service.get_remaining(cooldown_key)) == 3, "set wrapper delegates cooldown state")
		controller.call("_tick_unique_skill_cooldowns_for_side", "ally")
		_expect(int(service.get_remaining(cooldown_key)) == 2, "side tick wrapper decrements deployed ally cooldown once")
		var exported: Dictionary = service.export_state()
		_expect(exported.has(cooldown_key), "controller cooldown state exports through service")
		service.clear()
		_expect(int(service.get_remaining(cooldown_key)) == 0, "service clear is visible to controller state")

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
	push_error("[BATTLE_UNIQUE_SKILL_COOLDOWN_STATE_SERVICE_FAIL] %s" % label)
