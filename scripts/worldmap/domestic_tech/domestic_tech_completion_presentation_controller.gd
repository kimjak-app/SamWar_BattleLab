class_name WorldMapDomesticTechCompletionPresentationController
extends Node

signal presentation_completed(result: Dictionary)
signal presentation_queue_empty(result: Dictionary)
signal sfx_requested(sfx_id: String)

const DomesticTechCatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")
const DOMESTIC_TECH_SCOPE_CITY := DomesticTechCatalogScript.DOMESTIC_TECH_SCOPE_CITY
const DOMESTIC_TECH_SCOPE_NATIONAL := DomesticTechCatalogScript.DOMESTIC_TECH_SCOPE_NATIONAL
const DOMESTIC_TECH_CATEGORY_AGRI := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_AGRI
const DOMESTIC_TECH_CATEGORY_FISH := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_FISH
const DOMESTIC_TECH_CATEGORY_COMMERCE := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_COMMERCE
const DOMESTIC_TECH_CATEGORY_MILITARY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_MILITARY
const DOMESTIC_TECH_CATEGORY_NATION_ADMIN := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_ADMIN
const DOMESTIC_TECH_CATEGORY_NATION_ECONOMY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_ECONOMY
const DOMESTIC_TECH_CATEGORY_NATION_MILITARY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_MILITARY
const DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY := DomesticTechCatalogScript.DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY
const DOMESTIC_TECH_COMPLETION_NATIONAL_VIDEO_PATH := "res://assets/ui/research/videos/research_completion_national_theora_q8_1920x1080.ogv"
const DOMESTIC_TECH_COMPLETION_CITY_VIDEO_PATH := "res://assets/ui/research/videos/research_completion_city_theora_q8_1920x1080.ogv"
const DOMESTIC_TECH_COMPLETION_VIDEO_FALLBACK_DURATION_SEC := 6.75
const DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_WIDTH_RATIO := 0.88
const DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_HEIGHT_RATIO := 9.0 / 16.0
const DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_MAX_HEIGHT_RATIO := 0.60

var _ui_parent: Node
var _callbacks: Dictionary = {}
var _effect_provider: RefCounted
var _domestic_tech_completion_presentation_queue: Array[Dictionary] = []
var _domestic_tech_completion_presentation_active := false
var _domestic_tech_completion_video_completion_handled := false
var _domestic_tech_completion_current_item: Dictionary = {}
var _queued_or_active_completion_ids: Dictionary = {}
var _finish_guard := false
var _queue_empty_emitted := true
var _domestic_tech_completion_layer: CanvasLayer
var _domestic_tech_completion_root: Control
var _domestic_tech_completion_backdrop: ColorRect
var _domestic_tech_completion_video_player: VideoStreamPlayer
var _domestic_tech_completion_card: PanelContainer
var _domestic_tech_completion_icon: TextureRect
var _domestic_tech_completion_scope_label: Label
var _domestic_tech_completion_title_label: Label
var _domestic_tech_completion_message_label: Label
var _domestic_tech_completion_effect_label: RichTextLabel
var _domestic_tech_completion_confirm_button: Button


func configure(ui_parent: Node, callbacks: Dictionary, effect_provider: RefCounted) -> void:
	_ui_parent = ui_parent
	_callbacks = callbacks.duplicate()
	_effect_provider = effect_provider


func ensure_overlay() -> void:
	_ensure_domestic_tech_completion_presentation_overlay()


func enqueue(completed_events: Variant) -> void:
	_enqueue_domestic_tech_completion_presentations_mvp(completed_events)


func play_next() -> void:
	_play_next_domestic_tech_completion_presentation()


func is_card_visible() -> bool:
	return _is_domestic_tech_completion_card_visible()


func confirm() -> void:
	_on_domestic_tech_completion_confirm_pressed()


func handles_confirm_event(event: InputEvent) -> bool:
	return _is_domestic_tech_completion_space_confirm_event(event)


func get_state_snapshot() -> Dictionary:
	return {
		"queue": _domestic_tech_completion_presentation_queue.duplicate(true),
		"active": _domestic_tech_completion_presentation_active,
		"current_item": _domestic_tech_completion_current_item.duplicate(true),
		"video_completion_handled": _domestic_tech_completion_video_completion_handled,
		"card_visible": _is_domestic_tech_completion_card_visible(),
	}


func _call(callback_id: String, args: Array = [], fallback: Variant = null) -> Variant:
	var callback_variant: Variant = _callbacks.get(callback_id)
	if callback_variant is Callable and (callback_variant as Callable).is_valid():
		return (callback_variant as Callable).callv(args)
	return fallback


func _ensure_domestic_tech_effect_provider() -> RefCounted:
	return _effect_provider


func _get_domestic_tech_categories_mvp() -> Dictionary:
	return _call("categories", [], {}) as Dictionary


func _get_domestic_tech_definition_mvp(tech_id: String) -> Dictionary:
	return _call("definition", [tech_id], {}) as Dictionary


func _get_domestic_tech_resolved_icon_path_mvp(tech_id: String, definition_icon_path: String = "") -> String:
	return str(_call("resolved_icon_path", [tech_id, definition_icon_path], ""))


func _format_city_name_by_id(city_id: String, fallback: String = "") -> String:
	return str(_call("format_city_name", [city_id, fallback], fallback))


func _is_city_owned_by_player_mvp(city_id: String) -> bool:
	return bool(_call("city_owned", [city_id], false))


func _format_domestic_tech_percent_bonus_mvp(value: float) -> String:
	return str(_call("format_percent", [value], ""))


func _format_signed_int(value: int) -> String:
	return str(_call("format_signed_int", [value], str(value)))


func _play_worldmap_sfx(sfx_id: String) -> void:
	sfx_requested.emit(sfx_id)
	var callback_variant: Variant = _callbacks.get("play_sfx")
	if callback_variant is Callable and (callback_variant as Callable).is_valid():
		(callback_variant as Callable).call(sfx_id)

func _ensure_domestic_tech_completion_presentation_overlay() -> void:
	if _domestic_tech_completion_layer != null:
		return
	_domestic_tech_completion_layer = CanvasLayer.new()
	_domestic_tech_completion_layer.name = "DomesticTechCompletionLayer"
	_domestic_tech_completion_layer.layer = 80
	_ui_parent.add_child(_domestic_tech_completion_layer)

	_domestic_tech_completion_root = Control.new()
	_domestic_tech_completion_root.name = "DomesticTechCompletionRoot"
	_domestic_tech_completion_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_domestic_tech_completion_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_domestic_tech_completion_root.visible = false
	_domestic_tech_completion_layer.add_child(_domestic_tech_completion_root)

	_domestic_tech_completion_backdrop = ColorRect.new()
	_domestic_tech_completion_backdrop.name = "DimBackdrop"
	_domestic_tech_completion_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_domestic_tech_completion_backdrop.color = Color(0.0, 0.0, 0.0, 0.72)
	_domestic_tech_completion_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_domestic_tech_completion_root.add_child(_domestic_tech_completion_backdrop)

	_domestic_tech_completion_video_player = VideoStreamPlayer.new()
	_domestic_tech_completion_video_player.name = "VideoStreamPlayer_DomesticTechCompletion"
	_domestic_tech_completion_video_player.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_domestic_tech_completion_video_player.expand = true
	_domestic_tech_completion_video_player.visible = false
	_domestic_tech_completion_video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_domestic_tech_completion_video_player.finished.connect(_on_domestic_tech_completion_video_finished)
	_domestic_tech_completion_root.add_child(_domestic_tech_completion_video_player)

	_domestic_tech_completion_card = PanelContainer.new()
	_domestic_tech_completion_card.name = "CompletionCard"
	_domestic_tech_completion_card.visible = false
	_domestic_tech_completion_card.mouse_filter = Control.MOUSE_FILTER_STOP
	_domestic_tech_completion_card.add_theme_stylebox_override("panel", _make_domestic_tech_completion_card_style_mvp())
	_domestic_tech_completion_root.add_child(_domestic_tech_completion_card)

	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 22)
	card_margin.add_theme_constant_override("margin_top", 20)
	card_margin.add_theme_constant_override("margin_right", 22)
	card_margin.add_theme_constant_override("margin_bottom", 18)
	_domestic_tech_completion_card.add_child(card_margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	card_margin.add_child(content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	content.add_child(header)

	_domestic_tech_completion_icon = TextureRect.new()
	_domestic_tech_completion_icon.custom_minimum_size = Vector2(64.0, 64.0)
	_domestic_tech_completion_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_domestic_tech_completion_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header.add_child(_domestic_tech_completion_icon)

	var header_text := VBoxContainer.new()
	header_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_text.add_theme_constant_override("separation", 4)
	header.add_child(header_text)

	_domestic_tech_completion_scope_label = _make_domestic_tech_label_mvp("", 15, Color(0.95, 0.80, 0.48, 1.0))
	header_text.add_child(_domestic_tech_completion_scope_label)

	_domestic_tech_completion_title_label = _make_domestic_tech_label_mvp("", 22, Color(1.0, 0.96, 0.84, 1.0))
	header_text.add_child(_domestic_tech_completion_title_label)

	_domestic_tech_completion_message_label = _make_domestic_tech_label_mvp("", 15, Color(0.92, 0.93, 0.90, 1.0))
	content.add_child(_domestic_tech_completion_message_label)

	_domestic_tech_completion_effect_label = RichTextLabel.new()
	_domestic_tech_completion_effect_label.name = "EffectSummary"
	_domestic_tech_completion_effect_label.custom_minimum_size = Vector2(420.0, 92.0)
	_domestic_tech_completion_effect_label.fit_content = true
	_domestic_tech_completion_effect_label.bbcode_enabled = false
	_domestic_tech_completion_effect_label.scroll_active = false
	_domestic_tech_completion_effect_label.add_theme_font_size_override("normal_font_size", 14)
	_domestic_tech_completion_effect_label.add_theme_color_override("default_color", Color(0.86, 0.88, 0.82, 1.0))
	content.add_child(_domestic_tech_completion_effect_label)

	_domestic_tech_completion_confirm_button = Button.new()
	_domestic_tech_completion_confirm_button.name = "ConfirmButton"
	_domestic_tech_completion_confirm_button.text = "확인"
	_domestic_tech_completion_confirm_button.custom_minimum_size = Vector2(128.0, 38.0)
	_domestic_tech_completion_confirm_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_domestic_tech_completion_confirm_button.pressed.connect(_on_domestic_tech_completion_confirm_pressed)
	content.add_child(_domestic_tech_completion_confirm_button)
	_layout_domestic_tech_completion_presentation_overlay()


func _make_domestic_tech_completion_card_style_mvp() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.052, 0.045, 0.96)
	style.border_color = Color(0.76, 0.57, 0.28, 0.95)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style


func _layout_domestic_tech_completion_presentation_overlay() -> void:
	if _domestic_tech_completion_card == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if _domestic_tech_completion_video_player != null:
		var video_panel_rect := _get_domestic_tech_completion_video_panel_rect_mvp(viewport_size)
		_domestic_tech_completion_video_player.position = video_panel_rect.position
		_domestic_tech_completion_video_player.size = video_panel_rect.size
		_domestic_tech_completion_video_player.custom_minimum_size = video_panel_rect.size
	var card_size := Vector2(minf(560.0, maxf(360.0, viewport_size.x - 48.0)), 300.0)
	_domestic_tech_completion_card.size = card_size
	_domestic_tech_completion_card.position = (viewport_size - card_size) * 0.5


func _get_domestic_tech_completion_video_panel_rect_mvp(viewport_size: Vector2) -> Rect2:
	var viewport_margin := 24.0
	var max_width = max(0.0, viewport_size.x - viewport_margin * 2.0)
	var max_height = max(0.0, viewport_size.y * DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_MAX_HEIGHT_RATIO)
	var panel_width = min(viewport_size.x * DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_WIDTH_RATIO, max_width)
	var panel_height = panel_width * DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_HEIGHT_RATIO
	if panel_height > max_height:
		panel_height = max_height
		panel_width = panel_height / DOMESTIC_TECH_COMPLETION_VIDEO_PANEL_HEIGHT_RATIO
	var panel_size := Vector2(panel_width, panel_height)
	var panel_position := (viewport_size - panel_size) * 0.5
	return Rect2(panel_position, panel_size)


func _enqueue_domestic_tech_completion_presentations_mvp(completed_events: Variant) -> void:
	if not completed_events is Array:
		return
	for event_variant in completed_events:
		if not event_variant is Dictionary:
			continue
		var item := _make_domestic_tech_completion_presentation_item_mvp(event_variant as Dictionary)
		if item.is_empty():
			continue
		var presentation_id := _get_completion_presentation_identity(item)
		if presentation_id.is_empty() or _queued_or_active_completion_ids.has(presentation_id):
			continue
		_queued_or_active_completion_ids[presentation_id] = true
		_domestic_tech_completion_presentation_queue.append(item)
	if not _domestic_tech_completion_presentation_queue.is_empty():
		_queue_empty_emitted = false
		call_deferred("_play_next_domestic_tech_completion_presentation")


func _get_completion_presentation_identity(item: Dictionary) -> String:
	var tech_id := str(item.get("tech_id", ""))
	var scope := str(item.get("scope", ""))
	if tech_id.is_empty() or scope.is_empty():
		return ""
	return "%s|%s|%s" % [scope, str(item.get("city_id", "")), tech_id]


func _make_domestic_tech_completion_presentation_item_mvp(event: Dictionary) -> Dictionary:
	if not bool(event.get("completed", false)):
		return {}
	var scope := str(event.get("type", ""))
	if scope != DOMESTIC_TECH_SCOPE_NATIONAL and scope != DOMESTIC_TECH_SCOPE_CITY:
		return {}
	var tech_id := str(event.get("tech_id", ""))
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	if tech_id.is_empty() or definition.is_empty():
		return {}
	if scope == DOMESTIC_TECH_SCOPE_CITY:
		var city_id_for_check := str(event.get("city_id", ""))
		if not _is_city_owned_by_player_mvp(city_id_for_check):
			return {}
	var category_id := str(definition.get("category", ""))
	var category_data: Dictionary = _get_domestic_tech_categories_mvp().get(category_id, {})
	var category_name := str(category_data.get("name", category_id))
	var tech_name := str(definition.get("name", tech_id))
	var city_id := str(event.get("city_id", ""))
	var city_name := _format_city_name_by_id(city_id, city_id) if scope == DOMESTIC_TECH_SCOPE_CITY else ""
	var message := "%s 연구가 끝났습니다." % tech_name
	if scope == DOMESTIC_TECH_SCOPE_CITY:
		message = "%s의 %s 연구가 끝났습니다." % [city_name, tech_name]
	var effect_summary := _get_domestic_tech_completion_effect_summary_mvp(tech_id, scope, city_id)
	return {
		"scope": scope,
		"city_id": city_id,
		"city_name": city_name,
		"tech_id": tech_id,
		"tech_name": tech_name,
		"category_name": category_name,
		"icon_path": _get_domestic_tech_resolved_icon_path_mvp(tech_id, str(definition.get("icon_path", ""))),
		"message": message,
		"effect_summary": effect_summary,
		"video_path": _get_domestic_tech_completion_video_path_mvp(scope),
	}


func _get_domestic_tech_completion_effect_summary_mvp(tech_id: String, scope: String, city_id: String = "") -> String:
	var definition := _get_domestic_tech_definition_mvp(tech_id)
	if tech_id.is_empty() or definition.is_empty():
		return "내정 연구 효과 표시 정보를 확인할 수 없습니다.\n적용 범위 확인이 필요합니다."
	var city_name := _format_city_name_by_id(city_id, city_id) if scope == DOMESTIC_TECH_SCOPE_CITY else ""
	var lines := _get_domestic_tech_completion_direct_effect_lines_mvp(tech_id, definition, scope, city_name)
	if lines.is_empty():
		var effect_stub: Dictionary = definition.get("effect_stub", {})
		var effect_description := str(effect_stub.get("description", "")).strip_edges()
		if not effect_description.is_empty():
			lines.append(effect_description)
	if lines.is_empty():
		lines.append_array(_get_domestic_tech_completion_category_fallback_lines_mvp(definition, scope, city_name))
	if scope == DOMESTIC_TECH_SCOPE_CITY and not lines.has("해당 도시에서만 적용됩니다."):
		lines.append("해당 도시에서만 적용됩니다.")
	elif scope == DOMESTIC_TECH_SCOPE_NATIONAL and not lines.has("PLAYER 국가 전체에 적용됩니다."):
		lines.append("PLAYER 국가 전체에 적용됩니다.")
	return "\n- ".join(lines.slice(0, 4))


func _get_domestic_tech_completion_direct_effect_lines_mvp(tech_id: String, definition: Dictionary, scope: String, city_name: String) -> Array[String]:
	var lines: Array[String] = []
	var category_id := str(definition.get("category", ""))
	var branch_id := str(definition.get("branch", ""))
	var city_prefix := "%s " % city_name if not city_name.is_empty() else ""
	if scope == DOMESTIC_TECH_SCOPE_CITY:
		if _ensure_domestic_tech_effect_provider().has_effect_mapping("economy", tech_id):
			var economy_mapping: Dictionary = _ensure_domestic_tech_effect_provider().get_effect_mapping("economy", tech_id)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s군량 생산" % city_prefix, float(economy_mapping.get("food_percent", 0.0)), int(economy_mapping.get("food_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "%s금전 수입" % city_prefix, float(economy_mapping.get("gold_percent", 0.0)), int(economy_mapping.get("gold_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "%s보급/저장 기반" % city_prefix, float(economy_mapping.get("supply_percent", 0.0)), int(economy_mapping.get("supply_flat", 0)))
		if _ensure_domestic_tech_effect_provider().has_effect_mapping("military_defense", tech_id):
			var military_mapping: Dictionary = _ensure_domestic_tech_effect_provider().get_effect_mapping("military_defense", tech_id)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s도시 방어" % city_prefix, float(military_mapping.get("defense_percent", 0.0)), int(military_mapping.get("defense_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "%s모집 기반" % city_prefix, 0.0, int(military_mapping.get("recruit_capacity_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "%s보병 전투 기반" % city_prefix, float(military_mapping.get("infantry_training_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s궁병 전투 기반" % city_prefix, float(military_mapping.get("archer_training_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s기병 전투 기반" % city_prefix, float(military_mapping.get("cavalry_training_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s기병 돌격" % city_prefix, float(military_mapping.get("cavalry_charge_percent", 0.0)), 0)
		if _ensure_domestic_tech_effect_provider().has_effect_mapping("naval_siege", tech_id):
			var naval_siege_mapping: Dictionary = _ensure_domestic_tech_effect_provider().get_effect_mapping("naval_siege", tech_id)
			_append_domestic_tech_completion_city_unlock_lines_mvp(lines, tech_id)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s조선 준비" % city_prefix, 0.0, int(naval_siege_mapping.get("shipyard_capacity_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "%s수군 전투 기반" % city_prefix, float(naval_siege_mapping.get("naval_training_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s해상 보급" % city_prefix, float(naval_siege_mapping.get("naval_supply_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s함선 정비" % city_prefix, float(naval_siege_mapping.get("ship_maintenance_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s공성 준비" % city_prefix, 0.0, int(naval_siege_mapping.get("siege_preparation_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "%s공성 훈련" % city_prefix, float(naval_siege_mapping.get("siege_training_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "%s공성 공학" % city_prefix, float(naval_siege_mapping.get("siege_engineering_percent", 0.0)), 0)
	elif scope == DOMESTIC_TECH_SCOPE_NATIONAL:
		if _ensure_domestic_tech_effect_provider().has_effect_mapping("national_policy", tech_id):
			var policy_mapping: Dictionary = _ensure_domestic_tech_effect_provider().get_effect_mapping("national_policy", tech_id)
			_append_domestic_tech_completion_value_line_mvp(lines, "국가 세금 수입", float(policy_mapping.get("tax_gold_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "국가 행정 효율", float(policy_mapping.get("admin_efficiency_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "국가 징병 기반", float(policy_mapping.get("recruit_capacity_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "국가 병참 준비", float(policy_mapping.get("logistics_supply_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "국가 인구 기반", float(policy_mapping.get("population_growth_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "국가 비축 기반", 0.0, int(policy_mapping.get("storage_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "국가 질서 기반", 0.0, int(policy_mapping.get("law_order_flat", 0)))
		if _ensure_domestic_tech_effect_provider().has_effect_mapping("national_battle", tech_id):
			var battle_mapping: Dictionary = _ensure_domestic_tech_effect_provider().get_effect_mapping("national_battle", tech_id)
			_append_domestic_tech_completion_value_line_mvp(lines, "PLAYER 전군 공격", float(battle_mapping.get("global_attack_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "PLAYER 전군 방어", float(battle_mapping.get("global_defense_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "PLAYER 병참", float(battle_mapping.get("logistics_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "PLAYER 공성 공격", float(battle_mapping.get("siege_attack_percent", 0.0)), 0)
		if _ensure_domestic_tech_effect_provider().has_effect_mapping("diplomacy_spy", tech_id):
			var diplomacy_spy_mapping: Dictionary = _ensure_domestic_tech_effect_provider().get_effect_mapping("diplomacy_spy", tech_id)
			_append_domestic_tech_completion_value_line_mvp(lines, "외교 기반", 0.0, int(diplomacy_spy_mapping.get("diplomacy_influence_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "외교 성공 준비", float(diplomacy_spy_mapping.get("diplomacy_preparation_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "조공 외교 준비", float(diplomacy_spy_mapping.get("tribute_readiness_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "대외 외교 기반", float(diplomacy_spy_mapping.get("world_diplomacy_display_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "첩보망", 0.0, int(diplomacy_spy_mapping.get("spy_network_flat", 0)))
			_append_domestic_tech_completion_value_line_mvp(lines, "첩보 성공 준비", float(diplomacy_spy_mapping.get("spy_preparation_percent", 0.0)), 0)
			_append_domestic_tech_completion_value_line_mvp(lines, "발각 위험", -float(diplomacy_spy_mapping.get("counter_intel_display_percent", 0.0)), 0)
		_append_domestic_tech_completion_national_unlock_lines_mvp(lines, tech_id, category_id, branch_id)
	return _get_unique_domestic_tech_completion_lines_mvp(lines)


func _append_domestic_tech_completion_value_line_mvp(lines: Array[String], label: String, percent_value: float, flat_value: int) -> void:
	if not is_equal_approx(percent_value, 0.0):
		lines.append("%s %s" % [label, _format_domestic_tech_percent_bonus_mvp(percent_value)])
	if flat_value != 0:
		lines.append("%s %s" % [label, _format_signed_int(flat_value)])


func _append_domestic_tech_completion_city_unlock_lines_mvp(lines: Array[String], tech_id: String) -> void:
	match tech_id:
		"commerce_port":
			lines.append("항구/무역선 사용 가능")
		"commerce_shipyard":
			lines.append("조선소/소형 함선 사용 가능")
		"commerce_trade_port":
			lines.append("해상 무역 루트 조건 활성화")
		"naval_warship_building":
			lines.append("전투선 생산 가능")
		"naval_panokseon":
			lines.append("판옥선 생산 가능")
		"naval_turtle_ship":
			lines.append("거북선 생산 가능")
		"naval_crane_wing_formation":
			lines.append("수군 진형 보정 활성화")
		"naval_fire_ship":
			lines.append("화공선 사용 가능")
		"naval_cannon_mount":
			lines.append("화포/원거리 해상 공격 조건 활성화")
		"mil_siege_unit":
			lines.append("공성부대 편성 가능")
		"mil_siege_engine":
			lines.append("공성병기 사용 가능")


func _append_domestic_tech_completion_national_unlock_lines_mvp(lines: Array[String], tech_id: String, category_id: String, branch_id: String) -> void:
	match tech_id:
		"nation_logistics_system":
			lines.append("원정 병참 조건에 반영됩니다.")
		"nation_expedition_system":
			lines.append("장거리 원정 조건에 반영됩니다.")
		"nation_military_reform":
			lines.append("고급 군사/해군 해금 조건에 반영됩니다.")
		"nation_weapon_factory":
			lines.append("화포/공성 관련 해금 조건에 반영됩니다.")
		_:
			if category_id == DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY and branch_id == "intelligence":
				lines.append("정보 확인/첩보 계산에 반영됩니다.")


func _get_domestic_tech_completion_category_fallback_lines_mvp(definition: Dictionary, scope: String, city_name: String) -> Array[String]:
	var category_id := str(definition.get("category", ""))
	var branch_id := str(definition.get("branch", ""))
	var city_prefix := "%s의 " % city_name if not city_name.is_empty() else ""
	if scope == DOMESTIC_TECH_SCOPE_CITY:
		match category_id:
			DOMESTIC_TECH_CATEGORY_AGRI:
				return ["%s농업/군량 생산 보정이 활성화되었습니다." % city_prefix]
			DOMESTIC_TECH_CATEGORY_FISH:
				return ["%s수산/항구 보정이 활성화되었습니다." % city_prefix]
			DOMESTIC_TECH_CATEGORY_COMMERCE:
				return ["%s상업/금 수입 보정이 활성화되었습니다." % city_prefix]
			DOMESTIC_TECH_CATEGORY_MILITARY:
				if branch_id == "defense":
					return ["%s도시 방어 보정이 활성화되었습니다." % city_prefix, "해당 도시 방어 계산에 반영됩니다."]
				if branch_id == "naval" or branch_id == "siege":
					return ["%s해군/공성 관련 해금 조건이 활성화되었습니다." % city_prefix, "생산/편성/공격 가능 조건에 반영됩니다."]
				return ["%s군사/전투 보정이 활성화되었습니다." % city_prefix]
		return ["%s도시 내정 보정이 활성화되었습니다." % city_prefix]
	match category_id:
		DOMESTIC_TECH_CATEGORY_NATION_ADMIN:
			return ["국가 행정/운영 보정이 활성화되었습니다."]
		DOMESTIC_TECH_CATEGORY_NATION_ECONOMY:
			return ["국가 경제/세금 보정이 활성화되었습니다."]
		DOMESTIC_TECH_CATEGORY_NATION_MILITARY:
			return ["국가 군사/전투 보정이 활성화되었습니다.", "PLAYER 전투 계산에 반영됩니다."]
		DOMESTIC_TECH_CATEGORY_NATION_DIPLOMACY:
			return ["외교/첩보 보정이 활성화되었습니다.", "성공률/발각률/정보 확인 계산에 반영됩니다."]
	return ["국가 내정 보정이 활성화되었습니다."]


func _get_unique_domestic_tech_completion_lines_mvp(lines: Array[String]) -> Array[String]:
	var result: Array[String] = []
	var seen := {}
	for line in lines:
		var clean_line := str(line).strip_edges()
		if clean_line.is_empty() or seen.has(clean_line):
			continue
		seen[clean_line] = true
		result.append(clean_line)
	return result


func _get_domestic_tech_completion_video_path_mvp(scope: String) -> String:
	if scope == DOMESTIC_TECH_SCOPE_NATIONAL:
		return DOMESTIC_TECH_COMPLETION_NATIONAL_VIDEO_PATH
	if scope == DOMESTIC_TECH_SCOPE_CITY:
		return DOMESTIC_TECH_COMPLETION_CITY_VIDEO_PATH
	return ""


func _play_next_domestic_tech_completion_presentation() -> void:
	if _domestic_tech_completion_presentation_active:
		return
	if _domestic_tech_completion_presentation_queue.is_empty():
		_hide_domestic_tech_completion_presentation_overlay()
		if not _queue_empty_emitted:
			_queue_empty_emitted = true
			presentation_queue_empty.emit({"completed": true})
		return
	_ensure_domestic_tech_completion_presentation_overlay()
	_layout_domestic_tech_completion_presentation_overlay()
	_domestic_tech_completion_current_item = _domestic_tech_completion_presentation_queue.pop_front()
	_domestic_tech_completion_presentation_active = true
	_domestic_tech_completion_video_completion_handled = false
	_finish_guard = false
	if not _play_domestic_tech_completion_video_mvp(_domestic_tech_completion_current_item):
		_show_domestic_tech_completion_card_mvp(_domestic_tech_completion_current_item)


func _play_domestic_tech_completion_video_mvp(item: Dictionary) -> bool:
	if _domestic_tech_completion_video_player == null:
		return false
	var video_path := str(item.get("video_path", ""))
	if not _assign_domestic_tech_completion_video_stream_mvp(video_path):
		return false
	if _domestic_tech_completion_root != null:
		_domestic_tech_completion_root.visible = true
	if _domestic_tech_completion_backdrop != null:
		_domestic_tech_completion_backdrop.visible = true
	if _domestic_tech_completion_card != null:
		_domestic_tech_completion_card.visible = false
	_domestic_tech_completion_video_player.visible = true
	_domestic_tech_completion_video_player.play()
	get_tree().create_timer(DOMESTIC_TECH_COMPLETION_VIDEO_FALLBACK_DURATION_SEC).timeout.connect(
		_on_domestic_tech_completion_video_fallback_timeout.bind(str(item.get("tech_id", "")))
	)
	print("[DOMESTIC_TECH_COMPLETION_VIDEO] play scope=%s tech_id=%s path=%s" % [
		str(item.get("scope", "")),
		str(item.get("tech_id", "")),
		video_path,
	])
	return true


func _assign_domestic_tech_completion_video_stream_mvp(path: String) -> bool:
	if _domestic_tech_completion_video_player == null or path.is_empty():
		return false
	_domestic_tech_completion_video_player.stop()
	_domestic_tech_completion_video_player.stream = null
	var file_exists := FileAccess.file_exists(path)
	var loader_exists := ResourceLoader.exists(path)
	var loaded_resource: Resource = null
	if loader_exists:
		loaded_resource = ResourceLoader.load(path)
	var video_stream := loaded_resource as VideoStream
	print("[DOMESTIC_TECH_COMPLETION_VIDEO_LOAD] path=%s file_exists=%s resource_loader_exists=%s load_null=%s class=%s is_video_stream=%s" % [
		path,
		str(file_exists),
		str(loader_exists),
		str(loaded_resource == null),
		_get_domestic_tech_completion_debug_object_class_name_mvp(loaded_resource),
		str(video_stream != null),
	])
	if video_stream == null and path.get_extension().to_lower() == "ogv":
		video_stream = _create_domestic_tech_completion_theora_stream_direct_mvp(path)
	if video_stream == null:
		print("[DOMESTIC_TECH_COMPLETION_VIDEO] load_failed path=%s fallback=card" % path)
		return false
	_domestic_tech_completion_video_player.stream = video_stream
	return _domestic_tech_completion_video_player.stream != null


func _create_domestic_tech_completion_theora_stream_direct_mvp(path: String) -> VideoStream:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var direct_stream := VideoStreamTheora.new()
	if direct_stream == null or not _domestic_tech_completion_object_has_property_mvp(direct_stream, "file"):
		return null
	direct_stream.set("file", path)
	if str(direct_stream.get("file")).is_empty():
		return null
	return direct_stream as VideoStream


func _on_domestic_tech_completion_video_finished() -> void:
	_complete_domestic_tech_completion_video_mvp("finished_signal")


func _on_domestic_tech_completion_video_fallback_timeout(tech_id: String) -> void:
	if str(_domestic_tech_completion_current_item.get("tech_id", "")) != tech_id:
		return
	_complete_domestic_tech_completion_video_mvp("fallback_timer")


func _complete_domestic_tech_completion_video_mvp(source: String) -> void:
	if _domestic_tech_completion_video_completion_handled:
		return
	_domestic_tech_completion_video_completion_handled = true
	if _domestic_tech_completion_video_player != null:
		_domestic_tech_completion_video_player.stop()
		_domestic_tech_completion_video_player.visible = false
		_domestic_tech_completion_video_player.stream = null
	_show_domestic_tech_completion_card_mvp(_domestic_tech_completion_current_item)
	print("[DOMESTIC_TECH_COMPLETION_VIDEO] complete source=%s tech_id=%s" % [
		source,
		str(_domestic_tech_completion_current_item.get("tech_id", "")),
	])


func _show_domestic_tech_completion_card_mvp(item: Dictionary) -> void:
	if item.is_empty():
		_finish_domestic_tech_completion_presentation_item_mvp()
		return
	_ensure_domestic_tech_completion_presentation_overlay()
	_layout_domestic_tech_completion_presentation_overlay()
	if _domestic_tech_completion_root != null:
		_domestic_tech_completion_root.visible = true
	if _domestic_tech_completion_backdrop != null:
		_domestic_tech_completion_backdrop.visible = true
	if _domestic_tech_completion_video_player != null:
		_domestic_tech_completion_video_player.visible = false
	if _domestic_tech_completion_icon != null:
		var icon_path := str(item.get("icon_path", ""))
		var icon_texture := load(icon_path) as Texture2D if not icon_path.is_empty() else null
		_domestic_tech_completion_icon.texture = icon_texture
		_domestic_tech_completion_icon.visible = icon_texture != null
	if _domestic_tech_completion_scope_label != null:
		var scope_label := str(item.get("category_name", ""))
		if str(item.get("scope", "")) == DOMESTIC_TECH_SCOPE_CITY:
			scope_label = "%s / %s" % [str(item.get("city_name", "")), scope_label]
		_domestic_tech_completion_scope_label.text = scope_label
	if _domestic_tech_completion_title_label != null:
		_domestic_tech_completion_title_label.text = str(item.get("tech_name", ""))
	if _domestic_tech_completion_message_label != null:
		_domestic_tech_completion_message_label.text = str(item.get("message", ""))
	if _domestic_tech_completion_effect_label != null:
		_domestic_tech_completion_effect_label.text = "효과\n- %s" % str(item.get("effect_summary", "내정 연구 효과 범위가 표시됩니다."))
	if _domestic_tech_completion_card != null:
		_domestic_tech_completion_card.visible = true
		_play_worldmap_sfx("research")
	if _domestic_tech_completion_confirm_button != null:
		_domestic_tech_completion_confirm_button.call_deferred("grab_focus")


func _on_domestic_tech_completion_confirm_pressed() -> void:
	if not _is_domestic_tech_completion_card_visible():
		return
	_finish_domestic_tech_completion_presentation_item_mvp()


func _finish_domestic_tech_completion_presentation_item_mvp() -> void:
	if _finish_guard or not _domestic_tech_completion_presentation_active:
		return
	_finish_guard = true
	if _domestic_tech_completion_card != null:
		_domestic_tech_completion_card.visible = false
	var completed_item := _domestic_tech_completion_current_item.duplicate(true)
	_domestic_tech_completion_current_item = {}
	_domestic_tech_completion_presentation_active = false
	presentation_completed.emit(completed_item)
	if _domestic_tech_completion_presentation_queue.is_empty():
		_hide_domestic_tech_completion_presentation_overlay()
		if not _queue_empty_emitted:
			_queue_empty_emitted = true
			presentation_queue_empty.emit({"completed": true})
	else:
		call_deferred("_play_next_domestic_tech_completion_presentation")


func _hide_domestic_tech_completion_presentation_overlay() -> void:
	_domestic_tech_completion_video_completion_handled = false
	if _domestic_tech_completion_video_player != null:
		_domestic_tech_completion_video_player.stop()
		_domestic_tech_completion_video_player.visible = false
		_domestic_tech_completion_video_player.stream = null
	if _domestic_tech_completion_card != null:
		_domestic_tech_completion_card.visible = false
	if _domestic_tech_completion_root != null:
		_domestic_tech_completion_root.visible = false


func _is_domestic_tech_completion_card_visible() -> bool:
	return _domestic_tech_completion_card != null and _domestic_tech_completion_card.visible


func _is_domestic_tech_completion_space_confirm_event(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	var key_event := event as InputEventKey
	return key_event.pressed and not key_event.echo and key_event.keycode == KEY_SPACE


func _domestic_tech_completion_object_has_property_mvp(value: Object, property_name: String) -> bool:
	if value == null:
		return false
	for property_info in value.get_property_list():
		var property_data := property_info as Dictionary
		if String(property_data.get("name", "")) == property_name:
			return true
	return false


func _get_domestic_tech_completion_debug_object_class_name_mvp(value: Object) -> String:
	if value == null:
		return "null"
	return value.get_class()


func _make_domestic_tech_label_mvp(text: String, font_size: int, font_color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	return label
