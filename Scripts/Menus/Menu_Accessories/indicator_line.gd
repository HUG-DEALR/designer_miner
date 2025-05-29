extends Node2D

@onready var line: Line2D = $Line2D

var end: Node2D = null
var parent: Node2D = null
var offset: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if end != null:
		line.points[1] = to_local(end.global_position + offset)

func set_end_point_nodes(origin_node: Node2D, end_node: Node2D, origin_offset: Vector2 = Vector2.ZERO, end_offset: Vector2 = Vector2.ZERO) -> void:
	if get_parent():
		reparent(origin_node)
	else:
		origin_node.add_child(self)
	parent = origin_node
	global_position = origin_node.global_position + origin_offset
	end = end_node
	offset = end_offset
	line.points[1] = to_local(end.global_position + offset)

func set_colour(colour: Color) -> void:
	line.default_color = colour

func set_type(line_type: String) -> void:
	match line_type:
		"default":
			set_colour(Color(0,0,1,0.5)) # Blue
		"joint_connection":
			set_colour(Color(0,0.8,1,0.5)) # light blue

func auto_self_delete(threshold_length: float = 0.0) -> void:
	while (line.points[1] - line.points[0]).length() > threshold_length:
		await get_tree().process_frame
	queue_free()
