class_name InventorySpace
extends ColorRect

var item: InventoryItem	

@onready var texture_rect: TextureRect = $TextureRect
@onready var hover: ColorRect = $Hover
@onready var hover_title: Label = %HoverTitle
@onready var hover_description: Label = %HoverDescription

signal drop_item

func _ready():
	set_item(null)
	
func has_item() -> bool:
	return item != null

func set_item(item_in: InventoryItem):
	item = item_in
	if item:
		texture_rect.texture = item.inventory_image
		hover_title.text = item.title
		hover_description.text = item.description
	else:
		texture_rect.texture = null
		hover.visible = false

func _input(event: InputEvent) -> void:
	if hover.visible and event is InputEventMouseButton:
		if event.button_index == 2 and event.is_released():
			drop_item.emit()

func _on_mouse_entered() -> void:
	if item != null:
		hover.visible = true


func _on_mouse_exited() -> void:
	hover.visible = false
