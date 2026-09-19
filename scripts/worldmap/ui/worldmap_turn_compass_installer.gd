class_name WorldMapTurnCompassInstaller
extends Node

const TURN_COMPASS_SCRIPT := preload("res://scripts/worldmap/worldmap_turn_compass.gd")

@onready var world_map: Node = get_parent()


func _ready() -> void:
	call_deferred("_install")


func _install() -> void:
	if world_map == null:
		return
	var world_ui := world_map.get_node_or_null("WorldMapUI") as CanvasLayer
	if world_ui == null:
		push_warning("WorldMap Turn Compass Installer: WorldMapUI is missing.")
		return
	var compass := world_ui.get_node_or_null("TurnEndCompass") as Control
	if compass == null:
		compass = TURN_COMPASS_SCRIPT.new() as Control
		if compass == null:
			push_warning("WorldMap Turn Compass Installer: failed to instantiate compass.")
			return
		compass.name = "TurnEndCompass"
		world_ui.add_child(compass)
	if compass.has_method("bind_world_scene"):
		compass.call("bind_world_scene", world_map)
