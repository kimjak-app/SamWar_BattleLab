extends SceneTree
const Adapter = preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
const Fingerprint = preload("res://scripts/battle/services/battle_state_fingerprint_service.gd")
var checks := 0
var failures: Array = []
var lab

func _initialize() -> void:
	_run.call_deferred()

func expect(ok: bool,label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("M1B FAIL ",label)

func settle() -> void:
	await create_timer(.2).timeout

func click(cell: Vector2i) -> void:
	var pos: Vector2 = lab.camera.unproject_position(lab.board.world(cell))
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = pos
	lab._unhandled_input(event)

func fingerprint() -> Array:
	return Fingerprint.new().fingerprint_units(lab.queries.alive_units)

func rejected_click(cell: Vector2i,label: String) -> void:
	var before := fingerprint()
	var starts: int = lab.animation_starts
	var rejects: int = lab.rejected
	click(cell)
	expect(fingerprint() == before,label + " all 40 fields unchanged")
	expect(lab.animation_starts == starts,label + " no new presentation")
	expect(lab.rejected == rejects+1,label + " visible rejection")

func synced(label: String,positions := true) -> void:
	lab._sync_views()
	expect(lab.display_values.size()==10,label + " ten views")
	for unit in lab.queries.alive_units:
		expect(lab.display_values[unit.unit_id]==Adapter.to_view(unit),label+" adapter "+unit.unit_id)
		if positions: expect(lab.views[unit.unit_id].position.distance_to(lab.board.world(unit.grid_cell))<.001,label+" position "+unit.unit_id)

func wait_facing() -> void:
	for i in range(600):
		await create_timer(.01).timeout
		if lab.engine.get("current_phase")=="facing_select": return
	expect(false,"facing timeout")

func _run() -> void:
	root.size = Vector2i(1280,720)
	lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	root.add_child(lab)
	await settle()
	expect(lab.ready_for_input,"ready")
	expect(lab.host.get_parent()==lab and lab.engine.get_viewport()==lab.host,"subviewport isolated")
	expect(root.get_camera_3d()==lab.camera,"active camera")
	synced("start")
	click(Vector2i(3,8))
	var mover = lab.queries.find_unit("yi_sunsin")
	expect(lab.engine.get("active_unit_state")==mover,"ray selection")
	var initial_facing: String = mover.facing
	# Send raw root events while presentation's explicit handler is disabled.
	lab.set_process_unhandled_input(false)
	var before := fingerprint()
	for button in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
		var event := InputEventMouseButton.new()
		event.button_index=button
		event.pressed=true
		event.position=Vector2(400,400)
		root.push_input(event)
	expect(fingerprint()==before,"raw root clicks cannot reach engine")
	expect(lab.engine.get("active_unit_state")==mover,"raw right click cannot cancel selection")
	lab.set_process_unhandled_input(true)
	rejected_click(Vector2i(14,2),"enemy")
	rejected_click(Vector2i(17,9),"range")
	click(Vector2i(3,7))
	expect(lab.engine.get("is_demo_animating"),"real engine tween")
	expect(mover.grid_cell==Vector2i(3,8),"no direct state write before completion")
	rejected_click(Vector2i(3,6),"during engine animation")
	await wait_facing()
	lab._consume_events()
	expect(mover.grid_cell==Vector2i(3,7) and mover.has_moved and not mover.has_acted,"move flags")
	expect(mover.last_action.get("moved_distance")==1,"grid distance")
	var events: Array = lab.engine.get("ally_move_event_log").export()
	var executed: Array = []
	for event in events:
		if event.kind=="unit_moved": executed=event.path
	expect(not executed.is_empty() and lab.played_paths[-1]==executed,"presentation uses executed path")
	var expected_path: Array = []
	for cell in executed: expected_path.append(Vector2i(cell[0],cell[1]))
	expect(lab.playback.has(mover.unit_id) and lab.playback[mover.unit_id].path==expected_path,"animation consumes exact executed cells")
	# Pending movement makes leaked root right-click cancellation observable.
	lab.set_process_unhandled_input(false)
	var pending_before := fingerprint()
	var raw_cancel := InputEventMouseButton.new()
	raw_cancel.button_index=MOUSE_BUTTON_RIGHT
	raw_cancel.pressed=true
	raw_cancel.position=Vector2(900,600)
	root.push_input(raw_cancel)
	expect(fingerprint()==pending_before and lab.engine.get("current_phase")=="facing_select","raw right click cannot revert pending move")
	lab.set_process_unhandled_input(true)
	synced("moving",false)
	rejected_click(Vector2i(3,6),"facing duplicate")
	var last: Dictionary = mover.last_action.duplicate(true)
	var cancel := InputEventMouseButton.new()
	cancel.button_index=MOUSE_BUTTON_RIGHT
	cancel.pressed=true
	lab._unhandled_input(cancel)
	expect(mover.grid_cell==Vector2i(3,8) and mover.facing==initial_facing and not mover.has_moved,"cancel state")
	expect(not lab.engine.get("ally_has_moved"),"cancel controller")
	expect(mover.last_action==last,"last action intentionally retained")
	synced("cancel")
	click(Vector2i(3,8))
	lab.presentation_speed = .1
	click(Vector2i(3,7))
	await wait_facing()
	lab._consume_events()
	lab.confirm_facing("down")
	expect(lab.engine.get("current_phase")=="ally_turn" and not mover.has_acted,"confirm returns ally turn")
	expect(not lab.playback.is_empty(),"engine phase advances before presentation")
	rejected_click(Vector2i(3,6),"already moved")
	lab.presentation_speed = 30.0
	await create_timer(1.2).timeout
	synced("confirm")
	var old_engine: WeakRef = weakref(lab.engine)
	lab.free()
	await settle()
	expect(old_engine.get_ref()==null,"engine freed")
	for voice in root.get_node("GameAudio").get_children():
		if voice is AudioStreamPlayer: expect(not voice.playing and voice.stream==null,"audio cleared")
	lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	root.add_child(lab)
	await create_timer(.5).timeout
	expect(lab.queries.find_unit("yi_sunsin").grid_cell==Vector2i(3,8),"restart fresh state")
	expect(lab.event_cursor==0 and lab.playback.is_empty(),"restart no stale callbacks")
	synced("restart")
	# Test-only layout: force an occupied direct route, without changing runtime rules.
	var blocker = lab.queries.find_unit("jeong_dojeon")
	lab.queries.find_unit("yi_sunsin").move_range = 6
	blocker.set_grid_cell(Vector2i(4,8))
	lab.engine.call("_sync_resumed_unit_markers_to_grid",blocker)
	lab._sync_views()
	click(Vector2i(3,8))
	click(Vector2i(5,8))
	await wait_facing()
	lab._consume_events()
	if lab.played_paths.is_empty():
		lab.free()
		quit(1)
		return
	var detour: Array = lab.played_paths[-1]
	expect(detour.size()-1 > 2,"executed path detours around occupancy")
	var executed_detour: Array = []
	for event in lab.engine.get("ally_move_event_log").export():
		if event.kind == "unit_moved" and event.unit_id == "yi_sunsin":
			executed_detour.clear()
			for cell in event.path: executed_detour.append(Vector2i(cell[0],cell[1]))
	expect(executed_detour.size() > 2 and lab.playback.has("yi_sunsin") and lab.playback["yi_sunsin"].path == executed_detour,"detour playback equals engine executed path")
	expect(lab.queries.find_unit("yi_sunsin").last_action.moved_distance==2,"detour retains grid distance")
	# Free during active presentation: callbacks must not escape the old instance.
	lab.free()
	lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	root.add_child(lab)
	await create_timer(.5).timeout
	expect(lab.playback.is_empty() and lab.event_cursor==0,"restart during animation has no stale event")
	expect(lab.queries.find_unit("yi_sunsin").grid_cell==Vector2i(3,8),"restart during animation fresh cell")
	lab.free()
	print("M1B integration checks=",checks," failures=",failures)
	quit(0 if failures.is_empty() else 1)
