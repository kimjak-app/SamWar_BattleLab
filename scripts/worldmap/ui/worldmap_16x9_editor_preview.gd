@tool
extends Node

# Editor-only visual synchronizer for WorldMap_16x9_Test.tscn.
# It deliberately does nothing at runtime: F6 remains owned by the existing
# test host/controllers, while the 2D editor mirrors their approved visual state.

const TEST_HOST_SCRIPT := preload("res://scripts/worldmap/worldmap_16x9_test_host.gd")
const CITY_MARKER_SCRIPT := preload("res://scripts/worldmap_city_marker.gd")
const V2_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_bg_v2_test.png")
const LAND_SEA_MASK: Texture2D = preload("res://assets/source/worldmap/worldmap_land_sea_mask_v1_0_4096x2304.png")
const TERRITORY_SHADER: Shader = preload("res://shaders/worldmap/territory_shader.gdshader")

const WORLD_SIZE := Vector2(2048.0, 1152.0)
const TILE_SCALE := Vector2(0.5, 0.5)
const MAX_CITIES := 64
const EDITOR_TERRITORY_NAME := "__EditorTerritoryPreview"

var _tile_textures: Dictionary = {}
var _territory_layer: ColorRect = null
var _territory_material: ShaderMaterial = null


func _ready() -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		return

	_build_v2_tile_textures()
	set_process(true)
	call_deferred("_apply_editor_preview")


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		return

	# WorldMapCityMarker is itself @tool and keeps the old W1 background alive in
	# the production instance. This controller is the last test-scene sibling, so
	# reassert the approved Design-2 preview after the production subtree updates.
	_apply_editor_preview()


func _build_v2_tile_textures() -> void:
	_tile_textures.clear()
	_tile_textures["Tile_A1_TopLeft"] = _make_atlas(Rect2(0, 0, 2048, 1152))
	_tile_textures["Tile_A2_TopRight"] = _make_atlas(Rect2(2048, 0, 2048, 1152))
	_tile_textures["Tile_B1_BottomLeft"] = _make_atlas(Rect2(0, 1152, 2048, 1152))
	_tile_textures["Tile_B2_BottomRight"] = _make_atlas(Rect2(2048, 1152, 2048, 1152))


func _make_atlas(region: Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = V2_TEXTURE
	atlas_texture.region = region
	return atlas_texture


func _apply_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return

	var test_root := get_parent()
	if test_root == null:
		return
	var production_world_map := test_root.get_node_or_null("ProductionWorldMap")
	if production_world_map == null:
		return
	var world_root := production_world_map.get_node_or_null("WorldMapRoot")
	if world_root == null:
		return

	_apply_v2_background(world_root)
	_apply_approved_city_positions(world_root)
	_apply_city_label_offsets(world_root)
	_refresh_routes(world_root)
	_apply_compact_hud_preview(production_world_map)
	_apply_territory_preview(test_root, world_root)


func _apply_v2_background(world_root: Node) -> void:
	var tile_layer := world_root.get_node_or_null("WorldMapTileLayer")
	if tile_layer == null:
		return

	_apply_tile(tile_layer, "Tile_A1_TopLeft", Vector2(0, 0))
	_apply_tile(tile_layer, "Tile_A2_TopRight", Vector2(1024, 0))
	_apply_tile(tile_layer, "Tile_B1_BottomLeft", Vector2(0, 576))
	_apply_tile(tile_layer, "Tile_B2_BottomRight", Vector2(1024, 576))


func _apply_tile(tile_layer: Node, node_name: String, target_position: Vector2) -> void:
	var sprite := tile_layer.get_node_or_null(node_name) as Sprite2D
	if sprite == null:
		return
	var preview_texture := _tile_textures.get(node_name) as Texture2D
	if preview_texture == null:
		return

	# Assign every editor frame because the production CityMarker @tool refresh can
	# restore Design-1 while this nested production scene is open in the test scene.
	sprite.texture = preview_texture
	sprite.centered = false
	sprite.position = target_position
	sprite.rotation = 0.0
	sprite.scale = TILE_SCALE


func _apply_approved_city_positions(world_root: Node) -> void:
	var city_layer := world_root.get_node_or_null("CityLayer")
	if city_layer == null:
		return
	var city_positions: Dictionary = TEST_HOST_SCRIPT.CITY_POSITIONS

	for child in city_layer.get_children():
		if not child is Node2D:
			continue
		var city_id_value = child.get("city_id")
		if city_id_value == null:
			continue
		var city_id := str(city_id_value)
		if city_positions.has(city_id):
			(child as Node2D).position = city_positions[city_id]


func _apply_city_label_offsets(world_root: Node) -> void:
	var city_layer := world_root.get_node_or_null("CityLayer")
	if city_layer == null:
		return
	var label_offset_y := float(TEST_HOST_SCRIPT.CITY_NAME_OFFSET_Y)

	for child in city_layer.get_children():
		if not child is Node2D:
			continue
		var name_text := child.get_node_or_null("NameText") as Node2D
		if name_text == null:
			name_text = child.get_node_or_null("NameLabel") as Node2D
		if name_text != null:
			name_text.position.y = label_offset_y


func _refresh_routes(world_root: Node) -> void:
	var route_layer := world_root.get_node_or_null("RouteLayer")
	if route_layer == null:
		return
	for route in route_layer.get_children():
		if route.has_method("_refresh_route_geometry"):
			route.call("_refresh_route_geometry")


func _apply_compact_hud_preview(production_world_map: Node) -> void:
	var world_ui := production_world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		return

	world_ui.visible = true
	var compact_children: Dictionary = TEST_HOST_SCRIPT.COMPACT_WORLD_UI_CHILDREN
	for child in world_ui.get_children():
		if not child is CanvasItem:
			continue
		var child_name := str(child.name)
		# TurnEndCompass is runtime-created, so the editor preview keeps only the two
		# persisted compact side panels and hides the legacy temporary panels.
		var keep_visible := child_name == "LeftWorldStatusPanel" or child_name == "CityInfoPanel"
		if compact_children.has(child_name) and child_name != "TurnEndCompass":
			keep_visible = true
		(child as CanvasItem).visible = keep_visible

	var left_panel := world_ui.get_node_or_null("LeftWorldStatusPanel") as PanelContainer
	var right_panel := world_ui.get_node_or_null("CityInfoPanel") as PanelContainer
	_preview_compact_left(left_panel)
	_preview_compact_right(right_panel)
	_fit_panel_to_content(left_panel, float(TEST_HOST_SCRIPT.LEFT_PANEL_WIDTH), true)
	_fit_panel_to_content(right_panel, float(TEST_HOST_SCRIPT.RIGHT_PANEL_WIDTH), false)


func _preview_compact_left(left_panel: PanelContainer) -> void:
	if left_panel == null:
		return
	left_panel.visible = true
	var content := left_panel.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return
	var hard_hidden: Array = TEST_HOST_SCRIPT.LEFT_HARD_HIDDEN_CHILDREN
	var hide_after_turn_end := false
	for child in content.get_children():
		if not child is CanvasItem:
			continue
		var child_name := str(child.name)
		var should_hide := hard_hidden.has(child_name) or hide_after_turn_end
		(child as CanvasItem).visible = not should_hide
		if child_name == "WildArmyEditButtonPlaceholder":
			hide_after_turn_end = true


func _preview_compact_right(right_panel: PanelContainer) -> void:
	if right_panel == null:
		return
	right_panel.visible = true
	var content := right_panel.get_node_or_null("MarginContainer/Content") as VBoxContainer
	if content == null:
		return
	var garrison_card := content.get_node_or_null("GarrisonCard") as PanelContainer
	if garrison_card == null:
		return
	var custom_visible: Dictionary = TEST_HOST_SCRIPT.RIGHT_CUSTOM_VISIBLE_CHILDREN
	var garrison_index := garrison_card.get_index()
	for child in content.get_children():
		if not child is CanvasItem:
			continue
		var should_show := child.get_index() <= garrison_index or custom_visible.has(str(child.name))
		(child as CanvasItem).visible = should_show
	garrison_card.visible = true
	var title := garrison_card.get_node_or_null("MarginContainer/Content/SelectedHeroChipLabel") as Label
	if title != null:
		title.text = "도시 소속 무장"
		title.visible = true


func _fit_panel_to_content(panel: PanelContainer, target_width: float, is_left: bool) -> void:
	if panel == null:
		return
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 0.0
	panel.custom_minimum_size = Vector2(target_width, 0.0)
	var minimum := panel.get_combined_minimum_size()
	panel.size = Vector2(target_width, minimum.y)
	panel.set_meta("worldmap_editor_default_position", _get_editor_default_position(panel, is_left))


func _get_editor_default_position(panel: Control, is_left: bool) -> Vector2:
	var side_margin := maxf(float(TEST_HOST_SCRIPT.HUD_MIN_SIDE_MARGIN), WORLD_SIZE.x * float(TEST_HOST_SCRIPT.HUD_SIDE_MARGIN_RATIO))
	var top_margin := maxf(float(TEST_HOST_SCRIPT.HUD_MIN_TOP_MARGIN), WORLD_SIZE.y * float(TEST_HOST_SCRIPT.HUD_TOP_MARGIN_RATIO))
	if is_left:
		return Vector2(side_margin, top_margin)
	return Vector2(WORLD_SIZE.x - side_margin - panel.size.x, top_margin)


func _apply_territory_preview(test_root: Node, world_root: Node) -> void:
	var route_layer := world_root.get_node_or_null("RouteLayer")
	var city_layer := world_root.get_node_or_null("CityLayer")
	if route_layer == null or city_layer == null:
		return

	if _territory_layer == null or not is_instance_valid(_territory_layer):
		_territory_layer = ColorRect.new()
		_territory_layer.name = EDITOR_TERRITORY_NAME
		_territory_layer.position = Vector2.ZERO
		_territory_layer.size = WORLD_SIZE
		_territory_layer.color = Color.WHITE
		_territory_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# No owner is assigned: this is a live editor preview only and is never
		# serialized into WorldMap.tscn or the test scene.
		world_root.add_child(_territory_layer)

		_territory_material = ShaderMaterial.new()
		_territory_material.shader = TERRITORY_SHADER
		_territory_layer.material = _territory_material

		# Insert once, directly above the map tiles and below RouteLayer/CityLayer.
		world_root.move_child(_territory_layer, route_layer.get_index())

	if _territory_layer.get_parent() != world_root or _territory_material == null:
		return
	_territory_material.set_shader_parameter("land_sea_mask", LAND_SEA_MASK)
	_territory_material.set_shader_parameter("world_size", WORLD_SIZE)

	var radius := 80.0
	var falloff := 30.0
	var overlay_opacity := 0.35
	var runtime_controller := test_root.get_node_or_null("TerritoryTestController")
	if runtime_controller != null:
		var radius_value = runtime_controller.get("radius")
		var falloff_value = runtime_controller.get("falloff")
		var opacity_value = runtime_controller.get("overlay_opacity")
		if radius_value != null:
			radius = float(radius_value)
		if falloff_value != null:
			falloff = float(falloff_value)
		if opacity_value != null:
			overlay_opacity = float(opacity_value)

	_territory_material.set_shader_parameter("radius", radius)
	_territory_material.set_shader_parameter("falloff", falloff)
	_territory_material.set_shader_parameter("overlay_opacity", overlay_opacity)
	_refresh_territory_uniforms(city_layer)


func _refresh_territory_uniforms(city_layer: Node) -> void:
	if _territory_material == null:
		return

	var markers: Array[Node2D] = []
	for child in city_layer.get_children():
		if child is Node2D and child.get("city_id") != null and child.get("owner_faction_id") != null:
			markers.append(child as Node2D)
	markers.sort_custom(
		func(a: Node2D, b: Node2D) -> bool:
			return str(a.get("city_id")) < str(b.get("city_id"))
	)

	var city_positions: Array[Vector2] = []
	var city_colors: Array[Vector4] = []
	city_positions.resize(MAX_CITIES)
	city_colors.resize(MAX_CITIES)
	for i in range(MAX_CITIES):
		city_positions[i] = Vector2.ZERO
		city_colors[i] = Vector4.ZERO

	var owner_colors: Dictionary = CITY_MARKER_SCRIPT.OWNER_COLORS
	var city_count := mini(markers.size(), MAX_CITIES)
	for i in range(city_count):
		var marker := markers[i]
		var faction_id := str(marker.get("owner_faction_id"))
		if not owner_colors.has(faction_id):
			continue
		var faction_color: Color = owner_colors[faction_id]
		city_positions[i] = marker.position
		city_colors[i] = Vector4(faction_color.r, faction_color.g, faction_color.b, faction_color.a)

	_territory_material.set_shader_parameter("city_count", city_count)
	_territory_material.set_shader_parameter("city_positions", city_positions)
	_territory_material.set_shader_parameter("city_colors", city_colors)
