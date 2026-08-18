class_name EntityView
extends Control



signal pressed()
signal updated()


@export var _button: Button
@export var _icon: TextureRect
@export var _name_label: AutoFitLabel

var _current_entity: GameEntity
var current_entity: GameEntity:
	get:
		return _current_entity


func _ready() -> void:
	_button.pressed.connect(pressed.emit)


func set_visual(entity: GameEntity) -> void:
	if (entity == null):
		return

	_current_entity = entity

	_icon.texture = entity.icon
	_name_label.text = entity.name

	updated.emit()
