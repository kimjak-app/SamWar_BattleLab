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


func to_visual_slots_dictionary() -> Dictionary:
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


func to_dictionary() -> Dictionary:
	return to_visual_slots_dictionary()


func get_value(key: StringName) -> Variant:
	return to_visual_slots_dictionary().get(key)


func get_visual_group_nodes() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = []
	if shadow != null:
		nodes.append(shadow)
	if token != null:
		nodes.append(token)
	if move_dust != null:
		nodes.append(move_dust)
	if portrait != null:
		nodes.append(portrait)
	if hp_bar != null:
		nodes.append(hp_bar)
	if troop_label != null:
		nodes.append(troop_label)
	return nodes


func get_click_area() -> Area2D:
	return click_area


func get_click_shape() -> CollisionShape2D:
	return click_shape


func get_ready_frame() -> Control:
	return ready_frame


func get_facing_indicator() -> Label:
	return facing_indicator as Label


func set_visual_group_visible(should_show: bool) -> void:
	for node in get_visual_group_nodes():
		if node != null:
			node.visible = should_show


func set_click_area_enabled(should_enable: bool) -> void:
	if click_area == null:
		return
	click_area.monitoring = should_enable
	click_area.monitorable = should_enable
	click_area.input_pickable = should_enable


func set_facing_indicator_visible(should_show: bool) -> void:
	var indicator := get_facing_indicator()
	if indicator != null:
		indicator.visible = should_show


func has_click_nodes() -> bool:
	return click_area != null and click_shape != null


func has_ui_overlay_nodes() -> bool:
	return ready_frame != null or facing_indicator != null


func has_required_visual_nodes() -> bool:
	return (
		root != null
		and token != null
		and portrait != null
		and hp_bar != null
		and troop_label != null
		and click_area != null
	)


func get_debug_summary() -> Dictionary:
	return {
		"slot_id": slot_id,
		"root": root != null,
		"token": token != null,
		"hp_bar": hp_bar != null,
		"troop_label": troop_label != null,
		"portrait": portrait != null,
		"move_dust": move_dust != null,
		"click_area": click_area != null,
		"click_shape": click_shape != null,
		"ready_frame": ready_frame != null,
		"facing_indicator": facing_indicator != null,
	}


func has_root_visual() -> bool:
	return root != null and token != null
