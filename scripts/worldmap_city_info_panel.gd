extends "res://scripts/worldmap_city_info_panel_base.gd"


func _format_hero_stats(hero_data: Dictionary) -> String:
	if hero_data.is_empty():
		return "능력: -"
	return HeroRuntimeFactory.format_stat_line(hero_data)
