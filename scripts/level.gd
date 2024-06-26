class_name Level extends Node3D

@export var pellet_scene: PackedScene
@export var power_pellet_scene: PackedScene
@export var ghost_scene: PackedScene
@export var map: GridMap
@export var ghost_spawns: Array[GhostSpawn] = []
@export var begin_dialogs: Array[LevelDialog] = []
@export var end_dialogs: Array[LevelDialog] = []
@export var _player: Character
@export var initial_dialog: LevelDialog
@export var music: AudioStream
@export var easy_mode_dialog: LevelDialog

signal pellets_remaining_changed(remaining: int)
signal level_completed
signal level_failed

var completion_time: float = 0

var _nav_ready := false
var _attempts: int = 0
var _victories: int = 0
var _duration: float = 0

var remaining_pellets: int = 0

func _ready():
	await NavigationServer3D.map_changed
	_nav_ready = true

func _physics_process(delta):
	_duration += delta

func _spawn_pellets() -> void:
	if not _nav_ready: await NavigationServer3D.map_changed

	var player_tile_location := map.local_to_map(_player.global_position - global_position)

	var power_pellet_locations := %PowerPellets.find_children("*", "Node3D").map(
		func (child: Node3D):
			return map.local_to_map(child.position)
	)

	var cells := map.get_used_cells()
	cells.sort_custom(
		func (a: Vector3i, b: Vector3i):
			if a.x != b.x:
				return a.x < b.x
			if a.z != b.z:
				return a.z > b.z
			return a.y < b.y
	)

	if map and pellet_scene:
		for tile_location in cells:
			if tile_location == player_tile_location or (tile_location.x == 0 and tile_location.y == 0 and abs(tile_location.z) <= 1): continue
			var local_position = map.map_to_local(tile_location)
			var pos = map.map_to_local(tile_location) + global_position
			var closest_point = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, pos)
			if pos.distance_to(closest_point) < .5:
				if power_pellet_locations.has(tile_location):
					_spawn_power_pellet(local_position)
				else:
					pass
					_spawn_pellet(local_position)
				await get_tree().create_timer(.016, false).timeout

	await get_tree().create_timer(1, false).timeout

func _spawn_pellet(at: Vector3) -> void:
	var pellet: Pellet = pellet_scene.instantiate()
	pellet.position = at
	add_child(pellet)
	remaining_pellets += 1
	pellet.consumed.connect(_on_pellet_consumed)
	pellet.add_to_group("pellet")

func _spawn_power_pellet(at: Vector3) -> void:
	var pellet: Pellet = power_pellet_scene.instantiate()
	pellet.position = at
	add_child(pellet)
	remaining_pellets += 1
	pellet.consumed.connect(_on_power_pellet_consumed)
	pellet.add_to_group("pellet")

func _on_pellet_consumed():
	remaining_pellets -= 1
	if remaining_pellets <= 0:
		_on_level_completed()

func _spawn_ghosts() -> void:
	if not ghost_scene or not map: return
	for ghost_spawn in ghost_spawns:
		var ghost: Ghost = ghost_scene.instantiate()
		ghost.spawn_settings = ghost_spawn
		ghost.position = map.map_to_local(ghost_spawn.location) + Vector3(0, -.5, 0)
		ghost.ghost_color = ghost_spawn.color
		ghost.target = _player
		ghost.wander_position = map.map_to_local(ghost_spawn.wander_location) + global_position
		add_child(ghost)
		ghost.add_to_group("ghost")
		ghost.touched_character.connect(
			func (character: Character):
				_on_ghost_touched_character(ghost, character)
		)
		if ghost_spawn.delay_seconds > 0:
			var timer = Timer.new()
			timer.one_shot = true
			timer.autostart = true
			timer.wait_time = ghost_spawn.delay_seconds * DifficultyServer.current_difficulty.ghost_spawn_delay_scale
			timer.timeout.connect(func (): ghost.start(ghost_spawn.chase_interval))
			ghost.add_child(timer)
		else:
			ghost.start(ghost_spawn.chase_interval)

func start_level() -> void:
	clear_level()
	await _reset_player()
	_spawn_ghosts()
	get_tree().set_group("ghost", "process_mode", PROCESS_MODE_DISABLED)
	await get_tree().create_timer(1.0).timeout
	var dialog = _get_begin_dialog()
	if dialog:
		await get_tree().create_timer(1.0).timeout
		await _play_timeline(dialog.timeline)
	await _spawn_pellets()
	get_tree().set_group("ghost", "process_mode", PROCESS_MODE_INHERIT)
	_duration = 0
	_attempts += 1

func clear_level() -> void:
	remaining_pellets = 0
	get_tree().call_group("pellet", "queue_free")
	get_tree().call_group("ghost", "queue_free")

func _reset_player() -> void:
	if not _player or not %PlayerSpawn: return

	_player.reset()
	if _player.global_position.distance_to(%PlayerSpawn.global_position) > .1:
		var tween = create_tween()
		tween.tween_property(_player, "global_position", %PlayerSpawn.global_position, .25)
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		await tween.finished

func _on_ghost_touched_character(ghost: Ghost, character: Character):
	if character == _player:
		var ghosts = get_tree().get_nodes_in_group("ghost")
		if ghost.mode == Ghost.Mode.FLEE:
			_on_ghost_eaten(ghost)
		elif ghost.mode != Ghost.Mode.RESPAWN:
			for g in ghosts:
				g.mode = Ghost.Mode.IDLE
			%LoseSound.play()
			_player.process_mode = Node.PROCESS_MODE_DISABLED
			if ghost.spawn_settings and ghost.spawn_settings.victory_dialogs and ghost.spawn_settings.victory_dialogs.size() > 0:
				var dialog = ghost.spawn_settings.victory_dialogs.pick_random()
				for g in ghosts:
					if g == ghost:
						g.call_deferred("set", "process_mode", PROCESS_MODE_DISABLED)
					else:
						g.process_mode = PROCESS_MODE_DISABLED
				await _play_timeline(dialog.timeline)
			level_failed.emit()

func _play_timeline(timeline):
	Dialogic.VAR.attempts = _attempts
	Dialogic.VAR.victories = _victories
	var layout := Dialogic.start(timeline)
	if _player: _player.register_character(layout)
	var ghosts = get_tree().get_nodes_in_group("ghost")
	for g in ghosts:
		g.register_character(layout)
	await Dialogic.timeline_ended

func _on_power_pellet_consumed():
	_on_pellet_consumed()
	var existing_timer := get_node_or_null("FleeTimer")
	if existing_timer: existing_timer.queue_free()

	var ghosts := get_tree().get_nodes_in_group("ghost")
	for g in ghosts:
		if g.mode != Ghost.Mode.IDLE:
			g.mode = Ghost.Mode.FLEE
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 4
	timer.autostart = true
	timer.name = "FleeTimer"
	add_child(timer)
	timer.timeout.connect(_end_flee)

func _end_flee():
	var ghosts := get_tree().get_nodes_in_group("ghost")
	for g in ghosts:
		if g.mode == Ghost.Mode.FLEE:
			g.mode = Ghost.Mode.CHASE if randf() < .5 else Ghost.Mode.WANDER

func _on_ghost_eaten(ghost: Ghost):
	ghost.mode = Ghost.Mode.RESPAWN
	%GhostConsumeSound.play()
	Engine.time_scale = .05
	await get_tree().create_timer(.2, true, false, true).timeout
	Engine.time_scale = 1

func _get_begin_dialog():
	if _attempts == 0 and initial_dialog: return initial_dialog
	if _attempts % 3 == 0 and _victories == 0 and DifficultyServer.current_difficulty == DifficultyServer.normal: return easy_mode_dialog
	if begin_dialogs and begin_dialogs.size() > 0: return begin_dialogs.pick_random()
	return null

func _get_end_dialog():
	if end_dialogs and end_dialogs.size() > 0: return end_dialogs.pick_random()
	return null

func _on_level_completed():
	completion_time = _duration
	get_tree().set_group("ghost", "process_mode", PROCESS_MODE_DISABLED)
	_player.process_mode = PROCESS_MODE_DISABLED
	MusicPlayer.stop_music()
	await get_tree().create_timer(1.0).timeout
	var dialog = _get_end_dialog()
	if dialog:
		await get_tree().create_timer(1.0).timeout
		await _play_timeline(dialog.timeline)
	get_tree().call_group("ghost", "shrink")
	await get_tree().create_timer(2.0).timeout
	_victories += 1
	level_completed.emit()
