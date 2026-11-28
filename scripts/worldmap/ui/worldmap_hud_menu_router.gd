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
## Queue 43 (layout): the screen has three slots - left = the world status panel, right = the city panel, centre = the
## space between them under the top margin. The centre shows ONE menu window (CityDetailPanel or the popup; opening one
## hides the other); in the trade menu its sub-window (main's manual trade order window or internal transfer window, one
## at a time) takes CityDetailPanel's place until it closes. Each gets a vertical scroll inside, so a window taller than
## the centre slot scrolls instead of overlapping or running off the screen. A trade sub-window that main
## opens on its own (the city action "교역") switches to the trade menu, so it never shows without it. The layout is
## re-applied every frame while a centre window is shown (content and the left / right panels move).
## get_center_windows() is what the city interior picture checks to fold itself away.

const CITY_DETAIL_MENUS := [&"diplomacy", &"intel", &"trade"]
const POPUP_MENUS := [&"system", &"military", &"personnel", &"info"]
const PANEL_GAP := 12.0
const DETAIL_PANEL_PATH := "WorldMapUI/CityDetailPanel"
const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const RIGHT_PANEL_PATH := "WorldMapUI/CityInfoPanel"
const DETAIL_CONTENT_NAME := "MarginContainer"   # CityDetailPanel's only child (main's @onready paths are resolved before we move it)
## main member, its only child (main holds both by reference), close method
const TRADE_SUB_WINDOWS := [
	["_manual_trade_order_panel", "ManualTradeOrderPanelContent", "_close_manual_trade_order_panel"],
	["_internal_trade_transfer_panel", "InternalTradeTransferPanelContent", "_close_internal_trade_transfer_panel"],
]
const SCROLL_NAME := "HudScroll"
const SUB_WINDOW_WIDTH := 600.0   # main's own width for both trade sub-windows, kept while the centre slot has room
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
var _detail_shown := false   # CityDetailPanel was shown by this router (a menu or a city click) and not closed since
var _detail_replaced := false   # CityDetailPanel is hidden only because a trade sub-window took its place


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


## Closes every centre window, also CityDetailPanel shown by a city click (queue 43: one centre window at a time).
func close_all() -> void:
	if CITY_DETAIL_MENUS.has(open_menu):
		for sub in TRADE_SUB_WINDOWS:
			if world_map.has_method(sub[2]):
				world_map.call(sub[2])
		world_map.set("_unified_primary_tab", "city-detail")
	if _detail_shown:
		var panel := _city_detail_panel()
		if panel != null:
			panel.visible = false
		_detail_shown = false
	_detail_replaced = false
	if _popup != null:
		_popup.visible = false
	open_menu = &""


func get_city_detail_panel() -> Control:
	return _city_detail_panel()


func get_popup() -> PanelContainer:
	return _popup


## The centre windows on screen now (CityDetailPanel, the popup, the trade sub-window).
func get_center_windows() -> Array[Control]:
	var windows: Array[Control] = []
	for window in [_city_detail_panel() if _detail_shown else null, _popup, _trade_sub_window() if open_menu == &"trade" else null]:
		if window is Control and is_instance_valid(window) and (window as Control).is_visible_in_tree():
			windows.append(window)
	return windows


## The centre slot: between the left and right panels (their real rects, they can be dragged), from the HUD top margin
## down to PANEL_GAP above the bottom edge.
func get_center_slot() -> Rect2:
	var viewport_size := get_viewport().get_visible_rect().size
	var top := maxf(WorldMapHudPresentationController.HUD_MIN_TOP_MARGIN, viewport_size.y * WorldMapHudPresentationController.HUD_TOP_MARGIN_RATIO)
	var left := PANEL_GAP
	var right := viewport_size.x - PANEL_GAP
	var left_panel := _visible_world_control(LEFT_PANEL_PATH)
	if left_panel != null:
		left = left_panel.get_global_rect().end.x + PANEL_GAP
	var right_panel := _visible_world_control(RIGHT_PANEL_PATH)
	if right_panel != null:
		right = right_panel.get_global_rect().position.x - PANEL_GAP
	return Rect2(left, top, maxf(0.0, right - left), maxf(0.0, viewport_size.y - PANEL_GAP - top))


func _process(_delta: float) -> void:
	if not _installed or world_map == null or not is_instance_valid(world_map):
		return
	if open_menu != &"trade" and _trade_sub_window() != null:
		_adopt_trade_menu()
	_layout_center()


## main opened a trade sub-window by itself (the city action "교역" sets the trade tab first): that is the trade menu.
func _adopt_trade_menu() -> void:
	if _popup != null:
		_popup.visible = false
	open_menu = &"trade"
	_show_city_detail_panel()


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
			_layout_center()


func _show_city_detail_panel() -> void:
	var panel := _city_detail_panel()
	if panel == null:
		return
	if bool(world_map.get("_is_unified_city_panel_collapsed")) and world_map.has_method("_set_unified_city_panel_collapsed"):
		world_map.call("_set_unified_city_panel_collapsed", false)
	panel.visible = true
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_detail_shown = true
	world_map.call("_refresh_unified_panel_content")
	_layout_center()


## Queue 43: the menu window sits at the top right of the centre slot (left of the city panel). In the trade menu the
## trade sub-window takes CityDetailPanel's place (addendum 7: it replaces the trade tab, never covers it); when the
## sub-window closes (save / cancel) the same trade tab comes back. Each window is as tall as it needs, at most the slot
## height, and scrolls inside beyond that. The popup is centred in the slot.
func _layout_center() -> void:
	var slot := get_center_slot()
	var order := _trade_sub_window() if open_menu == &"trade" else null
	var detail := _city_detail_panel() if _detail_shown else null
	if detail != null:
		if order != null and detail.visible:
			detail.visible = false   # replaced in place by the sub-window
			_detail_replaced = true
		elif order == null and _detail_replaced:
			detail.visible = true    # the sub-window closed: the trade tab is back
			_detail_replaced = false
	if detail != null and detail.is_visible_in_tree():
		_fit_center_window(detail, _ensure_scroll(detail, DETAIL_CONTENT_NAME), slot, minf(detail.size.x, slot.size.x))
	if order != null:
		order.set_anchors_preset(Control.PRESET_TOP_LEFT)
		var width := minf(SUB_WINDOW_WIDTH, slot.size.x)
		order.custom_minimum_size = Vector2(width, 0.0)
		_fit_center_window(order, _ensure_scroll(order, _sub_window_content_name(order)), slot, width)
	if _popup != null and _popup.visible:
		_place_popup()


## Top right of the centre slot, `width` wide (never below the content's own minimum), as tall as the content up to the
## slot height (the scroll takes the rest).
func _fit_center_window(window: Control, scroll: ScrollContainer, slot: Rect2, width: float) -> void:
	if scroll == null:
		return
	var need := _scroll_content_height(scroll) + _panel_padding(window).y
	_fit_scroll_height(window, scroll, minf(need, slot.size.y))
	window.size = Vector2(width, 0.0)   # a container never goes below its minimum: the scroll height set above
	window.position = Vector2(maxf(slot.position.x, slot.end.x - window.size.x), slot.position.y)


## Moves the panel's only content child into a vertical-only ScrollContainer (once). The content node itself is kept, so
## every reference main holds to it and to its children stays valid.
func _ensure_scroll(panel: Control, content_name: String) -> ScrollContainer:
	var existing := panel.get_node_or_null(SCROLL_NAME) as ScrollContainer
	if existing != null:
		return existing
	var content := panel.get_node_or_null(content_name) as Control
	if content == null:
		return null
	var scroll := ScrollContainer.new()
	scroll.name = SCROLL_NAME
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var index := content.get_index()
	panel.remove_child(content)
	scroll.add_child(content)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)
	panel.move_child(scroll, index)
	return scroll


func _scroll_content_height(scroll: ScrollContainer) -> float:
	var content := scroll.get_child(0) as Control if scroll.get_child_count() > 0 else null
	return content.get_combined_minimum_size().y if content != null else 0.0


## The scroll's minimum height = the panel height wanted minus the panel's own padding (never negative).
func _fit_scroll_height(panel: Control, scroll: ScrollContainer, panel_height: float) -> void:
	var height := maxf(0.0, panel_height - _panel_padding(panel).y)
	if not is_equal_approx(scroll.custom_minimum_size.y, height):
		scroll.custom_minimum_size = Vector2(0.0, height)


func _panel_padding(panel: Control) -> Vector2:
	var style := panel.get_theme_stylebox("panel")
	return style.get_minimum_size() if style != null else Vector2.ZERO


## The trade sub-window on screen (main shows at most one), else null.
func _trade_sub_window() -> Control:
	if world_map == null:
		return null
	for sub in TRADE_SUB_WINDOWS:
		var panel = world_map.get(sub[0])
		if panel is Control and is_instance_valid(panel) and (panel as Control).is_visible_in_tree():
			return panel
	return null


func _sub_window_content_name(panel: Control) -> String:
	for sub in TRADE_SUB_WINDOWS:
		if world_map.get(sub[0]) == panel:
			return sub[1]
	return ""


func _visible_world_control(path: String) -> Control:
	var node := world_map.get_node_or_null(path) as Control if world_map != null else null
	return node if node != null and node.is_visible_in_tree() else null


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
	return world_map.get_node_or_null(DETAIL_PANEL_PATH) as Control if world_map != null else null


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
	# Queue 43: centred on the screen as before, but kept inside the centre slot (clear of the left / right panels).
	var slot := get_center_slot()
	var centred := (viewport.get_visible_rect().size.x - size.x) * 0.5
	_popup.position = Vector2(clampf(centred, slot.position.x, maxf(slot.position.x, slot.end.x - size.x)), slot.position.y)


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
