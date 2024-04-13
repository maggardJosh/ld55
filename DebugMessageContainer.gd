extends VBoxContainer

@export var label_scene: PackedScene

func _ready() -> void:
	GameEvents.add_message.connect(add_message)

func add_message(message):
	print(message)
	var new_label: Label = label_scene.instantiate()
	new_label.text = message
	add_child(new_label)
