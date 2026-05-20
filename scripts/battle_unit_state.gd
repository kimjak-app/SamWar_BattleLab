class_name BattleUnitState
extends RefCounted

var unit_id: String = ""
var display_name: String = ""
var side: String = ""
var slot_id: String = ""
var hero_name: String = ""
var nation: String = ""
var unit_type: String = "infantry"
var visual_key: String = ""
var portrait_key: String = ""
var domain: String = "land"
var footprint: String = "1x1"
var move_fx_profile: String = "dust"
var attack_fx_profile: String = "slash"
var click_area_profile: String = "standard_1x1"
var visual_scale_profile: String = "standard_256"
var current_hp: int = 0
var max_hp: int = 0
var current_troops: int = 0
var max_troops: int = 0
var attack: int = 0
var defense: int = 0
var move_range: int = 0
var attack_range: int = 0
var grid_cell: Vector2i = Vector2i.ZERO
var facing: String = "right"
var has_acted: bool = false
var has_moved: bool = false


func setup(data: Dictionary) -> void:
	unit_id = String(data.get("unit_id", ""))
	display_name = String(data.get("display_name", ""))
	side = String(data.get("side", ""))
	slot_id = String(data.get("slot_id", ""))
	hero_name = String(data.get("hero_name", display_name))
	nation = String(data.get("nation", ""))
	unit_type = String(data.get("unit_type", "infantry"))
	visual_key = String(data.get("visual_key", unit_type))
	portrait_key = String(data.get("portrait_key", hero_name))
	domain = String(data.get("domain", "land"))
	footprint = String(data.get("footprint", "1x1"))
	move_fx_profile = String(data.get("move_fx_profile", "dust"))
	attack_fx_profile = String(data.get("attack_fx_profile", "slash"))
	click_area_profile = String(data.get("click_area_profile", "standard_1x1"))
	visual_scale_profile = String(data.get("visual_scale_profile", "standard_256"))
	current_hp = int(data.get("current_hp", 0))
	max_hp = int(data.get("max_hp", current_hp))
	current_troops = int(data.get("current_troops", current_hp))
	max_troops = int(data.get("max_troops", max_hp))
	attack = int(data.get("attack", 0))
	defense = int(data.get("defense", 0))
	move_range = int(data.get("move_range", 0))
	attack_range = int(data.get("attack_range", 0))
	grid_cell = data.get("grid_cell", Vector2i.ZERO)
	facing = String(data.get("facing", "right"))
	has_acted = bool(data.get("has_acted", false))
	has_moved = bool(data.get("has_moved", false))


static func create(data: Dictionary) -> BattleUnitState:
	var state := BattleUnitState.new()
	state.setup(data)
	return state


func is_alive() -> bool:
	return current_hp > 0 and current_troops > 0


func apply_damage(amount: int) -> int:
	var damage: int = maxi(0, amount)
	var applied: int = mini(damage, current_hp)
	current_hp = maxi(0, current_hp - damage)
	current_troops = maxi(0, current_troops - damage)
	return applied


func heal(amount: int) -> int:
	var healing: int = maxi(0, amount)
	var previous_hp: int = current_hp
	current_hp = mini(max_hp, current_hp + healing)
	current_troops = mini(max_troops, current_troops + healing)
	return current_hp - previous_hp


func reset_action_flags() -> void:
	has_acted = false
	has_moved = false


func set_grid_cell(cell: Vector2i) -> void:
	grid_cell = cell


func get_troop_label_text() -> String:
	return "%d / %d" % [current_troops, current_troops]
