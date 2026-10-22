extends "res://tests/scripts/support/battle3d_option_harness.gd"
# M4-e harness: the 3D lab (M5-c observing host) with the S4-2 enemy strategy
# fixture (test-only engine writes): enemy guan_yu (units[5]) with strategy
# intelligence two cells from ally yi_sunsin (units[0]), every other unit far
# away and acted; the level set to "mid" through the engine function (not a 3D
# write); the strategy roll forced. One 3D [대기] starts the enemy slot.
const OracleScript = preload("res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd")
var oracle_fixture = OracleScript.new()

func strategy_fixture(spec: Dictionary) -> void:
	var b: Node = lab.engine
	var units: Array[BattleUnitState] = b.all_battle_unit_states
	var far_allies := [Vector2i(0,9), Vector2i(1,9), Vector2i(2,9), Vector2i(3,9)]
	var far_enemies := [Vector2i(17,0), Vector2i(16,0), Vector2i(15,0), Vector2i(14,0)]
	for i in range(1,5): oracle_fixture._setup_unit(units[i], "infantry", far_allies[i-1])
	for i in range(6,10): oracle_fixture._setup_unit(units[i], "infantry", far_enemies[i-6])
	oracle_fixture._setup_unit(units[0], "infantry", spec.get("target", Vector2i(9,4)))
	oracle_fixture._setup_unit(units[5], "infantry", spec.get("actor", Vector2i(12,4)))
	units[5].intelligence = spec.get("int", 86)
	units[0].intelligence = 70
	if spec.get("burning", false): units[5].apply_status_effect("burn", 2, 12)
	var lock = b.action_lock_state_service
	for i in range(6,10): lock.register_unit_acted(units[i], "enemy")
	for i in range(1,5): lock.register_unit_acted(units[i], "ally")
	for u in units:
		b.call("_sync_resumed_unit_markers_to_grid", u)
	b.call("_sync_demo_positions")
	b.call("_select_ally_unit", units[0], false, false, false)
	b.set("strategy_roll_override", forced_roll(spec.get("success", true), spec.get("pool", 0)))
	b.call("set_enemy_ai_level", "mid")
	lab._sync_views()

var tactic_labels_seen := {} # Label3D instance id -> [text, world position]

func wait_idle(tree: SceneTree) -> void:
	tactic_labels_seen.clear()
	for i in range(4000):
		await tree.process_frame
		for child in lab.get_children():
			if child is Label3D and child.has_meta("tactic_label"): tactic_labels_seen[child.get_instance_id()] = [child.text, child.position]
		if lab.engine.current_phase == "ally_turn" and not lab._presentation_busy(): return
	for i in range(5):
		await tree.process_frame
		for child in lab.get_children():
			if child is Label3D and child.has_meta("tactic_label"): tactic_labels_seen[child.get_instance_id()] = [child.text, child.position]
