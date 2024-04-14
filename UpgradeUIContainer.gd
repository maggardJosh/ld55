extends HBoxContainer
@onready var tank_text: TextureRect = $Tank/TankText
@onready var fins_text: TextureRect = $Fins/FinsText
@onready var pack_text: TextureRect = $Pack/PackText

func _ready():
	GameEvents.get_upgrade.connect(on_get_upgrade)


func on_get_upgrade(upgrade_item: UpgradeResource):
	if upgrade_item.upgrade_id == "tank":
		tank_text.texture = upgrade_item.image
	elif upgrade_item.upgrade_id == "flippers":
		fins_text.texture = upgrade_item.image
	elif upgrade_item.upgrade_id == "pack":
		pack_text.texture = upgrade_item.image
