extends SceneTree

# CITY-HUD CH-1: the 90 city-building 2.5D images (assets/worldmap/city_buildings/) and their loader helper
# (scripts/worldmap/ui/worldmap_city_building_assets.gd). Not wired into any screen yet.
# 1. 30 building keys x 3 region styles = 90 paths: all exist and load.
# 2. Every texture has alpha and its size matches city_buildings_manifest.txt (CSV text, size_px column).
# 3. Unknown keys / region styles: empty path, has_texture false, load_texture null.
# 4. region_key -> region style table (bare and "region." prefixed keys, unknown -> "").

const HELPER_PATH := "res://scripts/worldmap/ui/worldmap_city_building_assets.gd"
const MANIFEST_PATH := "res://assets/worldmap/city_buildings/city_buildings_manifest.txt"
const REGION_STYLES := ["kr", "cn", "jp"]

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var helper: Script = load(HELPER_PATH) if ResourceLoader.exists(HELPER_PATH) else null
	_expect(helper != null, "helper script exists")
	if helper == null:
		_finish()
		return
	var sizes := _manifest_sizes()
	_expect(sizes.size() == 90, "manifest has 90 game rows (got %d)" % sizes.size())

	var keys: PackedStringArray = helper.all_building_keys()
	_expect(keys.size() == 30, "30 building keys (got %d)" % keys.size())
	var groups := {"commerce": 0, "mil": 0, "agri": 0, "fish": 0, "life": 0}
	for key in keys:
		var prefix := key.get_slice("_", 0)
		if groups.has(prefix):
			groups[prefix] += 1
	_expect(groups == {"commerce": 8, "mil": 8, "agri": 5, "fish": 4, "life": 5}, "key groups by file prefix %s" % str(groups))

	var loaded := 0
	for key in keys:
		for style in REGION_STYLES:
			var path: String = helper.texture_path(key, style)
			var file_name := "bld_%s_%s.png" % [key, style]
			_expect(path == "res://assets/worldmap/city_buildings/" + file_name, "path %s" % file_name)
			_expect(helper.has_texture(key, style), "has_texture %s" % file_name)
			var texture: Texture2D = helper.load_texture(key, style)
			_expect(texture != null, "load_texture %s" % file_name)
			if texture == null:
				continue
			loaded += 1
			var size_text := "%dx%d" % [texture.get_width(), texture.get_height()]
			_expect(sizes.get(file_name, "") == size_text, "size %s %s (manifest %s)" % [file_name, size_text, sizes.get(file_name, "?")])
			var image := texture.get_image()
			_expect(image != null and image.detect_alpha() != Image.ALPHA_NONE, "alpha %s" % file_name)
	_expect(loaded == 90, "90 textures loaded (got %d)" % loaded)

	for bad in [["no_such_building", "kr"], ["commerce_street_market", "mn"], ["commerce_street_market", ""], ["", "kr"], ["commerce_street_market", "KR"]]:
		var label := "unknown %s/%s" % [bad[0], bad[1]]
		_expect(helper.texture_path(bad[0], bad[1]) == "", label + " -> empty path")
		_expect(not helper.has_texture(bad[0], bad[1]), label + " -> has_texture false")
		_expect(helper.load_texture(bad[0], bad[1]) == null, label + " -> load_texture null")

	var table := {
		"korean_peninsula": "kr", "china_mainland": "cn", "japanese_archipelago": "jp", "northern_steppe": "",
		"region.korean_peninsula": "kr", "region.china_mainland": "cn", "region.japanese_archipelago": "jp",
		"region.northern_steppe": "", "": "", "atlantis": "", "region.": "",
	}
	for region_key in table:
		_expect(helper.region_style_for_region_key(region_key) == table[region_key], "region style %s -> '%s'" % [region_key, table[region_key]])
	var prefix_mismatch: Array[String] = []
	for bare_key in ["korean_peninsula", "china_mainland", "japanese_archipelago", "northern_steppe"]:
		if helper.region_style_for_region_key(bare_key) != helper.region_style_for_region_key("region." + bare_key):
			prefix_mismatch.append(bare_key)
	_expect(prefix_mismatch.is_empty(), "region. prefix and bare key give the same style %s" % str(prefix_mismatch))
	_finish()


func _manifest_sizes() -> Dictionary:
	var sizes := {}
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return sizes
	var header := file.get_csv_line()
	var file_col := header.find("file")
	var kind_col := header.find("kind")
	var size_col := header.find("size_px")
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() <= maxi(file_col, maxi(kind_col, size_col)) or row[kind_col] != "game":
			continue
		sizes[row[file_col].get_file()] = row[size_col]
	return sizes


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[CITY_BUILDING_ASSETS_FAIL] %s" % label)


func _finish() -> void:
	print("[CITY_BUILDING_ASSETS] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
