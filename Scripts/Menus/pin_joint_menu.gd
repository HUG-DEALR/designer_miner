extends Node2D

@onready var panel_container: PanelContainer = $Control/PanelContainer
@onready var apply_button: Button = $Control/PanelContainer/VBoxContainer/MarginContainer2/GridContainer/Apply
@onready var left_click_line_edit: LineEdit = $Control/PanelContainer/VBoxContainer/MarginContainer/VBox/HBoxContainer2/LineEdit
@onready var right_click_line_edit: LineEdit = $Control/PanelContainer/VBoxContainer/MarginContainer/VBox/HBoxContainer3/LineEdit
@onready var freeze_button: Button = $Control/PanelContainer/VBoxContainer/MarginContainer2/GridContainer/Freeze

var host_menu: Node = null
var dragging_menu: bool = false
var mouse_offset: Vector2 = Vector2.ZERO
var body_1: RigidBody2D = null
var body_2: RigidBody2D = null
var marker_1: Marker2D = null
var marker_2: Marker2D = null
const indicator_line_path: String = "res://Scenes/Menus/Menu_Accessories/indicator_line.tscn"
var indicator_lines: Array[Node2D] = [null, null]

func _process(_delta: float) -> void:
	if dragging_menu:
		global_position = get_viewport().get_mouse_position() + mouse_offset

func set_target_body(body_num: int, body: RigidBody2D) -> void:
	match body_num:
		1:
			body_1 = body
		2:
			body_2 = body

func set_target_marker(body_num: int, marker: Marker2D) -> void:
	match  body_num:
		1:
			marker_1 = marker
		#	left_click_line_edit.text = str(marker.global_position)
			if indicator_lines[0] != null:
				indicator_lines[0].queue_free()
			var new_line = load(indicator_line_path).instantiate()
			new_line.set_end_point_nodes(self,marker,Vector2(300,80)) # This function adds the line to the scene
			indicator_lines[0] = new_line
		2:
			marker_2 = marker
		#	right_click_line_edit.text = str(marker.global_position)
			if indicator_lines[1] != null:
				indicator_lines[1].queue_free()
			var new_line = load(indicator_line_path).instantiate()
			new_line.set_end_point_nodes(self,marker,Vector2(300,120)) # This function adds the line to the scene
			indicator_lines[1] = new_line
	if marker_1 != null and marker_2 != null:
		apply_button.disabled = false

func set_visible_status(state: bool) -> void:
	self.visible = state
	if state:
		if not host_menu.get_build_freeze_state():
			freeze_button.text = "Freeze"
		else:
			freeze_button.text = "Unfreeze"
	else:
		reset_menu()
	if host_menu:
		host_menu.set_submenu_active_state("pin_joint", state)

func reset_menu() -> void:
	left_click_line_edit.text = ""
	right_click_line_edit.text = ""
	body_1 = null
	body_2 = null
	marker_1 = null
	marker_2 = null
	apply_button.disabled = true
	for line in indicator_lines:
		if line != null:
			line.queue_free()
	indicator_lines.fill(null)

func set_host(node: Node) -> void:
	host_menu = node

# Signal functions
func _on_close_pressed() -> void:
	set_visible_status(false)

func _on_drag_button_down() -> void:
	mouse_offset = global_position - get_viewport().get_mouse_position()
	dragging_menu = true

func _on_drag_button_up() -> void:
	dragging_menu = false
	global_position += Global.get_offset_to_be_fully_visible(panel_container)

func _on_apply_pressed() -> void:
	if marker_1 != null and marker_2 != null:
		if Global.create_pin_joint_from_markers(marker_1,marker_2):
			var new_line = load(indicator_line_path).instantiate()
			new_line.set_end_point_nodes(marker_1,marker_2)
			new_line.set_type("joint_connection")
			new_line.auto_self_delete(5.0)
		reset_menu()

func _on_cancel_pressed() -> void:
	reset_menu()

func _on_freeze_pressed() -> void:
	var current_state: bool = host_menu.get_build_freeze_state()
	host_menu.set_build_freeze(!current_state)
	if current_state:
		freeze_button.text = "Freeze"
	else:
		freeze_button.text = "Unfreeze"
