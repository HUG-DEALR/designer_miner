extends Node2D

@onready var panel_container: PanelContainer = $Control/PanelContainer
@onready var close_button: Button = $Control/PanelContainer/VBoxContainer/HBoxContainer/Close
@onready var drag_button: Button = $Control/PanelContainer/VBoxContainer/HBoxContainer/Drag
@onready var apply_button: Button = $Control/PanelContainer/VBoxContainer/MarginContainer2/GridContainer/Apply
@onready var cancel_button: Button = $Control/PanelContainer/VBoxContainer/MarginContainer2/GridContainer/Cancel
@onready var left_click_line_edit: LineEdit = $Control/PanelContainer/VBoxContainer/MarginContainer/VBox/HBoxContainer2/LineEdit
@onready var right_click_line_edit: LineEdit = $Control/PanelContainer/VBoxContainer/MarginContainer/VBox/HBoxContainer3/LineEdit

var dragging_menu: bool = false
var mouse_offset: Vector2 = Vector2.ZERO
var body_1: RigidBody2D = null
var body_2: RigidBody2D = null
var marker_1: Marker2D = null
var marker_2: Marker2D = null

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
		2:
			marker_2 = marker
	if marker_1 != null and marker_2 != null:
		apply_button.disabled = false

func set_visible_status(state: bool) -> void:
	self.visible = state
	if not state:
		reset_menu()

func reset_menu() -> void:
	left_click_line_edit.text = ""
	right_click_line_edit.text = ""
	body_1 = null
	body_2 = null
	marker_1 = null
	marker_2 = null
	apply_button.disabled = true

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
		Global.create_pin_joint_from_markers(marker_1,marker_2)

func _on_cancel_pressed() -> void:
	reset_menu()
