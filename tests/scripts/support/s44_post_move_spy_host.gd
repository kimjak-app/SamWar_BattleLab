extends "res://scripts/battle3d/battle3d_engine_host.gd"
# N2 measurement: the engine host with the observing battle controller.
func create_battle() -> Node:
	var node := super.create_battle()
	node.set_script(load("res://tests/scripts/support/s44_post_move_spy_battle.gd"))
	return node
