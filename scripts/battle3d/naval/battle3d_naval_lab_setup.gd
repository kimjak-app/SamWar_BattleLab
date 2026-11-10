extends RefCounted
# Queue 35: what a naval scenario changes on a freshly created 3D lab, before it enters the tree (called by the scenario
# shell only for a naval scenario). The sea builder in place of the land ground, ships in place of soldiers, and one
# child node for the title and the F9 capture. The lab's own code runs unchanged on these.
const SEA_BUILDER := "res://scripts/battle3d/naval/naval_sea_builder.gd"
const SHIP_VISUALS := "res://scripts/battle3d/naval/battle3d_ship_visuals.gd"
const Overlay := preload("res://scripts/battle3d/naval/battle3d_naval_overlay.gd")

static func apply(shell: Node, lab: Node, scenario: Dictionary) -> void:
	lab.field_script = SEA_BUILDER
	lab.unit_visuals_script = SHIP_VISUALS
	var overlay := Overlay.new()
	overlay.name = "NavalOverlay"
	overlay.title = String(scenario.get("title", ""))
	overlay.shell = shell
	lab.add_child(overlay) # freed with the lab
