extends Node2D

@export var min_x_scale:float = .8
@export var max_x_scale:float = 2.0
@export var keep_aspect: bool = false
@export var min_y_scale: float = .8
@export var max_y_scale: float = 2.0
@export var rand_rotation_degrees:float = 15
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	(sprite.material as ShaderMaterial).set_shader_parameter("offset", randf_range(0, 100))
	if keep_aspect:
		scale = Vector2.ONE * randf_range(min_x_scale, max_x_scale)
	else:
		scale.x = randf_range(min_x_scale,max_x_scale)
		scale.y = randf_range(min_y_scale, max_y_scale)
	
	rotation = rotation + deg_to_rad(randf_range(-rand_rotation_degrees,rand_rotation_degrees))
