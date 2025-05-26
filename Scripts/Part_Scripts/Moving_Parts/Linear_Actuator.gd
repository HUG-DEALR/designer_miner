extends RigidBody2D

@onready var base_circle: CollisionShape2D = $Base_Circle
@onready var pin_circle: CollisionShape2D = $Pin/Pin_Circle
@onready var base_rigid_body: RigidBody2D = self
@onready var pin_rigid_body: RigidBody2D = $Pin
@onready var groove_1: GrooveJoint2D = $GrooveJoint2D1
@onready var groove_2: GrooveJoint2D = $GrooveJoint2D2
@onready var base_sprite: Sprite2D = $Base
@onready var pin_sprite: Sprite2D = $Pin/Pin
@onready var joint_1: Marker2D = $Base_Circle/Marker2D
@onready var joint_2: Marker2D = $Pin/Pin_Circle/Marker2D

var base_touching_mouse: bool = false
var pin_touching_mouse: bool = false
var selected: bool = false

func _ready() -> void:
	groove_1.bias = 1.0
	groove_2.bias = 1.0

func set_select_state(state: bool) -> Sprite2D:
	selected = state
	if pin_touching_mouse:
		return pin_sprite
	else:
		return base_sprite

func get_offset(joint_number: int) -> Vector2:
	match  joint_number:
		1:
			return Vector2.ZERO
		2:
			return Vector2(87,0).rotated(pin_rigid_body.global_rotation)
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

func get_joint_positions() -> Array:
	return [get_offset(1), get_offset(2)]

func set_freeze(state: bool, pass_to_chilldren: bool = true) -> void:
	freeze = state
	if pass_to_chilldren:
		for child in Global.get_all_descendants(self):
			if child is RigidBody2D:
				child.freeze = state

func get_joints() -> Array:
	return [joint_1, joint_2]
