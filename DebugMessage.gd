extends Label

@export var alpha_curve: Curve
@export var label_time: float = 2.0

var count: float  = 0.0
func _process(delta: float) -> void:
	count += delta
	var t = count / label_time
	modulate.a = alpha_curve.sample(t)
	if t >= 1:
		queue_free()
