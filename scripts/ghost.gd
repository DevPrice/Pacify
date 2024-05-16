class_name Ghost extends CharacterBody3D

@export var movement_speed: float = 3.0
@export var mass: float = 0.1
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_color_no_alpha var ghost_color: Color = Color.WHITE:
	get: return ghost_color
	set(value):
		ghost_color = value
		if is_node_ready(): _update_color()

@export var target: Node3D
@export var wander_position: Vector3

var mode: Mode = Mode.IDLE

signal touched_character(character: Character)

func _ready():
	_update_color()
	%TouchArea.body_entered.connect(
		func (body: Node3D):
			if body is Character:
				touched_character.emit(body)
	)
	_set_shader_params("seed", randf())
	_face_camera()

func _process(_delta):
	if mode == Mode.CHASE and target:
		%NavigationAgent.target_position = target.global_position
	elif mode == Mode.WANDER and global_position.distance_to(%NavigationAgent.target_position) < 1:
		var random_nearby = Vector3(randf() * 16 - 8, 0, randf() * 16 - 8)
		%NavigationAgent.target_position = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, global_position + random_nearby)
	elif mode == Mode.FLEE and target:
		%NavigationAgent.target_position = _find_flee_target()
	_face_camera()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = _get_movement()
	if direction:
		velocity = direction * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)

	move_and_slide()

func _get_movement() -> Vector3:
	if not is_node_ready() or not target or mode == Mode.IDLE: return Vector3.ZERO

	var target_position = %NavigationAgent.target_position
	var distance_to_target = (target_position - global_position).length()
	if distance_to_target < .5: return Vector3.ZERO

	var next_path = %NavigationAgent.get_next_path_position()
	if not next_path: return Vector3.ZERO

	return (next_path - global_position).normalized()

func _update_color() -> void:
	_set_shader_params("modulate", ghost_color)

func _set_shader_params(param: String, value: Variant):
	for geometry in %Body.find_children("*", "GeometryInstance3D"):
		if geometry is GeometryInstance3D:
			geometry.set_instance_shader_parameter(param, value)

func start(wait_time: float) -> void:
	mode = Ghost.Mode.CHASE
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.autostart = true
	timer.timeout.connect(_change_mode)
	add_child(timer)

func _change_mode() -> void:
	match mode:
		Mode.WANDER:
			mode = Mode.CHASE
		Mode.CHASE:
			mode = Mode.WANDER
			%NavigationAgent.target_position = wander_position

func _face_camera() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera:
		var direction: Vector3 = Basis(Vector3.UP, camera.global_rotation.y) * Vector3.BACK
		%Body.look_at(%Body.global_position + Vector3(direction.x, %Body.position.y, direction.z))

func _find_flee_target() -> Vector3:
	if not target: return global_position

	var direction := (global_position - target.global_position).normalized()

	if global_position.distance_to(target.global_position) < 5:
		var test_point := NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, global_position + direction * 5)
		if test_point.distance_to(global_position) > 1:
			return test_point

	var test_points := [
		Vector3(10, 0, 0),
		Vector3(0, 0, 10),
		Vector3(-10, 0, 0),
		Vector3(0, 0, -10),
	].map(
		func (test_point: Vector3):
			return NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, global_position + test_point)
	)
	test_points.sort_custom(
		func (a: Vector3, b: Vector3) -> bool:
			return a.distance_squared_to(target.global_position) > b.distance_squared_to(target.global_position)
	)
	return test_points[0]

enum Mode { IDLE, WANDER, CHASE, FLEE }
