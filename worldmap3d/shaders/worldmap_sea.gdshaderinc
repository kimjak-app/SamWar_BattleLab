// EASTWAR WorldMap3D v3 — shared sea look (terrain shader + open-sea plane). Works in Forward+ and Compatibility.
// v3: depth arrives in METRES (16-bit, pre-smoothed in the bake) -> no stepped shallow-sea blotches;
// colour ramps are in metres; a tiny screen dither breaks 8-bit banding; v3.1: brightness/colour restored to v2 (sea_lift, v2 coast band).
uniform sampler2D wave_tex : filter_linear_mipmap, repeat_enable;
uniform vec3 sea_deep : source_color = vec3(0.025, 0.08, 0.22);
uniform vec3 sea_mid : source_color = vec3(0.035, 0.17, 0.38);
uniform vec3 sea_shallow : source_color = vec3(0.05, 0.24, 0.44);
uniform vec3 sea_coast : source_color = vec3(0.30, 0.70, 0.78);
uniform vec3 sea_mudflat : source_color = vec3(0.47, 0.50, 0.46);
uniform float sea_coast_band_km = 1.4;
uniform float sea_coast_strength = 0.60;
// v2 brightness: v2 added a near-constant (0.05, 0.08, 0.10) "streak" lift over everything deeper than ~30 m
// (it read the normal map B channel, ~1.0). The user liked that brighter, less navy sea -> kept as an explicit lift.
uniform vec3 sea_lift = vec3(0.05, 0.08, 0.10);
uniform float depth_max_m = 4000.0;
uniform float wave_scale_km = 5.0;
uniform float wave_strength = 0.28;
uniform float wave_speed = 1.0;

// depth_tex: LA8 (VRAM RG8, sampled as .r = L = hi byte, .a = A = lo byte); linear filtering of hi/lo separately
// stays exact because hi*256+lo is linear in both.
float decode_depth_m(vec4 dt) {
	float n = (dt.r * 65280.0 + dt.a * 255.0) / 65535.0;
	return n * n * depth_max_m;
}

float screen_dither(vec2 frag) {
	return fract(52.9829189 * fract(dot(frag, vec2(0.06711056, 0.00583715)))) - 0.5;   // interleaved gradient noise
}

void sea_surface(vec2 xz, float depth_m, float coast_km, float t, float dith, out vec3 col, out vec3 nrm_w) {
	float dm = depth_m * (1.0 + dith * 0.08);
	col = mix(sea_shallow, sea_mid, smoothstep(1.2, 77.0, dm));
	col = mix(col, sea_deep, smoothstep(173.0, 1920.0, dm));
	float band = exp(min(coast_km, 0.0) / sea_coast_band_km);
	col = mix(col, sea_coast, band * sea_coast_strength);
	float mud = (1.0 - smoothstep(0.0, 15.0, dm + dith * 4.0)) * exp(min(coast_km, 0.0) / 6.0);
	col = mix(col, sea_mudflat, mud * 0.5);
	float tt = t * wave_speed;
	vec2 uv1 = xz / wave_scale_km + vec2(tt * 0.021, tt * 0.013);
	vec2 uv2 = xz / (wave_scale_km * 2.9) + vec2(-tt * 0.010, tt * 0.017);
	vec2 uv3 = xz / (wave_scale_km * 11.0) + vec2(tt * 0.004, -tt * 0.003);
	vec2 a = texture(wave_tex, uv1).rg * 2.0 - 1.0;
	vec2 b = texture(wave_tex, uv2).rg * 2.0 - 1.0;
	vec2 c = texture(wave_tex, uv3).rg * 2.0 - 1.0;
	vec2 d = (a * 0.5 + b * 0.35 + c * 0.6) * wave_strength;
	nrm_w = normalize(vec3(d.x, 1.0, d.y));
	// slow light streaks. v2 read the normal map's B channel (~1.0 everywhere) -> a constant milky veil over the
	// deep sea; v3 uses the X slope channel so the streaks are actual sparse bands.
	float streak = smoothstep(0.60, 0.85, texture(wave_tex, uv3 * 0.37).r);
	col += sea_lift * smoothstep(30.0, 1080.0, dm);
	col += vec3(0.010, 0.020, 0.030) * streak * smoothstep(20.0, 1200.0, dm);
	col += dith / 255.0;
}
