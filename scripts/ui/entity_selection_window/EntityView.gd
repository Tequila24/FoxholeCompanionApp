class_name EntityView
extends Control



signal pressed()
signal updated()


@export var _button: Button
@export var icon: TextureRect
@export var name_label: AutoFitRichTextLabel

var attached_entity: GameEntity



func _ready() -> void:
	_button.pressed.connect(
		func(): 
			print("Entity: %s" % name_label.fit_text)
			for attack_component: GameEntityComponentAttack in attached_entity.get_components_of_type(GameEntityComponentAttack):
				print("\t%s" % attack_component.ammo_used_ids[0])
			var vitals_component: GameEntityComponentVitals = attached_entity.get_component_of_type(GameEntityComponentVitals)
			if (vitals_component):
				print("\tResistance id: %s" % vitals_component.resistance_id)
			
	)


# func set_visual(entity: GameEntity) -> void:
# 	if (entity == null):
# 		return

# 	_current_entity = entity

# 	_icon.texture = entity.icon
# 	_name_label.text = entity.name

# 	updated.emit()
