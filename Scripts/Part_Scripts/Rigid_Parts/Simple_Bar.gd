extends RigidBody2D

var touching_mouse: bool = false
var selected: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if touching_mouse:
			if selected:
				selected = false
			else:
				selected = true

func get_offset(join_number: int) -> Vector2:
	match  join_number:
		1:
			return Vector2(0,56).rotated(global_rotation)
		2:
			return Vector2(0,-56).rotated(global_rotation)
		_:
			return Vector2.ZERO

func _on_mouse_entered() -> void:
	touching_mouse = true

func _on_mouse_exited() -> void:
	touching_mouse = false
