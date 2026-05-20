shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float edge_softness : hint_range(0.001, 0.4) = 0.12;
uniform float noise_strength : hint_range(0.0, 0.5) = 0.18;
uniform vec2 spread_center = vec2(0.5, 0.5);

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amplitude * noise(p);
		p *= 2.03;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 centered_uv = UV - spread_center;
	float spread_distance = length(centered_uv * vec2(1.0, 0.78));
	float ink_noise = fbm(UV * 8.0) - 0.5;
	float reveal_radius = mix(0.02, 0.72, progress);
	float noisy_radius = reveal_radius + ink_noise * noise_strength;
	float mask = 1.0 - smoothstep(noisy_radius - edge_softness, noisy_radius, spread_distance);

	COLOR = vec4(tex.rgb, tex.a * mask);
}
