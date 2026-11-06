extends SceneTree
# M7-4: the 3D top "후퇴" button. The engine decides (one source): on only in a worldmap attack context before a result.
#   scenario mode: off, the off tooltip, a press does nothing.
#   defense context (the worldmap's own invasion builder): off, a press does nothing (no meta, no scene change).
#   attack context, during full auto: on with the on tooltip; one press stops the auto, the result meta says "retreat"
#     (not "defeat") with the context's transaction id, the scene becomes the worldmap, no resume file, and the applied
#     settlement equals the 2D reference: the same context in the canonical battle scene (the 3D engine host's own
#     create_battle()) and the same engine retreat function. A second press in the same frame does nothing.
# The attack context is the real builder plus the confirm function's departure / pending / snapshot steps (M7-2).
const CONTEXT_KEY := "samwar_worldmap_battle_context"
const RESULT_KEY := "samwar_worldmap_battle_result"
const RESUME_PATH := "user://battle_runtime_resume.json"
const WORLDMAP_SCENE := "res://WorldMap.tscn" # the scene the context comes from and the result returns to
const ENGINE_HOST := "res://scripts/battle3d/battle3d_engine_host.gd"
const SOURCE_CITY := "hanseong"
const TARGET_CITY := "pyeongyang"
const OFF_TOOLTIP := "월드맵 공격전에서만 후퇴할 수 있습니다."
const ON_TOOLTIP := "후퇴 · 생존 병력과 남은 보급을 출발 도시로 복귀"
var h
var checks := 0
var failures: Array = []
var hero_id := ""
var player_faction := ""
var saved_resume: PackedByteArray = PackedByteArray()
var had_resume := false


func _initialize() -> void:
	run.call_deferred()


func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		push_error("[BATTLE3D_RETREAT_FAIL] " + label)


func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	had_resume = FileAccess.file_exists(RESUME_PATH)
	if had_resume: saved_resume = FileAccess.get_file_as_bytes(RESUME_PATH)
	var contexts: Dictionary = await real_worldmap_contexts()
	expect(not contexts.get("attack", {}).is_empty() and not contexts.get("defense", {}).is_empty(), "the real WorldMap built an attack and a defense context")
	if contexts.get("attack", {}).is_empty() or contexts.get("defense", {}).is_empty():
		await finish()
		return
	await scenario_mode_off()
	await defense_context_off(contexts.defense)
	var reference: Dictionary = await run_2d(contexts.attack)
	var returned: Dictionary = await run_3d(contexts.attack)
	expect(not reference.is_empty() and not returned.is_empty(), "both paths reached the worldmap")
	if not reference.is_empty() and not returned.is_empty():
		for key in reference.settlement:
			expect(returned.settlement.get(key) == reference.settlement[key], "settlement %s 3D %s == 2D %s" % [key, str(returned.settlement.get(key)), str(reference.settlement[key])])
		for key in reference.payload:
			expect(returned.payload.get(key) == reference.payload[key], "result payload %s 3D %s == 2D %s" % [key, str(returned.payload.get(key)), str(reference.payload[key])])
		expect(returned.settlement.result_id_applied_once and returned.settlement.pending_context_cleared, "the worldmap applied the retreat settlement (%s)" % returned.settlement.status)
		print("[BATTLE3D_RETREAT] settlement %s" % str(returned.settlement))
	await finish()


func scenario_mode_off() -> void:
	await h.open_shell(self)
	await h.press_scenario(self, "default")
	await process_frame
	var cmd: Node = h.shell.top_commands
	expect(cmd.retreat_button.disabled and cmd.retreat_button.tooltip_text == OFF_TOOLTIP and not h.shell.retreat_available(), "scenario mode: retreat off ('%s')" % cmd.retreat_button.tooltip_text)
	var writes: Array = h.lab.engine.writes.duplicate()
	cmd.retreat_button.pressed.emit()
	expect(h.lab.engine.writes == writes and retreat_log_count(h.lab) == [0, 0] and h.lab.engine.call("_get_battle_result_state") == "" and not Engine.has_meta(RESULT_KEY), "scenario mode: a press sends nothing to the engine")
	await h.close_shell(self)


func defense_context_off(context: Dictionary) -> void:
	clear_metas()
	var shell: Node = await open_context_shell(context)
	expect(shell.lab != null and shell.worldmap_context_mode, "defense: the shell starts in context mode")
	if shell.lab == null:
		await unload_scene()
		return
	var lab: Node = shell.lab
	while not lab.ready_for_input: await process_frame
	await process_frame
	var engine: Node = lab.engine
	expect(not bool(engine.call("_is_worldmap_player_attack_context", engine.worldmap_battle_context)), "defense: the engine rule says not an attack")
	var cmd: Node = shell.top_commands
	expect(cmd.retreat_button.disabled and cmd.retreat_button.tooltip_text == OFF_TOOLTIP and not shell.retreat_available(), "defense context: retreat off ('%s')" % cmd.retreat_button.tooltip_text)
	var writes: Array = engine.writes.duplicate()
	cmd.retreat_button.pressed.emit()
	await process_frame
	expect(engine.writes == writes and retreat_log_count(lab) == [0, 0] and not Engine.has_meta(RESULT_KEY) and current_scene == shell and engine.call("_get_battle_result_state") == "", "defense context: a press does nothing (no engine call, no meta, same scene)")
	await unload_scene()


func run_2d(context: Dictionary) -> Dictionary:
	clear_metas()
	Engine.set_meta(CONTEXT_KEY, context.duplicate(true))
	var host: Node = load(ENGINE_HOST).new()
	var battle: Node = host.create_battle()
	host.free()
	root.add_child(battle)
	current_scene = battle
	for i in 3: await process_frame
	battle.call("_on_retreat_button_pressed")
	var payload: Dictionary = Engine.get_meta(RESULT_KEY, {}) if Engine.has_meta(RESULT_KEY) else {}
	expect(str(payload.get("result", "")) == "retreat", "2D reference: the engine retreat gives 'retreat' (%s)" % str(payload.get("result", "")))
	var worldmap: Node = await wait_worldmap()
	expect(worldmap != null, "2D reference: the engine returned to the worldmap")
	if worldmap == null: return {}
	var out := {"payload": comparable_payload(payload), "settlement": settlement(worldmap, payload)}
	await unload_scene()
	return out


func run_3d(context: Dictionary) -> Dictionary:
	clear_metas()
	write_resume_marker()
	var shell: Node = await open_context_shell(context)
	expect(shell.lab != null and shell.worldmap_context_mode, "attack: the shell starts in context mode")
	if shell.lab == null:
		await unload_scene()
		return {}
	var lab: Node = shell.lab
	while not lab.ready_for_input: await process_frame
	await physics_frame
	await process_frame
	var engine: Node = lab.engine
	var cmd: Node = shell.top_commands
	expect(not cmd.retreat_button.disabled and cmd.retreat_button.tooltip_text == ON_TOOLTIP and shell.retreat_available(), "attack context: retreat on ('%s')" % cmd.retreat_button.tooltip_text)
	cmd.auto_button.pressed.emit()
	expect(bool(engine.is_full_auto_battle_enabled), "full auto on before the retreat")
	expect(not cmd.retreat_button.disabled, "retreat stays on during full auto")
	cmd.retreat_button.pressed.emit()
	var payload: Dictionary = Engine.get_meta(RESULT_KEY, {}) if Engine.has_meta(RESULT_KEY) else {}
	expect(not bool(engine.is_full_auto_battle_enabled), "the retreat stopped the full auto")
	expect(str(payload.get("result", "")) == "retreat" and str(payload.get("result", "")) != "defeat", "the result is 'retreat', not 'defeat' (%s)" % str(payload.get("result", "")))
	expect(str(payload.get("transaction_id", "")) == str(context.transaction_id), "the result keeps the context's transaction id")
	expect(str(engine.get("battle_result_reason")) == "retreat", "the engine's result reason is retreat")
	expect(cmd.retreat_button.disabled, "the button is off right after the press")
	var writes_after: Array = engine.writes.duplicate()
	cmd.retreat_button.pressed.emit() # a second press in the same frame
	expect(engine.writes == writes_after and Engine.get_meta(RESULT_KEY, {}) == payload, "a second press sends nothing more")
	expect(retreat_log_count(lab) == [1, 0], "one engine retreat (log lines accepted/refused %s)" % str(retreat_log_count(lab)))
	expect(not FileAccess.file_exists(RESUME_PATH), "no battle resume file after the retreat")
	var worldmap: Node = await wait_worldmap()
	expect(worldmap != null, "the scene became the worldmap")
	expect(not is_instance_valid(shell), "the 3D shell is gone with the old scene")
	if worldmap == null:
		await unload_scene()
		return {}
	expect(not Engine.has_meta(RESULT_KEY), "the worldmap consumed the result meta")
	var out := {"payload": comparable_payload(payload), "settlement": settlement(worldmap, payload)}
	await unload_scene()
	return out


func retreat_log_count(lab: Node) -> Array:
	# The engine logs each _on_retreat_button_pressed: accepted "후퇴 명령 ·", refused "후퇴할 수 없습니다" (the test spy
	# records the 15 command writes only).
	var lines: Array = lab.read_battle_log_lines()
	return [lines.filter(func(l): return "후퇴 명령" in str(l)).size(), lines.filter(func(l): return "후퇴할 수 없습니다" in str(l)).size()]


func open_context_shell(context: Dictionary) -> Node:
	Engine.set_meta(CONTEXT_KEY, context.duplicate(true))
	root.size = Vector2i(1920, 1080)
	var shell: Node = h.SpyShell.new()
	shell.test_world = h.test_world
	root.add_child(shell)
	current_scene = shell # the engine's scene change replaces the current scene: the shell, as in the game
	await process_frame
	return shell


func wait_worldmap() -> Node:
	for i in 6:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == WORLDMAP_SCENE: break
	if current_scene == null or current_scene.scene_file_path != WORLDMAP_SCENE: return null
	for i in 3: await process_frame
	return current_scene


func settlement(worldmap: Node, payload: Dictionary) -> Dictionary:
	var player_state: Dictionary = worldmap.get("_player_state")
	var applied: Array = player_state.get("applied_battle_result_ids", []) if player_state.get("applied_battle_result_ids", []) is Array else []
	return {
		"target_owner": str(worldmap.call("_get_city_owner_id_for_battle_context", TARGET_CITY)),
		"target_troops": int(worldmap.call("_get_city_troops_for_battle_context", TARGET_CITY)),
		"source_owner": str(worldmap.call("_get_city_owner_id_for_battle_context", SOURCE_CITY)),
		"source_troops": int(worldmap.call("_get_city_troops_for_battle_context", SOURCE_CITY)),
		"hero_city": str(worldmap.call("_get_hero_city_id_for_battle_context", hero_id)),
		"pending_context_cleared": (worldmap.call("_get_pending_battle_context_mvp") as Dictionary).is_empty(),
		"result_id_applied_once": applied.count(str(payload.get("result_id", ""))) == 1,
		"status": str(worldmap.get("_save_management_status")),
	}


func comparable_payload(payload: Dictionary) -> Dictionary:
	var out := {}
	for key in payload:
		if key == "result_id" or "time" in str(key) or "timestamp" in str(key): continue
		out[key] = payload[key]
	return out


func write_resume_marker() -> void:
	var file := FileAccess.open(RESUME_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string("{}")
		file.close()


func clear_metas() -> void:
	for key in [CONTEXT_KEY, RESULT_KEY]:
		if Engine.has_meta(key): Engine.remove_meta(key)


func unload_scene() -> void:
	if current_scene != null:
		var scene := current_scene
		current_scene = null
		if scene.get_parent() == root: root.remove_child(scene)
		scene.free()
	await process_frame


func real_worldmap_contexts() -> Dictionary:
	var worldmap: Node = load(WORLDMAP_SCENE).instantiate()
	root.add_child(worldmap)
	await process_frame
	await process_frame
	var out := {}
	# Defense: the worldmap's own invasion builder, as test_worldmap_battle_context_service_extraction makes it.
	var invasion_event := {"type": "defense", "attacker_city_id": TARGET_CITY, "defender_city_id": SOURCE_CITY, "turn_number": 1}
	var defense: Dictionary = (worldmap.call("_build_battle_context_from_pending_invasion", invasion_event, "manual") as Dictionary).duplicate(true)
	if not defense.is_empty():
		defense["transaction_id"] = "t-test-4d"
		defense["result_return_destination"] = WORLDMAP_SCENE
	out["defense"] = defense
	var hero_ids: Array = worldmap.call("_get_available_player_attack_main_hero_ids", SOURCE_CITY)
	if hero_ids.is_empty():
		worldmap.free()
		return out
	hero_id = str(hero_ids[0])
	var supply: Dictionary = worldmap.call("_calculate_player_attack_supply_cost", 1)
	var food := maxi(0, int(supply.get("food", 0)))
	var food_type := ""
	for candidate in ["rice", "barley", "seafood"]:
		if food_type.is_empty() and int(worldmap.call("_get_city_supply_resource_amount", SOURCE_CITY, candidate)) >= food: food_type = candidate
	var supply_cost := {"food_type": food_type, "food": food, "gold": maxi(0, int(supply.get("gold", 0))), "salt": maxi(0, int(supply.get("salt", 0))), food_type: food}
	var selected: Array[String] = [hero_id]
	var context: Dictionary = (worldmap.call("_build_player_attack_battle_context", SOURCE_CITY, TARGET_CITY, "manual", selected, {hero_id: 1}, supply_cost) as Dictionary).duplicate(true)
	if not context.is_empty():
		context["attacker_total_allocated_troops"] = 1
		context["attacker_source_city_id"] = SOURCE_CITY
		context["transaction_id"] = "t-test-4"
		context["scenario_id"] = str(worldmap.get("_player_state").get("active_scenario_id", "korea_mvp"))
		context["player_faction_id"] = str(worldmap.call("_get_current_player_faction_id"))
		context["result_return_destination"] = WORLDMAP_SCENE
		# The rest of _confirm_player_attack_deployment before its handoff (M7-2): departure, pending, snapshot.
		var departure: Dictionary = worldmap.call("_ensure_player_attack_deployment_service").apply_departure(context, selected, supply_cost)
		if bool(departure.get("ok", false)):
			context = (departure.get("context", {}) as Dictionary).duplicate(true)
			worldmap.call("_set_pending_battle_context_mvp", context)
			var snapshot: Dictionary = worldmap.call("_serialize_worldmap_state")
			var snapshot_player_state: Dictionary = snapshot.get("player_state", {}).duplicate(true)
			snapshot_player_state["pending_battle_context"] = {"transaction_id": str(context.get("transaction_id", ""))}
			snapshot["player_state"] = snapshot_player_state
			context["worldmap_state_snapshot"] = snapshot
			player_faction = str(context.get("player_faction_id", ""))
		else:
			context = {}
	out["attack"] = context
	worldmap.free()
	await process_frame
	return out


func finish() -> void:
	clear_metas()
	if FileAccess.file_exists(RESUME_PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(RESUME_PATH))
	if had_resume:
		var file := FileAccess.open(RESUME_PATH, FileAccess.WRITE)
		if file != null:
			file.store_buffer(saved_resume)
			file.close()
	await unload_scene()
	print("[BATTLE3D_RETREAT] checks=%d failures=%s" % [checks, str(failures)])
	var code := 0 if failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
