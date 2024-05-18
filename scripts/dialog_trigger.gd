extends Area3D

@export_file("*.dtl") var dialog: String

var _triggered := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if not _triggered and dialog and body is Character:
		_triggered = true
		var layout = Dialogic.start(dialog)
		body.register_character(layout)
		body.process_mode = PROCESS_MODE_DISABLED
		await Dialogic.timeline_ended
		body.process_mode = PROCESS_MODE_INHERIT
