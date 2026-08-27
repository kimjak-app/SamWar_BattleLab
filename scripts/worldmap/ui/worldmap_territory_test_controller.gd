extends Node

const WORLD_SIZE := Vector2(2048.0, 1152.0)
const EXPECTED_MASK_SIZE := Vector2i(4096, 2304)
const MAX_CITIES := 64
const TERRITORY_LAYER_NAME := "TerritoryLayer"
const LAND_SEA_MASK: Texture2D = preload("res://assets/source/worldmap/worldmap_land_sea_mask_v1_0_4096x2304.png")
const TERRITORY_SHADER: Shader = preload("res://shaders/worldmap/territory_shader.gdshader")
const CITY_MARKER_SCRIPT := preload("res://scripts/worldmap_city_marker.gd")

@export_range(1.0, 512.0, 1.0) var radius: float = 80.0
@export_range(0.0, 256.0, 1.0) var falloff: float = 30.0
@export_range(0.0, 1.0, 0.01) var overlay_opacity: float = 0.35

var _initialized := false
var _territory_layer: ColorRect
var _territory_material: ShaderMaterial


func _ready() -> void:
	# The 16:9 host applies approved city positions deferred, and the Design-2
	# controller swaps the background on the first process frame. Build after
	# those test-only setup steps have had a chance to establish the final world.
	set_process(true)


func _process(_delta: float) -> void:
	if _initialized:
		set_process(false)
		return
	_initialized = true
	_initialize_territory_layer()
	set_process(false)


func _initialize_territory_layer() -> void:
	if LAND_SEA_MASK.get_width() != EXPECTED_MASK_SIZE.x or LAND_SEA_MASK.get_height() != EXPECTED_MASK_SIZE.y:
		push_error(
			"WorldMap Territory Test: expected %dx%d land/sea mask, got %dx%d."
			% [
				EXPECTED_MASK_SIZE.x,
				EXPECTED_MASK_SIZE.y,
				LAND_SEA_MASK.get_width(),
				LAND_SEA_MASK.get_height(),
			]
		)
		return

	var test_root := get_parent()
	if test_root == null:
		push_error("WorldMap Territory Test: test root is missing.")
		return

	var production_world_map := test_root.get_node_or_null("ProductionWorldMap")
	if production_world_map == null:
		push_error("WorldMap Territory Test: ProductionWorldMap is missing.")
		return

	var world_root := production_world_map.get_node_or_null("WorldMapRoot")
	if world_root == null:
		push_error("WorldMap Territory Test: WorldMapRoot is missing.")
		return

	var route_layer := world_root.get_node_or_null("RouteLayer")
	var city_layer := world_root.get_node_or_null("CityLayer")
	if route_layer == null or city_layer == null:
		push_error("WorldMap Territory Test: RouteLayer or CityLayer is missing.")
		return

	_territory_layer = world_root.get_node_or_null(TERRITORY_LAYER_NAME) as ColorRect
	if _territory_layer == null:
		_territory_layer = ColorRect.new()
		_territory_layer.name = TERRITORY_LAYER_NAME
		world_root.add_child(_territory_layer)

	_territory_layer.position = Vector2.ZERO
	_territory_layer.size = WORLD_SIZE
	_territory_layer.color = Color.WHITE
	_territory_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_territory_layer.show_behind_parent = false

	_territory_material = ShaderMaterial.new()
	_territory_material.shader = TERRITORY_SHADER
	_territory_layer.material = _territory_material

	# Keep the overlay above the map tiles but below routes, city markers and HUD.
	world_root.move_child(_territory_layer, route_layer.get_index())

	_apply_shader_parameters()
	refresh_territory_data()


func _apply_shader_parameters() -> void:
	if _territory_material == null:
		return
	_territory_material.set_shader_parameter("land_sea_mask", LAND_SEA_MASK)
	_territory_material.set_shader_parameter("world_size", WORLD_SIZE)
	_territory_material.set_shader_parameter("radius", radius)
	_territory_material.set_shader_parameter("falloff", falloff)
	_territory_material.set_shader_parameter("overlay_opacity", overlay_opacity)


func refresh_territory_data() -> void:
	if _territory_material == null or _territory_layer == null:
		return

	var world_root := _territory_layer.get_parent()
	if world_root == null:
		return
	var city_layer := world_root.get_node_or_null("CityLayer")
	if city_layer == null:
		push_warning("WorldMap Territory Test: CityLayer is missing during refresh.")
		return

	var markers: Array[Node2D] = []
	for child in city_layer.get_children():
		if not child is Node2D:
			continue
		if child.get("city_id") == null or child.get("owner_faction_id") == null:
			continue
		markers.append(child as Node2D)

	markers.sort_custom(
		func(a: Node2D, b: Node2D) -> bool:
			return str(a.get("city_id")) < str(b.get("city_id"))
	)

	if markers.size() > MAX_CITIES:
		push_warning(
			"WorldMap Territory Test: %d cities found; only first %d can be rendered."
			% [markers.size(), MAX_CITIES]
		)

	var city_positions: Array[Vector2] = []
	var city_colors: Array[Vector4] = []
	city_positions.resize(MAX_CITIES)
	city_colors.resize(MAX_CITIES)
	for i in range(MAX_CITIES):
		city_positions[i] = Vector2.ZERO
		city_colors[i] = Vector4.ZERO

	var owner_colors: Dictionary = CITY_MARKER_SCRIPT.OWNER_COLORS
	var city_count := min(markers.size(), MAX_CITIES)
	for i in range(city_count):
		var marker := markers[i]
		var faction_id := str(marker.get("owner_faction_id"))
		if not owner_colors.has(faction_id):
			push_warning(
				"WorldMap Territory Test: owner color missing for city %s faction %s."
				% [str(marker.get("city_id")), faction_id]
			)
			continue
		var faction_color: Color = owner_colors[faction_id]
		city_positions[i] = marker.position
		city_colors[i] = Vector4(
			faction_color.r,
			faction_color.g,
			faction_color.b,
			faction_color.a
		)

	_territory_material.set_shader_parameter("city_count", city_count)
	_territory_material.set_shader_parameter("city_positions", city_positions)
	_territory_material.set_shader_parameter("city_colors", city_colors)
