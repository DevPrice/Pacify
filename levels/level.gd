class_name Level extends Node3D

@export var pellet_scene: PackedScene
@export var map: GridMap

signal pellets_remaining_changed
signal level_completed

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

func start_level() -> void:
	clear_level()
	_spawn_pellets()

func clear_level() -> void:
	get_tree().call_group("pellet", "free")
