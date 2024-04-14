extends Node2D

@onready var ui: ColorRect = $UI
@export var summon_button_containers: Array[BoxContainer]
var summon_buttons: Array[SummonButton]

func _ready():
	ui.visible = false
	GameEvents.inventory_updated.connect(_on_inventory_updated)
	GameEvents.toggle_costs.connect(_on_toggle_costs)
	for cont in summon_button_containers:
		for child in cont.get_children():
			if child is SummonButton:
				summon_buttons.append(child)
				child.summon.connect(summon.bind(child))
	

func summon(button: SummonButton):
	var item = button.item
	if item is UpgradeResource:
		GameEvents.get_upgrade.emit(item)
	if item is CraftableInventoryItem:
		GameEvents.get_item.emit(item)
		
var cost_enabled = true
func _on_toggle_costs():
	cost_enabled = not cost_enabled
	for child in summon_buttons:
		if is_instance_valid(child):
			child.set_cost_enabled(cost_enabled)

func _on_inventory_updated(inventory_items: Array[InventoryItem]):
	for child in summon_buttons:
		if is_instance_valid(child):
			child.update_can_summon(inventory_items)



func _on_area_2d_body_entered(body: Node2D) -> void:
	ui.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	ui.visible = false
