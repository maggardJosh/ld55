class_name PickupComponent
extends Node2D

var items_in_range: Array[ItemPickup]
var player: Player

@onready var pickup_label: Label = %PickupLabel
@onready var break_label: Label = %BreakLabel
@onready var inventory_full_label: Label = %InventoryFullLabel

func _ready():
	visible = false
	player = get_tree().get_first_node_in_group("player")
	GameEvents.inventory_full_changed.connect(_on_inventory_full_changed)

var is_full: bool = false
func _on_inventory_full_changed(is_full_in: bool):
	is_full = is_full_in
	if is_full and pickup_label.visible:
		pickup_label.visible = false
		inventory_full_label.visible = true
	elif not is_full and inventory_full_label.visible:
		pickup_label.visible = true
		inventory_full_label.visible = false

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
	if closest_item is ItemBreakable:
		break_label.visible = true
		pickup_label.visible = false
		inventory_full_label.visible = false
	else:
		break_label.visible = false
		pickup_label.visible = not is_full
		inventory_full_label.visible = is_full
		pickup_label.text = "pickusp " + closest_item.inventory_item.title
		

func _sort_by_dist_to_player(a: ItemPickup, b: ItemPickup):
	return a.global_position.distance_squared_to(player.global_position) < b.global_position.distance_squared_to(player.global_position)

func try_pickup(inventory_component: InventoryComponent):
	if items_in_range.size() > 0:
		inventory_component.try_pickup(items_in_range[0])
