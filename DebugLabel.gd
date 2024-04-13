extends Label

var values = {}

func _ready() -> void:
	visible = false
	GameEvents.add_debug_obj.connect(add_debug_obj)
	GameEvents.on_enter_new_biome.connect(_on_enter_new_biome)

func _on_enter_new_biome(biome: Biome):
	add_debug_obj("biome", biome.name)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_debug"):
		visible = !visible

func add_debug_obj(key: String, value):
	values[key] = value
	text = ""
	for k in values:
		text += k + ": " + str(values[k]) + "\n"
