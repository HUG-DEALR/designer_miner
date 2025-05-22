extends Node2D

@onready var item_grid: GridContainer = $CanvasLayer/Control/PanelContainer/VBoxContainer/PanelContainer/ScrollContainer/MarginContainer/GridContainer
@onready var mouse_follower: Node2D = $Mouse_Follower

const item_frame_path: String = "res://Scenes/Menus/item_frame.tscn"
const parts_dict: Dictionary = {
	"Linear Actuator": "res://Scenes/Parts/Moving_Parts/linear_actuator.tscn"
}
const parts_thumbnail_dict: Dictionary = { # Keys must match parts_dict
	"Linear Actuator": "res://Sprites/Parts/Moving_Parts/Linear_Actuator_1_Base.png"
}

var mouse_carrying_a_part: bool = false

func _ready() -> void:
	for key in parts_dict:
		var new_item_frame = load(item_frame_path).instantiate()
		item_grid.add_child(new_item_frame)
		new_item_frame.init_item_frame(parts_thumbnail_dict[key], parts_dict[key], key, mouse_follower, self)

func _process(_delta: float) -> void:
	if mouse_carrying_a_part:
		mouse_follower.position = get_viewport().get_mouse_position()

func set_carrying_state(state: bool) -> void:
	mouse_carrying_a_part = state
