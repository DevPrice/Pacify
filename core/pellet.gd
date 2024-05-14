class_name Pellet extends Area3D

signal consumed

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		_on_character_entered(body)

func _on_character_entered(character: Character) -> void:
	print("Character entered!")
	_consume()

func _consume() -> void:
	consumed.emit()
	queue_free()
