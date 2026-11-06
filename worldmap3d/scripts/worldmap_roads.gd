## EASTWAR WorldMap3D v3 — road paths from rule-data links between MARKER display positions:
## A* over the terrain grid (avoids sea + steep slopes) + Chaikin smoothing. Drawn as ribbon meshes.
## PERF3: the A* output (grid cell ids per link) can come from a baked file (baked_file, written by
## tools/bake_worldmap3d_paths.gd) when its key matches the current inputs; smoothing and everything after it always run
## here. A missing or stale baked file falls back to the live A* with one push_warning, so the result never differs.
class_name WorldMapRoads
extends RefCounted

var paths: Array = []          # Array[PackedVector2Array] map km
var sea_paths: Array = []      # T-WM3D-06: Array[PackedVector2Array] map km, one per sea link (same order; skipped links missing)
var sea_links: Array = []      # the links that got a sea path (sea_paths[k] belongs to sea_links[k])
var baked_file := ""           # PERF3: res:// path of baked_paths.json; "" = always route live (maps without one)
var road_cells: Array = []     # PERF3: last build_paths A* output, [{link: [a, b], cells: Array[Vector2i]}]
var sea_cells: Array = []      # PERF3: last build_sea_paths A* output, [{link, status, cells}] (status "ok" or why skipped)
var last_road_source := ""     # "baked" / "live"
var last_sea_source := ""      # "baked" / "live"
var last_warning := ""         # the last fallback warning (tests)

const SEA_MAX_M := 2.0         # a grid cell with height <= 2.0 m is sea (same rule as the land A* solids above)
const SEA_SEARCH_CELLS := 80   # nearest-sea-cell search radius around a city (cells, ~3.2 km each)
const OPEN_SEA_MIN_CELLS := 5000   # a sea region this large counts as open sea (EastAsia: ocean 782k cells, next 328)
const BAKE_VERSION := 1
# Everything else the live A* depends on, folded into the bake key (change it together with the code above).
const ROAD_RULE := "land solid h<=2.0; weight 1+slope*60+h/500; diagonal only-if-no-obstacles; euclidean; ends opened"
const SEA_RULE := "sea open h<=2.0; diagonal only-if-no-obstacles; euclidean"

var _baked_cache := {}         # baked_file -> parsed Dictionary ({} = missing / unreadable)

func build_paths(geo: WorldMapGeo, city_xz: Dictionary, links: Array) -> void:
	var entries = _baked_entries("roads", section_key("roads", geo, city_xz, links))
	last_road_source = "live" if entries == null else "baked"
	road_cells = live_road_cells(geo, city_xz, links) if entries == null else entries
	paths.clear()
	for e in road_cells:
		var a: Vector2 = city_xz[e.link[0]]
		var b: Vector2 = city_xz[e.link[1]]
		var ids: Array = e.cells
		var pts := PackedVector2Array()
		pts.append(a)
		for k in range(1, ids.size() - 1):
			pts.append(geo.grid_to_xz(ids[k].x, ids[k].y))
		pts.append(b)
		paths.append(_chaikin(_chaikin(_chaikin(_chaikin(pts)))))

## The live land A*: one entry per link whose two cities exist, in link order. Each link opens its two end cells
## (they stay open for the later links), so the result depends on the whole link list.
func live_road_cells(geo: WorldMapGeo, city_xz: Dictionary, links: Array) -> Array:
	var astar := AStarGrid2D.new()
	astar.region = Rect2i(0, 0, geo.gw, geo.gh)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.update()
	var cell_m := geo.width_km / (geo.gw - 1) * 1000.0
	for j in geo.gh:
		for i in geo.gw:
			var h := geo.grid_height_m(i, j)
			if h <= 2.0:
				astar.set_point_solid(Vector2i(i, j), true)
				continue
			var s := maxf(absf(geo.grid_height_m(i + 1, j) - geo.grid_height_m(i - 1, j)),
					absf(geo.grid_height_m(i, j + 1) - geo.grid_height_m(i, j - 1))) / (2.0 * cell_m)
			astar.set_point_weight_scale(Vector2i(i, j), 1.0 + s * 60.0 + h / 500.0)
	var out := []
	for link in links:
		if not city_xz.has(link[0]) or not city_xz.has(link[1]):
			continue
		var ga := geo.xz_to_grid(city_xz[link[0]])
		var gb := geo.xz_to_grid(city_xz[link[1]])
		astar.set_point_solid(ga, false)
		astar.set_point_solid(gb, false)
		out.append({"link": [String(link[0]), String(link[1])], "cells": Array(astar.get_id_path(ga, gb))})
	return out

## T-WM3D-06: sea routes. A* over sea cells only (the reverse of the land A*: land is solid). Each end is the city's
## nearest sea cell, joined to the city by a straight connector; only the sea part is Chaikin-smoothed, so every point
## except the two cities lies over sea. A link without a nearby sea cell or a sea path is skipped with an error.
## Result: sea_paths[k] = [city_a, sea cells..., city_b] for sea_links[k].
func build_sea_paths(geo: WorldMapGeo, city_xz: Dictionary, links: Array) -> void:
	var entries = _baked_entries("sea_routes", section_key("sea_routes", geo, city_xz, links))
	last_sea_source = "live" if entries == null else "baked"
	sea_cells = live_sea_cells(geo, city_xz, links) if entries == null else entries
	sea_paths.clear()
	sea_links.clear()
	for e in sea_cells:
		var link: Array = e.link
		match String(e.status):
			"unknown_city":
				push_error("WorldMapRoads: sea route %s-%s: unknown city" % [link[0], link[1]])
				continue
			"no_sea_cell":
				push_error("WorldMapRoads: sea route %s-%s: no sea cell within %d cells of a city" % [link[0], link[1], SEA_SEARCH_CELLS])
				continue
			"no_path":
				push_error("WorldMapRoads: sea route %s-%s: no sea path" % [link[0], link[1]])
				continue
		var sea := PackedVector2Array()
		for id in e.cells:
			sea.append(geo.grid_to_xz(id.x, id.y))
		sea = _chaikin(_chaikin(_chaikin(_chaikin(sea))))
		var pts := PackedVector2Array()
		pts.append(city_xz[link[0]])
		pts.append_array(sea)
		pts.append(city_xz[link[1]])
		sea_paths.append(pts)
		sea_links.append(link)

## The live sea A*: one entry per link in link order; status "ok" or why the link is skipped (cells empty then).
func live_sea_cells(geo: WorldMapGeo, city_xz: Dictionary, links: Array) -> Array:
	var astar := AStarGrid2D.new()
	astar.region = Rect2i(0, 0, geo.gw, geo.gh)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.update()
	for j in geo.gh:
		for i in geo.gw:
			if geo.grid_height_m(i, j) > SEA_MAX_M:
				astar.set_point_solid(Vector2i(i, j), true)
	var out := []
	for link in links:
		var e := {"link": [String(link[0]), String(link[1])], "status": "ok", "cells": []}
		out.append(e)
		if not city_xz.has(link[0]) or not city_xz.has(link[1]):
			e.status = "unknown_city"
			continue
		var sa := _nearest_sea_cell(geo, geo.xz_to_grid(city_xz[link[0]]))
		var sb := _nearest_sea_cell(geo, geo.xz_to_grid(city_xz[link[1]]))
		if sa.x < 0 or sb.x < 0:
			e.status = "no_sea_cell"
			continue
		var ids := astar.get_id_path(sa, sb)
		if ids.is_empty():
			e.status = "no_path"
			continue
		e.cells = Array(ids)
	return out

## Nearest open-sea cell (Euclidean, in cells) to grid cell c, searching square rings outward; (-1, -1) if none.
## Open sea = a sea cell whose 4-connected sea region has at least OPEN_SEA_MIN_CELLS cells. Low inland cells
## (<= 2 m river / lagoon pockets of 1..328 cells on the EastAsia grid) are skipped: a path cannot start there.
func _nearest_sea_cell(geo: WorldMapGeo, c: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_d2 := INF
	var closed := {}                    # cells of sea pockets already found too small
	for r in SEA_SEARCH_CELLS + 1:
		if float(r * r) > best_d2:      # every cell on ring r is at least r away
			break
		var ring := []
		for dj in range(-r, r + 1):
			for di in range(-r, r + 1):
				if maxi(absi(di), absi(dj)) != r:
					continue
				var i := c.x + di
				var j := c.y + dj
				if i < 0 or j < 0 or i >= geo.gw or j >= geo.gh:
					continue
				var d2 := float(di * di + dj * dj)
				if d2 < best_d2 and geo.grid_height_m(i, j) <= SEA_MAX_M:
					ring.append([d2, Vector2i(i, j)])
		ring.sort_custom(func(x, y): return x[0] < y[0])
		for e in ring:
			if e[0] < best_d2 and not closed.has(e[1]) and _is_open_sea(geo, e[1], closed):
				best_d2 = e[0]
				best = e[1]
				break
	return best

## Bounded flood fill over sea cells from s: true once OPEN_SEA_MIN_CELLS cells are reached. A smaller pocket is added
## to `closed` so its other cells are not filled again.
func _is_open_sea(geo: WorldMapGeo, s: Vector2i, closed: Dictionary) -> bool:
	var seen := {s: true}
	var queue: Array[Vector2i] = [s]
	var head := 0
	while head < queue.size():
		if seen.size() >= OPEN_SEA_MIN_CELLS:
			return true
		var p: Vector2i = queue[head]
		head += 1
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + d
			if q.x < 0 or q.y < 0 or q.x >= geo.gw or q.y >= geo.gh or seen.has(q):
				continue
			if geo.grid_height_m(q.x, q.y) <= SEA_MAX_M:
				seen[q] = true
				queue.append(q)
	for k in seen:
		closed[k] = true
	return false

func _chaikin(p: PackedVector2Array) -> PackedVector2Array:
	if p.size() < 3:
		return p
	var o := PackedVector2Array()
	o.append(p[0])
	for k in p.size() - 1:
		o.append(p[k].lerp(p[k + 1], 0.25))
		o.append(p[k].lerp(p[k + 1], 0.75))
	o.append(p[p.size() - 1])
	return o

# ------------------------------------------------------------------ PERF3 bake

## SHA-256 over every input of one section's A*: version, rule string and constants, grid size / extent, the height
## grid's byte size and contents, every city's display position (km, 3 decimals) and grid cell, and the link list.
static func section_key(section: String, geo: WorldMapGeo, city_xz: Dictionary, links: Array) -> String:
	var parts := PackedStringArray()
	parts.append("v%d|%s" % [BAKE_VERSION, section])
	if section == "roads":
		parts.append(ROAD_RULE)
	else:
		parts.append("%s; SEA_MAX_M %.3f; SEA_SEARCH_CELLS %d; OPEN_SEA_MIN_CELLS %d" % [SEA_RULE, SEA_MAX_M, SEA_SEARCH_CELLS, OPEN_SEA_MIN_CELLS])
	parts.append("grid %dx%d width_km %.6f height_km %.6f" % [geo.gw, geo.gh, geo.width_km, geo.height_km])
	var grid_bytes := geo.grid.to_byte_array()
	var hc := HashingContext.new()
	hc.start(HashingContext.HASH_SHA256)
	hc.update(grid_bytes)
	parts.append("grid bytes %d sha256 %s" % [grid_bytes.size(), hc.finish().hex_encode()])
	var ids := city_xz.keys()
	ids.sort()
	for cid in ids:
		var p: Vector2 = city_xz[cid]
		parts.append("city %s %.3f %.3f %s" % [cid, p.x, p.y, str(geo.xz_to_grid(p))])
	for link in links:
		parts.append("link %s-%s" % [link[0], link[1]])
	return "\n".join(parts).sha256_text()

## The whole baked file for the current inputs (live A* for both sections). The bake tool and the freshness test use it.
func bake_dict(geo: WorldMapGeo, city_xz: Dictionary, road_links: Array, sea_route_links: Array) -> Dictionary:
	var rk := section_key("roads", geo, city_xz, road_links)
	var sk := section_key("sea_routes", geo, city_xz, sea_route_links)
	var roads_out := []
	for e in live_road_cells(geo, city_xz, road_links):
		roads_out.append({"link": e.link, "cells": _cells_to_json(e.cells)})
	var sea_out := []
	for e in live_sea_cells(geo, city_xz, sea_route_links):
		sea_out.append({"link": e.link, "status": e.status, "cells": _cells_to_json(e.cells)})
	return {"version": BAKE_VERSION, "key": (rk + sk).sha256_text(), "roads_key": rk, "sea_routes_key": sk,
		"roads": roads_out, "sea_routes": sea_out}

## Baked file text: header fields, then one link per line (stable, diff-friendly).
static func bake_text(d: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append("{")
	for k in ["version", "key", "roads_key", "sea_routes_key"]:
		lines.append("\t%s: %s," % [JSON.stringify(k), JSON.stringify(d[k])])
	for section in ["roads", "sea_routes"]:
		lines.append("\t%s: [" % JSON.stringify(section))
		var rows: Array = d[section]
		for n in rows.size():
			lines.append("\t\t%s%s" % [JSON.stringify(rows[n], "", false), "," if n < rows.size() - 1 else ""])
		lines.append("\t]%s" % ("," if section == "roads" else ""))
	lines.append("}")
	return "\n".join(lines) + "\n"

## Entries of one section from baked_file when its key matches, else null (live A*) with one warning.
func _baked_entries(section: String, key: String) -> Variant:
	if baked_file == "":
		return null
	if not _baked_cache.has(baked_file):
		var d = null
		if FileAccess.file_exists(baked_file):
			d = JSON.parse_string(FileAccess.get_file_as_string(baked_file))
		_baked_cache[baked_file] = d if d is Dictionary else {}
	var data: Dictionary = _baked_cache[baked_file]
	if data.is_empty():
		_fallback_warning("%s: baked file %s is missing or unreadable" % [section, baked_file])
		return null
	if int(data.get("version", -1)) != BAKE_VERSION or String(data.get(section + "_key", "")) != key or not data.get(section) is Array:
		_fallback_warning("%s: baked file %s is stale (inputs changed; re-run tools/bake_worldmap3d_paths.gd)" % [section, baked_file])
		return null
	var out := []
	for row in data[section]:
		var e := {"link": [String(row.link[0]), String(row.link[1])], "cells": _cells_from_json(row.cells)}
		if section == "sea_routes":
			e.status = String(row.get("status", "ok"))
		out.append(e)
	return out

func _fallback_warning(msg: String) -> void:
	last_warning = msg
	push_warning("WorldMapRoads: %s -> live A*" % msg)

static func _cells_to_json(cells: Array) -> Array:
	var out := []
	for c in cells:
		out.append([c.x, c.y])
	return out

static func _cells_from_json(rows: Array) -> Array:
	var out := []
	for r in rows:
		out.append(Vector2i(int(r[0]), int(r[1])))
	return out
