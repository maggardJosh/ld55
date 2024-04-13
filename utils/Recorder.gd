extends Node

@export var framesPerSecond = 30
@export var maxSecondsInGif = 20
@export var use_threading = true
@export var auto_record = false

var thread: Thread = Thread.new()
var viewportText: ViewportTexture


func _ready():
	viewportText = get_viewport().get_texture()

	if auto_record:
		start_recording()
	pass


var count = 0
var frame_num = 0
var image_buffer: Array[Image]
var is_recording = false
var is_saving = false
var did_loop = false


func _process(_delta):
	if is_saving or (not OS.has_feature("gif_recording") and not OS.has_feature("editor")):
		return
	if Input.is_action_just_pressed("Record"):
		if not is_recording:
			start_recording()
		else:
			save_images()
	if not is_recording:
		return
	if Input.is_action_just_pressed("reset_recording"):
		start_recording()

func _physics_process(_delta):
	
	if is_saving or (not OS.has_feature("gif_recording") and not OS.has_feature("editor")):
		return
		
	if not is_recording:
		return
	count += 0.016;
	if count >= (1.0 / framesPerSecond):
		count -= 1.0 / framesPerSecond
		var image = viewportText.get_image()
		if image != null:
			image_buffer[frame_num] = image
			frame_num += 1
			if frame_num >= image_buffer.size():
				frame_num = 0
				did_loop = true
	

func start_recording():
	if is_recording:
		GameEvents.add_message_emit.call_deferred("Restarted Recording...")
	else:
		GameEvents.add_message_emit.call_deferred("Recording...")
	is_recording = true
	did_loop = false
	count = 0
	frame_num = 0
	image_buffer.clear()
	image_buffer.resize(framesPerSecond * maxSecondsInGif)


func save_images():
	is_saving = true
	is_recording = false
	GameEvents.add_message_emit("Saving Recording...")
	if use_threading:
		if thread.is_started() and !thread.is_alive():
			thread.wait_to_finish()
		thread.start(actual_save)
	else:
		actual_save()


func actual_save():
	var start_frame_num = 1
	var end_frame_num = frame_num - 1
	if end_frame_num < 0:
		end_frame_num = image_buffer.size() - 1
	if did_loop and frame_num + 1 < image_buffer.size():
		start_frame_num = frame_num + 1

	var frame_num_local = start_frame_num
	var frame_count = 0
	var screenshotDirName = Time.get_datetime_string_from_system().replace(":", "_")
	var projectName = ProjectSettings.get_setting("application/config/name")
	var fullScreenshotDirectory = (
		OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		+ "/gifs/"
		+ projectName
		+ "/"
		+ screenshotDirName
	)
	DirAccess.make_dir_recursive_absolute(fullScreenshotDirectory)
	
	while true:
		var actualImage = image_buffer[frame_num_local]
		if actualImage == null:
			if frame_num_local == end_frame_num:
				break
			frame_num_local += 1
			continue
		actualImage.save_png(fullScreenshotDirectory + "/Screenshot-" + str(frame_count) + ".png")
		if frame_num_local == end_frame_num:
			break
		frame_num_local += 1
		frame_count += 1
		if frame_num_local >= image_buffer.size():
			frame_num_local = 0

	GameEvents.add_message_emit.call_deferred("Finished Saving Recording!")
	GameEvents.add_message_emit.call_deferred(fullScreenshotDirectory)

	var output = []
	match OS.get_name():
		"macOS":
		
			OS.execute(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/../Library/Application Support/Steam/steamapps/common/Aseprite/Aseprite.app/Contents/MacOS/aseprite", [ fullScreenshotDirectory + "/Screenshot-0.png"])
			print(output)
		_:
			OS.execute("cmd.exe", ["/C", "aseprite", fullScreenshotDirectory + "/Screenshot-0.png"])
	
	is_saving = false
	if auto_record:
		start_recording()
