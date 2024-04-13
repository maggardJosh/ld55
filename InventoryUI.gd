extends Control
@onready var inventory_grid_container: GridContainer = $InventoryGridContainer
var inventorySpaces: Array[InventorySpace]

func _enter_tree() -> void:
	GameEvents.inventory_updated.connect(_on_inventory_updated)
	GameEvents.inventory_settings_updated.connect(_on_inventory_settings_updated)

func _ready():
	var i = 0
	for child in inventory_grid_container.get_children():
		if child is InventorySpace:
			inventorySpaces.append(child)
			child.drop_item.connect(_on_drop_item.bind(i))
			i += 1

func _on_drop_item(item_index: int):
	GameEvents.drop_item_index.emit(item_index)
	
func _on_inventory_settings_updated(inventory_space: int):
	var i = 0
	for space in inventorySpaces:
		space.visible = i < inventory_space
		i += 1
	
func _on_inventory_updated(items: Array[InventoryItem]):
	var i = 0
	for item: InventoryItem in items:
		inventorySpaces[i].set_item(item)
		i += 1
