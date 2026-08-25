extends Node

const AdminRoleResolver := preload("res://scripts/worldmap/ui/worldmap_hero_admin_role_resolver.gd")

const CALENDAR_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/CalendarLabel"
const POWER_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/PowerLabel"
const POWER_BAR_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/NationalGaugeCard/MarginContainer/GaugeList/PowerBar"
const CHANCELLOR_CARD_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard"
const CHANCELLOR_ASSIGNMENT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorAssignmentOption"
const RIGHT_PANEL_PATH := "WorldMapUI/CityInfoPanel"
const LOYALTY_LABEL_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard/MarginContainer/Content/LoyaltyLabel"
const LOYALTY_BAR_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/LoyaltyCard/MarginContainer/Content/LoyaltyBar"

const STABLE_THRESHOLD := 80
const CAUTION_THRESHOLD := 60
const STABLE_COLOR := Color(0.31, 0.67, 0.36, 1.0)
const CAUTION_COLOR := Color(0.86, 0.67, 0.20, 1.0)
const DANGER_COLOR := Color(0.78, 0.25, 0.22, 1.0)
const HIDE_GUARD_META := "w2_a15_stable_source_hidden"

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _calendar_source: Label = null
var _calendar_mirror: Label = null
var _power_label_source: Label = null
var _power_label_mirror: Label = null
var _power_bar_source: ProgressBar = null
var _power_bar_mirror: ProgressBar = null
var _loyalty_label_source: Label = null
var _loyalty_label_mirror: Label = null
var _loyalty_bar_source: ProgressBar = null
var _loyalty_bar_mirror: ProgressBar = null
var _chancellor_role_source: Label = null
var _chancellor_role_mirror: Label = null
var _chancellor_assignment: OptionButton = null
var _governor_role_source: Label = null
var _governor_role_mirror: Label = null
var _governor_assignment: OptionButton = null
var _installed := false


func _ready() -> void:
	set_process(false)
	call_deferred("_install")


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap Stable HUD Mirror: ProductionWorldMap is missing.")
		return

	_calendar_source = production_world_map.get_node_or_null(CALENDAR_PATH) as Label
	_calendar_mirror = _mirror_label(_calendar_source, "StableCalendarLabel")

	_power_label_source = production_world_map.get_node_or_null(POWER_LABEL_PATH) as Label
	_power_label_mirror = _mirror_label(_power_label_source, "StableNationalLoyaltyLabel")
	_power_bar_source = production_world_map.get_node_or_null(POWER_BAR_PATH) as ProgressBar
	_power_bar_mirror = _mirror_progress_bar(_power_bar_source, "StableNationalLoyaltyBar")

	_loyalty_label_source = production_world_map.get_node_or_null(LOYALTY_LABEL_PATH) as Label
	_loyalty_label_mirror = _mirror_label(_loyalty_label_source, "StableCityLoyaltyLabel")
	_loyalty_bar_source = production_world_map.get_node_or_null(LOYALTY_BAR_PATH) as ProgressBar
	_loyalty_bar_mirror = _mirror_progress_bar(_loyalty_bar_source, "StableCityLoyaltyBar")

	_chancellor_assignment = production_world_map.get_node_or_null(CHANCELLOR_ASSIGNMENT_PATH) as OptionButton
	var chancellor_card := production_world_map.get_node_or_null(CHANCELLOR_CARD_PATH)
	if chancellor_card != null:
		_chancellor_role_source = chancellor_card.find_child("ChancellorStatsLabel", true, false) as Label
		_chancellor_role_mirror = _mirror_label(_chancellor_role_source, "StableChancellorRoleLabel")

	var right_panel := production_world_map.get_node_or_null(RIGHT_PANEL_PATH)
	if right_panel != null:
		var governor_card := right_panel.find_child("GovernorCard", true, false)
		if governor_card != null:
			_governor_assignment = governor_card.find_child("GovernorAssignOption", true, false) as OptionButton
			_governor_role_source = governor_card.find_child("GovernorStatsLabel", true, false) as Label
			_governor_role_mirror = _mirror_label(_governor_role_source, "StableGovernorRoleLabel")

	_sync_from_sources()
	_installed = true


func _sync_from_sources() -> void:
	if not _installed and _calendar_mirror == null:
		return
	_sync_calendar()
	_sync_stability_pair(_power_label_source, _power_label_mirror, _power_bar_source, _power_bar_mirror, true)
	_sync_stability_pair(_loyalty_label_source, _loyalty_label_mirror, _loyalty_bar_source, _loyalty_bar_mirror, false)
	_sync_role(_chancellor_assignment, _chancellor_role_mirror)
	_sync_role(_governor_assignment, _governor_role_mirror)


func _mirror_label(source: Label, mirror_name: String) -> Label:
	if source == null:
		return null
	var parent := source.get_parent()
	if parent == null:
		return null
	var existing := parent.get_node_or_null(mirror_name) as Label
	if existing != null:
		_hide_source_forever(source)
		return existing
	var index := source.get_index()
	var mirror := source.duplicate() as Label
	if mirror == null:
		return null
	mirror.name = mirror_name
	mirror.visible = true
	mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(mirror)
	parent.move_child(mirror, mini(index, parent.get_child_count() - 1))
	_hide_source_forever(source)
	return mirror


func _mirror_progress_bar(source: ProgressBar, mirror_name: String) -> ProgressBar:
	if source == null:
		return null
	var parent := source.get_parent()
	if parent == null:
		return null
	var existing := parent.get_node_or_null(mirror_name) as ProgressBar
	if existing != null:
		_hide_source_forever(source)
		return existing
	var index := source.get_index()
	var mirror := source.duplicate() as ProgressBar
	if mirror == null:
		return null
	mirror.name = mirror_name
	mirror.visible = true
	mirror.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(mirror)
	parent.move_child(mirror, mini(index, parent.get_child_count() - 1))
	_hide_source_forever(source)
	return mirror


func _hide_source_forever(item: CanvasItem) -> void:
	if item == null:
		return
	item.visible = false
	if item.has_meta(HIDE_GUARD_META):
		return
	item.set_meta(HIDE_GUARD_META, true)
	item.visibility_changed.connect(_on_source_visibility_changed.bind(item))


func _on_source_visibility_changed(item: CanvasItem) -> void:
	if item != null and is_instance_valid(item) and item.visible:
		item.visible = false


func _sync_calendar() -> void:
	if _calendar_source == null or _calendar_mirror == null:
		return
	var compact := _compact_calendar(_calendar_source.text)
	if compact.is_empty():
		return
	if _calendar_mirror.text != compact:
		_calendar_mirror.text = compact


func _compact_calendar(value: String) -> String:
	var flattened := value.replace("·", " ")
	while flattened.contains("  "):
		flattened = flattened.replace("  ", " ")
	var regex := RegEx.new()
	if regex.compile("([0-9]+년\\s+[^\\s]+\\s+[0-9]+턴)") != OK:
		return ""
	var matched := regex.search(flattened)
	return matched.get_string(1).strip_edges() if matched != null else ""


func _sync_stability_pair(
	label_source: Label,
	label_mirror: Label,
	bar_source: ProgressBar,
	bar_mirror: ProgressBar,
	is_national: bool
) -> void:
	if label_source == null or label_mirror == null:
		return
	var value := _extract_optional_integer(label_source.text)
	if value < 0 and bar_source != null:
		value = int(round(bar_source.value))
	if value < 0:
		return
	var state := _stability_state(value)
	var text := "국가충성도 %d · %s" % [value, state] if is_national else "%d · %s" % [value, state]
	if label_mirror.text != text:
		label_mirror.text = text
	if bar_mirror != null:
		bar_mirror.value = value
		_apply_progress_fill_color(bar_mirror, _stability_color(state))


func _sync_role(assignment: OptionButton, mirror: Label) -> void:
	if mirror == null:
		return
	var hero_id := ""
	if assignment != null and assignment.selected >= 0 and assignment.selected < assignment.item_count:
		var metadata = assignment.get_item_metadata(assignment.selected)
		if metadata != null:
			hero_id = str(metadata).strip_edges()
	var summary := AdminRoleResolver.format_summary(hero_id) if not hero_id.is_empty() else ""
	mirror.text = summary
	mirror.visible = not summary.is_empty()


func _extract_optional_integer(text: String) -> int:
	var regex := RegEx.new()
	if regex.compile("([0-9]+)") != OK:
		return -1
	var matched := regex.search(text)
	return int(matched.get_string(1)) if matched != null else -1


func _stability_state(value: int) -> String:
	if value >= STABLE_THRESHOLD:
		return "안정"
	if value >= CAUTION_THRESHOLD:
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


func _apply_progress_fill_color(progress_bar: ProgressBar, color: Color) -> void:
	var source_style := progress_bar.get_theme_stylebox("fill")
	var fill_style: StyleBoxFlat = null
	if source_style is StyleBoxFlat:
		fill_style = source_style.duplicate() as StyleBoxFlat
	else:
		fill_style = StyleBoxFlat.new()
		fill_style.corner_radius_top_left = 99
		fill_style.corner_radius_top_right = 99
		fill_style.corner_radius_bottom_left = 99
		fill_style.corner_radius_bottom_right = 99
	fill_style.bg_color = color
	progress_bar.add_theme_stylebox_override("fill", fill_style)
