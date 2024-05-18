extends Node3D

@export var _paused_scene: PackedScene
@export var _ability_indicator_scene: PackedScene
@export var _levels: Array[Level] = []

var _current_level_index: int = 0
var _current_level: Level:
	get:
		if not _levels: return null
		var size = _levels.size()
		if size < 1 or _current_level_index < 0 or _current_level_index >= size: return null
		return _levels[_current_level_index]

func _ready():
	%Character.process_mode = PROCESS_MODE_DISABLED
	await %MainMenu.start_pressed
	%MainMenu.dismiss()
	start_next_level()
	_init_hud()
	%Ground.body_entered.connect(
		func (body: Node3D):
			if body is Character: _on_level_failed()
	)

func _init_hud():
	%Hud.visible = true

	if _ability_indicator_scene:
		for ability in %Character.find_children("*", "Ability", false):
			var ability_indicator: AbilityIndicator = _ability_indicator_scene.instantiate()
			ability_indicator.ability = ability
			%Hud.add_ability(ability_indicator)

func start_next_level() -> void:
	var level = _current_level
	if level: level.clear_level()
	_current_level_index += 1
	var next_level = _current_level
	if next_level:
		_start_level(next_level)
	else:
		pass # SHOW VICTORY SCREEN

func _start_level(level: Level) -> void:
	GameInstance.pausable = true
	level.level_completed.connect(start_next_level)
	level.level_failed.connect(_on_level_failed)
	%Character.process_mode = PROCESS_MODE_DISABLED
	await level.start_level()
	%Character.process_mode = Node.PROCESS_MODE_INHERIT

func _on_level_failed():
	GameInstance.pausable = false
	%Character.process_mode = PROCESS_MODE_DISABLED
	var level = _current_level
	if level:
		level.level_completed.disconnect(start_next_level)
		level.level_failed.disconnect(_on_level_failed)
		await get_tree().create_timer(2.0).timeout
		_start_level(level)

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
