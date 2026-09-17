class_name WorldMapHudController
extends Node


const HeroPortraitHelper := preload("res://scripts/worldmap_hero_portrait_helper.gd")

var _nodes := {}
var _warehouse_card: PanelContainer = null
var _warehouse_resource_row_labels := {}


func set_ui_nodes(nodes: Dictionary) -> void:
	_nodes = nodes.duplicate()


func setup_world_status_panel(request_position: Callable, top_left: Vector2, panel_size: Vector2) -> void:
	var panel := _control("left_world_status_panel")
	if panel != null:
		panel.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
		if not request_position.is_valid() or not bool(request_position.call(panel, top_left)):
			panel.position = top_left
		panel.size = panel_size
		panel.custom_minimum_size = panel_size
	_lock_world_turn_header_order()
	var eyebrow := _label("eyebrow")
	if eyebrow != null:
		eyebrow.visible = false
		eyebrow.text = ""
	var turn := _label("turn")
	if turn != null:
		turn.visible = false
		turn.text = ""
	var nation := _label("nation")
	if nation != null:
		nation.visible = false
		nation.text = ""
	var calendar := _label("calendar")
	if calendar != null:
		calendar.visible = true
		calendar.add_theme_font_size_override("font_size", 16)
	var tax_bar := _progress_bar("tax_bar")
	if tax_bar != null:
		tax_bar.visible = false
	var security := _label("security")
	if security != null:
		security.visible = false
		security.text = ""
	var security_bar := _progress_bar("security_bar")
	if security_bar != null:
		security_bar.visible = false
	for key in ["power", "tax", "security", "chancellor_stats", "chancellor_policy_description", "resource", "supply", "military_logistics", "external_trade", "world_status_hint"]:
		var label := _label(key)
		if label != null:
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for key in ["resource", "supply", "military_logistics", "external_trade"]:
		var compact_label := _label(key)
		if compact_label != null:
			compact_label.add_theme_font_size_override("font_size", 10)
	_ensure_warehouse_card()


func refresh_world_status(model: Dictionary) -> void:
	_set_label("eyebrow", str(model.get("eyebrow", "")), true)
	_set_label("turn", "", false)
	_set_label("calendar", str(model.get("calendar", "")), true)
	_set_label("nation", str(model.get("nation", "")), true)
	_set_label("power", str(model.get("power", "")), true)
	_set_progress("power_bar", float(model.get("national_loyalty", 0)))
	_set_label("tax", str(model.get("tax", "")), true)
	_set_progress("tax_bar", float(model.get("tax_level", 0)), false)
	var tax_slider := _nodes.get("tax_slider") as HSlider
	if tax_slider != null:
		tax_slider.set_value_no_signal(float(model.get("tax_level", 0)))
	_set_label("security", "", false)
	_set_progress("security_bar", float(model.get("public_order", 0)), false)
	_set_label("chancellor", "재상", true)
	var portrait_texture := _nodes.get("chancellor_portrait_texture") as TextureRect
	var portrait_label := _label("chancellor_portrait")
	HeroPortraitHelper.apply_hero_portrait_or_placeholder(portrait_texture, portrait_label, model.get("chancellor_data", {}))
	_set_label("chancellor_name", str(model.get("chancellor_name", "미임명")), true)
	var chancellor_data: Dictionary = model.get("chancellor_data", {})
	_set_label("chancellor_stats", str(model.get("chancellor_stats", "")), not chancellor_data.is_empty())
	_set_label("chancellor_policy_description", str(model.get("chancellor_policy_description", "")), true)
	_select_option_by_metadata(_nodes.get("chancellor_assignment") as OptionButton, str(model.get("chancellor_id", "")))
	_select_option_by_metadata(_nodes.get("chancellor_policy") as OptionButton, str(model.get("policy_id", "balanced")))
	var national_bonus_lines: Array = model.get("national_bonus_lines", [])
	_set_label("resource", "\n".join(national_bonus_lines), not national_bonus_lines.is_empty())
	_set_label("supply", "", false)
	_set_label("military_logistics", "", false)
	var external_trade_text := str(model.get("external_trade", ""))
	_set_label("external_trade", external_trade_text, not external_trade_text.is_empty())
	var hint := str(model.get("world_status_hint", ""))
	_set_label("world_status_hint", hint, not hint.is_empty())
	var turn_end_button := _button("turn_end")
	if turn_end_button != null:
		turn_end_button.text = "아군 턴 종료"
		turn_end_button.disabled = bool(model.get("turn_end_disabled", false))
	_set_button_text("save", "저장")
	_set_button_text("load", "불러오기")
	_set_button_text("reset", "초기화")
	_set_label("save_management_title", "저장 관리", true)
	var save_status := str(model.get("save_status", ""))
	_set_label("save_management_status", save_status, not save_status.is_empty())
	refresh_warehouse(model.get("warehouse_rows", []))


func refresh_selected_city_binding(model: Dictionary) -> void:
	var panel: Object = _nodes.get("city_info_panel") as Object
	if panel == null:
		return
	if panel.has_method("set_player_faction_id"):
		panel.call("set_player_faction_id", str(model.get("player_faction_id", "")))
	if panel.has_method("set_enemy_city_intel"):
		panel.call("set_enemy_city_intel", model.get("enemy_city_intel", {}))
	if panel.has_method("set_hud_data"):
		panel.call("set_hud_data", model.get("hero_data", {}), model.get("city_data", {}), model.get("governor_policy_data", {}), model.get("city_policy_state", {}))
	if panel.has_method("set_recruitment_summaries"):
		panel.call("set_recruitment_summaries", model.get("recruitment_summaries", {}))
	if panel.has_method("set_revolt_risk_summaries"):
		panel.call("set_revolt_risk_summaries", model.get("revolt_risk_summaries", {}))


func set_hud_visible(visible: bool) -> void:
	for key in ["left_world_status_panel", "city_info_panel"]:
		var control := _control(key)
		if control != null:
			control.visible = visible


func set_hud_enabled(enabled: bool) -> void:
	for key in ["turn_end", "save", "load", "reset"]:
		var button := _button(key)
		if button != null:
			button.disabled = not enabled


func refresh_warehouse(rows: Array) -> void:
	if _warehouse_card == null:
		return
	_warehouse_card.visible = true
	for row_model in rows:
		if not row_model is Dictionary:
			continue
		var resource_id := str(row_model.get("resource_id", ""))
		var row_labels: Dictionary = _warehouse_resource_row_labels.get(resource_id, {})
		var amount_label := row_labels.get("amount") as Label
		var status_label := row_labels.get("status") as Label
		if amount_label != null:
			amount_label.text = str(row_model.get("amount", ""))
		if status_label != null:
			status_label.text = str(row_model.get("status", ""))
			status_label.add_theme_color_override("font_color", row_model.get("status_color", Color.WHITE))


func _ensure_warehouse_card() -> void:
	if _warehouse_card != null:
		return
	var supply_label := _label("supply")
	if supply_label == null or supply_label.get_parent() == null:
		return
	var parent := supply_label.get_parent()
	_warehouse_card = PanelContainer.new()
	_warehouse_card.name = "WarehouseCard"
	_warehouse_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.08, 0.12, 0.86)
	panel_style.border_color = Color(0.85, 0.66, 0.32, 0.58)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 8.0
	panel_style.content_margin_top = 7.0
	panel_style.content_margin_right = 8.0
	panel_style.content_margin_bottom = 7.0
	_warehouse_card.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(_warehouse_card)
	parent.move_child(_warehouse_card, supply_label.get_index())
	var content := VBoxContainer.new()
	content.name = "WarehouseCardContent"
	content.add_theme_constant_override("separation", 4)
	_warehouse_card.add_child(content)
	var title_label := Label.new()
	title_label.name = "WarehouseTitleLabel"
	title_label.text = "국가 창고"
	title_label.add_theme_color_override("font_color", Color(0.98, 0.82, 0.46, 1.0))
	title_label.add_theme_font_size_override("font_size", 12)
	content.add_child(title_label)
	var resource_order: Array = _nodes.get("resource_order", [])
	var resource_labels: Dictionary = _nodes.get("resource_labels", {})
	for resource_id_value in resource_order:
		var resource_id := str(resource_id_value)
		var row := HBoxContainer.new()
		row.name = "WarehouseRow_%s" % resource_id
		row.add_theme_constant_override("separation", 6)
		content.add_child(row)
		var name_label := Label.new()
		name_label.text = str(resource_labels.get(resource_id, resource_id))
		name_label.custom_minimum_size.x = 52.0
		name_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.92, 1.0))
		name_label.add_theme_font_size_override("font_size", 10)
		row.add_child(name_label)
		var amount_label := Label.new()
		amount_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amount_label.add_theme_color_override("font_color", Color(0.90, 0.91, 0.86, 1.0))
		amount_label.add_theme_font_size_override("font_size", 10)
		row.add_child(amount_label)
		var status_label := Label.new()
		status_label.custom_minimum_size.x = 38.0
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		status_label.add_theme_font_size_override("font_size", 10)
		row.add_child(status_label)
		_warehouse_resource_row_labels[resource_id] = {"amount": amount_label, "status": status_label}
	supply_label.visible = false
	supply_label.text = ""


func _lock_world_turn_header_order() -> void:
	var eyebrow := _label("eyebrow")
	if eyebrow == null:
		return
	var content := eyebrow.get_parent() as VBoxContainer
	if content == null:
		return
	var ordered_nodes: Array[Node] = [eyebrow, _label("turn"), _label("calendar"), _label("nation")]
	var separator := content.get_node_or_null("WorldTurnSeparator") as HSeparator
	if separator != null:
		ordered_nodes.append(separator)
	for node_index in range(ordered_nodes.size()):
		var child := ordered_nodes[node_index]
		if child != null and child.get_parent() == content:
			content.move_child(child, node_index)


func _select_option_by_metadata(option_button: OptionButton, metadata_value: String) -> void:
	if option_button == null:
		return
	for index in range(option_button.item_count):
		if str(option_button.get_item_metadata(index)) == metadata_value:
			option_button.select(index)
			return


func _set_label(key: String, text: String, visible: bool) -> void:
	var label := _label(key)
	if label != null:
		label.text = text
		label.visible = visible


func _set_progress(key: String, value: float, visible: bool = true) -> void:
	var bar := _progress_bar(key)
	if bar != null:
		bar.value = value
		bar.visible = visible


func _set_button_text(key: String, text: String) -> void:
	var button := _button(key)
	if button != null:
		button.text = text


func _label(key: String) -> Label:
	return _nodes.get(key) as Label


func _button(key: String) -> Button:
	return _nodes.get(key) as Button


func _control(key: String) -> Control:
	return _nodes.get(key) as Control


func _progress_bar(key: String) -> ProgressBar:
	return _nodes.get(key) as ProgressBar
