extends Node3D

@export var _levels: Array[Level] = []

var _current_level_index: int = -1
var _current_level: Level:
	get:
		if not _levels: return null
		var size = _levels.size()
		if size < 1 or _current_level_index < 0 or _current_level_index > size: return null
		return _levels[_current_level_index]

func _ready():
	await get_tree().create_timer(2.0).timeout
	start_next_level()
	var ghosts = find_children("*", "Ghost", false)
	for ghost in ghosts:
		ghost.mode = Ghost.Mode.CHASE

func start_current_level() -> void:
	var level = _current_level
	if level:
		level.start_level()

func start_next_level() -> void:
	var level = _current_level
	if level:
		level.clear_level()
	_current_level_index += 1
	var next_level = _current_level
	if next_level:
		next_level.start_level()
