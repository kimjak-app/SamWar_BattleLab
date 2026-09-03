extends Node

const SPEECH_SCENE: PackedScene = preload("res://WorldMapCharacterSpeechPopup.tscn")

const CHANCELLOR_ASSIGN_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorAssignmentOption"
const CHANCELLOR_POLICY_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorPolicyOption"
const CHANCELLOR_DESCRIPTION_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/ChancellorPolicyDescriptionLabel"
const CHANCELLOR_NAME_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/Copy/ChancellorNameLabel"
const CHANCELLOR_PORTRAIT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/PortraitBox/ChancellorPortraitTexture"
const CHANCELLOR_FALLBACK_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/ChancellorCard/MarginContainer/Content/HeaderRow/PortraitBox/PortraitLabel"

const CITY_NAME_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/CityNameLabel"
const GOVERNOR_ASSIGN_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorAssignOption"
const GOVERNOR_POLICY_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorPolicyOption"
const GOVERNOR_DESCRIPTION_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/GovernorPolicyDescriptionLabel"
const GOVERNOR_NAME_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/Copy/GovernorNameLabel"
const GOVERNOR_PORTRAIT_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/PortraitBox/GovernorPortraitTexture"
const GOVERNOR_FALLBACK_PATH := "WorldMapUI/CityInfoPanel/MarginContainer/Content/GovernorCard/MarginContainer/Content/HeaderRow/PortraitBox/PortraitLabel"

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _popup: Control = null
var _last_chancellor_id := ""
var _last_governor_id := ""
var _last_chancellor_policy := ""
var _last_governor_policy := ""
var _installed := false


func _ready() -> void:
	process_priority = 1220
	set_process(true)
	call_deferred("_install")


func _process(_delta: float) -> void:
	if _installed:
		_hide_description_labels()


func _install() -> void:
	if production_world_map == null:
		return
	var world_ui := production_world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return
	_popup = SPEECH_SCENE.instantiate() as Control
	if _popup != null:
		_popup.name = "CharacterSpeechPopup"
		world_ui.add_child(_popup)

	_hide_description_labels()
	_connect_events()
	_capture_initial_state()
	_installed = true


func _hide_description_labels() -> void:
	for path in [CHANCELLOR_DESCRIPTION_PATH, GOVERNOR_DESCRIPTION_PATH]:
		var item := production_world_map.get_node_or_null(path) as CanvasItem
		if item != null:
			item.visible = false


func _connect_events() -> void:
	var chancellor_assign := production_world_map.get_node_or_null(CHANCELLOR_ASSIGN_PATH) as OptionButton
	var chancellor_policy := production_world_map.get_node_or_null(CHANCELLOR_POLICY_PATH) as OptionButton
	var governor_assign := production_world_map.get_node_or_null(GOVERNOR_ASSIGN_PATH) as OptionButton
	var governor_policy := production_world_map.get_node_or_null(GOVERNOR_POLICY_PATH) as OptionButton
	if chancellor_assign != null and not chancellor_assign.item_selected.is_connected(_on_chancellor_assignment_selected):
		chancellor_assign.item_selected.connect(_on_chancellor_assignment_selected)
	if chancellor_policy != null and not chancellor_policy.item_selected.is_connected(_on_chancellor_policy_selected):
		chancellor_policy.item_selected.connect(_on_chancellor_policy_selected)
	if governor_assign != null and not governor_assign.item_selected.is_connected(_on_governor_assignment_selected):
		governor_assign.item_selected.connect(_on_governor_assignment_selected)
	if governor_policy != null and not governor_policy.item_selected.is_connected(_on_governor_policy_selected):
		governor_policy.item_selected.connect(_on_governor_policy_selected)


func _capture_initial_state() -> void:
	_last_chancellor_id = _selected_metadata(production_world_map.get_node_or_null(CHANCELLOR_ASSIGN_PATH) as OptionButton)
	_last_governor_id = _selected_metadata(production_world_map.get_node_or_null(GOVERNOR_ASSIGN_PATH) as OptionButton)
	_last_chancellor_policy = _selected_metadata(production_world_map.get_node_or_null(CHANCELLOR_POLICY_PATH) as OptionButton)
	_last_governor_policy = _selected_metadata(production_world_map.get_node_or_null(GOVERNOR_POLICY_PATH) as OptionButton)


func _on_chancellor_assignment_selected(_index: int) -> void:
	call_deferred("_show_chancellor_assignment_if_changed")


func _on_governor_assignment_selected(_index: int) -> void:
	call_deferred("_show_governor_assignment_if_changed")


func _on_chancellor_policy_selected(_index: int) -> void:
	call_deferred("_show_chancellor_policy_if_changed")


func _on_governor_policy_selected(_index: int) -> void:
	call_deferred("_show_governor_policy_if_changed")


func _show_chancellor_assignment_if_changed() -> void:
	var option := production_world_map.get_node_or_null(CHANCELLOR_ASSIGN_PATH) as OptionButton
	var current := _selected_metadata(option)
	if current == _last_chancellor_id:
		return
	_last_chancellor_id = current
	if current.is_empty():
		return
	_show_character(
		"재상",
		_text_at(CHANCELLOR_NAME_PATH, _selected_text(option, "재상")),
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
	_show_character(
		"태수",
		_text_at(GOVERNOR_NAME_PATH, _selected_text(option, "태수")),
		GOVERNOR_PORTRAIT_PATH,
		GOVERNOR_FALLBACK_PATH,
		"맡겨 주십쇼. 이제 %s%s 제가 책임지겠습니다." % [city_name, _subject_particle(city_name)]
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
	_show_character(
		"재상",
		_text_at(CHANCELLOR_NAME_PATH, "재상"),
		CHANCELLOR_PORTRAIT_PATH,
		CHANCELLOR_FALLBACK_PATH,
		_build_policy_speech(option.get_item_text(option.selected), _text_at(CHANCELLOR_DESCRIPTION_PATH, ""), true)
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
	_show_character(
		"태수",
		_text_at(GOVERNOR_NAME_PATH, "태수"),
		GOVERNOR_PORTRAIT_PATH,
		GOVERNOR_FALLBACK_PATH,
		_build_policy_speech(option.get_item_text(option.selected), _text_at(GOVERNOR_DESCRIPTION_PATH, ""), false)
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
		return "%s%s 선택하시면 '%s' 효과가 적용됩니다. 정책은 %s" % [policy_name, particle, effect, _ensure_sentence(policy)]
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


func _show_character(role_text: String, character_name: String, portrait_path: String, fallback_path: String, speech: String) -> void:
	if _popup == null:
		return
	var portrait_node := production_world_map.get_node_or_null(portrait_path) as TextureRect
	var fallback_node := production_world_map.get_node_or_null(fallback_path) as Label
	var texture: Texture2D = portrait_node.texture if portrait_node != null else null
	var fallback := fallback_node.text if fallback_node != null else "?"
	if _popup.has_method("show_character"):
		_popup.call("show_character", texture, fallback, role_text, character_name, speech)


func _selected_metadata(option: OptionButton) -> String:
	if option == null or option.selected < 0 or option.selected >= option.item_count:
		return ""
	return str(option.get_item_metadata(option.selected))


func _selected_text(option: OptionButton, fallback: String) -> String:
	if option == null or option.selected < 0 or option.selected >= option.item_count:
		return fallback
	var value := option.get_item_text(option.selected).strip_edges()
	return value if not value.is_empty() else fallback


func _text_at(path: String, fallback: String) -> String:
	var label := production_world_map.get_node_or_null(path) as Label
	if label == null:
		return fallback
	var value := label.text.strip_edges()
	return value if not value.is_empty() else fallback


func _object_particle(value: String) -> String:
	return _particle_for(value, "을", "를")


func _subject_particle(value: String) -> String:
	return _particle_for(value, "은", "는")


func _particle_for(value: String, consonant_form: String, vowel_form: String) -> String:
	if value.is_empty():
		return consonant_form
	var code := value.unicode_at(value.length() - 1)
	if code >= 0xAC00 and code <= 0xD7A3:
		return consonant_form if ((code - 0xAC00) % 28) != 0 else vowel_form
	return consonant_form
