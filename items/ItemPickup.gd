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
		
func pickup():
	queue_free()
