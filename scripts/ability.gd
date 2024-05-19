class_name Ability extends Node

@export var cooldown_seconds: float = 0
@export var icon: Texture2D

var remaining_cooldown: float = 0

signal activated

func _physics_process(delta):
	remaining_cooldown = move_toward(remaining_cooldown, 0, delta)

func can_activate() -> bool:
	return remaining_cooldown <= 0

func try_activate() -> bool:
	if can_activate():
		_activate()
		_fx()
		remaining_cooldown = cooldown_seconds * DifficultyServer.current_difficulty.cooldown_scale
		activated.emit()
		return true
	return false

func _activate() -> void:
	pass

func _fx() -> void:
	for audio in find_children("*", "AudioStreamPlayer", false):
		audio.play()

func cooldown_percent() -> float:
	if cooldown_seconds <= 0: return 1
	return 1 - remaining_cooldown / (cooldown_seconds * DifficultyServer.current_difficulty.cooldown_scale)
