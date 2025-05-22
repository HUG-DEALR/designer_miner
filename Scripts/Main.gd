extends Node2D

@onready var LA = $Linear_Actuator
@onready var SB = $StaticBody2D
@onready var RB = $RigidBody2D

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_1:
					Global.create_pin_joint(LA.get_joint_physics_body(1),SB)
				KEY_2:
					Global.create_pin_joint(LA.get_joint_physics_body(2),RB, LA.get_offset(2))
				KEY_3:
					RB.linear_velocity = Vector2.ZERO
					LA.linear_velocity = Vector2.ZERO
