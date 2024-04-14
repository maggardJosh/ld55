extends ColorRect

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var mute_button: Button = $VBoxContainer/MuteButton

func _ready():
	visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			hide_screen()
		else:
			show_screen()
	
func show_screen():
	visible = true
	Engine.time_scale = 0
	resume_button.grab_focus()

func hide_screen():
	visible = false
	Engine.time_scale = 1
	


func _on_resume_button_pressed() -> void:
	hide_screen()
	

func _on_quit_pressed() -> void:
	get_tree().quit()

var is_muted = false
func _on_mute_button_pressed() -> void:
	is_muted = not is_muted
	mute_button.text = "Mute Music" if not is_muted else "Unmute Music"
	AudioServer.set_bus_mute(1, is_muted )
