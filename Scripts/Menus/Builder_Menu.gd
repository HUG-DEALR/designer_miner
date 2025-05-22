extends Node2D

@onready var item_grid: GridContainer = $CanvasLayer/Control/PanelContainer/VBoxContainer/PanelContainer/ScrollContainer/MarginContainer/GridContainer
@onready var mouse_follower: Node2D = $CanvasLayer/Mouse_Follower
@onready var build_plate_node: Node2D = $CanvasLayer/Control2/ScrollContainer/PanelContainer/Build_Plate
@onready var build_panel: PanelContainer = $CanvasLayer/Control2/ScrollContainer/PanelContainer

const item_frame_path: String = "res://Scenes/Menus/item_frame.tscn"
const parts_dict: Dictionary = {
	"Linear Actuator": "res://Scenes/Parts/Moving_Parts/linear_actuator.tscn",
	"Simple Bar": "res://Scenes/Parts/Rigid_Parts/simple_bar.tscn"
}
const parts_thumbnail_dict: Dictionary = { # Keys must match parts_dict
	"Linear Actuator": "res://Sprites/Parts/Moving_Parts/Linear_Actuator_1_Base.png",
	"Simple Bar": "res://Sprites/Parts/Rigid_Parts/Simple_Bar.png"
}

var mouse_carrying_a_part: bool = false
var mouse_over_buildplate: bool = false
var part_being_carried: Node2D
var item_frames: Dictionary = {}

func _ready() -> void:
	init_items()

func _process(_delta: float) -> void:
	if mouse_carrying_a_part:
		mouse_follower.position = get_viewport().get_mouse_position()
		part_being_carried.position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if mouse_carrying_a_part:
			if mouse_over_buildplate:
				part_being_carried.reparent(build_plate_node)
				part_being_carried = null
				mouse_carrying_a_part = false
			else:
				for node in mouse_follower.get_children():
					node.queue_free()
				part_being_carried = null
				mouse_carrying_a_part = false

func set_carrying_state(state: bool) -> void:
	mouse_carrying_a_part = state
	if mouse_follower.get_child(-1):
		part_being_carried = mouse_follower.get_child(-1)

func get_carrying_state() -> bool:
	return mouse_carrying_a_part

func init_items() -> void:
	if item_frames.size() > 0:
		for key in item_frames:
			item_frames[key].queue_free()
		item_frames.clear()
	for key in parts_dict:
		var new_item_frame = load(item_frame_path).instantiate()
		item_grid.add_child(new_item_frame)
		item_frames[key] = new_item_frame
		new_item_frame.init_item_frame(parts_thumbnail_dict[key], parts_dict[key], key, mouse_follower, self)

func _on_build_plate_mouse_entered() -> void:
	mouse_over_buildplate = true

func _on_build_plate_mouse_exited() -> void:
	mouse_over_buildplate = false
