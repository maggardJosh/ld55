class_name PickupComponent
extends Node2D

var items_in_range: Array[ItemPickup]
var player: Player

func _ready():
	visible = false
	player = get_tree().get_first_node_in_group("player")

func enter_range_pickup(pickup: ItemPickup):
	items_in_range.append(pickup)
	update_visibility()
	
func exit_range_pickup(pickup: ItemPickup):
	items_in_range.erase(pickup)
	update_visibility()

func update_visibility():
	visible = items_in_range.size() > 0
	
func _process(delta: float) -> void:
	if not visible:
		return
	if items_in_range.size() > 1:
		items_in_range.sort_custom(_sort_by_dist_to_player)
	var closest_item: ItemPickup = items_in_range[0]
	global_position = closest_item.global_position
		

func _sort_by_dist_to_player(a: ItemPickup, b: ItemPickup):
	return a.global_position.distance_squared_to(player.global_position) < b.global_position.distance_squared_to(player.global_position)

func try_pickup(inventory_component: InventoryComponent):
	if items_in_range.size() > 0:
		inventory_component.try_pickup(items_in_range[0])
