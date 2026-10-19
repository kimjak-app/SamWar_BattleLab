extends RefCounted
const Fingerprint = preload("res://scripts/battle/services/battle_state_fingerprint_service.gd")
var fingerprint := Fingerprint.new()
var failures: Array[String] = []
var checks := 0
var boundary_samples: Array = []

# Transparent test-only boundary observer. All normal production calls run once,
# immediately, via super; no Tween is replaced or completed by the harness.
class BoundaryBattle extends "res://scripts/battle/presentation/iso/battle_iso_production_controller.gd":
	var observe: Callable
	func _play_enemy_turn_demo() -> void:
		if observe.is_valid(): observe.call("finished_before_enemy")
		super._play_enemy_turn_demo()
		if observe.is_valid(): observe.call("finished_after_enemy_start")
	func _return_to_ally_turn() -> void:
		super._return_to_ally_turn()
		if observe.is_valid(): observe.call("after_enemy_callback")
	func _handle_battle_end_guard(source: String) -> bool:
		var result := super._handle_battle_end_guard(source)
		if result:
			printerr("[ATTACK_ORACLE] FORBIDDEN end guard: ",source)
			get_tree().quit(1)
		return result
	func _try_show_battle_result_toast_if_needed() -> bool:
		if _get_battle_result_state() != "":
			printerr("[ATTACK_ORACLE] FORBIDDEN result path")
			get_tree().quit(1)
			return true
		return super._try_show_battle_result_toast_if_needed()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("[ATTACK_ORACLE] FAIL ",label)

func snapshot(battle: Node, label: String) -> Dictionary:
	var active = battle.get("active_unit_state")
	var lock = battle.get("action_lock_state_service")
	return {"stage":label,"units":fingerprint.fingerprint_units(battle.get("all_battle_unit_states")),"controller":{
		"current_phase":battle.get("current_phase"),"is_demo_animating":battle.get("is_demo_animating"),
		"ally_has_moved":battle.get("ally_has_moved"),"has_pending_move_snapshot":battle.get("has_pending_move_snapshot"),
		"active_unit_id":active.unit_id if active != null else "", "battle_round":battle.get("battle_round"),
		"ally_momentum":battle.get("battle_momentum").get_value("ally"),"enemy_momentum":battle.get("battle_momentum").get_value("enemy"),
		"acted_ally_ids":lock.export_acted_ids("ally"),"acted_enemy_ids":lock.export_acted_ids("enemy"),
		"dead_unit_ids":battle.get("dead_unit_ids").duplicate(true)}}

func boundary(label: String, battle: Node) -> void:
	boundary_samples.append(snapshot(battle,label))

func run_case(tree: SceneTree, label: String) -> Dictionary:
	boundary_samples.clear()
	var packed = load("res://scenes/battle/Battle_Main.tscn")
	var battle = packed.instantiate()
	battle.set_script(BoundaryBattle)
	tree.root.add_child(battle)
	await tree.process_frame
	battle.call("_skip_battle_intro_camera_zoom")
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
	battle.observe = boundary.bind(battle)
	var samples: Array = [snapshot(battle,"start")]
	var angle: String = battle.call("_get_attack_angle_type",actor,target)
	battle.call("try_basic_attack")
	samples.append(snapshot(battle,"attack_select"))
	var input_evidence := {}
	if label=="A7b":
		var candidates: Array = battle.call("_get_alive_enemy_units")
		var candidate_ids: Array = []
		for candidate in candidates:
			candidate_ids.append(candidate.unit_id)
			expect(candidate.side=="enemy",label+" candidate is enemy")
		for unit in units:
			if unit.side=="ally": expect(not candidates.has(unit),label+" ally excluded "+unit.unit_id)
		expect(not candidates.is_empty(),label+" live deployed enemy candidates present")
		input_evidence={"method":"_get_alive_enemy_units", "candidate_ids":candidate_ids,"allies_excluded":true,"mouse_input_simulated":false}
		samples.append(snapshot(battle,"input_candidates_checked"))
		expect(fingerprint.diff(samples[0].units,samples[-1].units).is_empty(),label+" candidate query changes no unit fields")
		expect(not battle.get("is_demo_animating"),label+" no attack started")
	elif label=="A11":
		battle.call("_handle_right_click_cancel")
		samples.append(snapshot(battle,"cancelled"))
		expect(battle.get("current_phase")=="ally_turn" and not actor.has_acted,label+" cancel restores ally phase without consumption")
	else:
		battle.call("_try_attack_enemy_target_from_attack_select",target)
		samples.append(snapshot(battle,"requested"))
		if label in ["A5","A7_range","A7_acted"]:
			expect(fingerprint.diff(samples[0].units,samples[-1].units).is_empty(),label+" rejection all fields unchanged")
		else:
			expect(battle.get("is_demo_animating"),label+" actual tween started")
			expect(target.current_troops < 300,label+" requested damage applied")
			expect(not actor.has_acted,label+" requested before action consumed")
			await tree.process_frame
			samples.append(snapshot(battle,"animating"))
			if label=="A10":
				battle.call("_handle_right_click_cancel")
				battle.call("_try_attack_enemy_target_from_attack_select",target)
				samples.append(snapshot(battle,"duplicate_cancel_input"))
				expect(fingerprint.diff(samples[-2].units,samples[-1].units).is_empty(),label+" duplicate input does not change units")
			var reached := false
			for frame in range(1800):
				await tree.process_frame
				if not boundary_samples.is_empty() and battle.get("current_phase")=="ally_turn" and not battle.get("is_demo_animating"):
					reached=true
					break
			expect(reached,label+" actual enemy slot completed within 1800 frames")
			samples.append_array(boundary_samples.duplicate(true))
			samples.append(snapshot(battle,"after_enemy_slot"))
			expect(actor.has_acted and actor.has_moved,label+" finished action consumed")
			if label=="A6": expect(actor.last_action.get("moved_distance")==2,label+" move distance preserved")
			if label=="A9": expect(battle.get("dead_unit_ids").has(target.unit_id),label+" death cleanup")
	var result := {"case":label,"angle_type":angle,"checkpoints":samples}
	if label=="A7a": result["observation_note"]="엔진 함수는 대상 진영을 검사하지 않음(알려진 미보호 경계)"
	if label=="A7b": result["input_evidence"]=input_evidence
	# Same settling/audio policy as the existing movement harness.
	for i in range(10): await tree.process_frame
	await tree.create_timer(.1).timeout
	battle.observe=Callable()
	var projection = battle.get("_iso_grid_controller")
	battle.free()
	# Test teardown only: the production ISO adapter is a parentless Node.
	if is_instance_valid(projection) and projection.get_parent()==null: projection.free()
	var audio=tree.root.get_node_or_null("GameAudio")
	if audio:
		for voice in audio.get_children():
			if voice is AudioStreamPlayer:
				if voice.playing: await voice.finished
				voice.stop()
				voice.stream=null
	return result
