extends Node2D

@onready var ui: ColorRect = $UI
@onready var e_prompt: TextureRect = %e_prompt

var can_summon:bool = false

@export var current_upgrade: UpgradeResource
@export var next_upgrades: Array[UpgradeResource]
@onready var upgrade_title: Label = %UpgradeTitle
@onready var upgrade_image: TextureRect = %UpgradeImage
@onready var requirements_h_box: HBoxContainer = %RequirementsHBox

func _ready():
	ui.visible = false
	e_prompt.visible = false
	GameEvents.inventory_updated.connect(_on_inventory_updated)
	refresh_upgrade_ui()
	
func _input(event: InputEvent) -> void:
	if ui.visible and event.is_action("interact") and can_summon:
		summon()

func summon():
	GameEvents.get_upgrade.emit(current_upgrade)
	if next_upgrades.size() > 0:
		current_upgrade = next_upgrades.pop_front()
	else:
		current_upgrade = null
	refresh_upgrade_ui()
		

func refresh_upgrade_ui():
	if current_upgrade == null:
		upgrade_title.text = "Thanks for playing!"
		upgrade_image.texture = null
		for child in requirements_h_box.get_children():
			child.queue_free()
		return
	upgrade_title.text = current_upgrade.title
	upgrade_image.texture = current_upgrade.image
	for child in requirements_h_box.get_children():
		child.queue_free()
	for reqItem in current_upgrade.requirements:
		var trect: TextureRect = TextureRect.new()
		trect.texture = reqItem.inventory_image
		requirements_h_box.add_child(trect)

func _on_inventory_updated(inventory_items: Array[InventoryItem]):
	update_can_summon(inventory_items)
	e_prompt.visible = can_summon

func update_can_summon(inventory_items: Array[InventoryItem]):
	if current_upgrade == null:
		return
	var inventory_items_copy = inventory_items.duplicate()
	for i in current_upgrade.requirements.size():
		var current_req = current_upgrade.requirements[i]
		if inventory_items_copy.has(current_req):
			inventory_items_copy.erase(current_req)
		else:
			can_summon = false
			return
	can_summon = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	ui.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	ui.visible = false
