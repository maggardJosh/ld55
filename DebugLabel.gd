extends Label

var values = {}

func _ready() -> void:
	GameEvents.add_debug_obj.connect(add_debug_obj)

func add_debug_obj(key: String, value):
	values[key] = value
	text = ""
	for k in values:
		text += k + ": " + str(values[k]) + "\n"
