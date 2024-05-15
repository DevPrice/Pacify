class_name Level extends Node3D

@export var pellet_scene: PackedScene
@export var map: GridMap

signal pellets_remaining_changed
signal level_completed

var remaining_pellets: int = 0:
	get: return remaining_pellets
	set(value):
		var win = remaining_pellets > 0 and value <= 0
		remaining_pellets = value
		pellets_remaining_changed.emit(value)
		if win: level_completed.emit()

func _ready():
	await NavigationServer3D.map_changed
	_spawn_pellets()

func _spawn_pellets() -> void:
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
	pellet.consumed.connect(func (): remaining_pellets -= 1)
