class_name Level extends Node3D

@export var pellet_scene: PackedScene
@export var ghost_scene: PackedScene
@export var map: GridMap
@export var ghost_spawns: Array[GhostSpawn] = []
@export var _player: Character

signal pellets_remaining_changed(remaining: int)
signal level_completed
signal level_failed

var _nav_ready = false

var remaining_pellets: int = 0:
	get: return remaining_pellets
	set(value):
		var win = remaining_pellets > 0 and value <= 0
		remaining_pellets = value
		pellets_remaining_changed.emit(value)
		if win: level_completed.emit()

func _ready():
	await NavigationServer3D.map_changed
	_nav_ready = true

func _spawn_pellets() -> void:
	if not _nav_ready: await NavigationServer3D.map_changed

	if map and pellet_scene:
		for tile_location in map.get_used_cells():
			if tile_location.x == 0 and tile_location.y == 0 and abs(tile_location.z) <= 1: continue
			var local_position = map.map_to_local(tile_location)
			var pos = map.map_to_local(tile_location) + global_position
			var closest_point = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, pos)
			if pos.distance_to(closest_point) < .5:
				_spawn_pellet(local_position)

func _spawn_pellet(at: Vector3) -> void:
	var pellet: Pellet = pellet_scene.instantiate()
	pellet.position = at
	add_child(pellet)
	remaining_pellets += 1
	pellet.tree_exited.connect(func (): remaining_pellets -= 1)
	pellet.add_to_group("pellet")

func _spawn_ghosts() -> void:
	if not ghost_scene or not map: return
	for ghost_spawn in ghost_spawns:
		var ghost: Ghost = ghost_scene.instantiate()
		ghost.position = map.map_to_local(ghost_spawn.location) + Vector3(0, -.5, 0)
		ghost.ghost_color = ghost_spawn.color
		ghost.target = _player
		ghost.wander_position = map.map_to_local(ghost_spawn.wander_location) + global_position
		add_child(ghost)
		ghost.add_to_group("ghost")
		ghost.touched_character.connect(_on_ghost_touched_character)
		if ghost_spawn.delay_seconds > 0:
			var timer = Timer.new()
			timer.one_shot = true
			timer.autostart = true
			timer.wait_time = ghost_spawn.delay_seconds
			timer.timeout.connect(func (): ghost.start(ghost_spawn.chase_interval))
			ghost.add_child(timer)
		else:
			ghost.start(ghost_spawn.chase_interval)

func start_level() -> void:
	clear_level()
	_spawn_pellets()
	_spawn_ghosts()

func clear_level() -> void:
	get_tree().call_group("pellet", "queue_free")
	get_tree().call_group("ghost", "queue_free")

func _on_ghost_touched_character(character: Character):
	if character == _player:
		level_failed.emit()