// EASTWAR WorldMap3D v3 — open-sea plane = low-res OUTER RING beyond the terrain mesh (to the horizon).
// Inside the map it reads the same data texture; toward/after the map border it fades into the shared edge mist.
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
#include "res://worldmap3d/shaders/worldmap_sea.gdshaderinc"
#include "res://worldmap3d/shaders/worldmap_edge.gdshaderinc"
uniform float anim_time = -1.0;   // >= 0: freeze animation at this time (tests / reproducible captures)
uniform sampler2D coast_tex : filter_linear_mipmap, repeat_disable;
uniform sampler2D depth_tex : filter_linear_mipmap, repeat_disable;
uniform float coast_sdf_km = 8.0;
varying vec3 world_pos;
void vertex() { world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float _t = anim_time >= 0.0 ? anim_time : TIME;
	vec2 p = world_pos.xz;
	vec2 uv = p / map_size_km + 0.5;
	float depth_m = 2000.0; float coast_km = -60.0;
	if (uv.x > 0.0 && uv.y > 0.0 && uv.x < 1.0 && uv.y < 1.0) {
		depth_m = decode_depth_m(texture(depth_tex, uv)); coast_km = (texture(coast_tex, uv).r * 2.0 - 1.0) * coast_sdf_km;
	}
	vec3 col; vec3 n;
	sea_surface(p, depth_m, coast_km, _t, screen_dither(FRAGCOORD.xy), col, n);
	float mist = edge_mist(p);
	col = mix(col, edge_mist_color(p), mist);
	ALBEDO = col;
	NORMAL = normalize((VIEW_MATRIX * vec4(normalize(mix(n, vec3(0.0, 1.0, 0.0), mist)), 0.0)).xyz);
	ROUGHNESS = mix(0.22, 0.45, mist);
	SPECULAR = mix(0.55, 0.35, mist);
}
