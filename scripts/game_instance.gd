extends Node

func _input(event: InputEvent):
	if event.is_action_pressed("fullscreen"):
		toggle_fullscreen()
		get_window().set_input_as_handled()

func toggle_fullscreen() -> void:
	var window = get_window()
	if window:
		window.mode = Window.MODE_FULLSCREEN if window.mode != Window.MODE_FULLSCREEN else Window.MODE_WINDOWED
