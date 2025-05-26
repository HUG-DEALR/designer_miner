extends Node2D

@onready var line: Line2D = $Line2D

func set_colour(colour: Color) -> void:
	line.default_color = colour

func set_type(type: String) -> void:
	match type:
		"default":
			set_colour(Color(0.5,0.5,0.5,1))
		"selected":
			set_colour(Color(1,0,0,1))
			name = "Rotary Joint "
