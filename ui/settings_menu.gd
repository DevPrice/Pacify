class_name SettingsMenu extends PanelContainer

@onready var _master_bus = AudioServer.get_bus_index("Master")
@onready var _music_bus = AudioServer.get_bus_index("Music")
@onready var _fx_bus = AudioServer.get_bus_index("Effects")

func _ready():
	get_window().size_changed.connect(_refresh)
	_refresh()
	%CloseButton.pressed.connect(close)
	%FullscreenButton.pressed.connect(GameInstance.toggle_fullscreen)
	%MasterSlider.value_changed.connect(
		func (value: float):
			AudioServer.set_bus_volume_db(_master_bus, linear_to_db(value))
	)
	%MusicSlider.value_changed.connect(
		func (value: float):
			AudioServer.set_bus_volume_db(_music_bus, linear_to_db(value))
	)
	%EffectsSlider.value_changed.connect(
		func (value: float):
			AudioServer.set_bus_volume_db(_fx_bus, linear_to_db(value))
	)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func close():
	queue_free()

func _refresh():
	var window = get_window()
	%FullscreenButton.button_pressed = window and window.mode == Window.MODE_FULLSCREEN
	%MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(_master_bus))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(_music_bus))
	%EffectsSlider.value = db_to_linear(AudioServer.get_bus_volume_db(_fx_bus))
