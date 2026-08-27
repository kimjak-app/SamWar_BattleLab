extends Node

const V2_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_bg_v2_test.png")
const LAND_MASK_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_bg_v2_land_mask.png")
const TILE_SCALE := Vector2(0.5, 0.5)
const OVERLAY_SPRITE_NAME := "V2WaterOverlaySprite"
const OVERLAY_SHADER_CODE := """
shader_type canvas_item;
render_mode unshaded, blend_add;

uniform sampler2D land_mask : filter_linear, repeat_disable;
uniform vec2 mask_texel_size = vec2(0.00048828125, 0.00086805556);
uniform float coast_strength : hint_range(0.0, 1.0) = 0.18;
uniform float foam_strength : hint_range(0.0, 1.0) = 0.12;
uniform float open_water_strength : hint_range(0.0, 1.0) = 0.022;
uniform vec4 highlight_tint : source_color = vec4(0.84, 0.94, 1.0, 1.0);

float get_max3(vec3 v) {
	return max(max(v.r, v.g), v.b);
}

float get_min3(vec3 v) {
	return min(min(v.r, v.g), v.b);
}

float land_alpha(vec2 uv) {
	return texture(land_mask, clamp(uv, vec2(0.0), vec2(1.0))).a;
}

float sample_land_ring(vec2 uv, float radius_px) {
	vec2 dx = vec2(mask_texel_size.x * radius_px, 0.0);
	vec2 dy = vec2(0.0, mask_texel_size.y * radius_px);
	vec2 dd = vec2(mask_texel_size.x * radius_px * 0.7071, mask_texel_size.y * radius_px * 0.7071);

	float ring = 0.0;
	ring = max(ring, land_alpha(uv + dx));
	ring = max(ring, land_alpha(uv - dx));
	ring = max(ring, land_alpha(uv + dy));
	ring = max(ring, land_alpha(uv - dy));
	ring = max(ring, land_alpha(uv + dd));
	ring = max(ring, land_alpha(uv - dd));
	ring = max(ring, land_alpha(uv + vec2(dd.x, -dd.y)));
	ring = max(ring, land_alpha(uv + vec2(-dd.x, dd.y)));
	return ring;
}

float coast_proximity(vec2 uv) {
	float near_land = sample_land_ring(uv, 24.0);
	float mid_land = sample_land_ring(uv, 56.0);
	float far_land = sample_land_ring(uv, 96.0);
	return clamp(near_land + mid_land * 0.58 + far_land * 0.24, 0.0, 1.0);
}

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	vec3 rgb = src.rgb;

	float land = smoothstep(0.06, 0.94, land_alpha(UV));
	float water = 1.0 - land;
	float coast = water * coast_proximity(UV);

	// Narrow ridges oscillate back and forth instead of travelling away from land.
	float wobble_a = sin(TIME * 0.34) * 0.62;
	float wobble_b = cos(TIME * 0.27) * 0.48;
	float ridge_a = pow(0.5 + 0.5 * sin(UV.x * 96.0 + UV.y * 31.0 + wobble_a), 6.5);
	float ridge_b = pow(0.5 + 0.5 * sin(UV.x * 71.0 - UV.y * 43.0 - wobble_a * 0.55 + wobble_b), 7.0);
	float ridge_mix = clamp(ridge_a * 0.62 + ridge_b * 0.46, 0.0, 1.0);

	float brightness = dot(rgb, vec3(0.299, 0.587, 0.114));
	float chroma = get_max3(rgb) - get_min3(rgb);
	float existing_foam = smoothstep(0.40, 0.76, brightness) * (1.0 - smoothstep(0.10, 0.30, chroma));
	float foam_pulse = 0.60 + 0.40 * sin(TIME * 0.48 + sin(UV.x * 28.0) * 1.10 + cos(UV.y * 25.0) * 1.05);

	float coast_shimmer = coast * ridge_mix * coast_strength;
	float foam_shimmer = coast * existing_foam * max(foam_pulse, 0.0) * foam_strength;
	float open_shimmer = water * ridge_mix * open_water_strength;
	float alpha = clamp(coast_shimmer + foam_shimmer + open_shimmer, 0.0, 0.20) * src.a;

	COLOR = vec4(highlight_tint.rgb, alpha);
}
"""

var _applied := false


func _ready() -> void:
	# Test-only experimental overlay. Wait one frame so the Design-2 background
	# controller wins first, then add a separate transparent shimmer layer.
	set_process(true)


func _process(_delta: float) -> void:
	if _applied:
		set_process(false)
		return
	_apply_water_overlay()
	_applied = true
	set_process(false)


func _apply_water_overlay() -> void:
	var test_root := get_parent()
	if test_root == null:
		push_warning("WorldMap V2 Water Overlay Test: test root is missing.")
		return

	var production_world_map := test_root.get_node_or_null("ProductionWorldMap")
	if production_world_map == null:
		push_warning("WorldMap V2 Water Overlay Test: ProductionWorldMap is missing.")
		return

	var world_root := production_world_map.get_node_or_null("WorldMapRoot")
	if world_root == null:
		push_warning("WorldMap V2 Water Overlay Test: WorldMapRoot is missing.")
		return

	var tile_layer := world_root.get_node_or_null("WorldMapTileLayer")
	if tile_layer == null:
		push_warning("WorldMap V2 Water Overlay Test: WorldMapTileLayer is missing.")
		return

	var overlay := tile_layer.get_node_or_null(OVERLAY_SPRITE_NAME) as Sprite2D
	if overlay == null:
		overlay = Sprite2D.new()
		overlay.name = OVERLAY_SPRITE_NAME
		tile_layer.add_child(overlay)

	overlay.texture = V2_TEXTURE
	overlay.centered = false
	overlay.position = Vector2.ZERO
	overlay.rotation = 0.0
	overlay.scale = TILE_SCALE
	overlay.material = _build_water_material()
	tile_layer.move_child(overlay, tile_layer.get_child_count() - 1)


func _build_water_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = OVERLAY_SHADER_CODE

	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("land_mask", LAND_MASK_TEXTURE)
	material.set_shader_parameter(
		"mask_texel_size",
		Vector2(
			1.0 / float(max(LAND_MASK_TEXTURE.get_width(), 1)),
			1.0 / float(max(LAND_MASK_TEXTURE.get_height(), 1))
		)
	)
	return material
