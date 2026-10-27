extends "res://tests/scripts/support/battle3d_strategy_harness.gd"
# M4-c1 harness: M4-b harness plus the eleventh and twelfth write calls
# (`_on_unique_skill_button_pressed`, `_try_use_unique_skill_on_target`).
# Fixtures reuse the S4-1 tactic oracle board (caster units[0] at (8,4), ally
# units[1] adjacent, enemies units[5..7] near, the rest far; only the caster and
# units[5] unacted) with one skill per effect_type, first in data order.
const StrategyHarness = preload("res://tests/scripts/support/battle3d_strategy_harness.gd")
const TacticOracle = preload("res://tests/scripts/support/battle_tactic_oracle_harness.gd")
const StatusNames = preload("res://scripts/battle/helpers/battle_ui_text_format_helper.gd")
const TWELVE := ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
	"_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target",
	"_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target"]
const NEW_COMMANDS := ["_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target",
	"_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target"]
var tactic = TacticOracle.new()
var label_seen := {} # Label3D instance id -> [unit_id, text] of every skill label seen on screen
var momentum_checks := 0
var held_momentum_text := ""

static func skill_cases() -> Array:
	var cases: Array = []
	for effect_type in TacticOracle.SKILL_EFFECT_TYPES: cases.append("K_" + effect_type)
	cases.append("X_enemy_skill_in_slot")
	return cases

class SkillSpyBattle extends StrategyHarness.StrategySpyBattle:
	var skill_calls := 0
	func _on_unique_skill_button_pressed() -> void:
		writes.append("_on_unique_skill_button_pressed")
		skill_calls += 1
		super._on_unique_skill_button_pressed()
	func _try_use_unique_skill_on_target(target_state: BattleUnitState) -> void:
		writes.append("_try_use_unique_skill_on_target")
		skill_calls += 1
		super._try_use_unique_skill_on_target(target_state)

class SkillHost extends Host:
	func create_battle() -> Node:
		var node := super.create_battle()
		node.set_script(SkillSpyBattle)
		return node

func open_lab(tree: SceneTree) -> void:
	tree.root.size = Vector2i(1280,800)
	lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	lab.host.free()
	lab.host = SkillHost.new()
	tree.root.add_child(lab)
	while not lab.ready_for_input: await tree.process_frame
	await tree.physics_frame

func open_bare(tree: SceneTree, spy := true) -> Node:
	var host = SkillHost.new() if spy else Host.new()
	tree.root.add_child(host)
	await host.initialized
	preload("res://tests/scripts/support/battle3d_blocked_reference.gd").apply(host.battle) # T1: the same blocked cells as the 3D lab
	await tree.process_frame
	return host

func press_skill() -> void:
	lab.skill_button.pressed.emit()

func skill_setup(battle: Node, label: String) -> Dictionary:
	# Fixture writes only, shared by both paths (same as the S4-1 K_ cases).
	var units: Array[BattleUnitState] = battle.get("all_battle_unit_states")
	tactic._board(battle, units)
	var momentum = battle.get("battle_momentum")
	momentum.gain("ally", 10, "fixture")
	momentum.gain("enemy", 3, "fixture")
	var skill: Dictionary = tactic.skill_for_effect("single_debuff" if label == "X_enemy_skill_in_slot" else label.trim_prefix("K_"))
	if label == "X_enemy_skill_in_slot":
		# The enemy actor keeps a real skill and enough momentum to use it in its slot.
		units[5].unique_skill_definition = tactic.skill_by_id("guan_yu_unique")
		momentum.gain("enemy", 7, "fixture")
	if label == "K_retreat_counter":
		tactic._setup_unit(units[1], "infantry", Vector2i(7,5)) # free the retreat cell behind the caster
	if label == "K_rally_restore":
		units[0].apply_status_effect("burn", 2, 8)
		units[1].apply_status_effect("defense_down", 2, 10)
		for i in [0, 1]:
			units[i].current_hp = 200
			units[i].current_troops = 200
	expect(not skill.is_empty(), label + " skill found")
	units[0].unique_skill_definition = skill
	tactic._sync(battle, units)
	return {"caster":units[0], "skill":skill, "units":units}

func is_auto(battle: Node, caster: BattleUnitState) -> bool:
	return battle.call("_should_unique_skill_resolve_without_manual_target", battle.call("_get_unique_skill_for_unit", caster))

func chosen_target(battle: Node, caster: BattleUnitState) -> BattleUnitState:
	# Test-side choice, same on both paths: the engine's own best target query.
	return battle.call("_get_best_unique_skill_target_for_actor", caster, battle.call("_get_unique_skill_for_unit", caster))

func run_skill_direct(tree: SceneTree, label: String) -> Dictionary:
	var host = await open_bare(tree)
	var battle: Node = host.battle
	var s := skill_setup(battle, label)
	await tree.process_frame
	battle.call("_select_ally_unit", s.caster, false, false, false)
	var auto := is_auto(battle, s.caster)
	var target: BattleUnitState = chosen_target(battle, s.caster)
	battle.call("_on_unique_skill_button_pressed")
	if not auto: battle.call("_try_use_unique_skill_on_target", target)
	await settle_bare(tree, battle, label)
	var result := final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["target"] = target.unit_id if target != null else ""
	await close_bare(tree, host)
	return result

func skill_display_probe(tree: SceneTree) -> void:
	# Labels: every skill Label3D on screen is recorded with its actual text.
	for child in lab.get_children():
		if child is Label3D and child.has_meta("skill_label"): label_seen[child.get_instance_id()] = [child.get_meta("skill_label"), child.text]
	# Momentum HUD == engine momentum whenever no enemy replay is pending.
	lab._sync_views() # reads new events first: a fresh enemy slot makes the replay pending
	if lab._enemy_presentation_busy():
		# While an enemy slot replays, the HUD keeps the value it had when the replay began.
		if held_momentum_text.is_empty(): held_momentum_text = lab.momentum_label.text
		momentum_checks += 1
		if lab.momentum_label.text != held_momentum_text:
			expect(false, "momentum HUD changed during the enemy replay: %s -> %s" % [held_momentum_text, lab.momentum_label.text])
	else:
		held_momentum_text = ""
		var m = lab.engine.get("battle_momentum")
		momentum_checks += 1
		if not lab.momentum_label.text.begins_with("기세 아군 %d / 적 %d" % [m.get_value("ally"), m.get_value("enemy")]):
			expect(false, "momentum HUD %s vs engine %d/%d" % [lab.momentum_label.text, m.get_value("ally"), m.get_value("enemy")])
	strategy_display_probe(tree)

func run_skill_3d(tree: SceneTree, label: String) -> Dictionary:
	frames.clear()
	label_seen.clear()
	held_momentum_text = ""
	await open_lab(tree)
	var battle: Node = lab.engine
	var s := skill_setup(battle, label)
	lab._sync_views()
	await tree.process_frame
	click(s.caster.grid_cell)
	lab._sync_views()
	expect(not lab.skill_button.disabled, label + " skill button enabled " + lab.skill_button.tooltip_text)
	var auto := is_auto(battle, s.caster)
	var target: BattleUnitState = chosen_target(battle, s.caster)
	press_skill()
	expect(battle.get("current_phase") == "unique_skill_target_select", label + " engine entered skill target select")
	if auto:
		expect(battle.get("is_manual_unique_skill_preview_pending") and lab.skill_target_ids.is_empty(), label + " self-resolving mode: engine preview, no target marks")
	else:
		var valid: Array = battle.call("_get_unique_skill_valid_targets", s.caster, s.skill).map(func(u): return u.unit_id)
		expect(lab.skill_target_ids == valid and lab.skill_marks.get_child_count() == valid.size(), label + " marks == engine valid targets " + str(lab.skill_target_ids))
		click(target.grid_cell)
		expect(battle.get("tactic_event_log").export().any(func(e): return e.kind == "skill_cast"), label + " target click committed the skill")
	await settle_lab(tree, label, skill_display_probe)
	await tree.process_frame
	lab._process(0.0)
	var result := final_state(battle)
	result["tactic"] = battle.get("tactic_event_log").export()
	result["target"] = target.unit_id if target != null else ""
	result["lab"] = skill_lab_view()
	return result

func skill_lab_view() -> Dictionary:
	var view := lab_view()
	view["tactic_cursor"] = lab.tactic_cursor
	view["presentations"] = lab.tactic_presentations.duplicate(true)
	view["skill_presentations"] = lab.skill_presentations.duplicate(true)
	view["skill_texts"] = lab.skill_texts.duplicate()
	view["labels"] = label_seen.values()
	view["momentum_text"] = lab.momentum_label.text
	view["pending_ticks"] = lab.pending_enemy_ticks.duplicate(true)
	return view

# Expected display, built here from the event values only (independent of 3D code).
static func status_name(status_id: String) -> String:
	return StatusNames.format_unique_skill_status_display_name(status_id)

static func signed(amount: int) -> String:
	return ("+" if amount > 0 else "") + str(amount)

static func cell_text(cell: Array) -> String:
	return "(" + str(cell[0]) + ", " + str(cell[1]) + ")"

static func expected_display(events: Array, skill_names: Dictionary) -> Dictionary:
	# events: allied-caster skill_* events in log order; skill_names: skill_id -> display_name.
	var lines: Array = []
	var labels: Array = []
	var note := ""
	for e in events:
		match e.kind:
			"skill_cast":
				var name: String = skill_names.get(e.skill_id, e.skill_id)
				note = ""
				labels.append([e.caster_id, name])
				lines.append("특기 · " + e.caster_id + " · " + name + " (기세 −" + str(e.momentum_cost) + ")")
			"skill_finished":
				lines.append("특기 종료 · " + e.caster_id + ("" if e.cooldown_turns == 0 else " · 쿨다운 " + str(e.cooldown_turns) + "턴"))
			"skill_effect":
				match e.effect_kind:
					"damage":
						labels.append([e.target_id, "−" + str(e.amount) + ("\n격파" if e.killed else "")])
						lines.append("특기 피해 · " + e.target_id + " −" + str(e.amount) + (" · 격파" if e.killed else "") + ("" if e.status_id == "" else " · " + e.status_id))
					"heal":
						labels.append([e.target_id, "+" + str(e.amount)])
						lines.append("특기 회복 · " + e.target_id + " +" + str(e.amount))
					"status":
						labels.append([e.target_id, status_name(e.status_id) + " " + str(e.turns_after) + "턴"])
						lines.append("특기 상태 · " + e.target_id + " · " + status_name(e.status_id) + " " + str(e.turns_after) + "턴")
					"cleanse":
						labels.append([e.target_id, status_name(e.status_id) + " 해제"])
						lines.append("특기 해제 · " + e.target_id + " · " + status_name(e.status_id) + " 해제")
					"momentum":
						note = ("아군" if e.target_id == "ally" else "적") + " 기세 " + signed(e.amount)
						lines.append("특기 기세 · " + note)
					"move":
						lines.append("특기 이동 · " + e.target_id + " 이동 " + cell_text(e.from_cell) + " → " + cell_text(e.to_cell))
	return {"lines":lines, "labels":labels, "note":note}

static func ally_skill_events(events: Array, sides: Dictionary) -> Array:
	return events.filter(func(e): return e.kind in ["skill_cast", "skill_effect", "skill_finished"] and sides.get(e.caster_id, "") == "ally")

static func sorted_pairs(pairs: Array) -> Array:
	var copy: Array = pairs.map(func(p): return str(p[0]) + "|" + str(p[1]))
	copy.sort()
	return copy
