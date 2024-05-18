class_name TutorialLevel extends Level

@export var _completion_zone: Area3D
@export_file("*.dtl") var _pellet_consume_dialog: String

func _ready():
	if _completion_zone:
		_completion_zone.body_entered.connect(
			func (body: Node3D):
				if body == _player:
					level_completed.emit()
		)

func _update_player_spawn():
	if %PlayerSpawn and _player and _player.is_on_floor():
		%PlayerSpawn.global_position = _player.global_position

func _on_pellet_consumed():
	if _pellet_consume_dialog and _player:
		var layout = Dialogic.start(_pellet_consume_dialog)
		_player.register_character(layout)
		_player.process_mode = PROCESS_MODE_DISABLED
		await Dialogic.timeline_ended
		_player.process_mode = PROCESS_MODE_INHERIT

func _spawn_ghosts():
	pass

func _spawn_pellets():
	pass
