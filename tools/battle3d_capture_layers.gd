extends RefCounted

## Queue 44b: the two extra layers of tools/battle3d_capture.gd (12호 prep). Static, so the option test can call them.
##
## --guide: two top-down orthographic PNGs drawn from the engine's own data (no camera render) for 록비서 to paint on:
##   guide_board_60m.png - the board 0..60 m; pixel (px, py) covers world x = px / res * 60, z = py / res * 60, the same
##                         mapping as the terrain shader's board_paint_tex UV (v_world_pos.xz / board_paint_world_size)
##   guide_outer.png     - the outer ground: uv = (xz - play_center) / outer_size + 0.5, as the shader's outer_ground_tex
##   Layers, each its own colour (legend in the .json): height shading + 0.5 m contours, cell borders (3 m), forest cells,
##   water surface (between the two river shorelines the water mesh uses), the bridge deck and its two ends, the castle
##   (fort) cells, the four board corners. A guide is a working drawing - nothing of it is baked into the game.
## props.json (in the --paint folder): upright 2D pictures (Y-fixed billboards) standing on the terrain - trees, rocks.
##   Entry: {"image": "tree_a.png", "x": 12.5, "z": 30.0, "height_m": 4.0, "anchor": "bottom", "shadow": true}.
##   No props.json = no node at all (off by default). A bad entry (missing image, outside the outer ground) is skipped
##   with one warning line. Only the capture tool's preview uses them; the battle scene does not.

const GUIDE_RES := 2048
const BOARD_SIZE_M := 60.0
const GUIDE_BOARD_FILE := "guide_board_60m"
const GUIDE_OUTER_FILE := "guide_outer"
const PROPS_FILE := "props.json"
const PROPS_ROOT := "BillboardProps"
const CONTOUR_STEP_M := 0.5
const CELL_M := 3.0
const HEIGHT_BLOCK := 4   # heights are sampled every 4 px (512 x 512 samples) and held across the block
const LEGEND := {
	"height": "grey shade, dark = low, light = high (min..max of the image)",
	"contour": "#5a4a3a every 0.5 m",
	"cell_border": "#ffffff 3 m cell borders (board image only)",
	"forest": "#3c8c3c forest cells (FOREST)",
	"water": "#2f78d0 water surface",
	"bridge": "#b07030 bridge deck, #ff2020 bridge ends",
	"castle": "#a040c0 castle (fort) cells - the board data has no separate gate cell",
	"board_corner": "#ffd000 the four board corners (0,0) (60,0) (0,60) (60,60)",
	"play_area": "#ff8000 play area outline (outer image)",
}
const COLORS := {
	"contour": Color8(0x5a, 0x4a, 0x3a), "cell_border": Color8(0xff, 0xff, 0xff), "forest": Color8(0x3c, 0x8c, 0x3c),
	"water": Color8(0x2f, 0x78, 0xd0), "bridge": Color8(0xb0, 0x70, 0x30), "bridge_end": Color8(0xff, 0x20, 0x20),
	"castle": Color8(0xa0, 0x40, 0xc0), "board_corner": Color8(0xff, 0xd0, 0x00), "play_area": Color8(0xff, 0x80, 0x00),
}


# ---------------------------------------------------------------- coordinates (the shader's UV formulas)
static func board_pixel(world_x: float, world_z: float, res: int = GUIDE_RES) -> Vector2:
	return Vector2(world_x / BOARD_SIZE_M, world_z / BOARD_SIZE_M) * float(res)


static func outer_pixel(world_x: float, world_z: float, outer_size: float, play_center: Vector2, res: int = GUIDE_RES) -> Vector2:
	return ((Vector2(world_x, world_z) - play_center) / maxf(outer_size, 1.0) + Vector2(0.5, 0.5)) * float(res)


static func play_center(field: Node) -> Vector2:
	var rect: Vector4 = field.call("_get_play_rect_world")
	return 0.5 * (Vector2(rect.x, rect.y) + Vector2(rect.z, rect.w))


static func bridge_ends(field: Node) -> Array:
	var ends: Array = []
	for row in ([5.5, 14.5] if bool(field.get("show_far_bridge")) else [5.5]):
		if not bool(field.get("show_bridges")):
			break
		var z: float = row * CELL_M
		var x: float = 28.0 + 1.4 * sin(z * 0.25)   # terrain_board_builder.gd _rebuild_all_wooden_log_bridges
		ends.append([Vector2(x - 3.2, z), Vector2(x + 3.2, z)])   # span 6.4 m along x
	return ends


## {origin_m, size_m, axes, resolution, ...} for a guide image (origin = world xz of the image's top-left corner).
static func guide_info(kind: String, outer_size: float, center: Vector2) -> Dictionary:
	var origin := Vector2.ZERO if kind == "board" else center - Vector2.ONE * outer_size * 0.5
	var size := BOARD_SIZE_M if kind == "board" else outer_size
	return {
		"kind": kind,
		"origin_m": [origin.x, origin.y],
		"size_m": size,
		"axes": "+x world = right (pixel x grows), +z world = down (pixel y grows); pixel (0,0) = origin_m",
		"resolution": [GUIDE_RES, GUIDE_RES],
		"shader_uv": "v_world_pos.xz / board_paint_world_size (60)" if kind == "board" else "(v_world_pos.xz - play_center) / outer_ground_world_size + 0.5",
		"play_center_m": [center.x, center.y],
		"legend": LEGEND,
	}


# ---------------------------------------------------------------- --guide drawing
static func draw_guide(kind: String, board, field: Node, outer_size: float) -> Image:
	var center := play_center(field)
	var info := guide_info(kind, outer_size, center)
	var origin := Vector2(float(info.origin_m[0]), float(info.origin_m[1]))
	var size_m := float(info.size_m)
	var res := GUIDE_RES
	var m_per_px := size_m / float(res)
	var image := Image.create(res, res, false, Image.FORMAT_RGB8)
	# heights on a coarse grid, then shading + contours per pixel
	var blocks := res / HEIGHT_BLOCK
	var heights := PackedFloat32Array()
	heights.resize(blocks * blocks)
	var h_min := INF
	var h_max := -INF
	for by in blocks:
		for bx in blocks:
			var wx := origin.x + (float(bx) + 0.5) * HEIGHT_BLOCK * m_per_px
			var wz := origin.y + (float(by) + 0.5) * HEIGHT_BLOCK * m_per_px
			var h := float(field.call("sample_smooth_height_at_world", wx, wz))
			heights[by * blocks + bx] = h
			h_min = minf(h_min, h)
			h_max = maxf(h_max, h)
	var span := maxf(h_max - h_min, 0.001)
	for py in res:
		var wz := origin.y + (float(py) + 0.5) * m_per_px
		var x_west := float(field.call("_find_river_shore_x", wz, -1.0))
		var x_east := float(field.call("_find_river_shore_x", wz, 1.0))
		var by := mini(py / HEIGHT_BLOCK, blocks - 1)
		for px in res:
			var wx := origin.x + (float(px) + 0.5) * m_per_px
			var bx := mini(px / HEIGHT_BLOCK, blocks - 1)
			var h := heights[by * blocks + bx]
			var shade := 0.25 + 0.6 * (h - h_min) / span
			var color := Color(shade, shade, shade)
			var cell := Vector2i(floori(wx / CELL_M), floori(wz / CELL_M))
			var on_board := wx >= 0.0 and wz >= 0.0 and wx < BOARD_SIZE_M and wz < BOARD_SIZE_M
			if on_board and str(board.terrain(cell)) == "forest":
				color = color.lerp(COLORS.forest, 0.55)
			if on_board and str(board.terrain(cell)) == "fort":
				color = color.lerp(COLORS.castle, 0.7)
			if wx >= x_west and wx <= x_east:
				color = COLORS.water
			# contour: a 0.5 m level between this block and its right / lower neighbour
			if bx + 1 < blocks and by + 1 < blocks and (px % HEIGHT_BLOCK == 0 or py % HEIGHT_BLOCK == 0):
				var here := floori(h / CONTOUR_STEP_M)
				if here != floori(heights[by * blocks + bx + 1] / CONTOUR_STEP_M) or here != floori(heights[(by + 1) * blocks + bx] / CONTOUR_STEP_M):
					color = COLORS.contour
			if kind == "board" and (fposmod(wx, CELL_M) < m_per_px or fposmod(wz, CELL_M) < m_per_px):
				color = COLORS.cell_border
			image.set_pixel(px, py, color)
	var to_px := func(p: Vector2) -> Vector2:
		return board_pixel(p.x, p.y, res) if kind == "board" else outer_pixel(p.x, p.y, outer_size, center, res)
	for ends in bridge_ends(field):
		var a: Vector2 = to_px.call(ends[0])
		var b: Vector2 = to_px.call(ends[1])
		var half_w := maxi(1, int(1.1 / m_per_px))
		for x in range(int(a.x), int(b.x) + 1):
			for dy in range(-half_w, half_w + 1):
				_dot(image, Vector2(x, a.y + dy), 0, COLORS.bridge)
		_dot(image, a, maxi(3, int(0.6 / m_per_px)), COLORS.bridge_end)
		_dot(image, b, maxi(3, int(0.6 / m_per_px)), COLORS.bridge_end)
	if kind == "outer":
		var rect: Vector4 = field.call("_get_play_rect_world")
		_rect_outline(image, to_px.call(Vector2(rect.x, rect.y)), to_px.call(Vector2(rect.z, rect.w)), COLORS.play_area)
		_rect_outline(image, to_px.call(Vector2.ZERO), to_px.call(Vector2.ONE * BOARD_SIZE_M), COLORS.board_corner)
	for corner in [Vector2(0, 0), Vector2(BOARD_SIZE_M, 0), Vector2(0, BOARD_SIZE_M), Vector2(BOARD_SIZE_M, BOARD_SIZE_M)]:
		_dot(image, to_px.call(corner), maxi(4, int(0.8 / m_per_px)), COLORS.board_corner)
	return image


static func _dot(image: Image, at: Vector2, radius: int, color: Color) -> void:
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var x := int(round(at.x)) + dx
			var y := int(round(at.y)) + dy
			if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height() and dx * dx + dy * dy <= radius * radius:
				image.set_pixel(x, y, color)


static func _rect_outline(image: Image, a: Vector2, b: Vector2, color: Color) -> void:
	for x in range(int(a.x), int(b.x) + 1):
		_dot(image, Vector2(x, a.y), 1, color)
		_dot(image, Vector2(x, b.y), 1, color)
	for y in range(int(a.y), int(b.y) + 1):
		_dot(image, Vector2(a.x, y), 1, color)
		_dot(image, Vector2(b.x, y), 1, color)


# ---------------------------------------------------------------- props.json billboards
## Reads <folder>/props.json and stands each valid entry on the terrain under `parent`. Returns {count, warnings}.
## No props.json: nothing is added (no container node either).
static func add_props(parent: Node3D, folder: String, height_at: Callable, outer_size: float, center: Vector2) -> Dictionary:
	var result := {"count": 0, "warnings": [], "root": null}
	var path := folder.path_join(PROPS_FILE)
	if folder.is_empty() or not FileAccess.file_exists(path):
		return result
	var entries: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not entries is Array:
		_warn(result, "props.json is not a list")
		return result
	var root := Node3D.new()
	root.name = PROPS_ROOT
	parent.add_child(root)
	result.root = root
	var half := outer_size * 0.5
	for i in (entries as Array).size():
		var entry: Variant = entries[i]
		if not entry is Dictionary:
			_warn(result, "entry %d is not an object" % i)
			continue
		var image_path := folder.path_join(str(entry.get("image", "")))
		var x := float(entry.get("x", INF))
		var z := float(entry.get("z", INF))
		var height_m := float(entry.get("height_m", 0.0))
		if str(entry.get("image", "")).is_empty() or not FileAccess.file_exists(image_path):
			_warn(result, "entry %d: image not found (%s)" % [i, image_path])
			continue
		if absf(x - center.x) > half or absf(z - center.y) > half or height_m <= 0.0:
			_warn(result, "entry %d: outside the outer ground (%.1f, %.1f) or height %.2f" % [i, x, z, height_m])
			continue
		var image := Image.load_from_file(image_path)
		if image == null or image.is_empty():
			_warn(result, "entry %d: unreadable image %s" % [i, image_path])
			continue
		var texture := ImageTexture.create_from_image(image)
		var base_y := float(height_at.call(x, z))
		var prop := Node3D.new()
		prop.name = "Prop_%d" % i
		prop.position = Vector3(x, base_y, z)
		prop.set_meta("base_y", base_y)
		root.add_child(prop)
		var sprite := Sprite3D.new()
		sprite.name = "Picture"
		sprite.texture = texture
		sprite.pixel_size = height_m / float(image.get_height())
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		sprite.position = Vector3(0.0, height_m * 0.5, 0.0)   # anchor "bottom": the picture's lower edge on the ground
		prop.add_child(sprite)
		if bool(entry.get("shadow", false)):
			var shadow := MeshInstance3D.new()
			shadow.name = "GroundShadow"
			var disc := CylinderMesh.new()
			var radius := maxf(0.3, height_m * 0.22)
			disc.top_radius = radius
			disc.bottom_radius = radius
			disc.height = 0.02
			disc.radial_segments = 24
			shadow.mesh = disc
			var material := StandardMaterial3D.new()
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color = Color(0.0, 0.0, 0.0, 0.32)
			shadow.material_override = material
			shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			shadow.position = Vector3(0.0, 0.03, 0.0)
			prop.add_child(shadow)
		result.count = int(result.count) + 1
	return result


static func _warn(result: Dictionary, message: String) -> void:
	(result.warnings as Array).append(message)
	push_warning("[BATTLE3D_CAPTURE] props: skipped - %s" % message)   # one warning line per skipped entry
