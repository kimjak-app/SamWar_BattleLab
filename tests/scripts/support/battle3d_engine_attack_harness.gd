extends "res://tests/scripts/support/battle_attack_oracle_harness.gd"
const Oracle = preload("res://tests/scripts/support/battle_attack_oracle_harness.gd")
const Adapter = preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
const Host = preload("res://scripts/battle3d/battle3d_engine_host.gd")
var lab
var samples: Array = []
var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden/battle_attack_baseline_v0.json"))

class SpyBattle extends Oracle.BoundaryBattle:
	var target_calls := 0
	var attack_calls := 0
	func try_basic_attack() -> void:
		attack_calls+=1
		super.try_basic_attack()
	func _try_attack_enemy_target_from_attack_select(target: BattleUnitState) -> void:
		target_calls+=1
		super._try_attack_enemy_target_from_attack_select(target)

class SpyHost extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(SpyBattle)
		return node

func open_lab(tree: SceneTree) -> void:
	tree.root.size=Vector2i(1280,800)
	lab=preload("res://tests/scripts/support/battle3d_test_world.gd").lab(load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()) # T2 split: the test world (C1 groves)
	lab.host.free()
	lab.host=SpyHost.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame

func close_lab(tree: SceneTree) -> void:
	lab.engine.observe=Callable()
	var iso=lab.engine.get("_iso_grid_controller")
	lab.free()
	if is_instance_valid(iso) and iso.get_parent()==null: iso.free()
	await tree.process_frame

func click(cell: Vector2i, button := MOUSE_BUTTON_LEFT) -> void:
	var event := InputEventMouseButton.new()
	event.button_index=button
	event.pressed=true
	event.position=lab.camera.unproject_position(lab.board.world(cell))
	lab._unhandled_input(event)

func press_attack() -> void:
	lab.attack_button.pressed.emit()

func point(case: String, stage: String) -> Dictionary:
	for scenario in golden.scenarios:
		if scenario.case==case:
			for checkpoint in scenario.checkpoints:
				if checkpoint.stage==stage: return checkpoint
	return {}

func check_point(case: String, stage: String) -> void:
	var captured := snapshot(lab.engine,stage)
	samples.append(captured)
	var differences := fingerprint.diff(point(case,stage),captured)
	expect(differences.is_empty(),case+" golden "+stage+" "+str(differences))
	print("[M2_CHECKPOINT] ",case," ",stage," ",JSON.stringify(captured))

func sync_check(label: String, positions := true) -> void:
	lab._consume_action_events()
	lab._sync_views()
	var visible: Array = []
	var expected_visible: Array = []
	var occupied := {}
	for unit in lab.engine.all_battle_unit_states:
		var value: Dictionary = Adapter.to_view(unit)
		var view: Node3D = lab.views[unit.unit_id]
		var available: bool = lab.engine._is_unit_state_available_for_battle_slot(unit)
		if available: expected_visible.append(unit.unit_id)
		if view.visible: visible.append(unit.unit_id)
		expect(lab.display_values[unit.unit_id]==value,label+" adapter "+unit.unit_id)
		if positions and lab.playback.has(unit.unit_id):
			# M3: an enemy path playback may still run after the engine callback; it must end on the engine cell.
			expect(lab.playback[unit.unit_id].path[-1]==unit.grid_cell,label+" playback ends on engine cell "+unit.unit_id)
		elif positions: expect(view.position.distance_to(lab.board.world(unit.grid_cell))<.001,label+" cell "+unit.unit_id)
		var count := 0
		for soldier in lab.soldiers[unit.unit_id]:
			if soldier.visible: count+=1
		var expected_count := clampi(ceili(6.0*float(value.current_troops)/maxf(1.0,float(value.max_troops))),0,6)
		expect(count==expected_count,label+" visual density "+unit.unit_id)
		for child in view.get_children():
			if child is Label3D: expect(child.text=="%s | %s\n%s" % [value.unit_id,value.unit_type,value.current_troops],label+" troops label "+unit.unit_id)
		if available:
			expect(not occupied.has(unit.grid_cell),label+" no visible overlap "+unit.unit_id)
			occupied[unit.grid_cell]=true
	expect(visible==expected_visible,label+" deployed/live visible set")
	var active=lab.engine.active_unit_state
	expect(lab.selected==(active.unit_id if active!=null else ""),label+" selected engine actor")
	if active!=null and lab.views[active.unit_id].visible:
		expect(lab.ring.visible and lab.ring.position.distance_to(lab.views[active.unit_id].position+Vector3(0,.09,0))<.001,label+" ring follows actor")
	expect(lab.get_tree().root.get_camera_3d()==lab.camera,label+" 3D camera remains current")

func range_check(label: String) -> void:
	var actor=lab.engine.active_unit_state
	var cells: Array[Vector2i]=lab.engine.battle_grid_controller.get_tiles_in_range(actor.grid_cell,actor.attack_range)
	expect(lab.attack_cells==cells,label+" exact engine range cells")
	var expected_markers := cells.duplicate()
	expected_markers.erase(actor.grid_cell)
	var actual_markers: Array = []
	for child in lab.range_view.get_children(): actual_markers.append(lab.board.cell_at(child.position))
	expect(actual_markers==expected_markers,label+" rendered range exact cells")
	var candidates: Array=lab.engine._get_alive_enemy_units()
	expect(lab.enemy_candidates==candidates,label+" exact candidate set")
	var ids: Array[String]=[]
	for candidate in candidates:
		if lab.engine.is_unit_in_attack_range(actor,candidate): ids.append(candidate.unit_id)
	expect(lab.valid_target_ids==ids,label+" exact target highlights")
	expect(lab.target_marks.get_child_count()==ids.size(),label+" target marker count")

func boundary(label: String, battle: Node) -> void:
	super.boundary(label,battle)
	sync_check(label)

func wait_for(tree: SceneTree, phase: String) -> void:
	for i in range(5000):
		await tree.process_frame
		if lab.engine.current_phase==phase and not lab.engine.is_demo_animating: return
	expect(false,"timeout phase "+phase)

func run_case(tree: SceneTree, label: String) -> Dictionary:
	boundary_samples.clear()
	samples.clear()
	await open_lab(tree)
	await setup_case(tree,label)
	lab.engine.observe=boundary.bind(lab.engine)
	sync_check(label+" start")
	click(lab.engine.all_battle_unit_states[0].grid_cell)
	check_point(label,"start")
	if label=="A6b":
		click(Vector2i(3,4))
		check_point(label,"move_requested")
		await wait_for(tree,"facing_select")
		check_point(label,"move_finished")
		lab.confirm_facing("right")
		check_point(label,"facing_confirmed")
		lab.engine.trace_pending_clear=true
	press_attack()
	check_point(label,"attack_select")
	range_check(label)
	sync_check(label+" select",label!="A6b")
	var target=lab.engine.all_battle_unit_states[5]
	var motion := InputEventMouseMotion.new()
	motion.position=lab.camera.unproject_position(lab.board.world(target.grid_cell))
	lab._unhandled_input(motion)
	expect(lab.target_id==target.unit_id,label+" target hover ID")
	expect(lab.target_defending==target.is_defending,label+" target defense display")
	if label=="A8": expect(lab.target_info.text.contains("방어 중"),"A8 defended target panel")
	click(target.grid_cell)
	check_point(label,"requested")
	sync_check(label+" requested")
	expect(lab.engine.target_calls==1,label+" exactly one engine target call")
	expect(lab.engine.is_demo_animating,label+" real Tween active")
	expect(lab.damage_presentations.size()==1,label+" damage display once at request")
	var event: Dictionary=lab.engine.battle_action_event_log.export()[0]
	expect(lab.damage_presentations[0]==event,label+" damage display from exact event")
	await tree.process_frame
	check_point(label,"animating")
	if label=="A10":
		click(target.grid_cell,MOUSE_BUTTON_RIGHT)
		click(target.grid_cell)
		press_attack()
		check_point(label,"duplicate_cancel_input")
		expect(lab.engine.target_calls==1 and lab.engine.attack_calls==1,"A10 repeated input blocked before engine")
	await wait_for(tree,"ally_turn")
	for sample in boundary_samples:
		var differences := fingerprint.diff(point(label,sample.stage),sample)
		expect(differences.is_empty(),label+" golden "+sample.stage+" "+str(differences))
		print("[M2_CHECKPOINT] ",label," ",sample.stage," ",JSON.stringify(sample))
	check_point(label,"after_enemy_slot")
	sync_check(label+" after enemy")
	expect(lab.enemy_summaries.size()==1,label+" enemy state summary exactly once")
	for i in range(3): lab._consume_action_events()
	expect(lab.damage_presentations.size()==1,label+" repeated polling cannot duplicate damage")
	expect(lab.action_cursor==lab.engine.battle_action_event_log.export().size(),label+" action cursor independent")
	expect(lab.event_cursor==lab.engine.ally_move_event_log.export().size(),label+" move cursor independent")
	if label=="A6b": expect(lab.event_cursor>lab.action_cursor,"A6b different log cursors are not merged")
	if label=="A9": expect(not lab.views[target.unit_id].visible,"A9 dead target hidden")
	await close_lab(tree)
	print("[M2_ATTACK_CASE] ",label," failures=",failures.size())
	return {}

func setup_case(tree: SceneTree, label: String) -> void:
	var battle=lab.engine
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	expect(units.size()==10,label+" ten production units")
	for i in range(units.size()):
		var u = units[i]
		u.set_grid_cell(Vector2i(10+i%5,6+i/5))
		u.reset_action_flags()
		u.unit_type="infantry"
		u.current_hp=300
		u.max_hp=300
		u.current_troops=300
		u.max_troops=300
		u.allocated_troops=300
		u.initial_allocated_troops=300
		u.unique_skill_definition={}
		u.status_effects={}
		u.facing="left"
	var actor = units[0]
	var target = units[5]
	actor.set_grid_cell(Vector2i(3,4))
	target.set_grid_cell(Vector2i(4,4))
	if label=="A6b": actor.set_grid_cell(Vector2i(1,4))
	if label=="A2_side": target.facing="up"
	if label=="A2_back": target.facing="right"
	if label=="A3":
		actor.unit_type="archer"
		target.set_grid_cell(Vector2i(6,4))
	if label in ["A4","A5"]:
		actor.unit_type="gunner"
		target.set_grid_cell(Vector2i(5,4))
	if label in ["A5","A6"]:
		actor.has_moved=true
		actor.last_action={"type":"move","origin_cell":[1,4],"destination_cell":[3,4],"moved_distance":2}
	if label=="A7_range": target.set_grid_cell(Vector2i(17,0))
	if label=="A7_acted": actor.has_acted=true
	if label in ["A7a","A7b"]:
		target=units[1]
		target.set_grid_cell(Vector2i(4,4))
	if label=="A8": target.is_defending=true
	if label=="A9":
		target.current_hp=1
		target.current_troops=1
		battle.get("action_lock_state_service").register_unit_acted(target,"enemy")
	for u in units: battle.call("_sync_resumed_unit_markers_to_grid",u)
	battle.call("_sync_demo_positions")
	battle.call("_select_ally_unit",actor,false,false,false)
	await tree.process_frame
