extends RefCounted
# T2 split: the regression tests' world. Their expectations (goldens, round counts, the 3D == engine-alone runs) were
# recorded before any grove was blocked and last passed with the C1 groves (5a51e53); the presentation default in
# terrain_types.json (C4b) stands on the enemies' route and changes those battles. So the harnesses freeze the grove
# placement at C1: lab() writes C1 into a lab's board after it is instantiated and before it enters the tree (the board
# is made at instantiate; _ready builds the trees and hands the engine its blocked cells from it), and freeze() does the
# same for the engine-alone reference's board. Trees and blocked cells keep one source, the board. Ground heights and
# every other cell are untouched. Tests that check the presentation default itself opt out (scenario harness).
const Groves = preload("res://tests/scripts/support/battle3d_t2_groves.gd")
const GROVES := "C1"

static func freeze(board) -> void:
	Groves.apply(board, GROVES)

static func lab(node: Node) -> Node:
	freeze(node.board)
	return node
