extends SceneTree
# T1 test 3: the enemy AI with blocked cells, on the engine alone (the 2D battle without any 3D presentation). Every ally
# turn ends with the engine's wait command until round 3 starts (two full enemy turns) or the battle ends; each frame
# every enemy's cell is read and a change is an enemy move. For seeds 1, 2 and 3:
#   - a free run (no blocked cell) records the cells the enemies moved to (they keep to the plain: the forest is not on
#     their way in this battle);
#   - a blocked run on the same seed blocks the 24 forest cells (read here from terrain_types.json) AND those cells:
#     no enemy move ends on a blocked cell, and the enemies still move (they go round).
const Host := preload("res://scripts/battle3d/battle3d_engine_host.gd")
const SEEDS := [1, 2, 3]
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func forest_cells() -> Array:
	var cells: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/battle3d/terrain_types.json")).cells
	var out := []
	for y in range(10):
		for x in range(18):
			if cells[y][x] == "forest": out.append(Vector2i(x, y))
	return out

func play(s: int, blocked: Array) -> Dictionary:
	var host := Host.new()
	root.add_child(host)
	await host.initialized
	await process_frame
	var battle: Node = host.battle
	battle.get("battle_grid_controller").set_blocked_cells(blocked)
	seed(s)
	var last := {}
	var moves := []
	for u in battle.all_battle_unit_states:
		if u.side == "enemy": last[u.unit_id] = u.grid_cell
	for i in range(20000):
		await process_frame
		for u in battle.all_battle_unit_states:
			if u.side != "enemy" or not u.is_alive(): continue
			if u.grid_cell != last.get(u.unit_id, u.grid_cell): moves.append([u.unit_id, last[u.unit_id], u.grid_cell, battle.battle_round])
			last[u.unit_id] = u.grid_cell
		if battle.call("_get_battle_result_state") != "" or battle.battle_round >= 3: break
		if battle.current_phase == "ally_turn" and not battle.is_demo_animating and battle.active_unit_state != null: battle.call("_end_ally_turn_by_wait")
	var round_reached: int = battle.battle_round
	var iso = battle.get("_iso_grid_controller")
	host.free()
	if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
	await process_frame
	return {"moves":moves, "round":round_reached}

func run() -> void:
	var forest := forest_cells()
	var summary := {}
	for s in SEEDS:
		var free := await play(s, [])
		var went: Array = []
		for m in free.moves:
			if not went.has(m[2]): went.append(m[2])
		var blocked: Array = forest + went.filter(func(c): return not forest.has(c))
		var held := await play(s, blocked)
		var into: Array = held.moves.filter(func(m): return blocked.has(m[2]))
		summary[s] = {"free_moves":free.moves.size(), "free_cells":went, "blocked":blocked.size(), "blocked_moves":held.moves.size(), "into_blocked":into, "round":held.round}
		expect(not went.is_empty() and into.is_empty() and held.moves.size() > 0,
			"seed %d: the free run moved to %s; with those cells and the forest blocked no enemy move ends on one (%s), %d moves" % [s, str(went), str(into), held.moves.size()])
	print("[T1_ENEMY_AI_BLOCKED] %s: %d checks, %d failures; %s" % ["PASS" if failures == 0 else "FAIL", checks, failures, summary])
	quit(0 if failures == 0 else 1)
