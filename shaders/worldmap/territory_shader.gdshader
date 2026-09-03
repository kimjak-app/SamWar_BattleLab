shader_type canvas_item;
render_mode unshaded;

const int MAX_CITIES = 64;

uniform sampler2D land_sea_mask : filter_linear, repeat_disable;
uniform vec2 world_size = vec2(2048.0, 1152.0);
uniform int city_count = 0;
uniform vec2 city_positions[MAX_CITIES];
uniform vec4 city_colors[MAX_CITIES];
uniform float radius = 80.0;
uniform float falloff = 30.0;
uniform float overlay_opacity = 0.35;

void fragment() {
	vec2 world_pos = UV * world_size;
	float nearest_distance_squared = 1.0e20;
	vec4 nearest_color = vec4(0.0);

	for (int i = 0; i < MAX_CITIES; i++) {
		if (i >= city_count) {
			break;
		}
		vec2 delta = world_pos - city_positions[i];
		float distance_squared = dot(delta, delta);
		if (distance_squared < nearest_distance_squared) {
			nearest_distance_squared = distance_squared;
			nearest_color = city_colors[i];
		}
	}

	float influence = 0.0;
	if (city_count > 0) {
		float nearest_distance = sqrt(nearest_distance_squared);
		float fade_end = radius + max(falloff, 0.001);
		influence = 1.0 - smoothstep(radius, fade_end, nearest_distance);
	}

	// W3-1 contract: mask and global opacity are multiplied into the final alpha
	// immediately before compositing, so sea pixels can never receive territory tint.
	float land_amount = texture(land_sea_mask, UV).r;
	float final_alpha = influence * land_amount * overlay_opacity * nearest_color.a;

	COLOR = vec4(nearest_color.rgb, final_alpha);
}
