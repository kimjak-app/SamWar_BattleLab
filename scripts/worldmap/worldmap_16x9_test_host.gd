extends Node

const MASTER_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_master_4096x2304.png")
const TILE_SCALE := Vector2(0.5, 0.5)
const WORLD_SIZE := Vector2(2048.0, 1152.0)
const CAMERA_MIN_ZOOM := 0.35
const CAMERA_MAX_ZOOM := 1.6

@export var hide_legacy_world_ui: bool = true

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
	_set_legacy_ui_visibility()
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


func _set_legacy_ui_visibility() -> void:
	var world_ui := production_world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui != null:
		world_ui.visible = not hide_legacy_world_ui


func _on_viewport_size_changed() -> void:
	call_deferred("_apply_camera_fit")


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
