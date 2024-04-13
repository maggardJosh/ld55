class_name Player
extends CharacterBody2D

@export_category("Air")
@export var air_accel = 200.0
@export var air_speed = 300.0
@export var air_friction_speed = 20

@export_category("Ground")
@export var ground_accel = 200.0
@export var ground_speed = 300.0
@export var ground_friction_speed = 300.0
@export var jump_vel = -200.0

@export_category("Water")
@export var water_accel: float = 20
@export var water_speed: float = 200
@export var water_friction_speed: float = 10

@export_group("Float")
@export var float_noise: NoiseTexture2D
@export var float_effect_magnitude: float = 3.0

@onready var sprite: Sprite2D = %Sprite


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_in_water: bool = false

func enter_water():
	is_in_water = true
	velocity.y *= .5

func exit_water():
	is_in_water = false
	velocity.y *= 2

func _physics_process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	GameEvents.add_debug_obj.emit("direction_input", direction_input)
	if not is_in_water:
		if not is_on_floor():
			velocity.y += gravity * delta

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_vel

		var x_input = Input.get_axis("move_left", "move_right")	
		if is_on_floor():
			if x_input:
				velocity.x = move_toward(velocity.x, x_input * ground_speed, ground_accel * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, ground_friction_speed * delta)
		else:
			if x_input:
				velocity.x = move_toward(velocity.x, x_input * air_speed, air_accel * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, air_friction_speed * delta)
	else:
		
		var x_input = direction_input.x
		var y_input = direction_input.y
		if x_input:
			velocity.x = move_toward(velocity.x, x_input * water_speed, water_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, water_friction_speed * delta)
		if y_input:
			velocity.y = move_toward(velocity.y, y_input * water_speed, water_accel * delta)
		else:
			velocity.y = move_toward(velocity.y, 0, water_friction_speed * delta)
	
	if direction_input.x > 0:
		sprite.flip_h = true
	if direction_input.x < 0:
		sprite.flip_h = false
		
	GameEvents.add_debug_obj.emit("velocity", velocity)
	move_and_slide()

