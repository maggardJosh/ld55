class_name Player
extends CharacterBody2D

@export_category("Air")
@export var air_accel = 200.0
@export var air_speed = 300.0
@export var air_friction_speed = 20
@export var max_fall_speed = 500.0

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
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	floor_constant_speed = false
	is_in_water = true
	velocity.y *= .5

func exit_water():
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	floor_constant_speed = true
	is_in_water = false
	velocity.y *= 2

var noise_count: float = 0
func _physics_process(delta):
	GameEvents.add_debug_obj.emit("in_water", is_in_water)
	GameEvents.add_debug_obj.emit("grounded", is_on_floor())
	GameEvents.add_debug_obj.emit("pos", global_position)
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	GameEvents.add_debug_obj.emit("direction_input", direction_input)
	
	if not is_in_water:
		sprite.position = sprite.position.move_toward(Vector2.ZERO, delta*10)
		if not is_on_floor():
			velocity.y += gravity * delta
			if velocity.y > max_fall_speed:
				velocity.y = max_fall_speed

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
		noise_count += delta
		var x_disp = float_noise.noise.get_noise_2d(noise_count, 0) * float_effect_magnitude
		var y_disp = float_noise.noise.get_noise_2d(0, noise_count) * float_effect_magnitude
		sprite.position = sprite.position.move_toward(Vector2(x_disp, y_disp), delta)
		
		var x_input = direction_input.x
		var y_input = direction_input.y
		var accel_value = water_accel
		if x_input:
			if sign(x_input) != sign(velocity.x):
				accel_value *= 2
			velocity.x = move_toward(velocity.x, x_input * water_speed, accel_value * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, water_friction_speed * delta)
		accel_value = water_accel
		if y_input:
			if sign(y_input) != sign(velocity.y):
				accel_value *= 2
			velocity.y = move_toward(velocity.y, y_input * water_speed, accel_value * delta)
		else:
			velocity.y = move_toward(velocity.y, 0, water_friction_speed * delta)
	
	if direction_input.x > 0:
		sprite.flip_h = true
	if direction_input.x < 0:
		sprite.flip_h = false
	GameEvents.add_debug_obj.emit("disp", sprite.position)
	GameEvents.add_debug_obj.emit("velocity", velocity)
	if move_and_slide():
		if is_in_water:
			var collision_data: KinematicCollision2D = get_last_slide_collision()
			GameEvents.add_debug_obj.emit("norm", collision_data.get_normal())
			velocity = velocity.bounce(collision_data.get_normal()) * .8
			

	GameEvents.add_debug_obj.emit("post-velocity", velocity)
