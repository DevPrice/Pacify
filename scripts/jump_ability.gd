extends Ability

@export var jump_velocity: float = 4.5
@export var input_action: String

@onready var _body: CharacterBody3D = get_parent()

func can_activate():
	return super.can_activate() and _body and _body.is_on_floor()

func _activate():
	_body.velocity.y = jump_velocity

func _unhandled_input(event: InputEvent):
	if input_action and event.is_action_pressed(input_action):
		if try_activate(): get_viewport().set_input_as_handled()
