extends SceneTree
## Approved manual-only close-range fixture. All writes finish before player input.
## Uses the ordinary production 3D scene/host, without the oracle end-path spy.
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	root.size=Vector2i(1280,800)
	var label := "A6b"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--case="): label=arg.trim_prefix("--case=")
	if label not in ["A1","A2_side","A2_back","A3","A4","A6b","A8","A9"]:
		printerr("M2_MANUAL unknown case: ",label)
		quit(1)
		return
	var h=load("res://tests/scripts/support/battle3d_engine_attack_harness.gd").new()
	var lab=load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	root.add_child(lab)
	while not lab.ready_for_input: await process_frame
	h.lab=lab
	await h.setup_case(self,label)
	lab._sync_views()
	h.expect(h.fingerprint.diff(h.point(label,"start"),h.snapshot(lab.engine,"start")).is_empty(),"manual fixture equals existing golden start")
	if not h.failures.is_empty():
		quit(1)
		return
	root.title="EASTWAR | M2 3D ATTACK · "+label+" TEST LAYOUT"
	lab.status.text="검증 배치 "+label+" / 초기 배치만 테스트용 · 이후 모든 행동은 실제 엔진"
	for layer in lab.get_children():
		if layer is CanvasLayer:
			for panel in layer.get_children():
				if panel is PanelContainer:
					for box in panel.get_children():
						for child in box.get_children():
							if child is Label and child.text.begins_with("3D PRESENTATION"):
								child.text="M2 검증 배치 "+label+" · 원본 기본 배치와 다름 · 실제 엔진"
	print("M2_MANUAL READY case=",label," golden_start=true (no scripted player actions)")
	if OS.get_cmdline_user_args().has("--check"):
		var iso=lab.engine.get("_iso_grid_controller")
		lab.free()
		if is_instance_valid(iso) and iso.get_parent()==null: iso.free()
		await process_frame
		quit(0)
