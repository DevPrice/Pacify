class_name TutorialLevel extends Level

func _spawn_ghosts():
	pass

func _spawn_pellets():
	pass

func _update_player_spawn():
	if %PlayerSpawn and _player and _player.is_on_floor():
		%PlayerSpawn.global_position = _player.global_position
