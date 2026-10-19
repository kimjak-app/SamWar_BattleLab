extends SceneTree
const Log = preload("res://scripts/battle/services/battle_event_log_service.gd")
var checks := 0
var failures := 0

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func _initialize() -> void:
	var log_service := Log.new()
	var fields := {"unit_id":"u", "from":[1,1], "to":[2,1], "path":[[1,1],[2,1]], "movement_kind":"normal", "facing_before":"left", "facing_after":"right", "flags_before":{"has_moved":false}, "flags_after":{"has_moved":true}, "last_action_after":{"type":"move"}}
	var first: Dictionary = log_service.emit("unit_moved", fields)
	expect(first.get("sequence", -1) == 0 and first.get("schema_version", -1) == 0, "first sequence/schema")
	fields.path[0][0] = 99
	first.last_action_after.type = "mutated"
	var saved: Array = log_service.export()
	expect(saved[0].path[0][0] == 1 and saved[0].last_action_after.type == "move", "input and return deep copy")
	saved[0].flags_before.has_moved = true
	expect(not log_service.export()[0].flags_before.has_moved, "export deep copy")
	for kind in ["facing_changed", "move_confirmed", "move_reverted"]:
		var payload: Dictionary = {"unit_id":"u", "restored_fields":[]}
		if kind == "facing_changed":
			payload = {"unit_id":"u", "from":"left", "to":"right", "reason":"step"}
		elif kind == "move_reverted":
			payload.restored_fields = ["grid_cell","facing","has_moved","ally_has_moved"]
		expect(not log_service.emit(kind, payload).is_empty(), "accept " + kind)
	for i in range(4):
		expect(log_service.export()[i].sequence == i, "ordered sequence " + str(i))
	expect(log_service.emit("unit_attacked", {}).is_empty(), "unknown kind rejected")
	expect(log_service.emit("facing_changed", {"unit_id":"u"}).is_empty(), "missing fields rejected")
	var invalid := {"unit_id":"u", "from":"left", "to":"right", "reason":"manual", "sequence":99}
	expect(log_service.emit("facing_changed", invalid).is_empty(), "reserved fields rejected")
	var invalid_move := log_service.export()[0].duplicate(true)
	for key in ["kind","sequence","schema_version"]: invalid_move.erase(key)
	invalid_move.from = Vector2i(1,1)
	expect(log_service.emit("unit_moved", invalid_move).is_empty(), "vector rejected")
	invalid_move.from = [1,1]
	invalid_move.last_action_after = {"reference":RefCounted.new()}
	expect(log_service.emit("unit_moved", invalid_move).is_empty(), "object rejected")
	expect(log_service.emit("move_reverted", {"unit_id":"u", "restored_fields":["last_action"]}).is_empty(), "last_action not restored")
	var next: Dictionary = log_service.emit("move_confirmed", {"unit_id":"u","restored_fields":[]})
	expect(next.sequence == 4, "rejection consumes no sequence")
	expect(JSON.parse_string(JSON.stringify(log_service.export())) is Array, "JSON serializable")
	log_service.clear()
	expect(log_service.export().is_empty(), "clear history")
	expect(log_service.emit("move_confirmed", {"unit_id":"u","restored_fields":[]}).sequence == 0, "clear resets sequence")
	print("[BATTLE_EVENT_LOG] %s: %d checks, %d failures" % ["PASS" if failures == 0 else "FAIL",checks,failures])
	quit(0 if failures == 0 else 1)
