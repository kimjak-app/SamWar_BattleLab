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
	func set_city_owner(city_id: String, faction_id: String) -> bool:
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
