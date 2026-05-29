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
var _allocation_summary_label: Label
var _hero_list: VBoxContainer
var _supply_label: Label
var _warning_label: Label
var _button_hint_label: Label
var _confirm_button: Button
var _cancel_button: Button


func _ready() -> void:
	visible = false
	custom_minimum_size = Vector2(720.0, 560.0)
	size = Vector2(720.0, 560.0)
	position = Vector2(430.0, 120.0)
	z_index = 320
	_build_layout()


func open(payload: Dictionary) -> void:
	_payload = payload.duplicate(true)
	visible = true
	_clamp_to_viewport()
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
	_title_label.add_theme_font_size_override("font_size", 20)
	_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.62, 1.0))
	content.add_child(_title_label)

	_city_label = Label.new()
	_city_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_city_label.add_theme_font_size_override("font_size", 16)
	content.add_child(_city_label)

	_troop_label = Label.new()
	content.add_child(_troop_label)

	_resource_label = Label.new()
	_resource_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_resource_label)

	_allocation_summary_label = Label.new()
	_allocation_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_allocation_summary_label.add_theme_color_override("font_color", Color(0.82, 0.92, 1.0, 1.0))
	content.add_child(_allocation_summary_label)

	var hero_title := Label.new()
	hero_title.text = "출전 장수"
	hero_title.add_theme_font_size_override("font_size", 14)
	content.add_child(hero_title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(692.0, 230.0)
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

	_button_hint_label = Label.new()
	_button_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button_hint_label.add_theme_font_size_override("font_size", 11)
	content.add_child(_button_hint_label)

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	content.add_child(button_row)

	_confirm_button = Button.new()
	_confirm_button.text = "출정"
	_confirm_button.custom_minimum_size = Vector2(132.0, 34.0)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	button_row.add_child(_confirm_button)

	_cancel_button = Button.new()
	_cancel_button.text = "취소"
	_cancel_button.custom_minimum_size = Vector2(96.0, 34.0)
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
	_troop_label.text = "출발 도시: %s · 공격 대상: %s\n주둔 병력: %d · 최대 출정: %d" % [
		str(_payload.get("source_city_name", "출발 도시")),
		str(_payload.get("target_city_name", "대상 도시")),
		int(_payload.get("source_troops", 0)),
		int(_payload.get("max_deployable_troops", 0)),
	]
	_resource_label.text = "보유 보급: 식량 %d · 금 %d · 소금 %d" % [
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
	row.add_theme_constant_override("separation", 8)
	_hero_list.add_child(row)

	var check := CheckBox.new()
	check.button_pressed = default_selected
	check.toggled.connect(_on_selection_changed.bind(hero_id))
	row.add_child(check)

	var name_label := Label.new()
	name_label.custom_minimum_size.x = 154.0
	name_label.text = str(hero.get("display_name", hero_id))
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(name_label)

	var state_label := Label.new()
	state_label.custom_minimum_size.x = 74.0
	state_label.text = _format_state_badge_for_row(str(hero.get("state_badge", "")))
	state_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.38, 1.0) if state_label.text != "정상" else Color(0.72, 0.88, 0.72, 1.0))
	row.add_child(state_label)

	var stat_label := Label.new()
	stat_label.custom_minimum_size.x = 100.0
	stat_label.text = "무 %d / 지 %d / 통 %d" % [
		int(hero.get("war", 0)),
		int(hero.get("intelligence", 0)),
		int(hero.get("leadership", hero.get("command", 0))),
	]
	stat_label.clip_text = true
	stat_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(stat_label)

	var command_label := Label.new()
	command_label.custom_minimum_size.x = 126.0
	command_label.text = "%s %d명" % [
		str(hero.get("command_label", "군관")),
		maxi(0, int(hero.get("command_limit", 0))),
	]
	command_label.clip_text = true
	command_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(command_label)

	var hero_command_limit := maxi(0, int(hero.get("command_limit", _payload.get("max_deployable_troops", 0))))
	var max_for_hero := mini(hero_command_limit, maxi(0, int(_payload.get("max_deployable_troops", 0))))
	var spin := SpinBox.new()
	spin.min_value = 0.0
	spin.max_value = float(max_for_hero)
	spin.step = 10.0
	spin.prefix = "병력 "
	spin.custom_minimum_size.x = 118.0
	spin.value = 1.0 if default_selected and max_for_hero > 0 else 0.0
	spin.editable = default_selected and max_for_hero > 0
	spin.value_changed.connect(_on_troop_value_changed.bind(hero_id))
	row.add_child(spin)

	_hero_controls[hero_id] = {
		"check": check,
		"spin": spin,
		"command_limit": hero_command_limit,
	}


func _on_selection_changed(selected: bool, hero_id: String) -> void:
	var controls: Dictionary = _hero_controls.get(hero_id, {})
	var spin := controls.get("spin", null) as SpinBox
	if spin != null:
		spin.editable = selected and int(spin.max_value) > 0
		if selected and int(spin.value) <= 0:
			spin.value = 1.0 if int(spin.max_value) > 0 else 0.0
		elif not selected:
			spin.value = 0.0
	_refresh_state()


func _on_troop_value_changed(_value: float, _hero_id: String) -> void:
	_refresh_state()


func _refresh_state() -> void:
	var deployment := _collect_deployment()
	var selected_count := (deployment.get("selected_hero_ids", []) as Array).size()
	var total_troops := int(deployment.get("total_assigned_troops", 0))
	var source_troops := int(_payload.get("source_troops", 0))
	var max_deployable := int(_payload.get("max_deployable_troops", 0))
	var remaining_troops := source_troops - total_troops
	var cost := _calculate_supply_cost(total_troops)
	var warnings: Array[String] = []
	if selected_count <= 0:
		warnings.append("출정할 장수를 1명 이상 선택해야 합니다.")
	if total_troops <= 0:
		warnings.append("출정 병력을 배정하십시오.")
	if total_troops > max_deployable:
		warnings.append("도시에 최소 1명의 병력은 남겨야 합니다.")
	if total_troops > source_troops:
		warnings.append("배정 병력이 주둔 병력을 초과했습니다.")
	for hero_id_variant in _hero_controls.keys():
		var hero_id := str(hero_id_variant)
		var controls: Dictionary = _hero_controls.get(hero_id, {})
		var check := controls.get("check", null) as CheckBox
		var spin := controls.get("spin", null) as SpinBox
		if check == null or spin == null or not check.button_pressed:
			continue
		var command_limit := maxi(0, int(controls.get("command_limit", 0)))
		if int(spin.value) > command_limit:
			warnings.append("%s 병력이 지휘한계를 초과했습니다." % _get_hero_display_name(hero_id))
	var missing_supply := _get_missing_supply_reasons(cost)
	for reason in missing_supply:
		warnings.append(reason)
	_allocation_summary_label.text = "총 출정 병력: %d\n잔여 주둔 병력: %d" % [
		total_troops,
		remaining_troops,
	]
	_supply_label.text = "보급 필요량\n%s\n%s\n%s" % [
		_format_supply_line("식량", int(cost.get("food", 0)), int(_payload.get("food_available", 0))),
		_format_supply_line("금", int(cost.get("gold", 0)), int(_payload.get("gold_available", 0))),
		_format_supply_line("소금", int(cost.get("salt", 0)), int(_payload.get("salt_available", 0))),
	]
	_warning_label.text = " · ".join(warnings)
	if warnings.is_empty():
		_button_hint_label.text = "출정 가능: %s 병력 %d명" % [
			str(_payload.get("target_city_name", "대상 도시")),
			total_troops,
		]
		_button_hint_label.add_theme_color_override("font_color", Color(0.72, 0.92, 0.72, 1.0))
	else:
		_button_hint_label.text = "출정 불가: %s" % warnings[0]
		_button_hint_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.42, 1.0))
	_confirm_button.disabled = not warnings.is_empty()


func _format_supply_line(label: String, need: int, available: int) -> String:
	var status := "충분" if available >= need else "부족"
	return "%s %d / 보유 %d  %s" % [label, need, available, status]


func _get_missing_supply_reasons(cost: Dictionary) -> Array[String]:
	var reasons: Array[String] = []
	if int(_payload.get("food_available", 0)) < int(cost.get("food", 0)):
		reasons.append("식량이 부족합니다.")
	if int(_payload.get("gold_available", 0)) < int(cost.get("gold", 0)):
		reasons.append("금이 부족합니다.")
	if int(_payload.get("salt_available", 0)) < int(cost.get("salt", 0)):
		reasons.append("소금이 부족합니다.")
	return reasons


func _format_state_badge_for_row(raw_badge: String) -> String:
	var badge := raw_badge.strip_edges()
	if badge.is_empty():
		return "정상"
	return badge.replace("[", "").replace("]", "").strip_edges()


func _clamp_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var target_size := custom_minimum_size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	position.x = clampf(position.x, 12.0, maxf(12.0, viewport_size.x - target_size.x - 12.0))
	position.y = clampf(position.y, 12.0, maxf(12.0, viewport_size.y - target_size.y - 12.0))


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
		var command_limit := maxi(0, int(controls.get("command_limit", spin.max_value)))
		troops = mini(troops, command_limit)
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


func _get_hero_display_name(hero_id: String) -> String:
	var heroes: Array = _payload.get("heroes", [])
	for hero_variant in heroes:
		if not (hero_variant is Dictionary):
			continue
		var hero: Dictionary = hero_variant
		if str(hero.get("hero_id", "")) == hero_id:
			return str(hero.get("display_name", hero_id))
	return hero_id


func _on_confirm_pressed() -> void:
	_refresh_state()
	if _confirm_button.disabled:
		return
	deployment_confirmed.emit(_collect_deployment())


func _on_cancel_pressed() -> void:
	deployment_cancelled.emit()
	close()
