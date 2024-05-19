class_name MainMenu extends PanelContainer

signal start_pressed
signal settings_pressed

func _ready():
	%Title.text = ProjectSettings.get_setting_with_override("application/config/name")
	%StartButton.pressed.connect(_on_start)
	%SettingsButton.pressed.connect(_on_settings)
	%ExitButton.pressed.connect(_on_exit)

func _on_start():
	start_pressed.emit()

func _on_exit():
	get_tree().quit()

func _on_settings():
	settings_pressed.emit()

func dismiss() -> void:
	%UIAnimations.play("dismiss")
	await %UIAnimations.animation_finished
	queue_free()
