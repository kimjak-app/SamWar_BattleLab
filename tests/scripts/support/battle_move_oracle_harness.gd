extends RefCounted
const Fingerprint = preload("res://scripts/battle/services/battle_state_fingerprint_service.gd")
const EventLog = preload("res://scripts/battle/services/battle_event_log_service.gd")
var fingerprint := Fingerprint.new()
var failures: Array[String] = []
var checks := 0

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("[MOVE_ORACLE] FAIL: ", label)

func run_case(tree: SceneTree, label: String) -> Dictionary:
	# Deliberately dynamic: run_case is called after SceneTree's deferred _run.
	var packed := load("res://scenes/battle/Battle_Main.tscn") as PackedScene
	expect(packed != null, label + " dynamic load")
	if packed == null:
		return {}
	var battle := packed.instantiate()
	tree.root.add_child(battle)
	await tree.process_frame
	battle.call("_skip_battle_intro_camera_zoom")
	var units: Array[BattleUnitState] = []
	for unit in battle.call("_get_all_unit_states_in_slot_order"):
		units.append(unit)
	expect(units.size() == 10, label + " actual controller roster")
	if units.size() != 10:
		battle.free()
		return {}
	# Deterministic test layout, keeping production identities/skills/capacity policy.
	# Only fixture preparation writes state. All observed actions use production calls.
	for i in range(units.size()):
		units[i].set_grid_cell(Vector2i(13 + i % 4, 5 + i / 4))
		units[i].reset_action_flags()
	var mover := units[0]
	mover.set_grid_cell(Vector2i(2,2))
	mover.facing = "left"
	mover.move_range = 6 # enough for the deliberate four-step detour
	mover.last_action = {"type":"fixture_before_move", "sentinel":73}
	if label == "M2" or label == "M3_occupied":
		units[1].set_grid_cell(Vector2i(3,2))
	if label == "M3_no_path":
		for pair in [[1,Vector2i(3,2)],[2,Vector2i(1,2)],[5,Vector2i(2,3)],[6,Vector2i(2,1)]]:
			units[pair[0]].set_grid_cell(pair[1])
	for unit in units:
		battle.call("_sync_resumed_unit_markers_to_grid",unit)
	battle.call("_sync_demo_positions")
	battle.call("_select_ally_unit",mover,false,false,false)
	await tree.process_frame
	var checkpoints := [_snapshot(battle,units,"start")]
	var initial: Dictionary = checkpoints[0]
	expect(initial.controller.current_phase == "ally_turn", label + " ready ally turn")
	expect(not initial.controller.has_pending_move_snapshot, label + " no initial pending move")
	var target := Vector2i(4,2)
	if label == "M3_occupied": target = Vector2i(3,2)
	if label == "M3_range": target = Vector2i(17,2)
	if label == "M4": target = Vector2i(2,4)
	var path: Array = battle.call("_find_ally_move_path",mover.grid_cell,target)
	var path_json := []
	for cell in path: path_json.append([cell.x,cell.y])
	var log_service := EventLog.new()
	if label.begins_with("M3_"):
		if label == "M3_no_path": expect(path.is_empty(), label + " no route")
		if label == "M3_range": expect(path.is_empty(), label + " outside budget")
		if label == "M3_occupied": expect(not battle.call("_is_valid_destination_for_unit",target,mover), label + " occupied")
		battle.call("set_move_target_cell",target)
		battle.call("play_basic_move_demo")
		await tree.process_frame
		var rejected := _snapshot(battle,units,"rejected")
		checkpoints.append(rejected)
		_expect_state_equal(initial,rejected,label + " rejected state unchanged")
		expect(not battle.get("is_demo_animating"),label + " no animation")
	else:
		expect(path.size() >= 2,label + " valid path")
		if label == "M2": expect(path.size()-1 > 2,label + " genuine detour")
		battle.call("set_move_target_cell",target)
		expect(battle.get("has_selected_move_target"),label + " target selected")
		battle.call("play_basic_move_demo")
		expect(battle.get("is_demo_animating"),label + " actual tween started")
		var last_facing := mover.facing
		var reached := false
		for frame in range(1800):
			await tree.process_frame
			if mover.facing != last_facing:
				log_service.emit("facing_changed",{"unit_id":mover.unit_id,"from":last_facing,"to":mover.facing,"reason":"step"})
				last_facing = mover.facing
			if battle.get("current_phase") == "facing_select" and not battle.get("is_demo_animating"):
				reached = true
				break
		expect(reached,label + " reached FACING_SELECT via frames (max 1800)")
		if not reached:
			printerr("[MOVE_ORACLE] STOP phase=",battle.get("current_phase")," cell=",mover.grid_cell)
			battle.free()
			await _finish_audio(tree)
			return {}
		var finished := _snapshot(battle,units,"move_finished")
		checkpoints.append(finished)
		expect(mover.grid_cell == target,label + " final cell")
		expect(mover.has_moved and not mover.has_acted,label + " moved but not acted")
		expect(battle.get("ally_has_moved") and battle.get("has_pending_move_snapshot"),label + " pending facing")
		expect(mover.last_action.get("moved_distance",-1) == 2,label + " grid distance not path length")
		expect(mover.last_action.get("origin_cell",[]) == [2,2] and mover.last_action.get("destination_cell",[]) == [target.x,target.y],label + " last_action cells")
		if label == "M4": expect(mover.facing == "left",label + " vertical steps retain facing")
		var moved_event: Dictionary = log_service.emit("unit_moved",{
			"unit_id":mover.unit_id,"from":[2,2],"to":[target.x,target.y],"path":path_json,
			"movement_kind":"normal","facing_before":initial.units[0].facing,"facing_after":mover.facing,
			"flags_before":{"has_moved":initial.units[0].has_moved},"flags_after":{"has_moved":mover.has_moved},"last_action_after":mover.last_action})
		expect(not moved_event.is_empty(),label + " observed moved event accepted")
		if label == "M4":
			battle.call("_handle_right_click_cancel")
			checkpoints.append(_snapshot(battle,units,"reverted"))
			for key in ["grid_cell","facing","has_moved"]:
				expect(checkpoints[-1].units[0][key] == initial.units[0][key],label + " restores " + key)
			expect(battle.get("ally_has_moved") == initial.controller.ally_has_moved,label + " restores ally_has_moved")
			expect(mover.last_action == finished.units[0].last_action and mover.last_action != initial.units[0].last_action,label + " last_action deliberately NOT restored")
			log_service.emit("move_reverted",{"unit_id":mover.unit_id,"restored_fields":["grid_cell","facing","has_moved","ally_has_moved"]})
		else:
			var facing_before := mover.facing
			battle.call("_select_post_move_facing","down")
			expect(mover.facing == "down",label + " manual facing")
			log_service.emit("facing_changed",{"unit_id":mover.unit_id,"from":facing_before,"to":mover.facing,"reason":"manual"})
			log_service.emit("move_confirmed",{"unit_id":mover.unit_id,"restored_fields":[]})
			checkpoints.append(_snapshot(battle,units,"confirmed"))
			if label == "M5":
				var before_retry: Dictionary = checkpoints[-1]
				battle.call("set_move_target_cell",Vector2i(5,2))
				battle.call("play_basic_move_demo")
				await tree.process_frame
				var retry := _snapshot(battle,units,"retry_rejected")
				checkpoints.append(retry)
				_expect_state_equal(before_retry,retry,label + " already moved rejection")
				expect(not battle.get("is_demo_animating"),label + " retry no animation")
		expect(battle.get("current_phase") == "ally_turn" and not battle.get("has_pending_move_snapshot"),label + " terminal input phase")
		expect(not mover.has_acted,label + " movement never acts")
		for i in range(1,units.size()):
			expect(fingerprint.diff([initial.units[i]],[checkpoints[-1].units[i]]).is_empty(),label + " other unit unchanged " + str(i))
	var result := {"case":label,"path":path_json,"checkpoints":checkpoints,"events":log_service.export()}
	# Drain the production camera guard's frame waits + 0.06s timer before freeing.
	for settle_frame in range(10):
		await tree.process_frame
	await tree.create_timer(0.1).timeout
	battle.free()
	await _finish_audio(tree)
	await tree.process_frame
	return result

func _snapshot(battle: Node, units: Array[BattleUnitState], stage: String) -> Dictionary:
	return {"stage":stage,"units":fingerprint.fingerprint_units(units),"controller":{
		"ally_has_moved":battle.get("ally_has_moved"),"has_pending_move_snapshot":battle.get("has_pending_move_snapshot"),"current_phase":battle.get("current_phase")}}

func _expect_state_equal(a: Dictionary, b: Dictionary, label: String) -> void:
	expect(fingerprint.diff(a.units,b.units).is_empty(),label + " units")
	expect(a.controller == b.controller,label + " controller")

func _finish_audio(tree: SceneTree) -> void:
	var game_audio := tree.root.get_node_or_null("GameAudio")
	if game_audio == null: return
	for child in game_audio.get_children():
		var voice := child as AudioStreamPlayer
		if voice != null:
			if voice.playing: await voice.finished
			voice.stop()
			voice.stream = null
