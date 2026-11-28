class_name WorldMapCityRosterService
extends RefCounted

## Queue 39 (CITIES65 0.7): the scene keeps its 13 hand-placed CityMarker nodes; the other cities of the 3D map data
## get a logical 2D marker built here (a copy of an existing marker), so 3D clicks, the HUD and turn code see them
## the same way. The 2D map itself is hidden by the 3D HUD; positions are a least-squares fit of the 13 scene markers.
## Queue 46 (PLACEMENT_A + 0.7 roads): every marker — the 13 scene markers too — gets its links from the same 0.7 rule
## data the 3D roads are drawn from (100 roads as "land", 20 sea routes as "sea"), both directions. The scene's v2.4
## neighbors / route types (18 links, e.g. 상도–평양, 상도–업성) are replaced, so sortie, AI, battle context, trade
## and supply all read the 0.7 graph, and the route type of every linked pair is explicit (e.g. 오사카–히로시마 is
## land, no naval research; 사비–개성 is sea).

const RULE_DATA_PATH := "res://worldmap3d/maps/eastasia/rule_data_eastasia.json"
const MARKERS_PATH := "res://worldmap3d/maps/eastasia/markers.json"
const REGION_ID_BY_STYLE := {"kr": "region.korean_peninsula", "cn": "region.china_mainland", "jp": "region.japanese_archipelago"}


static func add_missing_city_markers(city_layer: Node, city_hud_data: Dictionary) -> Array[String]:
	var added: Array[String] = []
	if city_layer == null:
		return added
	var rules := _load_json(RULE_DATA_PATH)
	var marker_km: Dictionary = _load_json(MARKERS_PATH).get("markers", {})
	var existing := {}
	var template: Node2D = null
	for child in city_layer.get_children():
		if child is WorldMapCityMarker:
			existing[str(child.city_id)] = child
			if template == null:
				template = child
	if template == null or rules.is_empty():
		return added
	var fit := _fit_km_to_layer(existing, marker_km)
	var links := _links_by_city(rules)
	for city_id in existing:
		_apply_links(existing[city_id] as WorldMapCityMarker, links.get(city_id, {}))
	for city in rules.get("cities", []):
		var city_id := str(city.get("id", ""))
		if city_id.is_empty() or existing.has(city_id) or not city_hud_data.has(city_id) or not marker_km.has(city_id):
			continue
		var marker := template.duplicate() as WorldMapCityMarker
		marker.name = "CityMarker_" + city_id
		marker.city_id = city_id
		marker.display_name = str(city_hud_data[city_id].get("name", city.get("name_ko", city_id)))
		marker.region_id = str(REGION_ID_BY_STYLE.get(str(city.get("building_style", "")), ""))
		marker.owner_faction_id = str(city_hud_data[city_id].get("owner", ""))
		_apply_links(marker, links.get(city_id, {}))
		var km: Dictionary = marker_km[city_id]
		marker.position = Vector2(fit.ax * float(km.x_km) + fit.bx, fit.az * float(km.z_km) + fit.bz)
		marker.web_seed_position = marker.position
		city_layer.add_child(marker)
		added.append(city_id)
	return added


static func _apply_links(marker: WorldMapCityMarker, city_links: Dictionary) -> void:
	var neighbor_ids: Array[String] = []
	for neighbor_id in city_links:
		neighbor_ids.append(str(neighbor_id))
	neighbor_ids.sort()
	marker.neighbors = neighbor_ids
	marker.route_types = city_links.duplicate()


## The gameplay link table: city id -> {neighbor id: "land" | "sea"}, symmetric (both directions of every pair).
static func load_links() -> Dictionary:
	return _links_by_city(_load_json(RULE_DATA_PATH))


static func _links_by_city(rules: Dictionary) -> Dictionary:
	var links := {}
	for pair in rules.get("roads", []):
		_add_link(links, str(pair[0]), str(pair[1]), "land")
	for pair in rules.get("sea_routes", []):
		_add_link(links, str(pair[0]), str(pair[1]), "sea")
	return links


static func _add_link(links: Dictionary, a: String, b: String, route_type: String) -> void:
	if not links.has(a):
		links[a] = {}
	if not links.has(b):
		links[b] = {}
	links[a][b] = route_type
	links[b][a] = route_type


## Per-axis least squares: layer position = a * km + b, from the scene markers that also have 3D km positions.
static func _fit_km_to_layer(existing: Dictionary, marker_km: Dictionary) -> Dictionary:
	var xs: Array = []
	var zs: Array = []
	var px: Array = []
	var pz: Array = []
	for city_id in existing:
		if not marker_km.has(city_id):
			continue
		xs.append(float(marker_km[city_id].x_km))
		zs.append(float(marker_km[city_id].z_km))
		px.append((existing[city_id] as Node2D).position.x)
		pz.append((existing[city_id] as Node2D).position.y)
	var x_fit := _line_fit(xs, px)
	var z_fit := _line_fit(zs, pz)
	return {"ax": x_fit.x, "bx": x_fit.y, "az": z_fit.x, "bz": z_fit.y}


static func _line_fit(source: Array, target: Array) -> Vector2:
	var n := source.size()
	if n < 2:
		return Vector2(1.0, 0.0)
	var mean_s := 0.0
	var mean_t := 0.0
	for i in n:
		mean_s += source[i]
		mean_t += target[i]
	mean_s /= n
	mean_t /= n
	var cov := 0.0
	var var_s := 0.0
	for i in n:
		cov += (source[i] - mean_s) * (target[i] - mean_t)
		var_s += (source[i] - mean_s) * (source[i] - mean_s)
	var slope := cov / var_s if var_s > 0.0 else 1.0
	return Vector2(slope, mean_t - slope * mean_s)


static func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}
