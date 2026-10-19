extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("_run")
func expect(ok: bool,label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		printerr("FAIL ",label)
func _run() -> void:
	var lab=load("res://scenes/battle3d/Battle3D_EngineConnectLab.tscn").instantiate()
	root.add_child(lab)
	await physics_frame
	await physics_frame
	expect(lab.query_mode and not lab.terrain_rules_enabled,"default query mode")
	var id := "lab_ally_01"
	var original: Dictionary=lab.UnitAdapter.to_view(lab.queries.find_unit(id))
	lab.select_engine_unit(id)
	lab.preview_cell(Vector2i(3,3))
	expect(lab.moving_id=="" and not lab.port.busy,"query cannot move")
	expect(lab.range_view.get_child_count()>0 and lab.route_view.get_child_count()>0,"query highlights")
	expect(lab.UnitAdapter.to_view(lab.queries.find_unit(id))==original,"query state unchanged")
	lab.set_query_mode(false)
	expect(lab.range_view.get_child_count()==0,"demo hides engine highlights")
	lab.selected=id
	expect(lab.port.request_move(id,Vector2i(3,3)),"demo accepted")
	await create_timer(.15).timeout
	expect(lab.moving_id==id,"demo in progress")
	lab.set_query_mode(true)
	expect(lab.moving_id=="" and lab.active_path.is_empty() and not lab.port.busy,"cancel motion")
	expect(lab.selected=="" and not lab.ring.visible,"clear selection")
	expect(lab.range_view.get_child_count()==0 and lab.route_view.get_child_count()==0,"clear overlays")
	for unit in lab.queries.alive_units:
		expect(lab.views[unit.unit_id].position.distance_to(lab.projection.grid_to_world_3d(unit.grid_cell))<.001,"restore view")
		expect(lab.port.by_id(unit.unit_id).grid_cell==unit.grid_cell,"restore demo fixture")
	await create_timer(.2).timeout
	expect(lab.UnitAdapter.to_view(lab.queries.find_unit(id))==original,"engine remains unchanged after transition")
	var before: Dictionary=lab.queries.query(id,Vector2i(4,3))
	lab.terrain_rules_enabled=true
	lab._show_terrain_annotations()
	expect(lab.queries.query(id,Vector2i(4,3))==before,"terrain annotation cannot alter engine query")
	lab.queue_free()
	await process_frame
	print("[BATTLE3D_MODES] %s: %d checks, %d failures" % ["PASS" if failures==0 else "FAIL",checks,failures])
	quit(0 if failures==0 else 1)
