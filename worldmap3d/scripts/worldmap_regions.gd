## EASTWAR WorldMap3D v3 — regions & ownership.
## The region map texture (region_ids.png) holds region INDICES; regions.json maps index <-> region_id <-> city_id
## (one region = one city). Ownership is a 256x2 lookup texture:
##   row 0: texel[i] = owner colour (rgb) + BORDER-GROUP slot (a)
##   row 1: texel[i].r = 0.5 + 0.5 * shade  (v2.2: same-realm neighbours alternate fill brightness, regions.json "shade")
## Border group (v2.2, map_config territory.border_group): "realm" = the owner faction's realm (Korea / Japan / Wei / ...),
## so all regions of one realm share a slot -> thin two-tone inner borders between them, thick borders to other realms;
## "owner" = one slot per faction (v2.1 behaviour).
## Changing an owner rewrites ONE texel -> the whole region recolours on the next frame. O(1) per pixel in the shader.
class_name WorldMapRegions
extends RefCounted

const LUT_SIZE := 256

var regions: Array = []            # [{index, region_id, city_id, name_ko, realm, shade, ...}]
var index_by_city := {}            # city_id -> region index
var city_by_index := {}            # region index -> city_id
var faction_slot := {}             # faction_id -> border-group slot (1..255), 0 = none
var faction_color := {}            # faction_id -> Color (sRGB)
var faction_realm := {}            # faction_id -> realm id
var region_owner := {}             # region index -> faction_id ("" = none)
var region_shade := {}             # region index -> -1 / 0 / +1
var border_group := "realm"
var lut_image: Image
var lut_texture: ImageTexture

## palette: optional faction_id -> colour string that overrides the factions' own "color" (map palette).
func load_tables(regions_path: String, factions: Array, group := "realm", palette := {}) -> bool:
	var d = JSON.parse_string(FileAccess.get_file_as_string(regions_path))
	if d == null:
		push_error("WorldMapRegions: cannot read " + regions_path)
		return false
	border_group = group
	regions = d.regions
	for r in regions:
		var i := int(r.index)
		index_by_city[r.city_id] = i
		city_by_index[i] = r.city_id
		region_owner[i] = ""
		region_shade[i] = int(r.get("shade", 0))
	var realm_slot := {}
	for k in factions.size():
		var f: Dictionary = factions[k]
		var realm: String = String(f.get("realm", ""))
		faction_realm[f.id] = realm
		if group == "realm" and realm != "":
			if not realm_slot.has(realm):
				realm_slot[realm] = realm_slot.size() + 1
			faction_slot[f.id] = realm_slot[realm]
		else:
			faction_slot[f.id] = 0       # filled below (after all realm slots)
		faction_color[f.id] = Color(palette.get(f.id, f.get("color", "#808080")))
	var nxt := realm_slot.size() + 1
	for f in factions:
		if faction_slot[f.id] == 0:
			faction_slot[f.id] = mini(nxt, 255)
			nxt += 1
	lut_image = Image.create(LUT_SIZE, 2, false, Image.FORMAT_RGBA8)
	lut_image.fill(Color(0, 0, 0, 0))
	for i in region_shade:
		lut_image.set_pixel(i, 1, Color(0.5 + 0.5 * clampf(region_shade[i], -1.0, 1.0), 0, 0, 1))
	for i in range(LUT_SIZE):
		if not region_shade.has(i):
			lut_image.set_pixel(i, 1, Color(0.5, 0, 0, 1))
	lut_texture = ImageTexture.create_from_image(lut_image)
	return true

func _write_texel(i: int) -> void:
	var f: String = region_owner.get(i, "")
	if f == "" or not faction_slot.has(f):
		lut_image.set_pixel(i, 0, Color(0, 0, 0, 0))
	else:
		var c: Color = faction_color[f]
		lut_image.set_pixel(i, 0, Color(c.r, c.g, c.b, float(faction_slot[f]) / 255.0))

## Set many owners at once (initial load).
func set_all_owners(city_owner: Dictionary) -> void:
	for cid in city_owner:
		if index_by_city.has(cid):
			region_owner[index_by_city[cid]] = city_owner[cid]
	for i in region_owner:
		_write_texel(i)
	lut_texture.update(lut_image)

## O(1): one texel + one texture upload of 2 KB.
func set_city_owner(city_id: String, faction_id: String) -> bool:
	if not index_by_city.has(city_id):
		return false
	var i: int = index_by_city[city_id]
	region_owner[i] = faction_id
	_write_texel(i)
	lut_texture.update(lut_image)
	return true

## v2.2: recolour a faction everywhere (palette override from the game).
func set_faction_color(faction_id: String, c: Color) -> void:
	faction_color[faction_id] = c
	for i in region_owner:
		if region_owner[i] == faction_id:
			_write_texel(i)
	lut_texture.update(lut_image)

func owner_of_city(city_id: String) -> String:
	return region_owner.get(index_by_city.get(city_id, -1), "")
