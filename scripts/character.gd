class_name Character extends CharacterBody3D

@export var movement_speed: float = 6.0
@export var mass: float = 0.1
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var jump_ability: Ability
@export_file("*.dch") var dialog_character: String

var _character_resource: Resource

var _camera_pos_index: int = 0

func _ready() -> void:
	_get_dialog_character()

func reset() -> void:
	velocity = Vector3.ZERO
	for ability in find_children("*", "Ability", false):
		ability.remaining_cooldown = 0
	_reset_camera()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir: Vector2 = _get_movement_input()
	var movement_strength: float = input_dir.length()

	var camera: Camera3D = get_viewport().get_camera_3d()
	var movement_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y)
	var raw_direction: Vector3 = movement_basis * Vector3(input_dir.x, 0, input_dir.y)
	var direction: Vector3 = raw_direction.normalized() * movement_strength

	if direction:
		%Body.look_at(%Body.global_position + Vector3(direction.x, %Body.position.y, direction.z))
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)

	var speed = velocity.length()
	var inertia = mass * speed
	var fall_velocity = abs(velocity.y) if velocity.y < -1 else 0

	if move_and_slide():
		if %LandSound and fall_velocity and abs(velocity.y) < .25:
			%LandSound.volume_db = lerpf(-20, -8, clampf(abs(fall_velocity) / 4.5, 0, 1))
			%LandSound.play()
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody3D:
				c.get_collider().apply_impulse(-c.get_normal() * inertia * .2, c.get_position())
				c.get_collider().apply_central_impulse(-c.get_normal() * inertia * .8)

func _input(event):
	if event.is_action_pressed("camera_left"):
		_rotate_camera(1)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("camera_right"):
		_rotate_camera(-1)
		get_viewport().set_input_as_handled()

func _rotate_camera(amount: int) -> void:
	_camera_pos_index += amount
	var tween = get_tree().create_tween()
	var result_rotation = _camera_pos_index * Vector3(0, PI / 2, 0)
	tween.tween_property(%CameraArm, "rotation", result_rotation, .2) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _reset_camera():
	var offset = _camera_pos_index % 4
	if offset < 2:
		_rotate_camera(-offset)
	else:
		_rotate_camera(4 - offset)

func _get_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _get_dialog_character() -> Resource:
	if not _character_resource:
		_character_resource = load(dialog_character)
	return _character_resource

func register_character(layout: Node) -> void:
	var c = _get_dialog_character()
	if c: layout.register_character(c, %DialogNode)
