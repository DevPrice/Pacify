class_name Ability extends Node

@export var cooldown_seconds = 0

var _remaining_cooldown = 0

func _physics_process(delta):
	_remaining_cooldown = move_toward(_remaining_cooldown, 0, delta)

func can_activate() -> bool:
	return _remaining_cooldown <= 0

func try_activate() -> bool:
	if can_activate():
		_activate()
		_fx()
		_remaining_cooldown = cooldown_seconds
		return true
	return false

func _activate() -> void:
	pass

func _fx() -> void:
	for audio in find_children("*", "AudioStreamPlayer", false):
		audio.play()
