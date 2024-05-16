class_name AbilityIndicator extends Control

@export var ability: Ability:
	get: return ability
	set(value):
		if ability: ability.activated.disconnect(_on_activated)
		ability = value
		if ability: ability.activated.connect(_on_activated)
		if is_node_ready(): _update_icon()

var _was_ready := true

func _ready():
	_update_icon()
	_update_cooldown()

func _process(_delta):
	_update_cooldown()
	if ability:
		var is_ready = ability.cooldown_percent() >= 1
		if !_was_ready and is_ready:
			_on_ability_ready()
		_was_ready = is_ready

func _update_icon() -> void:
	if ability and ability.icon:
		%Icon.texture = ability.icon
	else:
		%Icon.texture = null

func _update_cooldown() -> void:
	var cd_material = %CooldownContainer.material
	if ability and cd_material:
		cd_material.set_shader_parameter("cooldown_percent", ability.cooldown_percent())

func _on_activated() -> void:
	%AnimationPlayer.play("activated")

func _on_ability_ready() -> void:
	%AnimationPlayer.play("ability_ready")
