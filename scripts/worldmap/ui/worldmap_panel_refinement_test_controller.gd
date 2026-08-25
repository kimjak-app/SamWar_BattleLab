extends Node

const TOOLTIP_SCENE: PackedScene = preload("res://WorldMapHoverTooltip.tscn")

const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const RIGHT_PANEL_PATH := "WorldMapUI/CityInfoPanel"
const LEFT_POWER_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/PowerLabel"
const LOYALTY_CARD_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard"
const LOYALTY_LABEL_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard/MarginContainer/Content/LoyaltyLabel"
const LOYALTY_BAR_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard/MarginContainer/Content/LoyaltyBar"
const REVOLT_RISK_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard/MarginContainer/Content/RevoltRiskLabel"
const DOMESTIC_INFO_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/MilitaryStateLabel"
const GARRISON_CARD_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GarrisonCard"

const STABLE_COLOR := Color(0.31, 0.60, 0.34, 1.0)
const CAUTION_COLOR := Color(0.78, 0.62, 0.22, 1.0)
const DANGER_COLOR := Color(0.70, 0.25, 0.22, 1.0)

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _tooltip: Control = null
var _left_panel: Control = null
var _right_panel: Control = null
var _domestic_row: HBoxContainer = null
var _metric_labels: Dictionary = {}
var _last_stability_state := ""
var _installed := false


func _ready() -> void:
	process_priority = 1200
	set_process(true)
	call_deferred("_install")


func _process(_delta: float) -> void:
	if not _installed:
		return
	_align_left_panel_to_right()
	_hide_legacy_help_ui()
	_apply_city_stability_presentation()
	_refresh_domestic_metrics()


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap Panel Refinement: ProductionWorldMap is missing.")
		return
	var world_ui := production_world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return

	_left_panel = production_world_map.get_node_or_null(LEFT_PANEL_PATH) as Control
	_right_panel = production_world_map.get_node_or_null(RIGHT_PANEL_PATH) as Control
	_tooltip = TOOLTIP_SCENE.instantiate() as Control
	if _tooltip != null:
		_tooltip.name = "HoverTooltip"
		world_ui.add_child(_tooltip)

	_hide_legacy_help_ui()
	_bind_help_target(production_world_map.get_node_or_null(LEFT_POWER_LABEL_PATH) as Control, "national_loyalty")
	_bind_help_target(production_world_map.get_node_or_null(LOYALTY_CARD_PATH) as Control, "city_loyalty")
	_bind_help_target(production_world_map.get_node_or_null(GARRISON_CARD_PATH) as Control, "garrison")
	_ensure_domestic_metrics_row()
	_align_left_panel_to_right()
	_apply_city_stability_presentation()
	_refresh_domestic_metrics()
	_installed = true


func _align_left_panel_to_right() -> void:
	if _left_panel == null or _right_panel == null:
		return
	if not is_instance_valid(_left_panel) or not is_instance_valid(_right_panel):
		return
	if _right_panel.visible:
		_left_panel.position.y = _right_panel.position.y


func _hide_legacy_help_ui() -> void:
	for panel in [_left_panel, _right_panel]:
		if panel != null and is_instance_valid(panel):
			_hide_help_recursive(panel)


func _hide_help_recursive(node: Node) -> void:
	if node is Button:
		var button := node as Button
		if button.text.strip_edges() == "?" or str(button.name).contains("HelpButton"):
			button.visible = false
	if node is Control and str(node.name) == "DomesticHelpRow":
		(node as Control).visible = false
	for child in node.get_children():
		_hide_help_recursive(child)


func _bind_help_target(target: Control, topic_id: String) -> void:
	if target == null:
		return
	var key := "worldmap_hover_help_%s" % topic_id
	if target.has_meta(key):
		return
	target.set_meta(key, true)
	target.mouse_filter = Control.MOUSE_FILTER_PASS
	target.mouse_entered.connect(_show_help.bind(topic_id))
	target.mouse_exited.connect(_hide_help)


func _show_help(topic_id: String) -> void:
	if _tooltip == null or production_world_map == null:
		return
	var payload: Dictionary = {}
	if production_world_map.has_method("_get_worldmap_help_content"):
		var result = production_world_map.call("_get_worldmap_help_content", topic_id)
		if result is Dictionary:
			payload = result
	if not payload.is_empty() and _tooltip.has_method("show_help"):
		_tooltip.call("show_help", str(payload.get("title", "도움말")), str(payload.get("body", "")))


func _hide_help() -> void:
	if _tooltip != null and _tooltip.has_method("hide_help"):
		_tooltip.call("hide_help")


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

	for item in [["public_support", "민심"], ["security", "치안"], ["commerce", "상업"], ["agriculture", "농업"]]:
		if _domestic_row.get_child_count() > 0:
			var separator := Label.new()
			separator.text = "·"
			separator.add_theme_font_size_override("font_size", 10)
			_domestic_row.add_child(separator)
		var metric := Label.new()
		metric.text = "%s -" % str(item[1])
		metric.add_theme_font_size_override("font_size", 10)
		metric.mouse_filter = Control.MOUSE_FILTER_PASS
		_domestic_row.add_child(metric)
		_metric_labels[str(item[0])] = metric

	var public_support_target := _metric_labels.get("public_support") as Control
	var security_target := _metric_labels.get("security") as Control
	_bind_help_target(public_support_target, "public_support")
	_bind_help_target(security_target, "security")


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
	var labels := {"public_support": "민심", "security": "치안", "commerce": "상업", "agriculture": "농업"}
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


func _extract_first_integer(text: String, fallback: int) -> int:
	var regex := RegEx.new()
	if regex.compile("([0-9]+)") != OK:
		return fallback
	var matched := regex.search(text)
	return int(matched.get_string(1)) if matched != null else fallback
