class_name PauseMenu extends PanelContainer

func _ready():
	%ResumeButton.pressed.connect(_on_resume)
	%QuitToMenuButton.pressed.connect(_on_quit_to_menu)

func _on_resume():
	get_tree().paused = false

func _on_quit_to_menu():
	get_tree().paused = false
	get_tree().reload_current_scene()

func appear() -> void:
	%UIAnimations.play("show")

func dismiss() -> void:
	%UIAnimations.play("dismiss")
