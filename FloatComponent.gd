class_name FloatComponent
extends Node

@export var float_target: Node2D
@export var max_float_speed: float = 1
@export var max_unfloat_speed: float = 10
@export var float_noise: NoiseTexture2D
@export var float_effect_magnitude: float = 3.0

@export var is_in_water: bool = false

func _ready() -> void:
	count = randf_range(0,200)

func set_in_water(value: bool):
	is_in_water = value


var count: float = 0
func _process(delta: float) -> void:
	if not is_in_water:
		float_target.position = float_target.position.move_toward(Vector2.ZERO, delta*max_unfloat_speed)
	else:
		count += delta
		var x_disp = float_noise.noise.get_noise_2d(count, 0) * float_effect_magnitude
		var y_disp = float_noise.noise.get_noise_2d(0, count) * float_effect_magnitude
		float_target.position = float_target.position.move_toward(Vector2(x_disp, y_disp), delta * max_float_speed)
		
