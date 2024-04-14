class_name ItemBreakable
extends ItemPickup

@export var possible_drops: Array[PackedScene]

func pickup():
	var drop: ItemPickup = possible_drops.pick_random().instantiate()
	get_tree().root.add_child(drop)
	drop.drop(global_position, 0, TAU, 50,100)
	queue_free()
	
