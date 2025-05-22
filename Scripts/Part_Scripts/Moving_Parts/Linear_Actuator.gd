extends RigidBody2D

@onready var base_circle: CollisionShape2D = $Base_Circle
@onready var pin_circle: CollisionShape2D = $Pin/Pin_Circle
@onready var base_rigid_body: RigidBody2D = self
@onready var pin_rigid_body: RigidBody2D = $Pin
@onready var groove_1: GrooveJoint2D = $GrooveJoint2D1
@onready var groove_2: GrooveJoint2D = $GrooveJoint2D2

func _ready() -> void:
	groove_1.bias = 1.0
	groove_2.bias = 1.0

func get_offset(join_number: int) -> Vector2:
	match  join_number:
		1:
			return Vector2.ZERO
		2:
			return Vector2(0,-87).rotated(pin_rigid_body.global_rotation)
		_:
			return Vector2.ZERO

func get_joint_physics_body(joint_number: int) -> PhysicsBody2D:
	match joint_number:
		1:
			return base_rigid_body
		2:
			return pin_rigid_body
		_:
			return base_rigid_body
