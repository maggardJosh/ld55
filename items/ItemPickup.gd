class_name ItemPickup
extends RigidBody2D

@export var inventory_item: InventoryItem

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("pickup_update_range"):
		body.pickup_update_range(true, self)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("pickup_update_range"):
		body.pickup_update_range(false, self)
		
func enter_water() -> void:
	linear_velocity *= .4

const MIN_DROP_VEL:float = 200
const MAX_DROP_VEL:float = 300

func drop(global_pos: Vector2):
	global_position = global_pos
	freeze = false
	linear_velocity = Vector2.UP.rotated(randf_range(-PI/4, PI/4)) * randf_range(MIN_DROP_VEL,MAX_DROP_VEL)
	
func pickup():
	queue_free()
