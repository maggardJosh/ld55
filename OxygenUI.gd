extends Control
@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var o_2_label: Label = $Control/ProgressBar/O2Label

func _ready():
	GameEvents.oxygen_updated.connect(_on_oxygen_updated)

func _on_oxygen_updated(current_seconds, max_seconds):
	progress_bar.value = current_seconds
	progress_bar.max_value = max_seconds
	o_2_label.text = str(floori(max(0,current_seconds))) + "s"
