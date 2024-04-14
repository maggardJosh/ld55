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
	GameEvents.get_upgrade.connect(_on_get_upgrade)
	GameEvents.get_item.connect(_on_get_item)
	
func _on_get_upgrade(upgrade: UpgradeResource):
	for req in upgrade.requirements:
		for i in items.size():
			if items[i] == req:
				items[i] = null
				break
	emit_inventory_signals()

func _on_get_item(item: CraftableInventoryItem):
	for req in item.requirements:
		for i in items.size():
			if items[i] == req:
				items[i] = null
				break
	try_get_inventory_item(item.inventory_item)
	

func _on_drop_item_index(item_index: int):
	var instantiated_obj:ItemPickup = load(items[item_index].scenePath).instantiate()
	get_tree().root.add_child(instantiated_obj)
	instantiated_obj.drop(owner.global_position)
	items[item_index] = null
	emit_inventory_signals()
	
func try_pickup(item_pickup: ItemPickup):
	if item_pickup is ItemBreakable:
		item_pickup.pickup()
		return
	if try_get_inventory_item(item_pickup.inventory_item):
		item_pickup.pickup()

func try_get_inventory_item(inventory_item: InventoryItem) -> bool:
	for i in max_inventory_size:
		if items[i] == null:
			items[i] = inventory_item
			emit_inventory_signals()
			return true
	return false

func emit_inventory_signals():
	GameEvents.inventory_updated.emit(items)
	if is_full != (items.filter(func(i): return i != null).size() >= max_inventory_size):
		is_full = !is_full
		GameEvents.inventory_full_changed.emit(is_full)
			
