class_name SummonButton
extends ColorRect

@export var item: CraftableResource
@onready var upgrade_title: Label = %UpgradeTitle
@onready var upgrade_description: Label = %UpgradeDescription
@onready var requirements_h_box: HBoxContainer = %RequirementsHBox
@onready var ui: ColorRect = $UI
@onready var texture_rect: TextureRect = $TextureRect
@onready var can_summon_label: Label = %CanSummonLabel

@export var can_summon_color: Color = Color.GREEN
@export var cannot_summon_color: Color = Color.RED

var can_summon: bool = false

signal summon

func _input(event: InputEvent) -> void:
	if ui.visible and event is InputEventMouseButton and event.is_pressed() and can_summon:
		if event.button_index == 1:
			summon.emit()
			if item is UpgradeResource:
				if is_instance_valid(item.next_upgrade):
					_set_item(item.next_upgrade)
				else:
					queue_free()

func _ready():
	ui.visible = false
	_set_item(item)

func _set_item(new_item: CraftableResource):
	if new_item == null:
		visible = false
		return
	item = new_item
	texture_rect.texture = item.image
	upgrade_title.text = item.title
	upgrade_description.text = item.description
	for child in requirements_h_box.get_children():
		child.queue_free()
	for reqItem in item.requirements:
		var trect: TextureRect = TextureRect.new()
		trect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		trect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		trect.texture = reqItem.inventory_image
		requirements_h_box.add_child(trect)
	update_ui()
	

func _on_mouse_entered() -> void:
	ui.visible = true

func _on_mouse_exited() -> void:
	ui.visible = false

func update_can_summon(inventory_items: Array[InventoryItem]):
	can_summon = false
	if item == null:
		return
	var inventory_items_copy = inventory_items.duplicate()
	for i in item.requirements.size():
		var current_req = item.requirements[i]
		if inventory_items_copy.has(current_req):
			inventory_items_copy.erase(current_req)
		else:
			can_summon = false
			update_ui()
			return
	can_summon = true
	update_ui()
	
func update_ui():
	can_summon_label.modulate = can_summon_color if can_summon else cannot_summon_color
	can_summon_label.text = "Can Summon" if can_summon else "Missing Ingredients"
