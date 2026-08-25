class_name GameEntity



var id: String
var name: String
var image_name: String
var faction: Enums.Faction = Enums.Faction.NEUTRAL
var _components: Array[GameEntityComponent]



func add_component(new_component: GameEntityComponent):
	_components.append(new_component)


func has_component_type(type: Variant) -> bool:
	for component in _components:
		if (is_instance_of(component, type)):
			return true

	return false


func get_component_of_type(type: Variant) -> GameEntityComponent:
	for component in _components:
		if (is_instance_of(component, type)):
			return component

	return null


func get_components_of_type(type: Variant) -> Array[GameEntityComponent]:
	var result: Array[GameEntityComponent] = []

	for component in _components:
		if (is_instance_of(component, type)):
			result.append(component)

	return result