extends Node

func create_pin_joint(moving_node: PhysicsBody2D, parent_node: PhysicsBody2D, offset_m:= Vector2.ZERO, offset_p:= Vector2.ZERO, offset_is_local:= true, bias:= 1.0) -> void:
	var new_joint: PinJoint2D = PinJoint2D.new()
	var pre_pos: Vector2 = moving_node.global_position
	parent_node.add_child(new_joint)
	if not offset_is_local: # Convert global offsets to local offsets
		offset_p = offset_p - parent_node.global_position
		offset_m = offset_m - moving_node.global_position
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

func create_pin_joint_from_markers(marker1: Marker2D, marker2: Marker2D, bias:= 1.0) -> void:
	var rigid_body_1: RigidBody2D = get_predecessor_by_type(marker1, RigidBody2D)
	var rigid_body_2: RigidBody2D = get_predecessor_by_type(marker2, RigidBody2D)
	if rigid_body_1 and rigid_body_2:
		create_pin_joint(rigid_body_1,rigid_body_2,marker1.global_position,marker2.global_position,false,bias)
	else:
		print("Failed to find RigidBody parents of Markers")

func get_predecessor_by_type(starting_node: Node, type) -> Node:
	var target_predecessor: Node = starting_node.get_parent()
	while not target_predecessor.get_class() == type:
		if target_predecessor.get_parent():
			target_predecessor = target_predecessor.get_parent()
		else:
			return
	return target_predecessor

func get_all_descendants(node: Node) -> Array:
	var descendants: Array = []
	for child in node.get_children():
		descendants.append(child)
		descendants += get_all_descendants(child)
	return descendants

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
