// EASTWAR WorldMap3D — screen vignette (frames the map, hides far-zoom map edges)
shader_type canvas_item;
uniform float strength : hint_range(0.0, 1.0) = 0.6;
uniform vec3 tint : source_color = vec3(0.01, 0.035, 0.09);
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float dx = smoothstep(0.56, 0.96, abs(p.x));
	float dy = smoothstep(0.70, 1.05, abs(p.y));
	float r = smoothstep(0.75, 1.55, length(p * vec2(1.0, 0.9)));
	float a = clamp(max(max(dx, dy) * 0.95, r), 0.0, 1.0) * strength;
	COLOR = vec4(tint, a);
}
