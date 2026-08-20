class_name EntityView
extends Control



signal pressed()
signal updated()


@export var _button: Button
@export var icon: TextureRect
@export var name_label: AutoFitRichTextLabel

# var _current_entity: GameEntity
# var attached_entity: GameEntity:
# 	get:
# 		return _current_entity


func _ready() -> void:
	_button.pressed.connect(func(): print("Entity view pressed: %s" % name_label.fit_text))


# func set_visual(entity: GameEntity) -> void:
# 	if (entity == null):
# 		return

# 	_current_entity = entity

# 	_icon.texture = entity.icon
# 	_name_label.text = entity.name

# 	updated.emit()
