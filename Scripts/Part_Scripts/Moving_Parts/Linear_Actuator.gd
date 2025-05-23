extends RigidBody2D

@onready var base_circle: CollisionShape2D = $Base_Circle
@onready var pin_circle: CollisionShape2D = $Pin/Pin_Circle
@onready var base_rigid_body: RigidBody2D = self
@onready var pin_rigid_body: RigidBody2D = $Pin
@onready var groove_1: GrooveJoint2D = $GrooveJoint2D1
@onready var groove_2: GrooveJoint2D = $GrooveJoint2D2

var base_touching_mouse: bool = false
var pin_touching_mouse: bool = false
var selected: bool = false

func _ready() -> void:
	groove_1.bias = 1.0
	groove_2.bias = 1.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if base_touching_mouse or pin_touching_mouse:
			if selected:
				selected = false
			else:
				selected = true

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

func set_freeze(state: bool, pass_to_chilldren: bool = true) -> void:
	freeze = state
	if pass_to_chilldren:
		for child in Global.get_all_descendants(self):
			if child is RigidBody2D:
				child.freeze = state

func _on_mouse_entered_base() -> void:
	base_touching_mouse = true

func _on_mouse_exited_base() -> void:
	base_touching_mouse = false

func _on_mouse_entered_pin() -> void:
	pin_touching_mouse = true

func _on_mouse_exited_pin() -> void:
	pin_touching_mouse = false
