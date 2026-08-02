extends SceneTree

const Registry := preload("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")
const RUNTIME_PAIRS := {
	"yi_sunsin": "hakikjin_barrage",
	"jeong_dojeon": "reform_order",
	"kwon_yul": "gwon_yul_haengju_defense",
	"gim_yusin": "kim_yu_sin_unification_charge",
	"eulji_mundeok": "eulji_mundeok_salsu_ambush",
}


func _init() -> void:
	for hero_id in RUNTIME_PAIRS:
		var entry := Registry.find_entry(hero_id, String(RUNTIME_PAIRS[hero_id]))
		if entry.is_empty():
			printerr("CUTIN GODOT FAILED registry miss hero=%s" % hero_id)
			quit(1)
			return
		var video := ResourceLoader.load(String(entry.get("video_path", ""))) as VideoStream
		var title := ResourceLoader.load(String(entry.get("skill_title_texture_path", ""))) as Texture2D
		if video == null or title == null:
			printerr("CUTIN GODOT FAILED resource load hero=%s video=%s title=%s" % [hero_id, str(video != null), str(title != null)])
			quit(1)
			return
		print("CUTIN GODOT PASS hero=%s video=%s" % [hero_id, String(entry.get("video_path", ""))])
	quit(0)
