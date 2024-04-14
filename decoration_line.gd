extends Line2D

@export var min_dist_between_deco: float = 5
@export var max_dist_between_deco: float = 15
@export var rand_pos_range: float = 4	

@export var decoration: PackedScene

func _ready():
	for i in points.size() - 1:
		var point_one: Vector2 = points[i]
		var point_two: Vector2 = points[i+1]
		var deco_pos = point_one
		while true:
			deco_pos = deco_pos.move_toward(point_two, randf_range(min_dist_between_deco,max_dist_between_deco))
			var instance: Node2D = decoration.instantiate()
			instance.global_position = deco_pos + global_position + Vector2(randf_range(-rand_pos_range, rand_pos_range), randf_range(-rand_pos_range, rand_pos_range))
			get_tree().root.add_child.call_deferred(instance)
			if deco_pos == point_two:
				break
	queue_free()
		
