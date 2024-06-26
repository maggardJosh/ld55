extends Node

signal add_debug_obj(key: String, value)
signal add_message(message: String)
signal on_enter_new_biome(biome: Biome)
signal enter_death_buffer()
signal player_enter_air()
signal inventory_updated(inventory_items: Array[InventoryItem], max_inventory_size: int)
signal inventory_settings_updated(inventory_size: int)
signal inventory_full_changed(is_full: bool)
signal drop_item_index(index: int)
signal get_upgrade(upgrade: UpgradeResource)
signal get_item(item: CraftableInventoryItem)
signal oxygen_updated(current_seconds: float, max_oxygen_seconds: float)
signal toggle_costs()

func add_message_emit(message):
	add_message.emit(message)
