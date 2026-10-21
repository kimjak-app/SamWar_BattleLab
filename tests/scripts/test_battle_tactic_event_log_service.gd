extends SceneTree
# S4-1 tactic event log service: schema validation, deep-copy export,
# independent sequence, staged status tick consumed once, no unit writes.
const Service = preload("res://scripts/battle/services/battle_tactic_event_log_service.gd")
var checks := 0
var failures: Array[String] = []

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("[TACTIC_LOG_SERVICE] FAIL ", label)

func unit(id: String, side := "ally") -> BattleUnitState:
	var u := BattleUnitState.new()
	u.unit_id = id
	u.side = side
	u.max_hp = 100
	u.current_hp = 100
	u.max_troops = 100
	u.current_troops = 100
	return u

func _initialize() -> void:
	var log := Service.new()
	var caster := unit("a1")
	var target := unit("e1", "enemy")
	target.apply_status_effect("shake", 3, 0)
	var before := target.status_effects.duplicate(true)
	var cast := log.record_strategy_cast(caster, target, 0.65, true, "shake", 1)
	expect(cast.kind == "strategy_cast" and cast.sequence == 0 and cast.schema_version == 0, "strategy_cast envelope")
	expect(cast.turns == 1 and cast.turns_after == 3, "turns is the rolled value, turns_after the target's remaining turns")
	expect(target.status_effects == before, "recording writes no unit state")
	var fail := log.record_strategy_cast(caster, target, 0.65, false, "shake", 2)
	expect(fail.status_id == "" and fail.turns == 0 and fail.turns_after == 0 and fail.sequence == 1, "failure clears status fields")
	expect(log.emit("strategy_cast", {"caster_id":"a1"}).is_empty(), "missing fields rejected")
	expect(log.emit("unknown_kind", {}).is_empty(), "unknown kind rejected")
	expect(log.emit("strategy_cast", {"caster_id":"a1", "target_id":"e1", "success_rate":0.5, "success":true, "status_id":"", "turns":1, "turns_after":1}).is_empty(), "success without status rejected")
	expect(log.emit("status_tick", {"unit_id":"a1", "burn_damage":-1, "expired":[], "remaining":{}}).is_empty(), "negative burn rejected")
	expect(log.export().size() == 2, "rejected events not stored")
	var exported := log.export()
	exported[0].caster_id = "changed"
	expect(log.export()[0].caster_id == "a1", "export is a deep copy")
	# Staged tick: values before, difference after, consumed once.
	var burning := unit("a2")
	burning.apply_status_effect("burn", 2, 12)
	burning.apply_status_effect("shake", 1, 0)
	log.stage_status_tick(burning)
	burning.apply_damage(6)
	burning.tick_status_effects()
	var tick := log.emit_staged_status_tick(burning)
	expect(tick.kind == "status_tick" and tick.burn_damage == 6 and tick.expired == ["shake"] and tick.remaining == {"burn":1}, "status_tick fields " + str(tick))
	expect(log.emit_staged_status_tick(burning).is_empty(), "staged tick consumed once")
	log.stage_status_tick(burning)
	expect(log.emit_staged_status_tick(unit("other")).is_empty(), "staged tick for another unit records nothing")
	# Recording draws no random number: the global RNG sequence is unchanged.
	seed(77)
	var expected_draw := randf()
	seed(77)
	var rng_log := Service.new()
	rng_log.record_strategy_cast(caster, target, 0.5, true, "shake", 1)
	rng_log.record_strategy_cast(caster, target, 0.5, false, "", 0)
	rng_log.stage_status_tick(burning)
	rng_log.emit_staged_status_tick(burning)
	for method in ["record_skill_cast", "record_skill_heal", "record_skill_status", "record_skill_momentum", "record_skill_finished", "record_reinforcement", "stage_skill_command", "record_skill_damage", "record_staged_cleanse", "record_staged_move"]:
		if rng_log.has_method(method):
			match method:
				"record_skill_cast": rng_log.call(method, caster, {"skill_id":"s", "effect_type":"e", "momentum_cost":1}, {"target_mode":"self"}, caster)
				"record_skill_heal": rng_log.call(method, caster, target, 3)
				"record_skill_status": rng_log.call(method, caster, target, "shake", 1, 0)
				"record_skill_momentum": rng_log.call(method, caster, "ally", 1)
				"record_skill_finished": rng_log.call(method, caster, 0)
				"record_reinforcement": rng_log.call(method, caster, 2, "reinforce_01")
				"stage_skill_command": rng_log.call(method, caster, target)
				"record_skill_damage": rng_log.call(method, caster, target, 1, "")
				_: rng_log.call(method, caster, target)
	expect(randf() == expected_draw, "recording consumed no random number")
	log.clear()
	expect(log.export().is_empty() and log.record_strategy_cast(caster, target, 0.5, false, "", 0).sequence == 0, "clear resets sequence")
	print("[TACTIC_LOG_SERVICE] checks=", checks, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
