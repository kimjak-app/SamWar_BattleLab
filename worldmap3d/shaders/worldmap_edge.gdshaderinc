// EASTWAR WorldMap3D v3 — shared map-edge mist (terrain land+sea AND the open-sea outer ring use the same
// function, so the DEM rectangle never shows as a straight cut). Outside the map rect mist = 1.
uniform sampler2D warp_tex : filter_linear_mipmap, repeat_enable;
uniform vec2 map_size_km = vec2(1140.4, 1331.4);
uniform float edge_mist_km = 130.0;
uniform vec3 mist_color : source_color = vec3(0.11, 0.22, 0.42);   // v3.1: brighter, matches the lit v2 open sea
uniform vec3 mist_color_hi : source_color = vec3(0.15, 0.27, 0.46);

float edge_mist(vec2 p) {
	vec2 h = map_size_km * 0.5;
	float ed = min(h.x - abs(p.x), h.y - abs(p.y));          // >0 inside the map
	vec3 w = texture(warp_tex, p / 300.0).rgb - 0.5;
	vec3 w2 = texture(warp_tex, p / 90.0 + 0.41).rgb - 0.5;
	float e = ed + (w.z + w2.x * 0.5) * edge_mist_km * 0.9 - edge_mist_km * 0.15;
	return 1.0 - smoothstep(0.0, edge_mist_km, e);
}

vec3 edge_mist_color(vec2 p) {
	float c = texture(warp_tex, p / 420.0 + 0.13).g;
	return mix(mist_color, mist_color_hi, smoothstep(0.35, 0.8, c) * 0.6);
}
