extends Node

var pin_joints: Array = [] # Fromat: [[Joint, [Node_A, Node_B]],[...
var groove_joints: Array = [] # Fromat: [[Joint, [Node_A, Node_B]],[...
var spring_joints: Array = [] # Fromat: [[Joint, [Node_A, Node_B]],[...

func create_pin_joint(moving_node: PhysicsBody2D, parent_node: PhysicsBody2D, offset_m:= Vector2.ZERO, offset_p:= Vector2.ZERO, offset_is_local:= true, bias:= 1.0) -> bool:
	if not is_joint_valid("PinJoint2D", moving_node, parent_node):
		return false
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
	pin_joints.append([new_joint,[moving_node,parent_node]])
	return true

func create_groove_joint(moving_node: PhysicsBody2D, parent_node: PhysicsBody2D, length: float , direction: Vector2 ,offset_m:= Vector2.ZERO, offset_p:= Vector2.ZERO, bias:= 1.0) -> bool:
	if not is_joint_valid("GrooveJoint2D", moving_node, parent_node):
		return false
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
	return true
	# Untested but works in theory

func create_pin_joint_from_markers(marker1: Marker2D, marker2: Marker2D, bias:= 1.0) -> bool:
	var rigid_body_1: RigidBody2D = get_predecessor_by_type(marker1, "RigidBody2D")
	var rigid_body_2: RigidBody2D = get_predecessor_by_type(marker2, "RigidBody2D")
	if rigid_body_1 and rigid_body_2:
		return create_pin_joint(rigid_body_1,rigid_body_2,marker1.global_position,marker2.global_position,false,bias)
	else:
		print("Failed to find RigidBody parents of Markers")
		return false

func build_plate_cleared() -> void:
	pin_joints.clear()
	groove_joints.clear()
	spring_joints.clear()

func is_joint_valid(joint_type: String, node_a: RigidBody2D, node_b: RigidBody2D) -> bool:
	if (not node_a is RigidBody2D) or (not node_b is RigidBody2D):
		print("invalid joint, constituent part(s) not RigidBody2D")
		return false
	if node_a == node_b:
		print("invalid joint; cannot join ", node_a, " to itself")
		return false
	match joint_type:
		"PinJoint2D":
		#	if array_has_at_depth(pin_joints,[node_a,node_b],1) or array_has_at_depth(pin_joints,[node_b,node_a],1):
			if check_array_for_joint_bodies(pin_joints,node_a,node_b):
				print("invalid joint; duplicate")
				return false
		"GrooveJoint2D":
		#	if array_has_at_depth(groove_joints,[node_a,node_b],1) or array_has_at_depth(groove_joints,[node_b,node_a],1):
			if check_array_for_joint_bodies(groove_joints,node_a,node_b):
				print("invalid joint; duplicate")
				return false
		"DampedSpringJoint2D":
		#	if array_has_at_depth(spring_joints,[node_a,node_b],1) or array_has_at_depth(spring_joints,[node_b,node_a],1):
			if check_array_for_joint_bodies(spring_joints,node_a,node_b):
				print("invalid joint; duplicate")
				return false
		_:
			print("unrecognised joint type in is_joint_valid call")
			return false
	return true

func check_array_for_joint_bodies(array: Array, node_a: RigidBody2D, node_b: RigidBody2D) -> bool:
	for joint in array:
		if joint[1].has(node_a) and joint[1].has(node_b):
			return true
	return false

func array_has_at_depth(nested_array: Array, value, target_depth: int = 0) -> bool:
	return _has_at_specific_depth(nested_array, value, target_depth, 0)
# These two functions are necessarily corelated
func _has_at_specific_depth(arr: Array, value, target_depth: int, current_depth: int) -> bool:
	if current_depth == target_depth:
		for element in arr:
			if element == value:
				return true
	else:
		for element in arr:
			if element is Array:
				if _has_at_specific_depth(element, value, target_depth, current_depth + 1):
					return true
	return false

func get_predecessor_by_type(starting_node: Node, type: String) -> Node:
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

func get_offset_to_be_fully_visible(control: Control) -> Vector2:
	var rect: Rect2 = control.get_global_rect()
	var viewport_size: Vector2 = control.get_viewport_rect().size
	var offset: Vector2 = Vector2.ZERO
	# Check left and top overflow (negative position)
	if rect.position.x < 0:
		offset.x = -rect.position.x
	elif rect.position.x + rect.size.x > viewport_size.x:
		offset.x = viewport_size.x - (rect.position.x + rect.size.x)
	if rect.position.y < 0:
		offset.y = -rect.position.y
	elif rect.position.y + rect.size.y > viewport_size.y:
		offset.y = viewport_size.y - (rect.position.y + rect.size.y)
	return offset

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
