shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Queue 35 reply 2: the open sea of the naval 3D battle (naval_sea_builder.gd). A calm sea on a clear day: one
// nearly plain colour, small waves that all travel one way, a little sun glitter, white foam only in the shallows
// around islands. From the land board's river shader it keeps only the play area's border line, the haze outside
// the play area and the baked shore distance (COLOR.r: 0 at an island's shore, 1 in open water).

// The play area (world xz: min_x, min_z, max_x, max_z), the haze outside it and its border line (as the river shader).
uniform vec4 play_rect = vec4(0.0, 0.0, 54.0, 30.0);
uniform vec3 haze_color : source_color = vec3(0.5529, 0.5373, 0.4784);
uniform float vista_max_distance = 45.0;
uniform bool show_border_line = true;
uniform vec4 border_line_color : source_color = vec4(0.92, 0.84, 0.58, 1.0);
uniform float border_line_width : hint_range(0.05, 0.30) = 0.12;
uniform float border_line_strength : hint_range(0.0, 2.0) = 0.85;

// The current: every wave layer travels along flow_direction (world x, z). The same two values are meant for a later
// rule that lets the current change how far ships move.
uniform vec2 flow_direction = vec2(0.0, 1.0);
uniform float flow_speed = 0.35; // m/s
// The look (defaults = the scenario's `sea` block).
uniform vec4 deep_color : source_color = vec4(0.07, 0.24, 0.34, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.20, 0.47, 0.52, 1.0);
uniform float wave_size = 1.3; // m: one wave is about this wide (smaller than a ship)
uniform float wave_strength : hint_range(0.0, 1.0) = 0.22; // light / dark difference of the waves
uniform float sparkle_strength : hint_range(0.0, 1.0) = 0.3;
uniform float foam_width : hint_range(0.0, 0.5) = 0.16; // of the shore reach
uniform float far_tint : hint_range(0.0, 1.0) = 0.22; // lighter, greyer blue far from the camera
uniform float far_start = 48.0; // m from the camera
uniform float far_end = 92.0;
uniform vec3 sun_direction = vec3(0.287, 0.819, 0.497);

varying vec3 v_world_pos;
varying float v_shore;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_shore = COLOR.r;
}

float hash(vec2 p) {
	p = fract(p * vec2(0.1031, 0.1030));
	p += dot(p, p.yx + 33.33);
	return fract((p.x + p.y) * p.x);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// Wave height (0..1) at a sea point: three layers of small waves, crests lying across the current, each a little
// smaller and slower or faster than the last, all moving the same way.
float sea_height(vec2 p, vec2 along, vec2 across, float time) {
	float size = max(wave_size, 0.2);
	vec2 q = vec2(dot(p, across) * 0.62, dot(p, along)) / size; // longer across the current than along it
	float travel = time * flow_speed / size;
	float h = value_noise(q - vec2(0.0, travel)) * 0.5;
	h += value_noise(q * 1.9 + vec2(11.3, 4.7) - vec2(0.0, travel * 1.35)) * 0.32;
	h += value_noise(q * 3.7 + vec2(3.1, 27.9) - vec2(0.0, travel * 0.8)) * 0.18;
	return h;
}

void fragment() {
	vec2 along = length(flow_direction) > 0.001 ? normalize(flow_direction) : vec2(0.0, 1.0);
	vec2 across = vec2(along.y, -along.x);
	vec2 p = v_world_pos.xz;
	float h = sea_height(p, along, across, TIME);
	float eps = 0.12;
	float hx = sea_height(p + vec2(eps, 0.0), along, across, TIME);
	float hz = sea_height(p + vec2(0.0, eps), along, across, TIME);
	vec3 wave_normal = normalize(vec3(-(hx - h) / eps * 0.5, 1.0, -(hz - h) / eps * 0.5));

	// Colour: the deep colour everywhere, the shallow colour near an island; the waves only shade it a little.
	float shore = clamp(v_shore, 0.0, 1.0);
	vec3 water = mix(shallow_color.rgb, deep_color.rgb, smoothstep(0.0, 0.85, shore));
	water *= 1.0 + (h - 0.5) * wave_strength;

	// Foam: a white line at the shore and a broken band just outside it. Nowhere else.
	float foam_w = max(0.005, foam_width);
	float edge = max(0.0, shore + (h - 0.5) * 0.08);
	float foam_line = 1.0 - smoothstep(0.0, foam_w, edge);
	float foam_band = smoothstep(foam_w * 0.5, foam_w, edge) * (1.0 - smoothstep(foam_w, foam_w * 1.9, edge)) * smoothstep(0.52, 0.7, h);
	float foam = clamp(foam_line * 0.8 + foam_band * 0.5, 0.0, 1.0) * step(shore, 0.999);
	water = mix(water, vec3(0.86, 0.91, 0.92), foam * 0.75);

	// Glitter: small highlights where a wave's slope faces the sun. The same from every camera angle.
	vec3 sun = normalize(sun_direction);
	vec3 half_up = normalize(sun + vec3(0.0, 1.0, 0.0));
	float glint = pow(max(dot(wave_normal, half_up), 0.0), 90.0) * smoothstep(0.55, 0.8, h);
	float sparkle = glint * sparkle_strength * (1.0 - foam);
	water = mix(water, vec3(0.80, 0.90, 0.94), clamp(sparkle, 0.0, 0.6));

	// Distance: lighter and greyer far from the camera.
	float far = smoothstep(far_start, far_end, -VERTEX.z) * far_tint;
	water = mix(water, vec3(0.50, 0.62, 0.70), far);

	// Outside the play area: one cell of toning down, then the haze (as the river shader).
	vec2 d_min = max(play_rect.xy - p, vec2(0.0));
	vec2 d_max = max(p - play_rect.zw, vec2(0.0));
	float outside = length(d_min + d_max);
	vec2 d_in = min(p - play_rect.xy, play_rect.zw - p);
	float border_dist = outside + max(0.0, min(d_in.x, d_in.y));
	float tone = smoothstep(0.0, 3.0, outside);
	float haze = smoothstep(2.5, max(3.0, vista_max_distance), outside);
	float luma = dot(water, vec3(0.299, 0.587, 0.114));
	water = mix(water, mix(water, vec3(luma), 0.45) * 0.9, tone);
	vec3 glow = vec3(0.0);
	if (show_border_line) {
		float half_w = border_line_width * 0.5;
		float aa = clamp(fwidth(border_dist), 0.004, 0.035);
		float line = 1.0 - smoothstep(half_w - aa, half_w + aa, border_dist);
		water = mix(water, border_line_color.rgb, clamp(line * border_line_strength * 0.75, 0.0, 1.0));
		glow += border_line_color.rgb * line * (0.18 * border_line_strength);
	}
	ALBEDO = water * (1.0 - haze);
	ROUGHNESS = mix(0.5, 1.0, haze);
	METALLIC = 0.0;
	SPECULAR = 0.2 * (1.0 - haze);
	EMISSION = mix(glow * (1.0 - haze), haze_color, haze);
}
