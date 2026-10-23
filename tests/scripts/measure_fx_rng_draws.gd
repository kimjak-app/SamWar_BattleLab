extends SceneTree
# T3 measurement (not a CI test): how many global random draws happen before
# and between the strategy dice in a headless battle. Default layout, rounds
# 1..10 (or the result), ally full auto (4x) or all-wait, per seed and enemy AI
# level ("none" = engine alone, flags untouched; else the start setup).
#
# The dice go through the engine's test hook `strategy_roll_override` with the
# same draw the engine itself makes (`randf() <= rate`, `randi() % size`), so
# the battle is unchanged; the hook counts them. A parallel RandomNumberGenerator
# with the same seed gives the same `randi()` steps as the global generator
# (checked; its `randf()` does not match, so only `randi()` values are located).
# Draws are counted in global `randi()` steps: the steps one global `randf()`,
# `randf_range()` and `randi()` use are calibrated first, then one `randi()`
# probe taken after the battle has ended is located in the parallel sequence:
# the steps before it are every draw the battle made since `seed()`. Pool-index
# dice (`randi`) are located as they happen. The spy controller counts the calls
# of the presentation functions that draw (in battle the only other draws).
# --plain runs without hook and spy, to check that the events are the same.
# Args: --seed=N --ally=auto|wait --level=none|low|mid|high [--plain] --out=<json>
const SETUP_KEY := "samwar_battle_setup"
const SEARCH := 200000
var out_path := ""
var rng := RandomNumberGenerator.new()
var position := 0 # 32-bit steps consumed so far in the parallel sequence
var dice: Array = []
var battle: Node = null
var lost := false

func _initialize() -> void:
	run.call_deferred()

func step_value(kind: String, state: int) -> Variant:
	var probe := RandomNumberGenerator.new()
	probe.state = state
	return probe.randf() if kind == "success" else probe.randi()

func locate(kind: String, value: Variant) -> int:
	# Steps skipped before this draw (-1 = not found within SEARCH).
	for skipped in range(SEARCH):
		if step_value(kind, rng.state) == value:
			rng.randi() # this draw itself (one step)
			position += skipped + 1
			return skipped
		rng.randi()
	return -1

func steps_used(draw: Callable) -> int:
	# Global randi() steps one draw uses (-1 = not found in 64 steps).
	seed(7)
	draw.call()
	var probe := randi()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	for k in range(64):
		if r.randi() == probe: return k
	return -1

func roll(kind: String, arg: Variant) -> Variant:
	# The engine's own expression on the same global generator.
	var value: Variant = randf() if kind == "success" else randi()
	var result: Variant = value <= float(arg) if kind == "success" else int(value) % int(arg)
	var row := {"index":dice.size(), "kind":kind, "arg":arg, "round":battle.battle_round, "phase":battle.current_phase,
		"fx_calls":battle.fx_calls.duplicate() if "fx_calls" in battle else {}}
	if lost or kind == "success":
		row["skipped"] = -1 # a randf() value cannot be located (see above)
		if kind == "success": lost = true
	else:
		var skipped := locate(kind, value)
		row["skipped"] = skipped
		row["position"] = position
		if skipped < 0: lost = true
	dice.append(row)
	return result

func run() -> void:
	var seed_value := 1
	var ally_mode := "auto"
	var level := "none"
	var plain := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="): seed_value = int(arg.trim_prefix("--seed="))
		if arg.begins_with("--ally="): ally_mode = arg.trim_prefix("--ally=")
		if arg.begins_with("--level="): level = arg.trim_prefix("--level=")
		if arg.begins_with("--out="): out_path = arg.trim_prefix("--out=")
		if arg == "--plain": plain = true
	# The global generator and a RandomNumberGenerator with the same seed give the same steps.
	seed(seed_value)
	var global_steps := [randi(), randi(), randi(), randf(), randi()]
	rng.seed = seed_value
	var rng_steps := [rng.randi(), rng.randi(), rng.randi(), rng.randf(), rng.randi()]
	var same_sequence := global_steps.slice(0, 3) == rng_steps.slice(0, 3)
	var calibration := {"randi":steps_used(func(): randi()), "randf":steps_used(func(): randf()), "randf_range":steps_used(func(): randf_range(0.18, 0.28)),
		"randi_mod":steps_used(func(): return randi() % 3), "none":steps_used(func(): pass)}
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	if level != "none": Engine.set_meta(SETUP_KEY, {"enemy_ai_level":level})
	var host = load("res://scripts/battle3d/battle3d_engine_host.gd" if plain else "res://tests/scripts/support/fx_rng_spy_host.gd").new()
	root.add_child(host)
	await host.initialized
	await process_frame
	battle = host.battle
	if not plain: battle.strategy_roll_override = roll
	Engine.time_scale = 4.0
	seed(seed_value)
	rng.seed = seed_value
	position = 0
	if ally_mode == "auto": battle._toggle_full_auto_battle()
	for i in range(80000):
		await process_frame
		if battle._get_battle_result_state() != "" or battle.battle_round > 10: break
		if ally_mode == "wait" and battle.current_phase == "ally_turn" and not battle.is_demo_animating and battle.active_unit_state != null: battle._end_ally_turn_by_wait()
	Engine.time_scale = 1.0
	# The battle is over (or past round 10): one probe draw, located in the parallel sequence.
	var end_steps := -1
	if not lost:
		var probe := randi()
		for k in range(SEARCH):
			if rng.randi() == probe:
				end_steps = position + k
				break
	var data := {"calibration":calibration, "end_steps":end_steps,"seed":seed_value, "ally":ally_mode, "level":level, "plain":plain, "same_sequence":same_sequence,
		"flags":[battle.enemy_strategy_enabled, battle.enemy_skill_spread_enabled, battle.enemy_skill_cap_enabled],
		"result":battle._get_battle_result_state(), "round":battle.battle_round, "dice":dice,
		"fx_calls_total":battle.fx_calls if "fx_calls" in battle else {},
		"enemy_events":battle.enemy_action_event_log.export(), "tactic_events":battle.tactic_event_log.export()}
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, " ", true))
	f.close()
	print("[FX_RNG] seed=", seed_value, " ally=", ally_mode, " level=", level, " plain=", plain, " same_sequence=", same_sequence,
		" result=", data.result, " round=", data.round, " dice=", dice.size(), " lost=", lost, " end_steps=", end_steps, " calibration=", calibration)
	var iso = battle.get("battle_grid_controller")
	host.free()
	if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
	await process_frame
	quit(0)
