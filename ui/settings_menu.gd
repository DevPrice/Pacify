class_name SettingsMenu extends PanelContainer

func _ready():
	get_window().size_changed.connect(_refresh)
	_refresh()
	%FullscreenButton.pressed.connect(GameInstance.toggle_fullscreen)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func close():
	queue_free()

func _refresh():
	var window = get_window()
	%FullscreenButton.button_pressed = window and window.mode == Window.MODE_FULLSCREEN
