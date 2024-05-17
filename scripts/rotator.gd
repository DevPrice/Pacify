extends Node3D

@export var rotation_speed := Vector3(0, 0, 0)

func _process(delta: float):
	rotation += rotation_speed * delta
