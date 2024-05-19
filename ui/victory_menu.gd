class_name VictoryMenu extends PanelContainer

signal play_again

func _ready():
	%TryAgainButton.pressed.connect(_on_try_again)
	%QuitToMenuButton.pressed.connect(_on_quit_to_menu)

func _on_try_again():
	play_again.emit()

func _on_quit_to_menu():
	get_tree().reload_current_scene()

func set_completion_time(completion_time: float):
	var minutes: int = int(completion_time) / 60
	var seconds: int = fmod(completion_time, 60)
	
	if completion_time < 60:
		var time_string := "%2d:%02d" % [minutes, int(seconds)]
		%StatsLabel.text = "Completed in %s." % time_string
	else:
		var time_string := "%2d:%0.3f" % [minutes, seconds]
		%StatsLabel.text = "Completed in %s." % time_string

func appear() -> void:
	%UIAnimations.play("show")

func dismiss() -> void:
	%UIAnimations.play("dismiss")
