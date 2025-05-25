extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D

var selected: bool = false

func set_select_state(state: bool) -> Sprite2D:
	selected = state
	return sprite

func get_offset(join_number: int) -> Vector2:
	match  join_number:
		1:
			return Vector2(0,56).rotated(global_rotation)
		2:
			return Vector2(0,-56).rotated(global_rotation)
		_:
			return Vector2.ZERO
