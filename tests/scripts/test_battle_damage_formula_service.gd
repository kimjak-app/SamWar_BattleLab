extends SceneTree

const DamageFormulaServiceScript := preload("res://scripts/battle/services/battle_damage_formula_service.gd")

var _checks := 0
var _failures := 0
var _service := DamageFormulaServiceScript.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_neutral_angles_and_minimum()
	_test_unit_type_context()
	_test_attacker_statuses()
	_test_defender_statuses()
	_test_flank_status_guards()
	_test_gunner_formula()
	await _test_controller_wrapper_parity()
	print("[BATTLE_DAMAGE_FORMULA_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_neutral_angles_and_minimum() -> void:
	var attacker := _unit("archer")
	var defender := _unit("archer")
	_expect_damage(100, attacker, defender, "front", 100, "front neutral damage")
	_expect_damage(100, attacker, defender, "side", 115, "side neutral damage")
	_expect_damage(100, attacker, defender, "back", 130, "back neutral damage")
	_expect_damage(0, attacker, defender, "front", 1, "minimum damage clamps to one")


func _test_unit_type_context() -> void:
	_expect_damage(100, _unit("mounted_archer"), _unit("archer"), "front", 92, "unit-type base damage modifier")
	_expect_damage(100, _unit("archer"), _unit("infantry"), "front", 103, "matchup and received modifiers")
	_expect_damage(100, _unit("cavalry"), _unit("archer"), "side", 137, "unit-type side modifier")


func _test_attacker_statuses() -> void:
	var defender := _unit("archer")
	var attacker := _unit("archer")
	attacker.status_effects = {"shake": 1}
	_expect_damage(100, attacker, defender, "front", 90, "attacker shake default")
	attacker = _unit("archer")
	attacker.status_effects = {"attack_defense_up": 1}
	_expect_damage(100, attacker, defender, "front", 110, "attacker attack-defense up default")
	attacker = _unit("archer")
	attacker.status_effects = {"attack_defense_down": 1}
	_expect_damage(100, attacker, defender, "front", 90, "attacker attack-defense down default")
	attacker = _unit("archer")
	attacker.status_effects = {"counter_up": 1}
	_expect_damage(100, attacker, defender, "front", 115, "counter-up default")


func _test_defender_statuses() -> void:
	var attacker := _unit("archer")
	var defender := _unit("archer")
	defender.status_effects = {"shake": 1}
	_expect_damage(100, attacker, defender, "front", 110, "defender shake default")
	defender = _unit("archer")
	defender.is_defending = true
	_expect_damage(100, attacker, defender, "front", 62, "defending multiplier")
	defender = _unit("archer")
	defender.status_effects = {"defense_up": 1}
	_expect_damage(100, attacker, defender, "front", 90, "defender defense up default")
	defender = _unit("archer")
	defender.status_effects = {"attack_defense_up": 1}
	_expect_damage(100, attacker, defender, "front", 90, "defender attack-defense up alias")
	defender = _unit("archer")
	defender.status_effects = {"defense_down": 1}
	_expect_damage(100, attacker, defender, "front", 110, "defender defense down default")
	defender = _unit("archer")
	defender.status_effects = {"attack_defense_down": 1}
	_expect_damage(100, attacker, defender, "front", 110, "defender attack-defense down alias")
	defender = _unit("archer")
	defender.status_effects = {"damage_reduction": 1}
	_expect_damage(100, attacker, defender, "front", 88, "damage reduction default")
	defender = _unit("archer")
	defender.status_effects = {"formation_break": 1}
	_expect_damage(100, attacker, defender, "front", 112, "formation break multiplier")
	defender = _unit("archer")
	defender.status_effects = {"incoming_damage_down": 1}
	_expect_damage(100, attacker, defender, "front", 88, "incoming damage down default")


func _test_flank_status_guards() -> void:
	var attacker := _unit("archer")
	var defender := _unit("archer")
	attacker.status_effects = {"flank_damage_up": 1}
	_expect_damage(100, attacker, defender, "front", 100, "attacker flank bonus excludes front")
	_expect_damage(100, attacker, defender, "side", 132, "attacker flank bonus applies to side")
	attacker = _unit("archer")
	defender.status_effects = {"flank_damage_taken_up": 1}
	_expect_damage(100, attacker, defender, "front", 100, "defender flank-taken bonus excludes front")
	_expect_damage(100, attacker, defender, "back", 150, "defender flank-taken bonus applies to back")


func _test_gunner_formula() -> void:
	var defender := _unit("archer")
	var gunner := _unit("gunner")
	_expect_damage(100, gunner, defender, "front", 115, "gunner prepared fire")
	gunner.has_moved = true
	_expect_damage(100, gunner, defender, "front", 100, "moved gunner skips prepared fire")
	gunner = _unit("gunner")
	gunner.status_effects = {"post_fire_penalty": 1}
	_expect_damage(100, gunner, defender, "front", 69, "gunner post-fire penalty after prepared fire")
	gunner = _unit("gunner")
	defender.defense = 44
	_expect_damage(2, gunner, defender, "front", 2, "gunner armor ignore preserves second-round result")


func _test_controller_wrapper_parity() -> void:
	var packed := load("res://scenes/battle/Battle_Main.tscn") as PackedScene
	_expect(packed != null, "Battle_Main loads for damage wrapper parity")
	if packed == null:
		return
	var controller := packed.instantiate()
	root.add_child(controller)
	await process_frame
	var attacker := _unit("archer")
	attacker.grid_cell = Vector2i(3, 2)
	var defender := _unit("archer")
	defender.grid_cell = Vector2i(2, 2)
	defender.facing = "right"
	var angle_type := String(controller.call("_get_attack_angle_type", attacker, defender))
	var service_damage := _service.calculate_pre_wounded_damage(100, attacker, defender, angle_type)
	var wrapper_damage: Variant = controller.call("_get_directional_attack_damage", 100, attacker, defender, false, false)
	_expect(typeof(wrapper_damage) == TYPE_INT, "damage wrapper executes and returns an integer")
	_expect(wrapper_damage == service_damage, "damage wrapper preserves pre-wounded service result")
	_expect(controller.call("_get_attack_angle_damage_multiplier", "side") == _service.get_attack_angle_damage_multiplier("side"), "angle multiplier wrapper parity")
	attacker.status_effects = {"attack_defense_up": 1}
	service_damage = _service.calculate_pre_wounded_damage(100, attacker, defender, angle_type)
	wrapper_damage = controller.call("_get_directional_attack_damage", 100, attacker, defender, false, true)
	_expect(wrapper_damage == service_damage, "skill-style wounded flag false avoids a second attacker penalty")
	controller.free()
	await _finish_fixture_audio()
	await process_frame


func _finish_fixture_audio() -> void:
	var game_audio := root.get_node_or_null("GameAudio")
	if game_audio == null:
		return
	for child in game_audio.get_children():
		var voice := child as AudioStreamPlayer
		if voice != null:
			if voice.playing:
				await voice.finished
			voice.stop()
			voice.stream = null


func _expect_damage(base_damage: int, attacker: BattleUnitState, defender: BattleUnitState, angle_type: String, expected: int, label: String) -> void:
	var actual := _service.calculate_pre_wounded_damage(base_damage, attacker, defender, angle_type)
	_expect(actual == expected, "%s expected=%d actual=%d" % [label, expected, actual])


func _unit(unit_type: String) -> BattleUnitState:
	var unit := BattleUnitState.new()
	unit.unit_type = unit_type
	unit.current_hp = 100
	unit.max_hp = 100
	unit.current_troops = 100
	unit.max_troops = 100
	unit.defense = 0
	unit.has_moved = false
	unit.has_acted = false
	unit.is_defending = false
	unit.facing = "right"
	return unit


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("[BATTLE_DAMAGE_FORMULA_SERVICE_FAIL] %s" % label)
