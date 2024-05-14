extends Node

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent):
	if event.is_action_pressed("fullscreen"):
		toggle_fullscreen()
		get_window().set_input_as_handled()
	if event.is_action_pressed("pause"):
		toggle_paused()
		get_window().set_input_as_handled()

func toggle_fullscreen() -> void:
	var window = get_window()
	if window:
		window.mode = Window.MODE_FULLSCREEN if window.mode != Window.MODE_FULLSCREEN else Window.MODE_WINDOWED

func toggle_paused() -> void:
	var tree = get_tree()
	if tree:
		tree.paused = not tree.paused
