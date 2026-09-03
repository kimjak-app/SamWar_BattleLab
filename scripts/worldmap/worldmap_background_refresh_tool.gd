@tool
class_name WorldMapBackgroundRefreshTool
extends RefCounted

const MASTER_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_master_4096x2912.png")
const TURN_COMPASS_SCRIPT := preload("res://scripts/worldmap/worldmap_turn_compass.gd")
const TILE_SCALE := Vector2(0.5, 0.5)
const WORLD_SIZE := Vector2(2048.0, 1456.0)
const CAMERA_MIN_ZOOM := 0.35
const CAMERA_MAX_ZOOM := 1.6
const CAMERA_DEFERRED_META := "worldmap_refresh_camera_deferred"
const CAMERA_APPLIED_META := "worldmap_refresh_camera_applied"


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

	_schedule_initial_camera_cover(context, world_root)
	_ensure_turn_compass(world_root)


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


static func _ensure_turn_compass(world_root: Node) -> void:
	if Engine.is_editor_hint():
		return
	if world_root == null:
		return

	var world_scene := world_root.get_parent()
	if world_scene == null:
		return
	var world_ui := world_scene.get_node_or_null("WorldMapUI")
	if world_ui == null:
		return

	var compass := world_ui.get_node_or_null("TurnEndCompass")
	if compass == null:
		compass = TURN_COMPASS_SCRIPT.new()
		compass.name = "TurnEndCompass"
		world_ui.add_child(compass)

	if compass.has_method("bind_world_scene"):
		compass.call("bind_world_scene", world_scene)


static func _schedule_initial_camera_cover(context: Node, world_root: Node) -> void:
	if Engine.is_editor_hint():
		return
	if context.get_meta(CAMERA_APPLIED_META, false):
		return

	# City markers become ready before the WorldMap root. Defer once so the root's
	# legacy 0.7 camera setup finishes first, then replace only the initial framing.
	if not context.get_meta(CAMERA_DEFERRED_META, false):
		context.set_meta(CAMERA_DEFERRED_META, true)
		context.call_deferred("_ensure_worldmap_refresh_background")
		return

	_apply_initial_camera_cover(context, world_root)
	context.set_meta(CAMERA_APPLIED_META, true)


static func _apply_initial_camera_cover(context: Node, world_root: Node) -> void:
	var world_scene := world_root.get_parent()
	if world_scene == null:
		return
	var camera := world_scene.get_node_or_null("WorldMapCamera") as Camera2D
	if camera == null:
		return

	var viewport := context.get_viewport()
	if viewport == null:
		return
	var viewport_size := viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	# Cover the full viewport without stretching the map. On 16:9 screens the map
	# fills the width, keeps the title/top edge visible, and lets excess lower sea
	# extend below the viewport for normal pan/zoom access.
	var width_zoom := viewport_size.x / WORLD_SIZE.x
	var height_zoom := viewport_size.y / WORLD_SIZE.y
	var cover_zoom := clampf(maxf(width_zoom, height_zoom), CAMERA_MIN_ZOOM, CAMERA_MAX_ZOOM)
	var visible_world_size := viewport_size / cover_zoom

	camera.zoom = Vector2(cover_zoom, cover_zoom)
	camera.position = Vector2(
		WORLD_SIZE.x * 0.5,
		visible_world_size.y * 0.5
	)
