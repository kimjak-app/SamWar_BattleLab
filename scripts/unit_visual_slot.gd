class_name UnitVisualSlot
extends RefCounted

var slot_id: String = ""
var root: Node2D = null
var token: Sprite2D = null
var shadow: CanvasItem = null
var portrait: CanvasItem = null
var hp_bar: Range = null
var troop_label: Label = null
var move_dust: CanvasItem = null
var click_area: Area2D = null
var click_shape: CollisionShape2D = null
var ready_frame: Control = null
var facing_indicator: Control = null


static func create_from_dictionary(target_slot_id: String, slot_visuals: Dictionary) -> UnitVisualSlot:
	var slot := UnitVisualSlot.new()
	slot.slot_id = target_slot_id
	slot.root = slot_visuals.get("root") as Node2D
	slot.token = slot_visuals.get("token") as Sprite2D
	slot.shadow = slot_visuals.get("shadow") as CanvasItem
	slot.portrait = slot_visuals.get("portrait") as CanvasItem
	slot.hp_bar = slot_visuals.get("hp_bar") as Range
	slot.troop_label = slot_visuals.get("troop_label") as Label
	slot.move_dust = slot_visuals.get("move_dust") as CanvasItem
	slot.click_area = slot_visuals.get("click_area") as Area2D
	slot.click_shape = slot_visuals.get("click_shape") as CollisionShape2D
	slot.ready_frame = slot_visuals.get("ready_frame") as Control
	slot.facing_indicator = slot_visuals.get("facing_indicator") as Control
	return slot


func to_dictionary() -> Dictionary:
	return {
		"root": root,
		"token": token,
		"shadow": shadow,
		"portrait": portrait,
		"hp_bar": hp_bar,
		"troop_label": troop_label,
		"move_dust": move_dust,
		"click_area": click_area,
		"click_shape": click_shape,
		"ready_frame": ready_frame,
		"facing_indicator": facing_indicator,
	}


func get_value(key: StringName) -> Variant:
	return to_dictionary().get(key)


func has_root_visual() -> bool:
	return root != null and token != null
