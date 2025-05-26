extends Node2D

@onready var parent: Node2D = self.get_parent()
@onready var sprite: Sprite2D = null

func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			sprite = child
			break

func set_select_state(state: bool) -> Sprite2D:
	if sprite != null:
		return sprite
	else:
		return parent.set_select_state(state)

func get_joint_positions() -> Array:
	return parent.get_joint_positions()
