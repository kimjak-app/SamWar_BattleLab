@tool
class_name WorldMapBackgroundRefreshTool
extends RefCounted

const MASTER_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_master_4096x2912.png")
const TILE_SCALE := Vector2(0.5, 0.5)


static func ensure_background(context: Node) -> void:
	if context == null:
		return

	var city_layer := context.get_parent()
	if city_layer == null:
		return
	var world_root := city_layer.get_parent()
	if world_root == null:
		return
	var tile_layer := world_root.get_node_or_null("WorldMapTileLayer")
	if tile_layer == null:
		return

	_apply_tile(tile_layer, "Tile_A1_TopLeft", Rect2(0, 0, 2048, 1456), Vector2(0, 0))
	_apply_tile(tile_layer, "Tile_A2_TopRight", Rect2(2048, 0, 2048, 1456), Vector2(1024, 0))
	_apply_tile(tile_layer, "Tile_B1_BottomLeft", Rect2(0, 1456, 2048, 1456), Vector2(0, 728))
	_apply_tile(tile_layer, "Tile_B2_BottomRight", Rect2(2048, 1456, 2048, 1456), Vector2(1024, 728))


static func _apply_tile(tile_layer: Node, node_name: String, region: Rect2, target_position: Vector2) -> void:
	var sprite := tile_layer.get_node_or_null(node_name) as Sprite2D
	if sprite == null:
		return

	var atlas_texture := sprite.texture as AtlasTexture
	var needs_texture_refresh := atlas_texture == null
	if atlas_texture != null:
		needs_texture_refresh = atlas_texture.atlas != MASTER_TEXTURE or atlas_texture.region != region

	if needs_texture_refresh:
		atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = MASTER_TEXTURE
		atlas_texture.region = region
		sprite.texture = atlas_texture

	sprite.centered = false
	sprite.position = target_position
	sprite.rotation = 0.0
	sprite.scale = TILE_SCALE
