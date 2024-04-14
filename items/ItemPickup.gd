class_name ItemPickup
extends RigidBody2D

@export var inventory_item: InventoryItem
@export var random_rotation_on_drop: bool = false

const random_rotation_range = PI/10

func _ready() -> void:
	rotation = rotation + randf_range(-random_rotation_range, random_rotation_range)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("pickup_update_range"):
		body.pickup_update_range(true, self)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("pickup_update_range"):
		body.pickup_update_range(false, self)

var in_water: bool = false
func enter_water() -> void:
	linear_velocity *= .4
	in_water = true
	handle_water_changed(in_water)
	
func exit_water() -> void:
	in_water = false
	handle_water_changed(in_water)
	
func handle_water_changed(new_value: bool):
	pass

const MIN_DROP_VEL:float = 200
const MAX_DROP_VEL:float = 300

func drop(global_pos: Vector2, min_angle = -PI/4, max_angle = PI/4, min_vel = MIN_DROP_VEL, max_vel=MAX_DROP_VEL):
	global_position = global_pos
	freeze = false
	linear_velocity = Vector2.UP.rotated(randf_range(min_angle, max_angle)) * randf_range(min_vel, max_vel)
	if random_rotation_on_drop:
		rotation = randf_range(0,TAU)
		angular_velocity = randf_range(0,PI)
	
func pickup():
	queue_free()
