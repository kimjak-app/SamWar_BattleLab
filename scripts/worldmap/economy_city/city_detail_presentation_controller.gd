class_name WorldMapCityDetailPresentationController
extends Node


signal attack_requested(city_id: String)
signal governor_assignment_requested(city_id: String, governor_id: String)
signal hero_transfer_confirmed(source_city_id: String, hero_id: String, target_city_id: String)
signal recruitment_requested(city_id: String, amount: int)

const TAB_RESOURCES := "resources"
const TAB_INTERNAL_TRADE := "internal-trade"
const TAB_EXTERNAL_TRADE := "external-trade"

var _nodes := {}


func set_ui_nodes(nodes: Dictionary) -> void:
	_nodes = nodes.duplicate()


func relay_attack_requested(city_id: String) -> void:
	attack_requested.emit(city_id)


func relay_governor_assignment_requested(city_id: String, governor_id: String) -> void:
	governor_assignment_requested.emit(city_id, governor_id)


func relay_hero_transfer_confirmed(source_city_id: String, hero_id: String, target_city_id: String) -> void:
	hero_transfer_confirmed.emit(source_city_id, hero_id, target_city_id)


func relay_recruitment_requested(city_id: String, amount: int) -> void:
	recruitment_requested.emit(city_id, amount)


func refresh_tab_styles(primary_tab: String, selected_tab: String, diplomacy_tab_id: String, trade_tab_id: String) -> String:
	if primary_tab == diplomacy_tab_id:
		return "refresh_chrome"
	if primary_tab == trade_tab_id:
		set_tab_active(_button("internal_trade_tab"), selected_tab == TAB_INTERNAL_TRADE)
		set_tab_active(_button("external_trade_tab"), selected_tab == TAB_EXTERNAL_TRADE)
		return "trade"
	set_tab_active(_button("resource_tab"), selected_tab == TAB_RESOURCES)
	return "resources"


func set_tab_active(button: Button, is_active: bool) -> void:
	if button == null:
		return
	button.modulate = Color(1.0, 0.9, 0.68, 1.0) if is_active else Color(0.82, 0.86, 0.92, 1.0)


func apply_resource_tab(model: Dictionary) -> void:
	set_body_labels_visible(true, false)
	set_resource_cards_enabled(true)
	var type_label := _label("type")
	var region_label := _label("region_owner")
	var resource_label := _label("resource")
	var security_label := _label("security")
	var military_label := _label("military")
	var commerce_label := _label("commerce")
	var rating_label := _label("rating")
	var status_label := _label("status")
	var hint_label := _label("hint")
	if type_label != null:
		type_label.text = "자원 잠재력\n식량 자원"
		type_label.add_theme_color_override("font_color", Color(0.96, 0.74, 0.34, 1.0))
	if region_label != null:
		region_label.text = str(model.get("food_resources", "미확인"))
		region_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	if resource_label != null:
		resource_label.text = "전략 자원"
		resource_label.add_theme_color_override("font_color", Color(0.62, 0.76, 0.88, 1.0))
	if security_label != null:
		security_label.text = str(model.get("strategy_resources", "미확인"))
		security_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	if military_label != null:
		military_label.text = "특산 자원"
		military_label.add_theme_color_override("font_color", Color(0.78, 0.56, 0.88, 1.0))
	if commerce_label != null:
		commerce_label.text = str(model.get("special_resources", "미확인"))
		commerce_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1.0))
	if rating_label != null:
		rating_label.text = "경제 잠재력\n인구 %s / 상업력 %s" % [str(model.get("population_rating", "-")), str(model.get("commerce_rating", "-"))]
		for raw_lines in [model.get("economy_bonus_lines", []), model.get("military_bonus_lines", []), model.get("naval_bonus_lines", []), model.get("spy_bonus_lines", [])]:
			if raw_lines is Array and not (raw_lines as Array).is_empty():
				rating_label.text += "\n%s" % "\n".join(raw_lines)
		rating_label.add_theme_color_override("font_color", Color(0.95, 0.92, 0.82, 1.0))
	if status_label != null:
		status_label.visible = true
		status_label.text = str(model.get("storage_summary", ""))
		var economy_modifier := str(model.get("economy_modifier_summary", ""))
		if not economy_modifier.is_empty():
			status_label.text += "\n%s" % economy_modifier
		status_label.add_theme_color_override("font_color", Color(0.86, 0.92, 0.88, 1.0))
	if hint_label != null:
		hint_label.text = "자원 잠재력은 생산 기반, 성 창고는 현재 보유량입니다."
	var domestic_button := _button("domestic_button")
	if domestic_button != null:
		domestic_button.visible = false


func set_resource_cards_enabled(is_enabled: bool) -> void:
	for key in ["resource_card", "storage_card"]:
		var card := _nodes.get(key) as PanelContainer
		if card != null:
			card.add_theme_stylebox_override("panel", make_resource_card_style(is_enabled))


func make_resource_card_style(is_enabled: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if is_enabled:
		style.bg_color = Color(0.08, 0.075, 0.055, 0.74)
		style.border_color = Color(0.70, 0.54, 0.26, 0.88)
		style.set_border_width_all(1)
		style.set_corner_radius_all(5)
		style.content_margin_left = 8.0
		style.content_margin_top = 7.0
		style.content_margin_right = 8.0
		style.content_margin_bottom = 7.0
	else:
		style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		style.border_color = Color(0.0, 0.0, 0.0, 0.0)
		style.set_border_width_all(0)
		style.set_corner_radius_all(0)
	return style


func set_body_labels_visible(should_show: bool, trade_control_active: bool) -> void:
	for key in ["type", "region_owner", "resource", "security", "military", "commerce", "rating", "status", "hint"]:
		var label := _label(key)
		if label != null:
			label.visible = should_show
	for key in ["resource_card", "storage_card"]:
		var card := _nodes.get(key) as PanelContainer
		if card != null:
			card.visible = should_show
	var trade_card := _nodes.get("trade_card") as PanelContainer
	if trade_card != null and not trade_control_active:
		trade_card.visible = false
	var domestic_button := _button("domestic_button")
	if domestic_button != null:
		domestic_button.visible = should_show


func format_city_storage_summary(storage: Dictionary, resource_labels: Dictionary, food_ids: Array, strategy_ids: Array, special_ids: Array) -> String:
	var food_total := _group_total(storage, food_ids)
	var strategy_total := _group_total(storage, strategy_ids)
	var special_total := _group_total(storage, special_ids)
	return "\n".join([
		"성 창고",
		"금전 %d" % _amount(storage, "gold"),
		"식량 %d %s" % [food_total, get_city_storage_status_label(food_total)],
		format_city_storage_group_details(storage, food_ids, resource_labels),
		"전략 %d %s" % [strategy_total, get_city_storage_status_label(strategy_total)],
		format_city_storage_group_details(storage, strategy_ids, resource_labels),
		"특산 %d %s" % [special_total, get_city_storage_status_label(special_total)],
		format_city_storage_group_details(storage, special_ids, resource_labels),
	])


func format_city_storage_group_details(storage: Dictionary, resource_ids: Array, resource_labels: Dictionary) -> String:
	var parts: Array[String] = []
	for raw_resource_id in resource_ids:
		var resource_id := str(raw_resource_id)
		parts.append("%s %d" % [str(resource_labels.get(resource_id, resource_id)), _amount(storage, resource_id)])
	return " / ".join(parts)


func get_city_storage_status_label(total: int) -> String:
	if total >= 300:
		return "안정"
	if total >= 100:
		return "주의"
	return "부족"


func format_recruitment_failure_hint(reason: String) -> String:
	match reason:
		"loyalty", "loyalty_limit":
			return "충성도 부족 · 모병 불가"
		"resources":
			return "자원 부족 · 금전/식량 확인"
		"not_peacetime":
			return "전투/침공 처리 중에는 모병 불가"
		"ownership":
			return "아군 도시에서만 모병 가능"
		"amount":
			return "모병 단위 오류"
		_:
			return "모병 불가"


func show_recruitment_result(message: String) -> void:
	var panel: Object = _nodes.get("city_info_panel") as Object
	if panel != null and panel.has_method("show_recruitment_result"):
		panel.call("show_recruitment_result", message)


func _group_total(storage: Dictionary, resource_ids: Array) -> int:
	var total := 0
	for resource_id in resource_ids:
		total += _amount(storage, str(resource_id))
	return total


func _amount(storage: Dictionary, resource_id: String) -> int:
	return maxi(0, int(storage.get(resource_id, 0)))


func _label(key: String) -> Label:
	return _nodes.get(key) as Label


func _button(key: String) -> Button:
	return _nodes.get(key) as Button
