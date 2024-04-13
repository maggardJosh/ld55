class_name Player
extends CharacterBody2D

@export var spawn_point: Marker2D


@export_group("Physics")
@export_subgroup("Air")
@export var air_accel = 200.0
@export var air_speed = 300.0
@export var air_friction_speed = 20
@export var max_fall_speed = 500.0

@export_subgroup("Ground")
@export var ground_accel = 200.0
@export var ground_speed = 300.0
@export var ground_friction_speed = 300.0
@export var jump_vel = -200.0

@export_subgroup("Water")
@export var water_accel: float = 20
@export var water_speed: float = 200
@export var water_friction_speed: float = 10

@onready var sprite: Sprite2D = %Sprite
@onready var float_component: FloatComponent = $FloatComponent
@onready var oxygen_component: OxygenComponent = $OxygenComponent


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_in_water: bool = false

func enter_water():
	float_component.set_in_water(true)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	floor_constant_speed = false
	is_in_water = true
	if Input.is_action_pressed("move_up"):
		velocity.y *= .1
	else:
		velocity.y *= .5

func exit_water():
	float_component.set_in_water(false)
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	floor_constant_speed = true
	is_in_water = false
	if velocity.y > -20:
		velocity.y = 0

func die():
	global_position = spawn_point.global_position
	
func set_in_oxygen(is_in_oxygen):
	if is_in_oxygen:
		GameEvents.player_enter_air.emit()
	oxygen_component.set_is_in_water(not is_in_oxygen)

func _physics_process(delta):
	GameEvents.add_debug_obj.emit("in_water", is_in_water)
	GameEvents.add_debug_obj.emit("grounded", is_on_floor())
	GameEvents.add_debug_obj.emit("pos", global_position)
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	GameEvents.add_debug_obj.emit("direction_input", direction_input)
	
	if not is_in_water:
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
			velocity = velocity.slide(collision_data.get_normal())

	GameEvents.add_debug_obj.emit("post-slide-velocity", velocity)
