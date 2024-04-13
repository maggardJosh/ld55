extends Polygon2D

@export var default_biome: Biome
@export var biome_transition_time: float = 1.0
@export var biome_transition_curve: Curve
@onready var water_bg: Polygon2D = $WaterBG


var current_biome: Biome
var previous_water_color: Color
var previous_water_bg_color: Color

var count = 0.0
func _ready():
	GameEvents.on_enter_new_biome.connect(on_enter_new_biome)
	color = default_biome.water_color
	water_bg.color = default_biome.water_bg_color
	current_biome = default_biome

func on_enter_new_biome(new_biome: Biome):
	if new_biome == current_biome:
		return
	count = biome_transition_time
	current_biome = new_biome
	previous_water_bg_color = water_bg.color
	previous_water_color = color


func _process(delta: float) -> void:
	if count <= 0:
		return
	
	count -= delta
	var t = 1 - (count/biome_transition_time)
	var sample = biome_transition_curve.sample(t)
	color = lerp(previous_water_color, current_biome.water_color, sample)
	water_bg.color = lerp(previous_water_bg_color, current_biome.water_bg_color, sample)
