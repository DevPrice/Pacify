extends Node

@export var default_track: AudioStream

func _ready():
	play_default()

func play_default():
	if default_track: cross_fade(default_track, 0)

func cross_fade(track: AudioStream, duration: float = 4):
	for player in get_children():
		if track == player.stream and not player.has_meta("audio_transient"): return
		_fade_out(player, duration)
	_fade_in(track, duration)

func _fade_in(track: AudioStream, duration: float = 4):
	var track_player = AudioStreamPlayer.new()
	track_player.stream = track
	track_player.autoplay = true
	track_player.bus = "Music"
	track_player.process_mode = PROCESS_MODE_ALWAYS
	add_child(track_player)
	if duration > 0:
		var in_tween = get_tree().create_tween()
		in_tween.tween_property(track_player, "volume_db", 0, duration).set_trans(Tween.TRANS_QUAD)

func _fade_out(player: AudioStreamPlayer, fade_duration: float = 4):
	if fade_duration > 0:
		var out_tween = get_tree().create_tween()
		out_tween.tween_property(player, "volume_db", -60, fade_duration).set_trans(Tween.TRANS_QUAD)
		out_tween.finished.connect(player.queue_free)
		player.set_meta("audio_transient", true)
	else:
		player.queue_free()

func stop_music(fade_duration: float = 4):
	for player in get_children():
		_fade_out(player, fade_duration)
