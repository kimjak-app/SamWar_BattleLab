extends Node

## Test-scene-only legacy roster content bridge.
##
## This node mirrors the existing Battle_Land formation-guide information contract
## into ProductionHudRoot without changing the shared battle controller, adapter,
## gameplay state, or runtime scene.

const SLOT_NAMES := ["Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"]


func _ready() -> void:
	call_deferred("_refresh")


func _process(_delta: float) -> void:
	_refresh()


func _refresh() -> void:
	var controller := get_parent()
	if controller == null or not controller.has_method("_get_all_unit_states_in_slot_order"):
		return
	var allies: Array = []
	var enemies: Array = []
	for unit in controller.call("_get_all_unit_states_in_slot_order"):
		if str(unit.side) == "ally":
			allies.append(unit)
		else:
			enemies.append(unit)
	_sync_side(controller, "Ally", allies)
	_sync_side(controller, "Enemy", enemies)


func _sync_side(controller: Node, side_name: String, roster: Array) -> void:
	for index in SLOT_NAMES.size():
		var slot := controller.get_node_or_null("BattleUI/ProductionHudRoot/%sRosterHud/%s" % [side_name, SLOT_NAMES[index]]) as Control
		if slot == null:
			continue
		_set_hidden(slot, "TroopBar")
		_set_hidden(slot, "ActionStateLabel")
		_set_hidden(slot, "UniqueSkillReadyLabel")
		_set_hidden(slot, "UnitTypeLabel")
		_set_hidden(slot, "TroopsLabel")
		var unit: Variant = roster[index] if index < roster.size() else null
		_sync_slot(controller, slot, unit)


func _sync_slot(controller: Node, slot: Control, unit: Variant) -> void:
	var portrait := slot.get_node_or_null("Portrait") as TextureRect
	var name_label := slot.get_node_or_null("NameLabel") as Label
	var hp_label := slot.get_node_or_null("HpLabel") as Label
	var status_label := slot.get_node_or_null("StatusLabel") as Label
	var troop_icon := slot.get_node_or_null("TroopIconRect") as TextureRect
	var troop_type_label := slot.get_node_or_null("TroopTypeLabel") as Label
	var ready_icon := slot.get_node_or_null("UniqueSkillReadyIcon") as TextureRect
	if unit == null:
		if hp_label != null:
			hp_label.text = "병력 -"
		if status_label != null:
			status_label.text = ""
			status_label.visible = false
		if ready_icon != null:
			ready_icon.visible = false
		return
	if name_label != null:
		name_label.text = str(unit.display_name)
	if hp_label != null:
		hp_label.text = "병력 %d / %d" % [int(unit.current_troops), int(unit.max_troops)]
	if portrait != null:
		portrait.texture = controller.call("_get_closeup_portrait_texture_for_unit", unit)
	if troop_icon != null:
		troop_icon.texture = controller.call("_get_troop_icon_texture_for_visual_key", "", unit)
		troop_icon.visible = troop_icon.texture != null
	if troop_type_label != null:
		troop_type_label.text = _unit_type_name(str(unit.unit_type))
	if status_label != null:
		var status_text := str(controller.call("_get_formation_status_summary_text", unit))
		status_label.text = status_text
		status_label.visible = status_text != ""
	if ready_icon != null:
		ready_icon.visible = bool(controller.call("_is_unique_skill_ready_for_formation_guide", unit))


func _set_hidden(slot: Control, node_name: String) -> void:
	var node := slot.get_node_or_null(node_name) as Control
	if node != null:
		node.visible = false


func _unit_type_name(unit_type: String) -> String:
	match unit_type:
		"infantry": return "보병"
		"cavalry": return "기병"
		"archer": return "궁병"
		"gunner": return "총병"
		"mounted_archer": return "기마궁병"
	return "부대"
