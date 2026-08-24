extends Node

const LEFT_PANEL_PATH := "WorldMapUI/LeftWorldStatusPanel"
const LEFT_CONTENT_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content"
const TURN_END_BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"
const SUMMARY_MARKERS := [
	"내정 적용",
	"무역 수입",
	"무역 수출",
	"시세:",
	"이번 턴",
	"적 전략:",
	"적 전략 행동",
	"도시 충성도",
	"민심 변동",
	"반란",
	"보급",
]

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _left_panel: PanelContainer = null
var _content: VBoxContainer = null
var _turn_end_button: Button = null


func _ready() -> void:
	process_priority = 1000
	set_process(true)
	call_deferred("_install")


func _process(_delta: float) -> void:
	_enforce_lock()
	# Catch deferred UI republishing that happens after normal _process callbacks.
	call_deferred("_enforce_lock")


func _install() -> void:
	if production_world_map == null:
		push_warning("WorldMap Left Panel Lock: ProductionWorldMap is missing.")
		return

	_left_panel = production_world_map.get_node_or_null(LEFT_PANEL_PATH) as PanelContainer
	_content = production_world_map.get_node_or_null(LEFT_CONTENT_PATH) as VBoxContainer
	_turn_end_button = production_world_map.get_node_or_null(TURN_END_BUTTON_PATH) as Button
	if _left_panel == null or _content == null or _turn_end_button == null:
		push_warning("WorldMap Left Panel Lock: required left HUD nodes are missing.")
		return

	_left_panel.clip_contents = true

	if not _content.child_entered_tree.is_connected(_on_content_child_entered):
		_content.child_entered_tree.connect(_on_content_child_entered)
	if not _content.child_order_changed.is_connected(_on_content_child_order_changed):
		_content.child_order_changed.connect(_on_content_child_order_changed)

	_register_existing_children()
	_enforce_lock()


func _register_existing_children() -> void:
	if _content == null:
		return
	for child in _content.get_children():
		_register_child_guard(child)


func _register_child_guard(node: Node) -> void:
	if node == null:
		return
	if node is CanvasItem:
		var item := node as CanvasItem
		if not item.has_meta("worldmap_left_panel_lock_guard"):
			item.set_meta("worldmap_left_panel_lock_guard", true)
			var callback := Callable(self, "_on_guarded_visibility_changed").bind(item)
			if not item.visibility_changed.is_connected(callback):
				item.visibility_changed.connect(callback)
	for child in node.get_children():
		_register_child_guard(child)


func _on_content_child_entered(node: Node) -> void:
	_register_child_guard(node)
	# child_entered_tree fires during insertion, before the next rendered frame.
	call_deferred("_enforce_lock")


func _on_content_child_order_changed() -> void:
	_register_existing_children()
	_enforce_lock()


func _on_guarded_visibility_changed(_item: CanvasItem) -> void:
	_enforce_lock()


func _enforce_lock() -> void:
	if _content == null or _turn_end_button == null:
		return
	if not is_instance_valid(_content) or not is_instance_valid(_turn_end_button):
		return

	var turn_end_index := _turn_end_button.get_index()
	for child in _content.get_children():
		if child == _turn_end_button:
			continue

		var should_hide := child.get_index() > turn_end_index
		if not should_hide:
			should_hide = _subtree_contains_summary_marker(child)
		if should_hide and child is CanvasItem:
			var item := child as CanvasItem
			if item.visible:
				item.visible = false

	# Defensive clip: even if production inserts a transient child between layout
	# passes, nothing outside the current compact panel rect can render.
	if _left_panel != null and is_instance_valid(_left_panel):
		_left_panel.clip_contents = true


func _subtree_contains_summary_marker(node: Node) -> bool:
	var node_text := ""
	if node is Label:
		node_text = (node as Label).text.strip_edges()
	elif node is RichTextLabel:
		node_text = (node as RichTextLabel).get_parsed_text().strip_edges()

	if not node_text.is_empty():
		for marker in SUMMARY_MARKERS:
			if node_text.contains(str(marker)):
				return true

	for child in node.get_children():
		if _subtree_contains_summary_marker(child):
			return true
	return false
