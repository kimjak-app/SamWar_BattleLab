extends SceneTree
# M7-2: the 3D result panel goes back to the worldmap. For a victory and a defeat:
#   2D reference: the same worldmap battle context in the canonical battle scene (the very scene the 3D lab's engine
#     host instantiates, battle3d_engine_host.create_battle()), the same units knocked out, the engine's own return.
#   3D: the shell opened in context mode as the current scene, the same units knocked out, the engine's battle end
#     guard emits battle_ended to the lab, the shell plays its ending and shows the result panel, the "월드맵으로" button.
# Checked: the button only in context mode; one press = one result meta with the context's transaction id and the
# result; the scene becomes the worldmap; no battle resume file; the worldmap applies the settlement and its result
# (owners, garrisons, hero city, pending context, applied result id) equals the 2D reference; a second press does nothing.
# The context comes from the real WorldMap builder as in M7-1 (no departure confirm, no handoff).
# Knocking the units out (current_hp / current_troops = 0) is the 2D roundtrip settlement test's way of ending a battle;
# the 3D side then calls the engine's _handle_battle_end_guard, the engine function that records battle_ended for the lab.
const CONTEXT_KEY := "samwar_worldmap_battle_context"
const RESULT_KEY := "samwar_worldmap_battle_result"
const RESUME_PATH := "user://battle_runtime_resume.json"
const WORLDMAP_SCENE := "res://WorldMap.tscn" # the scene the context comes from and the result returns to
const ENGINE_HOST := "res://scripts/battle3d/battle3d_engine_host.gd"
const SOURCE_CITY := "hanseong"
const TARGET_CITY := "pyeongyang"
const MAX_ENDING_FRAMES := 20000
var h
var checks := 0
var failures: Array = []
var hero_id := ""
var saved_resume: PackedByteArray = PackedByteArray() # a resume file that was there before the test, put back at the end
var had_resume := false
var player_faction := ""
var target_owner_before := ""


func _initialize() -> void:
	run.call_deferred()


func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		push_error("[BATTLE3D_RESULT_RETURN_FAIL] " + label)


func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	had_resume = FileAccess.file_exists(RESUME_PATH)
	if had_resume: saved_resume = FileAccess.get_file_as_bytes(RESUME_PATH)
	var context: Dictionary = await real_worldmap_context()
	expect(not context.is_empty(), "the real WorldMap built a player attack context")
	if context.is_empty():
		await finish()
		return
	await scenario_mode_has_no_worldmap_button()
	for result in ["victory", "defeat"]:
		var reference: Dictionary = await run_2d(context, result)
		var returned: Dictionary = await run_3d(context, result)
		expect(not reference.is_empty() and not returned.is_empty(), "%s: both paths reached the worldmap" % result)
		if reference.is_empty() or returned.is_empty(): continue
		for key in reference.settlement:
			expect(returned.settlement.get(key) == reference.settlement[key], "%s: settlement %s 3D %s == 2D %s" % [result, key, str(returned.settlement.get(key)), str(reference.settlement[key])])
		for key in reference.payload:
			expect(returned.payload.get(key) == reference.payload[key], "%s: result payload %s 3D %s == 2D %s" % [result, key, str(returned.payload.get(key)), str(reference.payload[key])])
		# The settlement really ran (not only "same as 2D"): the result id is recorded once, the pending context cleared,
		# and the target city goes to the player on a victory, stays with its owner on a defeat.
		var applied: Dictionary = returned.settlement
		expect(applied.result_id_applied_once and applied.pending_context_cleared, "%s: the worldmap applied the settlement (%s)" % [result, applied.status])
		if result == "victory":
			expect(applied.target_owner == player_faction and applied.hero_city == TARGET_CITY, "victory: %s taken by the player, the hero moved there" % TARGET_CITY)
		else:
			expect(applied.target_owner == target_owner_before and applied.target_owner != player_faction, "defeat: %s stays with %s" % [TARGET_CITY, target_owner_before])
		print("[BATTLE3D_RESULT_RETURN] %s settlement %s" % [result, str(returned.settlement)])
	await finish()


func scenario_mode_has_no_worldmap_button() -> void:
	# Outside context mode the result panel keeps its two buttons only.
	await h.open_shell(self)
	await h.press_scenario(self, "default")
	expect(not h.shell.worldmap_context_mode and not h.shell.worldmap_button.visible, "scenario mode: no worldmap button")
	knock_out(h.lab.engine, "enemy")
	h.lab.engine.call("_handle_battle_end_guard", "m7_2_test")
	await wait_result_panel(h.shell)
	expect(h.shell.result_panel.visible and not h.shell.worldmap_button.visible and h.shell.restart_button.visible and h.shell.choose_button.visible,
		"scenario mode result panel: restart and choose, no worldmap button")
	var before := Engine.has_meta(RESULT_KEY)
	h.shell.return_to_worldmap() # a call outside context mode does nothing
	expect(Engine.has_meta(RESULT_KEY) == before and h.shell.lab != null, "scenario mode: return_to_worldmap does nothing")
	await h.close_shell(self)


func run_2d(context: Dictionary, result: String) -> Dictionary:
	clear_metas()
	Engine.set_meta(CONTEXT_KEY, context.duplicate(true))
	var host: Node = load(ENGINE_HOST).new()
	var battle: Node = host.create_battle()
	host.free()
	root.add_child(battle)
	current_scene = battle
	for i in 3: await process_frame
	expect(str(battle.get("worldmap_battle_context").get("transaction_id", "")) == str(context.transaction_id), "%s 2D: the engine holds the context" % result)
	knock_out(battle, "enemy" if result == "victory" else "ally")
	expect(str(battle.call("_get_battle_result_state")) == result, "%s 2D: the engine reports %s" % [result, result])
	battle.call("_return_to_worldmap_with_result")
	var payload: Dictionary = Engine.get_meta(RESULT_KEY, {}) if Engine.has_meta(RESULT_KEY) else {}
	var worldmap: Node = await wait_worldmap()
	expect(worldmap != null, "%s 2D: the engine returned to the worldmap" % result)
	if worldmap == null: return {}
	var out := {"payload": comparable_payload(payload), "settlement": settlement(worldmap, payload)}
	await unload_scene()
	return out


func run_3d(context: Dictionary, result: String) -> Dictionary:
	clear_metas()
	write_resume_marker()
	Engine.set_meta(CONTEXT_KEY, context.duplicate(true))
	root.size = Vector2i(1280, 800)
	var shell: Node = h.SpyShell.new()
	shell.test_world = h.test_world
	root.add_child(shell)
	current_scene = shell # the engine's change_scene_to_file replaces the current scene: the shell, as in the game
	await process_frame
	expect(shell.lab != null and shell.worldmap_context_mode, "%s 3D: the shell starts in context mode" % result)
	if shell.lab == null:
		await unload_scene()
		return {}
	var lab: Node = shell.lab
	while not lab.ready_for_input: await process_frame
	await physics_frame
	expect(not shell.result_panel.visible, "%s 3D: no result panel during the battle" % result)
	var engine: Node = lab.engine
	expect(str(engine.worldmap_battle_context.get("transaction_id", "")) == str(context.transaction_id), "%s 3D: the engine holds the context" % result)
	# Before the battle ends the engine refuses: the button is usable again and no meta is set.
	shell.return_to_worldmap()
	expect(not Engine.has_meta(RESULT_KEY) and not shell.worldmap_button.disabled and current_scene == shell, "%s 3D: before the end the engine refuses, button usable again" % result)
	knock_out(engine, "enemy" if result == "victory" else "ally")
	engine.call("_handle_battle_end_guard", "m7_2_test")
	await wait_result_panel(shell)
	expect(lab.battle_result == result and shell.result_panel.visible, "%s 3D: the lab got battle_ended and the shell shows the result panel (lab %s)" % [result, lab.battle_result])
	expect(shell.worldmap_button.visible and not shell.worldmap_button.disabled and not shell.restart_button.visible and not shell.choose_button.visible,
		"%s 3D: result panel shows the worldmap button only" % result)
	expect(shell.worldmap_button.get_parent() == shell.restart_button.get_parent() and shell.worldmap_button.custom_minimum_size == shell.restart_button.custom_minimum_size,
		"%s 3D: the button sits in the result row, same size" % result)
	shell.worldmap_button.pressed.emit()
	var payload: Dictionary = Engine.get_meta(RESULT_KEY, {}) if Engine.has_meta(RESULT_KEY) else {}
	expect(not payload.is_empty(), "%s 3D: one press sets the result meta" % result)
	expect(str(payload.get("transaction_id", "")) == str(context.transaction_id) and str(payload.get("result", "")) == result,
		"%s 3D: meta transaction %s result %s" % [result, str(payload.get("transaction_id", "")), str(payload.get("result", ""))])
	expect(shell.worldmap_button.disabled, "%s 3D: the button is disabled after the press" % result)
	shell.worldmap_button.pressed.emit() # a second press before the scene changes
	expect(Engine.has_meta(RESULT_KEY) and Engine.get_meta(RESULT_KEY) == payload, "%s 3D: a second press does not build another result" % result)
	expect(not FileAccess.file_exists(RESUME_PATH), "%s 3D: no battle resume file after the return" % result)
	var worldmap: Node = await wait_worldmap()
	expect(worldmap != null, "%s 3D: the scene became the worldmap" % result)
	expect(not is_instance_valid(shell), "%s 3D: the 3D shell is gone with the old scene" % result)
	if worldmap == null:
		await unload_scene()
		return {}
	expect(not Engine.has_meta(RESULT_KEY), "%s 3D: the worldmap consumed the result meta" % result)
	var out := {"payload": comparable_payload(payload), "settlement": settlement(worldmap, payload)}
	await unload_scene()
	return out


func knock_out(battle: Node, side: String) -> void:
	for unit in battle.call("_get_deployed_unit_states_for_side", side):
		unit.set("current_hp", 0)
		unit.set("current_troops", 0)


func wait_result_panel(shell: Node) -> void:
	for i in MAX_ENDING_FRAMES:
		if shell.result_panel.visible: return
		await process_frame


func wait_worldmap() -> Node:
	for i in 6:
		await process_frame
		if current_scene != null and current_scene.scene_file_path == WORLDMAP_SCENE: break
	if current_scene == null or current_scene.scene_file_path != WORLDMAP_SCENE: return null
	for i in 3: await process_frame # main._ready consumed the result meta and settled
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
		"pending_battles": str(player_state.get("pending_battle_context", {})),
		"status": str(worldmap.get("_save_management_status")),
	}


func comparable_payload(payload: Dictionary) -> Dictionary:
	# The payload without its per-call identity (result id) and clock fields.
	var out := {}
	for key in payload:
		if key == "result_id" or "time" in str(key) or "timestamp" in str(key): continue
		out[key] = payload[key]
	return out


func write_resume_marker() -> void:
	# A resume file left from an earlier battle: the engine's return must clear it (the 2D path does).
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
		root.remove_child(scene)
		scene.free()
	await process_frame


func real_worldmap_context() -> Dictionary:
	var worldmap: Node = load(WORLDMAP_SCENE).instantiate()
	root.add_child(worldmap)
	await process_frame
	await process_frame
	var hero_ids: Array = worldmap.call("_get_available_player_attack_main_hero_ids", SOURCE_CITY)
	if hero_ids.is_empty():
		worldmap.free()
		return {}
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
		# The fields _confirm_player_attack_deployment adds after the builder (same names, as in M7-1).
		context["attacker_total_allocated_troops"] = 1
		context["attacker_source_city_id"] = SOURCE_CITY
		context["transaction_id"] = "t-test-2"
		context["scenario_id"] = str(worldmap.get("_player_state").get("active_scenario_id", "korea_mvp"))
		context["player_faction_id"] = str(worldmap.call("_get_current_player_faction_id"))
		context["result_return_destination"] = WORLDMAP_SCENE
		# The rest of _confirm_player_attack_deployment before its handoff, with the same calls: the departure, the
		# pending context and the state snapshot the returning worldmap settles against (its transaction id). Without
		# them the worldmap rejects the result ("트랜잭션 ID 불일치"). The confirm function and the handoff are not called.
		var departure: Dictionary = worldmap.call("_ensure_player_attack_deployment_service").apply_departure(context, selected, supply_cost)
		if not bool(departure.get("ok", false)):
			worldmap.free()
			return {}
		context = (departure.get("context", {}) as Dictionary).duplicate(true)
		worldmap.call("_set_pending_battle_context_mvp", context)
		var snapshot: Dictionary = worldmap.call("_serialize_worldmap_state")
		var snapshot_player_state: Dictionary = snapshot.get("player_state", {}).duplicate(true)
		snapshot_player_state["pending_battle_context"] = {"transaction_id": str(context.get("transaction_id", ""))}
		snapshot["player_state"] = snapshot_player_state
		context["worldmap_state_snapshot"] = snapshot
		player_faction = str(context.get("player_faction_id", ""))
		target_owner_before = str(worldmap.call("_get_city_owner_id_for_battle_context", TARGET_CITY))
	worldmap.free()
	await process_frame
	return context


func finish() -> void:
	clear_metas()
	if FileAccess.file_exists(RESUME_PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(RESUME_PATH))
	if had_resume:
		var file := FileAccess.open(RESUME_PATH, FileAccess.WRITE)
		if file != null:
			file.store_buffer(saved_resume)
			file.close()
	await unload_scene()
	print("[BATTLE3D_RESULT_RETURN] checks=%d failures=%s" % [checks, str(failures)])
	var code := 0 if failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
