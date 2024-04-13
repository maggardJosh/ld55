extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.has_method("enter_water"):
		body.enter_water()


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("exit_water"):
		body.exit_water()
