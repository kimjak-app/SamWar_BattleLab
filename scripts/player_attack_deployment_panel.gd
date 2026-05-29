class_name PlayerAttackDeploymentPanel
extends PanelContainer

signal deployment_confirmed(deployment: Dictionary)
signal deployment_cancelled()

const SUPPLY_FOOD_KEY := "rice"
const SUPPLY_GOLD_KEY := "gold"
const SUPPLY_SALT_KEY := "salt"
const SUPPLY_GOLD_RATE := 0.2
const SUPPLY_SALT_RATE := 0.1

var _payload: Dictionary = {}
var _hero_controls: Dictionary = {}

var _title_label: Label
var _city_label: Label
var _troop_label: Label
var _resource_label: Label
var _hero_list: VBoxContainer
var _supply_label: Label
var _warning_label: Label
var _confirm_button: Button
var _cancel_button: Button


func _ready() -> void:
	visible = false
	custom_minimum_size = Vector2(440.0, 540.0)
	position = Vector2(430.0, 150.0)
	z_index = 320
	_build_layout()


func open(payload: Dictionary) -> void:
	_payload = payload.duplicate(true)
	visible = true
	_populate()
	_refresh_state()


func close() -> void:
	visible = false
	_payload = {}
	_hero_controls.clear()


func _build_layout() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	_title_label = Label.new()
	_title_label.text = "출정 준비"
	_title_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_title_label)

	_city_label = Label.new()
	_city_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_city_label)

	_troop_label = Label.new()
	content.add_child(_troop_label)

	_resource_label = Label.new()
	_resource_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_resource_label)

	var hero_title := Label.new()
	hero_title.text = "출전 장수"
	hero_title.add_theme_font_size_override("font_size", 14)
	content.add_child(hero_title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(410.0, 250.0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	_hero_list = VBoxContainer.new()
	_hero_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_hero_list)

	_supply_label = Label.new()
	_supply_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_supply_label)

	_warning_label = Label.new()
	_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_warning_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.42, 1.0))
	content.add_child(_warning_label)

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	content.add_child(button_row)

	_confirm_button = Button.new()
	_confirm_button.text = "출정"
	_confirm_button.pressed.connect(_on_confirm_pressed)
	button_row.add_child(_confirm_button)

	_cancel_button = Button.new()
	_cancel_button.text = "취소"
	_cancel_button.pressed.connect(_on_cancel_pressed)
	button_row.add_child(_cancel_button)


func _populate() -> void:
	for child in _hero_list.get_children():
		child.queue_free()
	_hero_controls.clear()

	_city_label.text = "%s → %s" % [
		str(_payload.get("source_city_name", "출발 도시")),
		str(_payload.get("target_city_name", "대상 도시")),
	]
	_troop_label.text = "출발 도시 병력: %d · 최대 출정: %d" % [
		int(_payload.get("source_troops", 0)),
		int(_payload.get("max_deployable_troops", 0)),
	]
	_resource_label.text = "보유: 식량 %d / 금 %d / 소금 %d" % [
		int(_payload.get("food_available", 0)),
		int(_payload.get("gold_available", 0)),
		int(_payload.get("salt_available", 0)),
	]

	var heroes: Array = _payload.get("heroes", [])
	for index in range(heroes.size()):
		var hero: Dictionary = heroes[index]
		_add_hero_row(hero, index == 0)


func _add_hero_row(hero: Dictionary, default_selected: bool) -> void:
	var hero_id := str(hero.get("hero_id", ""))
	if hero_id.is_empty():
		return
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_hero_list.add_child(row)

	var check := CheckBox.new()
	check.button_pressed = default_selected
	check.toggled.connect(_on_selection_changed.bind(hero_id))
	row.add_child(check)

	var name_label := Label.new()
	name_label.custom_minimum_size.x = 168.0
	name_label.text = "%s%s" % [
		str(hero.get("display_name", hero_id)),
		str(hero.get("state_badge", "")),
	]
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(name_label)

	var stat_label := Label.new()
	stat_label.custom_minimum_size.x = 110.0
	stat_label.text = "무 %d / 지 %d / 통 %d" % [
		int(hero.get("war", 0)),
		int(hero.get("intelligence", 0)),
		int(hero.get("leadership", hero.get("command", 0))),
	]
	stat_label.clip_text = true
	stat_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(stat_label)

	var spin := SpinBox.new()
	spin.min_value = 0.0
	spin.max_value = float(maxi(0, int(_payload.get("max_deployable_troops", 0))))
	spin.step = 10.0
	spin.custom_minimum_size.x = 86.0
	spin.value = 1.0 if default_selected else 0.0
	spin.editable = default_selected
	spin.value_changed.connect(_on_troop_value_changed.bind(hero_id))
	row.add_child(spin)

	_hero_controls[hero_id] = {
		"check": check,
		"spin": spin,
	}


func _on_selection_changed(selected: bool, hero_id: String) -> void:
	var controls: Dictionary = _hero_controls.get(hero_id, {})
	var spin := controls.get("spin", null) as SpinBox
	if spin != null:
		spin.editable = selected
		if selected and int(spin.value) <= 0:
			spin.value = 1.0
		elif not selected:
			spin.value = 0.0
	_refresh_state()


func _on_troop_value_changed(_value: float, _hero_id: String) -> void:
	_refresh_state()


func _refresh_state() -> void:
	var deployment := _collect_deployment()
	var selected_count := (deployment.get("selected_hero_ids", []) as Array).size()
	var total_troops := int(deployment.get("total_assigned_troops", 0))
	var max_deployable := int(_payload.get("max_deployable_troops", 0))
	var cost := _calculate_supply_cost(total_troops)
	var warnings: Array[String] = []
	if selected_count <= 0:
		warnings.append("장수를 1명 이상 선택하십시오.")
	if total_troops <= 0:
		warnings.append("출정 병력을 배정하십시오.")
	if total_troops > max_deployable:
		warnings.append("출정 병력이 최대 출정 가능 병력을 초과했습니다.")
	if not _can_pay_supply_cost(cost):
		warnings.append("식량/금/소금이 부족합니다.")
	_supply_label.text = "필요 보급: 식량 %d / 금 %d / 소금 %d · 배정 병력 %d" % [
		int(cost.get("food", 0)),
		int(cost.get("gold", 0)),
		int(cost.get("salt", 0)),
		total_troops,
	]
	_warning_label.text = " · ".join(warnings)
	_confirm_button.disabled = not warnings.is_empty()


func _collect_deployment() -> Dictionary:
	var selected_hero_ids: Array[String] = []
	var troop_allocation := {}
	var total_troops := 0
	for hero_id_variant in _hero_controls.keys():
		var hero_id := str(hero_id_variant)
		var controls: Dictionary = _hero_controls.get(hero_id, {})
		var check := controls.get("check", null) as CheckBox
		var spin := controls.get("spin", null) as SpinBox
		if check == null or spin == null or not check.button_pressed:
			continue
		var troops := maxi(0, int(spin.value))
		selected_hero_ids.append(hero_id)
		troop_allocation[hero_id] = troops
		total_troops += troops
	var supply_cost := _calculate_supply_cost(total_troops)
	return {
		"source_city_id": str(_payload.get("source_city_id", "")),
		"target_city_id": str(_payload.get("target_city_id", "")),
		"selected_hero_ids": selected_hero_ids,
		"attacker_troop_allocation": troop_allocation,
		"total_assigned_troops": total_troops,
		"supply_cost": supply_cost,
		"supply_source_city_id": str(_payload.get("source_city_id", "")),
	}


func _calculate_supply_cost(total_troops: int) -> Dictionary:
	var troop_total := maxi(0, total_troops)
	return {
		"food": troop_total,
		"gold": int(ceil(float(troop_total) * SUPPLY_GOLD_RATE)),
		"salt": int(ceil(float(troop_total) * SUPPLY_SALT_RATE)),
		SUPPLY_FOOD_KEY: troop_total,
	}


func _can_pay_supply_cost(cost: Dictionary) -> bool:
	return int(_payload.get("food_available", 0)) >= int(cost.get("food", 0)) \
		and int(_payload.get("gold_available", 0)) >= int(cost.get("gold", 0)) \
		and int(_payload.get("salt_available", 0)) >= int(cost.get("salt", 0))


func _on_confirm_pressed() -> void:
	_refresh_state()
	if _confirm_button.disabled:
		return
	deployment_confirmed.emit(_collect_deployment())


func _on_cancel_pressed() -> void:
	deployment_cancelled.emit()
	close()
