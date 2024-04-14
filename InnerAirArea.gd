extends Area2D

func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body):
	if body.has_method("exit_water"):
		body.exit_water()
		
func on_body_exited(body):
	if body.has_method("enter_water"):
		body.enter_water()
