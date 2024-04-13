class_name OxygenComponent
extends Node

@export var max_oxygen_seconds: float = 20
@export var oxygen_bar: ProgressBar
@export var replenish_rate: float = 10

@export var death_buffer: float = 3

var count: float = 0
var is_in_water: bool = true

func _ready() -> void:
	GameEvents.get_upgrade.connect(_on_get_upgrade)
	
func _on_get_upgrade(upgrade_resource: UpgradeResource):
	if upgrade_resource.upgrade_id == "tank":
		max_oxygen_seconds = upgrade_resource.upgrade_value
		

func set_is_in_water(value: bool):
	is_in_water = value
	
func _physics_process(delta: float) -> void:
	if is_in_water:
		if count <= max_oxygen_seconds:
			count += delta
		elif count <= max_oxygen_seconds+death_buffer:
			GameEvents.enter_death_buffer.emit()
			count += delta
			if count > max_oxygen_seconds + death_buffer:
				owner.die()
				pass
	else:
		if count >= 0:
			count = clamp(count - replenish_rate * delta, 0, max_oxygen_seconds)
	GameEvents.oxygen_updated.emit(max_oxygen_seconds-count, max_oxygen_seconds)
