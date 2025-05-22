extends PanelContainer

@onready var button: TextureButton = $TextureButton
@onready var image: TextureRect = $TextureRect
@onready var label: Label = $Label

var item: PackedScene
var item_name: String
var mouse_node: Node2D
var code_running_node: Node2D

func init_item_frame(texture_path: String, item_path: String, name_of_item: String, mouse_follower: Node2D, code_parent: Node2D) -> void:
	image.texture = load(texture_path)
	item_name = name_of_item
	mouse_node = mouse_follower
	code_running_node = code_parent
	label.text = item_name
	label.visible = false
	item = load(item_path)

func _on_texture_button_pressed() -> void:
	if item and not code_running_node.get_carrying_state():
		mouse_node.add_child(item.instantiate())
		code_running_node.set_carrying_state(true)

func _on_texture_button_mouse_entered() -> void:
	label.visible = true

func _on_texture_button_mouse_exited() -> void:
	label.visible = false
