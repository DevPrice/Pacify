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

var mode: Mode = Mode.IDLE

func _ready():
	_update_color()

func _process(_delta):
	if target:
		%NavigationAgent.target_position = target.global_position

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
	for geometry in %Body.find_children("*", "GeometryInstance3D"):
		if geometry is GeometryInstance3D:
			geometry.set_instance_shader_parameter("modulate", ghost_color)

enum Mode { IDLE, WANDER, CHASE, FLEE }
