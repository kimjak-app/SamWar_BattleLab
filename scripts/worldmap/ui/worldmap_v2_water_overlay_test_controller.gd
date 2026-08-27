extends Node

const V2_TEXTURE: Texture2D = preload("res://assets/source/worldmap/worldmap_bg_v2_test.png")
const TILE_SCALE := Vector2(0.5, 0.5)
const OVERLAY_SPRITE_NAME := "V2WaterOverlaySprite"
const OVERLAY_SHADER_CODE := """
shader_type canvas_item;
render_mode unshaded;

uniform float shimmer_strength : hint_range(0.0, 1.0) = 0.055;
uniform float foam_strength : hint_range(0.0, 1.0) = 0.075;
uniform float flow_speed : hint_range(0.0, 1.0) = 0.16;
uniform vec4 highlight_tint : source_color = vec4(0.95, 0.98, 1.0, 1.0);

float get_max3(vec3 v) {
	return max(max(v.r, v.g), v.b);
}

float get_min3(vec3 v) {
	return min(min(v.r, v.g), v.b);
}

float water_mask(vec3 rgb) {
	float saturation = get_max3(rgb) - get_min3(rgb);
	float cyan_bias = smoothstep(0.20, 0.48, rgb.g) * smoothstep(0.28, 0.62, rgb.b);
	float cool_bias = smoothstep(0.02, 0.16, rgb.g - rgb.r) * smoothstep(0.04, 0.18, rgb.b - rgb.r);
	float warm_reject = smoothstep(0.03, 0.20, rgb.r - rgb.g) * smoothstep(0.02, 0.18, rgb.r - rgb.b);
	float mask = max(cyan_bias, cool_bias);
	mask *= smoothstep(0.015, 0.14, saturation + max(0.0, rgb.b - rgb.r) * 0.35);
	mask *= 1.0 - (warm_reject * 0.9);
	return clamp(mask, 0.0, 1.0);
}

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	vec3 rgb = src.rgb;
	float mask = water_mask(rgb);

	float band_a = 0.5 + 0.5 * sin(UV.x * 28.0 + UV.y * 13.0 - TIME * (0.45 + flow_speed));
	float band_b = 0.5 + 0.5 * sin(UV.x * 42.0 - UV.y * 12.0 + TIME * (0.38 + flow_speed * 0.8));
	float band_c = 0.5 + 0.5 * sin(UV.x * 19.0 + UV.y * 21.0 + TIME * 0.26);
	float shimmer = pow(max(band_a * 0.58 + band_b * 0.42, 0.0), 3.8);

	float brightness = dot(rgb, vec3(0.299, 0.587, 0.114));
	float chroma = get_max3(rgb) - get_min3(rgb);
	float foam_mask = mask * smoothstep(0.56, 0.82, brightness) * (1.0 - smoothstep(0.10, 0.34, chroma));
	float foam_flow = pow(band_c, 3.0) * foam_mask;

	float alpha = mask * shimmer * shimmer_strength + foam_flow * foam_strength;
	alpha = clamp(alpha, 0.0, 0.14) * src.a;
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
	return material
