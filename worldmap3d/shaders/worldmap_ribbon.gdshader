// EASTWAR WorldMap3D v3 — ribbon lines draped on the terrain (roads, rivers).
// Mesh = centre line duplicated (UV.x = -1/+1), NORMAL = horizontal side vector, COLOR.r = width factor,
// COLOR.g = end taper. The vertex stage widens it: world width, but never thinner than min_px screen pixels
// (no stair-stepping at any zoom). A small pull toward the camera acts as depth bias.
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx, world_vertex_coords, shadows_disabled;

uniform float width_km = 0.45;
uniform float min_px = 1.6;
uniform float fade_px_lo = 0.0;     // world width (px) below which the line fades out (rivers: hide tiny streams far away)
uniform float fade_px_hi = 0.0;
uniform float depth_pull = 0.004;
uniform vec3 core_color : source_color = vec3(0.95, 0.91, 0.78);
uniform vec3 edge_color : source_color = vec3(0.45, 0.36, 0.25);
uniform float edge_from = 0.62;
uniform float opacity = 0.92;
uniform float emission_k = 0.06;

varying float v_fade;
varying float v_wpx;

void vertex() {
	vec3 cam = INV_VIEW_MATRIX[3].xyz;
	float dist = length(cam - VERTEX);
	float px_km = dist * 2.0 / (abs(PROJECTION_MATRIX[1][1]) * VIEWPORT_SIZE.y);   // abs: Vulkan projection has y flipped
	float w = width_km * COLOR.r;
	float wpx = w / px_km;
	v_fade = (fade_px_hi > fade_px_lo) ? smoothstep(fade_px_lo, fade_px_hi, wpx) : 1.0;
	float hw = max(w, min_px * px_km * COLOR.g) * 0.5;
	v_wpx = hw * 2.0 / px_km;
	VERTEX += NORMAL * UV.x * hw;
	VERTEX += (cam - VERTEX) / dist * dist * depth_pull;
	NORMAL = vec3(0.0, 1.0, 0.0);
}

void fragment() {
	float s = abs(UV.x);
	float a = clamp((1.0 - s) / max(fwidth(UV.x), 1e-4) + 0.5, 0.0, 1.0);    // pixel coverage at the ribbon edge
	vec3 c = mix(core_color, edge_color, smoothstep(edge_from, 1.0, s) * smoothstep(3.0, 7.0, v_wpx));  // outline only when wide
	ALBEDO = c;
	EMISSION = c * emission_k;
	ROUGHNESS = 0.8;
	SPECULAR = 0.2;
	ALPHA = a * opacity * v_fade;
}
