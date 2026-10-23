extends SceneTree
# NIGHT6 measurement (not a CI test): global random draws before and between
# strategy dice in battles where the dice really roll.
#
# Fixtures (test-only engine writes, as the S4-1/S4-2 strategy tests do):
#   enemy: enemy guan_yu (units[5]) intelligence 86 at (12,4) (S4-2 ES01 cell),
#          enemy AI level "mid" through the engine's set_enemy_ai_level; the rest
#          of the default battle is untouched. Allies act through the engine's own
#          auto action (wait when it cannot act).
#   ally:  the three main allies intelligence 96; each ally turn uses a strategy
#          through the engine's input entry (_on_strategy_button_pressed ->
#          _try_use_strategy_on_target) on the first valid enemy, else the
#          engine's auto action (wait when it cannot act). Level untouched.
# Paths: engine = the engine host alone (headless); lab = the 3D lab with the
#   engine host swapped before it enters the tree (as the 3D test harnesses do),
#   played with the lab's [자동] at 4x (enemy fixture only).
#
# Counting: the dice go through the engine's test hook strategy_roll_override
# with the engine's own expression on the same global generator (randf() <=
# rate, randi() % size), so the battle is unchanged; the hook keeps the drawn
# value. A RandomNumberGenerator with the same seed gives the same randi()
# steps as the global generator, and a global randf() equals that step's
# randi() / 2^32 (float rounding, checked at start). Each dice value is located
# by walking the parallel sequence one step at a time; the steps before it are
# the other draws (in battle only the presentation functions draw; the spy
# controller counts their calls). One randi() probe after the battle stops
# gives the total. --plain runs without hook and spy (event check).
# Args: --fixture=enemy|ally --path=engine|lab --seed=N [--plain] --out=<json>
const SETUP_KEY := "samwar_battle_setup"
const SEARCH := 400000
const RANDF_TOLERANCE := 2e-7
var out_path := ""
var rng := RandomNumberGenerator.new()
var position := 0
var dice: Array = []
var battle: Node = null
var lost := false

func _initialize() -> void:
	run.call_deferred()

func matches(kind: String, step: int, value: Variant) -> bool:
	if kind == "success": return absf(float(step) / 4294967296.0 - float(value)) <= RANDF_TOLERANCE
	return step == int(value)

func locate(kind: String, value: Variant) -> int:
	for skipped in range(SEARCH):
		if matches(kind, rng.randi(), value):
			position += skipped + 1
			return skipped
	return -1

func roll(kind: String, arg: Variant) -> Variant:
	var value: Variant = randf() if kind == "success" else randi()
	var result: Variant = value <= float(arg) if kind == "success" else int(value) % int(arg)
	var row := {"index":dice.size(), "kind":kind, "arg":arg, "value":value, "result":result, "round":battle.battle_round, "phase":battle.current_phase,
		"fx_calls":battle.fx_calls.duplicate() if "fx_calls" in battle else {}}
	if lost:
		row["skipped"] = -1
	else:
		var skipped := locate(kind, value)
		row["skipped"] = skipped
		row["position"] = position
		if skipped < 0: lost = true
	dice.append(row)
	return result

func randf_check() -> bool:
	seed(11)
	var g := []
	for i in range(64): g.append(randf())
	var r := RandomNumberGenerator.new()
	r.seed = 11
	for i in range(64):
		if absf(float(r.randi()) / 4294967296.0 - g[i]) > RANDF_TOLERANCE: return false
	seed(11)
	var gi := [randi(), randi()]
	r.seed = 11
	return gi == [r.randi(), r.randi()]

func ally_idle(b: Node) -> bool:
	return b.current_phase == "ally_turn" and not b.is_demo_animating and not b.is_unique_skill_presenting

func enemy_fixture(b: Node) -> void:
	var units: Array = b.all_battle_unit_states
	var actor: BattleUnitState = units[5]
	actor.intelligence = 86
	if b.all_battle_unit_states.filter(func(u): return u != actor and u.is_alive() and u.grid_cell == Vector2i(12,4)).is_empty():
		actor.set_grid_cell(Vector2i(12,4))
	for u in units: b.call("_sync_resumed_unit_markers_to_grid", u)
	b.call("_sync_demo_positions")
	b.call("set_enemy_ai_level", "mid")

func ally_fixture(b: Node) -> void:
	var units: Array = b.all_battle_unit_states
	for i in range(3): units[i].intelligence = 96

func ally_step(b: Node, use_strategy: bool) -> void:
	var active = b.active_unit_state
	if active == null or active.side != "ally": return
	b.call("_select_ally_unit", active, false, false, false)
	if use_strategy and b.call("_can_use_strategy", active):
		for target in b.all_battle_unit_states:
			if target.side == "enemy" and target.is_alive() and b.call("_is_unit_state_available_for_battle_slot", target) and b.call("_is_valid_strategy_target", active, target):
				b.call("_on_strategy_button_pressed")
				if b.current_phase == "strategy":
					b.call("_try_use_strategy_on_target", target)
					if b.call("_has_ally_unit_acted", active): return
				b.call("_cancel_strategy_target_select_mode")
				break
	var before: int = b.tactic_event_log.export().size() + b.ally_move_event_log.export().size() + b.battle_action_event_log.export().size()
	b.call("_run_auto_action_for_active_ally_once")
	var after: int = b.tactic_event_log.export().size() + b.ally_move_event_log.export().size() + b.battle_action_event_log.export().size()
	if ally_idle(b) and after == before and not b.call("_has_ally_unit_acted", active): b.call("_end_ally_turn_by_wait")

func run() -> void:
	var fixture := "enemy"
	var path := "engine"
	var seed_value := 1
	var plain := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--fixture="): fixture = arg.trim_prefix("--fixture=")
		if arg.begins_with("--path="): path = arg.trim_prefix("--path=")
		if arg.begins_with("--seed="): seed_value = int(arg.trim_prefix("--seed="))
		if arg.begins_with("--out="): out_path = arg.trim_prefix("--out=")
		if arg == "--plain": plain = true
	var sequence_ok := randf_check()
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	var host_script := "res://scripts/battle3d/battle3d_engine_host.gd" if plain else "res://tests/scripts/support/fx_rng_spy_host.gd"
	var holder: Node
	var lab: Node = null
	if path == "lab":
		root.size = Vector2i(1920, 1080)
		lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
		lab.host.free()
		lab.host = load(host_script).new()
		root.add_child(lab)
		while not lab.ready_for_input: await process_frame
		holder = lab
		battle = lab.engine
	else:
		holder = load(host_script).new()
		root.add_child(holder)
		await holder.initialized
		battle = holder.battle
	for i in range(600):
		if ally_idle(battle): break
		await process_frame
	if fixture == "enemy": enemy_fixture(battle)
	else: ally_fixture(battle)
	if lab != null: lab._sync_views()
	await process_frame
	if not plain: battle.strategy_roll_override = roll
	seed(seed_value)
	rng.seed = seed_value
	position = 0
	if path == "lab":
		for i in range(2): lab.speed_button.pressed.emit() # 1x -> 2x -> 4x
		lab.request_auto()
	else:
		Engine.time_scale = 4.0
	var frames := 0
	for i in range(120000):
		await process_frame
		frames += 1
		if battle._get_battle_result_state() != "" or battle.battle_round > 10: break
		if path == "engine" and ally_idle(battle) and battle.active_unit_state != null and battle.active_unit_state.side == "ally":
			ally_step(battle, fixture == "ally")
	Engine.time_scale = 1.0
	var end_steps := -1
	if not lost:
		var probe := randi()
		for k in range(SEARCH):
			if rng.randi() == probe:
				end_steps = position + k
				break
	var tactic: Array = battle.tactic_event_log.export()
	var data := {"fixture":fixture, "path":path, "seed":seed_value, "plain":plain, "sequence_ok":sequence_ok, "frames":frames,
		"result":battle._get_battle_result_state(), "round":battle.battle_round, "dice":dice, "end_steps":end_steps,
		"fx_calls_total":battle.fx_calls if "fx_calls" in battle else {},
		"strategy_events":tactic.filter(func(e): return str(e.get("kind", "")).begins_with("strategy")).size(),
		"enemy_events":battle.enemy_action_event_log.export(), "tactic_events":tactic}
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, " ", true))
	f.close()
	print("[DICE_RNG] fixture=", fixture, " path=", path, " seed=", seed_value, " plain=", plain, " sequence_ok=", sequence_ok, " result=", data.result,
		" round=", data.round, " dice=", dice.size(), " first_skipped=", dice[0].skipped if not dice.is_empty() else -2, " lost=", lost, " end_steps=", end_steps, " strategy_events=", data.strategy_events)
	if lab != null:
		var grid = lab.queries.grid
		lab.free()
		if is_instance_valid(grid) and grid.get_parent() == null: grid.free()
	else:
		var iso = battle.get("battle_grid_controller")
		holder.free()
		if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
	await process_frame
	quit(0)
