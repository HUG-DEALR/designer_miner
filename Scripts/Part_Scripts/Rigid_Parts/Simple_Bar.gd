extends RigidBody2D

var force_array: Array = []
var moment_array: Array = []
var equiv_simple_force: Vector2 = Vector2.ZERO
var equiv_moment: float = 0.0

func _physics_process(_delta: float) -> void:
	if force_array.size() > 0 or moment_array.size() > 0:
		update_vels()

func update_vels() -> void:
	simplify_forces()
	linear_velocity += equiv_simple_force/mass
	angular_velocity += equiv_moment/inertia

func simplify_forces() -> void:
	equiv_simple_force = Global.convert_to_simple_force(force_array)
	equiv_moment = Global.convert_to_simple_moment(force_array, moment_array)
	force_array.clear()
	moment_array.clear()

func add_force_to_array(force_mag: float, force_direction: Vector2, force_pos: Vector2) -> void:
	force_pos = self.to_local(force_pos)
	force_array.append([force_mag*force_direction.normalized(),force_pos])

func add_moment_to_array(moment: float) -> void:
	moment_array.append(moment)
