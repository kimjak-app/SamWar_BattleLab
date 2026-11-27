class_name WorldMapHudMenuRouter
extends Control

## Queue 41 (3D HUD connection): the top menu opens the world map's existing windows instead of new UI.
##   diplomacy / intel -> CityDetailPanel on its "외교·첩보" tab (diplomacy / spy sub-tab, the real action cards)
##   trade             -> CityDetailPanel "무역 · 타국무역" tab (+ the manual trade order window for an own city)
##   system            -> save / load (the existing one-slot save functions) + sound settings
##   military          -> recruit for the selected own city (the existing recruitment request, 100 per press)
##   personnel / info  -> "준비 중" (no window exists yet)
## The same menu again closes it, another menu switches. A city click shows CityDetailPanel for that city (its storage).
## Every window here stops the mouse, so a click on it never reaches the 3D map (which only takes unhandled input).

const CITY_DETAIL_MENUS := [&"diplomacy", &"intel", &"trade"]
const POPUP_MENUS := [&"system", &"military", &"personnel", &"info"]
const PANEL_GAP := 12.0
const RECRUIT_AMOUNT := 100
# Tab ids are worldmap_main's UNIFIED_PANEL_TAB_* / DIPLOMACY_SPY_TAB_* / CITY_DETAIL_TAB_* values.
const PLACEHOLDER_TEXT := {&"personnel": "인사 — 준비 중입니다.", &"info": "정보 — 준비 중입니다."}

var world_map: Node = null
var top_nav: Control = null
var open_menu: StringName = &""

var _popup: PanelContainer = null
var _popup_title: Label = null
var _popup_body: Label = null
var _popup_buttons: HBoxContainer = null
var _installed := false


func install(nav: Control, map: Node) -> void:
	top_nav = nav
	world_map = map
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_popup()
	call_deferred("_connect_city_markers")
	_installed = true


## Returns the menu that is open after the press ("" = closed).
func route(menu_id: StringName) -> StringName:
	if not _installed or world_map == null:
		return &""
	if open_menu == menu_id:
		close_all()
		return &""
	close_all()
	if CITY_DETAIL_MENUS.has(menu_id):
		_open_city_detail(menu_id)
	elif POPUP_MENUS.has(menu_id):
		_open_popup(menu_id)
	else:
		return &""
	open_menu = menu_id
	return open_menu


func close_all() -> void:
	if CITY_DETAIL_MENUS.has(open_menu):
		if world_map.has_method("_close_manual_trade_order_panel"):
			world_map.call("_close_manual_trade_order_panel")
		world_map.set("_unified_primary_tab", "city-detail")
		var panel := _city_detail_panel()
		if panel != null:
			panel.visible = false
	if _popup != null:
		_popup.visible = false
	open_menu = &""


func get_city_detail_panel() -> Control:
	return _city_detail_panel()


func get_popup() -> PanelContainer:
	return _popup


# ---------------------------------------------------------------- CityDetailPanel (diplomacy / intel / trade / city click)
func _open_city_detail(menu_id: StringName) -> void:
	match menu_id:
		&"diplomacy":
			world_map.set("_unified_primary_tab", "diplomacy-spy")
			world_map.set("_selected_diplomacy_spy_tab", "diplomacy")
		&"intel":
			world_map.set("_unified_primary_tab", "diplomacy-spy")
			world_map.set("_selected_diplomacy_spy_tab", "spy")
		&"trade":
			world_map.set("_unified_primary_tab", "trade")
			world_map.set("_selected_city_detail_tab", "external-trade")
	_show_city_detail_panel()
	if menu_id == &"trade":
		var city_id := str(world_map.get("selected_city_id"))
		if not city_id.is_empty() and bool(world_map.call("_is_city_owned_by_player_mvp", city_id)) and not (world_map.call("_get_external_trade_candidate_city_ids", city_id) as Array).is_empty():
			world_map.call("_open_manual_trade_order_panel")


func _show_city_detail_panel() -> void:
	var panel := _city_detail_panel()
	if panel == null:
		return
	if bool(world_map.get("_is_unified_city_panel_collapsed")) and world_map.has_method("_set_unified_city_panel_collapsed"):
		world_map.call("_set_unified_city_panel_collapsed", false)
	panel.visible = true
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	world_map.call("_refresh_unified_panel_content")
	_place_city_detail_panel()
	call_deferred("_place_city_detail_panel")  # after the deferred content resize


## Left of the selected-city panel, under the top menu bar (the HUD owner's top margin).
func _place_city_detail_panel() -> void:
	var panel := _city_detail_panel()
	var viewport := get_viewport()
	if panel == null or viewport == null:
		return
	var viewport_size := viewport.get_visible_rect().size
	var right_panel := world_map.get_node_or_null("WorldMapUI/CityInfoPanel") as Control
	var top := maxf(WorldMapHudPresentationController.HUD_MIN_TOP_MARGIN, viewport_size.y * WorldMapHudPresentationController.HUD_TOP_MARGIN_RATIO)
	var right_edge := right_panel.position.x if right_panel != null and right_panel.visible else viewport_size.x - PANEL_GAP
	var size := panel.size
	panel.position = Vector2(
		clampf(right_edge - PANEL_GAP - size.x, PANEL_GAP, maxf(PANEL_GAP, viewport_size.x - size.x - PANEL_GAP)),
		clampf(top, PANEL_GAP, maxf(PANEL_GAP, viewport_size.y - size.y - PANEL_GAP))
	)


func _connect_city_markers() -> void:
	var city_layer := world_map.get_node_or_null("WorldMapRoot/CityLayer") if world_map != null else null
	if city_layer == null:
		return
	var callback := Callable(self, "_on_city_selected")
	for child in city_layer.get_children():
		if child.has_signal("city_selected") and not child.is_connected("city_selected", callback):
			child.connect("city_selected", callback)


## A city click shows that city in CityDetailPanel (storage etc.); an open diplomacy / intel / trade tab keeps its tab
## and follows the new target. A system / military popup refreshes for the new city.
func _on_city_selected(_marker: Node) -> void:
	if POPUP_MENUS.has(open_menu):
		_refresh_popup()
		return
	if open_menu == &"":
		world_map.set("_unified_primary_tab", "city-detail")
	_show_city_detail_panel()


func _city_detail_panel() -> Control:
	return world_map.get_node_or_null("WorldMapUI/CityDetailPanel") as Control if world_map != null else null


# ---------------------------------------------------------------- popup (system / military / placeholders)
func _build_popup() -> void:
	_popup = PanelContainer.new()
	_popup.name = "HudMenuPopup"
	_popup.visible = false
	_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	_popup.custom_minimum_size = Vector2(320.0, 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.055, 0.045, 0.94)
	style.border_color = Color(0.78, 0.62, 0.32, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(14)
	_popup.add_theme_stylebox_override("panel", style)
	add_child(_popup)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	_popup.add_child(box)
	_popup_title = Label.new()
	_popup_title.name = "Title"
	_popup_title.add_theme_font_size_override("font_size", 18)
	box.add_child(_popup_title)
	_popup_body = Label.new()
	_popup_body.name = "Body"
	_popup_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_popup_body)
	_popup_buttons = HBoxContainer.new()
	_popup_buttons.name = "Buttons"
	_popup_buttons.add_theme_constant_override("separation", 8)
	box.add_child(_popup_buttons)


func _open_popup(menu_id: StringName) -> void:
	open_menu = menu_id
	for child in _popup_buttons.get_children():
		_popup_buttons.remove_child(child)
		child.queue_free()
	match menu_id:
		&"system":
			_popup_title.text = "시스템"
			_add_button("SaveButton", "저장", _on_save_pressed)
			_add_button("LoadButton", "불러오기", _on_load_pressed)
			_add_button("SoundButton", "소리 설정", _on_sound_pressed)
		&"military":
			_popup_title.text = "군사 · 모병"
			_add_button("RecruitButton", "모병 +%d" % RECRUIT_AMOUNT, _on_recruit_pressed)
		_:
			_popup_title.text = "준비 중"
	_refresh_popup()
	_popup.visible = true
	_place_popup()


func _refresh_popup() -> void:
	if _popup == null:
		return
	match open_menu:
		&"system":
			_popup_body.text = "수동 저장 슬롯 1개(턴마다 쓰는 자동 저장과 별도).\n%s" % str(world_map.get("_save_management_status"))
		&"military":
			var city_id := str(world_map.get("selected_city_id"))
			var own := not city_id.is_empty() and bool(world_map.call("_is_city_owned_by_player_mvp", city_id))
			var recruit := _popup_buttons.get_node_or_null("RecruitButton") as Button
			if recruit != null:
				recruit.disabled = not own
			if not own:
				_popup_body.text = "내 도시를 선택하면 모병할 수 있습니다."
			else:
				var troops := int(world_map.call("_get_city_troops_for_battle_context", city_id))
				var last: Dictionary = (world_map.get("_player_state") as Dictionary).get("last_recruitment_result", {})
				var line := "%s · 병력 %d" % [str(world_map.call("_format_city_name_by_id", city_id, city_id)), troops]
				var last_message := str(world_map.get("_save_management_status"))
				_popup_body.text = line + ("\n" + last_message if not last.is_empty() and not last_message.is_empty() else "")
		_:
			_popup_body.text = str(PLACEHOLDER_TEXT.get(open_menu, "준비 중입니다."))
	_place_popup()


func _place_popup() -> void:
	var viewport := get_viewport()
	if viewport == null or _popup == null:
		return
	var size := _popup.get_combined_minimum_size()
	_popup.size = size
	var viewport_size := viewport.get_visible_rect().size
	var top := maxf(WorldMapHudPresentationController.HUD_MIN_TOP_MARGIN, viewport_size.y * WorldMapHudPresentationController.HUD_TOP_MARGIN_RATIO)
	_popup.position = Vector2(clampf((viewport_size.x - size.x) * 0.5, PANEL_GAP, maxf(PANEL_GAP, viewport_size.x - size.x - PANEL_GAP)), top)


func _add_button(node_name: String, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(88.0, 32.0)
	button.pressed.connect(callback)
	_popup_buttons.add_child(button)
	return button


func _on_save_pressed() -> void:
	world_map.call("_save_worldmap_manual_slot_mvp")
	_refresh_popup()


func _on_load_pressed() -> void:
	world_map.call("_load_worldmap_manual_slot_mvp")
	_refresh_popup()


func _on_sound_pressed() -> void:
	if top_nav != null and top_nav.has_method("open_audio_settings"):
		top_nav.call("open_audio_settings")


func _on_recruit_pressed() -> void:
	var city_id := str(world_map.get("selected_city_id"))
	world_map.call("_on_city_info_recruitment_requested", city_id, RECRUIT_AMOUNT)
	_refresh_popup()
