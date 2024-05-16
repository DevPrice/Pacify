extends Control

func _gui_input(event):
	_handle_focus(event)

func _unhandled_input(event):
	_handle_focus(event)

func _handle_focus(event: InputEvent):
	var current_focus = get_viewport().gui_get_focus_owner()
	var child_has_focus = current_focus and is_ancestor_of(current_focus)
	if not child_has_focus and (event is InputEventJoypadButton or event is InputEventJoypadMotion or event is InputEventKey):
		_set_button_focus_enabled(true)
	elif child_has_focus and event is InputEventMouseMotion:
		_set_button_focus_enabled(false)

func _set_button_focus_enabled(enabled: bool) -> void:
	for button in find_children("*", "Button"):
		button.focus_mode = FOCUS_ALL if enabled else FOCUS_NONE
	var current_focus = get_viewport().gui_get_focus_owner()
	if enabled:
		var focus_element = find_next_valid_focus()
		if focus_element: focus_element.grab_focus()
	elif current_focus:
		current_focus.release_focus()
