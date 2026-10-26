shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// === 1. 전장 그리드 규격 (20x20 타일, 타일당 3.0m -> 60.0m x 60.0m) ===
uniform vec2 grid_dimensions = vec2(20.0, 20.0);
uniform float tile_world_size = 3.0;

// === 2. 산악 비주얼 스타일 선택 스위치 (그림 1 · 2 · 3 대응) ===
// 0: 구역별 3종 자동 혼합 (서쪽=스타일1 초록능선+기암, 북동=스타일2 녹음·이끼암산, 남동=스타일3 황토바위산)
// 1: 스타일 1 고정 (그림 1: 푸른 초록 능선 + 황갈색/기암 절벽)
// 2: 스타일 2 고정 (그림 2: 푸른 나무와 이끼·녹음이 뒤덮인 청록 암산)
// 3: 스타일 3 고정 (그림 3: 삼국지 8R풍 중원 황토 바위산 / 흙산)
uniform int mountain_visual_style : hint_range(0, 3) = 0;

// 산이 시커멓게 죽지 않도록 보정하는 앰비언트 리프트 강도
uniform float mountain_brightness_lift : hint_range(0.0, 0.5) = 0.16;

// === 3. 20x20 타일 상태 제어 맵 (CPU에서 ImageTexture로 갱신) ===
// terrain_control_map (RGBA8, 20x20):
//   R: 숲(FOREST) 가중치 (0.0~1.0) -> 02_forest_floor 블렌딩
//   G: 눈(SNOW) 오버레이 강도 (0.0~1.0) -> 06_overlay_snow 블렌딩
//   B: 진흙(MUD) 오버레이 강도 (0.0~1.0) -> 07_overlay_mud 블렌딩
//   A: 소실/검댕(CHARRED) 강도 (0.0~1.0) -> 08_overlay_charred_ash 블렌딩
uniform sampler2D terrain_control_map : filter_linear, repeat_disable;

// tactical_highlight_map (RGBA8, 20x20):
//   R: 이동 가능 영역 (청록색 외곽 발광)
//   G: 공격/화공 사거리 (붉은색 외곽 발광)
//   B: 현재 선택 셀 (황금색 강조)
uniform sampler2D tactical_highlight_map : filter_nearest, repeat_disable;

uniform sampler2D detail_noise_tex : source_color, filter_linear_mipmap, repeat_enable;

// === 4. 심리스 PBR 텍스처 세트 (기본 + 산악 3종 + 오버레이) ===
uniform bool use_pbr_textures = true;

uniform sampler2D tex_01_grass_albedo  : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_01_grass_normal  : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_02_forest_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_02_forest_normal : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_03_dirt_albedo   : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_03_dirt_normal   : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_04_cliff_albedo  : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_04_cliff_normal  : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_04a_mtn_style1_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_04a_mtn_style1_normal : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_04b_mtn_style2_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_04b_mtn_style2_normal : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_04c_mtn_style3_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_04c_mtn_style3_normal : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_05_sand_albedo   : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_05_sand_normal   : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_06_snow_albedo   : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_06_snow_normal   : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_07_mud_albedo    : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_07_mud_normal    : hint_normal, filter_linear_mipmap, repeat_enable;

uniform sampler2D tex_08_char_albedo   : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_08_char_normal   : hint_normal, filter_linear_mipmap, repeat_enable;

uniform float uv_scale_ground = 0.18;
uniform float uv_scale_cliff  = 0.14;

// === 5. 프로시저럴 셰이더 폴백 컬러 팔레트 ===
uniform vec3 col_plain_grass : source_color = vec3(0.32, 0.40, 0.22);
uniform vec3 col_forest_moss : source_color = vec3(0.20, 0.31, 0.16);
uniform vec3 col_ochre_dirt  : source_color = vec3(0.52, 0.40, 0.27);
uniform vec3 col_river_bank  : source_color = vec3(0.45, 0.38, 0.28);
uniform vec3 col_mtn_style1  : source_color = vec3(0.56, 0.45, 0.31);
uniform vec3 col_mtn_style2  : source_color = vec3(0.32, 0.48, 0.28);
uniform vec3 col_mtn_style3  : source_color = vec3(0.64, 0.49, 0.33);
uniform vec3 col_snow_coat   : source_color = vec3(0.88, 0.91, 0.95);
uniform vec3 col_mud_wet     : source_color = vec3(0.24, 0.18, 0.13);
uniform vec3 col_charred_ash : source_color = vec3(0.12, 0.10, 0.10);
uniform vec3 col_vista_fog   : source_color = vec3(0.094, 0.137, 0.180);

// === 6. 경사면/고도 및 전장 경계 파라미터 ===
uniform float water_level_y = -0.12;
uniform float cliff_slope_start = 0.84;
uniform float cliff_slope_full  = 0.56;
uniform float grid_line_opacity = 0.14;
uniform float grid_line_thickness = 0.028;
uniform float vista_max_distance = 24.0;
uniform vec2 hovered_cell = vec2(-1.0, -1.0);

varying vec3 v_world_pos;
varying vec3 v_world_normal;
varying float v_is_skirt;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	v_is_skirt = step(0.5, 1.0 - COLOR.a);
}

vec4 triplanar_sample(sampler2D tex, vec3 world_p, vec3 world_n, float scale) {
	vec3 blend = abs(world_n);
	blend = normalize(max(blend, 0.00001));
	float b = (blend.x + blend.y + blend.z);
	blend /= vec3(b);
	vec4 xaxis = texture(tex, world_p.yz * scale);
	vec4 yaxis = texture(tex, world_p.xz * scale);
	vec4 zaxis = texture(tex, world_p.xy * scale);
	return xaxis * blend.x + yaxis * blend.y + zaxis * blend.z;
}

void fragment() {
	vec2 map_world_size = grid_dimensions * tile_world_size;
	vec2 grid_uv = clamp(v_world_pos.xz / map_world_size, vec2(0.001), vec2(0.999));
	vec2 cell_coord_f = v_world_pos.xz / tile_world_size;
	vec2 cell_id = floor(cell_coord_f);
	vec2 cell_local_uv = fract(cell_coord_f);

	// Out-of-bounds distance (0 inside 60m x 60m playable board, >0 in surrounding vista)
	vec2 d_min = max(vec2(0.0) - v_world_pos.xz, vec2(0.0));
	vec2 d_max = max(v_world_pos.xz - map_world_size, vec2(0.0));
	float oob_dist = length(d_min + d_max);
	float in_bounds = step(oob_dist, 0.001);

	float macro_noise = texture(detail_noise_tex, v_world_pos.xz * 0.032).r;
	float micro_noise = texture(detail_noise_tex, v_world_pos.xz * 0.16).r;

	if (v_is_skirt > 0.5) {
		float strata = sin(v_world_pos.y * 5.0 + macro_noise * 4.0) * 0.03;
		ALBEDO = vec3(0.18, 0.19, 0.17) + strata;
		ROUGHNESS = 0.92;
		METALLIC = 0.0;
	} else {
		vec4 ctrl = texture(terrain_control_map, grid_uv);
		// Outside the playable board, fade out cell control weights and use natural vista foliage/earth
		float oob_fade = 1.0 - smoothstep(0.0, 4.5, oob_dist);
		float forest_w  = ctrl.r * oob_fade;
		float snow_w    = ctrl.g * oob_fade;
		float mud_w     = ctrl.b * oob_fade;
		float charred_w = ctrl.a * oob_fade;

		vec2 g_uv = v_world_pos.xz * uv_scale_ground;
		float up_dot = clamp(v_world_normal.y, 0.0, 1.0);

		vec3 grass_col  = col_plain_grass;
		vec3 forest_col = col_forest_moss;
		vec3 dirt_col   = col_ochre_dirt;
		vec3 sand_col   = col_river_bank;
		vec3 snow_col   = col_snow_coat;
		vec3 mud_col    = col_mud_wet;
		vec3 char_col   = col_charred_ash;

		vec3 mtn1_col = col_mtn_style1;
		vec3 mtn2_col = col_mtn_style2;
		vec3 mtn3_col = col_mtn_style3;

		vec3 nrm_mtn1 = vec3(0.5, 0.5, 1.0);
		vec3 nrm_mtn2 = vec3(0.5, 0.5, 1.0);
		vec3 nrm_mtn3 = vec3(0.5, 0.5, 1.0);

		if (use_pbr_textures) {
			grass_col  = texture(tex_01_grass_albedo, g_uv).rgb;
			forest_col = texture(tex_02_forest_albedo, g_uv).rgb;
			dirt_col   = texture(tex_03_dirt_albedo, g_uv).rgb;
			sand_col   = texture(tex_05_sand_albedo, g_uv).rgb;
			snow_col   = texture(tex_06_snow_albedo, g_uv).rgb;
			mud_col    = texture(tex_07_mud_albedo, g_uv).rgb;
			char_col   = texture(tex_08_char_albedo, g_uv).rgb;

			mtn1_col = triplanar_sample(tex_04a_mtn_style1_albedo, v_world_pos, v_world_normal, uv_scale_cliff).rgb;
			mtn2_col = triplanar_sample(tex_04b_mtn_style2_albedo, v_world_pos, v_world_normal, uv_scale_cliff).rgb;
			mtn3_col = triplanar_sample(tex_04c_mtn_style3_albedo, v_world_pos, v_world_normal, uv_scale_cliff).rgb;

			nrm_mtn1 = triplanar_sample(tex_04a_mtn_style1_normal, v_world_pos, v_world_normal, uv_scale_cliff).rgb;
			nrm_mtn2 = triplanar_sample(tex_04b_mtn_style2_normal, v_world_pos, v_world_normal, uv_scale_cliff).rgb;
			nrm_mtn3 = triplanar_sample(tex_04c_mtn_style3_normal, v_world_pos, v_world_normal, uv_scale_cliff).rgb;
		}

		float ridge_grass_top = smoothstep(0.66, 0.90, up_dot);
		vec3 lush_ridge_grass = grass_col * vec3(1.12, 1.20, 0.88);
		mtn1_col = mix(mtn1_col, lush_ridge_grass, ridge_grass_top * 0.50);
		mtn2_col *= vec3(0.96, 1.12, 0.92);
		mtn3_col *= vec3(1.06, 1.03, 0.95);

		vec3 chosen_mtn_col = mtn1_col;
		vec3 chosen_mtn_nrm = nrm_mtn1;

		if (mountain_visual_style == 1) {
			chosen_mtn_col = mtn1_col;
			chosen_mtn_nrm = nrm_mtn1;
		} else if (mountain_visual_style == 2) {
			chosen_mtn_col = mtn2_col;
			chosen_mtn_nrm = nrm_mtn2;
		} else if (mountain_visual_style == 3) {
			chosen_mtn_col = mtn3_col;
			chosen_mtn_nrm = nrm_mtn3;
		} else {
			float w_east  = smoothstep(0.42, 0.58, grid_uv.x);
			float w_south = smoothstep(0.45, 0.60, grid_uv.y);
			vec3 east_col = mix(mtn2_col, mtn3_col, w_south);
			vec3 east_nrm = mix(nrm_mtn2, nrm_mtn3, w_south);
			chosen_mtn_col = mix(mtn1_col, east_col, w_east);
			chosen_mtn_nrm = mix(nrm_mtn1, east_nrm, w_east);
		}

		// 먼 배경 능선 실루엣(Out-of-Bounds): 개별 나무 메시 대신 푸른 수풀 암산(04b)과 황토 기암(04a) 텍스처로 식생 표현
		float vista_ridge_canopy = smoothstep(4.5, 14.0, oob_dist) * smoothstep(0.9, 2.8, v_world_pos.y);
		chosen_mtn_col = mix(chosen_mtn_col, mix(mtn2_col, forest_col, 0.35), vista_ridge_canopy * 0.55);

		chosen_mtn_col = mix(chosen_mtn_col, chosen_mtn_col * 1.25 + vec3(0.06, 0.05, 0.03), mountain_brightness_lift);

		float dirt_patch = smoothstep(0.38, 0.68, macro_noise * 0.7 + micro_noise * 0.3);
		vec3 ground_col = mix(grass_col, dirt_col, dirt_patch * 0.65);
		ground_col = mix(ground_col, forest_col, smoothstep(0.15, 0.75, forest_w));

		float shore_factor = 1.0 - smoothstep(water_level_y - 0.08, water_level_y + 0.52, v_world_pos.y + (micro_noise - 0.5) * 0.12);
		ground_col = mix(ground_col, sand_col, shore_factor * 0.85);

		float cliff_mask = 1.0 - smoothstep(cliff_slope_full, cliff_slope_start, up_dot + (micro_noise - 0.5) * 0.08);
		float high_alt_rock = smoothstep(1.05, 2.45, v_world_pos.y);
		cliff_mask = clamp(cliff_mask * 0.70 + high_alt_rock * 0.85, 0.0, 1.0);

		vec3 base_albedo = mix(ground_col, chosen_mtn_col, cliff_mask);
		float base_roughness = mix(0.82, 0.86, cliff_mask);

		float mud_mask = smoothstep(0.2, 0.75, mud_w + (micro_noise - 0.5) * 0.25) * (1.0 - cliff_mask * 0.7);
		base_albedo = mix(base_albedo, mud_col, mud_mask);
		base_roughness = mix(base_roughness, 0.24, mud_mask);

		float char_mask = smoothstep(0.2, 0.8, charred_w + (micro_noise - 0.5) * 0.2);
		base_albedo = mix(base_albedo, char_col, char_mask);
		base_roughness = mix(base_roughness, 0.95, char_mask);

		float snow_accumulation = snow_w * smoothstep(0.55, 0.85, up_dot + (micro_noise - 0.5) * 0.2);
		float snow_mask = smoothstep(0.25, 0.65, snow_accumulation);
		base_albedo = mix(base_albedo, snow_col, snow_mask);
		base_roughness = mix(base_roughness, 0.62, snow_mask);

		if (use_pbr_textures) {
			vec3 n_ground = mix(texture(tex_01_grass_normal, g_uv).rgb, texture(tex_03_dirt_normal, g_uv).rgb, dirt_patch * 0.65);
			n_ground = mix(n_ground, texture(tex_02_forest_normal, g_uv).rgb, smoothstep(0.15, 0.75, forest_w));
			n_ground = mix(n_ground, texture(tex_05_sand_normal, g_uv).rgb, shore_factor * 0.85);
			vec3 nrm_blend = mix(n_ground, chosen_mtn_nrm, cliff_mask);
			nrm_blend = mix(nrm_blend, texture(tex_07_mud_normal, g_uv).rgb, mud_mask);
			nrm_blend = mix(nrm_blend, texture(tex_08_char_normal, g_uv).rgb, char_mask);
			nrm_blend = mix(nrm_blend, texture(tex_06_snow_normal, g_uv).rgb, snow_mask);
			NORMAL_MAP = nrm_blend;
			NORMAL_MAP_DEPTH = 1.15;
		}

		// 전장(20x20) 내부 그리드 라인
		vec2 dist_to_edge = min(cell_local_uv, 1.0 - cell_local_uv);
		float min_edge_d = min(dist_to_edge.x, dist_to_edge.y);
		float aa_width = fwidth(min_edge_d) * 1.5;
		float grid_line = (1.0 - smoothstep(grid_line_thickness - aa_width, grid_line_thickness + aa_width, min_edge_d)) * in_bounds;
		float above_water = smoothstep(water_level_y - 0.05, water_level_y + 0.12, v_world_pos.y);
		grid_line *= above_water;

		vec3 grid_col = mix(base_albedo * 0.50, vec3(0.86, 0.82, 0.72), 0.38);
		base_albedo = mix(base_albedo, grid_col, grid_line * grid_line_opacity);

		// 전장(20x20) 경계선 및 바깥 대지 채도 감쇠·원거리 안개 페이드
		float border_band = exp(-pow(oob_dist / 0.18, 2.0)) * step(0.0001, oob_dist);
		base_albedo = mix(base_albedo, vec3(0.76, 0.68, 0.48), border_band * 0.32 * above_water);

		float oob_desat = smoothstep(0.5, 8.0, oob_dist);
		float luma = dot(base_albedo, vec3(0.299, 0.587, 0.114));
		base_albedo = mix(base_albedo, mix(vec3(luma), base_albedo, 0.75) * 0.86, oob_desat);

		float horizon_fog = smoothstep(vista_max_distance * 0.52, vista_max_distance * 0.98, oob_dist);
		base_albedo = mix(base_albedo, col_vista_fog, horizon_fog * 0.78);

		vec4 tac = texture(tactical_highlight_map, (cell_id + vec2(0.5)) / grid_dimensions) * in_bounds;
		float border_glow = 1.0 - smoothstep(0.0, 0.14, min_edge_d);

		vec3 emission_acc = chosen_mtn_col * cliff_mask * mountain_brightness_lift * 0.30 * (1.0 - horizon_fog * 0.8);
		if (tac.r > 0.1) {
			vec3 move_col = vec3(0.20, 0.68, 1.0);
			base_albedo = mix(base_albedo, move_col, (0.12 + 0.45 * border_glow) * tac.r);
			emission_acc += move_col * border_glow * 0.35 * tac.r;
		}
		if (tac.g > 0.1) {
			vec3 atk_col = vec3(1.0, 0.32, 0.15);
			base_albedo = mix(base_albedo, atk_col, (0.15 + 0.50 * border_glow) * tac.g);
			emission_acc += atk_col * border_glow * 0.45 * tac.g;
		}
		bool is_hovered = (in_bounds > 0.5) && (abs(cell_id.x - hovered_cell.x) < 0.1 && abs(cell_id.y - hovered_cell.y) < 0.1);
		if (is_hovered || tac.b > 0.1) {
			float sel_border = 1.0 - smoothstep(0.0, 0.18, min_edge_d);
			vec3 sel_col = vec3(1.0, 0.92, 0.55);
			base_albedo = mix(base_albedo, sel_col, 0.20 + 0.65 * sel_border);
			emission_acc += sel_col * sel_border * 0.65;
		}

		ALBEDO = base_albedo;
		ROUGHNESS = base_roughness;
		SPECULAR = mix(0.30, 0.65, mud_mask);
		EMISSION = emission_acc;
	}
}
