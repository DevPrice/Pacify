class_name PauseMenu extends PanelContainer

signal settings_pressed

var _dismissing := false

func _ready():
	%ResumeButton.pressed.connect(_on_resume)
	%SettingsButton.pressed.connect(_on_settings)
	%QuitToMenuButton.pressed.connect(_on_quit_to_menu)

func _on_settings():
	if not _dismissing: settings_pressed.emit()

func _on_resume():
	if not _dismissing: get_tree().paused = false

func _on_quit_to_menu():
	if _dismissing: return
	get_tree().paused = false
	get_tree().reload_current_scene()

func appear() -> void:
	%UIAnimations.play("show")

func dismiss() -> void:
	_dismissing = true
	%UIAnimations.play("dismiss")
