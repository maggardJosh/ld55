extends Node

signal add_debug_obj(key, value)
signal add_message(message)

func add_message_emit(message):
	add_message.emit(message)
