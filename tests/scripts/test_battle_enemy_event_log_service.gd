extends SceneTree
const EnemyLog = preload("res://scripts/battle/services/battle_enemy_event_log_service.gd")
var checks := 0
var failures: Array[String] = []

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("[ENEMY_EVENT_LOG] FAIL ", label)

func _initialize() -> void:
	var log = EnemyLog.new()
	expect(log is RefCounted, "service is RefCounted")
	expect(log.export().is_empty(), "starts empty")
	var actor := BattleUnitState.new()
	actor.unit_id = "enemy_a"
	actor.side = "enemy"
	actor.current_hp = 5
	actor.current_troops = 5
	var target := BattleUnitState.new()
	target.unit_id = "ally_a"
	target.side = "ally"
	target.current_hp = 0
	target.current_troops = 0
	var ally_caster := BattleUnitState.new()
	ally_caster.unit_id = "ally_b"
	ally_caster.side = "ally"
	# Valid records, independent sequence from 0.
	expect(log.emit("enemy_turn_started", {"round":1}).sequence == 0, "turn started")
	expect(log.record_unit("enemy_actor_selected", actor).kind == "enemy_actor_selected", "actor selected")
	for reason in ["wait", "confused", "no_path", "path_blocked", "no_target"]:
		expect(log.record_waited(actor, reason).reason == reason, "wait reason " + reason)
	var attack: Dictionary = log.record_attack(actor, target, 8, 5, "front")
	expect(attack.damage_applied == 5 and attack.raw_damage == 8 and attack.target_troops_after == 0 and attack.killed == true, "attack values read from units")
	expect(log.record_skill(actor, {"skill_id":"s1"}, null).target_id == "", "skill without target")
	expect(log.record_skill(ally_caster, {"skill_id":"s1"}, actor).is_empty(), "ally skill is not an enemy event")
	expect(log.emit("round_started", {"round":2}).round == 2, "round started")
	expect(log.emit("battle_ended", {"result_state":"defeat"}).result_state == "defeat", "battle ended")
	# Staged move: recorded once, only for the same unit and destination.
	var path: Array[Vector2i] = [Vector2i(3,1), Vector2i(2,1), Vector2i(2,2)]
	log.stage_move_path("enemy_a", path)
	var moved: Dictionary = log.emit_staged_move("enemy_a", Vector2i(2,2))
	expect(moved.path == [[3,1],[2,1],[2,2]] and moved.from == [3,1] and moved.to == [2,2], "moved path/from/to")
	expect(log.emit_staged_move("enemy_a", Vector2i(2,2)).is_empty(), "staged move consumed once")
	log.stage_move_path("enemy_a", path)
	expect(log.emit_staged_move("enemy_b", Vector2i(2,2)).is_empty(), "other unit cannot consume")
	expect(log.emit_staged_move("enemy_a", Vector2i(2,2)).is_empty(), "mismatch clears stage")
	log.stage_move_path("enemy_a", path)
	expect(log.emit_staged_move("enemy_a", Vector2i(9,9)).is_empty(), "destination must equal path end")
	log.stage_move_path("enemy_a", [Vector2i(1,1)] as Array[Vector2i])
	expect(log.emit_staged_move("enemy_a", Vector2i(1,1)).is_empty(), "single-cell path is not a move")
	var count: int = log.export().size()
	# Rejections leave the log untouched.
	var rejected := [
		["unknown_kind", {"unit_id":"x"}],
		["enemy_waited", {"unit_id":"x", "reason":"bored"}],
		["enemy_waited", {"unit_id":"", "reason":"wait"}],
		["enemy_waited", {"unit_id":"x", "reason":"wait", "extra":1}],
		["enemy_turn_started", {"round":"1"}],
		["battle_ended", {"result_state":""}],
		["enemy_attack_resolved", {"attacker_id":"a", "target_id":"b", "damage_applied":1, "raw_damage":1, "angle_type":"top", "target_troops_after":1, "killed":false}],
		["enemy_moved", {"unit_id":"x", "path":[[0,0],[0,1]], "from":[0,0], "to":[0,2]}],
		["enemy_actor_selected", {"unit_id":actor}],
		["enemy_skill_used", {"unit_id":"x", "skill_id":"s", "target_id":target}],
	]
	for item in rejected:
		expect(log.emit(item[0], item[1]).is_empty(), "rejects " + str(item[0]) + " " + str(item[1].keys()))
	expect(log.record_unit("enemy_actor_selected", null).is_empty() and log.record_attack(null, target, 1, 1, "front").is_empty(), "null units rejected")
	expect(log.export().size() == count, "rejections do not append")
	# Export is a deep copy.
	var exported: Array = log.export()
	exported[0]["round"] = 99
	exported[1].clear()
	exported.append({"kind":"forged"})
	var again: Array = log.export()
	expect(again.size() == count and again[0].round == 1 and again[1].unit_id == "enemy_a", "export deep copy")
	var returned: Dictionary = log.emit("enemy_action_completed", {"unit_id":"enemy_a"})
	returned["unit_id"] = "forged"
	expect(log.export()[-1].unit_id == "enemy_a", "returned event is a copy")
	var sequences := []
	for event in log.export(): sequences.append(event.sequence)
	expect(sequences == range(sequences.size()), "contiguous own sequence")
	expect(actor.current_hp == 5 and actor.current_troops == 5 and target.current_troops == 0, "recording does not write units")
	log.clear()
	expect(log.export().is_empty() and log.emit("round_started", {"round":1}).sequence == 0, "clear resets sequence")
	print("[ENEMY_EVENT_LOG] checks=", checks, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
