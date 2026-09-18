extends SceneTree

const CombatQueryServiceScript := preload("res://scripts/battle/services/battle_combat_query_service.gd")
const BattleControllerScript := preload("res://scripts/battle/battle_controller.gd")

var _checks := 0
var _failures := 0
var _service := CombatQueryServiceScript.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_direction_queries()
	_test_opposite_facing_queries()
	_test_attack_angle_queries()
	_test_attack_range_queries()
	_test_controller_wrapper_parity()
	print("[BATTLE_COMBAT_QUERY_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_direction_queries() -> void:
	_expect(_service.get_direction_from_positions(Vector2i.ZERO, Vector2i(1, 0)) == "right", "east resolves right")
	_expect(_service.get_direction_from_positions(Vector2i.ZERO, Vector2i(-1, 0)) == "left", "west resolves left")
	_expect(_service.get_direction_from_positions(Vector2i.ZERO, Vector2i(0, 1)) == "down", "south resolves down")
	_expect(_service.get_direction_from_positions(Vector2i.ZERO, Vector2i(0, -1)) == "up", "north resolves up")
	_expect(_service.get_direction_from_positions(Vector2i.ZERO, Vector2i(1, 1)) == "right", "axis tie preserves horizontal priority")
	_expect(_service.get_direction_from_positions(Vector2i.ZERO, Vector2i.ZERO) == "right", "zero delta preserves right fallback")


func _test_opposite_facing_queries() -> void:
	_expect(_service.get_opposite_facing("left") == "right", "left opposite is right")
	_expect(_service.get_opposite_facing("right") == "left", "right opposite is left")
	_expect(_service.get_opposite_facing("up") == "down", "up opposite is down")
	_expect(_service.get_opposite_facing("down") == "up", "down opposite is up")
	_expect(_service.get_opposite_facing("invalid") == "left", "invalid facing preserves normalize-right then opposite-left fallback")


func _test_attack_angle_queries() -> void:
	var defender := _unit("infantry", Vector2i(2, 2))
	defender.facing = "right"
	var front_attacker := _unit("infantry", Vector2i(3, 2))
	var back_attacker := _unit("infantry", Vector2i(1, 2))
	var side_attacker := _unit("infantry", Vector2i(2, 1))
	_expect(_service.get_attack_angle_type(front_attacker, defender) == "front", "attacker in defender facing direction is front")
	_expect(_service.get_attack_angle_type(back_attacker, defender) == "back", "attacker opposite defender facing is back")
	_expect(_service.get_attack_angle_type(side_attacker, defender) == "side", "orthogonal attacker is side")
	_expect(_service.get_attack_angle_type(null, defender) == "front", "null attacker preserves front fallback")
	_expect(_service.get_attack_angle_type(front_attacker, null) == "front", "null defender preserves front fallback")


func _test_attack_range_queries() -> void:
	var infantry := _unit("infantry", Vector2i.ZERO)
	var target := _unit("infantry", Vector2i(1, 0))
	_expect(_service.is_unit_in_attack_range(infantry, target, 1), "infantry attacks at distance one")
	_expect(not _service.is_unit_in_attack_range(infantry, target, 2), "infantry rejects distance two")
	infantry.has_acted = true
	_expect(not _service.is_unit_in_attack_range(infantry, target, 1), "acted unit cannot attack")
	infantry.has_acted = false
	target.current_hp = 0
	_expect(not _service.is_unit_in_attack_range(infantry, target, 1), "dead target cannot be attacked")
	target.current_hp = 100
	var gunner := _unit("gunner", Vector2i.ZERO)
	gunner.has_moved = true
	_expect(not _service.is_unit_in_attack_range(gunner, target, 2), "moved gunner preserves no-attack-after-move rule")
	var archer := _unit("archer", Vector2i.ZERO)
	archer.has_moved = true
	_expect(_service.is_unit_in_attack_range(archer, target, 3), "moved archer preserves ranged attack eligibility")
	_expect(not _service.is_unit_in_attack_range(null, target, 1), "null attacker rejected")
	_expect(not _service.is_unit_in_attack_range(infantry, null, 1), "null target rejected")


func _test_controller_wrapper_parity() -> void:
	var controller := BattleControllerScript.new()
	var attacker := _unit("infantry", Vector2i(3, 2))
	var defender := _unit("infantry", Vector2i(2, 2))
	defender.facing = "right"
	_expect(controller.call("_get_direction_from_positions", Vector2i.ZERO, Vector2i(1, 1)) == _service.get_direction_from_positions(Vector2i.ZERO, Vector2i(1, 1)), "direction wrapper parity")
	_expect(controller.call("_get_opposite_facing", "up") == _service.get_opposite_facing("up"), "opposite-facing wrapper parity")
	_expect(controller.call("_get_attack_angle_type", attacker, defender) == _service.get_attack_angle_type(attacker, defender), "attack-angle wrapper parity")
	_expect(controller.call("is_unit_in_attack_range", attacker, defender) == _service.is_unit_in_attack_range(attacker, defender, 1), "attack-range wrapper parity")
	controller.free()


func _unit(unit_type: String, cell: Vector2i) -> BattleUnitState:
	var unit := BattleUnitState.new()
	unit.unit_type = unit_type
	unit.grid_cell = cell
	unit.current_hp = 100
	unit.max_hp = 100
	unit.current_troops = 100
	unit.max_troops = 100
	unit.has_moved = false
	unit.has_acted = false
	unit.facing = "right"
	return unit


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		return
	_failures += 1
	push_error("[BATTLE_COMBAT_QUERY_SERVICE_FAIL] %s" % label)
