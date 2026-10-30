extends "res://scripts/battle3d/battle3d_scenario_shell.gd"
# Unit3D I4-A2: the scenario shell (start screen, HUD, result overlay) around the 3D lab with unit3d_models on, for
# a look with F6. Only the lab it creates differs: the A scene (Unit3D_LabConnect_Test.tscn). Not a CI test.

func create_lab() -> Node:
	return load("res://tests/scenes/Unit3D_LabConnect_Test.tscn").instantiate()
