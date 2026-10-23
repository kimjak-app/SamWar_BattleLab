extends "res://scripts/battle3d/battle3d_engine_host.gd"
# T3 measurement: the engine host with the observing battle controller.
func create_battle() -> Node:
	var node := super.create_battle()
	node.set_script(load("res://tests/scripts/support/fx_rng_spy_battle.gd"))
	return node
