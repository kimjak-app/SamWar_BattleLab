shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// === 1. 플레이 구역(18x10칸 -> 월드 xz min_x, min_z, max_x, max_z) 및 선 밖 안개/경계선 ===
uniform vec4 play_rect = vec4(0.0, 0.0, 54.0, 30.0);
uniform vec3 haze_color : source_color = vec3(0.5529, 0.5373, 0.4784); // 기본값 #8d897a (회황색 안개)
uniform float vista_max_distance = 45.0;                                // 선 밖 45m 지점에서 안개 비율 100% 도달

uniform bool show_border_line = true;
uniform vec4 border_line_color : source_color = vec4(0.92, 0.84, 0.58, 1.0);
uniform float border_line_width : hint_range(0.05, 0.30) = 0.12;
uniform float border_line_strength : hint_range(0.0, 2.0) = 0.85;

// === 2. 삼국지 8R 스타일 평면 강물 제어 파라미터 (@export 연동) ===
uniform float water_flow_speed : hint_range(0.0, 1.0) = 0.08;
uniform float water_ripple_scale : hint_range(0.05, 1.0) = 0.22;
uniform float water_foam_width : hint_range(0.0, 0.5) = 0.16;
uniform vec4 water_shallow_color : source_color = vec4(0.27, 0.36, 0.40, 1.0); // 강 가장자리 연한 회청색
uniform vec4 water_deep_color : source_color = vec4(0.14, 0.21, 0.26, 1.0);    // 강 중앙 어두운 저채도 회청색

// lab_presentation.gd 태양광(rotation_degrees = Vector3(-55, -30, 0)) 방향 벡터
uniform vec3 sun_direction = vec3(0.287, 0.819, 0.497);

// 코드에서 생성한 심리스 NoiseTexture2D (외부 PNG 추가 없이 프로시저럴 수면 파형과 결합)
uniform sampler2D ripple_noise_tex : source_color, filter_linear_mipmap, repeat_enable;

varying vec3 v_world_pos;
varying vec4 v_baked_color;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// v_baked_color:
	//   R: 강둑 해안선(y = -0.12)으로부터의 정규화 거리 (0.0 = 해안선 접촉부, 1.0 = 강 중앙)
	//   G: 5행 여울(Ford) 모래톱 가장자리 인접도 (1.0 = 여울 경계, 0.0 = 여울 밖)
	//   B: 가장자리->중앙 수심 그라데이션 가중치
	//   A: 가시 수면 마스크 (강둑 안쪽 숨김 정점은 0.0, 해안선~중앙은 1.0)
	v_baked_color = COLOR;
}

// 외부 PNG 없이도 매끄럽게 동작하는 2D 프로시저럴 잔물결 합성 함수 (Compatibility 100% 호환)
float procedural_ripple_layer(vec2 p) {
	float w1 = sin(p.x * 6.2831853 + sin(p.y * 3.1415926) * 0.85);
	float w2 = cos(p.y * 6.2831853 * 1.35 - cos(p.x * 4.712389) * 0.65);
	float w3 = sin((p.x + p.y * 0.75) * 9.424778);
	return (w1 * 0.45 + w2 * 0.35 + w3 * 0.20) * 0.5 + 0.5;
}

void fragment() {
	float shore_dist = clamp(v_baked_color.r, 0.0, 1.0);
	float ford_prox  = clamp(v_baked_color.g, 0.0, 1.0);
	float depth_grad = clamp(v_baked_color.b, 0.0, 1.0);
	float visible_water = clamp(v_baked_color.a, 0.0, 1.0);

	// 1) 흐름(Flow): 강 진행 방향(+Z, UV.y 증가 방향)으로 속도·크기가 다른 두 겹 잔물결 이동
	// 강둑에 가까울수록 유속이 살짝 완만해지는 자연스러운 유속 분포 반영
	float flow_drag = mix(0.68, 1.0, smoothstep(0.0, 0.38, shore_dist));
	float scale_base = max(0.05, water_ripple_scale);

	// 제1겹: 주 잔물결 (중간 크기, 기본 속도)
	vec2 uv_layer1 = vec2(
		UV.x * 2.2 + sin(UV.y * 0.45) * 0.08,
		UV.y * (scale_base * 2.5) - TIME * (water_flow_speed * 2.4 * flow_drag)
	);
	// 제2겹: 보조 잔물결 (더 촘촘한 크기, 다른 속도·위상)
	vec2 uv_layer2 = vec2(
		UV.x * 3.7 + 0.37 - cos(UV.y * 0.65) * 0.06,
		UV.y * (scale_base * 4.3) - TIME * (water_flow_speed * 1.55 * flow_drag) + 0.43
	);

	float n_tex1 = texture(ripple_noise_tex, uv_layer1 * 0.28).r;
	float n_tex2 = texture(ripple_noise_tex, uv_layer2 * 0.28).r;
	float p_wav1 = procedural_ripple_layer(uv_layer1 * 0.55);
	float p_wav2 = procedural_ripple_layer(uv_layer2 * 0.55);

	float ripple1 = mix(p_wav1, n_tex1, 0.55);
	float ripple2 = mix(p_wav2, n_tex2, 0.55);
	float ripple_combined = ripple1 * 0.58 + ripple2 * 0.42;

	// 수면 미세 기울기(법선 교란) 계산 — 정점 높이는 평평하게 유지하고 조명/반짝임에만 사용
	float eps = 0.04;
	float rx = procedural_ripple_layer((uv_layer1 + vec2(eps, 0.0)) * 0.55) * 0.58
	         + procedural_ripple_layer((uv_layer2 + vec2(eps, 0.0)) * 0.55) * 0.42;
	float rz = procedural_ripple_layer((uv_layer1 + vec2(0.0, eps)) * 0.55) * 0.58
	         + procedural_ripple_layer((uv_layer2 + vec2(0.0, eps)) * 0.55) * 0.42;
	float d_rx = (rx - ripple_combined) / eps;
	float d_rz = (rz - ripple_combined) / eps;
	vec3 water_normal = normalize(vec3(-d_rx * 0.22, 1.0, -d_rz * 0.22));

	// 2) 가장자리는 연하게, 중앙은 어두운 회청색 그라데이션 (삼국지 8R 저채도 톤)
	float center_t = smoothstep(0.0, 0.82, depth_grad) * (1.0 - ford_prox * 0.50);
	vec3 base_water = mix(water_shallow_color.rgb, water_deep_color.rgb, center_t);

	// 물가 극천수 구간(0.0~0.20)에 강바닥 모래·자갈 기운을 아주 은은하게 비침 표현
	vec3 bank_tint = mix(water_shallow_color.rgb, vec3(0.35, 0.38, 0.36), 0.32);
	base_water = mix(bank_tint, base_water, smoothstep(0.0, 0.22, shore_dist));

	// 두 겹 잔물결에 따른 수면 명암 결 추가
	float ripple_band = smoothstep(0.32, 0.72, ripple_combined) - 0.5;
	base_water += ripple_band * vec3(0.050, 0.064, 0.072) * (0.45 + 0.55 * center_t);

	// 3) 강둑 거품선 & 여울(Ford) 가장자리 물거품 (깊이 텍스처 없이 메시 버텍스 컬러 + UV 기반)
	float foam_w = max(0.005, water_foam_width);
	float foam_wave_jitter = (ripple_combined - 0.5) * 0.065;
	float d_edge = max(0.0, shore_dist + foam_wave_jitter);

	// 강둑 접촉선(shore_dist == 0)을 따라 흐르는 1차 흰 거품 줄
	float bank_foam_line = (1.0 - smoothstep(0.0, foam_w, d_edge)) * smoothstep(0.0, 0.12, visible_water);
	// 강둑 바로 안쪽을 따라 흐르는 2차 잔물결 물거품 결
	float inner_foam_band = smoothstep(foam_w * 0.35, foam_w * 0.75, d_edge)
	                      * (1.0 - smoothstep(foam_w * 0.75, foam_w * 1.45, d_edge));
	float bank_foam_lace = inner_foam_band * smoothstep(0.48, 0.74, ripple_combined);

	// 5행 여울(Ford) 모래톱 가장자리 거품 줄
	float ford_foam_line = smoothstep(1.0 - foam_w * 1.65, 1.0, ford_prox + foam_wave_jitter * 1.2) * 0.80;

	float foam_mask = clamp(max(bank_foam_line * 0.82 + bank_foam_lace * 0.45, ford_foam_line), 0.0, 1.0);
	vec3 foam_color = vec3(0.80, 0.86, 0.88);
	base_water = mix(base_water, foam_color, foam_mask * 0.70);

	// 4) 하이라이트(Highlight): 태양 방향에 따른 부드러운 반짝임 (거울 반사·SSR 금지)
	// 직교 카메라를 Q/E로 90도씩 회전해도 어느 각도에서나 자연스럽도록
	// 시점 무관 태양 경사 윤슬(70%)과 시점 보조 하프벡터 윤슬(30%)을 부드럽게 결합
	vec3 L_sun = normalize(sun_direction);
	vec3 H_sun_zenith = normalize(L_sun + vec3(0.0, 1.0, 0.0));
	float sun_slope_align = max(0.0, dot(water_normal, H_sun_zenith));
	float sun_sparkle = pow(sun_slope_align, 26.0) * smoothstep(0.45, 0.78, ripple_combined);

	vec3 V_world = normalize((INV_VIEW_MATRIX * vec4(VIEW, 0.0)).xyz);
	vec3 H_view = normalize(L_sun + V_world);
	float view_soft_glint = pow(max(0.0, dot(water_normal, H_view)), 16.0);

	float highlight_mask = (sun_sparkle * 0.70 + view_soft_glint * 0.30) * (0.35 + 0.65 * center_t) * (1.0 - foam_mask * 0.85);
	vec3 sun_highlight_col = vec3(0.74, 0.83, 0.87);
	base_water = mix(base_water, sun_highlight_col, clamp(highlight_mask * 0.48, 0.0, 0.38));

	// === 5) 선 밖 처리 (play_rect 기준 1칸 3.0m 부드러운 감쇠 + 45m 지점 안개색 100% 수렴 + 담황색 경계선) ===
	vec2 d_play_min = max(play_rect.xy - v_world_pos.xz, vec2(0.0));
	vec2 d_play_max = max(v_world_pos.xz - play_rect.zw, vec2(0.0));
	float play_oob_dist = length(d_play_min + d_play_max);

	vec2 d_play_in_edge = min(v_world_pos.xz - play_rect.xy, play_rect.zw - v_world_pos.xz);
	float play_in_edge_dist = max(0.0, min(d_play_in_edge.x, d_play_in_edge.y));
	float border_dist = play_oob_dist + play_in_edge_dist;

	float oob_tone = smoothstep(0.0, 3.0, play_oob_dist);
	float haze_ratio = smoothstep(2.5, max(3.0, vista_max_distance), play_oob_dist);

	if (play_oob_dist > 0.0) {
		float luma = dot(base_water, vec3(0.299, 0.587, 0.114));
		vec3 grey_slate = vec3(luma) * vec3(0.98, 0.99, 0.96);
		vec3 desaturated_water = mix(base_water, grey_slate, 0.58) * 0.86;
		base_water = mix(base_water, desaturated_water, oob_tone);
	}

	vec3 emission_acc = sun_highlight_col * (highlight_mask * 0.12 * (1.0 - oob_tone * 0.7)) * (1.0 - haze_ratio);

	if (show_border_line) {
		float half_w = border_line_width * 0.5;
		float border_aa = clamp(fwidth(border_dist), 0.004, 0.035);
		float border_mask = 1.0 - smoothstep(half_w - border_aa, half_w + border_aa, border_dist);
		float line_mix = clamp(border_mask * border_line_strength * 0.75, 0.0, 1.0);
		base_water = mix(base_water, border_line_color.rgb, line_mix);
		emission_acc += border_line_color.rgb * border_mask * (0.18 * border_line_strength);
	}

	// Compatibility(gl_compatibility) 100% 안개 수렴 보장 (선 밖 45m에서 haze_color #8d897a와 완전 일치)
	ALBEDO = base_water * (1.0 - haze_ratio);
	ROUGHNESS = mix(0.42, 1.0, haze_ratio);
	METALLIC = 0.04 * (1.0 - haze_ratio);
	SPECULAR = 0.28 * (1.0 - haze_ratio);
	EMISSION = mix(emission_acc, haze_color, haze_ratio);
}
