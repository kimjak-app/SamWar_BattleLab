extends Node

const MASTER_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_master_4096x2304.png")
const TURN_COMPASS_SCRIPT := preload("res://scripts/worldmap/worldmap_turn_compass.gd")
const TILE_SCALE := Vector2(0.5, 0.5)
const WORLD_SIZE := Vector2(2048.0, 1152.0)
const CAMERA_MIN_ZOOM := 0.35
const CAMERA_MAX_ZOOM := 1.6
const CITY_NAME_OFFSET_Y := 16.0
const LEFT_PANEL_WIDTH := 320.0
const RIGHT_PANEL_WIDTH := 308.0
const GARRISON_SCROLL_HEIGHT := 142.0
const COMPACT_WORLD_UI_CHILDREN := {
	"LeftWorldStatusPanel": true,
	"CityInfoPanel": true,
	"TurnEndCompass": true,
}

# Photoshop guide coordinates sampled from the approved 2048x1152 marker image.
# The test world uses the same 2048x1152 coordinate space, so these values are
# intentionally applied 1:1 with no additional scale conversion.
const CITY_POSITIONS := {
	"karakorum": Vector2(1080, 322),
	"yecheng": Vector2(840, 400),
	"pyeongyang": Vector2(1162, 432),
	"hanseong": Vector2(1210, 501),
	"luoyang": Vector2(706, 524),
	"gyeongju": Vector2(1283, 547),
	"sabi": Vector2(1199, 574),
	"edo": Vector2(1598, 626),
	"jianye": Vector2(965, 645),
	"kyoto": Vector2(1522, 670),
	"osaka": Vector2(1449, 724),
	"chengdu": Vector2(470, 746),
	"kyushu": Vector2(1275, 776),
}

@onready var production_world_map: Node = get_node_or_null("ProductionWorldMap")


func _ready() -> void:
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)

	# The production city marker applies the locked W1 background during its own
	# ready pass. Apply the 16:9 test baseline deferred so this thin host wins
	# afterwards without modifying WorldMap.tscn or the W1 background tool.
	call_deferred("_apply_test_baseline")


func _apply_test_baseline() -> void:
	if production_world_map == null:
		push_warning("WorldMap 16:9 Test: ProductionWorldMap instance is missing.")
		return

	var world_root := production_world_map.get_node_or_null("WorldMapRoot")
	if world_root == null:
		push_warning("WorldMap 16:9 Test: WorldMapRoot is missing.")
		return

	var tile_layer := world_root.get_node_or_null("WorldMapTileLayer")
	if tile_layer == null:
		push_warning("WorldMap 16:9 Test: WorldMapTileLayer is missing.")
		return

	# 4096x2304 source -> four 2048x1152 atlas regions -> 0.5 scale
	# -> exact 2048x1152 (16:9) Godot world space.
	_apply_tile(tile_layer, "Tile_A1_TopLeft", Rect2(0, 0, 2048, 1152), Vector2(0, 0))
	_apply_tile(tile_layer, "Tile_A2_TopRight", Rect2(2048, 0, 2048, 1152), Vector2(1024, 0))
	_apply_tile(tile_layer, "Tile_B1_BottomLeft", Rect2(0, 1152, 2048, 1152), Vector2(0, 576))
	_apply_tile(tile_layer, "Tile_B2_BottomRight", Rect2(2048, 1152, 2048, 1152), Vector2(1024, 576))

	world_root.set_meta("worldmap_16x9_test_size", WORLD_SIZE)
	_apply_city_positions(world_root)
	_apply_city_label_offsets(world_root)
	_refresh_routes(world_root)
	_connect_compact_hud_refresh_hooks(world_root)
	_apply_compact_world_ui()
	_apply_camera_fit()


func _apply_tile(tile_layer: Node, node_name: String, region: Rect2, target_position: Vector2) -> void:
	var sprite := tile_layer.get_node_or_null(node_name) as Sprite2D
	if sprite == null:
		push_warning("WorldMap 16:9 Test: missing tile node %s." % node_name)
		return

	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = MASTER_TEXTURE
	atlas_texture.region = region

	sprite.texture = atlas_texture
	sprite.centered = false
	sprite.position = target_position
	sprite.rotation = 0.0
	sprite.scale = TILE_SCALE


func _apply_city_positions(world_root: Node) -> void:
	var city_layer := world_root.get_node_or_null("CityLayer")
	if city_layer == null:
		push_warning("WorldMap 16:9 Test: CityLayer is missing.")
		return

	var applied_count := 0
	for child in city_layer.get_children():
		if not child is Node2D:
			continue
		var city_id_value = child.get("city_id")
		if city_id_value == null:
			continue
		var city_id := str(city_id_value)
		if not CITY_POSITIONS.has(city_id):
			continue
		(child as Node2D).position = CITY_POSITIONS[city_id]
		applied_count += 1

	if applied_count != CITY_POSITIONS.size():
		push_warning(
			"WorldMap 16:9 Test: applied %d/%d Photoshop city positions."
			% [applied_count, CITY_POSITIONS.size()]
		)


func _apply_city_label_offsets(world_root: Node) -> void:
	var city_layer := world_root.get_node_or_null("CityLayer")
	if city_layer == null:
		return

	for child in city_layer.get_children():
		if not child is Node2D:
			continue
		var name_text := child.get_node_or_null("NameText") as Node2D
		if name_text == null:
			name_text = child.get_node_or_null("NameLabel") as Node2D
		if name_text == null:
			continue
		name_text.position.y = CITY_NAME_OFFSET_Y


func _refresh_routes(world_root: Node) -> void:
	var route_layer := world_root.get_node_or_null("RouteLayer")
	if route_layer == null:
		push_warning("WorldMap 16:9 Test: RouteLayer is missing.")
		return

	for route in route_layer.get_children():
		if route.has_method("_refresh_route_geometry"):
			route.call("_refresh_route_geometry")


func _connect_compact_hud_refresh_hooks(world_root: Node) -> void:
	var city_layer := world_root.get_node_or_null("CityLayer")
	if city_layer == null:
		return
	var callback := Callable(self, "_on_test_city_selected")
	for child in city_layer.get_children():
		if not child.has_signal("city_selected"):
			continue
		if not child.is_connected("city_selected", callback):
			child.connect("city_selected", callback)


func _on_test_city_selected(_marker: Node) -> void:
	# Production refreshes CityInfoPanel from the same signal. Re-apply the compact
	# presentation one idle step later so runtime data stays the source of truth.
	call_deferred("_apply_compact_world_ui")


func _apply_compact_world_ui() -> void:
	if production_world_map == null:
		return
	var world_ui := production_world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		push_warning("WorldMap 16:9 Test: WorldMapUI is missing.")
		return

	world_ui.visible = true
	var compass := _ensure_turn_compass(world_ui)

	# This test host previews only the compact nation/city HUD plus the approved
	# turn-end compass. All other legacy direct children stay available in the
	# production instance but are hidden for this focused presentation test.
	for child in world_ui.get_children():
		if not child is CanvasItem:
			continue
		var keep_visible := COMPACT_WORLD_UI_CHILDREN.has(str(child.name))
		(child as CanvasItem).visible = keep_visible

	var left_panel := world_ui.get_node_or_null("LeftWorldStatusPanel") as PanelContainer
	var right_panel := world_ui.get_node_or_null("CityInfoPanel") as PanelContainer
	_compact_left_panel(left_panel)
	_compact_right_panel(right_panel)
	if compass != null:
		compass.visible = true
		if compass.has_method("_layout_compass"):
			compass.call_deferred("_layout_compass")
	call_deferred("_fit_compact_panels")


func _compact_left_panel(left_panel: PanelContainer) -> void:
	if left_panel == null:
		return
	left_panel.visible = true
	left_panel.custom_minimum_size = Vector2(LEFT_PANEL_WIDTH, 0.0)
	var content := left_panel.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return

	var hide_after_turn_end := false
	for child in content.get_children():
		if not child is CanvasItem:
			continue
		if hide_after_turn_end:
			(child as CanvasItem).visible = false
			continue
		if str(child.name) == "WildArmyEditButtonPlaceholder":
			hide_after_turn_end = true


func _compact_right_panel(right_panel: PanelContainer) -> void:
	if right_panel == null:
		return
	right_panel.visible = true
	right_panel.custom_minimum_size = Vector2(RIGHT_PANEL_WIDTH, 0.0)
	var content := right_panel.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return

	var garrison_card := content.get_node_or_null("GarrisonCard") as PanelContainer
	if garrison_card == null:
		push_warning("WorldMap 16:9 Test: GarrisonCard is missing.")
		return

	var garrison_index := garrison_card.get_index()
	for child in content.get_children():
		if not child is CanvasItem:
			continue
		if child.get_index() > garrison_index:
			(child as CanvasItem).visible = false

	garrison_card.visible = true
	_ensure_garrison_scroll(garrison_card)
	var title := garrison_card.get_node_or_null("MarginContainer/Content/SelectedHeroChipLabel") as Label
	if title != null:
		title.text = "도시 소속 무장"
		title.visible = true


func _ensure_garrison_scroll(garrison_card: PanelContainer) -> void:
	var card_content := garrison_card.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if card_content == null:
		return

	var existing_scroll := card_content.get_node_or_null("GarrisonScroll") as ScrollContainer
	if existing_scroll != null:
		existing_scroll.custom_minimum_size = Vector2(0.0, GARRISON_SCROLL_HEIGHT)
		existing_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		existing_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		return

	var garrison_list := card_content.get_node_or_null("GarrisonList") as VBoxContainer
	if garrison_list == null:
		return
	var list_index := garrison_list.get_index()
	card_content.remove_child(garrison_list)

	var scroll := ScrollContainer.new()
	scroll.name = "GarrisonScroll"
	scroll.custom_minimum_size = Vector2(0.0, GARRISON_SCROLL_HEIGHT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card_content.add_child(scroll)
	card_content.move_child(scroll, mini(list_index, card_content.get_child_count() - 1))

	garrison_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(garrison_list)


func _fit_compact_panels() -> void:
	if production_world_map == null:
		return
	var world_ui := production_world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return
	_fit_panel_to_content(world_ui.get_node_or_null("LeftWorldStatusPanel") as PanelContainer, LEFT_PANEL_WIDTH)
	_fit_panel_to_content(world_ui.get_node_or_null("CityInfoPanel") as PanelContainer, RIGHT_PANEL_WIDTH)


func _fit_panel_to_content(panel: PanelContainer, target_width: float) -> void:
	if panel == null:
		return
	panel.custom_minimum_size = Vector2(target_width, 0.0)
	var minimum := panel.get_combined_minimum_size()
	panel.size = Vector2(target_width, minimum.y)


func _ensure_turn_compass(world_ui: CanvasLayer) -> Control:
	var compass := world_ui.get_node_or_null("TurnEndCompass") as Control
	if compass == null:
		compass = TURN_COMPASS_SCRIPT.new() as Control
		if compass == null:
			return null
		compass.name = "TurnEndCompass"
		world_ui.add_child(compass)
	if compass.has_method("bind_world_scene"):
		compass.call("bind_world_scene", production_world_map)
	return compass


func _on_viewport_size_changed() -> void:
	call_deferred("_apply_camera_fit")
	call_deferred("_fit_compact_panels")


func _apply_camera_fit() -> void:
	if production_world_map == null:
		return

	var camera := production_world_map.get_node_or_null("WorldMapCamera") as Camera2D
	if camera == null:
		push_warning("WorldMap 16:9 Test: WorldMapCamera is missing.")
		return

	var viewport := get_viewport()
	if viewport == null:
		return
	var viewport_size := viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var width_zoom := viewport_size.x / WORLD_SIZE.x
	var height_zoom := viewport_size.y / WORLD_SIZE.y
	var cover_zoom := clampf(maxf(width_zoom, height_zoom), CAMERA_MIN_ZOOM, CAMERA_MAX_ZOOM)
	var visible_world_size := viewport_size / cover_zoom

	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(WORLD_SIZE.x)
	camera.limit_bottom = int(WORLD_SIZE.y)
	camera.zoom = Vector2(cover_zoom, cover_zoom)
	camera.position = Vector2(
		WORLD_SIZE.x * 0.5,
		visible_world_size.y * 0.5
	)
