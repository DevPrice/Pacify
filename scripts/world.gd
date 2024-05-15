extends Node3D

@export var _levels: Array[Level] = []

var _current_level_index: int = 0
var _current_level: Level:
	get:
		if not _levels or _levels.size() == 0: return null
		return _levels[_current_level_index]

func _ready():
	await get_tree().create_timer(2.0).timeout
	var level = _current_level
	if level:
		level.start_level()
	var ghosts = find_children("*", "Ghost", false)
	for ghost in ghosts:
		ghost.mode = Ghost.Mode.CHASE
