extends Node

@export var default_track: AudioStream

func _ready():
	if default_track: cross_fade(default_track, 0)

func cross_fade(track: AudioStream, duration: float = 4):
	for player in get_children():
		if track == player.stream: return
		if duration > 0:
			var out_tween = get_tree().create_tween()
			out_tween.tween_property(player, "volume_db", -60, duration).set_trans(Tween.TRANS_QUAD)
			out_tween.finished.connect(player.queue_free)
		else:
			player.queue_free()
	var track_player = AudioStreamPlayer.new()
	track_player.stream = track
	track_player.autoplay = true
	track_player.bus = "Music"
	add_child(track_player)
	if duration > 0:
		var in_tween = get_tree().create_tween()
		in_tween.tween_property(track_player, "volume_db", 0, duration).set_trans(Tween.TRANS_QUAD)
