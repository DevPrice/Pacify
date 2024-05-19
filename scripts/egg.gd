extends Label

var _count := 0

func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		_count += 1
		if _count % 3 == 0:
			%AudioPlayer.play()
