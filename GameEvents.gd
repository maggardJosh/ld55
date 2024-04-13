extends Node

signal add_debug_obj(key: String, value)
signal add_message(message: String)
signal on_enter_new_biome(biome: Biome)

func add_message_emit(message):
	add_message.emit(message)
