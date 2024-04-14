class_name Player
extends CharacterBody2D

@export var spawn_point: Marker2D
@export var swim_rotation_speed: float = 5;

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
@export var water_friction_speed: float = 150
@export var water_accels: Array[float] = [250]
@export var water_speeds: Array[float] = [75]

var current_water_speed_level: int = 0

@onready var sprite: Sprite2D = %Sprite
@onready var float_component: FloatComponent = $FloatComponent
@onready var oxygen_component: OxygenComponent = $OxygenComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pickup_component: PickupComponent = $PickupComponent
@onready var inventory_component: InventoryComponent = $InventoryComponent
@onready var tank_sprite: Sprite2D = %TankSprite
@onready var flippers_sprite: Sprite2D = %FlippersSprite
@onready var pack_sprite: Sprite2D = %PackSprite


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_in_water: bool = false

func _ready() -> void:
	GameEvents.get_upgrade.connect(_on_get_upgrade)

func _on_get_upgrade(upgrade: UpgradeResource):
	if upgrade.upgrade_id == "tank":
		tank_sprite.visible = true
	if upgrade.upgrade_id == "flippers":
		flippers_sprite.visible = true
		update_speed(upgrade.upgrade_value)
	if upgrade.upgrade_id == "pack":
		pack_sprite.visible = true


func update_speed(upgrade_value: float):
	current_water_speed_level = roundi(upgrade_value)

func pickup_update_range(in_range: bool, pickup: ItemPickup):
	if in_range:
		pickup_component.enter_range_pickup(pickup)
	else:
		pickup_component.exit_range_pickup(pickup)

func enter_water():
	if sprite.scale.x == 1:
		swim_target_angle = -PI
		swim_angle = -PI
	else:
		swim_target_angle = 0
		swim_angle = 0
	float_component.set_in_water(true)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	floor_constant_speed = false
	is_in_water = true
	if Input.is_action_pressed("move_up"):
		velocity.y *= .1
	else:
		velocity.y *= .5

func exit_water():
	if sprite.scale.x == 1:
		swim_target_angle = -PI
		swim_angle = -PI
	else:
		swim_target_angle = 0
		swim_angle = 0
	float_component.set_in_water(false)
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	floor_constant_speed = true
	is_in_water = false
	if velocity.y > -20:
		velocity.y = 0

func die():
	global_position = spawn_point.global_position
	inventory_component.die()
	
func set_in_oxygen(is_in_oxygen):
	if is_in_oxygen:
		GameEvents.player_enter_air.emit()
	oxygen_component.set_is_in_water(not is_in_oxygen)
	
func is_facing_left() -> bool:
	return sprite.scale.x == 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		pickup_component.try_pickup(inventory_component)
	if event.is_action_pressed("cheat_1"):
		current_water_speed_level += 1
	if event.is_action_pressed("cheat_2"):
		GameEvents.toggle_costs.emit()
	if event.is_action_pressed("drop"):
		inventory_component.try_drop()
		
		
var swim_angle: float = 0
var swim_target_angle: float =0
func _physics_process(delta):
	GameEvents.add_debug_obj.emit("in_water", is_in_water)
	GameEvents.add_debug_obj.emit("grounded", is_on_floor())
	GameEvents.add_debug_obj.emit("pos", global_position)
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	var direction_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	GameEvents.add_debug_obj.emit("direction_input", direction_input)
	
	if not is_in_water:
		sprite.rotation = 0
		if not is_on_floor():
			velocity.y += gravity * delta
			if velocity.y > max_fall_speed:
				velocity.y = max_fall_speed
		else:
			if direction_input.x:
				animation_player.play("walk")
			else:
				animation_player.play("idle")

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
		if direction_input.x > 0:
			sprite.scale.x = -1
		if direction_input.x < 0:
			sprite.scale.x = 1
	else:
		
		var x_input = direction_input.x
		var y_input = direction_input.y
		
		var accel_value = water_accels[current_water_speed_level]
		if x_input:
			if sign(x_input) != sign(velocity.x):
				accel_value *= 2
			velocity.x = move_toward(velocity.x, x_input * water_speeds[current_water_speed_level], accel_value * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, water_friction_speed * delta)
		accel_value = water_accels[current_water_speed_level]
		if y_input:
			if sign(y_input) != sign(velocity.y):
				accel_value *= 2
			velocity.y = move_toward(velocity.y, y_input * water_speeds[current_water_speed_level], accel_value * delta)
		else:
			velocity.y = move_toward(velocity.y, 0, water_friction_speed * delta)
		if direction_input:
			swim_target_angle = direction_input.angle()
		else:
			swim_target_angle =  0 if sprite.scale.x == -1 else PI
		swim_angle = lerp_angle(swim_angle, swim_target_angle, .1)
		GameEvents.add_debug_obj.emit("swim_angle", swim_angle)
		var currently_flipped = sprite.scale.x == -1
		var dot_value = Vector2.RIGHT.dot(Vector2.from_angle(swim_angle))
		var is_flipped = dot_value > 0.1 if not currently_flipped else dot_value > -.1
		GameEvents.add_debug_obj.emit("is_flipped", is_flipped)
		sprite.rotation = swim_angle if is_flipped else swim_angle + PI
		sprite.scale.x = -1 if is_flipped else 1
		if direction_input:
			animation_player.play("swim")
		else:
			animation_player.play("swim_idle")
		
		
		
	GameEvents.add_debug_obj.emit("disp", sprite.position)
	GameEvents.add_debug_obj.emit("velocity", velocity)
	if move_and_slide():
		if is_in_water:
			var collision_data: KinematicCollision2D = get_last_slide_collision()
			velocity = velocity.slide(collision_data.get_normal())

	GameEvents.add_debug_obj.emit("post-slide-velocity", velocity)
