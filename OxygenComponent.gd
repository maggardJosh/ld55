class_name OxygenComponent
extends Node

@export var max_oxygen_seconds: float = 20
@export var oxygen_bar: ProgressBar
@export var replenish_rate: float = 10

var count: float = 0
var is_in_water: bool = true

func set_is_in_water(value: bool):
	is_in_water = value
	
func _physics_process(delta: float) -> void:
	if is_in_water:
		if count <= max_oxygen_seconds:
			count += delta
	else:
		if count >= 0:
			count = max(count - replenish_rate * delta, 0)
	oxygen_bar.value = max_oxygen_seconds - count
	oxygen_bar.max_value = max_oxygen_seconds
