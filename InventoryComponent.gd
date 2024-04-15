class_name InventoryComponent
extends Node

@export var max_inventory_size: int = 5
@onready var pickup_audio_stream_player: AudioStreamPlayer2D = $"../PickupAudioStreamPlayer"
@onready var drop_audio_stream_player: AudioStreamPlayer2D = $"../DropAudioStreamPlayer"

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

func die():
	for i in max_inventory_size:
		items[i] = null
	emit_inventory_signals()
	
func _on_get_upgrade(upgrade: UpgradeResource):
	for req in upgrade.requirements:
		for i in items.size():
			if items[i] == req:
				items[i] = null
				break
	if upgrade.upgrade_id == "pack":
		max_inventory_size = roundi(upgrade.upgrade_value)
		for i in max_inventory_size - items.size():
			items.append(null)
		GameEvents.inventory_settings_updated.emit(max_inventory_size)
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
	var facing_left = owner.is_facing_left()
	instantiated_obj.drop(owner.global_position, -PI/4 if facing_left else PI/4, -PI/9 if facing_left else PI/9 )
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
			pickup_audio_stream_player.play()
			emit_inventory_signals()
			return true
	return false

func try_drop() -> bool:
	for i in max_inventory_size:
		if items[i] != null:
			_on_drop_item_index(i)
			drop_audio_stream_player.play()
			return true

	return false

func emit_inventory_signals():
	GameEvents.inventory_updated.emit(items)
	if is_full != (items.filter(func(i): return i != null).size() >= max_inventory_size):
		is_full = !is_full
		GameEvents.inventory_full_changed.emit(is_full)
			
