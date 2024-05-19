class_name SettingsMenu extends PanelContainer

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func close():
	queue_free()
