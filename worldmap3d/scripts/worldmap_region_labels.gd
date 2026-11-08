## EASTWAR WorldMap3D v2.4 — region name labels (painterly serif map lettering).
## NO class_name (loaded by path from worldmap3d_root.gd: preload("res://worldmap3d/scripts/worldmap_region_labels.gd")).
## Data = the EXISTING region lookup: WorldMapRegions.regions (regions.json) -> per region "label_ko" (text, falls back to
## "name_ko") and "label_xz_km" (anchor; if missing it is computed from region_ids.png = mean of that region's texels).
## Style = map_config "region_labels" { enabled, font_size, color, outline_*, screen_scale, fade_*, scale_*, tilt_deg, ... }.
## Each label lies on the map tilted toward the camera (style.tilt_deg) and turns with the camera yaw, so it stays readable
## while rotating. Screen size is roughly constant (height = style.screen_scale × camera distance, clamped); "label_scale"
## shrinks small regions only at far zoom (scale_from_km -> scale_full_km); labels fade out close in (fade_near_km ->
## fade_full_km) where the city banners take over. Labels ignore depth (mountains never cut them) and draw below banners.
## Labels are geographic names: owner changes (F3 capture) do not change them.
extends Node3D

var labels := {}                  # region_id -> Label3D
var style := {}
var _scale := {}                  # region_id -> float (far-zoom size factor)
var _base_alpha := 1.0

## regions: WorldMapRegions.regions array; region_ids: the region index image (may be null if every label has label_xz_km);
## xz_of_uv: Callable(Vector2 uv) -> Vector2 xz km; height_at: Callable(Vector2 xz) -> float y.
func build(regions: Array, st: Dictionary, font: Font, region_ids: Image, xz_of_uv: Callable, height_at: Callable) -> int:
	style = st
	var fv := FontVariation.new()
	fv.base_font = font
	fv.spacing_glyph = int(style.get("letter_spacing_px", 28))
	var size := int(style.get("font_size", 128))
	var col := Color(String(style.get("color", "#F3E6C4")))
	_base_alpha = col.a
	var ocol := Color(String(style.get("outline_color", "#2A1C10E0")))
	var auto := {}
	for r in regions:
		if not r.has("label_xz_km"):
			auto = _centroids(region_ids, xz_of_uv)
			break
	for r in regions:
		var rid := String(r.region_id)
		var text := String(r.get("label_ko", r.get("name_ko", rid)))
		var xz: Vector2
		if r.has("label_xz_km"):
			xz = Vector2(float(r.label_xz_km[0]), float(r.label_xz_km[1]))
		elif auto.has(int(r.index)):
			xz = auto[int(r.index)]
		else:
			continue
		var l := Label3D.new()
		l.name = "RegionLabel_" + rid
		l.text = text
		l.font = fv
		l.font_size = size
		l.pixel_size = 1.0 / float(size)          # 1 unit = one text line; scaled per frame
		l.no_depth_test = true
		l.shaded = false
		l.double_sided = true
		l.render_priority = int(style.get("render_priority", -2))
		l.outline_render_priority = l.render_priority - 1
		l.modulate = col
		l.outline_modulate = ocol
		l.outline_size = int(style.get("outline_px", 22))
		l.alpha_cut = Label3D.ALPHA_CUT_DISABLED
		l.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		l.position = Vector3(xz.x, float(height_at.call(xz)) + float(style.get("lift_km", 2.0)), xz.y)
		add_child(l)
		labels[rid] = l
		_scale[rid] = float(r.get("label_scale", 1.0))
	return labels.size()

## Fallback anchor: mean position of each region index on a coarse grid of region_ids.png (red channel = index).
static func _centroids(img: Image, xz_of_uv: Callable) -> Dictionary:
	var out := {}
	if img == null:
		return out
	var sum := {}
	var cnt := {}
	var w := img.get_width()
	var h := img.get_height()
	# 의도된 버림: 샘플 간격(정수 픽셀)
	@warning_ignore("integer_division")
	var step := maxi(1, w / 384)
	for y in range(0, h, step):
		for x in range(0, w, step):
			var i := int(round(img.get_pixel(x, y).r * 255.0))
			if i == 0:
				continue
			sum[i] = sum.get(i, Vector2.ZERO) + Vector2((x + 0.5) / w, (y + 0.5) / h)
			cnt[i] = cnt.get(i, 0) + 1
	for i in sum:
		out[i] = xz_of_uv.call(sum[i] / float(cnt[i]))
	return out

## Called every frame by the root with the camera.
func update_for_camera(cam: Camera3D) -> void:
	var cb := cam.global_transform.basis
	var fwd := Vector3(-cb.z.x, 0.0, -cb.z.z)
	if fwd.length_squared() < 1e-6:
		fwd = Vector3(cb.y.x, 0.0, cb.y.z)        # straight top-down: screen-up direction
	fwd = fwd.normalized()
	var right := fwd.cross(Vector3.UP).normalized()
	var a := deg_to_rad(float(style.get("tilt_deg", 35.0)))
	var up_dir := (fwd * cos(a) + Vector3.UP * sin(a)).normalized()
	var label_basis := Basis(right, up_dir, right.cross(up_dir))
	var k := float(style.get("screen_scale", 0.03))
	var hmin := float(style.get("min_km", 8.0))
	var hmax := float(style.get("max_km", 160.0))
	var f0 := float(style.get("fade_near_km", 260.0))
	var f1 := float(style.get("fade_full_km", 520.0))
	var sf0 := float(style.get("scale_from_km", 1800.0))
	var sf1 := float(style.get("scale_full_km", 3800.0))
	for rid in labels:
		var l: Label3D = labels[rid]
		var dist := cam.global_position.distance_to(l.global_position)
		var sc := lerpf(1.0, float(_scale[rid]), smoothstep(sf0, sf1, dist))
		var hh := clampf(dist * k, hmin, hmax) * sc
		l.global_transform = Transform3D(label_basis.scaled(Vector3(hh, hh, hh)), l.global_position)
		var al := smoothstep(f0, f1, dist) * _base_alpha
		l.modulate.a = al
		l.outline_modulate.a = al * 0.88
		l.visible = al > 0.01
