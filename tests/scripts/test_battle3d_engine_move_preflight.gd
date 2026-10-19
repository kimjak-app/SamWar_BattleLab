extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var viewport = load("res://scripts/battle3d/battle3d_engine_host.gd").new()
	root.add_child(viewport)
	var battle = viewport.battle
	await viewport.initialized
	await create_timer(0.3).timeout
	var units: Array = battle.get("all_battle_unit_states")
	print("M1B PREFLIGHT roster=", units.size(), " phase=", battle.get("current_phase"))
	for unit in units:
		print("ROSTER ",unit.unit_id," ",unit.side," ",unit.unit_type," ",unit.grid_cell)
	var mover = units[0]
	battle.call("_select_ally_unit", mover, false, false, false)
	await process_frame
	print("M1B PREFLIGHT ui_hover=",battle.call("_is_mouse_over_battle_ui")," overlay=",battle.call("_is_move_range_overlay_visible"))
	var target: Vector2i = mover.grid_cell + Vector2i(0,-1)
	var accepted: bool = battle.call("_try_direct_move_to_cell",target)
	print("M1B PREFLIGHT accepted=",accepted)
	for i in range(600):
		await create_timer(0.01).timeout
		if battle.get("current_phase") == "facing_select": break
	print("M1B PREFLIGHT final phase=",battle.get("current_phase")," cell=",mover.grid_cell," events=",battle.get("ally_move_event_log").export())
	var passed: bool = accepted and mover.grid_cell == target and battle.get("current_phase") == "facing_select"
	viewport.free()
	await create_timer(0.5).timeout
	var audio = root.get_node_or_null("GameAudio")
	var audio_remaining := false
	if audio:
		for child in audio.get_children():
			if child is AudioStreamPlayer:
				print("M1B AUDIO AFTER FREE ",child.name," playing=",child.playing," stream=",child.stream)
				audio_remaining = audio_remaining or child.playing
	print("M1B MOVE PREFLIGHT ","PASS" if passed else "FAIL")
	print("M1B EXIT AUDIO ","FAIL: global voice still playing after scene free" if audio_remaining else "PASS")
	quit(0 if passed and not audio_remaining else 1)
