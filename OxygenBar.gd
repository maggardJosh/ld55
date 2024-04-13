extends ProgressBar

@export var disappear_time: float = 3
@export var disappear_curve: Curve
@export var appear_threshold: float = 1

@export var appear_time: float = 2
@export var appear_curve: Curve

func _ready() -> void:
	changed.connect(on_bar_settings_changed)
	value_changed.connect(on_bar_value_changed)
	modulate.a = 0
	
var count: float = 0
var is_showing: bool = false

func on_bar_value_changed(_value):
	update_visiblity_values()
	
func on_bar_settings_changed():
	update_visiblity_values()

func update_visiblity_values():
	var should_show = value + appear_threshold < max_value
	if should_show != is_showing:
		is_showing = should_show
		if not should_show:
			count = disappear_time
		else:
			count = appear_time

func _process(delta: float) -> void:
	if is_showing:
		if count > 0:
			count -= delta
			var t = count/appear_time
			modulate.a = appear_curve.sample(1.0-t)
	else:
		if count > 0:
			count -= delta
			var t = count/disappear_time
			modulate.a = disappear_curve.sample(1.0-t)
