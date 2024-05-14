class_name Ghost extends CharacterBody3D

@export var movement_speed: float = 3.0
@export var jump_velocity: float = 4.5
@export var mass: float = 0.1
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export_color_no_alpha var ghost_color: Color = Color.WHITE:
	get: return ghost_color
	set(value):
		ghost_color = value
		if is_node_ready(): _update_color()

func _ready():
	_update_color()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = _get_movement()
	if direction:
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)

	move_and_slide()

func _get_movement() -> Vector3:
	return Vector3.ZERO

func _update_color() -> void:
	for geometry in %Body.find_children("*", "GeometryInstance3D"):
		if geometry is GeometryInstance3D:
			geometry.set_instance_shader_parameter("modulate", ghost_color)
