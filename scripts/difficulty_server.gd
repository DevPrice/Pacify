extends Node

signal difficulty_changed(new_difficulty: Difficulty)

@export var easy: Difficulty
@export var normal: Difficulty
@export var hard: Difficulty

@onready var current_difficulty: Difficulty = normal:
	get: return current_difficulty
	set(value):
		current_difficulty = value
		difficulty_changed.emit(value)
