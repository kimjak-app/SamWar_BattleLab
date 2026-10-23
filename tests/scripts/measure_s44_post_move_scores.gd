extends SceneTree
# N2 measurement (not a CI test): default layout, rounds 1..10 (or the result),
# ally full auto (engine `_toggle_full_auto_battle`, 4x) or all-wait, per seed
# and enemy AI level ("none" = engine alone, flags untouched; else the start
# setup `enemy_ai_level`). For every enemy actor: the unique skill score before
# its move and after its move, and the engine events of that actor.
# --plain runs the same without the spy (to check the spy changes nothing).
# Args: --seed=N --ally=auto|wait --level=none|low|mid|high [--plain] --out=<json>
var out_path := ""
const SETUP_KEY := "samwar_battle_setup"

func _initialize() -> void:
	run.call_deferred()

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
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	if level != "none": Engine.set_meta(SETUP_KEY, {"enemy_ai_level":level})
	var host = load("res://scripts/battle3d/battle3d_engine_host.gd" if plain else "res://tests/scripts/support/s44_post_move_spy_host.gd").new()
	root.add_child(host)
	await host.initialized
	await process_frame
	var b: Node = host.battle
	Engine.time_scale = 4.0
	seed(seed_value)
	if ally_mode == "auto": b._toggle_full_auto_battle()
	for i in range(80000):
		await process_frame
		if b._get_battle_result_state() != "" or b.battle_round > 10: break
		if ally_mode == "wait" and b.current_phase == "ally_turn" and not b.is_demo_animating and b.active_unit_state != null: b._end_ally_turn_by_wait()
	Engine.time_scale = 1.0
	var events: Array = b.enemy_action_event_log.export()
	var rows: Array = [] if plain else b.actor_rows
	for index in range(rows.size()):
		var stop: int = rows[index + 1].event_index if index + 1 < rows.size() else events.size()
		var kinds: Array = []
		for e in events.slice(rows[index].event_index, stop):
			if e.get("unit_id", "") == rows[index].unit_id: kinds.append(e.kind)
		rows[index]["events"] = kinds
	var data := {"seed":seed_value, "ally":ally_mode, "level":level, "applied_level":b.enemy_ai_level if b.enemy_ai_level_applied else "(none)",
		"flags":[b.enemy_strategy_enabled, b.enemy_skill_spread_enabled, b.enemy_skill_cap_enabled],
		"result":b._get_battle_result_state(), "round":b.battle_round, "rows":rows, "plain":plain, "events":events}
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, " ", true))
	f.close()
	print("[N2_MEASURE] seed=", seed_value, " ally=", ally_mode, " level=", level, " result=", data.result, " round=", data.round, " actors=", rows.size())
	var iso = b.get("battle_grid_controller")
	host.free()
	if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
	await process_frame
	quit(0)
