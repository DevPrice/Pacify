class_name MainMenu extends PanelContainer

signal start_pressed

func _ready():
	%StartButton.pressed.connect(_on_start)
	%ExitButton.pressed.connect(_on_exit)

func _on_start():
	start_pressed.emit()

func _on_exit():
	get_tree().quit()

func dismiss() -> void:
	%AnimationPlayer.play("dismiss")
	await %AnimationPlayer.animation_finished
	queue_free()
