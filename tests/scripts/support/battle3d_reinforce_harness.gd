extends "res://tests/scripts/support/battle3d_defend_harness.gd"
# M4-d harness: M4-a harness (eight write calls) whose spy also records the
# engine's reinforcement deploy entry points, so a 3D-side deploy call would
# change the recorded sequence. The 3D side never calls them.
const WaitHarness = preload("res://tests/scripts/support/battle3d_wait_harness.gd")
const EIGHT := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
	"_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed"]
const DEPLOYS := ["_try_deploy_reinforce_01_pair", "_try_deploy_city_reinforce_02_pair"]
var start_shown: Array = [] # views shown when the lab opened (before any arrival)
var deferred_frames := 0 # frames where the engine had deployed a unit the 3D was still holding back for the replay

class ReinforceSpyBattle extends WaitHarness.WaitSpyBattle:
	var deploy_calls: Array = []
	func _try_deploy_reinforce_01_pair() -> void:
		deploy_calls.append(["_try_deploy_reinforce_01_pair", battle_round])
		super._try_deploy_reinforce_01_pair()
	func _try_deploy_city_reinforce_02_pair() -> void:
		deploy_calls.append(["_try_deploy_city_reinforce_02_pair", battle_round])
		super._try_deploy_city_reinforce_02_pair()

class ReinforceHost extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(ReinforceSpyBattle)
		return node

func open_lab(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	lab.host.free()
	lab.host = ReinforceHost.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame
	lab._sync_views()
	start_shown = visible_ids()

func open_bare(tree: SceneTree, spy := true) -> Node:
	var host = ReinforceHost.new() if spy else Host.new()
	tree.root.add_child(host)
	await host.initialized
	preload("res://tests/scripts/support/battle3d_blocked_reference.gd").apply(host.battle) # T1: the same blocked cells as the 3D lab
	await tree.process_frame
	return host

func available_ids(battle: Node) -> Array:
	var ids := []
	for u in battle.get("all_battle_unit_states"):
		if battle.call("_is_unit_state_available_for_battle_slot", u): ids.append(u.unit_id)
	return ids

func visible_ids() -> Array:
	var ids := []
	for id in lab.views:
		if lab.views[id].visible: ids.append(id)
	return ids

func state4(battle: Node) -> Dictionary:
	var result := final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["deploys"] = battle.deploy_calls.duplicate(true)
	return result

func arrival_probe(tree: SceneTree) -> void:
	# A unit is never shown before its arrival is presented; when no replay is
	# pending, the shown units are exactly the engine's deployed units.
	lab._sync_views()
	var arrived: Array = lab.arrival_presentations.map(func(e): return e.unit_id)
	var start_ids: Array = start_shown
	display_checks += 1
	for id in visible_ids():
		if not (start_ids.has(id) or arrived.has(id)):
			expect(false, "unit %s shown before its arrival was presented" % id)
	var badges := 0
	for badge in lab.action_badges.get_children():
		if badge.visible: badges += 1
	if available_ids(lab.engine).size() > visible_ids().size() and not lab.pending_arrivals.is_empty(): deferred_frames += 1
	if badges != visible_ids().size(): expect(false, "badge count %d != shown views %d" % [badges, visible_ids().size()])
	if lab.roster_label.text.split("\n").size() - 1 != badges: expect(false, "roster lines != badges")
	if not lab._enemy_presentation_busy() and lab.engine.get("current_phase") == "ally_turn" and not lab.engine.get("is_demo_animating"):
		var engine_ids: Array = available_ids(lab.engine)
		var shown: Array = visible_ids()
		engine_ids.sort()
		shown.sort()
		if engine_ids != shown: expect(false, "idle: shown %s != engine deployed %s" % [shown, engine_ids])
