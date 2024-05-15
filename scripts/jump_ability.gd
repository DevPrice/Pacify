extends Ability

@export var jump_velocity: float = 4.5

@onready var _body: CharacterBody3D = get_parent()

func can_activate():
	return super.can_activate() and _body and _body.is_on_floor()

func _activate():
	_body.velocity.y = jump_velocity
