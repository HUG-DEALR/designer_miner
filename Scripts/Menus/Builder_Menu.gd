extends Node2D

@onready var item_grid: GridContainer = $CanvasLayer/Control/HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/ScrollContainer/MarginContainer/GridContainer
@onready var mouse_follower: Node2D = $CanvasLayer/Mouse_Follower
@onready var build_plate_node: Node2D = $CanvasLayer/Control/HBoxContainer/ScrollContainer/PanelContainer/Build_Plate
@onready var build_panel: PanelContainer = $CanvasLayer/Control/HBoxContainer/ScrollContainer/PanelContainer
@onready var build_scroll_container: ScrollContainer = $CanvasLayer/Control/HBoxContainer/ScrollContainer
@onready var highlight: Sprite2D = $CanvasLayer/Highlighter
@onready var mouse_ray: RayCast2D = $CanvasLayer/Mouse_Ray
@onready var file_dropdown: MenuButton = $CanvasLayer/Top_Bar/HSplitContainer/ScrollContainer/PanelContainer/HBoxContainer/File
@onready var settings_dropdown: MenuButton = $CanvasLayer/Top_Bar/HSplitContainer/ScrollContainer/PanelContainer/HBoxContainer/Settings
@onready var plate_actions_dropdown: MenuButton = $CanvasLayer/Top_Bar/HSplitContainer/ScrollContainer/PanelContainer/HBoxContainer/Plate_Actions
@onready var create_joint_dropdown: MenuButton = $CanvasLayer/Top_Bar/HSplitContainer/ScrollContainer/PanelContainer/HBoxContainer/Create_Joint

# Submenus and corresponding variabls
@onready var pin_joint_menu: Node2D = $CanvasLayer/Pin_Joint_Menu
var pin_joint_submenu_active: bool = false

# Item variables
const item_frame_path: String = "res://Scenes/Menus/Menu_Accessories/item_frame.tscn"
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
const joint_indicator_path: String = "res://Scenes/Menus/Menu_Accessories/joint_indicator.tscn"
var active_indicators: Array = []
var build_frozen: bool = true
var build_scale: float = 1.0
var default_panel_size: Vector2i = Vector2i.ZERO
var dragging_build_plate: bool = false
var mouse_movement: Vector2 = Vector2.ZERO
var _last_mouse_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	init_items()
	build_plate_node.position = build_panel.size/2
	await get_tree().process_frame
	center_build_plate()
	default_panel_size = build_panel.size
	_last_mouse_position = get_viewport().get_mouse_position()
	file_dropdown.get_popup().connect("id_pressed", Callable(self, "_on_file_subbutton_pressed"))
	settings_dropdown.get_popup().connect("id_pressed", Callable(self, "_on_settings_subbutton_pressed"))
	plate_actions_dropdown.get_popup().connect("id_pressed", Callable(self, "_on_plate_actions_subbutton_pressed"))
	create_joint_dropdown.get_popup().connect("id_pressed", Callable(self, "_on_create_joint_dropdown_subbutton_pressed"))
	pin_joint_menu.set_host(self)

func _process(_delta: float) -> void:
	if mouse_carrying_a_part:
		mouse_follower.position = get_viewport().get_mouse_position()
		part_being_carried.position = Vector2.ZERO
	
	var current_mouse_position = get_viewport().get_mouse_position()
	mouse_movement = current_mouse_position - _last_mouse_position
	_last_mouse_position = current_mouse_position
	if dragging_build_plate:
		build_scroll_container.scroll_horizontal += int(-mouse_movement.x)
		build_scroll_container.scroll_vertical += int(-mouse_movement.y)

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
				
				var nearest_joint: Node2D = null
				var nearest_joint_distance: float = INF
				var selected_marker: Marker2D = null
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
						selected_marker = joint
				if nearest_joint != null:
					nearest_joint.set_type("selected")
				
				match event.button_index:
					MOUSE_BUTTON_LEFT:
						if pin_joint_submenu_active and selected_marker:
							pin_joint_menu.set_target_marker(1,selected_marker)
					MOUSE_BUTTON_RIGHT:
						if pin_joint_submenu_active and selected_marker:
							pin_joint_menu.set_target_marker(2,selected_marker)
			else:
				if selected_body:
					selected_body.set_select_state(false)
					selected_body = null
					highlight.texture = null
				
				if mouse_over_buildplate and not dragging_build_plate:
					dragging_build_plate = true
	elif event is InputEventMouseButton and not event.pressed:
		dragging_build_plate = false
#	if event is InputEventMouseMotion:
#		mouse_movement = event.relative
#	else:
#		print("movement is 0")
#		mouse_movement = Vector2.ZERO

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
	selected_body = null
	highlight.texture = null
	for node in active_indicators:
		if node:
			node.queue_free()
	active_indicators.clear()
	pin_joint_menu.reset_menu()
	Global.build_plate_cleared()

func set_submenu_active_state(submenu: String, state: bool) -> void:
	match submenu:
		"pin_joint":
			pin_joint_submenu_active = state

func set_freeze(node: RigidBody2D, state: bool) -> void:
	if node.is_in_group("multibody_part"):
		node.set_freeze(state)
	else:
		node.freeze = state

func set_build_freeze(state: bool) -> void:
	build_frozen = state
	for node in build_plate_node.get_children():
		if node.get_index() != 0:
			set_freeze(node, state)

func get_build_freeze_state() -> bool:
	return build_frozen

func set_build_scale(target_scale: float = 1.0) -> void:
	build_scale = clamp(target_scale,0.01,20.0)
	build_plate_node.scale = Vector2.ONE * build_scale
	build_panel.custom_minimum_size = default_panel_size * build_scale
	# WIP

func _on_build_plate_mouse_entered() -> void:
	mouse_over_buildplate = true

func _on_build_plate_mouse_exited() -> void:
	mouse_over_buildplate = false

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_file_subbutton_pressed(id: int) -> void: #Manually Connected
	var sub_button_chosen: String = file_dropdown.get_popup().get_item_text(id)
	match sub_button_chosen:
		"Save":
			pass
		"Load":
			pass
		"Clear":
			clear_build_plate()

func _on_settings_subbutton_pressed(id: int) -> void: #Manually Connected
	var sub_button_chosen: String = settings_dropdown.get_popup().get_item_text(id)
	match sub_button_chosen:
		"WIP":
			pass

func _on_plate_actions_subbutton_pressed(id: int) -> void: #Manually Connected
	var sub_button_chosen: String = plate_actions_dropdown.get_popup().get_item_text(id)
	match sub_button_chosen:
		"Recenter Build Plate":
			center_build_plate()
		"Default Zoom":
			set_build_scale(1.0)
			pass
		"Zoom In":
			set_build_scale(build_scale * 1.5)
			pass
		"Zoom Out":
			set_build_scale(build_scale * 0.5)
			pass
		"Freeze All Parts":
			set_build_freeze(true)
		"Unfreeze All Parts":
			set_build_freeze(false)

func _on_create_joint_dropdown_subbutton_pressed(id: int) -> void: #Manually Connected
	var sub_button_chosen: String = create_joint_dropdown.get_popup().get_item_text(id)
	match sub_button_chosen:
		"Rotary Joint":
			pin_joint_menu.set_visible_status(true)
		"Slider Joint":
			pin_joint_menu.set_visible_status(false)
		"Spring Joint":
			pin_joint_menu.set_visible_status(false)
