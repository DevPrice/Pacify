class_name MainMenu extends PanelContainer

signal start_pressed
signal settings_pressed

var _dismissing := false

func _ready():
	%Title.text = ProjectSettings.get_setting_with_override("application/config/name")
	%StartButton.pressed.connect(_on_start)
	%SettingsButton.pressed.connect(_on_settings)
	%ExitButton.pressed.connect(_on_exit)

func _on_start():
	if not _dismissing: start_pressed.emit()

func _on_exit():
	if not _dismissing: get_tree().quit()

func _on_settings():
	if not _dismissing: settings_pressed.emit()

func dismiss() -> void:
	_dismissing = true
	%UIAnimations.play("dismiss")
	get_tree().create_timer(2, true, false, true).timeout.connect(queue_free)
