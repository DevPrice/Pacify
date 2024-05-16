extends Node3D

@export var _paused_scene: PackedScene
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
	await %MainMenu.start_pressed
	%MainMenu.dismiss()
	GameInstance.pausable = true
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
	%Character.process_mode = Node.PROCESS_MODE_INHERIT

func _on_level_failed():
	var level = _current_level
	if level:
		%Character.process_mode = PROCESS_MODE_DISABLED
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()

func _notification(what):
	if what == NOTIFICATION_PAUSED:
		var existing_menu = %UI.get_node_or_null("PauseMenu")
		if existing_menu:
			existing_menu.free()
		if _paused_scene:
			var pause_menu: PauseMenu = _paused_scene.instantiate()
			pause_menu.name = "PauseMenu"
			%UI.add_child(pause_menu)
			pause_menu.appear()
	if what == NOTIFICATION_UNPAUSED:
		var pause_menu = %UI.get_node_or_null("PauseMenu")
		if pause_menu:
			pause_menu.dismiss()
