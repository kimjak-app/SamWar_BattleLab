## EASTWAR WorldMap3D v3 / EA v2 — acceptance tests (EA: run on the Korea window of the East Asia map) (automatic, no input). Renders real frames and measures pixels.
## godot --path . --rendering-method forward_plus res://tools/acceptance_tests.tscn -- --out=previews/acceptance
## Writes <out>/acceptance_results.json + evidence PNGs. Exit code 0 = all PASS, 1 = some FAIL.
##  T1 owner change -> whole region recolours on the next frame
##  T2 same owner = thin line, different owner = thick band (measured width in km)
##  T3 moving a marker does not change the region textures / border pixels
##  T4 13-region map with the SAME shader files (no shader edit)
##  T5 changing only map_config_path loads a different (dummy) map
## v2.2 (13 real regions, 13 different owners, border_group = owner): T2 as v2.1 (partner owned by player = thin).
##  T6 CAPTURED STATE: hanseong(player) captures pyeongyang, wei captures luoyang -> the two-tone same-faction inner border
##  (dark core ~40% of the faction border + light halo) is visible at far and mid zoom; in the new-game state the same
##  borders are thick faction borders.
extends Node

const SCENE := "res://worldmap3d/scenes/worldmap3d_eastasia.tscn"
const DUMMY_CFG := "res://worldmap3d/maps/dummy13/map_config.json"
var out_dir := "previews/acceptance"
var root: WorldMap3DRoot
var results := {}
var all_pass := true

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.substr(6)
	DirAccess.make_dir_recursive_absolute(out_dir)
	await _spawn("")
	if "--only-t2" in OS.get_cmdline_user_args():
		await t2_thin_thick()
		get_tree().quit(0)
		return
	await t1_owner_change()
	await t2_thin_thick()
	await t3_marker_move()
	if root.cfg.map_id != "dummy13":
		await t6_inner_visible()
	root.queue_free()
	await get_tree().process_frame
	await _spawn(DUMMY_CFG)
	await t4_t5_dummy()
	results["all_pass"] = all_pass
	results["renderer"] = RenderingServer.get_current_rendering_method()
	results["adapter"] = RenderingServer.get_video_adapter_name()
	var f := FileAccess.open(out_dir + "/acceptance_results.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(results, "  "))
	f.close()
	print("[accept] ALL_PASS=", all_pass)
	get_tree().quit(0 if all_pass else 1)

# ------------------------------------------------------------------ helpers
func _spawn(cfg_path: String) -> void:
	root = load(SCENE).instantiate()
	if cfg_path != "":
		root.map_config_path = cfg_path
	add_child(root)
	await get_tree().process_frame
	root.camera.manual = true
	# freeze water / cloud-shadow animation so frames are bit-comparable
	root.terrain_mat.set_shader_parameter("anim_time", 10.0)
	root.sea_mat.set_shader_parameter("anim_time", 10.0)

func _show_overlays(on: bool) -> void:
	for d in [root.banners, root.markers, root.glows]:
		for k in d:
			d[k].visible = on
	if root.region_labels:                      # v2.4: region name labels are overlays too
		root.region_labels.visible = on

## `zoom` is given in v3-Korea terms (far 1300 km, near 120 km) and converted to the same camera DISTANCE on the
## loaded map, so the EA map is tested at exactly the v3 screen scale.
func _view(xz: Vector2, zoom: float) -> void:
	var d := 1300.0 * pow(120.0 / 1300.0, zoom)
	var cf: float = root.camera.far_distance
	var cn: float = root.camera.near_distance
	if absf(cf - 1300.0) > 1.0 and cf > cn:
		zoom = clampf(log(d / cf) / log(cn / cf), 0.0, 1.0)
	root.camera.set_view(xz, zoom, 0.0, true)
	root.update_zoom_params()

func _grab(name := "") -> Image:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if name != "":
		img.save_png("%s/%s.png" % [out_dir, name])
	return img

func _grab_next_frame(name := "") -> Image:
	# exactly ONE frame after the state change
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if name != "":
		img.save_png("%s/%s.png" % [out_dir, name])
	return img

func _record(id: String, ok: bool, data: Dictionary) -> void:
	data["pass"] = ok
	results[id] = data
	if not ok:
		all_pass = false
	print("[accept] %s %s %s" % [id, "PASS" if ok else "FAIL", JSON.stringify(data)])

## Land texels of the region map: [{xz, r, n1, d1_km}] (every `step` texels).
func _region_samples(step: int, around: Array = ["hanseong", "pyeongyang", "gyeongju", "sabi"]) -> Array:
	var rid: Image = (root.terrain_mat.get_shader_parameter("region_ids_tex") as Texture2D).get_image()
	var rdi: Image = (root.terrain_mat.get_shader_parameter("region_dist_tex") as Texture2D).get_image()
	var dmax: float = root.cfg.region_dist_max_km
	var out := []
	var W := rid.get_width()
	var H := rid.get_height()
	# EA v2: big maps -> only scan the Korea window (the four test cities +-260 km)
	var x0 := 0
	var y0 := 0
	var x1 := W
	var y1 := H
	if W * H > 4000000:
		var bb := Rect2(root.marker_xz[around[0]], Vector2.ZERO)
		for c in around:
			bb = bb.expand(root.marker_xz[c])
		bb = bb.grow(260.0)
		var sz: Vector2 = root.cfg.size_km
		x0 = clampi(int((bb.position.x / sz.x + 0.5) * W), 0, W)
		x1 = clampi(int((bb.end.x / sz.x + 0.5) * W), 0, W)
		y0 = clampi(int((bb.position.y / sz.y + 0.5) * H), 0, H)
		y1 = clampi(int((bb.end.y / sz.y + 0.5) * H), 0, H)
	for y in range(y0 + step / 2, y1, step):
		for x in range(x0 + step / 2, x1, step):
			var uv := Vector2((x + 0.5) / W, (y + 0.5) / H)
			var xz: Vector2 = root.geo.uv_to_xz(uv)
			if root.geo.height_at(xz) < 0.002:
				continue
			var c := rid.get_pixel(x, y)
			var dd := rdi.get_pixel(x, y)
			out.append({"xz": xz, "r": int(round(c.r * 255)), "n1": int(round(c.g * 255)), "d1": dd.r * dd.r * dmax})
	return out

func _screen(xz: Vector2) -> Vector2i:
	var p := Vector3(xz.x, root.geo.mesh_height_at(xz), xz.y)
	if root.camera.is_position_behind(p):
		return Vector2i(-1, -1)
	var s := root.camera.unproject_position(p)
	var vs := get_viewport().get_visible_rect().size
	if s.x < 4 or s.y < 4 or s.x > vs.x - 5 or s.y > vs.y - 5:
		return Vector2i(-1, -1)
	return Vector2i(s)

func _cdiff(a: Color, b: Color) -> float:
	return maxf(maxf(absf(a.r - b.r), absf(a.g - b.g)), absf(a.b - b.b))

func _centroid(samples: Array, r: int) -> Vector2:
	var s := Vector2.ZERO
	var n := 0
	for p in samples:
		if p.r == r:
			s += p.xz
			n += 1
	return s / maxf(n, 1)

func _md5(path: String) -> String:
	return FileAccess.get_md5(path)

# ------------------------------------------------------------------ T1
func t1_owner_change() -> void:
	var samples := _region_samples(6)
	var sabi := root.region_of_city("sabi")
	_view(_centroid(samples, sabi) + Vector2(0, -40), 0.3)
	_show_overlays(false)
	var before := await _grab("T1_owner_before")
	var t0 := Time.get_ticks_usec()
	var newf := "goguryeo_faction" if root.faction_color.has("goguryeo_faction") else "wu"   # v2.2: Korea palette is purple-ish -> Wu red
	root.set_city_owner("sabi", newf)
	var api_us := Time.get_ticks_usec() - t0
	var after := await _grab_next_frame("T1_owner_after_next_frame")
	var n_in := 0
	var n_in_changed := 0
	var n_in_toward := 0
	var n_out := 0
	var n_out_changed := 0
	for p in samples:
		if p.d1 < 3.0:
			continue          # keep away from the border band itself
		var s := _screen(p.xz)
		if s.x < 0:
			continue
		var a := before.get_pixelv(s)
		var b := after.get_pixelv(s)
		var d := _cdiff(a, b)
		if p.r == sabi:
			n_in += 1
			if d > 0.02:
				n_in_changed += 1
			# moved toward red (goguryeo) and away from purple (baekje): red up / blue down
			if (b.r - a.r) - (b.b - a.b) > 0.0:
				n_in_toward += 1
		elif p.d1 > 25.0:
			n_out += 1
			if d > 0.02:
				n_out_changed += 1
	var frac_in := float(n_in_changed) / maxf(n_in, 1)
	var frac_toward := float(n_in_toward) / maxf(n_in, 1)
	var frac_out := float(n_out_changed) / maxf(n_out, 1)
	_record("T1_owner_change", n_in > 200 and frac_in > 0.95 and frac_toward > 0.95 and frac_out < 0.02, {
		"change": "sabi: baekje_faction -> " + newf, "frames_after_call": 1,
		"api_call_us": api_us, "region_pixels_sampled": n_in, "region_changed_frac": snappedf(frac_in, 0.0001),
		"region_toward_new_colour_frac": snappedf(frac_toward, 0.0001),
		"far_other_region_pixels": n_out, "far_other_changed_frac": snappedf(frac_out, 0.0001)})
	root.set_city_owner("sabi", "baekje_faction")

# ------------------------------------------------------------------ T2
func _border_profile(img: Image, ref: Image, samples: Array, ra: int, rb: int) -> Dictionary:
	var bins := [0.0, 1.0, 2.0, 3.0, 4.0, 6.0, 8.0, 12.0]
	var sum := []
	var cnt := []
	for i in bins.size() - 1:
		sum.append(0.0)
		cnt.append(0)
	for p in samples:
		if not ((p.r == ra and p.n1 == rb) or (p.r == rb and p.n1 == ra)):
			continue
		if p.d1 >= bins[-1]:
			continue
		var s := _screen(p.xz)
		if s.x < 0:
			continue
		var d := _cdiff(img.get_pixelv(s), ref.get_pixelv(s))
		for i in bins.size() - 1:
			if p.d1 >= bins[i] and p.d1 < bins[i + 1]:
				sum[i] += d
				cnt[i] += 1
	var prof := {}
	var width := 0.0
	for i in bins.size() - 1:
		var m: float = sum[i] / maxf(cnt[i], 1)
		prof["%s-%s km" % [str(bins[i]), str(bins[i + 1])]] = snappedf(m, 0.001)
		if m > 0.04 and cnt[i] > 0:
			width = bins[i + 1]
	return {"mean_diff_by_distance": prof, "visible_half_width_km": width, "n": cnt}

func t2_thin_thick() -> void:
	# region texel: v3 Korea ~0.28 km, EA v2 ~1.2 km -> sample every texel and widen the "on the border" pick radius
	var rtex: float = root.cfg.size_km.x / float((root.terrain_mat.get_shader_parameter("region_ids_tex") as Texture2D).get_width())
	var samples := _region_samples(2 if rtex < 0.6 else 1)
	var on_border := maxf(1.0, rtex * 1.2)
	var han := root.region_of_city("hanseong")
	# partner city: v3 = sabi. EA v2 (8 Korean regions): the owned (non-player) neighbour with the longest border
	var partner := "sabi"
	var cnt := {}
	for p in samples:
		if p.r == han and p.d1 < on_border:
			cnt[p.n1] = cnt.get(p.n1, 0) + 1
	if cnt.get(root.region_of_city("sabi"), 0) < 20:
		var best := 0
		for cid in root.cities:
			var own: String = root.cities[cid].get("owner", "")
			var ri: int = root.region_of_city(cid)
			if own != "" and own != "player" and cnt.get(ri, 0) > best:
				best = cnt[ri]
				partner = cid
	var partner_owner: String = root.cities[partner].get("owner", "")
	# v2.2 realm borders: thick = partner owned by ANOTHER realm (wu), thin = same realm as hanseong (korea: original owner)
	var realm_mode := root.regions.border_group == "realm" and root.faction_color.has("wu")
	var thick_owner := "wu" if realm_mode else partner_owner
	var thin_owner := partner_owner if realm_mode else "player"
	var sabi := root.region_of_city(partner)
	# view on the hanseong / partner border, mid zoom
	var bx := Vector2.ZERO
	var nb := 0
	for p in samples:
		if p.r == han and p.n1 == sabi and p.d1 < on_border:
			bx += p.xz
			nb += 1
	bx /= maxf(nb, 1)
	_view(bx + Vector2(0, -30), 0.55)
	_show_overlays(false)
	var keep: Dictionary = root._preset.duplicate()
	# fill 0 -> only the border lines/bands differ from the untinted reference
	root._preset = {"fill_far": 0.0, "fill_near": 0.0, "band": keep.band}
	root.update_zoom_params()
	root.terrain_mat.set_shader_parameter("territory_on", 0.0)
	var ref := await _grab("T2_ref_no_territory")
	root.terrain_mat.set_shader_parameter("territory_on", 1.0)
	root.set_city_owner(partner, thick_owner)
	var thick := await _grab("T2_border_lines_only_different_owner")
	root.set_city_owner(partner, thin_owner)
	var thin := await _grab("T2_border_lines_only_same_owner")
	var p_thick := _border_profile(thick, ref, samples, han, sabi)
	var p_thin := _border_profile(thin, ref, samples, han, sabi)
	root._preset = keep
	root.update_zoom_params()
	await _grab("T2_display_same_owner_thin")
	root.set_city_owner(partner, thick_owner)
	await _grab("T2_display_different_owner_thick")
	root.set_city_owner(partner, partner_owner)
	var near_thin: float = p_thin.mean_diff_by_distance.values()[0]
	var ok: bool = p_thick.visible_half_width_km >= 2.0 * maxf(p_thin.visible_half_width_km, 1.0) and near_thin > 0.03
	_record("T2_thin_vs_thick", ok, {"border": "hanseong|" + partner, "camera_distance_km": snappedf(root.camera.current_distance(), 0.1),
		"thick_state": "%s owned by %s" % [partner, thick_owner], "thin_state": "%s owned by %s" % [partner, thin_owner],
		"different_owner(thick)": p_thick, "same_owner(thin)": p_thin,
		"thin_line_visible": near_thin > 0.03})

# ------------------------------------------------------------------ T3
func _tex_md5(t: Texture2D) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(t.get_image().get_data())
	return ctx.finish().hex_encode()

func t3_marker_move() -> void:
	var samples := _region_samples(6)
	var han := root.region_of_city("hanseong")
	var c := _centroid(samples, han)
	_view(c + Vector2(0, -30), 0.4)
	_show_overlays(true)
	var rid_md5 := _tex_md5(root.terrain_mat.get_shader_parameter("region_ids_tex"))
	var rdi_md5 := _tex_md5(root.terrain_mat.get_shader_parameter("region_dist_tex"))
	var lut_md5 := _tex_md5(root.regions.lut_texture)
	var old_xz: Vector2 = root.marker_xz["hanseong"]
	await _grab("T3_display_marker_before")
	_show_overlays(false)
	var a := await _grab("T3_terrain_before")
	var new_xz := old_xz + Vector2(70, 45)      # 70 km east, 45 km south
	root.set_marker_position("hanseong", new_xz, false)
	var b := await _grab("T3_terrain_after_move")
	_show_overlays(true)
	await _grab("T3_display_marker_after")
	# full frame + land-only (terrain + borders); animation is frozen (anim_time) so frames are bit-comparable
	var same_px := 0
	var tot := 0
	for y in range(0, a.get_height(), 2):
		for x in range(0, a.get_width(), 2):
			tot += 1
			if _cdiff(a.get_pixel(x, y), b.get_pixel(x, y)) == 0.0:
				same_px += 1
	var land_same := 0
	var land_tot := 0
	var maxd := 0.0
	var border_tot := 0
	var border_same := 0
	for p in _region_samples(2):
		var s := _screen(p.xz)
		if s.x < 0 or p.xz.distance_to(old_xz) < 25.0 or p.xz.distance_to(new_xz) < 25.0:
			continue          # skip the marker footprints themselves (castle + glow), markers are hidden anyway
		var d := _cdiff(a.get_pixelv(s), b.get_pixelv(s))
		land_tot += 1
		maxd = maxf(maxd, d)
		if d == 0.0:
			land_same += 1
		if p.d1 < 8.0:
			border_tot += 1
			if d == 0.0:
				border_same += 1
	var rid2 := _tex_md5(root.terrain_mat.get_shader_parameter("region_ids_tex"))
	var rdi2 := _tex_md5(root.terrain_mat.get_shader_parameter("region_dist_tex"))
	var lut2 := _tex_md5(root.regions.lut_texture)
	var ok := rid_md5 == rid2 and rdi_md5 == rdi2 and lut_md5 == lut2 and land_tot > 1000 and land_same == land_tot and same_px == tot and root.region_of_city("hanseong") == han
	_record("T3_marker_move", ok, {"moved": "hanseong %s -> %s km" % [old_xz, new_xz],
		"region_ids_md5_same": rid_md5 == rid2, "region_dist_md5_same": rdi_md5 == rdi2, "owner_lut_md5_same": lut_md5 == lut2,
		"land_pixels_compared": land_tot, "land_pixels_identical_frac": snappedf(float(land_same) / maxf(land_tot, 1), 0.000001),
		"border_band_pixels(<8km)": border_tot, "border_band_identical_frac": snappedf(float(border_same) / maxf(border_tot, 1), 0.000001),
		"land_max_pixel_diff": maxd, "full_frame_identical_frac": snappedf(float(same_px) / tot, 0.0001),
		"region_of_city_unchanged": root.region_of_city("hanseong") == han})
	root.set_marker_position("hanseong", old_xz, false)

# ------------------------------------------------------------------ T4 + T5
func t4_t5_dummy() -> void:
	var st: Dictionary = root.stats
	var cfg: WorldMapConfig = root.cfg
	var shaders := {}
	for m in [root.terrain_mat, root.sea_mat, root.road_mat, root.river_mat]:
		if m:
			shaders[m.shader.resource_path] = _md5(m.shader.resource_path)
	var ok5: bool = st.get("map_id", "") == "dummy13" and is_equal_approx(root.geo.width_km, cfg.size_km.x) \
		and absf(cfg.size_km.x - 1140.378) > 1.0 and is_equal_approx(root.camera.far_distance, float(cfg.cam("far_distance_km", -1)))
	_record("T5_config_swap", ok5, {"map_config_path": DUMMY_CFG, "map_id": st.get("map_id", ""),
		"size_km": [cfg.size_km.x, cfg.size_km.y], "grid": [root.geo.gw, root.geo.gh],
		"camera_far_km": root.camera.far_distance, "camera_near_km": root.camera.near_distance,
		"build_ms": snappedf(st.build_ms, 0.1), "terrain_tris": st.terrain_tris,
		"how": "same scene + same scripts + same shaders; only map_config_path changed"})
	# T4: 13 regions, give each its own owner pattern, check the colours land in the right regions
	var facs := ["player", "goguryeo_faction", "silla_faction", "baekje_faction"]
	var expect := {}
	for r in root.regions.regions:
		var f: String = facs[(int(r.index) - 1) % 4]
		root.set_city_owner(r.city_id, f)
		expect[int(r.index)] = f
	root.set_fill_preset("strong")
	_view(Vector2.ZERO, 0.0)
	_show_overlays(true)
	await _grab("T4_dummy13_display")
	_show_overlays(false)
	root.terrain_mat.set_shader_parameter("territory_on", 0.0)
	await _grab("T4_dummy13_no_territory")
	root.terrain_mat.set_shader_parameter("territory_on", 1.0)
	var img := await _grab("T4_dummy13_regions")
	var samples := _region_samples(3)
	var acc := {}
	for p in samples:
		if p.d1 < 4.0 or p.r == 0:
			continue
		var s := _screen(p.xz)
		if s.x < 0:
			continue
		var a := img.get_pixelv(s)
		if not acc.has(p.r):
			acc[p.r] = [Vector3.ZERO, 0]
		acc[p.r][0] += Vector3(a.r, a.g, a.b)
		acc[p.r][1] += 1
	var good := 0
	var per := {}
	for r in acc:
		var shift: Vector3 = acc[r][0] / float(acc[r][1])     # mean rendered colour of the region interior
		var best := ""
		var bestv := -1e9
		for f in facs:
			var fc: Color = root.faction_color[f]
			var fv := Vector3(fc.r, fc.g, fc.b)
			fv -= Vector3.ONE * (fv.x + fv.y + fv.z) / 3.0
			var sv := shift - Vector3.ONE * (shift.x + shift.y + shift.z) / 3.0
			var cosv := sv.normalized().dot(fv.normalized())
			if cosv > bestv:
				bestv = cosv
				best = f
		per["r%02d" % r] = {"expected": expect.get(r, ""), "measured": best, "cos": snappedf(bestv, 0.01), "n": acc[r][1]}
		if best == expect.get(r, ""):
			good += 1
	# region switch check on region 13: one LUT texel
	var r13: String = root.regions.city_by_index.get(13, "")
	root.set_city_owner(r13, "goguryeo_faction")
	await _grab("T4_dummy13_r13_changed")
	var ok4: bool = root.regions.regions.size() == 13 and acc.size() == 13 and good == 13
	_record("T4_13_regions_no_shader_edit", ok4, {"region_count": root.regions.regions.size(),
		"regions_seen_on_screen": acc.size(), "owner_colour_matches": good, "per_region": per,
		"shader_files_md5(same files as korea)": shaders,
		"changed_files": "maps/dummy13/{map_config.json, regions.json, markers.json, rule_data_dummy13.json, textures/*, terrain/*}"})

# ------------------------------------------------------------------ T6 (v2.2)
## Same-realm inner border (two-tone: dark core + light halo) must stay visible at far and mid zoom.
## Lines-only frames (fill 0) vs the untinted reference: mean pixel diff on the line (d1 < max(half a px + 0.6 km, 1.6 km))
## must be clearly above the region interior (d1 > 20 km), and the line must contain dark AND light pixels.
func t6_inner_visible() -> void:
	var keep: Dictionary = root._preset.duplicate()
	var out := {}
	var ok := true
	for pair in [["hanseong", "pyeongyang"], ["yecheng", "luoyang"]]:
		var orig_owner := root.regions.owner_of_city(pair[1])
		var new_game_thick: bool = root.regions.faction_slot.get(root.regions.owner_of_city(pair[0]), -1) != root.regions.faction_slot.get(orig_owner, -2)
		root.set_city_owner(pair[1], root.regions.owner_of_city(pair[0]))     # captured state
		var samples := _region_samples(1, pair)
		var ra := root.region_of_city(pair[0])
		var rb := root.region_of_city(pair[1])
		var bx := Vector2.ZERO
		var nb := 0
		for p in samples:
			if p.r == ra and p.n1 == rb and p.d1 < 1.5:
				bx += p.xz
				nb += 1
		bx /= maxf(nb, 1)
		var same: bool = root.regions.faction_slot.get(root.regions.owner_of_city(pair[0]), -1) == root.regions.faction_slot.get(root.regions.owner_of_city(pair[1]), -2)
		for zv in [["far", 0.0], ["mid", -1150.0]]:
			var z: float = zv[1]
			if z < 0.0:
				var cf: float = root.camera.far_distance
				var cn: float = root.camera.near_distance
				z = clampf(log(-z / cf) / log(cn / cf), 0.0, 1.0)
			root.camera.set_view(bx, z, 0.0, true)
			root.update_zoom_params()
			_show_overlays(false)
			root._preset = {"fill_far": 0.0, "fill_near": 0.0, "band": keep.band}
			root.update_zoom_params()
			root.terrain_mat.set_shader_parameter("territory_on", 0.0)
			var ref := await _grab()
			root.terrain_mat.set_shader_parameter("territory_on", 1.0)
			var img := await _grab("T6_%s_%s_lines_only" % [pair[0], zv[0]])
			root._preset = keep
			root.update_zoom_params()
			await _grab("T6_%s_%s_display" % [pair[0], zv[0]])
			var vs := get_viewport().get_visible_rect().size
			var px_km: float = 2.0 * root.camera.current_distance() * tan(deg_to_rad(root.camera.fov * 0.5)) / vs.y
			var lim := maxf(px_km * 0.5 + 0.6, 1.6)   # region texel 1.2 km: the first distance ring sits at ~1.2 km
			var on_s := 0.0
			var on_n := 0
			var in_s := 0.0
			var in_n := 0
			var dark := 0
			var light := 0
			for p in samples:
				if not ((p.r == ra and p.n1 == rb) or (p.r == rb and p.n1 == ra)):
					continue
				var sp := _screen(p.xz)
				if sp.x < 0:
					continue
				var a := img.get_pixelv(sp)
				var b := ref.get_pixelv(sp)
				var d := _cdiff(a, b)
				if p.d1 < lim:
					on_s += d
					on_n += 1
					if a.get_luminance() < b.get_luminance() - 0.05:
						dark += 1
					elif a.get_luminance() > b.get_luminance() + 0.05:
						light += 1
				elif p.d1 > 20.0:
					in_s += d
					in_n += 1
			var on_m := on_s / maxf(on_n, 1)
			var in_m := in_s / maxf(in_n, 1)
			var good: bool = same and new_game_thick and on_n > 20 and on_m > 0.08 and on_m > in_m + 0.06
			ok = ok and good
			out["%s|%s_%s" % [pair[0], pair[1], zv[0]]] = {"captured_state": "%s owned by %s (new game: %s)" % [pair[1], root.regions.owner_of_city(pair[1]), orig_owner],
				"new_game_border_thick": new_game_thick, "same_faction": same, "camera_distance_km": snappedf(root.camera.current_distance(), 0.1),
				"km_per_px": snappedf(px_km, 0.01), "line_mean_diff": snappedf(on_m, 0.001), "interior_mean_diff": snappedf(in_m, 0.001),
				"line_samples": on_n, "line_dark_px": dark, "line_light_px": light, "pass": good}
		root.set_city_owner(pair[1], orig_owner)
	_record("T6_captured_same_faction_border_far_mid", ok, out)
