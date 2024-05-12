extends CharacterBody3D

@export var movement_speed = 6.0
@export var jump_velocity = 4.5
@export var mass = 1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var movement_basis = get_viewport().get_camera_3d().global_basis
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (movement_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)
	if direction:
		%Body.look_at(%Body.global_position + Vector3(direction.x, %Body.position.y, direction.z))

	var speed = velocity.length()

	if move_and_slide():
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody3D:
				c.get_collider().apply_impulse(-c.get_normal() * mass * speed, c.get_position())

func _input(event):
	if event.is_action_pressed("camera_left"):
		_rotate_camera(-PI / 2)
	if event.is_action_pressed("camera_right"):
		_rotate_camera(PI / 2)

func _rotate_camera(amount: float):
	var tween = create_tween()
	tween.tween_property(%CameraArm, "rotation", %CameraArm.rotation + Vector3(0, amount, 0), .2) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
