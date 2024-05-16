class_name AbilityIndicator extends Control

@export var ability: Ability:
	get: return ability
	set(value):
		ability = value
		if is_node_ready(): _update_icon()

func _ready():
	_update_icon()
	_update_cooldown()

func _process(_delta):
	_update_cooldown()

func _update_icon() -> void:
	if ability and ability.icon:
		%Icon.texture = ability.icon
	else:
		%Icon.texture = null

func _update_cooldown() -> void:
	var cd_material = %CooldownContainer.material
	if ability and cd_material:
		cd_material.set_shader_parameter("cooldown_percent", ability.cooldown_percent())
