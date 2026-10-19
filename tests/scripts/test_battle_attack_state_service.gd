extends SceneTree
const Service = preload("res://scripts/battle/services/battle_attack_state_service.gd")
const Log = preload("res://scripts/battle/services/battle_event_log_service.gd")
const Fingerprint = preload("res://scripts/battle/services/battle_state_fingerprint_service.gd")
var checks := 0
var failures: Array[String] = []
func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("[ATTACK_STATE] FAIL ",label)
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var service := Service.new()
	var fingerprint := Fingerprint.new()
	var actor := BattleUnitState.new()
	actor.unit_id="test_actor"
	actor.side="ally"
	actor.grid_cell=Vector2i(3,4)
	var target := BattleUnitState.new()
	target.unit_id="test_target"
	target.is_defending=true
	# Applied damage is HP-capped; troops delta is intentionally not its definition.
	for row in [[30,80,50,30,0,30,true],[80,30,50,50,30,0,true],[80,80,0,0,80,80,false],[80,80,-10,0,80,80,false]]:
		target.current_hp=row[0]
		target.current_troops=row[1]
		var before := fingerprint.fingerprint_units([actor])
		var result: Dictionary = service.apply_attack_damage(actor,target,row[2],"front")
		expect(result.damage_applied==row[3] and target.current_hp==row[4] and target.current_troops==row[5],"damage clamping "+str(row))
		expect(result.fields=={"attacker_id":"test_actor","target_id":"test_target","angle_type":"front","damage_requested":row[2],"damage_applied":row[3],"troops_before":row[1],"troops_after":row[5],"target_defending":true,"killed":row[6]},"event values "+str(row))
		expect(fingerprint.diff(before,fingerprint.fingerprint_units([actor])).is_empty(),"damage cannot consume actor action")
		var log_service := Log.new()
		var emitted := log_service.emit("attack_resolved",result.fields)
		expect(emitted.get("sequence",-1)==0,"valid attack accepted")
		result.fields.target_id="mutated"
		emitted.target_id="returned mutation"
		var exported := log_service.export()
		exported[0].target_id="export mutation"
		expect(log_service.export()[0].target_id=="test_target","attack event copies isolated")
	for type in ["infantry","cavalry","archer","gunner","mounted_archer"]:
		actor.reset_action_flags()
		actor.unit_type=type
		actor.has_moved=true
		actor.last_action={"type":"move","moved_distance":2}
		service.commit_attack_metadata(actor)
		expect(actor.attacked_this_turn and actor.last_action=={"type":"attack","origin_cell":[3,4],"destination_cell":[3,4],"moved_distance":2},type+" metadata keeps distance")
		expect(not actor.has_acted and actor.has_moved,type+" metadata cannot consume action or rewrite move flag")
		service.commit_post_attack_movement(actor)
		var mobile: bool = type=="mounted_archer"
		expect(actor.post_attack_move_available==mobile,type+" post attack permission")
		expect(actor.remaining_post_attack_move==(2 if mobile else 0),type+" post attack distance")
	actor.status_effects={"burn":{"turns":2,"magnitude":8}}
	service.apply_post_fire_penalty(actor)
	expect(actor.get_status_turns("post_fire_penalty")==1 and actor.get_status_magnitude("post_fire_penalty")==40,"gunner penalty")
	expect(actor.get_status_turns("burn")==2,"no early status tick")
	var log_service := Log.new()
	var valid := {"attacker_id":"a","target_id":"t","angle_type":"front","damage_requested":20,"damage_applied":20,"troops_before":100,"troops_after":80,"target_defending":false,"killed":false}
	for edit in [{"attacker_id":""},{"target_id":7},{"angle_type":"bad"},{"damage_requested":1.5},{"damage_applied":true},{"troops_before":"100"},{"troops_after":Vector2i.ZERO},{"killed":0},{"target_defending":0},{"sequence":99},{"unexpected":1}]:
		var bad := valid.duplicate(true)
		bad.merge(edit,true)
		expect(log_service.emit("attack_resolved",bad).is_empty(),"invalid fields "+str(edit.keys()))
	for key in valid:
		var bad := valid.duplicate(true)
		bad.erase(key)
		expect(log_service.emit("attack_resolved",bad).is_empty(),"missing "+key)
	for kind in ["action_completed","unit_defeated"]:
		expect(log_service.emit(kind,{"unit_id":""}).is_empty(),kind+" empty ID")
		expect(log_service.emit(kind,{"unit_id":"a","unexpected":true}).is_empty(),kind+" strict fields")
		expect(not log_service.emit(kind,{"unit_id":"a"}).is_empty(),kind+" accepted")
	expect(log_service.emit("attack_resolved",valid).sequence==2,"invalid attempts consume no sequence")
	log_service.clear()
	expect(log_service.export().is_empty() and log_service.emit("attack_resolved",valid).sequence==0,"reset history and sequence")
	print("[ATTACK_STATE] checks=",checks," failures=",failures)
	quit(0 if failures.is_empty() else 1)
