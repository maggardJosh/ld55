class_name InventoryComponent
extends Node

var items: Array[InventoryItem]

func try_pickup(item_pickup: ItemPickup):
	items.append(item_pickup.inventory_item)
	item_pickup.pickup()
