extends Node

@export var num_copper:int = 10
@export var num_silver:int = 10
@export var num_gold:int = 10
@export var num_coral:int = 10
@export var num_flower:int = 20
@export var num_shards:int = 10
@export var num_fish_1:int = 10
@export var num_fish_2:int = 10
@export var num_fish_3:int = 10

@export var copper_res: InventoryItem
@export var silver_res: InventoryItem
@export var gold_res: InventoryItem
@export var coral_res: InventoryItem
@export var flower_res: InventoryItem
@export var shards_res: InventoryItem
@export var fish_1_res: InventoryItem
@export var fish_2_res: InventoryItem
@export var fish_3_res: InventoryItem

@export var fauna_container: Node2D
@export var fish_container: Node2D

var all_items: Array[ItemPickup]

func _ready():
	for biome:Node2D in fauna_container.get_children():
		for pickup_item:Node2D in biome.get_children():
			if pickup_item is ItemPickup:
				all_items.append(pickup_item)
				pickup_item.despawn()
	for biome:Node2D in fish_container.get_children():
		for pickup_item:Node2D in biome.get_children():
			if pickup_item is ItemPickup:
				all_items.append(pickup_item)
				pickup_item.despawn()
	ensure_all_spawned()
	

func ensure_all_spawned():
	ensure_item_spawned(copper_res, num_copper)
	ensure_item_spawned(silver_res, num_silver)
	ensure_item_spawned(gold_res, num_gold)
	ensure_item_spawned(coral_res, num_coral)
	ensure_item_spawned(flower_res, num_flower)
	ensure_item_spawned(shards_res, num_shards)
	ensure_item_spawned(fish_1_res, num_fish_1)
	ensure_item_spawned(fish_2_res, num_fish_2)
	ensure_item_spawned(fish_3_res, num_fish_3)

@export var player: Player
func ensure_item_spawned(item_res: InventoryItem, num_to_spawn: int):

	var available_items = all_items.filter(func(i:ItemPickup): return i.inventory_item == item_res)
	var num_currently_spawned = available_items.filter(func(i): return i.is_spawned_currently).size()

	if num_currently_spawned < num_to_spawn:
		for i in num_to_spawn - num_currently_spawned:
			var valid_items = available_items.filter(func(c:Node2D): return not c.is_spawned_currently and not c.is_on_screen() )
			if valid_items.size() == 0:
				print("NOT ENOUGH INSTANCES OF " + item_res.title)
				return
			var rand_instance = valid_items.pick_random()
			rand_instance.spawn()


func _on_check_spawn_timer_timeout() -> void:
	ensure_all_spawned()
