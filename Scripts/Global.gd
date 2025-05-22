extends Node

func create_pin_joint(moving_node: PhysicsBody2D, parent_node: PhysicsBody2D, offset_m:= Vector2.ZERO, offset_p:= Vector2.ZERO, bias:= 1.0) -> void:
	var new_joint: PinJoint2D = PinJoint2D.new()
	var pre_pos: Vector2 = moving_node.global_position
	parent_node.add_child(new_joint)
	new_joint.global_position = parent_node.global_position + offset_p
	moving_node.global_position = new_joint.global_position - offset_m
	new_joint.node_a = new_joint.get_path_to(moving_node)
	new_joint.node_b = new_joint.get_path_to(parent_node)
	moving_node.global_position = pre_pos
	new_joint.bias = bias

func create_groove_joint(moving_node: PhysicsBody2D, parent_node: PhysicsBody2D, length: float , direction: Vector2 ,offset_m:= Vector2.ZERO, offset_p:= Vector2.ZERO, bias:= 1.0) -> void:
	var new_joint: GrooveJoint2D = GrooveJoint2D.new()
	var pre_pos: Vector2 = moving_node.global_position
	parent_node.add_child(new_joint)
	new_joint.global_position = parent_node.global_position + offset_p
	new_joint.look_at(new_joint.global_position - direction)
	new_joint.length = length
	moving_node.global_position = new_joint.global_position - offset_m
	new_joint.node_a = new_joint.get_path_to(moving_node)
	new_joint.node_b = new_joint.get_path_to(parent_node)
	new_joint.initial_offset = (parent_node.global_position - moving_node.global_position).project(direction).length()
	moving_node.global_position = pre_pos
	new_joint.bias = bias
	# Untested but works in theory

func convert_to_simple_force(force_array: Array) -> Vector2:
	var equiv_simple_force: Vector2 = Vector2.ZERO
	for i in range(force_array.size()):
		equiv_simple_force += force_array[i][0]
	return equiv_simple_force

func convert_to_simple_moment(force_array: Array, moment_array: Array) -> float:
	var equiv_moment: float = 0.0
	for i in range(force_array.size()):
		equiv_moment += force_array[i][0].cross(force_array[i][1])
	for i in range(moment_array.size()):
		equiv_moment += moment_array[i]
	return equiv_moment
