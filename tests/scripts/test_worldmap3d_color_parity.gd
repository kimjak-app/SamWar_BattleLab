extends SceneTree

# T-WM3D-05: the 2D faction colors follow the 3D palette (the color source of truth, 김작 11-01). Compares
# worldmap_city_marker.gd OWNER_COLORS, the CityDot colors written in WorldMap.tscn, map_config.json
# territory.faction_palette and rule_data_eastasia.json (factions[].color, cities[].owner).

const MARKER_SCRIPT_PATH := "res://scripts/worldmap_city_marker.gd"
const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const MAP_CONFIG_PATH := "res://worldmap3d/maps/eastasia/map_config.json"
const RULE_DATA_PATH := "res://worldmap3d/maps/eastasia/rule_data_eastasia.json"
const TOLERANCE := 1.0 / 255.0
# CityMarker_* in WorldMap.tscn -> starting owner faction (the 2D new-game owners)
const MARKER_OWNERS := {
	"Luoyang": "chu", "Yecheng": "wei", "Chengdu": "shu", "Jianye": "wu", "Karakorum": "mongol_faction",
	"Pyeongyang": "goguryeo", "Hanseong": "player", "Gyeongju": "silla", "Sabi": "baekje_faction",
	"Kyoto": "oda", "Osaka": "toyotomi", "Kyushu": "kyushu_faction", "Edo": "tokugawa",
}

var _checks := 0
var _failures: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var owner_colors: Dictionary = load(MARKER_SCRIPT_PATH).OWNER_COLORS
	var palette: Dictionary = _read_json(MAP_CONFIG_PATH).get("territory", {}).get("faction_palette", {})
	var rule: Dictionary = _read_json(RULE_DATA_PATH)

	# 1. the same 13 faction keys
	_expect(palette.size() == 13 and _sorted(owner_colors.keys()) == _sorted(palette.keys()),
		"OWNER_COLORS keys == faction_palette keys (13) %s / %s" % [_sorted(owner_colors.keys()), _sorted(palette.keys())])

	# 2. OWNER_COLORS == faction_palette per key
	for k in _sorted(palette.keys()):
		var c2d: Color = owner_colors.get(k, Color(-1, -1, -1))
		_expect(_same(c2d, Color(str(palette[k]))), "OWNER_COLORS[%s] %s == palette %s" % [k, _hex(c2d), palette[k]])

	# 3. rule_data factions[] id/color == faction_palette
	var rule_colors := {}
	for f in rule.get("factions", []):
		rule_colors[str(f.get("id", ""))] = str(f.get("color", ""))
	_expect(_sorted(rule_colors.keys()) == _sorted(palette.keys()), "rule_data factions ids == palette keys %s" % [_sorted(rule_colors.keys())])
	for k in _sorted(palette.keys()):
		_expect(rule_colors.has(k) and Color(rule_colors[k]) == Color(str(palette[k])), "rule_data faction %s color %s == palette %s" % [k, rule_colors.get(k, "?"), palette[k]])

	# 4. WorldMap.tscn CityDot colors == palette of the marker's starting owner
	var dots := _scene_dot_colors(FileAccess.get_file_as_string(WORLDMAP_SCENE_PATH))
	_expect(_sorted(dots.keys()) == _sorted(MARKER_OWNERS.keys()), "WorldMap.tscn: all 13 CityMarker_*/CityDot found %s" % [_sorted(dots.keys())])
	for m in _sorted(MARKER_OWNERS.keys()):
		var f: String = MARKER_OWNERS[m]
		var dot: Color = dots.get(m, Color(-1, -1, -1))
		_expect(_same(dot, Color(str(palette.get(f, "#000000")))), "WorldMap.tscn CityMarker_%s CityDot %s == %s %s" % [m, _hex(dot), f, palette.get(f, "?")])

	# 5. the same marker -> owner table against rule_data cities[].owner (city id = lower-case marker name)
	var rule_owners := {}
	for c in rule.get("cities", []):
		rule_owners[str(c.get("id", ""))] = str(c.get("owner", ""))
	for m in _sorted(MARKER_OWNERS.keys()):
		var cid := String(m).to_lower()
		_expect(rule_owners.get(cid, "<missing city>") == MARKER_OWNERS[m], "rule_data city %s owner %s == 2D %s" % [cid, rule_owners.get(cid, "<missing city>"), MARKER_OWNERS[m]])

	print("[WM3D_COLOR_PARITY] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)


func _scene_dot_colors(text: String) -> Dictionary:
	# marker name -> the color = line of its CityDot node (text parse: the scene is not instanced)
	var out := {}
	var current := ""
	for line in text.split("\n"):
		if line.begins_with("["):
			current = ""
			if line.begins_with("[node name=\"CityDot\"") and line.contains("/CityMarker_"):
				current = line.get_slice("/CityMarker_", 1).get_slice("\"", 0)
		elif current != "" and line.begins_with("color = Color("):
			var parts := line.trim_prefix("color = Color(").trim_suffix(")").split(",")
			out[current] = Color(float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3]))
	return out


func _read_json(path: String) -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	_expect(data is Dictionary, "%s parses as a JSON object" % path)
	return data if data is Dictionary else {}


func _same(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) <= TOLERANCE and absf(a.g - b.g) <= TOLERANCE and absf(a.b - b.b) <= TOLERANCE


func _hex(c: Color) -> String:
	return "#" + c.to_html(false).to_upper()


func _sorted(a: Array) -> Array:
	var s := a.duplicate()
	s.sort()
	return s


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
		push_error("[WM3D_COLOR_PARITY_FAIL] %s" % label)
