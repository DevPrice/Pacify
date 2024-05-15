class_name Pellet extends Area3D

signal consumed

@export var _consume_effect: PackedScene

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	scale = Vector3.ONE * .01
	%AnimationPlayer.play("spawn")

func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		_on_character_entered(body)

func _on_character_entered(_character: Character) -> void:
	_consume()
	if _consume_effect:
		var fx = _consume_effect.instantiate()
		get_parent_node_3d().add_child(fx)
		if fx is Node3D:
			fx.global_position = %Collision.global_position
		if fx is GPUParticles3D:
			fx.emitting = true
			fx.finished.connect(queue_free)

func _consume() -> void:
	consumed.emit()
	queue_free()
