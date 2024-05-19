extends Control

var _active_control: Control:
	get: return _active_control
	set(value):
		if _active_control: _active_control.visible = false
		_active_control = value
		if _active_control: _active_control.visible = true

func _ready():
	child_order_changed.connect(_update_active_control)
	_update_active_control()

func _update_active_control():
	var controls := get_children().filter(
		func (child: Node):
			return child is Control
	)
	var last = controls.pop_back()
	_active_control = last
