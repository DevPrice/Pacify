class_name Pellet extends Area3D

signal consumed

@export var _consume_effect: PackedScene
@export var _consume_sound: AudioStream

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	scale = Vector3.ONE * .01
	%AnimationPlayer.play("spawn")

func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		_on_character_entered(body)

func _on_character_entered(_character: Character) -> void:
	if _consume_effect:
		var fx = _consume_effect.instantiate()
		if fx is GPUParticles3D:
			fx.emitting = true
			fx.finished.connect(fx.queue_free)
		add_sibling(fx)
		if fx is Node3D:
			fx.global_position = %Collision.global_position
	if _consume_sound:
		var player = AudioStreamPlayer.new()
		player.stream = _consume_sound
		player.autoplay = true
		player.bus = "Effects"
		player.finished.connect(player.queue_free)
		add_sibling(player)
	_consume()

func _consume() -> void:
	consumed.emit()
	queue_free()
