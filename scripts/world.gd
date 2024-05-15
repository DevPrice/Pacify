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
	%Character.process_mode = PROCESS_MODE_DISABLED
	start_next_level()

func start_current_level() -> void:
	var level = _current_level
	if level:
		level.level_completed.connect(start_next_level)
		level.start_level()

func start_next_level() -> void:
	var level = _current_level
	if level:
		level.clear_level()
	_current_level_index += 1
	var next_level = _current_level
	if next_level:
		next_level.level_failed.connect(_on_level_failed)
		await next_level.start_level()
	%Character.process_mode = PROCESS_MODE_PAUSABLE

func _on_level_failed():
	var level = _current_level
	if level:
		level.clear_level()
		%Character.process_mode = PROCESS_MODE_DISABLED
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()
