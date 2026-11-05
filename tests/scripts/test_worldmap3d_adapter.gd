extends SceneTree

var _checks := 0
var _failures := 0


class FakeRoot extends Node:
	signal city_selected(city_id: String, region_index: int)
	var camera = "fake_camera"
	var marker_xz := {"hanseong": Vector2(10, 20), "luoyang": Vector2(-5, 7)}
	var owners := {}
	var troops := {}
	var factions := ["player", "wei", "chu"]
	var owner_calls := 0   # counts set_city_owner calls (03-4: unchanged values are not pushed again)
	func set_city_owner(city_id: String, faction_id: String) -> bool:
		owner_calls += 1
		if not factions.has(faction_id):
			return false
		owners[city_id] = faction_id
		return true
	func set_city_troops(city_id: String, n: int) -> void:
		troops[city_id] = n

class FakeMarker extends Node2D:
	signal city_selected(marker)
	var city_id := ""
	var owner_faction_id := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var adapter := WorldMap3DAdapter.new()
	root.add_child(adapter)
	var fake := FakeRoot.new()
	root.add_child(fake)
	var hanseong := _marker("hanseong", "player", Vector2(300, 400))
	var luoyang := _marker("luoyang", "nope", Vector2(700, 500))
	adapter.set_markers({"hanseong": hanseong, "luoyang": luoyang})

	# 1. bind_root / get_camera
	adapter.bind_root(fake)
	_expect(adapter.get_camera() == "fake_camera", "bind_root: get_camera returns the root's camera")
	adapter.bind_root(null)
	_expect(adapter.get_camera() == null, "bind_root(null): get_camera is null")
	adapter.bind_root(fake)

	# 2. picks are forwarded only while active
	var got: Array = []
	hanseong.city_selected.connect(func(m) -> void: got.append(m))
	var forwarded: Array = []
	adapter.city_pick_forwarded.connect(func(cid: String) -> void: forwarded.append(cid))
	fake.city_selected.emit("hanseong", 1)
	_expect(got.is_empty(), "inactive: 3D pick is not forwarded to the marker")
	_expect(forwarded.is_empty(), "inactive: city_pick_forwarded not emitted")
	adapter.set_active(true)
	fake.city_selected.emit("hanseong", 1)
	_expect(got.size() == 1, "active: marker city_selected emitted once")
	_expect(got.size() == 1 and got[0] == hanseong, "active: marker signal carries the marker itself")
	_expect(forwarded == ["hanseong"], "active: city_pick_forwarded emitted once with the city id")

	# 3. empty / unknown ids do nothing
	got.clear()
	forwarded.clear()
	fake.city_selected.emit("", 0)
	fake.city_selected.emit("nowhere", 0)
	_expect(got.is_empty(), "empty / unknown city id: no marker signal")
	_expect(forwarded.is_empty(), "empty / unknown city id: no city_pick_forwarded")

	# 4. rebinding drops the old root's signal (no duplicate connection)
	var fake2 := FakeRoot.new()
	root.add_child(fake2)
	adapter.bind_root(fake2)
	fake.city_selected.emit("hanseong", 1)
	_expect(got.is_empty(), "rebind: old root's pick is no longer forwarded")
	_expect(not fake.city_selected.is_connected(adapter._on_root_city_selected), "rebind: old root disconnected")
	fake2.city_selected.emit("hanseong", 1)
	_expect(got.size() == 1, "rebind: new root's pick is forwarded once")
	adapter.bind_root(fake2)
	got.clear()
	fake2.city_selected.emit("hanseong", 1)
	_expect(got.size() == 1, "binding the same root twice does not double-forward")
	adapter.bind_root(fake)
	got.clear()

	# 5. set_active toggles the 2D map (no layer built yet)
	var world2d := Node2D.new()
	root.add_child(world2d)
	adapter.world_root_2d = world2d
	adapter.set_active(true)
	_expect(world2d.visible == false, "set_active(true) hides the 2D map")
	_expect(adapter.is_active(), "is_active() true")
	adapter.set_active(false)
	_expect(world2d.visible == true, "set_active(false) shows the 2D map")
	_expect(not adapter.is_active(), "is_active() false")
	_expect(adapter.layer == null, "no layer: set_active runs without one")

	# 6. sync_city owner + troops
	_expect(adapter.sync_city("hanseong"), "sync_city(hanseong) accepted")
	_expect(fake.owners.get("hanseong", "") == "player", "3D owner of hanseong = player")
	_expect(not fake.troops.has("hanseong"), "no troops_provider: troops untouched")
	adapter.troops_provider = func(_cid: String) -> int: return 321
	adapter.sync_city("hanseong")
	_expect(fake.troops.get("hanseong", -1) == 321, "troops_provider value pushed to 3D")
	adapter.troops_provider = Callable()

	# 7. rejected faction is recorded once; faction_resolver can map it
	_expect(not adapter.sync_city("luoyang"), "sync_city(luoyang) with unknown faction rejected")
	_expect(adapter.unmapped_owners == ["luoyang:nope"], "rejected pair recorded")
	adapter.sync_city("luoyang")
	_expect(adapter.unmapped_owners == ["luoyang:nope"], "rejected pair not duplicated")
	adapter.faction_resolver = func(m) -> String: return "wei" if m.owner_faction_id == "nope" else str(m.owner_faction_id)
	_expect(adapter.sync_city("luoyang"), "faction_resolver maps nope -> wei: accepted")
	_expect(fake.owners.get("luoyang", "") == "wei", "3D owner of luoyang = wei")

	# 8. unknown id / no root / sync_all
	_expect(not adapter.sync_city("no_such_city"), "sync_city(unknown id) is false")
	_expect(adapter.sync_all() == 2, "sync_all with resolver: 2 accepted")
	adapter.faction_resolver = Callable()
	_expect(adapter.sync_all() == 1, "sync_all without resolver: 1 accepted (luoyang rejected)")
	var lone := WorldMap3DAdapter.new()
	lone.set_markers({"hanseong": hanseong})
	_expect(not lone.sync_city("hanseong"), "no root: sync_city is false")

	# 9. 2D position / city -> 3D coordinate
	var fb := Vector2(-1, -1)
	_expect(adapter.focus_for_2d_position(hanseong.global_position, fb) == Vector2(10, 20), "focus_for_2d_position(marker) = marker_xz")
	_expect(adapter.focus_for_2d_position(Vector2(9999, 9999), fb) == fb, "focus_for_2d_position(no marker) = fallback")
	_expect(adapter.focus_for_city("hanseong", fb) == Vector2(10, 20), "focus_for_city(hanseong)")
	_expect(adapter.focus_for_city("edo", fb) == fb, "focus_for_city(unknown) = fallback")
	_expect(lone.focus_for_city("hanseong", fb) == fb, "no root: focus_for_city = fallback")
	_expect(lone.focus_for_2d_position(hanseong.global_position, fb) == fb, "no root: focus_for_2d_position = fallback")
	lone.free()

	# 9b. T-WM3D-07: focus_for_blend_2d — the 72% point between two 2D markers -> the same 72% point between their 3D cities
	var blend_adapter := WorldMap3DAdapter.new()
	root.add_child(blend_adapter)
	var blend_root := FakeRoot.new()
	root.add_child(blend_root)
	var blend_markers := {}
	var blend_xz := {}
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261105
	for k in 13:
		var cid := "city%02d" % k
		blend_markers[cid] = _marker(cid, "player", Vector2(rng.randf_range(0, 1800), rng.randf_range(0, 1000)))
		blend_xz[cid] = Vector2(rng.randf_range(-2700, 2700), rng.randf_range(-1800, 1800))
	blend_root.marker_xz = blend_xz
	blend_adapter.set_markers(blend_markers)
	blend_adapter.bind_root(blend_root)
	var worst := 0.0
	var pairs := 0
	var matched := 0
	for a in blend_markers:
		for b in blend_markers:
			if a == b:
				continue
			pairs += 1
			var p2: Vector2 = (blend_markers[a] as Node2D).global_position.lerp((blend_markers[b] as Node2D).global_position, 0.72)
			var want: Vector2 = (blend_xz[a] as Vector2).lerp(blend_xz[b], 0.72)
			var got3: Vector2 = blend_adapter.focus_for_blend_2d(p2, 0.72, fb)
			if got3 != fb:
				matched += 1
			worst = maxf(worst, got3.distance_to(want))
	_expect(pairs == 156 and matched == 156, "focus_for_blend_2d: all 156 ordered pairs matched (%d/%d)" % [matched, pairs])
	_expect(worst <= 0.001, "focus_for_blend_2d: 72%% point within 0.001 km on every pair (worst %.6f)" % worst)
	var m0: Node2D = blend_markers["city00"]
	var m1: Node2D = blend_markers["city01"]
	_expect(blend_adapter.focus_for_blend_2d(m0.global_position, 0.72, fb) == blend_xz["city00"], "focus_for_blend_2d(exact marker) = that city")
	_expect(blend_adapter.focus_for_blend_2d(Vector2(-5000, -5000), 0.72, fb) == fb, "focus_for_blend_2d(nowhere) = fallback")
	var p01 := m0.global_position.lerp(m1.global_position, 0.72)
	_expect(blend_adapter.focus_for_blend_2d(p01 + Vector2(0.4, 0), 0.72, fb).distance_to((blend_xz["city00"] as Vector2).lerp(blend_xz["city01"], 0.72)) <= 0.001, "focus_for_blend_2d: 0.4 px off still matches")
	_expect(blend_adapter.focus_for_blend_2d(p01 + Vector2(0.6, 0), 0.72, fb) == fb, "focus_for_blend_2d: 0.6 px off = fallback")
	blend_xz.erase("city01")
	_expect(blend_adapter.focus_for_blend_2d(p01, 0.72, fb) == fb, "focus_for_blend_2d: pair with a city missing in 3D is skipped")
	var no_root := WorldMap3DAdapter.new()
	no_root.set_markers(blend_markers)
	_expect(no_root.focus_for_blend_2d(p01, 0.72, fb) == fb, "focus_for_blend_2d: no root = fallback")
	no_root.free()
	for cid in blend_markers:
		(blend_markers[cid] as Node).free()
	blend_adapter.free()
	blend_root.free()

	# 8b. unchanged owner + troops are not pushed again; a change or a new root pushes again
	adapter.bind_root(fake)
	fake.owner_calls = 0
	adapter.sync_city("hanseong")
	adapter.sync_city("hanseong")
	_expect(fake.owner_calls == 1, "same values twice: set_city_owner called once (%d)" % fake.owner_calls)
	adapter.troops_provider = func(_cid: String) -> int: return 500
	adapter.sync_city("hanseong")
	_expect(fake.owner_calls == 2 and fake.troops.get("hanseong", -1) == 500, "troops value changed: pushed again (%d)" % fake.owner_calls)
	adapter.sync_city("hanseong")
	_expect(fake.owner_calls == 2, "troops unchanged again: not pushed (%d)" % fake.owner_calls)
	fake2.owner_calls = 0
	adapter.bind_root(fake2)
	adapter.sync_city("hanseong")
	_expect(fake2.owner_calls == 1, "bind_root(other root): the same values are pushed again (%d)" % fake2.owner_calls)
	adapter.troops_provider = Callable()
	adapter.bind_root(fake)

	# 10. missing scene file -> safe failure
	var missing := WorldMap3DAdapter.new()
	root.add_child(missing)
	_expect(not missing.create_layer(root, "res://nope/missing.tscn"), "create_layer(missing file) is false")
	_expect(missing.layer == null, "create_layer(missing file) builds no layer")

	# 11. real 3D scene (builds the map once, ~4 s headless)
	var host := Node.new()
	root.add_child(host)
	var real := WorldMap3DAdapter.new()
	root.add_child(real)
	var built := real.create_layer(host)
	await process_frame
	_expect(built, "create_layer(default scene) is true")
	_expect(real.layer != null and real.layer.layer == -10, "layer order is -10")
	_expect(real.layer != null and (real.layer.get_child(0) as Control).mouse_filter == Control.MOUSE_FILTER_IGNORE, "container ignores the mouse")
	_expect(real.get_camera() != null, "real root exposes a camera")
	_expect(real.layer != null and real.layer.visible == false, "layer starts hidden (set_active(false))")

	# 12. cleanup
	for n in [real, host, missing, adapter, fake, fake2, world2d, hanseong, luoyang]:
		n.free()
	_finish()


func _marker(cid: String, faction: String, pos: Vector2) -> FakeMarker:
	var m := FakeMarker.new()
	m.city_id = cid
	m.owner_faction_id = faction
	m.position = pos
	root.add_child(m)
	return m


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[WORLDMAP3D_ADAPTER_FAIL] %s" % label)


func _finish() -> void:
	print("[WORLDMAP3D_ADAPTER] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
