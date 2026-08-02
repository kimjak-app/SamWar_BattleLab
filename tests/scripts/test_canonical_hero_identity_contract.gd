extends SceneTree

const Registry := preload("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")

const IDENTITY_MATRIX := [
	{"unit_id": "yi_sunsin", "skill_owner_id": "yi_sun_sin", "expected": "yi_sun_sin"},
	{"unit_id": "jeong_dojeon", "skill_owner_id": "jeong_do_jeon", "expected": "jeong_do_jeon"},
	{"unit_id": "gim_yusin", "skill_owner_id": "kim_yu_sin", "expected": "kim_yu_sin"},
	{"unit_id": "kwon_yul", "skill_owner_id": "kwon_yul", "expected": "kwon_yul"},
	{"unit_id": "eulji_mundeok", "skill_owner_id": "eulji_mundeok", "expected": "eulji_mundeok"},
	{"unit_id": "guan_yu", "skill_owner_id": "guan_yu", "expected": "guan_yu"},
	{"unit_id": "zhang_fei", "skill_owner_id": "zhang_fei", "expected": "zhang_fei"},
	{"unit_id": "liu_bei", "skill_owner_id": "liu_bei", "expected": "liu_bei"},
	{"unit_id": "xiahou_dun", "skill_owner_id": "xiahou_dun", "expected": "xiahou_dun"},
	{"unit_id": "zhuge_liang", "skill_owner_id": "zhuge_liang", "expected": "zhuge_liang"},
]


func _init() -> void:
	for row in IDENTITY_MATRIX:
		var unit_id := Registry.canonicalize_hero_id(String(row.unit_id))
		var skill_owner_id := Registry.canonicalize_hero_id(String(row.skill_owner_id))
		var expected := String(row.expected)
		var passed := unit_id == expected and skill_owner_id == expected and unit_id == skill_owner_id
		print("IDENTITY hero=%s unit=%s skill_owner=%s canonical=%s parity=%s" % [expected, String(row.unit_id), String(row.skill_owner_id), unit_id, str(passed)])
		if not passed:
			printerr("IDENTITY CONTRACT FAILED hero=%s" % expected)
			quit(1)
			return
	print("CANONICAL HERO IDENTITY GODOT PASS")
	quit(0)
