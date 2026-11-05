class_name WorldMapCityInteriorLayouts
extends RefCounted

## CITY-HUD CH-3: reads the five castle layouts (city_layouts.json, from the CH-3 asset pack) once and hands them to the
## city interior window. Coordinates are 1280x768 canvas pixels, origin top left; (ax, ay) is an item's foot (bottom
## centre), its rect is (ax - w/2, ay - h) with size (w, h) already scaled. Items are listed in draw order. The layout
## coordinates are data from the pack and are never adjusted here.

const LAYOUTS_PATH := "res://assets/worldmap/city_buildings/city_layouts.json"
const CANVAS_SIZE := Vector2(1280, 768)

static var _layouts: Dictionary = {}
static var _loaded := false


static func has_layout(city_id: String) -> bool:
	return _all_layouts().has(city_id)


## {} when the city has no layout.
static func get_layout(city_id: String) -> Dictionary:
	var layout: Variant = _all_layouts().get(city_id, {})
	return layout if layout is Dictionary else {}


## The items to draw, in draw order: without compare_only items, and without coastal_only items unless the city is coastal.
static func items_for_city(city_id: String, is_coastal: bool) -> Array:
	var items: Array = []
	var raw: Variant = get_layout(city_id).get("items", [])
	if not raw is Array:
		return items
	for item in raw:
		if not item is Dictionary:
			continue
		if bool(item.get("compare_only", false)):
			continue
		if bool(item.get("coastal_only", false)) and not is_coastal:
			continue
		items.append(item)
	return items


## k = min(W/1280, H/768); the canvas keeps its ratio and is centred: screen = off + canvas_point * k.
static func canvas_transform(area_size: Vector2) -> Dictionary:
	var k := minf(area_size.x / CANVAS_SIZE.x, area_size.y / CANVAS_SIZE.y)
	return {"k": k, "off": (area_size - CANVAS_SIZE * k) * 0.5}


## The item's top-left on the canvas: (ax - w/2, ay - h).
static func item_top_left(item: Dictionary) -> Vector2:
	return Vector2(float(item.get("ax", 0)) - float(item.get("w", 0)) * 0.5, float(item.get("ay", 0)) - float(item.get("h", 0)))


static func _all_layouts() -> Dictionary:
	if _loaded:
		return _layouts
	_loaded = true
	if not FileAccess.file_exists(LAYOUTS_PATH):
		return _layouts
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUTS_PATH))
	if parsed is Dictionary and (parsed as Dictionary).get("layouts") is Dictionary:
		_layouts = (parsed as Dictionary)["layouts"]
	return _layouts
