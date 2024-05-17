class_name GhostSpawn extends Resource

@export_color_no_alpha var color: Color
@export var location: Vector3i
@export var delay_seconds: float
@export var wander_location: Vector3i
@export var chase_interval: float = 7
@export_file("*.dch") var dialog_character: String
@export var victory_dialogs: Array[LevelDialog]
