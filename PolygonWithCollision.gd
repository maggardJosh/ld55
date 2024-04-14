extends Polygon2D

func _ready() -> void:
	var collision_poly = CollisionPolygon2D.new()
	get_parent().add_child.call_deferred(collision_poly)
	collision_poly.polygon = polygon
	collision_poly.position = position

