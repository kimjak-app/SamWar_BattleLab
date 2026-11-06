class_name WorldMapCityBuildingAssets
extends RefCounted

## CITY-HUD CH-1: paths and loading for the 90 city-building 2.5D images (30 buildings x kr/cn/jp).
## Not wired into any screen yet. Callers fall back on their own when load_texture() returns null.
## Building keys are the file names without "bld_" and "_<kr|cn|jp>.png". No city ids and no tech ids here
## (the tech link is CH-4).

const ASSET_DIR := "res://assets/worldmap/city_buildings/"
const REGION_STYLES: PackedStringArray = ["kr", "cn", "jp"]

## The 30 keys, in the manifest's group order: 1 commerce/barracks (6), 2 walls (7), 3 fields (5),
## 4 coast (7), 5 life (5).
const BUILDING_KEYS: PackedStringArray = [
	"commerce_street_market", "commerce_permanent_market", "commerce_grand_market", "commerce_merchant_guild",
	"commerce_mint", "mil_barracks",
	"mil_wall_upgrade", "mil_moat", "mil_double_moat", "mil_iron_gate", "mil_watchtower", "mil_beacon",
	"mil_iron_fortress",
	"agri_irrigation", "agri_reservoir", "agri_granary_zone", "agri_pasture", "agri_ranch",
	"commerce_port", "commerce_trade_port", "commerce_shipyard", "fish_village", "fish_salt_field",
	"fish_salt_warehouse", "fish_dried_supply_base",
	"life_office", "life_academy", "life_smithy", "life_storehouse", "life_temple",
]

## City data region_key (with or without the "region." prefix) -> image region style.
## Anything else (the northern steppe / Karakorum included) has no image set: "".
const REGION_STYLE_BY_REGION_KEY := {
	"korean_peninsula": "kr",
	"china_mainland": "cn",
	"japanese_archipelago": "jp",
}


static func all_building_keys() -> PackedStringArray:
	return BUILDING_KEYS.duplicate()


## "" for an unknown building key or a region style other than kr/cn/jp.
static func texture_path(building_key: String, region_style: String) -> String:
	if not BUILDING_KEYS.has(building_key) or not REGION_STYLES.has(region_style):
		return ""
	return "%sbld_%s_%s.png" % [ASSET_DIR, building_key, region_style]


static func has_texture(building_key: String, region_style: String) -> bool:
	var path := texture_path(building_key, region_style)
	return not path.is_empty() and ResourceLoader.exists(path)


## null (quietly) when there is no such image; the caller falls back.
static func load_texture(building_key: String, region_style: String) -> Texture2D:
	if not has_texture(building_key, region_style):
		return null
	return load(texture_path(building_key, region_style)) as Texture2D


static func region_style_for_region_key(region_key: String) -> String:
	var key := region_key.trim_prefix("region.")
	return str(REGION_STYLE_BY_REGION_KEY.get(key, ""))
