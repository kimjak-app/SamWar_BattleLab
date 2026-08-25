extends Node

const AdminRoleResolver := preload("res://scripts/worldmap/ui/worldmap_hero_admin_role_resolver.gd")

const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const RIGHT_PANEL_PATH := "WorldMapUI/CityInfoPanel"
const CALENDAR_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/CalendarLabel"
const CHANCELLOR_CARD_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard"
const CHANCELLOR_ASSIGNMENT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorAssignmentOption"

const FONT_DELTA := 3
const FONT_BASE_META := "w2_a12_font_base"
const PROFILE_OPTION_BASE_META := "w2_a12_profile_option_base"
const PROFILE_OPTION_FONT_SIZE := 14
const CHANCELLOR_PORTRAIT_SIZE := Vector2(78.0, 88.0)
const GOVERNOR_PORTRAIT_SIZE := Vector2(64.0, 72.0)
const TYPOGRAPHY_EXCLUDED_SUBTREES := {
	"CompactGarrisonScroll": true,
	"CompactGarrisonGrid": true,
	"WarehouseTabsCard": true,
}

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _left_panel: Control = null
var _right_panel: Control = null
var _installed := false


func _ready() -> void:
	# W2-A14: presentation is finalized by the single pre-draw coordinator.
	# Do not mutate the same HUD again in an independent per-frame _process loop.
	set_process(false)
	call_deferred("_install")


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap Readability: ProductionWorldMap is missing.")
		return
	_left_panel = production_world_map.get_node_or_null(LEFT_PANEL_PATH) as Control
	_right_panel = production_world_map.get_node_or_null(RIGHT_PANEL_PATH) as Control
	_compact_calendar_text()
	_apply_panel_typography()
	_refine_chancellor_card()
	_refine_governor_card()
	_request_initial_refit()
	_installed = true


func _request_initial_refit() -> void:
	# One startup fit is enough. Runtime tab/data changes must not resize the HUD.
	var host := get_parent()
	if host != null and host.has_method("_fit_compact_panels"):
		host.call_deferred("_fit_compact_panels")


func _compact_calendar_text() -> void:
	var calendar := production_world_map.get_node_or_null(CALENDAR_LABEL_PATH) as Label
	if calendar == null:
		return
	var flattened := calendar.text.replace("·", " ")
	while flattened.contains("  "):
		flattened = flattened.replace("  ", " ")
	var regex := RegEx.new()
	if regex.compile("([0-9]+년\\s+[^\\s]+\\s+[0-9]+턴)") != OK:
		return
	var matched := regex.search(flattened)
	if matched != null:
		calendar.text = matched.get_string(1).strip_edges()


func _apply_panel_typography() -> void:
	if _left_panel != null and is_instance_valid(_left_panel):
		_apply_font_delta_recursive(_left_panel)
	if _right_panel != null and is_instance_valid(_right_panel):
		_apply_font_delta_recursive(_right_panel)


func _apply_font_delta_recursive(node: Node) -> void:
	if TYPOGRAPHY_EXCLUDED_SUBTREES.has(str(node.name)):
		return
	if node is Label:
		var label := node as Label
		if not str(label.name).contains("PortraitLabel") and not str(label.name).contains("PortraitFallback"):
			_apply_font_delta(label)
	elif node is Button and not node is OptionButton:
		_apply_font_delta(node as Button)
	for child in node.get_children():
		_apply_font_delta_recursive(child)


func _apply_font_delta(control: Control) -> void:
	if not control.has_meta(FONT_BASE_META):
		control.set_meta(FONT_BASE_META, control.get_theme_font_size("font_size"))
	var base_size := int(control.get_meta(FONT_BASE_META))
	control.add_theme_font_size_override("font_size", maxi(1, base_size + FONT_DELTA))


func _apply_profile_option_size(option: OptionButton) -> void:
	if option == null:
		return
	if not option.has_meta(PROFILE_OPTION_BASE_META):
		option.set_meta(PROFILE_OPTION_BASE_META, option.get_theme_font_size("font_size"))
	option.add_theme_font_size_override("font_size", PROFILE_OPTION_FONT_SIZE)
	var popup := option.get_popup()
	if popup != null:
		popup.add_theme_font_size_override("font_size", PROFILE_OPTION_FONT_SIZE)


func _refine_chancellor_card() -> void:
	var card := production_world_map.get_node_or_null(CHANCELLOR_CARD_PATH)
	if card == null:
		return
	var assignment := production_world_map.get_node_or_null(CHANCELLOR_ASSIGNMENT_PATH) as OptionButton
	var policy := card.find_child("ChancellorPolicyOption", true, false) as OptionButton
	_refine_profile_card(card, assignment, policy, "ChancellorStatsLabel", CHANCELLOR_PORTRAIT_SIZE)


func _refine_governor_card() -> void:
	if _right_panel == null:
		return
	var card := _right_panel.find_child("GovernorCard", true, false)
	if card == null:
		return
	var assignment := card.find_child("GovernorAssignOption", true, false) as OptionButton
	if assignment == null:
		assignment = _right_panel.find_child("GovernorAssignOption", true, false) as OptionButton
	var policy := card.find_child("GovernorPolicyOption", true, false) as OptionButton
	if policy == null:
		policy = _right_panel.find_child("GovernorPolicyOption", true, false) as OptionButton
	_refine_profile_card(card, assignment, policy, "GovernorStatsLabel", GOVERNOR_PORTRAIT_SIZE)


func _refine_profile_card(
	card: Node,
	assignment: OptionButton,
	policy: OptionButton,
	role_label_name: String,
	portrait_size: Vector2
) -> void:
	_apply_profile_option_size(assignment)
	_apply_profile_option_size(policy)

	var selected_name := ""
	var selected_hero_id := ""
	if assignment != null and assignment.selected >= 0 and assignment.selected < assignment.item_count:
		selected_name = assignment.get_item_text(assignment.selected).strip_edges()
		var metadata = assignment.get_item_metadata(assignment.selected)
		if metadata != null:
			selected_hero_id = str(metadata).strip_edges()

	var role_label := card.find_child(role_label_name, true, false) as Label
	if role_label != null:
		if selected_hero_id.is_empty():
			role_label.text = ""
			role_label.visible = false
		else:
			role_label.text = AdminRoleResolver.format_summary(selected_hero_id)
			role_label.visible = not role_label.text.is_empty()
			_apply_font_delta(role_label)

	var labels: Array[Label] = []
	_collect_labels(card, labels)
	for label in labels:
		if label == role_label:
			continue
		var text := label.text.strip_edges()
		if str(label.name).ends_with("NameLabel"):
			label.visible = false
			continue
		if not selected_name.is_empty() and text == selected_name:
			label.visible = false
			continue
		if _looks_like_raw_hero_stats(text):
			label.visible = false
			continue
		if _is_role_summary(text):
			label.visible = true
			_apply_font_delta(label)

	var portrait_box := _find_control_by_name(card, "PortraitBox")
	if portrait_box == null:
		portrait_box = _find_control_name_contains(card, "PortraitFrame")
	if portrait_box != null:
		portrait_box.custom_minimum_size = portrait_size

	var portrait_texture := _find_portrait_texture(card)
	if portrait_texture != null:
		portrait_texture.custom_minimum_size = portrait_size


func _looks_like_raw_hero_stats(text: String) -> bool:
	if text.is_empty():
		return false
	var stat_hits := 0
	for token in ["지휘", "무", "지", "정", "충"]:
		if text.contains(token):
			stat_hits += 1
	return stat_hits >= 3 or (text.contains("지휘") and text.contains("/"))


func _is_role_summary(text: String) -> bool:
	return text.begins_with("주:") or text.contains("\n주:") or text.contains("보조:")


func _collect_labels(node: Node, output: Array[Label]) -> void:
	if node is Label:
		output.append(node as Label)
	for child in node.get_children():
		_collect_labels(child, output)


func _find_control_by_name(node: Node, target_name: String) -> Control:
	if node is Control and str(node.name) == target_name:
		return node as Control
	for child in node.get_children():
		var found := _find_control_by_name(child, target_name)
		if found != null:
			return found
	return null


func _find_control_name_contains(node: Node, token: String) -> Control:
	if node is Control and str(node.name).contains(token):
		return node as Control
	for child in node.get_children():
		var found := _find_control_name_contains(child, token)
		if found != null:
			return found
	return null


func _find_portrait_texture(node: Node) -> TextureRect:
	if node is TextureRect and str(node.name).contains("Portrait"):
		return node as TextureRect
	for child in node.get_children():
		var found := _find_portrait_texture(child)
		if found != null:
			return found
	return null
