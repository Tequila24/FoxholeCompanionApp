class_name EntityView
extends Control



signal pressed()
signal updated()


@export var _button: Button
@export var icon: TextureRect
@export var name_label: AutoFitRichTextLabel

var attached_entity: GameEntity



func _ready() -> void:
	_button.pressed.connect(pressed.emit)
	

func set_visual(new_entity: GameEntity) -> void:
	if (new_entity == null):
		return

	attached_entity = new_entity

	var entity_texture: Resource 
	if (ResourceLoader.exists(Globals.ICONS_PATH + attached_entity.icon_path)):
		entity_texture = load(Globals.ICONS_PATH + attached_entity.icon_path)
	else:
		entity_texture = Globals.error_texture
	icon.texture = entity_texture
	name_label.fit_text = attached_entity.name

	updated.emit()
