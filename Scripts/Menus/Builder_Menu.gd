extends Node2D

@onready var item_grid: GridContainer = $CanvasLayer/Control/HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/ScrollContainer/MarginContainer/GridContainer
@onready var mouse_follower: Node2D = $CanvasLayer/Mouse_Follower
@onready var build_plate_node: Node2D = $CanvasLayer/Control/HBoxContainer/ScrollContainer/PanelContainer/Build_Plate
@onready var build_panel: PanelContainer = $CanvasLayer/Control/HBoxContainer/ScrollContainer/PanelContainer
@onready var build_scroll_container: ScrollContainer = $CanvasLayer/Control/HBoxContainer/ScrollContainer
@onready var highlight: Sprite2D = $CanvasLayer/Highlighter
@onready var mouse_ray: RayCast2D = $CanvasLayer/Mouse_Ray
@onready var left_click_selection_line: LineEdit = $CanvasLayer/Control/HBoxContainer/PanelContainer/VBoxContainer/TabContainer/Join/VBox/HBoxContainer2/LineEdit
@onready var right_click_selection_line: LineEdit = $CanvasLayer/Control/HBoxContainer/PanelContainer/VBoxContainer/TabContainer/Join/VBox/HBoxContainer3/LineEdit
@onready var freeze_button: Button = $CanvasLayer/Control/HBoxContainer/PanelContainer/VBoxContainer/GridContainer/Freeze

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
var part_being_carried: Node2D = null
var item_frames: Dictionary = {}
var selected_body: PhysicsBody2D = null
const joint_indicator_path: String = "res://Scenes/Menus/joint_indicator.tscn"
var active_indicators: Array = []
var selected_joint_1: Node2D = null
var selected_joint_1_joint_num: int = 0
var joint_1_pos: Vector2 = Vector2.ZERO
var selected_joint_2: Node2D = null
var selected_joint_2_joint_num: int = 0
var joint_2_pos: Vector2 = Vector2.ZERO
var build_frozen: bool = true

func _ready() -> void:
	init_items()
	build_plate_node.position = build_panel.size/2
	await get_tree().process_frame
	center_build_plate()

func _process(_delta: float) -> void:
	if mouse_carrying_a_part:
		mouse_follower.position = get_viewport().get_mouse_position()
		part_being_carried.position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if mouse_carrying_a_part:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if mouse_over_buildplate:
						part_being_carried.reparent(build_plate_node)
						mouse_carrying_a_part = false
						if build_plate_node.get_child_count() == 1: #Center first part
							part_being_carried.position = Vector2.ZERO
						part_being_carried = null
					else:
						for node in mouse_follower.get_children():
							node.queue_free()
						part_being_carried = null
						mouse_carrying_a_part = false
					mouse_follower.rotation = 0.0
				MOUSE_BUTTON_WHEEL_UP:
					mouse_follower.rotate(deg_to_rad(15))
				MOUSE_BUTTON_WHEEL_DOWN:
					mouse_follower.rotate(deg_to_rad(-15))
		else:
			mouse_ray.global_position = get_viewport().get_mouse_position()
			mouse_ray.force_raycast_update()
			
			for node in active_indicators:
				if node:
					node.queue_free()
			active_indicators.clear()
			
			if mouse_ray.is_colliding():
				selected_body = mouse_ray.get_collider()
				var selected_sprite: Sprite2D = selected_body.set_select_state(true)
				highlight.texture = selected_sprite.texture
				highlight.global_transform = selected_sprite.global_transform
				
			#	var joint_positions: Array = selected_body.get_joint_positions()
				var nearest_joint: Node2D = null
				var nearest_joint_distance: float = INF
			#	var joint_num: int = 0
			#	
			#	for pos in joint_positions:
			#		var new_indicator: Node2D = load(joint_indicator_path).instantiate()
			#		selected_body.add_child(new_indicator)
			#		new_indicator.position = pos
			#		new_indicator.z_index = 101
			#		active_indicators.append(new_indicator)
			#		
			#		var indicator_distance: float = (get_viewport().get_mouse_position() - selected_body.to_global(pos)).length()
			#		if indicator_distance < nearest_joint_distance:
			#			nearest_joint = new_indicator
			#			nearest_joint_distance = indicator_distance
			#			joint_num = joint_positions.find(pos) + 1
			#	if nearest_joint != null:
			#		nearest_joint.set_type("selected")
				
				var joints: Array = selected_body.get_joints()
				for joint in joints:
					var joint_pos: Vector2 = joint.global_position
					var new_indicator: Node2D = load(joint_indicator_path).instantiate()
					selected_body.add_child(new_indicator)
					new_indicator.global_position = joint_pos
					new_indicator.z_index = 101
					active_indicators.append(new_indicator)
					
					var indicator_distance: float = (get_viewport().get_mouse_position() - joint_pos).length()
					if indicator_distance < nearest_joint_distance:
						nearest_joint = new_indicator
						nearest_joint_distance = indicator_distance
				if nearest_joint != null:
					nearest_joint.set_type("selected")
				
				match event.button_index:
					MOUSE_BUTTON_LEFT:
			#			left_click_selection_line.text = nearest_joint.name
						selected_joint_1 = selected_body
						joint_1_pos = nearest_joint.global_position
						left_click_selection_line.text = str(joint_1_pos)
			#			selected_joint_1_joint_num = joint_num
					MOUSE_BUTTON_RIGHT:
			#			right_click_selection_line.text = nearest_joint.name
						selected_joint_2 = selected_body
						joint_2_pos = nearest_joint.global_position
						right_click_selection_line.text = str(joint_2_pos)
			#			selected_joint_2_joint_num = joint_num
			else:
				if selected_body:
					selected_body.set_select_state(false)
					selected_body = null
					highlight.texture = null

func set_carrying_state(state: bool) -> void:
	mouse_carrying_a_part = state
	if mouse_follower.get_child(-1):
		part_being_carried = mouse_follower.get_child(-1)
		
		set_freeze(part_being_carried, true)

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

func center_build_plate() -> void:
	build_scroll_container.scroll_horizontal = max(0,(build_panel.size.x - build_scroll_container.size.x)/2.0)
	build_scroll_container.scroll_vertical = max(0,(build_panel.size.y - build_scroll_container.size.y)/2.0)

func clear_build_plate() -> void:
	for node in build_plate_node.get_children():
		node.queue_free()
	left_click_selection_line.text = ""
	right_click_selection_line.text = ""
	selected_body = null
	highlight.texture = null
	for node in active_indicators:
		if node:
			node.queue_free()
	active_indicators.clear()
	selected_joint_1 = null
	selected_joint_2 = null
	selected_joint_1_joint_num = 0
	selected_joint_2_joint_num = 0

func set_freeze(node: RigidBody2D, state: bool) -> void:
	if node.is_in_group("multibody_part"):
		node.set_freeze(state)
	else:
		node.freeze = state

func set_build_freeze(state: bool) -> void:
	for node in build_plate_node.get_children():
		if node.get_index() != 0:
			set_freeze(node, state)

func _on_build_plate_mouse_entered() -> void:
	mouse_over_buildplate = true

func _on_build_plate_mouse_exited() -> void:
	mouse_over_buildplate = false

func _on_recenter_pressed() -> void:
	center_build_plate()

func _on_clear_pressed() -> void:
	clear_build_plate()

func _on_create_pin_joint_pressed() -> void:
	if selected_joint_1 is RigidBody2D and selected_joint_2 is RigidBody2D:
	#	Global.create_pin_joint(selected_joint_1, selected_joint_2, selected_joint_1.get_offset(selected_joint_1_joint_num), selected_joint_2.get_offset(selected_joint_2_joint_num))
		Global.create_pin_joint(selected_joint_1, selected_joint_2, joint_1_pos, joint_2_pos, false)
	#	if selected_joint_1.get_index() > selected_joint_2.get_index():
	#		set_freeze(selected_joint_1, false)
	#		await get_tree().create_timer(1.0).timeout
	#		set_freeze(selected_joint_1, true)
	#	else:
	#		set_freeze(selected_joint_2, false)
	#		await get_tree().create_timer(1.0).timeout
	#		set_freeze(selected_joint_2, true)

func _on_freeze_pressed() -> void:
	build_frozen = !build_frozen
	set_build_freeze(build_frozen)
	if build_frozen:
		freeze_button.text = "Unfreeze"
	else:
		freeze_button.text = "Freeze"
