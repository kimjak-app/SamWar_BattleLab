extends SceneTree
const Fingerprint = preload("res://scripts/battle/services/battle_state_fingerprint_service.gd")
var checks := 0
var failures := 0

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ", label)

func _initialize() -> void:
	var service := Fingerprint.new()
	var unit := BattleUnitState.create({"unit_id":"oracle_fixture", "grid_cell":Vector2i(2,3), "current_hp":100,"current_troops":100})
	unit.status_effects = {"burn":{"turns":2,"magnitude":8}}
	unit.last_action = {"cells":[Vector2i(1,2)]}
	var units: Array[BattleUnitState] = [unit]
	var before: Array = service.fingerprint_units(units)
	expect(service.diff(before,service.fingerprint_units(units)).is_empty(), "stable fingerprint")
	expect(before[0].grid_cell == [2,3], "cell normalized")
	expect(before[0].last_action.cells == [[1,2]], "nested vector normalized")
	var property_count := 0
	for property in unit.get_property_list():
		if int(property.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE:
			property_count += 1
			expect(before[0].has(String(property.name)), "includes " + String(property.name))
	expect(before[0].size() == property_count, "all and only script variables")
	unit.grid_cell = Vector2i(3,3)
	expect(service.diff(before, service.fingerprint_units(units)) == ["units[0].grid_cell"], "exact cell field path")
	unit.grid_cell = Vector2i(2,3)
	unit.status_effects.burn.turns = 1
	expect(service.diff(before,service.fingerprint_units(units)) == ["units[0].status_effects.burn.turns"], "nested field path")
	expect(before[0].status_effects.burn.turns == 2, "source cannot mutate old fingerprint")
	before[0].last_action.cells[0][0] = 90
	expect(unit.last_action.cells[0] == Vector2i(1,2), "fingerprint cannot mutate source")
	var second := BattleUnitState.create({"unit_id":"second"})
	var ordered: Array = service.fingerprint_units([second,unit])
	expect(ordered[0].unit_id == "second" and ordered[1].unit_id == unit.unit_id, "unit order preserved")
	var roundtrip: Variant = JSON.parse_string(JSON.stringify(ordered))
	expect(service.diff(ordered,roundtrip).is_empty(), "JSON numeric equivalence")
	expect(service.diff([{"x":1}],[{"y":1}]) == ["units[0].x","units[0].y"], "added removed fields")
	expect(service.diff([],[{}]) == ["units[0]"], "array length difference")
	expect(service.diff([{"x":true}],[{"x":1}]) == ["units[0].x"], "bool is not numeric")
	print("[BATTLE_STATE_FINGERPRINT] %s: %d checks, %d failures" % ["PASS" if failures == 0 else "FAIL",checks,failures])
	quit(0 if failures == 0 else 1)
