extends "res://tests/scripts/test_battle3d_auto_hold.gd"
# 1x speed, seeds 1-3, until round 3 starts (a full 1x battle exceeds the 120 s CI limit).

func seeds() -> Array:
	return [1, 2, 3]

func speed_presses() -> int:
	return 0

func stop_round() -> int:
	return 3
