class_name TutorialLevel extends Level

@export var completion_zone: Area3D

func _ready():
	if completion_zone:
		completion_zone.body_entered.connect(
			func (body: Node3D):
				if body == _player:
					level_completed.emit()
		)

func _update_player_spawn():
	if %PlayerSpawn and _player and _player.is_on_floor():
		%PlayerSpawn.global_position = _player.global_position

func _spawn_ghosts():
	pass

func _spawn_pellets():
	pass
