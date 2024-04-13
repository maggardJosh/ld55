class_name Biome
extends Area2D

@export var water_bg_color: Color
@export var water_color: Color

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameEvents.on_enter_new_biome.emit(self)
