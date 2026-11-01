// EASTWAR WorldMap3D v3 — terrain: painterly albedo + world-space normal map + hex-tiled close detail
// + REGION-MAP territories (owner lookup texture, O(1) per pixel, no city loop) + coastline/sea + edge mist.
// Territory rule (per pixel, constant cost whatever the region count):
//   own region r0, nearest other region r1 (distance d1), 2nd nearest r2 (d2) come from two textures;
//   owner slot/colour come from owner_lut[r]. Neighbour with a DIFFERENT owner -> thick glowing band,
//   SAME owner -> thin subtle line (region extent stays visible). r0 slot 0 (no owner) -> nothing drawn.
// v2.2: the LUT slot is the owner's BORDER GROUP (realm: Korea / Japan / Wei / ...; see map_config territory.border_group),
//   so regions of one realm get the two-tone inner border (dark core ~40% of the national-border width + light halo)
//   and an alternating fill brightness (LUT row 1 = per-region shade -1/0/+1).
// v2.2: albedo/normal can be 2x2 texture TILES (tex_tiled = 1): seamless (exact bilinear across the seams per mip level).
// Forward+ and Compatibility safe.
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

#include "res://worldmap3d/shaders/worldmap_sea.gdshaderinc"
#include "res://worldmap3d/shaders/worldmap_edge.gdshaderinc"

uniform float anim_time = -1.0;   // >= 0: freeze animation at this time (tests / reproducible captures)
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap_anisotropic, repeat_disable;   // world normal xz in RG (BC5)
// v2.2 tiled albedo/normal (2x2 files terrain_*_tile_<x>_<y>; uniform suffix t<x><y>: x east, y south). Used when tex_tiled = 1, else the single textures above.
uniform int tex_tiled = 0;
uniform vec2 tex_full_px = vec2(13824.0, 9216.0);   // full (untiled) size in texels
uniform sampler2D albedo_t00 : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D albedo_t10 : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D albedo_t01 : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D albedo_t11 : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D normal_t00 : hint_normal, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D normal_t10 : hint_normal, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D normal_t01 : hint_normal, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D normal_t11 : hint_normal, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D coast_tex : filter_linear_mipmap, repeat_disable;  // R coast signed distance (+-coast_sdf_km)
uniform sampler2D depth_tex : filter_linear_mipmap, repeat_disable;  // LA: 16-bit sea depth (hi, lo)
uniform sampler2D mask_tex : filter_linear_mipmap, repeat_disable;   // R fields, G moisture, B rock (forest = rest)
uniform float coast_sdf_km = 8.0;
uniform float normal_strength = 1.0;

// ---- close-zoom detail (hex-tiled: no visible repetition)
uniform sampler2D det_field_a : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D det_field_n : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D det_forest_a : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D det_forest_n : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D det_rock_a : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D det_rock_n : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float detail_tile_km = 4.0;
uniform float detail_near_km = 90.0;
uniform float detail_far_km = 380.0;
uniform float detail_strength : hint_range(0.0, 2.0) = 0.9;
uniform float detail_normal_strength = 0.5;
uniform float hex_rot_strength = 1.0;

// ---- territories
uniform sampler2D region_ids_tex : filter_nearest, repeat_disable;          // R own, G nearest other, B 2nd other (index 0..255)
uniform sampler2D region_dist_tex : filter_linear_mipmap, repeat_disable;   // L(r) d1, A d2 / region_dist_max_km
uniform sampler2D owner_lut : source_color, filter_nearest, repeat_disable; // 256x1: rgb owner colour, a = owner slot/255
uniform float region_dist_max_km = 40.0;
uniform float region_texel_km = 0.557;
uniform float territory_fill : hint_range(0.0, 1.0) = 0.50;     // interior tint (root lerps far->near from the preset)
uniform float territory_band : hint_range(0.0, 1.0) = 0.80;     // tint near a national border
uniform float territory_edge_km = 20.0;                          // band width (root scales with zoom)
uniform float thick_width_km = 1.3;
uniform float thick_min_px = 2.6;
uniform float thick_glow = 1.4;
uniform float thin_width_km = 0.5;
uniform float thin_min_px = 2.2;
uniform float thin_opacity = 0.85;
uniform float territory_on = 1.0;
uniform float inner_width_ratio = 0.4;    // v2.2 same-realm border core width / national border width
uniform float inner_min_px = 1.6;
uniform float inner_dark = 0.42;          // core = owner colour x this (darker shade)
uniform float inner_halo = 0.45;          // halo = owner colour mixed toward white by this
uniform float inner_halo_px = 0.8;        // halo ring width on each side (px, + 0.15 km)
uniform float shade_amount = 0.08;        // fill brightness alternation between same-realm neighbours

// ---- atmosphere
uniform float cloud_shadow = 0.14;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// ---------- hex tiling (Mikkelsen 2022, "Practical Real-Time Hex-Tiling"), 3 taps per texture
vec2 hex_hash(vec2 p) {
	vec2 r = mat2(vec2(127.1, 311.7), vec2(269.5, 183.3)) * p;
	return fract(sin(r) * 43758.5453);
}
mat2 hex_rot(vec2 idx) {
	float ang = abs(idx.x * idx.y) + abs(idx.x + idx.y) + PI;
	ang = mod(ang, 2.0 * PI);
	if (ang > PI) ang -= 2.0 * PI;
	ang *= hex_rot_strength;
	float c = cos(ang), s = sin(ang);
	return mat2(vec2(c, s), vec2(-s, c));
}
void hex_setup(vec2 st, out vec3 w, out vec2 uv1, out vec2 uv2, out vec2 uv3, out mat2 r1, out mat2 r2, out mat2 r3) {
	const mat2 to_skew = mat2(vec2(1.0, -0.57735027), vec2(0.0, 1.15470054));
	const mat2 from_skew = mat2(vec2(1.0, 0.5), vec2(0.0, 0.8660254));
	vec2 sst = st * 3.46410162;                     // 2*sqrt(3)
	vec2 sk = to_skew * sst;
	vec2 base = floor(sk);
	vec3 tmp = vec3(fract(sk), 0.0);
	tmp.z = 1.0 - tmp.x - tmp.y;
	float s = step(0.0, -tmp.z);
	float s2 = 2.0 * s - 1.0;
	w = vec3(-tmp.z * s2, s - tmp.y * s2, s - tmp.x * s2);
	vec2 v1 = base + vec2(s, s);
	vec2 v2 = base + vec2(s, 1.0 - s);
	vec2 v3 = base + vec2(1.0 - s, s);
	r1 = hex_rot(v1); r2 = hex_rot(v2); r3 = hex_rot(v3);
	vec2 c1 = from_skew * v1 / 3.46410162;
	vec2 c2 = from_skew * v2 / 3.46410162;
	vec2 c3 = from_skew * v3 / 3.46410162;
	uv1 = r1 * (st - c1) + c1 + hex_hash(v1);
	uv2 = r2 * (st - c2) + c2 + hex_hash(v2);
	uv3 = r3 * (st - c3) + c3 + hex_hash(v3);
	w = pow(w, vec3(5.0));
	w /= (w.x + w.y + w.z);
}

// LUT row 1 r = 0.5 + 0.5 * shade (shade -1/0/+1); rgb are scaled by it (same-realm neighbours alternate brightness)
vec3 owner_rgb(int r) { return texelFetch(owner_lut, ivec2(r, 0), 0).rgb * (1.0 + shade_amount * (texelFetch(owner_lut, ivec2(r, 1), 0).r * 2.0 - 1.0)); }
vec3 owner_rgb_flat(int r) { return texelFetch(owner_lut, ivec2(r, 0), 0).rgb; }

// ---------- v2.2: seamless 2x2 tiles. Tile (i, j) holds texels [i*W/2, (i+1)*W/2) x [j*H/2, ...). Each tile is sampled with
// clamp-to-edge; within +-half a texel of a seam (texel size of the mip level the footprint selects = rho texels of level 0)
// the two neighbouring tiles are blended linearly — for a bilinear tap that is exactly the cross-seam interpolation
// (2 taps near a seam, 4 at the centre cross, 1 elsewhere). Tile mips equal the full texture's mips up to level 8
// (6912 = 27 * 2^8, BC blocks align), so there is no VRAM overhead (no padding).
vec4 seam_w(vec2 uv, vec2 gx, vec2 gy) {
	vec2 px = uv * tex_full_px;
	float rho = max(max(length(gx * tex_full_px), length(gy * tex_full_px)), 1.0);
	float wx = clamp((px.x - 0.5 * tex_full_px.x) / rho + 0.5, 0.0, 1.0);   // weight of the east column
	float wy = clamp((px.y - 0.5 * tex_full_px.y) / rho + 0.5, 0.0, 1.0);   // weight of the south row
	return vec4(wx, wy, 0.0, 0.0);
}
vec4 tiled_sample(sampler2D t00, sampler2D t10, sampler2D t01, sampler2D t11, vec2 uv, vec2 gx, vec2 gy, vec2 w) {
	vec2 g2x = gx * 2.0, g2y = gy * 2.0;
	vec4 acc = vec4(0.0);
	float a00 = (1.0 - w.x) * (1.0 - w.y), a10 = w.x * (1.0 - w.y), a01 = (1.0 - w.x) * w.y, a11 = w.x * w.y;
	if (a00 > 0.0) acc += a00 * textureGrad(t00, uv * 2.0, g2x, g2y);
	if (a10 > 0.0) acc += a10 * textureGrad(t10, uv * 2.0 - vec2(1.0, 0.0), g2x, g2y);
	if (a01 > 0.0) acc += a01 * textureGrad(t01, uv * 2.0 - vec2(0.0, 1.0), g2x, g2y);
	if (a11 > 0.0) acc += a11 * textureGrad(t11, uv * 2.0 - vec2(1.0, 1.0), g2x, g2y);
	return acc;
}
float owner_slot(int r) { return floor(texelFetch(owner_lut, ivec2(r, 0), 0).a * 255.0 + 0.5); }

// Owner tint (v3.1, back to the v2 look): luminance-preserving RGB mix. The owner colour is rescaled to the
// terrain's own luma (relief + light/shade stay), then mixed in by a SMALL amount in the interior, so the terrain
// keeps its own green/brown hue; most of the colour lives in the border band (fill + band * territory_band).
const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);
vec3 owner_tint(vec3 alb, vec3 oc, float k) {
	float lum = dot(alb, LUMA);
	float lum_oc = max(dot(oc, LUMA), 0.04);
	vec3 tint = oc * clamp(lum / lum_oc, 0.25, 1.2) * 0.88;
	return mix(alb, tint, k);
}

void fragment() {
	float _t = anim_time >= 0.0 ? anim_time : TIME;
	vec2 uv = UV;
	vec2 p = world_pos.xz;
	float coast_km = (texture(coast_tex, uv).r * 2.0 - 1.0) * coast_sdf_km;
	float aa = max(fwidth(coast_km), 0.03);
	float land = smoothstep(-aa, aa, coast_km);
	float px_km = max(length(dFdx(p)), length(dFdy(p)));

	vec3 alb;
	vec2 nn;
	vec2 uvgx = dFdx(uv), uvgy = dFdy(uv);
	if (tex_tiled == 1) {
		vec2 sw = seam_w(uv, uvgx, uvgy).xy;
		alb = tiled_sample(albedo_t00, albedo_t10, albedo_t01, albedo_t11, uv, uvgx, uvgy, sw).rgb;
		nn = tiled_sample(normal_t00, normal_t10, normal_t01, normal_t11, uv, uvgx, uvgy, sw).rg;
	} else {
		alb = textureGrad(albedo_tex, uv, uvgx, uvgy).rgb;
		nn = textureGrad(normal_tex, uv, uvgx, uvgy).rg;
	}
	nn = (nn * 2.0 - 1.0) * normal_strength;
	vec3 nw = normalize(vec3(nn.x, sqrt(max(1.0 - dot(nn, nn), 0.04)), nn.y));

	// ---------------- close-zoom detail (skipped entirely when far)
	float camd = length(world_pos - CAMERA_POSITION_WORLD);
	float dfade = (1.0 - smoothstep(detail_near_km, detail_far_km, camd)) * land;
	if (dfade > 0.001) {
		vec4 mk = texture(mask_tex, uv);
		float steep = smoothstep(0.18, 0.45, 1.0 - nw.y);
		float wr = clamp(mk.b + steep * 0.6, 0.0, 1.0);
		float wf = mk.r * (1.0 - wr);
		float wo = max(1.0 - wr - wf, 0.0);
		vec2 st = p / detail_tile_km;
		vec2 gx = dFdx(st), gy = dFdy(st);
		vec3 w; vec2 u1, u2, u3; mat2 r1, r2, r3;
		hex_setup(st, w, u1, u2, u3, r1, r2, r3);
		vec3 dfa = textureGrad(det_field_a, u1, r1 * gx, r1 * gy).rgb * w.x + textureGrad(det_field_a, u2, r2 * gx, r2 * gy).rgb * w.y + textureGrad(det_field_a, u3, r3 * gx, r3 * gy).rgb * w.z;
		vec3 doa = textureGrad(det_forest_a, u1, r1 * gx, r1 * gy).rgb * w.x + textureGrad(det_forest_a, u2, r2 * gx, r2 * gy).rgb * w.y + textureGrad(det_forest_a, u3, r3 * gx, r3 * gy).rgb * w.z;
		vec3 dra = textureGrad(det_rock_a, u1, r1 * gx, r1 * gy).rgb * w.x + textureGrad(det_rock_a, u2, r2 * gx, r2 * gy).rgb * w.y + textureGrad(det_rock_a, u3, r3 * gx, r3 * gy).rgb * w.z;
		dfa = 0.5 + (dfa - 0.5) * 1.6;
		doa = 0.5 + (doa - 0.5) * 1.15;
		dfa *= mix(vec3(1.0), vec3(0.90, 0.99, 1.04), mk.g);
		vec3 dm = (dfa * wf + doa * wo + dra * wr) * 2.0;
		alb *= mix(vec3(1.0), dm, dfade * detail_strength);
		// detail normals: sample, then rotate back to world (transpose of the UV rotation)
		vec2 n1 = (textureGrad(det_field_n, u1, r1 * gx, r1 * gy).rg * 2.0 - 1.0) * wf + (textureGrad(det_forest_n, u1, r1 * gx, r1 * gy).rg * 2.0 - 1.0) * wo + (textureGrad(det_rock_n, u1, r1 * gx, r1 * gy).rg * 2.0 - 1.0) * wr;
		vec2 n2 = (textureGrad(det_field_n, u2, r2 * gx, r2 * gy).rg * 2.0 - 1.0) * wf + (textureGrad(det_forest_n, u2, r2 * gx, r2 * gy).rg * 2.0 - 1.0) * wo + (textureGrad(det_rock_n, u2, r2 * gx, r2 * gy).rg * 2.0 - 1.0) * wr;
		vec2 n3 = (textureGrad(det_field_n, u3, r3 * gx, r3 * gy).rg * 2.0 - 1.0) * wf + (textureGrad(det_forest_n, u3, r3 * gx, r3 * gy).rg * 2.0 - 1.0) * wo + (textureGrad(det_rock_n, u3, r3 * gx, r3 * gy).rg * 2.0 - 1.0) * wr;
		vec2 dn = transpose(r1) * n1 * w.x + transpose(r2) * n2 * w.y + transpose(r3) * n3 * w.z;
		nw = normalize(nw + vec3(dn.x, 0.0, dn.y) * detail_normal_strength * dfade);
	}

	// ---------------- territories (region map + owner LUT)
	vec3 emis = vec3(0.0);
	ivec2 ts = textureSize(region_ids_tex, 0);
	vec2 tf = uv * vec2(ts) - 0.5;
	ivec2 tc = clamp(ivec2(floor(uv * vec2(ts))), ivec2(0), ts - 1);
	vec4 rid = texelFetch(region_ids_tex, tc, 0);
	int r0 = int(rid.r * 255.0 + 0.5);
	float s0 = owner_slot(r0);
	if (territory_on > 0.5 && s0 > 0.5 && land > 0.0) {
		int ra = int(rid.g * 255.0 + 0.5);
		int rb = int(rid.b * 255.0 + 0.5);
		vec4 dd = texture(region_dist_tex, uv);
		float half_t = region_texel_km * 0.5;
		float da = max(dd.r * dd.r * region_dist_max_km - half_t, 0.0);   // sqrt-encoded distance
		float db = max(dd.a * dd.a * region_dist_max_km - half_t, 0.0);
		float sa = owner_slot(ra), sb = owner_slot(rb);
		float big = 1e4;
		float d_thick = min(abs(sa - s0) > 0.5 ? da : big, abs(sb - s0) > 0.5 ? db : big);
		float d_thin = min(abs(sa - s0) < 0.5 ? da : big, abs(sb - s0) < 0.5 ? db : big);
		// owner colour, softened across the region-texel edge (4 nearest texels, bilinear) -> no stair-steps
		ivec2 b0 = clamp(ivec2(floor(tf)), ivec2(0), ts - 1);
		ivec2 b1 = min(b0 + 1, ts - 1);
		vec2 fr = clamp(tf - floor(tf), 0.0, 1.0);
		vec3 c00 = owner_rgb(int(texelFetch(region_ids_tex, b0, 0).r * 255.0 + 0.5));
		vec3 c10 = owner_rgb(int(texelFetch(region_ids_tex, ivec2(b1.x, b0.y), 0).r * 255.0 + 0.5));
		vec3 c01 = owner_rgb(int(texelFetch(region_ids_tex, ivec2(b0.x, b1.y), 0).r * 255.0 + 0.5));
		vec3 c11 = owner_rgb(int(texelFetch(region_ids_tex, b1, 0).r * 255.0 + 0.5));
		vec3 oc = mix(mix(c00, c10, fr.x), mix(c01, c11, fr.x), fr.y);
		if (dot(c00 + c10 + c01 + c11, vec3(1.0)) < 1e-4 || px_km > 1.2) { oc = owner_rgb(r0); }
		// owner tint: small luminance-preserving mix in the interior, strong only in the national-border band
		float band = pow(1.0 - smoothstep(0.0, territory_edge_km, d_thick), 1.35);
		float fa = min(territory_fill + territory_band * band, 0.92) * land;
		alb = owner_tint(alb, oc, fa);
		// thick national border: each side paints its own owner colour (brightened) + glow; no white rim
		float tw = max(thick_width_km, thick_min_px * px_km);
		float taa = max(px_km, 0.02);
		float thick = (1.0 - smoothstep(tw * 0.5 - taa, tw * 0.5 + taa, d_thick)) * land;
		alb = mix(alb, min(oc * 1.25, vec3(1.0)), thick);
		emis += oc * thick * thick_glow * 0.5 + oc * exp(-d_thick / max(territory_edge_km * 0.25, 0.8)) * land * 0.22 * thick_glow;
		// v2.2 inner border (same realm): two-tone line = dark core (owner colour x inner_dark, ~40% of the national-border
		// width, >= inner_min_px) + a thin light halo on each side, so it reads on dark and on light ground at every zoom.
		vec3 ocf = owner_rgb_flat(r0);
		// thin-line distance: the baked field is "distance to the nearest other-region texel centre", so right at the
		// seam it is still ~0.8-1.15 km. Subtracting only half a texel left the narrow dark core (< 1 km) broken into
		// dashes; subtract ~one texel for the thin line so the core is continuous (thick border keeps v2.1 maths).
		vec4 dd0 = textureLod(region_dist_tex, uv, 0.0);
		float tsub = region_texel_km * 0.95;
		float da0 = max(dd0.r * dd0.r * region_dist_max_km - tsub, 0.0);
		float db0 = max(dd0.a * dd0.a * region_dist_max_km - tsub, 0.0);
		d_thin = min(abs(sa - s0) < 0.5 ? da0 : big, abs(sb - s0) < 0.5 ? db0 : big);
		float cw = max(tw * inner_width_ratio, inner_min_px * px_km);
		float hw = cw * 0.5 + inner_halo_px * px_km + 0.15;
		float tin = taa * 0.7;
		float core = (1.0 - smoothstep(cw * 0.5 - tin, cw * 0.5 + tin, d_thin)) * land * (1.0 - thick);
		float halo = (1.0 - smoothstep(hw - tin, hw + tin, d_thin)) * land * (1.0 - thick) * (1.0 - core);
		alb = mix(alb, mix(ocf, vec3(1.0), inner_halo), halo * thin_opacity);
		alb = mix(alb, ocf * inner_dark, core * thin_opacity);
		emis += ocf * halo * thin_opacity * 0.10;
	}

	// ---------------- cloud shadows (slow drift)
	float cs = smoothstep(0.52, 0.78, texture(warp_tex, p / 520.0 + vec2(_t * 0.0015, _t * 0.0006)).b);
	alb *= 1.0 - cs * cloud_shadow * land;

	// ---------------- sea (same pass, crisp SDF coastline)
	vec3 sea_col; vec3 sea_n;
	sea_surface(p, decode_depth_m(texture(depth_tex, uv)), coast_km, _t, screen_dither(FRAGCOORD.xy), sea_col, sea_n);
	vec3 col = mix(sea_col, alb, land);
	vec3 n = normalize(mix(sea_n, nw, land));
	float rough = mix(0.22, 0.93, land);
	float spec = mix(0.55, 0.10, land);

	// ---------------- map-edge mist (shared with the outer-ring sea plane)
	float mist = edge_mist(p);
	col = mix(col, edge_mist_color(p), mist);
	n = normalize(mix(n, vec3(0.0, 1.0, 0.0), mist));
	rough = mix(rough, 0.45, mist);   // v3.1: mist keeps a soft sea sheen (v2 had a lit open sea out here)
	spec = mix(spec, 0.35, mist);
	emis *= 1.0 - mist;

	ALBEDO = col;
	NORMAL = normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz);
	ROUGHNESS = rough;
	SPECULAR = spec;
	EMISSION = emis;
}
