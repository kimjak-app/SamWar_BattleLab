extends RefCounted
## Live direction is state -> presentation only. Reverse direction creates fixtures.
const VIEW_FIELDS := ["unit_id","side","unit_type","grid_cell","facing","current_troops","max_troops","allocated_troops","footprint","has_moved","has_acted","status_effects","move_range","attack_range"]

static func to_view(state: BattleUnitState) -> Dictionary:
	var result := {}
	for field in VIEW_FIELDS:
		var value: Variant=state.get(field)
		result[field]=value.duplicate(true) if value is Dictionary or value is Array else value
	return result

static func create_fixture(data: Dictionary) -> BattleUnitState:
	var payload := data.duplicate(true)
	payload.erase("move_range")
	payload.erase("attack_range")
	# setup owns hero and unit-type normalization; no post-setup rule overrides.
	return BattleUnitState.create(payload)
