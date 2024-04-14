extends ColorRect

@export var show_time: float = 2
@export var show_curve: Curve

var is_showing: bool = false

var count: float = 0

func _ready() -> void:
	GameEvents.enter_death_buffer.connect(_on_enter_death_buffer)
	GameEvents.player_enter_air.connect(_on_exit_death_buffer)
	count = show_time
	modulate.a = 1
	is_showing = false
	
func _on_enter_death_buffer():
	is_showing = true

func _on_exit_death_buffer():
	is_showing = false
	
func _process(delta: float) -> void:
	if is_showing:
		if count < show_time:
			count += delta
			update_visibility()
	if not is_showing:
		if count > 0:
			count -= delta
			update_visibility()
			
func update_visibility():
	var t = count / show_time
	modulate.a = show_curve.sample(t)
	
	
