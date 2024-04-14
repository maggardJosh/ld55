extends Label

var max_tipe_time: float = 10.0
var has_shown: bool = false

func _ready():
	GameEvents.inventory_full_changed.connect(on_inventory_full)
	visible = false
	
var count:float = 0
func _process(delta: float) -> void:
	if not visible:
		return
	count += delta
	if count > max_tipe_time:
		visible = false
	
func on_inventory_full(is_full: bool):
	if is_full and not has_shown:
		visible = true
		has_shown = true
	else:
		visible = false
