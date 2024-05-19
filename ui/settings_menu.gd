class_name SettingsMenu extends PanelContainer

@onready var _master_bus = AudioServer.get_bus_index("Master")
@onready var _music_bus = AudioServer.get_bus_index("Music")
@onready var _fx_bus = AudioServer.get_bus_index("Effects")

static var _wobble_intensity: float = 1

func _ready():
	get_window().size_changed.connect(_refresh)
	_refresh()
	%CloseButton.pressed.connect(close)
	%FullscreenButton.pressed.connect(GameInstance.toggle_fullscreen)
	%WobbleSlider.value_changed.connect(
		func (value: float):
			RenderingServer.global_shader_parameter_set("global_wobble_intensity", value)
			SettingsMenu._wobble_intensity = value
	)
	%AASlider.value_changed.connect(
		func (value: float):
			match int(round(value)):
				2:
					get_viewport().use_taa = false
					get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
				1:
					get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
					get_viewport().use_taa = true
				_:
					get_viewport().use_taa = false
					get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	)
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
	%WobbleSlider.value = SettingsMenu._wobble_intensity
	%MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(_master_bus))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(_music_bus))
	%EffectsSlider.value = db_to_linear(AudioServer.get_bus_volume_db(_fx_bus))
	if get_viewport().scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR2:
		%AASlider.value = 2
	elif get_viewport().use_taa:
		%AASlider.value = 1
	else:
		%AASlider.value = 0
