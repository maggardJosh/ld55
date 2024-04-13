class_name InventorySpace
extends ColorRect

var item: InventoryItem	
@onready var texture_rect: TextureRect = $TextureRect

func _ready():
	set_item(null)
	
func has_item() -> bool:
	return item != null

func set_item(item_in: InventoryItem):
	item = item_in
	if item:
		texture_rect.texture = item.inventory_image
	else:
		texture_rect.texture = null
