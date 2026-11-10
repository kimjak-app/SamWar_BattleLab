extends RefCounted

## Queue 35 reply 1: the optional naval keys of the battle start setup (`samwar_battle_setup`).
## Called only from the engine's `_read_battle_setup_port`, `_apply_battle_setup_unit_override` and the two
## `build_plan` battle_type arguments. A setup without these keys never reaches a write here: nothing is
## changed, stored or logged, so the land battle and S4-3 stay as they were.
##
## Top level: `battle_type` ("naval" / "land"), `arrival_round_overrides` ({slot_id or unit_id: round}; 0 = on the
## board from the start), `blocked_cells` (cells the start cells must avoid; the lab hands the engine grid the same
## cells after the engine's _ready).
## Per unit: `unit_type`, `hero_id`, `troops`, `grid_cell` ([x, y]), `facing`.
## Order for one unit: type and hero are checked first; the hero is applied (its rebuild resets type and ranges),
## then the type with its ranges, then troops and facing. Cells are placed after every unit (so two units can swap
## cells), then the arrival rounds.

const UnitTypeContractScript := preload("res://scripts/battle/unit_type_contract.gd")
const HeroDefinitionRegistryScript := preload("res://scripts/worldmap/hero_definition_registry.gd")
const HeroRuntimeFactoryScript := preload("res://scripts/worldmap/hero_runtime_factory.gd")
const BattleSetupRulesServiceScript := preload("res://scripts/battle/services/battle_setup_rules_service.gd")

const UNIT_KEYS := ["unit_type", "hero_id", "troops", "grid_cell", "facing"]
const BATTLE_TYPES := ["naval", "land"]
const FACINGS := ["left", "right", "up", "down"]
const REINFORCE_SLOTS := ["ally_reinforce_01", "enemy_reinforce_01", "ally_reinforce_02", "enemy_reinforce_02"]
const CITY_REINFORCE_SLOTS := ["ally_reinforce_02", "enemy_reinforce_02"]
const META_BATTLE_TYPE := "battle_setup_battle_type"
const META_PENDING_CELLS := "battle_setup_pending_cells"
const PORTRAIT_PATH := "res://assets/heroes/portraits/%s/%s_%s.png"
const PORTRAIT_COUNTRIES := ["korea", "china", "japan", "mongol"]


static func has_unit_keys(override: Variant) -> bool:
	if not override is Dictionary:
		return false
	for key in UNIT_KEYS:
		if (override as Dictionary).has(key):
			return true
	return false


## The battle_type handed to the skill resolver: the worldmap context's value when it has one, else the start
## setup's, else "land". The setup value is never written into the worldmap context.
static func battle_type(battle: Node, context: Dictionary) -> String:
	if context.has("battle_type"):
		return String(context.get("battle_type"))
	return String(battle.get_meta(META_BATTLE_TYPE, "land"))


static func apply_unit_keys(battle: Node, target: BattleUnitState, unit_id: String, override: Dictionary) -> void:
	var unit_type := ""
	if override.has("unit_type"):
		var wanted: Variant = override.get("unit_type")
		if typeof(wanted) == TYPE_STRING and UnitTypeContractScript.is_supported(wanted):
			unit_type = wanted
		else:
			_ignored(battle, "%s unit_type %s" % [unit_id, str(wanted)])
	if override.has("hero_id"):
		var hero_id: Variant = override.get("hero_id")
		if typeof(hero_id) == TYPE_STRING and HeroDefinitionRegistryScript.HERO_DATA.has(hero_id):
			_apply_hero(battle, target, hero_id)
			print("[BATTLE_SETUP] %s hero_id=%s unit_id=%s name=%s" % [unit_id, hero_id, target.unit_id, target.display_name])
		else:
			_ignored(battle, "%s hero_id %s" % [unit_id, str(hero_id)])
	if not unit_type.is_empty():
		_apply_unit_type(target, unit_type)
		print("[BATTLE_SETUP] %s unit_type=%s move_range=%d attack_range=%d" % [unit_id, unit_type, target.move_range, target.attack_range])
	if override.has("troops"):
		var troops: Variant = override.get("troops")
		if (typeof(troops) == TYPE_INT or typeof(troops) == TYPE_FLOAT) and int(troops) > 0 and float(troops) == float(int(troops)):
			for field in BattleSetupRulesServiceScript.TROOP_FIELDS:
				target.set(field, int(troops))
			print("[BATTLE_SETUP] %s troops=%d" % [unit_id, int(troops)])
		else:
			_ignored(battle, "%s troops %s" % [unit_id, str(troops)])
	if override.has("facing"):
		var facing: Variant = override.get("facing")
		if typeof(facing) == TYPE_STRING and FACINGS.has(facing):
			target.facing = facing
			print("[BATTLE_SETUP] %s facing=%s" % [unit_id, facing])
		else:
			_ignored(battle, "%s facing %s" % [unit_id, str(facing)])
	if override.has("grid_cell"):
		var pending: Array = battle.get_meta(META_PENDING_CELLS, [])
		pending.append({"unit": target, "key": unit_id, "cell": override.get("grid_cell")})
		battle.set_meta(META_PENDING_CELLS, pending)


## After every unit override: the top-level keys, the start cells, then the arrival rounds.
static func finish(battle: Node, setup: Dictionary) -> void:
	if setup.has("battle_type"):
		var wanted: Variant = setup.get("battle_type")
		if typeof(wanted) == TYPE_STRING and BATTLE_TYPES.has(wanted):
			battle.set_meta(META_BATTLE_TYPE, wanted)
			print("[BATTLE_SETUP] battle_type=%s" % wanted)
		else:
			_ignored(battle, "battle_type %s" % str(wanted))
	var moved := false
	if battle.has_meta(META_PENDING_CELLS):
		var pending: Array = battle.get_meta(META_PENDING_CELLS)
		battle.remove_meta(META_PENDING_CELLS)
		moved = _place_cells(battle, pending, setup.get("blocked_cells", []))
	var deployed := false
	if setup.has("arrival_round_overrides"):
		var rounds: Variant = setup.get("arrival_round_overrides")
		if rounds is Dictionary:
			for key in (rounds as Dictionary).keys():
				if _apply_arrival(battle, str(key), (rounds as Dictionary)[key]):
					deployed = true
		else:
			_ignored(battle, "arrival_round_overrides is not a Dictionary")
	if moved or deployed:
		battle.call("_reset_unit_group_positions")
		battle.call("_update_all_unit_visuals_from_state")


static func _apply_hero(battle: Node, target: BattleUnitState, hero_id: String) -> void:
	# The worldmap context's own path: a registry entry (name, portrait), the slot's hero, then the unit id whose
	# setter rebuilds the hero's stats and unique skill, then the identity (name, portrait badge).
	var slot_id := String(battle.call("_get_capacity_slot_id_for_unit_state", target))
	var hero_data: Dictionary = HeroRuntimeFactoryScript.build_runtime_hero(HeroDefinitionRegistryScript.HERO_DATA[hero_id], HeroDefinitionRegistryScript.HERO_DATA[hero_id])
	hero_data["hero_id"] = hero_id
	for key in ["troops", "troop_count", "max_troops", "allocated_troops", "initial_allocated_troops"]:
		hero_data.erase(key) # the unit keeps its troops; `troops` is its own key
	if not _has_portrait(hero_data):
		for country in PORTRAIT_COUNTRIES:
			if ResourceLoader.exists(PORTRAIT_PATH % [country, country, hero_id]):
				hero_data["portrait_path"] = PORTRAIT_PATH % [country, country, hero_id]
				break
	var registry: Dictionary = battle.get("worldmap_context_hero_registry")
	registry[hero_id] = battle.call("_build_worldmap_context_hero_registry_entry", hero_data)
	if not slot_id.is_empty():
		battle.call("_set_capacity_slot_metadata_value", slot_id, "assigned_hero_id", hero_id)
		battle.call("_set_capacity_slot_metadata_value", slot_id, "assigned_unit_id", "%s_battle_unit" % hero_id)
	target.unit_id = "%s_battle_unit" % hero_id
	battle.call("_apply_hero_identity_to_unit", target)


static func _has_portrait(hero_data: Dictionary) -> bool:
	for key in ["portrait_path", "battlefield_portrait_path", "closeup_portrait_path"]:
		var path := String(hero_data.get(key, ""))
		if not path.is_empty() and ResourceLoader.exists(path):
			return true
	return false


static func _apply_unit_type(target: BattleUnitState, unit_type: String) -> void:
	# battle_unit_state.gd setup(): the type, then the values it derives from the type's rule.
	target.unit_type = unit_type
	target.move_range = UnitTypeContractScript.get_move_range(unit_type)
	target.attack_range = UnitTypeContractScript.get_maximum_attack_range(unit_type)
	var visual := UnitTypeContractScript.get_visual_metadata(unit_type, target.nation)
	target.move_fx_profile = String(visual.get("move_fx_profile", target.move_fx_profile))
	target.attack_fx_profile = String(visual.get("attack_fx_profile", target.attack_fx_profile))
	var domain := String(UnitTypeContractScript.get_rule(unit_type).get("domain", ""))
	if not domain.is_empty():
		target.domain = domain


static func _to_cell(value: Variant) -> Variant:
	if value is Vector2i:
		return value
	if value is Array and (value as Array).size() == 2:
		for part in value:
			if (typeof(part) != TYPE_INT and typeof(part) != TYPE_FLOAT) or float(part) != float(int(part)):
				return null
		return Vector2i(int(value[0]), int(value[1]))
	return null


static func _place_cells(battle: Node, pending: Array, blocked_variant: Variant) -> bool:
	var grid: Object = battle.get("battle_grid_controller")
	var blocked := {}
	if blocked_variant is Array:
		for raw in blocked_variant:
			var blocked_cell: Variant = _to_cell(raw)
			if blocked_cell != null:
				blocked[blocked_cell] = true
	# A unit's wanted cell is refused when it is off the board, blocked, wanted by an earlier unit, or held by a
	# unit that stays where it is. Refusing one can free or take a cell, so repeat until nothing changes.
	var requests: Array = []
	for entry in pending:
		var cell: Variant = _to_cell(entry.cell)
		if cell == null or not grid.is_in_bounds(cell):
			_ignored(battle, "%s grid_cell %s is off the board" % [entry.key, str(entry.cell)])
		elif grid.is_blocked(cell) or blocked.has(cell):
			_ignored(battle, "%s grid_cell %s is blocked" % [entry.key, str(entry.cell)])
		else:
			requests.append({"unit": entry.unit, "key": entry.key, "cell": cell})
	var changed := true
	while changed:
		changed = false
		var taken := {}
		for unit in battle.get("all_battle_unit_states"):
			if unit != null and unit.is_alive() and not requests.any(func(r): return r.unit == unit):
				taken[unit.grid_cell] = true
		for request in requests:
			if taken.has(request.cell):
				_ignored(battle, "%s grid_cell %s is taken" % [request.key, str(request.cell)])
				requests.erase(request)
				changed = true
				break
			taken[request.cell] = true
	for request in requests:
		var unit: BattleUnitState = request.unit
		unit.set_grid_cell(request.cell)
		battle.call("_sync_resumed_unit_markers_to_grid", unit)
		print("[BATTLE_SETUP] %s grid_cell=%s" % [request.key, str(request.cell)])
	return not requests.is_empty()


static func _apply_arrival(battle: Node, key: String, round_value: Variant) -> bool:
	var slot_id := key
	if not REINFORCE_SLOTS.has(slot_id):
		slot_id = ""
		for unit in battle.get("all_battle_unit_states"):
			if unit != null and unit.unit_id == key:
				slot_id = String(battle.call("_get_capacity_slot_id_for_unit_state", unit))
	if not REINFORCE_SLOTS.has(slot_id):
		_ignored(battle, "arrival_round_overrides %s is not a reinforcement slot" % key)
		return false
	if typeof(round_value) != TYPE_INT and typeof(round_value) != TYPE_FLOAT or float(round_value) != float(int(round_value)) or int(round_value) < 0:
		_ignored(battle, "arrival_round_overrides %s round %s" % [key, str(round_value)])
		return false
	var arrival_round := int(round_value)
	if arrival_round == 0:
		# On the board from the start: the engine's own deploy (the later round checks then find it deployed).
		var unit: BattleUnitState = battle.call("_get_unit_state_for_capacity_slot_id", slot_id)
		if unit == null or not bool(battle.call("_deploy_reinforce_unit", unit)):
			_ignored(battle, "arrival_round_overrides %s could not deploy" % key)
			return false
		print("[BATTLE_SETUP] %s arrival_round=0 deployed cell=%s" % [slot_id, str(unit.grid_cell)])
		return true
	if not CITY_REINFORCE_SLOTS.has(slot_id):
		_ignored(battle, "arrival_round_overrides %s round %d (this slot's round is fixed; only 0 is accepted)" % [key, arrival_round])
		return false
	battle.call("_set_capacity_slot_metadata_value", slot_id, "arrival_round", arrival_round)
	print("[BATTLE_SETUP] %s arrival_round=%d" % [slot_id, arrival_round])
	return false


static func _ignored(battle: Node, reason: String) -> void:
	battle.call("_log_battle_setup_ignored", reason) # the engine's own "[BATTLE_SETUP] ignored: ..." line
