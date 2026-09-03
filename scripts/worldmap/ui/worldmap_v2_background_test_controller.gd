extends Node

const V2_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_bg_v2_test.png")
const EXPECTED_SOURCE_SIZE := Vector2i(4096, 2304)
const TILE_SCALE := Vector2(0.5, 0.5)

var _applied := false


func _ready() -> void:
	# The existing 16:9 host reapplies the locked Design-1 background deferred
	# during startup. Apply Design-2 once on the first process frame so this
	# test-only controller wins before presentation without touching production.
	set_process(true)


func _process(_delta: float) -> void:
	if _applied:
		set_process(false)
		return
	_apply_v2_background()
	_applied = true
	set_process(false)


func _apply_v2_background() -> void:
	if V2_TEXTURE.get_width() != EXPECTED_SOURCE_SIZE.x or V2_TEXTURE.get_height() != EXPECTED_SOURCE_SIZE.y:
		push_warning(
			"WorldMap V2 Background Test: expected %dx%d source, got %dx%d."
			% [
				EXPECTED_SOURCE_SIZE.x,
				EXPECTED_SOURCE_SIZE.y,
				V2_TEXTURE.get_width(),
				V2_TEXTURE.get_height(),
			]
		)

	var test_root := get_parent()
	if test_root == null:
		push_warning("WorldMap V2 Background Test: test root is missing.")
		return

	var production_world_map := test_root.get_node_or_null("ProductionWorldMap")
	if production_world_map == null:
		push_warning("WorldMap V2 Background Test: ProductionWorldMap is missing.")
		return

	var world_root := production_world_map.get_node_or_null("WorldMapRoot")
	if world_root == null:
		push_warning("WorldMap V2 Background Test: WorldMapRoot is missing.")
		return

	var tile_layer := world_root.get_node_or_null("WorldMapTileLayer")
	if tile_layer == null:
		push_warning("WorldMap V2 Background Test: WorldMapTileLayer is missing.")
		return

	# Same four-region atlas contract as the approved Design-1 test host:
	# 4096x2304 source -> four 2048x1152 regions -> 0.5 scale
	# -> exact 2048x1152 Godot world space.
	_apply_tile(tile_layer, "Tile_A1_TopLeft", Rect2(0, 0, 2048, 1152), Vector2(0, 0))
	_apply_tile(tile_layer, "Tile_A2_TopRight", Rect2(2048, 0, 2048, 1152), Vector2(1024, 0))
	_apply_tile(tile_layer, "Tile_B1_BottomLeft", Rect2(0, 1152, 2048, 1152), Vector2(0, 576))
	_apply_tile(tile_layer, "Tile_B2_BottomRight", Rect2(2048, 1152, 2048, 1152), Vector2(1024, 576))


func _apply_tile(tile_layer: Node, node_name: String, region: Rect2, target_position: Vector2) -> void:
	var sprite := tile_layer.get_node_or_null(node_name) as Sprite2D
	if sprite == null:
		push_warning("WorldMap V2 Background Test: missing tile node %s." % node_name)
		return

	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = V2_TEXTURE
	atlas_texture.region = region

	sprite.texture = atlas_texture
	sprite.centered = false
	sprite.position = target_position
	sprite.rotation = 0.0
	sprite.scale = TILE_SCALE
