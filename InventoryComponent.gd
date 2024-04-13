class_name InventoryComponent
extends Node

@export var max_inventory_size: int = 5

var items: Array[InventoryItem]
var is_full = false

func _ready() -> void:
	items.clear()
	for i in max_inventory_size:
		items.append(null)
	GameEvents.inventory_settings_updated.emit(max_inventory_size)
	emit_inventory_signals()
	GameEvents.drop_item_index.connect(_on_drop_item_index)

func _on_drop_item_index(item_index: int):
	items[item_index] = null
	emit_inventory_signals()
	
func try_pickup(item_pickup: ItemPickup):
	for i in max_inventory_size:
		if items[i] == null:
			items[i] = item_pickup.inventory_item
			emit_inventory_signals()
			item_pickup.pickup()
			return

func emit_inventory_signals():
	GameEvents.inventory_updated.emit(items)
	if is_full != (items.filter(func(i): return i != null).size() >= max_inventory_size):
		is_full = !is_full
		GameEvents.inventory_full_changed.emit(is_full)
			
