extends SceneTree
# HUDFIX: the day/night turn button must show no background between the sky circle and the metal frame. The button
# (WorldMapTurnCompass, day/night layers) is put over a strong magenta background at several sky progress values
# (section starts and the middle of each fade) and every pixel inside the frame's hole, plus a band under the frame
# ring, is checked: the background may not show through by even one 8-bit step.
# Headless has no renderer, so the check composites the layers itself the way a TextureRect draws them (linear filter,
# stretch scale, no mipmaps): background weight = (1 - a_SkyA)(1 - a_SkyB)(1 - a_Frame)(1 - a_Center) per 240x240 pixel
# centre. With a real renderer (windowed run) the same pixels are also rendered over magenta and over green and any
# pixel whose two renders differ counts as a seam pixel.
# The frame hole is measured here independently of the compass code (alpha < 0.5 area joined to the centre of
# turn_btn_frame.png, bounding box), so a wrong measurement in the compass cannot pass by itself.
const COMPASS_SCRIPT := "res://scripts/worldmap/worldmap_turn_compass.gd"
const FRAME_PATH := "res://assets/ui/turn_button/turn_btn_frame.png"
const COMPASS_SIZE := 240.0
const PROGRESS_VALUES := [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 0.99]
const RING_BAND := 10.0     # also check this many px outside the hole (under the frame ring)
const VISIBLE_STEP := 1.0 / 255.0

var checks := 0
var failures: Array = []
var _images := {}   # Texture2D -> Image (decompressed)


func _initialize() -> void:
	run.call_deferred()


func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		push_error("[TURN_SEAM_FAIL] " + label)


func run() -> void:
	root.size = Vector2i(1920, 1080)
	var hole := measure_hole()
	print("[TURN_SEAM] frame hole @240: center=%s radius=(%.3f, %.3f) bbox512=%s" % [str(hole.center), hole.radius.x, hole.radius.y, str(hole.bbox)])
	var layer := CanvasLayer.new()
	root.add_child(layer)
	var compass: Control = load(COMPASS_SCRIPT).new()
	compass.name = "TurnEndCompass"
	compass.set("use_daynight_turn_button", true)
	layer.add_child(compass)
	for i in 4: await process_frame
	var sky_a: TextureRect = compass.get_node("SkyA")
	print("[TURN_SEAM] SkyA rect=%s size=%s" % [str(sky_a.position), str(sky_a.size)])
	var hole_r := maxf(hole.radius.x, hole.radius.y)
	var total := 0
	for progress in PROGRESS_VALUES:
		compass.call("_apply_sky_progress", progress)
		var result := composite_seam(compass, hole.center, hole_r + RING_BAND)
		total += int(result.count)
		print("[TURN_SEAM] progress=%.3f seam_pixels=%d max_bg=%.4f checked=%d first=%s" % [progress, result.count, result.max_bg, result.checked, str(result.first)])
		expect(int(result.checked) > 15000, "progress %.3f: the hole area was checked (%d px)" % [progress, result.checked])
		expect(int(result.count) == 0, "progress %.3f: no background inside the frame hole (%d px, max weight %.4f, first %s)" % [progress, result.count, result.max_bg, str(result.first)])
	if DisplayServer.get_name() != "headless":
		await check_rendered(compass, hole.center, hole_r + RING_BAND)
	else:
		print("[TURN_SEAM] headless: rendered check skipped, composited check only")
	print("[TURN_SEAM] total_seam_pixels=%d" % total)
	print("[TURN_SEAM] checks=%d failures=%s" % [checks, str(failures)])
	quit(0 if failures.is_empty() and checks > 0 else 1)


## The frame hole, measured from the PNG: alpha < 0.5 area 4-connected to the centre; bounding box on the 240 canvas.
func measure_hole() -> Dictionary:
	var img := image_of(load(FRAME_PATH))
	var w := img.get_width()
	var h := img.get_height()
	var seen := PackedByteArray()
	seen.resize(w * h)
	var stack: Array[Vector2i] = [Vector2i(w / 2, h / 2)]
	var lo := Vector2i(w, h)
	var hi := Vector2i(-1, -1)
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h or seen[p.y * w + p.x] != 0:
			continue
		seen[p.y * w + p.x] = 1
		if img.get_pixel(p.x, p.y).a >= 0.5:
			continue
		lo = Vector2i(mini(lo.x, p.x), mini(lo.y, p.y))
		hi = Vector2i(maxi(hi.x, p.x), maxi(hi.y, p.y))
		stack.append(p + Vector2i.RIGHT)
		stack.append(p + Vector2i.LEFT)
		stack.append(p + Vector2i.DOWN)
		stack.append(p + Vector2i.UP)
	var k := COMPASS_SIZE / float(w)
	return {"center": (Vector2(lo) + Vector2(hi) + Vector2.ONE) * 0.5 * k, "radius": Vector2(hi - lo + Vector2i.ONE) * 0.5 * k, "bbox": [lo, hi]}


## Background weight per pixel centre inside radius `limit` of `center`, from the compass's own layer nodes.
func composite_seam(compass: Control, center: Vector2, limit: float) -> Dictionary:
	var layers: Array = []
	for n in ["SkyA", "SkyB", "Frame", "Center"]:
		var node := compass.get_node(n) as TextureRect
		if node.visible and node.texture != null:
			layers.append([node, image_of(node.texture)])
	var count := 0
	var checked := 0
	var max_bg := 0.0
	var first = null
	for y in int(COMPASS_SIZE):
		for x in int(COMPASS_SIZE):
			var p := Vector2(x + 0.5, y + 0.5)
			if p.distance_to(center) > limit:
				continue
			checked += 1
			var bg := 1.0
			for entry in layers:
				var node: TextureRect = entry[0]
				bg *= 1.0 - sample_alpha(entry[1], (p - node.position) / node.size) * node.modulate.a * node.self_modulate.a
			if bg >= VISIBLE_STEP:
				count += 1
				if first == null:
					first = Vector2i(x, y)
			max_bg = maxf(max_bg, bg)
	return {"count": count, "checked": checked, "max_bg": max_bg, "first": first}


## Linear-filtered alpha at uv (0..1 over the rect); 0 outside the rect, clamped at the texture edge inside it.
func sample_alpha(img: Image, uv: Vector2) -> float:
	if uv.x < 0.0 or uv.y < 0.0 or uv.x > 1.0 or uv.y > 1.0:
		return 0.0
	var w := img.get_width()
	var h := img.get_height()
	var t := Vector2(uv.x * w - 0.5, uv.y * h - 0.5)
	var x0 := floori(t.x)
	var y0 := floori(t.y)
	var fx := t.x - x0
	var fy := t.y - y0
	var xa := clampi(x0, 0, w - 1)
	var xb := clampi(x0 + 1, 0, w - 1)
	var ya := clampi(y0, 0, h - 1)
	var yb := clampi(y0 + 1, 0, h - 1)
	var top := lerpf(img.get_pixel(xa, ya).a, img.get_pixel(xb, ya).a, fx)
	var bottom := lerpf(img.get_pixel(xa, yb).a, img.get_pixel(xb, yb).a, fx)
	return lerpf(top, bottom, fy)


func image_of(texture: Texture2D) -> Image:
	if _images.has(texture):
		return _images[texture]
	var img := texture.get_image()
	if img.is_compressed():
		img.decompress()
	_images[texture] = img
	return img


## Windowed runs only: render the compass in a SubViewport over magenta and over green; differing pixels show background.
func check_rendered(compass: Control, center: Vector2, limit: float) -> void:
	var holder := SubViewport.new()
	holder.size = Vector2i(int(COMPASS_SIZE), int(COMPASS_SIZE))
	holder.transparent_bg = false
	holder.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var bg := ColorRect.new()
	bg.size = Vector2(COMPASS_SIZE, COMPASS_SIZE)
	holder.add_child(bg)
	root.add_child(holder)
	compass.get_parent().remove_child(compass)
	holder.add_child(compass)
	compass.set_process(false)
	compass.position = Vector2.ZERO
	for progress in PROGRESS_VALUES:
		compass.call("_apply_sky_progress", progress)
		var shots := []
		for color in [Color(1, 0, 1), Color(0, 1, 0)]:
			bg.color = color
			for i in 3: await process_frame
			await RenderingServer.frame_post_draw
			shots.append(holder.get_texture().get_image())
		var count := 0
		for y in int(COMPASS_SIZE):
			for x in int(COMPASS_SIZE):
				if Vector2(x + 0.5, y + 0.5).distance_to(center) > limit:
					continue
				var a: Color = shots[0].get_pixel(x, y)
				var b: Color = shots[1].get_pixel(x, y)
				if maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b))) >= 1.5 / 255.0:
					count += 1
		print("[TURN_SEAM] rendered progress=%.3f seam_pixels=%d" % [progress, count])
		expect(count == 0, "rendered progress %.3f: no background inside the frame hole (%d px)" % [progress, count])
