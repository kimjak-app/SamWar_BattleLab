class_name BattleStateFingerprintService
extends RefCounted

func fingerprint_units(units: Array[BattleUnitState]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for unit in units:
		var values := {}
		if unit == null:
			values["_null_unit"] = true
		else:
			for property in unit.get_property_list():
				if int(property.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE:
					values[String(property.name)] = _copy(unit.get(property.name))
		result.append(values)
	return result

func diff(a: Variant, b: Variant) -> Array[String]:
	var paths: Array[String] = []
	_compare(a, b, "units", paths)
	return paths

func _copy(value: Variant) -> Variant:
	if value is Vector2i:
		return [value.x, value.y]
	if value is Dictionary:
		var copy := {}
		for key in value:
			copy[key] = _copy(value[key])
		return copy
	if value is Array:
		var copy := []
		for item in value:
			copy.append(_copy(item))
		return copy
	return value

func _compare(a: Variant, b: Variant, path: String, paths: Array[String]) -> void:
	if typeof(a) != typeof(b):
		# JSON parses integral numbers as floats; equal numeric values are equivalent.
		if (a is int or a is float) and (b is int or b is float) and a == b:
			return
		paths.append(path)
		return
	if a is Dictionary:
		var keys: Array = a.keys()
		for key in b:
			if not keys.has(key):
				keys.append(key)
		keys.sort()
		for key in keys:
			var field_path := path + "." + String(key)
			if not a.has(key) or not b.has(key):
				paths.append(field_path)
			else:
				_compare(a[key], b[key], field_path, paths)
	elif a is Array:
		if path == "units":
			for i in range(maxi(a.size(), b.size())):
				var item_path := "%s[%d]" % [path, i]
				if i >= a.size() or i >= b.size():
					paths.append(item_path)
				else:
					_compare(a[i], b[i], item_path, paths)
		else:
			var nested: Array[String] = []
			if a.size() != b.size():
				nested.append(path)
			else:
				for i in range(a.size()):
					_compare(a[i], b[i], "%s[%d]" % [path, i], nested)
			if not nested.is_empty():
				paths.append(path)
	elif a != b:
		paths.append(path)
