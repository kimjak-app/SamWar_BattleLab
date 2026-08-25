extends Node

const TOOLTIP_SCENE: PackedScene = preload("res://WorldMapHoverTooltip.tscn")
const SPEECH_SCENE: PackedScene = preload("res://WorldMapCharacterSpeechPopup.tscn")

const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const RIGHT_PANEL_PATH := "WorldMapUI/CityInfoPanel"
const LEFT_POWER_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/PowerLabel"
const CHANCELLOR_ASSIGN_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorAssignmentOption"
const CHANCELLOR_POLICY_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorPolicyOption"
const CHANCELLOR_DESCRIPTION_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorPolicyDescriptionLabel"
const CHANCELLOR_NAME_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/Copy/ChancellorNameLabel"
const CHANCELLOR_PORTRAIT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/PortraitBox/ChancellorPortraitTexture"
const CHANCELLOR_FALLBACK_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/PortraitBox/PortraitLabel"

const RIGHT_CONTENT_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content"
const CITY_NAME_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/CityNameLabel"
const LOYALTY_CARD_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard"
const LOYALTY_LABEL_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard/MarginContainer/Content/LoyaltyLabel"
const LOYALTY_BAR_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard/MarginContainer/Content/LoyaltyBar"
const REVOLT_RISK_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard/MarginContainer/Content/RevoltRiskLabel"
const GOVERNOR_ASSIGN_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorAssignOption"
const GOVERNOR_POLICY_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorPolicyOption"
const GOVERNOR_DESCRIPTION_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorPolicyDescriptionLabel"
const GOVERNOR_NAME_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/Copy/GovernorNameLabel"
const GOVERNOR_PORTRAIT_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/PortraitBox/GovernorPortraitTexture"
const GOVERNOR_FALLBACK_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/PortraitBox/PortraitLabel"
const DOMESTIC_INFO_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/MilitaryStateLabel"
const GARRISON_CARD_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GarrisonCard"

const STABLE_COLOR := Color(0.31, 0.60, 0.34, 1.0)
const CAUTION_COLOR := Color(0.78, 0.62, 0.22, 1.0)
const DANGER_COLOR := Color(0.70, 0.25, 0.22, 1.0)
const COMPACT_GARRISON_HEIGHT := 96.0

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _tooltip: Control = null
var _speech_popup: Control = null
var _left_panel: Control = null
var _right_panel: Control = null
var _domestic_row: HBoxContainer = null
var _metric_labels: Dictionary = {}
var _compact_garrison_scroll: ScrollContainer = null
var _compact_garrison_grid: GridContainer = null
var _garrison_signature := ""
var _last_stability_state := ""
var _last_chancellor_id := ""
var _last_governor_id := ""
var _last_chancellor_policy := ""
var _last_governor_policy := ""
var _installed := false


func _ready() -> void:
	process_priority = 1200
	set_process(true)
	call_deferred("_install")


func _process(_delta: float) -> void:
	if not _installed:
		return
	_align_left_panel_to_right()
	_hide_legacy_help_buttons()
	_hide_policy_description_labels()
	_apply_city_stability_presentation()
	_refresh_domestic_metrics()
	_refresh_compact_garrison_if_needed()


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap HUD Refinement: ProductionWorldMap is missing.")
		return
	var world_ui := production_world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		push_warning("WorldMap HUD Refinement: WorldMapUI is missing.")
		return

	_left_panel = production_world_map.get_node_or_null(LEFT_PANEL_PATH) as Control
	_right_panel = production_world_map.get_node_or_null(RIGHT_PANEL_PATH) as Control
	_tooltip = TOOLTIP_SCENE.instantiate() as Control
	_speech_popup = SPEECH_SCENE.instantiate() as Control
	if _tooltip != null:
		_tooltip.name = "HoverTooltip"
		world_ui.add_child(_tooltip)
	if _speech_popup != null:
		_speech_popup.name = "CharacterSpeechPopup"
		world_ui.add_child(_speech_popup)

	_hide_legacy_help_buttons()
	_bind_existing_help_targets()
	_hide_policy_description_labels()
	_ensure_domestic_metrics_row()
	_ensure_compact_garrison_view()
	_connect_character_events()
	_capture_initial_character_state()
	_align_left_panel_to_right()
	_apply_city_stability_presentation()
	_refresh_domestic_metrics()
	_refresh_compact_garrison_if_needed(true)
	_installed = true


func _align_left_panel_to_right() -> void:
	if _left_panel == null or _right_panel == null:
		return
	if not is_instance_valid(_left_panel) or not is_instance_valid(_right_panel):
		return
	if not _right_panel.visible:
		return
	_left_panel.position.y = _right_panel.position.y


func _hide_legacy_help_buttons() -> void:
	for panel in [_left_panel, _right_panel]:
		if panel == null or not is_instance_valid(panel):
			continue
		_hide_help_buttons_recursive(panel)


func _hide_help_buttons_recursive(node: Node) -> void:
	if node is Button:
		var button := node as Button
		if button.text.strip_edges() == "?" or str(button.name).contains("HelpButton"):
			button.visible = false
	for child in node.get_children():
		_hide_help_buttons_recursive(child)


func _bind_existing_help_targets() -> void:
	var power_label := production_world_map.get_node_or_null(LEFT_POWER_LABEL_PATH) as Control
	_bind_help_target(power_label, "national_loyalty")

	var loyalty_card := production_world_map.get_node_or_null(LOYALTY_CARD_PATH) as Control
	_bind_help_target(loyalty_card, "city_loyalty")

	var garrison_card := production_world_map.get_node_or_null(GARRISON_CARD_PATH) as Control
	_bind_help_target(garrison_card, "garrison")


func _bind_help_target(target: Control, topic_id: String) -> void:
	if target == null:
		return
	var meta_key := "worldmap_hover_help_%s" % topic_id
	if target.has_meta(meta_key):
		return
	target.set_meta(meta_key, true)
	target.mouse_filter = Control.MOUSE_FILTER_PASS
	target.mouse_entered.connect(_on_help_mouse_entered.bind(topic_id))
	target.mouse_exited.connect(_on_help_mouse_exited)


func _on_help_mouse_entered(topic_id: String) -> void:
	if _tooltip == null or production_world_map == null:
		return
	var payload: Dictionary = {}
	if production_world_map.has_method("_get_worldmap_help_content"):
		var value = production_world_map.call("_get_worldmap_help_content", topic_id)
		if value is Dictionary:
			payload = value
	if payload.is_empty():
		return
	if _tooltip.has_method("show_help"):
		_tooltip.call(
			"show_help",
			str(payload.get("title", "도움말")),
			str(payload.get("body", ""))
		)


func _on_help_mouse_exited() -> void:
	if _tooltip != null and _tooltip.has_method("hide_help"):
		_tooltip.call("hide_help")


func _hide_policy_description_labels() -> void:
	var chancellor_description := production_world_map.get_node_or_null(CHANCELLOR_DESCRIPTION_PATH) as CanvasItem
	var governor_description := production_world_map.get_node_or_null(GOVERNOR_DESCRIPTION_PATH) as CanvasItem
	if chancellor_description != null:
		chancellor_description.visible = false
	if governor_description != null:
		governor_description.visible = false


func _apply_city_stability_presentation() -> void:
	var loyalty_label := production_world_map.get_node_or_null(LOYALTY_LABEL_PATH) as Label
	var loyalty_bar := production_world_map.get_node_or_null(LOYALTY_BAR_PATH) as ProgressBar
	var revolt_risk := production_world_map.get_node_or_null(REVOLT_RISK_PATH) as CanvasItem
	if revolt_risk != null:
		revolt_risk.visible = false
	if loyalty_label == null or loyalty_bar == null:
		return

	var loyalty := _extract_first_integer(loyalty_label.text, int(round(loyalty_bar.value)))
	var state := _stability_state(loyalty)
	loyalty_label.text = "%d · %s" % [loyalty, state]
	loyalty_bar.value = loyalty

	if state != _last_stability_state:
		_last_stability_state = state
		var source_style := loyalty_bar.get_theme_stylebox("fill")
		if source_style is StyleBoxFlat:
			var fill_style := source_style.duplicate() as StyleBoxFlat
			fill_style.bg_color = _stability_color(state)
			loyalty_bar.add_theme_stylebox_override("fill", fill_style)


func _stability_state(loyalty: int) -> String:
	if loyalty >= 70:
		return "안정"
	if loyalty >= 50:
		return "주의"
	return "위험"


func _stability_color(state: String) -> Color:
	match state:
		"안정":
			return STABLE_COLOR
		"주의":
			return CAUTION_COLOR
		_:
			return DANGER_COLOR


func _ensure_domestic_metrics_row() -> void:
	if _domestic_row != null and is_instance_valid(_domestic_row):
		return
	var original := production_world_map.get_node_or_null(DOMESTIC_INFO_PATH) as Label
	if original == null:
		return
	var parent := original.get_parent() as Container
	if parent == null:
		return

	_domestic_row = HBoxContainer.new()
	_domestic_row.name = "CompactDomesticMetricsRow"
	_domestic_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_domestic_row.add_theme_constant_override("separation", 5)
	var insertion_index := original.get_index()
	parent.add_child(_domestic_row)
	parent.move_child(_domestic_row, insertion_index)
	original.visible = false

	for item in [
		["public_support", "민심"],
		["security", "치안"],
		["commerce", "상업"],
		["agriculture", "농업"],
	]:
		if _domestic_row.get_child_count() > 0:
			var separator := Label.new()
			separator.text = "·"
			separator.add_theme_font_size_override("font_size", 10)
			_domestic_row.add_child(separator)
		var metric := Label.new()
		metric.name = "%sMetricLabel" % str(item[0]).to_pascal_case()
		metric.text = "%s -" % str(item[1])
		metric.add_theme_font_size_override("font_size", 10)
		metric.mouse_filter = Control.MOUSE_FILTER_PASS
		_domestic_row.add_child(metric)
		_metric_labels[str(item[0])] = metric

	_bind_help_target(_metric_labels.get("public_support") as Control, "public_support")
	_bind_help_target(_metric_labels.get("security") as Control, "security")


func _refresh_domestic_metrics() -> void:
	_ensure_domestic_metrics_row()
	var original := production_world_map.get_node_or_null(DOMESTIC_INFO_PATH) as Label
	if original == null or _domestic_row == null:
		return
	original.visible = false
	_domestic_row.visible = true
	var raw := original.text.replace("\n", " ")
	var values := {
		"public_support": _extract_metric(raw, "민심"),
		"security": _extract_metric(raw, "치안"),
		"commerce": _extract_metric(raw, "상업"),
		"agriculture": _extract_metric(raw, "농업"),
	}
	var labels := {
		"public_support": "민심",
		"security": "치안",
		"commerce": "상업",
		"agriculture": "농업",
	}
	for key in values.keys():
		var label := _metric_labels.get(key) as Label
		if label != null:
			label.text = "%s %s" % [str(labels[key]), str(values[key])]


func _extract_metric(raw: String, label_text: String) -> String:
	var regex := RegEx.new()
	if regex.compile("%s\\s*([0-9]+|정보 없음|\\?)" % label_text) != OK:
		return "-"
	var matched := regex.search(raw)
	return matched.get_string(1) if matched != null else "-"


func _ensure_compact_garrison_view() -> void:
	if _compact_garrison_scroll != null and is_instance_valid(_compact_garrison_scroll):
		return
	var card := production_world_map.get_node_or_null(GARRISON_CARD_PATH) as PanelContainer
	if card == null:
		return
	var content := card.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return

	_compact_garrison_scroll = ScrollContainer.new()
	_compact_garrison_scroll.name = "CompactGarrisonScroll"
	_compact_garrison_scroll.custom_minimum_size = Vector2(0.0, COMPACT_GARRISON_HEIGHT)
	_compact_garrison_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_compact_garrison_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_compact_garrison_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content.add_child(_compact_garrison_scroll)

	_compact_garrison_grid = GridContainer.new()
	_compact_garrison_grid.name = "CompactGarrisonGrid"
	_compact_garrison_grid.columns = 3
	_compact_garrison_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_compact_garrison_grid.add_theme_constant_override("h_separation", 8)
	_compact_garrison_grid.add_theme_constant_override("v_separation", 7)
	_compact_garrison_scroll.add_child(_compact_garrison_grid)
	_bind_help_target(_compact_garrison_scroll, "garrison")


func _refresh_compact_garrison_if_needed(force: bool = false) -> void:
	_ensure_compact_garrison_view()
	if _compact_garrison_grid == null:
		return
	var original_scroll := production_world_map.get_node_or_null(GARRISON_CARD_PATH + "/MarginContainer/Content/GarrisonScroll") as ScrollContainer
	var original_list: Node = null
	if original_scroll != null:
		original_list = original_scroll.get_node_or_null("GarrisonList")
	if original_list == null:
		original_list = production_world_map.get_node_or_null(GARRISON_CARD_PATH + "/MarginContainer/Content/GarrisonList")
	if original_list == null:
		return

	var hero_rows: Array[Node] = []
	var names: Array[String] = []
	for row in original_list.get_children():
		var name_label := row.find_child("NameLabel", true, false) as Label
		if name_label == null:
			continue
		hero_rows.append(row)
		names.append(name_label.text.strip_edges())
	var signature := "|".join(names)
	if not force and signature == _garrison_signature:
		if original_scroll != null:
			original_scroll.visible = false
		_compact_garrison_scroll.visible = true
		return
	_garrison_signature = signature

	for child in _compact_garrison_grid.get_children():
		child.queue_free()
	for row in hero_rows:
		_build_compact_garrison_cell(row)
	if original_scroll != null:
		original_scroll.visible = false
	if original_list is CanvasItem and original_scroll == null:
		(original_list as CanvasItem).visible = false
	_compact_garrison_scroll.visible = true


func _build_compact_garrison_cell(source_row: Node) -> void:
	var name_source := source_row.find_child("NameLabel", true, false) as Label
	if name_source == null:
		return
	var cell := VBoxContainer.new()
	cell.custom_minimum_size = Vector2(70.0, 78.0)
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.add_theme_constant_override("separation", 2)

	var portrait_source := _find_first_textured_rect(source_row)
	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(52.0, 52.0)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = portrait_source.texture if portrait_source != null else null
	cell.add_child(portrait)

	var name_label := Label.new()
	name_label.text = name_source.text
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	cell.add_child(name_label)
	_compact_garrison_grid.add_child(cell)


func _find_first_textured_rect(node: Node) -> TextureRect:
	if node is TextureRect and (node as TextureRect).texture != null:
		return node as TextureRect
	for child in node.get_children():
		var found := _find_first_textured_rect(child)
		if found != null:
			return found
	return null


func _connect_character_events() -> void:
	var chancellor_assign := production_world_map.get_node_or_null(CHANCELLOR_ASSIGN_PATH) as OptionButton
	var chancellor_policy := production_world_map.get_node_or_null(CHANCELLOR_POLICY_PATH) as OptionButton
	var governor_assign := production_world_map.get_node_or_null(GOVERNOR_ASSIGN_PATH) as OptionButton
	var governor_policy := production_world_map.get_node_or_null(GOVERNOR_POLICY_PATH) as OptionButton
	if chancellor_assign != null and not chancellor_assign.item_selected.is_connected(_on_chancellor_assignment_observed):
		chancellor_assign.item_selected.connect(_on_chancellor_assignment_observed)
	if chancellor_policy != null and not chancellor_policy.item_selected.is_connected(_on_chancellor_policy_observed):
		chancellor_policy.item_selected.connect(_on_chancellor_policy_observed)
	if governor_assign != null and not governor_assign.item_selected.is_connected(_on_governor_assignment_observed):
		governor_assign.item_selected.connect(_on_governor_assignment_observed)
	if governor_policy != null and not governor_policy.item_selected.is_connected(_on_governor_policy_observed):
		governor_policy.item_selected.connect(_on_governor_policy_observed)


func _capture_initial_character_state() -> void:
	_last_chancellor_id = _selected_metadata(production_world_map.get_node_or_null(CHANCELLOR_ASSIGN_PATH) as OptionButton)
	_last_governor_id = _selected_metadata(production_world_map.get_node_or_null(GOVERNOR_ASSIGN_PATH) as OptionButton)
	_last_chancellor_policy = _selected_metadata(production_world_map.get_node_or_null(CHANCELLOR_POLICY_PATH) as OptionButton)
	_last_governor_policy = _selected_metadata(production_world_map.get_node_or_null(GOVERNOR_POLICY_PATH) as OptionButton)


func _on_chancellor_assignment_observed(_index: int) -> void:
	call_deferred("_show_chancellor_assignment_if_changed")


func _on_governor_assignment_observed(_index: int) -> void:
	call_deferred("_show_governor_assignment_if_changed")


func _on_chancellor_policy_observed(_index: int) -> void:
	call_deferred("_show_chancellor_policy_if_changed")


func _on_governor_policy_observed(_index: int) -> void:
	call_deferred("_show_governor_policy_if_changed")


func _show_chancellor_assignment_if_changed() -> void:
	var option := production_world_map.get_node_or_null(CHANCELLOR_ASSIGN_PATH) as OptionButton
	var current := _selected_metadata(option)
	if current == _last_chancellor_id:
		return
	_last_chancellor_id = current
	if current.is_empty():
		return
	_show_character_popup(
		"재상",
		_text_at(CHANCELLOR_NAME_PATH, option.get_item_text(option.selected) if option != null and option.selected >= 0 else "재상"),
		CHANCELLOR_PORTRAIT_PATH,
		CHANCELLOR_FALLBACK_PATH,
		"이제 국가의 모든 일은 제가 지휘하겠습니다."
	)


func _show_governor_assignment_if_changed() -> void:
	var option := production_world_map.get_node_or_null(GOVERNOR_ASSIGN_PATH) as OptionButton
	var current := _selected_metadata(option)
	if current == _last_governor_id:
		return
	_last_governor_id = current
	if current.is_empty():
		return
	var city_name := _text_at(CITY_NAME_PATH, "이 성")
	_show_character_popup(
		"태수",
		_text_at(GOVERNOR_NAME_PATH, option.get_item_text(option.selected) if option != null and option.selected >= 0 else "태수"),
		GOVERNOR_PORTRAIT_PATH,
		GOVERNOR_FALLBACK_PATH,
		"맡겨 주십쇼. 이제 %s은 제가 책임지겠습니다." % city_name
	)


func _show_chancellor_policy_if_changed() -> void:
	var option := production_world_map.get_node_or_null(CHANCELLOR_POLICY_PATH) as OptionButton
	var current := _selected_metadata(option)
	if current == _last_chancellor_policy:
		return
	_last_chancellor_policy = current
	var chancellor_id := _selected_metadata(production_world_map.get_node_or_null(CHANCELLOR_ASSIGN_PATH) as OptionButton)
	if chancellor_id.is_empty() or option == null or option.selected < 0:
		return
	var policy_name := option.get_item_text(option.selected)
	var description := _text_at(CHANCELLOR_DESCRIPTION_PATH, "")
	_show_character_popup(
		"재상",
		_text_at(CHANCELLOR_NAME_PATH, "재상"),
		CHANCELLOR_PORTRAIT_PATH,
		CHANCELLOR_FALLBACK_PATH,
		_build_policy_speech(policy_name, description, true)
	)


func _show_governor_policy_if_changed() -> void:
	var option := production_world_map.get_node_or_null(GOVERNOR_POLICY_PATH) as OptionButton
	var current := _selected_metadata(option)
	if current == _last_governor_policy:
		return
	_last_governor_policy = current
	var governor_id := _selected_metadata(production_world_map.get_node_or_null(GOVERNOR_ASSIGN_PATH) as OptionButton)
	if governor_id.is_empty() or option == null or option.selected < 0:
		return
	var policy_name := option.get_item_text(option.selected)
	var description := _text_at(GOVERNOR_DESCRIPTION_PATH, "")
	_show_character_popup(
		"태수",
		_text_at(GOVERNOR_NAME_PATH, "태수"),
		GOVERNOR_PORTRAIT_PATH,
		GOVERNOR_FALLBACK_PATH,
		_build_policy_speech(policy_name, description, false)
	)


func _build_policy_speech(policy_name: String, raw_description: String, is_chancellor: bool) -> String:
	var clean := raw_description.replace("\r", "").strip_edges()
	var effect := ""
	var policy := ""
	for line in clean.split("\n"):
		var text := str(line).strip_edges()
		if text.begins_with("효과:"):
			effect = text.trim_prefix("효과:").strip_edges()
		elif text.begins_with("정책:"):
			policy = text.trim_prefix("정책:").strip_edges()
		elif policy.is_empty() and not text.is_empty():
			policy = text.trim_prefix("효과:").strip_edges()

	var particle := _object_particle(policy_name)
	if is_chancellor:
		if effect.is_empty():
			effect = "재상 고유 효과"
		if policy.is_empty() or policy == "보정 없음":
			return "%s%s 선택하시면 '%s' 효과가 적용됩니다. 정책은 특별한 보정이 없습니다." % [policy_name, particle, effect]
		return "%s%s 선택하시면 '%s' 효과가 적용됩니다. 정책은 %s." % [policy_name, particle, effect, _ensure_sentence(policy)]
	if policy.is_empty():
		policy = clean if not clean.is_empty() else "도시 운영 보정"
	return "%s%s 선택하시면 %s" % [policy_name, particle, _ensure_sentence(policy)]


func _ensure_sentence(text: String) -> String:
	var value := text.strip_edges()
	if value.is_empty():
		return "특별한 보정이 없습니다."
	if value.ends_with(".") or value.ends_with("다") or value.ends_with("요"):
		return value
	return "%s 효과가 적용됩니다." % value


func _object_particle(value: String) -> String:
	if value.is_empty():
		return "을"
	var code := value.unicode_at(value.length() - 1)
	if code >= 0xAC00 and code <= 0xD7A3:
		return "을" if ((code - 0xAC00) % 28) != 0 else "를"
	return "을"


func _show_character_popup(role_text: String, character_name: String, portrait_path: String, fallback_path: String, speech: String) -> void:
	if _speech_popup == null:
		return
	var portrait_node := production_world_map.get_node_or_null(portrait_path) as TextureRect
	var fallback_node := production_world_map.get_node_or_null(fallback_path) as Label
	var texture: Texture2D = portrait_node.texture if portrait_node != null else null
	var fallback := fallback_node.text if fallback_node != null else "?"
	if _speech_popup.has_method("show_character"):
		_speech_popup.call("show_character", texture, fallback, role_text, character_name, speech)


func _selected_metadata(option: OptionButton) -> String:
	if option == null or option.selected < 0 or option.selected >= option.item_count:
		return ""
	return str(option.get_item_metadata(option.selected))


func _text_at(path: String, fallback: String) -> String:
	var label := production_world_map.get_node_or_null(path) as Label
	if label == null:
		return fallback
	var value := label.text.strip_edges()
	return value if not value.is_empty() else fallback


func _extract_first_integer(text: String, fallback: int) -> int:
	var regex := RegEx.new()
	if regex.compile("([0-9]+)") != OK:
		return fallback
	var matched := regex.search(text)
	return int(matched.get_string(1)) if matched != null else fallback
