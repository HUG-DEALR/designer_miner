extends Node2D

@onready var line: Line2D = $Line2D

var end: Node2D = null
var parent: Node2D = null
var offset: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if end != null:
		line.points = [Vector2.ZERO, end.global_position + offset - global_position]

func set_end_point_nodes(origin_node: Node2D, end_node: Node2D, origin_offset: Vector2 = Vector2.ZERO, end_offset: Vector2 = Vector2.ZERO) -> void:
	if get_parent():
		reparent(origin_node)
	else:
		origin_node.add_child(self)
	parent = origin_node
	global_position = origin_node.global_position + origin_offset
	end = end_node
	offset = end_offset
